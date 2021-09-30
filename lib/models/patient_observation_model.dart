import 'package:pegasus_medical_1808/models/share_option.dart';
import 'package:pegasus_medical_1808/services/navigation_service.dart';
import 'package:pegasus_medical_1808/shared/global_config.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../locator.dart';
import '../shared/global_config.dart';
import '../shared/global_functions.dart';
import './authentication_model.dart';
import '../shared/strings.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'authentication_model.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:connectivity/connectivity.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:image/image.dart' as FlutterImage;
import 'package:flutter/material.dart' as Material;
import '../models/share_option.dart';
import '../models/text_option.dart';
import '../utils/database.dart';
import 'package:sembast/sembast.dart' as Db;
import 'package:random_string/random_string.dart' as random_string;

import 'package:universal_html/html.dart' as html;


class PatientObservationModel extends ChangeNotifier {

  AuthenticationModel authenticationModel = AuthenticationModel();
  final NavigationService _navigationService = locator<NavigationService>();
  PatientObservationModel(this.authenticationModel);

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> _patientObservations = [];
  String _selPatientObservationId;
  final dateFormatDay = DateFormat("dd-MM-yyyy");

  List<Map<String, dynamic>> get allPatientObservations {
    return List.from(_patientObservations);
  }
  int get selectedPatientObservationIndex {
    return _patientObservations.indexWhere((Map<String, dynamic> patientObservation) {
      return patientObservation[Strings.documentId] == _selPatientObservationId;
    });
  }
  String get selectedPatientObservationId {
    return _selPatientObservationId;
  }

  Map<String, dynamic> get selectedPatientObservation {
    if (_selPatientObservationId == null) {
      return null;
    }
    return _patientObservations.firstWhere((Map<String, dynamic> patientObservation) {
      return patientObservation[Strings.documentId] == _selPatientObservationId;
    });
  }
  void selectPatientObservation(String patientObservationId) {
    _selPatientObservationId = patientObservationId;
    if (patientObservationId != null) {
      notifyListeners();
    }
  }

  void clearPatientObservations(){
    _patientObservations = [];
  }


  // Sembast database settings
  static const String TEMPORARY_PATIENT_OBSERVATIONS_STORE_NAME = 'temporary_patient_observations';
  final _temporaryPatientObservationsStore = Db.intMapStoreFactory.store(TEMPORARY_PATIENT_OBSERVATIONS_STORE_NAME);

  static const String PATIENT_OBSERVATIONS_STORE_NAME = 'patient_observation_timesheets';
  final _patientObservationsStore = Db.intMapStoreFactory.store(PATIENT_OBSERVATIONS_STORE_NAME);

  static const String EDITED_PATIENT_OBSERVATIONS_STORE_NAME = 'edited_patient_observations';
  final _editedPatientObservationsStore = Db.intMapStoreFactory.store(EDITED_PATIENT_OBSERVATIONS_STORE_NAME);

  static const String SAVED_PATIENT_OBSERVATIONS_STORE_NAME = 'saved_patient_observations';
  final _savedPatientObservationsStore = Db.intMapStoreFactory.store(SAVED_PATIENT_OBSERVATIONS_STORE_NAME);

  // Private getter to shorten the amount of code needed to get the
  // singleton instance of an opened database.
  Future<Db.Database> get _db async => await AppDatabase.instance.database;


  Future<void> setupTemporaryRecord() async {

    final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
        [Db.Filter.equals(Strings.uid, user.uid), Db.Filter.equals(Strings.jobId, '1')]
    ));
    List records = await _temporaryPatientObservationsStore.find(
      await _db,
      finder: finder,
    );
    if(records.length == 0){
      // Generate a random ID based on the date and a random string for virtual zero chance of duplicates
      int _id = DateTime.now().millisecondsSinceEpoch + int.parse(random_string.randomNumeric(2));
      await _temporaryPatientObservationsStore.record(_id).put(await _db,
          {Strings.uid : user.uid, Strings.formVersion: 1, Strings.jobId : '1'});
    }
  }

  Future<Map<String, dynamic>> getTemporaryRecord(bool edit, String selectedJobId, bool saved, int savedId) async{

    List records;

    if(edit){
      final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
          [Db.Filter.equals(Strings.documentId, selectedPatientObservation[Strings.documentId]), Db.Filter.equals(Strings.jobId, selectedJobId)]
      ));
      records = await _editedPatientObservationsStore.find(
        await _db,
        finder: finder,
      );
    } else if(saved) {
      final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
          [Db.Filter.equals(Strings.uid, user.uid), Db.Filter.equals(Strings.localId, savedId)]
      ));
      records = await _savedPatientObservationsStore.find(
        await _db,
        finder: finder,
      );
    } else {
      final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
          [Db.Filter.equals(Strings.uid, user.uid), Db.Filter.equals(Strings.jobId, selectedJobId)]
      ));
      records = await _temporaryPatientObservationsStore.find(
        await _db,
        finder: finder,
      );
    }

    return records[0].value;

  }

  Future<bool> checkPendingRecordExists() async{
    bool hasRecord = false;
    final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
        [Db.Filter.equals(Strings.uid, user.uid), Db.Filter.equals(Strings.serverUploaded, 0)]
    ));

    List records = await _patientObservationsStore.find(
      await _db,
      finder: finder,
    );

    if(records.length > 0) hasRecord = true;

    return hasRecord;
  }

  Future <List<dynamic>> getPendingRecords() async{
    final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
        [Db.Filter.equals(Strings.uid, user.uid), Db.Filter.equals(Strings.serverUploaded, 0)]
    ));

    List records = await _patientObservationsStore.find(
      await _db,
      finder: finder,
    );

    return records;
  }

  Future <void> deletePendingRecord(int localId) async{
    final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
        [Db.Filter.equals(Strings.uid, user.uid), Db.Filter.equals(Strings.localId, localId)]
    ));

    await _patientObservationsStore.delete(
      await _db,
      finder: finder,
    );
  }

  Future <List<dynamic>> getSavedRecords() async{
    final Db.Finder finder = Db.Finder(filter: Db.Filter.equals(Strings.uid, user.uid));
    List records = await _savedPatientObservationsStore.find(
      await _db,
      finder: finder,
    );
    return records;
  }

  Future<bool> checkRecordExists(bool edit, String selectedJobId, bool saved, int savedId) async{

    bool hasRecord = false;
    List records;


    if(edit){

      final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
          [Db.Filter.equals(Strings.documentId, selectedPatientObservation[Strings.documentId]), Db.Filter.equals(Strings.jobId, selectedJobId)]
      ));
      records = await _editedPatientObservationsStore.find(
        await _db,
        finder: finder,
      );
    } else if(saved){
      final Db.Finder finder = Db.Finder(filter: Db.Filter.equals(Strings.localId, savedId));
      records = await _savedPatientObservationsStore.find(
        await _db,
        finder: finder,
      );

    } else {

      final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
          [Db.Filter.equals(Strings.uid, user.uid), Db.Filter.equals(Strings.jobId, selectedJobId)]
      ));
      records = await _temporaryPatientObservationsStore.find(
        await _db,
        finder: finder,
      );
    }

    if(records.length > 0) hasRecord = true;


    return hasRecord;

  }

  Future<void> updateTemporaryRecord(bool edit, String field, var value, String selectedJobId, bool saved, int savedId) async {

    if(edit){
      final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
          [Db.Filter.equals(Strings.uid, user.uid), Db.Filter.equals(Strings.jobId, selectedJobId)]
      ));
      await _editedPatientObservationsStore.update(await _db, {field: value},
          finder: finder);
    } else if(saved){
      final Db.Finder finder = Db.Finder(filter: Db.Filter.equals(Strings.localId, savedId));
      await _savedPatientObservationsStore.update(await _db, {field: value},
          finder: finder);
    } else {
      final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
          [Db.Filter.equals(Strings.uid, user.uid), Db.Filter.equals(Strings.jobId, selectedJobId)]
      ));
      await _temporaryPatientObservationsStore.update(await _db, {field: value},
          finder: finder);

    }

  }

  void deleteEditedRecord() async {
    await _editedPatientObservationsStore.delete(await _db);
  }

  Future<void> setUpEditedRecord() async{

    Map<String, dynamic> editedReport = editedPatientObservation(selectedPatientObservation);
    Map<String, dynamic> localData = Map.from(editedReport);
    await _editedPatientObservationsStore.delete(await _db);
    int _id = DateTime.now().millisecondsSinceEpoch + int.parse(random_string.randomNumeric(2));
    await _editedPatientObservationsStore.record(_id).put(await _db,
        localData);

  }

  Future<void> deleteAllRows() async {
    await _patientObservationsStore.delete(await _db);
  }

  Future<bool> saveForLater(String jobId, bool saved, int savedId) async {

    GlobalFunctions.showLoadingDialog('Saving Patient Observation Timesheet...');
    String message = '';
    bool success = false;
    int id;

    if(saved){
      id = savedId;
    } else {
      id = DateTime.now().millisecondsSinceEpoch + int.parse(random_string.randomNumeric(2));
    }



    Map<String, dynamic> patientObservation = await getTemporaryRecord(false, '1', saved, savedId);

    Map<String, dynamic> localData = {
      Strings.localId: id,
      Strings.documentId: null,
      Strings.uid: user.uid,
      Strings.jobId: '1',
      Strings.formVersion: '1',
      Strings.jobRef: patientObservation[Strings.jobRef],
      Strings.patientObservationDate: patientObservation[Strings.patientObservationDate],
      Strings.patientObservationHospital: patientObservation[Strings.patientObservationHospital],
      Strings.patientObservationWard: patientObservation[Strings.patientObservationWard],
      Strings.patientObservationStartTime: patientObservation[Strings.patientObservationStartTime],
      Strings.patientObservationFinishTime: patientObservation[Strings.patientObservationFinishTime],
      Strings.patientObservationTotalHours: patientObservation[Strings.patientObservationTotalHours],
      Strings.patientObservationName: patientObservation[Strings.patientObservationName],
      Strings.patientObservationPosition: patientObservation[Strings.patientObservationPosition],
      Strings.patientObservationAuthorisedDate: patientObservation[Strings.patientObservationAuthorisedDate],
      Strings.patientObservationSignature: patientObservation[Strings.patientObservationSignature],
    };

    await _savedPatientObservationsStore.record(id).put(await _db,
        localData);

    message = 'Patient Observation Timesheet saved to device';
    success = true;

    if(success) resetTemporaryRecord(jobId, false, 0);
    GlobalFunctions.dismissLoadingDialog();
    GlobalFunctions.showToast(message);
    return success;
  }

  Future<void> deleteSavedRecord(int id) async {
    await _savedPatientObservationsStore.record(id).delete(await _db);
    _patientObservations.removeWhere((element) => element[Strings.localId] == id);
    notifyListeners();
  }

  Future<void> getSavedRecordsList() async{

    _isLoading = true;
    notifyListeners();
    String message = '';

    List<Map<String, dynamic>> _fetchedRecordList = [];

    try {

      List<dynamic> records = await getSavedRecords();

      if(records.length > 0){
        for(var record in records){
          _fetchedRecordList.add(record.value);
        }

        _patientObservations = List.from(_fetchedRecordList.reversed);
      } else {
        message = 'No saved records available';
      }

    } catch(e){
      print(e);
      message = 'Something went wrong. Please try again';

    }
    _isLoading = false;
    notifyListeners();
    _selPatientObservationId = null;
    if(message != '') GlobalFunctions.showToast(message);

  }

  void resetTemporaryRecord(String chosenJobId, bool saved, int savedId) async {

    Db.Finder finder;

    if(saved){
      finder = Db.Finder(filter: Db.Filter.equals(Strings.localId, savedId));
    } else {
      finder = Db.Finder(filter: Db.Filter.and(
          [Db.Filter.equals(Strings.uid, user.uid), Db.Filter.equals(Strings.jobId, chosenJobId)]
      ));
    }

    await _temporaryPatientObservationsStore.update(await _db, {
      Strings.formVersion: 1,
      Strings.jobRef: null,
      Strings.patientObservationDate: null,
      Strings.patientObservationHospital: null,
      Strings.patientObservationWard: null,
      Strings.patientObservationStartTime: null,
      Strings.patientObservationFinishTime: null,
      Strings.patientObservationTotalHours: null,
      Strings.patientObservationName: null,
      Strings.patientObservationPosition: null,
      Strings.patientObservationAuthorisedDate: null,
      Strings.patientObservationSignature: null,
      Strings.patientObservationSignaturePoints: null,
    },
        finder: finder);
    notifyListeners();
  }



  Future<bool> submitPatientObservation(String jobId, bool edit, bool saved, int savedId) async {

    GlobalFunctions.showLoadingDialog('Submitting Patient Observation Timesheet...');
    String message = '';
    bool success = false;
    List<String> storageUrlList = [];
    int id = DateTime.now().millisecondsSinceEpoch + int.parse(random_string.randomNumeric(2));
    //Sembast
    Map<String, dynamic> patientObservation = await getTemporaryRecord(false, jobId, saved, savedId);



    Map<String, dynamic> localData = {
      Strings.localId: id,
      Strings.documentId: null,
      Strings.uid: user.uid,
      Strings.jobId: '1',
      Strings.formVersion: '1',
      Strings.jobRef: patientObservation[Strings.jobRef],
      Strings.patientObservationDate: patientObservation[Strings.patientObservationDate],
      Strings.patientObservationHospital: patientObservation[Strings.patientObservationHospital],
      Strings.patientObservationWard: patientObservation[Strings.patientObservationWard],
      Strings.patientObservationStartTime: patientObservation[Strings.patientObservationStartTime],
      Strings.patientObservationFinishTime: patientObservation[Strings.patientObservationFinishTime],
      Strings.patientObservationTotalHours: patientObservation[Strings.patientObservationTotalHours],
      Strings.patientObservationName: patientObservation[Strings.patientObservationName],
      Strings.patientObservationPosition: patientObservation[Strings.patientObservationPosition],
      Strings.patientObservationAuthorisedDate: patientObservation[Strings.patientObservationAuthorisedDate],
      Strings.patientObservationSignature: patientObservation[Strings.patientObservationSignature],
      Strings.pendingTime: DateTime.now().toIso8601String(),
      Strings.serverUploaded: 0,
    };

    //Sembast
    await _patientObservationsStore.record(id).put(await _db,
        localData);

    message = 'Patient Observation Timesheet has successfully been added to local database';

    bool hasDataConnection = await GlobalFunctions.hasDataConnection();


    if(hasDataConnection){

      bool isTokenExpired = GlobalFunctions.isTokenExpired();
      bool authenticated = true;

      if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

      if(authenticated){


        try {

          DocumentReference ref =
          await FirebaseFirestore.instance.collection('patient_observation_timesheets').add({
            Strings.uid: user.uid,
            Strings.jobId: '1',
            Strings.formVersion: '1',
            Strings.jobRef: GlobalFunctions.databaseValueString(patientObservation[Strings.jobRef]),
            Strings.jobRefLowercase: GlobalFunctions.databaseValueString(patientObservation[Strings.jobRef]).toLowerCase(),
            Strings.patientObservationDate: patientObservation[Strings.patientObservationDate] == null ? null : DateTime.parse(patientObservation[Strings.patientObservationDate]),
            Strings.patientObservationHospital: patientObservation[Strings.patientObservationHospital],
            Strings.patientObservationWard: patientObservation[Strings.patientObservationWard],
            Strings.patientObservationStartTime: patientObservation[Strings.patientObservationStartTime],
            Strings.patientObservationFinishTime: patientObservation[Strings.patientObservationFinishTime],
            Strings.patientObservationTotalHours: patientObservation[Strings.patientObservationTotalHours],
            Strings.patientObservationName: patientObservation[Strings.patientObservationName],
            Strings.patientObservationPosition: patientObservation[Strings.patientObservationPosition],
            Strings.patientObservationAuthorisedDate: patientObservation[Strings.patientObservationAuthorisedDate] == null ? null : DateTime.parse(patientObservation[Strings.patientObservationAuthorisedDate]),
            Strings.patientObservationSignature: null,
            Strings.timestamp: FieldValue.serverTimestamp(),
            Strings.serverUploaded: 1,
          });

          DocumentSnapshot snap = await ref.get();

          //Signatures
          String patientObservationSignatureUrl;
          bool patientObservationSignatureSuccess = true;

          if(patientObservation[Strings.patientObservationSignature] != null){
            patientObservationSignatureSuccess = false;

            Reference storageRef =
            FirebaseStorage.instance.ref().child('patientObservationImages/' + snap.id + '/patientObservationSignature.jpg');

            if(kIsWeb){
              storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/patientObservationImages/' + snap.id + '/patientObservationSignature.jpg');
            }

            final UploadTask uploadTask = storageRef.putData(Uint8List.fromList(patientObservation[Strings.patientObservationSignature].toList().cast<int>()));
            final TaskSnapshot downloadUrl = (await uploadTask);
            patientObservationSignatureUrl = (await downloadUrl.ref.getDownloadURL());
            if(patientObservationSignatureUrl != null){
              patientObservationSignatureSuccess = true;
              storageUrlList.add('patientObservationImages/' + snap.id + '/patientObservationSignature.jpg');
            }

          }

          if(patientObservationSignatureSuccess){

            await FirebaseFirestore.instance.collection('patient_observation_timesheets').doc(snap.id).update({
              Strings.patientObservationSignature: patientObservationSignatureUrl == null ? null : patientObservationSignatureUrl,
            }).timeout(Duration(seconds: 60));


            //Sembast
            await _patientObservationsStore.record(id).delete(await _db);
            if(saved){
              deleteSavedRecord(savedId);
            }
            message = 'Patient Observation Timesheet uploaded successfully';
            success = true;


          } else {
            await FirebaseFirestore.instance.collection('patient_observation_timesheets').doc(snap.id).delete();
          }

        } on TimeoutException catch (_) {
          // A timeout occurred.
          message = 'Network Timeout communicating with the server, unable to upload Patient Observation Timesheet';

        } catch (e) {
          print(e);
          message = e.toString();
          print(e);
        }
      }

    } else {

      message = 'No data connection, Patient Observation Timesheet has been saved locally, please upload when you have a valid connection';
      success = true;

    }

    //Sembast
    if(success) resetTemporaryRecord(jobId, saved, savedId);

    GlobalFunctions.dismissLoadingDialog();
    if(edit){
      _navigationService.goBack();
      _navigationService.goBack();
    }
    if(saved){
      _navigationService.goBack();
    }
    GlobalFunctions.showToast(message);
    return success;
  }

  Future<bool> editPatientObservation(String jobId, [bool edit = false]) async {

    GlobalFunctions.showLoadingDialog('Editing Patient Observation Timesheet...');
    String message = '';
    bool success = false;
    List<String> storageUrlList = [];

    Map<String, dynamic> patientObservation = await getTemporaryRecord(true, jobId, false, 0);
    bool hasDataConnection = await GlobalFunctions.hasDataConnection();


    if(hasDataConnection){

      bool isTokenExpired = GlobalFunctions.isTokenExpired();
      bool authenticated = true;

      if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

      if(authenticated){


        try {

          await FirebaseFirestore.instance.collection('patient_observation_timesheets').doc(patientObservation[Strings.documentId]).update({
            Strings.jobId: '1',
            Strings.formVersion: '1',
            Strings.jobRef: GlobalFunctions.databaseValueString(patientObservation[Strings.jobRef]),
            Strings.jobRefLowercase: GlobalFunctions.databaseValueString(patientObservation[Strings.jobRef]).toLowerCase(),
            Strings.patientObservationDate: patientObservation[Strings.patientObservationDate] == null ? null : DateTime.parse(patientObservation[Strings.patientObservationDate]),
            Strings.patientObservationHospital: patientObservation[Strings.patientObservationHospital],
            Strings.patientObservationWard: patientObservation[Strings.patientObservationWard],
            Strings.patientObservationStartTime: patientObservation[Strings.patientObservationStartTime],
            Strings.patientObservationFinishTime: patientObservation[Strings.patientObservationFinishTime],
            Strings.patientObservationTotalHours: patientObservation[Strings.patientObservationTotalHours],
            Strings.patientObservationName: patientObservation[Strings.patientObservationName],
            Strings.patientObservationPosition: patientObservation[Strings.patientObservationPosition],
            Strings.patientObservationAuthorisedDate: patientObservation[Strings.patientObservationAuthorisedDate] == null ? null : DateTime.parse(patientObservation[Strings.patientObservationAuthorisedDate]),
            Strings.serverUploaded: 1
          });

          //Sembast

          final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
              [Db.Filter.equals(Strings.documentId, selectedPatientObservation[Strings.documentId]), Db.Filter.equals(Strings.jobId, jobId)]
          ));

          await _editedPatientObservationsStore.delete(await _db,
              finder: finder);
          message = 'Patient Observation Timesheet uploaded successfully';
          success = true;
          getPatientObservations();

        } on TimeoutException catch (_) {
          // A timeout occurred.
          message = 'Network Timeout communicating with the server, unable to edit Patient Observation Timesheet';

        } catch (e) {
          print(e);
          message = e.toString();
          print(e);
        }
      }

    } else {

      message = 'No data connection, unable to edit form';

    }

    GlobalFunctions.dismissLoadingDialog();
    if(success){
      _navigationService.goBack();
      _navigationService.goBack();
      deleteEditedRecord();
    }
    GlobalFunctions.showToast(message);
    return success;


  }


  Future<void> getPatientObservations() async{

    _isLoading = true;
    notifyListeners();
    String message = '';

    List<Map<String, dynamic>> _fetchedPatientObservationList = [];

    try {

      bool hasDataConnection = await GlobalFunctions.hasDataConnection();

      if(!hasDataConnection){

        GlobalFunctions.showToast('No data connection, unable to fetch Patient Observation Timesheets');
        _patientObservations = [];
      } else {


        bool isTokenExpired = GlobalFunctions.isTokenExpired();
        bool authenticated = true;

        if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

        if(authenticated){


          QuerySnapshot snapshot;

          if(user.role == 'Super User'){
            try{
              snapshot = await FirebaseFirestore.instance.collection('patient_observation_timesheets').orderBy('timestamp', descending: true).limit(10).get().timeout(Duration(seconds: 90));
            } catch(e){
              print(e);
            }
          } else {
            try{
              snapshot = await FirebaseFirestore.instance.collection('patient_observation_timesheets').where(
                  'uid', isEqualTo: user.uid).orderBy('timestamp', descending: true).limit(10).get().timeout(Duration(seconds: 90));
            } catch(e){
              print(e);
            }
          }


          Map<String, dynamic> snapshotData = {};

          if(snapshot.docs.length < 1){
            message = 'No Patient Observation Timesheets found';
          } else {
            for (DocumentSnapshot snap in snapshot.docs) {

              snapshotData = snap.data();

              Uint8List patientObservationSignature;

              if (snapshotData[Strings.patientObservationSignature] != null) {
                Reference storageRef =
                FirebaseStorage.instance.ref().child('patientObservationImages/' + snap.id + '/patientObservationSignature.jpg');

                if(kIsWeb){
                  storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/patientObservationImages/' + snap.id + '/patientObservationSignature.jpg');

                }

                patientObservationSignature = await storageRef.getData(dataLimit);
              }


              final Map<String, dynamic> patientObservation = onlinePatientObservation(snapshotData, snap.id, patientObservationSignature);

              _fetchedPatientObservationList.add(patientObservation);

            }

            _patientObservations = _fetchedPatientObservationList;
          }


        }

      }


    } on TimeoutException catch (_) {
      // A timeout occurred.
      message = 'Network Timeout communicating with the server, unable to fetch latest Patient Observation Timesheets';
    } catch(e){
      print(e);
      message = 'Something went wrong. Please try again';

    }

    _isLoading = false;
    notifyListeners();
    _selPatientObservationId = null;
    if(message != '') GlobalFunctions.showToast(message);

  }

  Future<void> getMorePatientObservations() async{

    String message = '';

    List<Map<String, dynamic>> _fetchedPatientObservationList = [];

    try {

      bool hasDataConnection = await GlobalFunctions.hasDataConnection();

      if(!hasDataConnection){

        GlobalFunctions.showToast('No data connection, unable to fetch Patient Observation Timesheets');

      } else {


        bool isTokenExpired = GlobalFunctions.isTokenExpired();
        bool authenticated = true;

        if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

        if(authenticated){


          QuerySnapshot snapshot;
          int currentLength = _patientObservations.length;
          DateTime latestDate = DateTime.parse(_patientObservations[currentLength - 1][Strings.timestamp]);

          if(user.role == 'Super User'){
            try {
              snapshot = await FirebaseFirestore.instance.collection('patient_observation_timesheets').orderBy(
                  'timestamp', descending: true).startAfter(
                  [Timestamp.fromDate(latestDate)]).limit(10)
                  .get()
                  .timeout(Duration(seconds: 90));
            } catch(e) {
              print(e);
            }

          } else {
            try {
              snapshot = await FirebaseFirestore.instance.collection('patient_observation_timesheets').where(
                  'uid', isEqualTo: user.uid).orderBy(
                  'timestamp', descending: true).startAfter(
                  [Timestamp.fromDate(latestDate)]).limit(10)
                  .get()
                  .timeout(Duration(seconds: 90));
            } catch(e) {
              print(e);
            }
          }


          Map<String, dynamic> snapshotData = {};

          if(snapshot.docs.length < 1){
            message = 'No more Patient Observation Timesheets found';
          } else {
            for (DocumentSnapshot snap in snapshot.docs) {

              snapshotData = snap.data();

              Uint8List patientObservationSignature;

              if (snapshotData[Strings.patientObservationSignature] != null) {
                Reference storageRef =
                FirebaseStorage.instance.ref().child('patientObservationImages/' + snap.id + '/patientObservationSignature.jpg');

                if(kIsWeb){
                  storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/patientObservationImages/' + snap.id + '/patientObservationSignature.jpg');
                }
                patientObservationSignature = await storageRef.getData(dataLimit);
              }

              final Map<String, dynamic> patientObservation = onlinePatientObservation(snapshotData, snap.id, patientObservationSignature);

              _fetchedPatientObservationList.add(patientObservation);

            }

            _patientObservations.addAll(_fetchedPatientObservationList);
          }


        }

      }


    } on TimeoutException catch (_) {
      // A timeout occurred.
      message = 'Network Timeout communicating with the server, unable to fetch latest Patient Observation Timesheets';
    } catch(e){
      print(e);
      message = 'Something went wrong. Please try again';

    }

    _isLoading = false;
    notifyListeners();
    _selPatientObservationId = null;
    if(message != '') GlobalFunctions.showToast(message);

  }

  Future<bool> searchPatientObservations(DateTime dateFrom, DateTime dateTo, String jobRef, String selectedUser) async{

    _isLoading = true;
    notifyListeners();
    bool success = false;
    String message = '';
    GlobalFunctions.showLoadingDialog('Searching Forms');
    List<Map<String, dynamic>> _fetchedPatientObservationList = [];

    try {

      bool hasDataConnection = await GlobalFunctions.hasDataConnection();

      if(!hasDataConnection){

        message = 'No Data Connection, unable to search Patient Observation Timesheets';

      } else {


        bool isTokenExpired = GlobalFunctions.isTokenExpired();
        bool authenticated = true;

        if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

        if(authenticated){


          QuerySnapshot snapshot;

          if(user.role == 'Super User'){



            if(dateFrom != null && dateTo != null){


              if(jobRef == null || jobRef.trim() == ''){


                if(selectedUser != null){
                  try{
                    snapshot =
                    await FirebaseFirestore.instance.collection('patient_observation_timesheets')
                        .where(Strings.uid, isEqualTo: selectedUser).orderBy('timestamp', descending: true)
                        .startAt([dateTo]).endAt([dateFrom]).get()
                        .timeout(Duration(seconds: 90));
                  } catch(e){
                    print(e);
                  }
                } else {
                  try{
                    snapshot =
                    await FirebaseFirestore.instance.collection('patient_observation_timesheets').orderBy('timestamp', descending: true)
                        .startAt([dateTo]).endAt([dateFrom]).get()
                        .timeout(Duration(seconds: 90));
                  } catch(e){
                    print(e);
                  }
                }


              } else {

                if(selectedUser != null){
                  try{
                    snapshot =
                    await FirebaseFirestore.instance.collection('patient_observation_timesheets').where(Strings.uid, isEqualTo: selectedUser).
                    where(Strings.jobRefLowercase, isEqualTo: jobRef.toLowerCase()).orderBy('timestamp', descending: true)
                        .startAt([dateTo]).endAt([dateFrom]).get()
                        .timeout(Duration(seconds: 90));
                  } catch(e){
                    print(e);
                  }
                } else {
                  try{
                    snapshot =
                    await FirebaseFirestore.instance.collection('patient_observation_timesheets')
                        .where(Strings.jobRefLowercase, isEqualTo: jobRef.toLowerCase()).orderBy('timestamp', descending: true)
                        .startAt([dateTo]).endAt([dateFrom]).get()
                        .timeout(Duration(seconds: 90));
                  } catch(e){
                    print(e);
                  }
                }




              }

            } else {


              if(jobRef == null || jobRef.trim() == ''){

                if(selectedUser != null){
                  try{
                    snapshot =
                    await FirebaseFirestore.instance.collection('patient_observation_timesheets')
                        .where(Strings.uid, isEqualTo: selectedUser).orderBy('timestamp', descending: true)
                        .get()
                        .timeout(Duration(seconds: 90));
                  } catch(e){
                    print(e);
                  }
                } else {
                  try{
                    snapshot =
                    await FirebaseFirestore.instance.collection('patient_observation_timesheets').orderBy('timestamp', descending: true)
                        .get()
                        .timeout(Duration(seconds: 90));
                  } catch(e){
                    print(e);
                  }
                }




              } else {

                if(selectedUser != null){
                  try{
                    snapshot =
                    await FirebaseFirestore.instance.collection('patient_observation_timesheets')
                        .where(Strings.jobRefLowercase, isEqualTo: jobRef.toLowerCase())
                        .where(Strings.uid, isEqualTo: selectedUser).orderBy('timestamp', descending: true)
                        .get()
                        .timeout(Duration(seconds: 90));
                  } catch(e){
                    print(e);
                  }
                } else {
                  try{
                    snapshot =
                    await FirebaseFirestore.instance.collection('patient_observation_timesheets')
                        .where(Strings.jobRefLowercase, isEqualTo: jobRef.toLowerCase())
                        .orderBy('timestamp', descending: true)
                        .get()
                        .timeout(Duration(seconds: 90));
                  } catch(e){
                    print(e);
                  }
                }



              }

            }

          } else {


            if(dateFrom != null && dateTo != null){


              if(jobRef == null || jobRef.trim() == ''){

                try{
                  snapshot =
                  await FirebaseFirestore.instance.collection('patient_observation_timesheets')
                      .where(Strings.uid, isEqualTo: user.uid).orderBy('timestamp', descending: true)
                      .startAt([dateTo]).endAt([dateFrom]).get()
                      .timeout(Duration(seconds: 90));
                } catch(e){
                  print(e);
                }


              } else {


                try{
                  snapshot =
                  await FirebaseFirestore.instance.collection('patient_observation_timesheets')
                      .where(Strings.jobRefLowercase, isEqualTo: jobRef.toLowerCase())
                      .where(Strings.uid, isEqualTo: user.uid).orderBy('timestamp', descending: true)
                      .startAt([dateTo]).endAt([dateFrom]).get()
                      .timeout(Duration(seconds: 90));
                } catch(e){
                  print(e);
                }
              }


            } else {


              if(jobRef == null || jobRef.trim() == ''){

                try{
                  snapshot =
                  await FirebaseFirestore.instance.collection('patient_observation_timesheets')
                      .where(Strings.uid, isEqualTo: user.uid).orderBy('timestamp', descending: true)
                      .get()
                      .timeout(Duration(seconds: 90));
                } catch(e){
                  print(e);
                }


              } else {

                try{
                  snapshot =
                  await FirebaseFirestore.instance.collection('patient_observation_timesheets')
                      .where(Strings.jobRefLowercase, isEqualTo: jobRef.toLowerCase())
                      .where(Strings.uid, isEqualTo: user.uid).orderBy('timestamp', descending: true)
                      .get()
                      .timeout(Duration(seconds: 90));
                } catch(e){
                  print(e);
                }
              }

            }




          }

          Map<String, dynamic> snapshotData = {};

          if(snapshot.docs.length < 1){
            message = 'No Patient Observation Timesheets found';
          } else {
            for (DocumentSnapshot snap in snapshot.docs) {

              snapshotData = snap.data();

              Uint8List patientObservationSignature;

              if (snapshotData[Strings.patientObservationSignature] != null) {
                Reference storageRef =
                FirebaseStorage.instance.ref().child('patientObservationImages/' + snap.id + '/patientObservationSignature.jpg');

                if(kIsWeb){
                  storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/patientObservationImages/' + snap.id + '/patientObservationSignature.jpg');
                }
                patientObservationSignature = await storageRef.getData(dataLimit);
              }

              final Map<String, dynamic> patientObservation = onlinePatientObservation(snapshotData, snap.id, patientObservationSignature);

              _fetchedPatientObservationList.add(patientObservation);

            }

            _patientObservations = _fetchedPatientObservationList;
            success = true;
          }


        }

      }


    } on TimeoutException catch (_) {
      // A timeout occurred.
      message = 'Network Timeout communicating with the server, unable to search Patient Observation Timesheets';
    } catch(e){
      print(e);
      message = 'Something went wrong. Please try again';

    }

    _isLoading = false;
    notifyListeners();
    _selPatientObservationId = null;
    GlobalFunctions.dismissLoadingDialog();
    if(message != '') GlobalFunctions.showToast(message);
    return success;

  }


  Future<bool> searchMorePatientObservations(DateTime dateFrom, DateTime dateTo) async{

    _isLoading = true;
    notifyListeners();
    bool success = false;
    String message = '';
    GlobalFunctions.showLoadingDialog('Searching Forms');
    List<Map<String, dynamic>> _fetchedPatientObservationList = [];

    try {

      bool hasDataConnection = await GlobalFunctions.hasDataConnection();

      if(!hasDataConnection){

        message = 'No Data Connection, unable to search Patient Observation Timesheets';

      } else {


        bool isTokenExpired = GlobalFunctions.isTokenExpired();
        bool authenticated = true;

        if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

        if(authenticated){


          QuerySnapshot snapshot;
          int currentLength = _patientObservations.length;
          DateTime latestDate = DateTime.parse(_patientObservations[currentLength - 1]['timestamp']);

          if(user.role == 'Super User'){
            try{
              snapshot =
              await FirebaseFirestore.instance.collection('patient_observation_timesheets').orderBy('timestamp', descending: true)
                  .startAfter([Timestamp.fromDate(latestDate)]).endAt([dateFrom]).limit(10).get()
                  .timeout(Duration(seconds: 90));
            } catch(e){
              print(e);
            }

          } else {

            try{
              snapshot =
              await FirebaseFirestore.instance.collection('patient_observation_timesheets').where('uid', isEqualTo: user.uid).orderBy('timestamp', descending: true)
                  .startAfter([Timestamp.fromDate(latestDate)]).endAt([dateFrom]).limit(10).get()
                  .timeout(Duration(seconds: 90));
            } catch(e){
              print(e);
            }

          }

          Map<String, dynamic> snapshotData = {};

          if(snapshot.docs.length < 1){
            message = 'No Patient Observation Timesheets found';
          } else {
            for (DocumentSnapshot snap in snapshot.docs) {

              snapshotData = snap.data();

              Uint8List patientObservationSignature;

              if (snapshotData[Strings.patientObservationSignature] != null) {
                Reference storageRef =
                FirebaseStorage.instance.ref().child('patientObservationImages/' + snap.id + '/patientObservationSignature.jpg');

                if(kIsWeb){
                  storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/patientObservationImages/' + snap.id + '/patientObservationSignature.jpg');
                }
                patientObservationSignature = await storageRef.getData(dataLimit);
              }

              final Map<String, dynamic> patientObservation = onlinePatientObservation(snapshotData, snap.id, patientObservationSignature);

              _fetchedPatientObservationList.add(patientObservation);

            }

            _patientObservations.addAll(_fetchedPatientObservationList);
            success = true;
          }


        }

      }


    } on TimeoutException catch (_) {
      // A timeout occurred.
      message = 'Network Timeout communicating with the server, unable to search Patient Observation Timesheets';
    } catch(e){
      print(e);
      message = 'Something went wrong. Please try again';

    }

    _isLoading = false;
    notifyListeners();
    _selPatientObservationId = null;
    GlobalFunctions.dismissLoadingDialog();
    if(message != '') GlobalFunctions.showToast(message);
    return success;

  }


  Map<String, dynamic> localPatientObservation(Map<String, dynamic> localRecord){
    return {
      Strings.documentId: GlobalFunctions.databaseValueString(localRecord[Strings.documentId]),
      Strings.uid: GlobalFunctions.databaseValueString(localRecord[Strings.uid]),
      Strings.jobId: localRecord[Strings.jobId],
      Strings.formVersion: localRecord[Strings.formVersion],
      Strings.jobRef: localRecord[Strings.jobRef],
      Strings.patientObservationDate: localRecord[Strings.patientObservationDate],
      Strings.patientObservationHospital: localRecord[Strings.patientObservationHospital],
      Strings.patientObservationWard: localRecord[Strings.patientObservationWard],
      Strings.patientObservationStartTime: localRecord[Strings.patientObservationStartTime],
      Strings.patientObservationFinishTime: localRecord[Strings.patientObservationFinishTime],
      Strings.patientObservationTotalHours: localRecord[Strings.patientObservationTotalHours],
      Strings.patientObservationName: localRecord[Strings.patientObservationName],
      Strings.patientObservationPosition: localRecord[Strings.patientObservationPosition],
      Strings.patientObservationAuthorisedDate: localRecord[Strings.patientObservationAuthorisedDate],
      Strings.patientObservationSignature: localRecord[Strings.patientObservationSignature],
      Strings.patientObservationSignaturePoints: localRecord[Strings.patientObservationSignaturePoints],
      Strings.serverUploaded: localRecord[Strings.serverUploaded],
      Strings.timestamp: localRecord[Strings.timestamp] == null ? null : localRecord[Strings.timestamp]
    };
  }

  Map<String, dynamic> onlinePatientObservation(Map<String, dynamic> localRecord, String docId, Uint8List patientObservationSignature){
    return {
      Strings.documentId: docId,
      Strings.uid: GlobalFunctions.databaseValueString(localRecord[Strings.uid]),
      Strings.jobId: localRecord[Strings.jobId],
      Strings.formVersion: localRecord[Strings.formVersion],
      Strings.jobRef: localRecord[Strings.jobRef],
      Strings.patientObservationDate: localRecord[Strings.patientObservationDate] == null ? null : DateTime
          .fromMillisecondsSinceEpoch(
          localRecord[Strings.patientObservationDate].millisecondsSinceEpoch)
          .toIso8601String(),
      Strings.patientObservationHospital: localRecord[Strings.patientObservationHospital],
      Strings.patientObservationWard: localRecord[Strings.patientObservationWard],
      Strings.patientObservationStartTime: localRecord[Strings.patientObservationStartTime],
      Strings.patientObservationFinishTime: localRecord[Strings.patientObservationFinishTime],
      Strings.patientObservationTotalHours: localRecord[Strings.patientObservationTotalHours],
      Strings.patientObservationName: localRecord[Strings.patientObservationName],
      Strings.patientObservationPosition: localRecord[Strings.patientObservationPosition],
      Strings.patientObservationAuthorisedDate: localRecord[Strings.patientObservationAuthorisedDate] == null ? null : DateTime
          .fromMillisecondsSinceEpoch(
          localRecord[Strings.patientObservationAuthorisedDate].millisecondsSinceEpoch)
          .toIso8601String(),
      Strings.patientObservationSignature: patientObservationSignature,
      Strings.serverUploaded: localRecord[Strings.serverUploaded],
      Strings.timestamp: localRecord[Strings.timestamp] == null ? null : DateTime
          .fromMillisecondsSinceEpoch(
          localRecord['timestamp'].millisecondsSinceEpoch)
          .toIso8601String()
    };
  }

  Map<String, dynamic> editedPatientObservation(Map<String, dynamic> localRecord){
    return {
      Strings.documentId: GlobalFunctions.databaseValueString(localRecord[Strings.documentId]),
      Strings.uid: GlobalFunctions.databaseValueString(localRecord[Strings.uid]),
      Strings.jobId: localRecord[Strings.jobId],
      Strings.formVersion: localRecord[Strings.formVersion],
      Strings.jobRef: localRecord[Strings.jobRef],
      Strings.patientObservationDate: localRecord[Strings.patientObservationDate],
      Strings.patientObservationHospital: localRecord[Strings.patientObservationHospital],
      Strings.patientObservationWard: localRecord[Strings.patientObservationWard],
      Strings.patientObservationStartTime: localRecord[Strings.patientObservationStartTime],
      Strings.patientObservationFinishTime: localRecord[Strings.patientObservationFinishTime],
      Strings.patientObservationTotalHours: localRecord[Strings.patientObservationTotalHours],
      Strings.patientObservationName: localRecord[Strings.patientObservationName],
      Strings.patientObservationPosition: localRecord[Strings.patientObservationPosition],
      Strings.patientObservationAuthorisedDate: localRecord[Strings.patientObservationAuthorisedDate],
      Strings.patientObservationSignature: localRecord[Strings.patientObservationSignature],
      Strings.patientObservationSignaturePoints: localRecord[Strings.patientObservationSignaturePoints],
      Strings.serverUploaded: localRecord[Strings.serverUploaded],
      Strings.timestamp: localRecord[Strings.timestamp]
    };
  }



  Future<Map<String, dynamic>> uploadPendingPatientObservations() async {
    _isLoading = true;
    String message = 'Something went wrong!';
    bool success = false;
    List<String> storageUrlList = [];

    try {

      List<dynamic> patientObservationRecords = await getPendingRecords();

      List<Map<String, dynamic>> patientObservations = [];

      for(var patientObservationRecord in patientObservationRecords){
        patientObservations.add(patientObservationRecord.value);
      }


      bool isTokenExpired = GlobalFunctions.isTokenExpired();
      bool authenticated = true;

      if (isTokenExpired)
        authenticated = await authenticationModel.reAuthenticate();

      if (authenticated) {

        for (Map<String, dynamic> patientObservation in patientObservations) {

          success = false;

          DocumentReference ref =
          await FirebaseFirestore.instance.collection('patient_observation_timesheets').add({
            Strings.uid: user.uid,
            Strings.jobId: '1',
            Strings.formVersion: '1',
            Strings.jobRef: GlobalFunctions.databaseValueString(patientObservation[Strings.jobRef]),
            Strings.jobRefLowercase: GlobalFunctions.databaseValueString(patientObservation[Strings.jobRef]).toLowerCase(),
            Strings.patientObservationDate: patientObservation[Strings.patientObservationDate] == null ? null : DateTime.parse(patientObservation[Strings.patientObservationDate]),
            Strings.patientObservationHospital: patientObservation[Strings.patientObservationHospital],
            Strings.patientObservationWard: patientObservation[Strings.patientObservationWard],
            Strings.patientObservationStartTime: patientObservation[Strings.patientObservationStartTime],
            Strings.patientObservationFinishTime: patientObservation[Strings.patientObservationFinishTime],
            Strings.patientObservationTotalHours: patientObservation[Strings.patientObservationTotalHours],
            Strings.patientObservationName: patientObservation[Strings.patientObservationName],
            Strings.patientObservationPosition: patientObservation[Strings.patientObservationPosition],
            Strings.patientObservationAuthorisedDate: patientObservation[Strings.patientObservationAuthorisedDate] == null ? null : DateTime.parse(patientObservation[Strings.patientObservationAuthorisedDate]),
            Strings.patientObservationSignature: null,
            Strings.timestamp: FieldValue.serverTimestamp(),
            Strings.serverUploaded: 1,
          });

          DocumentSnapshot snap = await ref.get();

          //Signatures
          String patientObservationSignatureUrl;
          bool patientObservationSignatureSuccess = true;

          if(patientObservation[Strings.patientObservationSignature] != null){
            patientObservationSignatureSuccess = false;

            Reference storageRef =
            FirebaseStorage.instance.ref().child('patientObservationImages/' + snap.id + '/patientObservationSignature.jpg');

            if(kIsWeb){
              storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/patientObservationImages/' + snap.id + '/patientObservationSignature.jpg');
            }
            final UploadTask uploadTask = storageRef.putData(Uint8List.fromList(patientObservation[Strings.patientObservationSignature].toList().cast<int>()));
            final TaskSnapshot downloadUrl = (await uploadTask);
            patientObservationSignatureUrl = (await downloadUrl.ref.getDownloadURL());
            if(patientObservationSignatureUrl != null){
              patientObservationSignatureSuccess = true;
              storageUrlList.add('patientObservationImages/' + snap.id + '/patientObservationSignature.jpg');
            }

          }


          if(patientObservationSignatureSuccess){

            await FirebaseFirestore.instance.collection('patient_observation_timesheets').doc(snap.id).update({
              Strings.patientObservationSignature: patientObservationSignatureUrl == null ? null : patientObservationSignatureUrl,
            }).timeout(Duration(seconds: 60));

            await deletePendingRecord(patientObservation[Strings.localId]);
            success = true;


          } else {
            await FirebaseFirestore.instance.collection('patient_observation_timesheets').doc(snap.id).delete();
          }

        }

        message = 'Data Successfully Uploaded';

      }
    } on TimeoutException catch (_) {
      // A timeout occurred.
      message =
      'Network Timeout communicating with the server, unable to upload Data';
    } catch (e) {

      print(e);
    }


    _isLoading = false;
    notifyListeners();
    return {'success': success, 'message': message};
  }


  Future<void> setUpEditedPatientObservation() async{

    Map<String, dynamic> editedReport = editedPatientObservation(selectedPatientObservation);
    Map<String, dynamic> localData = Map.from(editedReport);
    await _editedPatientObservationsStore.delete(await _db);
    int _id = DateTime.now().millisecondsSinceEpoch + int.parse(random_string.randomNumeric(2));
    await _editedPatientObservationsStore.record(_id).put(await _db,
        localData);




  }




  Future<bool> sharePdf(ShareOption option, [List<String> emailList]) async {

    bool success = false;
    final dateFormat = DateFormat("dd/MM/yyyy");
    final timeFormat = DateFormat("HH:mm");
    final ByteData fontData = await rootBundle.load("assets/fonts/OpenSans-Regular.ttf");
    final Font ttf = Font.ttf(fontData.buffer.asByteData());
    final ByteData fontDataBold = await rootBundle.load("assets/fonts/OpenSans-Bold.ttf");
    final Font ttfBold = Font.ttf(fontDataBold.buffer.asByteData());


    Widget sectionTitle(String text){
      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text, style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 9, fontWeight: FontWeight.bold)),
            Container(height: 5)
          ]
      );
    }

    Widget textField(TextOption option, String value, [double width = 120, double minHeight = 20, double maxHeight]) {


      if(option == TextOption.Date){
        if(value == null){
          value = '';
        } else {
          value = dateFormat.format(DateTime.parse(value));
        }
      } else if(option == TextOption.PlainText){
        if(value == null){
          value = '';
        } else {
          value = value;
        }
      } else if(option == TextOption.EncryptedText){
        if(value == null){
          value = '';
        } else {
          value = GlobalFunctions.decryptString(value);
        }
      } else if(option == TextOption.Time){
        if(value == null){
          value = '';
        } else {
          value = timeFormat.format(DateTime.parse(value));
        }
      } else if(option == TextOption.EncryptedDate){
        if(value == null){
          value = '';
        } else {
          value = dateFormat.format(DateTime.parse(GlobalFunctions.decryptString(value)));
        }
      } else if(option == TextOption.EncryptedText){
        if(value == null){
          value = '';
        } else {
          value = GlobalFunctions.decryptString(value);
        }
      }

      return ConstrainedBox(constraints: maxHeight == null ? BoxConstraints(minHeight: minHeight) : BoxConstraints(minHeight: minHeight, maxHeight: maxHeight),
          child: Container(
            width: width,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: 5,
              border: BoxBorder(
                top: true,
                left: true,
                right: true,
                bottom: true,
                width: 1,
                color: PdfColors.grey,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(value, style: TextStyle(fontSize: 8)),
              ],
            ),
          ));
    }

    Widget signatureField(FlutterImage.Image signature, PdfDocument doc) {

      return ConstrainedBox(constraints: BoxConstraints(minHeight: 20),
          child: Container(
            width: 120,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              borderRadius: 5,
              border: BoxBorder(
                top: true,
                left: true,
                right: true,
                bottom: true,
                width: 1,
                color: PdfColors.grey,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                signature == null ? Text('') : Container(height: 20, child: FittedBox(alignment: Alignment.centerLeft, child: Image(PdfImage(doc,
                    image: signature.data.buffer
                        .asUint8List(),
                    width: signature.width,
                    height: signature.height)))),
              ],
            ),
          ));
    }

    Widget singleLineField(String text, String value, [TextOption option = TextOption.EncryptedText, bool small = false]){

      if(option == TextOption.Date){
        if(value == null){
          value = '';
        } else {
          value = dateFormat.format(DateTime.parse(value));
        }
      } else if(option == TextOption.PlainText){
        if(value == null){
          value = '';
        } else {
          value = value;
        }
      } else if(option == TextOption.EncryptedText){
        if(value == null){
          value = '';
        } else {
          value = GlobalFunctions.decryptString(value);
        }
      } else if(option == TextOption.Time){
        if(value == null){
          value = '';
        } else {
          value = timeFormat.format(DateTime.parse(value));
        }
      } else if(option == TextOption.EncryptedDate){
        if(value == null){
          value = '';
        } else {
          value = dateFormat.format(DateTime.parse(GlobalFunctions.decryptString(value)));
        }
      } else if(option == TextOption.EncryptedText){
        if(value == null){
          value = '';
        } else {
          value = GlobalFunctions.decryptString(value);
        }
      }



      return Column(
          children: [
            Row(
                children: [
                  Container(width: 90, child: Text(text, style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 8))),
                  SizedBox(width: 5),
                  small ? ConstrainedBox(constraints: BoxConstraints(minHeight: 20),
                      child: Container(
                        width: 158,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          borderRadius: 5,
                          border: BoxBorder(
                            top: true,
                            left: true,
                            right: true,
                            bottom: true,
                            width: 1,
                            color: PdfColors.grey,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(value == null ? '' : value, style: TextStyle(fontSize: 8)),
                          ],
                        ),
                      )) :Expanded(child: ConstrainedBox(constraints: BoxConstraints(minHeight: 20),
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          borderRadius: 5,
                          border: BoxBorder(
                            top: true,
                            left: true,
                            right: true,
                            bottom: true,
                            width: 1,
                            color: PdfColors.grey,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(value == null ? '' : value, style: TextStyle(fontSize: 8)),
                          ],
                        ),
                      ))),
                ]
            ),
            Container(height: 4)
          ]
      );
    }

    Widget doubleLineField(String text1, String value1, String text2, String value2, [TextOption option1 = TextOption.EncryptedText, TextOption option2 = TextOption.EncryptedText, FlutterImage.Image signature, PdfDocument doc]){

      if(option1 == TextOption.Date){
        if(value1 == null){
          value1 = '';
        } else {
          value1 = dateFormat.format(DateTime.parse(value1));
        }
      } else if(option1 == TextOption.PlainText){
        if(value1 == null){
          value1 = '';
        } else {
          value1 = value1;
        }
      } else if(option1 == TextOption.EncryptedText){
        if(value1 == null){
          value1 = '';
        } else {
          value1 = GlobalFunctions.decryptString(value1);
        }
      } else if(option1 == TextOption.Time){
        if(value1 == null){
          value1 = '';
        } else {
          value1 = timeFormat.format(DateTime.parse(value1));
        }
      } else if(option1 == TextOption.EncryptedDate){
        if(value1 == null){
          value1 = '';
        } else {
          value1 = dateFormat.format(DateTime.parse(GlobalFunctions.decryptString(value1)));
        }
      } else if(option1 == TextOption.EncryptedText){
        if(value1 == null){
          value1 = '';
        } else {
          value1 = GlobalFunctions.decryptString(value1);
        }
      }

      if(option2 == TextOption.Date){
        if(value2 == null){
          value2 = '';
        } else {
          value2 = dateFormat.format(DateTime.parse(value2));
        }
      } else if(option2 == TextOption.PlainText){
        if(value2 == null){
          value2 = '';
        } else {
          value2 = value2;
        }
      } else if(option2 == TextOption.EncryptedText){
        if(value2 == null){
          value2 = '';
        } else {
          value2 = GlobalFunctions.decryptString(value2);
        }
      } else if(option2 == TextOption.Time){
        if(value2 == null){
          value2 = '';
        } else {
          value2 = timeFormat.format(DateTime.parse(value2));
        }
      } else if(option2 == TextOption.EncryptedDate){
        if(value2 == null){
          value2 = '';
        } else {
          value2 = dateFormat.format(DateTime.parse(GlobalFunctions.decryptString(value2)));
        }
      } else if(option2 == TextOption.EncryptedText){
        if(value2 == null){
          value2 = '';
        } else {
          value2 = GlobalFunctions.decryptString(value2);
        }
      }



      return Column(
          children: [
            Row(
                children: [
                  Container(width: 90, child: Text(text1, style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 8))),
                  SizedBox(width: 5),
                  Expanded(child: ConstrainedBox(constraints: BoxConstraints(minHeight: 20),
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          borderRadius: 5,
                          border: BoxBorder(
                            top: true,
                            left: true,
                            right: true,
                            bottom: true,
                            width: 1,
                            color: PdfColors.grey,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            value1 == 'signature' && signature != null ? Container(height: 20, child: FittedBox(alignment: Alignment.centerLeft, child: Image(PdfImage(doc,
                                image: signature.data.buffer
                                    .asUint8List(),
                                width: signature.width,
                                height: signature.height)))) : Text(value1 == null || value1 == 'signature' ? '' : value1, style: TextStyle(fontSize: 8))
                          ],
                        ),
                      ))),
                  SizedBox(width: 10),
                  Container(width: 90, child: Text(text2, style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 8))),
                  SizedBox(width: 5),
                  Expanded(child: ConstrainedBox(constraints: BoxConstraints(minHeight: 20),
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          borderRadius: 5,
                          border: BoxBorder(
                            top: true,
                            left: true,
                            right: true,
                            bottom: true,
                            width: 1,
                            color: PdfColors.grey,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            value2 == 'signature' && signature != null ? Container(height: 20, child: FittedBox(alignment: Alignment.centerLeft, child: Image(PdfImage(doc,
                                image: signature.data.buffer
                                    .asUint8List(),
                                width: signature.width,
                                height: signature.height)))) : Text(value2 == null || value2 == 'signature' ? '' : value2, style: TextStyle(fontSize: 8)),
                          ],
                        ),
                      ))),
                ]
            ),
            Container(height: 4)
          ]
      );
    }


    try {

      Document pdf;
      pdf = Document();
      PdfDocument pdfDoc = pdf.document;
      FlutterImage.Image patientObservationSignatureImage;
      PdfImage pegasusLogo = await pdfImageFromImageProvider(pdf: pdfDoc, image: Material.AssetImage('assets/images/pegasusLogo.png'),);

      if (selectedPatientObservation[Strings.patientObservationSignature] != null) {
        Uint8List decryptedSignature = await GlobalFunctions.decryptSignature(selectedPatientObservation[Strings.patientObservationSignature]);
        patientObservationSignatureImage = FlutterImage.decodeImage(decryptedSignature);
      }


      pdf.addPage(MultiPage(
          theme: Theme.withFont(base: ttf, bold: ttfBold),
          pageFormat: PdfPageFormat.a4,
          crossAxisAlignment: CrossAxisAlignment.start,
          margin: EdgeInsets.all(40),
          footer: (Context context) {
            return Container(
                alignment: Alignment.centerRight,
                margin: const EdgeInsets.only(top: 5),
                child: Text('Patient Observation Timesheet - Page ${context.pageNumber} of ${context.pagesCount}',
                    style: TextStyle(color: PdfColors.grey, fontSize: 8)));
          },
          build: (Context context) => <Widget>[


            Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(children: [
                          sectionTitle('Job Ref'),
                          SizedBox(width: 10),
                          textField(TextOption.PlainText, selectedPatientObservation[Strings.jobRef]),
                        ]),
                      ]
                  ),

                  Container(height: 50, child: Image(pegasusLogo)),

                ]
            ),
            Container(height: 20),
            Center(child: Text('PATIENT OBSERVATION TIMESHEET', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontWeight: FontWeight.bold))),
            Container(height: 20),
            singleLineField('Date', selectedPatientObservation[Strings.patientObservationDate], TextOption.Date, true),
            Container(height: 10),
            doubleLineField('Hospital', selectedPatientObservation[Strings.patientObservationHospital], 'Ward', selectedPatientObservation[Strings.patientObservationWard]),
            Container(height: 10),
            doubleLineField('Start Time', selectedPatientObservation[Strings.patientObservationStartTime], 'Finish Time', selectedPatientObservation[Strings.patientObservationFinishTime], TextOption.Time, TextOption.Time),
            Container(height: 10),
            singleLineField('Total Hours', selectedPatientObservation[Strings.patientObservationTotalHours], TextOption.PlainText, true),
            Container(height: 10),
            Text('Authorised By', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 10, fontWeight: FontWeight.bold)),
            Container(height: 5),
            doubleLineField('Name', selectedPatientObservation[Strings.patientObservationName], 'Position', selectedPatientObservation[Strings.patientObservationPosition]),
            Container(height: 10),
            doubleLineField('Signed', 'signature', 'Date', selectedPatientObservation[Strings.patientObservationAuthorisedDate], TextOption.PlainText, TextOption.Date, patientObservationSignatureImage, pdfDoc),

          ]

      ));



      String formDate = selectedPatientObservation[Strings.patientObservationDate] == null ? '' : dateFormatDay.format(DateTime.parse(selectedPatientObservation[Strings.patientObservationDate]));
      String id = selectedPatientObservation[Strings.documentId];




      if(kIsWeb){

        if(option == ShareOption.Download){
          List<int> pdfList = pdf.save();
          Uint8List pdfInBytes = Uint8List.fromList(pdfList);

//Create blob and link from bytes
          final blob = html.Blob([pdfInBytes], 'application/pdf');
          final url = html.Url.createObjectUrlFromBlob(blob);
          final anchor = html.document.createElement('a') as html.AnchorElement
            ..href = url
            ..style.display = 'none'
            ..download = 'patient_observation_timesheet_${formDate}_$id.pdf';
          html.document.body.children.add(anchor);
          anchor.click();
        } else {
          if(option == ShareOption.Print) await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
        }


      } else {
        Directory dir = await getApplicationDocumentsDirectory();

        String pdfPath =
            '${dir.path}/pdfs';
        Directory(pdfPath).createSync();



        final File file = File('$pdfPath/patient_observation_timesheet_${formDate}_$id.pdf');

        if(option == ShareOption.Email){
          file.writeAsBytesSync(pdf.save());
        }

        ConnectivityResult connectivityResult = await Connectivity().checkConnectivity();

        if(connectivityResult != ConnectivityResult.none) {

          if(option == ShareOption.Share) Printing.sharePdf(bytes: pdf.save(),filename: 'patient_observation_timesheet_${formDate}_$id.pdf');
          if(option == ShareOption.Print) await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());

          if(option == ShareOption.Email) {
            final smtpServer = gmail(emailUsername, emailPassword);

            // Create our message.
            final mailmessage = new Message()
              ..from = new Address(emailUsername, 'Pegasus Medical')
              ..recipients = emailList
              ..subject = 'Completed Patient Observation Timesheet'
              ..html = "<p1>Dear Sir/Madam,</p1>\n<p>Attached is a completed Patient Observation Timesheet from ${user
                  .name}.</p>"
                  "<p>Regards,<br>$emailSender</p>"
                  "<p><small>$emailFooter</small></p>"
              ..attachments = [FileAttachment(file)];

            await send(mailmessage, smtpServer);
          }
        }

      }

      success = true;

    } catch (e) {

      print(e);

    }
    return success;
  }





}



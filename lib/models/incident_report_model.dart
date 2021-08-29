import 'package:pegasus_medical_1808/models/share_option.dart';
import 'package:pegasus_medical_1808/services/navigation_service.dart';
import 'package:pegasus_medical_1808/shared/global_config.dart';
import 'package:pegasus_medical_1808/utils/database_helper.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../locator.dart';
import '../shared/global_config.dart';
import '../shared/global_functions.dart';
import '../utils/database_helper.dart';
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


class IncidentReportModel extends ChangeNotifier {

  DatabaseHelper _databaseHelper = DatabaseHelper();
  AuthenticationModel authenticationModel = AuthenticationModel();
  final NavigationService _navigationService = locator<NavigationService>();
  IncidentReportModel(this.authenticationModel);

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> _incidentReports = [];
  String _selIncidentReportId;
  final dateFormatDay = DateFormat("dd-MM-yyyy");

  List<Map<String, dynamic>> get allIncidentReports {
    return List.from(_incidentReports);
  }
  int get selectedIncidentReportIndex {
    return _incidentReports.indexWhere((Map<String, dynamic> incidentReport) {
      return incidentReport[Strings.documentId] == _selIncidentReportId;
    });
  }
  String get selectedIncidentReportId {
    return _selIncidentReportId;
  }

  Map<String, dynamic> get selectedIncidentReport {
    if (_selIncidentReportId == null) {
      return null;
    }
    return _incidentReports.firstWhere((Map<String, dynamic> incidentReport) {
      return incidentReport[Strings.documentId] == _selIncidentReportId;
    });
  }
  void selectIncidentReport(String incidentReportId) {
    _selIncidentReportId = incidentReportId;
    if (incidentReportId != null) {
      notifyListeners();
    }
  }

  void clearIncidentReports(){
    _incidentReports = [];
  }


  // Sembast database settings
  static const String TEMPORARY_INCIDENT_REPORTS_STORE_NAME = 'temporary_incident_reports';
  final _temporaryIncidentReportsStore = Db.intMapStoreFactory.store(TEMPORARY_INCIDENT_REPORTS_STORE_NAME);

  static const String INCIDENT_REPORTS_STORE_NAME = 'incident_reports';
  final _incidentReportsStore = Db.intMapStoreFactory.store(INCIDENT_REPORTS_STORE_NAME);

  static const String EDITED_INCIDENT_REPORTS_STORE_NAME = 'edited_incident_reports';
  final _editedIncidentReportsStore = Db.intMapStoreFactory.store(EDITED_INCIDENT_REPORTS_STORE_NAME);

  // Private getter to shorten the amount of code needed to get the
  // singleton instance of an opened database.
  Future<Db.Database> get _db async => await AppDatabase.instance.database;


  Future<void> setupTemporaryRecord() async {
    int count = await _temporaryIncidentReportsStore.count(await _db);

    if(count == 0){
      // Generate a random ID based on the date and a random string for virtual zero chance of duplicates
      int _id = DateTime.now().millisecondsSinceEpoch + int.parse(random_string.randomNumeric(2));
      await _temporaryIncidentReportsStore.record(_id).put(await _db,
          {Strings.uid : user.uid, Strings.formVersion: 1, Strings.jobId : '1'});
    }
  }

  Future<Map<String, dynamic>> getTemporaryRecord(bool edit, String selectedJobId) async{

    final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
        [Db.Filter.equals(Strings.uid, user.uid), Db.Filter.equals(Strings.jobId, selectedJobId)]
    ));

    List records;

    if(edit){
      records = await _editedIncidentReportsStore.find(
        await _db,
        finder: finder,
      );
    } else {
      records = await _temporaryIncidentReportsStore.find(
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

    List records = await _incidentReportsStore.find(
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

    List records = await _incidentReportsStore.find(
        await _db,
        finder: finder,
      );

    return records;
  }

  Future <void> deletePendingRecord(int localId) async{
    final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
        [Db.Filter.equals(Strings.uid, user.uid), Db.Filter.equals(Strings.localId, localId)]
    ));

    await _incidentReportsStore.delete(
      await _db,
      finder: finder,
    );
  }

  Future<bool> checkRecordExists(bool edit, String selectedJobId) async{

    bool hasRecord = false;

    final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
        [Db.Filter.equals(Strings.uid, user.uid), Db.Filter.equals(Strings.jobId, selectedJobId)]
    ));

    List records;


    if(edit){
      records = await _editedIncidentReportsStore.find(
        await _db,
        finder: finder,
      );
    } else {
      records = await _temporaryIncidentReportsStore.find(
        await _db,
        finder: finder,
      );
    }

    if(records.length > 0) hasRecord = true;


    return hasRecord;

  }

  void updateTemporaryRecord(bool edit, String field, var value, String selectedJobId) async {

    final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
      [Db.Filter.equals(Strings.uid, user.uid), Db.Filter.equals(Strings.jobId, selectedJobId)]
    ));


    if(edit){
      await _editedIncidentReportsStore.update(await _db, {field: value},
          finder: finder);
    } else {
      await _temporaryIncidentReportsStore.update(await _db, {field: value},
          finder: finder);
    }

  }

  void deleteEditedRecord() async {
    await _editedIncidentReportsStore.delete(await _db);
  }

  Future<void> setUpEditedRecord() async{

    Map<String, dynamic> editedReport = editedIncidentReport(selectedIncidentReport);
    Map<String, dynamic> localData = Map.from(editedReport);
    await _editedIncidentReportsStore.delete(await _db);
    int _id = DateTime.now().millisecondsSinceEpoch + int.parse(random_string.randomNumeric(2));
    await _editedIncidentReportsStore.record(_id).put(await _db,
        localData);

  }

  Future<void> deleteAllRows() async {
    await _incidentReportsStore.delete(await _db);
  }


  void resetTemporaryRecord(String chosenJobId) async {

    final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
        [Db.Filter.equals(Strings.uid, user.uid), Db.Filter.equals(Strings.jobId, chosenJobId)]
    ));

      await _temporaryIncidentReportsStore.update(await _db, {
        Strings.formVersion: 1,
        Strings.jobRef: null,
        Strings.incidentDate: null,
        Strings.incidentTime: null,
        Strings.incidentDetails: null,
        Strings.incidentLocation: null,
        Strings.incidentAction: null,
        Strings.incidentStaffInvolved: null,
        Strings.incidentSignature: null,
        Strings.incidentSignaturePoints: null,
        Strings.incidentSignatureDate: null,
        Strings.incidentPrintName: null,
      },
          finder: finder);
      notifyListeners();
  }



  Future<bool> submitIncidentReport(String jobId, [bool edit = false]) async {

    GlobalFunctions.showLoadingDialog('Submitting Incident Report...');
    String message = '';
    bool success = false;
    List<String> storageUrlList = [];

    //Semabast
    int count = await _incidentReportsStore.count(await _db);

    //Sqlflite
    //int count = await _databaseHelper.getRowCount(Strings.incidentReportTable);
    int id;

    if (count == 0) {
      id = 1;
    } else {
      id = count + 1;
    }

    //Sembast
    Map<String, dynamic> incidentReport = await getTemporaryRecord(false, jobId);

    //Sqlflite
    //Map<String, dynamic> incidentReport = await _databaseHelper.getTemporaryIncidentReport(false, user.uid, jobId);


    Map<String, dynamic> localData = {
      Strings.localId: id,
      Strings.documentId: null,
      Strings.uid: user.uid,
      Strings.jobId: '1',
      Strings.formVersion: '1',
      Strings.jobRef: incidentReport[Strings.jobRef],
      Strings.incidentDate: incidentReport[Strings.incidentDate],
      Strings.incidentTime: incidentReport[Strings.incidentTime],
      Strings.incidentDetails: incidentReport[Strings.incidentDetails],
      Strings.incidentLocation: incidentReport[Strings.incidentLocation],
      Strings.incidentAction: incidentReport[Strings.incidentAction],
      Strings.incidentStaffInvolved: incidentReport[Strings.incidentStaffInvolved],
      Strings.incidentSignature: incidentReport[Strings.incidentSignature],
      Strings.incidentSignatureDate: incidentReport[Strings.incidentSignatureDate],
      Strings.incidentPrintName: incidentReport[Strings.incidentPrintName],
      Strings.pendingTime: DateTime.now().toIso8601String(),
      Strings.serverUploaded: 0,
    };

    //Sembast
    int _id = DateTime.now().millisecondsSinceEpoch + int.parse(random_string.randomNumeric(2));
    await _incidentReportsStore.record(_id).put(await _db,
        localData);

    message = 'Incident Report has successfully been added to local database';


    //Sqlflite
    // int result = await _databaseHelper.add(Strings.incidentReportTable, localData);
    //
    // if (result != 0) {
    //   message = 'Incident Report has successfully been added to local database';
    // }


    bool hasDataConnection = await GlobalFunctions.hasDataConnection();


    if(hasDataConnection){

      bool isTokenExpired = GlobalFunctions.isTokenExpired();
      bool authenticated = true;

      if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

      if(authenticated){


        try {

          await GlobalFunctions.checkFirebaseStorageFail(_databaseHelper);


          DocumentReference ref =
          await FirebaseFirestore.instance.collection('incident_reports').add({
            Strings.uid: user.uid,
            Strings.jobId: '1',
            Strings.formVersion: '1',
            Strings.jobRef: GlobalFunctions.databaseValueString(incidentReport[Strings.jobRef]),
            Strings.jobRefLowercase: GlobalFunctions.databaseValueString(incidentReport[Strings.jobRef]).toLowerCase(),
            Strings.incidentDate: incidentReport[Strings.incidentDate] == null ? null : DateTime.parse(incidentReport[Strings.incidentDate]),
            Strings.incidentTime: incidentReport[Strings.incidentTime],
            Strings.incidentDetails: incidentReport[Strings.incidentDetails],
            Strings.incidentLocation: incidentReport[Strings.incidentLocation],
            Strings.incidentAction: incidentReport[Strings.incidentAction],
            Strings.incidentStaffInvolved: incidentReport[Strings.incidentStaffInvolved],
            Strings.incidentSignature: null,
            Strings.incidentSignatureDate: incidentReport[Strings.incidentSignatureDate],
            Strings.incidentPrintName: incidentReport[Strings.incidentPrintName],
            Strings.timestamp: FieldValue.serverTimestamp(),
            Strings.serverUploaded: 1,
          });

          DocumentSnapshot snap = await ref.get();

          //Signatures
          String incidentSignatureUrl;
          bool incidentSignatureSuccess = true;

          if(incidentReport[Strings.incidentSignature] != null){
            incidentSignatureSuccess = false;

            Reference storageRef =
            FirebaseStorage.instance.ref().child('incidentReportImages/' + snap.id + '/incidentSignature.jpg');

            if(kIsWeb){
              storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/incidentReportImages/' + snap.id + '/incidentSignature.jpg');
            }

            final UploadTask uploadTask = storageRef.putData(Uint8List.fromList(incidentReport[Strings.incidentSignature].toList().cast<int>()));
            final TaskSnapshot downloadUrl = (await uploadTask);
            incidentSignatureUrl = (await downloadUrl.ref.getDownloadURL());
            if(incidentSignatureUrl != null){
              incidentSignatureSuccess = true;
              storageUrlList.add('incidentReportImages/' + snap.id + '/incidentSignature.jpg');
            }

          }

          if(incidentSignatureSuccess){

            await FirebaseFirestore.instance.collection('incident_reports').doc(snap.id).update({
              Strings.incidentSignature: incidentSignatureUrl == null ? null : incidentSignatureUrl,
            }).timeout(Duration(seconds: 60));


            //Sembast
            await _incidentReportsStore.record(_id).delete(await _db);
            message = 'Incident Report uploaded successfully';
            success = true;

            //Sqlflite
            // Map<String, dynamic> localData = {
            //   Strings.documentId: snap.id,
            //   Strings.serverUploaded: 1,
            //   'timestamp': DateTime.fromMillisecondsSinceEpoch(snap.data()[Strings.timestamp].millisecondsSinceEpoch).toIso8601String()
            // };
            //
            // int queryResult = await _databaseHelper.updateRow(
            //     Strings.incidentReportTable,
            //     localData,
            //     Strings.localId,
            //     id);
            //
            // if (queryResult != 0) {
            //   success = true;
            //   message = 'Incident Report uploaded successfully';
            // } else {
            //   message =
            //   'Incident Report uploaded successfully to the server';
            // }

          } else {
            await FirebaseFirestore.instance.collection('incident_reports').doc(snap.id).delete();
          }

        } on TimeoutException catch (_) {
          // A timeout occurred.
          message = 'Network Timeout communicating with the server, unable to upload Incident Report';

          await GlobalFunctions.checkAddFirebaseStorageRow(storageUrlList, _databaseHelper);

        } catch (e) {
          print(e);
          message = e.toString();
          await GlobalFunctions.checkAddFirebaseStorageRow(storageUrlList, _databaseHelper);

          print(e);
        }
      }

    } else {

      message = 'No data connection, Incident Report has been saved locally, please upload when you have a valid connection';
      success = true;

    }

    //Sembast
    if(success) resetTemporaryRecord(jobId);

    //Sqlflite
    //if(success) resetTemporaryIncidentReport(jobId);
    GlobalFunctions.dismissLoadingDialog();
    if(edit){
      _navigationService.goBack();
      _navigationService.goBack();
    }
    GlobalFunctions.showToast(message);
    return success;


  }

  Future<bool> editIncidentReport(String jobId, [bool edit = false]) async {

    GlobalFunctions.showLoadingDialog('Editing Incident Report...');
    String message = '';
    bool success = false;
    List<String> storageUrlList = [];

    //Map<String, dynamic> incidentReport = await _databaseHelper.getTemporaryIncidentReport(true, user.uid, jobId);
    Map<String, dynamic> incidentReport = await getTemporaryRecord(true, jobId);

    bool hasDataConnection = await GlobalFunctions.hasDataConnection();


    if(hasDataConnection){

      bool isTokenExpired = GlobalFunctions.isTokenExpired();
      bool authenticated = true;

      if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

      if(authenticated){


        try {

          await FirebaseFirestore.instance.collection('incident_reports').doc(incidentReport[Strings.documentId]).update({
            Strings.uid: user.uid,
            Strings.jobId: '1',
            Strings.formVersion: '1',
            Strings.jobRef: GlobalFunctions.databaseValueString(incidentReport[Strings.jobRef]),
            Strings.jobRefLowercase: GlobalFunctions.databaseValueString(incidentReport[Strings.jobRef]).toLowerCase(),
            Strings.incidentDate: incidentReport[Strings.incidentDate] == null ? null : DateTime.parse(incidentReport[Strings.incidentDate]),
            Strings.incidentTime: incidentReport[Strings.incidentTime],
            Strings.incidentDetails: incidentReport[Strings.incidentDetails],
            Strings.incidentLocation: incidentReport[Strings.incidentLocation],
            Strings.incidentAction: incidentReport[Strings.incidentAction],
            Strings.incidentStaffInvolved: incidentReport[Strings.incidentStaffInvolved],
            Strings.incidentSignatureDate: incidentReport[Strings.incidentSignatureDate],
            Strings.incidentPrintName: incidentReport[Strings.incidentPrintName],
            Strings.timestamp: FieldValue.serverTimestamp(),
            Strings.serverUploaded: 1,
          });






          //Sembast

          final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
              [Db.Filter.equals(Strings.uid, user.uid), Db.Filter.equals(Strings.jobId, jobId)]
          ));


          await _incidentReportsStore.delete(await _db,
              finder: finder);
          message = 'Incident Report uploaded successfully';
          success = true;

          // Map<String, dynamic> localData = {
          //   Strings.documentId: incidentReport[Strings.documentId],
          //   Strings.uid: incidentReport[Strings.uid],
          //   Strings.jobId: incidentReport[Strings.jobId],
          //   Strings.formVersion: incidentReport[Strings.formVersion],
          //   Strings.jobRef: incidentReport[Strings.jobRef],
          //   Strings.incidentDate: incidentReport[Strings.incidentDate],
          //   Strings.incidentTime: incidentReport[Strings.incidentTime],
          //   Strings.incidentDetails: incidentReport[Strings.incidentDetails],
          //   Strings.incidentLocation: incidentReport[Strings.incidentLocation],
          //   Strings.incidentAction: incidentReport[Strings.incidentAction],
          //   Strings.incidentStaffInvolved: incidentReport[Strings.incidentStaffInvolved],
          //   Strings.incidentSignatureDate: incidentReport[Strings.incidentSignatureDate],
          //   Strings.incidentPrintName: incidentReport[Strings.incidentPrintName],
          // };

          // int queryResult = await _databaseHelper.updateRow(
          //     Strings.incidentReportTable,
          //     localData,
          //     Strings.documentId,
          //     incidentReport[Strings.documentId]);
          //
          // if (queryResult != 0) {
          //   success = true;
          //   message = 'Incident Report uploaded successfully';
          // } else {
          //   message =
          //   'Incident Report uploaded successfully to the server';
          // }



        } on TimeoutException catch (_) {
          // A timeout occurred.
          message = 'Network Timeout communicating with the server, unable to edit Incident Report';

          await GlobalFunctions.checkAddFirebaseStorageRow(storageUrlList, _databaseHelper);

        } catch (e) {
          print(e);
          message = e.toString();
          await GlobalFunctions.checkAddFirebaseStorageRow(storageUrlList, _databaseHelper);

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
      //deleteEditedIncidentReport();
      deleteEditedRecord();
    }
    GlobalFunctions.showToast(message);
    return success;


  }


  Future<void> getIncidentReports() async{

    _isLoading = true;
    notifyListeners();
    String message = '';

    List<Map<String, dynamic>> _fetchedIncidentReportList = [];
    DatabaseHelper databaseHelper = DatabaseHelper();

    try {

      bool hasDataConnection = await GlobalFunctions.hasDataConnection();

      if(!hasDataConnection){

        GlobalFunctions.showToast('No data connection, unable to fetch Incident Reports');
        _incidentReports = [];

        // int localChecklistCount;
        //
        // if(user.role == 'Super User'){
        //   localChecklistCount = await databaseHelper.getRowCountWhere(Strings.incidentReportTable, Strings.serverUploaded, 1);
        //
        // } else {
        //   localChecklistCount = await databaseHelper.getRowCountWhereAndWhere(Strings.incidentReportTable, Strings.serverUploaded, 1, Strings.uid, user.uid);
        //
        // }
        //
        //
        // if (localChecklistCount > 0) {
        //
        //   List<Map<String, dynamic>> localRecords = [];
        //
        //   if(user.role == 'Super User'){
        //     localRecords = await databaseHelper.getRowsWhereOrderByDirection(Strings.incidentReportTable, Strings.serverUploaded, 1, Strings.timestamp, 'DESC');
        //
        //   } else {
        //     localRecords = await databaseHelper.getRowsWhereAndWhereOrderByDirection(Strings.incidentReportTable, Strings.serverUploaded, 1, Strings.uid, user.uid, Strings.timestamp, 'DESC');
        //
        //   }
        //
        //
        //   if(localRecords.length >0){
        //
        //     for (Map<String, dynamic> localRecord in localRecords) {
        //
        //       final Map<String, dynamic> incidentReport = localIncidentReport(localRecord);
        //
        //       _fetchedIncidentReportList.add(incidentReport);
        //     }
        //
        //     _incidentReports = _fetchedIncidentReportList;
        //     message = 'No data connection, unable to fetch latest Incident Reports';
        //
        //   }
        //
        // } else {
        //   _incidentReports = [];
        //   message = 'No Incident Reports available, please try again when you have a data connection';
        // }


      } else {


        bool isTokenExpired = GlobalFunctions.isTokenExpired();
        bool authenticated = true;

        if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

        if(authenticated){


          QuerySnapshot snapshot;

          if(user.role == 'Super User'){
            try{
              snapshot = await FirebaseFirestore.instance.collection('incident_reports').orderBy('timestamp', descending: true).limit(10).get().timeout(Duration(seconds: 90));
            } catch(e){
              print(e);
            }
          } else {
            try{
              snapshot = await FirebaseFirestore.instance.collection('incident_reports').where(
                  'uid', isEqualTo: user.uid).orderBy('timestamp', descending: true).limit(10).get().timeout(Duration(seconds: 90));
            } catch(e){
              print(e);
            }
          }





          Map<String, dynamic> snapshotData = {};

          if(snapshot.docs.length < 1){
            message = 'No Incident Reports found';
          } else {
            for (DocumentSnapshot snap in snapshot.docs) {

              snapshotData = snap.data();

              Uint8List incidentSignature;

              if (snapshotData[Strings.incidentSignature] != null) {
                Reference storageRef =
                FirebaseStorage.instance.ref().child('incidentReportImages/' + snap.id + '/incidentSignature.jpg');

                if(kIsWeb){
                  storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/incidentReportImages/' + snap.id + '/incidentSignature.jpg');

                }

                incidentSignature = await storageRef.getData(dataLimit);
              }


              final Map<String, dynamic> incidentReport = onlineIncidentReport(snapshotData, snap.id, incidentSignature);

              _fetchedIncidentReportList.add(incidentReport);

              // if(!isWeb){
              //   Map<String, dynamic> localData = Map.from(incidentReport);
              //   int queryResult;
              //
              //   int existingIncidentReport = await databaseHelper.checkIncidentReportExists(snap.id);
              //
              //   if (existingIncidentReport == 0) {
              //
              //     queryResult = await databaseHelper.add(Strings.incidentReportTable, localData);
              //   } else {
              //
              //     queryResult = await databaseHelper.updateRow(Strings.incidentReportTable, localData, Strings.documentId, snap.id);
              //
              //   }
              //
              //   if (queryResult != 0) {
              //
              //     print('added to local db');
              //   } else {
              //     print('issue with local db');
              //   }
              // }

            }

            _incidentReports = _fetchedIncidentReportList;
          }


        }

      }


    } on TimeoutException catch (_) {
      // A timeout occurred.
      message = 'Network Timeout communicating with the server, unable to fetch latest Incident Reports';
    } catch(e){
      print(e);
      message = 'Something went wrong. Please try again';

    }

    _isLoading = false;
    notifyListeners();
    _selIncidentReportId = null;
    if(message != '') GlobalFunctions.showToast(message);

  }

  Future<void> getMoreIncidentReports() async{

    String message = '';

    List<Map<String, dynamic>> _fetchedIncidentReportList = [];
    DatabaseHelper databaseHelper = DatabaseHelper();

    try {

      bool hasDataConnection = await GlobalFunctions.hasDataConnection();

      if(!hasDataConnection){

        GlobalFunctions.showToast('No data connection, unable to fetch Incident Reports');

      } else {


        bool isTokenExpired = GlobalFunctions.isTokenExpired();
        bool authenticated = true;

        if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

        if(authenticated){


          QuerySnapshot snapshot;
          int currentLength = _incidentReports.length;
          DateTime latestDate = DateTime.parse(_incidentReports[currentLength - 1][Strings.timestamp]);

          if(user.role == 'Super User'){
            try {
              snapshot = await FirebaseFirestore.instance.collection('incident_reports').orderBy(
                  'timestamp', descending: true).startAfter(
                  [Timestamp.fromDate(latestDate)]).limit(10)
                  .get()
                  .timeout(Duration(seconds: 90));
            } catch(e) {
              print(e);
            }

          } else {
            try {
              snapshot = await FirebaseFirestore.instance.collection('incident_reports').where(
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
            message = 'No more Incident Reports found';
          } else {
            for (DocumentSnapshot snap in snapshot.docs) {

              snapshotData = snap.data();

              Uint8List incidentSignature;

              if (snapshotData[Strings.incidentSignature] != null) {
                Reference storageRef =
                FirebaseStorage.instance.ref().child('incidentReportImages/' + snap.id + '/incidentSignature.jpg');

                if(kIsWeb){
                  storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/incidentReportImages/' + snap.id + '/incidentSignature.jpg');
                }
                incidentSignature = await storageRef.getData(dataLimit);
              }

              final Map<String, dynamic> incidentReport = onlineIncidentReport(snapshotData, snap.id, incidentSignature);

              _fetchedIncidentReportList.add(incidentReport);

              // Map<String, dynamic> localData = Map.from(incidentReport);
              // int queryResult;
              //
              // int existingIncidentReport = await databaseHelper.checkIncidentReportExists(snap.id);
              //
              // if (existingIncidentReport == 0) {
              //
              //   queryResult = await databaseHelper.add(Strings.incidentReportTable, localData);
              // } else {
              //
              //   queryResult = await databaseHelper.updateRow(Strings.incidentReportTable, localData, Strings.documentId, snap.id);
              //
              // }
              //
              // if (queryResult != 0) {
              //
              //   print('added to local db');
              // } else {
              //   print('issue with local db');
              // }

            }

            _incidentReports.addAll(_fetchedIncidentReportList);
          }


        }

      }


    } on TimeoutException catch (_) {
      // A timeout occurred.
      message = 'Network Timeout communicating with the server, unable to fetch latest Incident Reports';
    } catch(e){
      print(e);
      message = 'Something went wrong. Please try again';

    }

    _isLoading = false;
    notifyListeners();
    _selIncidentReportId = null;
    if(message != '') GlobalFunctions.showToast(message);

  }

  Future<bool> searchIncidentReports(DateTime dateFrom, DateTime dateTo, String jobRef, String selectedUser) async{

    _isLoading = true;
    notifyListeners();
    bool success = false;
    String message = '';
    GlobalFunctions.showLoadingDialog('Searching Forms');
    List<Map<String, dynamic>> _fetchedIncidentReportList = [];

    try {

      bool hasDataConnection = await GlobalFunctions.hasDataConnection();

      if(!hasDataConnection){

        message = 'No Data Connection, unable to search Incident Reports';

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
                    await FirebaseFirestore.instance.collection('incident_reports')
                        .where(Strings.uid, isEqualTo: selectedUser).orderBy('timestamp', descending: true)
                        .startAt([dateTo]).endAt([dateFrom]).get()
                        .timeout(Duration(seconds: 90));
                  } catch(e){
                    print(e);
                  }
                } else {
                  try{
                    snapshot =
                    await FirebaseFirestore.instance.collection('incident_reports').orderBy('timestamp', descending: true)
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
                    await FirebaseFirestore.instance.collection('incident_reports').where(Strings.uid, isEqualTo: selectedUser).
                    where(Strings.jobRefLowercase, isEqualTo: jobRef.toLowerCase()).orderBy('timestamp', descending: true)
                        .startAt([dateTo]).endAt([dateFrom]).get()
                        .timeout(Duration(seconds: 90));
                  } catch(e){
                    print(e);
                  }
                } else {
                  try{
                    snapshot =
                    await FirebaseFirestore.instance.collection('incident_reports')
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
                    await FirebaseFirestore.instance.collection('incident_reports')
                        .where(Strings.uid, isEqualTo: selectedUser).orderBy('timestamp', descending: true)
                        .get()
                        .timeout(Duration(seconds: 90));
                  } catch(e){
                    print(e);
                  }
                } else {
                  try{
                    snapshot =
                    await FirebaseFirestore.instance.collection('incident_reports').orderBy('timestamp', descending: true)
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
                    await FirebaseFirestore.instance.collection('incident_reports')
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
                    await FirebaseFirestore.instance.collection('incident_reports')
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
                  await FirebaseFirestore.instance.collection('incident_reports')
                      .where(Strings.uid, isEqualTo: user.uid).orderBy('timestamp', descending: true)
                      .startAt([dateTo]).endAt([dateFrom]).get()
                      .timeout(Duration(seconds: 90));
                } catch(e){
                  print(e);
                }


              } else {


                try{
                  snapshot =
                  await FirebaseFirestore.instance.collection('incident_reports')
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
                  await FirebaseFirestore.instance.collection('incident_reports')
                      .where(Strings.uid, isEqualTo: user.uid).orderBy('timestamp', descending: true)
                      .get()
                      .timeout(Duration(seconds: 90));
                } catch(e){
                  print(e);
                }


              } else {

                try{
                  snapshot =
                  await FirebaseFirestore.instance.collection('incident_reports')
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
            message = 'No Incident Reports found';
          } else {
            for (DocumentSnapshot snap in snapshot.docs) {

              snapshotData = snap.data();

              Uint8List incidentSignature;

              if (snapshotData[Strings.incidentSignature] != null) {
                Reference storageRef =
                FirebaseStorage.instance.ref().child('incidentReportImages/' + snap.id + '/incidentSignature.jpg');

                if(kIsWeb){
                  storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/incidentReportImages/' + snap.id + '/incidentSignature.jpg');
                }
                incidentSignature = await storageRef.getData(dataLimit);
              }

              final Map<String, dynamic> incidentReport = onlineIncidentReport(snapshotData, snap.id, incidentSignature);

              _fetchedIncidentReportList.add(incidentReport);

            }

            _incidentReports = _fetchedIncidentReportList;
            success = true;
          }


        }

      }


    } on TimeoutException catch (_) {
      // A timeout occurred.
      message = 'Network Timeout communicating with the server, unable to search Incident Reports';
    } catch(e){
      print(e);
      message = 'Something went wrong. Please try again';

    }

    _isLoading = false;
    notifyListeners();
    _selIncidentReportId = null;
    GlobalFunctions.dismissLoadingDialog();
    if(message != '') GlobalFunctions.showToast(message);
    return success;

  }


  Future<bool> searchMoreIncidentReports(DateTime dateFrom, DateTime dateTo) async{

    _isLoading = true;
    notifyListeners();
    bool success = false;
    String message = '';
    GlobalFunctions.showLoadingDialog('Searching Forms');
    List<Map<String, dynamic>> _fetchedIncidentReportList = [];

    try {

      bool hasDataConnection = await GlobalFunctions.hasDataConnection();

      if(!hasDataConnection){

        message = 'No Data Connection, unable to search Incident Reports';

      } else {


        bool isTokenExpired = GlobalFunctions.isTokenExpired();
        bool authenticated = true;

        if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

        if(authenticated){


          QuerySnapshot snapshot;
          int currentLength = _incidentReports.length;
          DateTime latestDate = DateTime.parse(_incidentReports[currentLength - 1]['timestamp']);

          if(user.role == 'Super User'){
            try{
              snapshot =
              await FirebaseFirestore.instance.collection('incident_reports').orderBy('timestamp', descending: true)
                  .startAfter([Timestamp.fromDate(latestDate)]).endAt([dateFrom]).limit(10).get()
                  .timeout(Duration(seconds: 90));
            } catch(e){
              print(e);
            }

          } else {

            try{
              snapshot =
              await FirebaseFirestore.instance.collection('incident_reports').where('uid', isEqualTo: user.uid).orderBy('timestamp', descending: true)
                  .startAfter([Timestamp.fromDate(latestDate)]).endAt([dateFrom]).limit(10).get()
                  .timeout(Duration(seconds: 90));
            } catch(e){
              print(e);
            }

          }

          Map<String, dynamic> snapshotData = {};

          if(snapshot.docs.length < 1){
            message = 'No Incident Reports found';
          } else {
            for (DocumentSnapshot snap in snapshot.docs) {

              snapshotData = snap.data();

              Uint8List incidentSignature;

              if (snapshotData[Strings.incidentSignature] != null) {
                Reference storageRef =
                FirebaseStorage.instance.ref().child('incidentReportImages/' + snap.id + '/incidentSignature.jpg');

                if(kIsWeb){
                  storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/incidentReportImages/' + snap.id + '/incidentSignature.jpg');
                }
                incidentSignature = await storageRef.getData(dataLimit);
              }

              final Map<String, dynamic> incidentReport = onlineIncidentReport(snapshotData, snap.id, incidentSignature);

              _fetchedIncidentReportList.add(incidentReport);

            }

            _incidentReports.addAll(_fetchedIncidentReportList);
            success = true;
          }


        }

      }


    } on TimeoutException catch (_) {
      // A timeout occurred.
      message = 'Network Timeout communicating with the server, unable to search Incident Reports';
    } catch(e){
      print(e);
      message = 'Something went wrong. Please try again';

    }

    _isLoading = false;
    notifyListeners();
    _selIncidentReportId = null;
    GlobalFunctions.dismissLoadingDialog();
    if(message != '') GlobalFunctions.showToast(message);
    return success;

  }


  Map<String, dynamic> localIncidentReport(Map<String, dynamic> localRecord){
    return {
      Strings.documentId: GlobalFunctions.databaseValueString(localRecord[Strings.documentId]),
      Strings.uid: GlobalFunctions.databaseValueString(localRecord[Strings.uid]),
      Strings.jobId: localRecord[Strings.jobId],
      Strings.formVersion: localRecord[Strings.formVersion],
      Strings.jobRef: localRecord[Strings.jobRef],
      Strings.incidentDate: localRecord[Strings.incidentDate],
      Strings.incidentTime: localRecord[Strings.incidentTime],
      Strings.incidentDetails: localRecord[Strings.incidentDetails],
      Strings.incidentLocation: localRecord[Strings.incidentLocation],
      Strings.incidentAction: localRecord[Strings.incidentAction],
      Strings.incidentStaffInvolved: localRecord[Strings.incidentStaffInvolved],
      Strings.incidentSignature: localRecord[Strings.incidentSignature],
      Strings.incidentSignaturePoints: localRecord[Strings.incidentSignaturePoints],
      Strings.incidentSignatureDate: localRecord[Strings.incidentSignatureDate],
      Strings.incidentPrintName: localRecord[Strings.incidentPrintName],
      Strings.serverUploaded: localRecord[Strings.serverUploaded],
      Strings.timestamp: localRecord[Strings.timestamp] == null ? null : localRecord[Strings.timestamp]
    };
  }

  Map<String, dynamic> onlineIncidentReport(Map<String, dynamic> localRecord, String docId, Uint8List incidentSignature){
    return {
      Strings.documentId: docId,
      Strings.uid: GlobalFunctions.databaseValueString(localRecord[Strings.uid]),
      Strings.jobId: localRecord[Strings.jobId],
      Strings.formVersion: localRecord[Strings.formVersion],
      Strings.jobRef: localRecord[Strings.jobRef],
      Strings.incidentDate: localRecord[Strings.incidentDate] == null ? null : DateTime
          .fromMillisecondsSinceEpoch(
          localRecord[Strings.incidentDate].millisecondsSinceEpoch)
          .toIso8601String(),
      Strings.incidentTime: localRecord[Strings.incidentTime],
      Strings.incidentDetails: localRecord[Strings.incidentDetails],
      Strings.incidentLocation: localRecord[Strings.incidentLocation],
      Strings.incidentAction: localRecord[Strings.incidentAction],
      Strings.incidentStaffInvolved: localRecord[Strings.incidentStaffInvolved],
      Strings.incidentSignature: incidentSignature,
      Strings.incidentSignatureDate: localRecord[Strings.incidentSignatureDate],
      Strings.incidentPrintName: localRecord[Strings.incidentPrintName],
      Strings.serverUploaded: localRecord[Strings.serverUploaded],
      Strings.timestamp: localRecord[Strings.timestamp] == null ? null : DateTime
          .fromMillisecondsSinceEpoch(
          localRecord['timestamp'].millisecondsSinceEpoch)
          .toIso8601String()
    };
  }

  Map<String, dynamic> editedIncidentReport(Map<String, dynamic> localRecord){
    return {
      Strings.documentId: GlobalFunctions.databaseValueString(localRecord[Strings.documentId]),
      Strings.uid: GlobalFunctions.databaseValueString(localRecord[Strings.uid]),
      Strings.jobId: localRecord[Strings.jobId],
      Strings.formVersion: localRecord[Strings.formVersion],
      Strings.jobRef: localRecord[Strings.jobRef],
      Strings.incidentDate: localRecord[Strings.incidentDate],
      Strings.incidentTime: localRecord[Strings.incidentTime],
      Strings.incidentDetails: localRecord[Strings.incidentDetails],
      Strings.incidentLocation: localRecord[Strings.incidentLocation],
      Strings.incidentAction: localRecord[Strings.incidentAction],
      Strings.incidentStaffInvolved: localRecord[Strings.incidentStaffInvolved],
      Strings.incidentSignature: localRecord[Strings.incidentSignature],
      Strings.incidentSignaturePoints: localRecord[Strings.incidentSignaturePoints],
      Strings.incidentSignatureDate: localRecord[Strings.incidentSignatureDate],
      Strings.incidentPrintName: localRecord[Strings.incidentPrintName],
      Strings.serverUploaded: localRecord[Strings.serverUploaded],
      Strings.timestamp: localRecord[Strings.timestamp]
    };
  }



  Future<Map<String, dynamic>> uploadPendingIncidentReports() async {
    _isLoading = true;
    String message = 'Something went wrong!';
    bool success = false;
    List<String> storageUrlList = [];

    try {

      List<dynamic> incidentReportRecords = await getPendingRecords();

      List<Map<String, dynamic>> incidentReports = [];

      for(var incidentReportRecord in incidentReportRecords){
        incidentReports.add(incidentReportRecord.value);
      }


      // List<Map<String, dynamic>> incidentReports =
      // await _databaseHelper.getAllWhereAndWhere(
      //     Strings.incidentReportTable,
      //     Strings.serverUploaded,
      //     0,
      //     Strings.uid,
      //     user.uid);


      bool isTokenExpired = GlobalFunctions.isTokenExpired();
      bool authenticated = true;

      if (isTokenExpired)
        authenticated = await authenticationModel.reAuthenticate();

      if (authenticated) {

        for (Map<String, dynamic> incidentReport in incidentReports) {

          success = false;




          await GlobalFunctions.checkFirebaseStorageFail(_databaseHelper);



          DocumentReference ref =
          await FirebaseFirestore.instance.collection('incident_reports').add({
            Strings.uid: user.uid,
            Strings.jobId: '1',
            Strings.formVersion: '1',
            Strings.jobRef: GlobalFunctions.databaseValueString(incidentReport[Strings.jobRef]),
            Strings.jobRefLowercase: GlobalFunctions.databaseValueString(incidentReport[Strings.jobRef]).toLowerCase(),
            Strings.incidentDate: incidentReport[Strings.incidentDate] == null ? null : DateTime.parse(incidentReport[Strings.incidentDate]),
            Strings.incidentTime: incidentReport[Strings.incidentTime],
            Strings.incidentDetails: incidentReport[Strings.incidentDetails],
            Strings.incidentLocation: incidentReport[Strings.incidentLocation],
            Strings.incidentAction: incidentReport[Strings.incidentAction],
            Strings.incidentStaffInvolved: incidentReport[Strings.incidentStaffInvolved],
            Strings.incidentSignature: null,
            Strings.incidentSignatureDate: incidentReport[Strings.incidentSignatureDate],
            Strings.incidentPrintName: incidentReport[Strings.incidentPrintName],
            Strings.timestamp: FieldValue.serverTimestamp(),
            Strings.serverUploaded: 1,
          });

          DocumentSnapshot snap = await ref.get();

          //Signatures
          String incidentSignatureUrl;
          bool incidentSignatureSuccess = true;

          if(incidentReport[Strings.incidentSignature] != null){
            incidentSignatureSuccess = false;

            Reference storageRef =
            FirebaseStorage.instance.ref().child('incidentReportImages/' + snap.id + '/incidentSignature.jpg');

            if(kIsWeb){
              storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/incidentReportImages/' + snap.id + '/incidentSignature.jpg');
            }
            final UploadTask uploadTask = storageRef.putData(Uint8List.fromList(incidentReport[Strings.incidentSignature].toList().cast<int>()));
            final TaskSnapshot downloadUrl = (await uploadTask);
            incidentSignatureUrl = (await downloadUrl.ref.getDownloadURL());
            if(incidentSignatureUrl != null){
              incidentSignatureSuccess = true;
              storageUrlList.add('incidentReportImages/' + snap.id + '/incidentSignature.jpg');
            }

          }


          if(incidentSignatureSuccess){

            await FirebaseFirestore.instance.collection('incident_reports').doc(snap.id).update({
              Strings.incidentSignature: incidentSignatureUrl == null ? null : incidentSignatureUrl,
            }).timeout(Duration(seconds: 60));

            await deletePendingRecord(incidentReport[Strings.localId]);
            success = true;


            // Map<String, dynamic> localData = {
            //   Strings.documentId: snap.id,
            //   Strings.serverUploaded: 1,
            //   'timestamp': DateTime.fromMillisecondsSinceEpoch(snap.data()[Strings.timestamp].millisecondsSinceEpoch).toIso8601String()
            // };
            //
            // int queryResult = await _databaseHelper.updateRow(
            //     Strings.incidentReportTable,
            //     localData,
            //     Strings.localId,
            //     incidentReport[Strings.localId]);
            //
            // if (queryResult != 0) {
            //   success = true;
            // }


          } else {
            await FirebaseFirestore.instance.collection('incident_reports').doc(snap.id).delete();
          }

        }

        message = 'Data Successfully Uploaded';

      }
    } on TimeoutException catch (_) {
      // A timeout occurred.
      message =
      'Network Timeout communicating with the server, unable to upload Data';
      await GlobalFunctions.checkAddFirebaseStorageRow(storageUrlList, _databaseHelper);

    } catch (e) {
      await GlobalFunctions.checkAddFirebaseStorageRow(storageUrlList, _databaseHelper);

      print(e);
    }


    _isLoading = false;
    notifyListeners();
    return {'success': success, 'message': message};
  }


  Future<void> setUpEditedIncidentReport() async{

    Map<String, dynamic> editedReport = editedIncidentReport(selectedIncidentReport);
    Map<String, dynamic> localData = Map.from(editedReport);
    await _databaseHelper.deleteAllRows(Strings.editedIncidentReportTable);
    await _databaseHelper.add(Strings.editedIncidentReportTable, localData);


    await _editedIncidentReportsStore.delete(await _db);
    int _id = DateTime.now().millisecondsSinceEpoch + int.parse(random_string.randomNumeric(2));
    await _editedIncidentReportsStore.record(_id).put(await _db,
        localData);




  }

  Future<void> deleteEditedIncidentReport() async{
    await _databaseHelper.deleteAllRows(Strings.editedIncidentReportTable);
  }

  void resetTemporaryIncidentReport(String chosenJobId) {
    _databaseHelper.resetTemporaryIncidentReport(user.uid, chosenJobId);
    notifyListeners();
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
                        width: 100,
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
      FlutterImage.Image incidentSignatureImage;
      PdfImage pegasusLogo = await pdfImageFromImageProvider(pdf: pdfDoc, image: Material.AssetImage('assets/images/pegasusLogo.png'),);

      if (selectedIncidentReport[Strings.incidentSignature] != null) {
        Uint8List decryptedSignature = await GlobalFunctions.decryptSignature(selectedIncidentReport[Strings.incidentSignature]);
        incidentSignatureImage = FlutterImage.decodeImage(decryptedSignature);
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
                child: Text('Incident Report Form - Page ${context.pageNumber} of ${context.pagesCount}',
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
                          textField(TextOption.PlainText, selectedIncidentReport[Strings.jobRef]),
                        ]),
                      ]
                  ),

                  Container(height: 50, child: Image(pegasusLogo)),

                ]
            ),
            Container(height: 20),
            Center(child: Text('INCIDENT REPORT FORM', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontWeight: FontWeight.bold))),
            Container(height: 20),
            doubleLineField('Date', selectedIncidentReport[Strings.incidentDate], 'Time', selectedIncidentReport[Strings.incidentTime], TextOption.Date, TextOption.Time),
            Container(height: 10),
            Text('Incident Details', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 10, fontWeight: FontWeight.bold)),
            Container(height: 5),
            textField(TextOption.EncryptedText, selectedIncidentReport[Strings.incidentDetails], 700, 580, 580),
            Container(height: 10),
            Text('Incident Location', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 10, fontWeight: FontWeight.bold)),
            Container(height: 5),
            textField(TextOption.EncryptedText, selectedIncidentReport[Strings.incidentLocation], 700, 50, 50),
            Container(height: 10),
            Text('What action did you take?', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 10, fontWeight: FontWeight.bold)),
            Container(height: 5),
            textField(TextOption.EncryptedText, selectedIncidentReport[Strings.incidentAction], 700, 360, 360),
            Container(height: 10),
            Text('Staff involved', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 10, fontWeight: FontWeight.bold)),
            Container(height: 5),
            textField(TextOption.EncryptedText, selectedIncidentReport[Strings.incidentStaffInvolved], 700, 150, 150),
            Container(height: 10),
            doubleLineField('Signed', 'signature', 'Date', selectedIncidentReport[Strings.incidentSignatureDate], TextOption.PlainText, TextOption.Date, incidentSignatureImage, pdfDoc),
            singleLineField('Print Name', selectedIncidentReport[Strings.incidentPrintName], TextOption.EncryptedText, true),

          ]

      ));



      String formDate = selectedIncidentReport[Strings.incidentDate] == null ? '' : dateFormatDay.format(DateTime.parse(selectedIncidentReport[Strings.incidentDate]));
      String id = selectedIncidentReport[Strings.documentId];




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
            ..download = 'incident_report_form_${formDate}_$id.pdf';
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



        final File file = File('$pdfPath/incident_report_form_${formDate}_$id.pdf');

        if(option == ShareOption.Email){
          file.writeAsBytesSync(pdf.save());
        }

        ConnectivityResult connectivityResult = await Connectivity().checkConnectivity();

        if(connectivityResult != ConnectivityResult.none) {

          if(option == ShareOption.Share) Printing.sharePdf(bytes: pdf.save(),filename: 'incident_report_form_${formDate}_$id.pdf');
          if(option == ShareOption.Print) await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());

          if(option == ShareOption.Email) {
            final smtpServer = gmail(emailUsername, emailPassword);

            // Create our message.
            final mailmessage = new Message()
              ..from = new Address(emailUsername, 'Pegasus Medical')
              ..recipients = emailList
              ..subject = 'Completed Incident Report Form'
              ..html = "<p1>Dear Sir/Madam,</p1>\n<p>Attached is a completed Incident Report Form from ${user
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



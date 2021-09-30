import 'package:pegasus_medical_1808/models/share_option.dart';
import 'package:pegasus_medical_1808/services/navigation_service.dart';
import 'package:pegasus_medical_1808/shared/global_config.dart';
import 'package:pegasus_medical_1808/utils/database_helper.dart';
import 'dart:io';
import 'dart:typed_data';
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



class ObservationBookingModel extends ChangeNotifier {

  DatabaseHelper _databaseHelper = DatabaseHelper();
  AuthenticationModel authenticationModel = AuthenticationModel();
  final NavigationService _navigationService = locator<NavigationService>();
  ObservationBookingModel(this.authenticationModel);

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> _observationBookings = [];
  String _selObservationBookingId;
  final dateFormatDay = DateFormat("dd-MM-yyyy");

  List<Map<String, dynamic>> get allObservationBookings {
    return List.from(_observationBookings);
  }
  int get selectedObservationBookingIndex {
    return _observationBookings.indexWhere((Map<String, dynamic> observationBooking) {
      return observationBooking[Strings.documentId] == _selObservationBookingId;
    });
  }
  String get selectedObservationBookingId {
    return _selObservationBookingId;
  }

  Map<String, dynamic> get selectedObservationBooking {
    if (_selObservationBookingId == null) {
      return null;
    }
    return _observationBookings.firstWhere((Map<String, dynamic> observationBooking) {
      return observationBooking[Strings.documentId] == _selObservationBookingId;
    });
  }
  void selectObservationBooking(String observationBookingId) {
    _selObservationBookingId = observationBookingId;
    if (observationBookingId != null) {
      notifyListeners();
    }
  }

  void clearObservationBookings(){
    _observationBookings = [];
  }


  // Sembast database settings
  static const String TEMPORARY_OBSERVATION_BOOKINGS_STORE_NAME = 'temporary_observation_bookings';
  final _temporaryObservationBookingsStore = Db.intMapStoreFactory.store(TEMPORARY_OBSERVATION_BOOKINGS_STORE_NAME);

  static const String OBSERVATION_BOOKINGS_STORE_NAME = 'observation_bookings';
  final _observationBookingsStore = Db.intMapStoreFactory.store(OBSERVATION_BOOKINGS_STORE_NAME);

  static const String EDITED_OBSERVATION_BOOKINGS_STORE_NAME = 'edited_observation_bookings';
  final _editedObservationBookingsStore = Db.intMapStoreFactory.store(EDITED_OBSERVATION_BOOKINGS_STORE_NAME);

  static const String SAVED_OBSERVATION_BOOKINGS_STORE_NAME = 'saved_observation_bookings';
  final _savedObservationBookingsStore = Db.intMapStoreFactory.store(SAVED_OBSERVATION_BOOKINGS_STORE_NAME);

  // Private getter to shorten the amount of code needed to get the
  // singleton instance of an opened database.
  Future<Db.Database> get _db async => await AppDatabase.instance.database;


  Future<void> setupTemporaryRecord() async {

    final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
        [Db.Filter.equals(Strings.uid, user.uid), Db.Filter.equals(Strings.jobId, '1')]
    ));
    List records = await _temporaryObservationBookingsStore.find(
      await _db,
      finder: finder,
    );
    if(records.length == 0){
      // Generate a random ID based on the date and a random string for virtual zero chance of duplicates
      int _id = DateTime.now().millisecondsSinceEpoch + int.parse(random_string.randomNumeric(2));
      await _temporaryObservationBookingsStore.record(_id).put(await _db,
          {Strings.uid : user.uid, Strings.formVersion: 1, Strings.jobId : '1'});
    }
  }

  Future<Map<String, dynamic>> getTemporaryRecord(bool edit, String selectedJobId, bool saved, int savedId) async{

    List records;

    if(edit){
      final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
          [Db.Filter.equals(Strings.documentId, selectedObservationBooking[Strings.documentId]), Db.Filter.equals(Strings.jobId, selectedJobId)]
      ));
      records = await _editedObservationBookingsStore.find(
        await _db,
        finder: finder,
      );
    } else if(saved) {
      final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
          [Db.Filter.equals(Strings.uid, user.uid), Db.Filter.equals(Strings.localId, savedId)]
      ));
      records = await _savedObservationBookingsStore.find(
        await _db,
        finder: finder,
      );
    } else {
      final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
          [Db.Filter.equals(Strings.uid, user.uid), Db.Filter.equals(Strings.jobId, selectedJobId)]
      ));
      records = await _temporaryObservationBookingsStore.find(
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

    List records = await _observationBookingsStore.find(
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

    List records = await _observationBookingsStore.find(
      await _db,
      finder: finder,
    );

    return records;
  }

  Future <void> deletePendingRecord(int localId) async{
    final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
        [Db.Filter.equals(Strings.uid, user.uid), Db.Filter.equals(Strings.localId, localId)]
    ));

    await _observationBookingsStore.delete(
      await _db,
      finder: finder,
    );
  }

  Future <List<dynamic>> getSavedRecords() async{
    final Db.Finder finder = Db.Finder(filter: Db.Filter.equals(Strings.uid, user.uid));
    List records = await _savedObservationBookingsStore.find(
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
          [Db.Filter.equals(Strings.documentId, selectedObservationBooking[Strings.documentId]), Db.Filter.equals(Strings.jobId, selectedJobId)]
      ));
      records = await _editedObservationBookingsStore.find(
        await _db,
        finder: finder,
      );
    } else if(saved){
      final Db.Finder finder = Db.Finder(filter: Db.Filter.equals(Strings.localId, savedId));
      records = await _savedObservationBookingsStore.find(
        await _db,
        finder: finder,
      );

    } else {

      final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
          [Db.Filter.equals(Strings.uid, user.uid), Db.Filter.equals(Strings.jobId, selectedJobId)]
      ));
      records = await _temporaryObservationBookingsStore.find(
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
      await _editedObservationBookingsStore.update(await _db, {field: value},
          finder: finder);
    } else if(saved){
      final Db.Finder finder = Db.Finder(filter: Db.Filter.equals(Strings.localId, savedId));
      await _savedObservationBookingsStore.update(await _db, {field: value},
          finder: finder);
    } else {
      final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
          [Db.Filter.equals(Strings.uid, user.uid), Db.Filter.equals(Strings.jobId, selectedJobId)]
      ));
      await _temporaryObservationBookingsStore.update(await _db, {field: value},
          finder: finder);
    }

  }

  void deleteEditedRecord() async {
    await _editedObservationBookingsStore.delete(await _db);
  }

  Future<void> setUpEditedRecord() async{

    Map<String, dynamic> editedReport = editedObservationBooking(selectedObservationBooking);
    Map<String, dynamic> localData = Map.from(editedReport);
    await _editedObservationBookingsStore.delete(await _db);
    int _id = DateTime.now().millisecondsSinceEpoch + int.parse(random_string.randomNumeric(2));
    await _editedObservationBookingsStore.record(_id).put(await _db,
        localData);

  }

  Future<void> deleteAllRows() async {
    await _observationBookingsStore.delete(await _db);
  }

  Future<bool> saveForLater(String jobId, bool saved, int savedId) async {

    GlobalFunctions.showLoadingDialog('Saving Observation Booking...');
    String message = '';
    bool success = false;
    int id;

    if(saved){
      id = savedId;
    } else {
      id = DateTime.now().millisecondsSinceEpoch + int.parse(random_string.randomNumeric(2));
    }



    Map<String, dynamic> observationBooking = await getTemporaryRecord(false, '1', saved, savedId);

    Map<String, dynamic> localData = {
      Strings.localId: id,
      Strings.documentId: null,
      Strings.uid: user.uid,
      Strings.jobId: '1',
      Strings.formVersion: '1',
      Strings.jobRef: observationBooking[Strings.jobRef],
      Strings.obRequestedBy: observationBooking[Strings.obRequestedBy],
      Strings.obJobTitle: observationBooking[Strings.obJobTitle],
      Strings.obJobContact: observationBooking[Strings.obJobContact],
      Strings.obJobAuthorisingManager: observationBooking[Strings.obJobAuthorisingManager],
      Strings.obJobDate: observationBooking[Strings.obJobDate],
      Strings.obJobTime: observationBooking[Strings.obJobTime],
      Strings.obBookingCoordinator: observationBooking[Strings.obBookingCoordinator],
      Strings.obPatientLocation: observationBooking[Strings.obPatientLocation],
      Strings.obPostcode: observationBooking[Strings.obPostcode],
      Strings.obLocationTel: observationBooking[Strings.obLocationTel],
      Strings.obInvoiceDetails: observationBooking[Strings.obInvoiceDetails],
      Strings.obCostCode: observationBooking[Strings.obCostCode],
      Strings.obPurchaseOrder: observationBooking[Strings.obPurchaseOrder],
      Strings.obStartDateTime: observationBooking[Strings.obStartDateTime],
      Strings.obMhaAssessmentYes: observationBooking[Strings.obMhaAssessmentYes],
      Strings.obMhaAssessmentNo: observationBooking[Strings.obMhaAssessmentNo],
      Strings.obBedIdentifiedYes: observationBooking[Strings.obBedIdentifiedYes],
      Strings.obBedIdentifiedNo: observationBooking[Strings.obBedIdentifiedNo],
      Strings.obWrapDocumentationYes: observationBooking[Strings.obWrapDocumentationYes],
      Strings.obWrapDocumentationNo: observationBooking[Strings.obWrapDocumentationNo],
      Strings.obShiftRequired: observationBooking[Strings.obShiftRequired],
      Strings.obPatientName: observationBooking[Strings.obPatientName],
      Strings.obLegalStatus: observationBooking[Strings.obLegalStatus],
      Strings.obDateOfBirth: observationBooking[Strings.obDateOfBirth],
      Strings.obNhsNumber: observationBooking[Strings.obNhsNumber],
      Strings.obGender: observationBooking[Strings.obGender],
      Strings.obEthnicity: observationBooking[Strings.obEthnicity],
      Strings.obCovidStatus: observationBooking[Strings.obCovidStatus],
      Strings.obRmn: observationBooking[Strings.obRmn],
      Strings.obHca: observationBooking[Strings.obHca],
      Strings.obHca1: observationBooking[Strings.obHca1],
      Strings.obHca2: observationBooking[Strings.obHca2],
      Strings.obHca3: observationBooking[Strings.obHca3],
      Strings.obHca4: observationBooking[Strings.obHca4],
      Strings.obHca5: observationBooking[Strings.obHca5],
      Strings.obCurrentPresentation: observationBooking[Strings.obCurrentPresentation],
      Strings.obSpecificCarePlanYes: observationBooking[Strings.obSpecificCarePlanYes],
      Strings.obSpecificCarePlanNo: observationBooking[Strings.obSpecificCarePlanNo],
      Strings.obSpecificCarePlan: observationBooking[Strings.obSpecificCarePlan],
      Strings.obPatientWarningsYes: observationBooking[Strings.obPatientWarningsYes],
      Strings.obPatientWarningsNo: observationBooking[Strings.obPatientWarningsNo],
      Strings.obPatientWarnings: observationBooking[Strings.obPatientWarnings],
      Strings.obPresentingRisks: observationBooking[Strings.obPresentingRisks],
      Strings.obPreviousRisks: observationBooking[Strings.obPreviousRisks],
      Strings.obGenderConcernsYes: observationBooking[Strings.obGenderConcernsYes],
      Strings.obGenderConcernsNo: observationBooking[Strings.obGenderConcernsNo],
      Strings.obGenderConcerns: observationBooking[Strings.obGenderConcerns],
      Strings.obSafeguardingConcernsYes: observationBooking[Strings.obSafeguardingConcernsYes],
      Strings.obSafeguardingConcernsNo: observationBooking[Strings.obSafeguardingConcernsNo],
      Strings.obSafeguardingConcerns: observationBooking[Strings.obSafeguardingConcerns],
      Strings.obTimeDue: observationBooking[Strings.obTimeDue],
      Strings.obStaffDate1: observationBooking[Strings.obStaffDate1],
      Strings.obStaffDate2: observationBooking[Strings.obStaffDate2],
      Strings.obStaffDate3: observationBooking[Strings.obStaffDate3],
      Strings.obStaffDate4: observationBooking[Strings.obStaffDate4],
      Strings.obStaffDate5: observationBooking[Strings.obStaffDate5],
      Strings.obStaffDate6: observationBooking[Strings.obStaffDate6],
      Strings.obStaffDate7: observationBooking[Strings.obStaffDate7],
      Strings.obStaffDate8: observationBooking[Strings.obStaffDate8],
      Strings.obStaffDate9: observationBooking[Strings.obStaffDate9],
      Strings.obStaffDate10: observationBooking[Strings.obStaffDate10],
      Strings.obStaffDate11: observationBooking[Strings.obStaffDate11],
      Strings.obStaffDate12: observationBooking[Strings.obStaffDate12],
      Strings.obStaffDate13: observationBooking[Strings.obStaffDate13],
      Strings.obStaffDate14: observationBooking[Strings.obStaffDate14],
      Strings.obStaffDate15: observationBooking[Strings.obStaffDate15],
      Strings.obStaffDate16: observationBooking[Strings.obStaffDate16],
      Strings.obStaffDate17: observationBooking[Strings.obStaffDate17],
      Strings.obStaffDate18: observationBooking[Strings.obStaffDate18],
      Strings.obStaffDate19: observationBooking[Strings.obStaffDate19],
      Strings.obStaffDate20: observationBooking[Strings.obStaffDate20],
      Strings.obStaffStartTime1: observationBooking[Strings.obStaffStartTime1],
      Strings.obStaffStartTime2: observationBooking[Strings.obStaffStartTime2],
      Strings.obStaffStartTime3: observationBooking[Strings.obStaffStartTime3],
      Strings.obStaffStartTime4: observationBooking[Strings.obStaffStartTime4],
      Strings.obStaffStartTime5: observationBooking[Strings.obStaffStartTime5],
      Strings.obStaffStartTime6: observationBooking[Strings.obStaffStartTime6],
      Strings.obStaffStartTime7: observationBooking[Strings.obStaffStartTime7],
      Strings.obStaffStartTime8: observationBooking[Strings.obStaffStartTime8],
      Strings.obStaffStartTime9: observationBooking[Strings.obStaffStartTime9],
      Strings.obStaffStartTime10: observationBooking[Strings.obStaffStartTime10],
      Strings.obStaffStartTime11: observationBooking[Strings.obStaffStartTime11],
      Strings.obStaffStartTime12: observationBooking[Strings.obStaffStartTime12],
      Strings.obStaffStartTime13: observationBooking[Strings.obStaffStartTime13],
      Strings.obStaffStartTime14: observationBooking[Strings.obStaffStartTime14],
      Strings.obStaffStartTime15: observationBooking[Strings.obStaffStartTime15],
      Strings.obStaffStartTime16: observationBooking[Strings.obStaffStartTime16],
      Strings.obStaffStartTime17: observationBooking[Strings.obStaffStartTime17],
      Strings.obStaffStartTime18: observationBooking[Strings.obStaffStartTime18],
      Strings.obStaffStartTime19: observationBooking[Strings.obStaffStartTime19],
      Strings.obStaffStartTime20: observationBooking[Strings.obStaffStartTime20],
      Strings.obStaffEndTime1: observationBooking[Strings.obStaffEndTime1],
      Strings.obStaffEndTime2: observationBooking[Strings.obStaffEndTime2],
      Strings.obStaffEndTime3: observationBooking[Strings.obStaffEndTime3],
      Strings.obStaffEndTime4: observationBooking[Strings.obStaffEndTime4],
      Strings.obStaffEndTime5: observationBooking[Strings.obStaffEndTime5],
      Strings.obStaffEndTime6: observationBooking[Strings.obStaffEndTime6],
      Strings.obStaffEndTime7: observationBooking[Strings.obStaffEndTime7],
      Strings.obStaffEndTime8: observationBooking[Strings.obStaffEndTime8],
      Strings.obStaffEndTime9: observationBooking[Strings.obStaffEndTime9],
      Strings.obStaffEndTime10: observationBooking[Strings.obStaffEndTime10],
      Strings.obStaffEndTime11: observationBooking[Strings.obStaffEndTime11],
      Strings.obStaffEndTime12: observationBooking[Strings.obStaffEndTime12],
      Strings.obStaffEndTime13: observationBooking[Strings.obStaffEndTime13],
      Strings.obStaffEndTime14: observationBooking[Strings.obStaffEndTime14],
      Strings.obStaffEndTime15: observationBooking[Strings.obStaffEndTime15],
      Strings.obStaffEndTime16: observationBooking[Strings.obStaffEndTime16],
      Strings.obStaffEndTime17: observationBooking[Strings.obStaffEndTime17],
      Strings.obStaffEndTime18: observationBooking[Strings.obStaffEndTime18],
      Strings.obStaffEndTime19: observationBooking[Strings.obStaffEndTime19],
      Strings.obStaffEndTime20: observationBooking[Strings.obStaffEndTime20],
      Strings.obStaffName1: observationBooking[Strings.obStaffName1],
      Strings.obStaffName2: observationBooking[Strings.obStaffName2],
      Strings.obStaffName3: observationBooking[Strings.obStaffName3],
      Strings.obStaffName4: observationBooking[Strings.obStaffName4],
      Strings.obStaffName5: observationBooking[Strings.obStaffName5],
      Strings.obStaffName6: observationBooking[Strings.obStaffName6],
      Strings.obStaffName7: observationBooking[Strings.obStaffName7],
      Strings.obStaffName8: observationBooking[Strings.obStaffName8],
      Strings.obStaffName9: observationBooking[Strings.obStaffName9],
      Strings.obStaffName10: observationBooking[Strings.obStaffName10],
      Strings.obStaffName11: observationBooking[Strings.obStaffName11],
      Strings.obStaffName12: observationBooking[Strings.obStaffName12],
      Strings.obStaffName13: observationBooking[Strings.obStaffName13],
      Strings.obStaffName14: observationBooking[Strings.obStaffName14],
      Strings.obStaffName15: observationBooking[Strings.obStaffName15],
      Strings.obStaffName16: observationBooking[Strings.obStaffName16],
      Strings.obStaffName17: observationBooking[Strings.obStaffName17],
      Strings.obStaffName18: observationBooking[Strings.obStaffName18],
      Strings.obStaffName19: observationBooking[Strings.obStaffName19],
      Strings.obStaffName20: observationBooking[Strings.obStaffName20],
      Strings.obStaffRmn1: observationBooking[Strings.obStaffRmn1],
      Strings.obStaffRmn2: observationBooking[Strings.obStaffRmn2],
      Strings.obStaffRmn3: observationBooking[Strings.obStaffRmn3],
      Strings.obStaffRmn4: observationBooking[Strings.obStaffRmn4],
      Strings.obStaffRmn5: observationBooking[Strings.obStaffRmn5],
      Strings.obStaffRmn6: observationBooking[Strings.obStaffRmn6],
      Strings.obStaffRmn7: observationBooking[Strings.obStaffRmn7],
      Strings.obStaffRmn8: observationBooking[Strings.obStaffRmn8],
      Strings.obStaffRmn9: observationBooking[Strings.obStaffRmn9],
      Strings.obStaffRmn10: observationBooking[Strings.obStaffRmn10],
      Strings.obStaffRmn11: observationBooking[Strings.obStaffRmn11],
      Strings.obStaffRmn12: observationBooking[Strings.obStaffRmn12],
      Strings.obStaffRmn13: observationBooking[Strings.obStaffRmn13],
      Strings.obStaffRmn14: observationBooking[Strings.obStaffRmn14],
      Strings.obStaffRmn15: observationBooking[Strings.obStaffRmn15],
      Strings.obStaffRmn16: observationBooking[Strings.obStaffRmn16],
      Strings.obStaffRmn17: observationBooking[Strings.obStaffRmn17],
      Strings.obStaffRmn18: observationBooking[Strings.obStaffRmn18],
      Strings.obStaffRmn19: observationBooking[Strings.obStaffRmn19],
      Strings.obStaffRmn20: observationBooking[Strings.obStaffRmn20],
      Strings.obUsefulDetails: observationBooking[Strings.obUsefulDetails],
    };

    await _savedObservationBookingsStore.record(id).put(await _db,
        localData);

    message = 'Observation Booking saved to device';
    success = true;

    if(success) resetTemporaryRecord(jobId, false, 0);
    GlobalFunctions.dismissLoadingDialog();
    GlobalFunctions.showToast(message);
    return success;
  }

  Future<void> deleteSavedRecord(int id) async {
    await _savedObservationBookingsStore.record(id).delete(await _db);
    _observationBookings.removeWhere((element) => element[Strings.localId] == id);
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

        _observationBookings = List.from(_fetchedRecordList.reversed);
      } else {
        message = 'No saved records available';
      }

    } catch(e){
      print(e);
      message = 'Something went wrong. Please try again';

    }
    _isLoading = false;
    notifyListeners();
    _selObservationBookingId = null;
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

    await _temporaryObservationBookingsStore.update(await _db, {
      Strings.formVersion: 1,
      Strings.jobRef: null,
      Strings.obRequestedBy: null,
      Strings.obJobTitle: null,
      Strings.obJobContact: null,
      Strings.obJobAuthorisingManager: null,
      Strings.obJobDate: null,
      Strings.obJobTime: null,
      Strings.obBookingCoordinator: null,
      Strings.obPatientLocation: null,
      Strings.obPostcode: null,
      Strings.obLocationTel: null,
      Strings.obInvoiceDetails: null,
      Strings.obCostCode: null,
      Strings.obPurchaseOrder: null,
      Strings.obStartDateTime: null,
      Strings.obMhaAssessmentYes: null,
      Strings.obMhaAssessmentNo: null,
      Strings.obBedIdentifiedYes: null,
      Strings.obBedIdentifiedNo: null,
      Strings.obWrapDocumentationYes: null,
      Strings.obWrapDocumentationNo: null,
      Strings.obShiftRequired: null,
      Strings.obPatientName: null,
      Strings.obLegalStatus: null,
      Strings.obDateOfBirth: null,
      Strings.obNhsNumber: null,
      Strings.obGender: null,
      Strings.obEthnicity: null,
      Strings.obCovidStatus: null,
      Strings.obRmn: null,
      Strings.obHca: null,
      Strings.obHca1: null,
      Strings.obHca2: null,
      Strings.obHca3: null,
      Strings.obHca4: null,
      Strings.obHca5: null,
      Strings.obCurrentPresentation: null,
      Strings.obSpecificCarePlanYes: null,
      Strings.obSpecificCarePlanNo: null,
      Strings.obSpecificCarePlan: null,
      Strings.obPatientWarningsYes: null,
      Strings.obPatientWarningsNo: null,
      Strings.obPatientWarnings: null,
      Strings.obPresentingRisks: null,
      Strings.obPreviousRisks: null,
      Strings.obGenderConcernsYes: null,
      Strings.obGenderConcernsNo: null,
      Strings.obGenderConcerns: null,
      Strings.obSafeguardingConcernsYes: null,
      Strings.obSafeguardingConcernsNo: null,
      Strings.obSafeguardingConcerns: null,
      Strings.obTimeDue: null,
      Strings.obStaffDate1: null,
      Strings.obStaffDate2: null,
      Strings.obStaffDate3: null,
      Strings.obStaffDate4: null,
      Strings.obStaffDate5: null,
      Strings.obStaffDate6: null,
      Strings.obStaffDate7: null,
      Strings.obStaffDate8: null,
      Strings.obStaffDate9: null,
      Strings.obStaffDate10: null,
      Strings.obStaffDate11: null,
      Strings.obStaffDate12: null,
      Strings.obStaffDate13: null,
      Strings.obStaffDate14: null,
      Strings.obStaffDate15: null,
      Strings.obStaffDate16: null,
      Strings.obStaffDate17: null,
      Strings.obStaffDate18: null,
      Strings.obStaffDate19: null,
      Strings.obStaffDate20: null,
      Strings.obStaffStartTime1: null,
      Strings.obStaffStartTime2: null,
      Strings.obStaffStartTime3: null,
      Strings.obStaffStartTime4: null,
      Strings.obStaffStartTime5: null,
      Strings.obStaffStartTime6: null,
      Strings.obStaffStartTime7: null,
      Strings.obStaffStartTime8: null,
      Strings.obStaffStartTime9: null,
      Strings.obStaffStartTime10: null,
      Strings.obStaffStartTime11: null,
      Strings.obStaffStartTime12: null,
      Strings.obStaffStartTime13: null,
      Strings.obStaffStartTime14: null,
      Strings.obStaffStartTime15: null,
      Strings.obStaffStartTime16: null,
      Strings.obStaffStartTime17: null,
      Strings.obStaffStartTime18: null,
      Strings.obStaffStartTime19: null,
      Strings.obStaffStartTime20: null,
      Strings.obStaffEndTime1: null,
      Strings.obStaffEndTime2: null,
      Strings.obStaffEndTime3: null,
      Strings.obStaffEndTime4: null,
      Strings.obStaffEndTime5: null,
      Strings.obStaffEndTime6: null,
      Strings.obStaffEndTime7: null,
      Strings.obStaffEndTime8: null,
      Strings.obStaffEndTime9: null,
      Strings.obStaffEndTime10: null,
      Strings.obStaffEndTime11: null,
      Strings.obStaffEndTime12: null,
      Strings.obStaffEndTime13: null,
      Strings.obStaffEndTime14: null,
      Strings.obStaffEndTime15: null,
      Strings.obStaffEndTime16: null,
      Strings.obStaffEndTime17: null,
      Strings.obStaffEndTime18: null,
      Strings.obStaffEndTime19: null,
      Strings.obStaffEndTime20: null,
      Strings.obStaffName1: null,
      Strings.obStaffName2: null,
      Strings.obStaffName3: null,
      Strings.obStaffName4: null,
      Strings.obStaffName5: null,
      Strings.obStaffName6: null,
      Strings.obStaffName7: null,
      Strings.obStaffName8: null,
      Strings.obStaffName9: null,
      Strings.obStaffName10: null,
      Strings.obStaffName11: null,
      Strings.obStaffName12: null,
      Strings.obStaffName13: null,
      Strings.obStaffName14: null,
      Strings.obStaffName15: null,
      Strings.obStaffName16: null,
      Strings.obStaffName17: null,
      Strings.obStaffName18: null,
      Strings.obStaffName19: null,
      Strings.obStaffName20: null,
      Strings.obStaffRmn1: null,
      Strings.obStaffRmn2: null,
      Strings.obStaffRmn3: null,
      Strings.obStaffRmn4: null,
      Strings.obStaffRmn5: null,
      Strings.obStaffRmn6: null,
      Strings.obStaffRmn7: null,
      Strings.obStaffRmn8: null,
      Strings.obStaffRmn9: null,
      Strings.obStaffRmn10: null,
      Strings.obStaffRmn11: null,
      Strings.obStaffRmn12: null,
      Strings.obStaffRmn13: null,
      Strings.obStaffRmn14: null,
      Strings.obStaffRmn15: null,
      Strings.obStaffRmn16: null,
      Strings.obStaffRmn17: null,
      Strings.obStaffRmn18: null,
      Strings.obStaffRmn19: null,
      Strings.obStaffRmn20: null,
      Strings.obUsefulDetails: null,

    },
        finder: finder);
    notifyListeners();
  }

  Future<bool> validateObservationBooking(String jobId, bool edit, bool saved, int savedId) async {

    bool success = true;

    //Map<String, dynamic> observationBooking = await _databaseHelper.getTemporaryObservationBooking(edit, user.uid, jobId);
    Map<String, dynamic> observationBooking = await getTemporaryRecord(edit, jobId, saved, savedId);


    if(observationBooking[Strings.jobRef]== null || observationBooking[Strings.jobRef].toString().trim() == ''){
      success = false;
    }

    if(observationBooking[Strings.obRequestedBy]== null || observationBooking[Strings.obRequestedBy].toString().trim() == ''){
      success = false;
    }

    if(observationBooking[Strings.obJobTitle]== null || observationBooking[Strings.obJobTitle].toString().trim() == ''){
      success = false;
    }

    if(observationBooking[Strings.obJobContact]== null || observationBooking[Strings.obJobContact].toString().trim() == ''){
      success = false;
    }

    if(observationBooking[Strings.obJobAuthorisingManager]== null || observationBooking[Strings.obJobAuthorisingManager].toString().trim() == ''){
      success = false;
    }

    if(observationBooking[Strings.obJobDate] == null){
      success = false;
    }

    if(observationBooking[Strings.obJobTime] == null){
      success = false;
    }

    if(observationBooking[Strings.obBookingCoordinator]== null || observationBooking[Strings.obBookingCoordinator].toString().trim() == ''){
      success = false;
    }

    if(observationBooking[Strings.obStartDateTime] == null){
      success = false;
    }

    if(observationBooking[Strings.obPatientLocation]== null || observationBooking[Strings.obPatientLocation].toString().trim() == ''){
      success = false;
    }

    if(observationBooking[Strings.obPostcode]== null || observationBooking[Strings.obPostcode].toString().trim() == ''){
      success = false;
    }

    if(observationBooking[Strings.obLocationTel]== null || observationBooking[Strings.obLocationTel].toString().trim() == ''){
      success = false;
    }

    if(observationBooking[Strings.obMhaAssessmentYes] == null && observationBooking[Strings.obMhaAssessmentNo] == null){
      success = false;
    }
    if(observationBooking[Strings.obMhaAssessmentYes] == 0 && observationBooking[Strings.obMhaAssessmentNo] == 0){
      success = false;
    }
    if(observationBooking[Strings.obMhaAssessmentYes] == null && observationBooking[Strings.obMhaAssessmentNo] == 0){
      success = false;
    }
    if(observationBooking[Strings.obMhaAssessmentYes] == 0 && observationBooking[Strings.obMhaAssessmentNo] == null){
      success = false;
    }

    if(observationBooking[Strings.obBedIdentifiedYes] == null && observationBooking[Strings.obBedIdentifiedNo] == null){
      success = false;
    }
    if(observationBooking[Strings.obBedIdentifiedYes] == 0 && observationBooking[Strings.obBedIdentifiedNo] == 0){
      success = false;
    }
    if(observationBooking[Strings.obBedIdentifiedYes] == null && observationBooking[Strings.obBedIdentifiedNo] == 0){
      success = false;
    }
    if(observationBooking[Strings.obBedIdentifiedYes] == 0 && observationBooking[Strings.obBedIdentifiedNo] == null){
      success = false;
    }

    if(observationBooking[Strings.obWrapDocumentationYes] == null && observationBooking[Strings.obWrapDocumentationNo] == null){
      success = false;
    }
    if(observationBooking[Strings.obWrapDocumentationYes] == 0 && observationBooking[Strings.obWrapDocumentationNo] == 0){
      success = false;
    }
    if(observationBooking[Strings.obWrapDocumentationYes] == null && observationBooking[Strings.obWrapDocumentationNo] == 0){
      success = false;
    }
    if(observationBooking[Strings.obWrapDocumentationYes] == 0 && observationBooking[Strings.obWrapDocumentationNo] == null){
      success = false;
    }

    if(observationBooking[Strings.obShiftRequired]== null || observationBooking[Strings.obShiftRequired].toString().trim() == ''){
      success = false;
    }

    if(observationBooking[Strings.obPatientName]== null || observationBooking[Strings.obPatientName].toString().trim() == ''){
      success = false;
    }

    if(observationBooking[Strings.obLegalStatus]== null || observationBooking[Strings.obLegalStatus].toString().trim() == ''){
      success = false;
    }

    if(observationBooking[Strings.obDateOfBirth] == null){
      success = false;
    }

    if(observationBooking[Strings.obNhsNumber]== null || observationBooking[Strings.obNhsNumber].toString().trim() == ''){
      success = false;
    }

    if(observationBooking[Strings.obCurrentPresentation]== null || observationBooking[Strings.obCurrentPresentation].toString().trim() == ''){
      success = false;
    }

    if(observationBooking[Strings.obGender]== null || observationBooking[Strings.obGender].toString().trim() == ''){
      success = false;
    }

    if(observationBooking[Strings.obEthnicity]== null || observationBooking[Strings.obEthnicity].toString().trim() == ''){
      success = false;
    }

    if(observationBooking[Strings.obCovidStatus]== null || observationBooking[Strings.obCovidStatus].toString().trim() == ''){
      success = false;
    }


    if(observationBooking[Strings.obSpecificCarePlanYes] == null && observationBooking[Strings.obSpecificCarePlanNo] == null){
      success = false;
    }
    if(observationBooking[Strings.obSpecificCarePlanYes] == 0 && observationBooking[Strings.obSpecificCarePlanNo] == 0){
      success = false;
    }
    if(observationBooking[Strings.obSpecificCarePlanYes] == null && observationBooking[Strings.obSpecificCarePlanNo] == 0){
      success = false;
    }
    if(observationBooking[Strings.obSpecificCarePlanYes] == 0 && observationBooking[Strings.obSpecificCarePlanNo] == null){
      success = false;
    }


    if(observationBooking[Strings.obSpecificCarePlanYes] == 1){
      if(observationBooking[Strings.obSpecificCarePlan]== null || observationBooking[Strings.obSpecificCarePlan].toString().trim() == ''){
        success = false;
      }

    }

    if(observationBooking[Strings.obPatientWarningsYes] == null && observationBooking[Strings.obPatientWarningsNo] == null){
      success = false;
    }
    if(observationBooking[Strings.obPatientWarningsYes] == 0 && observationBooking[Strings.obPatientWarningsNo] == 0){
      success = false;
    }
    if(observationBooking[Strings.obPatientWarningsYes] == null && observationBooking[Strings.obPatientWarningsNo] == 0){
      success = false;
    }
    if(observationBooking[Strings.obPatientWarningsYes] == 0 && observationBooking[Strings.obPatientWarningsNo] == null){
      success = false;
    }


    if(observationBooking[Strings.obPatientWarningsYes] == 1){
      if(observationBooking[Strings.obPatientWarnings]== null || observationBooking[Strings.obPatientWarnings].toString().trim() == ''){
        success = false;
      }

    }

    if(observationBooking[Strings.obPresentingRisks]== null || observationBooking[Strings.obPresentingRisks].toString().trim() == ''){
      success = false;
    }

    if(observationBooking[Strings.obPreviousRisks]== null || observationBooking[Strings.obPreviousRisks].toString().trim() == ''){
      success = false;
    }

    if(observationBooking[Strings.obGenderConcernsYes] == null && observationBooking[Strings.obGenderConcernsNo] == null){
      success = false;
    }
    if(observationBooking[Strings.obGenderConcernsYes] == 0 && observationBooking[Strings.obGenderConcernsNo] == 0){
      success = false;
    }
    if(observationBooking[Strings.obGenderConcernsYes] == null && observationBooking[Strings.obGenderConcernsNo] == 0){
      success = false;
    }
    if(observationBooking[Strings.obGenderConcernsYes] == 0 && observationBooking[Strings.obGenderConcernsNo] == null){
      success = false;
    }


    if(observationBooking[Strings.obGenderConcernsYes] == 1){
      if(observationBooking[Strings.obGenderConcerns]== null || observationBooking[Strings.obGenderConcerns].toString().trim() == ''){
        success = false;
      }

    }

    if(observationBooking[Strings.obSafeguardingConcernsYes] == null && observationBooking[Strings.obSafeguardingConcernsNo] == null){
      success = false;
    }
    if(observationBooking[Strings.obSafeguardingConcernsYes] == 0 && observationBooking[Strings.obSafeguardingConcernsNo] == 0){
      success = false;
    }
    if(observationBooking[Strings.obSafeguardingConcernsYes] == null && observationBooking[Strings.obSafeguardingConcernsNo] == 0){
      success = false;
    }
    if(observationBooking[Strings.obSafeguardingConcernsYes] == 0 && observationBooking[Strings.obSafeguardingConcernsNo] == null){
      success = false;
    }


    if(observationBooking[Strings.obSafeguardingConcernsYes] == 1){
      if(observationBooking[Strings.obSafeguardingConcerns]== null || observationBooking[Strings.obSafeguardingConcerns].toString().trim() == ''){
        success = false;
      }

    }

    if(observationBooking[Strings.obTimeDue] == null){
      success = false;
    }

    return success;

  }

  Future<bool> submitObservationBooking(String jobId, bool edit, bool saved, int savedId) async {

    GlobalFunctions.showLoadingDialog('Submitting Observation Booking...');
    String message = '';
    bool success = false;
    int id = DateTime.now().millisecondsSinceEpoch + int.parse(random_string.randomNumeric(2));

    //Sembast
    Map<String, dynamic> observationBooking = await getTemporaryRecord(false, jobId, saved, savedId);

    Map<String, dynamic> localData = {
      Strings.localId: id,
      Strings.documentId: null,
      Strings.uid: user.uid,
      Strings.jobId: '1',
      Strings.formVersion: '1',
      Strings.jobRef: observationBooking[Strings.jobRef],
      Strings.obRequestedBy: observationBooking[Strings.obRequestedBy],
      Strings.obJobTitle: observationBooking[Strings.obJobTitle],
      Strings.obJobContact: observationBooking[Strings.obJobContact],
      Strings.obJobAuthorisingManager: observationBooking[Strings.obJobAuthorisingManager],
      Strings.obJobDate: observationBooking[Strings.obJobDate],
      Strings.obJobTime: observationBooking[Strings.obJobTime],
      Strings.obBookingCoordinator: observationBooking[Strings.obBookingCoordinator],
      Strings.obPatientLocation: observationBooking[Strings.obPatientLocation],
      Strings.obPostcode: observationBooking[Strings.obPostcode],
      Strings.obLocationTel: observationBooking[Strings.obLocationTel],
      Strings.obInvoiceDetails: observationBooking[Strings.obInvoiceDetails],
      Strings.obCostCode: observationBooking[Strings.obCostCode],
      Strings.obPurchaseOrder: observationBooking[Strings.obPurchaseOrder],
      Strings.obStartDateTime: observationBooking[Strings.obStartDateTime],
      Strings.obMhaAssessmentYes: observationBooking[Strings.obMhaAssessmentYes],
      Strings.obMhaAssessmentNo: observationBooking[Strings.obMhaAssessmentNo],
      Strings.obBedIdentifiedYes: observationBooking[Strings.obBedIdentifiedYes],
      Strings.obBedIdentifiedNo: observationBooking[Strings.obBedIdentifiedNo],
      Strings.obWrapDocumentationYes: observationBooking[Strings.obWrapDocumentationYes],
      Strings.obWrapDocumentationNo: observationBooking[Strings.obWrapDocumentationNo],
      Strings.obShiftRequired: observationBooking[Strings.obShiftRequired],
      Strings.obPatientName: observationBooking[Strings.obPatientName],
      Strings.obLegalStatus: observationBooking[Strings.obLegalStatus],
      Strings.obDateOfBirth: observationBooking[Strings.obDateOfBirth],
      Strings.obNhsNumber: observationBooking[Strings.obNhsNumber],
      Strings.obGender: observationBooking[Strings.obGender],
      Strings.obEthnicity: observationBooking[Strings.obEthnicity],
      Strings.obCovidStatus: observationBooking[Strings.obCovidStatus],
      Strings.obRmn: observationBooking[Strings.obRmn],
      Strings.obHca: observationBooking[Strings.obHca],
      Strings.obHca1: observationBooking[Strings.obHca1],
      Strings.obHca2: observationBooking[Strings.obHca2],
      Strings.obHca3: observationBooking[Strings.obHca3],
      Strings.obHca4: observationBooking[Strings.obHca4],
      Strings.obHca5: observationBooking[Strings.obHca5],
      Strings.obCurrentPresentation: observationBooking[Strings.obCurrentPresentation],
      Strings.obSpecificCarePlanYes: observationBooking[Strings.obSpecificCarePlanYes],
      Strings.obSpecificCarePlanNo: observationBooking[Strings.obSpecificCarePlanNo],
      Strings.obSpecificCarePlan: observationBooking[Strings.obSpecificCarePlan],
      Strings.obPatientWarningsYes: observationBooking[Strings.obPatientWarningsYes],
      Strings.obPatientWarningsNo: observationBooking[Strings.obPatientWarningsNo],
      Strings.obPatientWarnings: observationBooking[Strings.obPatientWarnings],
      Strings.obPresentingRisks: observationBooking[Strings.obPresentingRisks],
      Strings.obPreviousRisks: observationBooking[Strings.obPreviousRisks],
      Strings.obGenderConcernsYes: observationBooking[Strings.obGenderConcernsYes],
      Strings.obGenderConcernsNo: observationBooking[Strings.obGenderConcernsNo],
      Strings.obGenderConcerns: observationBooking[Strings.obGenderConcerns],
      Strings.obSafeguardingConcernsYes: observationBooking[Strings.obSafeguardingConcernsYes],
      Strings.obSafeguardingConcernsNo: observationBooking[Strings.obSafeguardingConcernsNo],
      Strings.obSafeguardingConcerns: observationBooking[Strings.obSafeguardingConcerns],
      Strings.obTimeDue: observationBooking[Strings.obTimeDue],
      Strings.obStaffDate1: observationBooking[Strings.obStaffDate1],
      Strings.obStaffDate2: observationBooking[Strings.obStaffDate2],
      Strings.obStaffDate3: observationBooking[Strings.obStaffDate3],
      Strings.obStaffDate4: observationBooking[Strings.obStaffDate4],
      Strings.obStaffDate5: observationBooking[Strings.obStaffDate5],
      Strings.obStaffDate6: observationBooking[Strings.obStaffDate6],
      Strings.obStaffDate7: observationBooking[Strings.obStaffDate7],
      Strings.obStaffDate8: observationBooking[Strings.obStaffDate8],
      Strings.obStaffDate9: observationBooking[Strings.obStaffDate9],
      Strings.obStaffDate10: observationBooking[Strings.obStaffDate10],
      Strings.obStaffDate11: observationBooking[Strings.obStaffDate11],
      Strings.obStaffDate12: observationBooking[Strings.obStaffDate12],
      Strings.obStaffDate13: observationBooking[Strings.obStaffDate13],
      Strings.obStaffDate14: observationBooking[Strings.obStaffDate14],
      Strings.obStaffDate15: observationBooking[Strings.obStaffDate15],
      Strings.obStaffDate16: observationBooking[Strings.obStaffDate16],
      Strings.obStaffDate17: observationBooking[Strings.obStaffDate17],
      Strings.obStaffDate18: observationBooking[Strings.obStaffDate18],
      Strings.obStaffDate19: observationBooking[Strings.obStaffDate19],
      Strings.obStaffDate20: observationBooking[Strings.obStaffDate20],
      Strings.obStaffStartTime1: observationBooking[Strings.obStaffStartTime1],
      Strings.obStaffStartTime2: observationBooking[Strings.obStaffStartTime2],
      Strings.obStaffStartTime3: observationBooking[Strings.obStaffStartTime3],
      Strings.obStaffStartTime4: observationBooking[Strings.obStaffStartTime4],
      Strings.obStaffStartTime5: observationBooking[Strings.obStaffStartTime5],
      Strings.obStaffStartTime6: observationBooking[Strings.obStaffStartTime6],
      Strings.obStaffStartTime7: observationBooking[Strings.obStaffStartTime7],
      Strings.obStaffStartTime8: observationBooking[Strings.obStaffStartTime8],
      Strings.obStaffStartTime9: observationBooking[Strings.obStaffStartTime9],
      Strings.obStaffStartTime10: observationBooking[Strings.obStaffStartTime10],
      Strings.obStaffStartTime11: observationBooking[Strings.obStaffStartTime11],
      Strings.obStaffStartTime12: observationBooking[Strings.obStaffStartTime12],
      Strings.obStaffStartTime13: observationBooking[Strings.obStaffStartTime13],
      Strings.obStaffStartTime14: observationBooking[Strings.obStaffStartTime14],
      Strings.obStaffStartTime15: observationBooking[Strings.obStaffStartTime15],
      Strings.obStaffStartTime16: observationBooking[Strings.obStaffStartTime16],
      Strings.obStaffStartTime17: observationBooking[Strings.obStaffStartTime17],
      Strings.obStaffStartTime18: observationBooking[Strings.obStaffStartTime18],
      Strings.obStaffStartTime19: observationBooking[Strings.obStaffStartTime19],
      Strings.obStaffStartTime20: observationBooking[Strings.obStaffStartTime20],
      Strings.obStaffEndTime1: observationBooking[Strings.obStaffEndTime1],
      Strings.obStaffEndTime2: observationBooking[Strings.obStaffEndTime2],
      Strings.obStaffEndTime3: observationBooking[Strings.obStaffEndTime3],
      Strings.obStaffEndTime4: observationBooking[Strings.obStaffEndTime4],
      Strings.obStaffEndTime5: observationBooking[Strings.obStaffEndTime5],
      Strings.obStaffEndTime6: observationBooking[Strings.obStaffEndTime6],
      Strings.obStaffEndTime7: observationBooking[Strings.obStaffEndTime7],
      Strings.obStaffEndTime8: observationBooking[Strings.obStaffEndTime8],
      Strings.obStaffEndTime9: observationBooking[Strings.obStaffEndTime9],
      Strings.obStaffEndTime10: observationBooking[Strings.obStaffEndTime10],
      Strings.obStaffEndTime11: observationBooking[Strings.obStaffEndTime11],
      Strings.obStaffEndTime12: observationBooking[Strings.obStaffEndTime12],
      Strings.obStaffEndTime13: observationBooking[Strings.obStaffEndTime13],
      Strings.obStaffEndTime14: observationBooking[Strings.obStaffEndTime14],
      Strings.obStaffEndTime15: observationBooking[Strings.obStaffEndTime15],
      Strings.obStaffEndTime16: observationBooking[Strings.obStaffEndTime16],
      Strings.obStaffEndTime17: observationBooking[Strings.obStaffEndTime17],
      Strings.obStaffEndTime18: observationBooking[Strings.obStaffEndTime18],
      Strings.obStaffEndTime19: observationBooking[Strings.obStaffEndTime19],
      Strings.obStaffEndTime20: observationBooking[Strings.obStaffEndTime20],
      Strings.obStaffName1: observationBooking[Strings.obStaffName1],
      Strings.obStaffName2: observationBooking[Strings.obStaffName2],
      Strings.obStaffName3: observationBooking[Strings.obStaffName3],
      Strings.obStaffName4: observationBooking[Strings.obStaffName4],
      Strings.obStaffName5: observationBooking[Strings.obStaffName5],
      Strings.obStaffName6: observationBooking[Strings.obStaffName6],
      Strings.obStaffName7: observationBooking[Strings.obStaffName7],
      Strings.obStaffName8: observationBooking[Strings.obStaffName8],
      Strings.obStaffName9: observationBooking[Strings.obStaffName9],
      Strings.obStaffName10: observationBooking[Strings.obStaffName10],
      Strings.obStaffName11: observationBooking[Strings.obStaffName11],
      Strings.obStaffName12: observationBooking[Strings.obStaffName12],
      Strings.obStaffName13: observationBooking[Strings.obStaffName13],
      Strings.obStaffName14: observationBooking[Strings.obStaffName14],
      Strings.obStaffName15: observationBooking[Strings.obStaffName15],
      Strings.obStaffName16: observationBooking[Strings.obStaffName16],
      Strings.obStaffName17: observationBooking[Strings.obStaffName17],
      Strings.obStaffName18: observationBooking[Strings.obStaffName18],
      Strings.obStaffName19: observationBooking[Strings.obStaffName19],
      Strings.obStaffName20: observationBooking[Strings.obStaffName20],
      Strings.obStaffRmn1: observationBooking[Strings.obStaffRmn1],
      Strings.obStaffRmn2: observationBooking[Strings.obStaffRmn2],
      Strings.obStaffRmn3: observationBooking[Strings.obStaffRmn3],
      Strings.obStaffRmn4: observationBooking[Strings.obStaffRmn4],
      Strings.obStaffRmn5: observationBooking[Strings.obStaffRmn5],
      Strings.obStaffRmn6: observationBooking[Strings.obStaffRmn6],
      Strings.obStaffRmn7: observationBooking[Strings.obStaffRmn7],
      Strings.obStaffRmn8: observationBooking[Strings.obStaffRmn8],
      Strings.obStaffRmn9: observationBooking[Strings.obStaffRmn9],
      Strings.obStaffRmn10: observationBooking[Strings.obStaffRmn10],
      Strings.obStaffRmn11: observationBooking[Strings.obStaffRmn11],
      Strings.obStaffRmn12: observationBooking[Strings.obStaffRmn12],
      Strings.obStaffRmn13: observationBooking[Strings.obStaffRmn13],
      Strings.obStaffRmn14: observationBooking[Strings.obStaffRmn14],
      Strings.obStaffRmn15: observationBooking[Strings.obStaffRmn15],
      Strings.obStaffRmn16: observationBooking[Strings.obStaffRmn16],
      Strings.obStaffRmn17: observationBooking[Strings.obStaffRmn17],
      Strings.obStaffRmn18: observationBooking[Strings.obStaffRmn18],
      Strings.obStaffRmn19: observationBooking[Strings.obStaffRmn19],
      Strings.obStaffRmn20: observationBooking[Strings.obStaffRmn20],
      Strings.obUsefulDetails: observationBooking[Strings.obUsefulDetails],
      Strings.pendingTime: DateTime.now().toIso8601String(),
      Strings.serverUploaded: 0,
    };

    //Sembast
    await _observationBookingsStore.record(id).put(await _db,
        localData);

    message = 'Observation Booking has successfully been added to local database';
    bool hasDataConnection = await GlobalFunctions.hasDataConnection();

    if(hasDataConnection){

      bool isTokenExpired = GlobalFunctions.isTokenExpired();
      bool authenticated = true;

      if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

      if(authenticated){


        try {

          await FirebaseFirestore.instance.collection('observation_bookings').add({
            Strings.uid: user.uid,
            Strings.jobId: '1',
            Strings.formVersion: '1',
            Strings.jobRef: GlobalFunctions.databaseValueString(observationBooking[Strings.jobRef]),
            Strings.jobRefLowercase: GlobalFunctions.databaseValueString(observationBooking[Strings.jobRef]).toLowerCase(),
            Strings.obRequestedBy: observationBooking[Strings.obRequestedBy],
            Strings.obJobTitle: observationBooking[Strings.obJobTitle],
            Strings.obJobContact: observationBooking[Strings.obJobContact],
            Strings.obJobAuthorisingManager: observationBooking[Strings.obJobAuthorisingManager],
            Strings.obJobDate: observationBooking[Strings.obJobDate] == null ? null : DateTime.parse(observationBooking[Strings.obJobDate]),
            Strings.obJobTime: observationBooking[Strings.obJobTime],
            Strings.obBookingCoordinator: observationBooking[Strings.obBookingCoordinator],
            Strings.obPatientLocation: observationBooking[Strings.obPatientLocation],
            Strings.obPostcode: observationBooking[Strings.obPostcode],
            Strings.obLocationTel: observationBooking[Strings.obLocationTel],
            Strings.obInvoiceDetails: observationBooking[Strings.obInvoiceDetails],
            Strings.obCostCode: observationBooking[Strings.obCostCode],
            Strings.obPurchaseOrder: observationBooking[Strings.obPurchaseOrder],
            Strings.obStartDateTime: observationBooking[Strings.obStartDateTime],
            Strings.obMhaAssessmentYes: observationBooking[Strings.obMhaAssessmentYes],
            Strings.obMhaAssessmentNo: observationBooking[Strings.obMhaAssessmentNo],
            Strings.obBedIdentifiedYes: observationBooking[Strings.obBedIdentifiedYes],
            Strings.obBedIdentifiedNo: observationBooking[Strings.obBedIdentifiedNo],
            Strings.obWrapDocumentationYes: observationBooking[Strings.obWrapDocumentationYes],
            Strings.obWrapDocumentationNo: observationBooking[Strings.obWrapDocumentationNo],
            Strings.obShiftRequired: observationBooking[Strings.obShiftRequired],
            Strings.obPatientName: observationBooking[Strings.obPatientName],
            Strings.obLegalStatus: observationBooking[Strings.obLegalStatus],
            Strings.obDateOfBirth: observationBooking[Strings.obDateOfBirth],
            Strings.obNhsNumber: observationBooking[Strings.obNhsNumber],
            Strings.obGender: observationBooking[Strings.obGender],
            Strings.obEthnicity: observationBooking[Strings.obEthnicity],
            Strings.obCovidStatus: observationBooking[Strings.obCovidStatus],
            Strings.obRmn: observationBooking[Strings.obRmn],
            Strings.obHca: observationBooking[Strings.obHca],
            Strings.obHca1: observationBooking[Strings.obHca1],
            Strings.obHca2: observationBooking[Strings.obHca2],
            Strings.obHca3: observationBooking[Strings.obHca3],
            Strings.obHca4: observationBooking[Strings.obHca4],
            Strings.obHca5: observationBooking[Strings.obHca5],
            Strings.obCurrentPresentation: observationBooking[Strings.obCurrentPresentation],
            Strings.obSpecificCarePlanYes: observationBooking[Strings.obSpecificCarePlanYes],
            Strings.obSpecificCarePlanNo: observationBooking[Strings.obSpecificCarePlanNo],
            Strings.obSpecificCarePlan: observationBooking[Strings.obSpecificCarePlan],
            Strings.obPatientWarningsYes: observationBooking[Strings.obPatientWarningsYes],
            Strings.obPatientWarningsNo: observationBooking[Strings.obPatientWarningsNo],
            Strings.obPatientWarnings: observationBooking[Strings.obPatientWarnings],
            Strings.obPresentingRisks: observationBooking[Strings.obPresentingRisks],
            Strings.obPreviousRisks: observationBooking[Strings.obPreviousRisks],
            Strings.obGenderConcernsYes: observationBooking[Strings.obGenderConcernsYes],
            Strings.obGenderConcernsNo: observationBooking[Strings.obGenderConcernsNo],
            Strings.obGenderConcerns: observationBooking[Strings.obGenderConcerns],
            Strings.obSafeguardingConcernsYes: observationBooking[Strings.obSafeguardingConcernsYes],
            Strings.obSafeguardingConcernsNo: observationBooking[Strings.obSafeguardingConcernsNo],
            Strings.obSafeguardingConcerns: observationBooking[Strings.obSafeguardingConcerns],
            Strings.obTimeDue: observationBooking[Strings.obTimeDue],
            Strings.obStaffDate1: observationBooking[Strings.obStaffDate1],
            Strings.obStaffDate2: observationBooking[Strings.obStaffDate2],
            Strings.obStaffDate3: observationBooking[Strings.obStaffDate3],
            Strings.obStaffDate4: observationBooking[Strings.obStaffDate4],
            Strings.obStaffDate5: observationBooking[Strings.obStaffDate5],
            Strings.obStaffDate6: observationBooking[Strings.obStaffDate6],
            Strings.obStaffDate7: observationBooking[Strings.obStaffDate7],
            Strings.obStaffDate8: observationBooking[Strings.obStaffDate8],
            Strings.obStaffDate9: observationBooking[Strings.obStaffDate9],
            Strings.obStaffDate10: observationBooking[Strings.obStaffDate10],
            Strings.obStaffDate11: observationBooking[Strings.obStaffDate11],
            Strings.obStaffDate12: observationBooking[Strings.obStaffDate12],
            Strings.obStaffDate13: observationBooking[Strings.obStaffDate13],
            Strings.obStaffDate14: observationBooking[Strings.obStaffDate14],
            Strings.obStaffDate15: observationBooking[Strings.obStaffDate15],
            Strings.obStaffDate16: observationBooking[Strings.obStaffDate16],
            Strings.obStaffDate17: observationBooking[Strings.obStaffDate17],
            Strings.obStaffDate18: observationBooking[Strings.obStaffDate18],
            Strings.obStaffDate19: observationBooking[Strings.obStaffDate19],
            Strings.obStaffDate20: observationBooking[Strings.obStaffDate20],
            Strings.obStaffStartTime1: observationBooking[Strings.obStaffStartTime1],
            Strings.obStaffStartTime2: observationBooking[Strings.obStaffStartTime2],
            Strings.obStaffStartTime3: observationBooking[Strings.obStaffStartTime3],
            Strings.obStaffStartTime4: observationBooking[Strings.obStaffStartTime4],
            Strings.obStaffStartTime5: observationBooking[Strings.obStaffStartTime5],
            Strings.obStaffStartTime6: observationBooking[Strings.obStaffStartTime6],
            Strings.obStaffStartTime7: observationBooking[Strings.obStaffStartTime7],
            Strings.obStaffStartTime8: observationBooking[Strings.obStaffStartTime8],
            Strings.obStaffStartTime9: observationBooking[Strings.obStaffStartTime9],
            Strings.obStaffStartTime10: observationBooking[Strings.obStaffStartTime10],
            Strings.obStaffStartTime11: observationBooking[Strings.obStaffStartTime11],
            Strings.obStaffStartTime12: observationBooking[Strings.obStaffStartTime12],
            Strings.obStaffStartTime13: observationBooking[Strings.obStaffStartTime13],
            Strings.obStaffStartTime14: observationBooking[Strings.obStaffStartTime14],
            Strings.obStaffStartTime15: observationBooking[Strings.obStaffStartTime15],
            Strings.obStaffStartTime16: observationBooking[Strings.obStaffStartTime16],
            Strings.obStaffStartTime17: observationBooking[Strings.obStaffStartTime17],
            Strings.obStaffStartTime18: observationBooking[Strings.obStaffStartTime18],
            Strings.obStaffStartTime19: observationBooking[Strings.obStaffStartTime19],
            Strings.obStaffStartTime20: observationBooking[Strings.obStaffStartTime20],
            Strings.obStaffEndTime1: observationBooking[Strings.obStaffEndTime1],
            Strings.obStaffEndTime2: observationBooking[Strings.obStaffEndTime2],
            Strings.obStaffEndTime3: observationBooking[Strings.obStaffEndTime3],
            Strings.obStaffEndTime4: observationBooking[Strings.obStaffEndTime4],
            Strings.obStaffEndTime5: observationBooking[Strings.obStaffEndTime5],
            Strings.obStaffEndTime6: observationBooking[Strings.obStaffEndTime6],
            Strings.obStaffEndTime7: observationBooking[Strings.obStaffEndTime7],
            Strings.obStaffEndTime8: observationBooking[Strings.obStaffEndTime8],
            Strings.obStaffEndTime9: observationBooking[Strings.obStaffEndTime9],
            Strings.obStaffEndTime10: observationBooking[Strings.obStaffEndTime10],
            Strings.obStaffEndTime11: observationBooking[Strings.obStaffEndTime11],
            Strings.obStaffEndTime12: observationBooking[Strings.obStaffEndTime12],
            Strings.obStaffEndTime13: observationBooking[Strings.obStaffEndTime13],
            Strings.obStaffEndTime14: observationBooking[Strings.obStaffEndTime14],
            Strings.obStaffEndTime15: observationBooking[Strings.obStaffEndTime15],
            Strings.obStaffEndTime16: observationBooking[Strings.obStaffEndTime16],
            Strings.obStaffEndTime17: observationBooking[Strings.obStaffEndTime17],
            Strings.obStaffEndTime18: observationBooking[Strings.obStaffEndTime18],
            Strings.obStaffEndTime19: observationBooking[Strings.obStaffEndTime19],
            Strings.obStaffEndTime20: observationBooking[Strings.obStaffEndTime20],
            Strings.obStaffName1: observationBooking[Strings.obStaffName1],
            Strings.obStaffName2: observationBooking[Strings.obStaffName2],
            Strings.obStaffName3: observationBooking[Strings.obStaffName3],
            Strings.obStaffName4: observationBooking[Strings.obStaffName4],
            Strings.obStaffName5: observationBooking[Strings.obStaffName5],
            Strings.obStaffName6: observationBooking[Strings.obStaffName6],
            Strings.obStaffName7: observationBooking[Strings.obStaffName7],
            Strings.obStaffName8: observationBooking[Strings.obStaffName8],
            Strings.obStaffName9: observationBooking[Strings.obStaffName9],
            Strings.obStaffName10: observationBooking[Strings.obStaffName10],
            Strings.obStaffName11: observationBooking[Strings.obStaffName11],
            Strings.obStaffName12: observationBooking[Strings.obStaffName12],
            Strings.obStaffName13: observationBooking[Strings.obStaffName13],
            Strings.obStaffName14: observationBooking[Strings.obStaffName14],
            Strings.obStaffName15: observationBooking[Strings.obStaffName15],
            Strings.obStaffName16: observationBooking[Strings.obStaffName16],
            Strings.obStaffName17: observationBooking[Strings.obStaffName17],
            Strings.obStaffName18: observationBooking[Strings.obStaffName18],
            Strings.obStaffName19: observationBooking[Strings.obStaffName19],
            Strings.obStaffName20: observationBooking[Strings.obStaffName20],
            Strings.obStaffRmn1: observationBooking[Strings.obStaffRmn1],
            Strings.obStaffRmn2: observationBooking[Strings.obStaffRmn2],
            Strings.obStaffRmn3: observationBooking[Strings.obStaffRmn3],
            Strings.obStaffRmn4: observationBooking[Strings.obStaffRmn4],
            Strings.obStaffRmn5: observationBooking[Strings.obStaffRmn5],
            Strings.obStaffRmn6: observationBooking[Strings.obStaffRmn6],
            Strings.obStaffRmn7: observationBooking[Strings.obStaffRmn7],
            Strings.obStaffRmn8: observationBooking[Strings.obStaffRmn8],
            Strings.obStaffRmn9: observationBooking[Strings.obStaffRmn9],
            Strings.obStaffRmn10: observationBooking[Strings.obStaffRmn10],
            Strings.obStaffRmn11: observationBooking[Strings.obStaffRmn11],
            Strings.obStaffRmn12: observationBooking[Strings.obStaffRmn12],
            Strings.obStaffRmn13: observationBooking[Strings.obStaffRmn13],
            Strings.obStaffRmn14: observationBooking[Strings.obStaffRmn14],
            Strings.obStaffRmn15: observationBooking[Strings.obStaffRmn15],
            Strings.obStaffRmn16: observationBooking[Strings.obStaffRmn16],
            Strings.obStaffRmn17: observationBooking[Strings.obStaffRmn17],
            Strings.obStaffRmn18: observationBooking[Strings.obStaffRmn18],
            Strings.obStaffRmn19: observationBooking[Strings.obStaffRmn19],
            Strings.obStaffRmn20: observationBooking[Strings.obStaffRmn20],
            Strings.obUsefulDetails: observationBooking[Strings.obUsefulDetails],
            Strings.timestamp: FieldValue.serverTimestamp(),
            Strings.serverUploaded: 1,
          });

          //Sembast
          await _observationBookingsStore.record(id).delete(await _db);
          if(saved){
            deleteSavedRecord(savedId);
          }
          message = 'Observation Booking uploaded successfully';
          success = true;


        } on TimeoutException catch (_) {
          // A timeout occurred.
          message = 'Network Timeout communicating with the server, unable to upload Observation Booking';

        } catch (e) {
          print(e);
          message = e.toString();

          print(e);
        }
      }

    } else {

      message = 'No data connection, Observation Booking has been saved locally, please upload when you have a valid connection';
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

  Future<bool> editObservationBooking(String jobId, [bool edit = false]) async {

    GlobalFunctions.showLoadingDialog('Editing Observation Booking...');
    String message = '';
    bool success = false;

    Map<String, dynamic> observationBooking = await getTemporaryRecord(true, jobId, false, 0);

    //Map<String, dynamic> observationBooking = await _databaseHelper.getTemporaryObservationBooking(true, user.uid, jobId);

    bool hasDataConnection = await GlobalFunctions.hasDataConnection();


    if(hasDataConnection){

      bool isTokenExpired = GlobalFunctions.isTokenExpired();
      bool authenticated = true;

      if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

      if(authenticated){


        try {

          await FirebaseFirestore.instance.collection('observation_bookings').doc(observationBooking[Strings.documentId]).update({
            Strings.jobId: '1',
            Strings.formVersion: '1',
            Strings.jobRef: GlobalFunctions.databaseValueString(observationBooking[Strings.jobRef]),
            Strings.jobRefLowercase: GlobalFunctions.databaseValueString(observationBooking[Strings.jobRef]).toLowerCase(),
            Strings.obRequestedBy: observationBooking[Strings.obRequestedBy],
            Strings.obJobTitle: observationBooking[Strings.obJobTitle],
            Strings.obJobContact: observationBooking[Strings.obJobContact],
            Strings.obJobAuthorisingManager: observationBooking[Strings.obJobAuthorisingManager],
            Strings.obJobDate: observationBooking[Strings.obJobDate] == null ? null : DateTime.parse(observationBooking[Strings.obJobDate]),
            Strings.obJobTime: observationBooking[Strings.obJobTime],
            Strings.obBookingCoordinator: observationBooking[Strings.obBookingCoordinator],
            Strings.obPatientLocation: observationBooking[Strings.obPatientLocation],
            Strings.obPostcode: observationBooking[Strings.obPostcode],
            Strings.obLocationTel: observationBooking[Strings.obLocationTel],
            Strings.obInvoiceDetails: observationBooking[Strings.obInvoiceDetails],
            Strings.obCostCode: observationBooking[Strings.obCostCode],
            Strings.obPurchaseOrder: observationBooking[Strings.obPurchaseOrder],
            Strings.obStartDateTime: observationBooking[Strings.obStartDateTime],
            Strings.obMhaAssessmentYes: observationBooking[Strings.obMhaAssessmentYes],
            Strings.obMhaAssessmentNo: observationBooking[Strings.obMhaAssessmentNo],
            Strings.obBedIdentifiedYes: observationBooking[Strings.obBedIdentifiedYes],
            Strings.obBedIdentifiedNo: observationBooking[Strings.obBedIdentifiedNo],
            Strings.obWrapDocumentationYes: observationBooking[Strings.obWrapDocumentationYes],
            Strings.obWrapDocumentationNo: observationBooking[Strings.obWrapDocumentationNo],
            Strings.obShiftRequired: observationBooking[Strings.obShiftRequired],
            Strings.obPatientName: observationBooking[Strings.obPatientName],
            Strings.obLegalStatus: observationBooking[Strings.obLegalStatus],
            Strings.obDateOfBirth: observationBooking[Strings.obDateOfBirth],
            Strings.obNhsNumber: observationBooking[Strings.obNhsNumber],
            Strings.obGender: observationBooking[Strings.obGender],
            Strings.obEthnicity: observationBooking[Strings.obEthnicity],
            Strings.obCovidStatus: observationBooking[Strings.obCovidStatus],
            Strings.obRmn: observationBooking[Strings.obRmn],
            Strings.obHca: observationBooking[Strings.obHca],
            Strings.obHca1: observationBooking[Strings.obHca1],
            Strings.obHca2: observationBooking[Strings.obHca2],
            Strings.obHca3: observationBooking[Strings.obHca3],
            Strings.obHca4: observationBooking[Strings.obHca4],
            Strings.obHca5: observationBooking[Strings.obHca5],
            Strings.obCurrentPresentation: observationBooking[Strings.obCurrentPresentation],
            Strings.obSpecificCarePlanYes: observationBooking[Strings.obSpecificCarePlanYes],
            Strings.obSpecificCarePlanNo: observationBooking[Strings.obSpecificCarePlanNo],
            Strings.obSpecificCarePlan: observationBooking[Strings.obSpecificCarePlan],
            Strings.obPatientWarningsYes: observationBooking[Strings.obPatientWarningsYes],
            Strings.obPatientWarningsNo: observationBooking[Strings.obPatientWarningsNo],
            Strings.obPatientWarnings: observationBooking[Strings.obPatientWarnings],
            Strings.obPresentingRisks: observationBooking[Strings.obPresentingRisks],
            Strings.obPreviousRisks: observationBooking[Strings.obPreviousRisks],
            Strings.obGenderConcernsYes: observationBooking[Strings.obGenderConcernsYes],
            Strings.obGenderConcernsNo: observationBooking[Strings.obGenderConcernsNo],
            Strings.obGenderConcerns: observationBooking[Strings.obGenderConcerns],
            Strings.obSafeguardingConcernsYes: observationBooking[Strings.obSafeguardingConcernsYes],
            Strings.obSafeguardingConcernsNo: observationBooking[Strings.obSafeguardingConcernsNo],
            Strings.obSafeguardingConcerns: observationBooking[Strings.obSafeguardingConcerns],
            Strings.obTimeDue: observationBooking[Strings.obTimeDue],
            Strings.obStaffDate1: observationBooking[Strings.obStaffDate1],
            Strings.obStaffDate2: observationBooking[Strings.obStaffDate2],
            Strings.obStaffDate3: observationBooking[Strings.obStaffDate3],
            Strings.obStaffDate4: observationBooking[Strings.obStaffDate4],
            Strings.obStaffDate5: observationBooking[Strings.obStaffDate5],
            Strings.obStaffDate6: observationBooking[Strings.obStaffDate6],
            Strings.obStaffDate7: observationBooking[Strings.obStaffDate7],
            Strings.obStaffDate8: observationBooking[Strings.obStaffDate8],
            Strings.obStaffDate9: observationBooking[Strings.obStaffDate9],
            Strings.obStaffDate10: observationBooking[Strings.obStaffDate10],
            Strings.obStaffDate11: observationBooking[Strings.obStaffDate11],
            Strings.obStaffDate12: observationBooking[Strings.obStaffDate12],
            Strings.obStaffDate13: observationBooking[Strings.obStaffDate13],
            Strings.obStaffDate14: observationBooking[Strings.obStaffDate14],
            Strings.obStaffDate15: observationBooking[Strings.obStaffDate15],
            Strings.obStaffDate16: observationBooking[Strings.obStaffDate16],
            Strings.obStaffDate17: observationBooking[Strings.obStaffDate17],
            Strings.obStaffDate18: observationBooking[Strings.obStaffDate18],
            Strings.obStaffDate19: observationBooking[Strings.obStaffDate19],
            Strings.obStaffDate20: observationBooking[Strings.obStaffDate20],
            Strings.obStaffStartTime1: observationBooking[Strings.obStaffStartTime1],
            Strings.obStaffStartTime2: observationBooking[Strings.obStaffStartTime2],
            Strings.obStaffStartTime3: observationBooking[Strings.obStaffStartTime3],
            Strings.obStaffStartTime4: observationBooking[Strings.obStaffStartTime4],
            Strings.obStaffStartTime5: observationBooking[Strings.obStaffStartTime5],
            Strings.obStaffStartTime6: observationBooking[Strings.obStaffStartTime6],
            Strings.obStaffStartTime7: observationBooking[Strings.obStaffStartTime7],
            Strings.obStaffStartTime8: observationBooking[Strings.obStaffStartTime8],
            Strings.obStaffStartTime9: observationBooking[Strings.obStaffStartTime9],
            Strings.obStaffStartTime10: observationBooking[Strings.obStaffStartTime10],
            Strings.obStaffStartTime11: observationBooking[Strings.obStaffStartTime11],
            Strings.obStaffStartTime12: observationBooking[Strings.obStaffStartTime12],
            Strings.obStaffStartTime13: observationBooking[Strings.obStaffStartTime13],
            Strings.obStaffStartTime14: observationBooking[Strings.obStaffStartTime14],
            Strings.obStaffStartTime15: observationBooking[Strings.obStaffStartTime15],
            Strings.obStaffStartTime16: observationBooking[Strings.obStaffStartTime16],
            Strings.obStaffStartTime17: observationBooking[Strings.obStaffStartTime17],
            Strings.obStaffStartTime18: observationBooking[Strings.obStaffStartTime18],
            Strings.obStaffStartTime19: observationBooking[Strings.obStaffStartTime19],
            Strings.obStaffStartTime20: observationBooking[Strings.obStaffStartTime20],
            Strings.obStaffEndTime1: observationBooking[Strings.obStaffEndTime1],
            Strings.obStaffEndTime2: observationBooking[Strings.obStaffEndTime2],
            Strings.obStaffEndTime3: observationBooking[Strings.obStaffEndTime3],
            Strings.obStaffEndTime4: observationBooking[Strings.obStaffEndTime4],
            Strings.obStaffEndTime5: observationBooking[Strings.obStaffEndTime5],
            Strings.obStaffEndTime6: observationBooking[Strings.obStaffEndTime6],
            Strings.obStaffEndTime7: observationBooking[Strings.obStaffEndTime7],
            Strings.obStaffEndTime8: observationBooking[Strings.obStaffEndTime8],
            Strings.obStaffEndTime9: observationBooking[Strings.obStaffEndTime9],
            Strings.obStaffEndTime10: observationBooking[Strings.obStaffEndTime10],
            Strings.obStaffEndTime11: observationBooking[Strings.obStaffEndTime11],
            Strings.obStaffEndTime12: observationBooking[Strings.obStaffEndTime12],
            Strings.obStaffEndTime13: observationBooking[Strings.obStaffEndTime13],
            Strings.obStaffEndTime14: observationBooking[Strings.obStaffEndTime14],
            Strings.obStaffEndTime15: observationBooking[Strings.obStaffEndTime15],
            Strings.obStaffEndTime16: observationBooking[Strings.obStaffEndTime16],
            Strings.obStaffEndTime17: observationBooking[Strings.obStaffEndTime17],
            Strings.obStaffEndTime18: observationBooking[Strings.obStaffEndTime18],
            Strings.obStaffEndTime19: observationBooking[Strings.obStaffEndTime19],
            Strings.obStaffEndTime20: observationBooking[Strings.obStaffEndTime20],
            Strings.obStaffName1: observationBooking[Strings.obStaffName1],
            Strings.obStaffName2: observationBooking[Strings.obStaffName2],
            Strings.obStaffName3: observationBooking[Strings.obStaffName3],
            Strings.obStaffName4: observationBooking[Strings.obStaffName4],
            Strings.obStaffName5: observationBooking[Strings.obStaffName5],
            Strings.obStaffName6: observationBooking[Strings.obStaffName6],
            Strings.obStaffName7: observationBooking[Strings.obStaffName7],
            Strings.obStaffName8: observationBooking[Strings.obStaffName8],
            Strings.obStaffName9: observationBooking[Strings.obStaffName9],
            Strings.obStaffName10: observationBooking[Strings.obStaffName10],
            Strings.obStaffName11: observationBooking[Strings.obStaffName11],
            Strings.obStaffName12: observationBooking[Strings.obStaffName12],
            Strings.obStaffName13: observationBooking[Strings.obStaffName13],
            Strings.obStaffName14: observationBooking[Strings.obStaffName14],
            Strings.obStaffName15: observationBooking[Strings.obStaffName15],
            Strings.obStaffName16: observationBooking[Strings.obStaffName16],
            Strings.obStaffName17: observationBooking[Strings.obStaffName17],
            Strings.obStaffName18: observationBooking[Strings.obStaffName18],
            Strings.obStaffName19: observationBooking[Strings.obStaffName19],
            Strings.obStaffName20: observationBooking[Strings.obStaffName20],
            Strings.obStaffRmn1: observationBooking[Strings.obStaffRmn1],
            Strings.obStaffRmn2: observationBooking[Strings.obStaffRmn2],
            Strings.obStaffRmn3: observationBooking[Strings.obStaffRmn3],
            Strings.obStaffRmn4: observationBooking[Strings.obStaffRmn4],
            Strings.obStaffRmn5: observationBooking[Strings.obStaffRmn5],
            Strings.obStaffRmn6: observationBooking[Strings.obStaffRmn6],
            Strings.obStaffRmn7: observationBooking[Strings.obStaffRmn7],
            Strings.obStaffRmn8: observationBooking[Strings.obStaffRmn8],
            Strings.obStaffRmn9: observationBooking[Strings.obStaffRmn9],
            Strings.obStaffRmn10: observationBooking[Strings.obStaffRmn10],
            Strings.obStaffRmn11: observationBooking[Strings.obStaffRmn11],
            Strings.obStaffRmn12: observationBooking[Strings.obStaffRmn12],
            Strings.obStaffRmn13: observationBooking[Strings.obStaffRmn13],
            Strings.obStaffRmn14: observationBooking[Strings.obStaffRmn14],
            Strings.obStaffRmn15: observationBooking[Strings.obStaffRmn15],
            Strings.obStaffRmn16: observationBooking[Strings.obStaffRmn16],
            Strings.obStaffRmn17: observationBooking[Strings.obStaffRmn17],
            Strings.obStaffRmn18: observationBooking[Strings.obStaffRmn18],
            Strings.obStaffRmn19: observationBooking[Strings.obStaffRmn19],
            Strings.obStaffRmn20: observationBooking[Strings.obStaffRmn20],
            Strings.obUsefulDetails: observationBooking[Strings.obUsefulDetails],
            Strings.serverUploaded: 1,
          });

          //Sembast

          final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
              [Db.Filter.equals(Strings.documentId, selectedObservationBooking[Strings.documentId]), Db.Filter.equals(Strings.jobId, jobId)]
          ));

          await _editedObservationBookingsStore.delete(await _db,
              finder: finder);
          message = 'Observation Booking uploaded successfully';
          success = true;
          getObservationBookings();

        } on TimeoutException catch (_) {
          // A timeout occurred.
          message = 'Network Timeout communicating with the server, unable to edit Observation Booking';
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
      //deleteEditedObservationBooking();
    }
    GlobalFunctions.showToast(message);
    return success;


  }


  Future<void> getObservationBookings() async{

    _isLoading = true;
    notifyListeners();
    String message = '';

    List<Map<String, dynamic>> _fetchedObservationBookingList = [];

    try {

      bool hasDataConnection = await GlobalFunctions.hasDataConnection();

      if(!hasDataConnection){

        GlobalFunctions.showToast('No data connection, unable to fetch Observation Bookings');
        _observationBookings = [];

      } else {


        bool isTokenExpired = GlobalFunctions.isTokenExpired();
        bool authenticated = true;

        if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

        if(authenticated){


          QuerySnapshot snapshot;

          if(user.role == 'Super User'){
            try{
              snapshot = await FirebaseFirestore.instance.collection('observation_bookings').orderBy('timestamp', descending: true).limit(10).get().timeout(Duration(seconds: 90));
            } catch(e){
              print(e);
            }
          } else {
            try{
              snapshot = await FirebaseFirestore.instance.collection('observation_bookings').where(
                  'uid', isEqualTo: user.uid).orderBy('timestamp', descending: true).limit(10).get().timeout(Duration(seconds: 90));
            } catch(e){
              print(e);
            }
          }





          Map<String, dynamic> snapshotData = {};

          if(snapshot.docs.length < 1){
            message = 'No Observation Bookings found';
          } else {
            for (DocumentSnapshot snap in snapshot.docs) {

              snapshotData = snap.data();

              final Map<String, dynamic> observationBooking = onlineObservationBooking(snapshotData, snap.id);

              _fetchedObservationBookingList.add(observationBooking);

            }

            _observationBookings = _fetchedObservationBookingList;
          }


        }

      }


    } on TimeoutException catch (_) {
      // A timeout occurred.
      message = 'Network Timeout communicating with the server, unable to fetch latest Observation Bookings';
    } catch(e){
      print(e);
      message = 'Something went wrong. Please try again';

    }

    _isLoading = false;
    notifyListeners();
    _selObservationBookingId = null;
    if(message != '') GlobalFunctions.showToast(message);

  }

  Future<void> getMoreObservationBookings() async{

    String message = '';

    List<Map<String, dynamic>> _fetchedObservationBookingList = [];

    try {

      bool hasDataConnection = await GlobalFunctions.hasDataConnection();

      if(!hasDataConnection){

        GlobalFunctions.showToast('No data connection, unable to fetch Observation Bookings');

      } else {


        bool isTokenExpired = GlobalFunctions.isTokenExpired();
        bool authenticated = true;

        if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

        if(authenticated){


          QuerySnapshot snapshot;
          int currentLength = _observationBookings.length;
          DateTime latestDate = DateTime.parse(_observationBookings[currentLength - 1][Strings.timestamp]);

          if(user.role == 'Super User'){
            try {
              snapshot = await FirebaseFirestore.instance.collection('observation_bookings').orderBy(
                  'timestamp', descending: true).startAfter(
                  [Timestamp.fromDate(latestDate)]).limit(10)
                  .get()
                  .timeout(Duration(seconds: 90));
            } catch(e) {
              print(e);
            }

          } else {
            try {
              snapshot = await FirebaseFirestore.instance.collection('observation_bookings').where(
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
            message = 'No more Observation Bookings found';
          } else {
            for (DocumentSnapshot snap in snapshot.docs) {

              snapshotData = snap.data();

              final Map<String, dynamic> observationBooking = onlineObservationBooking(snapshotData, snap.id);

              _fetchedObservationBookingList.add(observationBooking);

            }

            _observationBookings.addAll(_fetchedObservationBookingList);
          }


        }

      }


    } on TimeoutException catch (_) {
      // A timeout occurred.
      message = 'Network Timeout communicating with the server, unable to fetch latest Observation Bookings';
    } catch(e){
      print(e);
      message = 'Something went wrong. Please try again';

    }

    _isLoading = false;
    notifyListeners();
    _selObservationBookingId = null;
    if(message != '') GlobalFunctions.showToast(message);

  }

  Future<bool> searchObservationBookings(DateTime dateFrom, DateTime dateTo, String jobRef, String selectedUser) async{

    _isLoading = true;
    notifyListeners();
    bool success = false;
    String message = '';
    GlobalFunctions.showLoadingDialog('Searching Forms');
    List<Map<String, dynamic>> _fetchedObservationBookingList = [];

    try {

      bool hasDataConnection = await GlobalFunctions.hasDataConnection();

      if(!hasDataConnection){

        message = 'No Data Connection, unable to search Observation Bookings';

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
                    await FirebaseFirestore.instance.collection('observation_bookings')
                        .where(Strings.uid, isEqualTo: selectedUser).orderBy('timestamp', descending: true)
                        .startAt([dateTo]).endAt([dateFrom]).get()
                        .timeout(Duration(seconds: 90));
                  } catch(e){
                    print(e);
                  }
                } else {
                  try{
                    snapshot =
                    await FirebaseFirestore.instance.collection('observation_bookings').orderBy('timestamp', descending: true)
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
                    await FirebaseFirestore.instance.collection('observation_bookings').where(Strings.uid, isEqualTo: selectedUser).
                        where(Strings.jobRefLowercase, isEqualTo: jobRef.toLowerCase()).orderBy('timestamp', descending: true)
                        .startAt([dateTo]).endAt([dateFrom]).get()
                        .timeout(Duration(seconds: 90));
                  } catch(e){
                    print(e);
                  }
                } else {
                  try{
                    snapshot =
                    await FirebaseFirestore.instance.collection('observation_bookings')
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
                    await FirebaseFirestore.instance.collection('observation_bookings')
                        .where(Strings.uid, isEqualTo: selectedUser).orderBy('timestamp', descending: true)
                        .get()
                        .timeout(Duration(seconds: 90));
                  } catch(e){
                    print(e);
                  }
                } else {
                  try{
                    snapshot =
                    await FirebaseFirestore.instance.collection('observation_bookings').orderBy('timestamp', descending: true)
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
                    await FirebaseFirestore.instance.collection('observation_bookings')
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
                    await FirebaseFirestore.instance.collection('observation_bookings')
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
                  await FirebaseFirestore.instance.collection('observation_bookings')
                      .where(Strings.uid, isEqualTo: user.uid).orderBy('timestamp', descending: true)
                      .startAt([dateTo]).endAt([dateFrom]).get()
                      .timeout(Duration(seconds: 90));
                } catch(e){
                  print(e);
                }


              } else {


                try{
                  snapshot =
                  await FirebaseFirestore.instance.collection('observation_bookings')
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
                  await FirebaseFirestore.instance.collection('observation_bookings')
                      .where(Strings.uid, isEqualTo: user.uid).orderBy('timestamp', descending: true)
                      .get()
                      .timeout(Duration(seconds: 90));
                } catch(e){
                  print(e);
                }


              } else {

                try{
                  snapshot =
                  await FirebaseFirestore.instance.collection('observation_bookings')
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
            message = 'No Observation Bookings found';
          } else {
            for (DocumentSnapshot snap in snapshot.docs) {

              snapshotData = snap.data();

              final Map<String, dynamic> observationBooking = onlineObservationBooking(snapshotData, snap.id);

              _fetchedObservationBookingList.add(observationBooking);

            }

            _observationBookings = _fetchedObservationBookingList;
            success = true;
          }


        }

      }


    } on TimeoutException catch (_) {
      // A timeout occurred.
      message = 'Network Timeout communicating with the server, unable to search Observation Bookings';
    } catch(e){
      print(e);
      message = 'Something went wrong. Please try again';

    }

    _isLoading = false;
    notifyListeners();
    _selObservationBookingId = null;
    GlobalFunctions.dismissLoadingDialog();
    if(message != '') GlobalFunctions.showToast(message);
    return success;

  }


  Future<bool> searchMoreObservationBookings(DateTime dateFrom, DateTime dateTo) async{

    _isLoading = true;
    notifyListeners();
    bool success = false;
    String message = '';
    GlobalFunctions.showLoadingDialog('Searching Forms');
    List<Map<String, dynamic>> _fetchedObservationBookingList = [];

    try {

      bool hasDataConnection = await GlobalFunctions.hasDataConnection();

      if(!hasDataConnection){

        message = 'No Data Connection, unable to search Observation Bookings';

      } else {


        bool isTokenExpired = GlobalFunctions.isTokenExpired();
        bool authenticated = true;

        if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

        if(authenticated){


          QuerySnapshot snapshot;
          int currentLength = _observationBookings.length;
          DateTime latestDate = DateTime.parse(_observationBookings[currentLength - 1]['timestamp']);

          if(user.role == 'Super User'){
            try{
              snapshot =
              await FirebaseFirestore.instance.collection('observation_bookings').orderBy('timestamp', descending: true)
                  .startAfter([Timestamp.fromDate(latestDate)]).endAt([dateFrom]).limit(10).get()
                  .timeout(Duration(seconds: 90));
            } catch(e){
              print(e);
            }

          } else {

            try{
              snapshot =
              await FirebaseFirestore.instance.collection('observation_bookings').where('uid', isEqualTo: user.uid).orderBy('timestamp', descending: true)
                  .startAfter([Timestamp.fromDate(latestDate)]).endAt([dateFrom]).limit(10).get()
                  .timeout(Duration(seconds: 90));
            } catch(e){
              print(e);
            }

          }

          Map<String, dynamic> snapshotData = {};

          if(snapshot.docs.length < 1){
            message = 'No Observation Bookings found';
          } else {
            for (DocumentSnapshot snap in snapshot.docs) {

              snapshotData = snap.data();

              final Map<String, dynamic> observationBooking = onlineObservationBooking(snapshotData, snap.id);

              _fetchedObservationBookingList.add(observationBooking);

            }

            _observationBookings.addAll(_fetchedObservationBookingList);
            success = true;
          }


        }

      }


    } on TimeoutException catch (_) {
      // A timeout occurred.
      message = 'Network Timeout communicating with the server, unable to search Observation Bookings';
    } catch(e){
      print(e);
      message = 'Something went wrong. Please try again';

    }

    _isLoading = false;
    notifyListeners();
    _selObservationBookingId = null;
    GlobalFunctions.dismissLoadingDialog();
    if(message != '') GlobalFunctions.showToast(message);
    return success;

  }


  Map<String, dynamic> localObservationBooking(Map<String, dynamic> localRecord){
    return {
      Strings.documentId: GlobalFunctions.databaseValueString(localRecord[Strings.documentId]),
      Strings.uid: GlobalFunctions.databaseValueString(localRecord[Strings.uid]),
      Strings.jobId: localRecord[Strings.jobId],
      Strings.formVersion: localRecord[Strings.formVersion],
      Strings.jobRef: localRecord[Strings.jobRef],
      Strings.obRequestedBy: localRecord[Strings.obRequestedBy],
      Strings.obJobTitle: localRecord[Strings.obJobTitle],
      Strings.obJobContact: localRecord[Strings.obJobContact],
      Strings.obJobAuthorisingManager: localRecord[Strings.obJobAuthorisingManager],
      Strings.obJobDate: localRecord[Strings.obJobDate],
      Strings.obJobTime: localRecord[Strings.obJobTime],
      Strings.obBookingCoordinator: localRecord[Strings.obBookingCoordinator],
      Strings.obPatientLocation: localRecord[Strings.obPatientLocation],
      Strings.obPostcode: localRecord[Strings.obPostcode],
      Strings.obLocationTel: localRecord[Strings.obLocationTel],
      Strings.obInvoiceDetails: localRecord[Strings.obInvoiceDetails],
      Strings.obCostCode: localRecord[Strings.obCostCode],
      Strings.obPurchaseOrder: localRecord[Strings.obPurchaseOrder],
      Strings.obStartDateTime: localRecord[Strings.obStartDateTime],
      Strings.obMhaAssessmentYes: localRecord[Strings.obMhaAssessmentYes],
      Strings.obMhaAssessmentNo: localRecord[Strings.obMhaAssessmentNo],
      Strings.obBedIdentifiedYes: localRecord[Strings.obBedIdentifiedYes],
      Strings.obBedIdentifiedNo: localRecord[Strings.obBedIdentifiedNo],
      Strings.obWrapDocumentationYes: localRecord[Strings.obWrapDocumentationYes],
      Strings.obWrapDocumentationNo: localRecord[Strings.obWrapDocumentationNo],
      Strings.obShiftRequired: localRecord[Strings.obShiftRequired],
      Strings.obPatientName: localRecord[Strings.obPatientName],
      Strings.obLegalStatus: localRecord[Strings.obLegalStatus],
      Strings.obDateOfBirth: localRecord[Strings.obDateOfBirth],
      Strings.obNhsNumber: localRecord[Strings.obNhsNumber],
      Strings.obGender: localRecord[Strings.obGender],
      Strings.obEthnicity: localRecord[Strings.obEthnicity],
      Strings.obCovidStatus: localRecord[Strings.obCovidStatus],
      Strings.obRmn: localRecord[Strings.obRmn],
      Strings.obHca: localRecord[Strings.obHca],
      Strings.obHca1: localRecord[Strings.obHca1],
      Strings.obHca2: localRecord[Strings.obHca2],
      Strings.obHca3: localRecord[Strings.obHca3],
      Strings.obHca4: localRecord[Strings.obHca4],
      Strings.obHca5: localRecord[Strings.obHca5],
      Strings.obCurrentPresentation: localRecord[Strings.obCurrentPresentation],
      Strings.obSpecificCarePlanYes: localRecord[Strings.obSpecificCarePlanYes],
      Strings.obSpecificCarePlanNo: localRecord[Strings.obSpecificCarePlanNo],
      Strings.obSpecificCarePlan: localRecord[Strings.obSpecificCarePlan],
      Strings.obPatientWarningsYes: localRecord[Strings.obPatientWarningsYes],
      Strings.obPatientWarningsNo: localRecord[Strings.obPatientWarningsNo],
      Strings.obPatientWarnings: localRecord[Strings.obPatientWarnings],
      Strings.obPresentingRisks: localRecord[Strings.obPresentingRisks],
      Strings.obPreviousRisks: localRecord[Strings.obPreviousRisks],
      Strings.obGenderConcernsYes: localRecord[Strings.obGenderConcernsYes],
      Strings.obGenderConcernsNo: localRecord[Strings.obGenderConcernsNo],
      Strings.obGenderConcerns: localRecord[Strings.obGenderConcerns],
      Strings.obSafeguardingConcernsYes: localRecord[Strings.obSafeguardingConcernsYes],
      Strings.obSafeguardingConcernsNo: localRecord[Strings.obSafeguardingConcernsNo],
      Strings.obSafeguardingConcerns: localRecord[Strings.obSafeguardingConcerns],
      Strings.obTimeDue: localRecord[Strings.obTimeDue],
      Strings.obStaffDate1: localRecord[Strings.obStaffDate1],
      Strings.obStaffDate2: localRecord[Strings.obStaffDate2],
      Strings.obStaffDate3: localRecord[Strings.obStaffDate3],
      Strings.obStaffDate4: localRecord[Strings.obStaffDate4],
      Strings.obStaffDate5: localRecord[Strings.obStaffDate5],
      Strings.obStaffDate6: localRecord[Strings.obStaffDate6],
      Strings.obStaffDate7: localRecord[Strings.obStaffDate7],
      Strings.obStaffDate8: localRecord[Strings.obStaffDate8],
      Strings.obStaffDate9: localRecord[Strings.obStaffDate9],
      Strings.obStaffDate10: localRecord[Strings.obStaffDate10],
      Strings.obStaffDate11: localRecord[Strings.obStaffDate11],
      Strings.obStaffDate12: localRecord[Strings.obStaffDate12],
      Strings.obStaffDate13: localRecord[Strings.obStaffDate13],
      Strings.obStaffDate14: localRecord[Strings.obStaffDate14],
      Strings.obStaffDate15: localRecord[Strings.obStaffDate15],
      Strings.obStaffDate16: localRecord[Strings.obStaffDate16],
      Strings.obStaffDate17: localRecord[Strings.obStaffDate17],
      Strings.obStaffDate18: localRecord[Strings.obStaffDate18],
      Strings.obStaffDate19: localRecord[Strings.obStaffDate19],
      Strings.obStaffDate20: localRecord[Strings.obStaffDate20],
      Strings.obStaffStartTime1: localRecord[Strings.obStaffStartTime1],
      Strings.obStaffStartTime2: localRecord[Strings.obStaffStartTime2],
      Strings.obStaffStartTime3: localRecord[Strings.obStaffStartTime3],
      Strings.obStaffStartTime4: localRecord[Strings.obStaffStartTime4],
      Strings.obStaffStartTime5: localRecord[Strings.obStaffStartTime5],
      Strings.obStaffStartTime6: localRecord[Strings.obStaffStartTime6],
      Strings.obStaffStartTime7: localRecord[Strings.obStaffStartTime7],
      Strings.obStaffStartTime8: localRecord[Strings.obStaffStartTime8],
      Strings.obStaffStartTime9: localRecord[Strings.obStaffStartTime9],
      Strings.obStaffStartTime10: localRecord[Strings.obStaffStartTime10],
      Strings.obStaffStartTime11: localRecord[Strings.obStaffStartTime11],
      Strings.obStaffStartTime12: localRecord[Strings.obStaffStartTime12],
      Strings.obStaffStartTime13: localRecord[Strings.obStaffStartTime13],
      Strings.obStaffStartTime14: localRecord[Strings.obStaffStartTime14],
      Strings.obStaffStartTime15: localRecord[Strings.obStaffStartTime15],
      Strings.obStaffStartTime16: localRecord[Strings.obStaffStartTime16],
      Strings.obStaffStartTime17: localRecord[Strings.obStaffStartTime17],
      Strings.obStaffStartTime18: localRecord[Strings.obStaffStartTime18],
      Strings.obStaffStartTime19: localRecord[Strings.obStaffStartTime19],
      Strings.obStaffStartTime20: localRecord[Strings.obStaffStartTime20],
      Strings.obStaffEndTime1: localRecord[Strings.obStaffEndTime1],
      Strings.obStaffEndTime2: localRecord[Strings.obStaffEndTime2],
      Strings.obStaffEndTime3: localRecord[Strings.obStaffEndTime3],
      Strings.obStaffEndTime4: localRecord[Strings.obStaffEndTime4],
      Strings.obStaffEndTime5: localRecord[Strings.obStaffEndTime5],
      Strings.obStaffEndTime6: localRecord[Strings.obStaffEndTime6],
      Strings.obStaffEndTime7: localRecord[Strings.obStaffEndTime7],
      Strings.obStaffEndTime8: localRecord[Strings.obStaffEndTime8],
      Strings.obStaffEndTime9: localRecord[Strings.obStaffEndTime9],
      Strings.obStaffEndTime10: localRecord[Strings.obStaffEndTime10],
      Strings.obStaffEndTime11: localRecord[Strings.obStaffEndTime11],
      Strings.obStaffEndTime12: localRecord[Strings.obStaffEndTime12],
      Strings.obStaffEndTime13: localRecord[Strings.obStaffEndTime13],
      Strings.obStaffEndTime14: localRecord[Strings.obStaffEndTime14],
      Strings.obStaffEndTime15: localRecord[Strings.obStaffEndTime15],
      Strings.obStaffEndTime16: localRecord[Strings.obStaffEndTime16],
      Strings.obStaffEndTime17: localRecord[Strings.obStaffEndTime17],
      Strings.obStaffEndTime18: localRecord[Strings.obStaffEndTime18],
      Strings.obStaffEndTime19: localRecord[Strings.obStaffEndTime19],
      Strings.obStaffEndTime20: localRecord[Strings.obStaffEndTime20],
      Strings.obStaffName1: localRecord[Strings.obStaffName1],
      Strings.obStaffName2: localRecord[Strings.obStaffName2],
      Strings.obStaffName3: localRecord[Strings.obStaffName3],
      Strings.obStaffName4: localRecord[Strings.obStaffName4],
      Strings.obStaffName5: localRecord[Strings.obStaffName5],
      Strings.obStaffName6: localRecord[Strings.obStaffName6],
      Strings.obStaffName7: localRecord[Strings.obStaffName7],
      Strings.obStaffName8: localRecord[Strings.obStaffName8],
      Strings.obStaffName9: localRecord[Strings.obStaffName9],
      Strings.obStaffName10: localRecord[Strings.obStaffName10],
      Strings.obStaffName11: localRecord[Strings.obStaffName11],
      Strings.obStaffName12: localRecord[Strings.obStaffName12],
      Strings.obStaffName13: localRecord[Strings.obStaffName13],
      Strings.obStaffName14: localRecord[Strings.obStaffName14],
      Strings.obStaffName15: localRecord[Strings.obStaffName15],
      Strings.obStaffName16: localRecord[Strings.obStaffName16],
      Strings.obStaffName17: localRecord[Strings.obStaffName17],
      Strings.obStaffName18: localRecord[Strings.obStaffName18],
      Strings.obStaffName19: localRecord[Strings.obStaffName19],
      Strings.obStaffName20: localRecord[Strings.obStaffName20],
      Strings.obStaffRmn1: localRecord[Strings.obStaffRmn1],
      Strings.obStaffRmn2: localRecord[Strings.obStaffRmn2],
      Strings.obStaffRmn3: localRecord[Strings.obStaffRmn3],
      Strings.obStaffRmn4: localRecord[Strings.obStaffRmn4],
      Strings.obStaffRmn5: localRecord[Strings.obStaffRmn5],
      Strings.obStaffRmn6: localRecord[Strings.obStaffRmn6],
      Strings.obStaffRmn7: localRecord[Strings.obStaffRmn7],
      Strings.obStaffRmn8: localRecord[Strings.obStaffRmn8],
      Strings.obStaffRmn9: localRecord[Strings.obStaffRmn9],
      Strings.obStaffRmn10: localRecord[Strings.obStaffRmn10],
      Strings.obStaffRmn11: localRecord[Strings.obStaffRmn11],
      Strings.obStaffRmn12: localRecord[Strings.obStaffRmn12],
      Strings.obStaffRmn13: localRecord[Strings.obStaffRmn13],
      Strings.obStaffRmn14: localRecord[Strings.obStaffRmn14],
      Strings.obStaffRmn15: localRecord[Strings.obStaffRmn15],
      Strings.obStaffRmn16: localRecord[Strings.obStaffRmn16],
      Strings.obStaffRmn17: localRecord[Strings.obStaffRmn17],
      Strings.obStaffRmn18: localRecord[Strings.obStaffRmn18],
      Strings.obStaffRmn19: localRecord[Strings.obStaffRmn19],
      Strings.obStaffRmn20: localRecord[Strings.obStaffRmn20],
      Strings.obUsefulDetails: localRecord[Strings.obUsefulDetails],
      Strings.issuesFaults: localRecord[Strings.issuesFaults],
      Strings.serverUploaded: localRecord[Strings.serverUploaded],
      Strings.timestamp: localRecord[Strings.timestamp] == null ? null : localRecord[Strings.timestamp]
    };
  }

  Map<String, dynamic> onlineObservationBooking(Map<String, dynamic> localRecord, String docId){
    return {
      Strings.documentId: docId,
      Strings.uid: GlobalFunctions.databaseValueString(localRecord[Strings.uid]),
      Strings.jobId: localRecord[Strings.jobId],
      Strings.formVersion: localRecord[Strings.formVersion],
      Strings.jobRef: localRecord[Strings.jobRef],
      Strings.obRequestedBy: localRecord[Strings.obRequestedBy],
      Strings.obJobTitle: localRecord[Strings.obJobTitle],
      Strings.obJobContact: localRecord[Strings.obJobContact],
      Strings.obJobAuthorisingManager: localRecord[Strings.obJobAuthorisingManager],
      Strings.obJobDate: localRecord[Strings.obJobDate] == null ? null : DateTime
          .fromMillisecondsSinceEpoch(
          localRecord[Strings.obJobDate].millisecondsSinceEpoch)
          .toIso8601String(),      Strings.obJobTime: localRecord[Strings.obJobTime],
      Strings.obBookingCoordinator: localRecord[Strings.obBookingCoordinator],
      Strings.obPatientLocation: localRecord[Strings.obPatientLocation],
      Strings.obPostcode: localRecord[Strings.obPostcode],
      Strings.obLocationTel: localRecord[Strings.obLocationTel],
      Strings.obInvoiceDetails: localRecord[Strings.obInvoiceDetails],
      Strings.obCostCode: localRecord[Strings.obCostCode],
      Strings.obPurchaseOrder: localRecord[Strings.obPurchaseOrder],
      Strings.obStartDateTime: localRecord[Strings.obStartDateTime],
      Strings.obMhaAssessmentYes: localRecord[Strings.obMhaAssessmentYes],
      Strings.obMhaAssessmentNo: localRecord[Strings.obMhaAssessmentNo],
      Strings.obBedIdentifiedYes: localRecord[Strings.obBedIdentifiedYes],
      Strings.obBedIdentifiedNo: localRecord[Strings.obBedIdentifiedNo],
      Strings.obWrapDocumentationYes: localRecord[Strings.obWrapDocumentationYes],
      Strings.obWrapDocumentationNo: localRecord[Strings.obWrapDocumentationNo],
      Strings.obShiftRequired: localRecord[Strings.obShiftRequired],
      Strings.obPatientName: localRecord[Strings.obPatientName],
      Strings.obLegalStatus: localRecord[Strings.obLegalStatus],
      Strings.obDateOfBirth: localRecord[Strings.obDateOfBirth],
      Strings.obNhsNumber: localRecord[Strings.obNhsNumber],
      Strings.obGender: localRecord[Strings.obGender],
      Strings.obEthnicity: localRecord[Strings.obEthnicity],
      Strings.obCovidStatus: localRecord[Strings.obCovidStatus],
      Strings.obRmn: localRecord[Strings.obRmn],
      Strings.obHca: localRecord[Strings.obHca],
      Strings.obHca1: localRecord[Strings.obHca1],
      Strings.obHca2: localRecord[Strings.obHca2],
      Strings.obHca3: localRecord[Strings.obHca3],
      Strings.obHca4: localRecord[Strings.obHca4],
      Strings.obHca5: localRecord[Strings.obHca5],
      Strings.obCurrentPresentation: localRecord[Strings.obCurrentPresentation],
      Strings.obSpecificCarePlanYes: localRecord[Strings.obSpecificCarePlanYes],
      Strings.obSpecificCarePlanNo: localRecord[Strings.obSpecificCarePlanNo],
      Strings.obSpecificCarePlan: localRecord[Strings.obSpecificCarePlan],
      Strings.obPatientWarningsYes: localRecord[Strings.obPatientWarningsYes],
      Strings.obPatientWarningsNo: localRecord[Strings.obPatientWarningsNo],
      Strings.obPatientWarnings: localRecord[Strings.obPatientWarnings],
      Strings.obPresentingRisks: localRecord[Strings.obPresentingRisks],
      Strings.obPreviousRisks: localRecord[Strings.obPreviousRisks],
      Strings.obGenderConcernsYes: localRecord[Strings.obGenderConcernsYes],
      Strings.obGenderConcernsNo: localRecord[Strings.obGenderConcernsNo],
      Strings.obGenderConcerns: localRecord[Strings.obGenderConcerns],
      Strings.obSafeguardingConcernsYes: localRecord[Strings.obSafeguardingConcernsYes],
      Strings.obSafeguardingConcernsNo: localRecord[Strings.obSafeguardingConcernsNo],
      Strings.obSafeguardingConcerns: localRecord[Strings.obSafeguardingConcerns],
      Strings.obTimeDue: localRecord[Strings.obTimeDue],
      Strings.obStaffDate1: localRecord[Strings.obStaffDate1],
      Strings.obStaffDate2: localRecord[Strings.obStaffDate2],
      Strings.obStaffDate3: localRecord[Strings.obStaffDate3],
      Strings.obStaffDate4: localRecord[Strings.obStaffDate4],
      Strings.obStaffDate5: localRecord[Strings.obStaffDate5],
      Strings.obStaffDate6: localRecord[Strings.obStaffDate6],
      Strings.obStaffDate7: localRecord[Strings.obStaffDate7],
      Strings.obStaffDate8: localRecord[Strings.obStaffDate8],
      Strings.obStaffDate9: localRecord[Strings.obStaffDate9],
      Strings.obStaffDate10: localRecord[Strings.obStaffDate10],
      Strings.obStaffDate11: localRecord[Strings.obStaffDate11],
      Strings.obStaffDate12: localRecord[Strings.obStaffDate12],
      Strings.obStaffDate13: localRecord[Strings.obStaffDate13],
      Strings.obStaffDate14: localRecord[Strings.obStaffDate14],
      Strings.obStaffDate15: localRecord[Strings.obStaffDate15],
      Strings.obStaffDate16: localRecord[Strings.obStaffDate16],
      Strings.obStaffDate17: localRecord[Strings.obStaffDate17],
      Strings.obStaffDate18: localRecord[Strings.obStaffDate18],
      Strings.obStaffDate19: localRecord[Strings.obStaffDate19],
      Strings.obStaffDate20: localRecord[Strings.obStaffDate20],
      Strings.obStaffStartTime1: localRecord[Strings.obStaffStartTime1],
      Strings.obStaffStartTime2: localRecord[Strings.obStaffStartTime2],
      Strings.obStaffStartTime3: localRecord[Strings.obStaffStartTime3],
      Strings.obStaffStartTime4: localRecord[Strings.obStaffStartTime4],
      Strings.obStaffStartTime5: localRecord[Strings.obStaffStartTime5],
      Strings.obStaffStartTime6: localRecord[Strings.obStaffStartTime6],
      Strings.obStaffStartTime7: localRecord[Strings.obStaffStartTime7],
      Strings.obStaffStartTime8: localRecord[Strings.obStaffStartTime8],
      Strings.obStaffStartTime9: localRecord[Strings.obStaffStartTime9],
      Strings.obStaffStartTime10: localRecord[Strings.obStaffStartTime10],
      Strings.obStaffStartTime11: localRecord[Strings.obStaffStartTime11],
      Strings.obStaffStartTime12: localRecord[Strings.obStaffStartTime12],
      Strings.obStaffStartTime13: localRecord[Strings.obStaffStartTime13],
      Strings.obStaffStartTime14: localRecord[Strings.obStaffStartTime14],
      Strings.obStaffStartTime15: localRecord[Strings.obStaffStartTime15],
      Strings.obStaffStartTime16: localRecord[Strings.obStaffStartTime16],
      Strings.obStaffStartTime17: localRecord[Strings.obStaffStartTime17],
      Strings.obStaffStartTime18: localRecord[Strings.obStaffStartTime18],
      Strings.obStaffStartTime19: localRecord[Strings.obStaffStartTime19],
      Strings.obStaffStartTime20: localRecord[Strings.obStaffStartTime20],
      Strings.obStaffEndTime1: localRecord[Strings.obStaffEndTime1],
      Strings.obStaffEndTime2: localRecord[Strings.obStaffEndTime2],
      Strings.obStaffEndTime3: localRecord[Strings.obStaffEndTime3],
      Strings.obStaffEndTime4: localRecord[Strings.obStaffEndTime4],
      Strings.obStaffEndTime5: localRecord[Strings.obStaffEndTime5],
      Strings.obStaffEndTime6: localRecord[Strings.obStaffEndTime6],
      Strings.obStaffEndTime7: localRecord[Strings.obStaffEndTime7],
      Strings.obStaffEndTime8: localRecord[Strings.obStaffEndTime8],
      Strings.obStaffEndTime9: localRecord[Strings.obStaffEndTime9],
      Strings.obStaffEndTime10: localRecord[Strings.obStaffEndTime10],
      Strings.obStaffEndTime11: localRecord[Strings.obStaffEndTime11],
      Strings.obStaffEndTime12: localRecord[Strings.obStaffEndTime12],
      Strings.obStaffEndTime13: localRecord[Strings.obStaffEndTime13],
      Strings.obStaffEndTime14: localRecord[Strings.obStaffEndTime14],
      Strings.obStaffEndTime15: localRecord[Strings.obStaffEndTime15],
      Strings.obStaffEndTime16: localRecord[Strings.obStaffEndTime16],
      Strings.obStaffEndTime17: localRecord[Strings.obStaffEndTime17],
      Strings.obStaffEndTime18: localRecord[Strings.obStaffEndTime18],
      Strings.obStaffEndTime19: localRecord[Strings.obStaffEndTime19],
      Strings.obStaffEndTime20: localRecord[Strings.obStaffEndTime20],
      Strings.obStaffName1: localRecord[Strings.obStaffName1],
      Strings.obStaffName2: localRecord[Strings.obStaffName2],
      Strings.obStaffName3: localRecord[Strings.obStaffName3],
      Strings.obStaffName4: localRecord[Strings.obStaffName4],
      Strings.obStaffName5: localRecord[Strings.obStaffName5],
      Strings.obStaffName6: localRecord[Strings.obStaffName6],
      Strings.obStaffName7: localRecord[Strings.obStaffName7],
      Strings.obStaffName8: localRecord[Strings.obStaffName8],
      Strings.obStaffName9: localRecord[Strings.obStaffName9],
      Strings.obStaffName10: localRecord[Strings.obStaffName10],
      Strings.obStaffName11: localRecord[Strings.obStaffName11],
      Strings.obStaffName12: localRecord[Strings.obStaffName12],
      Strings.obStaffName13: localRecord[Strings.obStaffName13],
      Strings.obStaffName14: localRecord[Strings.obStaffName14],
      Strings.obStaffName15: localRecord[Strings.obStaffName15],
      Strings.obStaffName16: localRecord[Strings.obStaffName16],
      Strings.obStaffName17: localRecord[Strings.obStaffName17],
      Strings.obStaffName18: localRecord[Strings.obStaffName18],
      Strings.obStaffName19: localRecord[Strings.obStaffName19],
      Strings.obStaffName20: localRecord[Strings.obStaffName20],
      Strings.obStaffRmn1: localRecord[Strings.obStaffRmn1],
      Strings.obStaffRmn2: localRecord[Strings.obStaffRmn2],
      Strings.obStaffRmn3: localRecord[Strings.obStaffRmn3],
      Strings.obStaffRmn4: localRecord[Strings.obStaffRmn4],
      Strings.obStaffRmn5: localRecord[Strings.obStaffRmn5],
      Strings.obStaffRmn6: localRecord[Strings.obStaffRmn6],
      Strings.obStaffRmn7: localRecord[Strings.obStaffRmn7],
      Strings.obStaffRmn8: localRecord[Strings.obStaffRmn8],
      Strings.obStaffRmn9: localRecord[Strings.obStaffRmn9],
      Strings.obStaffRmn10: localRecord[Strings.obStaffRmn10],
      Strings.obStaffRmn11: localRecord[Strings.obStaffRmn11],
      Strings.obStaffRmn12: localRecord[Strings.obStaffRmn12],
      Strings.obStaffRmn13: localRecord[Strings.obStaffRmn13],
      Strings.obStaffRmn14: localRecord[Strings.obStaffRmn14],
      Strings.obStaffRmn15: localRecord[Strings.obStaffRmn15],
      Strings.obStaffRmn16: localRecord[Strings.obStaffRmn16],
      Strings.obStaffRmn17: localRecord[Strings.obStaffRmn17],
      Strings.obStaffRmn18: localRecord[Strings.obStaffRmn18],
      Strings.obStaffRmn19: localRecord[Strings.obStaffRmn19],
      Strings.obStaffRmn20: localRecord[Strings.obStaffRmn20],
      Strings.obUsefulDetails: localRecord[Strings.obUsefulDetails],





      Strings.serverUploaded: localRecord[Strings.serverUploaded],
      Strings.timestamp: localRecord[Strings.timestamp] == null ? null : DateTime
          .fromMillisecondsSinceEpoch(
          localRecord['timestamp'].millisecondsSinceEpoch)
          .toIso8601String()
    };
  }

  Map<String, dynamic> editedObservationBooking(Map<String, dynamic> localRecord){
    return {
      Strings.documentId: GlobalFunctions.databaseValueString(localRecord[Strings.documentId]),
      Strings.uid: GlobalFunctions.databaseValueString(localRecord[Strings.uid]),
      Strings.jobId: localRecord[Strings.jobId],
      Strings.formVersion: localRecord[Strings.formVersion],
      Strings.jobRef: localRecord[Strings.jobRef],
      Strings.obRequestedBy: localRecord[Strings.obRequestedBy],
      Strings.obJobTitle: localRecord[Strings.obJobTitle],
      Strings.obJobContact: localRecord[Strings.obJobContact],
      Strings.obJobAuthorisingManager: localRecord[Strings.obJobAuthorisingManager],
      Strings.obJobDate: localRecord[Strings.obJobDate],
      Strings.obJobTime: localRecord[Strings.obJobTime],
      Strings.obBookingCoordinator: localRecord[Strings.obBookingCoordinator],
      Strings.obPatientLocation: localRecord[Strings.obPatientLocation],
      Strings.obPostcode: localRecord[Strings.obPostcode],
      Strings.obLocationTel: localRecord[Strings.obLocationTel],
      Strings.obInvoiceDetails: localRecord[Strings.obInvoiceDetails],
      Strings.obCostCode: localRecord[Strings.obCostCode],
      Strings.obPurchaseOrder: localRecord[Strings.obPurchaseOrder],
      Strings.obStartDateTime: localRecord[Strings.obStartDateTime],
      Strings.obMhaAssessmentYes: localRecord[Strings.obMhaAssessmentYes],
      Strings.obMhaAssessmentNo: localRecord[Strings.obMhaAssessmentNo],
      Strings.obBedIdentifiedYes: localRecord[Strings.obBedIdentifiedYes],
      Strings.obBedIdentifiedNo: localRecord[Strings.obBedIdentifiedNo],
      Strings.obWrapDocumentationYes: localRecord[Strings.obWrapDocumentationYes],
      Strings.obWrapDocumentationNo: localRecord[Strings.obWrapDocumentationNo],
      Strings.obShiftRequired: localRecord[Strings.obShiftRequired],
      Strings.obPatientName: localRecord[Strings.obPatientName],
      Strings.obLegalStatus: localRecord[Strings.obLegalStatus],
      Strings.obDateOfBirth: localRecord[Strings.obDateOfBirth],
      Strings.obNhsNumber: localRecord[Strings.obNhsNumber],
      Strings.obGender: localRecord[Strings.obGender],
      Strings.obEthnicity: localRecord[Strings.obEthnicity],
      Strings.obCovidStatus: localRecord[Strings.obCovidStatus],
      Strings.obRmn: localRecord[Strings.obRmn],
      Strings.obHca: localRecord[Strings.obHca],
      Strings.obHca1: localRecord[Strings.obHca1],
      Strings.obHca2: localRecord[Strings.obHca2],
      Strings.obHca3: localRecord[Strings.obHca3],
      Strings.obHca4: localRecord[Strings.obHca4],
      Strings.obHca5: localRecord[Strings.obHca5],
      Strings.obCurrentPresentation: localRecord[Strings.obCurrentPresentation],
      Strings.obSpecificCarePlanYes: localRecord[Strings.obSpecificCarePlanYes],
      Strings.obSpecificCarePlanNo: localRecord[Strings.obSpecificCarePlanNo],
      Strings.obSpecificCarePlan: localRecord[Strings.obSpecificCarePlan],
      Strings.obPatientWarningsYes: localRecord[Strings.obPatientWarningsYes],
      Strings.obPatientWarningsNo: localRecord[Strings.obPatientWarningsNo],
      Strings.obPatientWarnings: localRecord[Strings.obPatientWarnings],
      Strings.obPresentingRisks: localRecord[Strings.obPresentingRisks],
      Strings.obPreviousRisks: localRecord[Strings.obPreviousRisks],
      Strings.obGenderConcernsYes: localRecord[Strings.obGenderConcernsYes],
      Strings.obGenderConcernsNo: localRecord[Strings.obGenderConcernsNo],
      Strings.obGenderConcerns: localRecord[Strings.obGenderConcerns],
      Strings.obSafeguardingConcernsYes: localRecord[Strings.obSafeguardingConcernsYes],
      Strings.obSafeguardingConcernsNo: localRecord[Strings.obSafeguardingConcernsNo],
      Strings.obSafeguardingConcerns: localRecord[Strings.obSafeguardingConcerns],
      Strings.obTimeDue: localRecord[Strings.obTimeDue],
      Strings.obStaffDate1: localRecord[Strings.obStaffDate1],
      Strings.obStaffDate2: localRecord[Strings.obStaffDate2],
      Strings.obStaffDate3: localRecord[Strings.obStaffDate3],
      Strings.obStaffDate4: localRecord[Strings.obStaffDate4],
      Strings.obStaffDate5: localRecord[Strings.obStaffDate5],
      Strings.obStaffDate6: localRecord[Strings.obStaffDate6],
      Strings.obStaffDate7: localRecord[Strings.obStaffDate7],
      Strings.obStaffDate8: localRecord[Strings.obStaffDate8],
      Strings.obStaffDate9: localRecord[Strings.obStaffDate9],
      Strings.obStaffDate10: localRecord[Strings.obStaffDate10],
      Strings.obStaffDate11: localRecord[Strings.obStaffDate11],
      Strings.obStaffDate12: localRecord[Strings.obStaffDate12],
      Strings.obStaffDate13: localRecord[Strings.obStaffDate13],
      Strings.obStaffDate14: localRecord[Strings.obStaffDate14],
      Strings.obStaffDate15: localRecord[Strings.obStaffDate15],
      Strings.obStaffDate16: localRecord[Strings.obStaffDate16],
      Strings.obStaffDate17: localRecord[Strings.obStaffDate17],
      Strings.obStaffDate18: localRecord[Strings.obStaffDate18],
      Strings.obStaffDate19: localRecord[Strings.obStaffDate19],
      Strings.obStaffDate20: localRecord[Strings.obStaffDate20],
      Strings.obStaffStartTime1: localRecord[Strings.obStaffStartTime1],
      Strings.obStaffStartTime2: localRecord[Strings.obStaffStartTime2],
      Strings.obStaffStartTime3: localRecord[Strings.obStaffStartTime3],
      Strings.obStaffStartTime4: localRecord[Strings.obStaffStartTime4],
      Strings.obStaffStartTime5: localRecord[Strings.obStaffStartTime5],
      Strings.obStaffStartTime6: localRecord[Strings.obStaffStartTime6],
      Strings.obStaffStartTime7: localRecord[Strings.obStaffStartTime7],
      Strings.obStaffStartTime8: localRecord[Strings.obStaffStartTime8],
      Strings.obStaffStartTime9: localRecord[Strings.obStaffStartTime9],
      Strings.obStaffStartTime10: localRecord[Strings.obStaffStartTime10],
      Strings.obStaffStartTime11: localRecord[Strings.obStaffStartTime11],
      Strings.obStaffStartTime12: localRecord[Strings.obStaffStartTime12],
      Strings.obStaffStartTime13: localRecord[Strings.obStaffStartTime13],
      Strings.obStaffStartTime14: localRecord[Strings.obStaffStartTime14],
      Strings.obStaffStartTime15: localRecord[Strings.obStaffStartTime15],
      Strings.obStaffStartTime16: localRecord[Strings.obStaffStartTime16],
      Strings.obStaffStartTime17: localRecord[Strings.obStaffStartTime17],
      Strings.obStaffStartTime18: localRecord[Strings.obStaffStartTime18],
      Strings.obStaffStartTime19: localRecord[Strings.obStaffStartTime19],
      Strings.obStaffStartTime20: localRecord[Strings.obStaffStartTime20],
      Strings.obStaffEndTime1: localRecord[Strings.obStaffEndTime1],
      Strings.obStaffEndTime2: localRecord[Strings.obStaffEndTime2],
      Strings.obStaffEndTime3: localRecord[Strings.obStaffEndTime3],
      Strings.obStaffEndTime4: localRecord[Strings.obStaffEndTime4],
      Strings.obStaffEndTime5: localRecord[Strings.obStaffEndTime5],
      Strings.obStaffEndTime6: localRecord[Strings.obStaffEndTime6],
      Strings.obStaffEndTime7: localRecord[Strings.obStaffEndTime7],
      Strings.obStaffEndTime8: localRecord[Strings.obStaffEndTime8],
      Strings.obStaffEndTime9: localRecord[Strings.obStaffEndTime9],
      Strings.obStaffEndTime10: localRecord[Strings.obStaffEndTime10],
      Strings.obStaffEndTime11: localRecord[Strings.obStaffEndTime11],
      Strings.obStaffEndTime12: localRecord[Strings.obStaffEndTime12],
      Strings.obStaffEndTime13: localRecord[Strings.obStaffEndTime13],
      Strings.obStaffEndTime14: localRecord[Strings.obStaffEndTime14],
      Strings.obStaffEndTime15: localRecord[Strings.obStaffEndTime15],
      Strings.obStaffEndTime16: localRecord[Strings.obStaffEndTime16],
      Strings.obStaffEndTime17: localRecord[Strings.obStaffEndTime17],
      Strings.obStaffEndTime18: localRecord[Strings.obStaffEndTime18],
      Strings.obStaffEndTime19: localRecord[Strings.obStaffEndTime19],
      Strings.obStaffEndTime20: localRecord[Strings.obStaffEndTime20],
      Strings.obStaffName1: localRecord[Strings.obStaffName1],
      Strings.obStaffName2: localRecord[Strings.obStaffName2],
      Strings.obStaffName3: localRecord[Strings.obStaffName3],
      Strings.obStaffName4: localRecord[Strings.obStaffName4],
      Strings.obStaffName5: localRecord[Strings.obStaffName5],
      Strings.obStaffName6: localRecord[Strings.obStaffName6],
      Strings.obStaffName7: localRecord[Strings.obStaffName7],
      Strings.obStaffName8: localRecord[Strings.obStaffName8],
      Strings.obStaffName9: localRecord[Strings.obStaffName9],
      Strings.obStaffName10: localRecord[Strings.obStaffName10],
      Strings.obStaffName11: localRecord[Strings.obStaffName11],
      Strings.obStaffName12: localRecord[Strings.obStaffName12],
      Strings.obStaffName13: localRecord[Strings.obStaffName13],
      Strings.obStaffName14: localRecord[Strings.obStaffName14],
      Strings.obStaffName15: localRecord[Strings.obStaffName15],
      Strings.obStaffName16: localRecord[Strings.obStaffName16],
      Strings.obStaffName17: localRecord[Strings.obStaffName17],
      Strings.obStaffName18: localRecord[Strings.obStaffName18],
      Strings.obStaffName19: localRecord[Strings.obStaffName19],
      Strings.obStaffName20: localRecord[Strings.obStaffName20],
      Strings.obStaffRmn1: localRecord[Strings.obStaffRmn1],
      Strings.obStaffRmn2: localRecord[Strings.obStaffRmn2],
      Strings.obStaffRmn3: localRecord[Strings.obStaffRmn3],
      Strings.obStaffRmn4: localRecord[Strings.obStaffRmn4],
      Strings.obStaffRmn5: localRecord[Strings.obStaffRmn5],
      Strings.obStaffRmn6: localRecord[Strings.obStaffRmn6],
      Strings.obStaffRmn7: localRecord[Strings.obStaffRmn7],
      Strings.obStaffRmn8: localRecord[Strings.obStaffRmn8],
      Strings.obStaffRmn9: localRecord[Strings.obStaffRmn9],
      Strings.obStaffRmn10: localRecord[Strings.obStaffRmn10],
      Strings.obStaffRmn11: localRecord[Strings.obStaffRmn11],
      Strings.obStaffRmn12: localRecord[Strings.obStaffRmn12],
      Strings.obStaffRmn13: localRecord[Strings.obStaffRmn13],
      Strings.obStaffRmn14: localRecord[Strings.obStaffRmn14],
      Strings.obStaffRmn15: localRecord[Strings.obStaffRmn15],
      Strings.obStaffRmn16: localRecord[Strings.obStaffRmn16],
      Strings.obStaffRmn17: localRecord[Strings.obStaffRmn17],
      Strings.obStaffRmn18: localRecord[Strings.obStaffRmn18],
      Strings.obStaffRmn19: localRecord[Strings.obStaffRmn19],
      Strings.obStaffRmn20: localRecord[Strings.obStaffRmn20],
      Strings.obUsefulDetails: localRecord[Strings.obUsefulDetails],
      Strings.serverUploaded: localRecord[Strings.serverUploaded],
      Strings.timestamp: localRecord[Strings.timestamp]
    };
  }



  Future<Map<String, dynamic>> uploadPendingObservationBookings() async {
    _isLoading = true;
    String message = 'Something went wrong!';
    bool success = false;

    try {

      List<dynamic> observationBookingRecords = await getPendingRecords();

      List<Map<String, dynamic>> observationBookings = [];

      for(var observationBookingRecord in observationBookingRecords){
        observationBookings.add(observationBookingRecord.value);
      }

      // List<Map<String, dynamic>> observationBookings =
      // await _databaseHelper.getAllWhereAndWhere(
      //     Strings.observationBookingTable,
      //     Strings.serverUploaded,
      //     0,
      //     Strings.uid,
      //     user.uid);


      bool isTokenExpired = GlobalFunctions.isTokenExpired();
      bool authenticated = true;

      if (isTokenExpired)
        authenticated = await authenticationModel.reAuthenticate();

      if (authenticated) {

        for (Map<String, dynamic> observationBooking in observationBookings) {

          success = false;

          await GlobalFunctions.checkFirebaseStorageFail(_databaseHelper);


          DocumentReference ref =
          await FirebaseFirestore.instance.collection('observation_bookings').add({
            Strings.uid: user.uid,
            Strings.jobId: '1',
            Strings.formVersion: '1',
            Strings.jobRef: GlobalFunctions.databaseValueString(observationBooking[Strings.jobRef]),
            Strings.jobRefLowercase: GlobalFunctions.databaseValueString(observationBooking[Strings.jobRef]).toLowerCase(),
            Strings.obRequestedBy: observationBooking[Strings.obRequestedBy],
            Strings.obJobTitle: observationBooking[Strings.obJobTitle],
            Strings.obJobContact: observationBooking[Strings.obJobContact],
            Strings.obJobAuthorisingManager: observationBooking[Strings.obJobAuthorisingManager],
            Strings.obJobDate: observationBooking[Strings.obJobDate] == null ? null : DateTime.parse(observationBooking[Strings.obJobDate]),
            Strings.obJobTime: observationBooking[Strings.obJobTime],
            Strings.obBookingCoordinator: observationBooking[Strings.obBookingCoordinator],
            Strings.obPatientLocation: observationBooking[Strings.obPatientLocation],
            Strings.obPostcode: observationBooking[Strings.obPostcode],
            Strings.obLocationTel: observationBooking[Strings.obLocationTel],
            Strings.obInvoiceDetails: observationBooking[Strings.obInvoiceDetails],
            Strings.obCostCode: observationBooking[Strings.obCostCode],
            Strings.obPurchaseOrder: observationBooking[Strings.obPurchaseOrder],
            Strings.obStartDateTime: observationBooking[Strings.obStartDateTime],
            Strings.obMhaAssessmentYes: observationBooking[Strings.obMhaAssessmentYes],
            Strings.obMhaAssessmentNo: observationBooking[Strings.obMhaAssessmentNo],
            Strings.obBedIdentifiedYes: observationBooking[Strings.obBedIdentifiedYes],
            Strings.obBedIdentifiedNo: observationBooking[Strings.obBedIdentifiedNo],
            Strings.obWrapDocumentationYes: observationBooking[Strings.obWrapDocumentationYes],
            Strings.obWrapDocumentationNo: observationBooking[Strings.obWrapDocumentationNo],
            Strings.obShiftRequired: observationBooking[Strings.obShiftRequired],
            Strings.obPatientName: observationBooking[Strings.obPatientName],
            Strings.obLegalStatus: observationBooking[Strings.obLegalStatus],
            Strings.obDateOfBirth: observationBooking[Strings.obDateOfBirth],
            Strings.obNhsNumber: observationBooking[Strings.obNhsNumber],
            Strings.obGender: observationBooking[Strings.obGender],
            Strings.obEthnicity: observationBooking[Strings.obEthnicity],
            Strings.obCovidStatus: observationBooking[Strings.obCovidStatus],
            Strings.obRmn: observationBooking[Strings.obRmn],
            Strings.obHca: observationBooking[Strings.obHca],
            Strings.obHca1: observationBooking[Strings.obHca1],
            Strings.obHca2: observationBooking[Strings.obHca2],
            Strings.obHca3: observationBooking[Strings.obHca3],
            Strings.obHca4: observationBooking[Strings.obHca4],
            Strings.obHca5: observationBooking[Strings.obHca5],
            Strings.obCurrentPresentation: observationBooking[Strings.obCurrentPresentation],
            Strings.obSpecificCarePlanYes: observationBooking[Strings.obSpecificCarePlanYes],
            Strings.obSpecificCarePlanNo: observationBooking[Strings.obSpecificCarePlanNo],
            Strings.obSpecificCarePlan: observationBooking[Strings.obSpecificCarePlan],
            Strings.obPatientWarningsYes: observationBooking[Strings.obPatientWarningsYes],
            Strings.obPatientWarningsNo: observationBooking[Strings.obPatientWarningsNo],
            Strings.obPatientWarnings: observationBooking[Strings.obPatientWarnings],
            Strings.obPresentingRisks: observationBooking[Strings.obPresentingRisks],
            Strings.obPreviousRisks: observationBooking[Strings.obPreviousRisks],
            Strings.obGenderConcernsYes: observationBooking[Strings.obGenderConcernsYes],
            Strings.obGenderConcernsNo: observationBooking[Strings.obGenderConcernsNo],
            Strings.obGenderConcerns: observationBooking[Strings.obGenderConcerns],
            Strings.obSafeguardingConcernsYes: observationBooking[Strings.obSafeguardingConcernsYes],
            Strings.obSafeguardingConcernsNo: observationBooking[Strings.obSafeguardingConcernsNo],
            Strings.obSafeguardingConcerns: observationBooking[Strings.obSafeguardingConcerns],
            Strings.obTimeDue: observationBooking[Strings.obTimeDue],
            Strings.obStaffDate1: observationBooking[Strings.obStaffDate1],
            Strings.obStaffDate2: observationBooking[Strings.obStaffDate2],
            Strings.obStaffDate3: observationBooking[Strings.obStaffDate3],
            Strings.obStaffDate4: observationBooking[Strings.obStaffDate4],
            Strings.obStaffDate5: observationBooking[Strings.obStaffDate5],
            Strings.obStaffDate6: observationBooking[Strings.obStaffDate6],
            Strings.obStaffDate7: observationBooking[Strings.obStaffDate7],
            Strings.obStaffDate8: observationBooking[Strings.obStaffDate8],
            Strings.obStaffDate9: observationBooking[Strings.obStaffDate9],
            Strings.obStaffDate10: observationBooking[Strings.obStaffDate10],
            Strings.obStaffDate11: observationBooking[Strings.obStaffDate11],
            Strings.obStaffDate12: observationBooking[Strings.obStaffDate12],
            Strings.obStaffDate13: observationBooking[Strings.obStaffDate13],
            Strings.obStaffDate14: observationBooking[Strings.obStaffDate14],
            Strings.obStaffDate15: observationBooking[Strings.obStaffDate15],
            Strings.obStaffDate16: observationBooking[Strings.obStaffDate16],
            Strings.obStaffDate17: observationBooking[Strings.obStaffDate17],
            Strings.obStaffDate18: observationBooking[Strings.obStaffDate18],
            Strings.obStaffDate19: observationBooking[Strings.obStaffDate19],
            Strings.obStaffDate20: observationBooking[Strings.obStaffDate20],
            Strings.obStaffStartTime1: observationBooking[Strings.obStaffStartTime1],
            Strings.obStaffStartTime2: observationBooking[Strings.obStaffStartTime2],
            Strings.obStaffStartTime3: observationBooking[Strings.obStaffStartTime3],
            Strings.obStaffStartTime4: observationBooking[Strings.obStaffStartTime4],
            Strings.obStaffStartTime5: observationBooking[Strings.obStaffStartTime5],
            Strings.obStaffStartTime6: observationBooking[Strings.obStaffStartTime6],
            Strings.obStaffStartTime7: observationBooking[Strings.obStaffStartTime7],
            Strings.obStaffStartTime8: observationBooking[Strings.obStaffStartTime8],
            Strings.obStaffStartTime9: observationBooking[Strings.obStaffStartTime9],
            Strings.obStaffStartTime10: observationBooking[Strings.obStaffStartTime10],
            Strings.obStaffStartTime11: observationBooking[Strings.obStaffStartTime11],
            Strings.obStaffStartTime12: observationBooking[Strings.obStaffStartTime12],
            Strings.obStaffStartTime13: observationBooking[Strings.obStaffStartTime13],
            Strings.obStaffStartTime14: observationBooking[Strings.obStaffStartTime14],
            Strings.obStaffStartTime15: observationBooking[Strings.obStaffStartTime15],
            Strings.obStaffStartTime16: observationBooking[Strings.obStaffStartTime16],
            Strings.obStaffStartTime17: observationBooking[Strings.obStaffStartTime17],
            Strings.obStaffStartTime18: observationBooking[Strings.obStaffStartTime18],
            Strings.obStaffStartTime19: observationBooking[Strings.obStaffStartTime19],
            Strings.obStaffStartTime20: observationBooking[Strings.obStaffStartTime20],
            Strings.obStaffEndTime1: observationBooking[Strings.obStaffEndTime1],
            Strings.obStaffEndTime2: observationBooking[Strings.obStaffEndTime2],
            Strings.obStaffEndTime3: observationBooking[Strings.obStaffEndTime3],
            Strings.obStaffEndTime4: observationBooking[Strings.obStaffEndTime4],
            Strings.obStaffEndTime5: observationBooking[Strings.obStaffEndTime5],
            Strings.obStaffEndTime6: observationBooking[Strings.obStaffEndTime6],
            Strings.obStaffEndTime7: observationBooking[Strings.obStaffEndTime7],
            Strings.obStaffEndTime8: observationBooking[Strings.obStaffEndTime8],
            Strings.obStaffEndTime9: observationBooking[Strings.obStaffEndTime9],
            Strings.obStaffEndTime10: observationBooking[Strings.obStaffEndTime10],
            Strings.obStaffEndTime11: observationBooking[Strings.obStaffEndTime11],
            Strings.obStaffEndTime12: observationBooking[Strings.obStaffEndTime12],
            Strings.obStaffEndTime13: observationBooking[Strings.obStaffEndTime13],
            Strings.obStaffEndTime14: observationBooking[Strings.obStaffEndTime14],
            Strings.obStaffEndTime15: observationBooking[Strings.obStaffEndTime15],
            Strings.obStaffEndTime16: observationBooking[Strings.obStaffEndTime16],
            Strings.obStaffEndTime17: observationBooking[Strings.obStaffEndTime17],
            Strings.obStaffEndTime18: observationBooking[Strings.obStaffEndTime18],
            Strings.obStaffEndTime19: observationBooking[Strings.obStaffEndTime19],
            Strings.obStaffEndTime20: observationBooking[Strings.obStaffEndTime20],
            Strings.obStaffName1: observationBooking[Strings.obStaffName1],
            Strings.obStaffName2: observationBooking[Strings.obStaffName2],
            Strings.obStaffName3: observationBooking[Strings.obStaffName3],
            Strings.obStaffName4: observationBooking[Strings.obStaffName4],
            Strings.obStaffName5: observationBooking[Strings.obStaffName5],
            Strings.obStaffName6: observationBooking[Strings.obStaffName6],
            Strings.obStaffName7: observationBooking[Strings.obStaffName7],
            Strings.obStaffName8: observationBooking[Strings.obStaffName8],
            Strings.obStaffName9: observationBooking[Strings.obStaffName9],
            Strings.obStaffName10: observationBooking[Strings.obStaffName10],
            Strings.obStaffName11: observationBooking[Strings.obStaffName11],
            Strings.obStaffName12: observationBooking[Strings.obStaffName12],
            Strings.obStaffName13: observationBooking[Strings.obStaffName13],
            Strings.obStaffName14: observationBooking[Strings.obStaffName14],
            Strings.obStaffName15: observationBooking[Strings.obStaffName15],
            Strings.obStaffName16: observationBooking[Strings.obStaffName16],
            Strings.obStaffName17: observationBooking[Strings.obStaffName17],
            Strings.obStaffName18: observationBooking[Strings.obStaffName18],
            Strings.obStaffName19: observationBooking[Strings.obStaffName19],
            Strings.obStaffName20: observationBooking[Strings.obStaffName20],
            Strings.obStaffRmn1: observationBooking[Strings.obStaffRmn1],
            Strings.obStaffRmn2: observationBooking[Strings.obStaffRmn2],
            Strings.obStaffRmn3: observationBooking[Strings.obStaffRmn3],
            Strings.obStaffRmn4: observationBooking[Strings.obStaffRmn4],
            Strings.obStaffRmn5: observationBooking[Strings.obStaffRmn5],
            Strings.obStaffRmn6: observationBooking[Strings.obStaffRmn6],
            Strings.obStaffRmn7: observationBooking[Strings.obStaffRmn7],
            Strings.obStaffRmn8: observationBooking[Strings.obStaffRmn8],
            Strings.obStaffRmn9: observationBooking[Strings.obStaffRmn9],
            Strings.obStaffRmn10: observationBooking[Strings.obStaffRmn10],
            Strings.obStaffRmn11: observationBooking[Strings.obStaffRmn11],
            Strings.obStaffRmn12: observationBooking[Strings.obStaffRmn12],
            Strings.obStaffRmn13: observationBooking[Strings.obStaffRmn13],
            Strings.obStaffRmn14: observationBooking[Strings.obStaffRmn14],
            Strings.obStaffRmn15: observationBooking[Strings.obStaffRmn15],
            Strings.obStaffRmn16: observationBooking[Strings.obStaffRmn16],
            Strings.obStaffRmn17: observationBooking[Strings.obStaffRmn17],
            Strings.obStaffRmn18: observationBooking[Strings.obStaffRmn18],
            Strings.obStaffRmn19: observationBooking[Strings.obStaffRmn19],
            Strings.obStaffRmn20: observationBooking[Strings.obStaffRmn20],
            Strings.obUsefulDetails: observationBooking[Strings.obUsefulDetails],
            Strings.timestamp: FieldValue.serverTimestamp(),
            Strings.serverUploaded: 1,
          });

          await deletePendingRecord(observationBooking[Strings.localId]);
          success = true;

          // DocumentSnapshot snap = await ref.get();
          //
          //
          //   Map<String, dynamic> localData = {
          //     Strings.documentId: snap.id,
          //     Strings.serverUploaded: 1,
          //     'timestamp': DateTime.fromMillisecondsSinceEpoch(snap.data()[Strings.timestamp].millisecondsSinceEpoch).toIso8601String()
          //   };
          //
          //   int queryResult = await _databaseHelper.updateRow(
          //       Strings.observationBookingTable,
          //       localData,
          //       Strings.localId,
          //       observationBooking[Strings.localId]);
          //
          //   if (queryResult != 0) {
          //     success = true;
          //   }

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


  Future<void> setUpEditedObservationBooking() async{

    Map<String, dynamic> editedReport = editedObservationBooking(selectedObservationBooking);
    Map<String, dynamic> localData = Map.from(editedReport);
    await _databaseHelper.deleteAllRows(Strings.editedObservationBookingTable);
    await _databaseHelper.add(Strings.editedObservationBookingTable, localData);

  }

  Future<void> deleteEditedObservationBooking() async{
    await _databaseHelper.deleteAllRows(Strings.editedObservationBookingTable);
  }

  void resetTemporaryObservationBooking(String chosenJobId) {
    _databaseHelper.resetTemporaryObservationBooking(user.uid, chosenJobId);
    notifyListeners();
  }


  Future<bool> sharePdf(ShareOption option, [List<String> emailList]) async {

    bool success = false;
    final dateFormat = DateFormat("dd/MM/yyyy");
    final dateTimeFormat = DateFormat("dd/MM/yyyy HH:mm");
    final timeFormat = DateFormat("HH:mm");
    final ByteData fontData = await rootBundle.load("assets/fonts/OpenSans-Regular.ttf");
    final Font ttf = Font.ttf(fontData.buffer.asByteData());
    final ByteData fontDataBold = await rootBundle.load("assets/fonts/OpenSans-Bold.ttf");
    final Font ttfBold = Font.ttf(fontDataBold.buffer.asByteData());

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

    Widget singleLineFieldSmall(String text, String value){
      return Column(
          children: [
            Row(
                children: [
                  Container(width: 90, child: Text(text, style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 8))),
                  SizedBox(width: 5),
                  ConstrainedBox(constraints: BoxConstraints(minHeight: 20),
                      child: Container(
                        width: 100,
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
                            Text(value == null ? '' : value, style: TextStyle(fontSize: 8)),
                          ],
                        ),
                      )),
                ]
            ),
            Container(height: 4)
          ]
      );
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
                            Text(value == null ? '' : value, style: TextStyle(fontSize: 8)),
                          ],
                        ),
                      )) :Expanded(child: ConstrainedBox(constraints: BoxConstraints(minHeight: 20),
                      child: Container(
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

    Widget tripleLineField(String text1, String value1, String text2, String value2, String text3, String value3, [TextOption option1 = TextOption.EncryptedText, TextOption option2 = TextOption.EncryptedText, TextOption option3 = TextOption.EncryptedText, FlutterImage.Image signature, PdfDocument doc]){

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

      if(option3 == TextOption.Date){
        if(value3 == null){
          value3 = '';
        } else {
          value3 = dateFormat.format(DateTime.parse(value3));
        }
      } else if(option3 == TextOption.PlainText){
        if(value3 == null){
          value3 = '';
        } else {
          value3 = value3;
        }
      } else if(option3 == TextOption.EncryptedText){
        if(value3 == null){
          value3 = '';
        } else {
          value3 = GlobalFunctions.decryptString(value3);
        }
      } else if(option3 == TextOption.Time){
        if(value3 == null){
          value3 = '';
        } else {
          value3 = timeFormat.format(DateTime.parse(value3));
        }
      } else if(option3 == TextOption.EncryptedDate){
        if(value3 == null){
          value3 = '';
        } else {
          value3 = dateFormat.format(DateTime.parse(GlobalFunctions.decryptString(value3)));
        }
      } else if(option3 == TextOption.EncryptedText){
        if(value3 == null){
          value3 = '';
        } else {
          value3 = GlobalFunctions.decryptString(value3);
        }
      }



      return Column(
          children: [
            Row(
                children: [
                  Container(width: 70, child: Text(text1, style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 8))),
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
                            Text(value1 == null ? '' : value1, style: TextStyle(fontSize: 8)),
                          ],
                        ),
                      ))),
                  SizedBox(width: 5),
                  Container(width: 70, child: Text(text2, style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 8))),
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
                            signature == null ? Text(value2 == null ? '' : value2, style: TextStyle(fontSize: 8)) : signature == null ? Text('') : Container(height: 20, child: FittedBox(alignment: Alignment.centerLeft, child: Image(PdfImage(doc,
                                image: signature.data.buffer
                                    .asUint8List(),
                                width: signature.width,
                                height: signature.height)))),
                          ],
                        ),
                      ))),
                  SizedBox(width: 5),
                  Container(width: 70, child: Text(text3, style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 8))),
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
                            signature == null ? Text(value3 == null ? '' : value3, style: TextStyle(fontSize: 8)) : signature == null ? Text('') : Container(height: 20, child: FittedBox(alignment: Alignment.centerLeft, child: Image(PdfImage(doc,
                                image: signature.data.buffer
                                    .asUint8List(),
                                width: signature.width,
                                height: signature.height)))),
                          ],
                        ),
                      ))),
                ]
            ),
            Container(height: 4)
          ]
      );
    }

    Widget yesNoField(String yesString, String noString, String text){
      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 100, child: Text(text, style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 8))),
                  Text('Yes', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 8)),
                  Container(width: 5),
                  Container(width: 15, height: 15, padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(shape: BoxShape.circle, border: BoxBorder(
                        top: true,
                        left: true,
                        right: true,
                        bottom: true,
                        width: 1,
                        color: PdfColors.grey,
                      )),
                      child: Center(child: Text(selectedObservationBooking[yesString] == null || selectedObservationBooking[yesString] == 0 ? '' : 'X', textAlign: TextAlign.center ,style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
                  Container(width: 10),
                  Text('No', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 8)),
                  Container(width: 5),
                  Container(width: 15, height: 15, padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(shape: BoxShape.circle, border: BoxBorder(
                        top: true,
                        left: true,
                        right: true,
                        bottom: true,
                        width: 1,
                        color: PdfColors.grey,
                      )),
                      child: Center(child: Text(selectedObservationBooking[noString] == null || selectedObservationBooking[noString] == 0 ? '' : 'X', textAlign: TextAlign.center ,style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
                ]
            ),
            Container(height: 5),
          ]
      );
    }

    Widget sectionTitle(String text){
      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text, style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 9, fontWeight: FontWeight.bold)),
            Container(height: 5)
          ]
      );
    }

    Widget checkBoxTitle(String text1, String text2){
      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(text1, style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 9, fontWeight: FontWeight.bold)),
              Text(text2, style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 8)),
            ]),
            Container(height: 5)
          ]
      );
    }

    Widget staffRow(String value1, String value2, String value3, String value4, String value5){
      return Column(
          children: [
            Row(
                children: [
                  ConstrainedBox(constraints: BoxConstraints(minHeight: 20),
                      child: Container(
                        width: 60,
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
                            Text(value1 == null ? '' : dateFormat.format(DateTime.parse(value1)), style: TextStyle(fontSize: 8)),
                          ],
                        ),
                      )),
                  Container(width: 2),
                  ConstrainedBox(constraints: BoxConstraints(minHeight: 20),
                      child: Container(
                        width: 60,
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
                            Text(value2 == null ? '' : timeFormat.format(DateTime.parse(value2)), style: TextStyle(fontSize: 8)),
                          ],
                        ),
                      )),
                  Container(width: 2),
                  ConstrainedBox(constraints: BoxConstraints(minHeight: 20),
                      child: Container(
                        width: 60,
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
                            Text(value3 == null ? '' : timeFormat.format(DateTime.parse(value3)), style: TextStyle(fontSize: 8)),
                          ],
                        ),
                      )),
                  Container(width: 2),
                  Expanded(child: Expanded(child: ConstrainedBox(constraints: BoxConstraints(minHeight: 20),
                      child: Container(
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
                            Text(value4 == null ? '' : GlobalFunctions.decryptString(value4), style: TextStyle(fontSize: 8)),
                          ],
                        ),
                      )))),
                  Container(width: 2),
                  ConstrainedBox(constraints: BoxConstraints(minHeight: 20),
                      child: Container(
                        width: 60,
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
                            Text(value5 == null ? '' : GlobalFunctions.decryptString(value5), style: TextStyle(fontSize: 8)),
                          ],
                        ),
                      )),
                ]
            ),
            Container(height: 3)
          ]
      );
    }

    Widget techniquePositionRow(String value1, String value2, String value3){
      return Column(
          children: [
            Row(
                children: [
                  Expanded(child: Expanded(child: ConstrainedBox(constraints: BoxConstraints(minHeight: 20),
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
                            Text(value1 == null ? '' : GlobalFunctions.decryptString(value1), style: TextStyle(fontSize: 8)),
                          ],
                        ),
                      )))),
                  Container(width: 2),
                  Expanded(child: Expanded(child: ConstrainedBox(constraints: BoxConstraints(minHeight: 20),
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
                            Text(value2 == null ? '' : GlobalFunctions.decryptString(value2), style: TextStyle(fontSize: 8)),
                          ],
                        ),
                      )))),
                  Container(width: 2),
                  Expanded(child: Expanded(child: ConstrainedBox(constraints: BoxConstraints(minHeight: 20),
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
                            Text(value3 == null ? '' : GlobalFunctions.decryptString(value3), style: TextStyle(fontSize: 8)),
                          ],
                        ),
                      )))),
                ]
            ),
            Container(height: 3)
          ]
      );
    }

    Widget yesNoCheckboxes(String text, var value1, var value2) {
      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8)),
            Container(height: 5),
            Row(
                children: [
                  Text('Yes', style: TextStyle(fontSize: 8)),
                  Container(width: 5),
                  Container(width: 15, height: 15, padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(shape: BoxShape.circle, border: BoxBorder(
                        top: true,
                        left: true,
                        right: true,
                        bottom: true,
                        width: 1,
                        color: PdfColors.grey,
                      )),
                      child: Center(child: Text(value1 == null || value1 == 0 ? '' : 'X', textAlign: TextAlign.center ,style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
                  Container(width: 10),
                  Text('No', style: TextStyle(fontSize: 8)),
                  Container(width: 5),
                  Container(width: 15, height: 15, padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(shape: BoxShape.circle, border: BoxBorder(
                        top: true,
                        left: true,
                        right: true,
                        bottom: true,
                        width: 1,
                        color: PdfColors.grey,
                      )),
                      child: Center(child: Text(value2 == null || value2 == 0 ? '' : 'X', textAlign: TextAlign.center ,style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
                ]
            ),
            Container(height: 5)
          ]);
    }

    Widget headingText(String value, [bool margin = false]){
      return margin ? Container(margin: EdgeInsets.all(2), child: Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8))) : Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8));
    }

    Widget valueText(String value, [bool margin = false, TextOption option = TextOption.EncryptedText]){

      if(option == TextOption.Date){
        if(value == null){
          value = '';
        } else {
          value = dateFormat.format(DateTime.parse(value));
        }
      } else if(option == TextOption.DateTime){
        if(value == null){
          value = '';
        } else {
          value = dateTimeFormat.format(DateTime.parse(value));
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



      return margin ? Container(margin: EdgeInsets.all(2), child: Text(value == null ? '' : value, style: TextStyle(fontSize: 8))) : Text(value == null ? '' : value, style: TextStyle(fontSize: 8));
    }

    Widget tableCellContainer(Widget child, [double width = 250, bool margin = true]){
      return Container(
          padding: EdgeInsets.all(margin ? 2 : 0),
          width: width, child: child);
    }

    String textValue(String value, [TextOption option = TextOption.EncryptedText]){

      if(option == TextOption.Date){
        if(value == null){
          value = '';
        } else {
          value = dateFormat.format(DateTime.parse(value));
        }
      } else if(option == TextOption.DateTime){
        if(value == null){
          value = '';
        } else {
          value = dateTimeFormat.format(DateTime.parse(value));
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



      return value;
    }

    TableRow staffingRow(String date, String startTime, String endTime, String name, String rmnHca){
      return TableRow(
          children: [
            Container(
                padding: EdgeInsets.all(2),
                width: 50, child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(date, style: TextStyle(fontSize: 8))
                ])),
            Container(
                padding: EdgeInsets.all(2),
                width: 30, child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(startTime, style: TextStyle(fontSize: 8))
                ])),
            Container(
                padding: EdgeInsets.all(2),
                width: 30, child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(endTime, style: TextStyle(fontSize: 8))
                ])),
            Container(
                padding: EdgeInsets.all(2),
                width: 70, child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(name, style: TextStyle(fontSize: 8))
                ])),
            Container(
                padding: EdgeInsets.all(2),
                width: 50, child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(rmnHca, style: TextStyle(fontSize: 8))
                ]))
          ]
      );
    }


    try {

      Document pdf;
      pdf = Document();
      PdfDocument pdfDoc = pdf.document;
      PdfImage pegasusLogo = await pdfImageFromImageProvider(pdf: pdfDoc, image: Material.AssetImage('assets/images/pegasusLogo.png'),);


      pdf.addPage(MultiPage(
          theme: Theme.withFont(base: ttf, bold: ttfBold),
          pageFormat: PdfPageFormat.a4,
          crossAxisAlignment: CrossAxisAlignment.start,
          margin: EdgeInsets.all(40),
          footer: (Context context) {
            return Container(
                alignment: Alignment.centerRight,
                margin: const EdgeInsets.only(top: 5),
                child: Text('Observation Booking - Page ${context.pageNumber} of ${context.pagesCount}',
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
                          textField(TextOption.PlainText, selectedObservationBooking[Strings.jobRef]),
                        ]),
                      ]
                  ),

                  Container(height: 50, child: Image(pegasusLogo)),

                ]
            ),
            Container(height: 10),
            Center(child: Text('Observation Booking', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontWeight: FontWeight.bold))),
            Container(height: 20),
            doubleLineField('Requested by', selectedObservationBooking[Strings.obRequestedBy], 'Job Title', selectedObservationBooking[Strings.obJobTitle]),
            doubleLineField('Contact Telephone Number', selectedObservationBooking[Strings.obJobContact], 'Authorising Manager', selectedObservationBooking[Strings.obJobAuthorisingManager]),
            doubleLineField('Date', selectedObservationBooking[Strings.obJobDate], 'Time', selectedObservationBooking[Strings.obJobTime], TextOption.Date, TextOption.Time),
            doubleLineField('Booking Coordinator', selectedObservationBooking[Strings.obBookingCoordinator], 'Start Date & Time', dateTimeFormat.format(DateTime.parse(selectedObservationBooking[Strings.obStartDateTime])), TextOption.EncryptedText, TextOption.DateTime),
            singleLineField('Patient Location Address', selectedObservationBooking[Strings.obPatientLocation]),
            doubleLineField('Postcode', selectedObservationBooking[Strings.obPostcode], 'Location Tel', selectedObservationBooking[Strings.obLocationTel]),
            Container(height: 10),
            yesNoField(Strings.obMhaAssessmentYes, Strings.obMhaAssessmentNo, 'Is the patient awaiting a MHA Assessment?'),
            Container(height: 10),
            yesNoField(Strings.obBedIdentifiedYes, Strings.obBedIdentifiedNo, 'has a bed been identified?'),
            Container(height: 10),
            yesNoField(Strings.obWrapDocumentationYes, Strings.obWrapDocumentationNo, 'Wrap documentation available?'),
            Container(height: 10),
            singleLineField('What shift do you require?', selectedObservationBooking[Strings.obShiftRequired]),
            Container(height: 10),
            Text('Invoice Details', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 10, fontWeight: FontWeight.bold)),
            Container(height: 5),
            textField(TextOption.EncryptedText, selectedObservationBooking[Strings.obInvoiceDetails], 700, 50, 200),
            Container(height: 5),
            doubleLineField('Cost Code', selectedObservationBooking[Strings.obCostCode], 'Purchase Order no', selectedObservationBooking[Strings.obPurchaseOrder]),
            Container(height: 5),
            Text('Patient Details', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 10, fontWeight: FontWeight.bold)),
            Container(height: 5),
            doubleLineField('Name', selectedObservationBooking[Strings.obPatientName], 'Gender', selectedObservationBooking[Strings.obGender]),
            doubleLineField('Legal Status', selectedObservationBooking[Strings.obLegalStatus], 'Ethnicity', selectedObservationBooking[Strings.obEthnicity]),
            doubleLineField('Date of birth', selectedObservationBooking[Strings.obDateOfBirth], 'Covid Status', selectedObservationBooking[Strings.obCovidStatus], TextOption.EncryptedDate),
            doubleLineField('NHS Number', selectedObservationBooking[Strings.obNhsNumber], 'RMN', selectedObservationBooking[Strings.obRmn]),
            singleLineField('Current Presentation', selectedObservationBooking[Strings.obCurrentPresentation]),
            doubleLineField("HCA's", selectedObservationBooking[Strings.obHca], '1.', selectedObservationBooking[Strings.obHca1]),
            doubleLineField('2.', selectedObservationBooking[Strings.obHca2], '3.', selectedObservationBooking[Strings.obHca3]),
            doubleLineField('4.', selectedObservationBooking[Strings.obHca4], '5.', selectedObservationBooking[Strings.obHca5]),
            Container(height: 10),
            yesNoField(Strings.obSpecificCarePlanYes, Strings.obSpecificCarePlanNo, 'Specific Care Plan:'),
            selectedObservationBooking[Strings.obSpecificCarePlanYes] != null && selectedObservationBooking[Strings.obSpecificCarePlanYes] == 1 ?
            singleLineField('Details', selectedObservationBooking[Strings.obSpecificCarePlan]) : Container(),
            Container(height: 10),
            yesNoField(Strings.obPatientWarningsYes, Strings.obPatientWarningsNo, 'Patient warnings/markers:'),
            selectedObservationBooking[Strings.obPatientWarningsYes] != null && selectedObservationBooking[Strings.obPatientWarningsYes] == 1 ?
            singleLineField('Details', selectedObservationBooking[Strings.obPatientWarnings]) : Container(),
            Container(height: 10),
            singleLineField('Presenting Risks: (inc physical health, covid symptoms)', selectedObservationBooking[Strings.obPresentingRisks]),
            singleLineField('Previous Risk History: (inc physical health, covid symptoms)', selectedObservationBooking[Strings.obPreviousRisks]),
            Container(height: 10),
            yesNoField(Strings.obGenderConcernsYes, Strings.obGenderConcernsNo, 'Gender/Race/Sexual Behaviour concerns:'),
            selectedObservationBooking[Strings.obGenderConcernsYes] != null && selectedObservationBooking[Strings.obGenderConcernsYes] == 1 ?
            singleLineField('Details', selectedObservationBooking[Strings.obGenderConcerns]) : Container(),
            Container(height: 10),
            yesNoField(Strings.obSafeguardingConcernsYes, Strings.obSafeguardingConcernsNo, 'Safeguarding Concerns:'),
            selectedObservationBooking[Strings.obSafeguardingConcernsYes] != null && selectedObservationBooking[Strings.obSafeguardingConcernsYes] == 1 ?
            singleLineField('Details', selectedObservationBooking[Strings.obSafeguardingConcerns]) : Container(),
            Container(height: 10),
            singleLineField('Time Due at Location', selectedObservationBooking[Strings.obTimeDue], TextOption.Time, true),
            Container(height: 10),
            Text('Staffing', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 10, fontWeight: FontWeight.bold)),
            Container(height: 5),
            Row(
                children: [
                  Container(width: 60, child: Text('Date', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 8))),
                  Container(width: 2),
                  Container(width: 60, child: Text('Start Time', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 8))),
                  Container(width: 2),
                  Container(width: 60, child: Text('End Time', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 8))),
                  Container(width: 2),
                  Expanded(child: Text('Name', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 8))),
                  Container(width: 2),
                  Container(width: 60, child: Text('RMN/HCA', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 8))),
                ]
            ),
            Container(height: 5),
            staffRow(selectedObservationBooking[Strings.obStaffDate1],
                selectedObservationBooking[Strings.obStaffStartTime1],
                selectedObservationBooking[Strings.obStaffEndTime1],
                selectedObservationBooking[Strings.obStaffName1],
                selectedObservationBooking[Strings.obStaffRmn1]),
            selectedObservationBooking[Strings.obStaffName2] != null && selectedObservationBooking[Strings.obStaffName2] != '' ?
            staffRow(selectedObservationBooking[Strings.obStaffDate2],
                selectedObservationBooking[Strings.obStaffStartTime2],
                selectedObservationBooking[Strings.obStaffEndTime2],
                selectedObservationBooking[Strings.obStaffName2],
                selectedObservationBooking[Strings.obStaffRmn2]) : Container(),
            selectedObservationBooking[Strings.obStaffName3] != null && selectedObservationBooking[Strings.obStaffName3] != '' ?
            staffRow(selectedObservationBooking[Strings.obStaffDate3],
                selectedObservationBooking[Strings.obStaffStartTime3],
                selectedObservationBooking[Strings.obStaffEndTime3],
                selectedObservationBooking[Strings.obStaffName3],
                selectedObservationBooking[Strings.obStaffRmn3]) : Container(),
            selectedObservationBooking[Strings.obStaffName4] != null && selectedObservationBooking[Strings.obStaffName4] != '' ?
            staffRow(selectedObservationBooking[Strings.obStaffDate4],
                selectedObservationBooking[Strings.obStaffStartTime4],
                selectedObservationBooking[Strings.obStaffEndTime4],
                selectedObservationBooking[Strings.obStaffName4],
                selectedObservationBooking[Strings.obStaffRmn4]) : Container(),
            selectedObservationBooking[Strings.obStaffName5] != null && selectedObservationBooking[Strings.obStaffName5] != '' ?
            staffRow(selectedObservationBooking[Strings.obStaffDate5],
                selectedObservationBooking[Strings.obStaffStartTime5],
                selectedObservationBooking[Strings.obStaffEndTime5],
                selectedObservationBooking[Strings.obStaffName5],
                selectedObservationBooking[Strings.obStaffRmn5]) : Container(),
            selectedObservationBooking[Strings.obStaffName6] != null && selectedObservationBooking[Strings.obStaffName6] != '' ?
            staffRow(selectedObservationBooking[Strings.obStaffDate6],
                selectedObservationBooking[Strings.obStaffStartTime6],
                selectedObservationBooking[Strings.obStaffEndTime6],
                selectedObservationBooking[Strings.obStaffName6],
                selectedObservationBooking[Strings.obStaffRmn6]) : Container(),
            selectedObservationBooking[Strings.obStaffName7] != null && selectedObservationBooking[Strings.obStaffName7] != '' ?
            staffRow(selectedObservationBooking[Strings.obStaffDate7],
                selectedObservationBooking[Strings.obStaffStartTime7],
                selectedObservationBooking[Strings.obStaffEndTime7],
                selectedObservationBooking[Strings.obStaffName7],
                selectedObservationBooking[Strings.obStaffRmn7]) : Container(),
            selectedObservationBooking[Strings.obStaffName8] != null && selectedObservationBooking[Strings.obStaffName8] != '' ?
            staffRow(selectedObservationBooking[Strings.obStaffDate8],
                selectedObservationBooking[Strings.obStaffStartTime8],
                selectedObservationBooking[Strings.obStaffEndTime8],
                selectedObservationBooking[Strings.obStaffName8],
                selectedObservationBooking[Strings.obStaffRmn8]) : Container(),
            selectedObservationBooking[Strings.obStaffName9] != null && selectedObservationBooking[Strings.obStaffName9] != '' ?
            staffRow(selectedObservationBooking[Strings.obStaffDate9],
                selectedObservationBooking[Strings.obStaffStartTime9],
                selectedObservationBooking[Strings.obStaffEndTime9],
                selectedObservationBooking[Strings.obStaffName9],
                selectedObservationBooking[Strings.obStaffRmn9]) : Container(),
            selectedObservationBooking[Strings.obStaffName10] != null && selectedObservationBooking[Strings.obStaffName10] != '' ?
            staffRow(selectedObservationBooking[Strings.obStaffDate10],
                selectedObservationBooking[Strings.obStaffStartTime10],
                selectedObservationBooking[Strings.obStaffEndTime10],
                selectedObservationBooking[Strings.obStaffName10],
                selectedObservationBooking[Strings.obStaffRmn10]) : Container(),
            selectedObservationBooking[Strings.obStaffName11] != null && selectedObservationBooking[Strings.obStaffName11] != '' ?
            staffRow(selectedObservationBooking[Strings.obStaffDate11],
                selectedObservationBooking[Strings.obStaffStartTime11],
                selectedObservationBooking[Strings.obStaffEndTime11],
                selectedObservationBooking[Strings.obStaffName11],
                selectedObservationBooking[Strings.obStaffRmn11]) : Container(),
            selectedObservationBooking[Strings.obStaffName12] != null && selectedObservationBooking[Strings.obStaffName12] != '' ?
            staffRow(selectedObservationBooking[Strings.obStaffDate12],
                selectedObservationBooking[Strings.obStaffStartTime12],
                selectedObservationBooking[Strings.obStaffEndTime12],
                selectedObservationBooking[Strings.obStaffName12],
                selectedObservationBooking[Strings.obStaffRmn12]) : Container(),
            selectedObservationBooking[Strings.obStaffName13] != null && selectedObservationBooking[Strings.obStaffName13] != '' ?
            staffRow(selectedObservationBooking[Strings.obStaffDate13],
                selectedObservationBooking[Strings.obStaffStartTime13],
                selectedObservationBooking[Strings.obStaffEndTime13],
                selectedObservationBooking[Strings.obStaffName13],
                selectedObservationBooking[Strings.obStaffRmn13]) : Container(),
            selectedObservationBooking[Strings.obStaffName14] != null && selectedObservationBooking[Strings.obStaffName14] != '' ?
            staffRow(selectedObservationBooking[Strings.obStaffDate14],
                selectedObservationBooking[Strings.obStaffStartTime14],
                selectedObservationBooking[Strings.obStaffEndTime14],
                selectedObservationBooking[Strings.obStaffName14],
                selectedObservationBooking[Strings.obStaffRmn14]) : Container(),
            selectedObservationBooking[Strings.obStaffName15] != null && selectedObservationBooking[Strings.obStaffName15] != '' ?
            staffRow(selectedObservationBooking[Strings.obStaffDate15],
                selectedObservationBooking[Strings.obStaffStartTime15],
                selectedObservationBooking[Strings.obStaffEndTime15],
                selectedObservationBooking[Strings.obStaffName15],
                selectedObservationBooking[Strings.obStaffRmn15]) : Container(),
            selectedObservationBooking[Strings.obStaffName16] != null && selectedObservationBooking[Strings.obStaffName16] != '' ?
            staffRow(selectedObservationBooking[Strings.obStaffDate16],
                selectedObservationBooking[Strings.obStaffStartTime16],
                selectedObservationBooking[Strings.obStaffEndTime16],
                selectedObservationBooking[Strings.obStaffName16],
                selectedObservationBooking[Strings.obStaffRmn16]) : Container(),
            selectedObservationBooking[Strings.obStaffName17] != null && selectedObservationBooking[Strings.obStaffName17] != '' ?
            staffRow(selectedObservationBooking[Strings.obStaffDate17],
                selectedObservationBooking[Strings.obStaffStartTime17],
                selectedObservationBooking[Strings.obStaffEndTime17],
                selectedObservationBooking[Strings.obStaffName17],
                selectedObservationBooking[Strings.obStaffRmn17]) : Container(),
            selectedObservationBooking[Strings.obStaffName18] != null && selectedObservationBooking[Strings.obStaffName18] != '' ?
            staffRow(selectedObservationBooking[Strings.obStaffDate18],
                selectedObservationBooking[Strings.obStaffStartTime18],
                selectedObservationBooking[Strings.obStaffEndTime18],
                selectedObservationBooking[Strings.obStaffName18],
                selectedObservationBooking[Strings.obStaffRmn18]) : Container(),
            selectedObservationBooking[Strings.obStaffName19] != null && selectedObservationBooking[Strings.obStaffName19] != '' ?
            staffRow(selectedObservationBooking[Strings.obStaffDate19],
                selectedObservationBooking[Strings.obStaffStartTime19],
                selectedObservationBooking[Strings.obStaffEndTime19],
                selectedObservationBooking[Strings.obStaffName19],
                selectedObservationBooking[Strings.obStaffRmn19]) : Container(),
            selectedObservationBooking[Strings.obStaffName20] != null && selectedObservationBooking[Strings.obStaffName20] != '' ?
            staffRow(selectedObservationBooking[Strings.obStaffDate20],
                selectedObservationBooking[Strings.obStaffStartTime20],
                selectedObservationBooking[Strings.obStaffEndTime20],
                selectedObservationBooking[Strings.obStaffName20],
                selectedObservationBooking[Strings.obStaffRmn20]) : Container(),
            Container(height: 10),
            Text('Useful Details', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 10, fontWeight: FontWeight.bold)),
            Container(height: 5),
            textField(TextOption.EncryptedText, selectedObservationBooking[Strings.obUsefulDetails], 700, 100, 300),
            Container(height: 5),
          ]

      ));

      String formDate = selectedObservationBooking[Strings.obJobDate] == null ? '' : dateFormatDay.format(DateTime.parse(selectedObservationBooking[Strings.obJobDate]));
      String id = selectedObservationBooking[Strings.documentId];

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
            ..download = 'observation_booking_${formDate}_$id.pdf';
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

        final File file = File('$pdfPath/observation_booking_${formDate}_$id.pdf');

        if(option == ShareOption.Email){
          file.writeAsBytesSync(pdf.save());
        }

        ConnectivityResult connectivityResult = await Connectivity().checkConnectivity();

        if(connectivityResult != ConnectivityResult.none) {

          if(option == ShareOption.Share) Printing.sharePdf(bytes: pdf.save(),filename: 'observation_booking_${formDate}_$id.pdf');
          if(option == ShareOption.Print) await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());

          if(option == ShareOption.Email) {
            final smtpServer = gmail(emailUsername, emailPassword);

            // Create our message.
            final mailmessage = new Message()
              ..from = new Address(emailUsername, 'Pegasus Medical')
              ..recipients = emailList
              ..subject = 'Completed Observation Booking'
              ..html = "<p1>Dear Sir/Madam,</p1>\n<p>Attached is a completed Observation Booking from ${user
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



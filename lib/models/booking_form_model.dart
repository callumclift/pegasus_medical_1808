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


class BookingFormModel extends ChangeNotifier {

  DatabaseHelper _databaseHelper = DatabaseHelper();
  AuthenticationModel authenticationModel = AuthenticationModel();
  final NavigationService _navigationService = locator<NavigationService>();
  BookingFormModel(this.authenticationModel);

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> _bookingForms = [];
  String _selBookingFormId;
  final dateFormatDay = DateFormat("dd-MM-yyyy");

  List<Map<String, dynamic>> get allBookingForms {
    return List.from(_bookingForms);
  }
  int get selectedBookingFormIndex {
    return _bookingForms.indexWhere((Map<String, dynamic> bookingForm) {
      return bookingForm[Strings.documentId] == _selBookingFormId;
    });
  }
  String get selectedBookingFormId {
    return _selBookingFormId;
  }

  Map<String, dynamic> get selectedBookingForm {
    if (_selBookingFormId == null) {
      return null;
    }
    return _bookingForms.firstWhere((Map<String, dynamic> bookingForm) {
      return bookingForm[Strings.documentId] == _selBookingFormId;
    });
  }
  void selectBookingForm(String bookingFormId) {
    _selBookingFormId = bookingFormId;
    if (bookingFormId != null) {
      notifyListeners();
    }
  }

  void clearBookingForms(){
    _bookingForms = [];
  }


  // Sembast database settings
  static const String TEMPORARY_BOOKING_FORMS_STORE_NAME = 'temporary_booking_forms';
  final _temporaryBookingFormsStore = Db.intMapStoreFactory.store(TEMPORARY_BOOKING_FORMS_STORE_NAME);

  static const String BOOKING_FORMS_STORE_NAME = 'booking_forms';
  final _bookingFormsStore = Db.intMapStoreFactory.store(BOOKING_FORMS_STORE_NAME);

  static const String EDITED_BOOKING_FORMS_STORE_NAME = 'edited_booking_forms';
  final _editedBookingFormsStore = Db.intMapStoreFactory.store(EDITED_BOOKING_FORMS_STORE_NAME);

  static const String SAVED_BOOKING_FORMS_STORE_NAME = 'saved_booking_forms';
  final _savedBookingFormsStore = Db.intMapStoreFactory.store(SAVED_BOOKING_FORMS_STORE_NAME);

  // Private getter to shorten the amount of code needed to get the
  // singleton instance of an opened database.
  Future<Db.Database> get _db async => await AppDatabase.instance.database;


  Future<void> setupTemporaryRecord() async {

    final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
        [Db.Filter.equals(Strings.uid, user.uid), Db.Filter.equals(Strings.jobId, '1')]
    ));
    List records = await _temporaryBookingFormsStore.find(
      await _db,
      finder: finder,
    );
    if(records.length == 0){
      // Generate a random ID based on the date and a random string for virtual zero chance of duplicates
      int _id = DateTime.now().millisecondsSinceEpoch + int.parse(random_string.randomNumeric(2));
      await _temporaryBookingFormsStore.record(_id).put(await _db,
          {Strings.uid : user.uid, Strings.formVersion: 1, Strings.jobId : '1'});
    }
  }

  Future<Map<String, dynamic>> getTemporaryRecord(bool edit, String selectedJobId, bool saved, int savedId) async{

    List records;

    if(edit){
      final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
          [Db.Filter.equals(Strings.documentId, selectedBookingForm[Strings.documentId]), Db.Filter.equals(Strings.jobId, selectedJobId)]
      ));
      records = await _editedBookingFormsStore.find(
        await _db,
        finder: finder,
      );
    } else if(saved) {
      final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
          [Db.Filter.equals(Strings.uid, user.uid), Db.Filter.equals(Strings.localId, savedId)]
      ));
      records = await _savedBookingFormsStore.find(
        await _db,
        finder: finder,
      );
    } else {
      final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
          [Db.Filter.equals(Strings.uid, user.uid), Db.Filter.equals(Strings.jobId, selectedJobId)]
      ));
      records = await _temporaryBookingFormsStore.find(
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

    List records = await _bookingFormsStore.find(
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

    List records = await _bookingFormsStore.find(
      await _db,
      finder: finder,
    );

    return records;
  }

  Future <List<dynamic>> getSavedRecords() async{
    final Db.Finder finder = Db.Finder(filter: Db.Filter.equals(Strings.uid, user.uid));
    List records = await _savedBookingFormsStore.find(
      await _db,
      finder: finder,
    );
    return records;
  }

  Future <void> deletePendingRecord(int localId) async{
    final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
        [Db.Filter.equals(Strings.uid, user.uid), Db.Filter.equals(Strings.localId, localId)]
    ));

    await _bookingFormsStore.delete(
      await _db,
      finder: finder,
    );
  }

  Future<bool> checkRecordExists(bool edit, String selectedJobId, bool saved, int savedId) async{

    bool hasRecord = false;
    List records;


    if(edit){

      final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
          [Db.Filter.equals(Strings.documentId, selectedBookingForm[Strings.documentId]), Db.Filter.equals(Strings.jobId, selectedJobId)]
      ));
      records = await _editedBookingFormsStore.find(
        await _db,
        finder: finder,
      );
    } else if(saved){
      final Db.Finder finder = Db.Finder(filter: Db.Filter.equals(Strings.localId, savedId));
      records = await _savedBookingFormsStore.find(
        await _db,
        finder: finder,
      );

    } else {

      final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
          [Db.Filter.equals(Strings.uid, user.uid), Db.Filter.equals(Strings.jobId, selectedJobId)]
      ));
      records = await _temporaryBookingFormsStore.find(
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
      await _editedBookingFormsStore.update(await _db, {field: value},
          finder: finder);
    } else if(saved){
      final Db.Finder finder = Db.Finder(filter: Db.Filter.equals(Strings.localId, savedId));
      await _savedBookingFormsStore.update(await _db, {field: value},
          finder: finder);
    } else {
      final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
          [Db.Filter.equals(Strings.uid, user.uid), Db.Filter.equals(Strings.jobId, selectedJobId)]
      ));
      await _temporaryBookingFormsStore.update(await _db, {field: value},
          finder: finder);
    }

  }

  void deleteEditedRecord() async {
    await _editedBookingFormsStore.delete(await _db);
  }

  Future<void> setUpEditedRecord() async{

    Map<String, dynamic> editedReport = editedBookingForm(selectedBookingForm);
    Map<String, dynamic> localData = Map.from(editedReport);
    await _editedBookingFormsStore.delete(await _db);
    int _id = DateTime.now().millisecondsSinceEpoch + int.parse(random_string.randomNumeric(2));
    await _editedBookingFormsStore.record(_id).put(await _db,
        localData);

  }

  Future<void> deleteAllRows() async {
    await _bookingFormsStore.delete(await _db);
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

    await _temporaryBookingFormsStore.update(await _db, {
      Strings.formVersion: 1,
      Strings.jobRef: null,
      Strings.bfRequestedBy: null,
      Strings.bfJobTitle: null,
      Strings.bfJobContact: null,
      Strings.bfJobAuthorisingManager: null,
      Strings.bfJobDate: null,
      Strings.bfJobTime: null,
      Strings.bfTransportCoordinator: null,
      Strings.bfCollectionDateTime: null,
      Strings.bfCollectionAddress: null,
      Strings.bfCollectionPostcode: null,
      Strings.bfCollectionTel: null,
      Strings.bfDestinationAddress: null,
      Strings.bfDestinationPostcode: null,
      Strings.bfDestinationTel: null,
      Strings.bfInvoiceDetails: null,
      Strings.bfCostCode: null,
      Strings.bfPurchaseOrder: null,
      Strings.bfPatientName: null,
      Strings.bfLegalStatus: null,
      Strings.bfDateOfBirth: null,
      Strings.bfNhsNumber: null,
      Strings.bfGender: null,
      Strings.bfEthnicity: null,
      Strings.bfCovidStatus: null,
      Strings.bfRmn: null,
      Strings.bfRmn1: null,
      Strings.bfHca: null,
      Strings.bfHca1: null,
      Strings.bfHca2: null,
      Strings.bfHca3: null,
      Strings.bfHca4: null,
      Strings.bfHca5: null,
      Strings.bfCurrentPresentation: null,
      Strings.bfSpecificCarePlanYes: null,
      Strings.bfSpecificCarePlanNo: null,
      Strings.bfSpecificCarePlan: null,
      Strings.bfPatientWarningsYes: null,
      Strings.bfPatientWarningsNo: null,
      Strings.bfPatientWarnings: null,
      Strings.bfPresentingRisks: null,
      Strings.bfPreviousRisks: null,
      Strings.bfGenderConcernsYes: null,
      Strings.bfGenderConcernsNo: null,
      Strings.bfGenderConcerns: null,
      Strings.bfSafeguardingConcernsYes: null,
      Strings.bfSafeguardingConcernsNo: null,
      Strings.bfSafeguardingConcerns: null,
      Strings.bfAmbulanceRegistration: null,
      Strings.bfTimeDue: null,
      Strings.assignedUserId: null,
      Strings.assignedUserName: null,
    },
        finder: finder);
    notifyListeners();
  }

  Future<bool> validateBookingForm(String jobId, bool edit, bool saved, int savedId) async {

    bool success = true;

    //Map<String, dynamic> bookingForm = await _databaseHelper.getTemporaryBookingForm(edit, user.uid, jobId);
    Map<String, dynamic> bookingForm = await getTemporaryRecord(edit, jobId, saved, savedId);


    if(bookingForm[Strings.jobRef]== null || bookingForm[Strings.jobRef].toString().trim() == ''){
      success = false;
    }

    if(bookingForm[Strings.bfRequestedBy]== null || bookingForm[Strings.bfRequestedBy].toString().trim() == ''){
      success = false;
    }

    if(bookingForm[Strings.bfJobTitle]== null || bookingForm[Strings.bfJobTitle].toString().trim() == ''){
      success = false;
    }

    if(bookingForm[Strings.bfJobContact]== null || bookingForm[Strings.bfJobContact].toString().trim() == ''){
      success = false;
    }

    if(bookingForm[Strings.bfJobAuthorisingManager]== null || bookingForm[Strings.bfJobAuthorisingManager].toString().trim() == ''){
      success = false;
    }

    if(bookingForm[Strings.bfJobDate] == null){
      success = false;
    }

    if(bookingForm[Strings.bfJobTime] == null){
      success = false;
    }

    if(bookingForm[Strings.bfTransportCoordinator]== null || bookingForm[Strings.bfTransportCoordinator].toString().trim() == ''){
      success = false;
    }

    if(bookingForm[Strings.bfCollectionDateTime] == null){
      success = false;
    }

    if(bookingForm[Strings.bfCollectionAddress]== null || bookingForm[Strings.bfCollectionAddress].toString().trim() == ''){
      success = false;
    }

    if(bookingForm[Strings.bfDestinationAddress]== null || bookingForm[Strings.bfDestinationAddress].toString().trim() == ''){
      success = false;
    }

    if(bookingForm[Strings.bfCollectionPostcode]== null || bookingForm[Strings.bfCollectionPostcode].toString().trim() == ''){
      success = false;
    }

    if(bookingForm[Strings.bfDestinationPostcode]== null || bookingForm[Strings.bfDestinationPostcode].toString().trim() == ''){
      success = false;
    }

    if(bookingForm[Strings.bfCollectionTel]== null || bookingForm[Strings.bfCollectionTel].toString().trim() == ''){
      success = false;
    }

    if(bookingForm[Strings.bfPatientName]== null || bookingForm[Strings.bfPatientName].toString().trim() == ''){
      success = false;
    }

    if(bookingForm[Strings.bfLegalStatus]== null || bookingForm[Strings.bfLegalStatus].toString().trim() == ''){
      success = false;
    }

    if(bookingForm[Strings.bfDateOfBirth] == null){
      success = false;
    }

    if(bookingForm[Strings.bfNhsNumber]== null || bookingForm[Strings.bfNhsNumber].toString().trim() == ''){
      success = false;
    }

    if(bookingForm[Strings.bfCurrentPresentation]== null || bookingForm[Strings.bfCurrentPresentation].toString().trim() == ''){
      success = false;
    }

    if(bookingForm[Strings.bfGender]== null || bookingForm[Strings.bfGender].toString().trim() == ''){
      success = false;
    }

    if(bookingForm[Strings.bfEthnicity]== null || bookingForm[Strings.bfEthnicity].toString().trim() == ''){
      success = false;
    }

    if(bookingForm[Strings.bfCovidStatus]== null || bookingForm[Strings.bfCovidStatus].toString().trim() == ''){
      success = false;
    }




    if(bookingForm[Strings.bfSpecificCarePlanYes] == 1){
      if(bookingForm[Strings.bfSpecificCarePlan]== null || bookingForm[Strings.bfSpecificCarePlan].toString().trim() == ''){
        success = false;
      }

    }


    if(bookingForm[Strings.bfPatientWarningsYes] == 1){
      if(bookingForm[Strings.bfPatientWarnings]== null || bookingForm[Strings.bfPatientWarnings].toString().trim() == ''){
        success = false;
      }

    }

    if(bookingForm[Strings.bfPresentingRisks]== null || bookingForm[Strings.bfPresentingRisks].toString().trim() == ''){
      success = false;
    }

    if(bookingForm[Strings.bfPreviousRisks]== null || bookingForm[Strings.bfPreviousRisks].toString().trim() == ''){
      success = false;
    }

    if(bookingForm[Strings.bfGenderConcernsYes] == null && bookingForm[Strings.bfGenderConcernsNo] == null){
      success = false;
    }
    if(bookingForm[Strings.bfGenderConcernsYes] == 0 && bookingForm[Strings.bfGenderConcernsNo] == 0){
      success = false;
    }
    if(bookingForm[Strings.bfGenderConcernsYes] == null && bookingForm[Strings.bfGenderConcernsNo] == 0){
      success = false;
    }
    if(bookingForm[Strings.bfGenderConcernsYes] == 0 && bookingForm[Strings.bfGenderConcernsNo] == null){
      success = false;
    }


    if(bookingForm[Strings.bfGenderConcernsYes] == 1){
      if(bookingForm[Strings.bfGenderConcerns]== null || bookingForm[Strings.bfGenderConcerns].toString().trim() == ''){
        success = false;
      }

    }

    if(bookingForm[Strings.bfSafeguardingConcernsYes] == null && bookingForm[Strings.bfSafeguardingConcernsNo] == null){
      success = false;
    }
    if(bookingForm[Strings.bfSafeguardingConcernsYes] == 0 && bookingForm[Strings.bfSafeguardingConcernsNo] == 0){
      success = false;
    }
    if(bookingForm[Strings.bfSafeguardingConcernsYes] == null && bookingForm[Strings.bfSafeguardingConcernsNo] == 0){
      success = false;
    }
    if(bookingForm[Strings.bfSafeguardingConcernsYes] == 0 && bookingForm[Strings.bfSafeguardingConcernsNo] == null){
      success = false;
    }


    if(bookingForm[Strings.bfSafeguardingConcernsYes] == 1){
      if(bookingForm[Strings.bfSafeguardingConcerns]== null || bookingForm[Strings.bfSafeguardingConcerns].toString().trim() == ''){
        success = false;
      }

    }

    if(bookingForm[Strings.bfTimeDue] == null){
      success = false;
    }

    if(bookingForm[Strings.bfAmbulanceRegistration]== null || bookingForm[Strings.bfAmbulanceRegistration].toString().trim() == ''){
      success = false;
    }

    return success;

  }

  Future<bool> saveForLater(String jobId, bool saved, int savedId) async {

    GlobalFunctions.showLoadingDialog('Saving Transport Booking...');
    String message = '';
    bool success = false;
    int id;

    if(saved){
      id = savedId;
    } else {
      id = DateTime.now().millisecondsSinceEpoch + int.parse(random_string.randomNumeric(2));
    }



    Map<String, dynamic> bookingForm = await getTemporaryRecord(false, '1', saved, savedId);

    Map<String, dynamic> localData = {
      Strings.localId: id,
      Strings.documentId: null,
      Strings.uid: user.uid,
      Strings.jobId: '1',
      Strings.formVersion: '1',
      Strings.jobRef: bookingForm[Strings.jobRef],
      Strings.bfRequestedBy: bookingForm[Strings.bfRequestedBy],
      Strings.bfJobTitle: bookingForm[Strings.bfJobTitle],
      Strings.bfJobContact: bookingForm[Strings.bfJobContact],
      Strings.bfJobAuthorisingManager: bookingForm[Strings.bfJobAuthorisingManager],
      Strings.bfJobDate: bookingForm[Strings.bfJobDate],
      Strings.bfJobTime: bookingForm[Strings.bfJobTime],
      Strings.bfTransportCoordinator: bookingForm[Strings.bfTransportCoordinator],
      Strings.bfCollectionDateTime: bookingForm[Strings.bfCollectionDateTime],
      Strings.bfCollectionAddress: bookingForm[Strings.bfCollectionAddress],
      Strings.bfCollectionPostcode: bookingForm[Strings.bfCollectionPostcode],
      Strings.bfCollectionTel: bookingForm[Strings.bfCollectionTel],
      Strings.bfDestinationAddress: bookingForm[Strings.bfDestinationAddress],
      Strings.bfDestinationPostcode: bookingForm[Strings.bfDestinationPostcode],
      Strings.bfDestinationTel: bookingForm[Strings.bfDestinationTel],
      Strings.bfInvoiceDetails: bookingForm[Strings.bfInvoiceDetails],
      Strings.bfCostCode: bookingForm[Strings.bfCostCode],
      Strings.bfPurchaseOrder: bookingForm[Strings.bfPurchaseOrder],
      Strings.bfPatientName: bookingForm[Strings.bfPatientName],
      Strings.bfLegalStatus: bookingForm[Strings.bfLegalStatus],
      Strings.bfDateOfBirth: bookingForm[Strings.bfDateOfBirth],
      Strings.bfNhsNumber: bookingForm[Strings.bfNhsNumber],
      Strings.bfGender: bookingForm[Strings.bfGender],
      Strings.bfEthnicity: bookingForm[Strings.bfEthnicity],
      Strings.bfCovidStatus: bookingForm[Strings.bfCovidStatus],
      Strings.bfRmn: bookingForm[Strings.bfRmn],
      Strings.bfRmn1: bookingForm[Strings.bfRmn1],
      Strings.bfHca: bookingForm[Strings.bfHca],
      Strings.bfHca1: bookingForm[Strings.bfHca1],
      Strings.bfHca2: bookingForm[Strings.bfHca2],
      Strings.bfHca3: bookingForm[Strings.bfHca3],
      Strings.bfHca4: bookingForm[Strings.bfHca4],
      Strings.bfHca5: bookingForm[Strings.bfHca5],
      Strings.bfCurrentPresentation: bookingForm[Strings.bfCurrentPresentation],
      Strings.bfSpecificCarePlanYes: bookingForm[Strings.bfSpecificCarePlanYes],
      Strings.bfSpecificCarePlanNo: bookingForm[Strings.bfSpecificCarePlanNo],
      Strings.bfSpecificCarePlan: bookingForm[Strings.bfSpecificCarePlan],
      Strings.bfPatientWarningsYes: bookingForm[Strings.bfPatientWarningsYes],
      Strings.bfPatientWarningsNo: bookingForm[Strings.bfPatientWarningsNo],
      Strings.bfPatientWarnings: bookingForm[Strings.bfPatientWarnings],
      Strings.bfPresentingRisks: bookingForm[Strings.bfPresentingRisks],
      Strings.bfPreviousRisks: bookingForm[Strings.bfPreviousRisks],
      Strings.bfGenderConcernsYes: bookingForm[Strings.bfGenderConcernsYes],
      Strings.bfGenderConcernsNo: bookingForm[Strings.bfGenderConcernsNo],
      Strings.bfGenderConcerns: bookingForm[Strings.bfGenderConcerns],
      Strings.bfSafeguardingConcernsYes: bookingForm[Strings.bfSafeguardingConcernsYes],
      Strings.bfSafeguardingConcernsNo: bookingForm[Strings.bfSafeguardingConcernsNo],
      Strings.bfSafeguardingConcerns: bookingForm[Strings.bfSafeguardingConcerns],
      Strings.bfAmbulanceRegistration: bookingForm[Strings.bfAmbulanceRegistration],
      Strings.bfTimeDue: bookingForm[Strings.bfTimeDue],
      Strings.assignedUserId: bookingForm[Strings.assignedUserId],
      Strings.assignedUserName: bookingForm[Strings.assignedUserName],
    };

    await _savedBookingFormsStore.record(id).put(await _db,
        localData);

    message = 'Transport Booking saved to device';
    success = true;

    if(success) resetTemporaryRecord(jobId, false, 0);
    GlobalFunctions.dismissLoadingDialog();
    GlobalFunctions.showToast(message);
    return success;
  }

  Future<void> deleteSavedRecord(int id) async {
    await _savedBookingFormsStore.record(id).delete(await _db);
    _bookingForms.removeWhere((element) => element[Strings.localId] == id);
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

        _bookingForms = List.from(_fetchedRecordList.reversed);
      } else {
        message = 'No saved records available';
      }

    } catch(e){
      print(e);
      message = 'Something went wrong. Please try again';

    }
    _isLoading = false;
    notifyListeners();
    _selBookingFormId = null;
    if(message != '') GlobalFunctions.showToast(message);

  }


  Future<bool> submitBookingForm(String jobId, bool edit, bool saved, int savedId) async {

    GlobalFunctions.showLoadingDialog('Submitting Transport Booking...');
    String message = '';
    bool success = false;
    int id = DateTime.now().millisecondsSinceEpoch + int.parse(random_string.randomNumeric(2));

    //Sembast
    Map<String, dynamic> bookingForm = await getTemporaryRecord(false, jobId, saved, savedId);

    Map<String, dynamic> localData = {
      Strings.localId: id,
      Strings.documentId: null,
      Strings.uid: user.uid,
      Strings.jobId: '1',
      Strings.formVersion: '1',
      Strings.jobRef: bookingForm[Strings.jobRef],
      Strings.bfRequestedBy: bookingForm[Strings.bfRequestedBy],
      Strings.bfJobTitle: bookingForm[Strings.bfJobTitle],
      Strings.bfJobContact: bookingForm[Strings.bfJobContact],
      Strings.bfJobAuthorisingManager: bookingForm[Strings.bfJobAuthorisingManager],
      Strings.bfJobDate: bookingForm[Strings.bfJobDate],
      Strings.bfJobTime: bookingForm[Strings.bfJobTime],
      Strings.bfTransportCoordinator: bookingForm[Strings.bfTransportCoordinator],
      Strings.bfCollectionDateTime: bookingForm[Strings.bfCollectionDateTime],
      Strings.bfCollectionAddress: bookingForm[Strings.bfCollectionAddress],
      Strings.bfCollectionPostcode: bookingForm[Strings.bfCollectionPostcode],
      Strings.bfCollectionTel: bookingForm[Strings.bfCollectionTel],
      Strings.bfDestinationAddress: bookingForm[Strings.bfDestinationAddress],
      Strings.bfDestinationPostcode: bookingForm[Strings.bfDestinationPostcode],
      Strings.bfDestinationTel: bookingForm[Strings.bfDestinationTel],
      Strings.bfInvoiceDetails: bookingForm[Strings.bfInvoiceDetails],
      Strings.bfCostCode: bookingForm[Strings.bfCostCode],
      Strings.bfPurchaseOrder: bookingForm[Strings.bfPurchaseOrder],
      Strings.bfPatientName: bookingForm[Strings.bfPatientName],
      Strings.bfLegalStatus: bookingForm[Strings.bfLegalStatus],
      Strings.bfDateOfBirth: bookingForm[Strings.bfDateOfBirth],
      Strings.bfNhsNumber: bookingForm[Strings.bfNhsNumber],
      Strings.bfGender: bookingForm[Strings.bfGender],
      Strings.bfEthnicity: bookingForm[Strings.bfEthnicity],
      Strings.bfCovidStatus: bookingForm[Strings.bfCovidStatus],
      Strings.bfRmn: bookingForm[Strings.bfRmn],
      Strings.bfRmn1: bookingForm[Strings.bfRmn1],
      Strings.bfHca: bookingForm[Strings.bfHca],
      Strings.bfHca1: bookingForm[Strings.bfHca1],
      Strings.bfHca2: bookingForm[Strings.bfHca2],
      Strings.bfHca3: bookingForm[Strings.bfHca3],
      Strings.bfHca4: bookingForm[Strings.bfHca4],
      Strings.bfHca5: bookingForm[Strings.bfHca5],
      Strings.bfCurrentPresentation: bookingForm[Strings.bfCurrentPresentation],
      Strings.bfSpecificCarePlanYes: bookingForm[Strings.bfSpecificCarePlanYes],
      Strings.bfSpecificCarePlanNo: bookingForm[Strings.bfSpecificCarePlanNo],
      Strings.bfSpecificCarePlan: bookingForm[Strings.bfSpecificCarePlan],
      Strings.bfPatientWarningsYes: bookingForm[Strings.bfPatientWarningsYes],
      Strings.bfPatientWarningsNo: bookingForm[Strings.bfPatientWarningsNo],
      Strings.bfPatientWarnings: bookingForm[Strings.bfPatientWarnings],
      Strings.bfPresentingRisks: bookingForm[Strings.bfPresentingRisks],
      Strings.bfPreviousRisks: bookingForm[Strings.bfPreviousRisks],
      Strings.bfGenderConcernsYes: bookingForm[Strings.bfGenderConcernsYes],
      Strings.bfGenderConcernsNo: bookingForm[Strings.bfGenderConcernsNo],
      Strings.bfGenderConcerns: bookingForm[Strings.bfGenderConcerns],
      Strings.bfSafeguardingConcernsYes: bookingForm[Strings.bfSafeguardingConcernsYes],
      Strings.bfSafeguardingConcernsNo: bookingForm[Strings.bfSafeguardingConcernsNo],
      Strings.bfSafeguardingConcerns: bookingForm[Strings.bfSafeguardingConcerns],
      Strings.bfAmbulanceRegistration: bookingForm[Strings.bfAmbulanceRegistration],
      Strings.bfTimeDue: bookingForm[Strings.bfTimeDue],
      Strings.assignedUserId: bookingForm[Strings.assignedUserId],
      Strings.assignedUserName: bookingForm[Strings.assignedUserName],
      Strings.pendingTime: DateTime.now().toIso8601String(),
      Strings.serverUploaded: 0,
    };

    //Sembast
    await _bookingFormsStore.record(id).put(await _db, localData);

    message = 'Transport Booking has successfully been added to local database';
    bool hasDataConnection = await GlobalFunctions.hasDataConnection();

    if(hasDataConnection){

      bool isTokenExpired = GlobalFunctions.isTokenExpired();
      bool authenticated = true;

      if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

      if(authenticated){

        try {

          await FirebaseFirestore.instance.collection('booking_forms').add({
            Strings.uid: user.uid,
            Strings.jobId: '1',
            Strings.formVersion: '1',
            Strings.jobRef: GlobalFunctions.databaseValueString(bookingForm[Strings.jobRef]),
            Strings.jobRefLowercase: GlobalFunctions.databaseValueString(bookingForm[Strings.jobRef]).toLowerCase(),
            Strings.bfRequestedBy: bookingForm[Strings.bfRequestedBy],
            Strings.bfJobTitle: bookingForm[Strings.bfJobTitle],
            Strings.bfJobContact: bookingForm[Strings.bfJobContact],
            Strings.bfJobAuthorisingManager: bookingForm[Strings.bfJobAuthorisingManager],
            Strings.bfJobDate: bookingForm[Strings.bfJobDate] == null ? null : DateTime.parse(bookingForm[Strings.bfJobDate]),
            Strings.bfJobTime: bookingForm[Strings.bfJobTime],
            Strings.bfTransportCoordinator: bookingForm[Strings.bfTransportCoordinator],
            Strings.bfCollectionDateTime: bookingForm[Strings.bfCollectionDateTime],
            Strings.bfCollectionAddress: bookingForm[Strings.bfCollectionAddress],
            Strings.bfCollectionPostcode: bookingForm[Strings.bfCollectionPostcode],
            Strings.bfCollectionTel: bookingForm[Strings.bfCollectionTel],
            Strings.bfDestinationAddress: bookingForm[Strings.bfDestinationAddress],
            Strings.bfDestinationPostcode: bookingForm[Strings.bfDestinationPostcode],
            Strings.bfDestinationTel: bookingForm[Strings.bfDestinationTel],
            Strings.bfInvoiceDetails: bookingForm[Strings.bfInvoiceDetails],
            Strings.bfCostCode: bookingForm[Strings.bfCostCode],
            Strings.bfPurchaseOrder: bookingForm[Strings.bfPurchaseOrder],
            Strings.bfPatientName: bookingForm[Strings.bfPatientName],
            Strings.bfLegalStatus: bookingForm[Strings.bfLegalStatus],
            Strings.bfDateOfBirth: bookingForm[Strings.bfDateOfBirth],
            Strings.bfNhsNumber: bookingForm[Strings.bfNhsNumber],
            Strings.bfGender: bookingForm[Strings.bfGender],
            Strings.bfEthnicity: bookingForm[Strings.bfEthnicity],
            Strings.bfCovidStatus: bookingForm[Strings.bfCovidStatus],
            Strings.bfRmn: bookingForm[Strings.bfRmn],
            Strings.bfRmn1: bookingForm[Strings.bfRmn1],
            Strings.bfHca: bookingForm[Strings.bfHca],
            Strings.bfHca1: bookingForm[Strings.bfHca1],
            Strings.bfHca2: bookingForm[Strings.bfHca2],
            Strings.bfHca3: bookingForm[Strings.bfHca3],
            Strings.bfHca4: bookingForm[Strings.bfHca4],
            Strings.bfHca5: bookingForm[Strings.bfHca5],
            Strings.bfCurrentPresentation: bookingForm[Strings.bfCurrentPresentation],
            Strings.bfSpecificCarePlanYes: bookingForm[Strings.bfSpecificCarePlanYes],
            Strings.bfSpecificCarePlanNo: bookingForm[Strings.bfSpecificCarePlanNo],
            Strings.bfSpecificCarePlan: bookingForm[Strings.bfSpecificCarePlan],
            Strings.bfPatientWarningsYes: bookingForm[Strings.bfPatientWarningsYes],
            Strings.bfPatientWarningsNo: bookingForm[Strings.bfPatientWarningsNo],
            Strings.bfPatientWarnings: bookingForm[Strings.bfPatientWarnings],
            Strings.bfPresentingRisks: bookingForm[Strings.bfPresentingRisks],
            Strings.bfPreviousRisks: bookingForm[Strings.bfPreviousRisks],
            Strings.bfGenderConcernsYes: bookingForm[Strings.bfGenderConcernsYes],
            Strings.bfGenderConcernsNo: bookingForm[Strings.bfGenderConcernsNo],
            Strings.bfGenderConcerns: bookingForm[Strings.bfGenderConcerns],
            Strings.bfSafeguardingConcernsYes: bookingForm[Strings.bfSafeguardingConcernsYes],
            Strings.bfSafeguardingConcernsNo: bookingForm[Strings.bfSafeguardingConcernsNo],
            Strings.bfSafeguardingConcerns: bookingForm[Strings.bfSafeguardingConcerns],
            Strings.bfAmbulanceRegistration: bookingForm[Strings.bfAmbulanceRegistration],
            Strings.bfTimeDue: bookingForm[Strings.bfTimeDue],
            Strings.assignedUserId: bookingForm[Strings.assignedUserId],
            Strings.assignedUserName: bookingForm[Strings.assignedUserName],
            Strings.timestamp: FieldValue.serverTimestamp(),
            Strings.serverUploaded: 1,
          });

          //Sembast
          await _bookingFormsStore.record(id).delete(await _db);
          if(saved){
            deleteSavedRecord(savedId);
          }
          message = 'Transport Booking uploaded successfully';
          success = true;


        } on TimeoutException catch (_) {
          // A timeout occurred.
          message = 'Network Timeout communicating with the server, unable to upload Transport Booking';

        } catch (e) {
          print(e);
          message = e.toString();

          print(e);
        }
      }

    } else {

      message = 'No data connection, Transport Booking has been saved locally, please upload when you have a valid connection';
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

  Future<bool> editBookingForm(String jobId, [bool edit = false]) async {

    GlobalFunctions.showLoadingDialog('Editing Transport Booking...');
    String message = '';
    bool success = false;

    //Map<String, dynamic> bookingForm = await _databaseHelper.getTemporaryBookingForm(true, user.uid, jobId);
    Map<String, dynamic> bookingForm = await getTemporaryRecord(true, jobId, false, 0);


    bool hasDataConnection = await GlobalFunctions.hasDataConnection();


    if(hasDataConnection){

      bool isTokenExpired = GlobalFunctions.isTokenExpired();
      bool authenticated = true;

      if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

      if(authenticated){


        try {

          await FirebaseFirestore.instance.collection('booking_forms').doc(bookingForm[Strings.documentId]).update({
            Strings.jobId: '1',
            Strings.formVersion: '1',
            Strings.jobRef: GlobalFunctions.databaseValueString(bookingForm[Strings.jobRef]),
            Strings.jobRefLowercase: GlobalFunctions.databaseValueString(bookingForm[Strings.jobRef]).toLowerCase(),
            Strings.bfRequestedBy: bookingForm[Strings.bfRequestedBy],
            Strings.bfJobTitle: bookingForm[Strings.bfJobTitle],
            Strings.bfJobContact: bookingForm[Strings.bfJobContact],
            Strings.bfJobAuthorisingManager: bookingForm[Strings.bfJobAuthorisingManager],
            Strings.bfJobDate: bookingForm[Strings.bfJobDate] == null ? null : DateTime.parse(bookingForm[Strings.bfJobDate]),
            Strings.bfJobTime: bookingForm[Strings.bfJobTime],
            Strings.bfTransportCoordinator: bookingForm[Strings.bfTransportCoordinator],
            Strings.bfCollectionDateTime: bookingForm[Strings.bfCollectionDateTime],
            Strings.bfCollectionAddress: bookingForm[Strings.bfCollectionAddress],
            Strings.bfCollectionPostcode: bookingForm[Strings.bfCollectionPostcode],
            Strings.bfCollectionTel: bookingForm[Strings.bfCollectionTel],
            Strings.bfDestinationAddress: bookingForm[Strings.bfDestinationAddress],
            Strings.bfDestinationPostcode: bookingForm[Strings.bfDestinationPostcode],
            Strings.bfDestinationTel: bookingForm[Strings.bfDestinationTel],
            Strings.bfInvoiceDetails: bookingForm[Strings.bfInvoiceDetails],
            Strings.bfCostCode: bookingForm[Strings.bfCostCode],
            Strings.bfPurchaseOrder: bookingForm[Strings.bfPurchaseOrder],
            Strings.bfPatientName: bookingForm[Strings.bfPatientName],
            Strings.bfLegalStatus: bookingForm[Strings.bfLegalStatus],
            Strings.bfDateOfBirth: bookingForm[Strings.bfDateOfBirth],
            Strings.bfNhsNumber: bookingForm[Strings.bfNhsNumber],
            Strings.bfGender: bookingForm[Strings.bfGender],
            Strings.bfEthnicity: bookingForm[Strings.bfEthnicity],
            Strings.bfCovidStatus: bookingForm[Strings.bfCovidStatus],
            Strings.bfRmn: bookingForm[Strings.bfRmn],
            Strings.bfRmn1: bookingForm[Strings.bfRmn1],
            Strings.bfHca: bookingForm[Strings.bfHca],
            Strings.bfHca1: bookingForm[Strings.bfHca1],
            Strings.bfHca2: bookingForm[Strings.bfHca2],
            Strings.bfHca3: bookingForm[Strings.bfHca3],
            Strings.bfHca4: bookingForm[Strings.bfHca4],
            Strings.bfHca5: bookingForm[Strings.bfHca5],
            Strings.bfCurrentPresentation: bookingForm[Strings.bfCurrentPresentation],
            Strings.bfSpecificCarePlanYes: bookingForm[Strings.bfSpecificCarePlanYes],
            Strings.bfSpecificCarePlanNo: bookingForm[Strings.bfSpecificCarePlanNo],
            Strings.bfSpecificCarePlan: bookingForm[Strings.bfSpecificCarePlan],
            Strings.bfPatientWarningsYes: bookingForm[Strings.bfPatientWarningsYes],
            Strings.bfPatientWarningsNo: bookingForm[Strings.bfPatientWarningsNo],
            Strings.bfPatientWarnings: bookingForm[Strings.bfPatientWarnings],
            Strings.bfPresentingRisks: bookingForm[Strings.bfPresentingRisks],
            Strings.bfPreviousRisks: bookingForm[Strings.bfPreviousRisks],
            Strings.bfGenderConcernsYes: bookingForm[Strings.bfGenderConcernsYes],
            Strings.bfGenderConcernsNo: bookingForm[Strings.bfGenderConcernsNo],
            Strings.bfGenderConcerns: bookingForm[Strings.bfGenderConcerns],
            Strings.bfSafeguardingConcernsYes: bookingForm[Strings.bfSafeguardingConcernsYes],
            Strings.bfSafeguardingConcernsNo: bookingForm[Strings.bfSafeguardingConcernsNo],
            Strings.bfSafeguardingConcerns: bookingForm[Strings.bfSafeguardingConcerns],
            Strings.bfAmbulanceRegistration: bookingForm[Strings.bfAmbulanceRegistration],
            Strings.bfTimeDue: bookingForm[Strings.bfTimeDue],
            Strings.assignedUserId: bookingForm[Strings.assignedUserId],
            Strings.assignedUserName: bookingForm[Strings.assignedUserName],
            Strings.serverUploaded: 1,
          });

          //Sembast

          final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
              [Db.Filter.equals(Strings.documentId, selectedBookingForm[Strings.documentId]), Db.Filter.equals(Strings.jobId, jobId)]
          ));

          await _editedBookingFormsStore.delete(await _db,
              finder: finder);
          message = 'Transport Booking uploaded successfully';
          success = true;
          getBookingForms();
        } on TimeoutException catch (_) {
          // A timeout occurred.
          message = 'Network Timeout communicating with the server, unable to edit Transport Booking';
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
      //deleteEditedBookingForm();
      deleteEditedRecord();
    }
    GlobalFunctions.showToast(message);
    return success;


  }

  Future<void> getBookingForms() async{

    _isLoading = true;
    notifyListeners();
    String message = '';
    List<Map<String, dynamic>> _fetchedBookingFormList = [];
    try {

      bool hasDataConnection = await GlobalFunctions.hasDataConnection();

      if(!hasDataConnection){

        GlobalFunctions.showToast('No data connection, unable to fetch Transport Bookings');
        _bookingForms = [];

      } else {


        bool isTokenExpired = GlobalFunctions.isTokenExpired();
        bool authenticated = true;

        if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

        if(authenticated){


          QuerySnapshot snapshot;

          if(user.role == 'Super User'){
            try{
              snapshot = await FirebaseFirestore.instance.collection('booking_forms').orderBy('timestamp', descending: true).limit(10).get().timeout(Duration(seconds: 90));
            } catch(e){
              print(e);
            }
          } else {
            try{
              snapshot = await FirebaseFirestore.instance.collection('booking_forms').where(
                  'uid', isEqualTo: user.uid).orderBy('timestamp', descending: true).limit(10).get().timeout(Duration(seconds: 90));
            } catch(e){
              print(e);
            }
          }

          Map<String, dynamic> snapshotData = {};

          if(snapshot.docs.length < 1){
            message = 'No Transport Bookings found';
          } else {
            for (DocumentSnapshot snap in snapshot.docs) {

              snapshotData = snap.data();

              final Map<String, dynamic> bookingForm = onlineBookingForm(snapshotData, snap.id);

              _fetchedBookingFormList.add(bookingForm);

            }

            _bookingForms = _fetchedBookingFormList;
          }


        }

      }


    } on TimeoutException catch (_) {
      // A timeout occurred.
      message = 'Network Timeout communicating with the server, unable to fetch latest Transport Bookings';
    } catch(e){
      print(e);
      message = 'Something went wrong. Please try again';

    }

    _isLoading = false;
    notifyListeners();
    _selBookingFormId = null;
    if(message != '') GlobalFunctions.showToast(message);

  }

  Future<void> getMoreBookingForms() async{

    String message = '';

    List<Map<String, dynamic>> _fetchedBookingFormList = [];

    try {

      bool hasDataConnection = await GlobalFunctions.hasDataConnection();

      if(!hasDataConnection){

        GlobalFunctions.showToast('No data connection, unable to fetch Transport Bookings');


      } else {


        bool isTokenExpired = GlobalFunctions.isTokenExpired();
        bool authenticated = true;

        if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

        if(authenticated){


          QuerySnapshot snapshot;
          int currentLength = _bookingForms.length;
          DateTime latestDate = DateTime.parse(_bookingForms[currentLength - 1][Strings.timestamp]);

          if(user.role == 'Super User'){
            try {
              snapshot = await FirebaseFirestore.instance.collection('booking_forms').orderBy(
                  'timestamp', descending: true).startAfter(
                  [Timestamp.fromDate(latestDate)]).limit(10)
                  .get()
                  .timeout(Duration(seconds: 90));
            } catch(e) {
              print(e);
            }

          } else {
            try {
              snapshot = await FirebaseFirestore.instance.collection('booking_forms').where(
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
            message = 'No more Transport Bookings found';
          } else {
            for (DocumentSnapshot snap in snapshot.docs) {

              snapshotData = snap.data();

              final Map<String, dynamic> bookingForm = onlineBookingForm(snapshotData, snap.id);

              _fetchedBookingFormList.add(bookingForm);

            }

            _bookingForms.addAll(_fetchedBookingFormList);
          }


        }

      }


    } on TimeoutException catch (_) {
      // A timeout occurred.
      message = 'Network Timeout communicating with the server, unable to fetch latest Transport Bookings';
    } catch(e){
      print(e);
      message = 'Something went wrong. Please try again';

    }

    _isLoading = false;
    notifyListeners();
    _selBookingFormId = null;
    if(message != '') GlobalFunctions.showToast(message);

  }

  Future<bool> searchBookingForms(DateTime dateFrom, DateTime dateTo, String jobRef, String selectedUser) async{

    _isLoading = true;
    notifyListeners();
    bool success = false;
    String message = '';
    GlobalFunctions.showLoadingDialog('Searching Forms');
    List<Map<String, dynamic>> _fetchedBookingFormList = [];

    try {

      bool hasDataConnection = await GlobalFunctions.hasDataConnection();

      if(!hasDataConnection){

        message = 'No Data Connection, unable to search Transport Bookings';

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
                    await FirebaseFirestore.instance.collection('booking_forms')
                        .where(Strings.uid, isEqualTo: selectedUser).orderBy('timestamp', descending: true)
                        .startAt([dateTo]).endAt([dateFrom]).get()
                        .timeout(Duration(seconds: 90));
                  } catch(e){
                    print(e);
                  }
                } else {
                  try{
                    snapshot =
                    await FirebaseFirestore.instance.collection('booking_forms').orderBy('timestamp', descending: true)
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
                    await FirebaseFirestore.instance.collection('booking_forms').where(Strings.uid, isEqualTo: selectedUser).
                    where(Strings.jobRefLowercase, isEqualTo: jobRef.toLowerCase()).orderBy('timestamp', descending: true)
                        .startAt([dateTo]).endAt([dateFrom]).get()
                        .timeout(Duration(seconds: 90));
                  } catch(e){
                    print(e);
                  }
                } else {
                  try{
                    snapshot =
                    await FirebaseFirestore.instance.collection('booking_forms')
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
                    await FirebaseFirestore.instance.collection('booking_forms')
                        .where(Strings.uid, isEqualTo: selectedUser).orderBy('timestamp', descending: true)
                        .get()
                        .timeout(Duration(seconds: 90));
                  } catch(e){
                    print(e);
                  }
                } else {
                  try{
                    snapshot =
                    await FirebaseFirestore.instance.collection('booking_forms').orderBy('timestamp', descending: true)
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
                    await FirebaseFirestore.instance.collection('booking_forms')
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
                    await FirebaseFirestore.instance.collection('booking_forms')
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
                  await FirebaseFirestore.instance.collection('booking_forms')
                      .where(Strings.uid, isEqualTo: user.uid).orderBy('timestamp', descending: true)
                      .startAt([dateTo]).endAt([dateFrom]).get()
                      .timeout(Duration(seconds: 90));
                } catch(e){
                  print(e);
                }


              } else {


                try{
                  snapshot =
                  await FirebaseFirestore.instance.collection('booking_forms')
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
                  await FirebaseFirestore.instance.collection('booking_forms')
                      .where(Strings.uid, isEqualTo: user.uid).orderBy('timestamp', descending: true)
                      .get()
                      .timeout(Duration(seconds: 90));
                } catch(e){
                  print(e);
                }


              } else {

                try{
                  snapshot =
                  await FirebaseFirestore.instance.collection('booking_forms')
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
            message = 'No Transport Bookings found';
          } else {
            for (DocumentSnapshot snap in snapshot.docs) {

              snapshotData = snap.data();

              final Map<String, dynamic> bookingForm = onlineBookingForm(snapshotData, snap.id);

              _fetchedBookingFormList.add(bookingForm);

            }

            _bookingForms = _fetchedBookingFormList;
            success = true;
          }


        }

      }


    } on TimeoutException catch (_) {
      // A timeout occurred.
      message = 'Network Timeout communicating with the server, unable to search Transport Bookings';
    } catch(e){
      print(e);
      message = 'Something went wrong. Please try again';

    }

    _isLoading = false;
    notifyListeners();
    _selBookingFormId = null;
    GlobalFunctions.dismissLoadingDialog();
    if(message != '') GlobalFunctions.showToast(message);
    return success;

  }

  Future<bool> searchMoreBookingForms(DateTime dateFrom, DateTime dateTo) async{

    _isLoading = true;
    notifyListeners();
    bool success = false;
    String message = '';
    GlobalFunctions.showLoadingDialog('Searching Forms');
    List<Map<String, dynamic>> _fetchedBookingFormList = [];

    try {

      bool hasDataConnection = await GlobalFunctions.hasDataConnection();

      if(!hasDataConnection){

        message = 'No Data Connection, unable to search Transport Bookings';

      } else {


        bool isTokenExpired = GlobalFunctions.isTokenExpired();
        bool authenticated = true;

        if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

        if(authenticated){


          QuerySnapshot snapshot;
          int currentLength = _bookingForms.length;
          DateTime latestDate = DateTime.parse(_bookingForms[currentLength - 1]['timestamp']);

          if(user.role == 'Super User'){
            try{
              snapshot =
              await FirebaseFirestore.instance.collection('booking_forms').orderBy('timestamp', descending: true)
                  .startAfter([Timestamp.fromDate(latestDate)]).endAt([dateFrom]).limit(10).get()
                  .timeout(Duration(seconds: 90));
            } catch(e){
              print(e);
            }

          } else {

            try{
              snapshot =
              await FirebaseFirestore.instance.collection('booking_forms').where('uid', isEqualTo: user.uid).orderBy('timestamp', descending: true)
                  .startAfter([Timestamp.fromDate(latestDate)]).endAt([dateFrom]).limit(10).get()
                  .timeout(Duration(seconds: 90));
            } catch(e){
              print(e);
            }

          }

          Map<String, dynamic> snapshotData = {};

          if(snapshot.docs.length < 1){
            message = 'No Transport Bookings found';
          } else {
            for (DocumentSnapshot snap in snapshot.docs) {

              snapshotData = snap.data();

              final Map<String, dynamic> bookingForm = onlineBookingForm(snapshotData, snap.id);

              _fetchedBookingFormList.add(bookingForm);

            }

            _bookingForms.addAll(_fetchedBookingFormList);
            success = true;
          }


        }

      }


    } on TimeoutException catch (_) {
      // A timeout occurred.
      message = 'Network Timeout communicating with the server, unable to search Transport Bookings';
    } catch(e){
      print(e);
      message = 'Something went wrong. Please try again';

    }

    _isLoading = false;
    notifyListeners();
    _selBookingFormId = null;
    GlobalFunctions.dismissLoadingDialog();
    if(message != '') GlobalFunctions.showToast(message);
    return success;

  }

  Map<String, dynamic> localBookingForm(Map<String, dynamic> localRecord){
    return {
      Strings.documentId: GlobalFunctions.databaseValueString(localRecord[Strings.documentId]),
      Strings.uid: GlobalFunctions.databaseValueString(localRecord[Strings.uid]),
      Strings.jobId: localRecord[Strings.jobId],
      Strings.formVersion: localRecord[Strings.formVersion],
      Strings.jobRef: localRecord[Strings.jobRef],
      Strings.bfRequestedBy: localRecord[Strings.bfRequestedBy],
      Strings.bfJobTitle: localRecord[Strings.bfJobTitle],
      Strings.bfJobContact: localRecord[Strings.bfJobContact],
      Strings.bfJobAuthorisingManager: localRecord[Strings.bfJobAuthorisingManager],
      Strings.bfJobDate: localRecord[Strings.bfJobDate],
      Strings.bfJobTime: localRecord[Strings.bfJobTime],
      Strings.bfTransportCoordinator: localRecord[Strings.bfTransportCoordinator],
      Strings.bfCollectionDateTime: localRecord[Strings.bfCollectionDateTime],
      Strings.bfCollectionAddress: localRecord[Strings.bfCollectionAddress],
      Strings.bfCollectionPostcode: localRecord[Strings.bfCollectionPostcode],
      Strings.bfCollectionTel: localRecord[Strings.bfCollectionTel],
      Strings.bfDestinationAddress: localRecord[Strings.bfDestinationAddress],
      Strings.bfDestinationPostcode: localRecord[Strings.bfDestinationPostcode],
      Strings.bfDestinationTel: localRecord[Strings.bfDestinationTel],
      Strings.bfInvoiceDetails: localRecord[Strings.bfInvoiceDetails],
      Strings.bfCostCode: localRecord[Strings.bfCostCode],
      Strings.bfPurchaseOrder: localRecord[Strings.bfPurchaseOrder],
      Strings.bfPatientName: localRecord[Strings.bfPatientName],
      Strings.bfLegalStatus: localRecord[Strings.bfLegalStatus],
      Strings.bfDateOfBirth: localRecord[Strings.bfDateOfBirth],
      Strings.bfNhsNumber: localRecord[Strings.bfNhsNumber],
      Strings.bfGender: localRecord[Strings.bfGender],
      Strings.bfEthnicity: localRecord[Strings.bfEthnicity],
      Strings.bfCovidStatus: localRecord[Strings.bfCovidStatus],
      Strings.bfRmn: localRecord[Strings.bfRmn],
      Strings.bfRmn1: localRecord[Strings.bfRmn1],
      Strings.bfHca: localRecord[Strings.bfHca],
      Strings.bfHca1: localRecord[Strings.bfHca1],
      Strings.bfHca2: localRecord[Strings.bfHca2],
      Strings.bfHca3: localRecord[Strings.bfHca3],
      Strings.bfHca4: localRecord[Strings.bfHca4],
      Strings.bfHca5: localRecord[Strings.bfHca5],
      Strings.bfCurrentPresentation: localRecord[Strings.bfCurrentPresentation],
      Strings.bfSpecificCarePlanYes: localRecord[Strings.bfSpecificCarePlanYes],
      Strings.bfSpecificCarePlanNo: localRecord[Strings.bfSpecificCarePlanNo],
      Strings.bfSpecificCarePlan: localRecord[Strings.bfSpecificCarePlan],
      Strings.bfPatientWarningsYes: localRecord[Strings.bfPatientWarningsYes],
      Strings.bfPatientWarningsNo: localRecord[Strings.bfPatientWarningsNo],
      Strings.bfPatientWarnings: localRecord[Strings.bfPatientWarnings],
      Strings.bfPresentingRisks: localRecord[Strings.bfPresentingRisks],
      Strings.bfPreviousRisks: localRecord[Strings.bfPreviousRisks],
      Strings.bfGenderConcernsYes: localRecord[Strings.bfGenderConcernsYes],
      Strings.bfGenderConcernsNo: localRecord[Strings.bfGenderConcernsNo],
      Strings.bfGenderConcerns: localRecord[Strings.bfGenderConcerns],
      Strings.bfSafeguardingConcernsYes: localRecord[Strings.bfSafeguardingConcernsYes],
      Strings.bfSafeguardingConcernsNo: localRecord[Strings.bfSafeguardingConcernsNo],
      Strings.bfSafeguardingConcerns: localRecord[Strings.bfSafeguardingConcerns],
      Strings.bfAmbulanceRegistration: localRecord[Strings.bfAmbulanceRegistration],
      Strings.bfTimeDue: localRecord[Strings.bfTimeDue],
      Strings.assignedUserId: localRecord[Strings.assignedUserId],
      Strings.assignedUserName: localRecord[Strings.assignedUserName],
      Strings.serverUploaded: localRecord[Strings.serverUploaded],
      Strings.timestamp: localRecord[Strings.timestamp] == null ? null : localRecord[Strings.timestamp]
    };
  }

  Map<String, dynamic> onlineBookingForm(Map<String, dynamic> localRecord, String docId){
    return {
      Strings.documentId: docId,
      Strings.uid: GlobalFunctions.databaseValueString(localRecord[Strings.uid]),
      Strings.jobId: localRecord[Strings.jobId],
      Strings.formVersion: localRecord[Strings.formVersion],
      Strings.jobRef: localRecord[Strings.jobRef],
      Strings.bfRequestedBy: localRecord[Strings.bfRequestedBy],
      Strings.bfJobTitle: localRecord[Strings.bfJobTitle],
      Strings.bfJobContact: localRecord[Strings.bfJobContact],
      Strings.bfJobAuthorisingManager: localRecord[Strings.bfJobAuthorisingManager],
      Strings.bfJobDate: localRecord[Strings.bfJobDate] == null ? null : DateTime
          .fromMillisecondsSinceEpoch(
          localRecord[Strings.bfJobDate].millisecondsSinceEpoch)
          .toIso8601String(),
      Strings.bfJobTime: localRecord[Strings.bfJobTime],
      Strings.bfTransportCoordinator: localRecord[Strings.bfTransportCoordinator],
      Strings.bfCollectionDateTime: localRecord[Strings.bfCollectionDateTime],
      Strings.bfCollectionAddress: localRecord[Strings.bfCollectionAddress],
      Strings.bfCollectionPostcode: localRecord[Strings.bfCollectionPostcode],
      Strings.bfCollectionTel: localRecord[Strings.bfCollectionTel],
      Strings.bfDestinationAddress: localRecord[Strings.bfDestinationAddress],
      Strings.bfDestinationPostcode: localRecord[Strings.bfDestinationPostcode],
      Strings.bfDestinationTel: localRecord[Strings.bfDestinationTel],
      Strings.bfInvoiceDetails: localRecord[Strings.bfInvoiceDetails],
      Strings.bfCostCode: localRecord[Strings.bfCostCode],
      Strings.bfPurchaseOrder: localRecord[Strings.bfPurchaseOrder],
      Strings.bfPatientName: localRecord[Strings.bfPatientName],
      Strings.bfLegalStatus: localRecord[Strings.bfLegalStatus],
      Strings.bfDateOfBirth: localRecord[Strings.bfDateOfBirth],
      Strings.bfNhsNumber: localRecord[Strings.bfNhsNumber],
      Strings.bfGender: localRecord[Strings.bfGender],
      Strings.bfEthnicity: localRecord[Strings.bfEthnicity],
      Strings.bfCovidStatus: localRecord[Strings.bfCovidStatus],
      Strings.bfRmn: localRecord[Strings.bfRmn],
      Strings.bfRmn1: localRecord[Strings.bfRmn1],
      Strings.bfHca: localRecord[Strings.bfHca],
      Strings.bfHca1: localRecord[Strings.bfHca1],
      Strings.bfHca2: localRecord[Strings.bfHca2],
      Strings.bfHca3: localRecord[Strings.bfHca3],
      Strings.bfHca4: localRecord[Strings.bfHca4],
      Strings.bfHca5: localRecord[Strings.bfHca5],
      Strings.bfCurrentPresentation: localRecord[Strings.bfCurrentPresentation],
      Strings.bfSpecificCarePlanYes: localRecord[Strings.bfSpecificCarePlanYes],
      Strings.bfSpecificCarePlanNo: localRecord[Strings.bfSpecificCarePlanNo],
      Strings.bfSpecificCarePlan: localRecord[Strings.bfSpecificCarePlan],
      Strings.bfPatientWarningsYes: localRecord[Strings.bfPatientWarningsYes],
      Strings.bfPatientWarningsNo: localRecord[Strings.bfPatientWarningsNo],
      Strings.bfPatientWarnings: localRecord[Strings.bfPatientWarnings],
      Strings.bfPresentingRisks: localRecord[Strings.bfPresentingRisks],
      Strings.bfPreviousRisks: localRecord[Strings.bfPreviousRisks],
      Strings.bfGenderConcernsYes: localRecord[Strings.bfGenderConcernsYes],
      Strings.bfGenderConcernsNo: localRecord[Strings.bfGenderConcernsNo],
      Strings.bfGenderConcerns: localRecord[Strings.bfGenderConcerns],
      Strings.bfSafeguardingConcernsYes: localRecord[Strings.bfSafeguardingConcernsYes],
      Strings.bfSafeguardingConcernsNo: localRecord[Strings.bfSafeguardingConcernsNo],
      Strings.bfSafeguardingConcerns: localRecord[Strings.bfSafeguardingConcerns],
      Strings.bfAmbulanceRegistration: localRecord[Strings.bfAmbulanceRegistration],
      Strings.bfTimeDue: localRecord[Strings.bfTimeDue],
      Strings.assignedUserId: localRecord[Strings.assignedUserId],
      Strings.assignedUserName: localRecord[Strings.assignedUserName],
      Strings.serverUploaded: localRecord[Strings.serverUploaded],
      Strings.timestamp: localRecord[Strings.timestamp] == null ? null : DateTime
          .fromMillisecondsSinceEpoch(
          localRecord['timestamp'].millisecondsSinceEpoch)
          .toIso8601String()
    };
  }

  Map<String, dynamic> editedBookingForm(Map<String, dynamic> localRecord){
    return {
      Strings.documentId: GlobalFunctions.databaseValueString(localRecord[Strings.documentId]),
      Strings.uid: GlobalFunctions.databaseValueString(localRecord[Strings.uid]),
      Strings.jobId: localRecord[Strings.jobId],
      Strings.formVersion: localRecord[Strings.formVersion],
      Strings.jobRef: localRecord[Strings.jobRef],
      Strings.bfRequestedBy: localRecord[Strings.bfRequestedBy],
      Strings.bfJobTitle: localRecord[Strings.bfJobTitle],
      Strings.bfJobContact: localRecord[Strings.bfJobContact],
      Strings.bfJobAuthorisingManager: localRecord[Strings.bfJobAuthorisingManager],
      Strings.bfJobDate: localRecord[Strings.bfJobDate],
      Strings.bfJobTime: localRecord[Strings.bfJobTime],
      Strings.bfTransportCoordinator: localRecord[Strings.bfTransportCoordinator],
      Strings.bfCollectionDateTime: localRecord[Strings.bfCollectionDateTime],
      Strings.bfCollectionAddress: localRecord[Strings.bfCollectionAddress],
      Strings.bfCollectionPostcode: localRecord[Strings.bfCollectionPostcode],
      Strings.bfCollectionTel: localRecord[Strings.bfCollectionTel],
      Strings.bfDestinationAddress: localRecord[Strings.bfDestinationAddress],
      Strings.bfDestinationPostcode: localRecord[Strings.bfDestinationPostcode],
      Strings.bfDestinationTel: localRecord[Strings.bfDestinationTel],
      Strings.bfInvoiceDetails: localRecord[Strings.bfInvoiceDetails],
      Strings.bfCostCode: localRecord[Strings.bfCostCode],
      Strings.bfPurchaseOrder: localRecord[Strings.bfPurchaseOrder],
      Strings.bfPatientName: localRecord[Strings.bfPatientName],
      Strings.bfLegalStatus: localRecord[Strings.bfLegalStatus],
      Strings.bfDateOfBirth: localRecord[Strings.bfDateOfBirth],
      Strings.bfNhsNumber: localRecord[Strings.bfNhsNumber],
      Strings.bfGender: localRecord[Strings.bfGender],
      Strings.bfEthnicity: localRecord[Strings.bfEthnicity],
      Strings.bfCovidStatus: localRecord[Strings.bfCovidStatus],
      Strings.bfRmn: localRecord[Strings.bfRmn],
      Strings.bfRmn1: localRecord[Strings.bfRmn1],
      Strings.bfHca: localRecord[Strings.bfHca],
      Strings.bfHca1: localRecord[Strings.bfHca1],
      Strings.bfHca2: localRecord[Strings.bfHca2],
      Strings.bfHca3: localRecord[Strings.bfHca3],
      Strings.bfHca4: localRecord[Strings.bfHca4],
      Strings.bfHca5: localRecord[Strings.bfHca5],
      Strings.bfCurrentPresentation: localRecord[Strings.bfCurrentPresentation],
      Strings.bfSpecificCarePlanYes: localRecord[Strings.bfSpecificCarePlanYes],
      Strings.bfSpecificCarePlanNo: localRecord[Strings.bfSpecificCarePlanNo],
      Strings.bfSpecificCarePlan: localRecord[Strings.bfSpecificCarePlan],
      Strings.bfPatientWarningsYes: localRecord[Strings.bfPatientWarningsYes],
      Strings.bfPatientWarningsNo: localRecord[Strings.bfPatientWarningsNo],
      Strings.bfPatientWarnings: localRecord[Strings.bfPatientWarnings],
      Strings.bfPresentingRisks: localRecord[Strings.bfPresentingRisks],
      Strings.bfPreviousRisks: localRecord[Strings.bfPreviousRisks],
      Strings.bfGenderConcernsYes: localRecord[Strings.bfGenderConcernsYes],
      Strings.bfGenderConcernsNo: localRecord[Strings.bfGenderConcernsNo],
      Strings.bfGenderConcerns: localRecord[Strings.bfGenderConcerns],
      Strings.bfSafeguardingConcernsYes: localRecord[Strings.bfSafeguardingConcernsYes],
      Strings.bfSafeguardingConcernsNo: localRecord[Strings.bfSafeguardingConcernsNo],
      Strings.bfSafeguardingConcerns: localRecord[Strings.bfSafeguardingConcerns],
      Strings.bfAmbulanceRegistration: localRecord[Strings.bfAmbulanceRegistration],
      Strings.bfTimeDue: localRecord[Strings.bfTimeDue],
      Strings.assignedUserId: localRecord[Strings.assignedUserId],
      Strings.assignedUserName: localRecord[Strings.assignedUserName],
      Strings.serverUploaded: localRecord[Strings.serverUploaded],
      Strings.timestamp: localRecord[Strings.timestamp]
    };
  }

  Future<Map<String, dynamic>> uploadPendingBookingForms() async {
    _isLoading = true;
    String message = 'Something went wrong!';
    bool success = false;

    try {

      List<dynamic> bookingFormRecords = await getPendingRecords();

      List<Map<String, dynamic>> bookingForms = [];

      for(var bookingFormRecord in bookingFormRecords){
        bookingForms.add(bookingFormRecord.value);
      }

      // List<Map<String, dynamic>> bookingForms =
      // await _databaseHelper.getAllWhereAndWhere(
      //     Strings.bookingFormTable,
      //     Strings.serverUploaded,
      //     0,
      //     Strings.uid,
      //     user.uid);


      bool isTokenExpired = GlobalFunctions.isTokenExpired();
      bool authenticated = true;

      if (isTokenExpired)
        authenticated = await authenticationModel.reAuthenticate();

      if (authenticated) {

        for (Map<String, dynamic> bookingForm in bookingForms) {

          success = false;
          await FirebaseFirestore.instance.collection('booking_forms').add({
            Strings.uid: user.uid,
            Strings.jobId: '1',
            Strings.formVersion: '1',
            Strings.jobRef: GlobalFunctions.databaseValueString(bookingForm[Strings.jobRef]),
            Strings.jobRefLowercase: GlobalFunctions.databaseValueString(bookingForm[Strings.jobRef]).toLowerCase(),
            Strings.bfRequestedBy: bookingForm[Strings.bfRequestedBy],
            Strings.bfJobTitle: bookingForm[Strings.bfJobTitle],
            Strings.bfJobContact: bookingForm[Strings.bfJobContact],
            Strings.bfJobAuthorisingManager: bookingForm[Strings.bfJobAuthorisingManager],
            Strings.bfJobDate: bookingForm[Strings.bfJobDate] == null ? null : DateTime.parse(bookingForm[Strings.bfJobDate]),
            Strings.bfJobTime: bookingForm[Strings.bfJobTime],
            Strings.bfTransportCoordinator: bookingForm[Strings.bfTransportCoordinator],
            Strings.bfCollectionDateTime: bookingForm[Strings.bfCollectionDateTime],
            Strings.bfCollectionAddress: bookingForm[Strings.bfCollectionAddress],
            Strings.bfCollectionPostcode: bookingForm[Strings.bfCollectionPostcode],
            Strings.bfCollectionTel: bookingForm[Strings.bfCollectionTel],
            Strings.bfDestinationAddress: bookingForm[Strings.bfDestinationAddress],
            Strings.bfDestinationPostcode: bookingForm[Strings.bfDestinationPostcode],
            Strings.bfDestinationTel: bookingForm[Strings.bfDestinationTel],
            Strings.bfInvoiceDetails: bookingForm[Strings.bfInvoiceDetails],
            Strings.bfCostCode: bookingForm[Strings.bfCostCode],
            Strings.bfPurchaseOrder: bookingForm[Strings.bfPurchaseOrder],
            Strings.bfPatientName: bookingForm[Strings.bfPatientName],
            Strings.bfLegalStatus: bookingForm[Strings.bfLegalStatus],
            Strings.bfDateOfBirth: bookingForm[Strings.bfDateOfBirth],
            Strings.bfNhsNumber: bookingForm[Strings.bfNhsNumber],
            Strings.bfGender: bookingForm[Strings.bfGender],
            Strings.bfEthnicity: bookingForm[Strings.bfEthnicity],
            Strings.bfCovidStatus: bookingForm[Strings.bfCovidStatus],
            Strings.bfRmn: bookingForm[Strings.bfRmn],
            Strings.bfRmn1: bookingForm[Strings.bfRmn1],
            Strings.bfHca: bookingForm[Strings.bfHca],
            Strings.bfHca1: bookingForm[Strings.bfHca1],
            Strings.bfHca2: bookingForm[Strings.bfHca2],
            Strings.bfHca3: bookingForm[Strings.bfHca3],
            Strings.bfHca4: bookingForm[Strings.bfHca4],
            Strings.bfHca5: bookingForm[Strings.bfHca5],
            Strings.bfCurrentPresentation: bookingForm[Strings.bfCurrentPresentation],
            Strings.bfSpecificCarePlanYes: bookingForm[Strings.bfSpecificCarePlanYes],
            Strings.bfSpecificCarePlanNo: bookingForm[Strings.bfSpecificCarePlanNo],
            Strings.bfSpecificCarePlan: bookingForm[Strings.bfSpecificCarePlan],
            Strings.bfPatientWarningsYes: bookingForm[Strings.bfPatientWarningsYes],
            Strings.bfPatientWarningsNo: bookingForm[Strings.bfPatientWarningsNo],
            Strings.bfPatientWarnings: bookingForm[Strings.bfPatientWarnings],
            Strings.bfPresentingRisks: bookingForm[Strings.bfPresentingRisks],
            Strings.bfPreviousRisks: bookingForm[Strings.bfPreviousRisks],
            Strings.bfGenderConcernsYes: bookingForm[Strings.bfGenderConcernsYes],
            Strings.bfGenderConcernsNo: bookingForm[Strings.bfGenderConcernsNo],
            Strings.bfGenderConcerns: bookingForm[Strings.bfGenderConcerns],
            Strings.bfSafeguardingConcernsYes: bookingForm[Strings.bfSafeguardingConcernsYes],
            Strings.bfSafeguardingConcernsNo: bookingForm[Strings.bfSafeguardingConcernsNo],
            Strings.bfSafeguardingConcerns: bookingForm[Strings.bfSafeguardingConcerns],
            Strings.bfAmbulanceRegistration: bookingForm[Strings.bfAmbulanceRegistration],
            Strings.bfTimeDue: bookingForm[Strings.bfTimeDue],
            Strings.assignedUserId: bookingForm[Strings.assignedUserId],
            Strings.assignedUserName: bookingForm[Strings.assignedUserName],
            Strings.timestamp: FieldValue.serverTimestamp(),
            Strings.serverUploaded: 1,
          });

          await deletePendingRecord(bookingForm[Strings.localId]);
          success = true;

          // DocumentSnapshot snap = await ref.get();
          //
          //
          // Map<String, dynamic> localData = {
          //   Strings.documentId: snap.id,
          //   Strings.serverUploaded: 1,
          //   'timestamp': DateTime.fromMillisecondsSinceEpoch(snap.data()[Strings.timestamp].millisecondsSinceEpoch).toIso8601String()
          // };
          //
          // int queryResult = await _databaseHelper.updateRow(
          //     Strings.bookingFormTable,
          //     localData,
          //     Strings.localId,
          //     bookingForm[Strings.localId]);
          //
          // if (queryResult != 0) {
          //   success = true;
          // }

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

  Future<void> setUpEditedBookingForm() async{
    Map<String, dynamic> editedReport = editedBookingForm(selectedBookingForm);
    Map<String, dynamic> localData = Map.from(editedReport);
    await _databaseHelper.deleteAllRows(Strings.editedBookingFormTable);
    await _databaseHelper.add(Strings.editedBookingFormTable, localData);

  }

  Future<void> deleteEditedBookingForm() async{
    await _databaseHelper.deleteAllRows(Strings.editedBookingFormTable);
  }

  void resetTemporaryBookingForm(String chosenJobId) {
    _databaseHelper.resetTemporaryBookingForm(user.uid, chosenJobId);
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

    Widget sectionTitle(String text){
      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text, style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 9, fontWeight: FontWeight.bold)),
            Container(height: 5)
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
                      child: Center(child: Text(selectedBookingForm[yesString] == null || selectedBookingForm[yesString] == 0 ? '' : 'X', textAlign: TextAlign.center ,style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
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
                      child: Center(child: Text(selectedBookingForm[noString] == null || selectedBookingForm[noString] == 0 ? '' : 'X', textAlign: TextAlign.center ,style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
                ]
            ),
            Container(height: 5),
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
                child: Text('Transport Booking - Page ${context.pageNumber} of ${context.pagesCount}',
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
                          textField(TextOption.PlainText, selectedBookingForm[Strings.jobRef]),
                        ]),
                      ]
                  ),

                  Container(height: 50, child: Image(pegasusLogo)),

                ]
            ),
            Container(height: 10),
            Center(child: Text('Transport Booking', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontWeight: FontWeight.bold))),
            Container(height: 20),
            doubleLineField('Requested by', selectedBookingForm[Strings.bfRequestedBy], 'Job Title', selectedBookingForm[Strings.bfJobTitle]),
            doubleLineField('Contact Telephone Number', selectedBookingForm[Strings.bfJobContact], 'Authorising Managers Name', selectedBookingForm[Strings.bfJobAuthorisingManager]),
            doubleLineField('Date', selectedBookingForm[Strings.bfJobDate], 'Time', selectedBookingForm[Strings.bfJobTime], TextOption.Date, TextOption.Time),
            doubleLineField('Transport Coordinator Name', selectedBookingForm[Strings.bfTransportCoordinator], 'Collection Date & Time', dateTimeFormat.format(DateTime.parse(selectedBookingForm[Strings.bfCollectionDateTime])), TextOption.EncryptedText, TextOption.DateTime),
            singleLineField('Patient Collection Address', selectedBookingForm[Strings.bfCollectionAddress]),
            doubleLineField('Postcode', selectedBookingForm[Strings.bfCollectionPostcode], 'Tel', selectedBookingForm[Strings.bfCollectionTel]),
            singleLineField('Patient Destination Address', selectedBookingForm[Strings.bfDestinationAddress]),
            doubleLineField('Postcode', selectedBookingForm[Strings.bfDestinationPostcode], 'Tel', selectedBookingForm[Strings.bfDestinationTel]),
            Container(height: 5),
            Text('Invoice Details', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 10, fontWeight: FontWeight.bold)),
            Container(height: 5),
            textField(TextOption.EncryptedText, selectedBookingForm[Strings.bfInvoiceDetails], 700, 50, 300),
            Container(height: 5),
            doubleLineField('Cost Code', selectedBookingForm[Strings.bfCostCode], 'Purchase Order no', selectedBookingForm[Strings.bfPurchaseOrder]),
            Container(height: 5),
            Text('Patient Details', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 10, fontWeight: FontWeight.bold)),
            Container(height: 5),
            doubleLineField('Name', selectedBookingForm[Strings.bfPatientName], 'Gender', selectedBookingForm[Strings.bfGender]),
            doubleLineField('Legal Status', selectedBookingForm[Strings.bfLegalStatus], 'Ethnicity', selectedBookingForm[Strings.bfEthnicity]),
            doubleLineField('Date of birth', selectedBookingForm[Strings.bfDateOfBirth], 'Covid Status', selectedBookingForm[Strings.bfCovidStatus], TextOption.EncryptedDate),
            singleLineField('NHS Number', selectedBookingForm[Strings.bfNhsNumber], TextOption.EncryptedText, true),
            singleLineField('Current Presentation', selectedBookingForm[Strings.bfCurrentPresentation]),
            doubleLineField("RMN", selectedBookingForm[Strings.bfRmn], '1.', selectedBookingForm[Strings.bfRmn1]),
            doubleLineField("HCA's:", selectedBookingForm[Strings.bfHca], '1.', selectedBookingForm[Strings.bfHca1]),
            doubleLineField('2.', selectedBookingForm[Strings.bfHca2], '3.', selectedBookingForm[Strings.bfHca3]),
            doubleLineField('4.', selectedBookingForm[Strings.bfHca4], '5.', selectedBookingForm[Strings.bfHca5]),
            Container(height: 10),
            yesNoField(Strings.bfSpecificCarePlanYes, Strings.bfSpecificCarePlanNo, 'Specific Care Plan:'),
            selectedBookingForm[Strings.bfSpecificCarePlanYes] != null && selectedBookingForm[Strings.bfSpecificCarePlanYes] == 1 ?
            singleLineField('Details', selectedBookingForm[Strings.bfSpecificCarePlan]) : Container(),
            Container(height: 10),
            yesNoField(Strings.bfPatientWarningsYes, Strings.bfPatientWarningsNo, 'Patient warnings/markers:'),
            selectedBookingForm[Strings.bfPatientWarningsYes] != null && selectedBookingForm[Strings.bfPatientWarningsYes] == 1 ?
            singleLineField('Details', selectedBookingForm[Strings.bfPatientWarnings]) : Container(),
            Container(height: 10),
            singleLineField('Presenting Risks: (inc physical health, covid symptoms)', selectedBookingForm[Strings.bfPresentingRisks]),
            singleLineField('Previous Risk History: (inc physical health, covid symptoms)', selectedBookingForm[Strings.bfPreviousRisks]),
            Container(height: 10),
            yesNoField(Strings.bfGenderConcernsYes, Strings.bfGenderConcernsNo, 'Gender/Race/Sexual Behaviour concerns:'),
            selectedBookingForm[Strings.bfGenderConcernsYes] != null && selectedBookingForm[Strings.bfGenderConcernsYes] == 1 ?
            singleLineField('Details', selectedBookingForm[Strings.bfGenderConcerns]) : Container(),
            Container(height: 10),
            yesNoField(Strings.bfSafeguardingConcernsYes, Strings.bfSafeguardingConcernsNo, 'Safeguarding Concerns:'),
            selectedBookingForm[Strings.bfSafeguardingConcernsYes] != null && selectedBookingForm[Strings.bfSafeguardingConcernsYes] == 1 ?
            singleLineField('Details', selectedBookingForm[Strings.bfSafeguardingConcerns]) : Container(),
            Container(height: 10),
            doubleLineField('Ambulance Registration', selectedBookingForm[Strings.bfAmbulanceRegistration], 'Time Due at Base', selectedBookingForm[Strings.bfTimeDue], TextOption.EncryptedText, TextOption.Time),
            Container(height: 10),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('•	Please ensure that all members of staff have had sufficient rest prior to this transfer', style: TextStyle(fontSize: 10, color: PdfColor.fromInt(bluePurpleInt)))
                ]
            ),

          ]

      ));

      String formDate = selectedBookingForm[Strings.bfJobDate] == null ? '' : dateFormatDay.format(DateTime.parse(selectedBookingForm[Strings.bfJobDate]));
      String id = selectedBookingForm[Strings.documentId];


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
            ..download = 'transport_booking_${formDate}_$id.pdf';
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



        final File file = File('$pdfPath/transport_booking_${formDate}_$id.pdf');

        if(option == ShareOption.Email){
          file.writeAsBytesSync(pdf.save());
        }

        ConnectivityResult connectivityResult = await Connectivity().checkConnectivity();

        if(connectivityResult != ConnectivityResult.none) {

          if(option == ShareOption.Share) Printing.sharePdf(bytes: pdf.save(),filename: 'transport_booking_${formDate}_$id.pdf');
          if(option == ShareOption.Print) await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());

          if(option == ShareOption.Email) {
            final smtpServer = gmail(emailUsername, emailPassword);

            // Create our message.
            final mailmessage = new Message()
              ..from = new Address(emailUsername, 'Pegasus Medical')
              ..recipients = emailList
              ..subject = 'Completed Transport Booking'
              ..html = "<p1>Dear Sir/Madam,</p1>\n<p>Attached is a completed Transport Booking from ${user
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



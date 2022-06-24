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



class SpotChecksModel extends ChangeNotifier {

  DatabaseHelper _databaseHelper = DatabaseHelper();
  AuthenticationModel authenticationModel = AuthenticationModel();
  final NavigationService _navigationService = locator<NavigationService>();
  SpotChecksModel(this.authenticationModel);

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> _spotChecks = [];
  String _selSpotChecksId;
  final dateFormatDay = DateFormat("dd-MM-yyyy");

  List<Map<String, dynamic>> get allSpotChecks {
    return List.from(_spotChecks);
  }
  int get selectedSpotChecksIndex {
    return _spotChecks.indexWhere((Map<String, dynamic> spotChecks) {
      return spotChecks[Strings.documentId] == _selSpotChecksId;
    });
  }
  String get selectedSpotChecksId {
    return _selSpotChecksId;
  }

  Map<String, dynamic> get selectedSpotChecks {
    if (_selSpotChecksId == null) {
      return null;
    }
    return _spotChecks.firstWhere((Map<String, dynamic> spotChecks) {
      return spotChecks[Strings.documentId] == _selSpotChecksId;
    });
  }
  void selectSpotChecks(String spotChecksId) {
    _selSpotChecksId = spotChecksId;
    if (spotChecksId != null) {
      notifyListeners();
    }
  }

  void clearSpotChecks(){
    _spotChecks = [];
  }


  // Sembast database settings
  static const String TEMPORARY_SPOT_CHECKS_STORE_NAME = 'temporary_spot_checks';
  final _temporarySpotChecksStore = Db.intMapStoreFactory.store(TEMPORARY_SPOT_CHECKS_STORE_NAME);

  static const String SPOT_CHECKS_STORE_NAME = 'spot_checks';
  final _spotChecksStore = Db.intMapStoreFactory.store(SPOT_CHECKS_STORE_NAME);

  static const String EDITED_SPOT_CHECKS_STORE_NAME = 'edited_spot_checks';
  final _editedSpotChecksStore = Db.intMapStoreFactory.store(EDITED_SPOT_CHECKS_STORE_NAME);

  // Private getter to shorten the amount of code needed to get the
  // singleton instance of an opened database.
  Future<Db.Database> get _db async => await AppDatabase.instance.database;


  Future<void> setupTemporaryRecord() async {

    final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
        [Db.Filter.equals(Strings.uid, user.uid), Db.Filter.equals(Strings.jobId, '1')]
    ));
    List records = await _temporarySpotChecksStore.find(
      await _db,
      finder: finder,
    );
    if(records.length == 0){
      // Generate a random ID based on the date and a random string for virtual zero chance of duplicates
      int _id = DateTime.now().millisecondsSinceEpoch + int.parse(random_string.randomNumeric(2));
      await _temporarySpotChecksStore.record(_id).put(await _db,
          {Strings.uid : user.uid, Strings.formVersion: 1, Strings.jobId : '1'});
    }
  }

  Future<Map<String, dynamic>> getTemporaryRecord(bool edit, String selectedJobId) async{

    List records;

    if(edit){
      final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
          [Db.Filter.equals(Strings.documentId, selectedSpotChecks[Strings.documentId]), Db.Filter.equals(Strings.jobId, selectedJobId)]
      ));
      records = await _editedSpotChecksStore.find(
        await _db,
        finder: finder,
      );
    } else {
      final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
          [Db.Filter.equals(Strings.uid, user.uid), Db.Filter.equals(Strings.jobId, selectedJobId)]
      ));
      records = await _temporarySpotChecksStore.find(
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

    List records = await _spotChecksStore.find(
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

    List records = await _spotChecksStore.find(
      await _db,
      finder: finder,
    );

    return records;
  }

  Future <void> deletePendingRecord(int localId) async{
    final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
        [Db.Filter.equals(Strings.uid, user.uid), Db.Filter.equals(Strings.localId, localId)]
    ));

    await _spotChecksStore.delete(
      await _db,
      finder: finder,
    );
  }

  Future<bool> checkRecordExists(bool edit, String selectedJobId) async{

    bool hasRecord = false;

    List records;


    if(edit){
      final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
          [Db.Filter.equals(Strings.documentId, selectedSpotChecks[Strings.documentId]), Db.Filter.equals(Strings.jobId, selectedJobId)]
      ));
      records = await _editedSpotChecksStore.find(
        await _db,
        finder: finder,
      );
    } else {

      final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
          [Db.Filter.equals(Strings.uid, user.uid), Db.Filter.equals(Strings.jobId, selectedJobId)]
      ));
      records = await _temporarySpotChecksStore.find(
        await _db,
        finder: finder,
      );
    }

    if(records.length > 0) hasRecord = true;


    return hasRecord;

  }

  Future<void> updateTemporaryRecord(bool edit, String field, var value, String selectedJobId) async {

    if(edit){
      final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
          [Db.Filter.equals(Strings.documentId, selectedSpotChecks[Strings.documentId]), Db.Filter.equals(Strings.jobId, selectedJobId)]
      ));
      await _editedSpotChecksStore.update(await _db, {field: value},
          finder: finder);
    } else {
      final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
          [Db.Filter.equals(Strings.uid, user.uid), Db.Filter.equals(Strings.jobId, selectedJobId)]
      ));
      await _temporarySpotChecksStore.update(await _db, {field: value},
          finder: finder);
    }

  }

  void deleteEditedRecord() async {
    await _editedSpotChecksStore.delete(await _db);
  }

  Future<void> setUpEditedRecord() async{

    Map<String, dynamic> editedReport = editedSpotChecks(selectedSpotChecks);
    Map<String, dynamic> localData = Map.from(editedReport);
    await _editedSpotChecksStore.delete(await _db);
    int _id = DateTime.now().millisecondsSinceEpoch + int.parse(random_string.randomNumeric(2));
    await _editedSpotChecksStore.record(_id).put(await _db,
        localData);

  }

  Future<void> deleteAllRows() async {
    await _spotChecksStore.delete(await _db);
  }


  void resetTemporaryRecord(String chosenJobId) async {

    final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
        [Db.Filter.equals(Strings.uid, user.uid), Db.Filter.equals(Strings.jobId, chosenJobId)]
    ));

    await _temporarySpotChecksStore.update(await _db, {
      Strings.formVersion: 1,
      Strings.jobRef: null,
      Strings.jobRefRef: null,
      Strings.jobRefNo: null,
      Strings.scStaff1: null,
      Strings.scStaff2: null,
      Strings.scStaff3: null,
      Strings.scStaff4: null,
      Strings.scStaff5: null,
      Strings.scStaff6: null,
      Strings.scStaff7: null,
      Strings.scStaff8: null,
      Strings.scStaff9: null,
      Strings.scStaff10: null,
      Strings.scOnTimeYes: null,
      Strings.scOnTimeNo: null,
      Strings.scCorrectUniformYes: null,
      Strings.scCorrectUniformNo: null,
      Strings.scPegasusBadgeYes: null,
      Strings.scPegasusBadgeNo: null,
      Strings.scVehicleChecksYes: null,
      Strings.scVehicleChecksNo: null,
      Strings.scCollectionStaffIntroduceYes: null,
      Strings.scCollectionStaffIntroduceNo: null,
      Strings.scCollectionTransferReportYes: null,
      Strings.scCollectionTransferReportNo: null,
      Strings.scStaffEngageYes: null,
      Strings.scStaffEngageNo: null,
      Strings.scArrivalStaffIntroduceYes: null,
      Strings.scArrivalStaffIntroduceNo: null,
      Strings.scArrivalTransferReportYes: null,
      Strings.scArrivalTransferReportNo: null,
      Strings.scPhysicalInterventionYes: null,
      Strings.scPhysicalInterventionNo: null,
      Strings.scInfectionControl1Yes: null,
      Strings.scInfectionControl1No: null,
      Strings.scInfectionControl2Yes: null,
      Strings.scInfectionControl2No: null,
      Strings.scVehicleTidyYes: null,
      Strings.scVehicleTidyNo: null,
      Strings.scCompletedTransferReportYes: null,
      Strings.scCompletedTransferReportNo: null,
      Strings.scIssuesIdentified: null,
      Strings.scActionTaken: null,
      Strings.scGoodPractice: null,
      Strings.scName: null,
      Strings.scDate: null,
      Strings.scSignature: null,
      Strings.scSignaturePoints: null,
    },
        finder: finder);
    notifyListeners();
  }


  Future<bool> validateSpotChecks(String jobId, bool edit) async {

    bool success = true;

    Map<String, dynamic> spotChecks = await getTemporaryRecord(edit, jobId);

    if(spotChecks[Strings.jobRefNo]== null || spotChecks[Strings.jobRefNo].toString().trim() == ''){
      success = false;
    }

    if(spotChecks[Strings.jobRefRef]== null || spotChecks[Strings.jobRefRef]== 'Select One'){
      success = false;
    }

    if(spotChecks[Strings.scName]== null || spotChecks[Strings.scName].toString().trim() == ''){
      success = false;
    }

    if(spotChecks[Strings.scDate] == null){
      success = false;
    }

    if(spotChecks[Strings.scSignature] == null){
      success = false;
    }

    if(spotChecks[Strings.scOnTimeYes] == null && spotChecks[Strings.scOnTimeNo] == null){
      success = false;
    }
    if(spotChecks[Strings.scOnTimeYes] == 0 && spotChecks[Strings.scOnTimeNo] == 0){
      success = false;
    }
    if(spotChecks[Strings.scOnTimeYes] == null && spotChecks[Strings.scOnTimeNo] == 0){
      success = false;
    }
    if(spotChecks[Strings.scOnTimeYes] == 0 && spotChecks[Strings.scOnTimeNo] == null){
      success = false;
    }

    if(spotChecks[Strings.scCorrectUniformYes] == null && spotChecks[Strings.scCorrectUniformNo] == null){
      success = false;
    }
    if(spotChecks[Strings.scCorrectUniformYes] == 0 && spotChecks[Strings.scCorrectUniformNo] == 0){
      success = false;
    }
    if(spotChecks[Strings.scCorrectUniformYes] == null && spotChecks[Strings.scCorrectUniformNo] == 0){
      success = false;
    }
    if(spotChecks[Strings.scCorrectUniformYes] == 0 && spotChecks[Strings.scCorrectUniformNo] == null){
      success = false;
    }

    if(spotChecks[Strings.scPegasusBadgeYes] == null && spotChecks[Strings.scPegasusBadgeNo] == null){
      success = false;
    }
    if(spotChecks[Strings.scPegasusBadgeYes] == 0 && spotChecks[Strings.scPegasusBadgeNo] == 0){
      success = false;
    }
    if(spotChecks[Strings.scPegasusBadgeYes] == null && spotChecks[Strings.scPegasusBadgeNo] == 0){
      success = false;
    }
    if(spotChecks[Strings.scPegasusBadgeYes] == 0 && spotChecks[Strings.scPegasusBadgeNo] == null){
      success = false;
    }

    if(spotChecks[Strings.scVehicleChecksYes] == null && spotChecks[Strings.scVehicleChecksNo] == null){
      success = false;
    }
    if(spotChecks[Strings.scVehicleChecksYes] == 0 && spotChecks[Strings.scVehicleChecksNo] == 0){
      success = false;
    }
    if(spotChecks[Strings.scVehicleChecksYes] == null && spotChecks[Strings.scVehicleChecksNo] == 0){
      success = false;
    }
    if(spotChecks[Strings.scVehicleChecksYes] == 0 && spotChecks[Strings.scVehicleChecksNo] == null){
      success = false;
    }

    if(spotChecks[Strings.scCollectionStaffIntroduceYes] == null && spotChecks[Strings.scCollectionStaffIntroduceNo] == null){
      success = false;
    }
    if(spotChecks[Strings.scCollectionStaffIntroduceYes] == 0 && spotChecks[Strings.scCollectionStaffIntroduceNo] == 0){
      success = false;
    }
    if(spotChecks[Strings.scCollectionStaffIntroduceYes] == null && spotChecks[Strings.scCollectionStaffIntroduceNo] == 0){
      success = false;
    }
    if(spotChecks[Strings.scCollectionStaffIntroduceYes] == 0 && spotChecks[Strings.scCollectionStaffIntroduceNo] == null){
      success = false;
    }

    if(spotChecks[Strings.scCollectionTransferReportYes] == null && spotChecks[Strings.scCollectionTransferReportNo] == null){
      success = false;
    }
    if(spotChecks[Strings.scCollectionTransferReportYes] == 0 && spotChecks[Strings.scCollectionTransferReportNo] == 0){
      success = false;
    }
    if(spotChecks[Strings.scCollectionTransferReportYes] == null && spotChecks[Strings.scCollectionTransferReportNo] == 0){
      success = false;
    }
    if(spotChecks[Strings.scCollectionTransferReportYes] == 0 && spotChecks[Strings.scCollectionTransferReportNo] == null){
      success = false;
    }

    if(spotChecks[Strings.scStaffEngageYes] == null && spotChecks[Strings.scStaffEngageNo] == null){
      success = false;
    }
    if(spotChecks[Strings.scStaffEngageYes] == 0 && spotChecks[Strings.scStaffEngageNo] == 0){
      success = false;
    }
    if(spotChecks[Strings.scStaffEngageYes] == null && spotChecks[Strings.scStaffEngageNo] == 0){
      success = false;
    }
    if(spotChecks[Strings.scStaffEngageYes] == 0 && spotChecks[Strings.scStaffEngageNo] == null){
      success = false;
    }

    if(spotChecks[Strings.scArrivalStaffIntroduceYes] == null && spotChecks[Strings.scArrivalStaffIntroduceNo] == null){
      success = false;
    }
    if(spotChecks[Strings.scArrivalStaffIntroduceYes] == 0 && spotChecks[Strings.scArrivalStaffIntroduceNo] == 0){
      success = false;
    }
    if(spotChecks[Strings.scArrivalStaffIntroduceYes] == null && spotChecks[Strings.scArrivalStaffIntroduceNo] == 0){
      success = false;
    }
    if(spotChecks[Strings.scArrivalStaffIntroduceYes] == 0 && spotChecks[Strings.scArrivalStaffIntroduceNo] == null){
      success = false;
    }

    if(spotChecks[Strings.scArrivalTransferReportYes] == null && spotChecks[Strings.scArrivalTransferReportNo] == null){
      success = false;
    }
    if(spotChecks[Strings.scArrivalTransferReportYes] == 0 && spotChecks[Strings.scArrivalTransferReportNo] == 0){
      success = false;
    }
    if(spotChecks[Strings.scArrivalTransferReportYes] == null && spotChecks[Strings.scArrivalTransferReportNo] == 0){
      success = false;
    }
    if(spotChecks[Strings.scArrivalTransferReportYes] == 0 && spotChecks[Strings.scArrivalTransferReportNo] == null){
      success = false;
    }

    if(spotChecks[Strings.scPhysicalInterventionYes] == null && spotChecks[Strings.scPhysicalInterventionNo] == null){
      success = false;
    }
    if(spotChecks[Strings.scPhysicalInterventionYes] == 0 && spotChecks[Strings.scPhysicalInterventionNo] == 0){
      success = false;
    }
    if(spotChecks[Strings.scPhysicalInterventionYes] == null && spotChecks[Strings.scPhysicalInterventionNo] == 0){
      success = false;
    }
    if(spotChecks[Strings.scPhysicalInterventionYes] == 0 && spotChecks[Strings.scPhysicalInterventionNo] == null){
      success = false;
    }

    if(spotChecks[Strings.scInfectionControl1Yes] == null && spotChecks[Strings.scInfectionControl1No] == null){
      success = false;
    }
    if(spotChecks[Strings.scInfectionControl1Yes] == 0 && spotChecks[Strings.scInfectionControl1No] == 0){
      success = false;
    }
    if(spotChecks[Strings.scInfectionControl1Yes] == null && spotChecks[Strings.scInfectionControl1No] == 0){
      success = false;
    }
    if(spotChecks[Strings.scInfectionControl1Yes] == 0 && spotChecks[Strings.scInfectionControl1No] == null){
      success = false;
    }

    if(spotChecks[Strings.scInfectionControl2Yes] == null && spotChecks[Strings.scInfectionControl2No] == null){
      success = false;
    }
    if(spotChecks[Strings.scInfectionControl2Yes] == 0 && spotChecks[Strings.scInfectionControl2No] == 0){
      success = false;
    }
    if(spotChecks[Strings.scInfectionControl2Yes] == null && spotChecks[Strings.scInfectionControl2No] == 0){
      success = false;
    }
    if(spotChecks[Strings.scInfectionControl2Yes] == 0 && spotChecks[Strings.scInfectionControl2No] == null){
      success = false;
    }

    if(spotChecks[Strings.scVehicleTidyYes] == null && spotChecks[Strings.scVehicleTidyNo] == null){
      success = false;
    }
    if(spotChecks[Strings.scVehicleTidyYes] == 0 && spotChecks[Strings.scVehicleTidyNo] == 0){
      success = false;
    }
    if(spotChecks[Strings.scVehicleTidyYes] == null && spotChecks[Strings.scVehicleTidyNo] == 0){
      success = false;
    }
    if(spotChecks[Strings.scVehicleTidyYes] == 0 && spotChecks[Strings.scVehicleTidyNo] == null){
      success = false;
    }

    if(spotChecks[Strings.scCompletedTransferReportYes] == null && spotChecks[Strings.scCompletedTransferReportNo] == null){
      success = false;
    }
    if(spotChecks[Strings.scCompletedTransferReportYes] == 0 && spotChecks[Strings.scCompletedTransferReportNo] == 0){
      success = false;
    }
    if(spotChecks[Strings.scCompletedTransferReportYes] == null && spotChecks[Strings.scCompletedTransferReportNo] == 0){
      success = false;
    }
    if(spotChecks[Strings.scCompletedTransferReportYes] == 0 && spotChecks[Strings.scCompletedTransferReportNo] == null){
      success = false;
    }

    return success;

  }

  Future<bool> submitSpotChecks(String jobId, [bool edit = false]) async {

    GlobalFunctions.showLoadingDialog('Submitting Spot Checks...');
    String message = '';
    bool success = false;
    List<String> storageUrlList = [];

    //Semabast
    int count = await _spotChecksStore.count(await _db);
    int id;

    if (count == 0) {
      id = 1;
    } else {
      id = count + 1;
    }

    //Sembast
    Map<String, dynamic> spotChecks = await getTemporaryRecord(false, jobId);

    Map<String, dynamic> localData = {
      Strings.localId: id,
      Strings.documentId: null,
      Strings.uid: user.uid,
      Strings.jobId: '1',
      Strings.formVersion: '1',
      Strings.jobRef: spotChecks[Strings.jobRefRef] + spotChecks[Strings.jobRefNo],
      Strings.jobRefRef: spotChecks[Strings.jobRefRef],
      Strings.jobRefNo: spotChecks[Strings.jobRefNo],
      Strings.scStaff1: spotChecks[Strings.scStaff1],
      Strings.scStaff2: spotChecks[Strings.scStaff2],
      Strings.scStaff3: spotChecks[Strings.scStaff3],
      Strings.scStaff4: spotChecks[Strings.scStaff4],
      Strings.scStaff5: spotChecks[Strings.scStaff5],
      Strings.scStaff6: spotChecks[Strings.scStaff6],
      Strings.scStaff7: spotChecks[Strings.scStaff7],
      Strings.scStaff8: spotChecks[Strings.scStaff8],
      Strings.scStaff9: spotChecks[Strings.scStaff9],
      Strings.scStaff10: spotChecks[Strings.scStaff10],
      Strings.scOnTimeYes: spotChecks[Strings.scOnTimeYes],
      Strings.scOnTimeNo: spotChecks[Strings.scOnTimeNo],
      Strings.scCorrectUniformYes: spotChecks[Strings.scCorrectUniformYes],
      Strings.scCorrectUniformNo: spotChecks[Strings.scCorrectUniformNo],
      Strings.scPegasusBadgeYes: spotChecks[Strings.scPegasusBadgeYes],
      Strings.scPegasusBadgeNo: spotChecks[Strings.scPegasusBadgeNo],
      Strings.scVehicleChecksYes: spotChecks[Strings.scVehicleChecksYes],
      Strings.scVehicleChecksNo: spotChecks[Strings.scVehicleChecksNo],
      Strings.scCollectionStaffIntroduceYes: spotChecks[Strings.scCollectionStaffIntroduceYes],
      Strings.scCollectionStaffIntroduceNo: spotChecks[Strings.scCollectionStaffIntroduceNo],
      Strings.scCollectionTransferReportYes: spotChecks[Strings.scCollectionTransferReportYes],
      Strings.scCollectionTransferReportNo: spotChecks[Strings.scCollectionTransferReportNo],
      Strings.scStaffEngageYes: spotChecks[Strings.scStaffEngageYes],
      Strings.scStaffEngageNo: spotChecks[Strings.scStaffEngageNo],
      Strings.scArrivalStaffIntroduceYes: spotChecks[Strings.scArrivalStaffIntroduceYes],
      Strings.scArrivalStaffIntroduceNo: spotChecks[Strings.scArrivalStaffIntroduceNo],
      Strings.scArrivalTransferReportYes: spotChecks[Strings.scArrivalTransferReportYes],
      Strings.scArrivalTransferReportNo: spotChecks[Strings.scArrivalTransferReportNo],
      Strings.scPhysicalInterventionYes: spotChecks[Strings.scPhysicalInterventionYes],
      Strings.scPhysicalInterventionNo: spotChecks[Strings.scPhysicalInterventionNo],
      Strings.scInfectionControl1Yes: spotChecks[Strings.scInfectionControl1Yes],
      Strings.scInfectionControl1No: spotChecks[Strings.scInfectionControl1No],
      Strings.scInfectionControl2Yes: spotChecks[Strings.scInfectionControl2Yes],
      Strings.scInfectionControl2No: spotChecks[Strings.scInfectionControl2No],
      Strings.scVehicleTidyYes: spotChecks[Strings.scVehicleTidyYes],
      Strings.scVehicleTidyNo: spotChecks[Strings.scVehicleTidyNo],
      Strings.scCompletedTransferReportYes: spotChecks[Strings.scCompletedTransferReportYes],
      Strings.scCompletedTransferReportNo: spotChecks[Strings.scCompletedTransferReportNo],
      Strings.scIssuesIdentified: spotChecks[Strings.scIssuesIdentified],
      Strings.scActionTaken: spotChecks[Strings.scActionTaken],
      Strings.scGoodPractice: spotChecks[Strings.scGoodPractice],
      Strings.scName: spotChecks[Strings.scName],
      Strings.scSignature: spotChecks[Strings.scSignature],
      Strings.scDate: spotChecks[Strings.scDate],
      Strings.pendingTime: DateTime.now().toIso8601String(),
      Strings.serverUploaded: 0,
    };

    //Sembast
    int _id = DateTime.now().millisecondsSinceEpoch + int.parse(random_string.randomNumeric(2));
    await _spotChecksStore.record(_id).put(await _db,
        localData);

    message = 'Spot Checks has successfully been added to local database';

    // int result = await _databaseHelper.add(Strings.spotChecksTable, localData);
    //
    // if (result != 0) {
    //   message = 'Spot Checks has successfully been added to local database';
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
          await FirebaseFirestore.instance.collection('spot_checks').add({
            Strings.uid: user.uid,
            Strings.jobId: '1',
            Strings.formVersion: '1',
            Strings.jobRef: GlobalFunctions.databaseValueString(spotChecks[Strings.jobRefRef]) + GlobalFunctions.databaseValueString(spotChecks[Strings.jobRefNo]),
            Strings.jobRefLowercase: GlobalFunctions.databaseValueString(spotChecks[Strings.jobRefRef]).toLowerCase() + GlobalFunctions.databaseValueString(spotChecks[Strings.jobRefNo]).toLowerCase(),
            Strings.jobRefRef: GlobalFunctions.databaseValueString(spotChecks[Strings.jobRefRef]),
            Strings.jobRefNo:  int.parse(spotChecks[Strings.jobRefNo]),
            Strings.scStaff1: spotChecks[Strings.scStaff1],
            Strings.scStaff2: spotChecks[Strings.scStaff2],
            Strings.scStaff3: spotChecks[Strings.scStaff3],
            Strings.scStaff4: spotChecks[Strings.scStaff4],
            Strings.scStaff5: spotChecks[Strings.scStaff5],
            Strings.scStaff6: spotChecks[Strings.scStaff6],
            Strings.scStaff7: spotChecks[Strings.scStaff7],
            Strings.scStaff8: spotChecks[Strings.scStaff8],
            Strings.scStaff9: spotChecks[Strings.scStaff9],
            Strings.scStaff10: spotChecks[Strings.scStaff10],
            Strings.scOnTimeYes: spotChecks[Strings.scOnTimeYes],
            Strings.scOnTimeNo: spotChecks[Strings.scOnTimeNo],
            Strings.scCorrectUniformYes: spotChecks[Strings.scCorrectUniformYes],
            Strings.scCorrectUniformNo: spotChecks[Strings.scCorrectUniformNo],
            Strings.scPegasusBadgeYes: spotChecks[Strings.scPegasusBadgeYes],
            Strings.scPegasusBadgeNo: spotChecks[Strings.scPegasusBadgeNo],
            Strings.scVehicleChecksYes: spotChecks[Strings.scVehicleChecksYes],
            Strings.scVehicleChecksNo: spotChecks[Strings.scVehicleChecksNo],
            Strings.scCollectionStaffIntroduceYes: spotChecks[Strings.scCollectionStaffIntroduceYes],
            Strings.scCollectionStaffIntroduceNo: spotChecks[Strings.scCollectionStaffIntroduceNo],
            Strings.scCollectionTransferReportYes: spotChecks[Strings.scCollectionTransferReportYes],
            Strings.scCollectionTransferReportNo: spotChecks[Strings.scCollectionTransferReportNo],
            Strings.scStaffEngageYes: spotChecks[Strings.scStaffEngageYes],
            Strings.scStaffEngageNo: spotChecks[Strings.scStaffEngageNo],
            Strings.scArrivalStaffIntroduceYes: spotChecks[Strings.scArrivalStaffIntroduceYes],
            Strings.scArrivalStaffIntroduceNo: spotChecks[Strings.scArrivalStaffIntroduceNo],
            Strings.scArrivalTransferReportYes: spotChecks[Strings.scArrivalTransferReportYes],
            Strings.scArrivalTransferReportNo: spotChecks[Strings.scArrivalTransferReportNo],
            Strings.scPhysicalInterventionYes: spotChecks[Strings.scPhysicalInterventionYes],
            Strings.scPhysicalInterventionNo: spotChecks[Strings.scPhysicalInterventionNo],
            Strings.scInfectionControl1Yes: spotChecks[Strings.scInfectionControl1Yes],
            Strings.scInfectionControl1No: spotChecks[Strings.scInfectionControl1No],
            Strings.scInfectionControl2Yes: spotChecks[Strings.scInfectionControl2Yes],
            Strings.scInfectionControl2No: spotChecks[Strings.scInfectionControl2No],
            Strings.scVehicleTidyYes: spotChecks[Strings.scVehicleTidyYes],
            Strings.scVehicleTidyNo: spotChecks[Strings.scVehicleTidyNo],
            Strings.scCompletedTransferReportYes: spotChecks[Strings.scCompletedTransferReportYes],
            Strings.scCompletedTransferReportNo: spotChecks[Strings.scCompletedTransferReportNo],
            Strings.scIssuesIdentified: spotChecks[Strings.scIssuesIdentified],
            Strings.scActionTaken: spotChecks[Strings.scActionTaken],
            Strings.scGoodPractice: spotChecks[Strings.scGoodPractice],
            Strings.scName: spotChecks[Strings.scName],
            Strings.scSignature: null,
            Strings.scDate: spotChecks[Strings.scDate] == null ? null : DateTime.parse(spotChecks[Strings.scDate]),
            Strings.timestamp: FieldValue.serverTimestamp(),
            Strings.serverUploaded: 1,
          });

          DocumentSnapshot snap = await ref.get();

          //Signatures
          String scSignatureUrl;
          bool scSignatureSuccess = true;

          if(spotChecks[Strings.scSignature] != null){
            scSignatureSuccess = false;

            Reference storageRef =
            FirebaseStorage.instance.ref().child('spotChecksImages/' + snap.id + '/scSignature.jpg');

            if(kIsWeb){
              storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/spotChecksImages/' + snap.id + '/scSignature.jpg');
            }

            final UploadTask uploadTask = storageRef.putData(Uint8List.fromList(spotChecks[Strings.scSignature].toList().cast<int>()));
            final TaskSnapshot downloadUrl = (await uploadTask);
            scSignatureUrl = (await downloadUrl.ref.getDownloadURL());
            if(scSignatureUrl != null){
              scSignatureSuccess = true;
              storageUrlList.add('spotChecksImages/' + snap.id + '/scSignature.jpg');
            }

          }

          if(scSignatureSuccess){

            await FirebaseFirestore.instance.collection('spot_checks').doc(snap.id).update({
              Strings.scSignature: scSignatureUrl == null ? null : scSignatureUrl,
            }).timeout(Duration(seconds: 60));


            //Sembast
            await _spotChecksStore.record(_id).delete(await _db);
            message = 'Spot Checks uploaded successfully';
            success = true;

          } else {
            await FirebaseFirestore.instance.collection('spot_checks').doc(snap.id).delete();
          }

        } on TimeoutException catch (_) {
          // A timeout occurred.
          message = 'Network Timeout communicating with the server, unable to upload Spot Checks';

        } catch (e) {
          print(e);
          message = e.toString();

          print(e);
        }
      }

    } else {

      message = 'No data connection, Spot Checks has been saved locally, please upload when you have a valid connection';
      success = true;

    }

    if(success) resetTemporaryRecord(jobId);
    GlobalFunctions.dismissLoadingDialog();
    if(edit){
      _navigationService.goBack();
      _navigationService.goBack();
    }
    GlobalFunctions.showToast(message);
    return success;


  }

  Future<bool> editSpotChecks(String jobId, [bool edit = false]) async {

    GlobalFunctions.showLoadingDialog('Editing Spot Checks...');
    String message = '';
    bool success = false;

    Map<String, dynamic> spotChecks = await getTemporaryRecord(true, jobId);

    bool hasDataConnection = await GlobalFunctions.hasDataConnection();

    if(hasDataConnection){

      bool isTokenExpired = GlobalFunctions.isTokenExpired();
      bool authenticated = true;

      if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

      if(authenticated){


        try {

          await FirebaseFirestore.instance.collection('spot_checks').doc(spotChecks[Strings.documentId]).update({
            Strings.jobId: '1',
            Strings.formVersion: '1',
            Strings.jobRef: GlobalFunctions.databaseValueString(spotChecks[Strings.jobRefRef]) + GlobalFunctions.databaseValueString(spotChecks[Strings.jobRefNo]),
            Strings.jobRefLowercase: GlobalFunctions.databaseValueString(spotChecks[Strings.jobRefRef]).toLowerCase() + GlobalFunctions.databaseValueString(spotChecks[Strings.jobRefNo]).toLowerCase(),
            Strings.jobRefRef: GlobalFunctions.databaseValueString(spotChecks[Strings.jobRefRef]),
            Strings.jobRefNo:  int.parse(spotChecks[Strings.jobRefNo]),
            Strings.scStaff1: spotChecks[Strings.scStaff1],
            Strings.scStaff2: spotChecks[Strings.scStaff2],
            Strings.scStaff3: spotChecks[Strings.scStaff3],
            Strings.scStaff4: spotChecks[Strings.scStaff4],
            Strings.scStaff5: spotChecks[Strings.scStaff5],
            Strings.scStaff6: spotChecks[Strings.scStaff6],
            Strings.scStaff7: spotChecks[Strings.scStaff7],
            Strings.scStaff8: spotChecks[Strings.scStaff8],
            Strings.scStaff9: spotChecks[Strings.scStaff9],
            Strings.scStaff10: spotChecks[Strings.scStaff10],
            Strings.scOnTimeYes: spotChecks[Strings.scOnTimeYes],
            Strings.scOnTimeNo: spotChecks[Strings.scOnTimeNo],
            Strings.scCorrectUniformYes: spotChecks[Strings.scCorrectUniformYes],
            Strings.scCorrectUniformNo: spotChecks[Strings.scCorrectUniformNo],
            Strings.scPegasusBadgeYes: spotChecks[Strings.scPegasusBadgeYes],
            Strings.scPegasusBadgeNo: spotChecks[Strings.scPegasusBadgeNo],
            Strings.scVehicleChecksYes: spotChecks[Strings.scVehicleChecksYes],
            Strings.scVehicleChecksNo: spotChecks[Strings.scVehicleChecksNo],
            Strings.scCollectionStaffIntroduceYes: spotChecks[Strings.scCollectionStaffIntroduceYes],
            Strings.scCollectionStaffIntroduceNo: spotChecks[Strings.scCollectionStaffIntroduceNo],
            Strings.scCollectionTransferReportYes: spotChecks[Strings.scCollectionTransferReportYes],
            Strings.scCollectionTransferReportNo: spotChecks[Strings.scCollectionTransferReportNo],
            Strings.scStaffEngageYes: spotChecks[Strings.scStaffEngageYes],
            Strings.scStaffEngageNo: spotChecks[Strings.scStaffEngageNo],
            Strings.scArrivalStaffIntroduceYes: spotChecks[Strings.scArrivalStaffIntroduceYes],
            Strings.scArrivalStaffIntroduceNo: spotChecks[Strings.scArrivalStaffIntroduceNo],
            Strings.scArrivalTransferReportYes: spotChecks[Strings.scArrivalTransferReportYes],
            Strings.scArrivalTransferReportNo: spotChecks[Strings.scArrivalTransferReportNo],
            Strings.scPhysicalInterventionYes: spotChecks[Strings.scPhysicalInterventionYes],
            Strings.scPhysicalInterventionNo: spotChecks[Strings.scPhysicalInterventionNo],
            Strings.scInfectionControl1Yes: spotChecks[Strings.scInfectionControl1Yes],
            Strings.scInfectionControl1No: spotChecks[Strings.scInfectionControl1No],
            Strings.scInfectionControl2Yes: spotChecks[Strings.scInfectionControl2Yes],
            Strings.scInfectionControl2No: spotChecks[Strings.scInfectionControl2No],
            Strings.scVehicleTidyYes: spotChecks[Strings.scVehicleTidyYes],
            Strings.scVehicleTidyNo: spotChecks[Strings.scVehicleTidyNo],
            Strings.scCompletedTransferReportYes: spotChecks[Strings.scCompletedTransferReportYes],
            Strings.scCompletedTransferReportNo: spotChecks[Strings.scCompletedTransferReportNo],
            Strings.scIssuesIdentified: spotChecks[Strings.scIssuesIdentified],
            Strings.scActionTaken: spotChecks[Strings.scActionTaken],
            Strings.scGoodPractice: spotChecks[Strings.scGoodPractice],
            Strings.scName: spotChecks[Strings.scName],
            Strings.scDate: spotChecks[Strings.scDate] == null ? null : DateTime.parse(spotChecks[Strings.scDate]),
            Strings.serverUploaded: 1,
          });

          //Sembast

          final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
              [Db.Filter.equals(Strings.documentId, selectedSpotChecks[Strings.documentId]), Db.Filter.equals(Strings.jobId, jobId)]
          ));

          await _editedSpotChecksStore.delete(await _db,
              finder: finder);
          message = 'Spot Checks uploaded successfully';
          success = true;
          getSpotChecks();

        } on TimeoutException catch (_) {
          // A timeout occurred.
          message = 'Network Timeout communicating with the server, unable to edit Spot Checks';
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
      //deleteEditedSpotChecks();
    }
    GlobalFunctions.showToast(message);
    return success;


  }


  Future<void> getSpotChecks() async{

    _isLoading = true;
    notifyListeners();
    String message = '';

    List<Map<String, dynamic>> _fetchedSpotChecksList = [];
    try {

      bool hasDataConnection = await GlobalFunctions.hasDataConnection();

      if(!hasDataConnection){

        GlobalFunctions.showToast('No data connection, unable to fetch Spot Checks');
        _spotChecks = [];

      } else {


        bool isTokenExpired = GlobalFunctions.isTokenExpired();
        bool authenticated = true;

        if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

        if(authenticated){


          QuerySnapshot snapshot;

          if(user.role == 'Super User'){
            try{
              snapshot = await FirebaseFirestore.instance.collection('spot_checks').orderBy('job_ref_no', descending: true).limit(10).get().timeout(Duration(seconds: 90));
            } catch(e){
              print(e);
            }
          } else {
            try{
              snapshot = await FirebaseFirestore.instance.collection('spot_checks').where(
                  'uid', isEqualTo: user.uid).orderBy('job_ref_no', descending: true).limit(10).get().timeout(Duration(seconds: 90));
            } catch(e){
              print(e);
            }
          }

          Map<String, dynamic> snapshotData = {};

          if(snapshot.docs.length < 1){
            message = 'No Spot Checks found';
          } else {
            for (DocumentSnapshot snap in snapshot.docs) {

              snapshotData = snap.data();

              Uint8List scSignature;

              if (snapshotData[Strings.scSignature] != null) {
                Reference storageRef =
                FirebaseStorage.instance.ref().child('spotChecksImages/' + snap.id + '/scSignature.jpg');

                if(kIsWeb){
                  storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/spotChecksImages/' + snap.id + '/scSignature.jpg');

                }

                scSignature = await storageRef.getData(dataLimit);
              }

              final Map<String, dynamic> spotChecks = onlineSpotChecks(snapshotData, snap.id, scSignature);

              _fetchedSpotChecksList.add(spotChecks);
            }

            _spotChecks = _fetchedSpotChecksList;
          }


        }

      }


    } on TimeoutException catch (_) {
      // A timeout occurred.
      message = 'Network Timeout communicating with the server, unable to fetch latest Spot Checks';
    } catch(e){
      print(e);
      message = 'Something went wrong. Please try again';

    }

    _isLoading = false;
    notifyListeners();
    _selSpotChecksId = null;
    if(message != '') GlobalFunctions.showToast(message);

  }

  Future<void> getMoreSpotChecks() async{

    String message = '';

    List<Map<String, dynamic>> _fetchedSpotChecksList = [];

    try {

      bool hasDataConnection = await GlobalFunctions.hasDataConnection();

      if(!hasDataConnection){

        GlobalFunctions.showToast('No data connection, unable to fetch Spot Checks');

      } else {


        bool isTokenExpired = GlobalFunctions.isTokenExpired();
        bool authenticated = true;

        if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

        if(authenticated){


          QuerySnapshot snapshot;
          int currentLength = _spotChecks.length;
          //DateTime latestDate = DateTime.parse(_spotChecks[currentLength - 1][Strings.timestamp]);
          int latestNo = int.parse(_spotChecks[currentLength - 1][Strings.jobRefNo]);


          if(user.role == 'Super User'){
            try {
              snapshot = await FirebaseFirestore.instance.collection('spot_checks').where(Strings.jobRefNo, isLessThan: latestNo).orderBy(
                  'job_ref_no', descending: true).limit(10)
                  .get()
                  .timeout(Duration(seconds: 90));
            } catch(e) {
              print(e);
            }

          } else {
            try {
              snapshot = await FirebaseFirestore.instance.collection('spot_checks').where(
                  'uid', isEqualTo: user.uid).where(Strings.jobRefNo, isLessThan: latestNo).orderBy(
                  'job_ref_no', descending: true).limit(10)
                  .get()
                  .timeout(Duration(seconds: 90));
            } catch(e) {
              print(e);
            }
          }


          Map<String, dynamic> snapshotData = {};

          if(snapshot.docs.length < 1){
            message = 'No more Spot Checks found';
          } else {
            for (DocumentSnapshot snap in snapshot.docs) {

              snapshotData = snap.data();

              Uint8List scSignature;

              if (snapshotData[Strings.scSignature] != null) {
                Reference storageRef =
                FirebaseStorage.instance.ref().child('spotChecksImages/' + snap.id + '/scSignature.jpg');

                if(kIsWeb){
                  storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/spotChecksImages/' + snap.id + '/scSignature.jpg');

                }

                scSignature = await storageRef.getData(dataLimit);
              }

              final Map<String, dynamic> spotChecks = onlineSpotChecks(snapshotData, snap.id, scSignature);

              _fetchedSpotChecksList.add(spotChecks);

            }

            _spotChecks.addAll(_fetchedSpotChecksList);
          }

        }

      }


    } on TimeoutException catch (_) {
      // A timeout occurred.
      message = 'Network Timeout communicating with the server, unable to fetch latest Spot Checks';
    } catch(e){
      print(e);
      message = 'Something went wrong. Please try again';

    }

    _isLoading = false;
    notifyListeners();
    _selSpotChecksId = null;
    if(message != '') GlobalFunctions.showToast(message);

  }

  Future<bool> searchSpotChecks(DateTime dateFrom, DateTime dateTo, String jobRefRef, int jobRefNo, String selectedUser) async{

    _isLoading = true;
    notifyListeners();
    bool success = false;
    String message = '';
    GlobalFunctions.showLoadingDialog('Searching Forms');
    List<Map<String, dynamic>> _fetchedSpotChecksList = [];

    try {

      bool hasDataConnection = await GlobalFunctions.hasDataConnection();

      if(!hasDataConnection){

        message = 'No Data Connection, unable to search Spot Checks';

      } else {


        bool isTokenExpired = GlobalFunctions.isTokenExpired();
        bool authenticated = true;

        if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

        if(authenticated){


          QuerySnapshot snapshot;

          if(user.role == 'Super User'){



            if(dateFrom != null && dateTo != null){


              if(jobRefRef == 'Select One' && (jobRefNo == null)){


                if(selectedUser != null){
                  try{
                    snapshot =
                    await FirebaseFirestore.instance.collection('spot_checks').where(Strings.uid, isEqualTo: selectedUser).where(Strings.scDate, isGreaterThanOrEqualTo: dateFrom).where(Strings.scDate, isLessThanOrEqualTo: dateTo)
                        .get()
                        .timeout(Duration(seconds: 90));
                  } catch(e){
                    print(e);
                  }
                } else {
                  try{
                    snapshot =
                    await FirebaseFirestore.instance.collection('spot_checks').where(Strings.scDate, isGreaterThanOrEqualTo: dateFrom).where(Strings.scDate, isLessThanOrEqualTo: dateTo)
                        .get()
                        .timeout(Duration(seconds: 90));
                  } catch(e){
                    print(e);
                  }
                }


              } else if(jobRefRef != 'Select One' && jobRefNo != null) {

                if(selectedUser != null){
                  try{
                    snapshot =
                    await FirebaseFirestore.instance.collection('spot_checks').where(Strings.uid, isEqualTo: selectedUser).where(Strings.scDate, isGreaterThanOrEqualTo: dateFrom).where(Strings.scDate, isLessThanOrEqualTo: dateTo)
                        .where(Strings.jobRefRef, isEqualTo: jobRefRef).where(Strings.jobRefNo, isEqualTo: jobRefNo).get()
                        .timeout(Duration(seconds: 90));
                  } catch(e){
                    print(e);
                  }
                } else {
                  try{
                    snapshot =
                    await FirebaseFirestore.instance.collection('spot_checks').where(Strings.scDate, isGreaterThanOrEqualTo: dateFrom).where(Strings.scDate, isLessThanOrEqualTo: dateTo)
                        .where(Strings.jobRefRef, isEqualTo: jobRefRef).where(Strings.jobRefNo, isEqualTo: jobRefNo)
                        .get()
                        .timeout(Duration(seconds: 90));
                  } catch(e){
                    print(e);
                  }
                }




              } else if(jobRefRef != 'Select One' && (jobRefNo == null)) {

                if(selectedUser != null){
                  try{
                    snapshot =
                    await FirebaseFirestore.instance.collection('spot_checks').where(Strings.uid, isEqualTo: selectedUser).where(Strings.scDate, isGreaterThanOrEqualTo: dateFrom).where(Strings.scDate, isLessThanOrEqualTo: dateTo)
                        .where(Strings.jobRefRef, isEqualTo: jobRefRef).get()
                        .timeout(Duration(seconds: 90));
                  } catch(e){
                    print(e);
                  }
                } else {
                  try{
                    snapshot =
                    await FirebaseFirestore.instance.collection('spot_checks').where(Strings.scDate, isGreaterThanOrEqualTo: dateFrom).where(Strings.scDate, isLessThanOrEqualTo: dateTo)
                        .where(Strings.jobRefRef, isEqualTo: jobRefRef)
                       .get()
                        .timeout(Duration(seconds: 90));
                  } catch(e){
                    print(e);
                  }
                }




              } else if(jobRefRef == 'Select One' && jobRefNo != null) {

                if(selectedUser != null){
                  try{
                    snapshot =
                    await FirebaseFirestore.instance.collection('spot_checks').where(Strings.uid, isEqualTo: selectedUser).where(Strings.scDate, isGreaterThanOrEqualTo: dateFrom).where(Strings.scDate, isLessThanOrEqualTo: dateTo)
                        .where(Strings.jobRefNo, isEqualTo: jobRefNo).get()
                        .timeout(Duration(seconds: 90));
                  } catch(e){
                    print(e);
                  }
                } else {
                  try{
                    snapshot =
                    await FirebaseFirestore.instance.collection('spot_checks').where(Strings.scDate, isGreaterThanOrEqualTo: dateFrom).where(Strings.scDate, isLessThanOrEqualTo: dateTo)
                        .where(Strings.jobRefNo, isEqualTo: jobRefNo)
                        .get()
                        .timeout(Duration(seconds: 90));
                  } catch(e){
                    print(e);
                  }
                }




              }

            } else {


              if(jobRefRef == 'Select One' && (jobRefNo == null)){


                if(selectedUser != null){
                  try{
                    snapshot =
                    await FirebaseFirestore.instance.collection('spot_checks').where(Strings.uid, isEqualTo: selectedUser)
                        .get()
                        .timeout(Duration(seconds: 90));
                  } catch(e){
                    print(e);
                  }
                } else {
                  try{
                    snapshot =
                    await FirebaseFirestore.instance.collection('spot_checks')
                        .get()
                        .timeout(Duration(seconds: 90));
                  } catch(e){
                    print(e);
                  }
                }


              } else if(jobRefRef != 'Select One' && jobRefNo != null) {

                if(selectedUser != null){
                  try{
                    snapshot =
                    await FirebaseFirestore.instance.collection('spot_checks').where(Strings.uid, isEqualTo: selectedUser)
                        .where(Strings.jobRefRef, isEqualTo: jobRefRef).where(Strings.jobRefNo, isEqualTo: jobRefNo).get()
                        .timeout(Duration(seconds: 90));
                  } catch(e){
                    print(e);
                  }
                } else {
                  try{
                    snapshot =
                    await FirebaseFirestore.instance.collection('spot_checks')
                        .where(Strings.jobRefRef, isEqualTo: jobRefRef).where(Strings.jobRefNo, isEqualTo: jobRefNo)
                        .get()
                        .timeout(Duration(seconds: 90));
                  } catch(e){
                    print(e);
                  }
                }




              } else if(jobRefRef != 'Select One' && (jobRefNo == null)) {

                if(selectedUser != null){
                  try{
                    snapshot =
                    await FirebaseFirestore.instance.collection('spot_checks').where(Strings.uid, isEqualTo: selectedUser)
                        .where(Strings.jobRefRef, isEqualTo: jobRefRef).get()
                        .timeout(Duration(seconds: 90));
                  } catch(e){
                    print(e);
                  }
                } else {
                  try{
                    snapshot =
                    await FirebaseFirestore.instance.collection('spot_checks')
                        .where(Strings.jobRefRef, isEqualTo: jobRefRef)
                        .get()
                        .timeout(Duration(seconds: 90));
                  } catch(e){
                    print(e);
                  }
                }




              } else if(jobRefRef == 'Select One' && jobRefNo != null) {

                if(selectedUser != null){
                  try{
                    snapshot =
                    await FirebaseFirestore.instance.collection('spot_checks').where(Strings.uid, isEqualTo: selectedUser)
                        .where(Strings.jobRefNo, isEqualTo: jobRefNo).get()
                        .timeout(Duration(seconds: 90));
                  } catch(e){
                    print(e);
                  }
                } else {
                  try{
                    snapshot =
                    await FirebaseFirestore.instance.collection('spot_checks')
                        .where(Strings.jobRefNo, isEqualTo: jobRefNo)
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


              if(jobRefRef == 'Select One' && (jobRefNo == null)){


                  try{
                    snapshot =
                    await FirebaseFirestore.instance.collection('spot_checks').where(Strings.uid, isEqualTo: user.uid).where(Strings.scDate, isGreaterThanOrEqualTo: dateFrom).where(Strings.scDate, isLessThanOrEqualTo: dateTo)
                        .get()
                        .timeout(Duration(seconds: 90));
                  } catch(e){
                    print(e);
                  }



              } else if(jobRefRef != 'Select One' && jobRefNo != null) {

                  try{
                    snapshot =
                    await FirebaseFirestore.instance.collection('spot_checks').where(Strings.uid, isEqualTo: user.uid).where(Strings.scDate, isGreaterThanOrEqualTo: dateFrom).where(Strings.scDate, isLessThanOrEqualTo: dateTo)
                        .where(Strings.jobRefRef, isEqualTo: jobRefRef).where(Strings.jobRefNo, isEqualTo: jobRefNo)
                        .get()
                        .timeout(Duration(seconds: 90));
                  } catch(e){
                    print(e);
                  }





              } else if(jobRefRef != 'Select One' && (jobRefNo == null)) {


                  try{
                    snapshot =
                    await FirebaseFirestore.instance.collection('spot_checks').where(Strings.uid, isEqualTo: user.uid).where(Strings.scDate, isGreaterThanOrEqualTo: dateFrom).where(Strings.scDate, isLessThanOrEqualTo: dateTo)
                        .where(Strings.jobRefRef, isEqualTo: jobRefRef)
                        .get()
                        .timeout(Duration(seconds: 90));
                  } catch(e){
                    print(e);
                  }





              } else if(jobRefRef == 'Select One' && jobRefNo != null) {

                  try{
                    snapshot =
                    await FirebaseFirestore.instance.collection('spot_checks').where(Strings.uid, isEqualTo: user.uid).where(Strings.scDate, isGreaterThanOrEqualTo: dateFrom).where(Strings.scDate, isLessThanOrEqualTo: dateTo)
                        .where(Strings.jobRefNo, isEqualTo: jobRefNo)
                        .get()
                        .timeout(Duration(seconds: 90));
                  } catch(e){
                    print(e);
                  }





              }

            } else {


              if(jobRefRef == 'Select One' && (jobRefNo == null)){

                  try{
                    snapshot =
                    await FirebaseFirestore.instance.collection('spot_checks').where(Strings.uid, isEqualTo: user.uid)
                        .get()
                        .timeout(Duration(seconds: 90));
                  } catch(e){
                    print(e);
                  }



              } else if(jobRefRef != 'Select One' && jobRefNo != null) {


                  try{
                    snapshot =
                    await FirebaseFirestore.instance.collection('spot_checks').where(Strings.uid, isEqualTo: user.uid)
                        .where(Strings.jobRefRef, isEqualTo: jobRefRef).where(Strings.jobRefNo, isEqualTo: jobRefNo)
                        .get()
                        .timeout(Duration(seconds: 90));
                  } catch(e){
                    print(e);
                  }





              } else if(jobRefRef != 'Select One' && (jobRefNo == null)) {

                  try{
                    snapshot =
                    await FirebaseFirestore.instance.collection('spot_checks').where(Strings.uid, isEqualTo: user.uid)
                        .where(Strings.jobRefRef, isEqualTo: jobRefRef)
                        .get()
                        .timeout(Duration(seconds: 90));
                  } catch(e){
                    print(e);
                  }





              } else if(jobRefRef == 'Select One' && jobRefNo != null) {
                  try{
                    snapshot =
                    await FirebaseFirestore.instance.collection('spot_checks').where(Strings.uid, isEqualTo: user.uid)
                        .where(Strings.jobRefNo, isEqualTo: jobRefNo)
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
            message = 'No Spot Checks found';
          } else {
            List<QueryDocumentSnapshot> snapDocs = snapshot.docs;
            snapDocs.sort((a, b) => (b.get('job_ref_no')).compareTo(a.get('job_ref_no')));

            for (DocumentSnapshot snap in snapDocs) {

              snapshotData = snap.data();

              Uint8List scSignature;

              if (snapshotData[Strings.scSignature] != null) {
                Reference storageRef =
                FirebaseStorage.instance.ref().child('spotChecksImages/' + snap.id + '/scSignature.jpg');

                if(kIsWeb){
                  storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/spotChecksImages/' + snap.id + '/scSignature.jpg');

                }

                scSignature = await storageRef.getData(dataLimit);
              }

              final Map<String, dynamic> spotChecks = onlineSpotChecks(snapshotData, snap.id, scSignature);

              _fetchedSpotChecksList.add(spotChecks);

            }

            _spotChecks = _fetchedSpotChecksList;
            success = true;
          }


        }

      }


    } on TimeoutException catch (_) {
      // A timeout occurred.
      message = 'Network Timeout communicating with the server, unable to search Spot Checks';
    } catch(e){
      print(e);
      message = 'Something went wrong. Please try again';

    }

    _isLoading = false;
    notifyListeners();
    _selSpotChecksId = null;
    GlobalFunctions.dismissLoadingDialog();
    if(message != '') GlobalFunctions.showToast(message);
    return success;

  }


  Map<String, dynamic> localSpotChecks(Map<String, dynamic> localRecord){
    return {
      Strings.documentId: GlobalFunctions.databaseValueString(localRecord[Strings.documentId]),
      Strings.uid: GlobalFunctions.databaseValueString(localRecord[Strings.uid]),
      Strings.jobId: localRecord[Strings.jobId],
      Strings.formVersion: localRecord[Strings.formVersion],
      Strings.jobRef: localRecord[Strings.jobRef],
      Strings.jobRefRef: localRecord[Strings.jobRefRef],
      Strings.jobRefNo: localRecord[Strings.jobRefNo],
      Strings.scStaff1: localRecord[Strings.scStaff1],
      Strings.scStaff2: localRecord[Strings.scStaff2],
      Strings.scStaff3: localRecord[Strings.scStaff3],
      Strings.scStaff4: localRecord[Strings.scStaff4],
      Strings.scStaff5: localRecord[Strings.scStaff5],
      Strings.scStaff6: localRecord[Strings.scStaff6],
      Strings.scStaff7: localRecord[Strings.scStaff7],
      Strings.scStaff8: localRecord[Strings.scStaff8],
      Strings.scStaff9: localRecord[Strings.scStaff9],
      Strings.scStaff10: localRecord[Strings.scStaff10],
      Strings.scOnTimeYes: localRecord[Strings.scOnTimeYes],
      Strings.scOnTimeNo: localRecord[Strings.scOnTimeNo],
      Strings.scCorrectUniformYes: localRecord[Strings.scCorrectUniformYes],
      Strings.scCorrectUniformNo: localRecord[Strings.scCorrectUniformNo],
      Strings.scPegasusBadgeYes: localRecord[Strings.scPegasusBadgeYes],
      Strings.scPegasusBadgeNo: localRecord[Strings.scPegasusBadgeNo],
      Strings.scVehicleChecksYes: localRecord[Strings.scVehicleChecksYes],
      Strings.scVehicleChecksNo: localRecord[Strings.scVehicleChecksNo],
      Strings.scCollectionStaffIntroduceYes: localRecord[Strings.scCollectionStaffIntroduceYes],
      Strings.scCollectionStaffIntroduceNo: localRecord[Strings.scCollectionStaffIntroduceNo],
      Strings.scCollectionTransferReportYes: localRecord[Strings.scCollectionTransferReportYes],
      Strings.scCollectionTransferReportNo: localRecord[Strings.scCollectionTransferReportNo],
      Strings.scStaffEngageYes: localRecord[Strings.scStaffEngageYes],
      Strings.scStaffEngageNo: localRecord[Strings.scStaffEngageNo],
      Strings.scArrivalStaffIntroduceYes: localRecord[Strings.scArrivalStaffIntroduceYes],
      Strings.scArrivalStaffIntroduceNo: localRecord[Strings.scArrivalStaffIntroduceNo],
      Strings.scArrivalTransferReportYes: localRecord[Strings.scArrivalTransferReportYes],
      Strings.scArrivalTransferReportNo: localRecord[Strings.scArrivalTransferReportNo],
      Strings.scPhysicalInterventionYes: localRecord[Strings.scPhysicalInterventionYes],
      Strings.scPhysicalInterventionNo: localRecord[Strings.scPhysicalInterventionNo],
      Strings.scInfectionControl1Yes: localRecord[Strings.scInfectionControl1Yes],
      Strings.scInfectionControl1No: localRecord[Strings.scInfectionControl1No],
      Strings.scInfectionControl2Yes: localRecord[Strings.scInfectionControl2Yes],
      Strings.scInfectionControl2No: localRecord[Strings.scInfectionControl2No],
      Strings.scVehicleTidyYes: localRecord[Strings.scVehicleTidyYes],
      Strings.scVehicleTidyNo: localRecord[Strings.scVehicleTidyNo],
      Strings.scCompletedTransferReportYes: localRecord[Strings.scCompletedTransferReportYes],
      Strings.scCompletedTransferReportNo: localRecord[Strings.scCompletedTransferReportNo],
      Strings.scIssuesIdentified: localRecord[Strings.scIssuesIdentified],
      Strings.scActionTaken: localRecord[Strings.scActionTaken],
      Strings.scGoodPractice: localRecord[Strings.scGoodPractice],
      Strings.scName: localRecord[Strings.scName],
      Strings.scSignature: localRecord[Strings.scSignature],
      Strings.scSignaturePoints: localRecord[Strings.scSignaturePoints],
      Strings.scDate: localRecord[Strings.scDate],
      Strings.serverUploaded: localRecord[Strings.serverUploaded],
      Strings.timestamp: localRecord[Strings.timestamp] == null ? null : localRecord[Strings.timestamp]
    };
  }

  Map<String, dynamic> onlineSpotChecks(Map<String, dynamic> localRecord, String docId, Uint8List scSignature){
    return {
      Strings.documentId: docId,
      Strings.uid: GlobalFunctions.databaseValueString(localRecord[Strings.uid]),
      Strings.jobId: localRecord[Strings.jobId],
      Strings.formVersion: localRecord[Strings.formVersion],
      Strings.jobRef: localRecord[Strings.jobRef],
      Strings.jobRefRef: localRecord[Strings.jobRefRef],
      Strings.jobRefNo: localRecord[Strings.jobRefNo].toString(),
      Strings.scStaff1: localRecord[Strings.scStaff1],
      Strings.scStaff2: localRecord[Strings.scStaff2],
      Strings.scStaff3: localRecord[Strings.scStaff3],
      Strings.scStaff4: localRecord[Strings.scStaff4],
      Strings.scStaff5: localRecord[Strings.scStaff5],
      Strings.scStaff6: localRecord[Strings.scStaff6],
      Strings.scStaff7: localRecord[Strings.scStaff7],
      Strings.scStaff8: localRecord[Strings.scStaff8],
      Strings.scStaff9: localRecord[Strings.scStaff9],
      Strings.scStaff10: localRecord[Strings.scStaff10],
      Strings.scOnTimeYes: localRecord[Strings.scOnTimeYes],
      Strings.scOnTimeNo: localRecord[Strings.scOnTimeNo],
      Strings.scCorrectUniformYes: localRecord[Strings.scCorrectUniformYes],
      Strings.scCorrectUniformNo: localRecord[Strings.scCorrectUniformNo],
      Strings.scPegasusBadgeYes: localRecord[Strings.scPegasusBadgeYes],
      Strings.scPegasusBadgeNo: localRecord[Strings.scPegasusBadgeNo],
      Strings.scVehicleChecksYes: localRecord[Strings.scVehicleChecksYes],
      Strings.scVehicleChecksNo: localRecord[Strings.scVehicleChecksNo],
      Strings.scCollectionStaffIntroduceYes: localRecord[Strings.scCollectionStaffIntroduceYes],
      Strings.scCollectionStaffIntroduceNo: localRecord[Strings.scCollectionStaffIntroduceNo],
      Strings.scCollectionTransferReportYes: localRecord[Strings.scCollectionTransferReportYes],
      Strings.scCollectionTransferReportNo: localRecord[Strings.scCollectionTransferReportNo],
      Strings.scStaffEngageYes: localRecord[Strings.scStaffEngageYes],
      Strings.scStaffEngageNo: localRecord[Strings.scStaffEngageNo],
      Strings.scArrivalStaffIntroduceYes: localRecord[Strings.scArrivalStaffIntroduceYes],
      Strings.scArrivalStaffIntroduceNo: localRecord[Strings.scArrivalStaffIntroduceNo],
      Strings.scArrivalTransferReportYes: localRecord[Strings.scArrivalTransferReportYes],
      Strings.scArrivalTransferReportNo: localRecord[Strings.scArrivalTransferReportNo],
      Strings.scPhysicalInterventionYes: localRecord[Strings.scPhysicalInterventionYes],
      Strings.scPhysicalInterventionNo: localRecord[Strings.scPhysicalInterventionNo],
      Strings.scInfectionControl1Yes: localRecord[Strings.scInfectionControl1Yes],
      Strings.scInfectionControl1No: localRecord[Strings.scInfectionControl1No],
      Strings.scInfectionControl2Yes: localRecord[Strings.scInfectionControl2Yes],
      Strings.scInfectionControl2No: localRecord[Strings.scInfectionControl2No],
      Strings.scVehicleTidyYes: localRecord[Strings.scVehicleTidyYes],
      Strings.scVehicleTidyNo: localRecord[Strings.scVehicleTidyNo],
      Strings.scCompletedTransferReportYes: localRecord[Strings.scCompletedTransferReportYes],
      Strings.scCompletedTransferReportNo: localRecord[Strings.scCompletedTransferReportNo],
      Strings.scIssuesIdentified: localRecord[Strings.scIssuesIdentified],
      Strings.scActionTaken: localRecord[Strings.scActionTaken],
      Strings.scGoodPractice: localRecord[Strings.scGoodPractice],
      Strings.scName: localRecord[Strings.scName],
      Strings.scSignature: scSignature,
      Strings.scDate: localRecord[Strings.scDate] == null ? null : DateTime
          .fromMillisecondsSinceEpoch(
          localRecord[Strings.scDate].millisecondsSinceEpoch)
          .toIso8601String(),
      Strings.serverUploaded: localRecord[Strings.serverUploaded],
      Strings.timestamp: localRecord[Strings.timestamp] == null ? null : DateTime
          .fromMillisecondsSinceEpoch(
          localRecord['timestamp'].millisecondsSinceEpoch)
          .toIso8601String()
    };
  }

  Map<String, dynamic> editedSpotChecks(Map<String, dynamic> localRecord){
    return {
      Strings.documentId: GlobalFunctions.databaseValueString(localRecord[Strings.documentId]),
      Strings.uid: GlobalFunctions.databaseValueString(localRecord[Strings.uid]),
      Strings.jobId: localRecord[Strings.jobId],
      Strings.formVersion: localRecord[Strings.formVersion],
      Strings.jobRef: localRecord[Strings.jobRef],
      Strings.jobRefRef: localRecord[Strings.jobRefRef],
      Strings.jobRefNo: localRecord[Strings.jobRefNo],
      Strings.scStaff1: localRecord[Strings.scStaff1],
      Strings.scStaff2: localRecord[Strings.scStaff2],
      Strings.scStaff3: localRecord[Strings.scStaff3],
      Strings.scStaff4: localRecord[Strings.scStaff4],
      Strings.scStaff5: localRecord[Strings.scStaff5],
      Strings.scStaff6: localRecord[Strings.scStaff6],
      Strings.scStaff7: localRecord[Strings.scStaff7],
      Strings.scStaff8: localRecord[Strings.scStaff8],
      Strings.scStaff9: localRecord[Strings.scStaff9],
      Strings.scStaff10: localRecord[Strings.scStaff10],
      Strings.scOnTimeYes: localRecord[Strings.scOnTimeYes],
      Strings.scOnTimeNo: localRecord[Strings.scOnTimeNo],
      Strings.scCorrectUniformYes: localRecord[Strings.scCorrectUniformYes],
      Strings.scCorrectUniformNo: localRecord[Strings.scCorrectUniformNo],
      Strings.scPegasusBadgeYes: localRecord[Strings.scPegasusBadgeYes],
      Strings.scPegasusBadgeNo: localRecord[Strings.scPegasusBadgeNo],
      Strings.scVehicleChecksYes: localRecord[Strings.scVehicleChecksYes],
      Strings.scVehicleChecksNo: localRecord[Strings.scVehicleChecksNo],
      Strings.scCollectionStaffIntroduceYes: localRecord[Strings.scCollectionStaffIntroduceYes],
      Strings.scCollectionStaffIntroduceNo: localRecord[Strings.scCollectionStaffIntroduceNo],
      Strings.scCollectionTransferReportYes: localRecord[Strings.scCollectionTransferReportYes],
      Strings.scCollectionTransferReportNo: localRecord[Strings.scCollectionTransferReportNo],
      Strings.scStaffEngageYes: localRecord[Strings.scStaffEngageYes],
      Strings.scStaffEngageNo: localRecord[Strings.scStaffEngageNo],
      Strings.scArrivalStaffIntroduceYes: localRecord[Strings.scArrivalStaffIntroduceYes],
      Strings.scArrivalStaffIntroduceNo: localRecord[Strings.scArrivalStaffIntroduceNo],
      Strings.scArrivalTransferReportYes: localRecord[Strings.scArrivalTransferReportYes],
      Strings.scArrivalTransferReportNo: localRecord[Strings.scArrivalTransferReportNo],
      Strings.scPhysicalInterventionYes: localRecord[Strings.scPhysicalInterventionYes],
      Strings.scPhysicalInterventionNo: localRecord[Strings.scPhysicalInterventionNo],
      Strings.scInfectionControl1Yes: localRecord[Strings.scInfectionControl1Yes],
      Strings.scInfectionControl1No: localRecord[Strings.scInfectionControl1No],
      Strings.scInfectionControl2Yes: localRecord[Strings.scInfectionControl2Yes],
      Strings.scInfectionControl2No: localRecord[Strings.scInfectionControl2No],
      Strings.scVehicleTidyYes: localRecord[Strings.scVehicleTidyYes],
      Strings.scVehicleTidyNo: localRecord[Strings.scVehicleTidyNo],
      Strings.scCompletedTransferReportYes: localRecord[Strings.scCompletedTransferReportYes],
      Strings.scCompletedTransferReportNo: localRecord[Strings.scCompletedTransferReportNo],
      Strings.scIssuesIdentified: localRecord[Strings.scIssuesIdentified],
      Strings.scActionTaken: localRecord[Strings.scActionTaken],
      Strings.scGoodPractice: localRecord[Strings.scGoodPractice],
      Strings.scName: localRecord[Strings.scName],
      Strings.scSignature: localRecord[Strings.scSignature],
      Strings.scSignaturePoints: localRecord[Strings.scSignaturePoints],
      Strings.scDate: localRecord[Strings.scDate],
      Strings.serverUploaded: localRecord[Strings.serverUploaded],
      Strings.timestamp: localRecord[Strings.timestamp]
    };
  }



  Future<Map<String, dynamic>> uploadPendingSpotChecks() async {
    _isLoading = true;
    String message = 'Something went wrong!';
    bool success = false;
    List<String> storageUrlList = [];

    try {

      List<dynamic> spotChecksRecords = await getPendingRecords();

      List<Map<String, dynamic>> spotChecks = [];

      for(var spotChecksRecord in spotChecksRecords){
        spotChecks.add(spotChecksRecord.value);
      }


      bool isTokenExpired = GlobalFunctions.isTokenExpired();
      bool authenticated = true;

      if (isTokenExpired)
        authenticated = await authenticationModel.reAuthenticate();

      if (authenticated) {

        for (Map<String, dynamic> spotChecks in spotChecks) {

          success = false;

          await GlobalFunctions.checkFirebaseStorageFail(_databaseHelper);


          DocumentReference ref =
          await FirebaseFirestore.instance.collection('spot_checks').add({
            Strings.uid: user.uid,
            Strings.jobId: '1',
            Strings.formVersion: '1',
            Strings.jobRef: GlobalFunctions.databaseValueString(spotChecks[Strings.jobRefRef]) + GlobalFunctions.databaseValueString(spotChecks[Strings.jobRefNo]),
            Strings.jobRefLowercase: GlobalFunctions.databaseValueString(spotChecks[Strings.jobRefRef]).toLowerCase() + GlobalFunctions.databaseValueString(spotChecks[Strings.jobRefNo]).toLowerCase(),
            Strings.jobRefRef: GlobalFunctions.databaseValueString(spotChecks[Strings.jobRefRef]),
            Strings.jobRefNo: int.parse(spotChecks[Strings.jobRefNo]),
            Strings.scStaff1: spotChecks[Strings.scStaff1],
            Strings.scStaff2: spotChecks[Strings.scStaff2],
            Strings.scStaff3: spotChecks[Strings.scStaff3],
            Strings.scStaff4: spotChecks[Strings.scStaff4],
            Strings.scStaff5: spotChecks[Strings.scStaff5],
            Strings.scStaff6: spotChecks[Strings.scStaff6],
            Strings.scStaff7: spotChecks[Strings.scStaff7],
            Strings.scStaff8: spotChecks[Strings.scStaff8],
            Strings.scStaff9: spotChecks[Strings.scStaff9],
            Strings.scStaff10: spotChecks[Strings.scStaff10],
            Strings.scOnTimeYes: spotChecks[Strings.scOnTimeYes],
            Strings.scOnTimeNo: spotChecks[Strings.scOnTimeNo],
            Strings.scCorrectUniformYes: spotChecks[Strings.scCorrectUniformYes],
            Strings.scCorrectUniformNo: spotChecks[Strings.scCorrectUniformNo],
            Strings.scPegasusBadgeYes: spotChecks[Strings.scPegasusBadgeYes],
            Strings.scPegasusBadgeNo: spotChecks[Strings.scPegasusBadgeNo],
            Strings.scVehicleChecksYes: spotChecks[Strings.scVehicleChecksYes],
            Strings.scVehicleChecksNo: spotChecks[Strings.scVehicleChecksNo],
            Strings.scCollectionStaffIntroduceYes: spotChecks[Strings.scCollectionStaffIntroduceYes],
            Strings.scCollectionStaffIntroduceNo: spotChecks[Strings.scCollectionStaffIntroduceNo],
            Strings.scCollectionTransferReportYes: spotChecks[Strings.scCollectionTransferReportYes],
            Strings.scCollectionTransferReportNo: spotChecks[Strings.scCollectionTransferReportNo],
            Strings.scStaffEngageYes: spotChecks[Strings.scStaffEngageYes],
            Strings.scStaffEngageNo: spotChecks[Strings.scStaffEngageNo],
            Strings.scArrivalStaffIntroduceYes: spotChecks[Strings.scArrivalStaffIntroduceYes],
            Strings.scArrivalStaffIntroduceNo: spotChecks[Strings.scArrivalStaffIntroduceNo],
            Strings.scArrivalTransferReportYes: spotChecks[Strings.scArrivalTransferReportYes],
            Strings.scArrivalTransferReportNo: spotChecks[Strings.scArrivalTransferReportNo],
            Strings.scPhysicalInterventionYes: spotChecks[Strings.scPhysicalInterventionYes],
            Strings.scPhysicalInterventionNo: spotChecks[Strings.scPhysicalInterventionNo],
            Strings.scInfectionControl1Yes: spotChecks[Strings.scInfectionControl1Yes],
            Strings.scInfectionControl1No: spotChecks[Strings.scInfectionControl1No],
            Strings.scInfectionControl2Yes: spotChecks[Strings.scInfectionControl2Yes],
            Strings.scInfectionControl2No: spotChecks[Strings.scInfectionControl2No],
            Strings.scVehicleTidyYes: spotChecks[Strings.scVehicleTidyYes],
            Strings.scVehicleTidyNo: spotChecks[Strings.scVehicleTidyNo],
            Strings.scCompletedTransferReportYes: spotChecks[Strings.scCompletedTransferReportYes],
            Strings.scCompletedTransferReportNo: spotChecks[Strings.scCompletedTransferReportNo],
            Strings.scIssuesIdentified: spotChecks[Strings.scIssuesIdentified],
            Strings.scActionTaken: spotChecks[Strings.scActionTaken],
            Strings.scGoodPractice: spotChecks[Strings.scGoodPractice],
            Strings.scName: spotChecks[Strings.scName],
            Strings.scSignature: null,
            Strings.scDate: spotChecks[Strings.scDate] == null ? null : DateTime.parse(spotChecks[Strings.scDate]),
            Strings.timestamp: FieldValue.serverTimestamp(),
            Strings.serverUploaded: 1,
          });

          DocumentSnapshot snap = await ref.get();

          //Signatures
          String scSignatureUrl;
          bool scSignatureSuccess = true;

          if(spotChecks[Strings.scSignature] != null){
            scSignatureSuccess = false;

            Reference storageRef =
            FirebaseStorage.instance.ref().child('spotChecksImages/' + snap.id + '/scSignature.jpg');

            if(kIsWeb){
              storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/spotChecksImages/' + snap.id + '/scSignature.jpg');
            }
            final UploadTask uploadTask = storageRef.putData(Uint8List.fromList(spotChecks[Strings.scSignature].toList().cast<int>()));
            final TaskSnapshot downloadUrl = (await uploadTask);
            scSignatureUrl = (await downloadUrl.ref.getDownloadURL());
            if(scSignatureUrl != null){
              scSignatureSuccess = true;
              storageUrlList.add('spotChecksImages/' + snap.id + '/scSignature.jpg');
            }

          }


          if(scSignatureSuccess){

            await FirebaseFirestore.instance.collection('spot_checks').doc(snap.id).update({
              Strings.scSignature: scSignatureUrl == null ? null : scSignatureUrl,
            }).timeout(Duration(seconds: 60));

            await deletePendingRecord(spotChecks[Strings.localId]);
            success = true;


          } else {
            await FirebaseFirestore.instance.collection('spot_checks').doc(snap.id).delete();
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


  Future<void> setUpEditedSpotChecks() async{

    Map<String, dynamic> editedReport = editedSpotChecks(selectedSpotChecks);
    Map<String, dynamic> localData = Map.from(editedReport);
    await _databaseHelper.deleteAllRows(Strings.editedSpotChecksTable);
    await _databaseHelper.add(Strings.editedSpotChecksTable, localData);

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
              borderRadius: BorderRadius.all(Radius.circular(5)),
              border: Border.all(width: 1, color: PdfColors.grey),
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
                        width: 100,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          border: Border.all(width: 1, color: PdfColors.grey),
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
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          border: Border.all(width: 1, color: PdfColors.grey),
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

    Widget staffField(String value){
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(constraints: BoxConstraints(minHeight: 20),
              child: Container(
                width: 200,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  border: Border.all(width: 1, color: PdfColors.grey),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(GlobalFunctions.decryptString(value), style: TextStyle(fontSize: 8))
                  ],
                ),
              )),
          Container(height: 5)
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
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          border: Border.all(width: 1, color: PdfColors.grey),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            value1 == 'signature' && signature != null ? Container(height: 20, child: FittedBox(alignment: Alignment.centerLeft, child: Image(ImageProxy(PdfImage(doc,
                                image: signature.data.buffer
                                    .asUint8List(),
                                width: signature.width,
                                height: signature.height))))) : Text(value1 == null || value1 == 'signature' ? '' : value1, style: TextStyle(fontSize: 8))
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
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          border: Border.all(width: 1, color: PdfColors.grey),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            value2 == 'signature' && signature != null ? Container(height: 20, child: FittedBox(alignment: Alignment.centerLeft, child: Image(ImageProxy(PdfImage(doc,
                                image: signature.data.buffer
                                    .asUint8List(),
                                width: signature.width,
                                height: signature.height))))) : Text(value2 == null || value2 == 'signature' ? '' : value2, style: TextStyle(fontSize: 8)),
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
                Container(width: 450, child: Text(text, style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 8))),
                Text('Yes', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 8)),
                Container(width: 5),
                Container(width: 15, height: 15, padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(width: 1, color: PdfColors.grey)),
                    child: Center(child: Text(selectedSpotChecks[yesString] == null || selectedSpotChecks[yesString] == 0 ? '' : 'X', textAlign: TextAlign.center ,style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
                Container(width: 10),
                Text('No', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 8)),
                Container(width: 5),
                Container(width: 15, height: 15, padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(width: 1, color: PdfColors.grey)),
                    child: Center(child: Text(selectedSpotChecks[noString] == null || selectedSpotChecks[noString] == 0 ? '' : 'X', textAlign: TextAlign.center ,style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
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
      FlutterImage.Image scSignatureImage;
      final pegasusLogo = MemoryImage((await rootBundle.load('assets/images/pegasusLogo.png')).buffer.asUint8List(),);

      if (selectedSpotChecks[Strings.scSignature] != null) {
        Uint8List decryptedSignature = await GlobalFunctions.decryptSignature(selectedSpotChecks[Strings.scSignature]);
        scSignatureImage = FlutterImage.decodeImage(decryptedSignature);
      }


      pdf.addPage(MultiPage(
          theme: ThemeData.withFont(base: ttf, bold: ttfBold),
          pageFormat: PdfPageFormat.a4,
          crossAxisAlignment: CrossAxisAlignment.start,
          margin: EdgeInsets.all(40),
          footer: (Context context) {
            return Container(
                alignment: Alignment.centerRight,
                margin: const EdgeInsets.only(top: 5),
                child: Text('Spot Checks Form - Page ${context.pageNumber} of ${context.pagesCount}',
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
                          textField(TextOption.PlainText, selectedSpotChecks[Strings.jobRef]),
                        ]),
                      ]
                  ),

                  Container(height: 50, child: Image(pegasusLogo)
),

                ]
            ),
            Container(height: 10),
            Center(child: Text('Pegasus Spot Checks', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontWeight: FontWeight.bold))),
            Container(height: 20),
            Text('Staff on Duty', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 10, fontWeight: FontWeight.bold)),
            Container(height: 5),
            staffField(selectedSpotChecks[Strings.scStaff1]),
            selectedSpotChecks[Strings.scStaff2] == null || selectedSpotChecks[Strings.scStaff2] == '' ? Container() : staffField(selectedSpotChecks[Strings.scStaff2]),
            selectedSpotChecks[Strings.scStaff3] == null || selectedSpotChecks[Strings.scStaff3] == '' ? Container() : staffField(selectedSpotChecks[Strings.scStaff3]),
            selectedSpotChecks[Strings.scStaff4] == null || selectedSpotChecks[Strings.scStaff4] == '' ? Container() : staffField(selectedSpotChecks[Strings.scStaff4]),
            selectedSpotChecks[Strings.scStaff5] == null || selectedSpotChecks[Strings.scStaff5] == '' ? Container() : staffField(selectedSpotChecks[Strings.scStaff5]),
            selectedSpotChecks[Strings.scStaff6] == null || selectedSpotChecks[Strings.scStaff6] == '' ? Container() : staffField(selectedSpotChecks[Strings.scStaff6]),
            selectedSpotChecks[Strings.scStaff7] == null || selectedSpotChecks[Strings.scStaff7] == '' ? Container() : staffField(selectedSpotChecks[Strings.scStaff7]),
            selectedSpotChecks[Strings.scStaff8] == null || selectedSpotChecks[Strings.scStaff8] == '' ? Container() : staffField(selectedSpotChecks[Strings.scStaff8]),
            selectedSpotChecks[Strings.scStaff9] == null || selectedSpotChecks[Strings.scStaff9] == '' ? Container() : staffField(selectedSpotChecks[Strings.scStaff9]),
            selectedSpotChecks[Strings.scStaff10] == null || selectedSpotChecks[Strings.scStaff10] == '' ? Container() : staffField(selectedSpotChecks[Strings.scStaff10]),
            Container(height: 20),
            yesNoField(Strings.scOnTimeYes, Strings.scOnTimeNo, 'Did staff arrive to base on time?'),
            yesNoField(Strings.scCorrectUniformYes, Strings.scCorrectUniformNo, 'Were staff in correct uniform?'),
            yesNoField(Strings.scPegasusBadgeYes, Strings.scPegasusBadgeNo, 'Were all staff wearing Pegasus ID badge?'),
            yesNoField(Strings.scVehicleChecksYes, Strings.scVehicleChecksNo, 'Were pre vehicle checks completed prior to leaving base?'),
            yesNoField(Strings.scCollectionStaffIntroduceYes, Strings.scCollectionStaffIntroduceNo, 'On arrival to collection unit did all staff introduce themselves?'),
            yesNoField(Strings.scCollectionTransferReportYes, Strings.scCollectionTransferReportNo, 'Was the transfer report completed fully and a detailed handover of the patient received?'),
            yesNoField(Strings.scStaffEngageYes, Strings.scStaffEngageNo, 'During the journey did staff engage with patient appropriately treating them with dignity and respect?'),
            yesNoField(Strings.scArrivalStaffIntroduceYes, Strings.scArrivalStaffIntroduceNo, 'On arrival to destination unit did staff introduce themselves?'),
            yesNoField(Strings.scArrivalTransferReportYes, Strings.scArrivalTransferReportNo, 'Was the transfer report completed fully and a detailed handover of the patient given?'),
            yesNoField(Strings.scPhysicalInterventionYes, Strings.scPhysicalInterventionNo, 'If physical intervention was used was this used utilised for the least amount of time possible in keeping with least restrictive principle?'),
            yesNoField(Strings.scInfectionControl1Yes, Strings.scInfectionControl1No, 'Did staff carry out infection control procedures during transfer i.e. handwashing?'),
            yesNoField(Strings.scInfectionControl2Yes, Strings.scInfectionControl2No, 'Following transfer did staff use infection control procedures to clean vehicle, i.e. touch point, seat?'),
            yesNoField(Strings.scVehicleTidyYes, Strings.scVehicleTidyNo, 'Was the vehicle left clean and tidy?'),
            yesNoField(Strings.scCompletedTransferReportYes, Strings.scCompletedTransferReportNo, 'Was the transfer report fully completed at the end of the journey?'),
            Container(height: 10),
            Text('Issues Identified', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 10, fontWeight: FontWeight.bold)),
            Container(height: 5),
            textField(TextOption.EncryptedText, selectedSpotChecks[Strings.scIssuesIdentified], 700, 200, 200),
            Container(height: 10),
            Text('Action Taken', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 10, fontWeight: FontWeight.bold)),
            Container(height: 5),
            textField(TextOption.EncryptedText, selectedSpotChecks[Strings.scActionTaken], 700, 200, 200),
            Container(height: 10),
            Text('Areas of good practice', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 10, fontWeight: FontWeight.bold)),
            Container(height: 5),
            textField(TextOption.EncryptedText, selectedSpotChecks[Strings.scGoodPractice], 700, 200, 200),
            Container(height: 10),
            singleLineField('Name', selectedSpotChecks[Strings.scName], TextOption.EncryptedText, true),
            doubleLineField('Signed', 'signature', 'Date', selectedSpotChecks[Strings.scDate], TextOption.PlainText, TextOption.Date, scSignatureImage, pdfDoc),

          ]

      ));



      String formDate = selectedSpotChecks[Strings.scDate] == null ? '' : dateFormatDay.format(DateTime.parse(selectedSpotChecks[Strings.scDate]));
      String id = selectedSpotChecks[Strings.documentId];




      if(kIsWeb){

        if(option == ShareOption.Download){
          List<int> pdfList = await pdf.save();
          Uint8List pdfInBytes = Uint8List.fromList(pdfList);

//Create blob and link from bytes
          final blob = html.Blob([pdfInBytes], 'application/pdf');
          final url = html.Url.createObjectUrlFromBlob(blob);
          final anchor = html.document.createElement('a') as html.AnchorElement
            ..href = url
            ..style.display = 'none'
            ..download = 'spot_checks_form_${formDate}_$id.pdf';
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



        final File file = File('$pdfPath/spot_checks_form_${formDate}_$id.pdf');

        if(option == ShareOption.Email){
await file.writeAsBytes(await pdf.save());}

        ConnectivityResult connectivityResult = await Connectivity().checkConnectivity();

        if(connectivityResult != ConnectivityResult.none) {

          if(option == ShareOption.Share) Printing.sharePdf(bytes: await pdf.save(),filename: 'spot_checks_form_${formDate}_$id.pdf');
          if(option == ShareOption.Print) await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());

          if(option == ShareOption.Email) {
            final smtpServer = gmail(emailUsername, emailPassword);

            // Create our message.
            final mailmessage = new Message()
              ..from = new Address(emailUsername, 'Pegasus Medical')
              ..recipients = emailList
              ..subject = 'Completed Spot Checks Form'
              ..html = "<p1>Dear Sir/Madam,</p1>\n<p>Attached is a completed Spot Checks Form from ${user
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



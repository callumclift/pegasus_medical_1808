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
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../utils/database.dart';
import 'package:sembast/sembast.dart' as Db;
import 'package:random_string/random_string.dart' as random_string;

import 'package:universal_html/html.dart' as html;



class TransferReportModel extends ChangeNotifier {

  DatabaseHelper _databaseHelper = DatabaseHelper();
  AuthenticationModel authenticationModel = AuthenticationModel();
  final NavigationService _navigationService = locator<NavigationService>();
  TransferReportModel(this.authenticationModel);

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> _transferReports = [];
  String _selTransferReportId;
  final dateFormatDay = DateFormat("dd-MM-yyyy");

  List<Map<String, dynamic>> get allTransferReports {
    return List.from(_transferReports);
  }
  int get selectedTransferReportIndex {
    return _transferReports.indexWhere((Map<String, dynamic> transferReport) {
      return transferReport[Strings.documentId] == _selTransferReportId;
    });
  }
  String get selectedTransferReportId {
    return _selTransferReportId;
  }

  Map<String, dynamic> get selectedTransferReport {
    if (_selTransferReportId == null) {
      return null;
    }
    return _transferReports.firstWhere((Map<String, dynamic> transferReport) {
      return transferReport[Strings.documentId] == _selTransferReportId;
    });
  }
  void selectTransferReport(String transferReportId) {
    _selTransferReportId = transferReportId;
    if (transferReportId != null) {
      notifyListeners();
    }
  }

  void clearTransferReports(){
    _transferReports = [];
  }



  // Sembast database settings
  static const String TEMPORARY_TRANSFER_REPORTS_STORE_NAME = 'temporary_transfer_reports';
  final _temporaryTransferReportsStore = Db.intMapStoreFactory.store(TEMPORARY_TRANSFER_REPORTS_STORE_NAME);

  static const String TRANSFER_REPORTS_STORE_NAME = 'transfer_reports';
  final _transferReportsStore = Db.intMapStoreFactory.store(TRANSFER_REPORTS_STORE_NAME);

  static const String EDITED_TRANSFER_REPORTS_STORE_NAME = 'edited_transfer_reports';
  final _editedTransferReportsStore = Db.intMapStoreFactory.store(EDITED_TRANSFER_REPORTS_STORE_NAME);

  static const String SAVED_TRANSFER_REPORTS_STORE_NAME = 'saved_transfer_reports';
  final _savedTransferReportsStore = Db.intMapStoreFactory.store(SAVED_TRANSFER_REPORTS_STORE_NAME);

  // Private getter to shorten the amount of code needed to get the
  // singleton instance of an opened database.
  Future<Db.Database> get _db async => await AppDatabase.instance.database;


  Future<void> setupTemporaryRecord() async {

    final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
        [Db.Filter.equals(Strings.uid, user.uid), Db.Filter.equals(Strings.jobId, '1')]
    ));
    List records = await _temporaryTransferReportsStore.find(
      await _db,
      finder: finder,
    );
    if(records.length == 0){
      // Generate a random ID based on the date and a random string for virtual zero chance of duplicates
      int _id = DateTime.now().millisecondsSinceEpoch + int.parse(random_string.randomNumeric(2));
      await _temporaryTransferReportsStore.record(_id).put(await _db,
          {Strings.uid : user.uid, Strings.formVersion: 1, Strings.jobId : '1'});
    }
  }

  Future<Map<String, dynamic>> getTemporaryRecord(bool edit, String selectedJobId, bool saved, int savedId) async{

    List records;

    if(edit){
      final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
          [Db.Filter.equals(Strings.documentId, selectedTransferReport[Strings.documentId]), Db.Filter.equals(Strings.jobId, selectedJobId)]
      ));
      records = await _editedTransferReportsStore.find(
        await _db,
        finder: finder,
      );
    } else if(saved) {
      final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
          [Db.Filter.equals(Strings.uid, user.uid), Db.Filter.equals(Strings.localId, savedId)]
      ));
      records = await _savedTransferReportsStore.find(
        await _db,
        finder: finder,
      );
    } else {
      final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
          [Db.Filter.equals(Strings.uid, user.uid), Db.Filter.equals(Strings.jobId, selectedJobId)]
      ));
      records = await _temporaryTransferReportsStore.find(
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

    List records = await _transferReportsStore.find(
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

    List records = await _transferReportsStore.find(
      await _db,
      finder: finder,
    );

    return records;
  }

  Future <void> deletePendingRecord(int localId) async{
    final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
        [Db.Filter.equals(Strings.uid, user.uid), Db.Filter.equals(Strings.localId, localId)]
    ));

    await _transferReportsStore.delete(
      await _db,
      finder: finder,
    );
  }

  Future <List<dynamic>> getSavedRecords() async{
    final Db.Finder finder = Db.Finder(filter: Db.Filter.equals(Strings.uid, user.uid));
    List records = await _savedTransferReportsStore.find(
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
          [Db.Filter.equals(Strings.documentId, selectedTransferReport[Strings.documentId]), Db.Filter.equals(Strings.jobId, selectedJobId)]
      ));
      records = await _editedTransferReportsStore.find(
        await _db,
        finder: finder,
      );
    } else if(saved){
      final Db.Finder finder = Db.Finder(filter: Db.Filter.equals(Strings.localId, savedId));
      records = await _savedTransferReportsStore.find(
        await _db,
        finder: finder,
      );

    } else {

      final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
          [Db.Filter.equals(Strings.uid, user.uid), Db.Filter.equals(Strings.jobId, selectedJobId)]
      ));
      records = await _temporaryTransferReportsStore.find(
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
      await _editedTransferReportsStore.update(await _db, {field: value},
          finder: finder);
    } else if(saved){
      final Db.Finder finder = Db.Finder(filter: Db.Filter.equals(Strings.localId, savedId));
      await _savedTransferReportsStore.update(await _db, {field: value},
          finder: finder);
    } else {
      final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
          [Db.Filter.equals(Strings.uid, user.uid), Db.Filter.equals(Strings.jobId, selectedJobId)]
      ));
      await _temporaryTransferReportsStore.update(await _db, {field: value},
          finder: finder);
    }

  }

  void deleteEditedRecord() async {
    await _editedTransferReportsStore.delete(await _db);
  }

  Future<void> setUpEditedRecord() async{

    Map<String, dynamic> editedReport = editedTransferReport(selectedTransferReport);
    Map<String, dynamic> localData = Map.from(editedReport);
    await _editedTransferReportsStore.delete(await _db);
    int _id = DateTime.now().millisecondsSinceEpoch + int.parse(random_string.randomNumeric(2));
    await _editedTransferReportsStore.record(_id).put(await _db,
        localData);

  }

  Future<void> deleteAllRows() async {
    await _transferReportsStore.delete(await _db);
  }

  Future<bool> saveForLater(String jobId, bool saved, int savedId) async {

    GlobalFunctions.showLoadingDialog('Saving Transfer Report...');
    String message = '';
    bool success = false;
    int id;

    if(saved){
      id = savedId;
    } else {
      id = DateTime.now().millisecondsSinceEpoch + int.parse(random_string.randomNumeric(2));
    }



    Map<String, dynamic> transferReport = await getTemporaryRecord(false, '1', saved, savedId);

    Map<String, dynamic> localData = {
      Strings.localId: id,
      Strings.documentId: null,
      Strings.uid: user.uid,
      Strings.jobId: '1',
      Strings.formVersion: '1',
      Strings.jobRef: transferReport[Strings.jobRef],
      Strings.date: transferReport[Strings.date],
      Strings.startTime: transferReport[Strings.startTime],
      Strings.finishTime: transferReport[Strings.finishTime],
      Strings.totalHours: transferReport[Strings.totalHours],
      Strings.collectionDetails: transferReport[Strings.collectionDetails],
      Strings.collectionPostcode: transferReport[Strings.collectionPostcode],
      Strings.collectionContactNo: transferReport[Strings.collectionContactNo],
      Strings.destinationDetails: transferReport[Strings.destinationDetails],
      Strings.destinationPostcode: transferReport[Strings.destinationPostcode],
      Strings.destinationContactNo: transferReport[Strings.destinationContactNo],
      Strings.collectionArrivalTime: transferReport[Strings.collectionArrivalTime],
      Strings.collectionDepartureTime: transferReport[Strings.collectionDepartureTime],
      Strings.destinationArrivalTime: transferReport[Strings.destinationArrivalTime],
      Strings.destinationDepartureTime: transferReport[Strings.destinationDepartureTime],
      Strings.vehicleRegNo: transferReport[Strings.vehicleRegNo],
      Strings.startMileage: transferReport[Strings.startMileage],
      Strings.finishMileage: transferReport[Strings.finishMileage],
      Strings.totalMileage: transferReport[Strings.totalMileage],
      Strings.name1: transferReport[Strings.name1],
      Strings.role1: transferReport[Strings.role1],
      Strings.drivingTimes1_1: transferReport[Strings.drivingTimes1_1],
      Strings.drivingTimes1_2: transferReport[Strings.drivingTimes1_2],
      Strings.name2: transferReport[Strings.name2],
      Strings.role2: transferReport[Strings.role2],
      Strings.drivingTimes2_1: transferReport[Strings.drivingTimes2_1],
      Strings.drivingTimes2_2: transferReport[Strings.drivingTimes2_2],
      Strings.name3: transferReport[Strings.name3],
      Strings.role3: transferReport[Strings.role3],
      Strings.drivingTimes3_1: transferReport[Strings.drivingTimes3_1],
      Strings.drivingTimes3_2: transferReport[Strings.drivingTimes3_2],
      Strings.name4: transferReport[Strings.name4],
      Strings.role4: transferReport[Strings.role4],
      Strings.drivingTimes4_1: transferReport[Strings.drivingTimes4_1],
      Strings.drivingTimes4_2: transferReport[Strings.drivingTimes4_2],
      Strings.name5: transferReport[Strings.name5],
      Strings.role5: transferReport[Strings.role5],
      Strings.drivingTimes5_1: transferReport[Strings.drivingTimes5_1],
      Strings.drivingTimes5_2: transferReport[Strings.drivingTimes5_2],
      Strings.name6: transferReport[Strings.name6],
      Strings.role6: transferReport[Strings.role6],
      Strings.drivingTimes6_1: transferReport[Strings.drivingTimes6_1],
      Strings.drivingTimes6_2: transferReport[Strings.drivingTimes6_2],
      Strings.name7: transferReport[Strings.name7],
      Strings.role7: transferReport[Strings.role7],
      Strings.drivingTimes7_1: transferReport[Strings.drivingTimes7_1],
      Strings.drivingTimes7_2: transferReport[Strings.drivingTimes7_2],
      Strings.name8: transferReport[Strings.name8],
      Strings.role8: transferReport[Strings.role8],
      Strings.drivingTimes8_1: transferReport[Strings.drivingTimes8_1],
      Strings.drivingTimes8_2: transferReport[Strings.drivingTimes8_2],
      Strings.name9: transferReport[Strings.name9],
      Strings.role9: transferReport[Strings.role9],
      Strings.drivingTimes9_1: transferReport[Strings.drivingTimes9_1],
      Strings.drivingTimes9_2: transferReport[Strings.drivingTimes9_2],
      Strings.name10: transferReport[Strings.name10],
      Strings.role10: transferReport[Strings.role10],
      Strings.drivingTimes10_1: transferReport[Strings.drivingTimes10_1],
      Strings.drivingTimes10_2: transferReport[Strings.drivingTimes10_2],
      Strings.name11: transferReport[Strings.name11],
      Strings.role11: transferReport[Strings.role11],
      Strings.drivingTimes11_1: transferReport[Strings.drivingTimes11_1],
      Strings.drivingTimes11_2: transferReport[Strings.drivingTimes11_2],
      Strings.collectionUnit: transferReport[Strings.collectionUnit],
      Strings.collectionPosition: transferReport[Strings.collectionPosition],
      Strings.collectionPrintName: transferReport[Strings.collectionPrintName],
      Strings.collectionArrivalTimeEnd: transferReport[Strings.collectionArrivalTimeEnd],
      Strings.collectionSignature: transferReport[Strings.collectionSignature],
      Strings.destinationUnit: transferReport[Strings.destinationUnit],
      Strings.destinationPosition: transferReport[Strings.destinationPosition],
      Strings.destinationPrintName: transferReport[Strings.destinationPrintName],
      Strings.destinationArrivalTimeEnd: transferReport[Strings.destinationArrivalTimeEnd],
      Strings.destinationSignature: transferReport[Strings.destinationSignature],
      Strings.patientName: transferReport[Strings.patientName],
      Strings.dateOfBirth: transferReport[Strings.dateOfBirth],
      Strings.ethnicity: transferReport[Strings.ethnicity],
      Strings.gender: transferReport[Strings.gender],
      Strings.mhaMcaDetails: transferReport[Strings.mhaMcaDetails],
      Strings.diagnosis: transferReport[Strings.diagnosis],
      Strings.currentPresentation: transferReport[Strings.currentPresentation],
      Strings.riskYes: transferReport[Strings.riskYes],
      Strings.riskNo: transferReport[Strings.riskNo],
      Strings.riskExplanation: transferReport[Strings.riskExplanation],
      Strings.forensicHistoryYes: transferReport[Strings.forensicHistoryYes],
      Strings.forensicHistoryNo: transferReport[Strings.forensicHistoryNo],
      Strings.racialGenderConcernsYes: transferReport[Strings.racialGenderConcernsYes],
      Strings.racialGenderConcernsNo: transferReport[Strings.racialGenderConcernsNo],
      Strings.violenceAggressionYes: transferReport[Strings.violenceAggressionYes],
      Strings.violenceAggressionNo: transferReport[Strings.violenceAggressionNo],
      Strings.selfHarmYes: transferReport[Strings.selfHarmYes],
      Strings.selfHarmNo: transferReport[Strings.selfHarmNo],
      Strings.alcoholSubstanceYes: transferReport[Strings.alcoholSubstanceYes],
      Strings.alcoholSubstanceNo: transferReport[Strings.alcoholSubstanceNo],
      Strings.virusesYes: transferReport[Strings.virusesYes],
      Strings.virusesNo: transferReport[Strings.virusesNo],
      Strings.safeguardingYes: transferReport[Strings.safeguardingYes],
      Strings.safeguardingNo: transferReport[Strings.safeguardingNo],
      Strings.physicalHealthConditionsYes: transferReport[Strings.physicalHealthConditionsYes],
      Strings.physicalHealthConditionsNo: transferReport[Strings.physicalHealthConditionsNo],
      Strings.useOfWeaponYes: transferReport[Strings.useOfWeaponYes],
      Strings.useOfWeaponNo: transferReport[Strings.useOfWeaponNo],
      Strings.absconsionRiskYes: transferReport[Strings.absconsionRiskYes],
      Strings.absconsionRiskNo: transferReport[Strings.absconsionRiskNo],
      Strings.forensicHistory: transferReport[Strings.forensicHistory],
      Strings.racialGenderConcerns: transferReport[Strings.racialGenderConcerns],
      Strings.violenceAggression: transferReport[Strings.violenceAggression],
      Strings.selfHarm: transferReport[Strings.selfHarm],
      Strings.alcoholSubstance: transferReport[Strings.alcoholSubstance],
      Strings.viruses: transferReport[Strings.viruses],
      Strings.safeguarding: transferReport[Strings.safeguarding],
      Strings.physicalHealthConditions: transferReport[Strings.physicalHealthConditions],
      Strings.useOfWeapon: transferReport[Strings.useOfWeapon],
      Strings.absconsionRisk: transferReport[Strings.absconsionRisk],
      Strings.patientPropertyYes: transferReport[Strings.patientPropertyYes],
      Strings.patientPropertyNo: transferReport[Strings.patientPropertyNo],
      Strings.patientPropertyExplanation: transferReport[Strings.riskExplanation],
      Strings.patientPropertyReceived: transferReport[Strings.patientPropertyReceived],
      Strings.patientPropertyReceivedYes: transferReport[Strings.patientPropertyReceivedYes],
      Strings.patientPropertyReceivedNo: transferReport[Strings.patientPropertyReceivedNo],
      Strings.patientNotesReceived: transferReport[Strings.patientNotesReceived],
      Strings.patientNotesReceivedYes: transferReport[Strings.patientNotesReceivedYes],
      Strings.patientNotesReceivedNo: transferReport[Strings.patientNotesReceivedNo],
      Strings.patientSearched: transferReport[Strings.patientSearched],
      Strings.patientSearchedYes: transferReport[Strings.patientSearchedYes],
      Strings.patientSearchedNo: transferReport[Strings.patientSearchedNo],
      Strings.itemsRemovedYes: transferReport[Strings.itemsRemovedYes],
      Strings.itemsRemovedNo: transferReport[Strings.itemsRemovedNo],
      Strings.itemsRemoved: transferReport[Strings.itemsRemoved],
      Strings.patientInformed: transferReport[Strings.patientInformed],
      Strings.injuriesNoted: transferReport[Strings.injuriesNoted],
      Strings.bodyMapImage: transferReport[Strings.bodyMapImage],
      Strings.medicalAttentionYes: transferReport[Strings.medicalAttentionYes],
      Strings.medicalAttentionNo: transferReport[Strings.medicalAttentionNo],
      Strings.relevantInformationYes: transferReport[Strings.relevantInformationYes],
      Strings.relevantInformationNo: transferReport[Strings.relevantInformationNo],
      Strings.medicalAttention: transferReport[Strings.medicalAttention],
      Strings.currentMedication: transferReport[Strings.currentMedication],
      Strings.physicalObservations: transferReport[Strings.physicalObservations],
      Strings.relevantInformation: transferReport[Strings.relevantInformation],
      Strings.patientReport: transferReport[Strings.patientReport],
      Strings.patientReportPrintName: transferReport[Strings.patientReportPrintName],
      Strings.patientReportRole: transferReport[Strings.patientReportRole],
      Strings.patientReportDate: transferReport[Strings.patientReportDate],
      Strings.patientReportTime: transferReport[Strings.patientReportTime],
      Strings.patientReportSignature: transferReport[Strings.patientReportSignature],
      Strings.handcuffsUsedYes: transferReport[Strings.handcuffsUsedYes],
      Strings.handcuffsUsedNo: transferReport[Strings.handcuffsUsedNo],
      Strings.handcuffsDate: transferReport[Strings.handcuffsDate],
      Strings.handcuffsTime: transferReport[Strings.handcuffsTime],
      Strings.handcuffsAuthorisedBy: transferReport[Strings.handcuffsAuthorisedBy],
      Strings.handcuffsAppliedBy: transferReport[Strings.handcuffsAppliedBy],
      Strings.handcuffsRemovedTime: transferReport[Strings.handcuffsRemovedTime],
      Strings.physicalInterventionYes: transferReport[Strings.physicalInterventionYes],
      Strings.physicalInterventionNo: transferReport[Strings.physicalInterventionNo],
      Strings.physicalIntervention: transferReport[Strings.physicalIntervention],
      Strings.whyInterventionRequired: transferReport[Strings.whyInterventionRequired],
      Strings.techniqueName1: transferReport[Strings.techniqueName1],
      Strings.techniqueName2: transferReport[Strings.techniqueName2],
      Strings.techniqueName3: transferReport[Strings.techniqueName3],
      Strings.techniqueName4: transferReport[Strings.techniqueName4],
      Strings.techniqueName5: transferReport[Strings.techniqueName5],
      Strings.techniqueName6: transferReport[Strings.techniqueName6],
      Strings.techniqueName7: transferReport[Strings.techniqueName7],
      Strings.techniqueName8: transferReport[Strings.techniqueName8],
      Strings.techniqueName9: transferReport[Strings.techniqueName9],
      Strings.techniqueName10: transferReport[Strings.techniqueName10],
      Strings.technique1: transferReport[Strings.technique1],
      Strings.technique2: transferReport[Strings.technique2],
      Strings.technique3: transferReport[Strings.technique3],
      Strings.technique4: transferReport[Strings.technique4],
      Strings.technique5: transferReport[Strings.technique5],
      Strings.technique6: transferReport[Strings.technique6],
      Strings.technique7: transferReport[Strings.technique7],
      Strings.technique8: transferReport[Strings.technique8],
      Strings.technique9: transferReport[Strings.technique9],
      Strings.technique10: transferReport[Strings.technique10],
      Strings.techniquePosition1: transferReport[Strings.techniquePosition1],
      Strings.techniquePosition2: transferReport[Strings.techniquePosition2],
      Strings.techniquePosition3: transferReport[Strings.techniquePosition3],
      Strings.techniquePosition4: transferReport[Strings.techniquePosition4],
      Strings.techniquePosition5: transferReport[Strings.techniquePosition5],
      Strings.techniquePosition6: transferReport[Strings.techniquePosition6],
      Strings.techniquePosition7: transferReport[Strings.techniquePosition7],
      Strings.techniquePosition8: transferReport[Strings.techniquePosition8],
      Strings.techniquePosition9: transferReport[Strings.techniquePosition9],
      Strings.techniquePosition10: transferReport[Strings.techniquePosition10],
      Strings.timeInterventionCommenced: transferReport[Strings.timeInterventionCommenced],
      Strings.timeInterventionCompleted: transferReport[Strings.timeInterventionCompleted],
      Strings.incidentDate: transferReport[Strings.incidentDate],
      Strings.incidentTime: transferReport[Strings.incidentTime],
      Strings.incidentDetails: transferReport[Strings.incidentDetails],
      Strings.incidentLocation: transferReport[Strings.incidentLocation],
      Strings.incidentAction: transferReport[Strings.incidentAction],
      Strings.incidentStaffInvolved: transferReport[Strings.incidentStaffInvolved],
      Strings.incidentSignature: transferReport[Strings.incidentSignature],
      Strings.incidentSignatureDate: transferReport[Strings.incidentSignatureDate],
      Strings.incidentPrintName: transferReport[Strings.incidentPrintName],
      Strings.hasSection2Checklist: transferReport[Strings.hasSection2Checklist],
      Strings.hasSection3Checklist: transferReport[Strings.hasSection3Checklist],
      Strings.hasSection3TransferChecklist: transferReport[Strings.hasSection3TransferChecklist],
      Strings.transferInPatientName1: transferReport[Strings.transferInPatientName1],
      Strings.patientCorrectYes1: transferReport[Strings.patientCorrectYes1],
      Strings.patientCorrectNo1: transferReport[Strings.patientCorrectNo1],
      Strings.hospitalCorrectYes1: transferReport[Strings.hospitalCorrectYes1],
      Strings.hospitalCorrectNo1: transferReport[Strings.hospitalCorrectNo1],
      Strings.applicationFormYes1: transferReport[Strings.applicationFormYes1],
      Strings.applicationFormNo1: transferReport[Strings.applicationFormNo1],
      Strings.applicationSignedYes1: transferReport[Strings.applicationSignedYes1],
      Strings.applicationSignedNo1: transferReport[Strings.applicationSignedNo1],
      Strings.within14DaysYes1: transferReport[Strings.within14DaysYes1],
      Strings.within14DaysNo1: transferReport[Strings.within14DaysNo1],
      Strings.localAuthorityNameYes1: transferReport[Strings.localAuthorityNameYes1],
      Strings.localAuthorityNameNo1: transferReport[Strings.localAuthorityNameNo1],
      Strings.medicalRecommendationsFormYes1: transferReport[Strings.medicalRecommendationsFormYes1],
      Strings.medicalRecommendationsFormNo1: transferReport[Strings.medicalRecommendationsFormNo1],
      Strings.medicalRecommendationsSignedYes1: transferReport[Strings.medicalRecommendationsSignedYes1],
      Strings.medicalRecommendationsSignedNo1: transferReport[Strings.medicalRecommendationsSignedNo1],
      Strings.datesSignatureSignedYes: transferReport[Strings.datesSignatureSignedYes],
      Strings.datesSignatureSignedNo: transferReport[Strings.datesSignatureSignedNo],
      Strings.signatureDatesOnBeforeYes1: transferReport[Strings.signatureDatesOnBeforeYes1],
      Strings.signatureDatesOnBeforeNo1: transferReport[Strings.signatureDatesOnBeforeNo1],
      Strings.practitionersNameYes1: transferReport[Strings.practitionersNameYes1],
      Strings.practitionersNameNo1: transferReport[Strings.practitionersNameNo1],
      Strings.transferInCheckedBy1: transferReport[Strings.transferInCheckedBy1],
      Strings.transferInDate1: transferReport[Strings.transferInDate1],
      Strings.transferInDesignation1: transferReport[Strings.transferInDesignation1],
      Strings.transferInSignature1: transferReport[Strings.transferInSignature1],
      Strings.transferInPatientName2: transferReport[Strings.transferInPatientName2],
      Strings.patientCorrectYes2: transferReport[Strings.patientCorrectYes2],
      Strings.patientCorrectNo2: transferReport[Strings.patientCorrectNo2],
      Strings.hospitalCorrectYes2: transferReport[Strings.hospitalCorrectYes2],
      Strings.hospitalCorrectNo2: transferReport[Strings.hospitalCorrectNo2],
      Strings.applicationFormYes2: transferReport[Strings.applicationFormYes2],
      Strings.applicationFormNo2: transferReport[Strings.applicationFormNo2],
      Strings.applicationSignedYes2: transferReport[Strings.applicationSignedYes2],
      Strings.applicationSignedNo2: transferReport[Strings.applicationSignedNo2],
      Strings.amhpIdentifiedYes: transferReport[Strings.amhpIdentifiedYes],
      Strings.amhpIdentifiedNo: transferReport[Strings.amhpIdentifiedNo],
      Strings.medicalRecommendationsFormYes2: transferReport[Strings.medicalRecommendationsFormYes2],
      Strings.medicalRecommendationsFormNo2: transferReport[Strings.medicalRecommendationsFormNo2],
      Strings.medicalRecommendationsSignedYes2: transferReport[Strings.medicalRecommendationsSignedYes2],
      Strings.medicalRecommendationsSignedNo2: transferReport[Strings.medicalRecommendationsSignedNo2],
      Strings.clearDaysYes2: transferReport[Strings.clearDaysYes2],
      Strings.clearDaysNo2: transferReport[Strings.clearDaysNo2],
      Strings.signatureDatesOnBeforeYes2: transferReport[Strings.signatureDatesOnBeforeYes2],
      Strings.signatureDatesOnBeforeNo2: transferReport[Strings.signatureDatesOnBeforeNo2],
      Strings.practitionersNameYes2: transferReport[Strings.practitionersNameYes2],
      Strings.practitionersNameNo2: transferReport[Strings.practitionersNameNo2],
      Strings.doctorsAgreeYes: transferReport[Strings.doctorsAgreeYes],
      Strings.doctorsAgreeNo: transferReport[Strings.doctorsAgreeNo],
      Strings.separateMedicalRecommendationsYes: transferReport[Strings.separateMedicalRecommendationsYes],
      Strings.separateMedicalRecommendationsNo: transferReport[Strings.separateMedicalRecommendationsNo],
      Strings.transferInCheckedBy2: transferReport[Strings.transferInCheckedBy2],
      Strings.transferInDate2: transferReport[Strings.transferInDate2],
      Strings.transferInDesignation2: transferReport[Strings.transferInDesignation2],
      Strings.transferInSignature2: transferReport[Strings.transferInSignature2],
      Strings.transferInPatientName3: transferReport[Strings.transferInPatientName3],
      Strings.patientCorrectYes3: transferReport[Strings.patientCorrectYes3],
      Strings.patientCorrectNo3: transferReport[Strings.patientCorrectNo3],
      Strings.hospitalCorrectYes3: transferReport[Strings.hospitalCorrectYes3],
      Strings.hospitalCorrectNo3: transferReport[Strings.hospitalCorrectNo3],
      Strings.h4Yes: transferReport[Strings.h4Yes],
      Strings.h4No: transferReport[Strings.h4No],
      Strings.currentConsentYes: transferReport[Strings.currentConsentYes],
      Strings.currentConsentNo: transferReport[Strings.currentConsentNo],
      Strings.applicationFormYes3: transferReport[Strings.applicationFormYes3],
      Strings.applicationFormNo3: transferReport[Strings.applicationFormNo3],
      Strings.applicationSignedYes3: transferReport[Strings.applicationSignedYes3],
      Strings.applicationSignedNo3: transferReport[Strings.applicationSignedNo3],
      Strings.within14DaysYes3: transferReport[Strings.within14DaysYes3],
      Strings.within14DaysNo3: transferReport[Strings.within14DaysNo3],
      Strings.localAuthorityNameYes3: transferReport[Strings.localAuthorityNameYes3],
      Strings.localAuthorityNameNo3: transferReport[Strings.localAuthorityNameNo3],
      Strings.nearestRelativeYes: transferReport[Strings.nearestRelativeYes],
      Strings.nearestRelativeNo: transferReport[Strings.nearestRelativeNo],
      Strings.amhpConsultationYes: transferReport[Strings.amhpConsultationYes],
      Strings.amhpConsultationNo: transferReport[Strings.amhpConsultationNo],
      Strings.knewPatientYes: transferReport[Strings.knewPatientYes],
      Strings.knewPatientNo: transferReport[Strings.knewPatientNo],
      Strings.medicalRecommendationsFormYes3: transferReport[Strings.medicalRecommendationsFormYes3],
      Strings.medicalRecommendationsFormNo3: transferReport[Strings.medicalRecommendationsFormNo3],
      Strings.medicalRecommendationsSignedYes3: transferReport[Strings.medicalRecommendationsSignedYes3],
      Strings.medicalRecommendationsSignedNo3: transferReport[Strings.medicalRecommendationsSignedNo3],
      Strings.clearDaysYes3: transferReport[Strings.clearDaysYes3],
      Strings.clearDaysNo3: transferReport[Strings.clearDaysNo3],
      Strings.approvedSection12Yes: transferReport[Strings.approvedSection12Yes],
      Strings.approvedSection12No: transferReport[Strings.approvedSection12No],
      Strings.signatureDatesOnBeforeYes3: transferReport[Strings.signatureDatesOnBeforeYes3],
      Strings.signatureDatesOnBeforeNo3: transferReport[Strings.signatureDatesOnBeforeNo3],
      Strings.practitionersNameYes3: transferReport[Strings.practitionersNameYes3],
      Strings.practitionersNameNo3: transferReport[Strings.practitionersNameNo3],
      Strings.previouslyAcquaintedYes: transferReport[Strings.previouslyAcquaintedYes],
      Strings.previouslyAcquaintedNo: transferReport[Strings.previouslyAcquaintedNo],
      Strings.acquaintedIfNoYes: transferReport[Strings.acquaintedIfNoYes],
      Strings.acquaintedIfNoNo: transferReport[Strings.acquaintedIfNoNo],
      Strings.recommendationsDifferentTeamsYes: transferReport[Strings.recommendationsDifferentTeamsYes],
      Strings.recommendationsDifferentTeamsNo: transferReport[Strings.recommendationsDifferentTeamsNo],
      Strings.originalDetentionPapersYes: transferReport[Strings.originalDetentionPapersYes],
      Strings.originalDetentionPapersNo: transferReport[Strings.originalDetentionPapersNo],
      Strings.transferInCheckedBy3: transferReport[Strings.transferInCheckedBy3],
      Strings.transferInDate3: transferReport[Strings.transferInDate3],
      Strings.transferInDesignation3: transferReport[Strings.transferInDesignation3],
      Strings.transferInSignature3: transferReport[Strings.transferInSignature3],
      Strings.feltSafeYes: transferReport[Strings.feltSafeYes],
      Strings.feltSafeNo: transferReport[Strings.feltSafeNo],
      Strings.staffIntroducedYes: transferReport[Strings.staffIntroducedYes],
      Strings.staffIntroducedNo: transferReport[Strings.staffIntroducedNo],
      Strings.experiencePositiveYes: transferReport[Strings.experiencePositiveYes],
      Strings.experiencePositiveNo: transferReport[Strings.experiencePositiveNo],
      Strings.otherComments: transferReport[Strings.otherComments],
      Strings.vehicleCompletedBy1: transferReport[Strings.vehicleCompletedBy1],
      Strings.vehicleDate: transferReport[Strings.vehicleDate],
      Strings.vehicleTime: transferReport[Strings.vehicleTime],
      Strings.ambulanceReg: transferReport[Strings.ambulanceReg],
      Strings.vehicleStartMileage: transferReport[Strings.vehicleStartMileage],
      Strings.nearestTank1: transferReport[Strings.nearestTank1],
      Strings.ambulanceTidyYes1: transferReport[Strings.ambulanceTidyYes1],
      Strings.ambulanceTidyNo1: transferReport[Strings.ambulanceTidyNo1],
      Strings.lightsWorkingYes: transferReport[Strings.lightsWorkingYes],
      Strings.lightsWorkingNo: transferReport[Strings.lightsWorkingNo],
      Strings.tyresInflatedYes: transferReport[Strings.tyresInflatedYes],
      Strings.tyresInflatedNo: transferReport[Strings.tyresInflatedNo],
      Strings.warningSignsYes: transferReport[Strings.warningSignsYes],
      Strings.warningSignsNo: transferReport[Strings.warningSignsNo],
      Strings.vehicleCompletedBy2: transferReport[Strings.vehicleCompletedBy2],
      Strings.nearestTank2: transferReport[Strings.nearestTank2],
      Strings.vehicleFinishMileage: transferReport[Strings.vehicleFinishMileage],
      Strings.ambulanceTidyYes2: transferReport[Strings.ambulanceTidyYes2],
      Strings.ambulanceTidyNo2: transferReport[Strings.ambulanceTidyNo2],
      Strings.sanitiserCleanYes: transferReport[Strings.sanitiserCleanYes],
      Strings.sanitiserCleanNo: transferReport[Strings.sanitiserCleanNo],
      Strings.issuesFaults: transferReport[Strings.issuesFaults],
    };

    await _savedTransferReportsStore.record(id).put(await _db,
        localData);

    message = 'Transfer Report saved to device';
    success = true;

    if(success) resetTemporaryRecord(jobId, false, 0);
    GlobalFunctions.dismissLoadingDialog();
    GlobalFunctions.showToast(message);
    return success;
  }

  Future<void> deleteSavedRecord(int id) async {
    await _savedTransferReportsStore.record(id).delete(await _db);
    _transferReports.removeWhere((element) => element[Strings.localId] == id);
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

        _transferReports = List.from(_fetchedRecordList.reversed);
      } else {
        message = 'No saved records available';
      }

    } catch(e){
      print(e);
      message = 'Something went wrong. Please try again';

    }
    _isLoading = false;
    notifyListeners();
    _selTransferReportId = null;
    if(message != '') GlobalFunctions.showToast(message);

  }

  Future<void> resetTemporaryRecord(String chosenJobId, bool saved, int savedId) async {

    Db.Finder finder;

    if(saved){
      finder = Db.Finder(filter: Db.Filter.equals(Strings.localId, savedId));
    } else {
      finder = Db.Finder(filter: Db.Filter.and(
          [Db.Filter.equals(Strings.uid, user.uid), Db.Filter.equals(Strings.jobId, chosenJobId)]
      ));
    }

    await _temporaryTransferReportsStore.update(await _db, {
      Strings.formVersion: 1,
      Strings.jobRef: null,
      Strings.date: null,
      Strings.startTime: null,
      Strings.finishTime: null,
      Strings.totalHours: null,
      Strings.collectionDetails: null,
      Strings.collectionPostcode: null,
      Strings.collectionContactNo: null,
      Strings.destinationDetails: null,
      Strings.destinationPostcode: null,
      Strings.destinationContactNo: null,
      Strings.collectionArrivalTime: null,
      Strings.collectionDepartureTime: null,
      Strings.destinationArrivalTime: null,
      Strings.destinationDepartureTime: null,
      Strings.vehicleRegNo: null,
      Strings.startMileage: null,
      Strings.finishMileage: null,
      Strings.totalMileage: null,
      Strings.name1: null,
      Strings.role1: null,
      Strings.drivingTimes1_1: null,
      Strings.drivingTimes1_2: null,
      Strings.name2: null,
      Strings.role2: null,
      Strings.drivingTimes2_1: null,
      Strings.drivingTimes2_2: null,
      Strings.name3: null,
      Strings.role3: null,
      Strings.drivingTimes3_1: null,
      Strings.drivingTimes3_2: null,
      Strings.name4: null,
      Strings.role4: null,
      Strings.drivingTimes4_1: null,
      Strings.drivingTimes4_2: null,
      Strings.name5: null,
      Strings.role5: null,
      Strings.drivingTimes5_1: null,
      Strings.drivingTimes5_2: null,
      Strings.name6: null,
      Strings.role6: null,
      Strings.drivingTimes6_1: null,
      Strings.drivingTimes6_2: null,
      Strings.name7: null,
      Strings.role7: null,
      Strings.drivingTimes7_1: null,
      Strings.drivingTimes7_2: null,
      Strings.name8: null,
      Strings.role8: null,
      Strings.drivingTimes8_1: null,
      Strings.drivingTimes8_2: null,
      Strings.name9: null,
      Strings.role9: null,
      Strings.drivingTimes9_1: null,
      Strings.drivingTimes9_2: null,
      Strings.name10: null,
      Strings.role10: null,
      Strings.drivingTimes10_1: null,
      Strings.drivingTimes10_2: null,
      Strings.name11: null,
      Strings.role11: null,
      Strings.drivingTimes11_1: null,
      Strings.drivingTimes11_2: null,
      Strings.collectionUnit: null,
      Strings.collectionPosition: null,
      Strings.collectionPrintName: null,
      Strings.collectionArrivalTimeEnd: null,
      Strings.collectionSignature: null,
      Strings.collectionSignaturePoints: null,
      Strings.destinationUnit: null,
      Strings.destinationPosition: null,
      Strings.destinationPrintName: null,
      Strings.destinationArrivalTimeEnd: null,
      Strings.destinationSignature: null,
      Strings.destinationSignaturePoints: null,
      Strings.patientName: null,
      Strings.dateOfBirth: null,
      Strings.ethnicity: null,
      Strings.gender: null,
      Strings.mhaMcaDetails: null,
      Strings.diagnosis: null,
      Strings.currentPresentation: null,
      Strings.riskYes: null,
      Strings.riskNo: null,
      Strings.riskExplanation: null,
      Strings.forensicHistoryYes: null,
      Strings.forensicHistoryNo: null,
      Strings.racialGenderConcernsYes: null,
      Strings.racialGenderConcernsNo: null,
      Strings.violenceAggressionYes: null,
      Strings.violenceAggressionNo: null,
      Strings.selfHarmYes: null,
      Strings.selfHarmNo: null,
      Strings.alcoholSubstanceYes: null,
      Strings.alcoholSubstanceNo: null,
      Strings.virusesYes: null,
      Strings.virusesNo: null,
      Strings.safeguardingYes: null,
      Strings.safeguardingNo: null,
      Strings.physicalHealthConditionsYes: null,
      Strings.physicalHealthConditionsNo: null,
      Strings.useOfWeaponYes: null,
      Strings.useOfWeaponNo: null,
      Strings.absconsionRiskYes: null,
      Strings.absconsionRiskNo: null,
      Strings.forensicHistory: null,
      Strings.racialGenderConcerns: null,
      Strings.violenceAggression: null,
      Strings.selfHarm: null,
      Strings.alcoholSubstance: null,
      Strings.viruses: null,
      Strings.safeguarding: null,
      Strings.physicalHealthConditions: null,
      Strings.useOfWeapon: null,
      Strings.absconsionRisk: null,
      Strings.patientPropertyYes: null,
      Strings.patientPropertyNo: null,
      Strings.patientPropertyExplanation: null,
      Strings.patientPropertyReceived: null,
      Strings.patientPropertyReceivedYes: null,
      Strings.patientPropertyReceivedNo: null,
      Strings.patientNotesReceived: null,
      Strings.patientNotesReceivedYes: null,
      Strings.patientNotesReceivedNo: null,
      Strings.patientSearchedYes: null,
      Strings.patientSearchedNo: null,
      Strings.patientSearched: null,
      Strings.itemsRemovedYes: null,
      Strings.itemsRemovedNo: null,
      Strings.itemsRemoved: null,
      Strings.patientInformed: null,
      Strings.injuriesNoted: null,
      Strings.bodyMapPoints: null,
      Strings.bodyMapImage: null,
      Strings.medicalAttentionYes: null,
      Strings.medicalAttentionNo: null,
      Strings.relevantInformationYes: null,
      Strings.relevantInformationNo: null,
      Strings.medicalAttention: null,
      Strings.currentMedication: null,
      Strings.physicalObservations: null,
      Strings.relevantInformation: null,
      Strings.patientReport: null,
      Strings.patientReportPrintName: null,
      Strings.patientReportRole: null,
      Strings.patientReportDate: null,
      Strings.patientReportTime: null,
      Strings.patientReportSignature: null,
      Strings.patientReportSignaturePoints: null,
      Strings.handcuffsUsedYes: null,
      Strings.handcuffsUsedNo: null,
      Strings.handcuffsDate: null,
      Strings.handcuffsTime: null,
      Strings.handcuffsAuthorisedBy: null,
      Strings.handcuffsAppliedBy: null,
      Strings.handcuffsRemovedTime: null,
      Strings.physicalInterventionYes: null,
      Strings.physicalInterventionNo: null,
      Strings.physicalIntervention: null,
      Strings.whyInterventionRequired: null,
      Strings.techniqueName1: null,
      Strings.techniqueName2: null,
      Strings.techniqueName3: null,
      Strings.techniqueName4: null,
      Strings.techniqueName5: null,
      Strings.techniqueName6: null,
      Strings.techniqueName7: null,
      Strings.techniqueName8: null,
      Strings.techniqueName9: null,
      Strings.techniqueName10: null,
      Strings.technique1: null,
      Strings.technique2: null,
      Strings.technique3: null,
      Strings.technique4: null,
      Strings.technique5: null,
      Strings.technique6: null,
      Strings.technique7: null,
      Strings.technique8: null,
      Strings.technique9: null,
      Strings.technique10: null,
      Strings.techniquePosition1: null,
      Strings.techniquePosition2: null,
      Strings.techniquePosition3: null,
      Strings.techniquePosition4: null,
      Strings.techniquePosition5: null,
      Strings.techniquePosition6: null,
      Strings.techniquePosition7: null,
      Strings.techniquePosition8: null,
      Strings.techniquePosition9: null,
      Strings.techniquePosition10: null,
      Strings.timeInterventionCommenced: null,
      Strings.timeInterventionCompleted: null,
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
      Strings.hasSection2Checklist: null,
      Strings.hasSection3Checklist: null,
      Strings.hasSection3TransferChecklist: null,
      Strings.transferInPatientName1: null,
      Strings.patientCorrectYes1: null,
      Strings.patientCorrectNo1: null,
      Strings.hospitalCorrectYes1: null,
      Strings.hospitalCorrectNo1: null,
      Strings.applicationFormYes1: null,
      Strings.applicationFormNo1: null,
      Strings.applicationSignedYes1: null,
      Strings.applicationSignedNo1: null,
      Strings.within14DaysYes1: null,
      Strings.within14DaysNo1: null,
      Strings.localAuthorityNameYes1: null,
      Strings.localAuthorityNameNo1: null,
      Strings.medicalRecommendationsFormYes1: null,
      Strings.medicalRecommendationsFormNo1: null,
      Strings.medicalRecommendationsSignedYes1: null,
      Strings.medicalRecommendationsSignedNo1: null,
      Strings.datesSignatureSignedYes: null,
      Strings.datesSignatureSignedNo: null,
      Strings.signatureDatesOnBeforeYes1: null,
      Strings.signatureDatesOnBeforeNo1: null,
      Strings.practitionersNameYes1: null,
      Strings.practitionersNameNo1: null,
      Strings.transferInCheckedBy1: null,
      Strings.transferInDate1: null,
      Strings.transferInDesignation1: null,
      Strings.transferInSignature1: null,
      Strings.transferInSignaturePoints1: null,
      Strings.transferInPatientName2: null,
      Strings.patientCorrectYes2: null,
      Strings.patientCorrectNo2: null,
      Strings.hospitalCorrectYes2: null,
      Strings.hospitalCorrectNo2: null,
      Strings.applicationFormYes2: null,
      Strings.applicationFormNo2: null,
      Strings.applicationSignedYes2: null,
      Strings.applicationSignedNo2: null,
      Strings.amhpIdentifiedYes: null,
      Strings.amhpIdentifiedNo: null,
      Strings.medicalRecommendationsFormYes2: null,
      Strings.medicalRecommendationsFormNo2: null,
      Strings.medicalRecommendationsSignedYes2: null,
      Strings.medicalRecommendationsSignedNo2: null,
      Strings.clearDaysYes2: null,
      Strings.clearDaysNo2: null,
      Strings.signatureDatesOnBeforeYes2: null,
      Strings.signatureDatesOnBeforeNo2: null,
      Strings.practitionersNameYes2: null,
      Strings.practitionersNameNo2: null,
      Strings.doctorsAgreeYes: null,
      Strings.doctorsAgreeNo: null,
      Strings.separateMedicalRecommendationsYes: null,
      Strings.separateMedicalRecommendationsNo: null,
      Strings.transferInCheckedBy2: null,
      Strings.transferInDate2: null,
      Strings.transferInDesignation2: null,
      Strings.transferInSignature2: null,
      Strings.transferInSignaturePoints2: null,
      Strings.transferInPatientName3: null,
      Strings.patientCorrectYes3: null,
      Strings.patientCorrectNo3: null,
      Strings.hospitalCorrectYes3: null,
      Strings.hospitalCorrectNo3: null,
      Strings.h4Yes: null,
      Strings.h4No: null,
      Strings.currentConsentYes: null,
      Strings.currentConsentNo: null,
      Strings.applicationFormYes3: null,
      Strings.applicationFormNo3: null,
      Strings.applicationSignedYes3: null,
      Strings.applicationSignedNo3: null,
      Strings.within14DaysYes3: null,
      Strings.within14DaysNo3: null,
      Strings.localAuthorityNameYes3: null,
      Strings.localAuthorityNameNo3: null,
      Strings.nearestRelativeYes: null,
      Strings.nearestRelativeNo: null,
      Strings.amhpConsultationYes: null,
      Strings.amhpConsultationNo: null,
      Strings.knewPatientYes: null,
      Strings.knewPatientNo: null,
      Strings.medicalRecommendationsFormYes3: null,
      Strings.medicalRecommendationsFormNo3: null,
      Strings.medicalRecommendationsSignedYes3: null,
      Strings.medicalRecommendationsSignedNo3: null,
      Strings.clearDaysYes3: null,
      Strings.clearDaysNo3: null,
      Strings.approvedSection12Yes: null,
      Strings.approvedSection12No: null,
      Strings.signatureDatesOnBeforeYes3: null,
      Strings.signatureDatesOnBeforeNo3: null,
      Strings.practitionersNameYes3: null,
      Strings.practitionersNameNo3: null,
      Strings.previouslyAcquaintedYes: null,
      Strings.previouslyAcquaintedNo: null,
      Strings.acquaintedIfNoYes: null,
      Strings.acquaintedIfNoNo: null,
      Strings.recommendationsDifferentTeamsYes: null,
      Strings.recommendationsDifferentTeamsNo: null,
      Strings.originalDetentionPapersYes: null,
      Strings.originalDetentionPapersNo: null,
      Strings.transferInCheckedBy3: null,
      Strings.transferInDate3: null,
      Strings.transferInDesignation3: null,
      Strings.transferInSignature3: null,
      Strings.transferInSignaturePoints3: null,
      Strings.feltSafeYes: null,
      Strings.feltSafeNo: null,
      Strings.staffIntroducedYes: null,
      Strings.staffIntroducedNo: null,
      Strings.experiencePositiveYes: null,
      Strings.experiencePositiveNo: null,
      Strings.otherComments: null,
      Strings.vehicleCompletedBy1: null,
      Strings.vehicleDate: null,
      Strings.vehicleTime: null,
      Strings.ambulanceReg: null,
      Strings.vehicleStartMileage: null,
      Strings.nearestTank1: null,
      Strings.ambulanceTidyYes1: null,
      Strings.ambulanceTidyNo1: null,
      Strings.lightsWorkingYes: null,
      Strings.lightsWorkingNo: null,
      Strings.tyresInflatedYes: null,
      Strings.tyresInflatedNo: null,
      Strings.warningSignsYes: null,
      Strings.warningSignsNo: null,
      Strings.vehicleCompletedBy2: null,
      Strings.nearestTank2: null,
      Strings.vehicleFinishMileage: null,
      Strings.ambulanceTidyYes2: null,
      Strings.ambulanceTidyNo2: null,
      Strings.sanitiserCleanYes: null,
      Strings.sanitiserCleanNo: null,
      Strings.issuesFaults: null,
    },
        finder: finder);
    //notifyListeners();
  }


  Future<Map<String, dynamic>> validateTransferReport(String jobId, bool edit, bool saved, int savedId) async {

    bool successJobDetails = true;
    bool successVehicleChecklist = true;
    bool successPatientDetails = true;


    //Map<String, dynamic> transferReport = await _databaseHelper.getTemporaryTransferReport(edit, user.uid, jobId);
    Map<String, dynamic> transferReport = await getTemporaryRecord(edit, jobId, saved, savedId);



    if(transferReport[Strings.jobRef]== null || transferReport[Strings.jobRef].toString().trim() == ''){
      successJobDetails = false;
    }

    if(transferReport[Strings.date] == null){
      successJobDetails = false;
    }

    if(transferReport[Strings.startMileage]== null || transferReport[Strings.startMileage].toString().trim() == ''){
      successJobDetails = false;
    }


    if(transferReport[Strings.collectionUnit]== null || transferReport[Strings.collectionUnit].toString().trim() == ''){
      successJobDetails = false;
    }
    if(transferReport[Strings.collectionPosition]== null || transferReport[Strings.collectionPosition].toString().trim() == ''){
      successJobDetails = false;
    }
    if(transferReport[Strings.collectionPrintName]== null || transferReport[Strings.collectionPrintName].toString().trim() == ''){
      successJobDetails = false;
    }

    if(transferReport[Strings.collectionArrivalTimeEnd] == null){
      successJobDetails = false;
    }

    if(transferReport[Strings.collectionSignature] == null){
      successJobDetails = false;
    }

    if(transferReport[Strings.destinationArrivalTimeEnd] == null){
      successJobDetails = false;
    }

    if(transferReport[Strings.destinationSignature] == null){
      successJobDetails = false;
    }

    if(transferReport[Strings.destinationUnit]== null || transferReport[Strings.destinationUnit].toString().trim() == ''){
      successJobDetails = false;
    }
    if(transferReport[Strings.destinationPosition]== null || transferReport[Strings.destinationPosition].toString().trim() == ''){
      successJobDetails = false;
    }
    if(transferReport[Strings.destinationPrintName]== null || transferReport[Strings.destinationPrintName].toString().trim() == ''){
      successJobDetails = false;
    }

    //Patient Details

    if(transferReport[Strings.patientName]== null || transferReport[Strings.patientName].toString().trim() == ''){
      successPatientDetails = false;
    }
    if(transferReport[Strings.dateOfBirth] == null){
      successPatientDetails = false;
    }
    if(transferReport[Strings.ethnicity]== null || transferReport[Strings.ethnicity].toString().trim() == ''){
      successPatientDetails = false;
    }
    if(transferReport[Strings.gender]== null || transferReport[Strings.gender].toString().trim() == ''){
      successPatientDetails = false;
    }
    if(transferReport[Strings.mhaMcaDetails]== null || transferReport[Strings.mhaMcaDetails].toString().trim() == ''){
      successPatientDetails = false;
    }
    if(transferReport[Strings.diagnosis]== null || transferReport[Strings.diagnosis].toString().trim() == ''){
      successPatientDetails = false;
    }
    if(transferReport[Strings.currentPresentation]== null || transferReport[Strings.currentPresentation].toString().trim() == ''){
      successPatientDetails = false;
    }

    //Risk

    if(transferReport[Strings.forensicHistoryYes] == null && transferReport[Strings.forensicHistoryNo] == null){
      successPatientDetails = false;
    }
    if(transferReport[Strings.forensicHistoryYes] == 0 && transferReport[Strings.forensicHistoryNo] == 0){
      successPatientDetails = false;
    }
    if(transferReport[Strings.forensicHistoryYes] == null && transferReport[Strings.forensicHistoryNo] == 0){
      successPatientDetails = false;
    }
    if(transferReport[Strings.forensicHistoryYes] == 0 && transferReport[Strings.forensicHistoryNo] == null){
      successPatientDetails = false;
    }

    if(transferReport[Strings.racialGenderConcernsYes] == null && transferReport[Strings.racialGenderConcernsNo] == null){
      successPatientDetails = false;
    }
    if(transferReport[Strings.racialGenderConcernsYes] == 0 && transferReport[Strings.racialGenderConcernsNo] == 0){
      successPatientDetails = false;
    }
    if(transferReport[Strings.racialGenderConcernsYes] == null && transferReport[Strings.racialGenderConcernsNo] == 0){
      successPatientDetails = false;
    }
    if(transferReport[Strings.racialGenderConcernsYes] == 0 && transferReport[Strings.racialGenderConcernsNo] == null){
      successPatientDetails = false;
    }

    if(transferReport[Strings.violenceAggressionYes] == null && transferReport[Strings.violenceAggressionNo] == null){
      successPatientDetails = false;
    }
    if(transferReport[Strings.violenceAggressionYes] == 0 && transferReport[Strings.violenceAggressionNo] == 0){
      successPatientDetails = false;
    }
    if(transferReport[Strings.violenceAggressionYes] == null && transferReport[Strings.violenceAggressionNo] == 0){
      successPatientDetails = false;
    }
    if(transferReport[Strings.violenceAggressionYes] == 0 && transferReport[Strings.violenceAggressionNo] == null){
      successPatientDetails = false;
    }

    if(transferReport[Strings.selfHarmYes] == null && transferReport[Strings.selfHarmNo] == null){
      successPatientDetails = false;
    }
    if(transferReport[Strings.selfHarmYes] == 0 && transferReport[Strings.selfHarmNo] == 0){
      successPatientDetails = false;
    }
    if(transferReport[Strings.selfHarmYes] == null && transferReport[Strings.selfHarmNo] == 0){
      successPatientDetails = false;
    }
    if(transferReport[Strings.selfHarmYes] == 0 && transferReport[Strings.selfHarmNo] == null){
      successPatientDetails = false;
    }

    if(transferReport[Strings.alcoholSubstanceYes] == null && transferReport[Strings.alcoholSubstanceNo] == null){
      successPatientDetails = false;
    }
    if(transferReport[Strings.alcoholSubstanceYes] == 0 && transferReport[Strings.alcoholSubstanceNo] == 0){
      successPatientDetails = false;
    }
    if(transferReport[Strings.alcoholSubstanceYes] == null && transferReport[Strings.alcoholSubstanceNo] == 0){
      successPatientDetails = false;
    }
    if(transferReport[Strings.alcoholSubstanceYes] == 0 && transferReport[Strings.alcoholSubstanceNo] == null){
      successPatientDetails = false;
    }

    if(transferReport[Strings.virusesYes] == null && transferReport[Strings.virusesNo] == null){
      successPatientDetails = false;
    }
    if(transferReport[Strings.virusesYes] == 0 && transferReport[Strings.virusesNo] == 0){
      successPatientDetails = false;
    }
    if(transferReport[Strings.virusesYes] == null && transferReport[Strings.virusesNo] == 0){
      successPatientDetails = false;
    }
    if(transferReport[Strings.virusesYes] == 0 && transferReport[Strings.virusesNo] == null){
      successPatientDetails = false;
    }

    if(transferReport[Strings.safeguardingYes] == null && transferReport[Strings.safeguardingNo] == null){
      successPatientDetails = false;
    }
    if(transferReport[Strings.safeguardingYes] == 0 && transferReport[Strings.safeguardingNo] == 0){
      successPatientDetails = false;
    }
    if(transferReport[Strings.safeguardingYes] == null && transferReport[Strings.safeguardingNo] == 0){
      successPatientDetails = false;
    }
    if(transferReport[Strings.safeguardingYes] == 0 && transferReport[Strings.safeguardingNo] == null){
      successPatientDetails = false;
    }

    if(transferReport[Strings.physicalHealthConditionsYes] == null && transferReport[Strings.physicalHealthConditionsNo] == null){
      successPatientDetails = false;
    }
    if(transferReport[Strings.physicalHealthConditionsYes] == 0 && transferReport[Strings.physicalHealthConditionsNo] == 0){
      successPatientDetails = false;
    }
    if(transferReport[Strings.physicalHealthConditionsYes] == null && transferReport[Strings.physicalHealthConditionsNo] == 0){
      successPatientDetails = false;
    }
    if(transferReport[Strings.physicalHealthConditionsYes] == 0 && transferReport[Strings.physicalHealthConditionsNo] == null){
      successPatientDetails = false;
    }

    if(transferReport[Strings.useOfWeaponYes] == null && transferReport[Strings.useOfWeaponNo] == null){
      successPatientDetails = false;
    }
    if(transferReport[Strings.useOfWeaponYes] == 0 && transferReport[Strings.useOfWeaponNo] == 0){
      successPatientDetails = false;
    }
    if(transferReport[Strings.useOfWeaponYes] == null && transferReport[Strings.useOfWeaponNo] == 0){
      successPatientDetails = false;
    }
    if(transferReport[Strings.useOfWeaponYes] == 0 && transferReport[Strings.useOfWeaponNo] == null){
      successPatientDetails = false;
    }

    if(transferReport[Strings.absconsionRiskYes] == null && transferReport[Strings.absconsionRiskNo] == null){
      successPatientDetails = false;
    }
    if(transferReport[Strings.absconsionRiskYes] == 0 && transferReport[Strings.absconsionRiskNo] == 0){
      successPatientDetails = false;
    }
    if(transferReport[Strings.absconsionRiskYes] == null && transferReport[Strings.absconsionRiskNo] == 0){
      successPatientDetails = false;
    }
    if(transferReport[Strings.absconsionRiskYes] == 0 && transferReport[Strings.absconsionRiskNo] == null){
      successPatientDetails = false;
    }




    if(transferReport[Strings.forensicHistoryYes] == 1){
      if(transferReport[Strings.forensicHistory]== null || transferReport[Strings.forensicHistory].toString().trim() == ''){
        successPatientDetails = false;
      }
    }
    if(transferReport[Strings.racialGenderConcernsYes] == 1){
      if(transferReport[Strings.racialGenderConcerns]== null || transferReport[Strings.racialGenderConcerns].toString().trim() == ''){
        successPatientDetails = false;
      }
    }
    if(transferReport[Strings.violenceAggressionYes] == 1){
      if(transferReport[Strings.violenceAggression]== null || transferReport[Strings.violenceAggression].toString().trim() == ''){
        successPatientDetails = false;
      }
    }
    if(transferReport[Strings.selfHarmYes] == 1){
      if(transferReport[Strings.selfHarm]== null || transferReport[Strings.selfHarm].toString().trim() == ''){
        successPatientDetails = false;
      }
    }
    if(transferReport[Strings.alcoholSubstanceYes] == 1){
      if(transferReport[Strings.alcoholSubstance]== null || transferReport[Strings.alcoholSubstance].toString().trim() == ''){
        successPatientDetails = false;
      }
    }
    if(transferReport[Strings.virusesYes] == 1){
      if(transferReport[Strings.viruses]== null || transferReport[Strings.viruses].toString().trim() == ''){
        successPatientDetails = false;
      }
    }
    if(transferReport[Strings.safeguardingYes] == 1){
      if(transferReport[Strings.safeguarding]== null || transferReport[Strings.safeguarding].toString().trim() == ''){
        successPatientDetails = false;
      }
    }
    if(transferReport[Strings.physicalHealthConditionsYes] == 1){
      if(transferReport[Strings.physicalHealthConditions]== null || transferReport[Strings.physicalHealthConditions].toString().trim() == ''){
        successPatientDetails = false;
      }
    }
    if(transferReport[Strings.useOfWeaponYes] == 1){
      if(transferReport[Strings.useOfWeapon]== null || transferReport[Strings.useOfWeapon].toString().trim() == ''){
        successPatientDetails = false;
      }
    }
    if(transferReport[Strings.absconsionRiskYes] == 1){
      if(transferReport[Strings.absconsionRisk]== null || transferReport[Strings.absconsionRisk].toString().trim() == ''){
        successPatientDetails = false;
      }
    }

    //Patient Property

    if(transferReport[Strings.patientPropertyYes] == null && transferReport[Strings.patientPropertyNo] == null){
      successPatientDetails = false;
    }
    if(transferReport[Strings.patientPropertyYes] == 0 && transferReport[Strings.patientPropertyNo] == 0){
      successPatientDetails = false;
    }
    if(transferReport[Strings.patientPropertyYes] == null && transferReport[Strings.patientPropertyNo] == 0){
      successPatientDetails = false;
    }
    if(transferReport[Strings.patientPropertyYes] == 0 && transferReport[Strings.patientPropertyNo] == null){
      successPatientDetails = false;
    }

    if(transferReport[Strings.patientNotesReceivedYes] == null && transferReport[Strings.patientNotesReceivedNo] == null){
      successPatientDetails = false;
    }
    if(transferReport[Strings.patientNotesReceivedYes] == 0 && transferReport[Strings.patientNotesReceivedNo] == 0){
      successPatientDetails = false;
    }
    if(transferReport[Strings.patientNotesReceivedYes] == null && transferReport[Strings.patientNotesReceivedNo] == 0){
      successPatientDetails = false;
    }
    if(transferReport[Strings.patientNotesReceivedYes] == 0 && transferReport[Strings.patientNotesReceivedNo] == null){
      successPatientDetails = false;
    }

    if(transferReport[Strings.patientPropertyYes] == 1){


      if(transferReport[Strings.patientPropertyReceivedYes] == null && transferReport[Strings.patientPropertyReceivedNo] == null){
        successPatientDetails = false;
      }
      if(transferReport[Strings.patientPropertyReceivedYes] == 0 && transferReport[Strings.patientPropertyReceivedNo] == 0){
        successPatientDetails = false;
      }
      if(transferReport[Strings.patientPropertyReceivedYes] == null && transferReport[Strings.patientPropertyReceivedNo] == 0){
        successPatientDetails = false;
      }
      if(transferReport[Strings.patientPropertyReceivedYes] == 0 && transferReport[Strings.patientPropertyReceivedNo] == null){
        successPatientDetails = false;
      }


      if(transferReport[Strings.patientPropertyReceivedYes] == 1){
        if(transferReport[Strings.patientPropertyReceived]== null || transferReport[Strings.patientPropertyReceived].toString().trim() == ''){
          successPatientDetails = false;
        }

      }

    }


    if(transferReport[Strings.patientNotesReceivedYes] == 1){
      if(transferReport[Strings.patientNotesReceived]== null || transferReport[Strings.patientNotesReceived].toString().trim() == ''){
        successPatientDetails = false;
      }
    }

    //Patient Checks

    if(transferReport[Strings.patientSearchedYes] == null && transferReport[Strings.patientSearchedNo] == null){
      successPatientDetails = false;
    }
    if(transferReport[Strings.patientSearchedYes] == 0 && transferReport[Strings.patientSearchedNo] == 0){
      successPatientDetails = false;
    }
    if(transferReport[Strings.patientSearchedYes] == null && transferReport[Strings.patientSearchedNo] == 0){
      successPatientDetails = false;
    }
    if(transferReport[Strings.patientSearchedYes] == 0 && transferReport[Strings.patientSearchedNo] == null){
      successPatientDetails = false;
    }

    if(transferReport[Strings.itemsRemovedYes] == null && transferReport[Strings.itemsRemovedNo] == null){
      successPatientDetails = false;
    }
    if(transferReport[Strings.itemsRemovedYes] == 0 && transferReport[Strings.itemsRemovedNo] == 0){
      successPatientDetails = false;
    }
    if(transferReport[Strings.itemsRemovedYes] == null && transferReport[Strings.itemsRemovedNo] == 0){
      successPatientDetails = false;
    }
    if(transferReport[Strings.itemsRemovedYes] == 0 && transferReport[Strings.itemsRemovedNo] == null){
      successPatientDetails = false;
    }

    if(transferReport[Strings.itemsRemovedYes] == 1){
      if(transferReport[Strings.itemsRemoved]== null || transferReport[Strings.itemsRemoved].toString().trim() == ''){
        successPatientDetails = false;
      }
    }

    if(transferReport[Strings.patientInformed]== null || transferReport[Strings.patientInformed].toString().trim() == ''){
      successPatientDetails = false;
    }

    if(transferReport[Strings.injuriesNoted]== null || transferReport[Strings.injuriesNoted].toString().trim() == ''){
      successPatientDetails = false;
    }


    //Body Map

    if(transferReport[Strings.medicalAttentionYes] == null && transferReport[Strings.medicalAttentionNo] == null){
      successPatientDetails = false;
    }
    if(transferReport[Strings.medicalAttentionYes] == 0 && transferReport[Strings.medicalAttentionNo] == 0){
      successPatientDetails = false;
    }
    if(transferReport[Strings.medicalAttentionYes] == null && transferReport[Strings.medicalAttentionNo] == 0){
      successPatientDetails = false;
    }
    if(transferReport[Strings.medicalAttentionYes] == 0 && transferReport[Strings.medicalAttentionNo] == null){
      successPatientDetails = false;
    }

    if(transferReport[Strings.medicalAttentionYes] == 1){
      if(transferReport[Strings.medicalAttention]== null || transferReport[Strings.medicalAttention].toString().trim() == ''){
        successPatientDetails = false;
      }
    }


    if(transferReport[Strings.currentMedication]== null || transferReport[Strings.currentMedication].toString().trim() == ''){
      successPatientDetails = false;
    }

    if(transferReport[Strings.physicalObservations]== null || transferReport[Strings.physicalObservations].toString().trim() == ''){
      successPatientDetails = false;
    }

    if(transferReport[Strings.relevantInformationYes] == null && transferReport[Strings.relevantInformationNo] == null){
      successPatientDetails = false;
    }
    if(transferReport[Strings.relevantInformationYes] == 0 && transferReport[Strings.relevantInformationNo] == 0){
      successPatientDetails = false;
    }
    if(transferReport[Strings.relevantInformationYes] == null && transferReport[Strings.relevantInformationNo] == 0){
      successPatientDetails = false;
    }
    if(transferReport[Strings.relevantInformationYes] == 0 && transferReport[Strings.relevantInformationNo] == null){
      successPatientDetails = false;
    }


    if(transferReport[Strings.relevantInformationYes] == 1){
      if(transferReport[Strings.relevantInformation]== null || transferReport[Strings.relevantInformation].toString().trim() == ''){
        successPatientDetails = false;
      }
    }




    if(transferReport[Strings.patientReport]== null || transferReport[Strings.patientReport].toString().trim() == ''){
      successPatientDetails = false;
    }
    if(transferReport[Strings.patientReportPrintName]== null || transferReport[Strings.patientReportPrintName].toString().trim() == ''){
      successPatientDetails = false;
    }
    if(transferReport[Strings.patientReportRole]== null || transferReport[Strings.patientReportRole].toString().trim() == ''){
      successPatientDetails = false;
    }
    if(transferReport[Strings.patientReportDate] == null){
      successPatientDetails = false;
    }
    if(transferReport[Strings.patientReportTime] == null){
      successPatientDetails = false;
    }
    if(transferReport[Strings.patientReportSignature] == null){
      successPatientDetails = false;
    }

    //Physical Intervention
    if(transferReport[Strings.physicalInterventionYes] == 1){
      if(transferReport[Strings.whyInterventionRequired]== null || transferReport[Strings.whyInterventionRequired].toString().trim() == ''){
        successPatientDetails = false;
      }
      if(transferReport[Strings.timeInterventionCommenced] == null){
        successPatientDetails = false;
      }
      if(transferReport[Strings.timeInterventionCompleted] == null){
        successPatientDetails = false;
      }
    }

    if(transferReport[Strings.handcuffsUsedYes] == 1){

      if(transferReport[Strings.handcuffsDate] == null){
        successPatientDetails = false;
      }
      if(transferReport[Strings.handcuffsTime] == null){
        successPatientDetails = false;
      }
      if(transferReport[Strings.handcuffsAuthorisedBy]== null || transferReport[Strings.handcuffsAuthorisedBy].toString().trim() == ''){
        successPatientDetails = false;
      }
      if(transferReport[Strings.handcuffsAppliedBy]== null || transferReport[Strings.handcuffsAppliedBy].toString().trim() == ''){
        successPatientDetails = false;
      }
      if(transferReport[Strings.handcuffsRemovedTime] == null){
        successPatientDetails = false;
      }
      if(transferReport[Strings.incidentDate] == null){
        successPatientDetails = false;
      }
      if(transferReport[Strings.incidentTime] == null){
        successPatientDetails = false;
      }
      if(transferReport[Strings.incidentDetails]== null || transferReport[Strings.incidentDetails].toString().trim() == ''){
        successPatientDetails = false;
      }
      if(transferReport[Strings.incidentSignature] == null){
        successPatientDetails = false;
      }
      if(transferReport[Strings.incidentSignatureDate] == null){
        successPatientDetails = false;
      }
      if(transferReport[Strings.incidentPrintName]== null || transferReport[Strings.incidentPrintName].toString().trim() == ''){
        successPatientDetails = false;
      }
    }


    if(transferReport[Strings.vehicleCompletedBy1]== null || transferReport[Strings.vehicleCompletedBy1].toString().trim() == ''){
      successVehicleChecklist = false;
    }

    if(transferReport[Strings.vehicleDate] == null){
      successVehicleChecklist = false;
    }

    if(transferReport[Strings.vehicleTime] == null){
      successVehicleChecklist = false;
    }

    if(transferReport[Strings.ambulanceReg]== null || transferReport[Strings.ambulanceReg].toString().trim() == ''){
      successVehicleChecklist = false;
    }

    // if(transferReport[Strings.vehicleStartMileage]== null || transferReport[Strings.vehicleStartMileage].toString().trim() == ''){
    //   successVehicleChecklist = false;
    // }

    if(transferReport[Strings.nearestTank1]== null || transferReport[Strings.nearestTank1].toString().trim() == ''){
      successVehicleChecklist = false;
    }

    if(transferReport[Strings.ambulanceTidyYes1] == null && transferReport[Strings.ambulanceTidyNo1] == null){
      successVehicleChecklist = false;
    }
    if(transferReport[Strings.ambulanceTidyYes1] == 0 && transferReport[Strings.ambulanceTidyNo1] == 0){
      successVehicleChecklist = false;
    }
    if(transferReport[Strings.ambulanceTidyYes1] == null && transferReport[Strings.ambulanceTidyNo1] == 0){
      successVehicleChecklist = false;
    }
    if(transferReport[Strings.ambulanceTidyYes1] == 0 && transferReport[Strings.ambulanceTidyNo1] == null){
      successVehicleChecklist = false;
    }

    if(transferReport[Strings.lightsWorkingYes] == null && transferReport[Strings.lightsWorkingNo] == null){
      successVehicleChecklist = false;
    }
    if(transferReport[Strings.lightsWorkingYes] == 0 && transferReport[Strings.lightsWorkingNo] == 0){
      successVehicleChecklist = false;
    }
    if(transferReport[Strings.lightsWorkingYes] == null && transferReport[Strings.lightsWorkingNo] == 0){
      successVehicleChecklist = false;
    }
    if(transferReport[Strings.lightsWorkingYes] == 0 && transferReport[Strings.lightsWorkingNo] == null){
      successVehicleChecklist = false;
    }

    if(transferReport[Strings.tyresInflatedYes] == null && transferReport[Strings.tyresInflatedNo] == null){
      successVehicleChecklist = false;
    }
    if(transferReport[Strings.tyresInflatedYes] == 0 && transferReport[Strings.tyresInflatedNo] == 0){
      successVehicleChecklist = false;
    }
    if(transferReport[Strings.tyresInflatedYes] == null && transferReport[Strings.tyresInflatedNo] == 0){
      successVehicleChecklist = false;
    }
    if(transferReport[Strings.tyresInflatedYes] == 0 && transferReport[Strings.tyresInflatedNo] == null){
      successVehicleChecklist = false;
    }

    if(transferReport[Strings.warningSignsYes] == null && transferReport[Strings.warningSignsNo] == null){
      successVehicleChecklist = false;
    }
    if(transferReport[Strings.warningSignsYes] == 0 && transferReport[Strings.warningSignsNo] == 0){
      successVehicleChecklist = false;
    }
    if(transferReport[Strings.warningSignsYes] == null && transferReport[Strings.warningSignsNo] == 0){
      successVehicleChecklist = false;
    }
    if(transferReport[Strings.warningSignsYes] == 0 && transferReport[Strings.warningSignsNo] == null){
      successVehicleChecklist = false;
    }

    if(transferReport[Strings.vehicleCompletedBy2]== null || transferReport[Strings.vehicleCompletedBy2].toString().trim() == ''){
      successVehicleChecklist = false;
    }

    if(transferReport[Strings.nearestTank2]== null || transferReport[Strings.nearestTank2].toString().trim() == ''){
      successVehicleChecklist = false;
    }

    if(transferReport[Strings.finishMileage]== null || transferReport[Strings.finishMileage].toString().trim() == ''){
      successVehicleChecklist = false;
    }

    if(transferReport[Strings.totalMileage]== null || transferReport[Strings.totalMileage].toString().trim() == ''){
      successVehicleChecklist = false;
    }

    if(transferReport[Strings.ambulanceTidyYes2] == null && transferReport[Strings.ambulanceTidyNo2] == null){
      successVehicleChecklist = false;
    }
    if(transferReport[Strings.ambulanceTidyYes2] == 0 && transferReport[Strings.ambulanceTidyNo2] == 0){
      successVehicleChecklist = false;
    }
    if(transferReport[Strings.ambulanceTidyYes2] == null && transferReport[Strings.ambulanceTidyNo2] == 0){
      successVehicleChecklist = false;
    }
    if(transferReport[Strings.ambulanceTidyYes2] == 0 && transferReport[Strings.ambulanceTidyNo2] == null){
      successVehicleChecklist = false;
    }

    if(transferReport[Strings.sanitiserCleanYes] == null && transferReport[Strings.sanitiserCleanNo] == null){
      successVehicleChecklist = false;
    }
    if(transferReport[Strings.sanitiserCleanYes] == 0 && transferReport[Strings.sanitiserCleanNo] == 0){
      successVehicleChecklist = false;
    }
    if(transferReport[Strings.sanitiserCleanYes] == null && transferReport[Strings.sanitiserCleanNo] == 0){
      successVehicleChecklist = false;
    }
    if(transferReport[Strings.sanitiserCleanYes] == 0 && transferReport[Strings.sanitiserCleanNo] == null){
      successVehicleChecklist = false;
    }

    if(transferReport[Strings.ambulanceTidyNo1] == 1 || transferReport[Strings.lightsWorkingNo] == 1 || transferReport[Strings.tyresInflatedNo] == 1 || transferReport[Strings.warningSignsNo] == 1 || transferReport[Strings.ambulanceTidyNo2] == 1 || transferReport[Strings.sanitiserCleanNo] == 1){
      if(transferReport[Strings.issuesFaults]== null || transferReport[Strings.issuesFaults].toString().trim() == ''){
        successVehicleChecklist = false;
      }
    }








    return{'successJobDetails' : successJobDetails, 'successPatientDetails' : successPatientDetails, 'successVehicleChecklist': successVehicleChecklist};

  }


  Future<bool> submitTransferReport(String jobId, bool edit, bool saved, int savedId) async {

    GlobalFunctions.showLoadingDialog('Submitting Transfer Report...');
    String message = '';
    bool success = false;
    List<String> storageUrlList = [];

    int id = DateTime.now().millisecondsSinceEpoch + int.parse(random_string.randomNumeric(2));
    Map<String, dynamic> transferReport = await getTemporaryRecord(false, jobId, saved, savedId);


    Map<String, dynamic> localData = {
      Strings.localId: id,
      Strings.documentId: null,
      Strings.uid: user.uid,
      Strings.jobId: '1',
      Strings.formVersion: '1',
      Strings.jobRef: transferReport[Strings.jobRef],
      Strings.date: transferReport[Strings.date],
      Strings.startTime: transferReport[Strings.startTime],
      Strings.finishTime: transferReport[Strings.finishTime],
      Strings.totalHours: transferReport[Strings.totalHours],
      Strings.collectionDetails: transferReport[Strings.collectionDetails],
      Strings.collectionPostcode: transferReport[Strings.collectionPostcode],
      Strings.collectionContactNo: transferReport[Strings.collectionContactNo],
      Strings.destinationDetails: transferReport[Strings.destinationDetails],
      Strings.destinationPostcode: transferReport[Strings.destinationPostcode],
      Strings.destinationContactNo: transferReport[Strings.destinationContactNo],
      Strings.collectionArrivalTime: transferReport[Strings.collectionArrivalTime],
      Strings.collectionDepartureTime: transferReport[Strings.collectionDepartureTime],
      Strings.destinationArrivalTime: transferReport[Strings.destinationArrivalTime],
      Strings.destinationDepartureTime: transferReport[Strings.destinationDepartureTime],
      Strings.vehicleRegNo: transferReport[Strings.vehicleRegNo],
      Strings.startMileage: transferReport[Strings.startMileage],
      Strings.finishMileage: transferReport[Strings.finishMileage],
      Strings.totalMileage: transferReport[Strings.totalMileage],
      Strings.name1: transferReport[Strings.name1],
      Strings.role1: transferReport[Strings.role1],
      Strings.drivingTimes1_1: transferReport[Strings.drivingTimes1_1],
      Strings.drivingTimes1_2: transferReport[Strings.drivingTimes1_2],
      Strings.name2: transferReport[Strings.name2],
      Strings.role2: transferReport[Strings.role2],
      Strings.drivingTimes2_1: transferReport[Strings.drivingTimes2_1],
      Strings.drivingTimes2_2: transferReport[Strings.drivingTimes2_2],
      Strings.name3: transferReport[Strings.name3],
      Strings.role3: transferReport[Strings.role3],
      Strings.drivingTimes3_1: transferReport[Strings.drivingTimes3_1],
      Strings.drivingTimes3_2: transferReport[Strings.drivingTimes3_2],
      Strings.name4: transferReport[Strings.name4],
      Strings.role4: transferReport[Strings.role4],
      Strings.drivingTimes4_1: transferReport[Strings.drivingTimes4_1],
      Strings.drivingTimes4_2: transferReport[Strings.drivingTimes4_2],
      Strings.name5: transferReport[Strings.name5],
      Strings.role5: transferReport[Strings.role5],
      Strings.drivingTimes5_1: transferReport[Strings.drivingTimes5_1],
      Strings.drivingTimes5_2: transferReport[Strings.drivingTimes5_2],
      Strings.name6: transferReport[Strings.name6],
      Strings.role6: transferReport[Strings.role6],
      Strings.drivingTimes6_1: transferReport[Strings.drivingTimes6_1],
      Strings.drivingTimes6_2: transferReport[Strings.drivingTimes6_2],
      Strings.name7: transferReport[Strings.name7],
      Strings.role7: transferReport[Strings.role7],
      Strings.drivingTimes7_1: transferReport[Strings.drivingTimes7_1],
      Strings.drivingTimes7_2: transferReport[Strings.drivingTimes7_2],
      Strings.name8: transferReport[Strings.name8],
      Strings.role8: transferReport[Strings.role8],
      Strings.drivingTimes8_1: transferReport[Strings.drivingTimes8_1],
      Strings.drivingTimes8_2: transferReport[Strings.drivingTimes8_2],
      Strings.name9: transferReport[Strings.name9],
      Strings.role9: transferReport[Strings.role9],
      Strings.drivingTimes9_1: transferReport[Strings.drivingTimes9_1],
      Strings.drivingTimes9_2: transferReport[Strings.drivingTimes9_2],
      Strings.name10: transferReport[Strings.name10],
      Strings.role10: transferReport[Strings.role10],
      Strings.drivingTimes10_1: transferReport[Strings.drivingTimes10_1],
      Strings.drivingTimes10_2: transferReport[Strings.drivingTimes10_2],
      Strings.name11: transferReport[Strings.name11],
      Strings.role11: transferReport[Strings.role11],
      Strings.drivingTimes11_1: transferReport[Strings.drivingTimes11_1],
      Strings.drivingTimes11_2: transferReport[Strings.drivingTimes11_2],
      Strings.collectionUnit: transferReport[Strings.collectionUnit],
      Strings.collectionPosition: transferReport[Strings.collectionPosition],
      Strings.collectionPrintName: transferReport[Strings.collectionPrintName],
      Strings.collectionArrivalTimeEnd: transferReport[Strings.collectionArrivalTimeEnd],
      Strings.collectionSignature: transferReport[Strings.collectionSignature],
      Strings.destinationUnit: transferReport[Strings.destinationUnit],
      Strings.destinationPosition: transferReport[Strings.destinationPosition],
      Strings.destinationPrintName: transferReport[Strings.destinationPrintName],
      Strings.destinationArrivalTimeEnd: transferReport[Strings.destinationArrivalTimeEnd],
      Strings.destinationSignature: transferReport[Strings.destinationSignature],
      Strings.patientName: transferReport[Strings.patientName],
      Strings.dateOfBirth: transferReport[Strings.dateOfBirth],
      Strings.ethnicity: transferReport[Strings.ethnicity],
      Strings.gender: transferReport[Strings.gender],
      Strings.mhaMcaDetails: transferReport[Strings.mhaMcaDetails],
      Strings.diagnosis: transferReport[Strings.diagnosis],
      Strings.currentPresentation: transferReport[Strings.currentPresentation],
      Strings.riskYes: transferReport[Strings.riskYes],
      Strings.riskNo: transferReport[Strings.riskNo],
      Strings.riskExplanation: transferReport[Strings.riskExplanation],
      Strings.forensicHistoryYes: transferReport[Strings.forensicHistoryYes],
      Strings.forensicHistoryNo: transferReport[Strings.forensicHistoryNo],
      Strings.racialGenderConcernsYes: transferReport[Strings.racialGenderConcernsYes],
      Strings.racialGenderConcernsNo: transferReport[Strings.racialGenderConcernsNo],
      Strings.violenceAggressionYes: transferReport[Strings.violenceAggressionYes],
      Strings.violenceAggressionNo: transferReport[Strings.violenceAggressionNo],
      Strings.selfHarmYes: transferReport[Strings.selfHarmYes],
      Strings.selfHarmNo: transferReport[Strings.selfHarmNo],
      Strings.alcoholSubstanceYes: transferReport[Strings.alcoholSubstanceYes],
      Strings.alcoholSubstanceNo: transferReport[Strings.alcoholSubstanceNo],
      Strings.virusesYes: transferReport[Strings.virusesYes],
      Strings.virusesNo: transferReport[Strings.virusesNo],
      Strings.safeguardingYes: transferReport[Strings.safeguardingYes],
      Strings.safeguardingNo: transferReport[Strings.safeguardingNo],
      Strings.physicalHealthConditionsYes: transferReport[Strings.physicalHealthConditionsYes],
      Strings.physicalHealthConditionsNo: transferReport[Strings.physicalHealthConditionsNo],
      Strings.useOfWeaponYes: transferReport[Strings.useOfWeaponYes],
      Strings.useOfWeaponNo: transferReport[Strings.useOfWeaponNo],
      Strings.absconsionRiskYes: transferReport[Strings.absconsionRiskYes],
      Strings.absconsionRiskNo: transferReport[Strings.absconsionRiskNo],
      Strings.forensicHistory: transferReport[Strings.forensicHistory],
      Strings.racialGenderConcerns: transferReport[Strings.racialGenderConcerns],
      Strings.violenceAggression: transferReport[Strings.violenceAggression],
      Strings.selfHarm: transferReport[Strings.selfHarm],
      Strings.alcoholSubstance: transferReport[Strings.alcoholSubstance],
      Strings.viruses: transferReport[Strings.viruses],
      Strings.safeguarding: transferReport[Strings.safeguarding],
      Strings.physicalHealthConditions: transferReport[Strings.physicalHealthConditions],
      Strings.useOfWeapon: transferReport[Strings.useOfWeapon],
      Strings.absconsionRisk: transferReport[Strings.absconsionRisk],
      Strings.patientPropertyYes: transferReport[Strings.patientPropertyYes],
      Strings.patientPropertyNo: transferReport[Strings.patientPropertyNo],
      Strings.patientPropertyExplanation: transferReport[Strings.riskExplanation],
      Strings.patientPropertyReceived: transferReport[Strings.patientPropertyReceived],
      Strings.patientPropertyReceivedYes: transferReport[Strings.patientPropertyReceivedYes],
      Strings.patientPropertyReceivedNo: transferReport[Strings.patientPropertyReceivedNo],
      Strings.patientNotesReceived: transferReport[Strings.patientNotesReceived],
      Strings.patientNotesReceivedYes: transferReport[Strings.patientNotesReceivedYes],
      Strings.patientNotesReceivedNo: transferReport[Strings.patientNotesReceivedNo],
      Strings.patientSearched: transferReport[Strings.patientSearched],
      Strings.patientSearchedYes: transferReport[Strings.patientSearchedYes],
      Strings.patientSearchedNo: transferReport[Strings.patientSearchedNo],
      Strings.itemsRemovedYes: transferReport[Strings.itemsRemovedYes],
      Strings.itemsRemovedNo: transferReport[Strings.itemsRemovedNo],
      Strings.itemsRemoved: transferReport[Strings.itemsRemoved],
      Strings.patientInformed: transferReport[Strings.patientInformed],
      Strings.injuriesNoted: transferReport[Strings.injuriesNoted],
      Strings.bodyMapImage: transferReport[Strings.bodyMapImage],
      Strings.medicalAttentionYes: transferReport[Strings.medicalAttentionYes],
      Strings.medicalAttentionNo: transferReport[Strings.medicalAttentionNo],
      Strings.relevantInformationYes: transferReport[Strings.relevantInformationYes],
      Strings.relevantInformationNo: transferReport[Strings.relevantInformationNo],
      Strings.medicalAttention: transferReport[Strings.medicalAttention],
      Strings.currentMedication: transferReport[Strings.currentMedication],
      Strings.physicalObservations: transferReport[Strings.physicalObservations],
      Strings.relevantInformation: transferReport[Strings.relevantInformation],
      Strings.patientReport: transferReport[Strings.patientReport],
      Strings.patientReportPrintName: transferReport[Strings.patientReportPrintName],
      Strings.patientReportRole: transferReport[Strings.patientReportRole],
      Strings.patientReportDate: transferReport[Strings.patientReportDate],
      Strings.patientReportTime: transferReport[Strings.patientReportTime],
      Strings.patientReportSignature: transferReport[Strings.patientReportSignature],
      Strings.handcuffsUsedYes: transferReport[Strings.handcuffsUsedYes],
      Strings.handcuffsUsedNo: transferReport[Strings.handcuffsUsedNo],
      Strings.handcuffsDate: transferReport[Strings.handcuffsDate],
      Strings.handcuffsTime: transferReport[Strings.handcuffsTime],
      Strings.handcuffsAuthorisedBy: transferReport[Strings.handcuffsAuthorisedBy],
      Strings.handcuffsAppliedBy: transferReport[Strings.handcuffsAppliedBy],
      Strings.handcuffsRemovedTime: transferReport[Strings.handcuffsRemovedTime],
      Strings.physicalInterventionYes: transferReport[Strings.physicalInterventionYes],
      Strings.physicalInterventionNo: transferReport[Strings.physicalInterventionNo],
      Strings.physicalIntervention: transferReport[Strings.physicalIntervention],
      Strings.whyInterventionRequired: transferReport[Strings.whyInterventionRequired],
      Strings.techniqueName1: transferReport[Strings.techniqueName1],
      Strings.techniqueName2: transferReport[Strings.techniqueName2],
      Strings.techniqueName3: transferReport[Strings.techniqueName3],
      Strings.techniqueName4: transferReport[Strings.techniqueName4],
      Strings.techniqueName5: transferReport[Strings.techniqueName5],
      Strings.techniqueName6: transferReport[Strings.techniqueName6],
      Strings.techniqueName7: transferReport[Strings.techniqueName7],
      Strings.techniqueName8: transferReport[Strings.techniqueName8],
      Strings.techniqueName9: transferReport[Strings.techniqueName9],
      Strings.techniqueName10: transferReport[Strings.techniqueName10],
      Strings.technique1: transferReport[Strings.technique1],
      Strings.technique2: transferReport[Strings.technique2],
      Strings.technique3: transferReport[Strings.technique3],
      Strings.technique4: transferReport[Strings.technique4],
      Strings.technique5: transferReport[Strings.technique5],
      Strings.technique6: transferReport[Strings.technique6],
      Strings.technique7: transferReport[Strings.technique7],
      Strings.technique8: transferReport[Strings.technique8],
      Strings.technique9: transferReport[Strings.technique9],
      Strings.technique10: transferReport[Strings.technique10],
      Strings.techniquePosition1: transferReport[Strings.techniquePosition1],
      Strings.techniquePosition2: transferReport[Strings.techniquePosition2],
      Strings.techniquePosition3: transferReport[Strings.techniquePosition3],
      Strings.techniquePosition4: transferReport[Strings.techniquePosition4],
      Strings.techniquePosition5: transferReport[Strings.techniquePosition5],
      Strings.techniquePosition6: transferReport[Strings.techniquePosition6],
      Strings.techniquePosition7: transferReport[Strings.techniquePosition7],
      Strings.techniquePosition8: transferReport[Strings.techniquePosition8],
      Strings.techniquePosition9: transferReport[Strings.techniquePosition9],
      Strings.techniquePosition10: transferReport[Strings.techniquePosition10],
      Strings.timeInterventionCommenced: transferReport[Strings.timeInterventionCommenced],
      Strings.timeInterventionCompleted: transferReport[Strings.timeInterventionCompleted],
      Strings.incidentDate: transferReport[Strings.incidentDate],
      Strings.incidentTime: transferReport[Strings.incidentTime],
      Strings.incidentDetails: transferReport[Strings.incidentDetails],
      Strings.incidentLocation: transferReport[Strings.incidentLocation],
      Strings.incidentAction: transferReport[Strings.incidentAction],
      Strings.incidentStaffInvolved: transferReport[Strings.incidentStaffInvolved],
      Strings.incidentSignature: transferReport[Strings.incidentSignature],
      Strings.incidentSignatureDate: transferReport[Strings.incidentSignatureDate],
      Strings.incidentPrintName: transferReport[Strings.incidentPrintName],
      Strings.hasSection2Checklist: transferReport[Strings.hasSection2Checklist],
      Strings.hasSection3Checklist: transferReport[Strings.hasSection3Checklist],
      Strings.hasSection3TransferChecklist: transferReport[Strings.hasSection3TransferChecklist],
      Strings.transferInPatientName1: transferReport[Strings.transferInPatientName1],
      Strings.patientCorrectYes1: transferReport[Strings.patientCorrectYes1],
      Strings.patientCorrectNo1: transferReport[Strings.patientCorrectNo1],
      Strings.hospitalCorrectYes1: transferReport[Strings.hospitalCorrectYes1],
      Strings.hospitalCorrectNo1: transferReport[Strings.hospitalCorrectNo1],
      Strings.applicationFormYes1: transferReport[Strings.applicationFormYes1],
      Strings.applicationFormNo1: transferReport[Strings.applicationFormNo1],
      Strings.applicationSignedYes1: transferReport[Strings.applicationSignedYes1],
      Strings.applicationSignedNo1: transferReport[Strings.applicationSignedNo1],
      Strings.within14DaysYes1: transferReport[Strings.within14DaysYes1],
      Strings.within14DaysNo1: transferReport[Strings.within14DaysNo1],
      Strings.localAuthorityNameYes1: transferReport[Strings.localAuthorityNameYes1],
      Strings.localAuthorityNameNo1: transferReport[Strings.localAuthorityNameNo1],
      Strings.medicalRecommendationsFormYes1: transferReport[Strings.medicalRecommendationsFormYes1],
      Strings.medicalRecommendationsFormNo1: transferReport[Strings.medicalRecommendationsFormNo1],
      Strings.medicalRecommendationsSignedYes1: transferReport[Strings.medicalRecommendationsSignedYes1],
      Strings.medicalRecommendationsSignedNo1: transferReport[Strings.medicalRecommendationsSignedNo1],
      Strings.datesSignatureSignedYes: transferReport[Strings.datesSignatureSignedYes],
      Strings.datesSignatureSignedNo: transferReport[Strings.datesSignatureSignedNo],
      Strings.signatureDatesOnBeforeYes1: transferReport[Strings.signatureDatesOnBeforeYes1],
      Strings.signatureDatesOnBeforeNo1: transferReport[Strings.signatureDatesOnBeforeNo1],
      Strings.practitionersNameYes1: transferReport[Strings.practitionersNameYes1],
      Strings.practitionersNameNo1: transferReport[Strings.practitionersNameNo1],
      Strings.transferInCheckedBy1: transferReport[Strings.transferInCheckedBy1],
      Strings.transferInDate1: transferReport[Strings.transferInDate1],
      Strings.transferInDesignation1: transferReport[Strings.transferInDesignation1],
      Strings.transferInSignature1: transferReport[Strings.transferInSignature1],
      Strings.transferInPatientName2: transferReport[Strings.transferInPatientName2],
      Strings.patientCorrectYes2: transferReport[Strings.patientCorrectYes2],
      Strings.patientCorrectNo2: transferReport[Strings.patientCorrectNo2],
      Strings.hospitalCorrectYes2: transferReport[Strings.hospitalCorrectYes2],
      Strings.hospitalCorrectNo2: transferReport[Strings.hospitalCorrectNo2],
      Strings.applicationFormYes2: transferReport[Strings.applicationFormYes2],
      Strings.applicationFormNo2: transferReport[Strings.applicationFormNo2],
      Strings.applicationSignedYes2: transferReport[Strings.applicationSignedYes2],
      Strings.applicationSignedNo2: transferReport[Strings.applicationSignedNo2],
      Strings.amhpIdentifiedYes: transferReport[Strings.amhpIdentifiedYes],
      Strings.amhpIdentifiedNo: transferReport[Strings.amhpIdentifiedNo],
      Strings.medicalRecommendationsFormYes2: transferReport[Strings.medicalRecommendationsFormYes2],
      Strings.medicalRecommendationsFormNo2: transferReport[Strings.medicalRecommendationsFormNo2],
      Strings.medicalRecommendationsSignedYes2: transferReport[Strings.medicalRecommendationsSignedYes2],
      Strings.medicalRecommendationsSignedNo2: transferReport[Strings.medicalRecommendationsSignedNo2],
      Strings.clearDaysYes2: transferReport[Strings.clearDaysYes2],
      Strings.clearDaysNo2: transferReport[Strings.clearDaysNo2],
      Strings.signatureDatesOnBeforeYes2: transferReport[Strings.signatureDatesOnBeforeYes2],
      Strings.signatureDatesOnBeforeNo2: transferReport[Strings.signatureDatesOnBeforeNo2],
      Strings.practitionersNameYes2: transferReport[Strings.practitionersNameYes2],
      Strings.practitionersNameNo2: transferReport[Strings.practitionersNameNo2],
      Strings.doctorsAgreeYes: transferReport[Strings.doctorsAgreeYes],
      Strings.doctorsAgreeNo: transferReport[Strings.doctorsAgreeNo],
      Strings.separateMedicalRecommendationsYes: transferReport[Strings.separateMedicalRecommendationsYes],
      Strings.separateMedicalRecommendationsNo: transferReport[Strings.separateMedicalRecommendationsNo],
      Strings.transferInCheckedBy2: transferReport[Strings.transferInCheckedBy2],
      Strings.transferInDate2: transferReport[Strings.transferInDate2],
      Strings.transferInDesignation2: transferReport[Strings.transferInDesignation2],
      Strings.transferInSignature2: transferReport[Strings.transferInSignature2],
      Strings.transferInPatientName3: transferReport[Strings.transferInPatientName3],
      Strings.patientCorrectYes3: transferReport[Strings.patientCorrectYes3],
      Strings.patientCorrectNo3: transferReport[Strings.patientCorrectNo3],
      Strings.hospitalCorrectYes3: transferReport[Strings.hospitalCorrectYes3],
      Strings.hospitalCorrectNo3: transferReport[Strings.hospitalCorrectNo3],
      Strings.h4Yes: transferReport[Strings.h4Yes],
      Strings.h4No: transferReport[Strings.h4No],
      Strings.currentConsentYes: transferReport[Strings.currentConsentYes],
      Strings.currentConsentNo: transferReport[Strings.currentConsentNo],
      Strings.applicationFormYes3: transferReport[Strings.applicationFormYes3],
      Strings.applicationFormNo3: transferReport[Strings.applicationFormNo3],
      Strings.applicationSignedYes3: transferReport[Strings.applicationSignedYes3],
      Strings.applicationSignedNo3: transferReport[Strings.applicationSignedNo3],
      Strings.within14DaysYes3: transferReport[Strings.within14DaysYes3],
      Strings.within14DaysNo3: transferReport[Strings.within14DaysNo3],
      Strings.localAuthorityNameYes3: transferReport[Strings.localAuthorityNameYes3],
      Strings.localAuthorityNameNo3: transferReport[Strings.localAuthorityNameNo3],
      Strings.nearestRelativeYes: transferReport[Strings.nearestRelativeYes],
      Strings.nearestRelativeNo: transferReport[Strings.nearestRelativeNo],
      Strings.amhpConsultationYes: transferReport[Strings.amhpConsultationYes],
      Strings.amhpConsultationNo: transferReport[Strings.amhpConsultationNo],
      Strings.knewPatientYes: transferReport[Strings.knewPatientYes],
      Strings.knewPatientNo: transferReport[Strings.knewPatientNo],
      Strings.medicalRecommendationsFormYes3: transferReport[Strings.medicalRecommendationsFormYes3],
      Strings.medicalRecommendationsFormNo3: transferReport[Strings.medicalRecommendationsFormNo3],
      Strings.medicalRecommendationsSignedYes3: transferReport[Strings.medicalRecommendationsSignedYes3],
      Strings.medicalRecommendationsSignedNo3: transferReport[Strings.medicalRecommendationsSignedNo3],
      Strings.clearDaysYes3: transferReport[Strings.clearDaysYes3],
      Strings.clearDaysNo3: transferReport[Strings.clearDaysNo3],
      Strings.approvedSection12Yes: transferReport[Strings.approvedSection12Yes],
      Strings.approvedSection12No: transferReport[Strings.approvedSection12No],
      Strings.signatureDatesOnBeforeYes3: transferReport[Strings.signatureDatesOnBeforeYes3],
      Strings.signatureDatesOnBeforeNo3: transferReport[Strings.signatureDatesOnBeforeNo3],
      Strings.practitionersNameYes3: transferReport[Strings.practitionersNameYes3],
      Strings.practitionersNameNo3: transferReport[Strings.practitionersNameNo3],
      Strings.previouslyAcquaintedYes: transferReport[Strings.previouslyAcquaintedYes],
      Strings.previouslyAcquaintedNo: transferReport[Strings.previouslyAcquaintedNo],
      Strings.acquaintedIfNoYes: transferReport[Strings.acquaintedIfNoYes],
      Strings.acquaintedIfNoNo: transferReport[Strings.acquaintedIfNoNo],
      Strings.recommendationsDifferentTeamsYes: transferReport[Strings.recommendationsDifferentTeamsYes],
      Strings.recommendationsDifferentTeamsNo: transferReport[Strings.recommendationsDifferentTeamsNo],
      Strings.originalDetentionPapersYes: transferReport[Strings.originalDetentionPapersYes],
      Strings.originalDetentionPapersNo: transferReport[Strings.originalDetentionPapersNo],
      Strings.transferInCheckedBy3: transferReport[Strings.transferInCheckedBy3],
      Strings.transferInDate3: transferReport[Strings.transferInDate3],
      Strings.transferInDesignation3: transferReport[Strings.transferInDesignation3],
      Strings.transferInSignature3: transferReport[Strings.transferInSignature3],
      Strings.feltSafeYes: transferReport[Strings.feltSafeYes],
      Strings.feltSafeNo: transferReport[Strings.feltSafeNo],
      Strings.staffIntroducedYes: transferReport[Strings.staffIntroducedYes],
      Strings.staffIntroducedNo: transferReport[Strings.staffIntroducedNo],
      Strings.experiencePositiveYes: transferReport[Strings.experiencePositiveYes],
      Strings.experiencePositiveNo: transferReport[Strings.experiencePositiveNo],
      Strings.otherComments: transferReport[Strings.otherComments],
      Strings.vehicleCompletedBy1: transferReport[Strings.vehicleCompletedBy1],
      Strings.vehicleDate: transferReport[Strings.vehicleDate],
      Strings.vehicleTime: transferReport[Strings.vehicleTime],
      Strings.ambulanceReg: transferReport[Strings.ambulanceReg],
      Strings.vehicleStartMileage: transferReport[Strings.vehicleStartMileage],
      Strings.nearestTank1: transferReport[Strings.nearestTank1],
      Strings.ambulanceTidyYes1: transferReport[Strings.ambulanceTidyYes1],
      Strings.ambulanceTidyNo1: transferReport[Strings.ambulanceTidyNo1],
      Strings.lightsWorkingYes: transferReport[Strings.lightsWorkingYes],
      Strings.lightsWorkingNo: transferReport[Strings.lightsWorkingNo],
      Strings.tyresInflatedYes: transferReport[Strings.tyresInflatedYes],
      Strings.tyresInflatedNo: transferReport[Strings.tyresInflatedNo],
      Strings.warningSignsYes: transferReport[Strings.warningSignsYes],
      Strings.warningSignsNo: transferReport[Strings.warningSignsNo],
      Strings.vehicleCompletedBy2: transferReport[Strings.vehicleCompletedBy2],
      Strings.nearestTank2: transferReport[Strings.nearestTank2],
      Strings.vehicleFinishMileage: transferReport[Strings.vehicleFinishMileage],
      Strings.ambulanceTidyYes2: transferReport[Strings.ambulanceTidyYes2],
      Strings.ambulanceTidyNo2: transferReport[Strings.ambulanceTidyNo2],
      Strings.sanitiserCleanYes: transferReport[Strings.sanitiserCleanYes],
      Strings.sanitiserCleanNo: transferReport[Strings.sanitiserCleanNo],
      Strings.issuesFaults: transferReport[Strings.issuesFaults],
      Strings.pendingTime: DateTime.now().toIso8601String(),
      Strings.serverUploaded: 0,
    };

    //Sembast
    await _transferReportsStore.record(id).put(await _db,
        localData);


    message = 'Transfer Report has successfully been added to local database';



    bool hasDataConnection = await GlobalFunctions.hasDataConnection();


    if(hasDataConnection){

      bool isTokenExpired = GlobalFunctions.isTokenExpired();
      bool authenticated = true;

      if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

      if(authenticated){


        try {

          await GlobalFunctions.checkFirebaseStorageFail(_databaseHelper);


          DocumentReference ref =
          await FirebaseFirestore.instance.collection('transfer_reports').add({
            Strings.uid: user.uid,
            Strings.jobId: '1',
            Strings.formVersion: '1',
            Strings.jobRef: GlobalFunctions.databaseValueString(transferReport[Strings.jobRef]),
            Strings.jobRefLowercase: GlobalFunctions.databaseValueString(transferReport[Strings.jobRef]).toLowerCase(),
            Strings.date: transferReport[Strings.date] == null ? null : DateTime.parse(transferReport[Strings.date]),
            Strings.startTime: transferReport[Strings.startTime],
            Strings.finishTime: transferReport[Strings.finishTime],
            Strings.totalHours: transferReport[Strings.totalHours],
            Strings.collectionDetails: transferReport[Strings.collectionDetails],
            Strings.collectionPostcode: transferReport[Strings.collectionPostcode],
            Strings.collectionContactNo: transferReport[Strings.collectionContactNo],
            Strings.destinationDetails: transferReport[Strings.destinationDetails],
            Strings.destinationPostcode: transferReport[Strings.destinationPostcode],
            Strings.destinationContactNo: transferReport[Strings.destinationContactNo],
            Strings.collectionArrivalTime: transferReport[Strings.collectionArrivalTime],
            Strings.collectionDepartureTime: transferReport[Strings.collectionDepartureTime],
            Strings.destinationArrivalTime: transferReport[Strings.destinationArrivalTime],
            Strings.destinationDepartureTime: transferReport[Strings.destinationDepartureTime],
            Strings.vehicleRegNo: transferReport[Strings.vehicleRegNo],
            Strings.startMileage: transferReport[Strings.startMileage],
            Strings.finishMileage: transferReport[Strings.finishMileage],
            Strings.totalMileage: transferReport[Strings.totalMileage],
            Strings.name1: transferReport[Strings.name1],
            Strings.role1: transferReport[Strings.role1],
            Strings.drivingTimes1_1: transferReport[Strings.drivingTimes1_1],
            Strings.drivingTimes1_2: transferReport[Strings.drivingTimes1_2],
            Strings.name2: transferReport[Strings.name2],
            Strings.role2: transferReport[Strings.role2],
            Strings.drivingTimes2_1: transferReport[Strings.drivingTimes2_1],
            Strings.drivingTimes2_2: transferReport[Strings.drivingTimes2_2],
            Strings.name3: transferReport[Strings.name3],
            Strings.role3: transferReport[Strings.role3],
            Strings.drivingTimes3_1: transferReport[Strings.drivingTimes3_1],
            Strings.drivingTimes3_2: transferReport[Strings.drivingTimes3_2],
            Strings.name4: transferReport[Strings.name4],
            Strings.role4: transferReport[Strings.role4],
            Strings.drivingTimes4_1: transferReport[Strings.drivingTimes4_1],
            Strings.drivingTimes4_2: transferReport[Strings.drivingTimes4_2],
            Strings.name5: transferReport[Strings.name5],
            Strings.role5: transferReport[Strings.role5],
            Strings.drivingTimes5_1: transferReport[Strings.drivingTimes5_1],
            Strings.drivingTimes5_2: transferReport[Strings.drivingTimes5_2],
            Strings.name6: transferReport[Strings.name6],
            Strings.role6: transferReport[Strings.role6],
            Strings.drivingTimes6_1: transferReport[Strings.drivingTimes6_1],
            Strings.drivingTimes6_2: transferReport[Strings.drivingTimes6_2],
            Strings.name7: transferReport[Strings.name7],
            Strings.role7: transferReport[Strings.role7],
            Strings.drivingTimes7_1: transferReport[Strings.drivingTimes7_1],
            Strings.drivingTimes7_2: transferReport[Strings.drivingTimes7_2],
            Strings.name8: transferReport[Strings.name8],
            Strings.role8: transferReport[Strings.role8],
            Strings.drivingTimes8_1: transferReport[Strings.drivingTimes8_1],
            Strings.drivingTimes8_2: transferReport[Strings.drivingTimes8_2],
            Strings.name9: transferReport[Strings.name9],
            Strings.role9: transferReport[Strings.role9],
            Strings.drivingTimes9_1: transferReport[Strings.drivingTimes9_1],
            Strings.drivingTimes9_2: transferReport[Strings.drivingTimes9_2],
            Strings.name10: transferReport[Strings.name10],
            Strings.role10: transferReport[Strings.role10],
            Strings.drivingTimes10_1: transferReport[Strings.drivingTimes10_1],
            Strings.drivingTimes10_2: transferReport[Strings.drivingTimes10_2],
            Strings.name11: transferReport[Strings.name11],
            Strings.role11: transferReport[Strings.role11],
            Strings.drivingTimes11_1: transferReport[Strings.drivingTimes11_1],
            Strings.drivingTimes11_2: transferReport[Strings.drivingTimes11_2],
            Strings.collectionUnit: transferReport[Strings.collectionUnit],
            Strings.collectionPosition: transferReport[Strings.collectionPosition],
            Strings.collectionPrintName: transferReport[Strings.collectionPrintName],
            Strings.collectionArrivalTimeEnd: transferReport[Strings.collectionArrivalTimeEnd],
            Strings.collectionSignature: null,
            Strings.destinationUnit: transferReport[Strings.destinationUnit],
            Strings.destinationPosition: transferReport[Strings.destinationPosition],
            Strings.destinationPrintName: transferReport[Strings.destinationPrintName],
            Strings.destinationArrivalTimeEnd: transferReport[Strings.destinationArrivalTimeEnd],
            Strings.destinationSignature: null,
            Strings.patientName: transferReport[Strings.patientName],
            Strings.dateOfBirth: transferReport[Strings.dateOfBirth],
            Strings.ethnicity: transferReport[Strings.ethnicity],
            Strings.gender: transferReport[Strings.gender],
            Strings.mhaMcaDetails: transferReport[Strings.mhaMcaDetails],
            Strings.diagnosis: transferReport[Strings.diagnosis],
            Strings.currentPresentation: transferReport[Strings.currentPresentation],
            Strings.riskYes: transferReport[Strings.riskYes],
            Strings.riskNo: transferReport[Strings.riskNo],
            Strings.riskExplanation: transferReport[Strings.riskExplanation],
            Strings.forensicHistoryYes: transferReport[Strings.forensicHistoryYes],
            Strings.forensicHistoryNo: transferReport[Strings.forensicHistoryNo],
            Strings.racialGenderConcernsYes: transferReport[Strings.racialGenderConcernsYes],
            Strings.racialGenderConcernsNo: transferReport[Strings.racialGenderConcernsNo],
            Strings.violenceAggressionYes: transferReport[Strings.violenceAggressionYes],
            Strings.violenceAggressionNo: transferReport[Strings.violenceAggressionNo],
            Strings.selfHarmYes: transferReport[Strings.selfHarmYes],
            Strings.selfHarmNo: transferReport[Strings.selfHarmNo],
            Strings.alcoholSubstanceYes: transferReport[Strings.alcoholSubstanceYes],
            Strings.alcoholSubstanceNo: transferReport[Strings.alcoholSubstanceNo],
            Strings.virusesYes: transferReport[Strings.virusesYes],
            Strings.virusesNo: transferReport[Strings.virusesNo],
            Strings.safeguardingYes: transferReport[Strings.safeguardingYes],
            Strings.safeguardingNo: transferReport[Strings.safeguardingNo],
            Strings.physicalHealthConditionsYes: transferReport[Strings.physicalHealthConditionsYes],
            Strings.physicalHealthConditionsNo: transferReport[Strings.physicalHealthConditionsNo],
            Strings.useOfWeaponYes: transferReport[Strings.useOfWeaponYes],
            Strings.useOfWeaponNo: transferReport[Strings.useOfWeaponNo],
            Strings.absconsionRiskYes: transferReport[Strings.absconsionRiskYes],
            Strings.absconsionRiskNo: transferReport[Strings.absconsionRiskNo],
            Strings.forensicHistory: transferReport[Strings.forensicHistory],
            Strings.racialGenderConcerns: transferReport[Strings.racialGenderConcerns],
            Strings.violenceAggression: transferReport[Strings.violenceAggression],
            Strings.selfHarm: transferReport[Strings.selfHarm],
            Strings.alcoholSubstance: transferReport[Strings.alcoholSubstance],
            Strings.viruses: transferReport[Strings.viruses],
            Strings.safeguarding: transferReport[Strings.safeguarding],
            Strings.physicalHealthConditions: transferReport[Strings.physicalHealthConditions],
            Strings.useOfWeapon: transferReport[Strings.useOfWeapon],
            Strings.absconsionRisk: transferReport[Strings.absconsionRisk],
            Strings.patientPropertyYes: transferReport[Strings.patientPropertyYes],
            Strings.patientPropertyNo: transferReport[Strings.patientPropertyNo],
            Strings.patientPropertyExplanation: transferReport[Strings.riskExplanation],
            Strings.patientPropertyReceived: transferReport[Strings.patientPropertyReceived],
            Strings.patientPropertyReceivedYes: transferReport[Strings.patientPropertyReceivedYes],
            Strings.patientPropertyReceivedNo: transferReport[Strings.patientPropertyReceivedNo],
            Strings.patientNotesReceived: transferReport[Strings.patientNotesReceived],
            Strings.patientNotesReceivedYes: transferReport[Strings.patientNotesReceivedYes],
            Strings.patientNotesReceivedNo: transferReport[Strings.patientNotesReceivedNo],
            Strings.patientSearched: transferReport[Strings.patientSearched],
            Strings.patientSearchedYes: transferReport[Strings.patientSearchedYes],
            Strings.patientSearchedNo: transferReport[Strings.patientSearchedNo],
            Strings.itemsRemovedYes: transferReport[Strings.itemsRemovedYes],
            Strings.itemsRemovedNo: transferReport[Strings.itemsRemovedNo],
            Strings.itemsRemoved: transferReport[Strings.itemsRemoved],
            Strings.patientInformed: transferReport[Strings.patientInformed],
            Strings.injuriesNoted: transferReport[Strings.injuriesNoted],
            Strings.bodyMapImage: null,
            Strings.medicalAttentionYes: transferReport[Strings.medicalAttentionYes],
            Strings.medicalAttentionNo: transferReport[Strings.medicalAttentionNo],
            Strings.relevantInformationYes: transferReport[Strings.relevantInformationYes],
            Strings.relevantInformationNo: transferReport[Strings.relevantInformationNo],
            Strings.medicalAttention: transferReport[Strings.medicalAttention],
            Strings.currentMedication: transferReport[Strings.currentMedication],
            Strings.physicalObservations: transferReport[Strings.physicalObservations],
            Strings.relevantInformation: transferReport[Strings.relevantInformation],
            Strings.patientReport: transferReport[Strings.patientReport],
            Strings.patientReportPrintName: transferReport[Strings.patientReportPrintName],
            Strings.patientReportRole: transferReport[Strings.patientReportRole],
            Strings.patientReportDate: transferReport[Strings.patientReportDate],
            Strings.patientReportTime: transferReport[Strings.patientReportTime],
            Strings.patientReportSignature: null,
            Strings.handcuffsUsedYes: transferReport[Strings.handcuffsUsedYes],
            Strings.handcuffsUsedNo: transferReport[Strings.handcuffsUsedNo],
            Strings.handcuffsDate: transferReport[Strings.handcuffsDate],
            Strings.handcuffsTime: transferReport[Strings.handcuffsTime],
            Strings.handcuffsAuthorisedBy: transferReport[Strings.handcuffsAuthorisedBy],
            Strings.handcuffsAppliedBy: transferReport[Strings.handcuffsAppliedBy],
            Strings.handcuffsRemovedTime: transferReport[Strings.handcuffsRemovedTime],
            Strings.physicalInterventionYes: transferReport[Strings.physicalInterventionYes],
            Strings.physicalInterventionNo: transferReport[Strings.physicalInterventionNo],
            Strings.physicalIntervention: transferReport[Strings.physicalIntervention],
            Strings.whyInterventionRequired: transferReport[Strings.whyInterventionRequired],
            Strings.techniqueName1: transferReport[Strings.techniqueName1],
            Strings.techniqueName2: transferReport[Strings.techniqueName2],
            Strings.techniqueName3: transferReport[Strings.techniqueName3],
            Strings.techniqueName4: transferReport[Strings.techniqueName4],
            Strings.techniqueName5: transferReport[Strings.techniqueName5],
            Strings.techniqueName6: transferReport[Strings.techniqueName6],
            Strings.techniqueName7: transferReport[Strings.techniqueName7],
            Strings.techniqueName8: transferReport[Strings.techniqueName8],
            Strings.techniqueName9: transferReport[Strings.techniqueName9],
            Strings.techniqueName10: transferReport[Strings.techniqueName10],
            Strings.technique1: transferReport[Strings.technique1],
            Strings.technique2: transferReport[Strings.technique2],
            Strings.technique3: transferReport[Strings.technique3],
            Strings.technique4: transferReport[Strings.technique4],
            Strings.technique5: transferReport[Strings.technique5],
            Strings.technique6: transferReport[Strings.technique6],
            Strings.technique7: transferReport[Strings.technique7],
            Strings.technique8: transferReport[Strings.technique8],
            Strings.technique9: transferReport[Strings.technique9],
            Strings.technique10: transferReport[Strings.technique10],
            Strings.techniquePosition1: transferReport[Strings.techniquePosition1],
            Strings.techniquePosition2: transferReport[Strings.techniquePosition2],
            Strings.techniquePosition3: transferReport[Strings.techniquePosition3],
            Strings.techniquePosition4: transferReport[Strings.techniquePosition4],
            Strings.techniquePosition5: transferReport[Strings.techniquePosition5],
            Strings.techniquePosition6: transferReport[Strings.techniquePosition6],
            Strings.techniquePosition7: transferReport[Strings.techniquePosition7],
            Strings.techniquePosition8: transferReport[Strings.techniquePosition8],
            Strings.techniquePosition9: transferReport[Strings.techniquePosition9],
            Strings.techniquePosition10: transferReport[Strings.techniquePosition10],
            Strings.timeInterventionCommenced: transferReport[Strings.timeInterventionCommenced],
            Strings.timeInterventionCompleted: transferReport[Strings.timeInterventionCompleted],
            Strings.incidentDate: transferReport[Strings.incidentDate] == null ? null : DateTime.parse(transferReport[Strings.incidentDate]),
            Strings.incidentTime: transferReport[Strings.incidentTime],
            Strings.incidentDetails: transferReport[Strings.incidentDetails],
            Strings.incidentLocation: transferReport[Strings.incidentLocation],
            Strings.incidentAction: transferReport[Strings.incidentAction],
            Strings.incidentStaffInvolved: transferReport[Strings.incidentStaffInvolved],
            Strings.incidentSignature: null,
            Strings.incidentSignatureDate: transferReport[Strings.incidentSignatureDate],
            Strings.incidentPrintName: transferReport[Strings.incidentPrintName],
            Strings.hasSection2Checklist: transferReport[Strings.hasSection2Checklist],
            Strings.hasSection3Checklist: transferReport[Strings.hasSection3Checklist],
            Strings.hasSection3TransferChecklist: transferReport[Strings.hasSection3TransferChecklist],
            Strings.transferInPatientName1: transferReport[Strings.transferInPatientName1],
            Strings.patientCorrectYes1: transferReport[Strings.patientCorrectYes1],
            Strings.patientCorrectNo1: transferReport[Strings.patientCorrectNo1],
            Strings.hospitalCorrectYes1: transferReport[Strings.hospitalCorrectYes1],
            Strings.hospitalCorrectNo1: transferReport[Strings.hospitalCorrectNo1],
            Strings.applicationFormYes1: transferReport[Strings.applicationFormYes1],
            Strings.applicationFormNo1: transferReport[Strings.applicationFormNo1],
            Strings.applicationSignedYes1: transferReport[Strings.applicationSignedYes1],
            Strings.applicationSignedNo1: transferReport[Strings.applicationSignedNo1],
            Strings.within14DaysYes1: transferReport[Strings.within14DaysYes1],
            Strings.within14DaysNo1: transferReport[Strings.within14DaysNo1],
            Strings.localAuthorityNameYes1: transferReport[Strings.localAuthorityNameYes1],
            Strings.localAuthorityNameNo1: transferReport[Strings.localAuthorityNameNo1],
            Strings.medicalRecommendationsFormYes1: transferReport[Strings.medicalRecommendationsFormYes1],
            Strings.medicalRecommendationsFormNo1: transferReport[Strings.medicalRecommendationsFormNo1],
            Strings.medicalRecommendationsSignedYes1: transferReport[Strings.medicalRecommendationsSignedYes1],
            Strings.medicalRecommendationsSignedNo1: transferReport[Strings.medicalRecommendationsSignedNo1],
            Strings.datesSignatureSignedYes: transferReport[Strings.datesSignatureSignedYes],
            Strings.datesSignatureSignedNo: transferReport[Strings.datesSignatureSignedNo],
            Strings.signatureDatesOnBeforeYes1: transferReport[Strings.signatureDatesOnBeforeYes1],
            Strings.signatureDatesOnBeforeNo1: transferReport[Strings.signatureDatesOnBeforeNo1],
            Strings.practitionersNameYes1: transferReport[Strings.practitionersNameYes1],
            Strings.practitionersNameNo1: transferReport[Strings.practitionersNameNo1],
            Strings.transferInCheckedBy1: transferReport[Strings.transferInCheckedBy1],
            Strings.transferInDate1: transferReport[Strings.transferInDate1],
            Strings.transferInDesignation1: transferReport[Strings.transferInDesignation1],
            Strings.transferInSignature1: null,
            Strings.transferInPatientName2: transferReport[Strings.transferInPatientName2],
            Strings.patientCorrectYes2: transferReport[Strings.patientCorrectYes2],
            Strings.patientCorrectNo2: transferReport[Strings.patientCorrectNo2],
            Strings.hospitalCorrectYes2: transferReport[Strings.hospitalCorrectYes2],
            Strings.hospitalCorrectNo2: transferReport[Strings.hospitalCorrectNo2],
            Strings.applicationFormYes2: transferReport[Strings.applicationFormYes2],
            Strings.applicationFormNo2: transferReport[Strings.applicationFormNo2],
            Strings.applicationSignedYes2: transferReport[Strings.applicationSignedYes2],
            Strings.applicationSignedNo2: transferReport[Strings.applicationSignedNo2],
            Strings.amhpIdentifiedYes: transferReport[Strings.amhpIdentifiedYes],
            Strings.amhpIdentifiedNo: transferReport[Strings.amhpIdentifiedNo],
            Strings.medicalRecommendationsFormYes2: transferReport[Strings.medicalRecommendationsFormYes2],
            Strings.medicalRecommendationsFormNo2: transferReport[Strings.medicalRecommendationsFormNo2],
            Strings.medicalRecommendationsSignedYes2: transferReport[Strings.medicalRecommendationsSignedYes2],
            Strings.medicalRecommendationsSignedNo2: transferReport[Strings.medicalRecommendationsSignedNo2],
            Strings.clearDaysYes2: transferReport[Strings.clearDaysYes2],
            Strings.clearDaysNo2: transferReport[Strings.clearDaysNo2],
            Strings.signatureDatesOnBeforeYes2: transferReport[Strings.signatureDatesOnBeforeYes2],
            Strings.signatureDatesOnBeforeNo2: transferReport[Strings.signatureDatesOnBeforeNo2],
            Strings.practitionersNameYes2: transferReport[Strings.practitionersNameYes2],
            Strings.practitionersNameNo2: transferReport[Strings.practitionersNameNo2],
            Strings.doctorsAgreeYes: transferReport[Strings.doctorsAgreeYes],
            Strings.doctorsAgreeNo: transferReport[Strings.doctorsAgreeNo],
            Strings.separateMedicalRecommendationsYes: transferReport[Strings.separateMedicalRecommendationsYes],
            Strings.separateMedicalRecommendationsNo: transferReport[Strings.separateMedicalRecommendationsNo],
            Strings.transferInCheckedBy2: transferReport[Strings.transferInCheckedBy2],
            Strings.transferInDate2: transferReport[Strings.transferInDate2],
            Strings.transferInDesignation2: transferReport[Strings.transferInDesignation2],
            Strings.transferInSignature2: null,
            Strings.transferInPatientName3: transferReport[Strings.transferInPatientName3],
            Strings.patientCorrectYes3: transferReport[Strings.patientCorrectYes3],
            Strings.patientCorrectNo3: transferReport[Strings.patientCorrectNo3],
            Strings.hospitalCorrectYes3: transferReport[Strings.hospitalCorrectYes3],
            Strings.hospitalCorrectNo3: transferReport[Strings.hospitalCorrectNo3],
            Strings.h4Yes: transferReport[Strings.h4Yes],
            Strings.h4No: transferReport[Strings.h4No],
            Strings.currentConsentYes: transferReport[Strings.currentConsentYes],
            Strings.currentConsentNo: transferReport[Strings.currentConsentNo],
            Strings.applicationFormYes3: transferReport[Strings.applicationFormYes3],
            Strings.applicationFormNo3: transferReport[Strings.applicationFormNo3],
            Strings.applicationSignedYes3: transferReport[Strings.applicationSignedYes3],
            Strings.applicationSignedNo3: transferReport[Strings.applicationSignedNo3],
            Strings.within14DaysYes3: transferReport[Strings.within14DaysYes3],
            Strings.within14DaysNo3: transferReport[Strings.within14DaysNo3],
            Strings.localAuthorityNameYes3: transferReport[Strings.localAuthorityNameYes3],
            Strings.localAuthorityNameNo3: transferReport[Strings.localAuthorityNameNo3],
            Strings.nearestRelativeYes: transferReport[Strings.nearestRelativeYes],
            Strings.nearestRelativeNo: transferReport[Strings.nearestRelativeNo],
            Strings.amhpConsultationYes: transferReport[Strings.amhpConsultationYes],
            Strings.amhpConsultationNo: transferReport[Strings.amhpConsultationNo],
            Strings.knewPatientYes: transferReport[Strings.knewPatientYes],
            Strings.knewPatientNo: transferReport[Strings.knewPatientNo],
            Strings.medicalRecommendationsFormYes3: transferReport[Strings.medicalRecommendationsFormYes3],
            Strings.medicalRecommendationsFormNo3: transferReport[Strings.medicalRecommendationsFormNo3],
            Strings.medicalRecommendationsSignedYes3: transferReport[Strings.medicalRecommendationsSignedYes3],
            Strings.medicalRecommendationsSignedNo3: transferReport[Strings.medicalRecommendationsSignedNo3],
            Strings.clearDaysYes3: transferReport[Strings.clearDaysYes3],
            Strings.clearDaysNo3: transferReport[Strings.clearDaysNo3],
            Strings.approvedSection12Yes: transferReport[Strings.approvedSection12Yes],
            Strings.approvedSection12No: transferReport[Strings.approvedSection12No],
            Strings.signatureDatesOnBeforeYes3: transferReport[Strings.signatureDatesOnBeforeYes3],
            Strings.signatureDatesOnBeforeNo3: transferReport[Strings.signatureDatesOnBeforeNo3],
            Strings.practitionersNameYes3: transferReport[Strings.practitionersNameYes3],
            Strings.practitionersNameNo3: transferReport[Strings.practitionersNameNo3],
            Strings.previouslyAcquaintedYes: transferReport[Strings.previouslyAcquaintedYes],
            Strings.previouslyAcquaintedNo: transferReport[Strings.previouslyAcquaintedNo],
            Strings.acquaintedIfNoYes: transferReport[Strings.acquaintedIfNoYes],
            Strings.acquaintedIfNoNo: transferReport[Strings.acquaintedIfNoNo],
            Strings.recommendationsDifferentTeamsYes: transferReport[Strings.recommendationsDifferentTeamsYes],
            Strings.recommendationsDifferentTeamsNo: transferReport[Strings.recommendationsDifferentTeamsNo],
            Strings.originalDetentionPapersYes: transferReport[Strings.originalDetentionPapersYes],
            Strings.originalDetentionPapersNo: transferReport[Strings.originalDetentionPapersNo],
            Strings.transferInCheckedBy3: transferReport[Strings.transferInCheckedBy3],
            Strings.transferInDate3: transferReport[Strings.transferInDate3],
            Strings.transferInDesignation3: transferReport[Strings.transferInDesignation3],
            Strings.transferInSignature3: null,
            Strings.feltSafeYes: transferReport[Strings.feltSafeYes],
            Strings.feltSafeNo: transferReport[Strings.feltSafeNo],
            Strings.staffIntroducedYes: transferReport[Strings.staffIntroducedYes],
            Strings.staffIntroducedNo: transferReport[Strings.staffIntroducedNo],
            Strings.experiencePositiveYes: transferReport[Strings.experiencePositiveYes],
            Strings.experiencePositiveNo: transferReport[Strings.experiencePositiveNo],
            Strings.otherComments: transferReport[Strings.otherComments],
            Strings.vehicleCompletedBy1: transferReport[Strings.vehicleCompletedBy1],
            Strings.vehicleDate: transferReport[Strings.vehicleDate],
            Strings.vehicleTime: transferReport[Strings.vehicleTime],
            Strings.ambulanceReg: transferReport[Strings.ambulanceReg],
            Strings.vehicleStartMileage: transferReport[Strings.vehicleStartMileage],
            Strings.nearestTank1: transferReport[Strings.nearestTank1],
            Strings.ambulanceTidyYes1: transferReport[Strings.ambulanceTidyYes1],
            Strings.ambulanceTidyNo1: transferReport[Strings.ambulanceTidyNo1],
            Strings.lightsWorkingYes: transferReport[Strings.lightsWorkingYes],
            Strings.lightsWorkingNo: transferReport[Strings.lightsWorkingNo],
            Strings.tyresInflatedYes: transferReport[Strings.tyresInflatedYes],
            Strings.tyresInflatedNo: transferReport[Strings.tyresInflatedNo],
            Strings.warningSignsYes: transferReport[Strings.warningSignsYes],
            Strings.warningSignsNo: transferReport[Strings.warningSignsNo],
            Strings.vehicleCompletedBy2: transferReport[Strings.vehicleCompletedBy2],
            Strings.nearestTank2: transferReport[Strings.nearestTank2],
            Strings.vehicleFinishMileage: transferReport[Strings.vehicleFinishMileage],
            Strings.ambulanceTidyYes2: transferReport[Strings.ambulanceTidyYes2],
            Strings.ambulanceTidyNo2: transferReport[Strings.ambulanceTidyNo2],
            Strings.sanitiserCleanYes: transferReport[Strings.sanitiserCleanYes],
            Strings.sanitiserCleanNo: transferReport[Strings.sanitiserCleanNo],
            Strings.issuesFaults: transferReport[Strings.issuesFaults],
            Strings.timestamp: FieldValue.serverTimestamp(),
            Strings.serverUploaded: 1,
          });

          DocumentSnapshot snap = await ref.get();

          //Signatures
          String collectionSignatureUrl;
          bool collectionSignatureSuccess = true;

          if(transferReport[Strings.collectionSignature] != null){
            collectionSignatureSuccess = false;

            Reference storageRef =
            FirebaseStorage.instance.ref().child('transferReportImages/' + snap.id + '/collectionSignature.jpg');

            if(kIsWeb){
              storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + snap.id + '/collectionSignature.jpg');
            }


            final UploadTask uploadTask = storageRef.putData(Uint8List.fromList(transferReport[Strings.collectionSignature].toList().cast<int>()));

            final TaskSnapshot downloadUrl = (await uploadTask);
            collectionSignatureUrl = (await downloadUrl.ref.getDownloadURL());
            if(collectionSignatureUrl != null){
              collectionSignatureSuccess = true;
              storageUrlList.add('transferReportImages/' + snap.id + '/collectionSignature.jpg');
            }

          }

          String incidentSignatureUrl;
          bool incidentSignatureSuccess = true;

          if(transferReport[Strings.incidentSignature] != null){
            incidentSignatureSuccess = false;

            Reference storageRef =
            FirebaseStorage.instance.ref().child('transferReportImages/' + snap.id + '/incidentSignature.jpg');

            if(kIsWeb){
              storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + snap.id + '/incidentSignature.jpg');
            }

            final UploadTask uploadTask = storageRef.putData(Uint8List.fromList(transferReport[Strings.incidentSignature].toList().cast<int>()));

            final TaskSnapshot downloadUrl = (await uploadTask);
            incidentSignatureUrl = (await downloadUrl.ref.getDownloadURL());
            if(incidentSignatureUrl != null){
              incidentSignatureSuccess = true;
              storageUrlList.add('transferReportImages/' + snap.id + '/incidentSignature.jpg');
            }

          }

          String destinationSignatureUrl;
          bool destinationSignatureSuccess = true;

          if(transferReport[Strings.destinationSignature] != null){
            destinationSignatureSuccess = false;

            Reference storageRef =
            FirebaseStorage.instance.ref().child('transferReportImages/' + snap.id + '/destinationSignature.jpg');

            if(kIsWeb){
              storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + snap.id + '/destinationSignature.jpg');
            }
            final UploadTask uploadTask = storageRef.putData(Uint8List.fromList(transferReport[Strings.destinationSignature].toList().cast<int>()));

            final TaskSnapshot downloadUrl = (await uploadTask);
            destinationSignatureUrl = (await downloadUrl.ref.getDownloadURL());
            if(destinationSignatureUrl != null){
              destinationSignatureSuccess = true;
              storageUrlList.add('transferReportImages/' + snap.id + '/destinationSignature.jpg');
            }

          }

          String bodyMapImageUrl;
          bool bodyMapImageSuccess = true;

          if(transferReport[Strings.bodyMapImage] != null){
            bodyMapImageSuccess = false;

            Uint8List decryptedImage = await GlobalFunctions.decryptSignature(transferReport[Strings.bodyMapImage]);



            Uint8List compressedImage;

            if(kIsWeb){
              compressedImage = decryptedImage;

            } else {
              compressedImage = await FlutterImageCompress.compressWithList(
                  decryptedImage,
                  quality: 50,
                  keepExif: true
              );
            }


            Uint8List encryptedImage = await GlobalFunctions.encryptSignature(compressedImage);

            Reference storageRef =
            FirebaseStorage.instance.ref().child('transferReportImages/' + snap.id + '/bodyMapImage.jpg');

            if(kIsWeb){
              storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + snap.id + '/bodyMapImage.jpg');
            }
            //final UploadTask uploadTask = storageRef.putData(encryptedImage);
            final UploadTask uploadTask = storageRef.putData(Uint8List.fromList(encryptedImage.toList().cast<int>()));

            final TaskSnapshot downloadUrl = (await uploadTask);
            bodyMapImageUrl = (await downloadUrl.ref.getDownloadURL());
            if(bodyMapImageUrl != null){
              bodyMapImageSuccess = true;
              storageUrlList.add('transferReportImages/' + snap.id + '/bodyMapImage.jpg');
            }

          }

          String patientReportSignatureUrl;
          bool patientReportSignatureSuccess = true;

          if(transferReport[Strings.patientReportSignature] != null){
            patientReportSignatureSuccess = false;

            Reference storageRef =
            FirebaseStorage.instance.ref().child('transferReportImages/' + snap.id + '/patientReportSignature.jpg');

            if(kIsWeb){
              storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + snap.id + '/patientReportSignature.jpg');
            }


            final UploadTask uploadTask = storageRef.putData(Uint8List.fromList(transferReport[Strings.patientReportSignature].toList().cast<int>()));

            final TaskSnapshot downloadUrl = (await uploadTask);
            patientReportSignatureUrl = (await downloadUrl.ref.getDownloadURL());
            if(patientReportSignatureUrl != null){
              patientReportSignatureSuccess = true;
              storageUrlList.add('transferReportImages/' + snap.id + '/patientReportSignature.jpg');
            }

          }

          String transferInSignature1Url;
          bool transferInSignature1Success = true;

          if(transferReport[Strings.transferInSignature1] != null){
            transferInSignature1Success = false;

            Reference storageRef =
            FirebaseStorage.instance.ref().child('transferReportImages/' + snap.id + '/transferInSignature1.jpg');

            if(kIsWeb){
              storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + snap.id + '/transferInSignature1.jpg');
            }
            final UploadTask uploadTask = storageRef.putData(Uint8List.fromList(transferReport[Strings.transferInSignature1].toList().cast<int>()));

            final TaskSnapshot downloadUrl = (await uploadTask);
            transferInSignature1Url = (await downloadUrl.ref.getDownloadURL());
            if(transferInSignature1Url != null){
              transferInSignature1Success = true;
              storageUrlList.add('transferReportImages/' + snap.id + '/transferInSignature1.jpg');
            }

          }

          String transferInSignature2Url;
          bool transferInSignature2Success = true;

          if(transferReport[Strings.transferInSignature2] != null){
            transferInSignature2Success = false;

            Reference storageRef =
            FirebaseStorage.instance.ref().child('transferReportImages/' + snap.id + '/transferInSignature2.jpg');

            if(kIsWeb){
              storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + snap.id + '/transferInSignature2.jpg');
            }
            final UploadTask uploadTask = storageRef.putData(Uint8List.fromList(transferReport[Strings.transferInSignature2].toList().cast<int>()));

            final TaskSnapshot downloadUrl = (await uploadTask);
            transferInSignature2Url = (await downloadUrl.ref.getDownloadURL());
            if(transferInSignature2Url != null){
              transferInSignature2Success = true;
              storageUrlList.add('transferReportImages/' + snap.id + '/transferInSignature2.jpg');
            }

          }

          String transferInSignature3Url;
          bool transferInSignature3Success = true;

          if(transferReport[Strings.transferInSignature3] != null){
            transferInSignature3Success = false;

            Reference storageRef =
            FirebaseStorage.instance.ref().child('transferReportImages/' + snap.id + '/transferInSignature3.jpg');

            if(kIsWeb){
              storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + snap.id + '/transferInSignature3.jpg');
            }
            final UploadTask uploadTask = storageRef.putData(Uint8List.fromList(transferReport[Strings.transferInSignature3].toList().cast<int>()));

            final TaskSnapshot downloadUrl = (await uploadTask);
            transferInSignature3Url = (await downloadUrl.ref.getDownloadURL());
            if(transferInSignature3Url != null){
              transferInSignature3Success = true;
              storageUrlList.add('transferReportImages/' + snap.id + '/transferInSignature3.jpg');
            }

          }


          if(incidentSignatureSuccess && collectionSignatureSuccess &&  destinationSignatureSuccess && bodyMapImageSuccess && patientReportSignatureSuccess && transferInSignature1Success && transferInSignature2Success && transferInSignature3Success){

            await FirebaseFirestore.instance.collection('transfer_reports').doc(snap.id).update({
              Strings.incidentSignature: incidentSignatureUrl == null ? null : incidentSignatureUrl,
              Strings.collectionSignature: collectionSignatureUrl == null ? null : collectionSignatureUrl,
              Strings.destinationSignature: destinationSignatureUrl == null ? null : destinationSignatureUrl,
              Strings.bodyMapImage: bodyMapImageUrl == null ? null : bodyMapImageUrl,
              Strings.patientReportSignature: patientReportSignatureUrl == null ? null : patientReportSignatureUrl,
              Strings.transferInSignature1: transferInSignature1Url == null ? null : transferInSignature1Url,
              Strings.transferInSignature2: transferInSignature2Url == null ? null : transferInSignature2Url,
              Strings.transferInSignature3: transferInSignature3Url == null ? null : transferInSignature3Url
            }).timeout(Duration(seconds: 60));


            //Sembast
            await _transferReportsStore.record(id).delete(await _db);
            if(saved){
              deleteSavedRecord(savedId);
            }
            message = 'Transfer Report uploaded successfully';
            success = true;


          } else {
            await FirebaseFirestore.instance.collection('transfer_reports').doc(snap.id).delete();
          }

        } on TimeoutException catch (_) {
          // A timeout occurred.
          message = 'Network Timeout communicating with the server, unable to upload Transfer Report';

          await GlobalFunctions.checkAddFirebaseStorageRow(storageUrlList, _databaseHelper);

        } catch (e) {
          print(e);
          message = e.toString();
          await GlobalFunctions.checkAddFirebaseStorageRow(storageUrlList, _databaseHelper);

          print(e);
        }
      }

    } else {

      message = 'No data connection, Transfer Report has been saved locally, please upload when you have a valid connection';
      success = true;

    }

    if(success){
      await resetTemporaryRecord(jobId, saved, savedId);
      if(kIsWeb) await resetTemporaryRecord(jobId, saved, savedId);
    }
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

  Future<bool> editTransferReport(String jobId, [bool edit = false]) async {

    GlobalFunctions.showLoadingDialog('Editing Transfer Report...');
    String message = '';
    bool success = false;
    List<String> storageUrlList = [];

    //Map<String, dynamic> transferReport = await _databaseHelper.getTemporaryTransferReport(true, user.uid, jobId);
    Map<String, dynamic> transferReport = await getTemporaryRecord(true, jobId, false, 0);


    bool hasDataConnection = await GlobalFunctions.hasDataConnection();


    if(hasDataConnection){

      bool isTokenExpired = GlobalFunctions.isTokenExpired();
      bool authenticated = true;

      if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

      if(authenticated){


        try {

          await FirebaseFirestore.instance.collection('transfer_reports').doc(transferReport[Strings.documentId]).update({
            Strings.jobId: '1',
            Strings.formVersion: '1',
            Strings.jobRef: GlobalFunctions.databaseValueString(transferReport[Strings.jobRef]),
            Strings.jobRefLowercase: GlobalFunctions.databaseValueString(transferReport[Strings.jobRef]).toLowerCase(),
            Strings.date: transferReport[Strings.date] == null ? null : DateTime.parse(transferReport[Strings.date]),
            Strings.startTime: transferReport[Strings.startTime],
            Strings.finishTime: transferReport[Strings.finishTime],
            Strings.totalHours: transferReport[Strings.totalHours],
            Strings.collectionDetails: transferReport[Strings.collectionDetails],
            Strings.collectionPostcode: transferReport[Strings.collectionPostcode],
            Strings.collectionContactNo: transferReport[Strings.collectionContactNo],
            Strings.destinationDetails: transferReport[Strings.destinationDetails],
            Strings.destinationPostcode: transferReport[Strings.destinationPostcode],
            Strings.destinationContactNo: transferReport[Strings.destinationContactNo],
            Strings.collectionArrivalTime: transferReport[Strings.collectionArrivalTime],
            Strings.collectionDepartureTime: transferReport[Strings.collectionDepartureTime],
            Strings.destinationArrivalTime: transferReport[Strings.destinationArrivalTime],
            Strings.destinationDepartureTime: transferReport[Strings.destinationDepartureTime],
            Strings.vehicleRegNo: transferReport[Strings.vehicleRegNo],
            Strings.startMileage: transferReport[Strings.startMileage],
            Strings.finishMileage: transferReport[Strings.finishMileage],
            Strings.totalMileage: transferReport[Strings.totalMileage],
            Strings.name1: transferReport[Strings.name1],
            Strings.role1: transferReport[Strings.role1],
            Strings.drivingTimes1_1: transferReport[Strings.drivingTimes1_1],
            Strings.drivingTimes1_2: transferReport[Strings.drivingTimes1_2],
            Strings.name2: transferReport[Strings.name2],
            Strings.role2: transferReport[Strings.role2],
            Strings.drivingTimes2_1: transferReport[Strings.drivingTimes2_1],
            Strings.drivingTimes2_2: transferReport[Strings.drivingTimes2_2],
            Strings.name3: transferReport[Strings.name3],
            Strings.role3: transferReport[Strings.role3],
            Strings.drivingTimes3_1: transferReport[Strings.drivingTimes3_1],
            Strings.drivingTimes3_2: transferReport[Strings.drivingTimes3_2],
            Strings.name4: transferReport[Strings.name4],
            Strings.role4: transferReport[Strings.role4],
            Strings.drivingTimes4_1: transferReport[Strings.drivingTimes4_1],
            Strings.drivingTimes4_2: transferReport[Strings.drivingTimes4_2],
            Strings.name5: transferReport[Strings.name5],
            Strings.role5: transferReport[Strings.role5],
            Strings.drivingTimes5_1: transferReport[Strings.drivingTimes5_1],
            Strings.drivingTimes5_2: transferReport[Strings.drivingTimes5_2],
            Strings.name6: transferReport[Strings.name6],
            Strings.role6: transferReport[Strings.role6],
            Strings.drivingTimes6_1: transferReport[Strings.drivingTimes6_1],
            Strings.drivingTimes6_2: transferReport[Strings.drivingTimes6_2],
            Strings.name7: transferReport[Strings.name7],
            Strings.role7: transferReport[Strings.role7],
            Strings.drivingTimes7_1: transferReport[Strings.drivingTimes7_1],
            Strings.drivingTimes7_2: transferReport[Strings.drivingTimes7_2],
            Strings.name8: transferReport[Strings.name8],
            Strings.role8: transferReport[Strings.role8],
            Strings.drivingTimes8_1: transferReport[Strings.drivingTimes8_1],
            Strings.drivingTimes8_2: transferReport[Strings.drivingTimes8_2],
            Strings.name9: transferReport[Strings.name9],
            Strings.role9: transferReport[Strings.role9],
            Strings.drivingTimes9_1: transferReport[Strings.drivingTimes9_1],
            Strings.drivingTimes9_2: transferReport[Strings.drivingTimes9_2],
            Strings.name10: transferReport[Strings.name10],
            Strings.role10: transferReport[Strings.role10],
            Strings.drivingTimes10_1: transferReport[Strings.drivingTimes10_1],
            Strings.drivingTimes10_2: transferReport[Strings.drivingTimes10_2],
            Strings.name11: transferReport[Strings.name11],
            Strings.role11: transferReport[Strings.role11],
            Strings.drivingTimes11_1: transferReport[Strings.drivingTimes11_1],
            Strings.drivingTimes11_2: transferReport[Strings.drivingTimes11_2],
            Strings.collectionUnit: transferReport[Strings.collectionUnit],
            Strings.collectionPosition: transferReport[Strings.collectionPosition],
            Strings.collectionPrintName: transferReport[Strings.collectionPrintName],
            Strings.collectionArrivalTimeEnd: transferReport[Strings.collectionArrivalTimeEnd],
            Strings.destinationUnit: transferReport[Strings.destinationUnit],
            Strings.destinationPosition: transferReport[Strings.destinationPosition],
            Strings.destinationPrintName: transferReport[Strings.destinationPrintName],
            Strings.destinationArrivalTimeEnd: transferReport[Strings.destinationArrivalTimeEnd],
            Strings.patientName: transferReport[Strings.patientName],
            Strings.dateOfBirth: transferReport[Strings.dateOfBirth],
            Strings.ethnicity: transferReport[Strings.ethnicity],
            Strings.gender: transferReport[Strings.gender],
            Strings.mhaMcaDetails: transferReport[Strings.mhaMcaDetails],
            Strings.diagnosis: transferReport[Strings.diagnosis],
            Strings.currentPresentation: transferReport[Strings.currentPresentation],
            Strings.riskYes: transferReport[Strings.riskYes],
            Strings.riskNo: transferReport[Strings.riskNo],
            Strings.riskExplanation: transferReport[Strings.riskExplanation],
            Strings.forensicHistoryYes: transferReport[Strings.forensicHistoryYes],
            Strings.forensicHistoryNo: transferReport[Strings.forensicHistoryNo],
            Strings.racialGenderConcernsYes: transferReport[Strings.racialGenderConcernsYes],
            Strings.racialGenderConcernsNo: transferReport[Strings.racialGenderConcernsNo],
            Strings.violenceAggressionYes: transferReport[Strings.violenceAggressionYes],
            Strings.violenceAggressionNo: transferReport[Strings.violenceAggressionNo],
            Strings.selfHarmYes: transferReport[Strings.selfHarmYes],
            Strings.selfHarmNo: transferReport[Strings.selfHarmNo],
            Strings.alcoholSubstanceYes: transferReport[Strings.alcoholSubstanceYes],
            Strings.alcoholSubstanceNo: transferReport[Strings.alcoholSubstanceNo],
            Strings.virusesYes: transferReport[Strings.virusesYes],
            Strings.virusesNo: transferReport[Strings.virusesNo],
            Strings.safeguardingYes: transferReport[Strings.safeguardingYes],
            Strings.safeguardingNo: transferReport[Strings.safeguardingNo],
            Strings.physicalHealthConditionsYes: transferReport[Strings.physicalHealthConditionsYes],
            Strings.physicalHealthConditionsNo: transferReport[Strings.physicalHealthConditionsNo],
            Strings.useOfWeaponYes: transferReport[Strings.useOfWeaponYes],
            Strings.useOfWeaponNo: transferReport[Strings.useOfWeaponNo],
            Strings.absconsionRiskYes: transferReport[Strings.absconsionRiskYes],
            Strings.absconsionRiskNo: transferReport[Strings.absconsionRiskNo],
            Strings.forensicHistory: transferReport[Strings.forensicHistory],
            Strings.racialGenderConcerns: transferReport[Strings.racialGenderConcerns],
            Strings.violenceAggression: transferReport[Strings.violenceAggression],
            Strings.selfHarm: transferReport[Strings.selfHarm],
            Strings.alcoholSubstance: transferReport[Strings.alcoholSubstance],
            Strings.viruses: transferReport[Strings.viruses],
            Strings.safeguarding: transferReport[Strings.safeguarding],
            Strings.physicalHealthConditions: transferReport[Strings.physicalHealthConditions],
            Strings.useOfWeapon: transferReport[Strings.useOfWeapon],
            Strings.absconsionRisk: transferReport[Strings.absconsionRisk],
            Strings.patientPropertyYes: transferReport[Strings.patientPropertyYes],
            Strings.patientPropertyNo: transferReport[Strings.patientPropertyNo],
            Strings.patientPropertyExplanation: transferReport[Strings.riskExplanation],
            Strings.patientPropertyReceived: transferReport[Strings.patientPropertyReceived],
            Strings.patientPropertyReceivedYes: transferReport[Strings.patientPropertyReceivedYes],
            Strings.patientPropertyReceivedNo: transferReport[Strings.patientPropertyReceivedNo],
            Strings.patientNotesReceived: transferReport[Strings.patientNotesReceived],
            Strings.patientNotesReceivedYes: transferReport[Strings.patientNotesReceivedYes],
            Strings.patientNotesReceivedNo: transferReport[Strings.patientNotesReceivedNo],
            Strings.patientSearched: transferReport[Strings.patientSearched],
            Strings.patientSearchedYes: transferReport[Strings.patientSearchedYes],
            Strings.patientSearchedNo: transferReport[Strings.patientSearchedNo],
            Strings.itemsRemovedYes: transferReport[Strings.itemsRemovedYes],
            Strings.itemsRemovedNo: transferReport[Strings.itemsRemovedNo],
            Strings.itemsRemoved: transferReport[Strings.itemsRemoved],
            Strings.patientInformed: transferReport[Strings.patientInformed],
            Strings.injuriesNoted: transferReport[Strings.injuriesNoted],
            Strings.medicalAttentionYes: transferReport[Strings.medicalAttentionYes],
            Strings.medicalAttentionNo: transferReport[Strings.medicalAttentionNo],
            Strings.relevantInformationYes: transferReport[Strings.relevantInformationYes],
            Strings.relevantInformationNo: transferReport[Strings.relevantInformationNo],
            Strings.medicalAttention: transferReport[Strings.medicalAttention],
            Strings.currentMedication: transferReport[Strings.currentMedication],
            Strings.physicalObservations: transferReport[Strings.physicalObservations],
            Strings.relevantInformation: transferReport[Strings.relevantInformation],
            Strings.patientReport: transferReport[Strings.patientReport],
            Strings.patientReportPrintName: transferReport[Strings.patientReportPrintName],
            Strings.patientReportRole: transferReport[Strings.patientReportRole],
            Strings.patientReportDate: transferReport[Strings.patientReportDate],
            Strings.patientReportTime: transferReport[Strings.patientReportTime],
            Strings.handcuffsUsedYes: transferReport[Strings.handcuffsUsedYes],
            Strings.handcuffsUsedNo: transferReport[Strings.handcuffsUsedNo],
            Strings.handcuffsDate: transferReport[Strings.handcuffsDate],
            Strings.handcuffsTime: transferReport[Strings.handcuffsTime],
            Strings.handcuffsAuthorisedBy: transferReport[Strings.handcuffsAuthorisedBy],
            Strings.handcuffsAppliedBy: transferReport[Strings.handcuffsAppliedBy],
            Strings.handcuffsRemovedTime: transferReport[Strings.handcuffsRemovedTime],
            Strings.physicalInterventionYes: transferReport[Strings.physicalInterventionYes],
            Strings.physicalInterventionNo: transferReport[Strings.physicalInterventionNo],
            Strings.physicalIntervention: transferReport[Strings.physicalIntervention],
            Strings.whyInterventionRequired: transferReport[Strings.whyInterventionRequired],
            Strings.techniqueName1: transferReport[Strings.techniqueName1],
            Strings.techniqueName2: transferReport[Strings.techniqueName2],
            Strings.techniqueName3: transferReport[Strings.techniqueName3],
            Strings.techniqueName4: transferReport[Strings.techniqueName4],
            Strings.techniqueName5: transferReport[Strings.techniqueName5],
            Strings.techniqueName6: transferReport[Strings.techniqueName6],
            Strings.techniqueName7: transferReport[Strings.techniqueName7],
            Strings.techniqueName8: transferReport[Strings.techniqueName8],
            Strings.techniqueName9: transferReport[Strings.techniqueName9],
            Strings.techniqueName10: transferReport[Strings.techniqueName10],
            Strings.technique1: transferReport[Strings.technique1],
            Strings.technique2: transferReport[Strings.technique2],
            Strings.technique3: transferReport[Strings.technique3],
            Strings.technique4: transferReport[Strings.technique4],
            Strings.technique5: transferReport[Strings.technique5],
            Strings.technique6: transferReport[Strings.technique6],
            Strings.technique7: transferReport[Strings.technique7],
            Strings.technique8: transferReport[Strings.technique8],
            Strings.technique9: transferReport[Strings.technique9],
            Strings.technique10: transferReport[Strings.technique10],
            Strings.techniquePosition1: transferReport[Strings.techniquePosition1],
            Strings.techniquePosition2: transferReport[Strings.techniquePosition2],
            Strings.techniquePosition3: transferReport[Strings.techniquePosition3],
            Strings.techniquePosition4: transferReport[Strings.techniquePosition4],
            Strings.techniquePosition5: transferReport[Strings.techniquePosition5],
            Strings.techniquePosition6: transferReport[Strings.techniquePosition6],
            Strings.techniquePosition7: transferReport[Strings.techniquePosition7],
            Strings.techniquePosition8: transferReport[Strings.techniquePosition8],
            Strings.techniquePosition9: transferReport[Strings.techniquePosition9],
            Strings.techniquePosition10: transferReport[Strings.techniquePosition10],
            Strings.timeInterventionCommenced: transferReport[Strings.timeInterventionCommenced],
            Strings.timeInterventionCompleted: transferReport[Strings.timeInterventionCompleted],
            Strings.incidentDate: transferReport[Strings.incidentDate] == null ? null : DateTime.parse(transferReport[Strings.incidentDate]),
            Strings.incidentTime: transferReport[Strings.incidentTime],
            Strings.incidentDetails: transferReport[Strings.incidentDetails],
            Strings.incidentLocation: transferReport[Strings.incidentLocation],
            Strings.incidentAction: transferReport[Strings.incidentAction],
            Strings.incidentStaffInvolved: transferReport[Strings.incidentStaffInvolved],
            Strings.incidentSignatureDate: transferReport[Strings.incidentSignatureDate],
            Strings.incidentPrintName: transferReport[Strings.incidentPrintName],
            Strings.hasSection2Checklist: transferReport[Strings.hasSection2Checklist],
            Strings.hasSection3Checklist: transferReport[Strings.hasSection3Checklist],
            Strings.hasSection3TransferChecklist: transferReport[Strings.hasSection3TransferChecklist],
            Strings.transferInPatientName1: transferReport[Strings.transferInPatientName1],
            Strings.patientCorrectYes1: transferReport[Strings.patientCorrectYes1],
            Strings.patientCorrectNo1: transferReport[Strings.patientCorrectNo1],
            Strings.hospitalCorrectYes1: transferReport[Strings.hospitalCorrectYes1],
            Strings.hospitalCorrectNo1: transferReport[Strings.hospitalCorrectNo1],
            Strings.applicationFormYes1: transferReport[Strings.applicationFormYes1],
            Strings.applicationFormNo1: transferReport[Strings.applicationFormNo1],
            Strings.applicationSignedYes1: transferReport[Strings.applicationSignedYes1],
            Strings.applicationSignedNo1: transferReport[Strings.applicationSignedNo1],
            Strings.within14DaysYes1: transferReport[Strings.within14DaysYes1],
            Strings.within14DaysNo1: transferReport[Strings.within14DaysNo1],
            Strings.localAuthorityNameYes1: transferReport[Strings.localAuthorityNameYes1],
            Strings.localAuthorityNameNo1: transferReport[Strings.localAuthorityNameNo1],
            Strings.medicalRecommendationsFormYes1: transferReport[Strings.medicalRecommendationsFormYes1],
            Strings.medicalRecommendationsFormNo1: transferReport[Strings.medicalRecommendationsFormNo1],
            Strings.medicalRecommendationsSignedYes1: transferReport[Strings.medicalRecommendationsSignedYes1],
            Strings.medicalRecommendationsSignedNo1: transferReport[Strings.medicalRecommendationsSignedNo1],
            Strings.datesSignatureSignedYes: transferReport[Strings.datesSignatureSignedYes],
            Strings.datesSignatureSignedNo: transferReport[Strings.datesSignatureSignedNo],
            Strings.signatureDatesOnBeforeYes1: transferReport[Strings.signatureDatesOnBeforeYes1],
            Strings.signatureDatesOnBeforeNo1: transferReport[Strings.signatureDatesOnBeforeNo1],
            Strings.practitionersNameYes1: transferReport[Strings.practitionersNameYes1],
            Strings.practitionersNameNo1: transferReport[Strings.practitionersNameNo1],
            Strings.transferInCheckedBy1: transferReport[Strings.transferInCheckedBy1],
            Strings.transferInDate1: transferReport[Strings.transferInDate1],
            Strings.transferInDesignation1: transferReport[Strings.transferInDesignation1],
            Strings.transferInPatientName2: transferReport[Strings.transferInPatientName2],
            Strings.patientCorrectYes2: transferReport[Strings.patientCorrectYes2],
            Strings.patientCorrectNo2: transferReport[Strings.patientCorrectNo2],
            Strings.hospitalCorrectYes2: transferReport[Strings.hospitalCorrectYes2],
            Strings.hospitalCorrectNo2: transferReport[Strings.hospitalCorrectNo2],
            Strings.applicationFormYes2: transferReport[Strings.applicationFormYes2],
            Strings.applicationFormNo2: transferReport[Strings.applicationFormNo2],
            Strings.applicationSignedYes2: transferReport[Strings.applicationSignedYes2],
            Strings.applicationSignedNo2: transferReport[Strings.applicationSignedNo2],
            Strings.amhpIdentifiedYes: transferReport[Strings.amhpIdentifiedYes],
            Strings.amhpIdentifiedNo: transferReport[Strings.amhpIdentifiedNo],
            Strings.medicalRecommendationsFormYes2: transferReport[Strings.medicalRecommendationsFormYes2],
            Strings.medicalRecommendationsFormNo2: transferReport[Strings.medicalRecommendationsFormNo2],
            Strings.medicalRecommendationsSignedYes2: transferReport[Strings.medicalRecommendationsSignedYes2],
            Strings.medicalRecommendationsSignedNo2: transferReport[Strings.medicalRecommendationsSignedNo2],
            Strings.clearDaysYes2: transferReport[Strings.clearDaysYes2],
            Strings.clearDaysNo2: transferReport[Strings.clearDaysNo2],
            Strings.signatureDatesOnBeforeYes2: transferReport[Strings.signatureDatesOnBeforeYes2],
            Strings.signatureDatesOnBeforeNo2: transferReport[Strings.signatureDatesOnBeforeNo2],
            Strings.practitionersNameYes2: transferReport[Strings.practitionersNameYes2],
            Strings.practitionersNameNo2: transferReport[Strings.practitionersNameNo2],
            Strings.doctorsAgreeYes: transferReport[Strings.doctorsAgreeYes],
            Strings.doctorsAgreeNo: transferReport[Strings.doctorsAgreeNo],
            Strings.separateMedicalRecommendationsYes: transferReport[Strings.separateMedicalRecommendationsYes],
            Strings.separateMedicalRecommendationsNo: transferReport[Strings.separateMedicalRecommendationsNo],
            Strings.transferInCheckedBy2: transferReport[Strings.transferInCheckedBy2],
            Strings.transferInDate2: transferReport[Strings.transferInDate2],
            Strings.transferInDesignation2: transferReport[Strings.transferInDesignation2],
            Strings.transferInPatientName3: transferReport[Strings.transferInPatientName3],
            Strings.patientCorrectYes3: transferReport[Strings.patientCorrectYes3],
            Strings.patientCorrectNo3: transferReport[Strings.patientCorrectNo3],
            Strings.hospitalCorrectYes3: transferReport[Strings.hospitalCorrectYes3],
            Strings.hospitalCorrectNo3: transferReport[Strings.hospitalCorrectNo3],
            Strings.h4Yes: transferReport[Strings.h4Yes],
            Strings.h4No: transferReport[Strings.h4No],
            Strings.currentConsentYes: transferReport[Strings.currentConsentYes],
            Strings.currentConsentNo: transferReport[Strings.currentConsentNo],
            Strings.applicationFormYes3: transferReport[Strings.applicationFormYes3],
            Strings.applicationFormNo3: transferReport[Strings.applicationFormNo3],
            Strings.applicationSignedYes3: transferReport[Strings.applicationSignedYes3],
            Strings.applicationSignedNo3: transferReport[Strings.applicationSignedNo3],
            Strings.within14DaysYes3: transferReport[Strings.within14DaysYes3],
            Strings.within14DaysNo3: transferReport[Strings.within14DaysNo3],
            Strings.localAuthorityNameYes3: transferReport[Strings.localAuthorityNameYes3],
            Strings.localAuthorityNameNo3: transferReport[Strings.localAuthorityNameNo3],
            Strings.nearestRelativeYes: transferReport[Strings.nearestRelativeYes],
            Strings.nearestRelativeNo: transferReport[Strings.nearestRelativeNo],
            Strings.amhpConsultationYes: transferReport[Strings.amhpConsultationYes],
            Strings.amhpConsultationNo: transferReport[Strings.amhpConsultationNo],
            Strings.knewPatientYes: transferReport[Strings.knewPatientYes],
            Strings.knewPatientNo: transferReport[Strings.knewPatientNo],
            Strings.medicalRecommendationsFormYes3: transferReport[Strings.medicalRecommendationsFormYes3],
            Strings.medicalRecommendationsFormNo3: transferReport[Strings.medicalRecommendationsFormNo3],
            Strings.medicalRecommendationsSignedYes3: transferReport[Strings.medicalRecommendationsSignedYes3],
            Strings.medicalRecommendationsSignedNo3: transferReport[Strings.medicalRecommendationsSignedNo3],
            Strings.clearDaysYes3: transferReport[Strings.clearDaysYes3],
            Strings.clearDaysNo3: transferReport[Strings.clearDaysNo3],
            Strings.approvedSection12Yes: transferReport[Strings.approvedSection12Yes],
            Strings.approvedSection12No: transferReport[Strings.approvedSection12No],
            Strings.signatureDatesOnBeforeYes3: transferReport[Strings.signatureDatesOnBeforeYes3],
            Strings.signatureDatesOnBeforeNo3: transferReport[Strings.signatureDatesOnBeforeNo3],
            Strings.practitionersNameYes3: transferReport[Strings.practitionersNameYes3],
            Strings.practitionersNameNo3: transferReport[Strings.practitionersNameNo3],
            Strings.previouslyAcquaintedYes: transferReport[Strings.previouslyAcquaintedYes],
            Strings.previouslyAcquaintedNo: transferReport[Strings.previouslyAcquaintedNo],
            Strings.acquaintedIfNoYes: transferReport[Strings.acquaintedIfNoYes],
            Strings.acquaintedIfNoNo: transferReport[Strings.acquaintedIfNoNo],
            Strings.recommendationsDifferentTeamsYes: transferReport[Strings.recommendationsDifferentTeamsYes],
            Strings.recommendationsDifferentTeamsNo: transferReport[Strings.recommendationsDifferentTeamsNo],
            Strings.originalDetentionPapersYes: transferReport[Strings.originalDetentionPapersYes],
            Strings.originalDetentionPapersNo: transferReport[Strings.originalDetentionPapersNo],
            Strings.transferInCheckedBy3: transferReport[Strings.transferInCheckedBy3],
            Strings.transferInDate3: transferReport[Strings.transferInDate3],
            Strings.transferInDesignation3: transferReport[Strings.transferInDesignation3],
            Strings.feltSafeYes: transferReport[Strings.feltSafeYes],
            Strings.feltSafeNo: transferReport[Strings.feltSafeNo],
            Strings.staffIntroducedYes: transferReport[Strings.staffIntroducedYes],
            Strings.staffIntroducedNo: transferReport[Strings.staffIntroducedNo],
            Strings.experiencePositiveYes: transferReport[Strings.experiencePositiveYes],
            Strings.experiencePositiveNo: transferReport[Strings.experiencePositiveNo],
            Strings.otherComments: transferReport[Strings.otherComments],
            Strings.vehicleCompletedBy1: transferReport[Strings.vehicleCompletedBy1],
            Strings.vehicleDate: transferReport[Strings.vehicleDate],
            Strings.vehicleTime: transferReport[Strings.vehicleTime],
            Strings.ambulanceReg: transferReport[Strings.ambulanceReg],
            Strings.vehicleStartMileage: transferReport[Strings.vehicleStartMileage],
            Strings.nearestTank1: transferReport[Strings.nearestTank1],
            Strings.ambulanceTidyYes1: transferReport[Strings.ambulanceTidyYes1],
            Strings.ambulanceTidyNo1: transferReport[Strings.ambulanceTidyNo1],
            Strings.lightsWorkingYes: transferReport[Strings.lightsWorkingYes],
            Strings.lightsWorkingNo: transferReport[Strings.lightsWorkingNo],
            Strings.tyresInflatedYes: transferReport[Strings.tyresInflatedYes],
            Strings.tyresInflatedNo: transferReport[Strings.tyresInflatedNo],
            Strings.warningSignsYes: transferReport[Strings.warningSignsYes],
            Strings.warningSignsNo: transferReport[Strings.warningSignsNo],
            Strings.vehicleCompletedBy2: transferReport[Strings.vehicleCompletedBy2],
            Strings.nearestTank2: transferReport[Strings.nearestTank2],
            Strings.vehicleFinishMileage: transferReport[Strings.vehicleFinishMileage],
            Strings.ambulanceTidyYes2: transferReport[Strings.ambulanceTidyYes2],
            Strings.ambulanceTidyNo2: transferReport[Strings.ambulanceTidyNo2],
            Strings.sanitiserCleanYes: transferReport[Strings.sanitiserCleanYes],
            Strings.sanitiserCleanNo: transferReport[Strings.sanitiserCleanNo],
            Strings.issuesFaults: transferReport[Strings.issuesFaults],
            Strings.serverUploaded: 1,
          });

          //Sembast
          final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
              [Db.Filter.equals(Strings.documentId, selectedTransferReport[Strings.documentId]), Db.Filter.equals(Strings.jobId, jobId)]
          ));

          await _editedTransferReportsStore.delete(await _db,
              finder: finder);
          message = 'Transfer Report uploaded successfully';
          success = true;
          getTransferReports();




        } on TimeoutException catch (_) {
          // A timeout occurred.
          message = 'Network Timeout communicating with the server, unable to edit Transfer Report';

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
      deleteEditedRecord();
      //deleteEditedTransferReport();
    }
    GlobalFunctions.showToast(message);
    return success;


  }


  Future<void> getTransferReports() async{

    _isLoading = true;
    notifyListeners();
    String message = '';
    List<Map<String, dynamic>> _fetchedTransferReportList = [];

    try {

      bool hasDataConnection = await GlobalFunctions.hasDataConnection();

      if(!hasDataConnection){

        GlobalFunctions.showToast('No data connection, unable to fetch Transfer Reports');
        _transferReports = [];

      } else {


        bool isTokenExpired = GlobalFunctions.isTokenExpired();
        bool authenticated = true;

        if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

        if(authenticated){


          QuerySnapshot snapshot;

          if(user.role == 'Super User'){
            try{
              snapshot = await FirebaseFirestore.instance.collection('transfer_reports').orderBy('timestamp', descending: true).limit(10).get().timeout(Duration(seconds: 90));
            } catch(e){
              print(e);
            }
          } else {
            try{
              snapshot = await FirebaseFirestore.instance.collection('transfer_reports').where(
                  'uid', isEqualTo: user.uid).orderBy('timestamp', descending: true).limit(10).get().timeout(Duration(seconds: 90));
            } catch(e){
              print(e);
            }
          }

          Map<String, dynamic> snapshotData = {};

          if(snapshot.docs.length < 1){
            message = 'No Transfer Reports found';
          } else {
            for (DocumentSnapshot snap in snapshot.docs) {

              snapshotData = snap.data();

              Uint8List incidentSignature;
              Uint8List collectionSignature;
              Uint8List destinationSignature;
              Uint8List bodyMapImage;
              Uint8List patientReportSignature;
              Uint8List transferInSignature1;
              Uint8List transferInSignature2;
              Uint8List transferInSignature3;


              if (snapshotData[Strings.incidentSignature] != null) {
                Reference storageRef =
                FirebaseStorage.instance.ref().child('transferReportImages/' + snap.id + '/incidentSignature.jpg');

                if(kIsWeb){
                  storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + snap.id + '/incidentSignature.jpg');
                }

                incidentSignature = await storageRef.getData(dataLimit);
              }
              if (snapshotData[Strings.collectionSignature] != null) {
                Reference storageRef =
                FirebaseStorage.instance.ref().child('transferReportImages/' + snap.id + '/collectionSignature.jpg');

                if(kIsWeb){
                  storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + snap.id + '/collectionSignature.jpg');
                }

                collectionSignature = await storageRef.getData(dataLimit);
              }
              if (snapshotData[Strings.destinationSignature] != null) {
                Reference storageRef =
                FirebaseStorage.instance.ref().child('transferReportImages/' + snap.id + '/destinationSignature.jpg');

                if(kIsWeb){
                  storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + snap.id + '/destinationSignature.jpg');
                }

                destinationSignature = await storageRef.getData(dataLimit);
              }
              if (snapshotData[Strings.bodyMapImage] != null) {
                Reference storageRef =
                FirebaseStorage.instance.ref().child('transferReportImages/' + snap.id + '/bodyMapImage.jpg');

                if(kIsWeb){
                  storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + snap.id + '/bodyMapImage.jpg');
                }

                bodyMapImage = await storageRef.getData(dataLimit);
              }
              if (snapshotData[Strings.patientReportSignature] != null) {
                Reference storageRef =
                FirebaseStorage.instance.ref().child('transferReportImages/' + snap.id + '/patientReportSignature.jpg');

                if(kIsWeb){
                  storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + snap.id + '/patientReportSignature.jpg');
                }

                patientReportSignature = await storageRef.getData(dataLimit);
              }
              if (snapshotData[Strings.transferInSignature1] != null) {
                Reference storageRef =
                FirebaseStorage.instance.ref().child('transferReportImages/' + snap.id + '/transferInSignature1.jpg');

                if(kIsWeb){
                  storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + snap.id + '/transferInSignature1.jpg');
                }

                transferInSignature1 = await storageRef.getData(dataLimit);
              }
              if (snapshotData[Strings.transferInSignature2] != null) {
                Reference storageRef =
                FirebaseStorage.instance.ref().child('transferReportImages/' + snap.id + '/transferInSignature2.jpg');

                if(kIsWeb){
                  storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + snap.id + '/transferInSignature2.jpg');
                }

                transferInSignature2 = await storageRef.getData(dataLimit);
              }
              if (snapshotData[Strings.transferInSignature3] != null) {
                Reference storageRef =
                FirebaseStorage.instance.ref().child('transferReportImages/' + snap.id + '/transferInSignature3.jpg');

                if(kIsWeb){
                  storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + snap.id + '/transferInSignature3.jpg');
                }

                transferInSignature3 = await storageRef.getData(dataLimit);
              }

              final Map<String, dynamic> transferReport = onlineTransferReport(snapshotData, snap.id, incidentSignature, collectionSignature, destinationSignature, bodyMapImage, patientReportSignature, transferInSignature1, transferInSignature2, transferInSignature3);

              _fetchedTransferReportList.add(transferReport);

            }

            _transferReports = _fetchedTransferReportList;
          }


        }

      }


    } on TimeoutException catch (_) {
      // A timeout occurred.
      message = 'Network Timeout communicating with the server, unable to fetch latest Transfer Reports';
    } catch(e){
      print(e);
      message = 'Something went wrong. Please try again';

    }

    _isLoading = false;
    notifyListeners();
    _selTransferReportId = null;
    if(message != '') GlobalFunctions.showToast(message);

  }

  Future<void> getMoreTransferReports() async{

    String message = '';

    List<Map<String, dynamic>> _fetchedTransferReportList = [];

    try {

      bool hasDataConnection = await GlobalFunctions.hasDataConnection();

      if(!hasDataConnection){

        GlobalFunctions.showToast('No data connection, unable to fetch Transfer Reports');

      } else {


        bool isTokenExpired = GlobalFunctions.isTokenExpired();
        bool authenticated = true;

        if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

        if(authenticated){


          QuerySnapshot snapshot;
          int currentLength = _transferReports.length;
          DateTime latestDate = DateTime.parse(_transferReports[currentLength - 1][Strings.timestamp]);

          if(user.role == 'Super User'){
            try {
              snapshot = await FirebaseFirestore.instance.collection('transfer_reports').orderBy(
                  'timestamp', descending: true).startAfter(
                  [Timestamp.fromDate(latestDate)]).limit(10)
                  .get()
                  .timeout(Duration(seconds: 90));
            } catch(e) {
              print(e);
            }

          } else {
            try {
              snapshot = await FirebaseFirestore.instance.collection('transfer_reports').where(
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
            message = 'No more Transfer Reports found';
          } else {
            for (DocumentSnapshot snap in snapshot.docs) {

              snapshotData = snap.data();

              Uint8List incidentSignature;
              Uint8List collectionSignature;
              Uint8List destinationSignature;
              Uint8List bodyMapImage;
              Uint8List patientReportSignature;
              Uint8List transferInSignature1;
              Uint8List transferInSignature2;
              Uint8List transferInSignature3;

              if (snapshotData[Strings.incidentSignature] != null) {
                Reference storageRef =
                FirebaseStorage.instance.ref().child('transferReportImages/' + snap.id + '/incidentSignature.jpg');

                if(kIsWeb){
                  storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + snap.id + '/incidentSignature.jpg');
                }

                incidentSignature = await storageRef.getData(dataLimit);
              }
              if (snapshotData[Strings.collectionSignature] != null) {
                Reference storageRef =
                FirebaseStorage.instance.ref().child('transferReportImages/' + snap.id + '/collectionSignature.jpg');

                if(kIsWeb){
                  storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + snap.id + '/collectionSignature.jpg');
                }

                collectionSignature = await storageRef.getData(dataLimit);
              }
              if (snapshotData[Strings.destinationSignature] != null) {
                Reference storageRef =
                FirebaseStorage.instance.ref().child('transferReportImages/' + snap.id + '/destinationSignature.jpg');

                if(kIsWeb){
                  storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + snap.id + '/destinationSignature.jpg');
                }

                destinationSignature = await storageRef.getData(dataLimit);
              }
              if (snapshotData[Strings.bodyMapImage] != null) {
                Reference storageRef =
                FirebaseStorage.instance.ref().child('transferReportImages/' + snap.id + '/bodyMapImage.jpg');

                if(kIsWeb){
                  storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + snap.id + '/bodyMapImage.jpg');
                }

                bodyMapImage = await storageRef.getData(dataLimit);
              }
              if (snapshotData[Strings.patientReportSignature] != null) {
                Reference storageRef =
                FirebaseStorage.instance.ref().child('transferReportImages/' + snap.id + '/patientReportSignature.jpg');

                if(kIsWeb){
                  storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + snap.id + '/patientReportSignature.jpg');
                }

                patientReportSignature = await storageRef.getData(dataLimit);
              }
              if (snapshotData[Strings.transferInSignature1] != null) {
                Reference storageRef =
                FirebaseStorage.instance.ref().child('transferReportImages/' + snap.id + '/transferInSignature1.jpg');

                if(kIsWeb){
                  storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + snap.id + '/transferInSignature1.jpg');
                }

                transferInSignature1 = await storageRef.getData(dataLimit);
              }
              if (snapshotData[Strings.transferInSignature2] != null) {
                Reference storageRef =
                FirebaseStorage.instance.ref().child('transferReportImages/' + snap.id + '/transferInSignature2.jpg');

                if(kIsWeb){
                  storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + snap.id + '/transferInSignature2.jpg');
                }

                transferInSignature2 = await storageRef.getData(dataLimit);
              }
              if (snapshotData[Strings.transferInSignature3] != null) {
                Reference storageRef =
                FirebaseStorage.instance.ref().child('transferReportImages/' + snap.id + '/transferInSignature3.jpg');

                if(kIsWeb){
                  storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + snap.id + '/transferInSignature3.jpg');
                }

                transferInSignature3 = await storageRef.getData(dataLimit);
              }

              final Map<String, dynamic> transferReport = onlineTransferReport(snapshotData, snap.id, incidentSignature, collectionSignature, destinationSignature, bodyMapImage, patientReportSignature, transferInSignature1, transferInSignature2, transferInSignature3);

              _fetchedTransferReportList.add(transferReport);

            }

            _transferReports.addAll(_fetchedTransferReportList);
          }


        }

      }


    } on TimeoutException catch (_) {
      // A timeout occurred.
      message = 'Network Timeout communicating with the server, unable to fetch latest Transfer Reports';
    } catch(e){
      print(e);
      message = 'Something went wrong. Please try again';

    }

    _isLoading = false;
    notifyListeners();
    _selTransferReportId = null;
    if(message != '') GlobalFunctions.showToast(message);

  }

  Future<bool> searchTransferReports(DateTime dateFrom, DateTime dateTo, String jobRef, String selectedGender, String selectedUser, bool handcuffs, bool physicalIntervention) async{

    _isLoading = true;
    notifyListeners();
    bool success = false;
    String message = '';
    GlobalFunctions.showLoadingDialog('Searching Forms');
    List<Map<String, dynamic>> _fetchedTransferReportList = [];

    print(dateFrom);
    print(dateTo);

    var handCuffsValue = handcuffs == false ? null : 1;
    var physicalInterventionValue = physicalIntervention == false ? null : 1;

    try {

      bool hasDataConnection = await GlobalFunctions.hasDataConnection();

      if(!hasDataConnection){

        message = 'No Data Connection, unable to search Transfer Reports';

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
                    await FirebaseFirestore.instance.collection('transfer_reports')
                        .where(Strings.uid, isEqualTo: selectedUser)
                        .where(Strings.gender, isEqualTo: selectedGender)
                        .where(Strings.handcuffsUsedYes, isEqualTo: handCuffsValue)
                        .where(Strings.physicalInterventionYes, isEqualTo: physicalInterventionValue).orderBy('timestamp', descending: true)
                        .startAt([dateTo]).endAt([dateFrom]).get()
                        .timeout(Duration(seconds: 90));
                  } catch(e){
                    print(e);
                  }
                } else {
                  try{
                    snapshot =
                    await FirebaseFirestore.instance.collection('transfer_reports')
                        .where(Strings.gender, isEqualTo: selectedGender)
                        .where(Strings.handcuffsUsedYes, isEqualTo: handCuffsValue)
                        .where(Strings.physicalInterventionYes, isEqualTo: physicalInterventionValue).orderBy('timestamp', descending: true)
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
                    await FirebaseFirestore.instance.collection('transfer_reports')
                        .where(Strings.jobRefLowercase, isEqualTo: jobRef.toLowerCase())
                        .where(Strings.uid, isEqualTo: selectedUser)
                        .where(Strings.gender, isEqualTo: selectedGender)
                        .where(Strings.handcuffsUsedYes, isEqualTo: handCuffsValue)
                        .where(Strings.physicalInterventionYes, isEqualTo: physicalInterventionValue).orderBy('timestamp', descending: true)
                        .startAt([dateTo]).endAt([dateFrom]).get()
                        .timeout(Duration(seconds: 90));
                  } catch(e){
                    print(e);
                  }
                } else {
                  try{
                    snapshot =
                    await FirebaseFirestore.instance.collection('transfer_reports')
                        .where(Strings.jobRefLowercase, isEqualTo: jobRef.toLowerCase())
                        .where(Strings.gender, isEqualTo: selectedGender)
                        .where(Strings.handcuffsUsedYes, isEqualTo: handCuffsValue)
                        .where(Strings.physicalInterventionYes, isEqualTo: physicalInterventionValue).orderBy('timestamp', descending: true)
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
                    await FirebaseFirestore.instance.collection('transfer_reports')
                        .where(Strings.uid, isEqualTo: selectedUser)
                        .where(Strings.gender, isEqualTo: selectedGender)
                        .where(Strings.handcuffsUsedYes, isEqualTo: handCuffsValue)
                        .where(Strings.physicalInterventionYes, isEqualTo: physicalInterventionValue).orderBy('timestamp', descending: true)
                        .get()
                        .timeout(Duration(seconds: 90));
                  } catch(e){
                    print(e);
                  }
                } else {
                  try{
                    snapshot =
                    await FirebaseFirestore.instance.collection('transfer_reports')
                        .where(Strings.gender, isEqualTo: selectedGender)
                        .where(Strings.handcuffsUsedYes, isEqualTo: handCuffsValue)
                        .where(Strings.physicalInterventionYes, isEqualTo: physicalInterventionValue).orderBy('timestamp', descending: true)
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
                    await FirebaseFirestore.instance.collection('transfer_reports')
                        .where(Strings.jobRefLowercase, isEqualTo: jobRef.toLowerCase())
                        .where(Strings.uid, isEqualTo: selectedUser)
                        .where(Strings.gender, isEqualTo: selectedGender)
                        .where(Strings.handcuffsUsedYes, isEqualTo: handCuffsValue)
                        .where(Strings.physicalInterventionYes, isEqualTo: physicalInterventionValue).orderBy('timestamp', descending: true)
                        .get()
                        .timeout(Duration(seconds: 90));
                  } catch(e){
                    print(e);
                  }
                } else {
                  try{
                    snapshot =
                    await FirebaseFirestore.instance.collection('transfer_reports')
                        .where(Strings.jobRefLowercase, isEqualTo: jobRef.toLowerCase())
                        .where(Strings.gender, isEqualTo: selectedGender)
                        .where(Strings.handcuffsUsedYes, isEqualTo: handCuffsValue)
                        .where(Strings.physicalInterventionYes, isEqualTo: physicalInterventionValue).orderBy('timestamp', descending: true)
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
                    await FirebaseFirestore.instance.collection('transfer_reports')
                        .where(Strings.uid, isEqualTo: user.uid)
                        .where(Strings.gender, isEqualTo: selectedGender)
                        .where(Strings.handcuffsUsedYes, isEqualTo: handCuffsValue)
                        .where(Strings.physicalInterventionYes, isEqualTo: physicalInterventionValue).orderBy('timestamp', descending: true)
                        .startAt([dateTo]).endAt([dateFrom]).get()
                        .timeout(Duration(seconds: 90));
                  } catch(e){
                    print(e);
                  }


              } else {


                  try{
                    snapshot =
                    await FirebaseFirestore.instance.collection('transfer_reports')
                        .where(Strings.jobRefLowercase, isEqualTo: jobRef.toLowerCase())
                        .where(Strings.uid, isEqualTo: user.uid)
                        .where(Strings.gender, isEqualTo: selectedGender)
                        .where(Strings.handcuffsUsedYes, isEqualTo: handCuffsValue)
                        .where(Strings.physicalInterventionYes, isEqualTo: physicalInterventionValue).orderBy('timestamp', descending: true)
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
                    await FirebaseFirestore.instance.collection('transfer_reports')
                        .where(Strings.uid, isEqualTo: user.uid)
                        .where(Strings.gender, isEqualTo: selectedGender)
                        .where(Strings.handcuffsUsedYes, isEqualTo: handCuffsValue)
                        .where(Strings.physicalInterventionYes, isEqualTo: physicalInterventionValue).orderBy('timestamp', descending: true)
                        .get()
                        .timeout(Duration(seconds: 90));
                  } catch(e){
                    print(e);
                  }


              } else {

                  try{
                    snapshot =
                    await FirebaseFirestore.instance.collection('transfer_reports')
                        .where(Strings.jobRefLowercase, isEqualTo: jobRef.toLowerCase())
                        .where(Strings.uid, isEqualTo: user.uid)
                        .where(Strings.gender, isEqualTo: selectedGender)
                        .where(Strings.handcuffsUsedYes, isEqualTo: handCuffsValue)
                        .where(Strings.physicalInterventionYes, isEqualTo: physicalInterventionValue).orderBy('timestamp', descending: true)
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
            message = 'No Transfer Reports found';
          } else {
            for (DocumentSnapshot snap in snapshot.docs) {

              snapshotData = snap.data();

              Uint8List incidentSignature;
              Uint8List collectionSignature;
              Uint8List destinationSignature;
              Uint8List bodyMapImage;
              Uint8List patientReportSignature;
              Uint8List transferInSignature1;
              Uint8List transferInSignature2;
              Uint8List transferInSignature3;

              if (snapshotData[Strings.incidentSignature] != null) {
                Reference storageRef =
                FirebaseStorage.instance.ref().child('transferReportImages/' + snap.id + '/incidentSignature.jpg');

                if(kIsWeb){
                  storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + snap.id + '/incidentSignature.jpg');
                }

                incidentSignature = await storageRef.getData(dataLimit);
              }
              if (snapshotData[Strings.collectionSignature] != null) {
                Reference storageRef =
                FirebaseStorage.instance.ref().child('transferReportImages/' + snap.id + '/collectionSignature.jpg');

                if(kIsWeb){
                  storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + snap.id + '/collectionSignature.jpg');
                }

                collectionSignature = await storageRef.getData(dataLimit);
              }
              if (snapshotData[Strings.destinationSignature] != null) {
                Reference storageRef =
                FirebaseStorage.instance.ref().child('transferReportImages/' + snap.id + '/destinationSignature.jpg');

                if(kIsWeb){
                  storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + snap.id + '/destinationSignature.jpg');
                }

                destinationSignature = await storageRef.getData(dataLimit);
              }
              if (snapshotData[Strings.bodyMapImage] != null) {
                Reference storageRef =
                FirebaseStorage.instance.ref().child('transferReportImages/' + snap.id + '/bodyMapImage.jpg');

                if(kIsWeb){
                  storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + snap.id + '/bodyMapImage.jpg');
                }

                bodyMapImage = await storageRef.getData(dataLimit);
              }
              if (snapshotData[Strings.patientReportSignature] != null) {
                Reference storageRef =
                FirebaseStorage.instance.ref().child('transferReportImages/' + snap.id + '/patientReportSignature.jpg');

                if(kIsWeb){
                  storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + snap.id + '/patientReportSignature.jpg');
                }

                patientReportSignature = await storageRef.getData(dataLimit);
              }
              if (snapshotData[Strings.transferInSignature1] != null) {
                Reference storageRef =
                FirebaseStorage.instance.ref().child('transferReportImages/' + snap.id + '/transferInSignature1.jpg');

                if(kIsWeb){
                  storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + snap.id + '/transferInSignature1.jpg');
                }

                transferInSignature1 = await storageRef.getData(dataLimit);
              }
              if (snapshotData[Strings.transferInSignature2] != null) {
                Reference storageRef =
                FirebaseStorage.instance.ref().child('transferReportImages/' + snap.id + '/transferInSignature2.jpg');

                if(kIsWeb){
                  storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + snap.id + '/transferInSignature2.jpg');
                }

                transferInSignature2 = await storageRef.getData(dataLimit);
              }
              if (snapshotData[Strings.transferInSignature3] != null) {
                Reference storageRef =
                FirebaseStorage.instance.ref().child('transferReportImages/' + snap.id + '/transferInSignature3.jpg');

                if(kIsWeb){
                  storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + snap.id + '/transferInSignature3.jpg');
                }

                transferInSignature3 = await storageRef.getData(dataLimit);
              }

              final Map<String, dynamic> transferReport = onlineTransferReport(snapshotData, snap.id, incidentSignature, collectionSignature, destinationSignature, bodyMapImage, patientReportSignature, transferInSignature1, transferInSignature2, transferInSignature3);

              _fetchedTransferReportList.add(transferReport);

            }

            _transferReports = _fetchedTransferReportList;
            success = true;
          }


        }

      }


    } on TimeoutException catch (_) {
      // A timeout occurred.
      message = 'Network Timeout communicating with the server, unable to search Transfer Reports';
    } catch(e){
      print(e);
      message = 'Something went wrong. Please try again';

    }

    _isLoading = false;
    notifyListeners();
    _selTransferReportId = null;
    GlobalFunctions.dismissLoadingDialog();
    if(message != '') GlobalFunctions.showToast(message);
    return success;

  }


  Future<bool> searchMoreTransferReports(DateTime dateFrom, DateTime dateTo) async{

    _isLoading = true;
    notifyListeners();
    bool success = false;
    String message = '';
    GlobalFunctions.showLoadingDialog('Searching Forms');
    List<Map<String, dynamic>> _fetchedTransferReportList = [];

    try {

      bool hasDataConnection = await GlobalFunctions.hasDataConnection();

      if(!hasDataConnection){

        message = 'No Data Connection, unable to search Transfer Reports';

      } else {


        bool isTokenExpired = GlobalFunctions.isTokenExpired();
        bool authenticated = true;

        if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

        if(authenticated){


          QuerySnapshot snapshot;
          int currentLength = _transferReports.length;
          DateTime latestDate = DateTime.parse(_transferReports[currentLength - 1]['timestamp']);

          if(user.role == 'Super User'){
              try{
                snapshot =
                await FirebaseFirestore.instance.collection('transfer_reports').orderBy('timestamp', descending: true)
                    .startAfter([Timestamp.fromDate(latestDate)]).endAt([dateFrom]).limit(10).get()
                    .timeout(Duration(seconds: 90));
              } catch(e){
                print(e);
              }

          } else {

              try{
                snapshot =
                await FirebaseFirestore.instance.collection('transfer_reports').where('uid', isEqualTo: user.uid).orderBy('timestamp', descending: true)
                    .startAfter([Timestamp.fromDate(latestDate)]).endAt([dateFrom]).limit(10).get()
                    .timeout(Duration(seconds: 90));
              } catch(e){
                print(e);
              }

          }

          Map<String, dynamic> snapshotData = {};

          if(snapshot.docs.length < 1){
            message = 'No Transfer Reports found';
          } else {
            for (DocumentSnapshot snap in snapshot.docs) {

              snapshotData = snap.data();

              Uint8List incidentSignature;
              Uint8List collectionSignature;
              Uint8List destinationSignature;
              Uint8List bodyMapImage;
              Uint8List patientReportSignature;
              Uint8List transferInSignature1;
              Uint8List transferInSignature2;
              Uint8List transferInSignature3;

              if (snapshotData[Strings.incidentSignature] != null) {
                Reference storageRef =
                FirebaseStorage.instance.ref().child('transferReportImages/' + snap.id + '/incidentSignature.jpg');

                if(kIsWeb){
                  storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + snap.id + '/incidentSignature.jpg');
                }

                incidentSignature = await storageRef.getData(dataLimit);
              }
              if (snapshotData[Strings.collectionSignature] != null) {
                Reference storageRef =
                FirebaseStorage.instance.ref().child('transferReportImages/' + snap.id + '/collectionSignature.jpg');

                if(kIsWeb){
                  storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + snap.id + '/collectionSignature.jpg');
                }

                collectionSignature = await storageRef.getData(dataLimit);
              }
              if (snapshotData[Strings.destinationSignature] != null) {
                Reference storageRef =
                FirebaseStorage.instance.ref().child('transferReportImages/' + snap.id + '/destinationSignature.jpg');

                if(kIsWeb){
                  storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + snap.id + '/destinationSignature.jpg');
                }

                destinationSignature = await storageRef.getData(dataLimit);
              }
              if (snapshotData[Strings.bodyMapImage] != null) {
                Reference storageRef =
                FirebaseStorage.instance.ref().child('transferReportImages/' + snap.id + '/bodyMapImage.jpg');

                if(kIsWeb){
                  storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + snap.id + '/bodyMapImage.jpg');
                }

                bodyMapImage = await storageRef.getData(dataLimit);
              }
              if (snapshotData[Strings.patientReportSignature] != null) {
                Reference storageRef =
                FirebaseStorage.instance.ref().child('transferReportImages/' + snap.id + '/patientReportSignature.jpg');

                if(kIsWeb){
                  storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + snap.id + '/patientReportSignature.jpg');
                }

                patientReportSignature = await storageRef.getData(dataLimit);
              }
              if (snapshotData[Strings.transferInSignature1] != null) {
                Reference storageRef =
                FirebaseStorage.instance.ref().child('transferReportImages/' + snap.id + '/transferInSignature1.jpg');

                if(kIsWeb){
                  storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + snap.id + '/transferInSignature1.jpg');
                }

                transferInSignature1 = await storageRef.getData(dataLimit);
              }
              if (snapshotData[Strings.transferInSignature2] != null) {
                Reference storageRef =
                FirebaseStorage.instance.ref().child('transferReportImages/' + snap.id + '/transferInSignature2.jpg');

                if(kIsWeb){
                  storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + snap.id + '/transferInSignature2.jpg');
                }

                transferInSignature2 = await storageRef.getData(dataLimit);
              }
              if (snapshotData[Strings.transferInSignature3] != null) {
                Reference storageRef =
                FirebaseStorage.instance.ref().child('transferReportImages/' + snap.id + '/transferInSignature3.jpg');

                if(kIsWeb){
                  storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + snap.id + '/transferInSignature3.jpg');
                }

                transferInSignature3 = await storageRef.getData(dataLimit);
              }

              final Map<String, dynamic> transferReport = onlineTransferReport(snapshotData, snap.id, incidentSignature, collectionSignature, destinationSignature, bodyMapImage, patientReportSignature, transferInSignature1, transferInSignature2, transferInSignature3);

              _fetchedTransferReportList.add(transferReport);

            }

            _transferReports.addAll(_fetchedTransferReportList);
            success = true;
          }


        }

      }


    } on TimeoutException catch (_) {
      // A timeout occurred.
      message = 'Network Timeout communicating with the server, unable to search Transfer Reports';
    } catch(e){
      print(e);
      message = 'Something went wrong. Please try again';

    }

    _isLoading = false;
    notifyListeners();
    _selTransferReportId = null;
    GlobalFunctions.dismissLoadingDialog();
    if(message != '') GlobalFunctions.showToast(message);
    return success;

  }


  Map<String, dynamic> localTransferReport(Map<String, dynamic> localRecord){
    return {
      Strings.documentId: GlobalFunctions.databaseValueString(localRecord[Strings.documentId]),
      Strings.uid: GlobalFunctions.databaseValueString(localRecord[Strings.uid]),
      Strings.jobId: localRecord[Strings.jobId],
      Strings.formVersion: localRecord[Strings.formVersion],
      Strings.jobRef: localRecord[Strings.jobRef],
      Strings.date: localRecord[Strings.date],
      Strings.startTime: localRecord[Strings.startTime],
      Strings.finishTime: localRecord[Strings.finishTime],
      Strings.totalHours: localRecord[Strings.totalHours],
      Strings.collectionDetails: localRecord[Strings.collectionDetails],
      Strings.collectionPostcode: localRecord[Strings.collectionPostcode],
      Strings.collectionContactNo: localRecord[Strings.collectionContactNo],
      Strings.destinationDetails: localRecord[Strings.destinationDetails],
      Strings.destinationPostcode: localRecord[Strings.destinationPostcode],
      Strings.destinationContactNo: localRecord[Strings.destinationContactNo],
      Strings.collectionArrivalTime: localRecord[Strings.collectionArrivalTime],
      Strings.collectionDepartureTime: localRecord[Strings.collectionDepartureTime],
      Strings.destinationArrivalTime: localRecord[Strings.destinationArrivalTime],
      Strings.destinationDepartureTime: localRecord[Strings.destinationDepartureTime],
      Strings.vehicleRegNo: localRecord[Strings.vehicleRegNo],
      Strings.startMileage: localRecord[Strings.startMileage],
      Strings.finishMileage: localRecord[Strings.finishMileage],
      Strings.totalMileage: localRecord[Strings.totalMileage],
      Strings.name1: localRecord[Strings.name1],
      Strings.role1: localRecord[Strings.role1],
      Strings.drivingTimes1_1: localRecord[Strings.drivingTimes1_1],
      Strings.drivingTimes1_2: localRecord[Strings.drivingTimes1_2],
      Strings.name2: localRecord[Strings.name2],
      Strings.role2: localRecord[Strings.role2],
      Strings.drivingTimes2_1: localRecord[Strings.drivingTimes2_1],
      Strings.drivingTimes2_2: localRecord[Strings.drivingTimes2_2],
      Strings.name3: localRecord[Strings.name3],
      Strings.role3: localRecord[Strings.role3],
      Strings.drivingTimes3_1: localRecord[Strings.drivingTimes3_1],
      Strings.drivingTimes3_2: localRecord[Strings.drivingTimes3_2],
      Strings.name4: localRecord[Strings.name4],
      Strings.role4: localRecord[Strings.role4],
      Strings.drivingTimes4_1: localRecord[Strings.drivingTimes4_1],
      Strings.drivingTimes4_2: localRecord[Strings.drivingTimes4_2],
      Strings.name5: localRecord[Strings.name5],
      Strings.role5: localRecord[Strings.role5],
      Strings.drivingTimes5_1: localRecord[Strings.drivingTimes5_1],
      Strings.drivingTimes5_2: localRecord[Strings.drivingTimes5_2],
      Strings.name6: localRecord[Strings.name6],
      Strings.role6: localRecord[Strings.role6],
      Strings.drivingTimes6_1: localRecord[Strings.drivingTimes6_1],
      Strings.drivingTimes6_2: localRecord[Strings.drivingTimes6_2],
      Strings.name7: localRecord[Strings.name7],
      Strings.role7: localRecord[Strings.role7],
      Strings.drivingTimes7_1: localRecord[Strings.drivingTimes7_1],
      Strings.drivingTimes7_2: localRecord[Strings.drivingTimes7_2],
      Strings.name8: localRecord[Strings.name8],
      Strings.role8: localRecord[Strings.role8],
      Strings.drivingTimes8_1: localRecord[Strings.drivingTimes8_1],
      Strings.drivingTimes8_2: localRecord[Strings.drivingTimes8_2],
      Strings.name9: localRecord[Strings.name9],
      Strings.role9: localRecord[Strings.role9],
      Strings.drivingTimes9_1: localRecord[Strings.drivingTimes9_1],
      Strings.drivingTimes9_2: localRecord[Strings.drivingTimes9_2],
      Strings.name10: localRecord[Strings.name10],
      Strings.role10: localRecord[Strings.role10],
      Strings.drivingTimes10_1: localRecord[Strings.drivingTimes10_1],
      Strings.drivingTimes10_2: localRecord[Strings.drivingTimes10_2],
      Strings.name11: localRecord[Strings.name11],
      Strings.role11: localRecord[Strings.role11],
      Strings.drivingTimes11_1: localRecord[Strings.drivingTimes11_1],
      Strings.drivingTimes11_2: localRecord[Strings.drivingTimes11_2],
      Strings.collectionUnit: localRecord[Strings.collectionUnit],
      Strings.collectionPosition: localRecord[Strings.collectionPosition],
      Strings.collectionPrintName: localRecord[Strings.collectionPrintName],
      Strings.collectionArrivalTimeEnd: localRecord[Strings.collectionArrivalTimeEnd],
      Strings.collectionSignature: localRecord[Strings.collectionSignature],
      Strings.collectionSignaturePoints: localRecord[Strings.collectionSignaturePoints],
      Strings.destinationUnit: localRecord[Strings.destinationUnit],
      Strings.destinationPosition: localRecord[Strings.destinationPosition],
      Strings.destinationPrintName: localRecord[Strings.destinationPrintName],
      Strings.destinationArrivalTimeEnd: localRecord[Strings.destinationArrivalTimeEnd],
      Strings.destinationSignature: localRecord[Strings.destinationSignature],
      Strings.patientName: localRecord[Strings.patientName],
      Strings.dateOfBirth: localRecord[Strings.dateOfBirth],
      Strings.ethnicity: localRecord[Strings.ethnicity],
      Strings.gender: localRecord[Strings.gender],
      Strings.mhaMcaDetails: localRecord[Strings.mhaMcaDetails],
      Strings.diagnosis: localRecord[Strings.diagnosis],
      Strings.currentPresentation: localRecord[Strings.currentPresentation],
      Strings.riskYes: localRecord[Strings.riskYes],
      Strings.riskNo: localRecord[Strings.riskNo],
      Strings.riskExplanation: localRecord[Strings.riskExplanation],
      Strings.forensicHistoryYes: localRecord[Strings.forensicHistoryYes],
      Strings.forensicHistoryNo: localRecord[Strings.forensicHistoryNo],
      Strings.racialGenderConcernsYes: localRecord[Strings.racialGenderConcernsYes],
      Strings.racialGenderConcernsNo: localRecord[Strings.racialGenderConcernsNo],
      Strings.violenceAggressionYes: localRecord[Strings.violenceAggressionYes],
      Strings.violenceAggressionNo: localRecord[Strings.violenceAggressionNo],
      Strings.selfHarmYes: localRecord[Strings.selfHarmYes],
      Strings.selfHarmNo: localRecord[Strings.selfHarmNo],
      Strings.alcoholSubstanceYes: localRecord[Strings.alcoholSubstanceYes],
      Strings.alcoholSubstanceNo: localRecord[Strings.alcoholSubstanceNo],
      Strings.virusesYes: localRecord[Strings.virusesYes],
      Strings.virusesNo: localRecord[Strings.virusesNo],
      Strings.safeguardingYes: localRecord[Strings.safeguardingYes],
      Strings.safeguardingNo: localRecord[Strings.safeguardingNo],
      Strings.physicalHealthConditionsYes: localRecord[Strings.physicalHealthConditionsYes],
      Strings.physicalHealthConditionsNo: localRecord[Strings.physicalHealthConditionsNo],
      Strings.useOfWeaponYes: localRecord[Strings.useOfWeaponYes],
      Strings.useOfWeaponNo: localRecord[Strings.useOfWeaponNo],
      Strings.absconsionRiskYes: localRecord[Strings.absconsionRiskYes],
      Strings.absconsionRiskNo: localRecord[Strings.absconsionRiskNo],
      Strings.forensicHistory: localRecord[Strings.forensicHistory],
      Strings.racialGenderConcerns: localRecord[Strings.racialGenderConcerns],
      Strings.violenceAggression: localRecord[Strings.violenceAggression],
      Strings.selfHarm: localRecord[Strings.selfHarm],
      Strings.alcoholSubstance: localRecord[Strings.alcoholSubstance],
      Strings.viruses: localRecord[Strings.viruses],
      Strings.safeguarding: localRecord[Strings.safeguarding],
      Strings.physicalHealthConditions: localRecord[Strings.physicalHealthConditions],
      Strings.useOfWeapon: localRecord[Strings.useOfWeapon],
      Strings.absconsionRisk: localRecord[Strings.absconsionRisk],
      Strings.patientPropertyYes: localRecord[Strings.patientPropertyYes],
      Strings.patientPropertyNo: localRecord[Strings.patientPropertyNo],
      Strings.patientPropertyExplanation: localRecord[Strings.patientPropertyExplanation],
      Strings.patientPropertyReceived: localRecord[Strings.patientPropertyReceived],
      Strings.patientPropertyReceivedYes: localRecord[Strings.patientPropertyReceivedYes],
      Strings.patientPropertyReceivedNo: localRecord[Strings.patientPropertyReceivedNo],
      Strings.patientNotesReceived: localRecord[Strings.patientNotesReceived],
      Strings.patientNotesReceivedYes: localRecord[Strings.patientNotesReceivedYes],
      Strings.patientNotesReceivedNo: localRecord[Strings.patientNotesReceivedNo],
      Strings.patientSearched: localRecord[Strings.patientSearched],
      Strings.patientSearchedYes: localRecord[Strings.patientSearchedYes],
      Strings.patientSearchedNo: localRecord[Strings.patientSearchedNo],
      Strings.itemsRemovedYes: localRecord[Strings.itemsRemovedYes],
      Strings.itemsRemovedNo: localRecord[Strings.itemsRemovedNo],
      Strings.itemsRemoved: localRecord[Strings.itemsRemoved],
      Strings.patientInformed: localRecord[Strings.patientInformed],
      Strings.injuriesNoted: localRecord[Strings.injuriesNoted],
      Strings.bodyMapImage: localRecord[Strings.bodyMapImage],
      Strings.medicalAttentionYes: localRecord[Strings.medicalAttentionYes],
      Strings.medicalAttentionNo: localRecord[Strings.medicalAttentionNo],
      Strings.relevantInformationYes: localRecord[Strings.relevantInformationYes],
      Strings.relevantInformationNo: localRecord[Strings.relevantInformationNo],
      Strings.medicalAttention: localRecord[Strings.medicalAttention],
      Strings.currentMedication: localRecord[Strings.currentMedication],
      Strings.physicalObservations: localRecord[Strings.physicalObservations],
      Strings.relevantInformation: localRecord[Strings.relevantInformation],
      Strings.patientReport: localRecord[Strings.patientReport],
      Strings.patientReportPrintName: localRecord[Strings.patientReportPrintName],
      Strings.patientReportRole: localRecord[Strings.patientReportRole],
      Strings.patientReportDate: localRecord[Strings.patientReportDate],
      Strings.patientReportTime: localRecord[Strings.patientReportTime],
      Strings.patientReportSignature: localRecord[Strings.patientReportSignature],
      Strings.handcuffsUsedYes: localRecord[Strings.handcuffsUsedYes],
      Strings.handcuffsUsedNo: localRecord[Strings.handcuffsUsedNo],
      Strings.handcuffsDate: localRecord[Strings.handcuffsDate],
      Strings.handcuffsTime: localRecord[Strings.handcuffsTime],
      Strings.handcuffsAuthorisedBy: localRecord[Strings.handcuffsAuthorisedBy],
      Strings.handcuffsAppliedBy: localRecord[Strings.handcuffsAppliedBy],
      Strings.handcuffsRemovedTime: localRecord[Strings.handcuffsRemovedTime],
      Strings.physicalInterventionYes: localRecord[Strings.physicalInterventionYes],
      Strings.physicalInterventionNo: localRecord[Strings.physicalInterventionNo],
      Strings.physicalIntervention: localRecord[Strings.physicalIntervention],
      Strings.whyInterventionRequired: localRecord[Strings.whyInterventionRequired],
      Strings.techniqueName1: localRecord[Strings.techniqueName1],
      Strings.techniqueName2: localRecord[Strings.techniqueName2],
      Strings.techniqueName3: localRecord[Strings.techniqueName3],
      Strings.techniqueName4: localRecord[Strings.techniqueName4],
      Strings.techniqueName5: localRecord[Strings.techniqueName5],
      Strings.techniqueName6: localRecord[Strings.techniqueName6],
      Strings.techniqueName7: localRecord[Strings.techniqueName7],
      Strings.techniqueName8: localRecord[Strings.techniqueName8],
      Strings.techniqueName9: localRecord[Strings.techniqueName9],
      Strings.techniqueName10: localRecord[Strings.techniqueName10],
      Strings.technique1: localRecord[Strings.technique1],
      Strings.technique2: localRecord[Strings.technique2],
      Strings.technique3: localRecord[Strings.technique3],
      Strings.technique4: localRecord[Strings.technique4],
      Strings.technique5: localRecord[Strings.technique5],
      Strings.technique6: localRecord[Strings.technique6],
      Strings.technique7: localRecord[Strings.technique7],
      Strings.technique8: localRecord[Strings.technique8],
      Strings.technique9: localRecord[Strings.technique9],
      Strings.technique10: localRecord[Strings.technique10],
      Strings.techniquePosition1: localRecord[Strings.techniquePosition1],
      Strings.techniquePosition2: localRecord[Strings.techniquePosition2],
      Strings.techniquePosition3: localRecord[Strings.techniquePosition3],
      Strings.techniquePosition4: localRecord[Strings.techniquePosition4],
      Strings.techniquePosition5: localRecord[Strings.techniquePosition5],
      Strings.techniquePosition6: localRecord[Strings.techniquePosition6],
      Strings.techniquePosition7: localRecord[Strings.techniquePosition7],
      Strings.techniquePosition8: localRecord[Strings.techniquePosition8],
      Strings.techniquePosition9: localRecord[Strings.techniquePosition9],
      Strings.techniquePosition10: localRecord[Strings.techniquePosition10],
      Strings.timeInterventionCommenced: localRecord[Strings.timeInterventionCommenced],
      Strings.timeInterventionCompleted: localRecord[Strings.timeInterventionCompleted],
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
      Strings.hasSection2Checklist: localRecord[Strings.hasSection2Checklist],
      Strings.hasSection3Checklist: localRecord[Strings.hasSection3Checklist],
      Strings.hasSection3TransferChecklist: localRecord[Strings.hasSection3TransferChecklist],
      Strings.transferInPatientName1: localRecord[Strings.transferInPatientName1],
      Strings.patientCorrectYes1: localRecord[Strings.patientCorrectYes1],
      Strings.patientCorrectNo1: localRecord[Strings.patientCorrectNo1],
      Strings.hospitalCorrectYes1: localRecord[Strings.hospitalCorrectYes1],
      Strings.hospitalCorrectNo1: localRecord[Strings.hospitalCorrectNo1],
      Strings.applicationFormYes1: localRecord[Strings.applicationFormYes1],
      Strings.applicationFormNo1: localRecord[Strings.applicationFormNo1],
      Strings.applicationSignedYes1: localRecord[Strings.applicationSignedYes1],
      Strings.applicationSignedNo1: localRecord[Strings.applicationSignedNo1],
      Strings.within14DaysYes1: localRecord[Strings.within14DaysYes1],
      Strings.within14DaysNo1: localRecord[Strings.within14DaysNo1],
      Strings.localAuthorityNameYes1: localRecord[Strings.localAuthorityNameYes1],
      Strings.localAuthorityNameNo1: localRecord[Strings.localAuthorityNameNo1],
      Strings.medicalRecommendationsFormYes1: localRecord[Strings.medicalRecommendationsFormYes1],
      Strings.medicalRecommendationsFormNo1: localRecord[Strings.medicalRecommendationsFormNo1],
      Strings.medicalRecommendationsSignedYes1: localRecord[Strings.medicalRecommendationsSignedYes1],
      Strings.medicalRecommendationsSignedNo1: localRecord[Strings.medicalRecommendationsSignedNo1],
      Strings.datesSignatureSignedYes: localRecord[Strings.datesSignatureSignedYes],
      Strings.datesSignatureSignedNo: localRecord[Strings.datesSignatureSignedNo],
      Strings.signatureDatesOnBeforeYes1: localRecord[Strings.signatureDatesOnBeforeYes1],
      Strings.signatureDatesOnBeforeNo1: localRecord[Strings.signatureDatesOnBeforeNo1],
      Strings.practitionersNameYes1: localRecord[Strings.practitionersNameYes1],
      Strings.practitionersNameNo1: localRecord[Strings.practitionersNameNo1],
      Strings.transferInCheckedBy1: localRecord[Strings.transferInCheckedBy1],
      Strings.transferInDate1: localRecord[Strings.transferInDate1],
      Strings.transferInDesignation1: localRecord[Strings.transferInDesignation1],
      Strings.transferInSignature1: localRecord[Strings.transferInSignature1],
      Strings.transferInPatientName2: localRecord[Strings.transferInPatientName2],
      Strings.patientCorrectYes2: localRecord[Strings.patientCorrectYes2],
      Strings.patientCorrectNo2: localRecord[Strings.patientCorrectNo2],
      Strings.hospitalCorrectYes2: localRecord[Strings.hospitalCorrectYes2],
      Strings.hospitalCorrectNo2: localRecord[Strings.hospitalCorrectNo2],
      Strings.applicationFormYes2: localRecord[Strings.applicationFormYes2],
      Strings.applicationFormNo2: localRecord[Strings.applicationFormNo2],
      Strings.applicationSignedYes2: localRecord[Strings.applicationSignedYes2],
      Strings.applicationSignedNo2: localRecord[Strings.applicationSignedNo2],
      Strings.amhpIdentifiedYes: localRecord[Strings.amhpIdentifiedYes],
      Strings.amhpIdentifiedNo: localRecord[Strings.amhpIdentifiedNo],
      Strings.medicalRecommendationsFormYes2: localRecord[Strings.medicalRecommendationsFormYes2],
      Strings.medicalRecommendationsFormNo2: localRecord[Strings.medicalRecommendationsFormNo2],
      Strings.medicalRecommendationsSignedYes2: localRecord[Strings.medicalRecommendationsSignedYes2],
      Strings.medicalRecommendationsSignedNo2: localRecord[Strings.medicalRecommendationsSignedNo2],
      Strings.clearDaysYes2: localRecord[Strings.clearDaysYes2],
      Strings.clearDaysNo2: localRecord[Strings.clearDaysNo2],
      Strings.signatureDatesOnBeforeYes2: localRecord[Strings.signatureDatesOnBeforeYes2],
      Strings.signatureDatesOnBeforeNo2: localRecord[Strings.signatureDatesOnBeforeNo2],
      Strings.practitionersNameYes2: localRecord[Strings.practitionersNameYes2],
      Strings.practitionersNameNo2: localRecord[Strings.practitionersNameNo2],
      Strings.doctorsAgreeYes: localRecord[Strings.doctorsAgreeYes],
      Strings.doctorsAgreeNo: localRecord[Strings.doctorsAgreeNo],
      Strings.separateMedicalRecommendationsYes: localRecord[Strings.separateMedicalRecommendationsYes],
      Strings.separateMedicalRecommendationsNo: localRecord[Strings.separateMedicalRecommendationsNo],
      Strings.transferInCheckedBy2: localRecord[Strings.transferInCheckedBy2],
      Strings.transferInDate2: localRecord[Strings.transferInDate2],
      Strings.transferInDesignation2: localRecord[Strings.transferInDesignation2],
      Strings.transferInSignature2: localRecord[Strings.transferInSignature2],
      Strings.transferInPatientName3: localRecord[Strings.transferInPatientName3],
      Strings.patientCorrectYes3: localRecord[Strings.patientCorrectYes3],
      Strings.patientCorrectNo3: localRecord[Strings.patientCorrectNo3],
      Strings.hospitalCorrectYes3: localRecord[Strings.hospitalCorrectYes3],
      Strings.hospitalCorrectNo3: localRecord[Strings.hospitalCorrectNo3],
      Strings.h4Yes: localRecord[Strings.h4Yes],
      Strings.h4No: localRecord[Strings.h4No],
      Strings.currentConsentYes: localRecord[Strings.currentConsentYes],
      Strings.currentConsentNo: localRecord[Strings.currentConsentNo],
      Strings.applicationFormYes3: localRecord[Strings.applicationFormYes3],
      Strings.applicationFormNo3: localRecord[Strings.applicationFormNo3],
      Strings.applicationSignedYes3: localRecord[Strings.applicationSignedYes3],
      Strings.applicationSignedNo3: localRecord[Strings.applicationSignedNo3],
      Strings.within14DaysYes3: localRecord[Strings.within14DaysYes3],
      Strings.within14DaysNo3: localRecord[Strings.within14DaysNo3],
      Strings.localAuthorityNameYes3: localRecord[Strings.localAuthorityNameYes3],
      Strings.localAuthorityNameNo3: localRecord[Strings.localAuthorityNameNo3],
      Strings.nearestRelativeYes: localRecord[Strings.nearestRelativeYes],
      Strings.nearestRelativeNo: localRecord[Strings.nearestRelativeNo],
      Strings.amhpConsultationYes: localRecord[Strings.amhpConsultationYes],
      Strings.amhpConsultationNo: localRecord[Strings.amhpConsultationNo],
      Strings.knewPatientYes: localRecord[Strings.knewPatientYes],
      Strings.knewPatientNo: localRecord[Strings.knewPatientNo],
      Strings.medicalRecommendationsFormYes3: localRecord[Strings.medicalRecommendationsFormYes3],
      Strings.medicalRecommendationsFormNo3: localRecord[Strings.medicalRecommendationsFormNo3],
      Strings.medicalRecommendationsSignedYes3: localRecord[Strings.medicalRecommendationsSignedYes3],
      Strings.medicalRecommendationsSignedNo3: localRecord[Strings.medicalRecommendationsSignedNo3],
      Strings.clearDaysYes3: localRecord[Strings.clearDaysYes3],
      Strings.clearDaysNo3: localRecord[Strings.clearDaysNo3],
      Strings.approvedSection12Yes: localRecord[Strings.approvedSection12Yes],
      Strings.approvedSection12No: localRecord[Strings.approvedSection12No],
      Strings.signatureDatesOnBeforeYes3: localRecord[Strings.signatureDatesOnBeforeYes3],
      Strings.signatureDatesOnBeforeNo3: localRecord[Strings.signatureDatesOnBeforeNo3],
      Strings.practitionersNameYes3: localRecord[Strings.practitionersNameYes3],
      Strings.practitionersNameNo3: localRecord[Strings.practitionersNameNo3],
      Strings.previouslyAcquaintedYes: localRecord[Strings.previouslyAcquaintedYes],
      Strings.previouslyAcquaintedNo: localRecord[Strings.previouslyAcquaintedNo],
      Strings.acquaintedIfNoYes: localRecord[Strings.acquaintedIfNoYes],
      Strings.acquaintedIfNoNo: localRecord[Strings.acquaintedIfNoNo],
      Strings.recommendationsDifferentTeamsYes: localRecord[Strings.recommendationsDifferentTeamsYes],
      Strings.recommendationsDifferentTeamsNo: localRecord[Strings.recommendationsDifferentTeamsNo],
      Strings.originalDetentionPapersYes: localRecord[Strings.originalDetentionPapersYes],
      Strings.originalDetentionPapersNo: localRecord[Strings.originalDetentionPapersNo],
      Strings.transferInCheckedBy3: localRecord[Strings.transferInCheckedBy3],
      Strings.transferInDate3: localRecord[Strings.transferInDate3],
      Strings.transferInDesignation3: localRecord[Strings.transferInDesignation3],
      Strings.transferInSignature3: localRecord[Strings.transferInSignature3],
      Strings.feltSafeYes: localRecord[Strings.feltSafeYes],
      Strings.feltSafeNo: localRecord[Strings.feltSafeNo],
      Strings.staffIntroducedYes: localRecord[Strings.staffIntroducedYes],
      Strings.staffIntroducedNo: localRecord[Strings.staffIntroducedNo],
      Strings.experiencePositiveYes: localRecord[Strings.experiencePositiveYes],
      Strings.experiencePositiveNo: localRecord[Strings.experiencePositiveNo],
      Strings.otherComments: localRecord[Strings.otherComments],
      Strings.vehicleCompletedBy1: localRecord[Strings.vehicleCompletedBy1],
      Strings.vehicleDate: localRecord[Strings.vehicleDate],
      Strings.vehicleTime: localRecord[Strings.vehicleTime],
      Strings.ambulanceReg: localRecord[Strings.ambulanceReg],
      Strings.vehicleStartMileage: localRecord[Strings.vehicleStartMileage],
      Strings.nearestTank1: localRecord[Strings.nearestTank1],
      Strings.ambulanceTidyYes1: localRecord[Strings.ambulanceTidyYes1],
      Strings.ambulanceTidyNo1: localRecord[Strings.ambulanceTidyNo1],
      Strings.lightsWorkingYes: localRecord[Strings.lightsWorkingYes],
      Strings.lightsWorkingNo: localRecord[Strings.lightsWorkingNo],
      Strings.tyresInflatedYes: localRecord[Strings.tyresInflatedYes],
      Strings.tyresInflatedNo: localRecord[Strings.tyresInflatedNo],
      Strings.warningSignsYes: localRecord[Strings.warningSignsYes],
      Strings.warningSignsNo: localRecord[Strings.warningSignsNo],
      Strings.vehicleCompletedBy2: localRecord[Strings.vehicleCompletedBy2],
      Strings.nearestTank2: localRecord[Strings.nearestTank2],
      Strings.vehicleFinishMileage: localRecord[Strings.vehicleFinishMileage],
      Strings.ambulanceTidyYes2: localRecord[Strings.ambulanceTidyYes2],
      Strings.ambulanceTidyNo2: localRecord[Strings.ambulanceTidyNo2],
      Strings.sanitiserCleanYes: localRecord[Strings.sanitiserCleanYes],
      Strings.sanitiserCleanNo: localRecord[Strings.sanitiserCleanNo],
      Strings.issuesFaults: localRecord[Strings.issuesFaults],
      Strings.serverUploaded: localRecord[Strings.serverUploaded],
      Strings.timestamp: localRecord[Strings.timestamp] == null ? null : localRecord[Strings.timestamp]
    };
  }

  Map<String, dynamic> onlineTransferReport(Map<String, dynamic> localRecord, String docId, Uint8List incidentSignature, Uint8List collectionSignature, Uint8List destinationSignature, Uint8List bodyMapImage, Uint8List patientReportSignature, Uint8List transferInSignature1, Uint8List transferInSignature2, Uint8List transferInSignature3){
    return {
      Strings.documentId: docId,
      Strings.uid: GlobalFunctions.databaseValueString(localRecord[Strings.uid]),
      Strings.jobId: localRecord[Strings.jobId],
      Strings.formVersion: localRecord[Strings.formVersion],
      Strings.jobRef: localRecord[Strings.jobRef],
      Strings.date: localRecord[Strings.date] == null ? null : DateTime
          .fromMillisecondsSinceEpoch(
          localRecord[Strings.date].millisecondsSinceEpoch)
          .toIso8601String(),
      Strings.startTime: localRecord[Strings.startTime],
      Strings.finishTime: localRecord[Strings.finishTime],
      Strings.totalHours: localRecord[Strings.totalHours],
      Strings.collectionDetails: localRecord[Strings.collectionDetails],
      Strings.collectionPostcode: localRecord[Strings.collectionPostcode],
      Strings.collectionContactNo: localRecord[Strings.collectionContactNo],
      Strings.destinationDetails: localRecord[Strings.destinationDetails],
      Strings.destinationPostcode: localRecord[Strings.destinationPostcode],
      Strings.destinationContactNo: localRecord[Strings.destinationContactNo],
      Strings.collectionArrivalTime: localRecord[Strings.collectionArrivalTime],
      Strings.collectionDepartureTime: localRecord[Strings.collectionDepartureTime],
      Strings.destinationArrivalTime: localRecord[Strings.destinationArrivalTime],
      Strings.destinationDepartureTime: localRecord[Strings.destinationDepartureTime],
      Strings.vehicleRegNo: localRecord[Strings.vehicleRegNo],
      Strings.startMileage: localRecord[Strings.startMileage],
      Strings.finishMileage: localRecord[Strings.finishMileage],
      Strings.totalMileage: localRecord[Strings.totalMileage],
      Strings.name1: localRecord[Strings.name1],
      Strings.role1: localRecord[Strings.role1],
      Strings.drivingTimes1_1: localRecord[Strings.drivingTimes1_1],
      Strings.drivingTimes1_2: localRecord[Strings.drivingTimes1_2],
      Strings.name2: localRecord[Strings.name2],
      Strings.role2: localRecord[Strings.role2],
      Strings.drivingTimes2_1: localRecord[Strings.drivingTimes2_1],
      Strings.drivingTimes2_2: localRecord[Strings.drivingTimes2_2],
      Strings.name3: localRecord[Strings.name3],
      Strings.role3: localRecord[Strings.role3],
      Strings.drivingTimes3_1: localRecord[Strings.drivingTimes3_1],
      Strings.drivingTimes3_2: localRecord[Strings.drivingTimes3_2],
      Strings.name4: localRecord[Strings.name4],
      Strings.role4: localRecord[Strings.role4],
      Strings.drivingTimes4_1: localRecord[Strings.drivingTimes4_1],
      Strings.drivingTimes4_2: localRecord[Strings.drivingTimes4_2],
      Strings.name5: localRecord[Strings.name5],
      Strings.role5: localRecord[Strings.role5],
      Strings.drivingTimes5_1: localRecord[Strings.drivingTimes5_1],
      Strings.drivingTimes5_2: localRecord[Strings.drivingTimes5_2],
      Strings.name6: localRecord[Strings.name6],
      Strings.role6: localRecord[Strings.role6],
      Strings.drivingTimes6_1: localRecord[Strings.drivingTimes6_1],
      Strings.drivingTimes6_2: localRecord[Strings.drivingTimes6_2],
      Strings.name7: localRecord[Strings.name7],
      Strings.role7: localRecord[Strings.role7],
      Strings.drivingTimes7_1: localRecord[Strings.drivingTimes7_1],
      Strings.drivingTimes7_2: localRecord[Strings.drivingTimes7_2],
      Strings.name8: localRecord[Strings.name8],
      Strings.role8: localRecord[Strings.role8],
      Strings.drivingTimes8_1: localRecord[Strings.drivingTimes8_1],
      Strings.drivingTimes8_2: localRecord[Strings.drivingTimes8_2],
      Strings.name9: localRecord[Strings.name9],
      Strings.role9: localRecord[Strings.role9],
      Strings.drivingTimes9_1: localRecord[Strings.drivingTimes9_1],
      Strings.drivingTimes9_2: localRecord[Strings.drivingTimes9_2],
      Strings.name10: localRecord[Strings.name10],
      Strings.role10: localRecord[Strings.role10],
      Strings.drivingTimes10_1: localRecord[Strings.drivingTimes10_1],
      Strings.drivingTimes10_2: localRecord[Strings.drivingTimes10_2],
      Strings.name11: localRecord[Strings.name11],
      Strings.role11: localRecord[Strings.role11],
      Strings.drivingTimes11_1: localRecord[Strings.drivingTimes11_1],
      Strings.drivingTimes11_2: localRecord[Strings.drivingTimes11_2],
      Strings.collectionUnit: localRecord[Strings.collectionUnit],
      Strings.collectionPosition: localRecord[Strings.collectionPosition],
      Strings.collectionPrintName: localRecord[Strings.collectionPrintName],
      Strings.collectionArrivalTimeEnd: localRecord[Strings.collectionArrivalTimeEnd],
      Strings.collectionSignature: collectionSignature,
      Strings.collectionSignaturePoints: localRecord[Strings.collectionSignaturePoints],
      Strings.destinationUnit: localRecord[Strings.destinationUnit],
      Strings.destinationPosition: localRecord[Strings.destinationPosition],
      Strings.destinationPrintName: localRecord[Strings.destinationPrintName],
      Strings.destinationArrivalTimeEnd: localRecord[Strings.destinationArrivalTimeEnd],
      Strings.destinationSignature: destinationSignature,
      Strings.patientName: localRecord[Strings.patientName],
      Strings.dateOfBirth: localRecord[Strings.dateOfBirth],
      Strings.ethnicity: localRecord[Strings.ethnicity],
      Strings.gender: localRecord[Strings.gender],
      Strings.mhaMcaDetails: localRecord[Strings.mhaMcaDetails],
      Strings.diagnosis: localRecord[Strings.diagnosis],
      Strings.currentPresentation: localRecord[Strings.currentPresentation],
      Strings.riskYes: localRecord[Strings.riskYes],
      Strings.riskNo: localRecord[Strings.riskNo],
      Strings.riskExplanation: localRecord[Strings.riskExplanation],
      Strings.forensicHistoryYes: localRecord[Strings.forensicHistoryYes],
      Strings.forensicHistoryNo: localRecord[Strings.forensicHistoryNo],
      Strings.racialGenderConcernsYes: localRecord[Strings.racialGenderConcernsYes],
      Strings.racialGenderConcernsNo: localRecord[Strings.racialGenderConcernsNo],
      Strings.violenceAggressionYes: localRecord[Strings.violenceAggressionYes],
      Strings.violenceAggressionNo: localRecord[Strings.violenceAggressionNo],
      Strings.selfHarmYes: localRecord[Strings.selfHarmYes],
      Strings.selfHarmNo: localRecord[Strings.selfHarmNo],
      Strings.alcoholSubstanceYes: localRecord[Strings.alcoholSubstanceYes],
      Strings.alcoholSubstanceNo: localRecord[Strings.alcoholSubstanceNo],
      Strings.virusesYes: localRecord[Strings.virusesYes],
      Strings.virusesNo: localRecord[Strings.virusesNo],
      Strings.safeguardingYes: localRecord[Strings.safeguardingYes],
      Strings.safeguardingNo: localRecord[Strings.safeguardingNo],
      Strings.physicalHealthConditionsYes: localRecord[Strings.physicalHealthConditionsYes],
      Strings.physicalHealthConditionsNo: localRecord[Strings.physicalHealthConditionsNo],
      Strings.useOfWeaponYes: localRecord[Strings.useOfWeaponYes],
      Strings.useOfWeaponNo: localRecord[Strings.useOfWeaponNo],
      Strings.absconsionRiskYes: localRecord[Strings.absconsionRiskYes],
      Strings.absconsionRiskNo: localRecord[Strings.absconsionRiskNo],
      Strings.forensicHistory: localRecord[Strings.forensicHistory],
      Strings.racialGenderConcerns: localRecord[Strings.racialGenderConcerns],
      Strings.violenceAggression: localRecord[Strings.violenceAggression],
      Strings.selfHarm: localRecord[Strings.selfHarm],
      Strings.alcoholSubstance: localRecord[Strings.alcoholSubstance],
      Strings.viruses: localRecord[Strings.viruses],
      Strings.safeguarding: localRecord[Strings.safeguarding],
      Strings.physicalHealthConditions: localRecord[Strings.physicalHealthConditions],
      Strings.useOfWeapon: localRecord[Strings.useOfWeapon],
      Strings.absconsionRisk: localRecord[Strings.absconsionRisk],
      Strings.patientPropertyYes: localRecord[Strings.patientPropertyYes],
      Strings.patientPropertyNo: localRecord[Strings.patientPropertyNo],
      Strings.patientPropertyExplanation: localRecord[Strings.patientPropertyExplanation],
      Strings.patientPropertyReceived: localRecord[Strings.patientPropertyReceived],
      Strings.patientPropertyReceivedYes: localRecord[Strings.patientPropertyReceivedYes],
      Strings.patientPropertyReceivedNo: localRecord[Strings.patientPropertyReceivedNo],
      Strings.patientNotesReceived: localRecord[Strings.patientNotesReceived],
      Strings.patientNotesReceivedYes: localRecord[Strings.patientNotesReceivedYes],
      Strings.patientNotesReceivedNo: localRecord[Strings.patientNotesReceivedNo],
      Strings.patientSearched: localRecord[Strings.patientSearched],
      Strings.patientSearchedYes: localRecord[Strings.patientSearchedYes],
      Strings.patientSearchedNo: localRecord[Strings.patientSearchedNo],
      Strings.itemsRemovedYes: localRecord[Strings.itemsRemovedYes],
      Strings.itemsRemovedNo: localRecord[Strings.itemsRemovedNo],
      Strings.itemsRemoved: localRecord[Strings.itemsRemoved],
      Strings.patientInformed: localRecord[Strings.patientInformed],
      Strings.injuriesNoted: localRecord[Strings.injuriesNoted],
      Strings.bodyMapImage: bodyMapImage,
      Strings.medicalAttentionYes: localRecord[Strings.medicalAttentionYes],
      Strings.medicalAttentionNo: localRecord[Strings.medicalAttentionNo],
      Strings.relevantInformationYes: localRecord[Strings.relevantInformationYes],
      Strings.relevantInformationNo: localRecord[Strings.relevantInformationNo],
      Strings.medicalAttention: localRecord[Strings.medicalAttention],
      Strings.currentMedication: localRecord[Strings.currentMedication],
      Strings.physicalObservations: localRecord[Strings.physicalObservations],
      Strings.relevantInformation: localRecord[Strings.relevantInformation],
      Strings.patientReport: localRecord[Strings.patientReport],
      Strings.patientReportPrintName: localRecord[Strings.patientReportPrintName],
      Strings.patientReportRole: localRecord[Strings.patientReportRole],
      Strings.patientReportDate: localRecord[Strings.patientReportDate],
      Strings.patientReportTime: localRecord[Strings.patientReportTime],
      Strings.patientReportSignature: patientReportSignature,
      Strings.handcuffsUsedYes: localRecord[Strings.handcuffsUsedYes],
      Strings.handcuffsUsedNo: localRecord[Strings.handcuffsUsedNo],
      Strings.handcuffsDate: localRecord[Strings.handcuffsDate],
      Strings.handcuffsTime: localRecord[Strings.handcuffsTime],
      Strings.handcuffsAuthorisedBy: localRecord[Strings.handcuffsAuthorisedBy],
      Strings.handcuffsAppliedBy: localRecord[Strings.handcuffsAppliedBy],
      Strings.handcuffsRemovedTime: localRecord[Strings.handcuffsRemovedTime],
      Strings.physicalInterventionYes: localRecord[Strings.physicalInterventionYes],
      Strings.physicalInterventionNo: localRecord[Strings.physicalInterventionNo],
      Strings.physicalIntervention: localRecord[Strings.physicalIntervention],
      Strings.whyInterventionRequired: localRecord[Strings.whyInterventionRequired],
      Strings.techniqueName1: localRecord[Strings.techniqueName1],
      Strings.techniqueName2: localRecord[Strings.techniqueName2],
      Strings.techniqueName3: localRecord[Strings.techniqueName3],
      Strings.techniqueName4: localRecord[Strings.techniqueName4],
      Strings.techniqueName5: localRecord[Strings.techniqueName5],
      Strings.techniqueName6: localRecord[Strings.techniqueName6],
      Strings.techniqueName7: localRecord[Strings.techniqueName7],
      Strings.techniqueName8: localRecord[Strings.techniqueName8],
      Strings.techniqueName9: localRecord[Strings.techniqueName9],
      Strings.techniqueName10: localRecord[Strings.techniqueName10],
      Strings.technique1: localRecord[Strings.technique1],
      Strings.technique2: localRecord[Strings.technique2],
      Strings.technique3: localRecord[Strings.technique3],
      Strings.technique4: localRecord[Strings.technique4],
      Strings.technique5: localRecord[Strings.technique5],
      Strings.technique6: localRecord[Strings.technique6],
      Strings.technique7: localRecord[Strings.technique7],
      Strings.technique8: localRecord[Strings.technique8],
      Strings.technique9: localRecord[Strings.technique9],
      Strings.technique10: localRecord[Strings.technique10],
      Strings.techniquePosition1: localRecord[Strings.techniquePosition1],
      Strings.techniquePosition2: localRecord[Strings.techniquePosition2],
      Strings.techniquePosition3: localRecord[Strings.techniquePosition3],
      Strings.techniquePosition4: localRecord[Strings.techniquePosition4],
      Strings.techniquePosition5: localRecord[Strings.techniquePosition5],
      Strings.techniquePosition6: localRecord[Strings.techniquePosition6],
      Strings.techniquePosition7: localRecord[Strings.techniquePosition7],
      Strings.techniquePosition8: localRecord[Strings.techniquePosition8],
      Strings.techniquePosition9: localRecord[Strings.techniquePosition9],
      Strings.techniquePosition10: localRecord[Strings.techniquePosition10],
      Strings.timeInterventionCommenced: localRecord[Strings.timeInterventionCommenced],
      Strings.timeInterventionCompleted: localRecord[Strings.timeInterventionCompleted],
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
      Strings.incidentSignaturePoints: localRecord[Strings.incidentSignaturePoints],
      Strings.incidentSignatureDate: localRecord[Strings.incidentSignatureDate],
      Strings.incidentPrintName: localRecord[Strings.incidentPrintName],
      Strings.hasSection2Checklist: localRecord[Strings.hasSection2Checklist],
      Strings.hasSection3Checklist: localRecord[Strings.hasSection3Checklist],
      Strings.hasSection3TransferChecklist: localRecord[Strings.hasSection3TransferChecklist],
      Strings.transferInPatientName1: localRecord[Strings.transferInPatientName1],
      Strings.patientCorrectYes1: localRecord[Strings.patientCorrectYes1],
      Strings.patientCorrectNo1: localRecord[Strings.patientCorrectNo1],
      Strings.hospitalCorrectYes1: localRecord[Strings.hospitalCorrectYes1],
      Strings.hospitalCorrectNo1: localRecord[Strings.hospitalCorrectNo1],
      Strings.applicationFormYes1: localRecord[Strings.applicationFormYes1],
      Strings.applicationFormNo1: localRecord[Strings.applicationFormNo1],
      Strings.applicationSignedYes1: localRecord[Strings.applicationSignedYes1],
      Strings.applicationSignedNo1: localRecord[Strings.applicationSignedNo1],
      Strings.within14DaysYes1: localRecord[Strings.within14DaysYes1],
      Strings.within14DaysNo1: localRecord[Strings.within14DaysNo1],
      Strings.localAuthorityNameYes1: localRecord[Strings.localAuthorityNameYes1],
      Strings.localAuthorityNameNo1: localRecord[Strings.localAuthorityNameNo1],
      Strings.medicalRecommendationsFormYes1: localRecord[Strings.medicalRecommendationsFormYes1],
      Strings.medicalRecommendationsFormNo1: localRecord[Strings.medicalRecommendationsFormNo1],
      Strings.medicalRecommendationsSignedYes1: localRecord[Strings.medicalRecommendationsSignedYes1],
      Strings.medicalRecommendationsSignedNo1: localRecord[Strings.medicalRecommendationsSignedNo1],
      Strings.datesSignatureSignedYes: localRecord[Strings.datesSignatureSignedYes],
      Strings.datesSignatureSignedNo: localRecord[Strings.datesSignatureSignedNo],
      Strings.signatureDatesOnBeforeYes1: localRecord[Strings.signatureDatesOnBeforeYes1],
      Strings.signatureDatesOnBeforeNo1: localRecord[Strings.signatureDatesOnBeforeNo1],
      Strings.practitionersNameYes1: localRecord[Strings.practitionersNameYes1],
      Strings.practitionersNameNo1: localRecord[Strings.practitionersNameNo1],
      Strings.transferInCheckedBy1: localRecord[Strings.transferInCheckedBy1],
      Strings.transferInDate1: localRecord[Strings.transferInDate1],
      Strings.transferInDesignation1: localRecord[Strings.transferInDesignation1],
      Strings.transferInSignature1: transferInSignature1,
      Strings.transferInPatientName2: localRecord[Strings.transferInPatientName2],
      Strings.patientCorrectYes2: localRecord[Strings.patientCorrectYes2],
      Strings.patientCorrectNo2: localRecord[Strings.patientCorrectNo2],
      Strings.hospitalCorrectYes2: localRecord[Strings.hospitalCorrectYes2],
      Strings.hospitalCorrectNo2: localRecord[Strings.hospitalCorrectNo2],
      Strings.applicationFormYes2: localRecord[Strings.applicationFormYes2],
      Strings.applicationFormNo2: localRecord[Strings.applicationFormNo2],
      Strings.applicationSignedYes2: localRecord[Strings.applicationSignedYes2],
      Strings.applicationSignedNo2: localRecord[Strings.applicationSignedNo2],
      Strings.amhpIdentifiedYes: localRecord[Strings.amhpIdentifiedYes],
      Strings.amhpIdentifiedNo: localRecord[Strings.amhpIdentifiedNo],
      Strings.medicalRecommendationsFormYes2: localRecord[Strings.medicalRecommendationsFormYes2],
      Strings.medicalRecommendationsFormNo2: localRecord[Strings.medicalRecommendationsFormNo2],
      Strings.medicalRecommendationsSignedYes2: localRecord[Strings.medicalRecommendationsSignedYes2],
      Strings.medicalRecommendationsSignedNo2: localRecord[Strings.medicalRecommendationsSignedNo2],
      Strings.clearDaysYes2: localRecord[Strings.clearDaysYes2],
      Strings.clearDaysNo2: localRecord[Strings.clearDaysNo2],
      Strings.signatureDatesOnBeforeYes2: localRecord[Strings.signatureDatesOnBeforeYes2],
      Strings.signatureDatesOnBeforeNo2: localRecord[Strings.signatureDatesOnBeforeNo2],
      Strings.practitionersNameYes2: localRecord[Strings.practitionersNameYes2],
      Strings.practitionersNameNo2: localRecord[Strings.practitionersNameNo2],
      Strings.doctorsAgreeYes: localRecord[Strings.doctorsAgreeYes],
      Strings.doctorsAgreeNo: localRecord[Strings.doctorsAgreeNo],
      Strings.separateMedicalRecommendationsYes: localRecord[Strings.separateMedicalRecommendationsYes],
      Strings.separateMedicalRecommendationsNo: localRecord[Strings.separateMedicalRecommendationsNo],
      Strings.transferInCheckedBy2: localRecord[Strings.transferInCheckedBy2],
      Strings.transferInDate2: localRecord[Strings.transferInDate2],
      Strings.transferInDesignation2: localRecord[Strings.transferInDesignation2],
      Strings.transferInSignature2: transferInSignature2,
      Strings.transferInPatientName3: localRecord[Strings.transferInPatientName3],
      Strings.patientCorrectYes3: localRecord[Strings.patientCorrectYes3],
      Strings.patientCorrectNo3: localRecord[Strings.patientCorrectNo3],
      Strings.hospitalCorrectYes3: localRecord[Strings.hospitalCorrectYes3],
      Strings.hospitalCorrectNo3: localRecord[Strings.hospitalCorrectNo3],
      Strings.h4Yes: localRecord[Strings.h4Yes],
      Strings.h4No: localRecord[Strings.h4No],
      Strings.currentConsentYes: localRecord[Strings.currentConsentYes],
      Strings.currentConsentNo: localRecord[Strings.currentConsentNo],
      Strings.applicationFormYes3: localRecord[Strings.applicationFormYes3],
      Strings.applicationFormNo3: localRecord[Strings.applicationFormNo3],
      Strings.applicationSignedYes3: localRecord[Strings.applicationSignedYes3],
      Strings.applicationSignedNo3: localRecord[Strings.applicationSignedNo3],
      Strings.within14DaysYes3: localRecord[Strings.within14DaysYes3],
      Strings.within14DaysNo3: localRecord[Strings.within14DaysNo3],
      Strings.localAuthorityNameYes3: localRecord[Strings.localAuthorityNameYes3],
      Strings.localAuthorityNameNo3: localRecord[Strings.localAuthorityNameNo3],
      Strings.nearestRelativeYes: localRecord[Strings.nearestRelativeYes],
      Strings.nearestRelativeNo: localRecord[Strings.nearestRelativeNo],
      Strings.amhpConsultationYes: localRecord[Strings.amhpConsultationYes],
      Strings.amhpConsultationNo: localRecord[Strings.amhpConsultationNo],
      Strings.knewPatientYes: localRecord[Strings.knewPatientYes],
      Strings.knewPatientNo: localRecord[Strings.knewPatientNo],
      Strings.medicalRecommendationsFormYes3: localRecord[Strings.medicalRecommendationsFormYes3],
      Strings.medicalRecommendationsFormNo3: localRecord[Strings.medicalRecommendationsFormNo3],
      Strings.medicalRecommendationsSignedYes3: localRecord[Strings.medicalRecommendationsSignedYes3],
      Strings.medicalRecommendationsSignedNo3: localRecord[Strings.medicalRecommendationsSignedNo3],
      Strings.clearDaysYes3: localRecord[Strings.clearDaysYes3],
      Strings.clearDaysNo3: localRecord[Strings.clearDaysNo3],
      Strings.approvedSection12Yes: localRecord[Strings.approvedSection12Yes],
      Strings.approvedSection12No: localRecord[Strings.approvedSection12No],
      Strings.signatureDatesOnBeforeYes3: localRecord[Strings.signatureDatesOnBeforeYes3],
      Strings.signatureDatesOnBeforeNo3: localRecord[Strings.signatureDatesOnBeforeNo3],
      Strings.practitionersNameYes3: localRecord[Strings.practitionersNameYes3],
      Strings.practitionersNameNo3: localRecord[Strings.practitionersNameNo3],
      Strings.previouslyAcquaintedYes: localRecord[Strings.previouslyAcquaintedYes],
      Strings.previouslyAcquaintedNo: localRecord[Strings.previouslyAcquaintedNo],
      Strings.acquaintedIfNoYes: localRecord[Strings.acquaintedIfNoYes],
      Strings.acquaintedIfNoNo: localRecord[Strings.acquaintedIfNoNo],
      Strings.recommendationsDifferentTeamsYes: localRecord[Strings.recommendationsDifferentTeamsYes],
      Strings.recommendationsDifferentTeamsNo: localRecord[Strings.recommendationsDifferentTeamsNo],
      Strings.originalDetentionPapersYes: localRecord[Strings.originalDetentionPapersYes],
      Strings.originalDetentionPapersNo: localRecord[Strings.originalDetentionPapersNo],
      Strings.transferInCheckedBy3: localRecord[Strings.transferInCheckedBy3],
      Strings.transferInDate3: localRecord[Strings.transferInDate3],
      Strings.transferInDesignation3: localRecord[Strings.transferInDesignation3],
      Strings.transferInSignature3: transferInSignature3,
      Strings.feltSafeYes: localRecord[Strings.feltSafeYes],
      Strings.feltSafeNo: localRecord[Strings.feltSafeNo],
      Strings.staffIntroducedYes: localRecord[Strings.staffIntroducedYes],
      Strings.staffIntroducedNo: localRecord[Strings.staffIntroducedNo],
      Strings.experiencePositiveYes: localRecord[Strings.experiencePositiveYes],
      Strings.experiencePositiveNo: localRecord[Strings.experiencePositiveNo],
      Strings.otherComments: localRecord[Strings.otherComments],
      Strings.vehicleCompletedBy1: localRecord[Strings.vehicleCompletedBy1],
      Strings.vehicleDate: localRecord[Strings.vehicleDate],
      Strings.vehicleTime: localRecord[Strings.vehicleTime],
      Strings.ambulanceReg: localRecord[Strings.ambulanceReg],
      Strings.vehicleStartMileage: localRecord[Strings.vehicleStartMileage],
      Strings.nearestTank1: localRecord[Strings.nearestTank1],
      Strings.ambulanceTidyYes1: localRecord[Strings.ambulanceTidyYes1],
      Strings.ambulanceTidyNo1: localRecord[Strings.ambulanceTidyNo1],
      Strings.lightsWorkingYes: localRecord[Strings.lightsWorkingYes],
      Strings.lightsWorkingNo: localRecord[Strings.lightsWorkingNo],
      Strings.tyresInflatedYes: localRecord[Strings.tyresInflatedYes],
      Strings.tyresInflatedNo: localRecord[Strings.tyresInflatedNo],
      Strings.warningSignsYes: localRecord[Strings.warningSignsYes],
      Strings.warningSignsNo: localRecord[Strings.warningSignsNo],
      Strings.vehicleCompletedBy2: localRecord[Strings.vehicleCompletedBy2],
      Strings.nearestTank2: localRecord[Strings.nearestTank2],
      Strings.vehicleFinishMileage: localRecord[Strings.vehicleFinishMileage],
      Strings.ambulanceTidyYes2: localRecord[Strings.ambulanceTidyYes2],
      Strings.ambulanceTidyNo2: localRecord[Strings.ambulanceTidyNo2],
      Strings.sanitiserCleanYes: localRecord[Strings.sanitiserCleanYes],
      Strings.sanitiserCleanNo: localRecord[Strings.sanitiserCleanNo],
      Strings.issuesFaults: localRecord[Strings.issuesFaults],
      Strings.serverUploaded: localRecord[Strings.serverUploaded],
      Strings.timestamp: localRecord[Strings.timestamp] == null ? null : DateTime
          .fromMillisecondsSinceEpoch(
          localRecord['timestamp'].millisecondsSinceEpoch)
          .toIso8601String()
    };
  }

  Map<String, dynamic> editedTransferReport(Map<String, dynamic> localRecord){
    return {
      Strings.documentId: GlobalFunctions.databaseValueString(localRecord[Strings.documentId]),
      Strings.uid: GlobalFunctions.databaseValueString(localRecord[Strings.uid]),
      Strings.jobId: localRecord[Strings.jobId],
      Strings.formVersion: localRecord[Strings.formVersion],
      Strings.jobRef: localRecord[Strings.jobRef],
      Strings.date: localRecord[Strings.date],
      Strings.startTime: localRecord[Strings.startTime],
      Strings.finishTime: localRecord[Strings.finishTime],
      Strings.totalHours: localRecord[Strings.totalHours],
      Strings.collectionDetails: localRecord[Strings.collectionDetails],
      Strings.collectionPostcode: localRecord[Strings.collectionPostcode],
      Strings.collectionContactNo: localRecord[Strings.collectionContactNo],
      Strings.destinationDetails: localRecord[Strings.destinationDetails],
      Strings.destinationPostcode: localRecord[Strings.destinationPostcode],
      Strings.destinationContactNo: localRecord[Strings.destinationContactNo],
      Strings.collectionArrivalTime: localRecord[Strings.collectionArrivalTime],
      Strings.collectionDepartureTime: localRecord[Strings.collectionDepartureTime],
      Strings.destinationArrivalTime: localRecord[Strings.destinationArrivalTime],
      Strings.destinationDepartureTime: localRecord[Strings.destinationDepartureTime],
      Strings.vehicleRegNo: localRecord[Strings.vehicleRegNo],
      Strings.startMileage: localRecord[Strings.startMileage],
      Strings.finishMileage: localRecord[Strings.finishMileage],
      Strings.totalMileage: localRecord[Strings.totalMileage],
      Strings.name1: localRecord[Strings.name1],
      Strings.role1: localRecord[Strings.role1],
      Strings.drivingTimes1_1: localRecord[Strings.drivingTimes1_1],
      Strings.drivingTimes1_2: localRecord[Strings.drivingTimes1_2],
      Strings.name2: localRecord[Strings.name2],
      Strings.role2: localRecord[Strings.role2],
      Strings.drivingTimes2_1: localRecord[Strings.drivingTimes2_1],
      Strings.drivingTimes2_2: localRecord[Strings.drivingTimes2_2],
      Strings.name3: localRecord[Strings.name3],
      Strings.role3: localRecord[Strings.role3],
      Strings.drivingTimes3_1: localRecord[Strings.drivingTimes3_1],
      Strings.drivingTimes3_2: localRecord[Strings.drivingTimes3_2],
      Strings.name4: localRecord[Strings.name4],
      Strings.role4: localRecord[Strings.role4],
      Strings.drivingTimes4_1: localRecord[Strings.drivingTimes4_1],
      Strings.drivingTimes4_2: localRecord[Strings.drivingTimes4_2],
      Strings.name5: localRecord[Strings.name5],
      Strings.role5: localRecord[Strings.role5],
      Strings.drivingTimes5_1: localRecord[Strings.drivingTimes5_1],
      Strings.drivingTimes5_2: localRecord[Strings.drivingTimes5_2],
      Strings.name6: localRecord[Strings.name6],
      Strings.role6: localRecord[Strings.role6],
      Strings.drivingTimes6_1: localRecord[Strings.drivingTimes6_1],
      Strings.drivingTimes6_2: localRecord[Strings.drivingTimes6_2],
      Strings.name7: localRecord[Strings.name7],
      Strings.role7: localRecord[Strings.role7],
      Strings.drivingTimes7_1: localRecord[Strings.drivingTimes7_1],
      Strings.drivingTimes7_2: localRecord[Strings.drivingTimes7_2],
      Strings.name8: localRecord[Strings.name8],
      Strings.role8: localRecord[Strings.role8],
      Strings.drivingTimes8_1: localRecord[Strings.drivingTimes8_1],
      Strings.drivingTimes8_2: localRecord[Strings.drivingTimes8_2],
      Strings.name9: localRecord[Strings.name9],
      Strings.role9: localRecord[Strings.role9],
      Strings.drivingTimes9_1: localRecord[Strings.drivingTimes9_1],
      Strings.drivingTimes9_2: localRecord[Strings.drivingTimes9_2],
      Strings.name10: localRecord[Strings.name10],
      Strings.role10: localRecord[Strings.role10],
      Strings.drivingTimes10_1: localRecord[Strings.drivingTimes10_1],
      Strings.drivingTimes10_2: localRecord[Strings.drivingTimes10_2],
      Strings.name11: localRecord[Strings.name11],
      Strings.role11: localRecord[Strings.role11],
      Strings.drivingTimes11_1: localRecord[Strings.drivingTimes11_1],
      Strings.drivingTimes11_2: localRecord[Strings.drivingTimes11_2],
      Strings.collectionUnit: localRecord[Strings.collectionUnit],
      Strings.collectionPosition: localRecord[Strings.collectionPosition],
      Strings.collectionPrintName: localRecord[Strings.collectionPrintName],
      Strings.collectionArrivalTimeEnd: localRecord[Strings.collectionArrivalTimeEnd],
      Strings.collectionSignature: localRecord[Strings.collectionSignature],
      Strings.collectionSignaturePoints: localRecord[Strings.collectionSignaturePoints],
      Strings.destinationUnit: localRecord[Strings.destinationUnit],
      Strings.destinationPosition: localRecord[Strings.destinationPosition],
      Strings.destinationPrintName: localRecord[Strings.destinationPrintName],
      Strings.destinationArrivalTimeEnd: localRecord[Strings.destinationArrivalTimeEnd],
      Strings.destinationSignature: localRecord[Strings.destinationSignature],
      Strings.patientName: localRecord[Strings.patientName],
      Strings.dateOfBirth: localRecord[Strings.dateOfBirth],
      Strings.ethnicity: localRecord[Strings.ethnicity],
      Strings.gender: localRecord[Strings.gender],
      Strings.mhaMcaDetails: localRecord[Strings.mhaMcaDetails],
      Strings.diagnosis: localRecord[Strings.diagnosis],
      Strings.currentPresentation: localRecord[Strings.currentPresentation],
      Strings.riskYes: localRecord[Strings.riskYes],
      Strings.riskNo: localRecord[Strings.riskNo],
      Strings.riskExplanation: localRecord[Strings.riskExplanation],
      Strings.forensicHistoryYes: localRecord[Strings.forensicHistoryYes],
      Strings.forensicHistoryNo: localRecord[Strings.forensicHistoryNo],
      Strings.racialGenderConcernsYes: localRecord[Strings.racialGenderConcernsYes],
      Strings.racialGenderConcernsNo: localRecord[Strings.racialGenderConcernsNo],
      Strings.violenceAggressionYes: localRecord[Strings.violenceAggressionYes],
      Strings.violenceAggressionNo: localRecord[Strings.violenceAggressionNo],
      Strings.selfHarmYes: localRecord[Strings.selfHarmYes],
      Strings.selfHarmNo: localRecord[Strings.selfHarmNo],
      Strings.alcoholSubstanceYes: localRecord[Strings.alcoholSubstanceYes],
      Strings.alcoholSubstanceNo: localRecord[Strings.alcoholSubstanceNo],
      Strings.virusesYes: localRecord[Strings.virusesYes],
      Strings.virusesNo: localRecord[Strings.virusesNo],
      Strings.safeguardingYes: localRecord[Strings.safeguardingYes],
      Strings.safeguardingNo: localRecord[Strings.safeguardingNo],
      Strings.physicalHealthConditionsYes: localRecord[Strings.physicalHealthConditionsYes],
      Strings.physicalHealthConditionsNo: localRecord[Strings.physicalHealthConditionsNo],
      Strings.useOfWeaponYes: localRecord[Strings.useOfWeaponYes],
      Strings.useOfWeaponNo: localRecord[Strings.useOfWeaponNo],
      Strings.absconsionRiskYes: localRecord[Strings.absconsionRiskYes],
      Strings.absconsionRiskNo: localRecord[Strings.absconsionRiskNo],
      Strings.forensicHistory: localRecord[Strings.forensicHistory],
      Strings.racialGenderConcerns: localRecord[Strings.racialGenderConcerns],
      Strings.violenceAggression: localRecord[Strings.violenceAggression],
      Strings.selfHarm: localRecord[Strings.selfHarm],
      Strings.alcoholSubstance: localRecord[Strings.alcoholSubstance],
      Strings.viruses: localRecord[Strings.viruses],
      Strings.safeguarding: localRecord[Strings.safeguarding],
      Strings.physicalHealthConditions: localRecord[Strings.physicalHealthConditions],
      Strings.useOfWeapon: localRecord[Strings.useOfWeapon],
      Strings.absconsionRisk: localRecord[Strings.absconsionRisk],
      Strings.patientPropertyYes: localRecord[Strings.patientPropertyYes],
      Strings.patientPropertyNo: localRecord[Strings.patientPropertyNo],
      Strings.patientPropertyExplanation: localRecord[Strings.patientPropertyExplanation],
      Strings.patientPropertyReceived: localRecord[Strings.patientPropertyReceived],
      Strings.patientPropertyReceivedYes: localRecord[Strings.patientPropertyReceivedYes],
      Strings.patientPropertyReceivedNo: localRecord[Strings.patientPropertyReceivedNo],
      Strings.patientNotesReceived: localRecord[Strings.patientNotesReceived],
      Strings.patientNotesReceivedYes: localRecord[Strings.patientNotesReceivedYes],
      Strings.patientNotesReceivedNo: localRecord[Strings.patientNotesReceivedNo],
      Strings.patientSearched: localRecord[Strings.patientSearched],
      Strings.patientSearchedYes: localRecord[Strings.patientSearchedYes],
      Strings.patientSearchedNo: localRecord[Strings.patientSearchedNo],
      Strings.itemsRemovedYes: localRecord[Strings.itemsRemovedYes],
      Strings.itemsRemovedNo: localRecord[Strings.itemsRemovedNo],
      Strings.itemsRemoved: localRecord[Strings.itemsRemoved],
      Strings.patientInformed: localRecord[Strings.patientInformed],
      Strings.injuriesNoted: localRecord[Strings.injuriesNoted],
      Strings.bodyMapImage: localRecord[Strings.bodyMapImage],
      Strings.medicalAttentionYes: localRecord[Strings.medicalAttentionYes],
      Strings.medicalAttentionNo: localRecord[Strings.medicalAttentionNo],
      Strings.relevantInformationYes: localRecord[Strings.relevantInformationYes],
      Strings.relevantInformationNo: localRecord[Strings.relevantInformationNo],
      Strings.medicalAttention: localRecord[Strings.medicalAttention],
      Strings.currentMedication: localRecord[Strings.currentMedication],
      Strings.physicalObservations: localRecord[Strings.physicalObservations],
      Strings.relevantInformation: localRecord[Strings.relevantInformation],
      Strings.patientReport: localRecord[Strings.patientReport],
      Strings.patientReportPrintName: localRecord[Strings.patientReportPrintName],
      Strings.patientReportRole: localRecord[Strings.patientReportRole],
      Strings.patientReportDate: localRecord[Strings.patientReportDate],
      Strings.patientReportTime: localRecord[Strings.patientReportTime],
      Strings.patientReportSignature: localRecord[Strings.patientReportSignature],
      Strings.handcuffsUsedYes: localRecord[Strings.handcuffsUsedYes],
      Strings.handcuffsUsedNo: localRecord[Strings.handcuffsUsedNo],
      Strings.handcuffsDate: localRecord[Strings.handcuffsDate],
      Strings.handcuffsTime: localRecord[Strings.handcuffsTime],
      Strings.handcuffsAuthorisedBy: localRecord[Strings.handcuffsAuthorisedBy],
      Strings.handcuffsAppliedBy: localRecord[Strings.handcuffsAppliedBy],
      Strings.handcuffsRemovedTime: localRecord[Strings.handcuffsRemovedTime],
      Strings.physicalInterventionYes: localRecord[Strings.physicalInterventionYes],
      Strings.physicalInterventionNo: localRecord[Strings.physicalInterventionNo],
      Strings.physicalIntervention: localRecord[Strings.physicalIntervention],
      Strings.whyInterventionRequired: localRecord[Strings.whyInterventionRequired],
      Strings.techniqueName1: localRecord[Strings.techniqueName1],
      Strings.techniqueName2: localRecord[Strings.techniqueName2],
      Strings.techniqueName3: localRecord[Strings.techniqueName3],
      Strings.techniqueName4: localRecord[Strings.techniqueName4],
      Strings.techniqueName5: localRecord[Strings.techniqueName5],
      Strings.techniqueName6: localRecord[Strings.techniqueName6],
      Strings.techniqueName7: localRecord[Strings.techniqueName7],
      Strings.techniqueName8: localRecord[Strings.techniqueName8],
      Strings.techniqueName9: localRecord[Strings.techniqueName9],
      Strings.techniqueName10: localRecord[Strings.techniqueName10],
      Strings.technique1: localRecord[Strings.technique1],
      Strings.technique2: localRecord[Strings.technique2],
      Strings.technique3: localRecord[Strings.technique3],
      Strings.technique4: localRecord[Strings.technique4],
      Strings.technique5: localRecord[Strings.technique5],
      Strings.technique6: localRecord[Strings.technique6],
      Strings.technique7: localRecord[Strings.technique7],
      Strings.technique8: localRecord[Strings.technique8],
      Strings.technique9: localRecord[Strings.technique9],
      Strings.technique10: localRecord[Strings.technique10],
      Strings.techniquePosition1: localRecord[Strings.techniquePosition1],
      Strings.techniquePosition2: localRecord[Strings.techniquePosition2],
      Strings.techniquePosition3: localRecord[Strings.techniquePosition3],
      Strings.techniquePosition4: localRecord[Strings.techniquePosition4],
      Strings.techniquePosition5: localRecord[Strings.techniquePosition5],
      Strings.techniquePosition6: localRecord[Strings.techniquePosition6],
      Strings.techniquePosition7: localRecord[Strings.techniquePosition7],
      Strings.techniquePosition8: localRecord[Strings.techniquePosition8],
      Strings.techniquePosition9: localRecord[Strings.techniquePosition9],
      Strings.techniquePosition10: localRecord[Strings.techniquePosition10],
      Strings.timeInterventionCommenced: localRecord[Strings.timeInterventionCommenced],
      Strings.timeInterventionCompleted: localRecord[Strings.timeInterventionCompleted],
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
      Strings.hasSection2Checklist: localRecord[Strings.hasSection2Checklist],
      Strings.hasSection3Checklist: localRecord[Strings.hasSection3Checklist],
      Strings.hasSection3TransferChecklist: localRecord[Strings.hasSection3TransferChecklist],
      Strings.transferInPatientName1: localRecord[Strings.transferInPatientName1],
      Strings.patientCorrectYes1: localRecord[Strings.patientCorrectYes1],
      Strings.patientCorrectNo1: localRecord[Strings.patientCorrectNo1],
      Strings.hospitalCorrectYes1: localRecord[Strings.hospitalCorrectYes1],
      Strings.hospitalCorrectNo1: localRecord[Strings.hospitalCorrectNo1],
      Strings.applicationFormYes1: localRecord[Strings.applicationFormYes1],
      Strings.applicationFormNo1: localRecord[Strings.applicationFormNo1],
      Strings.applicationSignedYes1: localRecord[Strings.applicationSignedYes1],
      Strings.applicationSignedNo1: localRecord[Strings.applicationSignedNo1],
      Strings.within14DaysYes1: localRecord[Strings.within14DaysYes1],
      Strings.within14DaysNo1: localRecord[Strings.within14DaysNo1],
      Strings.localAuthorityNameYes1: localRecord[Strings.localAuthorityNameYes1],
      Strings.localAuthorityNameNo1: localRecord[Strings.localAuthorityNameNo1],
      Strings.medicalRecommendationsFormYes1: localRecord[Strings.medicalRecommendationsFormYes1],
      Strings.medicalRecommendationsFormNo1: localRecord[Strings.medicalRecommendationsFormNo1],
      Strings.medicalRecommendationsSignedYes1: localRecord[Strings.medicalRecommendationsSignedYes1],
      Strings.medicalRecommendationsSignedNo1: localRecord[Strings.medicalRecommendationsSignedNo1],
      Strings.datesSignatureSignedYes: localRecord[Strings.datesSignatureSignedYes],
      Strings.datesSignatureSignedNo: localRecord[Strings.datesSignatureSignedNo],
      Strings.signatureDatesOnBeforeYes1: localRecord[Strings.signatureDatesOnBeforeYes1],
      Strings.signatureDatesOnBeforeNo1: localRecord[Strings.signatureDatesOnBeforeNo1],
      Strings.practitionersNameYes1: localRecord[Strings.practitionersNameYes1],
      Strings.practitionersNameNo1: localRecord[Strings.practitionersNameNo1],
      Strings.transferInCheckedBy1: localRecord[Strings.transferInCheckedBy1],
      Strings.transferInDate1: localRecord[Strings.transferInDate1],
      Strings.transferInDesignation1: localRecord[Strings.transferInDesignation1],
      Strings.transferInSignature1: localRecord[Strings.transferInSignature1],
      Strings.transferInPatientName2: localRecord[Strings.transferInPatientName2],
      Strings.patientCorrectYes2: localRecord[Strings.patientCorrectYes2],
      Strings.patientCorrectNo2: localRecord[Strings.patientCorrectNo2],
      Strings.hospitalCorrectYes2: localRecord[Strings.hospitalCorrectYes2],
      Strings.hospitalCorrectNo2: localRecord[Strings.hospitalCorrectNo2],
      Strings.applicationFormYes2: localRecord[Strings.applicationFormYes2],
      Strings.applicationFormNo2: localRecord[Strings.applicationFormNo2],
      Strings.applicationSignedYes2: localRecord[Strings.applicationSignedYes2],
      Strings.applicationSignedNo2: localRecord[Strings.applicationSignedNo2],
      Strings.amhpIdentifiedYes: localRecord[Strings.amhpIdentifiedYes],
      Strings.amhpIdentifiedNo: localRecord[Strings.amhpIdentifiedNo],
      Strings.medicalRecommendationsFormYes2: localRecord[Strings.medicalRecommendationsFormYes2],
      Strings.medicalRecommendationsFormNo2: localRecord[Strings.medicalRecommendationsFormNo2],
      Strings.medicalRecommendationsSignedYes2: localRecord[Strings.medicalRecommendationsSignedYes2],
      Strings.medicalRecommendationsSignedNo2: localRecord[Strings.medicalRecommendationsSignedNo2],
      Strings.clearDaysYes2: localRecord[Strings.clearDaysYes2],
      Strings.clearDaysNo2: localRecord[Strings.clearDaysNo2],
      Strings.signatureDatesOnBeforeYes2: localRecord[Strings.signatureDatesOnBeforeYes2],
      Strings.signatureDatesOnBeforeNo2: localRecord[Strings.signatureDatesOnBeforeNo2],
      Strings.practitionersNameYes2: localRecord[Strings.practitionersNameYes2],
      Strings.practitionersNameNo2: localRecord[Strings.practitionersNameNo2],
      Strings.doctorsAgreeYes: localRecord[Strings.doctorsAgreeYes],
      Strings.doctorsAgreeNo: localRecord[Strings.doctorsAgreeNo],
      Strings.separateMedicalRecommendationsYes: localRecord[Strings.separateMedicalRecommendationsYes],
      Strings.separateMedicalRecommendationsNo: localRecord[Strings.separateMedicalRecommendationsNo],
      Strings.transferInCheckedBy2: localRecord[Strings.transferInCheckedBy2],
      Strings.transferInDate2: localRecord[Strings.transferInDate2],
      Strings.transferInDesignation2: localRecord[Strings.transferInDesignation2],
      Strings.transferInSignature2: localRecord[Strings.transferInSignature2],
      Strings.transferInPatientName3: localRecord[Strings.transferInPatientName3],
      Strings.patientCorrectYes3: localRecord[Strings.patientCorrectYes3],
      Strings.patientCorrectNo3: localRecord[Strings.patientCorrectNo3],
      Strings.hospitalCorrectYes3: localRecord[Strings.hospitalCorrectYes3],
      Strings.hospitalCorrectNo3: localRecord[Strings.hospitalCorrectNo3],
      Strings.h4Yes: localRecord[Strings.h4Yes],
      Strings.h4No: localRecord[Strings.h4No],
      Strings.currentConsentYes: localRecord[Strings.currentConsentYes],
      Strings.currentConsentNo: localRecord[Strings.currentConsentNo],
      Strings.applicationFormYes3: localRecord[Strings.applicationFormYes3],
      Strings.applicationFormNo3: localRecord[Strings.applicationFormNo3],
      Strings.applicationSignedYes3: localRecord[Strings.applicationSignedYes3],
      Strings.applicationSignedNo3: localRecord[Strings.applicationSignedNo3],
      Strings.within14DaysYes3: localRecord[Strings.within14DaysYes3],
      Strings.within14DaysNo3: localRecord[Strings.within14DaysNo3],
      Strings.localAuthorityNameYes3: localRecord[Strings.localAuthorityNameYes3],
      Strings.localAuthorityNameNo3: localRecord[Strings.localAuthorityNameNo3],
      Strings.nearestRelativeYes: localRecord[Strings.nearestRelativeYes],
      Strings.nearestRelativeNo: localRecord[Strings.nearestRelativeNo],
      Strings.amhpConsultationYes: localRecord[Strings.amhpConsultationYes],
      Strings.amhpConsultationNo: localRecord[Strings.amhpConsultationNo],
      Strings.knewPatientYes: localRecord[Strings.knewPatientYes],
      Strings.knewPatientNo: localRecord[Strings.knewPatientNo],
      Strings.medicalRecommendationsFormYes3: localRecord[Strings.medicalRecommendationsFormYes3],
      Strings.medicalRecommendationsFormNo3: localRecord[Strings.medicalRecommendationsFormNo3],
      Strings.medicalRecommendationsSignedYes3: localRecord[Strings.medicalRecommendationsSignedYes3],
      Strings.medicalRecommendationsSignedNo3: localRecord[Strings.medicalRecommendationsSignedNo3],
      Strings.clearDaysYes3: localRecord[Strings.clearDaysYes3],
      Strings.clearDaysNo3: localRecord[Strings.clearDaysNo3],
      Strings.approvedSection12Yes: localRecord[Strings.approvedSection12Yes],
      Strings.approvedSection12No: localRecord[Strings.approvedSection12No],
      Strings.signatureDatesOnBeforeYes3: localRecord[Strings.signatureDatesOnBeforeYes3],
      Strings.signatureDatesOnBeforeNo3: localRecord[Strings.signatureDatesOnBeforeNo3],
      Strings.practitionersNameYes3: localRecord[Strings.practitionersNameYes3],
      Strings.practitionersNameNo3: localRecord[Strings.practitionersNameNo3],
      Strings.previouslyAcquaintedYes: localRecord[Strings.previouslyAcquaintedYes],
      Strings.previouslyAcquaintedNo: localRecord[Strings.previouslyAcquaintedNo],
      Strings.acquaintedIfNoYes: localRecord[Strings.acquaintedIfNoYes],
      Strings.acquaintedIfNoNo: localRecord[Strings.acquaintedIfNoNo],
      Strings.recommendationsDifferentTeamsYes: localRecord[Strings.recommendationsDifferentTeamsYes],
      Strings.recommendationsDifferentTeamsNo: localRecord[Strings.recommendationsDifferentTeamsNo],
      Strings.originalDetentionPapersYes: localRecord[Strings.originalDetentionPapersYes],
      Strings.originalDetentionPapersNo: localRecord[Strings.originalDetentionPapersNo],
      Strings.transferInCheckedBy3: localRecord[Strings.transferInCheckedBy3],
      Strings.transferInDate3: localRecord[Strings.transferInDate3],
      Strings.transferInDesignation3: localRecord[Strings.transferInDesignation3],
      Strings.transferInSignature3: localRecord[Strings.transferInSignature3],
      Strings.feltSafeYes: localRecord[Strings.feltSafeYes],
      Strings.feltSafeNo: localRecord[Strings.feltSafeNo],
      Strings.staffIntroducedYes: localRecord[Strings.staffIntroducedYes],
      Strings.staffIntroducedNo: localRecord[Strings.staffIntroducedNo],
      Strings.experiencePositiveYes: localRecord[Strings.experiencePositiveYes],
      Strings.experiencePositiveNo: localRecord[Strings.experiencePositiveNo],
      Strings.otherComments: localRecord[Strings.otherComments],
      Strings.vehicleCompletedBy1: localRecord[Strings.vehicleCompletedBy1],
      Strings.vehicleDate: localRecord[Strings.vehicleDate],
      Strings.vehicleTime: localRecord[Strings.vehicleTime],
      Strings.ambulanceReg: localRecord[Strings.ambulanceReg],
      Strings.vehicleStartMileage: localRecord[Strings.vehicleStartMileage],
      Strings.nearestTank1: localRecord[Strings.nearestTank1],
      Strings.ambulanceTidyYes1: localRecord[Strings.ambulanceTidyYes1],
      Strings.ambulanceTidyNo1: localRecord[Strings.ambulanceTidyNo1],
      Strings.lightsWorkingYes: localRecord[Strings.lightsWorkingYes],
      Strings.lightsWorkingNo: localRecord[Strings.lightsWorkingNo],
      Strings.tyresInflatedYes: localRecord[Strings.tyresInflatedYes],
      Strings.tyresInflatedNo: localRecord[Strings.tyresInflatedNo],
      Strings.warningSignsYes: localRecord[Strings.warningSignsYes],
      Strings.warningSignsNo: localRecord[Strings.warningSignsNo],
      Strings.vehicleCompletedBy2: localRecord[Strings.vehicleCompletedBy2],
      Strings.nearestTank2: localRecord[Strings.nearestTank2],
      Strings.vehicleFinishMileage: localRecord[Strings.vehicleFinishMileage],
      Strings.ambulanceTidyYes2: localRecord[Strings.ambulanceTidyYes2],
      Strings.ambulanceTidyNo2: localRecord[Strings.ambulanceTidyNo2],
      Strings.sanitiserCleanYes: localRecord[Strings.sanitiserCleanYes],
      Strings.sanitiserCleanNo: localRecord[Strings.sanitiserCleanNo],
      Strings.issuesFaults: localRecord[Strings.issuesFaults],
      Strings.serverUploaded: localRecord[Strings.serverUploaded],
      Strings.timestamp: localRecord[Strings.timestamp]
    };
  }



  Future<Map<String, dynamic>> uploadPendingTransferReports() async {
    _isLoading = true;
    String message = 'Something went wrong!';
    bool success = false;
    List<String> storageUrlList = [];

    try {

      List<dynamic> transferReportRecords = await getPendingRecords();

      List<Map<String, dynamic>> transferReports = [];

      for(var transferReportRecord in transferReportRecords){
        transferReports.add(transferReportRecord.value);
      }

      // List<Map<String, dynamic>> transferReports =
      // await _databaseHelper.getAllWhereAndWhere(
      //     Strings.transferReportTable,
      //     Strings.serverUploaded,
      //     0,
      //     Strings.uid,
      //     user.uid);


      bool isTokenExpired = GlobalFunctions.isTokenExpired();
      bool authenticated = true;

      if (isTokenExpired)
        authenticated = await authenticationModel.reAuthenticate();

      if (authenticated) {

        for (Map<String, dynamic> transferReport in transferReports) {

          success = false;




          await GlobalFunctions.checkFirebaseStorageFail(_databaseHelper);


          DocumentReference ref =
          await FirebaseFirestore.instance.collection('transfer_reports').add({
            Strings.uid: user.uid,
            Strings.jobId: '1',
            Strings.formVersion: '1',
            Strings.jobRef: GlobalFunctions.databaseValueString(transferReport[Strings.jobRef]),
            Strings.jobRefLowercase: GlobalFunctions.databaseValueString(transferReport[Strings.jobRef]).toLowerCase(),
            Strings.date: transferReport[Strings.date] == null ? null : DateTime.parse(transferReport[Strings.date]),
            Strings.startTime: transferReport[Strings.startTime],
            Strings.finishTime: transferReport[Strings.finishTime],
            Strings.totalHours: transferReport[Strings.totalHours],
            Strings.collectionDetails: transferReport[Strings.collectionDetails],
            Strings.collectionPostcode: transferReport[Strings.collectionPostcode],
            Strings.collectionContactNo: transferReport[Strings.collectionContactNo],
            Strings.destinationDetails: transferReport[Strings.destinationDetails],
            Strings.destinationPostcode: transferReport[Strings.destinationPostcode],
            Strings.destinationContactNo: transferReport[Strings.destinationContactNo],
            Strings.collectionArrivalTime: transferReport[Strings.collectionArrivalTime],
            Strings.collectionDepartureTime: transferReport[Strings.collectionDepartureTime],
            Strings.destinationArrivalTime: transferReport[Strings.destinationArrivalTime],
            Strings.destinationDepartureTime: transferReport[Strings.destinationDepartureTime],
            Strings.vehicleRegNo: transferReport[Strings.vehicleRegNo],
            Strings.startMileage: transferReport[Strings.startMileage],
            Strings.finishMileage: transferReport[Strings.finishMileage],
            Strings.totalMileage: transferReport[Strings.totalMileage],
            Strings.name1: transferReport[Strings.name1],
            Strings.role1: transferReport[Strings.role1],
            Strings.drivingTimes1_1: transferReport[Strings.drivingTimes1_1],
            Strings.drivingTimes1_2: transferReport[Strings.drivingTimes1_2],
            Strings.name2: transferReport[Strings.name2],
            Strings.role2: transferReport[Strings.role2],
            Strings.drivingTimes2_1: transferReport[Strings.drivingTimes2_1],
            Strings.drivingTimes2_2: transferReport[Strings.drivingTimes2_2],
            Strings.name3: transferReport[Strings.name3],
            Strings.role3: transferReport[Strings.role3],
            Strings.drivingTimes3_1: transferReport[Strings.drivingTimes3_1],
            Strings.drivingTimes3_2: transferReport[Strings.drivingTimes3_2],
            Strings.name4: transferReport[Strings.name4],
            Strings.role4: transferReport[Strings.role4],
            Strings.drivingTimes4_1: transferReport[Strings.drivingTimes4_1],
            Strings.drivingTimes4_2: transferReport[Strings.drivingTimes4_2],
            Strings.name5: transferReport[Strings.name5],
            Strings.role5: transferReport[Strings.role5],
            Strings.drivingTimes5_1: transferReport[Strings.drivingTimes5_1],
            Strings.drivingTimes5_2: transferReport[Strings.drivingTimes5_2],
            Strings.name6: transferReport[Strings.name6],
            Strings.role6: transferReport[Strings.role6],
            Strings.drivingTimes6_1: transferReport[Strings.drivingTimes6_1],
            Strings.drivingTimes6_2: transferReport[Strings.drivingTimes6_2],
            Strings.name7: transferReport[Strings.name7],
            Strings.role7: transferReport[Strings.role7],
            Strings.drivingTimes7_1: transferReport[Strings.drivingTimes7_1],
            Strings.drivingTimes7_2: transferReport[Strings.drivingTimes7_2],
            Strings.name8: transferReport[Strings.name8],
            Strings.role8: transferReport[Strings.role8],
            Strings.drivingTimes8_1: transferReport[Strings.drivingTimes8_1],
            Strings.drivingTimes8_2: transferReport[Strings.drivingTimes8_2],
            Strings.name9: transferReport[Strings.name9],
            Strings.role9: transferReport[Strings.role9],
            Strings.drivingTimes9_1: transferReport[Strings.drivingTimes9_1],
            Strings.drivingTimes9_2: transferReport[Strings.drivingTimes9_2],
            Strings.name10: transferReport[Strings.name10],
            Strings.role10: transferReport[Strings.role10],
            Strings.drivingTimes10_1: transferReport[Strings.drivingTimes10_1],
            Strings.drivingTimes10_2: transferReport[Strings.drivingTimes10_2],
            Strings.name11: transferReport[Strings.name11],
            Strings.role11: transferReport[Strings.role11],
            Strings.drivingTimes11_1: transferReport[Strings.drivingTimes11_1],
            Strings.drivingTimes11_2: transferReport[Strings.drivingTimes11_2],
            Strings.collectionUnit: transferReport[Strings.collectionUnit],
            Strings.collectionPosition: transferReport[Strings.collectionPosition],
            Strings.collectionPrintName: transferReport[Strings.collectionPrintName],
            Strings.collectionArrivalTimeEnd: transferReport[Strings.collectionArrivalTimeEnd],
            Strings.collectionSignature: null,
            Strings.destinationUnit: transferReport[Strings.destinationUnit],
            Strings.destinationPosition: transferReport[Strings.destinationPosition],
            Strings.destinationPrintName: transferReport[Strings.destinationPrintName],
            Strings.destinationArrivalTimeEnd: transferReport[Strings.destinationArrivalTimeEnd],
            Strings.destinationSignature: null,
            Strings.patientName: transferReport[Strings.patientName],
            Strings.dateOfBirth: transferReport[Strings.dateOfBirth],
            Strings.ethnicity: transferReport[Strings.ethnicity],
            Strings.gender: transferReport[Strings.gender],
            Strings.mhaMcaDetails: transferReport[Strings.mhaMcaDetails],
            Strings.diagnosis: transferReport[Strings.diagnosis],
            Strings.currentPresentation: transferReport[Strings.currentPresentation],
            Strings.riskYes: transferReport[Strings.riskYes],
            Strings.riskNo: transferReport[Strings.riskNo],
            Strings.riskExplanation: transferReport[Strings.riskExplanation],
            Strings.forensicHistoryYes: transferReport[Strings.forensicHistoryYes],
            Strings.forensicHistoryNo: transferReport[Strings.forensicHistoryNo],
            Strings.racialGenderConcernsYes: transferReport[Strings.racialGenderConcernsYes],
            Strings.racialGenderConcernsNo: transferReport[Strings.racialGenderConcernsNo],
            Strings.violenceAggressionYes: transferReport[Strings.violenceAggressionYes],
            Strings.violenceAggressionNo: transferReport[Strings.violenceAggressionNo],
            Strings.selfHarmYes: transferReport[Strings.selfHarmYes],
            Strings.selfHarmNo: transferReport[Strings.selfHarmNo],
            Strings.alcoholSubstanceYes: transferReport[Strings.alcoholSubstanceYes],
            Strings.alcoholSubstanceNo: transferReport[Strings.alcoholSubstanceNo],
            Strings.virusesYes: transferReport[Strings.virusesYes],
            Strings.virusesNo: transferReport[Strings.virusesNo],
            Strings.safeguardingYes: transferReport[Strings.safeguardingYes],
            Strings.safeguardingNo: transferReport[Strings.safeguardingNo],
            Strings.physicalHealthConditionsYes: transferReport[Strings.physicalHealthConditionsYes],
            Strings.physicalHealthConditionsNo: transferReport[Strings.physicalHealthConditionsNo],
            Strings.useOfWeaponYes: transferReport[Strings.useOfWeaponYes],
            Strings.useOfWeaponNo: transferReport[Strings.useOfWeaponNo],
            Strings.absconsionRiskYes: transferReport[Strings.absconsionRiskYes],
            Strings.absconsionRiskNo: transferReport[Strings.absconsionRiskNo],
            Strings.forensicHistory: transferReport[Strings.forensicHistory],
            Strings.racialGenderConcerns: transferReport[Strings.racialGenderConcerns],
            Strings.violenceAggression: transferReport[Strings.violenceAggression],
            Strings.selfHarm: transferReport[Strings.selfHarm],
            Strings.alcoholSubstance: transferReport[Strings.alcoholSubstance],
            Strings.viruses: transferReport[Strings.viruses],
            Strings.safeguarding: transferReport[Strings.safeguarding],
            Strings.physicalHealthConditions: transferReport[Strings.physicalHealthConditions],
            Strings.useOfWeapon: transferReport[Strings.useOfWeapon],
            Strings.absconsionRisk: transferReport[Strings.absconsionRisk],
            Strings.patientPropertyYes: transferReport[Strings.patientPropertyYes],
            Strings.patientPropertyNo: transferReport[Strings.patientPropertyNo],
            Strings.patientPropertyExplanation: transferReport[Strings.patientPropertyExplanation],
            Strings.patientPropertyReceived: transferReport[Strings.patientPropertyReceived],
            Strings.patientPropertyReceivedYes: transferReport[Strings.patientPropertyReceivedYes],
            Strings.patientPropertyReceivedNo: transferReport[Strings.patientPropertyReceivedNo],
            Strings.patientNotesReceived: transferReport[Strings.patientNotesReceived],
            Strings.patientNotesReceivedYes: transferReport[Strings.patientNotesReceivedYes],
            Strings.patientNotesReceivedNo: transferReport[Strings.patientNotesReceivedNo],
            Strings.patientSearched: transferReport[Strings.patientSearched],
            Strings.patientSearchedYes: transferReport[Strings.patientSearchedYes],
            Strings.patientSearchedNo: transferReport[Strings.patientSearchedNo],
            Strings.itemsRemovedYes: transferReport[Strings.itemsRemovedYes],
            Strings.itemsRemovedNo: transferReport[Strings.itemsRemovedNo],
            Strings.itemsRemoved: transferReport[Strings.itemsRemoved],
            Strings.patientInformed: transferReport[Strings.patientInformed],
            Strings.injuriesNoted: transferReport[Strings.injuriesNoted],
            Strings.bodyMapImage: null,
            Strings.medicalAttentionYes: transferReport[Strings.medicalAttentionYes],
            Strings.medicalAttentionNo: transferReport[Strings.medicalAttentionNo],
            Strings.relevantInformationYes: transferReport[Strings.relevantInformationYes],
            Strings.relevantInformationNo: transferReport[Strings.relevantInformationNo],
            Strings.medicalAttention: transferReport[Strings.medicalAttention],
            Strings.currentMedication: transferReport[Strings.currentMedication],
            Strings.physicalObservations: transferReport[Strings.physicalObservations],
            Strings.relevantInformation: transferReport[Strings.relevantInformation],
            Strings.patientReport: transferReport[Strings.patientReport],
            Strings.patientReportPrintName: transferReport[Strings.patientReportPrintName],
            Strings.patientReportRole: transferReport[Strings.patientReportRole],
            Strings.patientReportDate: transferReport[Strings.patientReportDate],
            Strings.patientReportTime: transferReport[Strings.patientReportTime],
            Strings.patientReportSignature: null,
            Strings.handcuffsUsedYes: transferReport[Strings.handcuffsUsedYes],
            Strings.handcuffsUsedNo: transferReport[Strings.handcuffsUsedNo],
            Strings.handcuffsDate: transferReport[Strings.handcuffsDate],
            Strings.handcuffsTime: transferReport[Strings.handcuffsTime],
            Strings.handcuffsAuthorisedBy: transferReport[Strings.handcuffsAuthorisedBy],
            Strings.handcuffsAppliedBy: transferReport[Strings.handcuffsAppliedBy],
            Strings.handcuffsRemovedTime: transferReport[Strings.handcuffsRemovedTime],
            Strings.physicalInterventionYes: transferReport[Strings.physicalInterventionYes],
            Strings.physicalInterventionNo: transferReport[Strings.physicalInterventionNo],
            Strings.physicalIntervention: transferReport[Strings.physicalIntervention],
            Strings.whyInterventionRequired: transferReport[Strings.whyInterventionRequired],
            Strings.techniqueName1: transferReport[Strings.techniqueName1],
            Strings.techniqueName2: transferReport[Strings.techniqueName2],
            Strings.techniqueName3: transferReport[Strings.techniqueName3],
            Strings.techniqueName4: transferReport[Strings.techniqueName4],
            Strings.techniqueName5: transferReport[Strings.techniqueName5],
            Strings.techniqueName6: transferReport[Strings.techniqueName6],
            Strings.techniqueName7: transferReport[Strings.techniqueName7],
            Strings.techniqueName8: transferReport[Strings.techniqueName8],
            Strings.techniqueName9: transferReport[Strings.techniqueName9],
            Strings.techniqueName10: transferReport[Strings.techniqueName10],
            Strings.technique1: transferReport[Strings.technique1],
            Strings.technique2: transferReport[Strings.technique2],
            Strings.technique3: transferReport[Strings.technique3],
            Strings.technique4: transferReport[Strings.technique4],
            Strings.technique5: transferReport[Strings.technique5],
            Strings.technique6: transferReport[Strings.technique6],
            Strings.technique7: transferReport[Strings.technique7],
            Strings.technique8: transferReport[Strings.technique8],
            Strings.technique9: transferReport[Strings.technique9],
            Strings.technique10: transferReport[Strings.technique10],
            Strings.techniquePosition1: transferReport[Strings.techniquePosition1],
            Strings.techniquePosition2: transferReport[Strings.techniquePosition2],
            Strings.techniquePosition3: transferReport[Strings.techniquePosition3],
            Strings.techniquePosition4: transferReport[Strings.techniquePosition4],
            Strings.techniquePosition5: transferReport[Strings.techniquePosition5],
            Strings.techniquePosition6: transferReport[Strings.techniquePosition6],
            Strings.techniquePosition7: transferReport[Strings.techniquePosition7],
            Strings.techniquePosition8: transferReport[Strings.techniquePosition8],
            Strings.techniquePosition9: transferReport[Strings.techniquePosition9],
            Strings.techniquePosition10: transferReport[Strings.techniquePosition10],
            Strings.timeInterventionCommenced: transferReport[Strings.timeInterventionCommenced],
            Strings.timeInterventionCompleted: transferReport[Strings.timeInterventionCompleted],
            Strings.incidentDate: transferReport[Strings.incidentDate] == null ? null : DateTime.parse(transferReport[Strings.incidentDate]),
            Strings.incidentTime: transferReport[Strings.incidentTime],
            Strings.incidentDetails: transferReport[Strings.incidentDetails],
            Strings.incidentLocation: transferReport[Strings.incidentLocation],
            Strings.incidentAction: transferReport[Strings.incidentAction],
            Strings.incidentStaffInvolved: transferReport[Strings.incidentStaffInvolved],
            Strings.incidentSignature: null,
            Strings.incidentSignatureDate: transferReport[Strings.incidentSignatureDate],
            Strings.incidentPrintName: transferReport[Strings.incidentPrintName],
            Strings.hasSection2Checklist: transferReport[Strings.hasSection2Checklist],
            Strings.hasSection3Checklist: transferReport[Strings.hasSection3Checklist],
            Strings.hasSection3TransferChecklist: transferReport[Strings.hasSection3TransferChecklist],
            Strings.transferInPatientName1: transferReport[Strings.transferInPatientName1],
            Strings.patientCorrectYes1: transferReport[Strings.patientCorrectYes1],
            Strings.patientCorrectNo1: transferReport[Strings.patientCorrectNo1],
            Strings.hospitalCorrectYes1: transferReport[Strings.hospitalCorrectYes1],
            Strings.hospitalCorrectNo1: transferReport[Strings.hospitalCorrectNo1],
            Strings.applicationFormYes1: transferReport[Strings.applicationFormYes1],
            Strings.applicationFormNo1: transferReport[Strings.applicationFormNo1],
            Strings.applicationSignedYes1: transferReport[Strings.applicationSignedYes1],
            Strings.applicationSignedNo1: transferReport[Strings.applicationSignedNo1],
            Strings.within14DaysYes1: transferReport[Strings.within14DaysYes1],
            Strings.within14DaysNo1: transferReport[Strings.within14DaysNo1],
            Strings.localAuthorityNameYes1: transferReport[Strings.localAuthorityNameYes1],
            Strings.localAuthorityNameNo1: transferReport[Strings.localAuthorityNameNo1],
            Strings.medicalRecommendationsFormYes1: transferReport[Strings.medicalRecommendationsFormYes1],
            Strings.medicalRecommendationsFormNo1: transferReport[Strings.medicalRecommendationsFormNo1],
            Strings.medicalRecommendationsSignedYes1: transferReport[Strings.medicalRecommendationsSignedYes1],
            Strings.medicalRecommendationsSignedNo1: transferReport[Strings.medicalRecommendationsSignedNo1],
            Strings.datesSignatureSignedYes: transferReport[Strings.datesSignatureSignedYes],
            Strings.datesSignatureSignedNo: transferReport[Strings.datesSignatureSignedNo],
            Strings.signatureDatesOnBeforeYes1: transferReport[Strings.signatureDatesOnBeforeYes1],
            Strings.signatureDatesOnBeforeNo1: transferReport[Strings.signatureDatesOnBeforeNo1],
            Strings.practitionersNameYes1: transferReport[Strings.practitionersNameYes1],
            Strings.practitionersNameNo1: transferReport[Strings.practitionersNameNo1],
            Strings.transferInCheckedBy1: transferReport[Strings.transferInCheckedBy1],
            Strings.transferInDate1: transferReport[Strings.transferInDate1],
            Strings.transferInDesignation1: transferReport[Strings.transferInDesignation1],
            Strings.transferInSignature1: null,
            Strings.transferInPatientName2: transferReport[Strings.transferInPatientName2],
            Strings.patientCorrectYes2: transferReport[Strings.patientCorrectYes2],
            Strings.patientCorrectNo2: transferReport[Strings.patientCorrectNo2],
            Strings.hospitalCorrectYes2: transferReport[Strings.hospitalCorrectYes2],
            Strings.hospitalCorrectNo2: transferReport[Strings.hospitalCorrectNo2],
            Strings.applicationFormYes2: transferReport[Strings.applicationFormYes2],
            Strings.applicationFormNo2: transferReport[Strings.applicationFormNo2],
            Strings.applicationSignedYes2: transferReport[Strings.applicationSignedYes2],
            Strings.applicationSignedNo2: transferReport[Strings.applicationSignedNo2],
            Strings.amhpIdentifiedYes: transferReport[Strings.amhpIdentifiedYes],
            Strings.amhpIdentifiedNo: transferReport[Strings.amhpIdentifiedNo],
            Strings.medicalRecommendationsFormYes2: transferReport[Strings.medicalRecommendationsFormYes2],
            Strings.medicalRecommendationsFormNo2: transferReport[Strings.medicalRecommendationsFormNo2],
            Strings.medicalRecommendationsSignedYes2: transferReport[Strings.medicalRecommendationsSignedYes2],
            Strings.medicalRecommendationsSignedNo2: transferReport[Strings.medicalRecommendationsSignedNo2],
            Strings.clearDaysYes2: transferReport[Strings.clearDaysYes2],
            Strings.clearDaysNo2: transferReport[Strings.clearDaysNo2],
            Strings.signatureDatesOnBeforeYes2: transferReport[Strings.signatureDatesOnBeforeYes2],
            Strings.signatureDatesOnBeforeNo2: transferReport[Strings.signatureDatesOnBeforeNo2],
            Strings.practitionersNameYes2: transferReport[Strings.practitionersNameYes2],
            Strings.practitionersNameNo2: transferReport[Strings.practitionersNameNo2],
            Strings.doctorsAgreeYes: transferReport[Strings.doctorsAgreeYes],
            Strings.doctorsAgreeNo: transferReport[Strings.doctorsAgreeNo],
            Strings.separateMedicalRecommendationsYes: transferReport[Strings.separateMedicalRecommendationsYes],
            Strings.separateMedicalRecommendationsNo: transferReport[Strings.separateMedicalRecommendationsNo],
            Strings.transferInCheckedBy2: transferReport[Strings.transferInCheckedBy2],
            Strings.transferInDate2: transferReport[Strings.transferInDate2],
            Strings.transferInDesignation2: transferReport[Strings.transferInDesignation2],
            Strings.transferInSignature2: null,
            Strings.transferInPatientName3: transferReport[Strings.transferInPatientName3],
            Strings.patientCorrectYes3: transferReport[Strings.patientCorrectYes3],
            Strings.patientCorrectNo3: transferReport[Strings.patientCorrectNo3],
            Strings.hospitalCorrectYes3: transferReport[Strings.hospitalCorrectYes3],
            Strings.hospitalCorrectNo3: transferReport[Strings.hospitalCorrectNo3],
            Strings.h4Yes: transferReport[Strings.h4Yes],
            Strings.h4No: transferReport[Strings.h4No],
            Strings.currentConsentYes: transferReport[Strings.currentConsentYes],
            Strings.currentConsentNo: transferReport[Strings.currentConsentNo],
            Strings.applicationFormYes3: transferReport[Strings.applicationFormYes3],
            Strings.applicationFormNo3: transferReport[Strings.applicationFormNo3],
            Strings.applicationSignedYes3: transferReport[Strings.applicationSignedYes3],
            Strings.applicationSignedNo3: transferReport[Strings.applicationSignedNo3],
            Strings.within14DaysYes3: transferReport[Strings.within14DaysYes3],
            Strings.within14DaysNo3: transferReport[Strings.within14DaysNo3],
            Strings.localAuthorityNameYes3: transferReport[Strings.localAuthorityNameYes3],
            Strings.localAuthorityNameNo3: transferReport[Strings.localAuthorityNameNo3],
            Strings.nearestRelativeYes: transferReport[Strings.nearestRelativeYes],
            Strings.nearestRelativeNo: transferReport[Strings.nearestRelativeNo],
            Strings.amhpConsultationYes: transferReport[Strings.amhpConsultationYes],
            Strings.amhpConsultationNo: transferReport[Strings.amhpConsultationNo],
            Strings.knewPatientYes: transferReport[Strings.knewPatientYes],
            Strings.knewPatientNo: transferReport[Strings.knewPatientNo],
            Strings.medicalRecommendationsFormYes3: transferReport[Strings.medicalRecommendationsFormYes3],
            Strings.medicalRecommendationsFormNo3: transferReport[Strings.medicalRecommendationsFormNo3],
            Strings.medicalRecommendationsSignedYes3: transferReport[Strings.medicalRecommendationsSignedYes3],
            Strings.medicalRecommendationsSignedNo3: transferReport[Strings.medicalRecommendationsSignedNo3],
            Strings.clearDaysYes3: transferReport[Strings.clearDaysYes3],
            Strings.clearDaysNo3: transferReport[Strings.clearDaysNo3],
            Strings.approvedSection12Yes: transferReport[Strings.approvedSection12Yes],
            Strings.approvedSection12No: transferReport[Strings.approvedSection12No],
            Strings.signatureDatesOnBeforeYes3: transferReport[Strings.signatureDatesOnBeforeYes3],
            Strings.signatureDatesOnBeforeNo3: transferReport[Strings.signatureDatesOnBeforeNo3],
            Strings.practitionersNameYes3: transferReport[Strings.practitionersNameYes3],
            Strings.practitionersNameNo3: transferReport[Strings.practitionersNameNo3],
            Strings.previouslyAcquaintedYes: transferReport[Strings.previouslyAcquaintedYes],
            Strings.previouslyAcquaintedNo: transferReport[Strings.previouslyAcquaintedNo],
            Strings.acquaintedIfNoYes: transferReport[Strings.acquaintedIfNoYes],
            Strings.acquaintedIfNoNo: transferReport[Strings.acquaintedIfNoNo],
            Strings.recommendationsDifferentTeamsYes: transferReport[Strings.recommendationsDifferentTeamsYes],
            Strings.recommendationsDifferentTeamsNo: transferReport[Strings.recommendationsDifferentTeamsNo],
            Strings.originalDetentionPapersYes: transferReport[Strings.originalDetentionPapersYes],
            Strings.originalDetentionPapersNo: transferReport[Strings.originalDetentionPapersNo],
            Strings.transferInCheckedBy3: transferReport[Strings.transferInCheckedBy3],
            Strings.transferInDate3: transferReport[Strings.transferInDate3],
            Strings.transferInDesignation3: transferReport[Strings.transferInDesignation3],
            Strings.transferInSignature3: null,
            Strings.feltSafeYes: transferReport[Strings.feltSafeYes],
            Strings.feltSafeNo: transferReport[Strings.feltSafeNo],
            Strings.staffIntroducedYes: transferReport[Strings.staffIntroducedYes],
            Strings.staffIntroducedNo: transferReport[Strings.staffIntroducedNo],
            Strings.experiencePositiveYes: transferReport[Strings.experiencePositiveYes],
            Strings.experiencePositiveNo: transferReport[Strings.experiencePositiveNo],
            Strings.otherComments: transferReport[Strings.otherComments],
            Strings.vehicleCompletedBy1: transferReport[Strings.vehicleCompletedBy1],
            Strings.vehicleDate: transferReport[Strings.vehicleDate],
            Strings.vehicleTime: transferReport[Strings.vehicleTime],
            Strings.ambulanceReg: transferReport[Strings.ambulanceReg],
            Strings.vehicleStartMileage: transferReport[Strings.vehicleStartMileage],
            Strings.nearestTank1: transferReport[Strings.nearestTank1],
            Strings.ambulanceTidyYes1: transferReport[Strings.ambulanceTidyYes1],
            Strings.ambulanceTidyNo1: transferReport[Strings.ambulanceTidyNo1],
            Strings.lightsWorkingYes: transferReport[Strings.lightsWorkingYes],
            Strings.lightsWorkingNo: transferReport[Strings.lightsWorkingNo],
            Strings.tyresInflatedYes: transferReport[Strings.tyresInflatedYes],
            Strings.tyresInflatedNo: transferReport[Strings.tyresInflatedNo],
            Strings.warningSignsYes: transferReport[Strings.warningSignsYes],
            Strings.warningSignsNo: transferReport[Strings.warningSignsNo],
            Strings.vehicleCompletedBy2: transferReport[Strings.vehicleCompletedBy2],
            Strings.nearestTank2: transferReport[Strings.nearestTank2],
            Strings.vehicleFinishMileage: transferReport[Strings.vehicleFinishMileage],
            Strings.ambulanceTidyYes2: transferReport[Strings.ambulanceTidyYes2],
            Strings.ambulanceTidyNo2: transferReport[Strings.ambulanceTidyNo2],
            Strings.sanitiserCleanYes: transferReport[Strings.sanitiserCleanYes],
            Strings.sanitiserCleanNo: transferReport[Strings.sanitiserCleanNo],
            Strings.issuesFaults: transferReport[Strings.issuesFaults],
            Strings.timestamp: FieldValue.serverTimestamp(),
            Strings.serverUploaded: 1,
          });

          DocumentSnapshot snap = await ref.get();

          //Signatures
          String collectionSignatureUrl;
          bool collectionSignatureSuccess = true;

          if(transferReport[Strings.collectionSignature] != null){
            collectionSignatureSuccess = false;

            Reference storageRef =
            FirebaseStorage.instance.ref().child('transferReportImages/' + snap.id + '/collectionSignature.jpg');

            if(kIsWeb){
              storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + snap.id + '/collectionSignature.jpg');
            }


            final UploadTask uploadTask = storageRef.putData(Uint8List.fromList(transferReport[Strings.collectionSignature].toList().cast<int>()));

            final TaskSnapshot downloadUrl = (await uploadTask);
            collectionSignatureUrl = (await downloadUrl.ref.getDownloadURL());
            if(collectionSignatureUrl != null){
              collectionSignatureSuccess = true;
              storageUrlList.add('transferReportImages/' + snap.id + '/collectionSignature.jpg');
            }

          }

          String incidentSignatureUrl;
          bool incidentSignatureSuccess = true;

          if(transferReport[Strings.incidentSignature] != null){
            incidentSignatureSuccess = false;

            Reference storageRef =
            FirebaseStorage.instance.ref().child('transferReportImages/' + snap.id + '/incidentSignature.jpg');

            if(kIsWeb){
              storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + snap.id + '/incidentSignature.jpg');
            }

            final UploadTask uploadTask = storageRef.putData(Uint8List.fromList(transferReport[Strings.incidentSignature].toList().cast<int>()));

            final TaskSnapshot downloadUrl = (await uploadTask);
            incidentSignatureUrl = (await downloadUrl.ref.getDownloadURL());
            if(incidentSignatureUrl != null){
              incidentSignatureSuccess = true;
              storageUrlList.add('transferReportImages/' + snap.id + '/incidentSignature.jpg');
            }

          }

          String destinationSignatureUrl;
          bool destinationSignatureSuccess = true;

          if(transferReport[Strings.destinationSignature] != null){
            destinationSignatureSuccess = false;

            Reference storageRef =
            FirebaseStorage.instance.ref().child('transferReportImages/' + snap.id + '/destinationSignature.jpg');

            if(kIsWeb){
              storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + snap.id + '/destinationSignature.jpg');
            }
            final UploadTask uploadTask = storageRef.putData(Uint8List.fromList(transferReport[Strings.destinationSignature].toList().cast<int>()));

            final TaskSnapshot downloadUrl = (await uploadTask);
            destinationSignatureUrl = (await downloadUrl.ref.getDownloadURL());
            if(destinationSignatureUrl != null){
              destinationSignatureSuccess = true;
              storageUrlList.add('transferReportImages/' + snap.id + '/destinationSignature.jpg');
            }

          }

          String bodyMapImageUrl;
          bool bodyMapImageSuccess = true;

          if(transferReport[Strings.bodyMapImage] != null){
            bodyMapImageSuccess = false;

            Uint8List decryptedImage = await GlobalFunctions.decryptSignature(transferReport[Strings.bodyMapImage]);

            Uint8List compressedImage = await FlutterImageCompress.compressWithList(
                decryptedImage,
                quality: 50,
                keepExif: true
            );


            Uint8List encryptedImage = await GlobalFunctions.encryptSignature(compressedImage);

            Reference storageRef =
            FirebaseStorage.instance.ref().child('transferReportImages/' + snap.id + '/bodyMapImage.jpg');

            if(kIsWeb){
              storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + snap.id + '/bodyMapImage.jpg');
            }
            //final UploadTask uploadTask = storageRef.putData(encryptedImage);
            final UploadTask uploadTask = storageRef.putData(Uint8List.fromList(encryptedImage.toList().cast<int>()));

            final TaskSnapshot downloadUrl = (await uploadTask);
            bodyMapImageUrl = (await downloadUrl.ref.getDownloadURL());
            if(bodyMapImageUrl != null){
              bodyMapImageSuccess = true;
              storageUrlList.add('transferReportImages/' + snap.id + '/bodyMapImage.jpg');
            }

          }

          String patientReportSignatureUrl;
          bool patientReportSignatureSuccess = true;

          if(transferReport[Strings.patientReportSignature] != null){
            patientReportSignatureSuccess = false;

            Reference storageRef =
            FirebaseStorage.instance.ref().child('transferReportImages/' + snap.id + '/patientReportSignature.jpg');

            if(kIsWeb){
              storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + snap.id + '/patientReportSignature.jpg');
            }


            final UploadTask uploadTask = storageRef.putData(Uint8List.fromList(transferReport[Strings.patientReportSignature].toList().cast<int>()));

            final TaskSnapshot downloadUrl = (await uploadTask);
            patientReportSignatureUrl = (await downloadUrl.ref.getDownloadURL());
            if(patientReportSignatureUrl != null){
              patientReportSignatureSuccess = true;
              storageUrlList.add('transferReportImages/' + snap.id + '/patientReportSignature.jpg');
            }

          }

          String transferInSignature1Url;
          bool transferInSignature1Success = true;

          if(transferReport[Strings.transferInSignature1] != null){
            transferInSignature1Success = false;

            Reference storageRef =
            FirebaseStorage.instance.ref().child('transferReportImages/' + snap.id + '/transferInSignature1.jpg');

            if(kIsWeb){
              storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + snap.id + '/transferInSignature1.jpg');
            }
            final UploadTask uploadTask = storageRef.putData(Uint8List.fromList(transferReport[Strings.transferInSignature1].toList().cast<int>()));

            final TaskSnapshot downloadUrl = (await uploadTask);
            transferInSignature1Url = (await downloadUrl.ref.getDownloadURL());
            if(transferInSignature1Url != null){
              transferInSignature1Success = true;
              storageUrlList.add('transferReportImages/' + snap.id + '/transferInSignature1.jpg');
            }

          }

          String transferInSignature2Url;
          bool transferInSignature2Success = true;

          if(transferReport[Strings.transferInSignature2] != null){
            transferInSignature2Success = false;

            Reference storageRef =
            FirebaseStorage.instance.ref().child('transferReportImages/' + snap.id + '/transferInSignature2.jpg');

            if(kIsWeb){
              storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + snap.id + '/transferInSignature2.jpg');
            }
            final UploadTask uploadTask = storageRef.putData(Uint8List.fromList(transferReport[Strings.transferInSignature2].toList().cast<int>()));
            final TaskSnapshot downloadUrl = (await uploadTask);
            transferInSignature2Url = (await downloadUrl.ref.getDownloadURL());
            if(transferInSignature2Url != null){
              transferInSignature2Success = true;
              storageUrlList.add('transferReportImages/' + snap.id + '/transferInSignature2.jpg');
            }

          }

          String transferInSignature3Url;
          bool transferInSignature3Success = true;

          if(transferReport[Strings.transferInSignature3] != null){
            transferInSignature3Success = false;

            Reference storageRef =
            FirebaseStorage.instance.ref().child('transferReportImages/' + snap.id + '/transferInSignature3.jpg');

            if(kIsWeb){
              storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + snap.id + '/transferInSignature3.jpg');
            }
            final UploadTask uploadTask = storageRef.putData(Uint8List.fromList(transferReport[Strings.transferInSignature3].toList().cast<int>()));
            final TaskSnapshot downloadUrl = (await uploadTask);
            transferInSignature3Url = (await downloadUrl.ref.getDownloadURL());
            if(transferInSignature3Url != null){
              transferInSignature3Success = true;
              storageUrlList.add('transferReportImages/' + snap.id + '/transferInSignature3.jpg');
            }

          }


          if(incidentSignatureSuccess && collectionSignatureSuccess &&  destinationSignatureSuccess && bodyMapImageSuccess && patientReportSignatureSuccess && transferInSignature1Success && transferInSignature2Success && transferInSignature3Success){

            await FirebaseFirestore.instance.collection('transfer_reports').doc(snap.id).update({
              Strings.incidentSignature: incidentSignatureUrl == null ? null : incidentSignatureUrl,
              Strings.collectionSignature: collectionSignatureUrl == null ? null : collectionSignatureUrl,
              Strings.destinationSignature: destinationSignatureUrl == null ? null : destinationSignatureUrl,
              Strings.bodyMapImage: bodyMapImageUrl == null ? null : bodyMapImageUrl,
              Strings.patientReportSignature: patientReportSignatureUrl == null ? null : patientReportSignatureUrl,
              Strings.transferInSignature1: transferInSignature1Url == null ? null : transferInSignature1Url,
              Strings.transferInSignature2: transferInSignature2Url == null ? null : transferInSignature2Url,
              Strings.transferInSignature3: transferInSignature3Url == null ? null : transferInSignature3Url
            }).timeout(Duration(seconds: 60));

            await deletePendingRecord(transferReport[Strings.localId]);
            success = true;


            // Map<String, dynamic> localData = {
            //   Strings.documentId: snap.id,
            //   Strings.serverUploaded: 1,
            //   'timestamp': DateTime.fromMillisecondsSinceEpoch(snap.data()[Strings.timestamp].millisecondsSinceEpoch).toIso8601String()
            // };
            //
            // int queryResult = await _databaseHelper.updateRow(
            //     Strings.transferReportTable,
            //     localData,
            //     Strings.localId,
            //     transferReport[Strings.localId]);
            //
            // if (queryResult != 0) {
            //   success = true;
            // }


          } else {
            await FirebaseFirestore.instance.collection('transfer_reports').doc(snap.id).delete();
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


  Future<void> setUpEditedTransferReport() async{

    Map<String, dynamic> editedReport = editedTransferReport(selectedTransferReport);
    Map<String, dynamic> localData = Map.from(editedReport);
    await _databaseHelper.deleteAllRows(Strings.editedTransferReportTable);
    await _databaseHelper.add(Strings.editedTransferReportTable, localData);

  }

  Future<void> deleteEditedTransferReport() async{
    await _databaseHelper.deleteAllRows(Strings.editedTransferReportTable);
  }

  void resetTemporaryTransferReport(String chosenJobId) {
    _databaseHelper.resetTemporaryTransferReport(user.uid, chosenJobId);
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


    Widget drivingTimesRow(String value1, String value2, String value3, String value4){
      return Column(
        children: [
          Row(
              children: [
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
                          Text(value1 == null ? '' : GlobalFunctions.decryptString(value1), style: TextStyle(fontSize: 8)),
                        ],
                      ),
                    )))),
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
                          Text(value2 == null ? '' : GlobalFunctions.decryptString(value2), style: TextStyle(fontSize: 8)),
                        ],
                      ),
                    )))),
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
                          Text(value3 == null ? '' : timeFormat.format(DateTime.parse(value3)), style: TextStyle(fontSize: 8)),
                        ],
                      ),
                    )))),
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
                          Text(value4 == null ? '' : timeFormat.format(DateTime.parse(value4)), style: TextStyle(fontSize: 8)),
                        ],
                      ),
                    )))),
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
      return Column(children: [
        Row(
            children: [
              Expanded(child: Text(text, style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 8)),),
              Container(width: 10),
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
                  child: Center(child: Text(value1 == null || value1 == 0 ? '' : 'X', textAlign: TextAlign.center ,style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
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
                  child: Center(child: Text(value2 == null || value2 == 0 ? '' : 'X', textAlign: TextAlign.center ,style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
            ]
        ),
        Container(height: 5)
      ]);
    }


    try {

      Document pdf;
      pdf = Document();
      PdfDocument pdfDoc = pdf.document;
      FlutterImage.Image incidentSignatureImage;
      FlutterImage.Image patientReportSignatureImage;
      FlutterImage.Image collectionSignatureImage;
      FlutterImage.Image destinationSignatureImage;
      FlutterImage.Image transferInSignature1Image;
      FlutterImage.Image transferInSignature2Image;
      FlutterImage.Image transferInSignature3Image;
      FlutterImage.Image bodyMapImage;
      PdfImage pegasusLogo = await pdfImageFromImageProvider(pdf: pdfDoc, image: Material.AssetImage('assets/images/pegasusLogo.png'),);
      PdfImage bodyMapEmpty = await pdfImageFromImageProvider(pdf: pdfDoc, image: Material.AssetImage('assets/images/bodyMap.png'),);

      print(DateTime.parse(selectedTransferReport[Strings.startTime]));

      print(timeFormat.format(DateTime.parse(selectedTransferReport[Strings.startTime])));



      if (selectedTransferReport[Strings.bodyMapImage] != null) {
        Uint8List decryptedImage = await GlobalFunctions.decryptSignature(selectedTransferReport[Strings.bodyMapImage]);
        bodyMapImage = FlutterImage.decodeImage(decryptedImage);
      }
      if (selectedTransferReport[Strings.incidentSignature] != null) {
        Uint8List decryptedImage = await GlobalFunctions.decryptSignature(selectedTransferReport[Strings.incidentSignature]);
        incidentSignatureImage = FlutterImage.decodeImage(decryptedImage);
      }
      if (selectedTransferReport[Strings.patientReportSignature] != null) {
        Uint8List decryptedImage = await GlobalFunctions.decryptSignature(selectedTransferReport[Strings.patientReportSignature]);
        patientReportSignatureImage = FlutterImage.decodeImage(decryptedImage);
      }
      if (selectedTransferReport[Strings.collectionSignature] != null) {
        Uint8List decryptedImage = await GlobalFunctions.decryptSignature(selectedTransferReport[Strings.collectionSignature]);
        collectionSignatureImage = FlutterImage.decodeImage(decryptedImage);
      }
      if (selectedTransferReport[Strings.destinationSignature] != null) {
        Uint8List decryptedImage = await GlobalFunctions.decryptSignature(selectedTransferReport[Strings.destinationSignature]);
        destinationSignatureImage = FlutterImage.decodeImage(decryptedImage);
      }
      if (selectedTransferReport[Strings.transferInSignature1] != null) {
        Uint8List decryptedImage = await GlobalFunctions.decryptSignature(selectedTransferReport[Strings.transferInSignature1]);
        transferInSignature1Image = FlutterImage.decodeImage(decryptedImage);
      }
      if (selectedTransferReport[Strings.transferInSignature2] != null) {
        Uint8List decryptedImage = await GlobalFunctions.decryptSignature(selectedTransferReport[Strings.transferInSignature2]);
        transferInSignature2Image = FlutterImage.decodeImage(decryptedImage);
      }
      if (selectedTransferReport[Strings.transferInSignature3] != null) {
        Uint8List decryptedImage = await GlobalFunctions.decryptSignature(selectedTransferReport[Strings.transferInSignature3]);
        transferInSignature3Image = FlutterImage.decodeImage(decryptedImage);
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
                child: Text('Transfer Report - Page ${context.pageNumber} of ${context.pagesCount}',
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
                        textField(TextOption.PlainText, selectedTransferReport[Strings.jobRef]),
                      ]),
                      Container(height: 5),
                      Row(children: [
                        sectionTitle('Date'),
                        SizedBox(width: 20),
                        textField(TextOption.Date, selectedTransferReport[Strings.date]),
                      ])
                    ]
                  ),

                  Container(height: 50, child: Image(pegasusLogo)),

                ]
            ),
            Container(height: 5),
            Center(child: Text('TRANSFER REPORT', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontWeight: FontWeight.bold))),
            Container(height: 10),
            doubleLineField('Name', selectedTransferReport[Strings.patientName], 'Date of Birth', selectedTransferReport[Strings.dateOfBirth], TextOption.EncryptedText, TextOption.EncryptedDate),
            doubleLineField('Ethnicity', selectedTransferReport[Strings.ethnicity], 'Gender', selectedTransferReport[Strings.gender]),
            singleLineField('Legal Status', selectedTransferReport[Strings.mhaMcaDetails]),
            singleLineField('Diagnosis', selectedTransferReport[Strings.diagnosis]),
            singleLineField('Current Presentation', selectedTransferReport[Strings.currentPresentation]),
            sectionTitle('Risk'),
            // Row(
            //     mainAxisAlignment: MainAxisAlignment.start,
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Container(width: 90),
            //       Text('Yes', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 8)),
            //       Container(width: 5),
            //       Container(width: 15, height: 15, padding: const EdgeInsets.all(2),
            //           decoration: BoxDecoration(shape: BoxShape.circle, border: BoxBorder(
            //             top: true,
            //             left: true,
            //             right: true,
            //             bottom: true,
            //             width: 1,
            //             color: PdfColors.grey,
            //           )),
            //           child: Center(child: Text(selectedTransferReport[Strings.riskYes] == null || selectedTransferReport[Strings.riskYes] == 0 ? '' : 'X', textAlign: TextAlign.center ,style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
            //       Container(width: 10),
            //       Text('No', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 8)),
            //       Container(width: 5),
            //       Container(width: 15, height: 15, padding: const EdgeInsets.all(2),
            //           decoration: BoxDecoration(shape: BoxShape.circle, border: BoxBorder(
            //             top: true,
            //             left: true,
            //             right: true,
            //             bottom: true,
            //             width: 1,
            //             color: PdfColors.grey,
            //           )),
            //           child: Center(child: Text(selectedTransferReport[Strings.riskNo] == null || selectedTransferReport[Strings.riskNo] == 0 ? '' : 'X', textAlign: TextAlign.center ,style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
            //     ]
            // ),
            // Container(height: 10),
            // selectedTransferReport[Strings.riskYes] != null && selectedTransferReport[Strings.riskYes] == 1 ? singleLineField('Explanation', selectedTransferReport[Strings.riskExplanation]) : Container(),

            Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 90, child: Text('Forensic History', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 8))),
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
                      child: Center(child: Text(selectedTransferReport[Strings.forensicHistoryYes] == null || selectedTransferReport[Strings.forensicHistoryYes] == 0 ? '' : 'X', textAlign: TextAlign.center ,style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
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
                      child: Center(child: Text(selectedTransferReport[Strings.forensicHistoryNo] == null || selectedTransferReport[Strings.forensicHistoryNo] == 0 ? '' : 'X', textAlign: TextAlign.center ,style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
                ]
            ),
            Container(height: 5),
            selectedTransferReport[Strings.forensicHistoryYes] != null && selectedTransferReport[Strings.forensicHistoryYes] == 1 ? singleLineField('', selectedTransferReport[Strings.forensicHistory]) : Container(),
            Container(height: 5),
            Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 90, child: Text('Any Racial of Gender Concerns', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 8))),
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
                      child: Center(child: Text(selectedTransferReport[Strings.racialGenderConcernsYes] == null || selectedTransferReport[Strings.racialGenderConcernsYes] == 0 ? '' : 'X', textAlign: TextAlign.center ,style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
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
                      child: Center(child: Text(selectedTransferReport[Strings.racialGenderConcernsNo] == null || selectedTransferReport[Strings.racialGenderConcernsNo] == 0 ? '' : 'X', textAlign: TextAlign.center ,style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
                ]
            ),
            Container(height: 5),
            selectedTransferReport[Strings.racialGenderConcernsYes] != null && selectedTransferReport[Strings.racialGenderConcernsYes] == 1 ? singleLineField('', selectedTransferReport[Strings.racialGenderConcerns]) : Container(),
            Container(height: 5),
            Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 90, child: Text('Violence or Aggression (Actual or Potential)', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 8))),
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
                      child: Center(child: Text(selectedTransferReport[Strings.violenceAggressionYes] == null || selectedTransferReport[Strings.violenceAggressionYes] == 0 ? '' : 'X', textAlign: TextAlign.center ,style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
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
                      child: Center(child: Text(selectedTransferReport[Strings.violenceAggressionNo] == null || selectedTransferReport[Strings.violenceAggressionNo] == 0 ? '' : 'X', textAlign: TextAlign.center ,style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
                ]
            ),
            Container(height: 5),
            selectedTransferReport[Strings.violenceAggressionYes] != null && selectedTransferReport[Strings.violenceAggressionYes] == 1 ? singleLineField('', selectedTransferReport[Strings.violenceAggression]) : Container(),
            Container(height: 5),

            Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 90, child: Text('Self Harm/Attempted Suicide', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 8))),
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
                      child: Center(child: Text(selectedTransferReport[Strings.selfHarmYes] == null || selectedTransferReport[Strings.selfHarmYes] == 0 ? '' : 'X', textAlign: TextAlign.center ,style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
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
                      child: Center(child: Text(selectedTransferReport[Strings.selfHarmNo] == null || selectedTransferReport[Strings.selfHarmNo] == 0 ? '' : 'X', textAlign: TextAlign.center ,style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
                ]
            ),
            Container(height: 5),
            selectedTransferReport[Strings.selfHarmYes] != null && selectedTransferReport[Strings.selfHarmYes] == 1 ? singleLineField('', selectedTransferReport[Strings.selfHarm]) : Container(),
            Container(height: 5),
            Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 90, child: Text('Alcohol / Substance Abuse', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 8))),
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
                      child: Center(child: Text(selectedTransferReport[Strings.alcoholSubstanceYes] == null || selectedTransferReport[Strings.alcoholSubstanceYes] == 0 ? '' : 'X', textAlign: TextAlign.center ,style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
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
                      child: Center(child: Text(selectedTransferReport[Strings.alcoholSubstanceNo] == null || selectedTransferReport[Strings.alcoholSubstanceNo] == 0 ? '' : 'X', textAlign: TextAlign.center ,style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
                ]
            ),
            Container(height: 5),
            selectedTransferReport[Strings.alcoholSubstanceYes] != null && selectedTransferReport[Strings.alcoholSubstanceYes] == 1 ? singleLineField('', selectedTransferReport[Strings.alcoholSubstance]) : Container(),
            Container(height: 5),
            Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 90, child: Text('Any known Blood Borne Viruses', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 8))),
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
                      child: Center(child: Text(selectedTransferReport[Strings.virusesYes] == null || selectedTransferReport[Strings.virusesYes] == 0 ? '' : 'X', textAlign: TextAlign.center ,style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
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
                      child: Center(child: Text(selectedTransferReport[Strings.virusesNo] == null || selectedTransferReport[Strings.virusesNo] == 0 ? '' : 'X', textAlign: TextAlign.center ,style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
                ]
            ),
            Container(height: 5),
            selectedTransferReport[Strings.virusesYes] != null && selectedTransferReport[Strings.virusesYes] == 1 ? singleLineField('', selectedTransferReport[Strings.viruses]) : Container(),
            Container(height: 5),
            Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 90, child: Text('Safeguarding Concerns', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 8))),
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
                      child: Center(child: Text(selectedTransferReport[Strings.safeguardingYes] == null || selectedTransferReport[Strings.safeguardingYes] == 0 ? '' : 'X', textAlign: TextAlign.center ,style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
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
                      child: Center(child: Text(selectedTransferReport[Strings.safeguardingNo] == null || selectedTransferReport[Strings.safeguardingNo] == 0 ? '' : 'X', textAlign: TextAlign.center ,style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
                ]
            ),
            Container(height: 5),
            selectedTransferReport[Strings.safeguardingYes] != null && selectedTransferReport[Strings.safeguardingYes] == 1 ? singleLineField('', selectedTransferReport[Strings.safeguarding]) : Container(),
            Container(height: 5),
            Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 90, child: Text('Physical Health Conditions', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 8))),
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
                      child: Center(child: Text(selectedTransferReport[Strings.physicalHealthConditionsYes] == null || selectedTransferReport[Strings.physicalHealthConditionsYes] == 0 ? '' : 'X', textAlign: TextAlign.center ,style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
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
                      child: Center(child: Text(selectedTransferReport[Strings.physicalHealthConditionsNo] == null || selectedTransferReport[Strings.physicalHealthConditionsNo] == 0 ? '' : 'X', textAlign: TextAlign.center ,style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
                ]
            ),
            Container(height: 5),
            selectedTransferReport[Strings.physicalHealthConditionsYes] != null && selectedTransferReport[Strings.physicalHealthConditionsYes] == 1 ? singleLineField('', selectedTransferReport[Strings.physicalHealthConditions]) : Container(),
            Container(height: 5),
            Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 90, child: Text('Use of Weapon(s)', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 8))),
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
                      child: Center(child: Text(selectedTransferReport[Strings.useOfWeaponYes] == null || selectedTransferReport[Strings.useOfWeaponYes] == 0 ? '' : 'X', textAlign: TextAlign.center ,style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
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
                      child: Center(child: Text(selectedTransferReport[Strings.useOfWeaponNo] == null || selectedTransferReport[Strings.useOfWeaponNo] == 0 ? '' : 'X', textAlign: TextAlign.center ,style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
                ]
            ),
            Container(height: 5),
            selectedTransferReport[Strings.useOfWeaponYes] != null && selectedTransferReport[Strings.useOfWeaponYes] == 1 ? singleLineField('', selectedTransferReport[Strings.useOfWeapon]) : Container(),
            Container(height: 5),
            Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 90, child: Text('Absconsion Risk', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 8))),
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
                      child: Center(child: Text(selectedTransferReport[Strings.absconsionRiskYes] == null || selectedTransferReport[Strings.absconsionRiskYes] == 0 ? '' : 'X', textAlign: TextAlign.center ,style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
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
                      child: Center(child: Text(selectedTransferReport[Strings.absconsionRiskNo] == null || selectedTransferReport[Strings.absconsionRiskNo] == 0 ? '' : 'X', textAlign: TextAlign.center ,style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
                ]
            ),
            Container(height: 10),
            selectedTransferReport[Strings.absconsionRiskYes] != null && selectedTransferReport[Strings.absconsionRiskYes] == 1 ? singleLineField('', selectedTransferReport[Strings.absconsionRisk]) : Container(),


            sectionTitle('Patient Property'),
            Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 90),
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
                      child: Center(child: Text(selectedTransferReport[Strings.patientPropertyYes] == null || selectedTransferReport[Strings.patientPropertyYes] == 0 ? '' : 'X', textAlign: TextAlign.center ,style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
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
                      child: Center(child: Text(selectedTransferReport[Strings.patientPropertyNo] == null || selectedTransferReport[Strings.patientPropertyNo] == 0 ? '' : 'X', textAlign: TextAlign.center ,style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
                ]
            ),
            Container(height: 5),

            selectedTransferReport[Strings.patientPropertyYes] != null && selectedTransferReport[Strings.patientPropertyYes] == 1 ? Column (
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 90, child: Text('Patient Property Received', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 8))),
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
                          child: Center(child: Text(selectedTransferReport[Strings.patientPropertyReceivedYes] == null || selectedTransferReport[Strings.patientPropertyReceivedYes] == 0 ? '' : 'X', textAlign: TextAlign.center ,style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
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
                          child: Center(child: Text(selectedTransferReport[Strings.patientPropertyReceivedNo] == null || selectedTransferReport[Strings.patientPropertyReceivedNo] == 0 ? '' : 'X', textAlign: TextAlign.center ,style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
                    ]
                ),
                Container(height: 5),
                selectedTransferReport[Strings.patientPropertyReceivedYes] != null && selectedTransferReport[Strings.patientPropertyReceivedYes] == 1 ? Column(
                  children: [
                    singleLineField('', selectedTransferReport[Strings.patientPropertyReceived]),
                    Container(height: 5),

                  ]
                ) : Container(),
              ]
            ) : Container(),


            Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 90, child: Text('Patient Notes Received', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 8))),
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
                      child: Center(child: Text(selectedTransferReport[Strings.patientNotesReceivedYes] == null || selectedTransferReport[Strings.patientNotesReceivedYes] == 0 ? '' : 'X', textAlign: TextAlign.center ,style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
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
                      child: Center(child: Text(selectedTransferReport[Strings.patientNotesReceivedNo] == null || selectedTransferReport[Strings.patientNotesReceivedNo] == 0 ? '' : 'X', textAlign: TextAlign.center ,style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
                ]
            ),
            Container(height: 5),
            selectedTransferReport[Strings.patientNotesReceivedYes] != null && selectedTransferReport[Strings.patientNotesReceivedYes] == 1 ? singleLineField(' ', selectedTransferReport[Strings.patientNotesReceived]) : Container(),



            sectionTitle('Patient Checks'),
            Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 90, child: Text('Patient Been Searched/Wanded', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 8))),
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
                      child: Center(child: Text(selectedTransferReport[Strings.patientSearchedYes] == null || selectedTransferReport[Strings.patientSearchedYes] == 0 ? '' : 'X', textAlign: TextAlign.center ,style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
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
                      child: Center(child: Text(selectedTransferReport[Strings.patientSearchedNo] == null || selectedTransferReport[Strings.patientSearchedNo] == 0 ? '' : 'X', textAlign: TextAlign.center ,style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
                ]
            ),
            Container(height: 5),
            Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 90, child: Text('Any Items Removed', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 8))),
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
                      child: Center(child: Text(selectedTransferReport[Strings.itemsRemovedYes] == null || selectedTransferReport[Strings.itemsRemovedYes] == 0 ? '' : 'X', textAlign: TextAlign.center ,style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
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
                      child: Center(child: Text(selectedTransferReport[Strings.itemsRemovedNo] == null || selectedTransferReport[Strings.itemsRemovedNo] == 0 ? '' : 'X', textAlign: TextAlign.center ,style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
                ]
            ),
            Container(height: 5),
            selectedTransferReport[Strings.itemsRemovedYes] != null && selectedTransferReport[Strings.itemsRemovedYes] == 1 ? singleLineField('', selectedTransferReport[Strings.itemsRemoved]) : Container(),
            singleLineField('Patient informed and understands what is happening and involved in decision making', selectedTransferReport[Strings.patientInformed]),
            singleLineField('Injuries noted at collection', selectedTransferReport[Strings.injuriesNoted]),
          ]

      ));

      pdf.addPage(MultiPage(
          theme: Theme.withFont(base: ttf, bold: ttfBold),
          pageFormat: PdfPageFormat.a4,
          crossAxisAlignment: CrossAxisAlignment.start,
          margin: EdgeInsets.all(40),
          footer: (Context context) {
            return Container(
                alignment: Alignment.centerRight,
                margin: const EdgeInsets.only(top: 5),
                child: Text('Transfer Report - Page ${context.pageNumber} of ${context.pagesCount}',
                    style: TextStyle(color: PdfColors.grey, fontSize: 8)));
          },
          build: (Context context) => <Widget>[


            Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sectionTitle('Job Ref'),
                  SizedBox(width: 10),
                  textField(TextOption.PlainText, selectedTransferReport[Strings.jobRef]),
                ]
            ),
            Center(child: Text('BODY MAP', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontWeight: FontWeight.bold))),
            Center(child: Text('To be used before leaving the unit with any patient', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 8))),
            selectedTransferReport[Strings.bodyMapImage] == null ? Center(child: Image(bodyMapEmpty)) : Center(child: Image(PdfImage(pdfDoc,
                image: bodyMapImage.data.buffer
                    .asUint8List(),
                width: bodyMapImage.width,
                height: bodyMapImage.height))),

            Container(height: 10),
            Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 90, child: Text('Received medical attention in the last 24 hours', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 8))),
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
                      child: Center(child: Text(selectedTransferReport[Strings.medicalAttentionYes] == null || selectedTransferReport[Strings.medicalAttentionYes] == 0 ? '' : 'X', textAlign: TextAlign.center ,style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
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
                      child: Center(child: Text(selectedTransferReport[Strings.medicalAttentionNo] == null || selectedTransferReport[Strings.medicalAttentionNo] == 0 ? '' : 'X', textAlign: TextAlign.center ,style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
                ]
            ),
            selectedTransferReport[Strings.medicalAttentionYes] != null && selectedTransferReport[Strings.medicalAttentionYes] == 1 ? singleLineField('', selectedTransferReport[Strings.medicalAttention]) : Container(),
            Container(height: 5),
            singleLineField('Current Medication (inc. time last administered)', selectedTransferReport[Strings.currentMedication]),
            Container(height: 5),
            singleLineField('Last Recorded Physical Observations', selectedTransferReport[Strings.physicalObservations]),
            Container(height: 5),
            Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 90, child: Text('Any other Relevant Information (including rapid tranquilisation)', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 8))),
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
                      child: Center(child: Text(selectedTransferReport[Strings.relevantInformationYes] == null || selectedTransferReport[Strings.relevantInformationYes] == 0 ? '' : 'X', textAlign: TextAlign.center ,style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
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
                      child: Center(child: Text(selectedTransferReport[Strings.relevantInformationNo] == null || selectedTransferReport[Strings.relevantInformationNo] == 0 ? '' : 'X', textAlign: TextAlign.center ,style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
                ]
            ),
            selectedTransferReport[Strings.relevantInformationYes] != null && selectedTransferReport[Strings.relevantInformationYes] == 1 ? singleLineField('', selectedTransferReport[Strings.relevantInformation]) : Container(),
          ]

      ));

      pdf.addPage(MultiPage(
          theme: Theme.withFont(base: ttf, bold: ttfBold),
          pageFormat: PdfPageFormat.a4,
          crossAxisAlignment: CrossAxisAlignment.start,
          margin: EdgeInsets.all(40),
          footer: (Context context) {
            return Container(
                alignment: Alignment.centerRight,
                margin: const EdgeInsets.only(top: 5),
                child: Text('Transfer Report - Page ${context.pageNumber} of ${context.pagesCount}',
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
                          textField(TextOption.PlainText, selectedTransferReport[Strings.jobRef]),
                        ]),
                        Container(height: 5),
                        Row(children: [
                          sectionTitle('Date'),
                          SizedBox(width: 20),
                          textField(TextOption.Date, selectedTransferReport[Strings.date]),
                        ])
                      ]
                  ),

                  Container(height: 50, child: Image(pegasusLogo)),

                ]
            ),
            Container(height: 10),
            Center(child: Text('TRANSFER REPORT', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontWeight: FontWeight.bold))),
            Container(height: 20),
            tripleLineField('Start Time', selectedTransferReport[Strings.startTime], 'Finish Time', selectedTransferReport[Strings.finishTime], 'Total Hours', selectedTransferReport[Strings.totalHours], TextOption.Time, TextOption.Time, TextOption.PlainText),
            singleLineField('Collection Details', selectedTransferReport[Strings.collectionDetails]),
            doubleLineField('Postcode', selectedTransferReport[Strings.collectionPostcode], 'Contact No.', selectedTransferReport[Strings.collectionContactNo]),
            singleLineField('Destination Details', selectedTransferReport[Strings.destinationDetails]),
            doubleLineField('Postcode', selectedTransferReport[Strings.destinationPostcode], 'Contact No.', selectedTransferReport[Strings.destinationContactNo]),
            doubleLineField('Collection arrival time', selectedTransferReport[Strings.collectionArrivalTime], 'Collection departure time', selectedTransferReport[Strings.collectionDepartureTime], TextOption.Time, TextOption.Time),
            doubleLineField('Destination arrival time', selectedTransferReport[Strings.destinationArrivalTime], 'Destination departure time', selectedTransferReport[Strings.destinationDepartureTime], TextOption.Time, TextOption.Time),
            singleLineField('Vehicle Reg No.', selectedTransferReport[Strings.vehicleRegNo]),
            tripleLineField('Start Mileage', selectedTransferReport[Strings.startMileage], 'Finish Mileage', selectedTransferReport[Strings.finishMileage], 'Total Mileage', selectedTransferReport[Strings.totalMileage], TextOption.EncryptedText, TextOption.EncryptedText, TextOption.EncryptedText),
            Container(height: 3),

            Row(
              children: [
                Expanded(child: Text('Name', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 8))),
                Expanded(child: Text('Role', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 8))),
                Expanded(child: Text('Driving Times', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 8))),
                Expanded(child: Text('Driving Times', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 8))),
              ]
            ),
            Container(height: 2),
            drivingTimesRow(selectedTransferReport[Strings.name1], selectedTransferReport[Strings.role1], selectedTransferReport[Strings.drivingTimes1_1], selectedTransferReport[Strings.drivingTimes1_2]),
            selectedTransferReport[Strings.name2] == null || selectedTransferReport[Strings.name2] == '' ? Container() : drivingTimesRow(selectedTransferReport[Strings.name2], selectedTransferReport[Strings.role2], selectedTransferReport[Strings.drivingTimes2_1], selectedTransferReport[Strings.drivingTimes2_2]),
            selectedTransferReport[Strings.name3] == null || selectedTransferReport[Strings.name3] == '' ? Container() : drivingTimesRow(selectedTransferReport[Strings.name3], selectedTransferReport[Strings.role3], selectedTransferReport[Strings.drivingTimes3_1], selectedTransferReport[Strings.drivingTimes3_2]),
            selectedTransferReport[Strings.name4] == null || selectedTransferReport[Strings.name4] == '' ? Container() : drivingTimesRow(selectedTransferReport[Strings.name4], selectedTransferReport[Strings.role4], selectedTransferReport[Strings.drivingTimes4_1], selectedTransferReport[Strings.drivingTimes4_2]),
            selectedTransferReport[Strings.name5] == null || selectedTransferReport[Strings.name5] == '' ? Container() : drivingTimesRow(selectedTransferReport[Strings.name5], selectedTransferReport[Strings.role5], selectedTransferReport[Strings.drivingTimes5_1], selectedTransferReport[Strings.drivingTimes5_2]),
            // drivingTimesRow(selectedTransferReport[Strings.name6], selectedTransferReport[Strings.role6], selectedTransferReport[Strings.drivingTimes6_1], selectedTransferReport[Strings.drivingTimes6_2]),
            // drivingTimesRow(selectedTransferReport[Strings.name7], selectedTransferReport[Strings.role7], selectedTransferReport[Strings.drivingTimes7_1], selectedTransferReport[Strings.drivingTimes7_2]),
            // drivingTimesRow(selectedTransferReport[Strings.name8], selectedTransferReport[Strings.role8], selectedTransferReport[Strings.drivingTimes8_1], selectedTransferReport[Strings.drivingTimes8_2]),
            // drivingTimesRow(selectedTransferReport[Strings.name9], selectedTransferReport[Strings.role9], selectedTransferReport[Strings.drivingTimes9_1], selectedTransferReport[Strings.drivingTimes9_2]),
            // drivingTimesRow(selectedTransferReport[Strings.name10], selectedTransferReport[Strings.role10], selectedTransferReport[Strings.drivingTimes10_1], selectedTransferReport[Strings.drivingTimes10_2]),
            // drivingTimesRow(selectedTransferReport[Strings.name11], selectedTransferReport[Strings.role11], selectedTransferReport[Strings.drivingTimes11_1], selectedTransferReport[Strings.drivingTimes11_2]),
          ]

      ));

      pdf.addPage(MultiPage(
          theme: Theme.withFont(base: ttf, bold: ttfBold),
          pageFormat: PdfPageFormat.a4,
          crossAxisAlignment: CrossAxisAlignment.start,
          margin: EdgeInsets.all(40),
          footer: (Context context) {
            return Container(
                alignment: Alignment.centerRight,
                margin: const EdgeInsets.only(top: 5),
                child: Text('Transfer Report - Page ${context.pageNumber} of ${context.pagesCount}',
                    style: TextStyle(color: PdfColors.grey, fontSize: 8)));
          },
          build: (Context context) => <Widget>[

            doubleLineField('Name', selectedTransferReport[Strings.jobRef], 'Date', selectedTransferReport[Strings.dateOfBirth], TextOption.PlainText, TextOption.EncryptedDate),
            Container(height: 20),
            Center(child: Text('TRANSFER REPORT', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontWeight: FontWeight.bold))),
            Center(child: Text('Patient Report - please include: mental state, risk, physical health concerns, delays', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontWeight: FontWeight.bold, fontSize: 8))),
            Container(height: 20),
            textField(TextOption.EncryptedText, selectedTransferReport[Strings.patientReport], 700, 550, 550),
            Container(height: 10),
            doubleLineField('Print Name', selectedTransferReport[Strings.patientReportPrintName], 'Role', selectedTransferReport[Strings.patientReportRole]),
            doubleLineField('Signed', 'signature', 'Date', selectedTransferReport[Strings.patientReportDate], TextOption.PlainText, TextOption.Date, patientReportSignatureImage, pdfDoc),
            singleLineField('Time', selectedTransferReport[Strings.patientReportTime], TextOption.Time, true)


          ]

      ));

      pdf.addPage(MultiPage(
          theme: Theme.withFont(base: ttf, bold: ttfBold),
          pageFormat: PdfPageFormat.a4,
          crossAxisAlignment: CrossAxisAlignment.start,
          margin: EdgeInsets.all(40),
          footer: (Context context) {
            return Container(
                alignment: Alignment.centerRight,
                margin: const EdgeInsets.only(top: 5),
                child: Text('Transfer Report - Page ${context.pageNumber} of ${context.pagesCount}',
                    style: TextStyle(color: PdfColors.grey, fontSize: 8)));
          },
          build: (Context context) => <Widget>[

            Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sectionTitle('Job Ref'),
                  SizedBox(width: 10),
                  textField(TextOption.PlainText, selectedTransferReport[Strings.jobRef]),
                ]
            ),
            Container(height: 10),
            Center(child: Text('TRANSFER REPORT', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontWeight: FontWeight.bold))),
            Container(height: 10),
            sectionTitle('Collection Details'),
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('This is a legal and binding document and will be retained by the company for reference of any incidents that may occur in the event that we have been given any incorrect information. By signing this form, you are satisfied that all property, section papers and documents listed within this report have been handed over to Pegasus Medical (1808) Ltd.', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 9)),
                  Container(height: 5)
                ]
            ),
            sectionTitle('Section Papers handed over if required.'),
            doubleLineField('Unit', selectedTransferReport[Strings.collectionUnit], 'Postion', selectedTransferReport[Strings.collectionPosition]),
            doubleLineField('Print Name', selectedTransferReport[Strings.collectionPrintName], 'Signed', 'signature', TextOption.EncryptedText, TextOption.PlainText, collectionSignatureImage, pdfDoc),
            singleLineField('Time', selectedTransferReport[Strings.collectionArrivalTimeEnd], TextOption.Time, true),
            sectionTitle('Destination Details'),
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('This is a legal and binding document and will be retained by the company for reference of any incidents that may occur in the event that we have been given any incorrect information. By signing this form, you are satisfied that all property, section papers and documents listed within this report have been handed over to Pegasus Medical (1808) Ltd.', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 9)),
                  Container(height: 5)
                ]
            ),
            sectionTitle('Section Papers handed over if required.'),
            doubleLineField('Unit', selectedTransferReport[Strings.destinationUnit], 'Postion', selectedTransferReport[Strings.destinationPosition]),
            doubleLineField('Print Name', selectedTransferReport[Strings.destinationPrintName], 'Signed', 'signature', TextOption.EncryptedText, TextOption.PlainText, destinationSignatureImage, pdfDoc),
            singleLineField('Time', selectedTransferReport[Strings.destinationArrivalTimeEnd], TextOption.Time, true)







          ]

      ));


      pdf.addPage(MultiPage(
          theme: Theme.withFont(base: ttf, bold: ttfBold),
          pageFormat: PdfPageFormat.a4,
          crossAxisAlignment: CrossAxisAlignment.start,
          margin: EdgeInsets.all(40),
          footer: (Context context) {
            return Container(
                alignment: Alignment.centerRight,
                margin: const EdgeInsets.only(top: 5),
                child: Text('Transfer Report - Page ${context.pageNumber} of ${context.pagesCount}',
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
                          textField(TextOption.PlainText, selectedTransferReport[Strings.jobRef]),
                        ]),
                        Container(height: 5),
                        Row(children: [
                          sectionTitle('Date'),
                          SizedBox(width: 20),
                          textField(TextOption.Date, selectedTransferReport[Strings.date]),
                        ])
                      ]
                  ),

                  Container(height: 50, child: Image(pegasusLogo)),

                ]
            ),
            Container(height: 10),
            Center(child: Text('TRANSFER REPORT', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontWeight: FontWeight.bold))),
            Container(height: 5),
            Center(child: Text('HANDCUFF FORM', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontWeight: FontWeight.bold))),
            Container(height: 5),
            Center(child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Handcuffs used', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 8, fontWeight: FontWeight.bold)),
                    Container(width: 10),
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
                        child: Center(child: Text(selectedTransferReport[Strings.handcuffsUsedYes] == null || selectedTransferReport[Strings.handcuffsUsedYes] == 0 ? '' : 'X', textAlign: TextAlign.center ,style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
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
                        child: Center(child: Text(selectedTransferReport[Strings.handcuffsUsedNo] == null || selectedTransferReport[Strings.handcuffsUsedNo] == 0 ? '' : 'X', textAlign: TextAlign.center ,style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
                  ]
              ),
              Container(height: 5),
              Text('If yes please complete incident form', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 8)),
              Container(height: 5),
            ])),
            doubleLineField('Date', selectedTransferReport[Strings.handcuffsDate], 'Time Handcuffs Applied', selectedTransferReport[Strings.handcuffsTime], TextOption.Date, TextOption.Time),
            doubleLineField('Authorised by', selectedTransferReport[Strings.handcuffsAuthorisedBy], 'Handcuffs Applied by', selectedTransferReport[Strings.handcuffsAppliedBy]),
            singleLineField('Time Handcuffs Removed', selectedTransferReport[Strings.handcuffsRemovedTime], TextOption.Time),
            singleLineField('PHYSICAL INTERVENTION: ', selectedTransferReport[Strings.physicalIntervention]),
            Text('Why was the intervention required?', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 8)),
            Container(height: 5),
            textField(TextOption.EncryptedText, selectedTransferReport[Strings.whyInterventionRequired], 700, 200, 200),
            Container(height: 5),

            sectionTitle('TECHNIQUE & POSITION'),
            Row(
                children: [
                  Expanded(child: Text('Staff Name', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 8))),
                  Expanded(child: Text('Technique', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 8))),
                  Expanded(child: Text('Position', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 8))),
                ]
            ),
            Container(height: 5),
            techniquePositionRow(selectedTransferReport[Strings.techniqueName1], selectedTransferReport[Strings.technique1], selectedTransferReport[Strings.techniquePosition1]),

            selectedTransferReport[Strings.techniqueName2] == null || selectedTransferReport[Strings.techniqueName2] == '' ? Container() : techniquePositionRow(selectedTransferReport[Strings.techniqueName2], selectedTransferReport[Strings.technique2], selectedTransferReport[Strings.techniquePosition2]),
            selectedTransferReport[Strings.techniqueName3] == null || selectedTransferReport[Strings.techniqueName3] == '' ? Container() : techniquePositionRow(selectedTransferReport[Strings.techniqueName3], selectedTransferReport[Strings.technique3], selectedTransferReport[Strings.techniquePosition3]),
            selectedTransferReport[Strings.techniqueName4] == null || selectedTransferReport[Strings.techniqueName4] == '' ? Container() : techniquePositionRow(selectedTransferReport[Strings.techniqueName4], selectedTransferReport[Strings.technique4], selectedTransferReport[Strings.techniquePosition4]),
            selectedTransferReport[Strings.techniqueName5] == null || selectedTransferReport[Strings.techniqueName5] == '' ? Container() : techniquePositionRow(selectedTransferReport[Strings.techniqueName5], selectedTransferReport[Strings.technique5], selectedTransferReport[Strings.techniquePosition5]),
            selectedTransferReport[Strings.techniqueName6] == null || selectedTransferReport[Strings.techniqueName6] == '' ? Container() : techniquePositionRow(selectedTransferReport[Strings.techniqueName6], selectedTransferReport[Strings.technique6], selectedTransferReport[Strings.techniquePosition6]),
            selectedTransferReport[Strings.techniqueName7] == null || selectedTransferReport[Strings.techniqueName7] == '' ? Container() : techniquePositionRow(selectedTransferReport[Strings.techniqueName7], selectedTransferReport[Strings.technique7], selectedTransferReport[Strings.techniquePosition7]),
            selectedTransferReport[Strings.techniqueName8] == null || selectedTransferReport[Strings.techniqueName8] == '' ? Container() : techniquePositionRow(selectedTransferReport[Strings.techniqueName8], selectedTransferReport[Strings.technique8], selectedTransferReport[Strings.techniquePosition8]),
            selectedTransferReport[Strings.techniqueName9] == null || selectedTransferReport[Strings.techniqueName9] == '' ? Container() : techniquePositionRow(selectedTransferReport[Strings.techniqueName9], selectedTransferReport[Strings.technique9], selectedTransferReport[Strings.techniquePosition9]),
            selectedTransferReport[Strings.techniqueName10] == null || selectedTransferReport[Strings.techniqueName10] == '' ? Container() : techniquePositionRow(selectedTransferReport[Strings.techniqueName10], selectedTransferReport[Strings.technique10], selectedTransferReport[Strings.techniquePosition10]),

            Container(height: 5),
            doubleLineField('Time Intervention Commenced', selectedTransferReport[Strings.timeInterventionCommenced], 'Time Intervention Completed', selectedTransferReport[Strings.timeInterventionCompleted], TextOption.Time, TextOption.Time),
          ]

      ));

      if(selectedTransferReport[Strings.handcuffsUsedYes] != null && selectedTransferReport[Strings.handcuffsUsedYes] == 1){

        pdf.addPage(MultiPage(
            theme: Theme.withFont(base: ttf, bold: ttfBold),
            pageFormat: PdfPageFormat.a4,
            crossAxisAlignment: CrossAxisAlignment.start,
            margin: EdgeInsets.all(40),
            footer: (Context context) {
              return Container(
                  alignment: Alignment.centerRight,
                  margin: const EdgeInsets.only(top: 5),
                  child: Text('Transfer Report - Page ${context.pageNumber} of ${context.pagesCount}',
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
                            textField(TextOption.PlainText, selectedTransferReport[Strings.jobRef]),
                          ]),
                        ]
                    ),

                    Container(height: 50, child: Image(pegasusLogo)),

                  ]
              ),
              Container(height: 10),
              Center(child: Text('INCIDENT REPORT FORM', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontWeight: FontWeight.bold))),
              Container(height: 20),
              doubleLineField('Date', selectedTransferReport[Strings.incidentDate], 'Time', selectedTransferReport[Strings.incidentTime], TextOption.Date, TextOption.Time),
              Container(height: 10),
              Text('Incident Details', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 10, fontWeight: FontWeight.bold)),
              Container(height: 5),
              textField(TextOption.EncryptedText, selectedTransferReport[Strings.incidentDetails], 700, 580, 580),
              Container(height: 10),
              Text('Incident Location', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 10, fontWeight: FontWeight.bold)),
              Container(height: 5),
              textField(TextOption.EncryptedText, selectedTransferReport[Strings.incidentLocation], 700, 50, 50),
              Container(height: 10),
              Text('What action did you take?', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 10, fontWeight: FontWeight.bold)),
              Container(height: 5),
              textField(TextOption.EncryptedText, selectedTransferReport[Strings.incidentAction], 700, 360, 360),
              Container(height: 10),
              Text('Staff involved', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 10, fontWeight: FontWeight.bold)),
              Container(height: 10),
              textField(TextOption.EncryptedText, selectedTransferReport[Strings.incidentStaffInvolved], 700, 150, 150),
              doubleLineField('Signed', 'signature', 'Date', selectedTransferReport[Strings.incidentSignatureDate], TextOption.PlainText, TextOption.Date, incidentSignatureImage, pdfDoc),
              singleLineField('Print Name', selectedTransferReport[Strings.incidentPrintName], TextOption.EncryptedText, true),

            ]

        ));

      }


      if(selectedTransferReport[Strings.hasSection2Checklist] != null && selectedTransferReport[Strings.hasSection2Checklist] == 1){
        pdf.addPage(MultiPage(
            theme: Theme.withFont(base: ttf, bold: ttfBold),
            pageFormat: PdfPageFormat.a4,
            crossAxisAlignment: CrossAxisAlignment.start,
            margin: EdgeInsets.all(40),
            footer: (Context context) {
              return Container(
                  alignment: Alignment.centerRight,
                  margin: const EdgeInsets.only(top: 5),
                  child: Text('Transfer Report - Page ${context.pageNumber} of ${context.pagesCount}',
                      style: TextStyle(color: PdfColors.grey, fontSize: 8)));
            },
            build: (Context context) => <Widget>[

              Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionTitle('Job Ref'),
                    SizedBox(width: 10),
                    textField(TextOption.PlainText, selectedTransferReport[Strings.jobRef]),
                  ]
              ),
              Container(height: 10),
              Center(child: Text('SECTION 2', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontWeight: FontWeight.bold))),
              Container(height: 5),
              Center(child: Text('CHECKLIST', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontWeight: FontWeight.bold))),
              Container(height: 10),
              doubleLineField('Name of Patient', selectedTransferReport[Strings.patientName], 'Job Ref', selectedTransferReport[Strings.jobRef], TextOption.EncryptedText, TextOption.PlainText),
              Container(height: 10),
              checkBoxTitle('FOR ALL DOCUMENTS ', '(please put an x in the appropriate box)'),
              yesNoCheckboxes('• is the patient correct name and address the same on all documents', selectedTransferReport[Strings.patientCorrectYes1], selectedTransferReport[Strings.patientCorrectNo1]),
              yesNoCheckboxes('• is the hospital name and address the same on the A1/A2', selectedTransferReport[Strings.hospitalCorrectYes1], selectedTransferReport[Strings.hospitalCorrectNo1]),
              checkBoxTitle('APPLICATION ', '(please put an x in the appropriate box)'),
              yesNoCheckboxes('• *is there an application on a Form A2?', selectedTransferReport[Strings.applicationFormYes1], selectedTransferReport[Strings.applicationFormNo1]),
              yesNoCheckboxes('• *is there Application A2 signed and dated by an Approved Mental Health Practitioner (AMHP)?', selectedTransferReport[Strings.applicationSignedYes1], selectedTransferReport[Strings.applicationSignedNo1]),
              yesNoCheckboxes('• *is the date on which the applicant last saw the patient within 14 days of the date of application?', selectedTransferReport[Strings.within14DaysYes1], selectedTransferReport[Strings.within14DaysNo1]),
              yesNoCheckboxes('• is the local authority name?', selectedTransferReport[Strings.localAuthorityNameYes1], selectedTransferReport[Strings.localAuthorityNameNo1]),
              checkBoxTitle('MEDICAL RECOMMENDATIONS  ', '(please put an x in the appropriate box)'),
              yesNoCheckboxes('• *have two medical recommendations been received, either on a Form A3 or two A4s?', selectedTransferReport[Strings.medicalRecommendationsFormYes1], selectedTransferReport[Strings.medicalRecommendationsFormNo1]),
              yesNoCheckboxes('• *have the medical recommendations been signed by the two doctors?', selectedTransferReport[Strings.medicalRecommendationsSignedYes1], selectedTransferReport[Strings.medicalRecommendationsSignedNo1]),
              yesNoCheckboxes('• *are the dates of the signature been signed by the two doctors?', selectedTransferReport[Strings.datesSignatureSignedYes], selectedTransferReport[Strings.datesSignatureSignedNo]),
              yesNoCheckboxes('• *are the dates of signature on both medical recommendations on or before the date of the application on Form A2?', selectedTransferReport[Strings.signatureDatesOnBeforeYes1], selectedTransferReport[Strings.signatureDatesOnBeforeNo1]),
              yesNoCheckboxes('• have the medical practitioners entered their full name and address?', selectedTransferReport[Strings.practitionersNameYes1], selectedTransferReport[Strings.practitionersNameNo1]),
              Container(height: 10),
              Text('*Indicates non-rectifiable errors. If the answer to question marked with * is NO, the documents must be declared invalid and there is no authority to detain the patient. New forms will have to be provided.', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 8)),
              // Container(height: 250),
              // doubleLineField('Checked By', selectedTransferReport[Strings.transferInCheckedBy1], 'Signature', 'signature', TextOption.EncryptedText, TextOption.PlainText, transferInSignature1Image, pdfDoc),
              // doubleLineField('Date', selectedTransferReport[Strings.transferInDate1], 'Position', selectedTransferReport[Strings.transferInDesignation1], TextOption.Date),
            ]

        ));

      }




      if(selectedTransferReport[Strings.hasSection3Checklist] != null && selectedTransferReport[Strings.hasSection3Checklist] == 1){

        pdf.addPage(MultiPage(
            theme: Theme.withFont(base: ttf, bold: ttfBold),
            pageFormat: PdfPageFormat.a4,
            crossAxisAlignment: CrossAxisAlignment.start,
            margin: EdgeInsets.all(40),
            footer: (Context context) {
              return Container(
                  alignment: Alignment.centerRight,
                  margin: const EdgeInsets.only(top: 5),
                  child: Text('Transfer Report - Page ${context.pageNumber} of ${context.pagesCount}',
                      style: TextStyle(color: PdfColors.grey, fontSize: 8)));
            },
            build: (Context context) => <Widget>[

              Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionTitle('Job Ref'),
                    SizedBox(width: 10),
                    textField(TextOption.PlainText, selectedTransferReport[Strings.jobRef]),
                  ]
              ),
              Container(height: 10),
              Center(child: Text('SECTION 3', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontWeight: FontWeight.bold))),
              Container(height: 5),
              Center(child: Text('CHECKLIST', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontWeight: FontWeight.bold))),
              Container(height: 10),
              doubleLineField('Name of Patient', selectedTransferReport[Strings.patientName], 'Job Ref', selectedTransferReport[Strings.jobRef], TextOption.EncryptedText, TextOption.PlainText),
              Container(height: 10),
              checkBoxTitle('FOR ALL DOCUMENTS ', '(please put an x in the appropriate box)'),
              yesNoCheckboxes('• is the patient correct name and address the same on all documents', selectedTransferReport[Strings.patientCorrectYes2], selectedTransferReport[Strings.patientCorrectNo2]),
              yesNoCheckboxes('• Is the hospital name and address the same on the A5/A6? (and H3 if the patient is detained at collection address)', selectedTransferReport[Strings.hospitalCorrectYes2], selectedTransferReport[Strings.hospitalCorrectNo2]),
              checkBoxTitle('APPLICATION ', '(please put an x in the appropriate box)'),
              yesNoCheckboxes('• *Is there an application on a Form A6?', selectedTransferReport[Strings.applicationFormYes2], selectedTransferReport[Strings.applicationFormNo2]),
              yesNoCheckboxes('• *Is there Application A6 signed and dated by an Approved Mental Health Practitioner (AMHP)?', selectedTransferReport[Strings.applicationSignedYes2], selectedTransferReport[Strings.applicationSignedNo2]),
              yesNoCheckboxes('• Is the AMHP identified by name and address?', selectedTransferReport[Strings.amhpIdentifiedYes], selectedTransferReport[Strings.amhpIdentifiedNo]),
              checkBoxTitle('MEDICAL RECOMMENDATIONS  ', '(please put an x in the appropriate box)'),
              yesNoCheckboxes('• *Have two medical recommendations been received, either on a Form A7 or two A8s?', selectedTransferReport[Strings.medicalRecommendationsFormYes2], selectedTransferReport[Strings.medicalRecommendationsFormNo2]),
              yesNoCheckboxes('• *Have the medical recommendations been signed by the two doctors?', selectedTransferReport[Strings.medicalRecommendationsSignedYes2], selectedTransferReport[Strings.medicalRecommendationsSignedNo2]),
              yesNoCheckboxes('• *Are there no more than 5 clear days between the dates of the two medical examinations?', selectedTransferReport[Strings.clearDaysYes2], selectedTransferReport[Strings.clearDaysNo2]),
              yesNoCheckboxes('• *Are the dates of signature on both medical recommendations on or before the date of the application on Form A6?', selectedTransferReport[Strings.signatureDatesOnBeforeYes2], selectedTransferReport[Strings.signatureDatesOnBeforeNo2]),
              yesNoCheckboxes('• Have the medical practitioners entered their full name and address?', selectedTransferReport[Strings.practitionersNameYes2], selectedTransferReport[Strings.practitionersNameNo2]),
              yesNoCheckboxes('• Do the two doctors agree on the hospital/unit where appropriate treatment is to be delivered?', selectedTransferReport[Strings.doctorsAgreeYes], selectedTransferReport[Strings.doctorsAgreeNo]),
              yesNoCheckboxes('• If separate medical recommendations have been completed have both doctors specified the location in writing on the A8', selectedTransferReport[Strings.separateMedicalRecommendationsYes], selectedTransferReport[Strings.separateMedicalRecommendationsNo]),
              Container(height: 10),
              Text('*Indicates non-rectifiable errors. If the answer to question marked with * is NO, the documents must be declared invalid and there is no authority to detain the patient. New forms will have to be provided.', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 8)),
              // Container(height: 200),
              // doubleLineField('Checked By', selectedTransferReport[Strings.transferInCheckedBy2], 'Signature', 'signature', TextOption.EncryptedText, TextOption.PlainText, transferInSignature2Image, pdfDoc),
              // doubleLineField('Date', selectedTransferReport[Strings.transferInDate2], 'Position', selectedTransferReport[Strings.transferInDesignation2], TextOption.Date),
            ]

        ));

      }


      if(selectedTransferReport[Strings.hasSection3TransferChecklist] != null && selectedTransferReport[Strings.hasSection3TransferChecklist] == 1){

        pdf.addPage(MultiPage(
            theme: Theme.withFont(base: ttf, bold: ttfBold),
            pageFormat: PdfPageFormat.a4,
            crossAxisAlignment: CrossAxisAlignment.start,
            margin: EdgeInsets.all(40),
            footer: (Context context) {
              return Container(
                  alignment: Alignment.centerRight,
                  margin: const EdgeInsets.only(top: 5),
                  child: Text('Transfer Report - Page ${context.pageNumber} of ${context.pagesCount}',
                      style: TextStyle(color: PdfColors.grey, fontSize: 8)));
            },
            build: (Context context) => <Widget>[

              Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionTitle('Job Ref'),
                    SizedBox(width: 10),
                    textField(TextOption.PlainText, selectedTransferReport[Strings.jobRef]),
                  ]
              ),
              Container(height: 10),
              Center(child: Text('SECTION 3', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontWeight: FontWeight.bold))),
              Container(height: 5),
              Center(child: Text('TRANSFER CHECKLIST', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontWeight: FontWeight.bold))),
              Container(height: 10),
              doubleLineField('Name of Patient', selectedTransferReport[Strings.patientName], 'Job Ref', selectedTransferReport[Strings.jobRef], TextOption.EncryptedText, TextOption.PlainText),
              Container(height: 10),
              checkBoxTitle('FOR ALL DOCUMENTS ', '(please put an x in the appropriate box)'),
              yesNoCheckboxes('• is the patient correct name and address the same on all documents', selectedTransferReport[Strings.patientCorrectYes3], selectedTransferReport[Strings.patientCorrectNo3]),
              yesNoCheckboxes('• Is the hospital name and address the same on the A5/A6? (and H3 if the patient is detained at collection address)', selectedTransferReport[Strings.hospitalCorrectYes3], selectedTransferReport[Strings.hospitalCorrectNo3]),
              yesNoCheckboxes('• Is there a H4 (Section 19 transfer) with Part 1 completed by transferring hospital made out from and to the correct hospitals?', selectedTransferReport[Strings.h4Yes], selectedTransferReport[Strings.h4No]),
              yesNoCheckboxes('• Is there a current consent to treatment document (T2 or T3)', selectedTransferReport[Strings.currentConsentYes], selectedTransferReport[Strings.currentConsentNo]),
              checkBoxTitle('ON THE ORIGINAL APPLICATION ', '(please put an x in the appropriate box)'),
              yesNoCheckboxes('• *Is there an application on a Form A6?', selectedTransferReport[Strings.applicationFormYes3], selectedTransferReport[Strings.applicationFormNo3]),
              yesNoCheckboxes('• *Is there Application A6 signed and dated by an Approved Mental Health Practitioner (AMHP)?', selectedTransferReport[Strings.applicationSignedYes3], selectedTransferReport[Strings.applicationSignedNo3]),
              yesNoCheckboxes('• *Is the date on which the applicant last saw the patient within 14 days of the date of application?', selectedTransferReport[Strings.within14DaysYes3], selectedTransferReport[Strings.within14DaysNo3]),
              yesNoCheckboxes('• Is the local authority named?', selectedTransferReport[Strings.localAuthorityNameYes3], selectedTransferReport[Strings.localAuthorityNameNo3]),
              yesNoCheckboxes('• Has the nearest relative been consulted by the AMHP and has the full name and address of the nearest relative been entered on the form?', selectedTransferReport[Strings.nearestRelativeYes], selectedTransferReport[Strings.nearestRelativeNo]),
              yesNoCheckboxes('• If not, has the AMHP identified why consultation did not take place?', selectedTransferReport[Strings.amhpConsultationYes], selectedTransferReport[Strings.amhpConsultationNo]),
              yesNoCheckboxes('• If neither medical practitioners completing the recommendations knew the patient prior to the application, does the application form contain an explanation?', selectedTransferReport[Strings.knewPatientYes], selectedTransferReport[Strings.knewPatientNo]),

              checkBoxTitle('MEDICAL RECOMMENDATIONS  ', '(please put an x in the appropriate box)'),

              yesNoCheckboxes('• *Have two medical recommendations been received, either on a Form A7 or two A8s?', selectedTransferReport[Strings.medicalRecommendationsFormYes3], selectedTransferReport[Strings.medicalRecommendationsFormNo3]),
              yesNoCheckboxes('• *Have the medical recommendations been signed by the two doctors?', selectedTransferReport[Strings.medicalRecommendationsSignedYes3], selectedTransferReport[Strings.medicalRecommendationsSignedNo3]),
              yesNoCheckboxes('• *Are there no more than 5 clear days between the dates of the two medical examinations?', selectedTransferReport[Strings.clearDaysYes3], selectedTransferReport[Strings.clearDaysNo3]),
              yesNoCheckboxes('• *Is one of the medical recommendations signed by doctor approved for the purpose of the Section 12 of the Act', selectedTransferReport[Strings.approvedSection12Yes], selectedTransferReport[Strings.approvedSection12No]),
              yesNoCheckboxes('• *Are the dates of signature on both medical recommendations on or before the date of the application on Form A6?', selectedTransferReport[Strings.signatureDatesOnBeforeYes3], selectedTransferReport[Strings.signatureDatesOnBeforeNo3]),
              yesNoCheckboxes('• Have the medical practitioners entered their full name and address?', selectedTransferReport[Strings.practitionersNameYes3], selectedTransferReport[Strings.practitionersNameNo3]),
              yesNoCheckboxes('• Is one of the medical recommendations signed by doctor previously acquainted with the patient?', selectedTransferReport[Strings.previouslyAcquaintedYes], selectedTransferReport[Strings.previouslyAcquaintedNo]),
              yesNoCheckboxes('• If NO, has the paragraph set aside on Form A6 been completed, explaining why this is not so?', selectedTransferReport[Strings.acquaintedIfNoYes], selectedTransferReport[Strings.acquaintedIfNoNo]),
              yesNoCheckboxes('• Are the two doctors making the recommendations from different teams?', selectedTransferReport[Strings.recommendationsDifferentTeamsYes], selectedTransferReport[Strings.recommendationsDifferentTeamsNo]),
              yesNoCheckboxes('• On the original detention papers is the name of the hospital/unit specified where appropriate treatment is to be delivered?', selectedTransferReport[Strings.originalDetentionPapersYes], selectedTransferReport[Strings.originalDetentionPapersNo]),

              Container(height: 10),
              Text('*Indicates non-rectifiable errors. If the answer to question marked with * is NO, the documents must be declared invalid and there is no authority to detain the patient. New forms will have to be provided.', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 8)),
              // Container(height: 10),
              // doubleLineField('Checked By', selectedTransferReport[Strings.transferInCheckedBy3], 'Signature', 'signature', TextOption.EncryptedText, TextOption.PlainText, transferInSignature3Image, pdfDoc),
              // doubleLineField('Date', selectedTransferReport[Strings.transferInDate3], 'Position', selectedTransferReport[Strings.transferInDesignation3], TextOption.Date),
            ]

        ));

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
                child: Text('Transfer Report - Page ${context.pageNumber} of ${context.pagesCount}',
                    style: TextStyle(color: PdfColors.grey, fontSize: 8)));
          },
          build: (Context context) => <Widget>[

            Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sectionTitle('Job Ref'),
                  SizedBox(width: 10),
                  textField(TextOption.PlainText, selectedTransferReport[Strings.jobRef]),
                ]
            ),
            Container(height: 10),
            Center(child: Text('TRANSFER REPORT', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontWeight: FontWeight.bold))),
            Container(height: 5),
            Center(child: Text('PATIENT FEEDBACK FORM', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontWeight: FontWeight.bold))),
            Container(height: 10),
            yesNoCheckboxes('• Whilst travelling with us today have you felt safe?', selectedTransferReport[Strings.feltSafeYes], selectedTransferReport[Strings.feltSafeNo]),
            yesNoCheckboxes('• Staff introduced themselves to me and they were friendly?', selectedTransferReport[Strings.staffIntroducedYes], selectedTransferReport[Strings.staffIntroducedNo]),
            yesNoCheckboxes('• My overall experience was positive?', selectedTransferReport[Strings.experiencePositiveYes], selectedTransferReport[Strings.experiencePositiveNo]),
            Container(height: 20),
            Text('PLEASE SHARE ANY OTHER COMMENTS', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 8)),
            Container(height: 10),
            textField(TextOption.EncryptedText, selectedTransferReport[Strings.otherComments], 700, 550, 550),
          ]

      ));

      pdf.addPage(MultiPage(
          theme: Theme.withFont(base: ttf, bold: ttfBold),
          pageFormat: PdfPageFormat.a4,
          crossAxisAlignment: CrossAxisAlignment.start,
          margin: EdgeInsets.all(40),
          footer: (Context context) {
            return Container(
                alignment: Alignment.centerRight,
                margin: const EdgeInsets.only(top: 5),
                child: Text('Transfer Report - Page ${context.pageNumber} of ${context.pagesCount}',
                    style: TextStyle(color: PdfColors.grey, fontSize: 8)));
          },
          build: (Context context) => <Widget>[

            Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sectionTitle('Job Ref'),
                  SizedBox(width: 10),
                  textField(TextOption.PlainText, selectedTransferReport[Strings.jobRef]),
                ]
            ),
            Container(height: 10),
            Center(child: Text('TRANSFER REPORT', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontWeight: FontWeight.bold))),
            Container(height: 5),
            Center(child: Text('PRE-TRANSFER VEHICLE CHECKLIST', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontWeight: FontWeight.bold))),
            Container(height: 10),
            doubleLineField('Completed by', selectedTransferReport[Strings.vehicleCompletedBy1], 'Date', selectedTransferReport[Strings.vehicleDate], TextOption.EncryptedText, TextOption.Date),
            doubleLineField('Ambulance Reg', selectedTransferReport[Strings.ambulanceReg], 'Time', selectedTransferReport[Strings.vehicleTime], TextOption.EncryptedText, TextOption.Time),
            doubleLineField('Start Mileage', selectedTransferReport[Strings.startMileage], 'Fuel to the nearest 1/4 tank', selectedTransferReport[Strings.nearestTank1]),
            yesNoCheckboxes('• Was the ambulance left clean and tidy?', selectedTransferReport[Strings.ambulanceTidyYes1], selectedTransferReport[Strings.ambulanceTidyNo1]),
            yesNoCheckboxes('• Ambulance lights working?', selectedTransferReport[Strings.lightsWorkingYes], selectedTransferReport[Strings.lightsWorkingNo]),
            yesNoCheckboxes('• Tyres appear inflated fully?', selectedTransferReport[Strings.tyresInflatedYes], selectedTransferReport[Strings.tyresInflatedNo]),
            yesNoCheckboxes('• Vehicle warning signs showing?', selectedTransferReport[Strings.warningSignsYes], selectedTransferReport[Strings.warningSignsNo]),
            Container(height: 10),
            Center(child: Text('POST-TRANSFER VEHICLE CHECKLIST', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontWeight: FontWeight.bold))),
            Container(height: 10),
            doubleLineField('Completed by', selectedTransferReport[Strings.vehicleCompletedBy2], 'Fuel to the nearest 1/4 tank', selectedTransferReport[Strings.nearestTank2]),
            singleLineField('Finish Mileage', selectedTransferReport[Strings.finishMileage], TextOption.EncryptedText, true),
            yesNoCheckboxes('• Was the ambulance left clean and tidy?', selectedTransferReport[Strings.ambulanceTidyYes2], selectedTransferReport[Strings.ambulanceTidyNo2]),
            yesNoCheckboxes('• General clean & touch points', selectedTransferReport[Strings.sanitiserCleanYes], selectedTransferReport[Strings.sanitiserCleanNo]),
            Container(height: 10),
            Text('ANY ISSUES OR FAULTS PLEASE REPORT BELOW', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 8)),
            Container(height: 10),
            textField(TextOption.EncryptedText, selectedTransferReport[Strings.issuesFaults], 700, 300, 300),
          ]

      ));



      String formDate = selectedTransferReport[Strings.date] == null ? '' : dateFormatDay.format(DateTime.parse(selectedTransferReport[Strings.date]));
      String id = selectedTransferReport[Strings.documentId];



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
            ..download = 'transfer_report_form_${formDate}_$id.pdf';
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



        final File file = File('$pdfPath/transfer_report_${formDate}_$id.pdf');

        if(option == ShareOption.Email){
          file.writeAsBytesSync(pdf.save());
        }

        ConnectivityResult connectivityResult = await Connectivity().checkConnectivity();

        if(connectivityResult != ConnectivityResult.none) {

          if(option == ShareOption.Share) Printing.sharePdf(bytes: pdf.save(),filename: 'transfer_report_${formDate}_$id.pdf');
          if(option == ShareOption.Print) await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());

          if(option == ShareOption.Email) {
            final smtpServer = gmail(emailUsername, emailPassword);

            // Create our message.
            final mailmessage = new Message()
              ..from = new Address(emailUsername, 'Pegasus Medical')
              ..recipients = emailList
              ..subject = 'Completed Transfer Report'
              ..html = "<p1>Dear Sir/Madam,</p1>\n<p>Attached is a completed Transfer Report from ${user
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



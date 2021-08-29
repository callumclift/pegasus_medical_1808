import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import '../shared/global_config.dart';
import '../shared/strings.dart';
import 'package:flutter/foundation.dart' show kIsWeb;


class DatabaseHelper {

  //Singleton DatabaseHelper - only one instance throughout the app
  static DatabaseHelper _databaseHelper;
  //Singleton Database object
  static Database _database;


  static String createUsersTableSql = 'CREATE TABLE IF NOT EXISTS ${Strings.usersTable}('
      '${Strings.localId} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
      '${Strings.uid} VARCHAR(255) default NULL, '
      '${Strings.email} VARCHAR(255) default NULL, '
      '${Strings.name} VARCHAR(255) default NULL, '
      '${Strings.nameLowercase} VARCHAR(255) default NULL, '
      '${Strings.groups} JSON default NULL, '
      '${Strings.mobile} VARCHAR(255) default NULL, '
      '${Strings.role} VARCHAR(255) default NULL, '
      '${Strings.suspended} TINYINT(1) default NULL, '
      '${Strings.deleted} TINYINT(1) default NULL, '
      '${Strings.termsAccepted} TINYINT(1) default NULL, '
      '${Strings.profilePicture} TEXT default NULL, '
      '${Strings.forcePasswordReset} TINYINT(1) default NULL)';

  static String createFirebaseStorageUrlTable = 'CREATE TABLE IF NOT EXISTS ${Strings.firebaseStorageUrlTable}('
      '${Strings.localId} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
      '${Strings.uid} VARCHAR(255) default NULL, '
      '${Strings.urlList} JSON default NULL)';


  static String createObservationBookingTableSql = 'CREATE TABLE IF NOT EXISTS ${Strings.observationBookingTable}('
      '${Strings.localId} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
      '${Strings.formVersion} VARCHAR(255) default NULL, '
      '${Strings.pendingTime} VARCHAR(255) default NULL, '
      '${Strings.documentId} VARCHAR(255) default NULL, '
      '${Strings.jobId} VARCHAR(255) default NULL, '
      '${Strings.jobRef} VARCHAR(255) default NULL, '
      '${Strings.uid} VARCHAR(255) default NULL, '
      '${Strings.obRequestedBy} VARCHAR(255) default NULL, '
      '${Strings.obJobTitle} VARCHAR(255) default NULL, '
      '${Strings.obJobContact} VARCHAR(255) default NULL, '
      '${Strings.obJobAuthorisingManager} VARCHAR(255) default NULL, '
      '${Strings.obJobDate} VARCHAR(255) default NULL, '
      '${Strings.obJobTime} VARCHAR(255) default NULL, '
      '${Strings.obBookingCoordinator} VARCHAR(255) default NULL, '
      '${Strings.obPatientLocation} VARCHAR(255) default NULL, '
      '${Strings.obPostcode} VARCHAR(255) default NULL, '
      '${Strings.obLocationTel} VARCHAR(255) default NULL, '
      '${Strings.obInvoiceDetails} TEXT default NULL, '
      '${Strings.obCostCode} VARCHAR(255) default NULL, '
      '${Strings.obPurchaseOrder} VARCHAR(255) default NULL, '
      '${Strings.obStartDateTime} VARCHAR(255) default NULL, '
      '${Strings.obMhaAssessmentYes} TINYINT(1) default NULL,'
      '${Strings.obMhaAssessmentNo} TINYINT(1) default NULL,'
      '${Strings.obBedIdentifiedYes} TINYINT(1) default NULL,'
      '${Strings.obBedIdentifiedNo} TINYINT(1) default NULL,'
      '${Strings.obWrapDocumentationYes} TINYINT(1) default NULL,'
      '${Strings.obWrapDocumentationNo} TINYINT(1) default NULL,'
      '${Strings.obShiftRequired} VARCHAR(255) default NULL, '
      '${Strings.obPatientName} VARCHAR(255) default NULL, '
      '${Strings.obLegalStatus} VARCHAR(255) default NULL, '
      '${Strings.obDateOfBirth} VARCHAR(255) default NULL, '
      '${Strings.obNhsNumber} VARCHAR(255) default NULL, '
      '${Strings.obGender} VARCHAR(255) default NULL, '
      '${Strings.obEthnicity} VARCHAR(255) default NULL, '
      '${Strings.obCovidStatus} VARCHAR(255) default NULL, '
      '${Strings.obRmn} VARCHAR(255) default NULL, '
      '${Strings.obHca} VARCHAR(255) default NULL, '
      '${Strings.obHca1} VARCHAR(255) default NULL, '
      '${Strings.obHca2} VARCHAR(255) default NULL, '
      '${Strings.obHca3} VARCHAR(255) default NULL, '
      '${Strings.obHca4} VARCHAR(255) default NULL, '
      '${Strings.obHca5} VARCHAR(255) default NULL, '
      '${Strings.obCurrentPresentation} TEXT default NULL, '
      '${Strings.obSpecificCarePlanYes} TINYINT(1) default NULL, '
      '${Strings.obSpecificCarePlanNo} TINYINT(1) default NULL, '
      '${Strings.obSpecificCarePlan} VARCHAR(255) default NULL, '
      '${Strings.obPatientWarningsYes} TINYINT(1) default NULL, '
      '${Strings.obPatientWarningsNo} TINYINT(1) default NULL, '
      '${Strings.obPatientWarnings} VARCHAR(255) default NULL, '
      '${Strings.obPresentingRisks} TEXT default NULL, '
      '${Strings.obPreviousRisks} VARCHAR(255) default NULL, '
      '${Strings.obGenderConcernsYes} TINYINT(1) default NULL, '
      '${Strings.obGenderConcernsNo} TINYINT(1) default NULL, '
      '${Strings.obGenderConcerns} VARCHAR(255) default NULL, '
      '${Strings.obSafeguardingConcernsYes} TINYINT(1) default NULL, '
      '${Strings.obSafeguardingConcernsNo} TINYINT(1) default NULL, '
      '${Strings.obSafeguardingConcerns} VARCHAR(255) default NULL, '
      '${Strings.obTimeDue} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate1} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate2} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate3} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate4} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate5} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate6} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate7} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate8} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate9} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate10} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate11} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate12} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate13} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate14} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate15} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate16} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate17} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate18} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate19} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate20} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime1} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime2} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime3} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime4} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime5} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime6} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime7} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime8} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime9} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime10} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime11} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime12} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime13} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime14} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime15} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime16} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime17} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime18} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime19} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime20} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime1} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime2} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime3} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime4} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime5} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime6} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime7} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime8} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime9} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime10} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime11} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime12} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime13} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime14} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime15} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime16} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime17} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime18} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime19} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime20} VARCHAR(255) default NULL, '
      '${Strings.obStaffName1} VARCHAR(255) default NULL, '
      '${Strings.obStaffName2} VARCHAR(255) default NULL, '
      '${Strings.obStaffName3} VARCHAR(255) default NULL, '
      '${Strings.obStaffName4} VARCHAR(255) default NULL, '
      '${Strings.obStaffName5} VARCHAR(255) default NULL, '
      '${Strings.obStaffName6} VARCHAR(255) default NULL, '
      '${Strings.obStaffName7} VARCHAR(255) default NULL, '
      '${Strings.obStaffName8} VARCHAR(255) default NULL, '
      '${Strings.obStaffName9} VARCHAR(255) default NULL, '
      '${Strings.obStaffName10} VARCHAR(255) default NULL, '
      '${Strings.obStaffName11} VARCHAR(255) default NULL, '
      '${Strings.obStaffName12} VARCHAR(255) default NULL, '
      '${Strings.obStaffName13} VARCHAR(255) default NULL, '
      '${Strings.obStaffName14} VARCHAR(255) default NULL, '
      '${Strings.obStaffName15} VARCHAR(255) default NULL, '
      '${Strings.obStaffName16} VARCHAR(255) default NULL, '
      '${Strings.obStaffName17} VARCHAR(255) default NULL, '
      '${Strings.obStaffName18} VARCHAR(255) default NULL, '
      '${Strings.obStaffName19} VARCHAR(255) default NULL, '
      '${Strings.obStaffName20} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn1} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn2} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn3} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn4} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn5} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn6} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn7} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn8} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn9} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn10} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn11} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn12} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn13} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn14} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn15} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn16} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn17} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn18} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn19} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn20} VARCHAR(255) default NULL, '
      '${Strings.obUsefulDetails} TEXT default NULL, '
      '${Strings.serverUploaded} TINYINT(1) default NULL, '
      '${Strings.timestamp} VARCHAR(255) default NULL)';


  static String createEditedObservationBookingTableSql = 'CREATE TABLE IF NOT EXISTS ${Strings.editedObservationBookingTable}('
      '${Strings.localId} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
      '${Strings.formVersion} VARCHAR(255) default NULL, '
      '${Strings.pendingTime} VARCHAR(255) default NULL, '
      '${Strings.documentId} VARCHAR(255) default NULL, '
      '${Strings.jobId} VARCHAR(255) default NULL, '
      '${Strings.jobRef} VARCHAR(255) default NULL, '
      '${Strings.uid} VARCHAR(255) default NULL, '
      '${Strings.obRequestedBy} VARCHAR(255) default NULL, '
      '${Strings.obJobTitle} VARCHAR(255) default NULL, '
      '${Strings.obJobContact} VARCHAR(255) default NULL, '
      '${Strings.obJobAuthorisingManager} VARCHAR(255) default NULL, '
      '${Strings.obJobDate} VARCHAR(255) default NULL, '
      '${Strings.obJobTime} VARCHAR(255) default NULL, '
      '${Strings.obBookingCoordinator} VARCHAR(255) default NULL, '
      '${Strings.obPatientLocation} VARCHAR(255) default NULL, '
      '${Strings.obPostcode} VARCHAR(255) default NULL, '
      '${Strings.obLocationTel} VARCHAR(255) default NULL, '
      '${Strings.obInvoiceDetails} TEXT default NULL, '
      '${Strings.obCostCode} VARCHAR(255) default NULL, '
      '${Strings.obPurchaseOrder} VARCHAR(255) default NULL, '
      '${Strings.obStartDateTime} VARCHAR(255) default NULL, '
      '${Strings.obMhaAssessmentYes} TINYINT(1) default NULL,'
      '${Strings.obMhaAssessmentNo} TINYINT(1) default NULL,'
      '${Strings.obBedIdentifiedYes} TINYINT(1) default NULL,'
      '${Strings.obBedIdentifiedNo} TINYINT(1) default NULL,'
      '${Strings.obWrapDocumentationYes} TINYINT(1) default NULL,'
      '${Strings.obWrapDocumentationNo} TINYINT(1) default NULL,'
      '${Strings.obShiftRequired} VARCHAR(255) default NULL, '
      '${Strings.obPatientName} VARCHAR(255) default NULL, '
      '${Strings.obLegalStatus} VARCHAR(255) default NULL, '
      '${Strings.obDateOfBirth} VARCHAR(255) default NULL, '
      '${Strings.obNhsNumber} VARCHAR(255) default NULL, '
      '${Strings.obGender} VARCHAR(255) default NULL, '
      '${Strings.obEthnicity} VARCHAR(255) default NULL, '
      '${Strings.obCovidStatus} VARCHAR(255) default NULL, '
      '${Strings.obRmn} VARCHAR(255) default NULL, '
      '${Strings.obHca} VARCHAR(255) default NULL, '
      '${Strings.obHca1} VARCHAR(255) default NULL, '
      '${Strings.obHca2} VARCHAR(255) default NULL, '
      '${Strings.obHca3} VARCHAR(255) default NULL, '
      '${Strings.obHca4} VARCHAR(255) default NULL, '
      '${Strings.obHca5} VARCHAR(255) default NULL, '
      '${Strings.obCurrentPresentation} TEXT default NULL, '
      '${Strings.obSpecificCarePlanYes} TINYINT(1) default NULL, '
      '${Strings.obSpecificCarePlanNo} TINYINT(1) default NULL, '
      '${Strings.obSpecificCarePlan} VARCHAR(255) default NULL, '
      '${Strings.obPatientWarningsYes} TINYINT(1) default NULL, '
      '${Strings.obPatientWarningsNo} TINYINT(1) default NULL, '
      '${Strings.obPatientWarnings} VARCHAR(255) default NULL, '
      '${Strings.obPresentingRisks} TEXT default NULL, '
      '${Strings.obPreviousRisks} VARCHAR(255) default NULL, '
      '${Strings.obGenderConcernsYes} TINYINT(1) default NULL, '
      '${Strings.obGenderConcernsNo} TINYINT(1) default NULL, '
      '${Strings.obGenderConcerns} VARCHAR(255) default NULL, '
      '${Strings.obSafeguardingConcernsYes} TINYINT(1) default NULL, '
      '${Strings.obSafeguardingConcernsNo} TINYINT(1) default NULL, '
      '${Strings.obSafeguardingConcerns} VARCHAR(255) default NULL, '
      '${Strings.obTimeDue} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate1} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate2} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate3} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate4} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate5} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate6} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate7} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate8} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate9} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate10} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate11} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate12} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate13} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate14} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate15} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate16} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate17} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate18} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate19} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate20} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime1} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime2} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime3} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime4} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime5} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime6} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime7} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime8} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime9} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime10} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime11} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime12} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime13} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime14} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime15} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime16} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime17} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime18} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime19} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime20} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime1} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime2} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime3} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime4} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime5} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime6} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime7} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime8} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime9} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime10} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime11} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime12} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime13} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime14} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime15} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime16} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime17} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime18} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime19} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime20} VARCHAR(255) default NULL, '
      '${Strings.obStaffName1} VARCHAR(255) default NULL, '
      '${Strings.obStaffName2} VARCHAR(255) default NULL, '
      '${Strings.obStaffName3} VARCHAR(255) default NULL, '
      '${Strings.obStaffName4} VARCHAR(255) default NULL, '
      '${Strings.obStaffName5} VARCHAR(255) default NULL, '
      '${Strings.obStaffName6} VARCHAR(255) default NULL, '
      '${Strings.obStaffName7} VARCHAR(255) default NULL, '
      '${Strings.obStaffName8} VARCHAR(255) default NULL, '
      '${Strings.obStaffName9} VARCHAR(255) default NULL, '
      '${Strings.obStaffName10} VARCHAR(255) default NULL, '
      '${Strings.obStaffName11} VARCHAR(255) default NULL, '
      '${Strings.obStaffName12} VARCHAR(255) default NULL, '
      '${Strings.obStaffName13} VARCHAR(255) default NULL, '
      '${Strings.obStaffName14} VARCHAR(255) default NULL, '
      '${Strings.obStaffName15} VARCHAR(255) default NULL, '
      '${Strings.obStaffName16} VARCHAR(255) default NULL, '
      '${Strings.obStaffName17} VARCHAR(255) default NULL, '
      '${Strings.obStaffName18} VARCHAR(255) default NULL, '
      '${Strings.obStaffName19} VARCHAR(255) default NULL, '
      '${Strings.obStaffName20} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn1} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn2} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn3} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn4} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn5} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn6} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn7} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn8} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn9} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn10} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn11} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn12} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn13} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn14} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn15} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn16} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn17} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn18} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn19} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn20} VARCHAR(255) default NULL, '
      '${Strings.obUsefulDetails} TEXT default NULL, '
      '${Strings.serverUploaded} TINYINT(1) default NULL, '
      '${Strings.timestamp} VARCHAR(255) default NULL)';


  static String createTemporaryObservationBookingTableSql = 'CREATE TABLE IF NOT EXISTS ${Strings.temporaryObservationBookingTable}('
      '${Strings.localId} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
      '${Strings.formVersion} VARCHAR(255) default NULL, '
      '${Strings.documentId} VARCHAR(255) default NULL, '
      '${Strings.jobId} VARCHAR(255) default NULL, '
      '${Strings.jobRef} VARCHAR(255) default NULL, '
      '${Strings.uid} VARCHAR(255) default NULL, '
      '${Strings.obRequestedBy} VARCHAR(255) default NULL, '
      '${Strings.obJobTitle} VARCHAR(255) default NULL, '
      '${Strings.obJobContact} VARCHAR(255) default NULL, '
      '${Strings.obJobAuthorisingManager} VARCHAR(255) default NULL, '
      '${Strings.obJobDate} VARCHAR(255) default NULL, '
      '${Strings.obJobTime} VARCHAR(255) default NULL, '
      '${Strings.obBookingCoordinator} VARCHAR(255) default NULL, '
      '${Strings.obPatientLocation} VARCHAR(255) default NULL, '
      '${Strings.obPostcode} VARCHAR(255) default NULL, '
      '${Strings.obLocationTel} VARCHAR(255) default NULL, '
      '${Strings.obInvoiceDetails} TEXT default NULL, '
      '${Strings.obCostCode} VARCHAR(255) default NULL, '
      '${Strings.obPurchaseOrder} VARCHAR(255) default NULL, '
      '${Strings.obStartDateTime} VARCHAR(255) default NULL, '
      '${Strings.obMhaAssessmentYes} TINYINT(1) default NULL,'
      '${Strings.obMhaAssessmentNo} TINYINT(1) default NULL,'
      '${Strings.obBedIdentifiedYes} TINYINT(1) default NULL,'
      '${Strings.obBedIdentifiedNo} TINYINT(1) default NULL,'
      '${Strings.obWrapDocumentationYes} TINYINT(1) default NULL,'
      '${Strings.obWrapDocumentationNo} TINYINT(1) default NULL,'
      '${Strings.obShiftRequired} VARCHAR(255) default NULL, '
      '${Strings.obPatientName} VARCHAR(255) default NULL, '
      '${Strings.obLegalStatus} VARCHAR(255) default NULL, '
      '${Strings.obDateOfBirth} VARCHAR(255) default NULL, '
      '${Strings.obNhsNumber} VARCHAR(255) default NULL, '
      '${Strings.obGender} VARCHAR(255) default NULL, '
      '${Strings.obEthnicity} VARCHAR(255) default NULL, '
      '${Strings.obCovidStatus} VARCHAR(255) default NULL, '
      '${Strings.obRmn} VARCHAR(255) default NULL, '
      '${Strings.obHca} VARCHAR(255) default NULL, '
      '${Strings.obHca1} VARCHAR(255) default NULL, '
      '${Strings.obHca2} VARCHAR(255) default NULL, '
      '${Strings.obHca3} VARCHAR(255) default NULL, '
      '${Strings.obHca4} VARCHAR(255) default NULL, '
      '${Strings.obHca5} VARCHAR(255) default NULL, '
      '${Strings.obCurrentPresentation} TEXT default NULL, '
      '${Strings.obSpecificCarePlanYes} TINYINT(1) default NULL, '
      '${Strings.obSpecificCarePlanNo} TINYINT(1) default NULL, '
      '${Strings.obSpecificCarePlan} VARCHAR(255) default NULL, '
      '${Strings.obPatientWarningsYes} TINYINT(1) default NULL, '
      '${Strings.obPatientWarningsNo} TINYINT(1) default NULL, '
      '${Strings.obPatientWarnings} VARCHAR(255) default NULL, '
      '${Strings.obPresentingRisks} TEXT default NULL, '
      '${Strings.obPreviousRisks} VARCHAR(255) default NULL, '
      '${Strings.obGenderConcernsYes} TINYINT(1) default NULL, '
      '${Strings.obGenderConcernsNo} TINYINT(1) default NULL, '
      '${Strings.obGenderConcerns} VARCHAR(255) default NULL, '
      '${Strings.obSafeguardingConcernsYes} TINYINT(1) default NULL, '
      '${Strings.obSafeguardingConcernsNo} TINYINT(1) default NULL, '
      '${Strings.obSafeguardingConcerns} VARCHAR(255) default NULL, '
      '${Strings.obTimeDue} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate1} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate2} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate3} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate4} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate5} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate6} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate7} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate8} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate9} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate10} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate11} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate12} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate13} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate14} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate15} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate16} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate17} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate18} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate19} VARCHAR(255) default NULL, '
      '${Strings.obStaffDate20} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime1} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime2} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime3} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime4} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime5} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime6} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime7} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime8} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime9} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime10} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime11} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime12} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime13} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime14} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime15} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime16} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime17} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime18} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime19} VARCHAR(255) default NULL, '
      '${Strings.obStaffStartTime20} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime1} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime2} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime3} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime4} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime5} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime6} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime7} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime8} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime9} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime10} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime11} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime12} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime13} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime14} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime15} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime16} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime17} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime18} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime19} VARCHAR(255) default NULL, '
      '${Strings.obStaffEndTime20} VARCHAR(255) default NULL, '
      '${Strings.obStaffName1} VARCHAR(255) default NULL, '
      '${Strings.obStaffName2} VARCHAR(255) default NULL, '
      '${Strings.obStaffName3} VARCHAR(255) default NULL, '
      '${Strings.obStaffName4} VARCHAR(255) default NULL, '
      '${Strings.obStaffName5} VARCHAR(255) default NULL, '
      '${Strings.obStaffName6} VARCHAR(255) default NULL, '
      '${Strings.obStaffName7} VARCHAR(255) default NULL, '
      '${Strings.obStaffName8} VARCHAR(255) default NULL, '
      '${Strings.obStaffName9} VARCHAR(255) default NULL, '
      '${Strings.obStaffName10} VARCHAR(255) default NULL, '
      '${Strings.obStaffName11} VARCHAR(255) default NULL, '
      '${Strings.obStaffName12} VARCHAR(255) default NULL, '
      '${Strings.obStaffName13} VARCHAR(255) default NULL, '
      '${Strings.obStaffName14} VARCHAR(255) default NULL, '
      '${Strings.obStaffName15} VARCHAR(255) default NULL, '
      '${Strings.obStaffName16} VARCHAR(255) default NULL, '
      '${Strings.obStaffName17} VARCHAR(255) default NULL, '
      '${Strings.obStaffName18} VARCHAR(255) default NULL, '
      '${Strings.obStaffName19} VARCHAR(255) default NULL, '
      '${Strings.obStaffName20} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn1} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn2} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn3} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn4} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn5} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn6} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn7} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn8} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn9} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn10} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn11} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn12} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn13} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn14} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn15} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn16} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn17} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn18} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn19} VARCHAR(255) default NULL, '
      '${Strings.obStaffRmn20} VARCHAR(255) default NULL, '
      '${Strings.obUsefulDetails} TEXT default NULL) ';




  static String createBookingFormTableSql = 'CREATE TABLE IF NOT EXISTS ${Strings.bookingFormTable}('
      '${Strings.localId} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
      '${Strings.formVersion} VARCHAR(255) default NULL, '
      '${Strings.pendingTime} VARCHAR(255) default NULL, '
      '${Strings.documentId} VARCHAR(255) default NULL, '
      '${Strings.jobId} VARCHAR(255) default NULL, '
      '${Strings.jobRef} VARCHAR(255) default NULL, '
      '${Strings.uid} VARCHAR(255) default NULL, '
      '${Strings.bfRequestedBy} VARCHAR(255) default NULL, '
      '${Strings.bfJobTitle} VARCHAR(255) default NULL, '
      '${Strings.bfJobContact} VARCHAR(255) default NULL, '
      '${Strings.bfJobAuthorisingManager} VARCHAR(255) default NULL, '
      '${Strings.bfJobDate} VARCHAR(255) default NULL, '
      '${Strings.bfJobTime} VARCHAR(255) default NULL, '
      '${Strings.bfTransportCoordinator} VARCHAR(255) default NULL, '
      '${Strings.bfCollectionDateTime} VARCHAR(255) default NULL, '
      '${Strings.bfCollectionAddress} VARCHAR(255) default NULL, '
      '${Strings.bfCollectionPostcode} VARCHAR(255) default NULL, '
      '${Strings.bfCollectionTel} VARCHAR(255) default NULL, '
      '${Strings.bfDestinationAddress} VARCHAR(255) default NULL, '
      '${Strings.bfDestinationPostcode} VARCHAR(255) default NULL, '
      '${Strings.bfDestinationTel} VARCHAR(255) default NULL, '
      '${Strings.bfInvoiceDetails} TEXT default NULL, '
      '${Strings.bfCostCode} VARCHAR(255) default NULL, '
      '${Strings.bfPurchaseOrder} VARCHAR(255) default NULL, '
      '${Strings.bfPatientName} VARCHAR(255) default NULL, '
      '${Strings.bfLegalStatus} VARCHAR(255) default NULL, '
      '${Strings.bfDateOfBirth} VARCHAR(255) default NULL, '
      '${Strings.bfNhsNumber} VARCHAR(255) default NULL, '
      '${Strings.bfGender} VARCHAR(255) default NULL, '
      '${Strings.bfEthnicity} VARCHAR(255) default NULL, '
      '${Strings.bfCovidStatus} VARCHAR(255) default NULL, '
      '${Strings.bfRmn} VARCHAR(255) default NULL, '
      '${Strings.bfHca} VARCHAR(255) default NULL, '
      '${Strings.bfHca1} VARCHAR(255) default NULL, '
      '${Strings.bfHca2} VARCHAR(255) default NULL, '
      '${Strings.bfHca3} VARCHAR(255) default NULL, '
      '${Strings.bfHca4} VARCHAR(255) default NULL, '
      '${Strings.bfHca5} VARCHAR(255) default NULL, '
      '${Strings.bfCurrentPresentation} TEXT default NULL, '
      '${Strings.bfSpecificCarePlanYes} TINYINT(1) default NULL, '
      '${Strings.bfSpecificCarePlanNo} TINYINT(1) default NULL, '
      '${Strings.bfSpecificCarePlan} VARCHAR(255) default NULL, '
      '${Strings.bfPatientWarningsYes} TINYINT(1) default NULL, '
      '${Strings.bfPatientWarningsNo} TINYINT(1) default NULL, '
      '${Strings.bfPatientWarnings} VARCHAR(255) default NULL, '
      '${Strings.bfPresentingRisks} TEXT default NULL, '
      '${Strings.bfPreviousRisks} VARCHAR(255) default NULL, '
      '${Strings.bfGenderConcernsYes} TINYINT(1) default NULL, '
      '${Strings.bfGenderConcernsNo} TINYINT(1) default NULL, '
      '${Strings.bfGenderConcerns} VARCHAR(255) default NULL, '
      '${Strings.bfSafeguardingConcernsYes} TINYINT(1) default NULL, '
      '${Strings.bfSafeguardingConcernsNo} TINYINT(1) default NULL, '
      '${Strings.bfSafeguardingConcerns} VARCHAR(255) default NULL, '
      '${Strings.bfAmbulanceRegistration} VARCHAR(255) default NULL, '
      '${Strings.bfTimeDue} VARCHAR(255) default NULL, '
      '${Strings.assignedUserId} VARCHAR(255) default NULL, '
      '${Strings.assignedUserName} VARCHAR(255) default NULL, '
      '${Strings.serverUploaded} TINYINT(1) default NULL, '
      '${Strings.timestamp} VARCHAR(255) default NULL)';

  static String createEditedBookingFormTableSql = 'CREATE TABLE IF NOT EXISTS ${Strings.editedBookingFormTable}('
      '${Strings.localId} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
      '${Strings.formVersion} VARCHAR(255) default NULL, '
      '${Strings.pendingTime} VARCHAR(255) default NULL, '
      '${Strings.documentId} VARCHAR(255) default NULL, '
      '${Strings.jobId} VARCHAR(255) default NULL, '
      '${Strings.jobRef} VARCHAR(255) default NULL, '
      '${Strings.uid} VARCHAR(255) default NULL, '
      '${Strings.bfRequestedBy} VARCHAR(255) default NULL, '
      '${Strings.bfJobTitle} VARCHAR(255) default NULL, '
      '${Strings.bfJobContact} VARCHAR(255) default NULL, '
      '${Strings.bfJobAuthorisingManager} VARCHAR(255) default NULL, '
      '${Strings.bfJobDate} VARCHAR(255) default NULL, '
      '${Strings.bfJobTime} VARCHAR(255) default NULL, '
      '${Strings.bfTransportCoordinator} VARCHAR(255) default NULL, '
      '${Strings.bfCollectionDateTime} VARCHAR(255) default NULL, '
      '${Strings.bfCollectionAddress} VARCHAR(255) default NULL, '
      '${Strings.bfCollectionPostcode} VARCHAR(255) default NULL, '
      '${Strings.bfCollectionTel} VARCHAR(255) default NULL, '
      '${Strings.bfDestinationAddress} VARCHAR(255) default NULL, '
      '${Strings.bfDestinationPostcode} VARCHAR(255) default NULL, '
      '${Strings.bfDestinationTel} VARCHAR(255) default NULL, '
      '${Strings.bfInvoiceDetails} TEXT default NULL, '
      '${Strings.bfCostCode} VARCHAR(255) default NULL, '
      '${Strings.bfPurchaseOrder} VARCHAR(255) default NULL, '
      '${Strings.bfPatientName} VARCHAR(255) default NULL, '
      '${Strings.bfLegalStatus} VARCHAR(255) default NULL, '
      '${Strings.bfDateOfBirth} VARCHAR(255) default NULL, '
      '${Strings.bfNhsNumber} VARCHAR(255) default NULL, '
      '${Strings.bfGender} VARCHAR(255) default NULL, '
      '${Strings.bfEthnicity} VARCHAR(255) default NULL, '
      '${Strings.bfCovidStatus} VARCHAR(255) default NULL, '
      '${Strings.bfRmn} VARCHAR(255) default NULL, '
      '${Strings.bfHca} VARCHAR(255) default NULL, '
      '${Strings.bfHca1} VARCHAR(255) default NULL, '
      '${Strings.bfHca2} VARCHAR(255) default NULL, '
      '${Strings.bfHca3} VARCHAR(255) default NULL, '
      '${Strings.bfHca4} VARCHAR(255) default NULL, '
      '${Strings.bfHca5} VARCHAR(255) default NULL, '
      '${Strings.bfCurrentPresentation} TEXT default NULL, '
      '${Strings.bfSpecificCarePlanYes} TINYINT(1) default NULL, '
      '${Strings.bfSpecificCarePlanNo} TINYINT(1) default NULL, '
      '${Strings.bfSpecificCarePlan} VARCHAR(255) default NULL, '
      '${Strings.bfPatientWarningsYes} TINYINT(1) default NULL, '
      '${Strings.bfPatientWarningsNo} TINYINT(1) default NULL, '
      '${Strings.bfPatientWarnings} VARCHAR(255) default NULL, '
      '${Strings.bfPresentingRisks} TEXT default NULL, '
      '${Strings.bfPreviousRisks} VARCHAR(255) default NULL, '
      '${Strings.bfGenderConcernsYes} TINYINT(1) default NULL, '
      '${Strings.bfGenderConcernsNo} TINYINT(1) default NULL, '
      '${Strings.bfGenderConcerns} VARCHAR(255) default NULL, '
      '${Strings.bfSafeguardingConcernsYes} TINYINT(1) default NULL, '
      '${Strings.bfSafeguardingConcernsNo} TINYINT(1) default NULL, '
      '${Strings.bfSafeguardingConcerns} VARCHAR(255) default NULL, '
      '${Strings.bfAmbulanceRegistration} VARCHAR(255) default NULL, '
      '${Strings.bfTimeDue} VARCHAR(255) default NULL, '
      '${Strings.assignedUserId} VARCHAR(255) default NULL, '
      '${Strings.assignedUserName} VARCHAR(255) default NULL, '
      '${Strings.serverUploaded} TINYINT(1) default NULL, '
      '${Strings.timestamp} VARCHAR(255) default NULL)';


  static String createTemporaryBookingFormTableSql = 'CREATE TABLE IF NOT EXISTS ${Strings.temporaryBookingFormTable}('
      '${Strings.localId} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
      '${Strings.formVersion} VARCHAR(255) default NULL, '
      '${Strings.documentId} VARCHAR(255) default NULL, '
      '${Strings.jobId} VARCHAR(255) default NULL, '
      '${Strings.jobRef} VARCHAR(255) default NULL, '
      '${Strings.uid} VARCHAR(255) default NULL, '
      '${Strings.bfRequestedBy} VARCHAR(255) default NULL, '
      '${Strings.bfJobTitle} VARCHAR(255) default NULL, '
      '${Strings.bfJobContact} VARCHAR(255) default NULL, '
      '${Strings.bfJobAuthorisingManager} VARCHAR(255) default NULL, '
      '${Strings.bfJobDate} VARCHAR(255) default NULL, '
      '${Strings.bfJobTime} VARCHAR(255) default NULL, '
      '${Strings.bfTransportCoordinator} VARCHAR(255) default NULL, '
      '${Strings.bfCollectionDateTime} VARCHAR(255) default NULL, '
      '${Strings.bfCollectionAddress} VARCHAR(255) default NULL, '
      '${Strings.bfCollectionPostcode} VARCHAR(255) default NULL, '
      '${Strings.bfCollectionTel} VARCHAR(255) default NULL, '
      '${Strings.bfDestinationAddress} VARCHAR(255) default NULL, '
      '${Strings.bfDestinationPostcode} VARCHAR(255) default NULL, '
      '${Strings.bfDestinationTel} VARCHAR(255) default NULL, '
      '${Strings.bfInvoiceDetails} TEXT default NULL, '
      '${Strings.bfCostCode} VARCHAR(255) default NULL, '
      '${Strings.bfPurchaseOrder} VARCHAR(255) default NULL, '
      '${Strings.bfPatientName} VARCHAR(255) default NULL, '
      '${Strings.bfLegalStatus} VARCHAR(255) default NULL, '
      '${Strings.bfDateOfBirth} VARCHAR(255) default NULL, '
      '${Strings.bfNhsNumber} VARCHAR(255) default NULL, '
      '${Strings.bfGender} VARCHAR(255) default NULL, '
      '${Strings.bfEthnicity} VARCHAR(255) default NULL, '
      '${Strings.bfCovidStatus} VARCHAR(255) default NULL, '
      '${Strings.bfRmn} VARCHAR(255) default NULL, '
      '${Strings.bfHca} VARCHAR(255) default NULL, '
      '${Strings.bfHca1} VARCHAR(255) default NULL, '
      '${Strings.bfHca2} VARCHAR(255) default NULL, '
      '${Strings.bfHca3} VARCHAR(255) default NULL, '
      '${Strings.bfHca4} VARCHAR(255) default NULL, '
      '${Strings.bfHca5} VARCHAR(255) default NULL, '
      '${Strings.bfCurrentPresentation} TEXT default NULL, '
      '${Strings.bfSpecificCarePlanYes} TINYINT(1) default NULL, '
      '${Strings.bfSpecificCarePlanNo} TINYINT(1) default NULL, '
      '${Strings.bfSpecificCarePlan} VARCHAR(255) default NULL, '
      '${Strings.bfPatientWarningsYes} TINYINT(1) default NULL, '
      '${Strings.bfPatientWarningsNo} TINYINT(1) default NULL, '
      '${Strings.bfPatientWarnings} VARCHAR(255) default NULL, '
      '${Strings.bfPresentingRisks} TEXT default NULL, '
      '${Strings.bfPreviousRisks} VARCHAR(255) default NULL, '
      '${Strings.bfGenderConcernsYes} TINYINT(1) default NULL, '
      '${Strings.bfGenderConcernsNo} TINYINT(1) default NULL, '
      '${Strings.bfGenderConcerns} VARCHAR(255) default NULL, '
      '${Strings.bfSafeguardingConcernsYes} TINYINT(1) default NULL, '
      '${Strings.bfSafeguardingConcernsNo} TINYINT(1) default NULL, '
      '${Strings.bfSafeguardingConcerns} VARCHAR(255) default NULL, '
      '${Strings.bfAmbulanceRegistration} VARCHAR(255) default NULL, '
      '${Strings.assignedUserId} VARCHAR(255) default NULL, '
      '${Strings.assignedUserName} VARCHAR(255) default NULL, '
      '${Strings.bfTimeDue} VARCHAR(255) default NULL) ';


  static String createIncidentReportTableSql = 'CREATE TABLE IF NOT EXISTS ${Strings.incidentReportTable}('
      '${Strings.localId} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
      '${Strings.formVersion} VARCHAR(255) default NULL, '
      '${Strings.pendingTime} VARCHAR(255) default NULL, '
      '${Strings.documentId} VARCHAR(255) default NULL, '
      '${Strings.jobId} VARCHAR(255) default NULL, '
      '${Strings.jobRef} VARCHAR(255) default NULL, '
      '${Strings.uid} VARCHAR(255) default NULL, '
      '${Strings.incidentDate} VARCHAR(255) default NULL, '
      '${Strings.incidentTime} VARCHAR(255) default NULL, '
      '${Strings.incidentDetails} TEXT default NULL, '
      '${Strings.incidentLocation} TEXT default NULL, '
      '${Strings.incidentAction} TEXT default NULL, '
      '${Strings.incidentStaffInvolved} TEXT default NULL, '
      '${Strings.incidentSignature} BLOB default NULL, '
      '${Strings.incidentSignaturePoints} JSON default NULL, '
      '${Strings.incidentSignatureDate} TEXT default NULL, '
      '${Strings.incidentPrintName} TEXT default NULL, '
      '${Strings.serverUploaded} TINYINT(1) default NULL, '
      '${Strings.timestamp} VARCHAR(255) default NULL)';

  static String createEditedIncidentReportTableSql = 'CREATE TABLE IF NOT EXISTS ${Strings.editedIncidentReportTable}('
      '${Strings.localId} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
      '${Strings.formVersion} VARCHAR(255) default NULL, '
      '${Strings.pendingTime} VARCHAR(255) default NULL, '
      '${Strings.documentId} VARCHAR(255) default NULL, '
      '${Strings.jobId} VARCHAR(255) default NULL, '
      '${Strings.jobRef} VARCHAR(255) default NULL, '
      '${Strings.uid} VARCHAR(255) default NULL, '
      '${Strings.incidentDate} VARCHAR(255) default NULL, '
      '${Strings.incidentTime} VARCHAR(255) default NULL, '
      '${Strings.incidentDetails} TEXT default NULL, '
      '${Strings.incidentLocation} TEXT default NULL, '
      '${Strings.incidentAction} TEXT default NULL, '
      '${Strings.incidentStaffInvolved} TEXT default NULL, '
      '${Strings.incidentSignature} BLOB default NULL, '
      '${Strings.incidentSignaturePoints} JSON default NULL, '
      '${Strings.incidentSignatureDate} TEXT default NULL, '
      '${Strings.incidentPrintName} TEXT default NULL, '
      '${Strings.serverUploaded} TINYINT(1) default NULL, '
      '${Strings.timestamp} VARCHAR(255) default NULL)';


  static String createTemporaryIncidentReportTableSql = 'CREATE TABLE IF NOT EXISTS ${Strings.temporaryIncidentReportTable}('
      '${Strings.localId} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
      '${Strings.formVersion} VARCHAR(255) default NULL, '
      '${Strings.documentId} VARCHAR(255) default NULL, '
      '${Strings.jobId} VARCHAR(255) default NULL, '
      '${Strings.jobRef} VARCHAR(255) default NULL, '
      '${Strings.uid} VARCHAR(255) default NULL, '
      '${Strings.incidentDate} VARCHAR(255) default NULL, '
      '${Strings.incidentTime} VARCHAR(255) default NULL, '
      '${Strings.incidentDetails} TEXT default NULL, '
      '${Strings.incidentLocation} TEXT default NULL, '
      '${Strings.incidentAction} TEXT default NULL, '
      '${Strings.incidentStaffInvolved} TEXT default NULL, '
      '${Strings.incidentSignature} BLOB default NULL, '
      '${Strings.incidentSignaturePoints} JSON default NULL, '
      '${Strings.incidentSignatureDate} TEXT default NULL, '
      '${Strings.incidentPrintName} TEXT default NULL) ';


  static String createTransferReportTableSql = 'CREATE TABLE IF NOT EXISTS ${Strings.transferReportTable}('
      '${Strings.localId} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
      '${Strings.formVersion} VARCHAR(255) default NULL, '
      '${Strings.pendingTime} VARCHAR(255) default NULL, '
      '${Strings.documentId} VARCHAR(255) default NULL, '
      '${Strings.jobId} VARCHAR(255) default NULL, '
      '${Strings.jobRef} VARCHAR(255) default NULL, '
      '${Strings.uid} VARCHAR(255) default NULL, '
      '${Strings.date} VARCHAR(255) default NULL, '
      '${Strings.startTime} VARCHAR(255) default NULL, '
      '${Strings.finishTime} VARCHAR(255) default NULL, '
      '${Strings.totalHours} VARCHAR(255) default NULL, '
      '${Strings.collectionDetails} TEXT default NULL, '
      '${Strings.collectionPostcode} VARCHAR(255) default NULL, '
      '${Strings.collectionContactNo} VARCHAR(255) default NULL, '
      '${Strings.destinationDetails} TEXT default NULL, '
      '${Strings.destinationPostcode} VARCHAR(255) default NULL, '
      '${Strings.destinationContactNo} VARCHAR(255) default NULL, '
      '${Strings.collectionArrivalTime} VARCHAR(255) default NULL, '
      '${Strings.collectionDepartureTime} VARCHAR(255) default NULL, '
      '${Strings.destinationArrivalTime} VARCHAR(255) default NULL, '
      '${Strings.destinationDepartureTime} VARCHAR(255) default NULL, '
      '${Strings.vehicleRegNo} VARCHAR(255) default NULL, '
      '${Strings.startMileage} VARCHAR(255) default NULL, '
      '${Strings.finishMileage} VARCHAR(255) default NULL, '
      '${Strings.totalMileage} VARCHAR(255) default NULL, '
      '${Strings.name1} VARCHAR(255) default NULL, '
      '${Strings.role1} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes1_1} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes1_2} VARCHAR(255) default NULL, '
      '${Strings.name2} VARCHAR(255) default NULL, '
      '${Strings.role2} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes2_1} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes2_2} VARCHAR(255) default NULL, '
      '${Strings.name3} VARCHAR(255) default NULL, '
      '${Strings.role3} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes3_1} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes3_2} VARCHAR(255) default NULL, '
      '${Strings.name4} VARCHAR(255) default NULL, '
      '${Strings.role4} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes4_1} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes4_2} VARCHAR(255) default NULL, '
      '${Strings.name5} VARCHAR(255) default NULL, '
      '${Strings.role5} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes5_1} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes5_2} VARCHAR(255) default NULL, '
      '${Strings.name6} VARCHAR(255) default NULL, '
      '${Strings.role6} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes6_1} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes6_2} VARCHAR(255) default NULL, '
      '${Strings.name7} VARCHAR(255) default NULL, '
      '${Strings.role7} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes7_1} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes7_2} VARCHAR(255) default NULL, '
      '${Strings.name8} VARCHAR(255) default NULL, '
      '${Strings.role8} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes8_1} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes8_2} VARCHAR(255) default NULL, '
      '${Strings.name9} VARCHAR(255) default NULL, '
      '${Strings.role9} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes9_1} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes9_2} VARCHAR(255) default NULL, '
      '${Strings.name10} VARCHAR(255) default NULL, '
      '${Strings.role10} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes10_1} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes10_2} VARCHAR(255) default NULL, '
      '${Strings.name11} VARCHAR(255) default NULL, '
      '${Strings.role11} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes11_1} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes11_2} VARCHAR(255) default NULL, '
      '${Strings.collectionUnit} VARCHAR(255) default NULL, '
      '${Strings.collectionPosition} VARCHAR(255) default NULL, '
      '${Strings.collectionPrintName} VARCHAR(255) default NULL, '
      '${Strings.collectionArrivalTimeEnd} VARCHAR(255) default NULL, '
      '${Strings.collectionSignature} BLOB default NULL, '
      '${Strings.collectionSignaturePoints} JSON default NULL, '
      '${Strings.destinationUnit} VARCHAR(255) default NULL, '
      '${Strings.destinationPosition} VARCHAR(255) default NULL, '
      '${Strings.destinationPrintName} VARCHAR(255) default NULL, '
      '${Strings.destinationArrivalTimeEnd} VARCHAR(255) default NULL, '
      '${Strings.destinationSignature} BLOB default NULL, '
      '${Strings.destinationSignaturePoints} JSON default NULL, '
      '${Strings.patientName} VARCHAR(255) default NULL, '
      '${Strings.dateOfBirth} VARCHAR(255) default NULL, '
      '${Strings.ethnicity} VARCHAR(255) default NULL, '
      '${Strings.gender} VARCHAR(255) default NULL, '
      '${Strings.mhaMcaDetails} VARCHAR(255) default NULL, '
      '${Strings.diagnosis} VARCHAR(255) default NULL, '
      '${Strings.currentPresentation} VARCHAR(255) default NULL, '
      '${Strings.riskYes} TINYINT(1) default NULL, '
      '${Strings.riskNo} TINYINT(1) default NULL, '
      '${Strings.riskExplanation} TEXT default NULL, '
      '${Strings.forensicHistoryYes}  TINYINT(1) default NULL, '
      '${Strings.forensicHistoryNo} TINYINT(1) default NULL, '
      '${Strings.racialGenderConcernsYes} TINYINT(1) default NULL, '
      '${Strings.racialGenderConcernsNo}  TINYINT(1) default NULL, '
      '${Strings.violenceAggressionYes} TINYINT(1) default NULL, '
      '${Strings.violenceAggressionNo}  TINYINT(1) default NULL, '
      '${Strings.selfHarmYes} TINYINT(1) default NULL, '
      '${Strings.selfHarmNo}  TINYINT(1) default NULL, '
      '${Strings.alcoholSubstanceYes} TINYINT(1) default NULL, '
      '${Strings.alcoholSubstanceNo}  TINYINT(1) default NULL, '
      '${Strings.virusesYes}  TINYINT(1) default NULL, '
      '${Strings.virusesNo} TINYINT(1) default NULL, '
      '${Strings.safeguardingYes} TINYINT(1) default NULL, '
      '${Strings.safeguardingNo}  TINYINT(1) default NULL, '
      '${Strings.physicalHealthConditionsYes} TINYINT(1) default NULL, '
      '${Strings.physicalHealthConditionsNo}  TINYINT(1) default NULL, '
      '${Strings.useOfWeaponYes}  TINYINT(1) default NULL, '
      '${Strings.useOfWeaponNo} TINYINT(1) default NULL, '
      '${Strings.absconsionRiskYes} TINYINT(1) default NULL, '
      '${Strings.absconsionRiskNo}  TINYINT(1) default NULL, '
      '${Strings.forensicHistory} VARCHAR(255) default NULL, '
      '${Strings.racialGenderConcerns} VARCHAR(255) default NULL, '
      '${Strings.violenceAggression} VARCHAR(255) default NULL, '
      '${Strings.selfHarm} VARCHAR(255) default NULL, '
      '${Strings.alcoholSubstance} VARCHAR(255) default NULL, '
      '${Strings.viruses} VARCHAR(255) default NULL, '
      '${Strings.safeguarding} VARCHAR(255) default NULL, '
      '${Strings.physicalHealthConditions} VARCHAR(255) default NULL, '
      '${Strings.useOfWeapon} VARCHAR(255) default NULL, '
      '${Strings.absconsionRisk} VARCHAR(255) default NULL, '
      '${Strings.patientPropertyYes} TINYINT(1) default NULL, '
      '${Strings.patientPropertyNo} TINYINT(1) default NULL, '
      '${Strings.patientPropertyExplanation} TEXT default NULL, '
      '${Strings.patientPropertyReceived} VARCHAR(255) default NULL, '
      '${Strings.patientPropertyReceivedYes} TINYINT(1) default NULL, '
      '${Strings.patientPropertyReceivedNo} TINYINT(1) default NULL, '
      '${Strings.patientNotesReceived} VARCHAR(255) default NULL, '
      '${Strings.patientNotesReceivedYes} TINYINT(1) default NULL, '
      '${Strings.patientNotesReceivedNo} TINYINT(1) default NULL, '
      '${Strings.patientSearchedYes} TINYINT(1) default NULL, '
      '${Strings.patientSearchedNo} TINYINT(1) default NULL, '
      '${Strings.patientSearched} VARCHAR(255) default NULL, '
      '${Strings.itemsRemovedYes} TINYINT(1) default NULL, '
      '${Strings.itemsRemovedNo} TINYINT(1) default NULL, '
      '${Strings.itemsRemoved} VARCHAR(255) default NULL, '
      '${Strings.patientInformed} VARCHAR(255) default NULL, '
      '${Strings.injuriesNoted} VARCHAR(255) default NULL, '
      '${Strings.bodyMapPoints} JSON default NULL, '
      '${Strings.bodyMapImage} BLOB default NULL, '
      '${Strings.medicalAttentionYes} TINYINT(1) default NULL, '
      '${Strings.medicalAttentionNo} TINYINT(1) default NULL, '
      '${Strings.relevantInformationYes} TINYINT(1) default NULL, '
      '${Strings.relevantInformationNo} TINYINT(1) default NULL, '
      '${Strings.medicalAttention} VARCHAR(255) default NULL, '
      '${Strings.currentMedication} VARCHAR(255) default NULL, '
      '${Strings.physicalObservations} VARCHAR(255) default NULL, '
      '${Strings.relevantInformation} VARCHAR(255) default NULL, '
      '${Strings.patientReport} TEXT default NULL, '
      '${Strings.patientReportPrintName} VARCHAR(255) default NULL, '
      '${Strings.patientReportRole} VARCHAR(255) default NULL, '
      '${Strings.patientReportDate} VARCHAR(255) default NULL, '
      '${Strings.patientReportTime} VARCHAR(255) default NULL, '
      '${Strings.patientReportSignature} BLOB default NULL, '
      '${Strings.patientReportSignaturePoints} JSON default NULL, '
      '${Strings.handcuffsUsedYes} TINYINT(1) default NULL, '
      '${Strings.handcuffsUsedNo} TINYINT(1) default NULL, '
      '${Strings.handcuffsDate} VARCHAR(255) default NULL, '
      '${Strings.handcuffsTime} VARCHAR(255) default NULL, '
      '${Strings.handcuffsAuthorisedBy} VARCHAR(255) default NULL, '
      '${Strings.handcuffsAppliedBy} VARCHAR(255) default NULL, '
      '${Strings.handcuffsRemovedTime} VARCHAR(255) default NULL, '
      '${Strings.physicalInterventionYes} TINYINT(1) default NULL, '
      '${Strings.physicalInterventionNo} TINYINT(1) default NULL, '
      '${Strings.physicalIntervention} VARCHAR(255) default NULL, '
      '${Strings.whyInterventionRequired} TEXT default NULL, '
      '${Strings.techniqueName1} VARCHAR(255) default NULL, '
      '${Strings.techniqueName2} VARCHAR(255) default NULL, '
      '${Strings.techniqueName3} VARCHAR(255) default NULL, '
      '${Strings.techniqueName4} VARCHAR(255) default NULL, '
      '${Strings.techniqueName5} VARCHAR(255) default NULL, '
      '${Strings.techniqueName6} VARCHAR(255) default NULL, '
      '${Strings.techniqueName7} VARCHAR(255) default NULL, '
      '${Strings.techniqueName8} VARCHAR(255) default NULL, '
      '${Strings.techniqueName9} VARCHAR(255) default NULL, '
      '${Strings.techniqueName10} VARCHAR(255) default NULL, '
      '${Strings.technique1} VARCHAR(255) default NULL, '
      '${Strings.technique2} VARCHAR(255) default NULL, '
      '${Strings.technique3} VARCHAR(255) default NULL, '
      '${Strings.technique4} VARCHAR(255) default NULL, '
      '${Strings.technique5} VARCHAR(255) default NULL, '
      '${Strings.technique6} VARCHAR(255) default NULL, '
      '${Strings.technique7} VARCHAR(255) default NULL, '
      '${Strings.technique8} VARCHAR(255) default NULL, '
      '${Strings.technique9} VARCHAR(255) default NULL, '
      '${Strings.technique10} VARCHAR(255) default NULL, '
      '${Strings.techniquePosition1} VARCHAR(255) default NULL, '
      '${Strings.techniquePosition2} VARCHAR(255) default NULL, '
      '${Strings.techniquePosition3} VARCHAR(255) default NULL, '
      '${Strings.techniquePosition4} VARCHAR(255) default NULL, '
      '${Strings.techniquePosition5} VARCHAR(255) default NULL, '
      '${Strings.techniquePosition6} VARCHAR(255) default NULL, '
      '${Strings.techniquePosition7} VARCHAR(255) default NULL, '
      '${Strings.techniquePosition8} VARCHAR(255) default NULL, '
      '${Strings.techniquePosition9} VARCHAR(255) default NULL, '
      '${Strings.techniquePosition10} VARCHAR(255) default NULL, '
      '${Strings.timeInterventionCommenced} VARCHAR(255) default NULL, '
      '${Strings.timeInterventionCompleted} VARCHAR(255) default NULL, '
      '${Strings.incidentDate} VARCHAR(255) default NULL, '
      '${Strings.incidentTime} VARCHAR(255) default NULL, '
      '${Strings.incidentDetails} TEXT default NULL, '
      '${Strings.incidentLocation} TEXT default NULL, '
      '${Strings.incidentAction} TEXT default NULL, '
      '${Strings.incidentStaffInvolved} TEXT default NULL, '
      '${Strings.incidentSignature} BLOB default NULL, '
      '${Strings.incidentSignaturePoints} JSON default NULL, '
      '${Strings.incidentSignatureDate} TEXT default NULL, '
      '${Strings.incidentPrintName} TEXT default NULL, '
      '${Strings.hasSection2Checklist} TINYINT(1) default NULL, '
      '${Strings.hasSection3Checklist} TINYINT(1) default NULL, '
      '${Strings.hasSection3TransferChecklist} TINYINT(1) default NULL, '
      '${Strings.transferInPatientName1} VARCHAR(255) default NULL, '
      '${Strings.patientCorrectYes1} TINYINT(1) default NULL, '
      '${Strings.patientCorrectNo1} TINYINT(1) default NULL, '
      '${Strings.hospitalCorrectYes1} TINYINT(1) default NULL, '
      '${Strings.hospitalCorrectNo1} TINYINT(1) default NULL, '
      '${Strings.applicationFormYes1} TINYINT(1) default NULL, '
      '${Strings.applicationFormNo1} TINYINT(1) default NULL, '
      '${Strings.applicationSignedYes1} TINYINT(1) default NULL, '
      '${Strings.applicationSignedNo1} TINYINT(1) default NULL, '
      '${Strings.within14DaysYes1} TINYINT(1) default NULL, '
      '${Strings.within14DaysNo1} TINYINT(1) default NULL, '
      '${Strings.localAuthorityNameYes1} TINYINT(1) default NULL, '
      '${Strings.localAuthorityNameNo1} TINYINT(1) default NULL, '
      '${Strings.medicalRecommendationsFormYes1} TINYINT(1) default NULL, '
      '${Strings.medicalRecommendationsFormNo1} TINYINT(1) default NULL, '
      '${Strings.medicalRecommendationsSignedYes1} TINYINT(1) default NULL, '
      '${Strings.medicalRecommendationsSignedNo1} TINYINT(1) default NULL, '
      '${Strings.datesSignatureSignedYes} TINYINT(1) default NULL, '
      '${Strings.datesSignatureSignedNo} TINYINT(1) default NULL, '
      '${Strings.signatureDatesOnBeforeYes1} TINYINT(1) default NULL, '
      '${Strings.signatureDatesOnBeforeNo1} TINYINT(1) default NULL, '
      '${Strings.practitionersNameYes1} TINYINT(1) default NULL, '
      '${Strings.practitionersNameNo1} TINYINT(1) default NULL, '
      '${Strings.transferInCheckedBy1} VARCHAR(255) default NULL, '
      '${Strings.transferInDate1} VARCHAR(255) default NULL, '
      '${Strings.transferInDesignation1} VARCHAR(255) default NULL, '
      '${Strings.transferInSignature1} BLOB default NULL, '
      '${Strings.transferInSignaturePoints1} JSON default NULL, '
      '${Strings.transferInPatientName2} VARCHAR(255) default NULL, '
      '${Strings.patientCorrectYes2} TINYINT(1) default NULL, '
      '${Strings.patientCorrectNo2} TINYINT(1) default NULL, '
      '${Strings.hospitalCorrectYes2} TINYINT(1) default NULL, '
      '${Strings.hospitalCorrectNo2} TINYINT(1) default NULL, '
      '${Strings.applicationFormYes2} TINYINT(1) default NULL, '
      '${Strings.applicationFormNo2} TINYINT(1) default NULL, '
      '${Strings.applicationSignedYes2} TINYINT(1) default NULL, '
      '${Strings.applicationSignedNo2} TINYINT(1) default NULL, '
      '${Strings.amhpIdentifiedYes} TINYINT(1) default NULL, '
      '${Strings.amhpIdentifiedNo} TINYINT(1) default NULL, '
      '${Strings.medicalRecommendationsFormYes2} TINYINT(1) default NULL, '
      '${Strings.medicalRecommendationsFormNo2} TINYINT(1) default NULL, '
      '${Strings.medicalRecommendationsSignedYes2} TINYINT(1) default NULL, '
      '${Strings.medicalRecommendationsSignedNo2} TINYINT(1) default NULL, '
      '${Strings.clearDaysYes2} TINYINT(1) default NULL, '
      '${Strings.clearDaysNo2} TINYINT(1) default NULL, '
      '${Strings.signatureDatesOnBeforeYes2} TINYINT(1) default NULL, '
      '${Strings.signatureDatesOnBeforeNo2} TINYINT(1) default NULL, '
      '${Strings.practitionersNameYes2} TINYINT(1) default NULL, '
      '${Strings.practitionersNameNo2} TINYINT(1) default NULL, '
      '${Strings.doctorsAgreeYes} TINYINT(1) default NULL, '
      '${Strings.doctorsAgreeNo} TINYINT(1) default NULL, '
      '${Strings.separateMedicalRecommendationsYes} TINYINT(1) default NULL, '
      '${Strings.separateMedicalRecommendationsNo} TINYINT(1) default NULL, '
      '${Strings.transferInCheckedBy2} VARCHAR(255) default NULL, '
      '${Strings.transferInDate2} VARCHAR(255) default NULL, '
      '${Strings.transferInDesignation2} VARCHAR(255) default NULL, '
      '${Strings.transferInSignature2} BLOB default NULL, '
      '${Strings.transferInSignaturePoints2} JSON default NULL, '
      '${Strings.transferInPatientName3} VARCHAR(255) default NULL, '
      '${Strings.patientCorrectYes3} TINYINT(1) default NULL, '
      '${Strings.patientCorrectNo3} TINYINT(1) default NULL, '
      '${Strings.hospitalCorrectYes3} TINYINT(1) default NULL, '
      '${Strings.hospitalCorrectNo3} TINYINT(1) default NULL, '
      '${Strings.h4Yes} TINYINT(1) default NULL, '
      '${Strings.h4No} TINYINT(1) default NULL, '
      '${Strings.currentConsentYes} TINYINT(1) default NULL, '
      '${Strings.currentConsentNo} TINYINT(1) default NULL, '
      '${Strings.applicationFormYes3} TINYINT(1) default NULL, '
      '${Strings.applicationFormNo3} TINYINT(1) default NULL, '
      '${Strings.applicationSignedYes3} TINYINT(1) default NULL, '
      '${Strings.applicationSignedNo3} TINYINT(1) default NULL, '
      '${Strings.within14DaysYes3} TINYINT(1) default NULL, '
      '${Strings.within14DaysNo3} TINYINT(1) default NULL, '
      '${Strings.localAuthorityNameYes3} TINYINT(1) default NULL, '
      '${Strings.localAuthorityNameNo3} TINYINT(1) default NULL, '
      '${Strings.nearestRelativeYes} TINYINT(1) default NULL, '
      '${Strings.nearestRelativeNo} TINYINT(1) default NULL, '
      '${Strings.amhpConsultationYes} TINYINT(1) default NULL, '
      '${Strings.amhpConsultationNo} TINYINT(1) default NULL, '
      '${Strings.knewPatientYes} TINYINT(1) default NULL, '
      '${Strings.knewPatientNo} TINYINT(1) default NULL, '
      '${Strings.medicalRecommendationsFormYes3} TINYINT(1) default NULL, '
      '${Strings.medicalRecommendationsFormNo3} TINYINT(1) default NULL, '
      '${Strings.medicalRecommendationsSignedYes3} TINYINT(1) default NULL, '
      '${Strings.medicalRecommendationsSignedNo3} TINYINT(1) default NULL, '
      '${Strings.clearDaysYes3} TINYINT(1) default NULL, '
      '${Strings.clearDaysNo3} TINYINT(1) default NULL, '
      '${Strings.approvedSection12Yes} TINYINT(1) default NULL, '
      '${Strings.approvedSection12No} TINYINT(1) default NULL, '
      '${Strings.signatureDatesOnBeforeYes3} TINYINT(1) default NULL, '
      '${Strings.signatureDatesOnBeforeNo3} TINYINT(1) default NULL, '
      '${Strings.practitionersNameYes3} TINYINT(1) default NULL, '
      '${Strings.practitionersNameNo3} TINYINT(1) default NULL, '
      '${Strings.previouslyAcquaintedYes} TINYINT(1) default NULL, '
      '${Strings.previouslyAcquaintedNo} TINYINT(1) default NULL, '
      '${Strings.acquaintedIfNoYes} TINYINT(1) default NULL, '
      '${Strings.acquaintedIfNoNo} TINYINT(1) default NULL, '
      '${Strings.recommendationsDifferentTeamsYes} TINYINT(1) default NULL, '
      '${Strings.recommendationsDifferentTeamsNo} TINYINT(1) default NULL, '
      '${Strings.originalDetentionPapersYes} TINYINT(1) default NULL, '
      '${Strings.originalDetentionPapersNo} TINYINT(1) default NULL, '
      '${Strings.transferInCheckedBy3} VARCHAR(255) default NULL, '
      '${Strings.transferInDate3} VARCHAR(255) default NULL, '
      '${Strings.transferInDesignation3} VARCHAR(255) default NULL, '
      '${Strings.transferInSignature3} BLOB default NULL, '
      '${Strings.transferInSignaturePoints3} JSON default NULL, '
      '${Strings.feltSafeYes} TINYINT(1) default NULL, '
      '${Strings.feltSafeNo} TINYINT(1) default NULL, '
      '${Strings.staffIntroducedYes} TINYINT(1) default NULL, '
      '${Strings.staffIntroducedNo} TINYINT(1) default NULL, '
      '${Strings.experiencePositiveYes} TINYINT(1) default NULL, '
      '${Strings.experiencePositiveNo} TINYINT(1) default NULL, '
      '${Strings.otherComments} TEXT default NULL, '
      '${Strings.vehicleCompletedBy1} VARCHAR(255) default NULL, '
      '${Strings.vehicleDate} VARCHAR(255) default NULL, '
      '${Strings.vehicleTime} VARCHAR(255) default NULL, '
      '${Strings.ambulanceReg} VARCHAR(255) default NULL, '
      '${Strings.vehicleStartMileage} VARCHAR(255) default NULL, '
      '${Strings.nearestTank1} VARCHAR(255) default NULL, '
      '${Strings.ambulanceTidyYes1} TINYINT(1) default NULL, '
      '${Strings.ambulanceTidyNo1} TINYINT(1) default NULL, '
      '${Strings.lightsWorkingYes} TINYINT(1) default NULL, '
      '${Strings.lightsWorkingNo} TINYINT(1) default NULL, '
      '${Strings.tyresInflatedYes} TINYINT(1) default NULL, '
      '${Strings.tyresInflatedNo} TINYINT(1) default NULL, '
      '${Strings.warningSignsYes} TINYINT(1) default NULL, '
      '${Strings.warningSignsNo} TINYINT(1) default NULL, '
      '${Strings.vehicleCompletedBy2} VARCHAR(255) default NULL, '
      '${Strings.nearestTank2} VARCHAR(255) default NULL, '
      '${Strings.vehicleFinishMileage} VARCHAR(255) default NULL, '
      '${Strings.ambulanceTidyYes2} TINYINT(1) default NULL, '
      '${Strings.ambulanceTidyNo2} TINYINT(1) default NULL, '
      '${Strings.sanitiserCleanYes} TINYINT(1) default NULL, '
      '${Strings.sanitiserCleanNo} TINYINT(1) default NULL, '
      '${Strings.issuesFaults} TEXT default NULL, '
      '${Strings.serverUploaded} TINYINT(1) default NULL, '
      '${Strings.timestamp} VARCHAR(255) default NULL)';

  static String createEditedTransferReportTableSql = 'CREATE TABLE IF NOT EXISTS ${Strings.editedTransferReportTable}('
      '${Strings.localId} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
      '${Strings.formVersion} VARCHAR(255) default NULL, '
      '${Strings.pendingTime} VARCHAR(255) default NULL, '
      '${Strings.documentId} VARCHAR(255) default NULL, '
      '${Strings.jobId} VARCHAR(255) default NULL, '
      '${Strings.jobRef} VARCHAR(255) default NULL, '
      '${Strings.uid} VARCHAR(255) default NULL, '
      '${Strings.date} VARCHAR(255) default NULL, '
      '${Strings.startTime} VARCHAR(255) default NULL, '
      '${Strings.finishTime} VARCHAR(255) default NULL, '
      '${Strings.totalHours} VARCHAR(255) default NULL, '
      '${Strings.collectionDetails} TEXT default NULL, '
      '${Strings.collectionPostcode} VARCHAR(255) default NULL, '
      '${Strings.collectionContactNo} VARCHAR(255) default NULL, '
      '${Strings.destinationDetails} TEXT default NULL, '
      '${Strings.destinationPostcode} VARCHAR(255) default NULL, '
      '${Strings.destinationContactNo} VARCHAR(255) default NULL, '
      '${Strings.collectionArrivalTime} VARCHAR(255) default NULL, '
      '${Strings.collectionDepartureTime} VARCHAR(255) default NULL, '
      '${Strings.destinationArrivalTime} VARCHAR(255) default NULL, '
      '${Strings.destinationDepartureTime} VARCHAR(255) default NULL, '
      '${Strings.vehicleRegNo} VARCHAR(255) default NULL, '
      '${Strings.startMileage} VARCHAR(255) default NULL, '
      '${Strings.finishMileage} VARCHAR(255) default NULL, '
      '${Strings.totalMileage} VARCHAR(255) default NULL, '
      '${Strings.name1} VARCHAR(255) default NULL, '
      '${Strings.role1} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes1_1} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes1_2} VARCHAR(255) default NULL, '
      '${Strings.name2} VARCHAR(255) default NULL, '
      '${Strings.role2} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes2_1} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes2_2} VARCHAR(255) default NULL, '
      '${Strings.name3} VARCHAR(255) default NULL, '
      '${Strings.role3} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes3_1} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes3_2} VARCHAR(255) default NULL, '
      '${Strings.name4} VARCHAR(255) default NULL, '
      '${Strings.role4} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes4_1} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes4_2} VARCHAR(255) default NULL, '
      '${Strings.name5} VARCHAR(255) default NULL, '
      '${Strings.role5} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes5_1} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes5_2} VARCHAR(255) default NULL, '
      '${Strings.name6} VARCHAR(255) default NULL, '
      '${Strings.role6} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes6_1} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes6_2} VARCHAR(255) default NULL, '
      '${Strings.name7} VARCHAR(255) default NULL, '
      '${Strings.role7} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes7_1} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes7_2} VARCHAR(255) default NULL, '
      '${Strings.name8} VARCHAR(255) default NULL, '
      '${Strings.role8} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes8_1} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes8_2} VARCHAR(255) default NULL, '
      '${Strings.name9} VARCHAR(255) default NULL, '
      '${Strings.role9} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes9_1} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes9_2} VARCHAR(255) default NULL, '
      '${Strings.name10} VARCHAR(255) default NULL, '
      '${Strings.role10} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes10_1} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes10_2} VARCHAR(255) default NULL, '
      '${Strings.name11} VARCHAR(255) default NULL, '
      '${Strings.role11} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes11_1} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes11_2} VARCHAR(255) default NULL, '
      '${Strings.collectionUnit} VARCHAR(255) default NULL, '
      '${Strings.collectionPosition} VARCHAR(255) default NULL, '
      '${Strings.collectionPrintName} VARCHAR(255) default NULL, '
      '${Strings.collectionArrivalTimeEnd} VARCHAR(255) default NULL, '
      '${Strings.collectionSignature} BLOB default NULL, '
      '${Strings.collectionSignaturePoints} JSON default NULL, '
      '${Strings.destinationUnit} VARCHAR(255) default NULL, '
      '${Strings.destinationPosition} VARCHAR(255) default NULL, '
      '${Strings.destinationPrintName} VARCHAR(255) default NULL, '
      '${Strings.destinationArrivalTimeEnd} VARCHAR(255) default NULL, '
      '${Strings.destinationSignature} BLOB default NULL, '
      '${Strings.destinationSignaturePoints} JSON default NULL, '
      '${Strings.patientName} VARCHAR(255) default NULL, '
      '${Strings.dateOfBirth} VARCHAR(255) default NULL, '
      '${Strings.ethnicity} VARCHAR(255) default NULL, '
      '${Strings.gender} VARCHAR(255) default NULL, '
      '${Strings.mhaMcaDetails} VARCHAR(255) default NULL, '
      '${Strings.diagnosis} VARCHAR(255) default NULL, '
      '${Strings.currentPresentation} VARCHAR(255) default NULL, '
      '${Strings.riskYes} TINYINT(1) default NULL, '
      '${Strings.riskNo} TINYINT(1) default NULL, '
      '${Strings.riskExplanation} TEXT default NULL, '
      '${Strings.forensicHistoryYes}  TINYINT(1) default NULL, '
      '${Strings.forensicHistoryNo} TINYINT(1) default NULL, '
      '${Strings.racialGenderConcernsYes} TINYINT(1) default NULL, '
      '${Strings.racialGenderConcernsNo}  TINYINT(1) default NULL, '
      '${Strings.violenceAggressionYes} TINYINT(1) default NULL, '
      '${Strings.violenceAggressionNo}  TINYINT(1) default NULL, '
      '${Strings.selfHarmYes} TINYINT(1) default NULL, '
      '${Strings.selfHarmNo}  TINYINT(1) default NULL, '
      '${Strings.alcoholSubstanceYes} TINYINT(1) default NULL, '
      '${Strings.alcoholSubstanceNo}  TINYINT(1) default NULL, '
      '${Strings.virusesYes}  TINYINT(1) default NULL, '
      '${Strings.virusesNo} TINYINT(1) default NULL, '
      '${Strings.safeguardingYes} TINYINT(1) default NULL, '
      '${Strings.safeguardingNo}  TINYINT(1) default NULL, '
      '${Strings.physicalHealthConditionsYes} TINYINT(1) default NULL, '
      '${Strings.physicalHealthConditionsNo}  TINYINT(1) default NULL, '
      '${Strings.useOfWeaponYes}  TINYINT(1) default NULL, '
      '${Strings.useOfWeaponNo} TINYINT(1) default NULL, '
      '${Strings.absconsionRiskYes} TINYINT(1) default NULL, '
      '${Strings.absconsionRiskNo}  TINYINT(1) default NULL, '
      '${Strings.forensicHistory} VARCHAR(255) default NULL, '
      '${Strings.racialGenderConcerns} VARCHAR(255) default NULL, '
      '${Strings.violenceAggression} VARCHAR(255) default NULL, '
      '${Strings.selfHarm} VARCHAR(255) default NULL, '
      '${Strings.alcoholSubstance} VARCHAR(255) default NULL, '
      '${Strings.viruses} VARCHAR(255) default NULL, '
      '${Strings.safeguarding} VARCHAR(255) default NULL, '
      '${Strings.physicalHealthConditions} VARCHAR(255) default NULL, '
      '${Strings.useOfWeapon} VARCHAR(255) default NULL, '
      '${Strings.absconsionRisk} VARCHAR(255) default NULL, '
      '${Strings.patientPropertyYes} TINYINT(1) default NULL, '
      '${Strings.patientPropertyNo} TINYINT(1) default NULL, '
      '${Strings.patientPropertyExplanation} TEXT default NULL, '
      '${Strings.patientPropertyReceived} VARCHAR(255) default NULL, '
      '${Strings.patientPropertyReceivedYes} TINYINT(1) default NULL, '
      '${Strings.patientPropertyReceivedNo} TINYINT(1) default NULL, '
      '${Strings.patientNotesReceived} VARCHAR(255) default NULL, '
      '${Strings.patientNotesReceivedYes} TINYINT(1) default NULL, '
      '${Strings.patientNotesReceivedNo} TINYINT(1) default NULL, '
      '${Strings.patientSearchedYes} TINYINT(1) default NULL, '
      '${Strings.patientSearchedNo} TINYINT(1) default NULL, '
      '${Strings.patientSearched} VARCHAR(255) default NULL, '
      '${Strings.itemsRemovedYes} TINYINT(1) default NULL, '
      '${Strings.itemsRemovedNo} TINYINT(1) default NULL, '
      '${Strings.itemsRemoved} VARCHAR(255) default NULL, '
      '${Strings.patientInformed} VARCHAR(255) default NULL, '
      '${Strings.injuriesNoted} VARCHAR(255) default NULL, '
      '${Strings.bodyMapPoints} JSON default NULL, '
      '${Strings.bodyMapImage} BLOB default NULL, '
      '${Strings.medicalAttentionYes} TINYINT(1) default NULL, '
      '${Strings.medicalAttentionNo} TINYINT(1) default NULL, '
      '${Strings.relevantInformationYes} TINYINT(1) default NULL, '
      '${Strings.relevantInformationNo} TINYINT(1) default NULL, '
      '${Strings.medicalAttention} VARCHAR(255) default NULL, '
      '${Strings.currentMedication} VARCHAR(255) default NULL, '
      '${Strings.physicalObservations} VARCHAR(255) default NULL, '
      '${Strings.relevantInformation} VARCHAR(255) default NULL, '
      '${Strings.patientReport} TEXT default NULL, '
      '${Strings.patientReportPrintName} VARCHAR(255) default NULL, '
      '${Strings.patientReportRole} VARCHAR(255) default NULL, '
      '${Strings.patientReportDate} VARCHAR(255) default NULL, '
      '${Strings.patientReportTime} VARCHAR(255) default NULL, '
      '${Strings.patientReportSignature} BLOB default NULL, '
      '${Strings.patientReportSignaturePoints} JSON default NULL, '
      '${Strings.handcuffsUsedYes} TINYINT(1) default NULL, '
      '${Strings.handcuffsUsedNo} TINYINT(1) default NULL, '
      '${Strings.handcuffsDate} VARCHAR(255) default NULL, '
      '${Strings.handcuffsTime} VARCHAR(255) default NULL, '
      '${Strings.handcuffsAuthorisedBy} VARCHAR(255) default NULL, '
      '${Strings.handcuffsAppliedBy} VARCHAR(255) default NULL, '
      '${Strings.handcuffsRemovedTime} VARCHAR(255) default NULL, '
      '${Strings.physicalInterventionYes} TINYINT(1) default NULL, '
      '${Strings.physicalInterventionNo} TINYINT(1) default NULL, '
      '${Strings.physicalIntervention} VARCHAR(255) default NULL, '
      '${Strings.whyInterventionRequired} TEXT default NULL, '
      '${Strings.techniqueName1} VARCHAR(255) default NULL, '
      '${Strings.techniqueName2} VARCHAR(255) default NULL, '
      '${Strings.techniqueName3} VARCHAR(255) default NULL, '
      '${Strings.techniqueName4} VARCHAR(255) default NULL, '
      '${Strings.techniqueName5} VARCHAR(255) default NULL, '
      '${Strings.techniqueName6} VARCHAR(255) default NULL, '
      '${Strings.techniqueName7} VARCHAR(255) default NULL, '
      '${Strings.techniqueName8} VARCHAR(255) default NULL, '
      '${Strings.techniqueName9} VARCHAR(255) default NULL, '
      '${Strings.techniqueName10} VARCHAR(255) default NULL, '
      '${Strings.technique1} VARCHAR(255) default NULL, '
      '${Strings.technique2} VARCHAR(255) default NULL, '
      '${Strings.technique3} VARCHAR(255) default NULL, '
      '${Strings.technique4} VARCHAR(255) default NULL, '
      '${Strings.technique5} VARCHAR(255) default NULL, '
      '${Strings.technique6} VARCHAR(255) default NULL, '
      '${Strings.technique7} VARCHAR(255) default NULL, '
      '${Strings.technique8} VARCHAR(255) default NULL, '
      '${Strings.technique9} VARCHAR(255) default NULL, '
      '${Strings.technique10} VARCHAR(255) default NULL, '
      '${Strings.techniquePosition1} VARCHAR(255) default NULL, '
      '${Strings.techniquePosition2} VARCHAR(255) default NULL, '
      '${Strings.techniquePosition3} VARCHAR(255) default NULL, '
      '${Strings.techniquePosition4} VARCHAR(255) default NULL, '
      '${Strings.techniquePosition5} VARCHAR(255) default NULL, '
      '${Strings.techniquePosition6} VARCHAR(255) default NULL, '
      '${Strings.techniquePosition7} VARCHAR(255) default NULL, '
      '${Strings.techniquePosition8} VARCHAR(255) default NULL, '
      '${Strings.techniquePosition9} VARCHAR(255) default NULL, '
      '${Strings.techniquePosition10} VARCHAR(255) default NULL, '
      '${Strings.timeInterventionCommenced} VARCHAR(255) default NULL, '
      '${Strings.timeInterventionCompleted} VARCHAR(255) default NULL, '
      '${Strings.incidentDate} VARCHAR(255) default NULL, '
      '${Strings.incidentTime} VARCHAR(255) default NULL, '
      '${Strings.incidentDetails} TEXT default NULL, '
      '${Strings.incidentLocation} TEXT default NULL, '
      '${Strings.incidentAction} TEXT default NULL, '
      '${Strings.incidentStaffInvolved} TEXT default NULL, '
      '${Strings.incidentSignature} BLOB default NULL, '
      '${Strings.incidentSignaturePoints} JSON default NULL, '
      '${Strings.incidentSignatureDate} TEXT default NULL, '
      '${Strings.incidentPrintName} TEXT default NULL, '
      '${Strings.hasSection2Checklist} TINYINT(1) default NULL, '
      '${Strings.hasSection3Checklist} TINYINT(1) default NULL, '
      '${Strings.hasSection3TransferChecklist} TINYINT(1) default NULL, '
      '${Strings.transferInPatientName1} VARCHAR(255) default NULL, '
      '${Strings.patientCorrectYes1} TINYINT(1) default NULL, '
      '${Strings.patientCorrectNo1} TINYINT(1) default NULL, '
      '${Strings.hospitalCorrectYes1} TINYINT(1) default NULL, '
      '${Strings.hospitalCorrectNo1} TINYINT(1) default NULL, '
      '${Strings.applicationFormYes1} TINYINT(1) default NULL, '
      '${Strings.applicationFormNo1} TINYINT(1) default NULL, '
      '${Strings.applicationSignedYes1} TINYINT(1) default NULL, '
      '${Strings.applicationSignedNo1} TINYINT(1) default NULL, '
      '${Strings.within14DaysYes1} TINYINT(1) default NULL, '
      '${Strings.within14DaysNo1} TINYINT(1) default NULL, '
      '${Strings.localAuthorityNameYes1} TINYINT(1) default NULL, '
      '${Strings.localAuthorityNameNo1} TINYINT(1) default NULL, '
      '${Strings.medicalRecommendationsFormYes1} TINYINT(1) default NULL, '
      '${Strings.medicalRecommendationsFormNo1} TINYINT(1) default NULL, '
      '${Strings.medicalRecommendationsSignedYes1} TINYINT(1) default NULL, '
      '${Strings.medicalRecommendationsSignedNo1} TINYINT(1) default NULL, '
      '${Strings.datesSignatureSignedYes} TINYINT(1) default NULL, '
      '${Strings.datesSignatureSignedNo} TINYINT(1) default NULL, '
      '${Strings.signatureDatesOnBeforeYes1} TINYINT(1) default NULL, '
      '${Strings.signatureDatesOnBeforeNo1} TINYINT(1) default NULL, '
      '${Strings.practitionersNameYes1} TINYINT(1) default NULL, '
      '${Strings.practitionersNameNo1} TINYINT(1) default NULL, '
      '${Strings.transferInCheckedBy1} VARCHAR(255) default NULL, '
      '${Strings.transferInDate1} VARCHAR(255) default NULL, '
      '${Strings.transferInDesignation1} VARCHAR(255) default NULL, '
      '${Strings.transferInSignature1} BLOB default NULL, '
      '${Strings.transferInSignaturePoints1} JSON default NULL, '
      '${Strings.transferInPatientName2} VARCHAR(255) default NULL, '
      '${Strings.patientCorrectYes2} TINYINT(1) default NULL, '
      '${Strings.patientCorrectNo2} TINYINT(1) default NULL, '
      '${Strings.hospitalCorrectYes2} TINYINT(1) default NULL, '
      '${Strings.hospitalCorrectNo2} TINYINT(1) default NULL, '
      '${Strings.applicationFormYes2} TINYINT(1) default NULL, '
      '${Strings.applicationFormNo2} TINYINT(1) default NULL, '
      '${Strings.applicationSignedYes2} TINYINT(1) default NULL, '
      '${Strings.applicationSignedNo2} TINYINT(1) default NULL, '
      '${Strings.amhpIdentifiedYes} TINYINT(1) default NULL, '
      '${Strings.amhpIdentifiedNo} TINYINT(1) default NULL, '
      '${Strings.medicalRecommendationsFormYes2} TINYINT(1) default NULL, '
      '${Strings.medicalRecommendationsFormNo2} TINYINT(1) default NULL, '
      '${Strings.medicalRecommendationsSignedYes2} TINYINT(1) default NULL, '
      '${Strings.medicalRecommendationsSignedNo2} TINYINT(1) default NULL, '
      '${Strings.clearDaysYes2} TINYINT(1) default NULL, '
      '${Strings.clearDaysNo2} TINYINT(1) default NULL, '
      '${Strings.signatureDatesOnBeforeYes2} TINYINT(1) default NULL, '
      '${Strings.signatureDatesOnBeforeNo2} TINYINT(1) default NULL, '
      '${Strings.practitionersNameYes2} TINYINT(1) default NULL, '
      '${Strings.practitionersNameNo2} TINYINT(1) default NULL, '
      '${Strings.doctorsAgreeYes} TINYINT(1) default NULL, '
      '${Strings.doctorsAgreeNo} TINYINT(1) default NULL, '
      '${Strings.separateMedicalRecommendationsYes} TINYINT(1) default NULL, '
      '${Strings.separateMedicalRecommendationsNo} TINYINT(1) default NULL, '
      '${Strings.transferInCheckedBy2} VARCHAR(255) default NULL, '
      '${Strings.transferInDate2} VARCHAR(255) default NULL, '
      '${Strings.transferInDesignation2} VARCHAR(255) default NULL, '
      '${Strings.transferInSignature2} BLOB default NULL, '
      '${Strings.transferInSignaturePoints2} JSON default NULL, '
      '${Strings.transferInPatientName3} VARCHAR(255) default NULL, '
      '${Strings.patientCorrectYes3} TINYINT(1) default NULL, '
      '${Strings.patientCorrectNo3} TINYINT(1) default NULL, '
      '${Strings.hospitalCorrectYes3} TINYINT(1) default NULL, '
      '${Strings.hospitalCorrectNo3} TINYINT(1) default NULL, '
      '${Strings.h4Yes} TINYINT(1) default NULL, '
      '${Strings.h4No} TINYINT(1) default NULL, '
      '${Strings.currentConsentYes} TINYINT(1) default NULL, '
      '${Strings.currentConsentNo} TINYINT(1) default NULL, '
      '${Strings.applicationFormYes3} TINYINT(1) default NULL, '
      '${Strings.applicationFormNo3} TINYINT(1) default NULL, '
      '${Strings.applicationSignedYes3} TINYINT(1) default NULL, '
      '${Strings.applicationSignedNo3} TINYINT(1) default NULL, '
      '${Strings.within14DaysYes3} TINYINT(1) default NULL, '
      '${Strings.within14DaysNo3} TINYINT(1) default NULL, '
      '${Strings.localAuthorityNameYes3} TINYINT(1) default NULL, '
      '${Strings.localAuthorityNameNo3} TINYINT(1) default NULL, '
      '${Strings.nearestRelativeYes} TINYINT(1) default NULL, '
      '${Strings.nearestRelativeNo} TINYINT(1) default NULL, '
      '${Strings.amhpConsultationYes} TINYINT(1) default NULL, '
      '${Strings.amhpConsultationNo} TINYINT(1) default NULL, '
      '${Strings.knewPatientYes} TINYINT(1) default NULL, '
      '${Strings.knewPatientNo} TINYINT(1) default NULL, '
      '${Strings.medicalRecommendationsFormYes3} TINYINT(1) default NULL, '
      '${Strings.medicalRecommendationsFormNo3} TINYINT(1) default NULL, '
      '${Strings.medicalRecommendationsSignedYes3} TINYINT(1) default NULL, '
      '${Strings.medicalRecommendationsSignedNo3} TINYINT(1) default NULL, '
      '${Strings.clearDaysYes3} TINYINT(1) default NULL, '
      '${Strings.clearDaysNo3} TINYINT(1) default NULL, '
      '${Strings.approvedSection12Yes} TINYINT(1) default NULL, '
      '${Strings.approvedSection12No} TINYINT(1) default NULL, '
      '${Strings.signatureDatesOnBeforeYes3} TINYINT(1) default NULL, '
      '${Strings.signatureDatesOnBeforeNo3} TINYINT(1) default NULL, '
      '${Strings.practitionersNameYes3} TINYINT(1) default NULL, '
      '${Strings.practitionersNameNo3} TINYINT(1) default NULL, '
      '${Strings.previouslyAcquaintedYes} TINYINT(1) default NULL, '
      '${Strings.previouslyAcquaintedNo} TINYINT(1) default NULL, '
      '${Strings.acquaintedIfNoYes} TINYINT(1) default NULL, '
      '${Strings.acquaintedIfNoNo} TINYINT(1) default NULL, '
      '${Strings.recommendationsDifferentTeamsYes} TINYINT(1) default NULL, '
      '${Strings.recommendationsDifferentTeamsNo} TINYINT(1) default NULL, '
      '${Strings.originalDetentionPapersYes} TINYINT(1) default NULL, '
      '${Strings.originalDetentionPapersNo} TINYINT(1) default NULL, '
      '${Strings.transferInCheckedBy3} VARCHAR(255) default NULL, '
      '${Strings.transferInDate3} VARCHAR(255) default NULL, '
      '${Strings.transferInDesignation3} VARCHAR(255) default NULL, '
      '${Strings.transferInSignature3} BLOB default NULL, '
      '${Strings.transferInSignaturePoints3} JSON default NULL, '
      '${Strings.feltSafeYes} TINYINT(1) default NULL, '
      '${Strings.feltSafeNo} TINYINT(1) default NULL, '
      '${Strings.staffIntroducedYes} TINYINT(1) default NULL, '
      '${Strings.staffIntroducedNo} TINYINT(1) default NULL, '
      '${Strings.experiencePositiveYes} TINYINT(1) default NULL, '
      '${Strings.experiencePositiveNo} TINYINT(1) default NULL, '
      '${Strings.otherComments} TEXT default NULL, '
      '${Strings.vehicleCompletedBy1} VARCHAR(255) default NULL, '
      '${Strings.vehicleDate} VARCHAR(255) default NULL, '
      '${Strings.vehicleTime} VARCHAR(255) default NULL, '
      '${Strings.ambulanceReg} VARCHAR(255) default NULL, '
      '${Strings.vehicleStartMileage} VARCHAR(255) default NULL, '
      '${Strings.nearestTank1} VARCHAR(255) default NULL, '
      '${Strings.ambulanceTidyYes1} TINYINT(1) default NULL, '
      '${Strings.ambulanceTidyNo1} TINYINT(1) default NULL, '
      '${Strings.lightsWorkingYes} TINYINT(1) default NULL, '
      '${Strings.lightsWorkingNo} TINYINT(1) default NULL, '
      '${Strings.tyresInflatedYes} TINYINT(1) default NULL, '
      '${Strings.tyresInflatedNo} TINYINT(1) default NULL, '
      '${Strings.warningSignsYes} TINYINT(1) default NULL, '
      '${Strings.warningSignsNo} TINYINT(1) default NULL, '
      '${Strings.vehicleCompletedBy2} VARCHAR(255) default NULL, '
      '${Strings.nearestTank2} VARCHAR(255) default NULL, '
      '${Strings.vehicleFinishMileage} VARCHAR(255) default NULL, '
      '${Strings.ambulanceTidyYes2} TINYINT(1) default NULL, '
      '${Strings.ambulanceTidyNo2} TINYINT(1) default NULL, '
      '${Strings.sanitiserCleanYes} TINYINT(1) default NULL, '
      '${Strings.sanitiserCleanNo} TINYINT(1) default NULL, '
      '${Strings.issuesFaults} TEXT default NULL, '
      '${Strings.serverUploaded} TINYINT(1) default NULL, '
      '${Strings.timestamp} VARCHAR(255) default NULL)';


  static String createTemporaryTransferReportTableSql = 'CREATE TABLE IF NOT EXISTS ${Strings.temporaryTransferReportTable}('
      '${Strings.localId} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
      '${Strings.formVersion} VARCHAR(255) default NULL, '
      '${Strings.documentId} VARCHAR(255) default NULL, '
      '${Strings.jobId} VARCHAR(255) default NULL, '
      '${Strings.jobRef} VARCHAR(255) default NULL, '
      '${Strings.uid} VARCHAR(255) default NULL, '
      '${Strings.date} VARCHAR(255) default NULL, '
      '${Strings.startTime} VARCHAR(255) default NULL, '
      '${Strings.finishTime} VARCHAR(255) default NULL, '
      '${Strings.totalHours} VARCHAR(255) default NULL, '
      '${Strings.collectionDetails} TEXT default NULL, '
      '${Strings.collectionPostcode} VARCHAR(255) default NULL, '
      '${Strings.collectionContactNo} VARCHAR(255) default NULL, '
      '${Strings.destinationDetails} TEXT default NULL, '
      '${Strings.destinationPostcode} VARCHAR(255) default NULL, '
      '${Strings.destinationContactNo} VARCHAR(255) default NULL, '
      '${Strings.collectionArrivalTime} VARCHAR(255) default NULL, '
      '${Strings.collectionDepartureTime} VARCHAR(255) default NULL, '
      '${Strings.destinationArrivalTime} VARCHAR(255) default NULL, '
      '${Strings.destinationDepartureTime} VARCHAR(255) default NULL, '
      '${Strings.vehicleRegNo} VARCHAR(255) default NULL, '
      '${Strings.startMileage} VARCHAR(255) default NULL, '
      '${Strings.finishMileage} VARCHAR(255) default NULL, '
      '${Strings.totalMileage} VARCHAR(255) default NULL, '
      '${Strings.name1} VARCHAR(255) default NULL, '
      '${Strings.role1} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes1_1} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes1_2} VARCHAR(255) default NULL, '
      '${Strings.name2} VARCHAR(255) default NULL, '
      '${Strings.role2} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes2_1} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes2_2} VARCHAR(255) default NULL, '
      '${Strings.name3} VARCHAR(255) default NULL, '
      '${Strings.role3} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes3_1} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes3_2} VARCHAR(255) default NULL, '
      '${Strings.name4} VARCHAR(255) default NULL, '
      '${Strings.role4} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes4_1} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes4_2} VARCHAR(255) default NULL, '
      '${Strings.name5} VARCHAR(255) default NULL, '
      '${Strings.role5} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes5_1} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes5_2} VARCHAR(255) default NULL, '
      '${Strings.name6} VARCHAR(255) default NULL, '
      '${Strings.role6} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes6_1} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes6_2} VARCHAR(255) default NULL, '
      '${Strings.name7} VARCHAR(255) default NULL, '
      '${Strings.role7} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes7_1} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes7_2} VARCHAR(255) default NULL, '
      '${Strings.name8} VARCHAR(255) default NULL, '
      '${Strings.role8} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes8_1} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes8_2} VARCHAR(255) default NULL, '
      '${Strings.name9} VARCHAR(255) default NULL, '
      '${Strings.role9} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes9_1} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes9_2} VARCHAR(255) default NULL, '
      '${Strings.name10} VARCHAR(255) default NULL, '
      '${Strings.role10} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes10_1} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes10_2} VARCHAR(255) default NULL, '
      '${Strings.name11} VARCHAR(255) default NULL, '
      '${Strings.role11} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes11_1} VARCHAR(255) default NULL, '
      '${Strings.drivingTimes11_2} VARCHAR(255) default NULL, '
      '${Strings.collectionUnit} VARCHAR(255) default NULL, '
      '${Strings.collectionPosition} VARCHAR(255) default NULL, '
      '${Strings.collectionPrintName} VARCHAR(255) default NULL, '
      '${Strings.collectionArrivalTimeEnd} VARCHAR(255) default NULL, '
      '${Strings.collectionSignature} BLOB default NULL, '
      '${Strings.collectionSignaturePoints} JSON default NULL, '
      '${Strings.destinationUnit} VARCHAR(255) default NULL, '
      '${Strings.destinationPosition} VARCHAR(255) default NULL, '
      '${Strings.destinationPrintName} VARCHAR(255) default NULL, '
      '${Strings.destinationArrivalTimeEnd} VARCHAR(255) default NULL, '
      '${Strings.destinationSignature} BLOB default NULL, '
      '${Strings.destinationSignaturePoints} JSON default NULL, '
      '${Strings.patientName} VARCHAR(255) default NULL, '
      '${Strings.dateOfBirth} VARCHAR(255) default NULL, '
      '${Strings.ethnicity} VARCHAR(255) default NULL, '
      '${Strings.gender} VARCHAR(255) default NULL, '
      '${Strings.mhaMcaDetails} VARCHAR(255) default NULL, '
      '${Strings.diagnosis} VARCHAR(255) default NULL, '
      '${Strings.currentPresentation} VARCHAR(255) default NULL, '
      '${Strings.riskYes} TINYINT(1) default NULL, '
      '${Strings.riskNo} TINYINT(1) default NULL, '
      '${Strings.riskExplanation} TEXT default NULL, '
      '${Strings.forensicHistoryYes}  TINYINT(1) default NULL, '
      '${Strings.forensicHistoryNo} TINYINT(1) default NULL, '
      '${Strings.racialGenderConcernsYes} TINYINT(1) default NULL, '
      '${Strings.racialGenderConcernsNo}  TINYINT(1) default NULL, '
      '${Strings.violenceAggressionYes} TINYINT(1) default NULL, '
      '${Strings.violenceAggressionNo}  TINYINT(1) default NULL, '
      '${Strings.selfHarmYes} TINYINT(1) default NULL, '
      '${Strings.selfHarmNo}  TINYINT(1) default NULL, '
      '${Strings.alcoholSubstanceYes} TINYINT(1) default NULL, '
      '${Strings.alcoholSubstanceNo}  TINYINT(1) default NULL, '
      '${Strings.virusesYes}  TINYINT(1) default NULL, '
      '${Strings.virusesNo} TINYINT(1) default NULL, '
      '${Strings.safeguardingYes} TINYINT(1) default NULL, '
      '${Strings.safeguardingNo}  TINYINT(1) default NULL, '
      '${Strings.physicalHealthConditionsYes} TINYINT(1) default NULL, '
      '${Strings.physicalHealthConditionsNo}  TINYINT(1) default NULL, '
      '${Strings.useOfWeaponYes}  TINYINT(1) default NULL, '
      '${Strings.useOfWeaponNo} TINYINT(1) default NULL, '
      '${Strings.absconsionRiskYes} TINYINT(1) default NULL, '
      '${Strings.absconsionRiskNo}  TINYINT(1) default NULL, '
      '${Strings.forensicHistory} VARCHAR(255) default NULL, '
      '${Strings.racialGenderConcerns} VARCHAR(255) default NULL, '
      '${Strings.violenceAggression} VARCHAR(255) default NULL, '
      '${Strings.selfHarm} VARCHAR(255) default NULL, '
      '${Strings.alcoholSubstance} VARCHAR(255) default NULL, '
      '${Strings.viruses} VARCHAR(255) default NULL, '
      '${Strings.safeguarding} VARCHAR(255) default NULL, '
      '${Strings.physicalHealthConditions} VARCHAR(255) default NULL, '
      '${Strings.useOfWeapon} VARCHAR(255) default NULL, '
      '${Strings.absconsionRisk} VARCHAR(255) default NULL, '
      '${Strings.patientPropertyYes} TINYINT(1) default NULL, '
      '${Strings.patientPropertyNo} TINYINT(1) default NULL, '
      '${Strings.patientPropertyExplanation} TEXT default NULL, '
      '${Strings.patientPropertyReceived} VARCHAR(255) default NULL, '
      '${Strings.patientPropertyReceivedYes} TINYINT(1) default NULL, '
      '${Strings.patientPropertyReceivedNo} TINYINT(1) default NULL, '
      '${Strings.patientNotesReceived} VARCHAR(255) default NULL, '
      '${Strings.patientNotesReceivedYes} TINYINT(1) default NULL, '
      '${Strings.patientNotesReceivedNo} TINYINT(1) default NULL, '
      '${Strings.patientSearchedYes} TINYINT(1) default NULL, '
      '${Strings.patientSearchedNo} TINYINT(1) default NULL, '
      '${Strings.patientSearched} VARCHAR(255) default NULL, '
      '${Strings.itemsRemovedYes} TINYINT(1) default NULL, '
      '${Strings.itemsRemovedNo} TINYINT(1) default NULL, '
      '${Strings.itemsRemoved} VARCHAR(255) default NULL, '
      '${Strings.patientInformed} VARCHAR(255) default NULL, '
      '${Strings.injuriesNoted} VARCHAR(255) default NULL, '
      '${Strings.bodyMapPoints} JSON default NULL, '
      '${Strings.bodyMapImage} BLOB default NULL, '
      '${Strings.medicalAttentionYes} TINYINT(1) default NULL, '
      '${Strings.medicalAttentionNo} TINYINT(1) default NULL, '
      '${Strings.relevantInformationYes} TINYINT(1) default NULL, '
      '${Strings.relevantInformationNo} TINYINT(1) default NULL, '
      '${Strings.medicalAttention} VARCHAR(255) default NULL, '
      '${Strings.currentMedication} VARCHAR(255) default NULL, '
      '${Strings.physicalObservations} VARCHAR(255) default NULL, '
      '${Strings.relevantInformation} VARCHAR(255) default NULL, '
      '${Strings.patientReport} TEXT default NULL, '
      '${Strings.patientReportPrintName} VARCHAR(255) default NULL, '
      '${Strings.patientReportRole} VARCHAR(255) default NULL, '
      '${Strings.patientReportDate} VARCHAR(255) default NULL, '
      '${Strings.patientReportTime} VARCHAR(255) default NULL, '
      '${Strings.patientReportSignature} BLOB default NULL, '
      '${Strings.patientReportSignaturePoints} JSON default NULL, '
      '${Strings.handcuffsUsedYes} TINYINT(1) default NULL, '
      '${Strings.handcuffsUsedNo} TINYINT(1) default NULL, '
      '${Strings.handcuffsDate} VARCHAR(255) default NULL, '
      '${Strings.handcuffsTime} VARCHAR(255) default NULL, '
      '${Strings.handcuffsAuthorisedBy} VARCHAR(255) default NULL, '
      '${Strings.handcuffsAppliedBy} VARCHAR(255) default NULL, '
      '${Strings.handcuffsRemovedTime} VARCHAR(255) default NULL, '
      '${Strings.physicalInterventionYes} TINYINT(1) default NULL, '
      '${Strings.physicalInterventionNo} TINYINT(1) default NULL, '
      '${Strings.physicalIntervention} VARCHAR(255) default NULL, '
      '${Strings.whyInterventionRequired} TEXT default NULL, '
      '${Strings.techniqueName1} VARCHAR(255) default NULL, '
      '${Strings.techniqueName2} VARCHAR(255) default NULL, '
      '${Strings.techniqueName3} VARCHAR(255) default NULL, '
      '${Strings.techniqueName4} VARCHAR(255) default NULL, '
      '${Strings.techniqueName5} VARCHAR(255) default NULL, '
      '${Strings.techniqueName6} VARCHAR(255) default NULL, '
      '${Strings.techniqueName7} VARCHAR(255) default NULL, '
      '${Strings.techniqueName8} VARCHAR(255) default NULL, '
      '${Strings.techniqueName9} VARCHAR(255) default NULL, '
      '${Strings.techniqueName10} VARCHAR(255) default NULL, '
      '${Strings.technique1} VARCHAR(255) default NULL, '
      '${Strings.technique2} VARCHAR(255) default NULL, '
      '${Strings.technique3} VARCHAR(255) default NULL, '
      '${Strings.technique4} VARCHAR(255) default NULL, '
      '${Strings.technique5} VARCHAR(255) default NULL, '
      '${Strings.technique6} VARCHAR(255) default NULL, '
      '${Strings.technique7} VARCHAR(255) default NULL, '
      '${Strings.technique8} VARCHAR(255) default NULL, '
      '${Strings.technique9} VARCHAR(255) default NULL, '
      '${Strings.technique10} VARCHAR(255) default NULL, '
      '${Strings.techniquePosition1} VARCHAR(255) default NULL, '
      '${Strings.techniquePosition2} VARCHAR(255) default NULL, '
      '${Strings.techniquePosition3} VARCHAR(255) default NULL, '
      '${Strings.techniquePosition4} VARCHAR(255) default NULL, '
      '${Strings.techniquePosition5} VARCHAR(255) default NULL, '
      '${Strings.techniquePosition6} VARCHAR(255) default NULL, '
      '${Strings.techniquePosition7} VARCHAR(255) default NULL, '
      '${Strings.techniquePosition8} VARCHAR(255) default NULL, '
      '${Strings.techniquePosition9} VARCHAR(255) default NULL, '
      '${Strings.techniquePosition10} VARCHAR(255) default NULL, '
      '${Strings.timeInterventionCommenced} VARCHAR(255) default NULL, '
      '${Strings.timeInterventionCompleted} VARCHAR(255) default NULL, '
      '${Strings.incidentDate} VARCHAR(255) default NULL, '
      '${Strings.incidentTime} VARCHAR(255) default NULL, '
      '${Strings.incidentDetails} TEXT default NULL, '
      '${Strings.incidentLocation} TEXT default NULL, '
      '${Strings.incidentAction} TEXT default NULL, '
      '${Strings.incidentStaffInvolved} TEXT default NULL, '
      '${Strings.incidentSignature} BLOB default NULL, '
      '${Strings.incidentSignaturePoints} JSON default NULL, '
      '${Strings.incidentSignatureDate} TEXT default NULL, '
      '${Strings.incidentPrintName} TEXT default NULL, '
      '${Strings.hasSection2Checklist} TINYINT(1) default NULL, '
      '${Strings.hasSection3Checklist} TINYINT(1) default NULL, '
      '${Strings.hasSection3TransferChecklist} TINYINT(1) default NULL, '
      '${Strings.transferInPatientName1} VARCHAR(255) default NULL, '
      '${Strings.patientCorrectYes1} TINYINT(1) default NULL, '
      '${Strings.patientCorrectNo1} TINYINT(1) default NULL, '
      '${Strings.hospitalCorrectYes1} TINYINT(1) default NULL, '
      '${Strings.hospitalCorrectNo1} TINYINT(1) default NULL, '
      '${Strings.applicationFormYes1} TINYINT(1) default NULL, '
      '${Strings.applicationFormNo1} TINYINT(1) default NULL, '
      '${Strings.applicationSignedYes1} TINYINT(1) default NULL, '
      '${Strings.applicationSignedNo1} TINYINT(1) default NULL, '
      '${Strings.within14DaysYes1} TINYINT(1) default NULL, '
      '${Strings.within14DaysNo1} TINYINT(1) default NULL, '
      '${Strings.localAuthorityNameYes1} TINYINT(1) default NULL, '
      '${Strings.localAuthorityNameNo1} TINYINT(1) default NULL, '
      '${Strings.medicalRecommendationsFormYes1} TINYINT(1) default NULL, '
      '${Strings.medicalRecommendationsFormNo1} TINYINT(1) default NULL, '
      '${Strings.medicalRecommendationsSignedYes1} TINYINT(1) default NULL, '
      '${Strings.medicalRecommendationsSignedNo1} TINYINT(1) default NULL, '
      '${Strings.datesSignatureSignedYes} TINYINT(1) default NULL, '
      '${Strings.datesSignatureSignedNo} TINYINT(1) default NULL, '
      '${Strings.signatureDatesOnBeforeYes1} TINYINT(1) default NULL, '
      '${Strings.signatureDatesOnBeforeNo1} TINYINT(1) default NULL, '
      '${Strings.practitionersNameYes1} TINYINT(1) default NULL, '
      '${Strings.practitionersNameNo1} TINYINT(1) default NULL, '
      '${Strings.transferInCheckedBy1} VARCHAR(255) default NULL, '
      '${Strings.transferInDate1} VARCHAR(255) default NULL, '
      '${Strings.transferInDesignation1} VARCHAR(255) default NULL, '
      '${Strings.transferInSignature1} BLOB default NULL, '
      '${Strings.transferInSignaturePoints1} JSON default NULL, '
      '${Strings.transferInPatientName2} VARCHAR(255) default NULL, '
      '${Strings.patientCorrectYes2} TINYINT(1) default NULL, '
      '${Strings.patientCorrectNo2} TINYINT(1) default NULL, '
      '${Strings.hospitalCorrectYes2} TINYINT(1) default NULL, '
      '${Strings.hospitalCorrectNo2} TINYINT(1) default NULL, '
      '${Strings.applicationFormYes2} TINYINT(1) default NULL, '
      '${Strings.applicationFormNo2} TINYINT(1) default NULL, '
      '${Strings.applicationSignedYes2} TINYINT(1) default NULL, '
      '${Strings.applicationSignedNo2} TINYINT(1) default NULL, '
      '${Strings.amhpIdentifiedYes} TINYINT(1) default NULL, '
      '${Strings.amhpIdentifiedNo} TINYINT(1) default NULL, '
      '${Strings.medicalRecommendationsFormYes2} TINYINT(1) default NULL, '
      '${Strings.medicalRecommendationsFormNo2} TINYINT(1) default NULL, '
      '${Strings.medicalRecommendationsSignedYes2} TINYINT(1) default NULL, '
      '${Strings.medicalRecommendationsSignedNo2} TINYINT(1) default NULL, '
      '${Strings.clearDaysYes2} TINYINT(1) default NULL, '
      '${Strings.clearDaysNo2} TINYINT(1) default NULL, '
      '${Strings.signatureDatesOnBeforeYes2} TINYINT(1) default NULL, '
      '${Strings.signatureDatesOnBeforeNo2} TINYINT(1) default NULL, '
      '${Strings.practitionersNameYes2} TINYINT(1) default NULL, '
      '${Strings.practitionersNameNo2} TINYINT(1) default NULL, '
      '${Strings.doctorsAgreeYes} TINYINT(1) default NULL, '
      '${Strings.doctorsAgreeNo} TINYINT(1) default NULL, '
      '${Strings.separateMedicalRecommendationsYes} TINYINT(1) default NULL, '
      '${Strings.separateMedicalRecommendationsNo} TINYINT(1) default NULL, '
      '${Strings.transferInCheckedBy2} VARCHAR(255) default NULL, '
      '${Strings.transferInDate2} VARCHAR(255) default NULL, '
      '${Strings.transferInDesignation2} VARCHAR(255) default NULL, '
      '${Strings.transferInSignature2} BLOB default NULL, '
      '${Strings.transferInSignaturePoints2} JSON default NULL, '
      '${Strings.transferInPatientName3} VARCHAR(255) default NULL, '
      '${Strings.patientCorrectYes3} TINYINT(1) default NULL, '
      '${Strings.patientCorrectNo3} TINYINT(1) default NULL, '
      '${Strings.hospitalCorrectYes3} TINYINT(1) default NULL, '
      '${Strings.hospitalCorrectNo3} TINYINT(1) default NULL, '
      '${Strings.h4Yes} TINYINT(1) default NULL, '
      '${Strings.h4No} TINYINT(1) default NULL, '
      '${Strings.currentConsentYes} TINYINT(1) default NULL, '
      '${Strings.currentConsentNo} TINYINT(1) default NULL, '
      '${Strings.applicationFormYes3} TINYINT(1) default NULL, '
      '${Strings.applicationFormNo3} TINYINT(1) default NULL, '
      '${Strings.applicationSignedYes3} TINYINT(1) default NULL, '
      '${Strings.applicationSignedNo3} TINYINT(1) default NULL, '
      '${Strings.within14DaysYes3} TINYINT(1) default NULL, '
      '${Strings.within14DaysNo3} TINYINT(1) default NULL, '
      '${Strings.localAuthorityNameYes3} TINYINT(1) default NULL, '
      '${Strings.localAuthorityNameNo3} TINYINT(1) default NULL, '
      '${Strings.nearestRelativeYes} TINYINT(1) default NULL, '
      '${Strings.nearestRelativeNo} TINYINT(1) default NULL, '
      '${Strings.amhpConsultationYes} TINYINT(1) default NULL, '
      '${Strings.amhpConsultationNo} TINYINT(1) default NULL, '
      '${Strings.knewPatientYes} TINYINT(1) default NULL, '
      '${Strings.knewPatientNo} TINYINT(1) default NULL, '
      '${Strings.medicalRecommendationsFormYes3} TINYINT(1) default NULL, '
      '${Strings.medicalRecommendationsFormNo3} TINYINT(1) default NULL, '
      '${Strings.medicalRecommendationsSignedYes3} TINYINT(1) default NULL, '
      '${Strings.medicalRecommendationsSignedNo3} TINYINT(1) default NULL, '
      '${Strings.clearDaysYes3} TINYINT(1) default NULL, '
      '${Strings.clearDaysNo3} TINYINT(1) default NULL, '
      '${Strings.approvedSection12Yes} TINYINT(1) default NULL, '
      '${Strings.approvedSection12No} TINYINT(1) default NULL, '
      '${Strings.signatureDatesOnBeforeYes3} TINYINT(1) default NULL, '
      '${Strings.signatureDatesOnBeforeNo3} TINYINT(1) default NULL, '
      '${Strings.practitionersNameYes3} TINYINT(1) default NULL, '
      '${Strings.practitionersNameNo3} TINYINT(1) default NULL, '
      '${Strings.previouslyAcquaintedYes} TINYINT(1) default NULL, '
      '${Strings.previouslyAcquaintedNo} TINYINT(1) default NULL, '
      '${Strings.acquaintedIfNoYes} TINYINT(1) default NULL, '
      '${Strings.acquaintedIfNoNo} TINYINT(1) default NULL, '
      '${Strings.recommendationsDifferentTeamsYes} TINYINT(1) default NULL, '
      '${Strings.recommendationsDifferentTeamsNo} TINYINT(1) default NULL, '
      '${Strings.originalDetentionPapersYes} TINYINT(1) default NULL, '
      '${Strings.originalDetentionPapersNo} TINYINT(1) default NULL, '
      '${Strings.transferInCheckedBy3} VARCHAR(255) default NULL, '
      '${Strings.transferInDate3} VARCHAR(255) default NULL, '
      '${Strings.transferInDesignation3} VARCHAR(255) default NULL, '
      '${Strings.transferInSignature3} BLOB default NULL, '
      '${Strings.transferInSignaturePoints3} JSON default NULL, '
      '${Strings.feltSafeYes} TINYINT(1) default NULL, '
      '${Strings.feltSafeNo} TINYINT(1) default NULL, '
      '${Strings.staffIntroducedYes} TINYINT(1) default NULL, '
      '${Strings.staffIntroducedNo} TINYINT(1) default NULL, '
      '${Strings.experiencePositiveYes} TINYINT(1) default NULL, '
      '${Strings.experiencePositiveNo} TINYINT(1) default NULL, '
      '${Strings.otherComments} TEXT default NULL, '
      '${Strings.vehicleCompletedBy1} VARCHAR(255) default NULL, '
      '${Strings.vehicleDate} VARCHAR(255) default NULL, '
      '${Strings.vehicleTime} VARCHAR(255) default NULL, '
      '${Strings.ambulanceReg} VARCHAR(255) default NULL, '
      '${Strings.vehicleStartMileage} VARCHAR(255) default NULL, '
      '${Strings.nearestTank1} VARCHAR(255) default NULL, '
      '${Strings.ambulanceTidyYes1} TINYINT(1) default NULL, '
      '${Strings.ambulanceTidyNo1} TINYINT(1) default NULL, '
      '${Strings.lightsWorkingYes} TINYINT(1) default NULL, '
      '${Strings.lightsWorkingNo} TINYINT(1) default NULL, '
      '${Strings.tyresInflatedYes} TINYINT(1) default NULL, '
      '${Strings.tyresInflatedNo} TINYINT(1) default NULL, '
      '${Strings.warningSignsYes} TINYINT(1) default NULL, '
      '${Strings.warningSignsNo} TINYINT(1) default NULL, '
      '${Strings.vehicleCompletedBy2} VARCHAR(255) default NULL, '
      '${Strings.nearestTank2} VARCHAR(255) default NULL, '
      '${Strings.vehicleFinishMileage} VARCHAR(255) default NULL, '
      '${Strings.ambulanceTidyYes2} TINYINT(1) default NULL, '
      '${Strings.ambulanceTidyNo2} TINYINT(1) default NULL, '
      '${Strings.sanitiserCleanYes} TINYINT(1) default NULL, '
      '${Strings.sanitiserCleanNo} TINYINT(1) default NULL, '
      '${Strings.issuesFaults} TEXT default NULL)';


  List<String> createAllTables = [createUsersTableSql, createFirebaseStorageUrlTable,
    createBookingFormTableSql, createTemporaryBookingFormTableSql, createEditedBookingFormTableSql,
    createObservationBookingTableSql, createTemporaryObservationBookingTableSql, createEditedObservationBookingTableSql,
    createTransferReportTableSql, createTemporaryTransferReportTableSql, createEditedTransferReportTableSql,
    createIncidentReportTableSql, createEditedIncidentReportTableSql, createTemporaryIncidentReportTableSql];

  //Named constructor to create instance of DatabaseHelper
  DatabaseHelper._createInstance();

  //factory keyword allows the constructor to return some value
  factory DatabaseHelper() {
    //initialize our object as well and add a null check so we will create the instance of the database helper only if it is null, this statement will
    //only be executed once in the application

    if(!kIsWeb) {
      if (_databaseHelper == null) {
        _databaseHelper = DatabaseHelper._createInstance();
      }
    }
    return _databaseHelper;
  }

  //getter for our database
  Future<Database> get database async {
    //if it is null initialize it otherwise return the older instance

    if(!kIsWeb) {
      if (_database == null) {
        _database = await initializeDatabase();
      }
    }
    return _database;
  }

  //function to initialise our database
  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, 'hytechGas.db');

    //open/create the database at this given path
    var appDatabase =
    await openDatabase(path, version: 1, onCreate: _createDb, onUpgrade: _onUpgrade);
    return appDatabase;
  }

  //create a function to help us to execute a statement to create our database
  void _createDb(Database db, int newVersion) async {

    try {
      for (String table in createAllTables) {
        db.execute(table);
      }
    } catch (e){
      print(e);
    }

  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) async {

    print('running on upgrade');

    try {
      for (String table in createAllTables) {
        db.execute(table);
      }
    } catch (e){
      print(e);
    }

    // if (oldVersion < 2) {
    //   print('adding risk fields to patient details');
    //   db.execute("ALTER TABLE ${Strings.transferReportTable} ADD COLUMN ${Strings.riskYes} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.transferReportTable} ADD COLUMN ${Strings.riskNo} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.transferReportTable} ADD COLUMN ${Strings.riskExplanation} TEXT default NULL;");
    //
    //   db.execute("ALTER TABLE ${Strings.temporaryTransferReportTable} ADD COLUMN ${Strings.riskYes} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.temporaryTransferReportTable} ADD COLUMN ${Strings.riskNo} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.temporaryTransferReportTable} ADD COLUMN ${Strings.riskExplanation} TEXT default NULL;");
    //
    //   db.execute("ALTER TABLE ${Strings.editedTransferReportTable} ADD COLUMN ${Strings.riskYes} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.editedTransferReportTable} ADD COLUMN ${Strings.riskNo} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.editedTransferReportTable} ADD COLUMN ${Strings.riskExplanation} TEXT default NULL;");
    //
    //   db.execute("ALTER TABLE ${Strings.transferReportTable} ADD COLUMN ${Strings.patientPropertyYes} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.transferReportTable} ADD COLUMN ${Strings.patientPropertyNo} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.transferReportTable} ADD COLUMN ${Strings.patientPropertyExplanation} TEXT default NULL;");
    //
    //   db.execute("ALTER TABLE ${Strings.temporaryTransferReportTable} ADD COLUMN ${Strings.patientPropertyYes} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.temporaryTransferReportTable} ADD COLUMN ${Strings.patientPropertyNo} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.temporaryTransferReportTable} ADD COLUMN ${Strings.patientPropertyExplanation} TEXT default NULL;");
    //
    //   db.execute("ALTER TABLE ${Strings.editedTransferReportTable} ADD COLUMN ${Strings.patientPropertyYes} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.editedTransferReportTable} ADD COLUMN ${Strings.patientPropertyNo} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.editedTransferReportTable} ADD COLUMN ${Strings.patientPropertyExplanation} TEXT default NULL;");
    //
    //   db.execute("ALTER TABLE ${Strings.transferReportTable} ADD COLUMN ${Strings.patientSearchedYes} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.transferReportTable} ADD COLUMN ${Strings.patientSearchedNo} TINYINT(1) default NULL;");
    //
    //   db.execute("ALTER TABLE ${Strings.temporaryTransferReportTable} ADD COLUMN ${Strings.patientSearchedYes} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.temporaryTransferReportTable} ADD COLUMN ${Strings.patientSearchedNo} TINYINT(1) default NULL;");
    //
    //   db.execute("ALTER TABLE ${Strings.editedTransferReportTable} ADD COLUMN ${Strings.patientSearchedYes} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.editedTransferReportTable} ADD COLUMN ${Strings.patientSearchedNo} TINYINT(1) default NULL;");
    //
    //   db.execute("ALTER TABLE ${Strings.transferReportTable} ADD COLUMN ${Strings.itemsRemovedYes} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.transferReportTable} ADD COLUMN ${Strings.itemsRemovedNo} TINYINT(1) default NULL;");
    //
    //   db.execute("ALTER TABLE ${Strings.temporaryTransferReportTable} ADD COLUMN ${Strings.itemsRemovedYes} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.temporaryTransferReportTable} ADD COLUMN ${Strings.itemsRemovedNo} TINYINT(1) default NULL;");
    //
    //   db.execute("ALTER TABLE ${Strings.editedTransferReportTable} ADD COLUMN ${Strings.itemsRemovedYes} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.editedTransferReportTable} ADD COLUMN ${Strings.itemsRemovedNo} TINYINT(1) default NULL;");
    //
    //   db.execute("ALTER TABLE ${Strings.transferReportTable} ADD COLUMN ${Strings.patientPropertyReceivedYes} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.transferReportTable} ADD COLUMN ${Strings.patientPropertyReceivedNo} TINYINT(1) default NULL;");
    //
    //   db.execute("ALTER TABLE ${Strings.temporaryTransferReportTable} ADD COLUMN ${Strings.patientPropertyReceivedYes} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.temporaryTransferReportTable} ADD COLUMN ${Strings.patientPropertyReceivedNo} TINYINT(1) default NULL;");
    //
    //   db.execute("ALTER TABLE ${Strings.editedTransferReportTable} ADD COLUMN ${Strings.patientPropertyReceivedYes} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.editedTransferReportTable} ADD COLUMN ${Strings.patientPropertyReceivedNo} TINYINT(1) default NULL;");
    //
    //   db.execute("ALTER TABLE ${Strings.transferReportTable} ADD COLUMN ${Strings.patientNotesReceivedYes} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.transferReportTable} ADD COLUMN ${Strings.patientNotesReceivedNo} TINYINT(1) default NULL;");
    //
    //   db.execute("ALTER TABLE ${Strings.temporaryTransferReportTable} ADD COLUMN ${Strings.patientNotesReceivedYes} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.temporaryTransferReportTable} ADD COLUMN ${Strings.patientNotesReceivedNo} TINYINT(1) default NULL;");
    //
    //   db.execute("ALTER TABLE ${Strings.editedTransferReportTable} ADD COLUMN ${Strings.patientNotesReceivedYes} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.editedTransferReportTable} ADD COLUMN ${Strings.patientNotesReceivedNo} TINYINT(1) default NULL;");
    //
    //   db.execute("ALTER TABLE ${Strings.transferReportTable} ADD COLUMN ${Strings.forensicHistoryYes} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.transferReportTable} ADD COLUMN ${Strings.forensicHistoryNo} TINYINT(1) default NULL;");
    //
    //   db.execute("ALTER TABLE ${Strings.temporaryTransferReportTable} ADD COLUMN ${Strings.forensicHistoryYes} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.temporaryTransferReportTable} ADD COLUMN ${Strings.forensicHistoryNo} TINYINT(1) default NULL;");
    //
    //   db.execute("ALTER TABLE ${Strings.editedTransferReportTable} ADD COLUMN ${Strings.forensicHistoryYes} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.editedTransferReportTable} ADD COLUMN ${Strings.forensicHistoryNo} TINYINT(1) default NULL;");
    //
    //   db.execute("ALTER TABLE ${Strings.transferReportTable} ADD COLUMN ${Strings.racialGenderConcernsYes} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.transferReportTable} ADD COLUMN ${Strings.racialGenderConcernsNo} TINYINT(1) default NULL;");
    //
    //   db.execute("ALTER TABLE ${Strings.temporaryTransferReportTable} ADD COLUMN ${Strings.racialGenderConcernsYes} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.temporaryTransferReportTable} ADD COLUMN ${Strings.racialGenderConcernsNo} TINYINT(1) default NULL;");
    //
    //   db.execute("ALTER TABLE ${Strings.editedTransferReportTable} ADD COLUMN ${Strings.racialGenderConcernsYes} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.editedTransferReportTable} ADD COLUMN ${Strings.racialGenderConcernsNo} TINYINT(1) default NULL;");
    //
    //   db.execute("ALTER TABLE ${Strings.transferReportTable} ADD COLUMN ${Strings.violenceAggressionYes} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.transferReportTable} ADD COLUMN ${Strings.violenceAggressionNo} TINYINT(1) default NULL;");
    //
    //   db.execute("ALTER TABLE ${Strings.temporaryTransferReportTable} ADD COLUMN ${Strings.violenceAggressionYes} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.temporaryTransferReportTable} ADD COLUMN ${Strings.violenceAggressionNo} TINYINT(1) default NULL;");
    //
    //   db.execute("ALTER TABLE ${Strings.editedTransferReportTable} ADD COLUMN ${Strings.violenceAggressionYes} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.editedTransferReportTable} ADD COLUMN ${Strings.violenceAggressionNo} TINYINT(1) default NULL;");
    //
    //   db.execute("ALTER TABLE ${Strings.transferReportTable} ADD COLUMN ${Strings.selfHarmYes} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.transferReportTable} ADD COLUMN ${Strings.selfHarmNo} TINYINT(1) default NULL;");
    //
    //   db.execute("ALTER TABLE ${Strings.temporaryTransferReportTable} ADD COLUMN ${Strings.selfHarmYes} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.temporaryTransferReportTable} ADD COLUMN ${Strings.selfHarmNo} TINYINT(1) default NULL;");
    //
    //   db.execute("ALTER TABLE ${Strings.editedTransferReportTable} ADD COLUMN ${Strings.selfHarmYes} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.editedTransferReportTable} ADD COLUMN ${Strings.selfHarmNo} TINYINT(1) default NULL;");
    //
    //   db.execute("ALTER TABLE ${Strings.transferReportTable} ADD COLUMN ${Strings.alcoholSubstanceYes} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.transferReportTable} ADD COLUMN ${Strings.alcoholSubstanceNo} TINYINT(1) default NULL;");
    //
    //   db.execute("ALTER TABLE ${Strings.temporaryTransferReportTable} ADD COLUMN ${Strings.alcoholSubstanceYes} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.temporaryTransferReportTable} ADD COLUMN ${Strings.alcoholSubstanceNo} TINYINT(1) default NULL;");
    //
    //   db.execute("ALTER TABLE ${Strings.editedTransferReportTable} ADD COLUMN ${Strings.alcoholSubstanceYes} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.editedTransferReportTable} ADD COLUMN ${Strings.alcoholSubstanceNo} TINYINT(1) default NULL;");
    //
    //   db.execute("ALTER TABLE ${Strings.transferReportTable} ADD COLUMN ${Strings.virusesYes} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.transferReportTable} ADD COLUMN ${Strings.virusesNo} TINYINT(1) default NULL;");
    //
    //   db.execute("ALTER TABLE ${Strings.temporaryTransferReportTable} ADD COLUMN ${Strings.virusesYes} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.temporaryTransferReportTable} ADD COLUMN ${Strings.virusesNo} TINYINT(1) default NULL;");
    //
    //   db.execute("ALTER TABLE ${Strings.editedTransferReportTable} ADD COLUMN ${Strings.virusesYes} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.editedTransferReportTable} ADD COLUMN ${Strings.virusesNo} TINYINT(1) default NULL;");
    //
    //   db.execute("ALTER TABLE ${Strings.transferReportTable} ADD COLUMN ${Strings.safeguardingYes} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.transferReportTable} ADD COLUMN ${Strings.safeguardingNo} TINYINT(1) default NULL;");
    //
    //   db.execute("ALTER TABLE ${Strings.temporaryTransferReportTable} ADD COLUMN ${Strings.safeguardingYes} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.temporaryTransferReportTable} ADD COLUMN ${Strings.safeguardingNo} TINYINT(1) default NULL;");
    //
    //   db.execute("ALTER TABLE ${Strings.editedTransferReportTable} ADD COLUMN ${Strings.safeguardingYes} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.editedTransferReportTable} ADD COLUMN ${Strings.safeguardingNo} TINYINT(1) default NULL;");
    //
    //   db.execute("ALTER TABLE ${Strings.transferReportTable} ADD COLUMN ${Strings.physicalHealthConditionsYes} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.transferReportTable} ADD COLUMN ${Strings.physicalHealthConditionsNo} TINYINT(1) default NULL;");
    //
    //   db.execute("ALTER TABLE ${Strings.temporaryTransferReportTable} ADD COLUMN ${Strings.physicalHealthConditionsYes} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.temporaryTransferReportTable} ADD COLUMN ${Strings.physicalHealthConditionsNo} TINYINT(1) default NULL;");
    //
    //   db.execute("ALTER TABLE ${Strings.editedTransferReportTable} ADD COLUMN ${Strings.physicalHealthConditionsYes} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.editedTransferReportTable} ADD COLUMN ${Strings.physicalHealthConditionsNo} TINYINT(1) default NULL;");
    //
    //   db.execute("ALTER TABLE ${Strings.transferReportTable} ADD COLUMN ${Strings.useOfWeaponYes} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.transferReportTable} ADD COLUMN ${Strings.useOfWeaponNo} TINYINT(1) default NULL;");
    //
    //   db.execute("ALTER TABLE ${Strings.temporaryTransferReportTable} ADD COLUMN ${Strings.useOfWeaponYes} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.temporaryTransferReportTable} ADD COLUMN ${Strings.useOfWeaponNo} TINYINT(1) default NULL;");
    //
    //   db.execute("ALTER TABLE ${Strings.editedTransferReportTable} ADD COLUMN ${Strings.useOfWeaponYes} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.editedTransferReportTable} ADD COLUMN ${Strings.useOfWeaponNo} TINYINT(1) default NULL;");
    //
    //   db.execute("ALTER TABLE ${Strings.transferReportTable} ADD COLUMN ${Strings.absconsionRiskYes} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.transferReportTable} ADD COLUMN ${Strings.absconsionRiskNo} TINYINT(1) default NULL;");
    //
    //   db.execute("ALTER TABLE ${Strings.temporaryTransferReportTable} ADD COLUMN ${Strings.absconsionRiskYes} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.temporaryTransferReportTable} ADD COLUMN ${Strings.absconsionRiskNo} TINYINT(1) default NULL;");
    //
    //   db.execute("ALTER TABLE ${Strings.editedTransferReportTable} ADD COLUMN ${Strings.absconsionRiskYes} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.editedTransferReportTable} ADD COLUMN ${Strings.absconsionRiskNo} TINYINT(1) default NULL;");
    //
    //   //Body Map
    //
    //   db.execute("ALTER TABLE ${Strings.transferReportTable} ADD COLUMN ${Strings.medicalAttentionYes} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.transferReportTable} ADD COLUMN ${Strings.medicalAttentionNo} TINYINT(1) default NULL;");
    //
    //   db.execute("ALTER TABLE ${Strings.temporaryTransferReportTable} ADD COLUMN ${Strings.medicalAttentionYes} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.temporaryTransferReportTable} ADD COLUMN ${Strings.medicalAttentionNo} TINYINT(1) default NULL;");
    //
    //   db.execute("ALTER TABLE ${Strings.editedTransferReportTable} ADD COLUMN ${Strings.medicalAttentionYes} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.editedTransferReportTable} ADD COLUMN ${Strings.medicalAttentionNo} TINYINT(1) default NULL;");
    //
    //   db.execute("ALTER TABLE ${Strings.transferReportTable} ADD COLUMN ${Strings.relevantInformationYes} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.transferReportTable} ADD COLUMN ${Strings.relevantInformationNo} TINYINT(1) default NULL;");
    //
    //   db.execute("ALTER TABLE ${Strings.temporaryTransferReportTable} ADD COLUMN ${Strings.relevantInformationYes} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.temporaryTransferReportTable} ADD COLUMN ${Strings.relevantInformationNo} TINYINT(1) default NULL;");
    //
    //   db.execute("ALTER TABLE ${Strings.editedTransferReportTable} ADD COLUMN ${Strings.relevantInformationYes} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.editedTransferReportTable} ADD COLUMN ${Strings.relevantInformationNo} TINYINT(1) default NULL;");
    //
    //
    //   db.execute("ALTER TABLE ${Strings.transferReportTable} ADD COLUMN ${Strings.techniqueName9} VARCHAR(255) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.transferReportTable} ADD COLUMN ${Strings.techniqueName10} VARCHAR(255) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.transferReportTable} ADD COLUMN ${Strings.technique9} VARCHAR(255) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.transferReportTable} ADD COLUMN ${Strings.technique10} VARCHAR(255) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.transferReportTable} ADD COLUMN ${Strings.techniquePosition9} VARCHAR(255) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.transferReportTable} ADD COLUMN ${Strings.techniquePosition10} VARCHAR(255) default NULL;");
    //
    //   db.execute("ALTER TABLE ${Strings.temporaryTransferReportTable} ADD COLUMN ${Strings.techniqueName9} VARCHAR(255) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.temporaryTransferReportTable} ADD COLUMN ${Strings.techniqueName10} VARCHAR(255) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.temporaryTransferReportTable} ADD COLUMN ${Strings.technique9} VARCHAR(255) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.temporaryTransferReportTable} ADD COLUMN ${Strings.technique10} VARCHAR(255) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.temporaryTransferReportTable} ADD COLUMN ${Strings.techniquePosition9} VARCHAR(255) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.temporaryTransferReportTable} ADD COLUMN ${Strings.techniquePosition10} VARCHAR(255) default NULL;");
    //
    //   db.execute("ALTER TABLE ${Strings.editedTransferReportTable} ADD COLUMN ${Strings.techniqueName9} VARCHAR(255) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.editedTransferReportTable} ADD COLUMN ${Strings.techniqueName10} VARCHAR(255) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.editedTransferReportTable} ADD COLUMN ${Strings.technique9} VARCHAR(255) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.editedTransferReportTable} ADD COLUMN ${Strings.technique10} VARCHAR(255) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.editedTransferReportTable} ADD COLUMN ${Strings.techniquePosition9} VARCHAR(255) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.editedTransferReportTable} ADD COLUMN ${Strings.techniquePosition10} VARCHAR(255) default NULL;");
    //
    //
    //   db.execute("ALTER TABLE ${Strings.transferReportTable} ADD COLUMN ${Strings.hasSection2Checklist} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.transferReportTable} ADD COLUMN ${Strings.hasSection3Checklist} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.transferReportTable} ADD COLUMN ${Strings.hasSection3TransferChecklist} TINYINT(1) default NULL;");
    //
    //   db.execute("ALTER TABLE ${Strings.temporaryTransferReportTable} ADD COLUMN ${Strings.hasSection2Checklist} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.temporaryTransferReportTable} ADD COLUMN ${Strings.hasSection3Checklist} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.temporaryTransferReportTable} ADD COLUMN ${Strings.hasSection3TransferChecklist} TINYINT(1) default NULL;");
    //
    //   db.execute("ALTER TABLE ${Strings.editedTransferReportTable} ADD COLUMN ${Strings.hasSection2Checklist} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.editedTransferReportTable} ADD COLUMN ${Strings.hasSection3Checklist} TINYINT(1) default NULL;");
    //   db.execute("ALTER TABLE ${Strings.editedTransferReportTable} ADD COLUMN ${Strings.hasSection3TransferChecklist} TINYINT(1) default NULL;");
    //
    // }
    //
    // if(oldVersion < 3){
    //
    //   db.execute("ALTER TABLE ${Strings.usersTable} ADD COLUMN ${Strings.profilePicture} TEXT default NULL;");
    //
    // }

  }

  //Get all items from a database table
  Future<List<Map<String, dynamic>>> get(String tableName, String orderBy, String direction) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName order by $orderBy ' '$direction');
    return result;
  }

  Future<List<Map<String, dynamic>>> getLast10(String tableName, String orderBy, String direction) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName order by $orderBy ' '$direction'' LIMIT 10');
    return result;
  }

  Future<List<Map<String, dynamic>>> get10More(String tableName, String field, String direction, String timestamp) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field < ? order by $field ' '$direction'' LIMIT 10', [timestamp]);
    return result;
  }

  Future<List<Map<String, dynamic>>> get10MoreWhereAndWhereAndWhere(String tableName, String field1, var value1, String field2, var value2, String field3, var value3, String direction) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? AND $field2 < ? AND $field3 < ? order by $field2 ' '$direction'' LIMIT 10', [value1,value2, value3]);
    return result;
  }

  Future<List<Map<String, dynamic>>> get10MoreWhereAndWhereOrderByOrderBy(String tableName, String field1, var value1, String field2, var value2, String direction) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 < ? AND $field2 < ? order by $field1 $direction, $field2 $direction LIMIT 10', [value1,value2]);
    return result;
  }

  Future<List<Map<String, dynamic>>> get10MoreWhereAndWhereAndWhereOrderByOrderBy(String tableName, String field1, var value1, String field2, var value2, String field3, var value3, String direction) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? AND $field2 < ? AND $field3 < ? order by $field2 $direction, $field3 $direction LIMIT 10', [value1,value2, value3]);
    return result;
  }

  Future<List<Map<String, dynamic>>> get10MoreWhereAndWhereAndWhereAndWhereOrderByOrderBy(String tableName, String field1, var value1, String field2, var value2, String field3, var value3, String field4, var value4, String direction) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? AND $field2 = ? AND $field3 < ? AND $field4 < ? order by $field3 $direction, $field4 $direction LIMIT 10', [value1,value2, value3, value4]);
    return result;
  }

  Future<List<Map<String, dynamic>>> get10MoreWhereAndWhereAndWhereAndWhereAndWhereOrderByOrderBy(String tableName, String field1, var value1, String field2, var value2, String field3, var value3, String field4, var value4, String field5, var value5, String direction) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? AND $field2 = ? AND $field3 = ? AND $field4 < ? AND $field5 < ? order by $field4 $direction, $field5 $direction LIMIT 10', [value1,value2, value3, value4, value5]);
    return result;
  }



  //Insert Operation: Insert an item into a database table
  Future<int> add(String tableName, Map<String, dynamic> data) async {
    Database db = await this.database;

    int result;

    try{
      result = await db.insert(tableName, data);
    } catch(e){
      print(e);
    }
    return result;
  }

  Future<int> update(String tableName, Map<String, dynamic> data) async {
    Database db = await this.database;

    int result = await db.update(tableName, data);

    return result;
  }

  Future<int> updateRow(String tableName, Map<String, dynamic> data, String field1, var value1) async {
    Database db = await this.database;

    int result;

    try{

      result = await db.update(tableName, data, where: '$field1 = ?', whereArgs: [value1]);


    } catch(e){
      print(e);
    }


    return result;
  }

  Future<int> updateTemporaryObservationBookingField(bool edit, Map<String, dynamic> data, userUid, String selectedJobId) async {
    Database db = await this.database;

    int result;

    if(edit){
      result = await db.update(Strings.editedObservationBookingTable, data, where: '${Strings.uid} = ? AND ${Strings.jobId} = ?', whereArgs: [userUid, selectedJobId]);

    } else {
      result = await db.update(Strings.temporaryObservationBookingTable, data, where: '${Strings.uid} = ? AND ${Strings.jobId} = ?', whereArgs: [userUid, selectedJobId]);

    }


    return result;
  }

  Future<int> updateTemporaryBookingFormField(bool edit, Map<String, dynamic> data, userUid, String selectedJobId) async {
    Database db = await this.database;

    int result;

    if(edit){
      result = await db.update(Strings.editedBookingFormTable, data, where: '${Strings.uid} = ? AND ${Strings.jobId} = ?', whereArgs: [userUid, selectedJobId]);

    } else {
      result = await db.update(Strings.temporaryBookingFormTable, data, where: '${Strings.uid} = ? AND ${Strings.jobId} = ?', whereArgs: [userUid, selectedJobId]);

    }


    return result;
  }

  Future<int> updateTemporaryTransferReportField(bool edit, Map<String, dynamic> data, userUid, String selectedJobId) async {
    Database db = await this.database;

    int result;

    if(edit){
      result = await db.update(Strings.editedTransferReportTable, data, where: '${Strings.uid} = ? AND ${Strings.jobId} = ?', whereArgs: [userUid, selectedJobId]);

    } else {
      result = await db.update(Strings.temporaryTransferReportTable, data, where: '${Strings.uid} = ? AND ${Strings.jobId} = ?', whereArgs: [userUid, selectedJobId]);

    }


    return result;
  }

  Future<int> updateTemporaryIncidentReportField(bool edit, Map<String, dynamic> data, userUid, String selectedJobId) async {
    Database db = await this.database;

    int result;

    if(edit){
      result = await db.update(Strings.editedIncidentReportTable, data, where: '${Strings.uid} = ? AND ${Strings.jobId} = ?', whereArgs: [userUid, selectedJobId]);

    } else {
      result = await db.update(Strings.temporaryIncidentReportTable, data, where: '${Strings.uid} = ? AND ${Strings.jobId} = ?', whereArgs: [userUid, selectedJobId]);

    }


    return result;
  }

  Future<int> updateTemporaryJobField(Map<String, dynamic> data, userUid) async {
    Database db = await this.database;

    int result = await db.update(Strings.temporaryJobTable, data, where: '${Strings.uid} = ?', whereArgs: [userUid]);

    return result;
  }

  Future<int> delete(String tableName, String userDocumentId) async {
    Database db = await this.database;

    var result =
    await db.delete(tableName,
        where: '${Strings.documentId} = ?', whereArgs: [userDocumentId]);
    return result;
  }

  Future<int> deleteAllRows(String tableName) async {
    Database db = await this.database;

    var result =
    await db.rawDelete('DELETE FROM $tableName');
    return result;
  }

  Future<int> deleteLocalForm(String tableName) async {
    Database db = await this.database;

    var result = db.rawDelete('DELETE FROM $tableName ORDER BY ${Strings.localId} ASC limit 1');

    return result;
  }



  Future<int> deleteFirebaseRow(String tableName, String uidInput) async {
    Database db = await this.database;

    var result =
    await db.delete(Strings.firebaseStorageUrlTable,
        where: '${Strings.uid} = ?', whereArgs: [uidInput]);
    return result;
  }


  Future<int> deleteTemporaryForm(String tableName, String inputJobId) async {
    Database db = await this.database;

    var result =
    await db.delete(tableName,
        where: '${Strings.jobId} = ?', whereArgs: [inputJobId]);
    return result;
  }

  Future<int> getRowCount(String tableName) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
    await db.rawQuery('SELECT COUNT (*) from $tableName');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> getRowCountWhere(String tableName, String field1, var value1) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
    await db.rawQuery('SELECT COUNT (*) from $tableName WHERE $field1 = ?', [value1]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> getRowCountWhereAndWhere(String tableName, String field1, var value1, String field2, var value2) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
    await db.rawQuery('SELECT COUNT (*) from $tableName WHERE $field1 = ? AND $field2 = ?', [value1, value2]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> getRowCountWhereAndWhereAndWhere(String tableName, String field1, var value1, String field2, var value2, String field3, var value3) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
    await db.rawQuery('SELECT COUNT (*) from $tableName WHERE $field1 = ? AND $field2 = ? AND $field3 = ?', [value1, value2, value3]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> getRowCountWhereAndWhereAndWhereAndWhere(String tableName, String field1, var value1, String field2, var value2, String field3, var value3, String field4, var value4) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
    await db.rawQuery('SELECT COUNT (*) from $tableName WHERE $field1 = ? AND $field2 = ? AND $field3 = ? AND $field4 = ?', [value1, value2, value3, value4]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> checkExists(String tableName, String field1, var value1) async {
    Database db = await this.database;
    List<Map<String, dynamic>> resultQuery = await db.rawQuery('SELECT EXISTS(SELECT * FROM $tableName WHERE $field1 = ?)', [value1]);
    int result = resultQuery.length;
    return result;
  }

  Future<int> checkUserExists(String inputUid) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        "SELECT EXISTS(SELECT 1 FROM ${Strings.usersTable} WHERE ${Strings.uid} = ?)", [inputUid]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> checkObservationBookingExists(String inputDocumentId) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        "SELECT EXISTS(SELECT 1 FROM ${Strings.observationBookingTable} WHERE ${Strings.documentId} = ?)", [inputDocumentId]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> checkTemporaryObservationBookingExists(bool edit, String inputUid, String selectedJobId) async {
    Database db = await this.database;
    int result;
    if(edit){
      List<Map<String, dynamic>> x = await db.rawQuery(
          "SELECT EXISTS(SELECT 1 FROM ${Strings.editedObservationBookingTable} WHERE ${Strings.uid} = ? AND ${Strings.jobId} = ?)", [inputUid, selectedJobId]);
      result = Sqflite.firstIntValue(x);
    } else {
      List<Map<String, dynamic>> x = await db.rawQuery(
          "SELECT EXISTS(SELECT 1 FROM ${Strings.temporaryObservationBookingTable} WHERE ${Strings.uid} = ? AND ${Strings.jobId} = ?)", [inputUid, selectedJobId]);
      result = Sqflite.firstIntValue(x);
    }

    return result;
  }

  Future<Map<String, dynamic>> getTemporaryObservationBooking(bool edit, String userUid, String selectedJobId) async {
    Database db = await this.database;

    var result;

    if(edit){
      result = await db
          .rawQuery('SELECT * FROM ${Strings.editedObservationBookingTable} WHERE ${Strings.uid} = ? AND ${Strings.jobId} = ?', [userUid, selectedJobId]);

    } else {
      result = await db
          .rawQuery('SELECT * FROM ${Strings.temporaryObservationBookingTable} WHERE ${Strings.uid} = ? AND ${Strings.jobId} = ?', [userUid, selectedJobId]);
    }


    return result[0];
  }

  Future<Map<String, dynamic>> getPendingObservationBooking(String userUid, String selectedJobId) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM ${Strings.observationBookingTable} WHERE ${Strings.uid} = ? AND ${Strings.jobId} = ?', [userUid, selectedJobId]);
    return result[0];
  }

  Future<int> checkBookingFormExists(String inputDocumentId) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        "SELECT EXISTS(SELECT 1 FROM ${Strings.bookingFormTable} WHERE ${Strings.documentId} = ?)", [inputDocumentId]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> checkTemporaryBookingFormExists(bool edit, String inputUid, String selectedJobId) async {
    Database db = await this.database;
    int result;
    if(edit){
      List<Map<String, dynamic>> x = await db.rawQuery(
          "SELECT EXISTS(SELECT 1 FROM ${Strings.editedBookingFormTable} WHERE ${Strings.uid} = ? AND ${Strings.jobId} = ?)", [inputUid, selectedJobId]);
      result = Sqflite.firstIntValue(x);
    } else {
      List<Map<String, dynamic>> x = await db.rawQuery(
          "SELECT EXISTS(SELECT 1 FROM ${Strings.temporaryBookingFormTable} WHERE ${Strings.uid} = ? AND ${Strings.jobId} = ?)", [inputUid, selectedJobId]);
      result = Sqflite.firstIntValue(x);
    }

    return result;
  }

  Future<Map<String, dynamic>> getTemporaryBookingForm(bool edit, String userUid, String selectedJobId) async {
    Database db = await this.database;

    var result;

    if(edit){
      result = await db
          .rawQuery('SELECT * FROM ${Strings.editedBookingFormTable} WHERE ${Strings.uid} = ? AND ${Strings.jobId} = ?', [userUid, selectedJobId]);

    } else {
      result = await db
          .rawQuery('SELECT * FROM ${Strings.temporaryBookingFormTable} WHERE ${Strings.uid} = ? AND ${Strings.jobId} = ?', [userUid, selectedJobId]);
    }


    return result[0];
  }

  Future<Map<String, dynamic>> getPendingBookingForm(String userUid, String selectedJobId) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM ${Strings.bookingFormTable} WHERE ${Strings.uid} = ? AND ${Strings.jobId} = ?', [userUid, selectedJobId]);
    return result[0];
  }

  Future<int> checkTransferReportExists(String inputDocumentId) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        "SELECT EXISTS(SELECT 1 FROM ${Strings.transferReportTable} WHERE ${Strings.documentId} = ?)", [inputDocumentId]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> checkTemporaryTransferReportExists(bool edit, String inputUid, String selectedJobId) async {
    Database db = await this.database;
    int result;
    if(edit){
      List<Map<String, dynamic>> x = await db.rawQuery(
          "SELECT EXISTS(SELECT 1 FROM ${Strings.editedTransferReportTable} WHERE ${Strings.uid} = ? AND ${Strings.jobId} = ?)", [inputUid, selectedJobId]);
      result = Sqflite.firstIntValue(x);
    } else {
      List<Map<String, dynamic>> x = await db.rawQuery(
          "SELECT EXISTS(SELECT 1 FROM ${Strings.temporaryTransferReportTable} WHERE ${Strings.uid} = ? AND ${Strings.jobId} = ?)", [inputUid, selectedJobId]);
      result = Sqflite.firstIntValue(x);
    }

    return result;
  }

  Future<Map<String, dynamic>> getTemporaryTransferReport(bool edit, String userUid, String selectedJobId) async {
    Database db = await this.database;

    var result;

    if(edit){
      result = await db
          .rawQuery('SELECT * FROM ${Strings.editedTransferReportTable} WHERE ${Strings.uid} = ? AND ${Strings.jobId} = ?', [userUid, selectedJobId]);

    } else {
      result = await db
          .rawQuery('SELECT * FROM ${Strings.temporaryTransferReportTable} WHERE ${Strings.uid} = ? AND ${Strings.jobId} = ?', [userUid, selectedJobId]);
    }


    return result[0];
  }

  Future<Map<String, dynamic>> getPendingTransferRecord(String userUid, String selectedJobId) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM ${Strings.transferReportTable} WHERE ${Strings.uid} = ? AND ${Strings.jobId} = ?', [userUid, selectedJobId]);
    return result[0];
  }

  Future<int> checkIncidentReportExists(String inputDocumentId) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        "SELECT EXISTS(SELECT 1 FROM ${Strings.incidentReportTable} WHERE ${Strings.documentId} = ?)", [inputDocumentId]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> checkTemporaryIncidentReportExists(bool edit, String inputUid, String selectedJobId) async {
    Database db = await this.database;
    int result;
    if(edit){
      List<Map<String, dynamic>> x = await db.rawQuery(
          "SELECT EXISTS(SELECT 1 FROM ${Strings.editedIncidentReportTable} WHERE ${Strings.uid} = ? AND ${Strings.jobId} = ?)", [inputUid, selectedJobId]);
      result = Sqflite.firstIntValue(x);
    } else {
      List<Map<String, dynamic>> x = await db.rawQuery(
          "SELECT EXISTS(SELECT 1 FROM ${Strings.temporaryIncidentReportTable} WHERE ${Strings.uid} = ? AND ${Strings.jobId} = ?)", [inputUid, selectedJobId]);
      result = Sqflite.firstIntValue(x);
    }

    return result;
  }

  Future<Map<String, dynamic>> getTemporaryIncidentReport(bool edit, String userUid, String selectedJobId) async {
    Database db = await this.database;

    var result;

    if(edit){
      result = await db
          .rawQuery('SELECT * FROM ${Strings.editedIncidentReportTable} WHERE ${Strings.uid} = ? AND ${Strings.jobId} = ?', [userUid, selectedJobId]);

    } else {
      result = await db
          .rawQuery('SELECT * FROM ${Strings.temporaryIncidentReportTable} WHERE ${Strings.uid} = ? AND ${Strings.jobId} = ?', [userUid, selectedJobId]);
    }


    return result[0];
  }

  Future<Map<String, dynamic>> getPendingIncidentRecord(String userUid, String selectedJobId) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM ${Strings.incidentReportTable} WHERE ${Strings.uid} = ? AND ${Strings.jobId} = ?', [userUid, selectedJobId]);
    return result[0];
  }



  Future<int> checkCustomerExists(String inputDocumentId) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        "SELECT EXISTS(SELECT 1 FROM ${Strings.customersTable} WHERE ${Strings.documentId} = ?)", [inputDocumentId]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> checkJobExists(String inputDocumentId) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        "SELECT EXISTS(SELECT 1 FROM ${Strings.jobTable} WHERE ${Strings.documentId} = ?)", [inputDocumentId]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> checkTemporaryJobExists(String inputUid) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        "SELECT EXISTS(SELECT 1 FROM ${Strings.temporaryJobTable} WHERE ${Strings.uid} = ?)", [inputUid]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<Map<String, dynamic>> getTemporaryJob(String userUid) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM ${Strings.temporaryJobTable} WHERE ${Strings.uid} = ?', [userUid]);
    return result[0];
  }

  Future<int> checkPendingJobForm(String tableName, var pendingJobId, var userUid) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        "SELECT EXISTS(SELECT 1 FROM $tableName WHERE ${Strings.serverUploaded} = 0 AND ${Strings.jobId} = ? AND ${Strings.uid} = ?)", [pendingJobId, userUid]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> checkFirebaseStorageRowExists(String inputUid) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        "SELECT EXISTS(SELECT 1 FROM ${Strings.firebaseStorageUrlTable} WHERE ${Strings.uid} = ?)", [inputUid]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<List<Map<String, dynamic>>> getPendingJobForms(String tableName, var pendingJobId, var userUid) async {
    Database db = await this.database;

    var result = await db
        .rawQuery("SELECT * FROM $tableName WHERE ${Strings.serverUploaded} = 0 AND ${Strings.jobId} = ? AND ${Strings.uid} = ?", [pendingJobId, userUid]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getPendingJobFormsLocalId(String tableName, var pendingLocalId, var userUid) async {
    Database db = await this.database;

    var result = await db
        .rawQuery("SELECT * FROM $tableName WHERE ${Strings.serverUploaded} = 0 AND ${Strings.localId} = ? AND ${Strings.uid} = ?", [pendingLocalId, userUid]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getAllPendingForms(String tableName, var userUid) async {
    Database db = await this.database;

    var result = await db
        .rawQuery("SELECT * FROM $tableName WHERE ${Strings.serverUploaded} = 0 AND ${Strings.uid} = ?", [userUid]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getAllCaves() async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM ${Strings.caveTable} ORDER BY ${Strings.name} ASC');
    return result;
  }

  Future<int> checkExistsTwoArguments(String tableName, String field1, var value1, String field2, var value2) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        "SELECT EXISTS(SELECT 1 FROM $tableName WHERE $field1 = ? AND $field2 = ?)", [value1, value2]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<List<Map<String, dynamic>>> getAllWhereAndWhere(String tableName, field1, value1, field2, value2) async {
    Database db = await this.database;

    var result = await db
        .rawQuery("SELECT * FROM $tableName WHERE $field1 = ? AND $field2 = ?", [value1, value2]);
    return result;
  }


  Future<List<Map<String, dynamic>>> getRowsWhereOrderByDirectionLast10(String tableName, field1, value1, String orderByField, String direction) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? ORDER BY $orderByField ' '$direction'' LIMIT 10', [value1]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getRowsWhereOrderByDirectionLast20(String tableName, field1, value1, String orderByField, String direction) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? ORDER BY $orderByField ' '$direction'' LIMIT 20', [value1]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getCustomersLocally(String orgId) async {
    Database db = await this.database;


    var result = await db
        .rawQuery('SELECT * FROM ${Strings.customersTable} WHERE ${Strings.organisationId} = ?', [orgId]);

    return result;
  }

  Future<List<Map<String, dynamic>>> getCavesLocally() async {
    Database db = await this.database;


    var result = await db
        .rawQuery('SELECT * FROM ${Strings.caveTable}');

    return result;
  }

  Future<List<Map<String, dynamic>>> getSingleCustomer(String cusId) async {
    Database db = await this.database;


    var result = await db
        .rawQuery('SELECT * FROM ${Strings.customersTable} WHERE ${Strings.documentId} = ?', [cusId]);

    return result;
  }



  Future<List<Map<String, dynamic>>> getRowsWhereAndWhereIsLessThanOrderByDirectionLast10(String tableName, field1, value1, field2, value2, String orderByField, String direction) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? AND $field2 < ? ORDER BY $orderByField ' '$direction'' LIMIT 10', [value1, value2]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getRowsWhereAndWhereIsMoreThanOrEqualToOrderByDirectionLast10(String tableName, field1, value1, field2, value2, String orderByField, String direction) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? AND $field2 >= ? ORDER BY $orderByField ' '$direction'' LIMIT 10', [value1, value2]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getRowsOrderByOrderByDirectionLast10(String tableName, String orderByField1, String orderByField2, String direction) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName ORDER BY $orderByField1 $direction, $orderByField2 $direction LIMIT 10');
    return result;
  }

  Future<List<Map<String, dynamic>>> getRowsWhereOrderByOrderByDirectionLast10(String tableName, field1, value1, String orderByField1, String orderByField2, String direction) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? ORDER BY $orderByField1 $direction, $orderByField2 $direction LIMIT 10', [value1]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getRowsWhereAndWhereOrderByOrderByDirectionLast10(String tableName, String field1, var value1, String field2, var value2, String orderByField1, String orderByField2, String direction) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? AND $field2 = ? ORDER BY $orderByField1 $direction, $orderByField2 $direction LIMIT 10', [value1, value2]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getRowsWhereAndWhereOrderByOrderByDirection(String tableName, String field1, var value1, String field2, var value2, String orderByField1, String orderByField2, String direction) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? AND $field2 = ? ORDER BY $orderByField1 $direction, $orderByField2 $direction', [value1, value2]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getRowsWhereAndWhereAndWhereOrderByOrderByDirection(String tableName, String field1, var value1, String field2, var value2, String field3, var value3, String orderByField1, String orderByField2, String direction) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? AND $field2 = ? AND $field3 = ? ORDER BY $orderByField1 $direction, $orderByField2 $direction', [value1, value2, value3]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getRowsWhereAndWhereAndWhereAndWhereOrderByOrderByDirection(String tableName, String field1, var value1, String field2, var value2, String field3, var value3, String field4, var value4, String orderByField1, String orderByField2, String direction) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? AND $field2 = ? AND $field3 = ? AND $field4 = ? ORDER BY $orderByField1 $direction, $orderByField2 $direction', [value1, value2, value3, value4]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getRowsWhereAndWhereAndWhereOrderByOrderByDirectionLast10(String tableName, String field1, var value1, String field2, var value2, String field3, var value3, String orderByField1, String orderByField2, String direction) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? AND $field2 = ? AND $field3 = ? ORDER BY $orderByField1 $direction, $orderByField2 $direction LIMIT 10', [value1, value2, value3]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getRowsWhereOrderByDirection10More(String tableName, field1, value1, String field2, String direction, String timestamp) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? AND $field2 < ? ORDER BY $field2 ' '$direction'' LIMIT 10', [value1, timestamp]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getRowsWhereOrderByDirection20More(String tableName, field1, value1, String field2, String direction, String name) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? AND $field2 > ? ORDER BY $field2 ' '$direction'' LIMIT 20', [value1, name]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getRowsWhereAndWhereIsLessThanOrderByDirection10More(String tableName, field1, value1, field2, value2, String field3, String direction, String timestamp) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? AND $field2 < ? AND $field3 < ? ORDER BY $field3 ' '$direction'' LIMIT 10', [value1, value2, timestamp]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getRowsWhereAndWhereIsMoreThanOrEqualToOrderByDirection10More(String tableName, field1, value1, field2, value2, String field3, String direction, String timestamp) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? AND $field2 >= ? AND $field3 < ? ORDER BY $field3 ' '$direction'' LIMIT 10', [value1, value2, timestamp]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getRowsWhereAndWhereIsMoreThanOrderByDirection10More(String tableName, field1, value1, field2, value2, String field3, String direction, String timestamp) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? AND $field2 >= ? AND $field3 < ? ORDER BY $field3 ' '$direction'' LIMIT 10', [value1, value2, timestamp]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getRowsOrderByDirection(String tableName, String orderByField, String direction) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName ORDER BY $orderByField ' '$direction');
    return result;
  }

  Future<List<Map<String, dynamic>>> getRowsWhere(String tableName, field1, value1) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ?', [value1]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getRowsWhereOrderByDirection(String tableName, field1, value1, String orderByField, String direction) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? ORDER BY $orderByField ' '$direction', [value1]);
    return result;
  }
  Future<List<Map<String, dynamic>>> getRowsWhereOrderByOrderByDirection(String tableName, field1, value1, String orderByField1, String orderByField2, String direction) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? ORDER BY $orderByField1 $direction, $orderByField2 $direction', [value1]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getRowsWhereAndWhereOrderByDirection(String tableName, field1, value1, field2, value2, String orderByField, String direction) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? AND $field2 = ? ORDER BY $orderByField ' '$direction', [value1, value2]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getRowsWhereAndWhereAndWhereOrderByDirection(String tableName, field1, value1, field2, value2, field3, value3, String orderByField, String direction) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? AND $field2 = ? AND $field3 = ? ORDER BY $orderByField ' '$direction', [value1, value2, value3]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getRowsWhereAndWhereOrderByDirectionLast10(String tableName, field1, value1, field2, value2, String orderByField, String direction) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? AND $field2 = ? ORDER BY $orderByField ' '$direction'' LIMIT 10', [value1, value2]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getRowsWhereAndWhereAndWhereIsLessThanOrderByDirectionLast10(String tableName, field1, value1, field2, value2, field3, value3, String orderByField, String direction) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? AND $field2 = ? AND $field3 < ? ORDER BY $orderByField ' '$direction'' LIMIT 10', [value1, value2, value3]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getRowsWhereAndWhereAndWhereIsMoreThanOrEqualToOrderByDirectionLast10(String tableName, field1, value1, field2, value2, field3, value3, String orderByField, String direction) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? AND $field2 = ? AND $field3 >= ? ORDER BY $orderByField ' '$direction'' LIMIT 10', [value1, value2, value3]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getRowsWhereAndWhereAndWhereOrderByDirectionLast10(String tableName, field1, value1, field2, value2, field3, value3, String orderByField, String direction) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? AND $field2 = ? AND $field3 = ? ORDER BY $orderByField ' '$direction'' LIMIT 10', [value1, value2, value3]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getRowsWhereAndWhereOrderByDirection10More(String tableName, field1, value1, field2, value2, String field3, String direction, String timestamp) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? AND $field2 = ? AND $field3 < ? ORDER BY $field3 ' '$direction'' LIMIT 10', [value1, value2, timestamp]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getRowsWhereAndWhereAndWhereOrderByDirection10More(String tableName, field0, value0, field1, value1, field2, value2, String field3, String direction, String timestamp) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field0 = ? AND $field1 = ? AND $field2 = ? AND $field3 < ? ORDER BY $field3 ' '$direction'' LIMIT 10', [value0, value1, value2, timestamp]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getRowsWhereAndWhereAndWhereIsLessThanOrderByDirection10More(String tableName, field1, value1, field2, value2, field3, value3, String field4, String direction, String timestamp) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? AND $field2 = ? AND $field3 < ? and $field4 < ? ORDER BY $field4 ' '$direction'' LIMIT 10', [value1, value2, value3, timestamp]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getRowsWhereAndWhereAndWhereIsMoreThanOrEqualToOrderByDirection10More(String tableName, field1, value1, field2, value2, field3, value3, String field4, String direction, String timestamp) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? AND $field2 = ? AND $field3 >= ? AND $field4 < ? ORDER BY $field4 ' '$direction'' LIMIT 10', [value1, value2, value3, timestamp]);
    return result;
  }

  Future<int> resetTemporaryJob(String userUid) async {
    Database db = await this.database;
    var result = await db.update(Strings.temporaryJobTable , {
      Strings.formVersion: 1,
      Strings.jobNo: null,
    },
        where: '${Strings.uid} = ?', whereArgs: [userUid]);
    return result;
  }

  Future<int> resetTemporaryTransferReport(String userUid, String selectedJobId) async {
    Database db = await this.database;

    var result = await db.update(Strings.temporaryTransferReportTable , {
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
        where: '${Strings.uid} = ? AND ${Strings.jobId} = ?', whereArgs: [userUid, selectedJobId]);
    return result;
  }

  Future<int> resetTemporaryIncidentReport(String userUid, String selectedJobId) async {
    Database db = await this.database;

    var result = await db.update(Strings.temporaryIncidentReportTable , {
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
        where: '${Strings.uid} = ? AND ${Strings.jobId} = ?', whereArgs: [userUid, selectedJobId]);
    return result;
  }


  Future<int> resetTemporaryObservationBooking(String userUid, String selectedJobId) async {
    Database db = await this.database;

    var result = await db.update(Strings.temporaryObservationBookingTable , {
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
        where: '${Strings.uid} = ? AND ${Strings.jobId} = ?', whereArgs: [userUid, selectedJobId]);
    return result;
  }

  Future<int> resetTemporaryBookingForm(String userUid, String selectedJobId) async {
    Database db = await this.database;

    var result = await db.update(Strings.temporaryBookingFormTable , {
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
        where: '${Strings.uid} = ? AND ${Strings.jobId} = ?', whereArgs: [userUid, selectedJobId]);
    return result;
  }

}

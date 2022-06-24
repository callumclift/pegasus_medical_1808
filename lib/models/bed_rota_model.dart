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
import '../models/share_option.dart';
import '../models/text_option.dart';
import '../utils/database.dart';
import 'package:sembast/sembast.dart' as Db;
import 'package:random_string/random_string.dart' as random_string;
import 'package:universal_html/html.dart' as html;



class BedRotaModel extends ChangeNotifier {

  DatabaseHelper _databaseHelper = DatabaseHelper();
  AuthenticationModel authenticationModel = AuthenticationModel();
  final NavigationService _navigationService = locator<NavigationService>();
  BedRotaModel(this.authenticationModel);

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> _bedRotas = [];
  String _selBedRotaId;
  final dateFormatDay = DateFormat("dd-MM-yyyy");

  List<Map<String, dynamic>> get allBedRotas {
    return List.from(_bedRotas);
  }
  int get selectedBedRotaIndex {
    return _bedRotas.indexWhere((Map<String, dynamic> bedRota) {
      return bedRota[Strings.documentId] == _selBedRotaId;
    });
  }
  String get selectedBedRotaId {
    return _selBedRotaId;
  }

  Map<String, dynamic> get selectedBedRota {
    if (_selBedRotaId == null) {
      return null;
    }
    return _bedRotas.firstWhere((Map<String, dynamic> bedRota) {
      return bedRota[Strings.documentId] == _selBedRotaId;
    });
  }
  void selectBedRota(String bedRotaId) {
    _selBedRotaId = bedRotaId;
    if (bedRotaId != null) {
      notifyListeners();
    }
  }

  void clearBedRotas(){
    _bedRotas = [];
  }


  // Sembast database settings
  static const String TEMPORARY_BED_ROTAS_STORE_NAME = 'temporary_bed_rotas';
  final _temporaryBedRotasStore = Db.intMapStoreFactory.store(TEMPORARY_BED_ROTAS_STORE_NAME);

  static const String BED_ROTAS_STORE_NAME = 'bed_rotas';
  final _bedRotasStore = Db.intMapStoreFactory.store(BED_ROTAS_STORE_NAME);

  static const String EDITED_BED_ROTAS_STORE_NAME = 'edited_bed_rotas';
  final _editedBedRotasStore = Db.intMapStoreFactory.store(EDITED_BED_ROTAS_STORE_NAME);

  static const String SAVED_BED_ROTAS_STORE_NAME = 'saved_bed_rotas';
  final _savedBedRotasStore = Db.intMapStoreFactory.store(SAVED_BED_ROTAS_STORE_NAME);

  // Private getter to shorten the amount of code needed to get the
  // singleton instance of an opened database.
  Future<Db.Database> get _db async => await AppDatabase.instance.database;


  Future<void> setupTemporaryRecord() async {

    final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
        [Db.Filter.equals(Strings.uid, user.uid), Db.Filter.equals(Strings.jobId, '1')]
    ));
    List records = await _temporaryBedRotasStore.find(
      await _db,
      finder: finder,
    );
    if(records.length == 0){
      // Generate a random ID based on the date and a random string for virtual zero chance of duplicates
      int _id = DateTime.now().millisecondsSinceEpoch + int.parse(random_string.randomNumeric(2));
      await _temporaryBedRotasStore.record(_id).put(await _db,
          {Strings.uid : user.uid, Strings.formVersion: 1, Strings.jobId : '1'});
    }
  }

  Future<Map<String, dynamic>> getTemporaryRecord(bool edit, String selectedJobId, bool saved, int savedId) async{

    List records;

    if(edit){
      final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
          [Db.Filter.equals(Strings.documentId, selectedBedRota[Strings.documentId]), Db.Filter.equals(Strings.jobId, selectedJobId)]
      ));
      records = await _editedBedRotasStore.find(
        await _db,
        finder: finder,
      );
    } else if(saved) {
      final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
          [Db.Filter.equals(Strings.uid, user.uid), Db.Filter.equals(Strings.localId, savedId)]
      ));
      records = await _savedBedRotasStore.find(
        await _db,
        finder: finder,
      );
    } else {
      final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
          [Db.Filter.equals(Strings.uid, user.uid), Db.Filter.equals(Strings.jobId, selectedJobId)]
      ));
      records = await _temporaryBedRotasStore.find(
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

    List records = await _bedRotasStore.find(
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

    List records = await _bedRotasStore.find(
      await _db,
      finder: finder,
    );

    return records;
  }

  Future <void> deletePendingRecord(int localId) async{
    final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
        [Db.Filter.equals(Strings.uid, user.uid), Db.Filter.equals(Strings.localId, localId)]
    ));

    await _bedRotasStore.delete(
      await _db,
      finder: finder,
    );
  }

  Future <List<dynamic>> getSavedRecords() async{
    final Db.Finder finder = Db.Finder(filter: Db.Filter.equals(Strings.uid, user.uid));
    List records = await _savedBedRotasStore.find(
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
          [Db.Filter.equals(Strings.documentId, selectedBedRota[Strings.documentId]), Db.Filter.equals(Strings.jobId, selectedJobId)]
      ));
      records = await _editedBedRotasStore.find(
        await _db,
        finder: finder,
      );
    } else if(saved){
      final Db.Finder finder = Db.Finder(filter: Db.Filter.equals(Strings.localId, savedId));
      records = await _savedBedRotasStore.find(
        await _db,
        finder: finder,
      );

    } else {

      final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
          [Db.Filter.equals(Strings.uid, user.uid), Db.Filter.equals(Strings.jobId, selectedJobId)]
      ));
      records = await _temporaryBedRotasStore.find(
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
          [Db.Filter.equals(Strings.documentId, selectedBedRota[Strings.documentId]), Db.Filter.equals(Strings.jobId, selectedJobId)]
      ));
      await _editedBedRotasStore.update(await _db, {field: value},
          finder: finder);
    } else if(saved){
      final Db.Finder finder = Db.Finder(filter: Db.Filter.equals(Strings.localId, savedId));
      await _savedBedRotasStore.update(await _db, {field: value},
          finder: finder);
    } else {
      final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
          [Db.Filter.equals(Strings.uid, user.uid), Db.Filter.equals(Strings.jobId, selectedJobId)]
      ));
      await _temporaryBedRotasStore.update(await _db, {field: value},
          finder: finder);
    }

  }

  void deleteEditedRecord() async {
    await _editedBedRotasStore.delete(await _db);
  }

  Future<void> setUpEditedRecord() async{

    Map<String, dynamic> editedReport = editedBedRota(selectedBedRota);
    Map<String, dynamic> localData = Map.from(editedReport);
    await _editedBedRotasStore.delete(await _db);
    int _id = DateTime.now().millisecondsSinceEpoch + int.parse(random_string.randomNumeric(2));
    await _editedBedRotasStore.record(_id).put(await _db,
        localData);

  }

  Future<void> deleteAllRows() async {
    await _bedRotasStore.delete(await _db);
  }

  Future<bool> saveForLater(String jobId, bool saved, int savedId) async {

    GlobalFunctions.showLoadingDialog('Saving Bed Watch Rota...');
    String message = '';
    bool success = false;
    int id;

    if(saved){
      id = savedId;
    } else {
      id = DateTime.now().millisecondsSinceEpoch + int.parse(random_string.randomNumeric(2));
    }



    Map<String, dynamic> bedRota = await getTemporaryRecord(false, '1', saved, savedId);

    Map<String, dynamic> localData = {
      Strings.localId: id,
      Strings.documentId: null,
      Strings.uid: user.uid,
      Strings.jobId: '1',
      Strings.formVersion: '1',
      Strings.jobRef: bedRota[Strings.jobRef],
      Strings.jobRefRef: bedRota[Strings.jobRefRef],
      Strings.jobRefNo: bedRota[Strings.jobRefNo],
      Strings.weekCommencing: bedRota[Strings.weekCommencing],
      Strings.mondayAmName1: bedRota[Strings.mondayAmName1],
      Strings.mondayAmFrom1: bedRota[Strings.mondayAmFrom1],
      Strings.mondayAmTo1: bedRota[Strings.mondayAmTo1],
      Strings.mondayPmName1: bedRota[Strings.mondayPmName1],
      Strings.mondayPmFrom1: bedRota[Strings.mondayPmFrom1],
      Strings.mondayPmTo1: bedRota[Strings.mondayPmTo1],
      Strings.mondayNightName1: bedRota[Strings.mondayNightName1],
      Strings.mondayNightFrom1: bedRota[Strings.mondayNightFrom1],
      Strings.mondayNightTo1: bedRota[Strings.mondayNightTo1],
      Strings.mondayAmName2: bedRota[Strings.mondayAmName2],
      Strings.mondayAmFrom2: bedRota[Strings.mondayAmFrom2],
      Strings.mondayAmTo2: bedRota[Strings.mondayAmTo2],
      Strings.mondayPmName2: bedRota[Strings.mondayPmName2],
      Strings.mondayPmFrom2: bedRota[Strings.mondayPmFrom2],
      Strings.mondayPmTo2: bedRota[Strings.mondayPmTo2],
      Strings.mondayNightName2: bedRota[Strings.mondayNightName2],
      Strings.mondayNightFrom2: bedRota[Strings.mondayNightFrom2],
      Strings.mondayNightTo2: bedRota[Strings.mondayNightTo2],
      Strings.mondayAmName3: bedRota[Strings.mondayAmName3],
      Strings.mondayAmFrom3: bedRota[Strings.mondayAmFrom3],
      Strings.mondayAmTo3: bedRota[Strings.mondayAmTo3],
      Strings.mondayPmName3: bedRota[Strings.mondayPmName3],
      Strings.mondayPmFrom3: bedRota[Strings.mondayPmFrom3],
      Strings.mondayPmTo3: bedRota[Strings.mondayPmTo3],
      Strings.mondayNightName3: bedRota[Strings.mondayNightName3],
      Strings.mondayNightFrom3: bedRota[Strings.mondayNightFrom3],
      Strings.mondayNightTo3: bedRota[Strings.mondayNightTo3],
      Strings.mondayAmName4: bedRota[Strings.mondayAmName4],
      Strings.mondayAmFrom4: bedRota[Strings.mondayAmFrom4],
      Strings.mondayAmTo4: bedRota[Strings.mondayAmTo4],
      Strings.mondayPmName4: bedRota[Strings.mondayPmName4],
      Strings.mondayPmFrom4: bedRota[Strings.mondayPmFrom4],
      Strings.mondayPmTo4: bedRota[Strings.mondayPmTo4],
      Strings.mondayNightName4: bedRota[Strings.mondayNightName4],
      Strings.mondayNightFrom4: bedRota[Strings.mondayNightFrom4],
      Strings.mondayNightTo4: bedRota[Strings.mondayNightTo4],
      Strings.mondayAmName5: bedRota[Strings.mondayAmName5],
      Strings.mondayAmFrom5: bedRota[Strings.mondayAmFrom5],
      Strings.mondayAmTo5: bedRota[Strings.mondayAmTo5],
      Strings.mondayPmName5: bedRota[Strings.mondayPmName5],
      Strings.mondayPmFrom5: bedRota[Strings.mondayPmFrom5],
      Strings.mondayPmTo5: bedRota[Strings.mondayPmTo5],
      Strings.mondayNightName5: bedRota[Strings.mondayNightName5],
      Strings.mondayNightFrom5: bedRota[Strings.mondayNightFrom5],
      Strings.mondayNightTo5: bedRota[Strings.mondayNightTo5],
      Strings.tuesdayAmName1: bedRota[Strings.tuesdayAmName1],
      Strings.tuesdayAmFrom1: bedRota[Strings.tuesdayAmFrom1],
      Strings.tuesdayAmTo1: bedRota[Strings.tuesdayAmTo1],
      Strings.tuesdayPmName1: bedRota[Strings.tuesdayPmName1],
      Strings.tuesdayPmFrom1: bedRota[Strings.tuesdayPmFrom1],
      Strings.tuesdayPmTo1: bedRota[Strings.tuesdayPmTo1],
      Strings.tuesdayNightName1: bedRota[Strings.tuesdayNightName1],
      Strings.tuesdayNightFrom1: bedRota[Strings.tuesdayNightFrom1],
      Strings.tuesdayNightTo1: bedRota[Strings.tuesdayNightTo1],
      Strings.tuesdayAmName2: bedRota[Strings.tuesdayAmName2],
      Strings.tuesdayAmFrom2: bedRota[Strings.tuesdayAmFrom2],
      Strings.tuesdayAmTo2: bedRota[Strings.tuesdayAmTo2],
      Strings.tuesdayPmName2: bedRota[Strings.tuesdayPmName2],
      Strings.tuesdayPmFrom2: bedRota[Strings.tuesdayPmFrom2],
      Strings.tuesdayPmTo2: bedRota[Strings.tuesdayPmTo2],
      Strings.tuesdayNightName2: bedRota[Strings.tuesdayNightName2],
      Strings.tuesdayNightFrom2: bedRota[Strings.tuesdayNightFrom2],
      Strings.tuesdayNightTo2: bedRota[Strings.tuesdayNightTo2],
      Strings.tuesdayAmName3: bedRota[Strings.tuesdayAmName3],
      Strings.tuesdayAmFrom3: bedRota[Strings.tuesdayAmFrom3],
      Strings.tuesdayAmTo3: bedRota[Strings.tuesdayAmTo3],
      Strings.tuesdayPmName3: bedRota[Strings.tuesdayPmName3],
      Strings.tuesdayPmFrom3: bedRota[Strings.tuesdayPmFrom3],
      Strings.tuesdayPmTo3: bedRota[Strings.tuesdayPmTo3],
      Strings.tuesdayNightName3: bedRota[Strings.tuesdayNightName3],
      Strings.tuesdayNightFrom3: bedRota[Strings.tuesdayNightFrom3],
      Strings.tuesdayNightTo3: bedRota[Strings.tuesdayNightTo3],
      Strings.tuesdayAmName4: bedRota[Strings.tuesdayAmName4],
      Strings.tuesdayAmFrom4: bedRota[Strings.tuesdayAmFrom4],
      Strings.tuesdayAmTo4: bedRota[Strings.tuesdayAmTo4],
      Strings.tuesdayPmName4: bedRota[Strings.tuesdayPmName4],
      Strings.tuesdayPmFrom4: bedRota[Strings.tuesdayPmFrom4],
      Strings.tuesdayPmTo4: bedRota[Strings.tuesdayPmTo4],
      Strings.tuesdayNightName4: bedRota[Strings.tuesdayNightName4],
      Strings.tuesdayNightFrom4: bedRota[Strings.tuesdayNightFrom4],
      Strings.tuesdayNightTo4: bedRota[Strings.tuesdayNightTo4],
      Strings.tuesdayAmName5: bedRota[Strings.tuesdayAmName5],
      Strings.tuesdayAmFrom5: bedRota[Strings.tuesdayAmFrom5],
      Strings.tuesdayAmTo5: bedRota[Strings.tuesdayAmTo5],
      Strings.tuesdayPmName5: bedRota[Strings.tuesdayPmName5],
      Strings.tuesdayPmFrom5: bedRota[Strings.tuesdayPmFrom5],
      Strings.tuesdayPmTo5: bedRota[Strings.tuesdayPmTo5],
      Strings.tuesdayNightName5: bedRota[Strings.tuesdayNightName5],
      Strings.tuesdayNightFrom5: bedRota[Strings.tuesdayNightFrom5],
      Strings.tuesdayNightTo5: bedRota[Strings.tuesdayNightTo5],
      Strings.wednesdayAmName1: bedRota[Strings.wednesdayAmName1],
      Strings.wednesdayAmFrom1: bedRota[Strings.wednesdayAmFrom1],
      Strings.wednesdayAmTo1: bedRota[Strings.wednesdayAmTo1],
      Strings.wednesdayPmName1: bedRota[Strings.wednesdayPmName1],
      Strings.wednesdayPmFrom1: bedRota[Strings.wednesdayPmFrom1],
      Strings.wednesdayPmTo1: bedRota[Strings.wednesdayPmTo1],
      Strings.wednesdayNightName1: bedRota[Strings.wednesdayNightName1],
      Strings.wednesdayNightFrom1: bedRota[Strings.wednesdayNightFrom1],
      Strings.wednesdayNightTo1: bedRota[Strings.wednesdayNightTo1],
      Strings.wednesdayAmName2: bedRota[Strings.wednesdayAmName2],
      Strings.wednesdayAmFrom2: bedRota[Strings.wednesdayAmFrom2],
      Strings.wednesdayAmTo2: bedRota[Strings.wednesdayAmTo2],
      Strings.wednesdayPmName2: bedRota[Strings.wednesdayPmName2],
      Strings.wednesdayPmFrom2: bedRota[Strings.wednesdayPmFrom2],
      Strings.wednesdayPmTo2: bedRota[Strings.wednesdayPmTo2],
      Strings.wednesdayNightName2: bedRota[Strings.wednesdayNightName2],
      Strings.wednesdayNightFrom2: bedRota[Strings.wednesdayNightFrom2],
      Strings.wednesdayNightTo2: bedRota[Strings.wednesdayNightTo2],
      Strings.wednesdayAmName3: bedRota[Strings.wednesdayAmName3],
      Strings.wednesdayAmFrom3: bedRota[Strings.wednesdayAmFrom3],
      Strings.wednesdayAmTo3: bedRota[Strings.wednesdayAmTo3],
      Strings.wednesdayPmName3: bedRota[Strings.wednesdayPmName3],
      Strings.wednesdayPmFrom3: bedRota[Strings.wednesdayPmFrom3],
      Strings.wednesdayPmTo3: bedRota[Strings.wednesdayPmTo3],
      Strings.wednesdayNightName3: bedRota[Strings.wednesdayNightName3],
      Strings.wednesdayNightFrom3: bedRota[Strings.wednesdayNightFrom3],
      Strings.wednesdayNightTo3: bedRota[Strings.wednesdayNightTo3],
      Strings.wednesdayAmName4: bedRota[Strings.wednesdayAmName4],
      Strings.wednesdayAmFrom4: bedRota[Strings.wednesdayAmFrom4],
      Strings.wednesdayAmTo4: bedRota[Strings.wednesdayAmTo4],
      Strings.wednesdayPmName4: bedRota[Strings.wednesdayPmName4],
      Strings.wednesdayPmFrom4: bedRota[Strings.wednesdayPmFrom4],
      Strings.wednesdayPmTo4: bedRota[Strings.wednesdayPmTo4],
      Strings.wednesdayNightName4: bedRota[Strings.wednesdayNightName4],
      Strings.wednesdayNightFrom4: bedRota[Strings.wednesdayNightFrom4],
      Strings.wednesdayNightTo4: bedRota[Strings.wednesdayNightTo4],
      Strings.wednesdayAmName5: bedRota[Strings.wednesdayAmName5],
      Strings.wednesdayAmFrom5: bedRota[Strings.wednesdayAmFrom5],
      Strings.wednesdayAmTo5: bedRota[Strings.wednesdayAmTo5],
      Strings.wednesdayPmName5: bedRota[Strings.wednesdayPmName5],
      Strings.wednesdayPmFrom5: bedRota[Strings.wednesdayPmFrom5],
      Strings.wednesdayPmTo5: bedRota[Strings.wednesdayPmTo5],
      Strings.wednesdayNightName5: bedRota[Strings.wednesdayNightName5],
      Strings.wednesdayNightFrom5: bedRota[Strings.wednesdayNightFrom5],
      Strings.wednesdayNightTo5: bedRota[Strings.wednesdayNightTo5],
      Strings.thursdayAmName1: bedRota[Strings.thursdayAmName1],
      Strings.thursdayAmFrom1: bedRota[Strings.thursdayAmFrom1],
      Strings.thursdayAmTo1: bedRota[Strings.thursdayAmTo1],
      Strings.thursdayPmName1: bedRota[Strings.thursdayPmName1],
      Strings.thursdayPmFrom1: bedRota[Strings.thursdayPmFrom1],
      Strings.thursdayPmTo1: bedRota[Strings.thursdayPmTo1],
      Strings.thursdayNightName1: bedRota[Strings.thursdayNightName1],
      Strings.thursdayNightFrom1: bedRota[Strings.thursdayNightFrom1],
      Strings.thursdayNightTo1: bedRota[Strings.thursdayNightTo1],
      Strings.thursdayAmName2: bedRota[Strings.thursdayAmName2],
      Strings.thursdayAmFrom2: bedRota[Strings.thursdayAmFrom2],
      Strings.thursdayAmTo2: bedRota[Strings.thursdayAmTo2],
      Strings.thursdayPmName2: bedRota[Strings.thursdayPmName2],
      Strings.thursdayPmFrom2: bedRota[Strings.thursdayPmFrom2],
      Strings.thursdayPmTo2: bedRota[Strings.thursdayPmTo2],
      Strings.thursdayNightName2: bedRota[Strings.thursdayNightName2],
      Strings.thursdayNightFrom2: bedRota[Strings.thursdayNightFrom2],
      Strings.thursdayNightTo2: bedRota[Strings.thursdayNightTo2],
      Strings.thursdayAmName3: bedRota[Strings.thursdayAmName3],
      Strings.thursdayAmFrom3: bedRota[Strings.thursdayAmFrom3],
      Strings.thursdayAmTo3: bedRota[Strings.thursdayAmTo3],
      Strings.thursdayPmName3: bedRota[Strings.thursdayPmName3],
      Strings.thursdayPmFrom3: bedRota[Strings.thursdayPmFrom3],
      Strings.thursdayPmTo3: bedRota[Strings.thursdayPmTo3],
      Strings.thursdayNightName3: bedRota[Strings.thursdayNightName3],
      Strings.thursdayNightFrom3: bedRota[Strings.thursdayNightFrom3],
      Strings.thursdayNightTo3: bedRota[Strings.thursdayNightTo3],
      Strings.thursdayAmName4: bedRota[Strings.thursdayAmName4],
      Strings.thursdayAmFrom4: bedRota[Strings.thursdayAmFrom4],
      Strings.thursdayAmTo4: bedRota[Strings.thursdayAmTo4],
      Strings.thursdayPmName4: bedRota[Strings.thursdayPmName4],
      Strings.thursdayPmFrom4: bedRota[Strings.thursdayPmFrom4],
      Strings.thursdayPmTo4: bedRota[Strings.thursdayPmTo4],
      Strings.thursdayNightName4: bedRota[Strings.thursdayNightName4],
      Strings.thursdayNightFrom4: bedRota[Strings.thursdayNightFrom4],
      Strings.thursdayNightTo4: bedRota[Strings.thursdayNightTo4],
      Strings.thursdayAmName5: bedRota[Strings.thursdayAmName5],
      Strings.thursdayAmFrom5: bedRota[Strings.thursdayAmFrom5],
      Strings.thursdayAmTo5: bedRota[Strings.thursdayAmTo5],
      Strings.thursdayPmName5: bedRota[Strings.thursdayPmName5],
      Strings.thursdayPmFrom5: bedRota[Strings.thursdayPmFrom5],
      Strings.thursdayPmTo5: bedRota[Strings.thursdayPmTo5],
      Strings.thursdayNightName5: bedRota[Strings.thursdayNightName5],
      Strings.thursdayNightFrom5: bedRota[Strings.thursdayNightFrom5],
      Strings.thursdayNightTo5: bedRota[Strings.thursdayNightTo5],
      Strings.fridayAmName1: bedRota[Strings.fridayAmName1],
      Strings.fridayAmFrom1: bedRota[Strings.fridayAmFrom1],
      Strings.fridayAmTo1: bedRota[Strings.fridayAmTo1],
      Strings.fridayPmName1: bedRota[Strings.fridayPmName1],
      Strings.fridayPmFrom1: bedRota[Strings.fridayPmFrom1],
      Strings.fridayPmTo1: bedRota[Strings.fridayPmTo1],
      Strings.fridayNightName1: bedRota[Strings.fridayNightName1],
      Strings.fridayNightFrom1: bedRota[Strings.fridayNightFrom1],
      Strings.fridayNightTo1: bedRota[Strings.fridayNightTo1],
      Strings.fridayAmName2: bedRota[Strings.fridayAmName2],
      Strings.fridayAmFrom2: bedRota[Strings.fridayAmFrom2],
      Strings.fridayAmTo2: bedRota[Strings.fridayAmTo2],
      Strings.fridayPmName2: bedRota[Strings.fridayPmName2],
      Strings.fridayPmFrom2: bedRota[Strings.fridayPmFrom2],
      Strings.fridayPmTo2: bedRota[Strings.fridayPmTo2],
      Strings.fridayNightName2: bedRota[Strings.fridayNightName2],
      Strings.fridayNightFrom2: bedRota[Strings.fridayNightFrom2],
      Strings.fridayNightTo2: bedRota[Strings.fridayNightTo2],
      Strings.fridayAmName3: bedRota[Strings.fridayAmName3],
      Strings.fridayAmFrom3: bedRota[Strings.fridayAmFrom3],
      Strings.fridayAmTo3: bedRota[Strings.fridayAmTo3],
      Strings.fridayPmName3: bedRota[Strings.fridayPmName3],
      Strings.fridayPmFrom3: bedRota[Strings.fridayPmFrom3],
      Strings.fridayPmTo3: bedRota[Strings.fridayPmTo3],
      Strings.fridayNightName3: bedRota[Strings.fridayNightName3],
      Strings.fridayNightFrom3: bedRota[Strings.fridayNightFrom3],
      Strings.fridayNightTo3: bedRota[Strings.fridayNightTo3],
      Strings.fridayAmName4: bedRota[Strings.fridayAmName4],
      Strings.fridayAmFrom4: bedRota[Strings.fridayAmFrom4],
      Strings.fridayAmTo4: bedRota[Strings.fridayAmTo4],
      Strings.fridayPmName4: bedRota[Strings.fridayPmName4],
      Strings.fridayPmFrom4: bedRota[Strings.fridayPmFrom4],
      Strings.fridayPmTo4: bedRota[Strings.fridayPmTo4],
      Strings.fridayNightName4: bedRota[Strings.fridayNightName4],
      Strings.fridayNightFrom4: bedRota[Strings.fridayNightFrom4],
      Strings.fridayNightTo4: bedRota[Strings.fridayNightTo4],
      Strings.fridayAmName5: bedRota[Strings.fridayAmName5],
      Strings.fridayAmFrom5: bedRota[Strings.fridayAmFrom5],
      Strings.fridayAmTo5: bedRota[Strings.fridayAmTo5],
      Strings.fridayPmName5: bedRota[Strings.fridayPmName5],
      Strings.fridayPmFrom5: bedRota[Strings.fridayPmFrom5],
      Strings.fridayPmTo5: bedRota[Strings.fridayPmTo5],
      Strings.fridayNightName5: bedRota[Strings.fridayNightName5],
      Strings.fridayNightFrom5: bedRota[Strings.fridayNightFrom5],
      Strings.fridayNightTo5: bedRota[Strings.fridayNightTo5],
      Strings.saturdayAmName1: bedRota[Strings.saturdayAmName1],
      Strings.saturdayAmFrom1: bedRota[Strings.saturdayAmFrom1],
      Strings.saturdayAmTo1: bedRota[Strings.saturdayAmTo1],
      Strings.saturdayPmName1: bedRota[Strings.saturdayPmName1],
      Strings.saturdayPmFrom1: bedRota[Strings.saturdayPmFrom1],
      Strings.saturdayPmTo1: bedRota[Strings.saturdayPmTo1],
      Strings.saturdayNightName1: bedRota[Strings.saturdayNightName1],
      Strings.saturdayNightFrom1: bedRota[Strings.saturdayNightFrom1],
      Strings.saturdayNightTo1: bedRota[Strings.saturdayNightTo1],
      Strings.saturdayAmName2: bedRota[Strings.saturdayAmName2],
      Strings.saturdayAmFrom2: bedRota[Strings.saturdayAmFrom2],
      Strings.saturdayAmTo2: bedRota[Strings.saturdayAmTo2],
      Strings.saturdayPmName2: bedRota[Strings.saturdayPmName2],
      Strings.saturdayPmFrom2: bedRota[Strings.saturdayPmFrom2],
      Strings.saturdayPmTo2: bedRota[Strings.saturdayPmTo2],
      Strings.saturdayNightName2: bedRota[Strings.saturdayNightName2],
      Strings.saturdayNightFrom2: bedRota[Strings.saturdayNightFrom2],
      Strings.saturdayNightTo2: bedRota[Strings.saturdayNightTo2],
      Strings.saturdayAmName3: bedRota[Strings.saturdayAmName3],
      Strings.saturdayAmFrom3: bedRota[Strings.saturdayAmFrom3],
      Strings.saturdayAmTo3: bedRota[Strings.saturdayAmTo3],
      Strings.saturdayPmName3: bedRota[Strings.saturdayPmName3],
      Strings.saturdayPmFrom3: bedRota[Strings.saturdayPmFrom3],
      Strings.saturdayPmTo3: bedRota[Strings.saturdayPmTo3],
      Strings.saturdayNightName3: bedRota[Strings.saturdayNightName3],
      Strings.saturdayNightFrom3: bedRota[Strings.saturdayNightFrom3],
      Strings.saturdayNightTo3: bedRota[Strings.saturdayNightTo3],
      Strings.saturdayAmName4: bedRota[Strings.saturdayAmName4],
      Strings.saturdayAmFrom4: bedRota[Strings.saturdayAmFrom4],
      Strings.saturdayAmTo4: bedRota[Strings.saturdayAmTo4],
      Strings.saturdayPmName4: bedRota[Strings.saturdayPmName4],
      Strings.saturdayPmFrom4: bedRota[Strings.saturdayPmFrom4],
      Strings.saturdayPmTo4: bedRota[Strings.saturdayPmTo4],
      Strings.saturdayNightName4: bedRota[Strings.saturdayNightName4],
      Strings.saturdayNightFrom4: bedRota[Strings.saturdayNightFrom4],
      Strings.saturdayNightTo4: bedRota[Strings.saturdayNightTo4],
      Strings.saturdayAmName5: bedRota[Strings.saturdayAmName5],
      Strings.saturdayAmFrom5: bedRota[Strings.saturdayAmFrom5],
      Strings.saturdayAmTo5: bedRota[Strings.saturdayAmTo5],
      Strings.saturdayPmName5: bedRota[Strings.saturdayPmName5],
      Strings.saturdayPmFrom5: bedRota[Strings.saturdayPmFrom5],
      Strings.saturdayPmTo5: bedRota[Strings.saturdayPmTo5],
      Strings.saturdayNightName5: bedRota[Strings.saturdayNightName5],
      Strings.saturdayNightFrom5: bedRota[Strings.saturdayNightFrom5],
      Strings.saturdayNightTo5: bedRota[Strings.saturdayNightTo5],
      Strings.sundayAmName1: bedRota[Strings.sundayAmName1],
      Strings.sundayAmFrom1: bedRota[Strings.sundayAmFrom1],
      Strings.sundayAmTo1: bedRota[Strings.sundayAmTo1],
      Strings.sundayPmName1: bedRota[Strings.sundayPmName1],
      Strings.sundayPmFrom1: bedRota[Strings.sundayPmFrom1],
      Strings.sundayPmTo1: bedRota[Strings.sundayPmTo1],
      Strings.sundayNightName1: bedRota[Strings.sundayNightName1],
      Strings.sundayNightFrom1: bedRota[Strings.sundayNightFrom1],
      Strings.sundayNightTo1: bedRota[Strings.sundayNightTo1],
      Strings.sundayAmName2: bedRota[Strings.sundayAmName2],
      Strings.sundayAmFrom2: bedRota[Strings.sundayAmFrom2],
      Strings.sundayAmTo2: bedRota[Strings.sundayAmTo2],
      Strings.sundayPmName2: bedRota[Strings.sundayPmName2],
      Strings.sundayPmFrom2: bedRota[Strings.sundayPmFrom2],
      Strings.sundayPmTo2: bedRota[Strings.sundayPmTo2],
      Strings.sundayNightName2: bedRota[Strings.sundayNightName2],
      Strings.sundayNightFrom2: bedRota[Strings.sundayNightFrom2],
      Strings.sundayNightTo2: bedRota[Strings.sundayNightTo2],
      Strings.sundayAmName3: bedRota[Strings.sundayAmName3],
      Strings.sundayAmFrom3: bedRota[Strings.sundayAmFrom3],
      Strings.sundayAmTo3: bedRota[Strings.sundayAmTo3],
      Strings.sundayPmName3: bedRota[Strings.sundayPmName3],
      Strings.sundayPmFrom3: bedRota[Strings.sundayPmFrom3],
      Strings.sundayPmTo3: bedRota[Strings.sundayPmTo3],
      Strings.sundayNightName3: bedRota[Strings.sundayNightName3],
      Strings.sundayNightFrom3: bedRota[Strings.sundayNightFrom3],
      Strings.sundayNightTo3: bedRota[Strings.sundayNightTo3],
      Strings.sundayAmName4: bedRota[Strings.sundayAmName4],
      Strings.sundayAmFrom4: bedRota[Strings.sundayAmFrom4],
      Strings.sundayAmTo4: bedRota[Strings.sundayAmTo4],
      Strings.sundayPmName4: bedRota[Strings.sundayPmName4],
      Strings.sundayPmFrom4: bedRota[Strings.sundayPmFrom4],
      Strings.sundayPmTo4: bedRota[Strings.sundayPmTo4],
      Strings.sundayNightName4: bedRota[Strings.sundayNightName4],
      Strings.sundayNightFrom4: bedRota[Strings.sundayNightFrom4],
      Strings.sundayNightTo4: bedRota[Strings.sundayNightTo4],
      Strings.sundayAmName5: bedRota[Strings.sundayAmName5],
      Strings.sundayAmFrom5: bedRota[Strings.sundayAmFrom5],
      Strings.sundayAmTo5: bedRota[Strings.sundayAmTo5],
      Strings.sundayPmName5: bedRota[Strings.sundayPmName5],
      Strings.sundayPmFrom5: bedRota[Strings.sundayPmFrom5],
      Strings.sundayPmTo5: bedRota[Strings.sundayPmTo5],
      Strings.sundayNightName5: bedRota[Strings.sundayNightName5],
      Strings.sundayNightFrom5: bedRota[Strings.sundayNightFrom5],
      Strings.sundayNightTo5: bedRota[Strings.sundayNightTo5],
    };

    await _savedBedRotasStore.record(id).put(await _db,
        localData);

    message = 'Bed Watch Rota saved to device';
    success = true;

    if(success) resetTemporaryRecord(jobId, false, 0);
    GlobalFunctions.dismissLoadingDialog();
    GlobalFunctions.showToast(message);
    return success;
  }

  Future<void> deleteSavedRecord(int id) async {
    await _savedBedRotasStore.record(id).delete(await _db);
    _bedRotas.removeWhere((element) => element[Strings.localId] == id);
    notifyListeners();
  }

  Future<void> getSavedRecordsList() async{

    _isLoading = true;
    _bedRotas = [];
    notifyListeners();
    String message = '';

    List<Map<String, dynamic>> _fetchedRecordList = [];

    try {

      List<dynamic> records = await getSavedRecords();

      if(records.length > 0){
        for(var record in records){
          _fetchedRecordList.add(record.value);
        }

        _bedRotas = List.from(_fetchedRecordList.reversed);
      } else {
        //message = 'No saved records available';
      }

    } catch(e){
      print(e);
      message = 'Something went wrong. Please try again';

    }
    _isLoading = false;
    notifyListeners();
    _selBedRotaId = null;
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

    await _temporaryBedRotasStore.update(await _db, {
      Strings.formVersion: 1,
      Strings.jobRef: null,
      Strings.jobRefRef: null,
      Strings.jobRefNo: null,
      Strings.weekCommencing: null,
      Strings.mondayAmName1: null,
      Strings.mondayAmFrom1: null,
      Strings.mondayAmTo1: null,
      Strings.mondayPmName1: null,
      Strings.mondayPmFrom1: null,
      Strings.mondayPmTo1: null,
      Strings.mondayNightName1: null,
      Strings.mondayNightFrom1: null,
      Strings.mondayNightTo1: null,
      Strings.mondayAmName2: null,
      Strings.mondayAmFrom2: null,
      Strings.mondayAmTo2: null,
      Strings.mondayPmName2: null,
      Strings.mondayPmFrom2: null,
      Strings.mondayPmTo2: null,
      Strings.mondayNightName2: null,
      Strings.mondayNightFrom2: null,
      Strings.mondayNightTo2: null,
      Strings.mondayAmName3: null,
      Strings.mondayAmFrom3: null,
      Strings.mondayAmTo3: null,
      Strings.mondayPmName3: null,
      Strings.mondayPmFrom3: null,
      Strings.mondayPmTo3: null,
      Strings.mondayNightName3: null,
      Strings.mondayNightFrom3: null,
      Strings.mondayNightTo3: null,
      Strings.mondayAmName4: null,
      Strings.mondayAmFrom4: null,
      Strings.mondayAmTo4: null,
      Strings.mondayPmName4: null,
      Strings.mondayPmFrom4: null,
      Strings.mondayPmTo4: null,
      Strings.mondayNightName4: null,
      Strings.mondayNightFrom4: null,
      Strings.mondayNightTo4: null,
      Strings.mondayAmName5: null,
      Strings.mondayAmFrom5: null,
      Strings.mondayAmTo5: null,
      Strings.mondayPmName5: null,
      Strings.mondayPmFrom5: null,
      Strings.mondayPmTo5: null,
      Strings.mondayNightName5: null,
      Strings.mondayNightFrom5: null,
      Strings.mondayNightTo5: null,
      Strings.tuesdayAmName1: null,
      Strings.tuesdayAmFrom1: null,
      Strings.tuesdayAmTo1: null,
      Strings.tuesdayPmName1: null,
      Strings.tuesdayPmFrom1: null,
      Strings.tuesdayPmTo1: null,
      Strings.tuesdayNightName1: null,
      Strings.tuesdayNightFrom1: null,
      Strings.tuesdayNightTo1: null,
      Strings.tuesdayAmName2: null,
      Strings.tuesdayAmFrom2: null,
      Strings.tuesdayAmTo2: null,
      Strings.tuesdayPmName2: null,
      Strings.tuesdayPmFrom2: null,
      Strings.tuesdayPmTo2: null,
      Strings.tuesdayNightName2: null,
      Strings.tuesdayNightFrom2: null,
      Strings.tuesdayNightTo2: null,
      Strings.tuesdayAmName3: null,
      Strings.tuesdayAmFrom3: null,
      Strings.tuesdayAmTo3: null,
      Strings.tuesdayPmName3: null,
      Strings.tuesdayPmFrom3: null,
      Strings.tuesdayPmTo3: null,
      Strings.tuesdayNightName3: null,
      Strings.tuesdayNightFrom3: null,
      Strings.tuesdayNightTo3: null,
      Strings.tuesdayAmName4: null,
      Strings.tuesdayAmFrom4: null,
      Strings.tuesdayAmTo4: null,
      Strings.tuesdayPmName4: null,
      Strings.tuesdayPmFrom4: null,
      Strings.tuesdayPmTo4: null,
      Strings.tuesdayNightName4: null,
      Strings.tuesdayNightFrom4: null,
      Strings.tuesdayNightTo4: null,
      Strings.tuesdayAmName5: null,
      Strings.tuesdayAmFrom5: null,
      Strings.tuesdayAmTo5: null,
      Strings.tuesdayPmName5: null,
      Strings.tuesdayPmFrom5: null,
      Strings.tuesdayPmTo5: null,
      Strings.tuesdayNightName5: null,
      Strings.tuesdayNightFrom5: null,
      Strings.tuesdayNightTo5: null,
      Strings.wednesdayAmName1: null,
      Strings.wednesdayAmFrom1: null,
      Strings.wednesdayAmTo1: null,
      Strings.wednesdayPmName1: null,
      Strings.wednesdayPmFrom1: null,
      Strings.wednesdayPmTo1: null,
      Strings.wednesdayNightName1: null,
      Strings.wednesdayNightFrom1: null,
      Strings.wednesdayNightTo1: null,
      Strings.wednesdayAmName2: null,
      Strings.wednesdayAmFrom2: null,
      Strings.wednesdayAmTo2: null,
      Strings.wednesdayPmName2: null,
      Strings.wednesdayPmFrom2: null,
      Strings.wednesdayPmTo2: null,
      Strings.wednesdayNightName2: null,
      Strings.wednesdayNightFrom2: null,
      Strings.wednesdayNightTo2: null,
      Strings.wednesdayAmName3: null,
      Strings.wednesdayAmFrom3: null,
      Strings.wednesdayAmTo3: null,
      Strings.wednesdayPmName3: null,
      Strings.wednesdayPmFrom3: null,
      Strings.wednesdayPmTo3: null,
      Strings.wednesdayNightName3: null,
      Strings.wednesdayNightFrom3: null,
      Strings.wednesdayNightTo3: null,
      Strings.wednesdayAmName4: null,
      Strings.wednesdayAmFrom4: null,
      Strings.wednesdayAmTo4: null,
      Strings.wednesdayPmName4: null,
      Strings.wednesdayPmFrom4: null,
      Strings.wednesdayPmTo4: null,
      Strings.wednesdayNightName4: null,
      Strings.wednesdayNightFrom4: null,
      Strings.wednesdayNightTo4: null,
      Strings.wednesdayAmName5: null,
      Strings.wednesdayAmFrom5: null,
      Strings.wednesdayAmTo5: null,
      Strings.wednesdayPmName5: null,
      Strings.wednesdayPmFrom5: null,
      Strings.wednesdayPmTo5: null,
      Strings.wednesdayNightName5: null,
      Strings.wednesdayNightFrom5: null,
      Strings.wednesdayNightTo5: null,
      Strings.thursdayAmName1: null,
      Strings.thursdayAmFrom1: null,
      Strings.thursdayAmTo1: null,
      Strings.thursdayPmName1: null,
      Strings.thursdayPmFrom1: null,
      Strings.thursdayPmTo1: null,
      Strings.thursdayNightName1: null,
      Strings.thursdayNightFrom1: null,
      Strings.thursdayNightTo1: null,
      Strings.thursdayAmName2: null,
      Strings.thursdayAmFrom2: null,
      Strings.thursdayAmTo2: null,
      Strings.thursdayPmName2: null,
      Strings.thursdayPmFrom2: null,
      Strings.thursdayPmTo2: null,
      Strings.thursdayNightName2: null,
      Strings.thursdayNightFrom2: null,
      Strings.thursdayNightTo2: null,
      Strings.thursdayAmName3: null,
      Strings.thursdayAmFrom3: null,
      Strings.thursdayAmTo3: null,
      Strings.thursdayPmName3: null,
      Strings.thursdayPmFrom3: null,
      Strings.thursdayPmTo3: null,
      Strings.thursdayNightName3: null,
      Strings.thursdayNightFrom3: null,
      Strings.thursdayNightTo3: null,
      Strings.thursdayAmName4: null,
      Strings.thursdayAmFrom4: null,
      Strings.thursdayAmTo4: null,
      Strings.thursdayPmName4: null,
      Strings.thursdayPmFrom4: null,
      Strings.thursdayPmTo4: null,
      Strings.thursdayNightName4: null,
      Strings.thursdayNightFrom4: null,
      Strings.thursdayNightTo4: null,
      Strings.thursdayAmName5: null,
      Strings.thursdayAmFrom5: null,
      Strings.thursdayAmTo5: null,
      Strings.thursdayPmName5: null,
      Strings.thursdayPmFrom5: null,
      Strings.thursdayPmTo5: null,
      Strings.thursdayNightName5: null,
      Strings.thursdayNightFrom5: null,
      Strings.thursdayNightTo5: null,
      Strings.fridayAmName1: null,
      Strings.fridayAmFrom1: null,
      Strings.fridayAmTo1: null,
      Strings.fridayPmName1: null,
      Strings.fridayPmFrom1: null,
      Strings.fridayPmTo1: null,
      Strings.fridayNightName1: null,
      Strings.fridayNightFrom1: null,
      Strings.fridayNightTo1: null,
      Strings.fridayAmName2: null,
      Strings.fridayAmFrom2: null,
      Strings.fridayAmTo2: null,
      Strings.fridayPmName2: null,
      Strings.fridayPmFrom2: null,
      Strings.fridayPmTo2: null,
      Strings.fridayNightName2: null,
      Strings.fridayNightFrom2: null,
      Strings.fridayNightTo2: null,
      Strings.fridayAmName3: null,
      Strings.fridayAmFrom3: null,
      Strings.fridayAmTo3: null,
      Strings.fridayPmName3: null,
      Strings.fridayPmFrom3: null,
      Strings.fridayPmTo3: null,
      Strings.fridayNightName3: null,
      Strings.fridayNightFrom3: null,
      Strings.fridayNightTo3: null,
      Strings.fridayAmName4: null,
      Strings.fridayAmFrom4: null,
      Strings.fridayAmTo4: null,
      Strings.fridayPmName4: null,
      Strings.fridayPmFrom4: null,
      Strings.fridayPmTo4: null,
      Strings.fridayNightName4: null,
      Strings.fridayNightFrom4: null,
      Strings.fridayNightTo4: null,
      Strings.fridayAmName5: null,
      Strings.fridayAmFrom5: null,
      Strings.fridayAmTo5: null,
      Strings.fridayPmName5: null,
      Strings.fridayPmFrom5: null,
      Strings.fridayPmTo5: null,
      Strings.fridayNightName5: null,
      Strings.fridayNightFrom5: null,
      Strings.fridayNightTo5: null,
      Strings.saturdayAmName1: null,
      Strings.saturdayAmFrom1: null,
      Strings.saturdayAmTo1: null,
      Strings.saturdayPmName1: null,
      Strings.saturdayPmFrom1: null,
      Strings.saturdayPmTo1: null,
      Strings.saturdayNightName1: null,
      Strings.saturdayNightFrom1: null,
      Strings.saturdayNightTo1: null,
      Strings.saturdayAmName2: null,
      Strings.saturdayAmFrom2: null,
      Strings.saturdayAmTo2: null,
      Strings.saturdayPmName2: null,
      Strings.saturdayPmFrom2: null,
      Strings.saturdayPmTo2: null,
      Strings.saturdayNightName2: null,
      Strings.saturdayNightFrom2: null,
      Strings.saturdayNightTo2: null,
      Strings.saturdayAmName3: null,
      Strings.saturdayAmFrom3: null,
      Strings.saturdayAmTo3: null,
      Strings.saturdayPmName3: null,
      Strings.saturdayPmFrom3: null,
      Strings.saturdayPmTo3: null,
      Strings.saturdayNightName3: null,
      Strings.saturdayNightFrom3: null,
      Strings.saturdayNightTo3: null,
      Strings.saturdayAmName4: null,
      Strings.saturdayAmFrom4: null,
      Strings.saturdayAmTo4: null,
      Strings.saturdayPmName4: null,
      Strings.saturdayPmFrom4: null,
      Strings.saturdayPmTo4: null,
      Strings.saturdayNightName4: null,
      Strings.saturdayNightFrom4: null,
      Strings.saturdayNightTo4: null,
      Strings.saturdayAmName5: null,
      Strings.saturdayAmFrom5: null,
      Strings.saturdayAmTo5: null,
      Strings.saturdayPmName5: null,
      Strings.saturdayPmFrom5: null,
      Strings.saturdayPmTo5: null,
      Strings.saturdayNightName5: null,
      Strings.saturdayNightFrom5: null,
      Strings.saturdayNightTo5: null,
      Strings.sundayAmName1: null,
      Strings.sundayAmFrom1: null,
      Strings.sundayAmTo1: null,
      Strings.sundayPmName1: null,
      Strings.sundayPmFrom1: null,
      Strings.sundayPmTo1: null,
      Strings.sundayNightName1: null,
      Strings.sundayNightFrom1: null,
      Strings.sundayNightTo1: null,
      Strings.sundayAmName2: null,
      Strings.sundayAmFrom2: null,
      Strings.sundayAmTo2: null,
      Strings.sundayPmName2: null,
      Strings.sundayPmFrom2: null,
      Strings.sundayPmTo2: null,
      Strings.sundayNightName2: null,
      Strings.sundayNightFrom2: null,
      Strings.sundayNightTo2: null,
      Strings.sundayAmName3: null,
      Strings.sundayAmFrom3: null,
      Strings.sundayAmTo3: null,
      Strings.sundayPmName3: null,
      Strings.sundayPmFrom3: null,
      Strings.sundayPmTo3: null,
      Strings.sundayNightName3: null,
      Strings.sundayNightFrom3: null,
      Strings.sundayNightTo3: null,
      Strings.sundayAmName4: null,
      Strings.sundayAmFrom4: null,
      Strings.sundayAmTo4: null,
      Strings.sundayPmName4: null,
      Strings.sundayPmFrom4: null,
      Strings.sundayPmTo4: null,
      Strings.sundayNightName4: null,
      Strings.sundayNightFrom4: null,
      Strings.sundayNightTo4: null,
      Strings.sundayAmName5: null,
      Strings.sundayAmFrom5: null,
      Strings.sundayAmTo5: null,
      Strings.sundayPmName5: null,
      Strings.sundayPmFrom5: null,
      Strings.sundayPmTo5: null,
      Strings.sundayNightName5: null,
      Strings.sundayNightFrom5: null,
      Strings.sundayNightTo5: null,

    },
        finder: finder);
    notifyListeners();
  }

  Future<bool> validateBedRota(String jobId, bool edit, bool saved, int savedId) async {

    bool success = true;
    Map<String, dynamic> bedRota = await getTemporaryRecord(edit, jobId, saved, savedId);


    if(bedRota[Strings.jobRefNo]== null || bedRota[Strings.jobRefNo].toString().trim() == ''){
      success = false;
    }

    if(bedRota[Strings.jobRefRef]== null || bedRota[Strings.jobRefRef]== 'Select One'){
      success = false;
    }

    if(bedRota[Strings.weekCommencing] == null){
      success = false;
    }

    return success;
  }

  Future<bool> submitBedRota(String jobId, bool edit, bool saved, int savedId) async {

    GlobalFunctions.showLoadingDialog('Submitting Bed Watch Rota...');
    String message = '';
    bool success = false;
    int id = DateTime.now().millisecondsSinceEpoch + int.parse(random_string.randomNumeric(2));

    //Sembast
    Map<String, dynamic> bedRota = await getTemporaryRecord(false, jobId, saved, savedId);

    Map<String, dynamic> localData = {
      Strings.localId: id,
      Strings.documentId: null,
      Strings.uid: user.uid,
      Strings.jobId: '1',
      Strings.formVersion: '1',
      Strings.jobRef: bedRota[Strings.jobRefRef] + bedRota[Strings.jobRefNo],
      Strings.jobRefRef: bedRota[Strings.jobRefRef],
      Strings.jobRefNo: bedRota[Strings.jobRefNo],
      Strings.weekCommencing: bedRota[Strings.weekCommencing],
      Strings.mondayAmName1: bedRota[Strings.mondayAmName1],
      Strings.mondayAmFrom1: bedRota[Strings.mondayAmFrom1],
      Strings.mondayAmTo1: bedRota[Strings.mondayAmTo1],
      Strings.mondayPmName1: bedRota[Strings.mondayPmName1],
      Strings.mondayPmFrom1: bedRota[Strings.mondayPmFrom1],
      Strings.mondayPmTo1: bedRota[Strings.mondayPmTo1],
      Strings.mondayNightName1: bedRota[Strings.mondayNightName1],
      Strings.mondayNightFrom1: bedRota[Strings.mondayNightFrom1],
      Strings.mondayNightTo1: bedRota[Strings.mondayNightTo1],
      Strings.mondayAmName2: bedRota[Strings.mondayAmName2],
      Strings.mondayAmFrom2: bedRota[Strings.mondayAmFrom2],
      Strings.mondayAmTo2: bedRota[Strings.mondayAmTo2],
      Strings.mondayPmName2: bedRota[Strings.mondayPmName2],
      Strings.mondayPmFrom2: bedRota[Strings.mondayPmFrom2],
      Strings.mondayPmTo2: bedRota[Strings.mondayPmTo2],
      Strings.mondayNightName2: bedRota[Strings.mondayNightName2],
      Strings.mondayNightFrom2: bedRota[Strings.mondayNightFrom2],
      Strings.mondayNightTo2: bedRota[Strings.mondayNightTo2],
      Strings.mondayAmName3: bedRota[Strings.mondayAmName3],
      Strings.mondayAmFrom3: bedRota[Strings.mondayAmFrom3],
      Strings.mondayAmTo3: bedRota[Strings.mondayAmTo3],
      Strings.mondayPmName3: bedRota[Strings.mondayPmName3],
      Strings.mondayPmFrom3: bedRota[Strings.mondayPmFrom3],
      Strings.mondayPmTo3: bedRota[Strings.mondayPmTo3],
      Strings.mondayNightName3: bedRota[Strings.mondayNightName3],
      Strings.mondayNightFrom3: bedRota[Strings.mondayNightFrom3],
      Strings.mondayNightTo3: bedRota[Strings.mondayNightTo3],
      Strings.mondayAmName4: bedRota[Strings.mondayAmName4],
      Strings.mondayAmFrom4: bedRota[Strings.mondayAmFrom4],
      Strings.mondayAmTo4: bedRota[Strings.mondayAmTo4],
      Strings.mondayPmName4: bedRota[Strings.mondayPmName4],
      Strings.mondayPmFrom4: bedRota[Strings.mondayPmFrom4],
      Strings.mondayPmTo4: bedRota[Strings.mondayPmTo4],
      Strings.mondayNightName4: bedRota[Strings.mondayNightName4],
      Strings.mondayNightFrom4: bedRota[Strings.mondayNightFrom4],
      Strings.mondayNightTo4: bedRota[Strings.mondayNightTo4],
      Strings.mondayAmName5: bedRota[Strings.mondayAmName5],
      Strings.mondayAmFrom5: bedRota[Strings.mondayAmFrom5],
      Strings.mondayAmTo5: bedRota[Strings.mondayAmTo5],
      Strings.mondayPmName5: bedRota[Strings.mondayPmName5],
      Strings.mondayPmFrom5: bedRota[Strings.mondayPmFrom5],
      Strings.mondayPmTo5: bedRota[Strings.mondayPmTo5],
      Strings.mondayNightName5: bedRota[Strings.mondayNightName5],
      Strings.mondayNightFrom5: bedRota[Strings.mondayNightFrom5],
      Strings.mondayNightTo5: bedRota[Strings.mondayNightTo5],
      Strings.tuesdayAmName1: bedRota[Strings.tuesdayAmName1],
      Strings.tuesdayAmFrom1: bedRota[Strings.tuesdayAmFrom1],
      Strings.tuesdayAmTo1: bedRota[Strings.tuesdayAmTo1],
      Strings.tuesdayPmName1: bedRota[Strings.tuesdayPmName1],
      Strings.tuesdayPmFrom1: bedRota[Strings.tuesdayPmFrom1],
      Strings.tuesdayPmTo1: bedRota[Strings.tuesdayPmTo1],
      Strings.tuesdayNightName1: bedRota[Strings.tuesdayNightName1],
      Strings.tuesdayNightFrom1: bedRota[Strings.tuesdayNightFrom1],
      Strings.tuesdayNightTo1: bedRota[Strings.tuesdayNightTo1],
      Strings.tuesdayAmName2: bedRota[Strings.tuesdayAmName2],
      Strings.tuesdayAmFrom2: bedRota[Strings.tuesdayAmFrom2],
      Strings.tuesdayAmTo2: bedRota[Strings.tuesdayAmTo2],
      Strings.tuesdayPmName2: bedRota[Strings.tuesdayPmName2],
      Strings.tuesdayPmFrom2: bedRota[Strings.tuesdayPmFrom2],
      Strings.tuesdayPmTo2: bedRota[Strings.tuesdayPmTo2],
      Strings.tuesdayNightName2: bedRota[Strings.tuesdayNightName2],
      Strings.tuesdayNightFrom2: bedRota[Strings.tuesdayNightFrom2],
      Strings.tuesdayNightTo2: bedRota[Strings.tuesdayNightTo2],
      Strings.tuesdayAmName3: bedRota[Strings.tuesdayAmName3],
      Strings.tuesdayAmFrom3: bedRota[Strings.tuesdayAmFrom3],
      Strings.tuesdayAmTo3: bedRota[Strings.tuesdayAmTo3],
      Strings.tuesdayPmName3: bedRota[Strings.tuesdayPmName3],
      Strings.tuesdayPmFrom3: bedRota[Strings.tuesdayPmFrom3],
      Strings.tuesdayPmTo3: bedRota[Strings.tuesdayPmTo3],
      Strings.tuesdayNightName3: bedRota[Strings.tuesdayNightName3],
      Strings.tuesdayNightFrom3: bedRota[Strings.tuesdayNightFrom3],
      Strings.tuesdayNightTo3: bedRota[Strings.tuesdayNightTo3],
      Strings.tuesdayAmName4: bedRota[Strings.tuesdayAmName4],
      Strings.tuesdayAmFrom4: bedRota[Strings.tuesdayAmFrom4],
      Strings.tuesdayAmTo4: bedRota[Strings.tuesdayAmTo4],
      Strings.tuesdayPmName4: bedRota[Strings.tuesdayPmName4],
      Strings.tuesdayPmFrom4: bedRota[Strings.tuesdayPmFrom4],
      Strings.tuesdayPmTo4: bedRota[Strings.tuesdayPmTo4],
      Strings.tuesdayNightName4: bedRota[Strings.tuesdayNightName4],
      Strings.tuesdayNightFrom4: bedRota[Strings.tuesdayNightFrom4],
      Strings.tuesdayNightTo4: bedRota[Strings.tuesdayNightTo4],
      Strings.tuesdayAmName5: bedRota[Strings.tuesdayAmName5],
      Strings.tuesdayAmFrom5: bedRota[Strings.tuesdayAmFrom5],
      Strings.tuesdayAmTo5: bedRota[Strings.tuesdayAmTo5],
      Strings.tuesdayPmName5: bedRota[Strings.tuesdayPmName5],
      Strings.tuesdayPmFrom5: bedRota[Strings.tuesdayPmFrom5],
      Strings.tuesdayPmTo5: bedRota[Strings.tuesdayPmTo5],
      Strings.tuesdayNightName5: bedRota[Strings.tuesdayNightName5],
      Strings.tuesdayNightFrom5: bedRota[Strings.tuesdayNightFrom5],
      Strings.tuesdayNightTo5: bedRota[Strings.tuesdayNightTo5],
      Strings.wednesdayAmName1: bedRota[Strings.wednesdayAmName1],
      Strings.wednesdayAmFrom1: bedRota[Strings.wednesdayAmFrom1],
      Strings.wednesdayAmTo1: bedRota[Strings.wednesdayAmTo1],
      Strings.wednesdayPmName1: bedRota[Strings.wednesdayPmName1],
      Strings.wednesdayPmFrom1: bedRota[Strings.wednesdayPmFrom1],
      Strings.wednesdayPmTo1: bedRota[Strings.wednesdayPmTo1],
      Strings.wednesdayNightName1: bedRota[Strings.wednesdayNightName1],
      Strings.wednesdayNightFrom1: bedRota[Strings.wednesdayNightFrom1],
      Strings.wednesdayNightTo1: bedRota[Strings.wednesdayNightTo1],
      Strings.wednesdayAmName2: bedRota[Strings.wednesdayAmName2],
      Strings.wednesdayAmFrom2: bedRota[Strings.wednesdayAmFrom2],
      Strings.wednesdayAmTo2: bedRota[Strings.wednesdayAmTo2],
      Strings.wednesdayPmName2: bedRota[Strings.wednesdayPmName2],
      Strings.wednesdayPmFrom2: bedRota[Strings.wednesdayPmFrom2],
      Strings.wednesdayPmTo2: bedRota[Strings.wednesdayPmTo2],
      Strings.wednesdayNightName2: bedRota[Strings.wednesdayNightName2],
      Strings.wednesdayNightFrom2: bedRota[Strings.wednesdayNightFrom2],
      Strings.wednesdayNightTo2: bedRota[Strings.wednesdayNightTo2],
      Strings.wednesdayAmName3: bedRota[Strings.wednesdayAmName3],
      Strings.wednesdayAmFrom3: bedRota[Strings.wednesdayAmFrom3],
      Strings.wednesdayAmTo3: bedRota[Strings.wednesdayAmTo3],
      Strings.wednesdayPmName3: bedRota[Strings.wednesdayPmName3],
      Strings.wednesdayPmFrom3: bedRota[Strings.wednesdayPmFrom3],
      Strings.wednesdayPmTo3: bedRota[Strings.wednesdayPmTo3],
      Strings.wednesdayNightName3: bedRota[Strings.wednesdayNightName3],
      Strings.wednesdayNightFrom3: bedRota[Strings.wednesdayNightFrom3],
      Strings.wednesdayNightTo3: bedRota[Strings.wednesdayNightTo3],
      Strings.wednesdayAmName4: bedRota[Strings.wednesdayAmName4],
      Strings.wednesdayAmFrom4: bedRota[Strings.wednesdayAmFrom4],
      Strings.wednesdayAmTo4: bedRota[Strings.wednesdayAmTo4],
      Strings.wednesdayPmName4: bedRota[Strings.wednesdayPmName4],
      Strings.wednesdayPmFrom4: bedRota[Strings.wednesdayPmFrom4],
      Strings.wednesdayPmTo4: bedRota[Strings.wednesdayPmTo4],
      Strings.wednesdayNightName4: bedRota[Strings.wednesdayNightName4],
      Strings.wednesdayNightFrom4: bedRota[Strings.wednesdayNightFrom4],
      Strings.wednesdayNightTo4: bedRota[Strings.wednesdayNightTo4],
      Strings.wednesdayAmName5: bedRota[Strings.wednesdayAmName5],
      Strings.wednesdayAmFrom5: bedRota[Strings.wednesdayAmFrom5],
      Strings.wednesdayAmTo5: bedRota[Strings.wednesdayAmTo5],
      Strings.wednesdayPmName5: bedRota[Strings.wednesdayPmName5],
      Strings.wednesdayPmFrom5: bedRota[Strings.wednesdayPmFrom5],
      Strings.wednesdayPmTo5: bedRota[Strings.wednesdayPmTo5],
      Strings.wednesdayNightName5: bedRota[Strings.wednesdayNightName5],
      Strings.wednesdayNightFrom5: bedRota[Strings.wednesdayNightFrom5],
      Strings.wednesdayNightTo5: bedRota[Strings.wednesdayNightTo5],
      Strings.thursdayAmName1: bedRota[Strings.thursdayAmName1],
      Strings.thursdayAmFrom1: bedRota[Strings.thursdayAmFrom1],
      Strings.thursdayAmTo1: bedRota[Strings.thursdayAmTo1],
      Strings.thursdayPmName1: bedRota[Strings.thursdayPmName1],
      Strings.thursdayPmFrom1: bedRota[Strings.thursdayPmFrom1],
      Strings.thursdayPmTo1: bedRota[Strings.thursdayPmTo1],
      Strings.thursdayNightName1: bedRota[Strings.thursdayNightName1],
      Strings.thursdayNightFrom1: bedRota[Strings.thursdayNightFrom1],
      Strings.thursdayNightTo1: bedRota[Strings.thursdayNightTo1],
      Strings.thursdayAmName2: bedRota[Strings.thursdayAmName2],
      Strings.thursdayAmFrom2: bedRota[Strings.thursdayAmFrom2],
      Strings.thursdayAmTo2: bedRota[Strings.thursdayAmTo2],
      Strings.thursdayPmName2: bedRota[Strings.thursdayPmName2],
      Strings.thursdayPmFrom2: bedRota[Strings.thursdayPmFrom2],
      Strings.thursdayPmTo2: bedRota[Strings.thursdayPmTo2],
      Strings.thursdayNightName2: bedRota[Strings.thursdayNightName2],
      Strings.thursdayNightFrom2: bedRota[Strings.thursdayNightFrom2],
      Strings.thursdayNightTo2: bedRota[Strings.thursdayNightTo2],
      Strings.thursdayAmName3: bedRota[Strings.thursdayAmName3],
      Strings.thursdayAmFrom3: bedRota[Strings.thursdayAmFrom3],
      Strings.thursdayAmTo3: bedRota[Strings.thursdayAmTo3],
      Strings.thursdayPmName3: bedRota[Strings.thursdayPmName3],
      Strings.thursdayPmFrom3: bedRota[Strings.thursdayPmFrom3],
      Strings.thursdayPmTo3: bedRota[Strings.thursdayPmTo3],
      Strings.thursdayNightName3: bedRota[Strings.thursdayNightName3],
      Strings.thursdayNightFrom3: bedRota[Strings.thursdayNightFrom3],
      Strings.thursdayNightTo3: bedRota[Strings.thursdayNightTo3],
      Strings.thursdayAmName4: bedRota[Strings.thursdayAmName4],
      Strings.thursdayAmFrom4: bedRota[Strings.thursdayAmFrom4],
      Strings.thursdayAmTo4: bedRota[Strings.thursdayAmTo4],
      Strings.thursdayPmName4: bedRota[Strings.thursdayPmName4],
      Strings.thursdayPmFrom4: bedRota[Strings.thursdayPmFrom4],
      Strings.thursdayPmTo4: bedRota[Strings.thursdayPmTo4],
      Strings.thursdayNightName4: bedRota[Strings.thursdayNightName4],
      Strings.thursdayNightFrom4: bedRota[Strings.thursdayNightFrom4],
      Strings.thursdayNightTo4: bedRota[Strings.thursdayNightTo4],
      Strings.thursdayAmName5: bedRota[Strings.thursdayAmName5],
      Strings.thursdayAmFrom5: bedRota[Strings.thursdayAmFrom5],
      Strings.thursdayAmTo5: bedRota[Strings.thursdayAmTo5],
      Strings.thursdayPmName5: bedRota[Strings.thursdayPmName5],
      Strings.thursdayPmFrom5: bedRota[Strings.thursdayPmFrom5],
      Strings.thursdayPmTo5: bedRota[Strings.thursdayPmTo5],
      Strings.thursdayNightName5: bedRota[Strings.thursdayNightName5],
      Strings.thursdayNightFrom5: bedRota[Strings.thursdayNightFrom5],
      Strings.thursdayNightTo5: bedRota[Strings.thursdayNightTo5],
      Strings.fridayAmName1: bedRota[Strings.fridayAmName1],
      Strings.fridayAmFrom1: bedRota[Strings.fridayAmFrom1],
      Strings.fridayAmTo1: bedRota[Strings.fridayAmTo1],
      Strings.fridayPmName1: bedRota[Strings.fridayPmName1],
      Strings.fridayPmFrom1: bedRota[Strings.fridayPmFrom1],
      Strings.fridayPmTo1: bedRota[Strings.fridayPmTo1],
      Strings.fridayNightName1: bedRota[Strings.fridayNightName1],
      Strings.fridayNightFrom1: bedRota[Strings.fridayNightFrom1],
      Strings.fridayNightTo1: bedRota[Strings.fridayNightTo1],
      Strings.fridayAmName2: bedRota[Strings.fridayAmName2],
      Strings.fridayAmFrom2: bedRota[Strings.fridayAmFrom2],
      Strings.fridayAmTo2: bedRota[Strings.fridayAmTo2],
      Strings.fridayPmName2: bedRota[Strings.fridayPmName2],
      Strings.fridayPmFrom2: bedRota[Strings.fridayPmFrom2],
      Strings.fridayPmTo2: bedRota[Strings.fridayPmTo2],
      Strings.fridayNightName2: bedRota[Strings.fridayNightName2],
      Strings.fridayNightFrom2: bedRota[Strings.fridayNightFrom2],
      Strings.fridayNightTo2: bedRota[Strings.fridayNightTo2],
      Strings.fridayAmName3: bedRota[Strings.fridayAmName3],
      Strings.fridayAmFrom3: bedRota[Strings.fridayAmFrom3],
      Strings.fridayAmTo3: bedRota[Strings.fridayAmTo3],
      Strings.fridayPmName3: bedRota[Strings.fridayPmName3],
      Strings.fridayPmFrom3: bedRota[Strings.fridayPmFrom3],
      Strings.fridayPmTo3: bedRota[Strings.fridayPmTo3],
      Strings.fridayNightName3: bedRota[Strings.fridayNightName3],
      Strings.fridayNightFrom3: bedRota[Strings.fridayNightFrom3],
      Strings.fridayNightTo3: bedRota[Strings.fridayNightTo3],
      Strings.fridayAmName4: bedRota[Strings.fridayAmName4],
      Strings.fridayAmFrom4: bedRota[Strings.fridayAmFrom4],
      Strings.fridayAmTo4: bedRota[Strings.fridayAmTo4],
      Strings.fridayPmName4: bedRota[Strings.fridayPmName4],
      Strings.fridayPmFrom4: bedRota[Strings.fridayPmFrom4],
      Strings.fridayPmTo4: bedRota[Strings.fridayPmTo4],
      Strings.fridayNightName4: bedRota[Strings.fridayNightName4],
      Strings.fridayNightFrom4: bedRota[Strings.fridayNightFrom4],
      Strings.fridayNightTo4: bedRota[Strings.fridayNightTo4],
      Strings.fridayAmName5: bedRota[Strings.fridayAmName5],
      Strings.fridayAmFrom5: bedRota[Strings.fridayAmFrom5],
      Strings.fridayAmTo5: bedRota[Strings.fridayAmTo5],
      Strings.fridayPmName5: bedRota[Strings.fridayPmName5],
      Strings.fridayPmFrom5: bedRota[Strings.fridayPmFrom5],
      Strings.fridayPmTo5: bedRota[Strings.fridayPmTo5],
      Strings.fridayNightName5: bedRota[Strings.fridayNightName5],
      Strings.fridayNightFrom5: bedRota[Strings.fridayNightFrom5],
      Strings.fridayNightTo5: bedRota[Strings.fridayNightTo5],
      Strings.saturdayAmName1: bedRota[Strings.saturdayAmName1],
      Strings.saturdayAmFrom1: bedRota[Strings.saturdayAmFrom1],
      Strings.saturdayAmTo1: bedRota[Strings.saturdayAmTo1],
      Strings.saturdayPmName1: bedRota[Strings.saturdayPmName1],
      Strings.saturdayPmFrom1: bedRota[Strings.saturdayPmFrom1],
      Strings.saturdayPmTo1: bedRota[Strings.saturdayPmTo1],
      Strings.saturdayNightName1: bedRota[Strings.saturdayNightName1],
      Strings.saturdayNightFrom1: bedRota[Strings.saturdayNightFrom1],
      Strings.saturdayNightTo1: bedRota[Strings.saturdayNightTo1],
      Strings.saturdayAmName2: bedRota[Strings.saturdayAmName2],
      Strings.saturdayAmFrom2: bedRota[Strings.saturdayAmFrom2],
      Strings.saturdayAmTo2: bedRota[Strings.saturdayAmTo2],
      Strings.saturdayPmName2: bedRota[Strings.saturdayPmName2],
      Strings.saturdayPmFrom2: bedRota[Strings.saturdayPmFrom2],
      Strings.saturdayPmTo2: bedRota[Strings.saturdayPmTo2],
      Strings.saturdayNightName2: bedRota[Strings.saturdayNightName2],
      Strings.saturdayNightFrom2: bedRota[Strings.saturdayNightFrom2],
      Strings.saturdayNightTo2: bedRota[Strings.saturdayNightTo2],
      Strings.saturdayAmName3: bedRota[Strings.saturdayAmName3],
      Strings.saturdayAmFrom3: bedRota[Strings.saturdayAmFrom3],
      Strings.saturdayAmTo3: bedRota[Strings.saturdayAmTo3],
      Strings.saturdayPmName3: bedRota[Strings.saturdayPmName3],
      Strings.saturdayPmFrom3: bedRota[Strings.saturdayPmFrom3],
      Strings.saturdayPmTo3: bedRota[Strings.saturdayPmTo3],
      Strings.saturdayNightName3: bedRota[Strings.saturdayNightName3],
      Strings.saturdayNightFrom3: bedRota[Strings.saturdayNightFrom3],
      Strings.saturdayNightTo3: bedRota[Strings.saturdayNightTo3],
      Strings.saturdayAmName4: bedRota[Strings.saturdayAmName4],
      Strings.saturdayAmFrom4: bedRota[Strings.saturdayAmFrom4],
      Strings.saturdayAmTo4: bedRota[Strings.saturdayAmTo4],
      Strings.saturdayPmName4: bedRota[Strings.saturdayPmName4],
      Strings.saturdayPmFrom4: bedRota[Strings.saturdayPmFrom4],
      Strings.saturdayPmTo4: bedRota[Strings.saturdayPmTo4],
      Strings.saturdayNightName4: bedRota[Strings.saturdayNightName4],
      Strings.saturdayNightFrom4: bedRota[Strings.saturdayNightFrom4],
      Strings.saturdayNightTo4: bedRota[Strings.saturdayNightTo4],
      Strings.saturdayAmName5: bedRota[Strings.saturdayAmName5],
      Strings.saturdayAmFrom5: bedRota[Strings.saturdayAmFrom5],
      Strings.saturdayAmTo5: bedRota[Strings.saturdayAmTo5],
      Strings.saturdayPmName5: bedRota[Strings.saturdayPmName5],
      Strings.saturdayPmFrom5: bedRota[Strings.saturdayPmFrom5],
      Strings.saturdayPmTo5: bedRota[Strings.saturdayPmTo5],
      Strings.saturdayNightName5: bedRota[Strings.saturdayNightName5],
      Strings.saturdayNightFrom5: bedRota[Strings.saturdayNightFrom5],
      Strings.saturdayNightTo5: bedRota[Strings.saturdayNightTo5],
      Strings.sundayAmName1: bedRota[Strings.sundayAmName1],
      Strings.sundayAmFrom1: bedRota[Strings.sundayAmFrom1],
      Strings.sundayAmTo1: bedRota[Strings.sundayAmTo1],
      Strings.sundayPmName1: bedRota[Strings.sundayPmName1],
      Strings.sundayPmFrom1: bedRota[Strings.sundayPmFrom1],
      Strings.sundayPmTo1: bedRota[Strings.sundayPmTo1],
      Strings.sundayNightName1: bedRota[Strings.sundayNightName1],
      Strings.sundayNightFrom1: bedRota[Strings.sundayNightFrom1],
      Strings.sundayNightTo1: bedRota[Strings.sundayNightTo1],
      Strings.sundayAmName2: bedRota[Strings.sundayAmName2],
      Strings.sundayAmFrom2: bedRota[Strings.sundayAmFrom2],
      Strings.sundayAmTo2: bedRota[Strings.sundayAmTo2],
      Strings.sundayPmName2: bedRota[Strings.sundayPmName2],
      Strings.sundayPmFrom2: bedRota[Strings.sundayPmFrom2],
      Strings.sundayPmTo2: bedRota[Strings.sundayPmTo2],
      Strings.sundayNightName2: bedRota[Strings.sundayNightName2],
      Strings.sundayNightFrom2: bedRota[Strings.sundayNightFrom2],
      Strings.sundayNightTo2: bedRota[Strings.sundayNightTo2],
      Strings.sundayAmName3: bedRota[Strings.sundayAmName3],
      Strings.sundayAmFrom3: bedRota[Strings.sundayAmFrom3],
      Strings.sundayAmTo3: bedRota[Strings.sundayAmTo3],
      Strings.sundayPmName3: bedRota[Strings.sundayPmName3],
      Strings.sundayPmFrom3: bedRota[Strings.sundayPmFrom3],
      Strings.sundayPmTo3: bedRota[Strings.sundayPmTo3],
      Strings.sundayNightName3: bedRota[Strings.sundayNightName3],
      Strings.sundayNightFrom3: bedRota[Strings.sundayNightFrom3],
      Strings.sundayNightTo3: bedRota[Strings.sundayNightTo3],
      Strings.sundayAmName4: bedRota[Strings.sundayAmName4],
      Strings.sundayAmFrom4: bedRota[Strings.sundayAmFrom4],
      Strings.sundayAmTo4: bedRota[Strings.sundayAmTo4],
      Strings.sundayPmName4: bedRota[Strings.sundayPmName4],
      Strings.sundayPmFrom4: bedRota[Strings.sundayPmFrom4],
      Strings.sundayPmTo4: bedRota[Strings.sundayPmTo4],
      Strings.sundayNightName4: bedRota[Strings.sundayNightName4],
      Strings.sundayNightFrom4: bedRota[Strings.sundayNightFrom4],
      Strings.sundayNightTo4: bedRota[Strings.sundayNightTo4],
      Strings.sundayAmName5: bedRota[Strings.sundayAmName5],
      Strings.sundayAmFrom5: bedRota[Strings.sundayAmFrom5],
      Strings.sundayAmTo5: bedRota[Strings.sundayAmTo5],
      Strings.sundayPmName5: bedRota[Strings.sundayPmName5],
      Strings.sundayPmFrom5: bedRota[Strings.sundayPmFrom5],
      Strings.sundayPmTo5: bedRota[Strings.sundayPmTo5],
      Strings.sundayNightName5: bedRota[Strings.sundayNightName5],
      Strings.sundayNightFrom5: bedRota[Strings.sundayNightFrom5],
      Strings.sundayNightTo5: bedRota[Strings.sundayNightTo5],
      Strings.pendingTime: DateTime.now().toIso8601String(),
      Strings.serverUploaded: 0,
    };

    //Sembast
    await _bedRotasStore.record(id).put(await _db,
        localData);

    message = 'Bed Watch Rota has successfully been added to local database';
    bool hasDataConnection = await GlobalFunctions.hasDataConnection();

    if(hasDataConnection){

      bool isTokenExpired = GlobalFunctions.isTokenExpired();
      bool authenticated = true;

      if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

      if(authenticated){


        try {

          await FirebaseFirestore.instance.collection('bed_rotas').add({
            Strings.uid: user.uid,
            Strings.jobId: '1',
            Strings.formVersion: '1',
            Strings.jobRef: GlobalFunctions.databaseValueString(bedRota[Strings.jobRefRef]) + GlobalFunctions.databaseValueString(bedRota[Strings.jobRefNo]),
            Strings.jobRefLowercase: GlobalFunctions.databaseValueString(bedRota[Strings.jobRefRef]).toLowerCase() + GlobalFunctions.databaseValueString(bedRota[Strings.jobRefNo]).toLowerCase(),
            Strings.jobRefRef: GlobalFunctions.databaseValueString(bedRota[Strings.jobRefRef]),
            Strings.jobRefNo:  int.parse(bedRota[Strings.jobRefNo]),
            Strings.weekCommencing: bedRota[Strings.weekCommencing] == null ? null : DateTime.parse(bedRota[Strings.weekCommencing]),
            Strings.mondayAmName1: bedRota[Strings.mondayAmName1],
            Strings.mondayAmFrom1: bedRota[Strings.mondayAmFrom1],
            Strings.mondayAmTo1: bedRota[Strings.mondayAmTo1],
            Strings.mondayPmName1: bedRota[Strings.mondayPmName1],
            Strings.mondayPmFrom1: bedRota[Strings.mondayPmFrom1],
            Strings.mondayPmTo1: bedRota[Strings.mondayPmTo1],
            Strings.mondayNightName1: bedRota[Strings.mondayNightName1],
            Strings.mondayNightFrom1: bedRota[Strings.mondayNightFrom1],
            Strings.mondayNightTo1: bedRota[Strings.mondayNightTo1],
            Strings.mondayAmName2: bedRota[Strings.mondayAmName2],
            Strings.mondayAmFrom2: bedRota[Strings.mondayAmFrom2],
            Strings.mondayAmTo2: bedRota[Strings.mondayAmTo2],
            Strings.mondayPmName2: bedRota[Strings.mondayPmName2],
            Strings.mondayPmFrom2: bedRota[Strings.mondayPmFrom2],
            Strings.mondayPmTo2: bedRota[Strings.mondayPmTo2],
            Strings.mondayNightName2: bedRota[Strings.mondayNightName2],
            Strings.mondayNightFrom2: bedRota[Strings.mondayNightFrom2],
            Strings.mondayNightTo2: bedRota[Strings.mondayNightTo2],
            Strings.mondayAmName3: bedRota[Strings.mondayAmName3],
            Strings.mondayAmFrom3: bedRota[Strings.mondayAmFrom3],
            Strings.mondayAmTo3: bedRota[Strings.mondayAmTo3],
            Strings.mondayPmName3: bedRota[Strings.mondayPmName3],
            Strings.mondayPmFrom3: bedRota[Strings.mondayPmFrom3],
            Strings.mondayPmTo3: bedRota[Strings.mondayPmTo3],
            Strings.mondayNightName3: bedRota[Strings.mondayNightName3],
            Strings.mondayNightFrom3: bedRota[Strings.mondayNightFrom3],
            Strings.mondayNightTo3: bedRota[Strings.mondayNightTo3],
            Strings.mondayAmName4: bedRota[Strings.mondayAmName4],
            Strings.mondayAmFrom4: bedRota[Strings.mondayAmFrom4],
            Strings.mondayAmTo4: bedRota[Strings.mondayAmTo4],
            Strings.mondayPmName4: bedRota[Strings.mondayPmName4],
            Strings.mondayPmFrom4: bedRota[Strings.mondayPmFrom4],
            Strings.mondayPmTo4: bedRota[Strings.mondayPmTo4],
            Strings.mondayNightName4: bedRota[Strings.mondayNightName4],
            Strings.mondayNightFrom4: bedRota[Strings.mondayNightFrom4],
            Strings.mondayNightTo4: bedRota[Strings.mondayNightTo4],
            Strings.mondayAmName5: bedRota[Strings.mondayAmName5],
            Strings.mondayAmFrom5: bedRota[Strings.mondayAmFrom5],
            Strings.mondayAmTo5: bedRota[Strings.mondayAmTo5],
            Strings.mondayPmName5: bedRota[Strings.mondayPmName5],
            Strings.mondayPmFrom5: bedRota[Strings.mondayPmFrom5],
            Strings.mondayPmTo5: bedRota[Strings.mondayPmTo5],
            Strings.mondayNightName5: bedRota[Strings.mondayNightName5],
            Strings.mondayNightFrom5: bedRota[Strings.mondayNightFrom5],
            Strings.mondayNightTo5: bedRota[Strings.mondayNightTo5],
            Strings.tuesdayAmName1: bedRota[Strings.tuesdayAmName1],
            Strings.tuesdayAmFrom1: bedRota[Strings.tuesdayAmFrom1],
            Strings.tuesdayAmTo1: bedRota[Strings.tuesdayAmTo1],
            Strings.tuesdayPmName1: bedRota[Strings.tuesdayPmName1],
            Strings.tuesdayPmFrom1: bedRota[Strings.tuesdayPmFrom1],
            Strings.tuesdayPmTo1: bedRota[Strings.tuesdayPmTo1],
            Strings.tuesdayNightName1: bedRota[Strings.tuesdayNightName1],
            Strings.tuesdayNightFrom1: bedRota[Strings.tuesdayNightFrom1],
            Strings.tuesdayNightTo1: bedRota[Strings.tuesdayNightTo1],
            Strings.tuesdayAmName2: bedRota[Strings.tuesdayAmName2],
            Strings.tuesdayAmFrom2: bedRota[Strings.tuesdayAmFrom2],
            Strings.tuesdayAmTo2: bedRota[Strings.tuesdayAmTo2],
            Strings.tuesdayPmName2: bedRota[Strings.tuesdayPmName2],
            Strings.tuesdayPmFrom2: bedRota[Strings.tuesdayPmFrom2],
            Strings.tuesdayPmTo2: bedRota[Strings.tuesdayPmTo2],
            Strings.tuesdayNightName2: bedRota[Strings.tuesdayNightName2],
            Strings.tuesdayNightFrom2: bedRota[Strings.tuesdayNightFrom2],
            Strings.tuesdayNightTo2: bedRota[Strings.tuesdayNightTo2],
            Strings.tuesdayAmName3: bedRota[Strings.tuesdayAmName3],
            Strings.tuesdayAmFrom3: bedRota[Strings.tuesdayAmFrom3],
            Strings.tuesdayAmTo3: bedRota[Strings.tuesdayAmTo3],
            Strings.tuesdayPmName3: bedRota[Strings.tuesdayPmName3],
            Strings.tuesdayPmFrom3: bedRota[Strings.tuesdayPmFrom3],
            Strings.tuesdayPmTo3: bedRota[Strings.tuesdayPmTo3],
            Strings.tuesdayNightName3: bedRota[Strings.tuesdayNightName3],
            Strings.tuesdayNightFrom3: bedRota[Strings.tuesdayNightFrom3],
            Strings.tuesdayNightTo3: bedRota[Strings.tuesdayNightTo3],
            Strings.tuesdayAmName4: bedRota[Strings.tuesdayAmName4],
            Strings.tuesdayAmFrom4: bedRota[Strings.tuesdayAmFrom4],
            Strings.tuesdayAmTo4: bedRota[Strings.tuesdayAmTo4],
            Strings.tuesdayPmName4: bedRota[Strings.tuesdayPmName4],
            Strings.tuesdayPmFrom4: bedRota[Strings.tuesdayPmFrom4],
            Strings.tuesdayPmTo4: bedRota[Strings.tuesdayPmTo4],
            Strings.tuesdayNightName4: bedRota[Strings.tuesdayNightName4],
            Strings.tuesdayNightFrom4: bedRota[Strings.tuesdayNightFrom4],
            Strings.tuesdayNightTo4: bedRota[Strings.tuesdayNightTo4],
            Strings.tuesdayAmName5: bedRota[Strings.tuesdayAmName5],
            Strings.tuesdayAmFrom5: bedRota[Strings.tuesdayAmFrom5],
            Strings.tuesdayAmTo5: bedRota[Strings.tuesdayAmTo5],
            Strings.tuesdayPmName5: bedRota[Strings.tuesdayPmName5],
            Strings.tuesdayPmFrom5: bedRota[Strings.tuesdayPmFrom5],
            Strings.tuesdayPmTo5: bedRota[Strings.tuesdayPmTo5],
            Strings.tuesdayNightName5: bedRota[Strings.tuesdayNightName5],
            Strings.tuesdayNightFrom5: bedRota[Strings.tuesdayNightFrom5],
            Strings.tuesdayNightTo5: bedRota[Strings.tuesdayNightTo5],
            Strings.wednesdayAmName1: bedRota[Strings.wednesdayAmName1],
            Strings.wednesdayAmFrom1: bedRota[Strings.wednesdayAmFrom1],
            Strings.wednesdayAmTo1: bedRota[Strings.wednesdayAmTo1],
            Strings.wednesdayPmName1: bedRota[Strings.wednesdayPmName1],
            Strings.wednesdayPmFrom1: bedRota[Strings.wednesdayPmFrom1],
            Strings.wednesdayPmTo1: bedRota[Strings.wednesdayPmTo1],
            Strings.wednesdayNightName1: bedRota[Strings.wednesdayNightName1],
            Strings.wednesdayNightFrom1: bedRota[Strings.wednesdayNightFrom1],
            Strings.wednesdayNightTo1: bedRota[Strings.wednesdayNightTo1],
            Strings.wednesdayAmName2: bedRota[Strings.wednesdayAmName2],
            Strings.wednesdayAmFrom2: bedRota[Strings.wednesdayAmFrom2],
            Strings.wednesdayAmTo2: bedRota[Strings.wednesdayAmTo2],
            Strings.wednesdayPmName2: bedRota[Strings.wednesdayPmName2],
            Strings.wednesdayPmFrom2: bedRota[Strings.wednesdayPmFrom2],
            Strings.wednesdayPmTo2: bedRota[Strings.wednesdayPmTo2],
            Strings.wednesdayNightName2: bedRota[Strings.wednesdayNightName2],
            Strings.wednesdayNightFrom2: bedRota[Strings.wednesdayNightFrom2],
            Strings.wednesdayNightTo2: bedRota[Strings.wednesdayNightTo2],
            Strings.wednesdayAmName3: bedRota[Strings.wednesdayAmName3],
            Strings.wednesdayAmFrom3: bedRota[Strings.wednesdayAmFrom3],
            Strings.wednesdayAmTo3: bedRota[Strings.wednesdayAmTo3],
            Strings.wednesdayPmName3: bedRota[Strings.wednesdayPmName3],
            Strings.wednesdayPmFrom3: bedRota[Strings.wednesdayPmFrom3],
            Strings.wednesdayPmTo3: bedRota[Strings.wednesdayPmTo3],
            Strings.wednesdayNightName3: bedRota[Strings.wednesdayNightName3],
            Strings.wednesdayNightFrom3: bedRota[Strings.wednesdayNightFrom3],
            Strings.wednesdayNightTo3: bedRota[Strings.wednesdayNightTo3],
            Strings.wednesdayAmName4: bedRota[Strings.wednesdayAmName4],
            Strings.wednesdayAmFrom4: bedRota[Strings.wednesdayAmFrom4],
            Strings.wednesdayAmTo4: bedRota[Strings.wednesdayAmTo4],
            Strings.wednesdayPmName4: bedRota[Strings.wednesdayPmName4],
            Strings.wednesdayPmFrom4: bedRota[Strings.wednesdayPmFrom4],
            Strings.wednesdayPmTo4: bedRota[Strings.wednesdayPmTo4],
            Strings.wednesdayNightName4: bedRota[Strings.wednesdayNightName4],
            Strings.wednesdayNightFrom4: bedRota[Strings.wednesdayNightFrom4],
            Strings.wednesdayNightTo4: bedRota[Strings.wednesdayNightTo4],
            Strings.wednesdayAmName5: bedRota[Strings.wednesdayAmName5],
            Strings.wednesdayAmFrom5: bedRota[Strings.wednesdayAmFrom5],
            Strings.wednesdayAmTo5: bedRota[Strings.wednesdayAmTo5],
            Strings.wednesdayPmName5: bedRota[Strings.wednesdayPmName5],
            Strings.wednesdayPmFrom5: bedRota[Strings.wednesdayPmFrom5],
            Strings.wednesdayPmTo5: bedRota[Strings.wednesdayPmTo5],
            Strings.wednesdayNightName5: bedRota[Strings.wednesdayNightName5],
            Strings.wednesdayNightFrom5: bedRota[Strings.wednesdayNightFrom5],
            Strings.wednesdayNightTo5: bedRota[Strings.wednesdayNightTo5],
            Strings.thursdayAmName1: bedRota[Strings.thursdayAmName1],
            Strings.thursdayAmFrom1: bedRota[Strings.thursdayAmFrom1],
            Strings.thursdayAmTo1: bedRota[Strings.thursdayAmTo1],
            Strings.thursdayPmName1: bedRota[Strings.thursdayPmName1],
            Strings.thursdayPmFrom1: bedRota[Strings.thursdayPmFrom1],
            Strings.thursdayPmTo1: bedRota[Strings.thursdayPmTo1],
            Strings.thursdayNightName1: bedRota[Strings.thursdayNightName1],
            Strings.thursdayNightFrom1: bedRota[Strings.thursdayNightFrom1],
            Strings.thursdayNightTo1: bedRota[Strings.thursdayNightTo1],
            Strings.thursdayAmName2: bedRota[Strings.thursdayAmName2],
            Strings.thursdayAmFrom2: bedRota[Strings.thursdayAmFrom2],
            Strings.thursdayAmTo2: bedRota[Strings.thursdayAmTo2],
            Strings.thursdayPmName2: bedRota[Strings.thursdayPmName2],
            Strings.thursdayPmFrom2: bedRota[Strings.thursdayPmFrom2],
            Strings.thursdayPmTo2: bedRota[Strings.thursdayPmTo2],
            Strings.thursdayNightName2: bedRota[Strings.thursdayNightName2],
            Strings.thursdayNightFrom2: bedRota[Strings.thursdayNightFrom2],
            Strings.thursdayNightTo2: bedRota[Strings.thursdayNightTo2],
            Strings.thursdayAmName3: bedRota[Strings.thursdayAmName3],
            Strings.thursdayAmFrom3: bedRota[Strings.thursdayAmFrom3],
            Strings.thursdayAmTo3: bedRota[Strings.thursdayAmTo3],
            Strings.thursdayPmName3: bedRota[Strings.thursdayPmName3],
            Strings.thursdayPmFrom3: bedRota[Strings.thursdayPmFrom3],
            Strings.thursdayPmTo3: bedRota[Strings.thursdayPmTo3],
            Strings.thursdayNightName3: bedRota[Strings.thursdayNightName3],
            Strings.thursdayNightFrom3: bedRota[Strings.thursdayNightFrom3],
            Strings.thursdayNightTo3: bedRota[Strings.thursdayNightTo3],
            Strings.thursdayAmName4: bedRota[Strings.thursdayAmName4],
            Strings.thursdayAmFrom4: bedRota[Strings.thursdayAmFrom4],
            Strings.thursdayAmTo4: bedRota[Strings.thursdayAmTo4],
            Strings.thursdayPmName4: bedRota[Strings.thursdayPmName4],
            Strings.thursdayPmFrom4: bedRota[Strings.thursdayPmFrom4],
            Strings.thursdayPmTo4: bedRota[Strings.thursdayPmTo4],
            Strings.thursdayNightName4: bedRota[Strings.thursdayNightName4],
            Strings.thursdayNightFrom4: bedRota[Strings.thursdayNightFrom4],
            Strings.thursdayNightTo4: bedRota[Strings.thursdayNightTo4],
            Strings.thursdayAmName5: bedRota[Strings.thursdayAmName5],
            Strings.thursdayAmFrom5: bedRota[Strings.thursdayAmFrom5],
            Strings.thursdayAmTo5: bedRota[Strings.thursdayAmTo5],
            Strings.thursdayPmName5: bedRota[Strings.thursdayPmName5],
            Strings.thursdayPmFrom5: bedRota[Strings.thursdayPmFrom5],
            Strings.thursdayPmTo5: bedRota[Strings.thursdayPmTo5],
            Strings.thursdayNightName5: bedRota[Strings.thursdayNightName5],
            Strings.thursdayNightFrom5: bedRota[Strings.thursdayNightFrom5],
            Strings.thursdayNightTo5: bedRota[Strings.thursdayNightTo5],
            Strings.fridayAmName1: bedRota[Strings.fridayAmName1],
            Strings.fridayAmFrom1: bedRota[Strings.fridayAmFrom1],
            Strings.fridayAmTo1: bedRota[Strings.fridayAmTo1],
            Strings.fridayPmName1: bedRota[Strings.fridayPmName1],
            Strings.fridayPmFrom1: bedRota[Strings.fridayPmFrom1],
            Strings.fridayPmTo1: bedRota[Strings.fridayPmTo1],
            Strings.fridayNightName1: bedRota[Strings.fridayNightName1],
            Strings.fridayNightFrom1: bedRota[Strings.fridayNightFrom1],
            Strings.fridayNightTo1: bedRota[Strings.fridayNightTo1],
            Strings.fridayAmName2: bedRota[Strings.fridayAmName2],
            Strings.fridayAmFrom2: bedRota[Strings.fridayAmFrom2],
            Strings.fridayAmTo2: bedRota[Strings.fridayAmTo2],
            Strings.fridayPmName2: bedRota[Strings.fridayPmName2],
            Strings.fridayPmFrom2: bedRota[Strings.fridayPmFrom2],
            Strings.fridayPmTo2: bedRota[Strings.fridayPmTo2],
            Strings.fridayNightName2: bedRota[Strings.fridayNightName2],
            Strings.fridayNightFrom2: bedRota[Strings.fridayNightFrom2],
            Strings.fridayNightTo2: bedRota[Strings.fridayNightTo2],
            Strings.fridayAmName3: bedRota[Strings.fridayAmName3],
            Strings.fridayAmFrom3: bedRota[Strings.fridayAmFrom3],
            Strings.fridayAmTo3: bedRota[Strings.fridayAmTo3],
            Strings.fridayPmName3: bedRota[Strings.fridayPmName3],
            Strings.fridayPmFrom3: bedRota[Strings.fridayPmFrom3],
            Strings.fridayPmTo3: bedRota[Strings.fridayPmTo3],
            Strings.fridayNightName3: bedRota[Strings.fridayNightName3],
            Strings.fridayNightFrom3: bedRota[Strings.fridayNightFrom3],
            Strings.fridayNightTo3: bedRota[Strings.fridayNightTo3],
            Strings.fridayAmName4: bedRota[Strings.fridayAmName4],
            Strings.fridayAmFrom4: bedRota[Strings.fridayAmFrom4],
            Strings.fridayAmTo4: bedRota[Strings.fridayAmTo4],
            Strings.fridayPmName4: bedRota[Strings.fridayPmName4],
            Strings.fridayPmFrom4: bedRota[Strings.fridayPmFrom4],
            Strings.fridayPmTo4: bedRota[Strings.fridayPmTo4],
            Strings.fridayNightName4: bedRota[Strings.fridayNightName4],
            Strings.fridayNightFrom4: bedRota[Strings.fridayNightFrom4],
            Strings.fridayNightTo4: bedRota[Strings.fridayNightTo4],
            Strings.fridayAmName5: bedRota[Strings.fridayAmName5],
            Strings.fridayAmFrom5: bedRota[Strings.fridayAmFrom5],
            Strings.fridayAmTo5: bedRota[Strings.fridayAmTo5],
            Strings.fridayPmName5: bedRota[Strings.fridayPmName5],
            Strings.fridayPmFrom5: bedRota[Strings.fridayPmFrom5],
            Strings.fridayPmTo5: bedRota[Strings.fridayPmTo5],
            Strings.fridayNightName5: bedRota[Strings.fridayNightName5],
            Strings.fridayNightFrom5: bedRota[Strings.fridayNightFrom5],
            Strings.fridayNightTo5: bedRota[Strings.fridayNightTo5],
            Strings.saturdayAmName1: bedRota[Strings.saturdayAmName1],
            Strings.saturdayAmFrom1: bedRota[Strings.saturdayAmFrom1],
            Strings.saturdayAmTo1: bedRota[Strings.saturdayAmTo1],
            Strings.saturdayPmName1: bedRota[Strings.saturdayPmName1],
            Strings.saturdayPmFrom1: bedRota[Strings.saturdayPmFrom1],
            Strings.saturdayPmTo1: bedRota[Strings.saturdayPmTo1],
            Strings.saturdayNightName1: bedRota[Strings.saturdayNightName1],
            Strings.saturdayNightFrom1: bedRota[Strings.saturdayNightFrom1],
            Strings.saturdayNightTo1: bedRota[Strings.saturdayNightTo1],
            Strings.saturdayAmName2: bedRota[Strings.saturdayAmName2],
            Strings.saturdayAmFrom2: bedRota[Strings.saturdayAmFrom2],
            Strings.saturdayAmTo2: bedRota[Strings.saturdayAmTo2],
            Strings.saturdayPmName2: bedRota[Strings.saturdayPmName2],
            Strings.saturdayPmFrom2: bedRota[Strings.saturdayPmFrom2],
            Strings.saturdayPmTo2: bedRota[Strings.saturdayPmTo2],
            Strings.saturdayNightName2: bedRota[Strings.saturdayNightName2],
            Strings.saturdayNightFrom2: bedRota[Strings.saturdayNightFrom2],
            Strings.saturdayNightTo2: bedRota[Strings.saturdayNightTo2],
            Strings.saturdayAmName3: bedRota[Strings.saturdayAmName3],
            Strings.saturdayAmFrom3: bedRota[Strings.saturdayAmFrom3],
            Strings.saturdayAmTo3: bedRota[Strings.saturdayAmTo3],
            Strings.saturdayPmName3: bedRota[Strings.saturdayPmName3],
            Strings.saturdayPmFrom3: bedRota[Strings.saturdayPmFrom3],
            Strings.saturdayPmTo3: bedRota[Strings.saturdayPmTo3],
            Strings.saturdayNightName3: bedRota[Strings.saturdayNightName3],
            Strings.saturdayNightFrom3: bedRota[Strings.saturdayNightFrom3],
            Strings.saturdayNightTo3: bedRota[Strings.saturdayNightTo3],
            Strings.saturdayAmName4: bedRota[Strings.saturdayAmName4],
            Strings.saturdayAmFrom4: bedRota[Strings.saturdayAmFrom4],
            Strings.saturdayAmTo4: bedRota[Strings.saturdayAmTo4],
            Strings.saturdayPmName4: bedRota[Strings.saturdayPmName4],
            Strings.saturdayPmFrom4: bedRota[Strings.saturdayPmFrom4],
            Strings.saturdayPmTo4: bedRota[Strings.saturdayPmTo4],
            Strings.saturdayNightName4: bedRota[Strings.saturdayNightName4],
            Strings.saturdayNightFrom4: bedRota[Strings.saturdayNightFrom4],
            Strings.saturdayNightTo4: bedRota[Strings.saturdayNightTo4],
            Strings.saturdayAmName5: bedRota[Strings.saturdayAmName5],
            Strings.saturdayAmFrom5: bedRota[Strings.saturdayAmFrom5],
            Strings.saturdayAmTo5: bedRota[Strings.saturdayAmTo5],
            Strings.saturdayPmName5: bedRota[Strings.saturdayPmName5],
            Strings.saturdayPmFrom5: bedRota[Strings.saturdayPmFrom5],
            Strings.saturdayPmTo5: bedRota[Strings.saturdayPmTo5],
            Strings.saturdayNightName5: bedRota[Strings.saturdayNightName5],
            Strings.saturdayNightFrom5: bedRota[Strings.saturdayNightFrom5],
            Strings.saturdayNightTo5: bedRota[Strings.saturdayNightTo5],
            Strings.sundayAmName1: bedRota[Strings.sundayAmName1],
            Strings.sundayAmFrom1: bedRota[Strings.sundayAmFrom1],
            Strings.sundayAmTo1: bedRota[Strings.sundayAmTo1],
            Strings.sundayPmName1: bedRota[Strings.sundayPmName1],
            Strings.sundayPmFrom1: bedRota[Strings.sundayPmFrom1],
            Strings.sundayPmTo1: bedRota[Strings.sundayPmTo1],
            Strings.sundayNightName1: bedRota[Strings.sundayNightName1],
            Strings.sundayNightFrom1: bedRota[Strings.sundayNightFrom1],
            Strings.sundayNightTo1: bedRota[Strings.sundayNightTo1],
            Strings.sundayAmName2: bedRota[Strings.sundayAmName2],
            Strings.sundayAmFrom2: bedRota[Strings.sundayAmFrom2],
            Strings.sundayAmTo2: bedRota[Strings.sundayAmTo2],
            Strings.sundayPmName2: bedRota[Strings.sundayPmName2],
            Strings.sundayPmFrom2: bedRota[Strings.sundayPmFrom2],
            Strings.sundayPmTo2: bedRota[Strings.sundayPmTo2],
            Strings.sundayNightName2: bedRota[Strings.sundayNightName2],
            Strings.sundayNightFrom2: bedRota[Strings.sundayNightFrom2],
            Strings.sundayNightTo2: bedRota[Strings.sundayNightTo2],
            Strings.sundayAmName3: bedRota[Strings.sundayAmName3],
            Strings.sundayAmFrom3: bedRota[Strings.sundayAmFrom3],
            Strings.sundayAmTo3: bedRota[Strings.sundayAmTo3],
            Strings.sundayPmName3: bedRota[Strings.sundayPmName3],
            Strings.sundayPmFrom3: bedRota[Strings.sundayPmFrom3],
            Strings.sundayPmTo3: bedRota[Strings.sundayPmTo3],
            Strings.sundayNightName3: bedRota[Strings.sundayNightName3],
            Strings.sundayNightFrom3: bedRota[Strings.sundayNightFrom3],
            Strings.sundayNightTo3: bedRota[Strings.sundayNightTo3],
            Strings.sundayAmName4: bedRota[Strings.sundayAmName4],
            Strings.sundayAmFrom4: bedRota[Strings.sundayAmFrom4],
            Strings.sundayAmTo4: bedRota[Strings.sundayAmTo4],
            Strings.sundayPmName4: bedRota[Strings.sundayPmName4],
            Strings.sundayPmFrom4: bedRota[Strings.sundayPmFrom4],
            Strings.sundayPmTo4: bedRota[Strings.sundayPmTo4],
            Strings.sundayNightName4: bedRota[Strings.sundayNightName4],
            Strings.sundayNightFrom4: bedRota[Strings.sundayNightFrom4],
            Strings.sundayNightTo4: bedRota[Strings.sundayNightTo4],
            Strings.sundayAmName5: bedRota[Strings.sundayAmName5],
            Strings.sundayAmFrom5: bedRota[Strings.sundayAmFrom5],
            Strings.sundayAmTo5: bedRota[Strings.sundayAmTo5],
            Strings.sundayPmName5: bedRota[Strings.sundayPmName5],
            Strings.sundayPmFrom5: bedRota[Strings.sundayPmFrom5],
            Strings.sundayPmTo5: bedRota[Strings.sundayPmTo5],
            Strings.sundayNightName5: bedRota[Strings.sundayNightName5],
            Strings.sundayNightFrom5: bedRota[Strings.sundayNightFrom5],
            Strings.sundayNightTo5: bedRota[Strings.sundayNightTo5],
            Strings.timestamp: FieldValue.serverTimestamp(),
            Strings.serverUploaded: 1,
          });

          //Sembast
          await _bedRotasStore.record(id).delete(await _db);
          if(saved){
            deleteSavedRecord(savedId);
          }
          message = 'Bed Watch Rota uploaded successfully';
          success = true;


        } on TimeoutException catch (_) {
          // A timeout occurred.
          message = 'Network Timeout communicating with the server, unable to upload Bed Watch Rota';

        } catch (e) {
          print(e);
          message = e.toString();

          print(e);
        }
      }

    } else {

      message = 'No data connection, Bed Watch Rota has been saved locally, please upload when you have a valid connection';
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

  Future<bool> editBedRota(String jobId, [bool edit = false]) async {

    GlobalFunctions.showLoadingDialog('Editing Bed Watch Rota...');
    String message = '';
    bool success = false;

    Map<String, dynamic> bedRota = await getTemporaryRecord(true, jobId, false, 0);

    //Map<String, dynamic> bedRota = await _databaseHelper.getTemporaryBedRota(true, user.uid, jobId);

    bool hasDataConnection = await GlobalFunctions.hasDataConnection();


    if(hasDataConnection){

      bool isTokenExpired = GlobalFunctions.isTokenExpired();
      bool authenticated = true;

      if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

      if(authenticated){


        try {

          await FirebaseFirestore.instance.collection('bed_rotas').doc(bedRota[Strings.documentId]).update({
            Strings.jobId: '1',
            Strings.formVersion: '1',
            Strings.jobRef: GlobalFunctions.databaseValueString(bedRota[Strings.jobRefRef]) + GlobalFunctions.databaseValueString(bedRota[Strings.jobRefNo]),
            Strings.jobRefLowercase: GlobalFunctions.databaseValueString(bedRota[Strings.jobRefRef]).toLowerCase() + GlobalFunctions.databaseValueString(bedRota[Strings.jobRefNo]).toLowerCase(),
            Strings.jobRefRef: GlobalFunctions.databaseValueString(bedRota[Strings.jobRefRef]),
            Strings.jobRefNo:  int.parse(bedRota[Strings.jobRefNo]),
            Strings.weekCommencing: bedRota[Strings.weekCommencing] == null ? null : DateTime.parse(bedRota[Strings.weekCommencing]),
            Strings.mondayAmName1: bedRota[Strings.mondayAmName1],
            Strings.mondayAmFrom1: bedRota[Strings.mondayAmFrom1],
            Strings.mondayAmTo1: bedRota[Strings.mondayAmTo1],
            Strings.mondayPmName1: bedRota[Strings.mondayPmName1],
            Strings.mondayPmFrom1: bedRota[Strings.mondayPmFrom1],
            Strings.mondayPmTo1: bedRota[Strings.mondayPmTo1],
            Strings.mondayNightName1: bedRota[Strings.mondayNightName1],
            Strings.mondayNightFrom1: bedRota[Strings.mondayNightFrom1],
            Strings.mondayNightTo1: bedRota[Strings.mondayNightTo1],
            Strings.mondayAmName2: bedRota[Strings.mondayAmName2],
            Strings.mondayAmFrom2: bedRota[Strings.mondayAmFrom2],
            Strings.mondayAmTo2: bedRota[Strings.mondayAmTo2],
            Strings.mondayPmName2: bedRota[Strings.mondayPmName2],
            Strings.mondayPmFrom2: bedRota[Strings.mondayPmFrom2],
            Strings.mondayPmTo2: bedRota[Strings.mondayPmTo2],
            Strings.mondayNightName2: bedRota[Strings.mondayNightName2],
            Strings.mondayNightFrom2: bedRota[Strings.mondayNightFrom2],
            Strings.mondayNightTo2: bedRota[Strings.mondayNightTo2],
            Strings.mondayAmName3: bedRota[Strings.mondayAmName3],
            Strings.mondayAmFrom3: bedRota[Strings.mondayAmFrom3],
            Strings.mondayAmTo3: bedRota[Strings.mondayAmTo3],
            Strings.mondayPmName3: bedRota[Strings.mondayPmName3],
            Strings.mondayPmFrom3: bedRota[Strings.mondayPmFrom3],
            Strings.mondayPmTo3: bedRota[Strings.mondayPmTo3],
            Strings.mondayNightName3: bedRota[Strings.mondayNightName3],
            Strings.mondayNightFrom3: bedRota[Strings.mondayNightFrom3],
            Strings.mondayNightTo3: bedRota[Strings.mondayNightTo3],
            Strings.mondayAmName4: bedRota[Strings.mondayAmName4],
            Strings.mondayAmFrom4: bedRota[Strings.mondayAmFrom4],
            Strings.mondayAmTo4: bedRota[Strings.mondayAmTo4],
            Strings.mondayPmName4: bedRota[Strings.mondayPmName4],
            Strings.mondayPmFrom4: bedRota[Strings.mondayPmFrom4],
            Strings.mondayPmTo4: bedRota[Strings.mondayPmTo4],
            Strings.mondayNightName4: bedRota[Strings.mondayNightName4],
            Strings.mondayNightFrom4: bedRota[Strings.mondayNightFrom4],
            Strings.mondayNightTo4: bedRota[Strings.mondayNightTo4],
            Strings.mondayAmName5: bedRota[Strings.mondayAmName5],
            Strings.mondayAmFrom5: bedRota[Strings.mondayAmFrom5],
            Strings.mondayAmTo5: bedRota[Strings.mondayAmTo5],
            Strings.mondayPmName5: bedRota[Strings.mondayPmName5],
            Strings.mondayPmFrom5: bedRota[Strings.mondayPmFrom5],
            Strings.mondayPmTo5: bedRota[Strings.mondayPmTo5],
            Strings.mondayNightName5: bedRota[Strings.mondayNightName5],
            Strings.mondayNightFrom5: bedRota[Strings.mondayNightFrom5],
            Strings.mondayNightTo5: bedRota[Strings.mondayNightTo5],
            Strings.tuesdayAmName1: bedRota[Strings.tuesdayAmName1],
            Strings.tuesdayAmFrom1: bedRota[Strings.tuesdayAmFrom1],
            Strings.tuesdayAmTo1: bedRota[Strings.tuesdayAmTo1],
            Strings.tuesdayPmName1: bedRota[Strings.tuesdayPmName1],
            Strings.tuesdayPmFrom1: bedRota[Strings.tuesdayPmFrom1],
            Strings.tuesdayPmTo1: bedRota[Strings.tuesdayPmTo1],
            Strings.tuesdayNightName1: bedRota[Strings.tuesdayNightName1],
            Strings.tuesdayNightFrom1: bedRota[Strings.tuesdayNightFrom1],
            Strings.tuesdayNightTo1: bedRota[Strings.tuesdayNightTo1],
            Strings.tuesdayAmName2: bedRota[Strings.tuesdayAmName2],
            Strings.tuesdayAmFrom2: bedRota[Strings.tuesdayAmFrom2],
            Strings.tuesdayAmTo2: bedRota[Strings.tuesdayAmTo2],
            Strings.tuesdayPmName2: bedRota[Strings.tuesdayPmName2],
            Strings.tuesdayPmFrom2: bedRota[Strings.tuesdayPmFrom2],
            Strings.tuesdayPmTo2: bedRota[Strings.tuesdayPmTo2],
            Strings.tuesdayNightName2: bedRota[Strings.tuesdayNightName2],
            Strings.tuesdayNightFrom2: bedRota[Strings.tuesdayNightFrom2],
            Strings.tuesdayNightTo2: bedRota[Strings.tuesdayNightTo2],
            Strings.tuesdayAmName3: bedRota[Strings.tuesdayAmName3],
            Strings.tuesdayAmFrom3: bedRota[Strings.tuesdayAmFrom3],
            Strings.tuesdayAmTo3: bedRota[Strings.tuesdayAmTo3],
            Strings.tuesdayPmName3: bedRota[Strings.tuesdayPmName3],
            Strings.tuesdayPmFrom3: bedRota[Strings.tuesdayPmFrom3],
            Strings.tuesdayPmTo3: bedRota[Strings.tuesdayPmTo3],
            Strings.tuesdayNightName3: bedRota[Strings.tuesdayNightName3],
            Strings.tuesdayNightFrom3: bedRota[Strings.tuesdayNightFrom3],
            Strings.tuesdayNightTo3: bedRota[Strings.tuesdayNightTo3],
            Strings.tuesdayAmName4: bedRota[Strings.tuesdayAmName4],
            Strings.tuesdayAmFrom4: bedRota[Strings.tuesdayAmFrom4],
            Strings.tuesdayAmTo4: bedRota[Strings.tuesdayAmTo4],
            Strings.tuesdayPmName4: bedRota[Strings.tuesdayPmName4],
            Strings.tuesdayPmFrom4: bedRota[Strings.tuesdayPmFrom4],
            Strings.tuesdayPmTo4: bedRota[Strings.tuesdayPmTo4],
            Strings.tuesdayNightName4: bedRota[Strings.tuesdayNightName4],
            Strings.tuesdayNightFrom4: bedRota[Strings.tuesdayNightFrom4],
            Strings.tuesdayNightTo4: bedRota[Strings.tuesdayNightTo4],
            Strings.tuesdayAmName5: bedRota[Strings.tuesdayAmName5],
            Strings.tuesdayAmFrom5: bedRota[Strings.tuesdayAmFrom5],
            Strings.tuesdayAmTo5: bedRota[Strings.tuesdayAmTo5],
            Strings.tuesdayPmName5: bedRota[Strings.tuesdayPmName5],
            Strings.tuesdayPmFrom5: bedRota[Strings.tuesdayPmFrom5],
            Strings.tuesdayPmTo5: bedRota[Strings.tuesdayPmTo5],
            Strings.tuesdayNightName5: bedRota[Strings.tuesdayNightName5],
            Strings.tuesdayNightFrom5: bedRota[Strings.tuesdayNightFrom5],
            Strings.tuesdayNightTo5: bedRota[Strings.tuesdayNightTo5],
            Strings.wednesdayAmName1: bedRota[Strings.wednesdayAmName1],
            Strings.wednesdayAmFrom1: bedRota[Strings.wednesdayAmFrom1],
            Strings.wednesdayAmTo1: bedRota[Strings.wednesdayAmTo1],
            Strings.wednesdayPmName1: bedRota[Strings.wednesdayPmName1],
            Strings.wednesdayPmFrom1: bedRota[Strings.wednesdayPmFrom1],
            Strings.wednesdayPmTo1: bedRota[Strings.wednesdayPmTo1],
            Strings.wednesdayNightName1: bedRota[Strings.wednesdayNightName1],
            Strings.wednesdayNightFrom1: bedRota[Strings.wednesdayNightFrom1],
            Strings.wednesdayNightTo1: bedRota[Strings.wednesdayNightTo1],
            Strings.wednesdayAmName2: bedRota[Strings.wednesdayAmName2],
            Strings.wednesdayAmFrom2: bedRota[Strings.wednesdayAmFrom2],
            Strings.wednesdayAmTo2: bedRota[Strings.wednesdayAmTo2],
            Strings.wednesdayPmName2: bedRota[Strings.wednesdayPmName2],
            Strings.wednesdayPmFrom2: bedRota[Strings.wednesdayPmFrom2],
            Strings.wednesdayPmTo2: bedRota[Strings.wednesdayPmTo2],
            Strings.wednesdayNightName2: bedRota[Strings.wednesdayNightName2],
            Strings.wednesdayNightFrom2: bedRota[Strings.wednesdayNightFrom2],
            Strings.wednesdayNightTo2: bedRota[Strings.wednesdayNightTo2],
            Strings.wednesdayAmName3: bedRota[Strings.wednesdayAmName3],
            Strings.wednesdayAmFrom3: bedRota[Strings.wednesdayAmFrom3],
            Strings.wednesdayAmTo3: bedRota[Strings.wednesdayAmTo3],
            Strings.wednesdayPmName3: bedRota[Strings.wednesdayPmName3],
            Strings.wednesdayPmFrom3: bedRota[Strings.wednesdayPmFrom3],
            Strings.wednesdayPmTo3: bedRota[Strings.wednesdayPmTo3],
            Strings.wednesdayNightName3: bedRota[Strings.wednesdayNightName3],
            Strings.wednesdayNightFrom3: bedRota[Strings.wednesdayNightFrom3],
            Strings.wednesdayNightTo3: bedRota[Strings.wednesdayNightTo3],
            Strings.wednesdayAmName4: bedRota[Strings.wednesdayAmName4],
            Strings.wednesdayAmFrom4: bedRota[Strings.wednesdayAmFrom4],
            Strings.wednesdayAmTo4: bedRota[Strings.wednesdayAmTo4],
            Strings.wednesdayPmName4: bedRota[Strings.wednesdayPmName4],
            Strings.wednesdayPmFrom4: bedRota[Strings.wednesdayPmFrom4],
            Strings.wednesdayPmTo4: bedRota[Strings.wednesdayPmTo4],
            Strings.wednesdayNightName4: bedRota[Strings.wednesdayNightName4],
            Strings.wednesdayNightFrom4: bedRota[Strings.wednesdayNightFrom4],
            Strings.wednesdayNightTo4: bedRota[Strings.wednesdayNightTo4],
            Strings.wednesdayAmName5: bedRota[Strings.wednesdayAmName5],
            Strings.wednesdayAmFrom5: bedRota[Strings.wednesdayAmFrom5],
            Strings.wednesdayAmTo5: bedRota[Strings.wednesdayAmTo5],
            Strings.wednesdayPmName5: bedRota[Strings.wednesdayPmName5],
            Strings.wednesdayPmFrom5: bedRota[Strings.wednesdayPmFrom5],
            Strings.wednesdayPmTo5: bedRota[Strings.wednesdayPmTo5],
            Strings.wednesdayNightName5: bedRota[Strings.wednesdayNightName5],
            Strings.wednesdayNightFrom5: bedRota[Strings.wednesdayNightFrom5],
            Strings.wednesdayNightTo5: bedRota[Strings.wednesdayNightTo5],
            Strings.thursdayAmName1: bedRota[Strings.thursdayAmName1],
            Strings.thursdayAmFrom1: bedRota[Strings.thursdayAmFrom1],
            Strings.thursdayAmTo1: bedRota[Strings.thursdayAmTo1],
            Strings.thursdayPmName1: bedRota[Strings.thursdayPmName1],
            Strings.thursdayPmFrom1: bedRota[Strings.thursdayPmFrom1],
            Strings.thursdayPmTo1: bedRota[Strings.thursdayPmTo1],
            Strings.thursdayNightName1: bedRota[Strings.thursdayNightName1],
            Strings.thursdayNightFrom1: bedRota[Strings.thursdayNightFrom1],
            Strings.thursdayNightTo1: bedRota[Strings.thursdayNightTo1],
            Strings.thursdayAmName2: bedRota[Strings.thursdayAmName2],
            Strings.thursdayAmFrom2: bedRota[Strings.thursdayAmFrom2],
            Strings.thursdayAmTo2: bedRota[Strings.thursdayAmTo2],
            Strings.thursdayPmName2: bedRota[Strings.thursdayPmName2],
            Strings.thursdayPmFrom2: bedRota[Strings.thursdayPmFrom2],
            Strings.thursdayPmTo2: bedRota[Strings.thursdayPmTo2],
            Strings.thursdayNightName2: bedRota[Strings.thursdayNightName2],
            Strings.thursdayNightFrom2: bedRota[Strings.thursdayNightFrom2],
            Strings.thursdayNightTo2: bedRota[Strings.thursdayNightTo2],
            Strings.thursdayAmName3: bedRota[Strings.thursdayAmName3],
            Strings.thursdayAmFrom3: bedRota[Strings.thursdayAmFrom3],
            Strings.thursdayAmTo3: bedRota[Strings.thursdayAmTo3],
            Strings.thursdayPmName3: bedRota[Strings.thursdayPmName3],
            Strings.thursdayPmFrom3: bedRota[Strings.thursdayPmFrom3],
            Strings.thursdayPmTo3: bedRota[Strings.thursdayPmTo3],
            Strings.thursdayNightName3: bedRota[Strings.thursdayNightName3],
            Strings.thursdayNightFrom3: bedRota[Strings.thursdayNightFrom3],
            Strings.thursdayNightTo3: bedRota[Strings.thursdayNightTo3],
            Strings.thursdayAmName4: bedRota[Strings.thursdayAmName4],
            Strings.thursdayAmFrom4: bedRota[Strings.thursdayAmFrom4],
            Strings.thursdayAmTo4: bedRota[Strings.thursdayAmTo4],
            Strings.thursdayPmName4: bedRota[Strings.thursdayPmName4],
            Strings.thursdayPmFrom4: bedRota[Strings.thursdayPmFrom4],
            Strings.thursdayPmTo4: bedRota[Strings.thursdayPmTo4],
            Strings.thursdayNightName4: bedRota[Strings.thursdayNightName4],
            Strings.thursdayNightFrom4: bedRota[Strings.thursdayNightFrom4],
            Strings.thursdayNightTo4: bedRota[Strings.thursdayNightTo4],
            Strings.thursdayAmName5: bedRota[Strings.thursdayAmName5],
            Strings.thursdayAmFrom5: bedRota[Strings.thursdayAmFrom5],
            Strings.thursdayAmTo5: bedRota[Strings.thursdayAmTo5],
            Strings.thursdayPmName5: bedRota[Strings.thursdayPmName5],
            Strings.thursdayPmFrom5: bedRota[Strings.thursdayPmFrom5],
            Strings.thursdayPmTo5: bedRota[Strings.thursdayPmTo5],
            Strings.thursdayNightName5: bedRota[Strings.thursdayNightName5],
            Strings.thursdayNightFrom5: bedRota[Strings.thursdayNightFrom5],
            Strings.thursdayNightTo5: bedRota[Strings.thursdayNightTo5],
            Strings.fridayAmName1: bedRota[Strings.fridayAmName1],
            Strings.fridayAmFrom1: bedRota[Strings.fridayAmFrom1],
            Strings.fridayAmTo1: bedRota[Strings.fridayAmTo1],
            Strings.fridayPmName1: bedRota[Strings.fridayPmName1],
            Strings.fridayPmFrom1: bedRota[Strings.fridayPmFrom1],
            Strings.fridayPmTo1: bedRota[Strings.fridayPmTo1],
            Strings.fridayNightName1: bedRota[Strings.fridayNightName1],
            Strings.fridayNightFrom1: bedRota[Strings.fridayNightFrom1],
            Strings.fridayNightTo1: bedRota[Strings.fridayNightTo1],
            Strings.fridayAmName2: bedRota[Strings.fridayAmName2],
            Strings.fridayAmFrom2: bedRota[Strings.fridayAmFrom2],
            Strings.fridayAmTo2: bedRota[Strings.fridayAmTo2],
            Strings.fridayPmName2: bedRota[Strings.fridayPmName2],
            Strings.fridayPmFrom2: bedRota[Strings.fridayPmFrom2],
            Strings.fridayPmTo2: bedRota[Strings.fridayPmTo2],
            Strings.fridayNightName2: bedRota[Strings.fridayNightName2],
            Strings.fridayNightFrom2: bedRota[Strings.fridayNightFrom2],
            Strings.fridayNightTo2: bedRota[Strings.fridayNightTo2],
            Strings.fridayAmName3: bedRota[Strings.fridayAmName3],
            Strings.fridayAmFrom3: bedRota[Strings.fridayAmFrom3],
            Strings.fridayAmTo3: bedRota[Strings.fridayAmTo3],
            Strings.fridayPmName3: bedRota[Strings.fridayPmName3],
            Strings.fridayPmFrom3: bedRota[Strings.fridayPmFrom3],
            Strings.fridayPmTo3: bedRota[Strings.fridayPmTo3],
            Strings.fridayNightName3: bedRota[Strings.fridayNightName3],
            Strings.fridayNightFrom3: bedRota[Strings.fridayNightFrom3],
            Strings.fridayNightTo3: bedRota[Strings.fridayNightTo3],
            Strings.fridayAmName4: bedRota[Strings.fridayAmName4],
            Strings.fridayAmFrom4: bedRota[Strings.fridayAmFrom4],
            Strings.fridayAmTo4: bedRota[Strings.fridayAmTo4],
            Strings.fridayPmName4: bedRota[Strings.fridayPmName4],
            Strings.fridayPmFrom4: bedRota[Strings.fridayPmFrom4],
            Strings.fridayPmTo4: bedRota[Strings.fridayPmTo4],
            Strings.fridayNightName4: bedRota[Strings.fridayNightName4],
            Strings.fridayNightFrom4: bedRota[Strings.fridayNightFrom4],
            Strings.fridayNightTo4: bedRota[Strings.fridayNightTo4],
            Strings.fridayAmName5: bedRota[Strings.fridayAmName5],
            Strings.fridayAmFrom5: bedRota[Strings.fridayAmFrom5],
            Strings.fridayAmTo5: bedRota[Strings.fridayAmTo5],
            Strings.fridayPmName5: bedRota[Strings.fridayPmName5],
            Strings.fridayPmFrom5: bedRota[Strings.fridayPmFrom5],
            Strings.fridayPmTo5: bedRota[Strings.fridayPmTo5],
            Strings.fridayNightName5: bedRota[Strings.fridayNightName5],
            Strings.fridayNightFrom5: bedRota[Strings.fridayNightFrom5],
            Strings.fridayNightTo5: bedRota[Strings.fridayNightTo5],
            Strings.saturdayAmName1: bedRota[Strings.saturdayAmName1],
            Strings.saturdayAmFrom1: bedRota[Strings.saturdayAmFrom1],
            Strings.saturdayAmTo1: bedRota[Strings.saturdayAmTo1],
            Strings.saturdayPmName1: bedRota[Strings.saturdayPmName1],
            Strings.saturdayPmFrom1: bedRota[Strings.saturdayPmFrom1],
            Strings.saturdayPmTo1: bedRota[Strings.saturdayPmTo1],
            Strings.saturdayNightName1: bedRota[Strings.saturdayNightName1],
            Strings.saturdayNightFrom1: bedRota[Strings.saturdayNightFrom1],
            Strings.saturdayNightTo1: bedRota[Strings.saturdayNightTo1],
            Strings.saturdayAmName2: bedRota[Strings.saturdayAmName2],
            Strings.saturdayAmFrom2: bedRota[Strings.saturdayAmFrom2],
            Strings.saturdayAmTo2: bedRota[Strings.saturdayAmTo2],
            Strings.saturdayPmName2: bedRota[Strings.saturdayPmName2],
            Strings.saturdayPmFrom2: bedRota[Strings.saturdayPmFrom2],
            Strings.saturdayPmTo2: bedRota[Strings.saturdayPmTo2],
            Strings.saturdayNightName2: bedRota[Strings.saturdayNightName2],
            Strings.saturdayNightFrom2: bedRota[Strings.saturdayNightFrom2],
            Strings.saturdayNightTo2: bedRota[Strings.saturdayNightTo2],
            Strings.saturdayAmName3: bedRota[Strings.saturdayAmName3],
            Strings.saturdayAmFrom3: bedRota[Strings.saturdayAmFrom3],
            Strings.saturdayAmTo3: bedRota[Strings.saturdayAmTo3],
            Strings.saturdayPmName3: bedRota[Strings.saturdayPmName3],
            Strings.saturdayPmFrom3: bedRota[Strings.saturdayPmFrom3],
            Strings.saturdayPmTo3: bedRota[Strings.saturdayPmTo3],
            Strings.saturdayNightName3: bedRota[Strings.saturdayNightName3],
            Strings.saturdayNightFrom3: bedRota[Strings.saturdayNightFrom3],
            Strings.saturdayNightTo3: bedRota[Strings.saturdayNightTo3],
            Strings.saturdayAmName4: bedRota[Strings.saturdayAmName4],
            Strings.saturdayAmFrom4: bedRota[Strings.saturdayAmFrom4],
            Strings.saturdayAmTo4: bedRota[Strings.saturdayAmTo4],
            Strings.saturdayPmName4: bedRota[Strings.saturdayPmName4],
            Strings.saturdayPmFrom4: bedRota[Strings.saturdayPmFrom4],
            Strings.saturdayPmTo4: bedRota[Strings.saturdayPmTo4],
            Strings.saturdayNightName4: bedRota[Strings.saturdayNightName4],
            Strings.saturdayNightFrom4: bedRota[Strings.saturdayNightFrom4],
            Strings.saturdayNightTo4: bedRota[Strings.saturdayNightTo4],
            Strings.saturdayAmName5: bedRota[Strings.saturdayAmName5],
            Strings.saturdayAmFrom5: bedRota[Strings.saturdayAmFrom5],
            Strings.saturdayAmTo5: bedRota[Strings.saturdayAmTo5],
            Strings.saturdayPmName5: bedRota[Strings.saturdayPmName5],
            Strings.saturdayPmFrom5: bedRota[Strings.saturdayPmFrom5],
            Strings.saturdayPmTo5: bedRota[Strings.saturdayPmTo5],
            Strings.saturdayNightName5: bedRota[Strings.saturdayNightName5],
            Strings.saturdayNightFrom5: bedRota[Strings.saturdayNightFrom5],
            Strings.saturdayNightTo5: bedRota[Strings.saturdayNightTo5],
            Strings.sundayAmName1: bedRota[Strings.sundayAmName1],
            Strings.sundayAmFrom1: bedRota[Strings.sundayAmFrom1],
            Strings.sundayAmTo1: bedRota[Strings.sundayAmTo1],
            Strings.sundayPmName1: bedRota[Strings.sundayPmName1],
            Strings.sundayPmFrom1: bedRota[Strings.sundayPmFrom1],
            Strings.sundayPmTo1: bedRota[Strings.sundayPmTo1],
            Strings.sundayNightName1: bedRota[Strings.sundayNightName1],
            Strings.sundayNightFrom1: bedRota[Strings.sundayNightFrom1],
            Strings.sundayNightTo1: bedRota[Strings.sundayNightTo1],
            Strings.sundayAmName2: bedRota[Strings.sundayAmName2],
            Strings.sundayAmFrom2: bedRota[Strings.sundayAmFrom2],
            Strings.sundayAmTo2: bedRota[Strings.sundayAmTo2],
            Strings.sundayPmName2: bedRota[Strings.sundayPmName2],
            Strings.sundayPmFrom2: bedRota[Strings.sundayPmFrom2],
            Strings.sundayPmTo2: bedRota[Strings.sundayPmTo2],
            Strings.sundayNightName2: bedRota[Strings.sundayNightName2],
            Strings.sundayNightFrom2: bedRota[Strings.sundayNightFrom2],
            Strings.sundayNightTo2: bedRota[Strings.sundayNightTo2],
            Strings.sundayAmName3: bedRota[Strings.sundayAmName3],
            Strings.sundayAmFrom3: bedRota[Strings.sundayAmFrom3],
            Strings.sundayAmTo3: bedRota[Strings.sundayAmTo3],
            Strings.sundayPmName3: bedRota[Strings.sundayPmName3],
            Strings.sundayPmFrom3: bedRota[Strings.sundayPmFrom3],
            Strings.sundayPmTo3: bedRota[Strings.sundayPmTo3],
            Strings.sundayNightName3: bedRota[Strings.sundayNightName3],
            Strings.sundayNightFrom3: bedRota[Strings.sundayNightFrom3],
            Strings.sundayNightTo3: bedRota[Strings.sundayNightTo3],
            Strings.sundayAmName4: bedRota[Strings.sundayAmName4],
            Strings.sundayAmFrom4: bedRota[Strings.sundayAmFrom4],
            Strings.sundayAmTo4: bedRota[Strings.sundayAmTo4],
            Strings.sundayPmName4: bedRota[Strings.sundayPmName4],
            Strings.sundayPmFrom4: bedRota[Strings.sundayPmFrom4],
            Strings.sundayPmTo4: bedRota[Strings.sundayPmTo4],
            Strings.sundayNightName4: bedRota[Strings.sundayNightName4],
            Strings.sundayNightFrom4: bedRota[Strings.sundayNightFrom4],
            Strings.sundayNightTo4: bedRota[Strings.sundayNightTo4],
            Strings.sundayAmName5: bedRota[Strings.sundayAmName5],
            Strings.sundayAmFrom5: bedRota[Strings.sundayAmFrom5],
            Strings.sundayAmTo5: bedRota[Strings.sundayAmTo5],
            Strings.sundayPmName5: bedRota[Strings.sundayPmName5],
            Strings.sundayPmFrom5: bedRota[Strings.sundayPmFrom5],
            Strings.sundayPmTo5: bedRota[Strings.sundayPmTo5],
            Strings.sundayNightName5: bedRota[Strings.sundayNightName5],
            Strings.sundayNightFrom5: bedRota[Strings.sundayNightFrom5],
            Strings.sundayNightTo5: bedRota[Strings.sundayNightTo5],
            Strings.serverUploaded: 1,
          });

          //Sembast

          final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
              [Db.Filter.equals(Strings.documentId, selectedBedRota[Strings.documentId]), Db.Filter.equals(Strings.jobId, jobId)]
          ));

          await _editedBedRotasStore.delete(await _db,
              finder: finder);
          message = 'Bed Watch Rota uploaded successfully';
          success = true;
          getBedRotas();

        } on TimeoutException catch (_) {
          // A timeout occurred.
          message = 'Network Timeout communicating with the server, unable to edit Bed Watch Rota';
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
      //deleteEditedBedRota();
    }
    GlobalFunctions.showToast(message);
    return success;


  }


  Future<void> getBedRotas() async{

    _isLoading = true;
    notifyListeners();
    String message = '';

    List<Map<String, dynamic>> _fetchedBedRotaList = [];

    try {

      bool hasDataConnection = await GlobalFunctions.hasDataConnection();

      if(!hasDataConnection){

        GlobalFunctions.showToast('No data connection, unable to fetch Bed Watch Rotas');
        _bedRotas = [];

      } else {


        bool isTokenExpired = GlobalFunctions.isTokenExpired();
        bool authenticated = true;

        if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

        if(authenticated){


          QuerySnapshot snapshot;

          if(user.role == 'Super User'){
            try{
              snapshot = await FirebaseFirestore.instance.collection('bed_rotas').orderBy('job_ref_no', descending: true).limit(10).get().timeout(Duration(seconds: 90));
            } catch(e){
              print(e);
            }
          } else {
            try{
              snapshot = await FirebaseFirestore.instance.collection('bed_rotas').where(
                  'uid', isEqualTo: user.uid).orderBy('job_ref_no', descending: true).limit(10).get().timeout(Duration(seconds: 90));
            } catch(e){
              print(e);
            }
          }





          Map<String, dynamic> snapshotData = {};

          if(snapshot.docs.length < 1){
            message = 'No Bed Watch Rotas found';
          } else {
            for (DocumentSnapshot snap in snapshot.docs) {

              snapshotData = snap.data();

              final Map<String, dynamic> bedRota = onlineBedRota(snapshotData, snap.id);

              _fetchedBedRotaList.add(bedRota);

            }

            _bedRotas = _fetchedBedRotaList;
          }


        }

      }


    } on TimeoutException catch (_) {
      // A timeout occurred.
      message = 'Network Timeout communicating with the server, unable to fetch latest Bed Watch Rotas';
    } catch(e){
      print(e);
      message = 'Something went wrong. Please try again';

    }

    _isLoading = false;
    notifyListeners();
    _selBedRotaId = null;
    if(message != '') GlobalFunctions.showToast(message);

  }

  Future<void> getMoreBedRotas() async{

    String message = '';

    List<Map<String, dynamic>> _fetchedBedRotaList = [];

    try {

      bool hasDataConnection = await GlobalFunctions.hasDataConnection();

      if(!hasDataConnection){

        GlobalFunctions.showToast('No data connection, unable to fetch Bed Watch Rotas');

      } else {


        bool isTokenExpired = GlobalFunctions.isTokenExpired();
        bool authenticated = true;

        if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

        if(authenticated){


          QuerySnapshot snapshot;
          int currentLength = _bedRotas.length;
          int latestNo = int.parse(_bedRotas[currentLength - 1][Strings.jobRefNo]);


          if(user.role == 'Super User'){
            try {
              snapshot = await FirebaseFirestore.instance.collection('bed_rotas').where(Strings.jobRefNo, isLessThan: latestNo).orderBy(
                  'job_ref_no', descending: true).limit(10)
                  .get()
                  .timeout(Duration(seconds: 90));
            } catch(e) {
              print(e);
            }

          } else {
            try {
              snapshot = await FirebaseFirestore.instance.collection('bed_rotas').where(
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
            message = 'No more Bed Watch Rotas found';
          } else {
            for (DocumentSnapshot snap in snapshot.docs) {

              snapshotData = snap.data();

              final Map<String, dynamic> bedRota = onlineBedRota(snapshotData, snap.id);

              _fetchedBedRotaList.add(bedRota);

            }

            _bedRotas.addAll(_fetchedBedRotaList);
          }


        }

      }


    } on TimeoutException catch (_) {
      // A timeout occurred.
      message = 'Network Timeout communicating with the server, unable to fetch latest Bed Watch Rotas';
    } catch(e){
      print(e);
      message = 'Something went wrong. Please try again';

    }

    _isLoading = false;
    notifyListeners();
    _selBedRotaId = null;
    if(message != '') GlobalFunctions.showToast(message);

  }

  Future<bool> searchBedRotas(DateTime dateFrom, DateTime dateTo, String jobRefRef, int jobRefNo, String selectedUser) async{

    _isLoading = true;
    notifyListeners();
    bool success = false;
    String message = '';
    GlobalFunctions.showLoadingDialog('Searching Forms');
    List<Map<String, dynamic>> _fetchedBedRotaList = [];

    try {

      bool hasDataConnection = await GlobalFunctions.hasDataConnection();

      if(!hasDataConnection){

        message = 'No Data Connection, unable to search Bed Watch Rotas';

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
                    await FirebaseFirestore.instance.collection('bed_rotas').where(Strings.uid, isEqualTo: selectedUser).where(Strings.weekCommencing, isGreaterThanOrEqualTo: dateFrom).where(Strings.weekCommencing, isLessThanOrEqualTo: dateTo)
                        .get()
                        .timeout(Duration(seconds: 90));
                  } catch(e){
                    print(e);
                  }
                } else {
                  try{
                    snapshot =
                    await FirebaseFirestore.instance.collection('bed_rotas').where(Strings.weekCommencing, isGreaterThanOrEqualTo: dateFrom).where(Strings.weekCommencing, isLessThanOrEqualTo: dateTo)
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
                    await FirebaseFirestore.instance.collection('bed_rotas').where(Strings.uid, isEqualTo: selectedUser).where(Strings.weekCommencing, isGreaterThanOrEqualTo: dateFrom).where(Strings.weekCommencing, isLessThanOrEqualTo: dateTo)
                        .where(Strings.jobRefRef, isEqualTo: jobRefRef).where(Strings.jobRefNo, isEqualTo: jobRefNo).get()
                        .timeout(Duration(seconds: 90));
                  } catch(e){
                    print(e);
                  }
                } else {
                  try{
                    snapshot =
                    await FirebaseFirestore.instance.collection('bed_rotas').where(Strings.weekCommencing, isGreaterThanOrEqualTo: dateFrom).where(Strings.weekCommencing, isLessThanOrEqualTo: dateTo)
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
                    await FirebaseFirestore.instance.collection('bed_rotas').where(Strings.uid, isEqualTo: selectedUser).where(Strings.weekCommencing, isGreaterThanOrEqualTo: dateFrom).where(Strings.weekCommencing, isLessThanOrEqualTo: dateTo)
                        .where(Strings.jobRefRef, isEqualTo: jobRefRef).get()
                        .timeout(Duration(seconds: 90));
                  } catch(e){
                    print(e);
                  }
                } else {
                  try{
                    snapshot =
                    await FirebaseFirestore.instance.collection('bed_rotas').where(Strings.weekCommencing, isGreaterThanOrEqualTo: dateFrom).where(Strings.weekCommencing, isLessThanOrEqualTo: dateTo)
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
                    await FirebaseFirestore.instance.collection('bed_rotas').where(Strings.uid, isEqualTo: selectedUser).where(Strings.weekCommencing, isGreaterThanOrEqualTo: dateFrom).where(Strings.weekCommencing, isLessThanOrEqualTo: dateTo)
                        .where(Strings.jobRefNo, isEqualTo: jobRefNo).get()
                        .timeout(Duration(seconds: 90));
                  } catch(e){
                    print(e);
                  }
                } else {
                  try{
                    snapshot =
                    await FirebaseFirestore.instance.collection('bed_rotas').where(Strings.weekCommencing, isGreaterThanOrEqualTo: dateFrom).where(Strings.weekCommencing, isLessThanOrEqualTo: dateTo)
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
                    await FirebaseFirestore.instance.collection('bed_rotas').where(Strings.uid, isEqualTo: selectedUser)
                        .get()
                        .timeout(Duration(seconds: 90));
                  } catch(e){
                    print(e);
                  }
                } else {
                  try{
                    snapshot =
                    await FirebaseFirestore.instance.collection('bed_rotas')
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
                    await FirebaseFirestore.instance.collection('bed_rotas').where(Strings.uid, isEqualTo: selectedUser)
                        .where(Strings.jobRefRef, isEqualTo: jobRefRef).where(Strings.jobRefNo, isEqualTo: jobRefNo).get()
                        .timeout(Duration(seconds: 90));
                  } catch(e){
                    print(e);
                  }
                } else {
                  try{
                    snapshot =
                    await FirebaseFirestore.instance.collection('bed_rotas')
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
                    await FirebaseFirestore.instance.collection('bed_rotas').where(Strings.uid, isEqualTo: selectedUser)
                        .where(Strings.jobRefRef, isEqualTo: jobRefRef).get()
                        .timeout(Duration(seconds: 90));
                  } catch(e){
                    print(e);
                  }
                } else {
                  try{
                    snapshot =
                    await FirebaseFirestore.instance.collection('bed_rotas')
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
                    await FirebaseFirestore.instance.collection('bed_rotas').where(Strings.uid, isEqualTo: selectedUser)
                        .where(Strings.jobRefNo, isEqualTo: jobRefNo).get()
                        .timeout(Duration(seconds: 90));
                  } catch(e){
                    print(e);
                  }
                } else {
                  try{
                    snapshot =
                    await FirebaseFirestore.instance.collection('bed_rotas')
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
                  await FirebaseFirestore.instance.collection('bed_rotas').where(Strings.uid, isEqualTo: user.uid).where(Strings.weekCommencing, isGreaterThanOrEqualTo: dateFrom).where(Strings.weekCommencing, isLessThanOrEqualTo: dateTo)
                      .get()
                      .timeout(Duration(seconds: 90));
                } catch(e){
                  print(e);
                }
              } else if(jobRefRef != 'Select One' && jobRefNo != null) {

                try{
                  snapshot =
                  await FirebaseFirestore.instance.collection('bed_rotas').where(Strings.uid, isEqualTo: user.uid).where(Strings.weekCommencing, isGreaterThanOrEqualTo: dateFrom).where(Strings.weekCommencing, isLessThanOrEqualTo: dateTo)
                      .where(Strings.jobRefRef, isEqualTo: jobRefRef).where(Strings.jobRefNo, isEqualTo: jobRefNo)
                      .get()
                      .timeout(Duration(seconds: 90));
                } catch(e){
                  print(e);
                }
              } else if(jobRefRef != 'Select One' && (jobRefNo == null)) {


                try{
                  snapshot =
                  await FirebaseFirestore.instance.collection('bed_rotas').where(Strings.uid, isEqualTo: user.uid).where(Strings.weekCommencing, isGreaterThanOrEqualTo: dateFrom).where(Strings.weekCommencing, isLessThanOrEqualTo: dateTo)
                      .where(Strings.jobRefRef, isEqualTo: jobRefRef)
                      .get()
                      .timeout(Duration(seconds: 90));
                } catch(e){
                  print(e);
                }

              } else if(jobRefRef == 'Select One' && jobRefNo != null) {

                try{
                  snapshot =
                  await FirebaseFirestore.instance.collection('bed_rotas').where(Strings.uid, isEqualTo: user.uid).where(Strings.weekCommencing, isGreaterThanOrEqualTo: dateFrom).where(Strings.weekCommencing, isLessThanOrEqualTo: dateTo)
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
                  await FirebaseFirestore.instance.collection('bed_rotas').where(Strings.uid, isEqualTo: user.uid)
                      .get()
                      .timeout(Duration(seconds: 90));
                } catch(e){
                  print(e);
                }
              } else if(jobRefRef != 'Select One' && jobRefNo != null) {


                try{
                  snapshot =
                  await FirebaseFirestore.instance.collection('bed_rotas').where(Strings.uid, isEqualTo: user.uid)
                      .where(Strings.jobRefRef, isEqualTo: jobRefRef).where(Strings.jobRefNo, isEqualTo: jobRefNo)
                      .get()
                      .timeout(Duration(seconds: 90));
                } catch(e){
                  print(e);
                }

              } else if(jobRefRef != 'Select One' && (jobRefNo == null)) {

                try{
                  snapshot =
                  await FirebaseFirestore.instance.collection('bed_rotas').where(Strings.uid, isEqualTo: user.uid)
                      .where(Strings.jobRefRef, isEqualTo: jobRefRef)
                      .get()
                      .timeout(Duration(seconds: 90));
                } catch(e){
                  print(e);
                }

              } else if(jobRefRef == 'Select One' && jobRefNo != null) {
                try{
                  snapshot =
                  await FirebaseFirestore.instance.collection('bed_rotas').where(Strings.uid, isEqualTo: user.uid)
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
            message = 'No Bed Watch Rotas found';
          } else {
            List<QueryDocumentSnapshot> snapDocs = snapshot.docs;
            snapDocs.sort((a, b) => (b.get('job_ref_no')).compareTo(a.get('job_ref_no')));

            for (DocumentSnapshot snap in snapDocs) {

              snapshotData = snap.data();

              final Map<String, dynamic> bedRota = onlineBedRota(snapshotData, snap.id);

              _fetchedBedRotaList.add(bedRota);

            }

            _bedRotas = _fetchedBedRotaList;
            success = true;
          }


        }

      }


    } on TimeoutException catch (_) {
      // A timeout occurred.
      message = 'Network Timeout communicating with the server, unable to search Bed Watch Rotas';
    } catch(e){
      print(e);
      message = 'Something went wrong. Please try again';

    }

    _isLoading = false;
    notifyListeners();
    _selBedRotaId = null;
    GlobalFunctions.dismissLoadingDialog();
    if(message != '') GlobalFunctions.showToast(message);
    return success;

  }


  Map<String, dynamic> localBedRota(Map<String, dynamic> localRecord){
    return {
      Strings.documentId: GlobalFunctions.databaseValueString(localRecord[Strings.documentId]),
      Strings.uid: GlobalFunctions.databaseValueString(localRecord[Strings.uid]),
      Strings.jobId: localRecord[Strings.jobId],
      Strings.formVersion: localRecord[Strings.formVersion],
      Strings.jobRef: localRecord[Strings.jobRef],
      Strings.jobRefRef: localRecord[Strings.jobRefRef],
      Strings.jobRefNo: localRecord[Strings.jobRefNo],
      Strings.weekCommencing: localRecord[Strings.weekCommencing],
      Strings.mondayAmName1: localRecord[Strings.mondayAmName1],
      Strings.mondayAmFrom1: localRecord[Strings.mondayAmFrom1],
      Strings.mondayAmTo1: localRecord[Strings.mondayAmTo1],
      Strings.mondayPmName1: localRecord[Strings.mondayPmName1],
      Strings.mondayPmFrom1: localRecord[Strings.mondayPmFrom1],
      Strings.mondayPmTo1: localRecord[Strings.mondayPmTo1],
      Strings.mondayNightName1: localRecord[Strings.mondayNightName1],
      Strings.mondayNightFrom1: localRecord[Strings.mondayNightFrom1],
      Strings.mondayNightTo1: localRecord[Strings.mondayNightTo1],
      Strings.mondayAmName2: localRecord[Strings.mondayAmName2],
      Strings.mondayAmFrom2: localRecord[Strings.mondayAmFrom2],
      Strings.mondayAmTo2: localRecord[Strings.mondayAmTo2],
      Strings.mondayPmName2: localRecord[Strings.mondayPmName2],
      Strings.mondayPmFrom2: localRecord[Strings.mondayPmFrom2],
      Strings.mondayPmTo2: localRecord[Strings.mondayPmTo2],
      Strings.mondayNightName2: localRecord[Strings.mondayNightName2],
      Strings.mondayNightFrom2: localRecord[Strings.mondayNightFrom2],
      Strings.mondayNightTo2: localRecord[Strings.mondayNightTo2],
      Strings.mondayAmName3: localRecord[Strings.mondayAmName3],
      Strings.mondayAmFrom3: localRecord[Strings.mondayAmFrom3],
      Strings.mondayAmTo3: localRecord[Strings.mondayAmTo3],
      Strings.mondayPmName3: localRecord[Strings.mondayPmName3],
      Strings.mondayPmFrom3: localRecord[Strings.mondayPmFrom3],
      Strings.mondayPmTo3: localRecord[Strings.mondayPmTo3],
      Strings.mondayNightName3: localRecord[Strings.mondayNightName3],
      Strings.mondayNightFrom3: localRecord[Strings.mondayNightFrom3],
      Strings.mondayNightTo3: localRecord[Strings.mondayNightTo3],
      Strings.mondayAmName4: localRecord[Strings.mondayAmName4],
      Strings.mondayAmFrom4: localRecord[Strings.mondayAmFrom4],
      Strings.mondayAmTo4: localRecord[Strings.mondayAmTo4],
      Strings.mondayPmName4: localRecord[Strings.mondayPmName4],
      Strings.mondayPmFrom4: localRecord[Strings.mondayPmFrom4],
      Strings.mondayPmTo4: localRecord[Strings.mondayPmTo4],
      Strings.mondayNightName4: localRecord[Strings.mondayNightName4],
      Strings.mondayNightFrom4: localRecord[Strings.mondayNightFrom4],
      Strings.mondayNightTo4: localRecord[Strings.mondayNightTo4],
      Strings.mondayAmName5: localRecord[Strings.mondayAmName5],
      Strings.mondayAmFrom5: localRecord[Strings.mondayAmFrom5],
      Strings.mondayAmTo5: localRecord[Strings.mondayAmTo5],
      Strings.mondayPmName5: localRecord[Strings.mondayPmName5],
      Strings.mondayPmFrom5: localRecord[Strings.mondayPmFrom5],
      Strings.mondayPmTo5: localRecord[Strings.mondayPmTo5],
      Strings.mondayNightName5: localRecord[Strings.mondayNightName5],
      Strings.mondayNightFrom5: localRecord[Strings.mondayNightFrom5],
      Strings.mondayNightTo5: localRecord[Strings.mondayNightTo5],
      Strings.tuesdayAmName1: localRecord[Strings.tuesdayAmName1],
      Strings.tuesdayAmFrom1: localRecord[Strings.tuesdayAmFrom1],
      Strings.tuesdayAmTo1: localRecord[Strings.tuesdayAmTo1],
      Strings.tuesdayPmName1: localRecord[Strings.tuesdayPmName1],
      Strings.tuesdayPmFrom1: localRecord[Strings.tuesdayPmFrom1],
      Strings.tuesdayPmTo1: localRecord[Strings.tuesdayPmTo1],
      Strings.tuesdayNightName1: localRecord[Strings.tuesdayNightName1],
      Strings.tuesdayNightFrom1: localRecord[Strings.tuesdayNightFrom1],
      Strings.tuesdayNightTo1: localRecord[Strings.tuesdayNightTo1],
      Strings.tuesdayAmName2: localRecord[Strings.tuesdayAmName2],
      Strings.tuesdayAmFrom2: localRecord[Strings.tuesdayAmFrom2],
      Strings.tuesdayAmTo2: localRecord[Strings.tuesdayAmTo2],
      Strings.tuesdayPmName2: localRecord[Strings.tuesdayPmName2],
      Strings.tuesdayPmFrom2: localRecord[Strings.tuesdayPmFrom2],
      Strings.tuesdayPmTo2: localRecord[Strings.tuesdayPmTo2],
      Strings.tuesdayNightName2: localRecord[Strings.tuesdayNightName2],
      Strings.tuesdayNightFrom2: localRecord[Strings.tuesdayNightFrom2],
      Strings.tuesdayNightTo2: localRecord[Strings.tuesdayNightTo2],
      Strings.tuesdayAmName3: localRecord[Strings.tuesdayAmName3],
      Strings.tuesdayAmFrom3: localRecord[Strings.tuesdayAmFrom3],
      Strings.tuesdayAmTo3: localRecord[Strings.tuesdayAmTo3],
      Strings.tuesdayPmName3: localRecord[Strings.tuesdayPmName3],
      Strings.tuesdayPmFrom3: localRecord[Strings.tuesdayPmFrom3],
      Strings.tuesdayPmTo3: localRecord[Strings.tuesdayPmTo3],
      Strings.tuesdayNightName3: localRecord[Strings.tuesdayNightName3],
      Strings.tuesdayNightFrom3: localRecord[Strings.tuesdayNightFrom3],
      Strings.tuesdayNightTo3: localRecord[Strings.tuesdayNightTo3],
      Strings.tuesdayAmName4: localRecord[Strings.tuesdayAmName4],
      Strings.tuesdayAmFrom4: localRecord[Strings.tuesdayAmFrom4],
      Strings.tuesdayAmTo4: localRecord[Strings.tuesdayAmTo4],
      Strings.tuesdayPmName4: localRecord[Strings.tuesdayPmName4],
      Strings.tuesdayPmFrom4: localRecord[Strings.tuesdayPmFrom4],
      Strings.tuesdayPmTo4: localRecord[Strings.tuesdayPmTo4],
      Strings.tuesdayNightName4: localRecord[Strings.tuesdayNightName4],
      Strings.tuesdayNightFrom4: localRecord[Strings.tuesdayNightFrom4],
      Strings.tuesdayNightTo4: localRecord[Strings.tuesdayNightTo4],
      Strings.tuesdayAmName5: localRecord[Strings.tuesdayAmName5],
      Strings.tuesdayAmFrom5: localRecord[Strings.tuesdayAmFrom5],
      Strings.tuesdayAmTo5: localRecord[Strings.tuesdayAmTo5],
      Strings.tuesdayPmName5: localRecord[Strings.tuesdayPmName5],
      Strings.tuesdayPmFrom5: localRecord[Strings.tuesdayPmFrom5],
      Strings.tuesdayPmTo5: localRecord[Strings.tuesdayPmTo5],
      Strings.tuesdayNightName5: localRecord[Strings.tuesdayNightName5],
      Strings.tuesdayNightFrom5: localRecord[Strings.tuesdayNightFrom5],
      Strings.tuesdayNightTo5: localRecord[Strings.tuesdayNightTo5],
      Strings.wednesdayAmName1: localRecord[Strings.wednesdayAmName1],
      Strings.wednesdayAmFrom1: localRecord[Strings.wednesdayAmFrom1],
      Strings.wednesdayAmTo1: localRecord[Strings.wednesdayAmTo1],
      Strings.wednesdayPmName1: localRecord[Strings.wednesdayPmName1],
      Strings.wednesdayPmFrom1: localRecord[Strings.wednesdayPmFrom1],
      Strings.wednesdayPmTo1: localRecord[Strings.wednesdayPmTo1],
      Strings.wednesdayNightName1: localRecord[Strings.wednesdayNightName1],
      Strings.wednesdayNightFrom1: localRecord[Strings.wednesdayNightFrom1],
      Strings.wednesdayNightTo1: localRecord[Strings.wednesdayNightTo1],
      Strings.wednesdayAmName2: localRecord[Strings.wednesdayAmName2],
      Strings.wednesdayAmFrom2: localRecord[Strings.wednesdayAmFrom2],
      Strings.wednesdayAmTo2: localRecord[Strings.wednesdayAmTo2],
      Strings.wednesdayPmName2: localRecord[Strings.wednesdayPmName2],
      Strings.wednesdayPmFrom2: localRecord[Strings.wednesdayPmFrom2],
      Strings.wednesdayPmTo2: localRecord[Strings.wednesdayPmTo2],
      Strings.wednesdayNightName2: localRecord[Strings.wednesdayNightName2],
      Strings.wednesdayNightFrom2: localRecord[Strings.wednesdayNightFrom2],
      Strings.wednesdayNightTo2: localRecord[Strings.wednesdayNightTo2],
      Strings.wednesdayAmName3: localRecord[Strings.wednesdayAmName3],
      Strings.wednesdayAmFrom3: localRecord[Strings.wednesdayAmFrom3],
      Strings.wednesdayAmTo3: localRecord[Strings.wednesdayAmTo3],
      Strings.wednesdayPmName3: localRecord[Strings.wednesdayPmName3],
      Strings.wednesdayPmFrom3: localRecord[Strings.wednesdayPmFrom3],
      Strings.wednesdayPmTo3: localRecord[Strings.wednesdayPmTo3],
      Strings.wednesdayNightName3: localRecord[Strings.wednesdayNightName3],
      Strings.wednesdayNightFrom3: localRecord[Strings.wednesdayNightFrom3],
      Strings.wednesdayNightTo3: localRecord[Strings.wednesdayNightTo3],
      Strings.wednesdayAmName4: localRecord[Strings.wednesdayAmName4],
      Strings.wednesdayAmFrom4: localRecord[Strings.wednesdayAmFrom4],
      Strings.wednesdayAmTo4: localRecord[Strings.wednesdayAmTo4],
      Strings.wednesdayPmName4: localRecord[Strings.wednesdayPmName4],
      Strings.wednesdayPmFrom4: localRecord[Strings.wednesdayPmFrom4],
      Strings.wednesdayPmTo4: localRecord[Strings.wednesdayPmTo4],
      Strings.wednesdayNightName4: localRecord[Strings.wednesdayNightName4],
      Strings.wednesdayNightFrom4: localRecord[Strings.wednesdayNightFrom4],
      Strings.wednesdayNightTo4: localRecord[Strings.wednesdayNightTo4],
      Strings.wednesdayAmName5: localRecord[Strings.wednesdayAmName5],
      Strings.wednesdayAmFrom5: localRecord[Strings.wednesdayAmFrom5],
      Strings.wednesdayAmTo5: localRecord[Strings.wednesdayAmTo5],
      Strings.wednesdayPmName5: localRecord[Strings.wednesdayPmName5],
      Strings.wednesdayPmFrom5: localRecord[Strings.wednesdayPmFrom5],
      Strings.wednesdayPmTo5: localRecord[Strings.wednesdayPmTo5],
      Strings.wednesdayNightName5: localRecord[Strings.wednesdayNightName5],
      Strings.wednesdayNightFrom5: localRecord[Strings.wednesdayNightFrom5],
      Strings.wednesdayNightTo5: localRecord[Strings.wednesdayNightTo5],
      Strings.thursdayAmName1: localRecord[Strings.thursdayAmName1],
      Strings.thursdayAmFrom1: localRecord[Strings.thursdayAmFrom1],
      Strings.thursdayAmTo1: localRecord[Strings.thursdayAmTo1],
      Strings.thursdayPmName1: localRecord[Strings.thursdayPmName1],
      Strings.thursdayPmFrom1: localRecord[Strings.thursdayPmFrom1],
      Strings.thursdayPmTo1: localRecord[Strings.thursdayPmTo1],
      Strings.thursdayNightName1: localRecord[Strings.thursdayNightName1],
      Strings.thursdayNightFrom1: localRecord[Strings.thursdayNightFrom1],
      Strings.thursdayNightTo1: localRecord[Strings.thursdayNightTo1],
      Strings.thursdayAmName2: localRecord[Strings.thursdayAmName2],
      Strings.thursdayAmFrom2: localRecord[Strings.thursdayAmFrom2],
      Strings.thursdayAmTo2: localRecord[Strings.thursdayAmTo2],
      Strings.thursdayPmName2: localRecord[Strings.thursdayPmName2],
      Strings.thursdayPmFrom2: localRecord[Strings.thursdayPmFrom2],
      Strings.thursdayPmTo2: localRecord[Strings.thursdayPmTo2],
      Strings.thursdayNightName2: localRecord[Strings.thursdayNightName2],
      Strings.thursdayNightFrom2: localRecord[Strings.thursdayNightFrom2],
      Strings.thursdayNightTo2: localRecord[Strings.thursdayNightTo2],
      Strings.thursdayAmName3: localRecord[Strings.thursdayAmName3],
      Strings.thursdayAmFrom3: localRecord[Strings.thursdayAmFrom3],
      Strings.thursdayAmTo3: localRecord[Strings.thursdayAmTo3],
      Strings.thursdayPmName3: localRecord[Strings.thursdayPmName3],
      Strings.thursdayPmFrom3: localRecord[Strings.thursdayPmFrom3],
      Strings.thursdayPmTo3: localRecord[Strings.thursdayPmTo3],
      Strings.thursdayNightName3: localRecord[Strings.thursdayNightName3],
      Strings.thursdayNightFrom3: localRecord[Strings.thursdayNightFrom3],
      Strings.thursdayNightTo3: localRecord[Strings.thursdayNightTo3],
      Strings.thursdayAmName4: localRecord[Strings.thursdayAmName4],
      Strings.thursdayAmFrom4: localRecord[Strings.thursdayAmFrom4],
      Strings.thursdayAmTo4: localRecord[Strings.thursdayAmTo4],
      Strings.thursdayPmName4: localRecord[Strings.thursdayPmName4],
      Strings.thursdayPmFrom4: localRecord[Strings.thursdayPmFrom4],
      Strings.thursdayPmTo4: localRecord[Strings.thursdayPmTo4],
      Strings.thursdayNightName4: localRecord[Strings.thursdayNightName4],
      Strings.thursdayNightFrom4: localRecord[Strings.thursdayNightFrom4],
      Strings.thursdayNightTo4: localRecord[Strings.thursdayNightTo4],
      Strings.thursdayAmName5: localRecord[Strings.thursdayAmName5],
      Strings.thursdayAmFrom5: localRecord[Strings.thursdayAmFrom5],
      Strings.thursdayAmTo5: localRecord[Strings.thursdayAmTo5],
      Strings.thursdayPmName5: localRecord[Strings.thursdayPmName5],
      Strings.thursdayPmFrom5: localRecord[Strings.thursdayPmFrom5],
      Strings.thursdayPmTo5: localRecord[Strings.thursdayPmTo5],
      Strings.thursdayNightName5: localRecord[Strings.thursdayNightName5],
      Strings.thursdayNightFrom5: localRecord[Strings.thursdayNightFrom5],
      Strings.thursdayNightTo5: localRecord[Strings.thursdayNightTo5],
      Strings.fridayAmName1: localRecord[Strings.fridayAmName1],
      Strings.fridayAmFrom1: localRecord[Strings.fridayAmFrom1],
      Strings.fridayAmTo1: localRecord[Strings.fridayAmTo1],
      Strings.fridayPmName1: localRecord[Strings.fridayPmName1],
      Strings.fridayPmFrom1: localRecord[Strings.fridayPmFrom1],
      Strings.fridayPmTo1: localRecord[Strings.fridayPmTo1],
      Strings.fridayNightName1: localRecord[Strings.fridayNightName1],
      Strings.fridayNightFrom1: localRecord[Strings.fridayNightFrom1],
      Strings.fridayNightTo1: localRecord[Strings.fridayNightTo1],
      Strings.fridayAmName2: localRecord[Strings.fridayAmName2],
      Strings.fridayAmFrom2: localRecord[Strings.fridayAmFrom2],
      Strings.fridayAmTo2: localRecord[Strings.fridayAmTo2],
      Strings.fridayPmName2: localRecord[Strings.fridayPmName2],
      Strings.fridayPmFrom2: localRecord[Strings.fridayPmFrom2],
      Strings.fridayPmTo2: localRecord[Strings.fridayPmTo2],
      Strings.fridayNightName2: localRecord[Strings.fridayNightName2],
      Strings.fridayNightFrom2: localRecord[Strings.fridayNightFrom2],
      Strings.fridayNightTo2: localRecord[Strings.fridayNightTo2],
      Strings.fridayAmName3: localRecord[Strings.fridayAmName3],
      Strings.fridayAmFrom3: localRecord[Strings.fridayAmFrom3],
      Strings.fridayAmTo3: localRecord[Strings.fridayAmTo3],
      Strings.fridayPmName3: localRecord[Strings.fridayPmName3],
      Strings.fridayPmFrom3: localRecord[Strings.fridayPmFrom3],
      Strings.fridayPmTo3: localRecord[Strings.fridayPmTo3],
      Strings.fridayNightName3: localRecord[Strings.fridayNightName3],
      Strings.fridayNightFrom3: localRecord[Strings.fridayNightFrom3],
      Strings.fridayNightTo3: localRecord[Strings.fridayNightTo3],
      Strings.fridayAmName4: localRecord[Strings.fridayAmName4],
      Strings.fridayAmFrom4: localRecord[Strings.fridayAmFrom4],
      Strings.fridayAmTo4: localRecord[Strings.fridayAmTo4],
      Strings.fridayPmName4: localRecord[Strings.fridayPmName4],
      Strings.fridayPmFrom4: localRecord[Strings.fridayPmFrom4],
      Strings.fridayPmTo4: localRecord[Strings.fridayPmTo4],
      Strings.fridayNightName4: localRecord[Strings.fridayNightName4],
      Strings.fridayNightFrom4: localRecord[Strings.fridayNightFrom4],
      Strings.fridayNightTo4: localRecord[Strings.fridayNightTo4],
      Strings.fridayAmName5: localRecord[Strings.fridayAmName5],
      Strings.fridayAmFrom5: localRecord[Strings.fridayAmFrom5],
      Strings.fridayAmTo5: localRecord[Strings.fridayAmTo5],
      Strings.fridayPmName5: localRecord[Strings.fridayPmName5],
      Strings.fridayPmFrom5: localRecord[Strings.fridayPmFrom5],
      Strings.fridayPmTo5: localRecord[Strings.fridayPmTo5],
      Strings.fridayNightName5: localRecord[Strings.fridayNightName5],
      Strings.fridayNightFrom5: localRecord[Strings.fridayNightFrom5],
      Strings.fridayNightTo5: localRecord[Strings.fridayNightTo5],
      Strings.saturdayAmName1: localRecord[Strings.saturdayAmName1],
      Strings.saturdayAmFrom1: localRecord[Strings.saturdayAmFrom1],
      Strings.saturdayAmTo1: localRecord[Strings.saturdayAmTo1],
      Strings.saturdayPmName1: localRecord[Strings.saturdayPmName1],
      Strings.saturdayPmFrom1: localRecord[Strings.saturdayPmFrom1],
      Strings.saturdayPmTo1: localRecord[Strings.saturdayPmTo1],
      Strings.saturdayNightName1: localRecord[Strings.saturdayNightName1],
      Strings.saturdayNightFrom1: localRecord[Strings.saturdayNightFrom1],
      Strings.saturdayNightTo1: localRecord[Strings.saturdayNightTo1],
      Strings.saturdayAmName2: localRecord[Strings.saturdayAmName2],
      Strings.saturdayAmFrom2: localRecord[Strings.saturdayAmFrom2],
      Strings.saturdayAmTo2: localRecord[Strings.saturdayAmTo2],
      Strings.saturdayPmName2: localRecord[Strings.saturdayPmName2],
      Strings.saturdayPmFrom2: localRecord[Strings.saturdayPmFrom2],
      Strings.saturdayPmTo2: localRecord[Strings.saturdayPmTo2],
      Strings.saturdayNightName2: localRecord[Strings.saturdayNightName2],
      Strings.saturdayNightFrom2: localRecord[Strings.saturdayNightFrom2],
      Strings.saturdayNightTo2: localRecord[Strings.saturdayNightTo2],
      Strings.saturdayAmName3: localRecord[Strings.saturdayAmName3],
      Strings.saturdayAmFrom3: localRecord[Strings.saturdayAmFrom3],
      Strings.saturdayAmTo3: localRecord[Strings.saturdayAmTo3],
      Strings.saturdayPmName3: localRecord[Strings.saturdayPmName3],
      Strings.saturdayPmFrom3: localRecord[Strings.saturdayPmFrom3],
      Strings.saturdayPmTo3: localRecord[Strings.saturdayPmTo3],
      Strings.saturdayNightName3: localRecord[Strings.saturdayNightName3],
      Strings.saturdayNightFrom3: localRecord[Strings.saturdayNightFrom3],
      Strings.saturdayNightTo3: localRecord[Strings.saturdayNightTo3],
      Strings.saturdayAmName4: localRecord[Strings.saturdayAmName4],
      Strings.saturdayAmFrom4: localRecord[Strings.saturdayAmFrom4],
      Strings.saturdayAmTo4: localRecord[Strings.saturdayAmTo4],
      Strings.saturdayPmName4: localRecord[Strings.saturdayPmName4],
      Strings.saturdayPmFrom4: localRecord[Strings.saturdayPmFrom4],
      Strings.saturdayPmTo4: localRecord[Strings.saturdayPmTo4],
      Strings.saturdayNightName4: localRecord[Strings.saturdayNightName4],
      Strings.saturdayNightFrom4: localRecord[Strings.saturdayNightFrom4],
      Strings.saturdayNightTo4: localRecord[Strings.saturdayNightTo4],
      Strings.saturdayAmName5: localRecord[Strings.saturdayAmName5],
      Strings.saturdayAmFrom5: localRecord[Strings.saturdayAmFrom5],
      Strings.saturdayAmTo5: localRecord[Strings.saturdayAmTo5],
      Strings.saturdayPmName5: localRecord[Strings.saturdayPmName5],
      Strings.saturdayPmFrom5: localRecord[Strings.saturdayPmFrom5],
      Strings.saturdayPmTo5: localRecord[Strings.saturdayPmTo5],
      Strings.saturdayNightName5: localRecord[Strings.saturdayNightName5],
      Strings.saturdayNightFrom5: localRecord[Strings.saturdayNightFrom5],
      Strings.saturdayNightTo5: localRecord[Strings.saturdayNightTo5],
      Strings.sundayAmName1: localRecord[Strings.sundayAmName1],
      Strings.sundayAmFrom1: localRecord[Strings.sundayAmFrom1],
      Strings.sundayAmTo1: localRecord[Strings.sundayAmTo1],
      Strings.sundayPmName1: localRecord[Strings.sundayPmName1],
      Strings.sundayPmFrom1: localRecord[Strings.sundayPmFrom1],
      Strings.sundayPmTo1: localRecord[Strings.sundayPmTo1],
      Strings.sundayNightName1: localRecord[Strings.sundayNightName1],
      Strings.sundayNightFrom1: localRecord[Strings.sundayNightFrom1],
      Strings.sundayNightTo1: localRecord[Strings.sundayNightTo1],
      Strings.sundayAmName2: localRecord[Strings.sundayAmName2],
      Strings.sundayAmFrom2: localRecord[Strings.sundayAmFrom2],
      Strings.sundayAmTo2: localRecord[Strings.sundayAmTo2],
      Strings.sundayPmName2: localRecord[Strings.sundayPmName2],
      Strings.sundayPmFrom2: localRecord[Strings.sundayPmFrom2],
      Strings.sundayPmTo2: localRecord[Strings.sundayPmTo2],
      Strings.sundayNightName2: localRecord[Strings.sundayNightName2],
      Strings.sundayNightFrom2: localRecord[Strings.sundayNightFrom2],
      Strings.sundayNightTo2: localRecord[Strings.sundayNightTo2],
      Strings.sundayAmName3: localRecord[Strings.sundayAmName3],
      Strings.sundayAmFrom3: localRecord[Strings.sundayAmFrom3],
      Strings.sundayAmTo3: localRecord[Strings.sundayAmTo3],
      Strings.sundayPmName3: localRecord[Strings.sundayPmName3],
      Strings.sundayPmFrom3: localRecord[Strings.sundayPmFrom3],
      Strings.sundayPmTo3: localRecord[Strings.sundayPmTo3],
      Strings.sundayNightName3: localRecord[Strings.sundayNightName3],
      Strings.sundayNightFrom3: localRecord[Strings.sundayNightFrom3],
      Strings.sundayNightTo3: localRecord[Strings.sundayNightTo3],
      Strings.sundayAmName4: localRecord[Strings.sundayAmName4],
      Strings.sundayAmFrom4: localRecord[Strings.sundayAmFrom4],
      Strings.sundayAmTo4: localRecord[Strings.sundayAmTo4],
      Strings.sundayPmName4: localRecord[Strings.sundayPmName4],
      Strings.sundayPmFrom4: localRecord[Strings.sundayPmFrom4],
      Strings.sundayPmTo4: localRecord[Strings.sundayPmTo4],
      Strings.sundayNightName4: localRecord[Strings.sundayNightName4],
      Strings.sundayNightFrom4: localRecord[Strings.sundayNightFrom4],
      Strings.sundayNightTo4: localRecord[Strings.sundayNightTo4],
      Strings.sundayAmName5: localRecord[Strings.sundayAmName5],
      Strings.sundayAmFrom5: localRecord[Strings.sundayAmFrom5],
      Strings.sundayAmTo5: localRecord[Strings.sundayAmTo5],
      Strings.sundayPmName5: localRecord[Strings.sundayPmName5],
      Strings.sundayPmFrom5: localRecord[Strings.sundayPmFrom5],
      Strings.sundayPmTo5: localRecord[Strings.sundayPmTo5],
      Strings.sundayNightName5: localRecord[Strings.sundayNightName5],
      Strings.sundayNightFrom5: localRecord[Strings.sundayNightFrom5],
      Strings.sundayNightTo5: localRecord[Strings.sundayNightTo5],
      Strings.serverUploaded: localRecord[Strings.serverUploaded],
      Strings.timestamp: localRecord[Strings.timestamp] == null ? null : localRecord[Strings.timestamp]
    };
  }

  Map<String, dynamic> onlineBedRota(Map<String, dynamic> localRecord, String docId){
    return {
      Strings.documentId: docId,
      Strings.uid: GlobalFunctions.databaseValueString(localRecord[Strings.uid]),
      Strings.jobId: localRecord[Strings.jobId],
      Strings.formVersion: localRecord[Strings.formVersion],
      Strings.jobRef: localRecord[Strings.jobRef],
      Strings.jobRefRef: localRecord[Strings.jobRefRef],
      Strings.jobRefNo: localRecord[Strings.jobRefNo].toString(),
      Strings.weekCommencing: localRecord[Strings.weekCommencing] == null ? null : DateTime
          .fromMillisecondsSinceEpoch(
          localRecord[Strings.weekCommencing].millisecondsSinceEpoch)
          .toIso8601String(),      Strings.obJobTime: localRecord[Strings.obJobTime],
      Strings.mondayAmName1: localRecord[Strings.mondayAmName1],
      Strings.mondayAmFrom1: localRecord[Strings.mondayAmFrom1],
      Strings.mondayAmTo1: localRecord[Strings.mondayAmTo1],
      Strings.mondayPmName1: localRecord[Strings.mondayPmName1],
      Strings.mondayPmFrom1: localRecord[Strings.mondayPmFrom1],
      Strings.mondayPmTo1: localRecord[Strings.mondayPmTo1],
      Strings.mondayNightName1: localRecord[Strings.mondayNightName1],
      Strings.mondayNightFrom1: localRecord[Strings.mondayNightFrom1],
      Strings.mondayNightTo1: localRecord[Strings.mondayNightTo1],
      Strings.mondayAmName2: localRecord[Strings.mondayAmName2],
      Strings.mondayAmFrom2: localRecord[Strings.mondayAmFrom2],
      Strings.mondayAmTo2: localRecord[Strings.mondayAmTo2],
      Strings.mondayPmName2: localRecord[Strings.mondayPmName2],
      Strings.mondayPmFrom2: localRecord[Strings.mondayPmFrom2],
      Strings.mondayPmTo2: localRecord[Strings.mondayPmTo2],
      Strings.mondayNightName2: localRecord[Strings.mondayNightName2],
      Strings.mondayNightFrom2: localRecord[Strings.mondayNightFrom2],
      Strings.mondayNightTo2: localRecord[Strings.mondayNightTo2],
      Strings.mondayAmName3: localRecord[Strings.mondayAmName3],
      Strings.mondayAmFrom3: localRecord[Strings.mondayAmFrom3],
      Strings.mondayAmTo3: localRecord[Strings.mondayAmTo3],
      Strings.mondayPmName3: localRecord[Strings.mondayPmName3],
      Strings.mondayPmFrom3: localRecord[Strings.mondayPmFrom3],
      Strings.mondayPmTo3: localRecord[Strings.mondayPmTo3],
      Strings.mondayNightName3: localRecord[Strings.mondayNightName3],
      Strings.mondayNightFrom3: localRecord[Strings.mondayNightFrom3],
      Strings.mondayNightTo3: localRecord[Strings.mondayNightTo3],
      Strings.mondayAmName4: localRecord[Strings.mondayAmName4],
      Strings.mondayAmFrom4: localRecord[Strings.mondayAmFrom4],
      Strings.mondayAmTo4: localRecord[Strings.mondayAmTo4],
      Strings.mondayPmName4: localRecord[Strings.mondayPmName4],
      Strings.mondayPmFrom4: localRecord[Strings.mondayPmFrom4],
      Strings.mondayPmTo4: localRecord[Strings.mondayPmTo4],
      Strings.mondayNightName4: localRecord[Strings.mondayNightName4],
      Strings.mondayNightFrom4: localRecord[Strings.mondayNightFrom4],
      Strings.mondayNightTo4: localRecord[Strings.mondayNightTo4],
      Strings.mondayAmName5: localRecord[Strings.mondayAmName5],
      Strings.mondayAmFrom5: localRecord[Strings.mondayAmFrom5],
      Strings.mondayAmTo5: localRecord[Strings.mondayAmTo5],
      Strings.mondayPmName5: localRecord[Strings.mondayPmName5],
      Strings.mondayPmFrom5: localRecord[Strings.mondayPmFrom5],
      Strings.mondayPmTo5: localRecord[Strings.mondayPmTo5],
      Strings.mondayNightName5: localRecord[Strings.mondayNightName5],
      Strings.mondayNightFrom5: localRecord[Strings.mondayNightFrom5],
      Strings.mondayNightTo5: localRecord[Strings.mondayNightTo5],
      Strings.tuesdayAmName1: localRecord[Strings.tuesdayAmName1],
      Strings.tuesdayAmFrom1: localRecord[Strings.tuesdayAmFrom1],
      Strings.tuesdayAmTo1: localRecord[Strings.tuesdayAmTo1],
      Strings.tuesdayPmName1: localRecord[Strings.tuesdayPmName1],
      Strings.tuesdayPmFrom1: localRecord[Strings.tuesdayPmFrom1],
      Strings.tuesdayPmTo1: localRecord[Strings.tuesdayPmTo1],
      Strings.tuesdayNightName1: localRecord[Strings.tuesdayNightName1],
      Strings.tuesdayNightFrom1: localRecord[Strings.tuesdayNightFrom1],
      Strings.tuesdayNightTo1: localRecord[Strings.tuesdayNightTo1],
      Strings.tuesdayAmName2: localRecord[Strings.tuesdayAmName2],
      Strings.tuesdayAmFrom2: localRecord[Strings.tuesdayAmFrom2],
      Strings.tuesdayAmTo2: localRecord[Strings.tuesdayAmTo2],
      Strings.tuesdayPmName2: localRecord[Strings.tuesdayPmName2],
      Strings.tuesdayPmFrom2: localRecord[Strings.tuesdayPmFrom2],
      Strings.tuesdayPmTo2: localRecord[Strings.tuesdayPmTo2],
      Strings.tuesdayNightName2: localRecord[Strings.tuesdayNightName2],
      Strings.tuesdayNightFrom2: localRecord[Strings.tuesdayNightFrom2],
      Strings.tuesdayNightTo2: localRecord[Strings.tuesdayNightTo2],
      Strings.tuesdayAmName3: localRecord[Strings.tuesdayAmName3],
      Strings.tuesdayAmFrom3: localRecord[Strings.tuesdayAmFrom3],
      Strings.tuesdayAmTo3: localRecord[Strings.tuesdayAmTo3],
      Strings.tuesdayPmName3: localRecord[Strings.tuesdayPmName3],
      Strings.tuesdayPmFrom3: localRecord[Strings.tuesdayPmFrom3],
      Strings.tuesdayPmTo3: localRecord[Strings.tuesdayPmTo3],
      Strings.tuesdayNightName3: localRecord[Strings.tuesdayNightName3],
      Strings.tuesdayNightFrom3: localRecord[Strings.tuesdayNightFrom3],
      Strings.tuesdayNightTo3: localRecord[Strings.tuesdayNightTo3],
      Strings.tuesdayAmName4: localRecord[Strings.tuesdayAmName4],
      Strings.tuesdayAmFrom4: localRecord[Strings.tuesdayAmFrom4],
      Strings.tuesdayAmTo4: localRecord[Strings.tuesdayAmTo4],
      Strings.tuesdayPmName4: localRecord[Strings.tuesdayPmName4],
      Strings.tuesdayPmFrom4: localRecord[Strings.tuesdayPmFrom4],
      Strings.tuesdayPmTo4: localRecord[Strings.tuesdayPmTo4],
      Strings.tuesdayNightName4: localRecord[Strings.tuesdayNightName4],
      Strings.tuesdayNightFrom4: localRecord[Strings.tuesdayNightFrom4],
      Strings.tuesdayNightTo4: localRecord[Strings.tuesdayNightTo4],
      Strings.tuesdayAmName5: localRecord[Strings.tuesdayAmName5],
      Strings.tuesdayAmFrom5: localRecord[Strings.tuesdayAmFrom5],
      Strings.tuesdayAmTo5: localRecord[Strings.tuesdayAmTo5],
      Strings.tuesdayPmName5: localRecord[Strings.tuesdayPmName5],
      Strings.tuesdayPmFrom5: localRecord[Strings.tuesdayPmFrom5],
      Strings.tuesdayPmTo5: localRecord[Strings.tuesdayPmTo5],
      Strings.tuesdayNightName5: localRecord[Strings.tuesdayNightName5],
      Strings.tuesdayNightFrom5: localRecord[Strings.tuesdayNightFrom5],
      Strings.tuesdayNightTo5: localRecord[Strings.tuesdayNightTo5],
      Strings.wednesdayAmName1: localRecord[Strings.wednesdayAmName1],
      Strings.wednesdayAmFrom1: localRecord[Strings.wednesdayAmFrom1],
      Strings.wednesdayAmTo1: localRecord[Strings.wednesdayAmTo1],
      Strings.wednesdayPmName1: localRecord[Strings.wednesdayPmName1],
      Strings.wednesdayPmFrom1: localRecord[Strings.wednesdayPmFrom1],
      Strings.wednesdayPmTo1: localRecord[Strings.wednesdayPmTo1],
      Strings.wednesdayNightName1: localRecord[Strings.wednesdayNightName1],
      Strings.wednesdayNightFrom1: localRecord[Strings.wednesdayNightFrom1],
      Strings.wednesdayNightTo1: localRecord[Strings.wednesdayNightTo1],
      Strings.wednesdayAmName2: localRecord[Strings.wednesdayAmName2],
      Strings.wednesdayAmFrom2: localRecord[Strings.wednesdayAmFrom2],
      Strings.wednesdayAmTo2: localRecord[Strings.wednesdayAmTo2],
      Strings.wednesdayPmName2: localRecord[Strings.wednesdayPmName2],
      Strings.wednesdayPmFrom2: localRecord[Strings.wednesdayPmFrom2],
      Strings.wednesdayPmTo2: localRecord[Strings.wednesdayPmTo2],
      Strings.wednesdayNightName2: localRecord[Strings.wednesdayNightName2],
      Strings.wednesdayNightFrom2: localRecord[Strings.wednesdayNightFrom2],
      Strings.wednesdayNightTo2: localRecord[Strings.wednesdayNightTo2],
      Strings.wednesdayAmName3: localRecord[Strings.wednesdayAmName3],
      Strings.wednesdayAmFrom3: localRecord[Strings.wednesdayAmFrom3],
      Strings.wednesdayAmTo3: localRecord[Strings.wednesdayAmTo3],
      Strings.wednesdayPmName3: localRecord[Strings.wednesdayPmName3],
      Strings.wednesdayPmFrom3: localRecord[Strings.wednesdayPmFrom3],
      Strings.wednesdayPmTo3: localRecord[Strings.wednesdayPmTo3],
      Strings.wednesdayNightName3: localRecord[Strings.wednesdayNightName3],
      Strings.wednesdayNightFrom3: localRecord[Strings.wednesdayNightFrom3],
      Strings.wednesdayNightTo3: localRecord[Strings.wednesdayNightTo3],
      Strings.wednesdayAmName4: localRecord[Strings.wednesdayAmName4],
      Strings.wednesdayAmFrom4: localRecord[Strings.wednesdayAmFrom4],
      Strings.wednesdayAmTo4: localRecord[Strings.wednesdayAmTo4],
      Strings.wednesdayPmName4: localRecord[Strings.wednesdayPmName4],
      Strings.wednesdayPmFrom4: localRecord[Strings.wednesdayPmFrom4],
      Strings.wednesdayPmTo4: localRecord[Strings.wednesdayPmTo4],
      Strings.wednesdayNightName4: localRecord[Strings.wednesdayNightName4],
      Strings.wednesdayNightFrom4: localRecord[Strings.wednesdayNightFrom4],
      Strings.wednesdayNightTo4: localRecord[Strings.wednesdayNightTo4],
      Strings.wednesdayAmName5: localRecord[Strings.wednesdayAmName5],
      Strings.wednesdayAmFrom5: localRecord[Strings.wednesdayAmFrom5],
      Strings.wednesdayAmTo5: localRecord[Strings.wednesdayAmTo5],
      Strings.wednesdayPmName5: localRecord[Strings.wednesdayPmName5],
      Strings.wednesdayPmFrom5: localRecord[Strings.wednesdayPmFrom5],
      Strings.wednesdayPmTo5: localRecord[Strings.wednesdayPmTo5],
      Strings.wednesdayNightName5: localRecord[Strings.wednesdayNightName5],
      Strings.wednesdayNightFrom5: localRecord[Strings.wednesdayNightFrom5],
      Strings.wednesdayNightTo5: localRecord[Strings.wednesdayNightTo5],
      Strings.thursdayAmName1: localRecord[Strings.thursdayAmName1],
      Strings.thursdayAmFrom1: localRecord[Strings.thursdayAmFrom1],
      Strings.thursdayAmTo1: localRecord[Strings.thursdayAmTo1],
      Strings.thursdayPmName1: localRecord[Strings.thursdayPmName1],
      Strings.thursdayPmFrom1: localRecord[Strings.thursdayPmFrom1],
      Strings.thursdayPmTo1: localRecord[Strings.thursdayPmTo1],
      Strings.thursdayNightName1: localRecord[Strings.thursdayNightName1],
      Strings.thursdayNightFrom1: localRecord[Strings.thursdayNightFrom1],
      Strings.thursdayNightTo1: localRecord[Strings.thursdayNightTo1],
      Strings.thursdayAmName2: localRecord[Strings.thursdayAmName2],
      Strings.thursdayAmFrom2: localRecord[Strings.thursdayAmFrom2],
      Strings.thursdayAmTo2: localRecord[Strings.thursdayAmTo2],
      Strings.thursdayPmName2: localRecord[Strings.thursdayPmName2],
      Strings.thursdayPmFrom2: localRecord[Strings.thursdayPmFrom2],
      Strings.thursdayPmTo2: localRecord[Strings.thursdayPmTo2],
      Strings.thursdayNightName2: localRecord[Strings.thursdayNightName2],
      Strings.thursdayNightFrom2: localRecord[Strings.thursdayNightFrom2],
      Strings.thursdayNightTo2: localRecord[Strings.thursdayNightTo2],
      Strings.thursdayAmName3: localRecord[Strings.thursdayAmName3],
      Strings.thursdayAmFrom3: localRecord[Strings.thursdayAmFrom3],
      Strings.thursdayAmTo3: localRecord[Strings.thursdayAmTo3],
      Strings.thursdayPmName3: localRecord[Strings.thursdayPmName3],
      Strings.thursdayPmFrom3: localRecord[Strings.thursdayPmFrom3],
      Strings.thursdayPmTo3: localRecord[Strings.thursdayPmTo3],
      Strings.thursdayNightName3: localRecord[Strings.thursdayNightName3],
      Strings.thursdayNightFrom3: localRecord[Strings.thursdayNightFrom3],
      Strings.thursdayNightTo3: localRecord[Strings.thursdayNightTo3],
      Strings.thursdayAmName4: localRecord[Strings.thursdayAmName4],
      Strings.thursdayAmFrom4: localRecord[Strings.thursdayAmFrom4],
      Strings.thursdayAmTo4: localRecord[Strings.thursdayAmTo4],
      Strings.thursdayPmName4: localRecord[Strings.thursdayPmName4],
      Strings.thursdayPmFrom4: localRecord[Strings.thursdayPmFrom4],
      Strings.thursdayPmTo4: localRecord[Strings.thursdayPmTo4],
      Strings.thursdayNightName4: localRecord[Strings.thursdayNightName4],
      Strings.thursdayNightFrom4: localRecord[Strings.thursdayNightFrom4],
      Strings.thursdayNightTo4: localRecord[Strings.thursdayNightTo4],
      Strings.thursdayAmName5: localRecord[Strings.thursdayAmName5],
      Strings.thursdayAmFrom5: localRecord[Strings.thursdayAmFrom5],
      Strings.thursdayAmTo5: localRecord[Strings.thursdayAmTo5],
      Strings.thursdayPmName5: localRecord[Strings.thursdayPmName5],
      Strings.thursdayPmFrom5: localRecord[Strings.thursdayPmFrom5],
      Strings.thursdayPmTo5: localRecord[Strings.thursdayPmTo5],
      Strings.thursdayNightName5: localRecord[Strings.thursdayNightName5],
      Strings.thursdayNightFrom5: localRecord[Strings.thursdayNightFrom5],
      Strings.thursdayNightTo5: localRecord[Strings.thursdayNightTo5],
      Strings.fridayAmName1: localRecord[Strings.fridayAmName1],
      Strings.fridayAmFrom1: localRecord[Strings.fridayAmFrom1],
      Strings.fridayAmTo1: localRecord[Strings.fridayAmTo1],
      Strings.fridayPmName1: localRecord[Strings.fridayPmName1],
      Strings.fridayPmFrom1: localRecord[Strings.fridayPmFrom1],
      Strings.fridayPmTo1: localRecord[Strings.fridayPmTo1],
      Strings.fridayNightName1: localRecord[Strings.fridayNightName1],
      Strings.fridayNightFrom1: localRecord[Strings.fridayNightFrom1],
      Strings.fridayNightTo1: localRecord[Strings.fridayNightTo1],
      Strings.fridayAmName2: localRecord[Strings.fridayAmName2],
      Strings.fridayAmFrom2: localRecord[Strings.fridayAmFrom2],
      Strings.fridayAmTo2: localRecord[Strings.fridayAmTo2],
      Strings.fridayPmName2: localRecord[Strings.fridayPmName2],
      Strings.fridayPmFrom2: localRecord[Strings.fridayPmFrom2],
      Strings.fridayPmTo2: localRecord[Strings.fridayPmTo2],
      Strings.fridayNightName2: localRecord[Strings.fridayNightName2],
      Strings.fridayNightFrom2: localRecord[Strings.fridayNightFrom2],
      Strings.fridayNightTo2: localRecord[Strings.fridayNightTo2],
      Strings.fridayAmName3: localRecord[Strings.fridayAmName3],
      Strings.fridayAmFrom3: localRecord[Strings.fridayAmFrom3],
      Strings.fridayAmTo3: localRecord[Strings.fridayAmTo3],
      Strings.fridayPmName3: localRecord[Strings.fridayPmName3],
      Strings.fridayPmFrom3: localRecord[Strings.fridayPmFrom3],
      Strings.fridayPmTo3: localRecord[Strings.fridayPmTo3],
      Strings.fridayNightName3: localRecord[Strings.fridayNightName3],
      Strings.fridayNightFrom3: localRecord[Strings.fridayNightFrom3],
      Strings.fridayNightTo3: localRecord[Strings.fridayNightTo3],
      Strings.fridayAmName4: localRecord[Strings.fridayAmName4],
      Strings.fridayAmFrom4: localRecord[Strings.fridayAmFrom4],
      Strings.fridayAmTo4: localRecord[Strings.fridayAmTo4],
      Strings.fridayPmName4: localRecord[Strings.fridayPmName4],
      Strings.fridayPmFrom4: localRecord[Strings.fridayPmFrom4],
      Strings.fridayPmTo4: localRecord[Strings.fridayPmTo4],
      Strings.fridayNightName4: localRecord[Strings.fridayNightName4],
      Strings.fridayNightFrom4: localRecord[Strings.fridayNightFrom4],
      Strings.fridayNightTo4: localRecord[Strings.fridayNightTo4],
      Strings.fridayAmName5: localRecord[Strings.fridayAmName5],
      Strings.fridayAmFrom5: localRecord[Strings.fridayAmFrom5],
      Strings.fridayAmTo5: localRecord[Strings.fridayAmTo5],
      Strings.fridayPmName5: localRecord[Strings.fridayPmName5],
      Strings.fridayPmFrom5: localRecord[Strings.fridayPmFrom5],
      Strings.fridayPmTo5: localRecord[Strings.fridayPmTo5],
      Strings.fridayNightName5: localRecord[Strings.fridayNightName5],
      Strings.fridayNightFrom5: localRecord[Strings.fridayNightFrom5],
      Strings.fridayNightTo5: localRecord[Strings.fridayNightTo5],
      Strings.saturdayAmName1: localRecord[Strings.saturdayAmName1],
      Strings.saturdayAmFrom1: localRecord[Strings.saturdayAmFrom1],
      Strings.saturdayAmTo1: localRecord[Strings.saturdayAmTo1],
      Strings.saturdayPmName1: localRecord[Strings.saturdayPmName1],
      Strings.saturdayPmFrom1: localRecord[Strings.saturdayPmFrom1],
      Strings.saturdayPmTo1: localRecord[Strings.saturdayPmTo1],
      Strings.saturdayNightName1: localRecord[Strings.saturdayNightName1],
      Strings.saturdayNightFrom1: localRecord[Strings.saturdayNightFrom1],
      Strings.saturdayNightTo1: localRecord[Strings.saturdayNightTo1],
      Strings.saturdayAmName2: localRecord[Strings.saturdayAmName2],
      Strings.saturdayAmFrom2: localRecord[Strings.saturdayAmFrom2],
      Strings.saturdayAmTo2: localRecord[Strings.saturdayAmTo2],
      Strings.saturdayPmName2: localRecord[Strings.saturdayPmName2],
      Strings.saturdayPmFrom2: localRecord[Strings.saturdayPmFrom2],
      Strings.saturdayPmTo2: localRecord[Strings.saturdayPmTo2],
      Strings.saturdayNightName2: localRecord[Strings.saturdayNightName2],
      Strings.saturdayNightFrom2: localRecord[Strings.saturdayNightFrom2],
      Strings.saturdayNightTo2: localRecord[Strings.saturdayNightTo2],
      Strings.saturdayAmName3: localRecord[Strings.saturdayAmName3],
      Strings.saturdayAmFrom3: localRecord[Strings.saturdayAmFrom3],
      Strings.saturdayAmTo3: localRecord[Strings.saturdayAmTo3],
      Strings.saturdayPmName3: localRecord[Strings.saturdayPmName3],
      Strings.saturdayPmFrom3: localRecord[Strings.saturdayPmFrom3],
      Strings.saturdayPmTo3: localRecord[Strings.saturdayPmTo3],
      Strings.saturdayNightName3: localRecord[Strings.saturdayNightName3],
      Strings.saturdayNightFrom3: localRecord[Strings.saturdayNightFrom3],
      Strings.saturdayNightTo3: localRecord[Strings.saturdayNightTo3],
      Strings.saturdayAmName4: localRecord[Strings.saturdayAmName4],
      Strings.saturdayAmFrom4: localRecord[Strings.saturdayAmFrom4],
      Strings.saturdayAmTo4: localRecord[Strings.saturdayAmTo4],
      Strings.saturdayPmName4: localRecord[Strings.saturdayPmName4],
      Strings.saturdayPmFrom4: localRecord[Strings.saturdayPmFrom4],
      Strings.saturdayPmTo4: localRecord[Strings.saturdayPmTo4],
      Strings.saturdayNightName4: localRecord[Strings.saturdayNightName4],
      Strings.saturdayNightFrom4: localRecord[Strings.saturdayNightFrom4],
      Strings.saturdayNightTo4: localRecord[Strings.saturdayNightTo4],
      Strings.saturdayAmName5: localRecord[Strings.saturdayAmName5],
      Strings.saturdayAmFrom5: localRecord[Strings.saturdayAmFrom5],
      Strings.saturdayAmTo5: localRecord[Strings.saturdayAmTo5],
      Strings.saturdayPmName5: localRecord[Strings.saturdayPmName5],
      Strings.saturdayPmFrom5: localRecord[Strings.saturdayPmFrom5],
      Strings.saturdayPmTo5: localRecord[Strings.saturdayPmTo5],
      Strings.saturdayNightName5: localRecord[Strings.saturdayNightName5],
      Strings.saturdayNightFrom5: localRecord[Strings.saturdayNightFrom5],
      Strings.saturdayNightTo5: localRecord[Strings.saturdayNightTo5],
      Strings.sundayAmName1: localRecord[Strings.sundayAmName1],
      Strings.sundayAmFrom1: localRecord[Strings.sundayAmFrom1],
      Strings.sundayAmTo1: localRecord[Strings.sundayAmTo1],
      Strings.sundayPmName1: localRecord[Strings.sundayPmName1],
      Strings.sundayPmFrom1: localRecord[Strings.sundayPmFrom1],
      Strings.sundayPmTo1: localRecord[Strings.sundayPmTo1],
      Strings.sundayNightName1: localRecord[Strings.sundayNightName1],
      Strings.sundayNightFrom1: localRecord[Strings.sundayNightFrom1],
      Strings.sundayNightTo1: localRecord[Strings.sundayNightTo1],
      Strings.sundayAmName2: localRecord[Strings.sundayAmName2],
      Strings.sundayAmFrom2: localRecord[Strings.sundayAmFrom2],
      Strings.sundayAmTo2: localRecord[Strings.sundayAmTo2],
      Strings.sundayPmName2: localRecord[Strings.sundayPmName2],
      Strings.sundayPmFrom2: localRecord[Strings.sundayPmFrom2],
      Strings.sundayPmTo2: localRecord[Strings.sundayPmTo2],
      Strings.sundayNightName2: localRecord[Strings.sundayNightName2],
      Strings.sundayNightFrom2: localRecord[Strings.sundayNightFrom2],
      Strings.sundayNightTo2: localRecord[Strings.sundayNightTo2],
      Strings.sundayAmName3: localRecord[Strings.sundayAmName3],
      Strings.sundayAmFrom3: localRecord[Strings.sundayAmFrom3],
      Strings.sundayAmTo3: localRecord[Strings.sundayAmTo3],
      Strings.sundayPmName3: localRecord[Strings.sundayPmName3],
      Strings.sundayPmFrom3: localRecord[Strings.sundayPmFrom3],
      Strings.sundayPmTo3: localRecord[Strings.sundayPmTo3],
      Strings.sundayNightName3: localRecord[Strings.sundayNightName3],
      Strings.sundayNightFrom3: localRecord[Strings.sundayNightFrom3],
      Strings.sundayNightTo3: localRecord[Strings.sundayNightTo3],
      Strings.sundayAmName4: localRecord[Strings.sundayAmName4],
      Strings.sundayAmFrom4: localRecord[Strings.sundayAmFrom4],
      Strings.sundayAmTo4: localRecord[Strings.sundayAmTo4],
      Strings.sundayPmName4: localRecord[Strings.sundayPmName4],
      Strings.sundayPmFrom4: localRecord[Strings.sundayPmFrom4],
      Strings.sundayPmTo4: localRecord[Strings.sundayPmTo4],
      Strings.sundayNightName4: localRecord[Strings.sundayNightName4],
      Strings.sundayNightFrom4: localRecord[Strings.sundayNightFrom4],
      Strings.sundayNightTo4: localRecord[Strings.sundayNightTo4],
      Strings.sundayAmName5: localRecord[Strings.sundayAmName5],
      Strings.sundayAmFrom5: localRecord[Strings.sundayAmFrom5],
      Strings.sundayAmTo5: localRecord[Strings.sundayAmTo5],
      Strings.sundayPmName5: localRecord[Strings.sundayPmName5],
      Strings.sundayPmFrom5: localRecord[Strings.sundayPmFrom5],
      Strings.sundayPmTo5: localRecord[Strings.sundayPmTo5],
      Strings.sundayNightName5: localRecord[Strings.sundayNightName5],
      Strings.sundayNightFrom5: localRecord[Strings.sundayNightFrom5],
      Strings.sundayNightTo5: localRecord[Strings.sundayNightTo5],
      Strings.serverUploaded: localRecord[Strings.serverUploaded],
      Strings.timestamp: localRecord[Strings.timestamp] == null ? null : DateTime
          .fromMillisecondsSinceEpoch(
          localRecord['timestamp'].millisecondsSinceEpoch)
          .toIso8601String()
    };
  }

  Map<String, dynamic> editedBedRota(Map<String, dynamic> localRecord){
    return {
      Strings.documentId: GlobalFunctions.databaseValueString(localRecord[Strings.documentId]),
      Strings.uid: GlobalFunctions.databaseValueString(localRecord[Strings.uid]),
      Strings.jobId: localRecord[Strings.jobId],
      Strings.formVersion: localRecord[Strings.formVersion],
      Strings.jobRef: localRecord[Strings.jobRef],
      Strings.jobRefRef: localRecord[Strings.jobRefRef],
      Strings.jobRefNo: localRecord[Strings.jobRefNo],
      Strings.weekCommencing: localRecord[Strings.weekCommencing],
      Strings.mondayAmName1: localRecord[Strings.mondayAmName1],
      Strings.mondayAmFrom1: localRecord[Strings.mondayAmFrom1],
      Strings.mondayAmTo1: localRecord[Strings.mondayAmTo1],
      Strings.mondayPmName1: localRecord[Strings.mondayPmName1],
      Strings.mondayPmFrom1: localRecord[Strings.mondayPmFrom1],
      Strings.mondayPmTo1: localRecord[Strings.mondayPmTo1],
      Strings.mondayNightName1: localRecord[Strings.mondayNightName1],
      Strings.mondayNightFrom1: localRecord[Strings.mondayNightFrom1],
      Strings.mondayNightTo1: localRecord[Strings.mondayNightTo1],
      Strings.mondayAmName2: localRecord[Strings.mondayAmName2],
      Strings.mondayAmFrom2: localRecord[Strings.mondayAmFrom2],
      Strings.mondayAmTo2: localRecord[Strings.mondayAmTo2],
      Strings.mondayPmName2: localRecord[Strings.mondayPmName2],
      Strings.mondayPmFrom2: localRecord[Strings.mondayPmFrom2],
      Strings.mondayPmTo2: localRecord[Strings.mondayPmTo2],
      Strings.mondayNightName2: localRecord[Strings.mondayNightName2],
      Strings.mondayNightFrom2: localRecord[Strings.mondayNightFrom2],
      Strings.mondayNightTo2: localRecord[Strings.mondayNightTo2],
      Strings.mondayAmName3: localRecord[Strings.mondayAmName3],
      Strings.mondayAmFrom3: localRecord[Strings.mondayAmFrom3],
      Strings.mondayAmTo3: localRecord[Strings.mondayAmTo3],
      Strings.mondayPmName3: localRecord[Strings.mondayPmName3],
      Strings.mondayPmFrom3: localRecord[Strings.mondayPmFrom3],
      Strings.mondayPmTo3: localRecord[Strings.mondayPmTo3],
      Strings.mondayNightName3: localRecord[Strings.mondayNightName3],
      Strings.mondayNightFrom3: localRecord[Strings.mondayNightFrom3],
      Strings.mondayNightTo3: localRecord[Strings.mondayNightTo3],
      Strings.mondayAmName4: localRecord[Strings.mondayAmName4],
      Strings.mondayAmFrom4: localRecord[Strings.mondayAmFrom4],
      Strings.mondayAmTo4: localRecord[Strings.mondayAmTo4],
      Strings.mondayPmName4: localRecord[Strings.mondayPmName4],
      Strings.mondayPmFrom4: localRecord[Strings.mondayPmFrom4],
      Strings.mondayPmTo4: localRecord[Strings.mondayPmTo4],
      Strings.mondayNightName4: localRecord[Strings.mondayNightName4],
      Strings.mondayNightFrom4: localRecord[Strings.mondayNightFrom4],
      Strings.mondayNightTo4: localRecord[Strings.mondayNightTo4],
      Strings.mondayAmName5: localRecord[Strings.mondayAmName5],
      Strings.mondayAmFrom5: localRecord[Strings.mondayAmFrom5],
      Strings.mondayAmTo5: localRecord[Strings.mondayAmTo5],
      Strings.mondayPmName5: localRecord[Strings.mondayPmName5],
      Strings.mondayPmFrom5: localRecord[Strings.mondayPmFrom5],
      Strings.mondayPmTo5: localRecord[Strings.mondayPmTo5],
      Strings.mondayNightName5: localRecord[Strings.mondayNightName5],
      Strings.mondayNightFrom5: localRecord[Strings.mondayNightFrom5],
      Strings.mondayNightTo5: localRecord[Strings.mondayNightTo5],
      Strings.tuesdayAmName1: localRecord[Strings.tuesdayAmName1],
      Strings.tuesdayAmFrom1: localRecord[Strings.tuesdayAmFrom1],
      Strings.tuesdayAmTo1: localRecord[Strings.tuesdayAmTo1],
      Strings.tuesdayPmName1: localRecord[Strings.tuesdayPmName1],
      Strings.tuesdayPmFrom1: localRecord[Strings.tuesdayPmFrom1],
      Strings.tuesdayPmTo1: localRecord[Strings.tuesdayPmTo1],
      Strings.tuesdayNightName1: localRecord[Strings.tuesdayNightName1],
      Strings.tuesdayNightFrom1: localRecord[Strings.tuesdayNightFrom1],
      Strings.tuesdayNightTo1: localRecord[Strings.tuesdayNightTo1],
      Strings.tuesdayAmName2: localRecord[Strings.tuesdayAmName2],
      Strings.tuesdayAmFrom2: localRecord[Strings.tuesdayAmFrom2],
      Strings.tuesdayAmTo2: localRecord[Strings.tuesdayAmTo2],
      Strings.tuesdayPmName2: localRecord[Strings.tuesdayPmName2],
      Strings.tuesdayPmFrom2: localRecord[Strings.tuesdayPmFrom2],
      Strings.tuesdayPmTo2: localRecord[Strings.tuesdayPmTo2],
      Strings.tuesdayNightName2: localRecord[Strings.tuesdayNightName2],
      Strings.tuesdayNightFrom2: localRecord[Strings.tuesdayNightFrom2],
      Strings.tuesdayNightTo2: localRecord[Strings.tuesdayNightTo2],
      Strings.tuesdayAmName3: localRecord[Strings.tuesdayAmName3],
      Strings.tuesdayAmFrom3: localRecord[Strings.tuesdayAmFrom3],
      Strings.tuesdayAmTo3: localRecord[Strings.tuesdayAmTo3],
      Strings.tuesdayPmName3: localRecord[Strings.tuesdayPmName3],
      Strings.tuesdayPmFrom3: localRecord[Strings.tuesdayPmFrom3],
      Strings.tuesdayPmTo3: localRecord[Strings.tuesdayPmTo3],
      Strings.tuesdayNightName3: localRecord[Strings.tuesdayNightName3],
      Strings.tuesdayNightFrom3: localRecord[Strings.tuesdayNightFrom3],
      Strings.tuesdayNightTo3: localRecord[Strings.tuesdayNightTo3],
      Strings.tuesdayAmName4: localRecord[Strings.tuesdayAmName4],
      Strings.tuesdayAmFrom4: localRecord[Strings.tuesdayAmFrom4],
      Strings.tuesdayAmTo4: localRecord[Strings.tuesdayAmTo4],
      Strings.tuesdayPmName4: localRecord[Strings.tuesdayPmName4],
      Strings.tuesdayPmFrom4: localRecord[Strings.tuesdayPmFrom4],
      Strings.tuesdayPmTo4: localRecord[Strings.tuesdayPmTo4],
      Strings.tuesdayNightName4: localRecord[Strings.tuesdayNightName4],
      Strings.tuesdayNightFrom4: localRecord[Strings.tuesdayNightFrom4],
      Strings.tuesdayNightTo4: localRecord[Strings.tuesdayNightTo4],
      Strings.tuesdayAmName5: localRecord[Strings.tuesdayAmName5],
      Strings.tuesdayAmFrom5: localRecord[Strings.tuesdayAmFrom5],
      Strings.tuesdayAmTo5: localRecord[Strings.tuesdayAmTo5],
      Strings.tuesdayPmName5: localRecord[Strings.tuesdayPmName5],
      Strings.tuesdayPmFrom5: localRecord[Strings.tuesdayPmFrom5],
      Strings.tuesdayPmTo5: localRecord[Strings.tuesdayPmTo5],
      Strings.tuesdayNightName5: localRecord[Strings.tuesdayNightName5],
      Strings.tuesdayNightFrom5: localRecord[Strings.tuesdayNightFrom5],
      Strings.tuesdayNightTo5: localRecord[Strings.tuesdayNightTo5],
      Strings.wednesdayAmName1: localRecord[Strings.wednesdayAmName1],
      Strings.wednesdayAmFrom1: localRecord[Strings.wednesdayAmFrom1],
      Strings.wednesdayAmTo1: localRecord[Strings.wednesdayAmTo1],
      Strings.wednesdayPmName1: localRecord[Strings.wednesdayPmName1],
      Strings.wednesdayPmFrom1: localRecord[Strings.wednesdayPmFrom1],
      Strings.wednesdayPmTo1: localRecord[Strings.wednesdayPmTo1],
      Strings.wednesdayNightName1: localRecord[Strings.wednesdayNightName1],
      Strings.wednesdayNightFrom1: localRecord[Strings.wednesdayNightFrom1],
      Strings.wednesdayNightTo1: localRecord[Strings.wednesdayNightTo1],
      Strings.wednesdayAmName2: localRecord[Strings.wednesdayAmName2],
      Strings.wednesdayAmFrom2: localRecord[Strings.wednesdayAmFrom2],
      Strings.wednesdayAmTo2: localRecord[Strings.wednesdayAmTo2],
      Strings.wednesdayPmName2: localRecord[Strings.wednesdayPmName2],
      Strings.wednesdayPmFrom2: localRecord[Strings.wednesdayPmFrom2],
      Strings.wednesdayPmTo2: localRecord[Strings.wednesdayPmTo2],
      Strings.wednesdayNightName2: localRecord[Strings.wednesdayNightName2],
      Strings.wednesdayNightFrom2: localRecord[Strings.wednesdayNightFrom2],
      Strings.wednesdayNightTo2: localRecord[Strings.wednesdayNightTo2],
      Strings.wednesdayAmName3: localRecord[Strings.wednesdayAmName3],
      Strings.wednesdayAmFrom3: localRecord[Strings.wednesdayAmFrom3],
      Strings.wednesdayAmTo3: localRecord[Strings.wednesdayAmTo3],
      Strings.wednesdayPmName3: localRecord[Strings.wednesdayPmName3],
      Strings.wednesdayPmFrom3: localRecord[Strings.wednesdayPmFrom3],
      Strings.wednesdayPmTo3: localRecord[Strings.wednesdayPmTo3],
      Strings.wednesdayNightName3: localRecord[Strings.wednesdayNightName3],
      Strings.wednesdayNightFrom3: localRecord[Strings.wednesdayNightFrom3],
      Strings.wednesdayNightTo3: localRecord[Strings.wednesdayNightTo3],
      Strings.wednesdayAmName4: localRecord[Strings.wednesdayAmName4],
      Strings.wednesdayAmFrom4: localRecord[Strings.wednesdayAmFrom4],
      Strings.wednesdayAmTo4: localRecord[Strings.wednesdayAmTo4],
      Strings.wednesdayPmName4: localRecord[Strings.wednesdayPmName4],
      Strings.wednesdayPmFrom4: localRecord[Strings.wednesdayPmFrom4],
      Strings.wednesdayPmTo4: localRecord[Strings.wednesdayPmTo4],
      Strings.wednesdayNightName4: localRecord[Strings.wednesdayNightName4],
      Strings.wednesdayNightFrom4: localRecord[Strings.wednesdayNightFrom4],
      Strings.wednesdayNightTo4: localRecord[Strings.wednesdayNightTo4],
      Strings.wednesdayAmName5: localRecord[Strings.wednesdayAmName5],
      Strings.wednesdayAmFrom5: localRecord[Strings.wednesdayAmFrom5],
      Strings.wednesdayAmTo5: localRecord[Strings.wednesdayAmTo5],
      Strings.wednesdayPmName5: localRecord[Strings.wednesdayPmName5],
      Strings.wednesdayPmFrom5: localRecord[Strings.wednesdayPmFrom5],
      Strings.wednesdayPmTo5: localRecord[Strings.wednesdayPmTo5],
      Strings.wednesdayNightName5: localRecord[Strings.wednesdayNightName5],
      Strings.wednesdayNightFrom5: localRecord[Strings.wednesdayNightFrom5],
      Strings.wednesdayNightTo5: localRecord[Strings.wednesdayNightTo5],
      Strings.thursdayAmName1: localRecord[Strings.thursdayAmName1],
      Strings.thursdayAmFrom1: localRecord[Strings.thursdayAmFrom1],
      Strings.thursdayAmTo1: localRecord[Strings.thursdayAmTo1],
      Strings.thursdayPmName1: localRecord[Strings.thursdayPmName1],
      Strings.thursdayPmFrom1: localRecord[Strings.thursdayPmFrom1],
      Strings.thursdayPmTo1: localRecord[Strings.thursdayPmTo1],
      Strings.thursdayNightName1: localRecord[Strings.thursdayNightName1],
      Strings.thursdayNightFrom1: localRecord[Strings.thursdayNightFrom1],
      Strings.thursdayNightTo1: localRecord[Strings.thursdayNightTo1],
      Strings.thursdayAmName2: localRecord[Strings.thursdayAmName2],
      Strings.thursdayAmFrom2: localRecord[Strings.thursdayAmFrom2],
      Strings.thursdayAmTo2: localRecord[Strings.thursdayAmTo2],
      Strings.thursdayPmName2: localRecord[Strings.thursdayPmName2],
      Strings.thursdayPmFrom2: localRecord[Strings.thursdayPmFrom2],
      Strings.thursdayPmTo2: localRecord[Strings.thursdayPmTo2],
      Strings.thursdayNightName2: localRecord[Strings.thursdayNightName2],
      Strings.thursdayNightFrom2: localRecord[Strings.thursdayNightFrom2],
      Strings.thursdayNightTo2: localRecord[Strings.thursdayNightTo2],
      Strings.thursdayAmName3: localRecord[Strings.thursdayAmName3],
      Strings.thursdayAmFrom3: localRecord[Strings.thursdayAmFrom3],
      Strings.thursdayAmTo3: localRecord[Strings.thursdayAmTo3],
      Strings.thursdayPmName3: localRecord[Strings.thursdayPmName3],
      Strings.thursdayPmFrom3: localRecord[Strings.thursdayPmFrom3],
      Strings.thursdayPmTo3: localRecord[Strings.thursdayPmTo3],
      Strings.thursdayNightName3: localRecord[Strings.thursdayNightName3],
      Strings.thursdayNightFrom3: localRecord[Strings.thursdayNightFrom3],
      Strings.thursdayNightTo3: localRecord[Strings.thursdayNightTo3],
      Strings.thursdayAmName4: localRecord[Strings.thursdayAmName4],
      Strings.thursdayAmFrom4: localRecord[Strings.thursdayAmFrom4],
      Strings.thursdayAmTo4: localRecord[Strings.thursdayAmTo4],
      Strings.thursdayPmName4: localRecord[Strings.thursdayPmName4],
      Strings.thursdayPmFrom4: localRecord[Strings.thursdayPmFrom4],
      Strings.thursdayPmTo4: localRecord[Strings.thursdayPmTo4],
      Strings.thursdayNightName4: localRecord[Strings.thursdayNightName4],
      Strings.thursdayNightFrom4: localRecord[Strings.thursdayNightFrom4],
      Strings.thursdayNightTo4: localRecord[Strings.thursdayNightTo4],
      Strings.thursdayAmName5: localRecord[Strings.thursdayAmName5],
      Strings.thursdayAmFrom5: localRecord[Strings.thursdayAmFrom5],
      Strings.thursdayAmTo5: localRecord[Strings.thursdayAmTo5],
      Strings.thursdayPmName5: localRecord[Strings.thursdayPmName5],
      Strings.thursdayPmFrom5: localRecord[Strings.thursdayPmFrom5],
      Strings.thursdayPmTo5: localRecord[Strings.thursdayPmTo5],
      Strings.thursdayNightName5: localRecord[Strings.thursdayNightName5],
      Strings.thursdayNightFrom5: localRecord[Strings.thursdayNightFrom5],
      Strings.thursdayNightTo5: localRecord[Strings.thursdayNightTo5],
      Strings.fridayAmName1: localRecord[Strings.fridayAmName1],
      Strings.fridayAmFrom1: localRecord[Strings.fridayAmFrom1],
      Strings.fridayAmTo1: localRecord[Strings.fridayAmTo1],
      Strings.fridayPmName1: localRecord[Strings.fridayPmName1],
      Strings.fridayPmFrom1: localRecord[Strings.fridayPmFrom1],
      Strings.fridayPmTo1: localRecord[Strings.fridayPmTo1],
      Strings.fridayNightName1: localRecord[Strings.fridayNightName1],
      Strings.fridayNightFrom1: localRecord[Strings.fridayNightFrom1],
      Strings.fridayNightTo1: localRecord[Strings.fridayNightTo1],
      Strings.fridayAmName2: localRecord[Strings.fridayAmName2],
      Strings.fridayAmFrom2: localRecord[Strings.fridayAmFrom2],
      Strings.fridayAmTo2: localRecord[Strings.fridayAmTo2],
      Strings.fridayPmName2: localRecord[Strings.fridayPmName2],
      Strings.fridayPmFrom2: localRecord[Strings.fridayPmFrom2],
      Strings.fridayPmTo2: localRecord[Strings.fridayPmTo2],
      Strings.fridayNightName2: localRecord[Strings.fridayNightName2],
      Strings.fridayNightFrom2: localRecord[Strings.fridayNightFrom2],
      Strings.fridayNightTo2: localRecord[Strings.fridayNightTo2],
      Strings.fridayAmName3: localRecord[Strings.fridayAmName3],
      Strings.fridayAmFrom3: localRecord[Strings.fridayAmFrom3],
      Strings.fridayAmTo3: localRecord[Strings.fridayAmTo3],
      Strings.fridayPmName3: localRecord[Strings.fridayPmName3],
      Strings.fridayPmFrom3: localRecord[Strings.fridayPmFrom3],
      Strings.fridayPmTo3: localRecord[Strings.fridayPmTo3],
      Strings.fridayNightName3: localRecord[Strings.fridayNightName3],
      Strings.fridayNightFrom3: localRecord[Strings.fridayNightFrom3],
      Strings.fridayNightTo3: localRecord[Strings.fridayNightTo3],
      Strings.fridayAmName4: localRecord[Strings.fridayAmName4],
      Strings.fridayAmFrom4: localRecord[Strings.fridayAmFrom4],
      Strings.fridayAmTo4: localRecord[Strings.fridayAmTo4],
      Strings.fridayPmName4: localRecord[Strings.fridayPmName4],
      Strings.fridayPmFrom4: localRecord[Strings.fridayPmFrom4],
      Strings.fridayPmTo4: localRecord[Strings.fridayPmTo4],
      Strings.fridayNightName4: localRecord[Strings.fridayNightName4],
      Strings.fridayNightFrom4: localRecord[Strings.fridayNightFrom4],
      Strings.fridayNightTo4: localRecord[Strings.fridayNightTo4],
      Strings.fridayAmName5: localRecord[Strings.fridayAmName5],
      Strings.fridayAmFrom5: localRecord[Strings.fridayAmFrom5],
      Strings.fridayAmTo5: localRecord[Strings.fridayAmTo5],
      Strings.fridayPmName5: localRecord[Strings.fridayPmName5],
      Strings.fridayPmFrom5: localRecord[Strings.fridayPmFrom5],
      Strings.fridayPmTo5: localRecord[Strings.fridayPmTo5],
      Strings.fridayNightName5: localRecord[Strings.fridayNightName5],
      Strings.fridayNightFrom5: localRecord[Strings.fridayNightFrom5],
      Strings.fridayNightTo5: localRecord[Strings.fridayNightTo5],
      Strings.saturdayAmName1: localRecord[Strings.saturdayAmName1],
      Strings.saturdayAmFrom1: localRecord[Strings.saturdayAmFrom1],
      Strings.saturdayAmTo1: localRecord[Strings.saturdayAmTo1],
      Strings.saturdayPmName1: localRecord[Strings.saturdayPmName1],
      Strings.saturdayPmFrom1: localRecord[Strings.saturdayPmFrom1],
      Strings.saturdayPmTo1: localRecord[Strings.saturdayPmTo1],
      Strings.saturdayNightName1: localRecord[Strings.saturdayNightName1],
      Strings.saturdayNightFrom1: localRecord[Strings.saturdayNightFrom1],
      Strings.saturdayNightTo1: localRecord[Strings.saturdayNightTo1],
      Strings.saturdayAmName2: localRecord[Strings.saturdayAmName2],
      Strings.saturdayAmFrom2: localRecord[Strings.saturdayAmFrom2],
      Strings.saturdayAmTo2: localRecord[Strings.saturdayAmTo2],
      Strings.saturdayPmName2: localRecord[Strings.saturdayPmName2],
      Strings.saturdayPmFrom2: localRecord[Strings.saturdayPmFrom2],
      Strings.saturdayPmTo2: localRecord[Strings.saturdayPmTo2],
      Strings.saturdayNightName2: localRecord[Strings.saturdayNightName2],
      Strings.saturdayNightFrom2: localRecord[Strings.saturdayNightFrom2],
      Strings.saturdayNightTo2: localRecord[Strings.saturdayNightTo2],
      Strings.saturdayAmName3: localRecord[Strings.saturdayAmName3],
      Strings.saturdayAmFrom3: localRecord[Strings.saturdayAmFrom3],
      Strings.saturdayAmTo3: localRecord[Strings.saturdayAmTo3],
      Strings.saturdayPmName3: localRecord[Strings.saturdayPmName3],
      Strings.saturdayPmFrom3: localRecord[Strings.saturdayPmFrom3],
      Strings.saturdayPmTo3: localRecord[Strings.saturdayPmTo3],
      Strings.saturdayNightName3: localRecord[Strings.saturdayNightName3],
      Strings.saturdayNightFrom3: localRecord[Strings.saturdayNightFrom3],
      Strings.saturdayNightTo3: localRecord[Strings.saturdayNightTo3],
      Strings.saturdayAmName4: localRecord[Strings.saturdayAmName4],
      Strings.saturdayAmFrom4: localRecord[Strings.saturdayAmFrom4],
      Strings.saturdayAmTo4: localRecord[Strings.saturdayAmTo4],
      Strings.saturdayPmName4: localRecord[Strings.saturdayPmName4],
      Strings.saturdayPmFrom4: localRecord[Strings.saturdayPmFrom4],
      Strings.saturdayPmTo4: localRecord[Strings.saturdayPmTo4],
      Strings.saturdayNightName4: localRecord[Strings.saturdayNightName4],
      Strings.saturdayNightFrom4: localRecord[Strings.saturdayNightFrom4],
      Strings.saturdayNightTo4: localRecord[Strings.saturdayNightTo4],
      Strings.saturdayAmName5: localRecord[Strings.saturdayAmName5],
      Strings.saturdayAmFrom5: localRecord[Strings.saturdayAmFrom5],
      Strings.saturdayAmTo5: localRecord[Strings.saturdayAmTo5],
      Strings.saturdayPmName5: localRecord[Strings.saturdayPmName5],
      Strings.saturdayPmFrom5: localRecord[Strings.saturdayPmFrom5],
      Strings.saturdayPmTo5: localRecord[Strings.saturdayPmTo5],
      Strings.saturdayNightName5: localRecord[Strings.saturdayNightName5],
      Strings.saturdayNightFrom5: localRecord[Strings.saturdayNightFrom5],
      Strings.saturdayNightTo5: localRecord[Strings.saturdayNightTo5],
      Strings.sundayAmName1: localRecord[Strings.sundayAmName1],
      Strings.sundayAmFrom1: localRecord[Strings.sundayAmFrom1],
      Strings.sundayAmTo1: localRecord[Strings.sundayAmTo1],
      Strings.sundayPmName1: localRecord[Strings.sundayPmName1],
      Strings.sundayPmFrom1: localRecord[Strings.sundayPmFrom1],
      Strings.sundayPmTo1: localRecord[Strings.sundayPmTo1],
      Strings.sundayNightName1: localRecord[Strings.sundayNightName1],
      Strings.sundayNightFrom1: localRecord[Strings.sundayNightFrom1],
      Strings.sundayNightTo1: localRecord[Strings.sundayNightTo1],
      Strings.sundayAmName2: localRecord[Strings.sundayAmName2],
      Strings.sundayAmFrom2: localRecord[Strings.sundayAmFrom2],
      Strings.sundayAmTo2: localRecord[Strings.sundayAmTo2],
      Strings.sundayPmName2: localRecord[Strings.sundayPmName2],
      Strings.sundayPmFrom2: localRecord[Strings.sundayPmFrom2],
      Strings.sundayPmTo2: localRecord[Strings.sundayPmTo2],
      Strings.sundayNightName2: localRecord[Strings.sundayNightName2],
      Strings.sundayNightFrom2: localRecord[Strings.sundayNightFrom2],
      Strings.sundayNightTo2: localRecord[Strings.sundayNightTo2],
      Strings.sundayAmName3: localRecord[Strings.sundayAmName3],
      Strings.sundayAmFrom3: localRecord[Strings.sundayAmFrom3],
      Strings.sundayAmTo3: localRecord[Strings.sundayAmTo3],
      Strings.sundayPmName3: localRecord[Strings.sundayPmName3],
      Strings.sundayPmFrom3: localRecord[Strings.sundayPmFrom3],
      Strings.sundayPmTo3: localRecord[Strings.sundayPmTo3],
      Strings.sundayNightName3: localRecord[Strings.sundayNightName3],
      Strings.sundayNightFrom3: localRecord[Strings.sundayNightFrom3],
      Strings.sundayNightTo3: localRecord[Strings.sundayNightTo3],
      Strings.sundayAmName4: localRecord[Strings.sundayAmName4],
      Strings.sundayAmFrom4: localRecord[Strings.sundayAmFrom4],
      Strings.sundayAmTo4: localRecord[Strings.sundayAmTo4],
      Strings.sundayPmName4: localRecord[Strings.sundayPmName4],
      Strings.sundayPmFrom4: localRecord[Strings.sundayPmFrom4],
      Strings.sundayPmTo4: localRecord[Strings.sundayPmTo4],
      Strings.sundayNightName4: localRecord[Strings.sundayNightName4],
      Strings.sundayNightFrom4: localRecord[Strings.sundayNightFrom4],
      Strings.sundayNightTo4: localRecord[Strings.sundayNightTo4],
      Strings.sundayAmName5: localRecord[Strings.sundayAmName5],
      Strings.sundayAmFrom5: localRecord[Strings.sundayAmFrom5],
      Strings.sundayAmTo5: localRecord[Strings.sundayAmTo5],
      Strings.sundayPmName5: localRecord[Strings.sundayPmName5],
      Strings.sundayPmFrom5: localRecord[Strings.sundayPmFrom5],
      Strings.sundayPmTo5: localRecord[Strings.sundayPmTo5],
      Strings.sundayNightName5: localRecord[Strings.sundayNightName5],
      Strings.sundayNightFrom5: localRecord[Strings.sundayNightFrom5],
      Strings.sundayNightTo5: localRecord[Strings.sundayNightTo5],
      Strings.serverUploaded: localRecord[Strings.serverUploaded],
      Strings.timestamp: localRecord[Strings.timestamp]
    };
  }



  Future<Map<String, dynamic>> uploadPendingBedRotas() async {
    _isLoading = true;
    String message = 'Something went wrong!';
    bool success = false;

    try {

      List<dynamic> bedRotaRecords = await getPendingRecords();

      List<Map<String, dynamic>> bedRotas = [];

      for(var bedRotaRecord in bedRotaRecords){
        bedRotas.add(bedRotaRecord.value);
      }

      bool isTokenExpired = GlobalFunctions.isTokenExpired();
      bool authenticated = true;

      if (isTokenExpired)
        authenticated = await authenticationModel.reAuthenticate();

      if (authenticated) {

        for (Map<String, dynamic> bedRota in bedRotas) {

          success = false;

          await GlobalFunctions.checkFirebaseStorageFail(_databaseHelper);

          await FirebaseFirestore.instance.collection('bed_rotas').add({
            Strings.uid: user.uid,
            Strings.jobId: '1',
            Strings.formVersion: '1',
            Strings.jobRef: GlobalFunctions.databaseValueString(bedRota[Strings.jobRefRef]) + GlobalFunctions.databaseValueString(bedRota[Strings.jobRefNo]),
            Strings.jobRefLowercase: GlobalFunctions.databaseValueString(bedRota[Strings.jobRefRef]).toLowerCase() + GlobalFunctions.databaseValueString(bedRota[Strings.jobRefNo]).toLowerCase(),
            Strings.jobRefRef: GlobalFunctions.databaseValueString(bedRota[Strings.jobRefRef]),
            Strings.jobRefNo: int.parse(bedRota[Strings.jobRefNo]),
            Strings.weekCommencing: bedRota[Strings.weekCommencing] == null ? null : DateTime.parse(bedRota[Strings.weekCommencing]),
            Strings.mondayAmName1: bedRota[Strings.mondayAmName1],
            Strings.mondayAmFrom1: bedRota[Strings.mondayAmFrom1],
            Strings.mondayAmTo1: bedRota[Strings.mondayAmTo1],
            Strings.mondayPmName1: bedRota[Strings.mondayPmName1],
            Strings.mondayPmFrom1: bedRota[Strings.mondayPmFrom1],
            Strings.mondayPmTo1: bedRota[Strings.mondayPmTo1],
            Strings.mondayNightName1: bedRota[Strings.mondayNightName1],
            Strings.mondayNightFrom1: bedRota[Strings.mondayNightFrom1],
            Strings.mondayNightTo1: bedRota[Strings.mondayNightTo1],
            Strings.mondayAmName2: bedRota[Strings.mondayAmName2],
            Strings.mondayAmFrom2: bedRota[Strings.mondayAmFrom2],
            Strings.mondayAmTo2: bedRota[Strings.mondayAmTo2],
            Strings.mondayPmName2: bedRota[Strings.mondayPmName2],
            Strings.mondayPmFrom2: bedRota[Strings.mondayPmFrom2],
            Strings.mondayPmTo2: bedRota[Strings.mondayPmTo2],
            Strings.mondayNightName2: bedRota[Strings.mondayNightName2],
            Strings.mondayNightFrom2: bedRota[Strings.mondayNightFrom2],
            Strings.mondayNightTo2: bedRota[Strings.mondayNightTo2],
            Strings.mondayAmName3: bedRota[Strings.mondayAmName3],
            Strings.mondayAmFrom3: bedRota[Strings.mondayAmFrom3],
            Strings.mondayAmTo3: bedRota[Strings.mondayAmTo3],
            Strings.mondayPmName3: bedRota[Strings.mondayPmName3],
            Strings.mondayPmFrom3: bedRota[Strings.mondayPmFrom3],
            Strings.mondayPmTo3: bedRota[Strings.mondayPmTo3],
            Strings.mondayNightName3: bedRota[Strings.mondayNightName3],
            Strings.mondayNightFrom3: bedRota[Strings.mondayNightFrom3],
            Strings.mondayNightTo3: bedRota[Strings.mondayNightTo3],
            Strings.mondayAmName4: bedRota[Strings.mondayAmName4],
            Strings.mondayAmFrom4: bedRota[Strings.mondayAmFrom4],
            Strings.mondayAmTo4: bedRota[Strings.mondayAmTo4],
            Strings.mondayPmName4: bedRota[Strings.mondayPmName4],
            Strings.mondayPmFrom4: bedRota[Strings.mondayPmFrom4],
            Strings.mondayPmTo4: bedRota[Strings.mondayPmTo4],
            Strings.mondayNightName4: bedRota[Strings.mondayNightName4],
            Strings.mondayNightFrom4: bedRota[Strings.mondayNightFrom4],
            Strings.mondayNightTo4: bedRota[Strings.mondayNightTo4],
            Strings.mondayAmName5: bedRota[Strings.mondayAmName5],
            Strings.mondayAmFrom5: bedRota[Strings.mondayAmFrom5],
            Strings.mondayAmTo5: bedRota[Strings.mondayAmTo5],
            Strings.mondayPmName5: bedRota[Strings.mondayPmName5],
            Strings.mondayPmFrom5: bedRota[Strings.mondayPmFrom5],
            Strings.mondayPmTo5: bedRota[Strings.mondayPmTo5],
            Strings.mondayNightName5: bedRota[Strings.mondayNightName5],
            Strings.mondayNightFrom5: bedRota[Strings.mondayNightFrom5],
            Strings.mondayNightTo5: bedRota[Strings.mondayNightTo5],
            Strings.tuesdayAmName1: bedRota[Strings.tuesdayAmName1],
            Strings.tuesdayAmFrom1: bedRota[Strings.tuesdayAmFrom1],
            Strings.tuesdayAmTo1: bedRota[Strings.tuesdayAmTo1],
            Strings.tuesdayPmName1: bedRota[Strings.tuesdayPmName1],
            Strings.tuesdayPmFrom1: bedRota[Strings.tuesdayPmFrom1],
            Strings.tuesdayPmTo1: bedRota[Strings.tuesdayPmTo1],
            Strings.tuesdayNightName1: bedRota[Strings.tuesdayNightName1],
            Strings.tuesdayNightFrom1: bedRota[Strings.tuesdayNightFrom1],
            Strings.tuesdayNightTo1: bedRota[Strings.tuesdayNightTo1],
            Strings.tuesdayAmName2: bedRota[Strings.tuesdayAmName2],
            Strings.tuesdayAmFrom2: bedRota[Strings.tuesdayAmFrom2],
            Strings.tuesdayAmTo2: bedRota[Strings.tuesdayAmTo2],
            Strings.tuesdayPmName2: bedRota[Strings.tuesdayPmName2],
            Strings.tuesdayPmFrom2: bedRota[Strings.tuesdayPmFrom2],
            Strings.tuesdayPmTo2: bedRota[Strings.tuesdayPmTo2],
            Strings.tuesdayNightName2: bedRota[Strings.tuesdayNightName2],
            Strings.tuesdayNightFrom2: bedRota[Strings.tuesdayNightFrom2],
            Strings.tuesdayNightTo2: bedRota[Strings.tuesdayNightTo2],
            Strings.tuesdayAmName3: bedRota[Strings.tuesdayAmName3],
            Strings.tuesdayAmFrom3: bedRota[Strings.tuesdayAmFrom3],
            Strings.tuesdayAmTo3: bedRota[Strings.tuesdayAmTo3],
            Strings.tuesdayPmName3: bedRota[Strings.tuesdayPmName3],
            Strings.tuesdayPmFrom3: bedRota[Strings.tuesdayPmFrom3],
            Strings.tuesdayPmTo3: bedRota[Strings.tuesdayPmTo3],
            Strings.tuesdayNightName3: bedRota[Strings.tuesdayNightName3],
            Strings.tuesdayNightFrom3: bedRota[Strings.tuesdayNightFrom3],
            Strings.tuesdayNightTo3: bedRota[Strings.tuesdayNightTo3],
            Strings.tuesdayAmName4: bedRota[Strings.tuesdayAmName4],
            Strings.tuesdayAmFrom4: bedRota[Strings.tuesdayAmFrom4],
            Strings.tuesdayAmTo4: bedRota[Strings.tuesdayAmTo4],
            Strings.tuesdayPmName4: bedRota[Strings.tuesdayPmName4],
            Strings.tuesdayPmFrom4: bedRota[Strings.tuesdayPmFrom4],
            Strings.tuesdayPmTo4: bedRota[Strings.tuesdayPmTo4],
            Strings.tuesdayNightName4: bedRota[Strings.tuesdayNightName4],
            Strings.tuesdayNightFrom4: bedRota[Strings.tuesdayNightFrom4],
            Strings.tuesdayNightTo4: bedRota[Strings.tuesdayNightTo4],
            Strings.tuesdayAmName5: bedRota[Strings.tuesdayAmName5],
            Strings.tuesdayAmFrom5: bedRota[Strings.tuesdayAmFrom5],
            Strings.tuesdayAmTo5: bedRota[Strings.tuesdayAmTo5],
            Strings.tuesdayPmName5: bedRota[Strings.tuesdayPmName5],
            Strings.tuesdayPmFrom5: bedRota[Strings.tuesdayPmFrom5],
            Strings.tuesdayPmTo5: bedRota[Strings.tuesdayPmTo5],
            Strings.tuesdayNightName5: bedRota[Strings.tuesdayNightName5],
            Strings.tuesdayNightFrom5: bedRota[Strings.tuesdayNightFrom5],
            Strings.tuesdayNightTo5: bedRota[Strings.tuesdayNightTo5],
            Strings.wednesdayAmName1: bedRota[Strings.wednesdayAmName1],
            Strings.wednesdayAmFrom1: bedRota[Strings.wednesdayAmFrom1],
            Strings.wednesdayAmTo1: bedRota[Strings.wednesdayAmTo1],
            Strings.wednesdayPmName1: bedRota[Strings.wednesdayPmName1],
            Strings.wednesdayPmFrom1: bedRota[Strings.wednesdayPmFrom1],
            Strings.wednesdayPmTo1: bedRota[Strings.wednesdayPmTo1],
            Strings.wednesdayNightName1: bedRota[Strings.wednesdayNightName1],
            Strings.wednesdayNightFrom1: bedRota[Strings.wednesdayNightFrom1],
            Strings.wednesdayNightTo1: bedRota[Strings.wednesdayNightTo1],
            Strings.wednesdayAmName2: bedRota[Strings.wednesdayAmName2],
            Strings.wednesdayAmFrom2: bedRota[Strings.wednesdayAmFrom2],
            Strings.wednesdayAmTo2: bedRota[Strings.wednesdayAmTo2],
            Strings.wednesdayPmName2: bedRota[Strings.wednesdayPmName2],
            Strings.wednesdayPmFrom2: bedRota[Strings.wednesdayPmFrom2],
            Strings.wednesdayPmTo2: bedRota[Strings.wednesdayPmTo2],
            Strings.wednesdayNightName2: bedRota[Strings.wednesdayNightName2],
            Strings.wednesdayNightFrom2: bedRota[Strings.wednesdayNightFrom2],
            Strings.wednesdayNightTo2: bedRota[Strings.wednesdayNightTo2],
            Strings.wednesdayAmName3: bedRota[Strings.wednesdayAmName3],
            Strings.wednesdayAmFrom3: bedRota[Strings.wednesdayAmFrom3],
            Strings.wednesdayAmTo3: bedRota[Strings.wednesdayAmTo3],
            Strings.wednesdayPmName3: bedRota[Strings.wednesdayPmName3],
            Strings.wednesdayPmFrom3: bedRota[Strings.wednesdayPmFrom3],
            Strings.wednesdayPmTo3: bedRota[Strings.wednesdayPmTo3],
            Strings.wednesdayNightName3: bedRota[Strings.wednesdayNightName3],
            Strings.wednesdayNightFrom3: bedRota[Strings.wednesdayNightFrom3],
            Strings.wednesdayNightTo3: bedRota[Strings.wednesdayNightTo3],
            Strings.wednesdayAmName4: bedRota[Strings.wednesdayAmName4],
            Strings.wednesdayAmFrom4: bedRota[Strings.wednesdayAmFrom4],
            Strings.wednesdayAmTo4: bedRota[Strings.wednesdayAmTo4],
            Strings.wednesdayPmName4: bedRota[Strings.wednesdayPmName4],
            Strings.wednesdayPmFrom4: bedRota[Strings.wednesdayPmFrom4],
            Strings.wednesdayPmTo4: bedRota[Strings.wednesdayPmTo4],
            Strings.wednesdayNightName4: bedRota[Strings.wednesdayNightName4],
            Strings.wednesdayNightFrom4: bedRota[Strings.wednesdayNightFrom4],
            Strings.wednesdayNightTo4: bedRota[Strings.wednesdayNightTo4],
            Strings.wednesdayAmName5: bedRota[Strings.wednesdayAmName5],
            Strings.wednesdayAmFrom5: bedRota[Strings.wednesdayAmFrom5],
            Strings.wednesdayAmTo5: bedRota[Strings.wednesdayAmTo5],
            Strings.wednesdayPmName5: bedRota[Strings.wednesdayPmName5],
            Strings.wednesdayPmFrom5: bedRota[Strings.wednesdayPmFrom5],
            Strings.wednesdayPmTo5: bedRota[Strings.wednesdayPmTo5],
            Strings.wednesdayNightName5: bedRota[Strings.wednesdayNightName5],
            Strings.wednesdayNightFrom5: bedRota[Strings.wednesdayNightFrom5],
            Strings.wednesdayNightTo5: bedRota[Strings.wednesdayNightTo5],
            Strings.thursdayAmName1: bedRota[Strings.thursdayAmName1],
            Strings.thursdayAmFrom1: bedRota[Strings.thursdayAmFrom1],
            Strings.thursdayAmTo1: bedRota[Strings.thursdayAmTo1],
            Strings.thursdayPmName1: bedRota[Strings.thursdayPmName1],
            Strings.thursdayPmFrom1: bedRota[Strings.thursdayPmFrom1],
            Strings.thursdayPmTo1: bedRota[Strings.thursdayPmTo1],
            Strings.thursdayNightName1: bedRota[Strings.thursdayNightName1],
            Strings.thursdayNightFrom1: bedRota[Strings.thursdayNightFrom1],
            Strings.thursdayNightTo1: bedRota[Strings.thursdayNightTo1],
            Strings.thursdayAmName2: bedRota[Strings.thursdayAmName2],
            Strings.thursdayAmFrom2: bedRota[Strings.thursdayAmFrom2],
            Strings.thursdayAmTo2: bedRota[Strings.thursdayAmTo2],
            Strings.thursdayPmName2: bedRota[Strings.thursdayPmName2],
            Strings.thursdayPmFrom2: bedRota[Strings.thursdayPmFrom2],
            Strings.thursdayPmTo2: bedRota[Strings.thursdayPmTo2],
            Strings.thursdayNightName2: bedRota[Strings.thursdayNightName2],
            Strings.thursdayNightFrom2: bedRota[Strings.thursdayNightFrom2],
            Strings.thursdayNightTo2: bedRota[Strings.thursdayNightTo2],
            Strings.thursdayAmName3: bedRota[Strings.thursdayAmName3],
            Strings.thursdayAmFrom3: bedRota[Strings.thursdayAmFrom3],
            Strings.thursdayAmTo3: bedRota[Strings.thursdayAmTo3],
            Strings.thursdayPmName3: bedRota[Strings.thursdayPmName3],
            Strings.thursdayPmFrom3: bedRota[Strings.thursdayPmFrom3],
            Strings.thursdayPmTo3: bedRota[Strings.thursdayPmTo3],
            Strings.thursdayNightName3: bedRota[Strings.thursdayNightName3],
            Strings.thursdayNightFrom3: bedRota[Strings.thursdayNightFrom3],
            Strings.thursdayNightTo3: bedRota[Strings.thursdayNightTo3],
            Strings.thursdayAmName4: bedRota[Strings.thursdayAmName4],
            Strings.thursdayAmFrom4: bedRota[Strings.thursdayAmFrom4],
            Strings.thursdayAmTo4: bedRota[Strings.thursdayAmTo4],
            Strings.thursdayPmName4: bedRota[Strings.thursdayPmName4],
            Strings.thursdayPmFrom4: bedRota[Strings.thursdayPmFrom4],
            Strings.thursdayPmTo4: bedRota[Strings.thursdayPmTo4],
            Strings.thursdayNightName4: bedRota[Strings.thursdayNightName4],
            Strings.thursdayNightFrom4: bedRota[Strings.thursdayNightFrom4],
            Strings.thursdayNightTo4: bedRota[Strings.thursdayNightTo4],
            Strings.thursdayAmName5: bedRota[Strings.thursdayAmName5],
            Strings.thursdayAmFrom5: bedRota[Strings.thursdayAmFrom5],
            Strings.thursdayAmTo5: bedRota[Strings.thursdayAmTo5],
            Strings.thursdayPmName5: bedRota[Strings.thursdayPmName5],
            Strings.thursdayPmFrom5: bedRota[Strings.thursdayPmFrom5],
            Strings.thursdayPmTo5: bedRota[Strings.thursdayPmTo5],
            Strings.thursdayNightName5: bedRota[Strings.thursdayNightName5],
            Strings.thursdayNightFrom5: bedRota[Strings.thursdayNightFrom5],
            Strings.thursdayNightTo5: bedRota[Strings.thursdayNightTo5],
            Strings.fridayAmName1: bedRota[Strings.fridayAmName1],
            Strings.fridayAmFrom1: bedRota[Strings.fridayAmFrom1],
            Strings.fridayAmTo1: bedRota[Strings.fridayAmTo1],
            Strings.fridayPmName1: bedRota[Strings.fridayPmName1],
            Strings.fridayPmFrom1: bedRota[Strings.fridayPmFrom1],
            Strings.fridayPmTo1: bedRota[Strings.fridayPmTo1],
            Strings.fridayNightName1: bedRota[Strings.fridayNightName1],
            Strings.fridayNightFrom1: bedRota[Strings.fridayNightFrom1],
            Strings.fridayNightTo1: bedRota[Strings.fridayNightTo1],
            Strings.fridayAmName2: bedRota[Strings.fridayAmName2],
            Strings.fridayAmFrom2: bedRota[Strings.fridayAmFrom2],
            Strings.fridayAmTo2: bedRota[Strings.fridayAmTo2],
            Strings.fridayPmName2: bedRota[Strings.fridayPmName2],
            Strings.fridayPmFrom2: bedRota[Strings.fridayPmFrom2],
            Strings.fridayPmTo2: bedRota[Strings.fridayPmTo2],
            Strings.fridayNightName2: bedRota[Strings.fridayNightName2],
            Strings.fridayNightFrom2: bedRota[Strings.fridayNightFrom2],
            Strings.fridayNightTo2: bedRota[Strings.fridayNightTo2],
            Strings.fridayAmName3: bedRota[Strings.fridayAmName3],
            Strings.fridayAmFrom3: bedRota[Strings.fridayAmFrom3],
            Strings.fridayAmTo3: bedRota[Strings.fridayAmTo3],
            Strings.fridayPmName3: bedRota[Strings.fridayPmName3],
            Strings.fridayPmFrom3: bedRota[Strings.fridayPmFrom3],
            Strings.fridayPmTo3: bedRota[Strings.fridayPmTo3],
            Strings.fridayNightName3: bedRota[Strings.fridayNightName3],
            Strings.fridayNightFrom3: bedRota[Strings.fridayNightFrom3],
            Strings.fridayNightTo3: bedRota[Strings.fridayNightTo3],
            Strings.fridayAmName4: bedRota[Strings.fridayAmName4],
            Strings.fridayAmFrom4: bedRota[Strings.fridayAmFrom4],
            Strings.fridayAmTo4: bedRota[Strings.fridayAmTo4],
            Strings.fridayPmName4: bedRota[Strings.fridayPmName4],
            Strings.fridayPmFrom4: bedRota[Strings.fridayPmFrom4],
            Strings.fridayPmTo4: bedRota[Strings.fridayPmTo4],
            Strings.fridayNightName4: bedRota[Strings.fridayNightName4],
            Strings.fridayNightFrom4: bedRota[Strings.fridayNightFrom4],
            Strings.fridayNightTo4: bedRota[Strings.fridayNightTo4],
            Strings.fridayAmName5: bedRota[Strings.fridayAmName5],
            Strings.fridayAmFrom5: bedRota[Strings.fridayAmFrom5],
            Strings.fridayAmTo5: bedRota[Strings.fridayAmTo5],
            Strings.fridayPmName5: bedRota[Strings.fridayPmName5],
            Strings.fridayPmFrom5: bedRota[Strings.fridayPmFrom5],
            Strings.fridayPmTo5: bedRota[Strings.fridayPmTo5],
            Strings.fridayNightName5: bedRota[Strings.fridayNightName5],
            Strings.fridayNightFrom5: bedRota[Strings.fridayNightFrom5],
            Strings.fridayNightTo5: bedRota[Strings.fridayNightTo5],
            Strings.saturdayAmName1: bedRota[Strings.saturdayAmName1],
            Strings.saturdayAmFrom1: bedRota[Strings.saturdayAmFrom1],
            Strings.saturdayAmTo1: bedRota[Strings.saturdayAmTo1],
            Strings.saturdayPmName1: bedRota[Strings.saturdayPmName1],
            Strings.saturdayPmFrom1: bedRota[Strings.saturdayPmFrom1],
            Strings.saturdayPmTo1: bedRota[Strings.saturdayPmTo1],
            Strings.saturdayNightName1: bedRota[Strings.saturdayNightName1],
            Strings.saturdayNightFrom1: bedRota[Strings.saturdayNightFrom1],
            Strings.saturdayNightTo1: bedRota[Strings.saturdayNightTo1],
            Strings.saturdayAmName2: bedRota[Strings.saturdayAmName2],
            Strings.saturdayAmFrom2: bedRota[Strings.saturdayAmFrom2],
            Strings.saturdayAmTo2: bedRota[Strings.saturdayAmTo2],
            Strings.saturdayPmName2: bedRota[Strings.saturdayPmName2],
            Strings.saturdayPmFrom2: bedRota[Strings.saturdayPmFrom2],
            Strings.saturdayPmTo2: bedRota[Strings.saturdayPmTo2],
            Strings.saturdayNightName2: bedRota[Strings.saturdayNightName2],
            Strings.saturdayNightFrom2: bedRota[Strings.saturdayNightFrom2],
            Strings.saturdayNightTo2: bedRota[Strings.saturdayNightTo2],
            Strings.saturdayAmName3: bedRota[Strings.saturdayAmName3],
            Strings.saturdayAmFrom3: bedRota[Strings.saturdayAmFrom3],
            Strings.saturdayAmTo3: bedRota[Strings.saturdayAmTo3],
            Strings.saturdayPmName3: bedRota[Strings.saturdayPmName3],
            Strings.saturdayPmFrom3: bedRota[Strings.saturdayPmFrom3],
            Strings.saturdayPmTo3: bedRota[Strings.saturdayPmTo3],
            Strings.saturdayNightName3: bedRota[Strings.saturdayNightName3],
            Strings.saturdayNightFrom3: bedRota[Strings.saturdayNightFrom3],
            Strings.saturdayNightTo3: bedRota[Strings.saturdayNightTo3],
            Strings.saturdayAmName4: bedRota[Strings.saturdayAmName4],
            Strings.saturdayAmFrom4: bedRota[Strings.saturdayAmFrom4],
            Strings.saturdayAmTo4: bedRota[Strings.saturdayAmTo4],
            Strings.saturdayPmName4: bedRota[Strings.saturdayPmName4],
            Strings.saturdayPmFrom4: bedRota[Strings.saturdayPmFrom4],
            Strings.saturdayPmTo4: bedRota[Strings.saturdayPmTo4],
            Strings.saturdayNightName4: bedRota[Strings.saturdayNightName4],
            Strings.saturdayNightFrom4: bedRota[Strings.saturdayNightFrom4],
            Strings.saturdayNightTo4: bedRota[Strings.saturdayNightTo4],
            Strings.saturdayAmName5: bedRota[Strings.saturdayAmName5],
            Strings.saturdayAmFrom5: bedRota[Strings.saturdayAmFrom5],
            Strings.saturdayAmTo5: bedRota[Strings.saturdayAmTo5],
            Strings.saturdayPmName5: bedRota[Strings.saturdayPmName5],
            Strings.saturdayPmFrom5: bedRota[Strings.saturdayPmFrom5],
            Strings.saturdayPmTo5: bedRota[Strings.saturdayPmTo5],
            Strings.saturdayNightName5: bedRota[Strings.saturdayNightName5],
            Strings.saturdayNightFrom5: bedRota[Strings.saturdayNightFrom5],
            Strings.saturdayNightTo5: bedRota[Strings.saturdayNightTo5],
            Strings.sundayAmName1: bedRota[Strings.sundayAmName1],
            Strings.sundayAmFrom1: bedRota[Strings.sundayAmFrom1],
            Strings.sundayAmTo1: bedRota[Strings.sundayAmTo1],
            Strings.sundayPmName1: bedRota[Strings.sundayPmName1],
            Strings.sundayPmFrom1: bedRota[Strings.sundayPmFrom1],
            Strings.sundayPmTo1: bedRota[Strings.sundayPmTo1],
            Strings.sundayNightName1: bedRota[Strings.sundayNightName1],
            Strings.sundayNightFrom1: bedRota[Strings.sundayNightFrom1],
            Strings.sundayNightTo1: bedRota[Strings.sundayNightTo1],
            Strings.sundayAmName2: bedRota[Strings.sundayAmName2],
            Strings.sundayAmFrom2: bedRota[Strings.sundayAmFrom2],
            Strings.sundayAmTo2: bedRota[Strings.sundayAmTo2],
            Strings.sundayPmName2: bedRota[Strings.sundayPmName2],
            Strings.sundayPmFrom2: bedRota[Strings.sundayPmFrom2],
            Strings.sundayPmTo2: bedRota[Strings.sundayPmTo2],
            Strings.sundayNightName2: bedRota[Strings.sundayNightName2],
            Strings.sundayNightFrom2: bedRota[Strings.sundayNightFrom2],
            Strings.sundayNightTo2: bedRota[Strings.sundayNightTo2],
            Strings.sundayAmName3: bedRota[Strings.sundayAmName3],
            Strings.sundayAmFrom3: bedRota[Strings.sundayAmFrom3],
            Strings.sundayAmTo3: bedRota[Strings.sundayAmTo3],
            Strings.sundayPmName3: bedRota[Strings.sundayPmName3],
            Strings.sundayPmFrom3: bedRota[Strings.sundayPmFrom3],
            Strings.sundayPmTo3: bedRota[Strings.sundayPmTo3],
            Strings.sundayNightName3: bedRota[Strings.sundayNightName3],
            Strings.sundayNightFrom3: bedRota[Strings.sundayNightFrom3],
            Strings.sundayNightTo3: bedRota[Strings.sundayNightTo3],
            Strings.sundayAmName4: bedRota[Strings.sundayAmName4],
            Strings.sundayAmFrom4: bedRota[Strings.sundayAmFrom4],
            Strings.sundayAmTo4: bedRota[Strings.sundayAmTo4],
            Strings.sundayPmName4: bedRota[Strings.sundayPmName4],
            Strings.sundayPmFrom4: bedRota[Strings.sundayPmFrom4],
            Strings.sundayPmTo4: bedRota[Strings.sundayPmTo4],
            Strings.sundayNightName4: bedRota[Strings.sundayNightName4],
            Strings.sundayNightFrom4: bedRota[Strings.sundayNightFrom4],
            Strings.sundayNightTo4: bedRota[Strings.sundayNightTo4],
            Strings.sundayAmName5: bedRota[Strings.sundayAmName5],
            Strings.sundayAmFrom5: bedRota[Strings.sundayAmFrom5],
            Strings.sundayAmTo5: bedRota[Strings.sundayAmTo5],
            Strings.sundayPmName5: bedRota[Strings.sundayPmName5],
            Strings.sundayPmFrom5: bedRota[Strings.sundayPmFrom5],
            Strings.sundayPmTo5: bedRota[Strings.sundayPmTo5],
            Strings.sundayNightName5: bedRota[Strings.sundayNightName5],
            Strings.sundayNightFrom5: bedRota[Strings.sundayNightFrom5],
            Strings.sundayNightTo5: bedRota[Strings.sundayNightTo5],
            Strings.timestamp: FieldValue.serverTimestamp(),
            Strings.serverUploaded: 1,
          });

          await deletePendingRecord(bedRota[Strings.localId]);
          success = true;

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


  Future<void> setUpEditedBedRota() async{

    Map<String, dynamic> editedReport = editedBedRota(selectedBedRota);
    Map<String, dynamic> localData = Map.from(editedReport);
    await _databaseHelper.deleteAllRows(Strings.editedBedRotaTable);
    await _databaseHelper.add(Strings.editedBedRotaTable, localData);

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
              borderRadius: BorderRadius.all(Radius.circular(5)),
              border: Border.all(width: 1, color: PdfColors.grey),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(value, style: TextStyle(fontSize: 9)),
              ],
            ),
          ));
    }

    Widget singleLineFieldSmall(String text, String value){
      return Column(
          children: [
            Row(
                children: [
                  Container(width: 90, child: Text(text, style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 9))),
                  SizedBox(width: 5),
                  ConstrainedBox(constraints: BoxConstraints(minHeight: 20),
                      child: Container(
                        width: 100,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          border: Border.all(width: 1, color: PdfColors.grey),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(value == null ? '' : value, style: TextStyle(fontSize: 9)),
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
                  Container(width: 90, child: Text(text, style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 9))),
                  SizedBox(width: 5),
                  small ? ConstrainedBox(constraints: BoxConstraints(minHeight: 20),
                      child: Container(
                        width: 100,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          border: Border.all(width: 1, color: PdfColors.grey),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(value == null ? '' : value, style: TextStyle(fontSize: 9)),
                          ],
                        ),
                      )) :Expanded(child: ConstrainedBox(constraints: BoxConstraints(minHeight: 20),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          border: Border.all(width: 1, color: PdfColors.grey),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(value == null ? '' : value, style: TextStyle(fontSize: 9)),
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
                  Container(width: 90, child: Text(text1, style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 9))),
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
                                height: signature.height))))) : Text(value1 == null || value1 == 'signature' ? '' : value1, style: TextStyle(fontSize: 9))
                          ],
                        ),
                      ))),
                  SizedBox(width: 10),
                  Container(width: 90, child: Text(text2, style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 9))),
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
                                height: signature.height))))) : Text(value2 == null || value2 == 'signature' ? '' : value2, style: TextStyle(fontSize: 9)),
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
                  Container(width: 70, child: Text(text1, style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 9))),
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
                            Text(value1 == null ? '' : value1, style: TextStyle(fontSize: 9)),
                          ],
                        ),
                      ))),
                  SizedBox(width: 5),
                  Container(width: 70, child: Text(text2, style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 9))),
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
                            signature == null ? Text(value2 == null ? '' : value2, style: TextStyle(fontSize: 9)) : signature == null ? Text('') : Container(height: 20, child: FittedBox(alignment: Alignment.centerLeft, child: Image(ImageProxy(PdfImage(doc,
                                image: signature.data.buffer
                                    .asUint8List(),
                                width: signature.width,
                                height: signature.height))))),
                          ],
                        ),
                      ))),
                  SizedBox(width: 5),
                  Container(width: 70, child: Text(text3, style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 9))),
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
                            signature == null ? Text(value3 == null ? '' : value3, style: TextStyle(fontSize: 9)) : signature == null ? Text('') : Container(height: 20, child: FittedBox(alignment: Alignment.centerLeft, child: Image(ImageProxy(PdfImage(doc,
                                image: signature.data.buffer
                                    .asUint8List(),
                                width: signature.width,
                                height: signature.height))))),
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
                  Container(width: 100, child: Text(text, style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 9))),
                  Text('Yes', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 9)),
                  Container(width: 5),
                  Container(width: 15, height: 15, padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(width: 1, color: PdfColors.grey)),
                      child: Center(child: Text(selectedBedRota[yesString] == null || selectedBedRota[yesString] == 0 ? '' : 'X', textAlign: TextAlign.center ,style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)))),
                  Container(width: 10),
                  Text('No', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 9)),
                  Container(width: 5),
                  Container(width: 15, height: 15, padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(width: 1, color: PdfColors.grey)),
                      child: Center(child: Text(selectedBedRota[noString] == null || selectedBedRota[noString] == 0 ? '' : 'X', textAlign: TextAlign.center ,style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)))),
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
              Text(text2, style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontSize: 9)),
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
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          border: Border.all(width: 1, color: PdfColors.grey),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(value1 == null ? '' : dateFormat.format(DateTime.parse(value1)), style: TextStyle(fontSize: 9)),
                          ],
                        ),
                      )),
                  Container(width: 2),
                  ConstrainedBox(constraints: BoxConstraints(minHeight: 20),
                      child: Container(
                        width: 60,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          border: Border.all(width: 1, color: PdfColors.grey),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(value2 == null ? '' : timeFormat.format(DateTime.parse(value2)), style: TextStyle(fontSize: 9)),
                          ],
                        ),
                      )),
                  Container(width: 2),
                  ConstrainedBox(constraints: BoxConstraints(minHeight: 20),
                      child: Container(
                        width: 60,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          border: Border.all(width: 1, color: PdfColors.grey),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(value3 == null ? '' : timeFormat.format(DateTime.parse(value3)), style: TextStyle(fontSize: 9)),
                          ],
                        ),
                      )),
                  Container(width: 2),
                  Expanded(child: Expanded(child: ConstrainedBox(constraints: BoxConstraints(minHeight: 20),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          border: Border.all(width: 1, color: PdfColors.grey),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(value4 == null ? '' : GlobalFunctions.decryptString(value4), style: TextStyle(fontSize: 9)),
                          ],
                        ),
                      )))),
                  Container(width: 2),
                  ConstrainedBox(constraints: BoxConstraints(minHeight: 20),
                      child: Container(
                        width: 60,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          border: Border.all(width: 1, color: PdfColors.grey),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(value5 == null ? '' : GlobalFunctions.decryptString(value5), style: TextStyle(fontSize: 9)),
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
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          border: Border.all(width: 1, color: PdfColors.grey),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(value1 == null ? '' : GlobalFunctions.decryptString(value1), style: TextStyle(fontSize: 9)),
                          ],
                        ),
                      )))),
                  Container(width: 2),
                  Expanded(child: Expanded(child: ConstrainedBox(constraints: BoxConstraints(minHeight: 20),
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
                            Text(value2 == null ? '' : GlobalFunctions.decryptString(value2), style: TextStyle(fontSize: 9)),
                          ],
                        ),
                      )))),
                  Container(width: 2),
                  Expanded(child: Expanded(child: ConstrainedBox(constraints: BoxConstraints(minHeight: 20),
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
                            Text(value3 == null ? '' : GlobalFunctions.decryptString(value3), style: TextStyle(fontSize: 9)),
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
            Text(text, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9)),
            Container(height: 5),
            Row(
                children: [
                  Text('Yes', style: TextStyle(fontSize: 9)),
                  Container(width: 5),
                  Container(width: 15, height: 15, padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(width: 1, color: PdfColors.grey)),
                      child: Center(child: Text(value1 == null || value1 == 0 ? '' : 'X', textAlign: TextAlign.center ,style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)))),
                  Container(width: 10),
                  Text('No', style: TextStyle(fontSize: 9)),
                  Container(width: 5),
                  Container(width: 15, height: 15, padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(width: 1, color: PdfColors.grey)),
                      child: Center(child: Text(value2 == null || value2 == 0 ? '' : 'X', textAlign: TextAlign.center ,style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)))),
                ]
            ),
            Container(height: 5)
          ]);
    }

    Widget headingText(String value, [bool margin = false]){
      return margin ? Container(margin: EdgeInsets.all(2), child: Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9))) : Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9));
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



      return margin ? Container(margin: EdgeInsets.all(2), child: Text(value == null ? '' : value, style: TextStyle(fontSize: 9))) : Text(value == null ? '' : value, style: TextStyle(fontSize: 9));
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
                  Text(date, style: TextStyle(fontSize: 9))
                ])),
            Container(
                padding: EdgeInsets.all(2),
                width: 30, child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(startTime, style: TextStyle(fontSize: 9))
                ])),
            Container(
                padding: EdgeInsets.all(2),
                width: 30, child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(endTime, style: TextStyle(fontSize: 9))
                ])),
            Container(
                padding: EdgeInsets.all(2),
                width: 70, child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(name, style: TextStyle(fontSize: 9))
                ])),
            Container(
                padding: EdgeInsets.all(2),
                width: 50, child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(rmnHca, style: TextStyle(fontSize: 9))
                ]))
          ]
      );
    }

    double _buildDayHeight(){
      double height;
      int count = 1;

      if(selectedBedRota[Strings.mondayAmName2] != '' || selectedBedRota[Strings.mondayAmFrom2] != null || selectedBedRota[Strings.mondayAmTo2] != null) count ++;
      if(selectedBedRota[Strings.mondayAmName3] != '' || selectedBedRota[Strings.mondayAmFrom3] != null || selectedBedRota[Strings.mondayAmTo3] != null) count ++;
      if(selectedBedRota[Strings.mondayAmName4] != '' || selectedBedRota[Strings.mondayAmFrom4] != null || selectedBedRota[Strings.mondayAmTo4] != null) count ++;
      if(selectedBedRota[Strings.mondayAmName5] != '' || selectedBedRota[Strings.mondayAmFrom5] != null || selectedBedRota[Strings.mondayAmTo5] != null) count ++;

      if(count == 2) height = 31;
      if(count == 3) height = 30;
      if(count == 4) height = 40;
      if(count == 5) height = 50;

      return height;
    }


    try {

      Document pdf;
      pdf = Document();
      PdfDocument pdfDoc = pdf.document;
      final pegasusLogo = MemoryImage((await rootBundle.load('assets/images/pegasusLogo.png')).buffer.asUint8List(),);


      pdf.addPage(MultiPage(orientation: PageOrientation.landscape,
          theme: ThemeData.withFont(base: ttf, bold: ttfBold),
          pageFormat: PdfPageFormat.a4,
          crossAxisAlignment: CrossAxisAlignment.start,
          margin: EdgeInsets.all(20),
          // footer: (Context context) {
          //   return Container(
          //       alignment: Alignment.centerRight,
          //       margin: const EdgeInsets.only(top: 5),
          //       child: Text('Bed Watch Rota - Page ${context.pageNumber} of ${context.pagesCount}',
          //           style: TextStyle(color: PdfColors.grey, fontSize: 9)));
          // },
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
                          sectionTitle('Reference'),
                          SizedBox(width: 10),
                          textField(TextOption.PlainText, selectedBedRota[Strings.jobRef]),
                        ]),
                      ]
                  ),

                  Container(height: 30, child: Image(pegasusLogo)
                  ),

                ]
            ),
            Center(child: Text('Bed Watch Rota', style: TextStyle(color: PdfColor.fromInt(bluePurpleInt), fontWeight: FontWeight.bold))),
            Container(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(width: 100),
              Container(height: 20, decoration: BoxDecoration(color: PdfColors.grey, border: Border.all(width: 1, color: PdfColors.black),),width: 220, child: Text('AM', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
              Container(height: 20, decoration: BoxDecoration(color: PdfColors.grey, border: Border.all(width: 1, color: PdfColors.black),),width: 220, child: Text('PM', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
              Container(height: 20, decoration: BoxDecoration(color: PdfColors.grey, border: Border.all(width: 1, color: PdfColors.black),),width: 220, child: Text('Night', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
            ]),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(height: 66, decoration: BoxDecoration(color: PdfColors.grey, border: Border.all(width: 1, color: PdfColors.black),),width: 100, child: Text('Monday', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
              Container(height: 66, padding: EdgeInsets.all(2), decoration: BoxDecoration(border: Border.all(width: 1, color: PdfColors.black),),width: 220, child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                  selectedBedRota[Strings.mondayAmName1] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.mondayAmName1]), style: TextStyle(fontSize: 9)): Container(),
                  selectedBedRota[Strings.mondayAmFrom1] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.mondayAmFrom1]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                  selectedBedRota[Strings.mondayAmTo1] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.mondayAmTo1]), style: TextStyle(fontSize: 9)): Container(),
                  ]),
                  Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        selectedBedRota[Strings.mondayAmName2] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.mondayAmName2]), style: TextStyle(fontSize: 9)): Container(),
                        selectedBedRota[Strings.mondayAmFrom2] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.mondayAmFrom2]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                        selectedBedRota[Strings.mondayAmTo2] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.mondayAmTo2]), style: TextStyle(fontSize: 9)): Container(),
                      ]),
                  Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        selectedBedRota[Strings.mondayAmName3] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.mondayAmName3]), style: TextStyle(fontSize: 9)): Container(),
                        selectedBedRota[Strings.mondayAmFrom3] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.mondayAmFrom3]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                        selectedBedRota[Strings.mondayAmTo3] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.mondayAmTo3]), style: TextStyle(fontSize: 9)): Container(),
                      ]),
                  Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        selectedBedRota[Strings.mondayAmName4] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.mondayAmName4]), style: TextStyle(fontSize: 9)): Container(),
                        selectedBedRota[Strings.mondayAmFrom4] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.mondayAmFrom4]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                        selectedBedRota[Strings.mondayAmTo4] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.mondayAmTo4]), style: TextStyle(fontSize: 9)): Container(),
                      ]),
                  Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        selectedBedRota[Strings.mondayAmName5] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.mondayAmName5]), style: TextStyle(fontSize: 9)): Container(),
                        selectedBedRota[Strings.mondayAmFrom5] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.mondayAmFrom5]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                        selectedBedRota[Strings.mondayAmTo5] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.mondayAmTo5]), style: TextStyle(fontSize: 9)): Container(),
                      ]),
                ]
              )),
              Container(height: 66, padding: EdgeInsets.all(2), decoration: BoxDecoration(border: Border.all(width: 1, color: PdfColors.black),),width: 220, child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.mondayPmName1] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.mondayPmName1]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.mondayPmFrom1] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.mondayPmFrom1]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.mondayPmTo1] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.mondayPmTo1]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.mondayPmName2] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.mondayPmName2]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.mondayPmFrom2] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.mondayPmFrom2]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.mondayPmTo2] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.mondayPmTo2]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.mondayPmName3] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.mondayPmName3]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.mondayPmFrom3] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.mondayPmFrom3]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.mondayPmTo3] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.mondayPmTo3]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.mondayPmName4] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.mondayPmName4]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.mondayPmFrom4] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.mondayPmFrom4]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.mondayPmTo4] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.mondayPmTo4]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.mondayPmName5] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.mondayPmName5]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.mondayPmFrom5] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.mondayPmFrom5]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.mondayPmTo5] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.mondayPmTo5]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                  ]
              )),
              Container(height: 66, padding: EdgeInsets.all(2), decoration: BoxDecoration(border: Border.all(width: 1, color: PdfColors.black),),width: 220, child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.mondayNightName1] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.mondayNightName1]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.mondayNightFrom1] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.mondayNightFrom1]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.mondayNightTo1] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.mondayNightTo1]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.mondayNightName2] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.mondayNightName2]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.mondayNightFrom2] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.mondayNightFrom2]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.mondayNightTo2] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.mondayNightTo2]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.mondayNightName3] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.mondayNightName3]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.mondayNightFrom3] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.mondayNightFrom3]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.mondayNightTo3] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.mondayNightTo3]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.mondayNightName4] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.mondayNightName4]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.mondayNightFrom4] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.mondayNightFrom4]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.mondayNightTo4] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.mondayNightTo4]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.mondayNightName5] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.mondayNightName5]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.mondayNightFrom5] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.mondayNightFrom5]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.mondayNightTo5] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.mondayNightTo5]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                  ]
              )),
            ]),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(height: 66, decoration: BoxDecoration(color: PdfColors.grey, border: Border.all(width: 1, color: PdfColors.black),),width: 100, child: Text('Tuesday', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
              Container(height: 66, padding: EdgeInsets.all(2), decoration: BoxDecoration(border: Border.all(width: 1, color: PdfColors.black),),width: 220, child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.tuesdayAmName1] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.tuesdayAmName1]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.tuesdayAmFrom1] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.tuesdayAmFrom1]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.tuesdayAmTo1] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.tuesdayAmTo1]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.tuesdayAmName2] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.tuesdayAmName2]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.tuesdayAmFrom2] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.tuesdayAmFrom2]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.tuesdayAmTo2] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.tuesdayAmTo2]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.tuesdayAmName3] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.tuesdayAmName3]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.tuesdayAmFrom3] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.tuesdayAmFrom3]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.tuesdayAmTo3] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.tuesdayAmTo3]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.tuesdayAmName4] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.tuesdayAmName4]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.tuesdayAmFrom4] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.tuesdayAmFrom4]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.tuesdayAmTo4] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.tuesdayAmTo4]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.tuesdayAmName5] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.tuesdayAmName5]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.tuesdayAmFrom5] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.tuesdayAmFrom5]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.tuesdayAmTo5] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.tuesdayAmTo5]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                  ]
              )),
              Container(height: 66, padding: EdgeInsets.all(2), decoration: BoxDecoration(border: Border.all(width: 1, color: PdfColors.black),),width: 220, child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.tuesdayPmName1] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.tuesdayPmName1]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.tuesdayPmFrom1] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.tuesdayPmFrom1]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.tuesdayPmTo1] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.tuesdayPmTo1]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.tuesdayPmName2] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.tuesdayPmName2]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.tuesdayPmFrom2] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.tuesdayPmFrom2]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.tuesdayPmTo2] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.tuesdayPmTo2]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.tuesdayPmName3] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.tuesdayPmName3]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.tuesdayPmFrom3] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.tuesdayPmFrom3]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.tuesdayPmTo3] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.tuesdayPmTo3]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.tuesdayPmName4] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.tuesdayPmName4]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.tuesdayPmFrom4] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.tuesdayPmFrom4]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.tuesdayPmTo4] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.tuesdayPmTo4]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.tuesdayPmName5] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.tuesdayPmName5]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.tuesdayPmFrom5] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.tuesdayPmFrom5]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.tuesdayPmTo5] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.tuesdayPmTo5]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                  ]
              )),
              Container(height: 66, padding: EdgeInsets.all(2), decoration: BoxDecoration(border: Border.all(width: 1, color: PdfColors.black),),width: 220, child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.tuesdayNightName1] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.tuesdayNightName1]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.tuesdayNightFrom1] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.tuesdayNightFrom1]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.tuesdayNightTo1] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.tuesdayNightTo1]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.tuesdayNightName2] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.tuesdayNightName2]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.tuesdayNightFrom2] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.tuesdayNightFrom2]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.tuesdayNightTo2] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.tuesdayNightTo2]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.tuesdayNightName3] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.tuesdayNightName3]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.tuesdayNightFrom3] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.tuesdayNightFrom3]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.tuesdayNightTo3] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.tuesdayNightTo3]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.tuesdayNightName4] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.tuesdayNightName4]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.tuesdayNightFrom4] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.tuesdayNightFrom4]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.tuesdayNightTo4] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.tuesdayNightTo4]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.tuesdayNightName5] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.tuesdayNightName5]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.tuesdayNightFrom5] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.tuesdayNightFrom5]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.tuesdayNightTo5] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.tuesdayNightTo5]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                  ]
              )),
            ]),


            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(height: 66, decoration: BoxDecoration(color: PdfColors.grey, border: Border.all(width: 1, color: PdfColors.black),),width: 100, child: Text('Wednesday', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
              Container(height: 66, padding: EdgeInsets.all(2), decoration: BoxDecoration(border: Border.all(width: 1, color: PdfColors.black),),width: 220, child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.wednesdayAmName1] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.wednesdayAmName1]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.wednesdayAmFrom1] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.wednesdayAmFrom1]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.wednesdayAmTo1] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.wednesdayAmTo1]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.wednesdayAmName2] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.wednesdayAmName2]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.wednesdayAmFrom2] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.wednesdayAmFrom2]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.wednesdayAmTo2] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.wednesdayAmTo2]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.wednesdayAmName3] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.wednesdayAmName3]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.wednesdayAmFrom3] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.wednesdayAmFrom3]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.wednesdayAmTo3] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.wednesdayAmTo3]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.wednesdayAmName4] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.wednesdayAmName4]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.wednesdayAmFrom4] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.wednesdayAmFrom4]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.wednesdayAmTo4] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.wednesdayAmTo4]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.wednesdayAmName5] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.wednesdayAmName5]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.wednesdayAmFrom5] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.wednesdayAmFrom5]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.wednesdayAmTo5] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.wednesdayAmTo5]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                  ]
              )),
              Container(height: 66, padding: EdgeInsets.all(2), decoration: BoxDecoration(border: Border.all(width: 1, color: PdfColors.black),),width: 220, child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.wednesdayPmName1] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.wednesdayPmName1]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.wednesdayPmFrom1] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.wednesdayPmFrom1]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.wednesdayPmTo1] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.wednesdayPmTo1]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.wednesdayPmName2] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.wednesdayPmName2]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.wednesdayPmFrom2] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.wednesdayPmFrom2]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.wednesdayPmTo2] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.wednesdayPmTo2]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.wednesdayPmName3] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.wednesdayPmName3]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.wednesdayPmFrom3] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.wednesdayPmFrom3]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.wednesdayPmTo3] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.wednesdayPmTo3]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.wednesdayPmName4] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.wednesdayPmName4]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.wednesdayPmFrom4] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.wednesdayPmFrom4]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.wednesdayPmTo4] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.wednesdayPmTo4]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.wednesdayPmName5] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.wednesdayPmName5]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.wednesdayPmFrom5] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.wednesdayPmFrom5]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.wednesdayPmTo5] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.wednesdayPmTo5]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                  ]
              )),
              Container(height: 66, padding: EdgeInsets.all(2), decoration: BoxDecoration(border: Border.all(width: 1, color: PdfColors.black),),width: 220, child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.wednesdayNightName1] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.wednesdayNightName1]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.wednesdayNightFrom1] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.wednesdayNightFrom1]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.wednesdayNightTo1] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.wednesdayNightTo1]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.wednesdayNightName2] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.wednesdayNightName2]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.wednesdayNightFrom2] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.wednesdayNightFrom2]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.wednesdayNightTo2] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.wednesdayNightTo2]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.wednesdayNightName3] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.wednesdayNightName3]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.wednesdayNightFrom3] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.wednesdayNightFrom3]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.wednesdayNightTo3] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.wednesdayNightTo3]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.wednesdayNightName4] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.wednesdayNightName4]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.wednesdayNightFrom4] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.wednesdayNightFrom4]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.wednesdayNightTo4] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.wednesdayNightTo4]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.wednesdayNightName5] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.wednesdayNightName5]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.wednesdayNightFrom5] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.wednesdayNightFrom5]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.wednesdayNightTo5] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.wednesdayNightTo5]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                  ]
              )),
            ]),

            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(height: 66, decoration: BoxDecoration(color: PdfColors.grey, border: Border.all(width: 1, color: PdfColors.black),),width: 100, child: Text('Thursday', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
              Container(height: 66, padding: EdgeInsets.all(2), decoration: BoxDecoration(border: Border.all(width: 1, color: PdfColors.black),),width: 220, child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.thursdayAmName1] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.thursdayAmName1]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.thursdayAmFrom1] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.thursdayAmFrom1]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.thursdayAmTo1] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.thursdayAmTo1]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.thursdayAmName2] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.thursdayAmName2]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.thursdayAmFrom2] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.thursdayAmFrom2]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.thursdayAmTo2] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.thursdayAmTo2]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.thursdayAmName3] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.thursdayAmName3]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.thursdayAmFrom3] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.thursdayAmFrom3]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.thursdayAmTo3] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.thursdayAmTo3]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.thursdayAmName4] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.thursdayAmName4]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.thursdayAmFrom4] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.thursdayAmFrom4]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.thursdayAmTo4] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.thursdayAmTo4]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.thursdayAmName5] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.thursdayAmName5]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.thursdayAmFrom5] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.thursdayAmFrom5]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.thursdayAmTo5] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.thursdayAmTo5]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                  ]
              )),
              Container(height: 66, padding: EdgeInsets.all(2), decoration: BoxDecoration(border: Border.all(width: 1, color: PdfColors.black),),width: 220, child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.thursdayPmName1] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.thursdayPmName1]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.thursdayPmFrom1] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.thursdayPmFrom1]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.thursdayPmTo1] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.thursdayPmTo1]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.thursdayPmName2] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.thursdayPmName2]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.thursdayPmFrom2] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.thursdayPmFrom2]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.thursdayPmTo2] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.thursdayPmTo2]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.thursdayPmName3] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.thursdayPmName3]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.thursdayPmFrom3] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.thursdayPmFrom3]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.thursdayPmTo3] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.thursdayPmTo3]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.thursdayPmName4] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.thursdayPmName4]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.thursdayPmFrom4] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.thursdayPmFrom4]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.thursdayPmTo4] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.thursdayPmTo4]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.thursdayPmName5] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.thursdayPmName5]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.thursdayPmFrom5] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.thursdayPmFrom5]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.thursdayPmTo5] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.thursdayPmTo5]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                  ]
              )),
              Container(height: 66, padding: EdgeInsets.all(2), decoration: BoxDecoration(border: Border.all(width: 1, color: PdfColors.black),),width: 220, child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.thursdayNightName1] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.thursdayNightName1]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.thursdayNightFrom1] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.thursdayNightFrom1]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.thursdayNightTo1] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.thursdayNightTo1]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.thursdayNightName2] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.thursdayNightName2]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.thursdayNightFrom2] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.thursdayNightFrom2]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.thursdayNightTo2] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.thursdayNightTo2]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.thursdayNightName3] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.thursdayNightName3]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.thursdayNightFrom3] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.thursdayNightFrom3]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.thursdayNightTo3] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.thursdayNightTo3]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.thursdayNightName4] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.thursdayNightName4]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.thursdayNightFrom4] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.thursdayNightFrom4]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.thursdayNightTo4] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.thursdayNightTo4]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.thursdayNightName5] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.thursdayNightName5]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.thursdayNightFrom5] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.thursdayNightFrom5]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.thursdayNightTo5] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.thursdayNightTo5]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                  ]
              )),
            ]),

            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(height: 66, decoration: BoxDecoration(color: PdfColors.grey, border: Border.all(width: 1, color: PdfColors.black),),width: 100, child: Text('Friday', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
              Container(height: 66, padding: EdgeInsets.all(2), decoration: BoxDecoration(border: Border.all(width: 1, color: PdfColors.black),),width: 220, child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.fridayAmName1] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.fridayAmName1]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.fridayAmFrom1] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.fridayAmFrom1]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.fridayAmTo1] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.fridayAmTo1]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.fridayAmName2] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.fridayAmName2]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.fridayAmFrom2] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.fridayAmFrom2]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.fridayAmTo2] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.fridayAmTo2]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.fridayAmName3] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.fridayAmName3]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.fridayAmFrom3] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.fridayAmFrom3]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.fridayAmTo3] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.fridayAmTo3]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.fridayAmName4] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.fridayAmName4]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.fridayAmFrom4] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.fridayAmFrom4]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.fridayAmTo4] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.fridayAmTo4]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.fridayAmName5] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.fridayAmName5]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.fridayAmFrom5] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.fridayAmFrom5]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.fridayAmTo5] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.fridayAmTo5]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                  ]
              )),
              Container(height: 66, padding: EdgeInsets.all(2), decoration: BoxDecoration(border: Border.all(width: 1, color: PdfColors.black),),width: 220, child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.fridayPmName1] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.fridayPmName1]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.fridayPmFrom1] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.fridayPmFrom1]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.fridayPmTo1] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.fridayPmTo1]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.fridayPmName2] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.fridayPmName2]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.fridayPmFrom2] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.fridayPmFrom2]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.fridayPmTo2] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.fridayPmTo2]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.fridayPmName3] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.fridayPmName3]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.fridayPmFrom3] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.fridayPmFrom3]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.fridayPmTo3] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.fridayPmTo3]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.fridayPmName4] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.fridayPmName4]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.fridayPmFrom4] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.fridayPmFrom4]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.fridayPmTo4] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.fridayPmTo4]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.fridayPmName5] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.fridayPmName5]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.fridayPmFrom5] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.fridayPmFrom5]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.fridayPmTo5] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.fridayPmTo5]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                  ]
              )),
              Container(height: 66, padding: EdgeInsets.all(2), decoration: BoxDecoration(border: Border.all(width: 1, color: PdfColors.black),),width: 220, child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.fridayNightName1] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.fridayNightName1]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.fridayNightFrom1] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.fridayNightFrom1]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.fridayNightTo1] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.fridayNightTo1]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.fridayNightName2] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.fridayNightName2]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.fridayNightFrom2] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.fridayNightFrom2]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.fridayNightTo2] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.fridayNightTo2]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.fridayNightName3] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.fridayNightName3]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.fridayNightFrom3] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.fridayNightFrom3]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.fridayNightTo3] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.fridayNightTo3]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.fridayNightName4] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.fridayNightName4]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.fridayNightFrom4] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.fridayNightFrom4]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.fridayNightTo4] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.fridayNightTo4]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.fridayNightName5] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.fridayNightName5]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.fridayNightFrom5] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.fridayNightFrom5]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.fridayNightTo5] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.fridayNightTo5]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                  ]
              )),
            ]),

            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(height: 66, decoration: BoxDecoration(color: PdfColors.grey, border: Border.all(width: 1, color: PdfColors.black),),width: 100, child: Text('Saturday', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
              Container(height: 66, padding: EdgeInsets.all(2), decoration: BoxDecoration(border: Border.all(width: 1, color: PdfColors.black),),width: 220, child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.saturdayAmName1] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.saturdayAmName1]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.saturdayAmFrom1] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.saturdayAmFrom1]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.saturdayAmTo1] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.saturdayAmTo1]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.saturdayAmName2] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.saturdayAmName2]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.saturdayAmFrom2] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.saturdayAmFrom2]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.saturdayAmTo2] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.saturdayAmTo2]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.saturdayAmName3] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.saturdayAmName3]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.saturdayAmFrom3] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.saturdayAmFrom3]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.saturdayAmTo3] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.saturdayAmTo3]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.saturdayAmName4] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.saturdayAmName4]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.saturdayAmFrom4] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.saturdayAmFrom4]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.saturdayAmTo4] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.saturdayAmTo4]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.saturdayAmName5] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.saturdayAmName5]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.saturdayAmFrom5] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.saturdayAmFrom5]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.saturdayAmTo5] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.saturdayAmTo5]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                  ]
              )),
              Container(height: 66, padding: EdgeInsets.all(2), decoration: BoxDecoration(border: Border.all(width: 1, color: PdfColors.black),),width: 220, child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.saturdayPmName1] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.saturdayPmName1]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.saturdayPmFrom1] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.saturdayPmFrom1]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.saturdayPmTo1] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.saturdayPmTo1]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.saturdayPmName2] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.saturdayPmName2]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.saturdayPmFrom2] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.saturdayPmFrom2]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.saturdayPmTo2] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.saturdayPmTo2]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.saturdayPmName3] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.saturdayPmName3]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.saturdayPmFrom3] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.saturdayPmFrom3]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.saturdayPmTo3] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.saturdayPmTo3]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.saturdayPmName4] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.saturdayPmName4]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.saturdayPmFrom4] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.saturdayPmFrom4]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.saturdayPmTo4] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.saturdayPmTo4]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.saturdayPmName5] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.saturdayPmName5]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.saturdayPmFrom5] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.saturdayPmFrom5]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.saturdayPmTo5] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.saturdayPmTo5]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                  ]
              )),
              Container(height: 66, padding: EdgeInsets.all(2), decoration: BoxDecoration(border: Border.all(width: 1, color: PdfColors.black),),width: 220, child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.saturdayNightName1] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.saturdayNightName1]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.saturdayNightFrom1] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.saturdayNightFrom1]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.saturdayNightTo1] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.saturdayNightTo1]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.saturdayNightName2] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.saturdayNightName2]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.saturdayNightFrom2] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.saturdayNightFrom2]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.saturdayNightTo2] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.saturdayNightTo2]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.saturdayNightName3] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.saturdayNightName3]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.saturdayNightFrom3] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.saturdayNightFrom3]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.saturdayNightTo3] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.saturdayNightTo3]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.saturdayNightName4] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.saturdayNightName4]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.saturdayNightFrom4] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.saturdayNightFrom4]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.saturdayNightTo4] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.saturdayNightTo4]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.saturdayNightName5] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.saturdayNightName5]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.saturdayNightFrom5] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.saturdayNightFrom5]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.saturdayNightTo5] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.saturdayNightTo5]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                  ]
              )),
            ]),

            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(height: 66, decoration: BoxDecoration(color: PdfColors.grey, border: Border.all(width: 1, color: PdfColors.black),),width: 100, child: Text('Sunday', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
              Container(height: 66, padding: EdgeInsets.all(2), decoration: BoxDecoration(border: Border.all(width: 1, color: PdfColors.black),),width: 220, child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.sundayAmName1] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.sundayAmName1]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.sundayAmFrom1] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.sundayAmFrom1]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.sundayAmTo1] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.sundayAmTo1]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.sundayAmName2] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.sundayAmName2]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.sundayAmFrom2] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.sundayAmFrom2]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.sundayAmTo2] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.sundayAmTo2]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.sundayAmName3] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.sundayAmName3]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.sundayAmFrom3] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.sundayAmFrom3]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.sundayAmTo3] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.sundayAmTo3]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.sundayAmName4] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.sundayAmName4]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.sundayAmFrom4] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.sundayAmFrom4]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.sundayAmTo4] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.sundayAmTo4]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.sundayAmName5] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.sundayAmName5]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.sundayAmFrom5] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.sundayAmFrom5]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.sundayAmTo5] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.sundayAmTo5]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                  ]
              )),
              Container(height: 66, padding: EdgeInsets.all(2), decoration: BoxDecoration(border: Border.all(width: 1, color: PdfColors.black),),width: 220, child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.sundayPmName1] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.sundayPmName1]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.sundayPmFrom1] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.sundayPmFrom1]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.sundayPmTo1] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.sundayPmTo1]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.sundayPmName2] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.sundayPmName2]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.sundayPmFrom2] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.sundayPmFrom2]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.sundayPmTo2] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.sundayPmTo2]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.sundayPmName3] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.sundayPmName3]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.sundayPmFrom3] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.sundayPmFrom3]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.sundayPmTo3] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.sundayPmTo3]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.sundayPmName4] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.sundayPmName4]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.sundayPmFrom4] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.sundayPmFrom4]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.sundayPmTo4] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.sundayPmTo4]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.sundayPmName5] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.sundayPmName5]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.sundayPmFrom5] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.sundayPmFrom5]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.sundayPmTo5] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.sundayPmTo5]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                  ]
              )),
              Container(height: 66, padding: EdgeInsets.all(2), decoration: BoxDecoration(border: Border.all(width: 1, color: PdfColors.black),),width: 220, child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.sundayNightName1] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.sundayNightName1]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.sundayNightFrom1] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.sundayNightFrom1]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.sundayNightTo1] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.sundayNightTo1]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.sundayNightName2] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.sundayNightName2]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.sundayNightFrom2] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.sundayNightFrom2]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.sundayNightTo2] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.sundayNightTo2]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.sundayNightName3] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.sundayNightName3]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.sundayNightFrom3] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.sundayNightFrom3]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.sundayNightTo3] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.sundayNightTo3]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.sundayNightName4] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.sundayNightName4]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.sundayNightFrom4] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.sundayNightFrom4]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.sundayNightTo4] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.sundayNightTo4]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedBedRota[Strings.sundayNightName5] != '' ? Text(GlobalFunctions.decryptString(selectedBedRota[Strings.sundayNightName5]), style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.sundayNightFrom5] != null ? Text(': ' + GlobalFunctions.databaseValueTime(selectedBedRota[Strings.sundayNightFrom5]) + ' - ', style: TextStyle(fontSize: 9)): Container(),
                          selectedBedRota[Strings.sundayNightTo5] != null ? Text(GlobalFunctions.databaseValueTime(selectedBedRota[Strings.sundayNightTo5]), style: TextStyle(fontSize: 9)): Container(),
                        ]),
                  ]
              )),
            ]),







          ]

      ));

      String formDate = selectedBedRota[Strings.weekCommencing] == null ? '' : dateFormatDay.format(DateTime.parse(selectedBedRota[Strings.weekCommencing]));
      String id = selectedBedRota[Strings.documentId];

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
            ..download = 'bed_rota_${formDate}_$id.pdf';
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

        final File file = File('$pdfPath/bed_rota_${formDate}_$id.pdf');

        if(option == ShareOption.Email){
          await file.writeAsBytes(await pdf.save());}

        ConnectivityResult connectivityResult = await Connectivity().checkConnectivity();

        if(connectivityResult != ConnectivityResult.none) {

          if(option == ShareOption.Share) await Printing.sharePdf(bytes: await pdf.save(),filename: 'bed_rota_${formDate}_$id.pdf');
          if(option == ShareOption.Print) await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());

          if(option == ShareOption.Email) {
            final smtpServer = gmail(emailUsername, emailPassword);

            // Create our message.
            final mailmessage = new Message()
              ..from = new Address(emailUsername, 'Pegasus Medical')
              ..recipients = emailList
              ..subject = 'Completed Bed Watch Rota'
              ..html = "<p1>Dear Sir/Madam,</p1>\n<p>Attached is a completed Bed Watch Rota from ${user
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



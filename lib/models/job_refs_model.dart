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
import '../utils/database.dart';
import 'package:sembast/sembast.dart' as Db;
import 'package:random_string/random_string.dart' as random_string;

class JobRefsModel extends ChangeNotifier {

  DatabaseHelper _databaseHelper = DatabaseHelper();
  AuthenticationModel authenticationModel = AuthenticationModel();
  final NavigationService _navigationService = locator<NavigationService>();
  JobRefsModel(this.authenticationModel);

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> _jobRefs = [];
  String _selJobRefId;
  final dateFormatDay = DateFormat("dd-MM-yyyy");

  List<Map<String, dynamic>> get allJobRefs {
    return List.from(_jobRefs);
  }
  int get selectedJobRefIndex {
    return _jobRefs.indexWhere((Map<String, dynamic> jobRef) {
      return jobRef[Strings.documentId] == _selJobRefId;
    });
  }
  String get selectedJobRefId {
    return _selJobRefId;
  }

  Map<String, dynamic> get selectedJobRef {
    if (_selJobRefId == null) {
      return null;
    }
    return _jobRefs.firstWhere((Map<String, dynamic> jobRef) {
      return jobRef[Strings.documentId] == _selJobRefId;
    });
  }
  void selectJobRef(String jobRefId) {
    _selJobRefId = jobRefId;
    if (jobRefId != null) {
      notifyListeners();
    }
  }

  void clearJobRefs(){
    _jobRefs = [];
  }


  // Sembast database settings
  static const String TEMPORARY_JOB_REFS_STORE_NAME = 'temporary_job_refs';
  final _temporaryJobRefsStore = Db.intMapStoreFactory.store(TEMPORARY_JOB_REFS_STORE_NAME);

  static const String JOB_REFS_STORE_NAME = 'job_refs';
  final _jobRefsStore = Db.intMapStoreFactory.store(JOB_REFS_STORE_NAME);

  static const String EDITED_JOB_REFS_STORE_NAME = 'edited_job_refs';
  final _editedJobRefsStore = Db.intMapStoreFactory.store(EDITED_JOB_REFS_STORE_NAME);

  static const String SAVED_JOB_REFS_STORE_NAME = 'saved_job_refs';
  final _savedJobRefsStore = Db.intMapStoreFactory.store(SAVED_JOB_REFS_STORE_NAME);

  Future<Db.Database> get _db async => await AppDatabase.instance.database;

  Future<void> deleteAllRows() async {
    await _jobRefsStore.delete(await _db);
  }

  Future<bool> addJobRef(String jobRef) async {

    GlobalFunctions.showLoadingDialog('Adding Job Ref...');
    String message = '';
    bool success = false;
    bool hasDataConnection = await GlobalFunctions.hasDataConnection();


    if(hasDataConnection){

      bool isTokenExpired = GlobalFunctions.isTokenExpired();
      bool authenticated = true;

      if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

      if(authenticated){


        try {

          await FirebaseFirestore.instance.collection('job_refs').add({
            Strings.jobRef: jobRef,
          });

          await getJobRefs();
          message = 'Job Ref added successfully';
          success = true;



        } on TimeoutException catch (_) {
          // A timeout occurred.
          message = 'Network Timeout communicating with the server, unable to add job ref';


        } catch (e) {
          print(e);
          message = e.toString();

          print(e);
        }
      }

    } else {

      message = 'No data connection, unable to add Job Ref';
      success = true;

    }

    GlobalFunctions.dismissLoadingDialog();

    GlobalFunctions.showToast(message);
    return success;
  }

  Future<bool> deleteJobRef(String documentId) async {

    GlobalFunctions.showLoadingDialog('Deleting Job Ref...');
    String message = '';
    bool success = false;
    bool hasDataConnection = await GlobalFunctions.hasDataConnection();


    if(hasDataConnection){

      bool isTokenExpired = GlobalFunctions.isTokenExpired();
      bool authenticated = true;

      if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

      if(authenticated){


        try {

          await FirebaseFirestore.instance.collection('job_refs').doc(documentId).delete();

          await getJobRefs();
          message = 'Job Ref deleted successfully';
          success = true;



        } on TimeoutException catch (_) {
          // A timeout occurred.
          message = 'Network Timeout communicating with the server, unable to delete job ref';


        } catch (e) {
          print(e);
          message = e.toString();

          print(e);
        }
      }

    } else {

      message = 'No data connection, unable to add Job Ref';
      success = true;

    }

    GlobalFunctions.dismissLoadingDialog();

    GlobalFunctions.showToast(message);
    return success;
  }


  Future<void> getJobRefs() async{

    _isLoading = true;
    String message = '';

    List<Map<String, dynamic>> _fetchedJobRefList = [];

    try {

      bool hasDataConnection = await GlobalFunctions.hasDataConnection();

      if(!hasDataConnection){

        List<dynamic> records = await _jobRefsStore.find(
          await _db,
        );

        if(records.length > 0){
          for(var record in records){
            _fetchedJobRefList.add(record.value);
          }

          _fetchedJobRefList.sort((a, b) => (a['job_ref']).compareTo(b['job_ref']));

          _jobRefs = List.from(_fetchedJobRefList);
        } else {
          //message = 'No saved records available';
        }
      } else {

        await deleteAllRows();

        bool isTokenExpired = GlobalFunctions.isTokenExpired();
        bool authenticated = true;

        if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

        if(authenticated){


          QuerySnapshot snapshot;
            try{
              snapshot = await FirebaseFirestore.instance.collection('job_refs').get().timeout(Duration(seconds: 90));
            } catch(e){
              print(e);
            }



          Map<String, dynamic> snapshotData = {};

          if(snapshot.docs.length < 1){
            message = 'No Job Refs found';
            _jobRefs = [];
          } else {

            List<QueryDocumentSnapshot> snapDocs = snapshot.docs;
            snapDocs.sort((a, b) => (a.get('job_ref')).compareTo(b.get('job_ref')));

            for (DocumentSnapshot snap in snapDocs) {

              snapshotData = snap.data();
              final Map<String, dynamic> jobRef = {
                Strings.documentId: snap.id,
                Strings.jobRef: snapshotData[Strings.jobRef]
              };

              _fetchedJobRefList.add(jobRef);
              int _id = DateTime.now().millisecondsSinceEpoch + int.parse(random_string.randomNumeric(2));
              await _jobRefsStore.record(_id).put(await _db,
                  jobRef);

            }
            _jobRefs = _fetchedJobRefList;
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
    _selJobRefId = null;
    if(message != '') GlobalFunctions.showToast(message);

  }







}



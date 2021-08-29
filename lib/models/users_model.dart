import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as Auth;
import 'package:random_string/random_string.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import '../shared/global_config.dart';
import '../shared/global_functions.dart';
import '../utils/database_helper.dart';
import 'package:pegasus_medical_1808/shared/strings.dart';
import './authentication_model.dart';
import '../services/navigation_service.dart';
import '../locator.dart';
import '../constants/route_paths.dart' as routes;






class UsersModel extends ChangeNotifier {

  AuthenticationModel authenticationModel = AuthenticationModel();
  //DatabaseHelper databaseHelper = DatabaseHelper();
  final NavigationService _navigationService = locator<NavigationService>();




  UsersModel(this.authenticationModel);

  bool _isLoading = false;
  bool _isLoadingLogin = false;
  bool isCheckingImageCrash = false;
  bool shouldUpdateUsers = false;
  String searchControllerValue = '';

  List<User> _users = [];
  String _selUserId;

  bool get isLoading {
    return _isLoading;
  }

  bool get isLoadingLogin {
    return _isLoadingLogin;
  }

  List<User> get allUsers {
    return List.from(_users);
  }

  int get selectedUserIndex {
    return _users.indexWhere((User user) {
      return user.uid == _selUserId;
    });
  }

  String get selectedUserId {
    return _selUserId;
  }

  User get selectedUser {
    if (_selUserId == null) {
      return null;
    }
    return _users.firstWhere((User user) {
      return user.uid == _selUserId;
    });
  }

  void selectUser(String userId) {
    _selUserId = userId;
    if (userId != null) {
      notifyListeners();
    }
  }

  //TextEditingController _searchController = TextEditingController();


  // TextEditingController get searchController {
  //   return _searchController;
  // }

  TextEditingController _searchControllerRaiseJob = TextEditingController();

  String searchControllerValueRaiseJob = '';

  TextEditingController get searchControllerRaiseJob {
    return _searchControllerRaiseJob;
  }


  User createUserObjectOffline(Map<String, dynamic> localUser){
    return User(
      uid: GlobalFunctions.databaseValueString(localUser[Strings.uid]),
      email: GlobalFunctions.decryptString(localUser[Strings.email]),
      name: GlobalFunctions.decryptString(localUser[Strings.name]),
      nameLowercase: GlobalFunctions.decryptString(localUser[Strings.nameLowercase]),
      mobile: GlobalFunctions.decryptString(localUser[Strings.mobile]),
      role: GlobalFunctions.databaseValueString(localUser[Strings.role]),
      suspended: GlobalFunctions.databaseValueTinyInt(localUser[Strings.suspended]),
      deleted: GlobalFunctions.databaseValueTinyInt(localUser[Strings.deleted]),
      termsAccepted: GlobalFunctions.databaseValueTinyInt(localUser[Strings.termsAccepted]),
      forcePasswordReset: GlobalFunctions.databaseValueTinyInt(localUser[Strings.forcePasswordReset]),
      profilePicture: localUser[Strings.profilePicture] == null ? null : localUser[Strings.profilePicture]
    );
  }

  User createUserObject(Map<String, dynamic> snapshotData, String userId){
    return User(
      uid: GlobalFunctions.databaseValueString(userId),
      email: GlobalFunctions.databaseValueString(snapshotData[Strings.email]),
      name: GlobalFunctions.databaseValueString(snapshotData[Strings.name]),
      nameLowercase: GlobalFunctions.databaseValueString(snapshotData[Strings.nameLowercase]),
      mobile: GlobalFunctions.databaseValueString(snapshotData[Strings.mobile]),
      role: GlobalFunctions.databaseValueString(snapshotData[Strings.role]),
      suspended: GlobalFunctions.databaseValueBool(snapshotData[Strings.suspended]),
      deleted: GlobalFunctions.databaseValueBool(snapshotData[Strings.deleted]),
      termsAccepted: GlobalFunctions.databaseValueBool(snapshotData[Strings.termsAccepted]),
      forcePasswordReset: GlobalFunctions.databaseValueBool(snapshotData[Strings.forcePasswordReset]),
      profilePicture: snapshotData[Strings.profilePicture] == null ? null : snapshotData[Strings.profilePicture]
    );
  }

  Map<String, dynamic> createLocalUserData(snapshotData, String userId) {
    return {
      Strings.uid: GlobalFunctions.databaseValueString(userId),
      Strings.email: GlobalFunctions.encryptString(snapshotData[Strings.email]),
      Strings.name: GlobalFunctions.encryptString(snapshotData[Strings.name]),
      Strings.nameLowercase: GlobalFunctions.encryptString(snapshotData[Strings.nameLowercase]),
      Strings.mobile: GlobalFunctions.encryptString(snapshotData[Strings.mobile]),
      Strings.role: GlobalFunctions.databaseValueString(snapshotData[Strings.role]),
      Strings.suspended: GlobalFunctions.boolToTinyInt(snapshotData[Strings.suspended]),
      Strings.deleted: GlobalFunctions.boolToTinyInt(snapshotData[Strings.deleted]),
      Strings.termsAccepted: GlobalFunctions.boolToTinyInt(snapshotData[Strings.termsAccepted]),
      Strings.forcePasswordReset: GlobalFunctions.boolToTinyInt(snapshotData[Strings.forcePasswordReset]),
      Strings.profilePicture: snapshotData[Strings.profilePicture] == null ? null : snapshotData[Strings.profilePicture]

    };
  }




  Future<void> getUsers() async{

    _isLoading = true;
    List<User> _fetchedUsersList = [];

    try {

      bool hasConnection = await GlobalFunctions.hasDataConnection();

      if(!hasConnection){

        GlobalFunctions.showToast('No data connection, unable to fetch Users');
        _users = [];

        // int localUserCount = await databaseHelper.getRowCountWhere(Strings.usersTable, Strings.deleted, 0);
        //
        // if (localUserCount > 0) {
        //
        //   List<Map<String, dynamic>> localUsers = await databaseHelper.getRowsWhereOrderByDirection(Strings.usersTable, Strings.deleted, 0, Strings.nameLowercase, 'ASC');
        //
        //
        //   if(localUsers.length >0){
        //
        //     for (Map<String, dynamic> localUser in localUsers) {
        //
        //       final User userObject = createUserObjectOffline(localUser);
        //       _fetchedUsersList.add(userObject);
        //
        //     }
        //
        //     _fetchedUsersList.sort((User b,
        //         User a) =>
        //         b.nameLowercase.compareTo(a.nameLowercase));
        //       _users = _fetchedUsersList;
        //
        //     GlobalFunctions.showToast('No data connection, unable to fetch latest Users');
        //   }
        //
        // } else {
        //   GlobalFunctions.showToast('No Users available, please try again when you have a data connection');
        //   _users = [];
        // }
      } else {

        //Check the expiry time on the token before making the request
        bool isTokenExpired = GlobalFunctions.isTokenExpired();
        bool authenticated = true;

        if (isTokenExpired)
          authenticated = await authenticationModel.reAuthenticate();

        if (authenticated) {

          QuerySnapshot snapshot;

            try {
              snapshot =
              await FirebaseFirestore.instance.collection('users').where(
                  'deleted', isEqualTo: false).orderBy('name_lowercase', descending: false).limit(20)
                  .get()
                  .timeout(Duration(seconds: 90));

            } catch(e){
              print(e);
            }


          Map<String, dynamic> snapshotData = {};

          if(snapshot.docs.length < 1){

            GlobalFunctions.showToast('No Users found');

          } else {
            for (DocumentSnapshot snap in snapshot.docs) {
              snapshotData = snap.data();


              final User userItem = createUserObject(snapshotData, snap.id);
              _fetchedUsersList.add(userItem);

              // Map<String, dynamic> localData = createLocalUserData(snapshotData, snap.id);
              // int existingUser = await databaseHelper.checkUserExists(snap.id);
              //
              // if(existingUser == 0){
              //   await databaseHelper.add(Strings.usersTable, localData);
              // } else {
              //   await databaseHelper.updateRow(Strings.usersTable, localData, Strings.uid, snap.id);
              // }
            }

            _fetchedUsersList.sort((User b,
                User a) =>
                b.nameLowercase.compareTo(a.nameLowercase));


            _users = _fetchedUsersList;
          }

        }

      }

    } on TimeoutException catch (_) {
      // A timeout occurred.
      GlobalFunctions.showToast('Network Timeout communicating with the server, unable to fetch latest Users');
    } catch(e){
      print(e);
    }


    _isLoading = false;
    notifyListeners();
    _selUserId = null;
  }

  Future<void> getMoreUsers() async{

    notifyListeners();
    List<User> _fetchedUsersList = [];


    try {


      bool hasDataConnection = await GlobalFunctions.hasDataConnection();

      if(!hasDataConnection){

        GlobalFunctions.showToast('No data connection, unable to fetch Users');
        _users = [];

        // int localUserCount = await databaseHelper.getRowCountWhere(Strings.usersTable, Strings.deleted, 0);
        //
        // if (localUserCount == _users.length) {
        //
        //   GlobalFunctions.showToast('No more Users to fetch');
        //
        // } else if (localUserCount > 0) {
        //
        //   List<Map<String, dynamic>> localUsers = await databaseHelper.getRowsWhereOrderByDirection(Strings.usersTable, Strings.deleted, 0, Strings.nameLowercase, 'ASC');
        //
        //   if(localUsers.length >0){
        //
        //     for (Map<String, dynamic> localUser in localUsers) {
        //
        //       final User userObject = createUserObjectOffline(localUser);
        //       _fetchedUsersList.add(userObject);
        //
        //     }
        //
        //     _fetchedUsersList.sort((User b,
        //         User a) =>
        //         b.nameLowercase.compareTo(a.nameLowercase));
        //     _users = _fetchedUsersList;
        //
        //     GlobalFunctions.showToast('No data connection, unable to fetch latest Users');
        //   }
        //
        // } else {
        //   GlobalFunctions.showToast('No Users available, please try again when you have a data connection');
        //   _users = [];
        // }
      } else {

        bool isTokenExpired = GlobalFunctions.isTokenExpired();
        bool authenticated = true;

        if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

        if(authenticated){

          QuerySnapshot snapshot;
          int currentLength = _users.length;

          String latestUser = _users[currentLength - 1].nameLowercase;

            try {
              snapshot =
              await FirebaseFirestore.instance.collection('users').where(
                  'deleted', isEqualTo: false).orderBy('name_lowercase', descending: false).startAfter([latestUser]).limit(20)
                  .get()
                  .timeout(Duration(seconds: 20));
            } on TimeoutException catch (_) {
              // A timeout occurred.
              GlobalFunctions.showToast('Network Timeout communicating with the server, please try again');
            } catch(e) {
              print(e);
            }


          Map<String, dynamic> snapshotData = {};

          if(snapshot.docs.length < 1){
            GlobalFunctions.showToast('No more Users to fetch');
          } else {

            for (DocumentSnapshot snap in snapshot.docs) {
              snapshotData = snap.data();

              final User userItem = createUserObject(snapshotData, snap.id);
              _fetchedUsersList.add(userItem);


              // Map<String, dynamic> localData = createLocalUserData(snapshotData, snap.id);
              // int existingUser = await databaseHelper.checkUserExists(snap.id);
              //
              // if(existingUser == 0){
              //   await databaseHelper.add(Strings.usersTable, localData);
              // } else {
              //   await databaseHelper.updateRow(Strings.usersTable, localData, Strings.uid, snap.id);
              // }
            }

            _fetchedUsersList.sort((User b,
                User a) =>
                b.nameLowercase.compareTo(a.nameLowercase));
            }

            _users.addAll(_fetchedUsersList);

          }

        }


    } on TimeoutException catch (_) {
      // A timeout occurred.
      GlobalFunctions.showToast('Network Timeout communicating with the server, unable to fetch latest Users');
    } catch(e){
      print(e);
    }


    _isLoading = false;
    notifyListeners();
    _selUserId = null;
  }

  Future<void> searchUsers() async{

    print('inside');

    _isLoading = true;
    notifyListeners();
    String searchString;

    List<User> _fetchedUsersList = [];

    try {

      bool hasConnection = await GlobalFunctions.hasDataConnection();

      if(!hasConnection){

        GlobalFunctions.showToast('No data connection, unable to fetch Users');
        if(shouldUpdateUsers) _users = [];

        // int localUserCount = await databaseHelper.getRowCountWhere(Strings.usersTable, Strings.deleted, 0);
        //
        //
        // if (localUserCount > 0) {
        //
        //
        //   List<Map<String, dynamic>> localUsers = await databaseHelper.getRowsWhereOrderByDirection(Strings.usersTable, Strings.deleted, 0, Strings.nameLowercase, 'ASC');
        //
        //
        //   if(localUsers.length >0){
        //
        //     for (Map<String, dynamic> localUser in localUsers) {
        //
        //       final User userObject = createUserObjectOffline(localUser);
        //       if(userObject.nameLowercase.contains(searchControllerValue.toLowerCase())) _fetchedUsersList.add(userObject);
        //     }
        //
        //
        //
        //     _fetchedUsersList.sort((User b,
        //         User a) =>
        //         b.nameLowercase.compareTo(a.nameLowercase));
        //     if(shouldUpdateUsers) _users = _fetchedUsersList;
        //
        //   }
        //
        // } else {
        //   GlobalFunctions.showToast('No Customers available, please try again when you have a data connection');
        //   if(shouldUpdateUsers) _users = [];
        // }
      } else {

        //Check the expiry time on the token before making the request
        bool isTokenExpired = GlobalFunctions.isTokenExpired();
        bool authenticated = true;

        if (isTokenExpired)
          authenticated = await authenticationModel.reAuthenticate();

        if (authenticated) {

          QuerySnapshot snapshot;
          searchString = searchControllerValue.toLowerCase();

            try {
              snapshot =
              await FirebaseFirestore.instance.collection('users').where('name_lowercase', isGreaterThanOrEqualTo: searchString).where('name_lowercase', isLessThanOrEqualTo: searchString + '\uf8ff').limit(20)
                  .get()
                  .timeout(Duration(seconds: 90));
            } catch(e) {
              print(e);
            }

          Map<String, dynamic> snapshotData = {};

            if(snapshot.docs.length < 1){
              if(shouldUpdateUsers) _users = [];
            } else {

                for (DocumentSnapshot snap in snapshot.docs) {

                  snapshotData = snap.data();

                  final User userItem = createUserObject(snapshotData, snap.id);
                  _fetchedUsersList.add(userItem);

                }

                _fetchedUsersList.sort((User b,
                    User a) =>
                    b.nameLowercase.compareTo(a.nameLowercase));
            }

              if(searchString == searchControllerValue.toLowerCase() && shouldUpdateUsers) _users = _fetchedUsersList;

            }
        }
    } on TimeoutException catch (_) {
      // A timeout occurred.
      GlobalFunctions.showToast('Network Timeout communicating with the server, unable to fetch latest Customers');
    } catch(e){

      print(e);
    }

    _isLoading = false;
    notifyListeners();
    _selUserId = null;

  }

  Future <void> addUser(String email, String name, String mobile, String role) async {

    bool success = false;
    String message = '';
    GlobalFunctions.showLoadingDialog('Adding user');
    if(name.length > 1) name = name.trim();
    bool hasConnection = await GlobalFunctions.hasDataConnection();

    if(hasConnection){
      bool isTokenExpired = GlobalFunctions.isTokenExpired();
      bool authenticated = true;

      if (isTokenExpired)
        authenticated = await authenticationModel.reAuthenticate();

      if (authenticated) {

        final String temporaryPassword = randomAlphaNumeric(10);

        try {

          Auth.UserCredential authResult = await Auth.FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: temporaryPassword).timeout(Duration(seconds: 60));
          Auth.User firebaseUser = authResult.user;
          Auth.IdTokenResult tokenResult = await firebaseUser.getIdTokenResult();
          String token = tokenResult.token;
          firebaseUser.sendEmailVerification();

          if(token != null) {

            Map<String, dynamic> userInfo = {
              Strings.email: email,
              Strings.name: name,
              Strings.nameLowercase: name.toLowerCase(),
              Strings.mobile: mobile,
              Strings.role: role,
              Strings.suspended: false,
              Strings.deleted: false,
              Strings.termsAccepted: false,
              Strings.forcePasswordReset: false,
              Strings.profilePicture: null
            };

            await FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).set(userInfo).timeout(Duration(seconds: 60));

            // Map<String, dynamic> localData = {
            //   Strings.uid: firebaseUser.uid,
            //   Strings.email: GlobalFunctions.encryptString(email),
            //   Strings.name: GlobalFunctions.encryptString(name),
            //   Strings.nameLowercase: GlobalFunctions.encryptString(name.toLowerCase()),
            //   Strings.mobile: GlobalFunctions.encryptString(mobile),
            //   Strings.role: role,
            //   Strings.suspended: 0,
            //   Strings.deleted: 0,
            //   Strings.termsAccepted: 0,
            //   Strings.forcePasswordReset: 1,
            //   Strings.profilePicture: null
            // };
            //
            // await databaseHelper.add(Strings.usersTable, localData);
            final User userItem = createUserObject(userInfo, firebaseUser.uid);
            _users.add(userItem);

            await FirebaseAuth.instance.sendPasswordResetEmail(email: email).timeout(Duration(seconds: 30));

            // final smtpServer = gmail(emailUsername, emailPassword);
            //
            // // Create our message.
            // final mailMessage = new Message()
            //   ..from = new Address(emailUsername, 'Admin')
            //   ..recipients.add(email)
            //   ..subject = 'Pegasus Medical App - new account'
            //   ..html = "<p>Dear $name</p>\n<p>You have been added as a $role on the Pegasus Medical app, please login using your email and temporary password: $temporaryPassword</p>\n"
            //       "<p>Please make sure to change this password once you have successfully logged into the app for the first time.</p>"
            //       "<p>Regards,<br>$emailSender</p>"
            //       "<p><small>$emailFooter</small></p>";
            //
            //
            // await send(mailMessage, smtpServer);
            success = true;

          }

        } on TimeoutException catch (_) {

          message = 'Network Timeout communicating with the server, please try again';

        } catch (error) {

          String errorMessage = error.toString();

          if(errorMessage.contains('invalid-email')){

            message = 'Invalid Email Address';

          } else if(errorMessage.contains('email-already-in-use')){

            message = 'The email address is already in use by another account.';

          } else if(errorMessage.contains('email-exists')){

            message = 'The email address is already in use by another account.';

          } else if(errorMessage.contains('too-many-requests')){

            message = 'We have blocked all requests from this device due to unusual activity. Try again later.';

          } else if(errorMessage.contains('network-request-failed')){

            message = 'No data connection, please try again when you have a valid connection';

          } else {
            print(errorMessage);
            message = 'Something went wrong. Please try again';
          }

        }


      }


    } else {
      message = 'No data connection, please try again when you have a valid connection';
    }

    GlobalFunctions.dismissLoadingDialog();
    if(success) {
      _navigationService.navigateToReplacement(routes.UsersRoute);
      message = 'User successfully added';
    }
    GlobalFunctions.showToast(message);


  }

  Future <void> editUser(String email, String name, String mobile, String role) async {

    bool success = false;
    String message = '';
    GlobalFunctions.showLoadingDialog('Editing user');
    if(name.length > 1) name = name.trim();
    bool hasConnection = await GlobalFunctions.hasDataConnection();

    if(hasConnection){
      bool isTokenExpired = GlobalFunctions.isTokenExpired();
      bool authenticated = true;

      if (isTokenExpired)
        authenticated = await authenticationModel.reAuthenticate();

      if (authenticated) {

        bool updatedEmail = true;
        try {

          if(email != selectedUser.email){

            Map<String, dynamic> response = await changeUserEmail(email);


            updatedEmail = response['success'];

            if(!updatedEmail) message = response['message'];

          }

          if(updatedEmail){

            Map<String, dynamic> userInfo = {
              Strings.email: email,
              Strings.name: name,
              Strings.nameLowercase: name.toLowerCase(),
              Strings.mobile: mobile,
              Strings.role: role,
              Strings.suspended: selectedUser.suspended,
              Strings.deleted: selectedUser.deleted,
              Strings.termsAccepted: selectedUser.termsAccepted,
              Strings.forcePasswordReset: selectedUser.forcePasswordReset,
              Strings.profilePicture: selectedUser.profilePicture
            };

            await FirebaseFirestore.instance.collection('users').doc(selectedUserId).update(userInfo).timeout(Duration(seconds: 60));

            // Map<String, dynamic> localData = {
            //   Strings.email: GlobalFunctions.encryptString(email),
            //   Strings.name: GlobalFunctions.encryptString(name),
            //   Strings.nameLowercase: GlobalFunctions.encryptString(name.toLowerCase()),
            //   Strings.mobile: GlobalFunctions.encryptString(mobile),
            //   Strings.role: role,
            // };
            //
            // await databaseHelper.updateRow(Strings.usersTable, localData, Strings.uid, selectedUserId);
            final User userItem = createUserObject(userInfo, selectedUserId);
            _users.removeWhere((element) => element.uid == selectedUserId);
            _users.add(userItem);
            success = true;
            message = 'User edited successfully';

          }

        } on TimeoutException catch (_) {

          message = 'Network Timeout communicating with the server, please try again';

        } catch (error) {

          String errorMessage = error.toString();

          if(errorMessage.contains('invalid-email')){

            message = 'Invalid Email Address';

          } else if(errorMessage.contains('email-exists')){

            message = 'The email address is already in use by another account.';

          } else if(errorMessage.contains('email-already-in-use')){

            message = 'The email address is already in use by another account.';

          } else if(errorMessage.contains('too-many-requests')){

            message = 'We have blocked all requests from this device due to unusual activity. Try again later.';

          } else if(errorMessage.contains('network-request-failed')){

            message = 'No data connection, please try again when you have a valid connection';

          } else {
            print(errorMessage);
            message = 'Something went wrong. Please try again';
          }

        }


      }


    } else {
      message = 'No data connection, please try again when you have a valid connection';
    }

    GlobalFunctions.dismissLoadingDialog();
    if(success) {
      _navigationService.goBack();
    }
    GlobalFunctions.showToast(message);


  }

  Future<void>suspendResumeUser(User userData) async {

    String message = '';
    if(!userData.suspended){
      GlobalFunctions.showLoadingDialog('Suspending User...');

    } else {
      GlobalFunctions.showLoadingDialog('Resuming User...');

    }

    bool hasConnection = await GlobalFunctions.hasDataConnection();

    if(hasConnection){

      bool isTokenExpired = GlobalFunctions.isTokenExpired();
      bool authenticated = true;

      if (isTokenExpired)
        authenticated = await authenticationModel.reAuthenticate();

      if (authenticated) {


        try {

          await FirebaseFirestore.instance.collection('users').doc(userData.uid).update({
            Strings.suspended: !userData.suspended
          }).timeout(Duration(seconds: 60));
          // await databaseHelper.updateRow(Strings.usersTable, {
          //   Strings.suspended: GlobalFunctions.boolToTinyInt(!userData.suspended)
          // }, Strings.uid, userData.uid);
          _users[_users.indexWhere((element) => element.uid == userData.uid)].suspended = !userData.suspended;
          notifyListeners();

          if(userData.suspended){
            message = 'User has been suspended';

          } else {
            message = 'User has been resumed';
          }

        } on TimeoutException catch (_) {
          // A timeout occurred.
          message = 'Network Timeout communicating with the server, unable to accept terms';
        } catch(error){
          print(error);

        }
      }

    } else {

      if(userData.suspended){
        message = 'No data connection, unable to Resume User';

      } else {
        message = 'No data connection, unable to Suspend User';

      }
    }

    GlobalFunctions.dismissLoadingDialog();
    if(message != '') GlobalFunctions.showToast(message);


  }

  Future<void>deleteUser(User userData) async {

    String message = '';
    GlobalFunctions.showLoadingDialog('Deleting User...');
    bool hasConnection = await GlobalFunctions.hasDataConnection();

    if(hasConnection){

      bool isTokenExpired = GlobalFunctions.isTokenExpired();
      bool authenticated = true;

      if (isTokenExpired)
        authenticated = await authenticationModel.reAuthenticate();

      if (authenticated) {


        try {

          String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
          String deletedEmail = selectedUser.email + '-' + currentTime;
          Map<String, dynamic> response = await changeUserEmail(deletedEmail);
          bool updatedEmail = response['success'];

          if(!updatedEmail) message = response['message'];

          if(updatedEmail){

            await FirebaseFirestore.instance.collection('users').doc(selectedUser.uid).update({'deleted': true, 'email': deletedEmail}).timeout(Duration(seconds: 60));
            // await databaseHelper.delete(Strings.usersTable, userData.uid);
            _users.removeWhere((element) => element.uid == userData.uid);
            notifyListeners();
            message = 'User deleted successfully';

          }

        } on TimeoutException catch (_) {
          // A timeout occurred.
          message = 'Network Timeout communicating with the server, unable to accept terms';
        } catch(error){
          print(error);

        }
      }

    } else {

      message = 'No data connection, unable to delete User';

    }

    GlobalFunctions.dismissLoadingDialog();
    if(message != '') GlobalFunctions.showToast(message);


  }






  Future<Map<String, dynamic>> changeUserEmail(String newEmail) async{

    bool success = false;
    String message = 'Something went wrong';
    final request = http.MultipartRequest('POST', Uri.parse(changeEmailFunctionUrl));

    request.fields['email'] = Uri.encodeComponent(newEmail);
    request.fields['uid'] = Uri.encodeComponent(selectedUser.uid);

    request.headers['Authorization'] = 'Bearer ${user.token}';

    try {
      final http.StreamedResponse streamedResponse = await request.send().timeout(Duration(seconds: 60));
      final http.Response response =
      await http.Response.fromStream(streamedResponse);
      print(response.statusCode);
      print(response.body);
      if (response.statusCode != 200 && response.statusCode != 201) {
        print(json.decode(response.body));
        print(response.body);
        if(response.body.contains('The email address is already in use by another account')) message = 'This email address is already in use by another account';
      } else if(response.statusCode == 200 || response.statusCode == 201){
        success = true;
        message = 'success';
      }

    } on TimeoutException catch (_) {
      // A timeout occurred.
    } catch (error) {
      print(error);
      return null;
    }

    return {'success' : success, 'message' : message};

  }





}

class User {
  String uid;
  String email;
  String name;
  String nameLowercase;
  String mobile;
  String role;
  bool suspended;
  bool deleted;
  bool termsAccepted;
  bool forcePasswordReset;
  String profilePicture;

  User(
      {@required this.uid,
        @required this.email,
        @required this.name,
        @required this.nameLowercase,
        @required this.mobile,
        @required this.role,
        @required this.suspended,
        @required this.deleted,
        @required this.termsAccepted,
        @required this.forcePasswordReset,
        @required this.profilePicture,
      });
}
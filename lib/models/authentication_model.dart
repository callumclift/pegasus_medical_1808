import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:random_string/random_string.dart';
import '../shared/global_config.dart';
import '../shared/global_functions.dart';
import '../shared/strings.dart';
import '../utils/database_helper.dart';
import '../locator.dart';
import '../services/navigation_service.dart';
import '../services/secure_storage.dart';
import '../constants/route_paths.dart' as routes;
import '../utils/database.dart';
import 'package:sembast/sembast.dart' as Db;
import 'package:random_string/random_string.dart' as random_string;



class AuthenticationModel extends ChangeNotifier {

  final SecureStorage _secureStorage = SecureStorage();
  final NavigationService _navigationService = locator<NavigationService>();
  //DatabaseHelper _databaseHelper = DatabaseHelper();
  String _loginErrorMessage = '';
  String get loginErrorMessage => _loginErrorMessage;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _isLoadingLogin = false;
  bool get isLoadingLogin => _isLoadingLogin;
  bool _loginButtonEnabled = false;
  bool get loginButtonEnabled => _loginButtonEnabled;

  void setLoadingTrue() {
    _isLoading = true;
    notifyListeners();
  }

  void setLoadingFalse() {
    _isLoading = false;
    notifyListeners();
  }

  void setLoadingLoginTrue() {
    _isLoadingLogin = true;
    notifyListeners();
  }

  void setLoadingLoginFalse() {
    _isLoadingLogin = false;
    notifyListeners();
  }


  void setLoginButtonEnabledTrue() {
    _loginButtonEnabled = true;
    notifyListeners();
  }

  void setLoginButtonEnabledFalse() {
    _loginButtonEnabled = false;
    notifyListeners();
  }

  // Sembast database settings
  static const String USERS_STORE_NAME = 'users_store';
  final _usersStore = Db.intMapStoreFactory.store(USERS_STORE_NAME);

  // Private getter to shorten the amount of code needed to get the
  // singleton instance of an opened database.
  Future<Db.Database> get _db async => await AppDatabase.instance.database;




  Future <void> signUp(String email, String name, String mobile) async {

    bool success = false;
    String message = '';
    GlobalFunctions.showLoadingDialog('Adding user');
    if(name.length > 1) name = name.trim();
    bool hasConnection = await GlobalFunctions.hasDataConnection();

    if(hasConnection){

      final String temporaryPassword = randomAlphaNumeric(10);

      try {

        UserCredential authResult = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: temporaryPassword).timeout(Duration(seconds: 60));
        User firebaseUser = authResult.user;
        IdTokenResult tokenResult = await firebaseUser.getIdTokenResult(true);
        String token = tokenResult.token;
        firebaseUser.sendEmailVerification();

        if(token != null) {

          Map<String, dynamic> userInfo = {
            Strings.email: email,
            Strings.name: name,
            Strings.nameLowercase: name.toLowerCase(),
            Strings.groups: null,
            Strings.mobile: null,
            Strings.role: null,
            Strings.suspended: false,
            Strings.deleted: false,
            Strings.termsAccepted: false,
            Strings.forcePasswordReset: false,
            Strings.profilePicture: null
          };

          await FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).set(userInfo).timeout(Duration(seconds: 60));




          success = true;



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
    } else {
      message = 'No data connection, please try again when you have a valid connection';
    }

    GlobalFunctions.dismissLoadingDialog();
    if(success) {
      _navigationService.goBack();
      message = 'User successfully added';
    }
    GlobalFunctions.showToast(message);


  }

  Future <void> login(String email, String password) async {

    _isLoadingLogin = true;
    _loginErrorMessage = '';
    notifyListeners();


    try {


      UserCredential authResult = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password).timeout(Duration(seconds: 60));
      User firebaseUser = authResult.user;
      bool emailVerified = firebaseUser.emailVerified;
      IdTokenResult tokenResult = await firebaseUser.getIdTokenResult(true);
      String token = tokenResult.token;


      if(!emailVerified){
        _loginErrorMessage = 'Please verify your email before signing in';
      } else {
        if(token != null){



          DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).get();
          Map<String, dynamic> snapshotData = snapshot.data();

          if(snapshotData['suspended'] == false) {

            final DateTime expiryTime = DateTime.now().add(Duration(seconds: 3300));
            final String expiryTimeString = expiryTime.toIso8601String();
            //Store user credentials in secure storage


            if(!kIsWeb) {
              _secureStorage.writeSecureData('email', email);
              _secureStorage.writeSecureData('password', password);
            }
            await createOnlineAuthenticatedUser(uid: firebaseUser.uid, email: email, token: token, tokenExpiryTime: expiryTimeString, snapshotData: snapshotData);
            //if(!isWeb) await createTemporaryForms();
            _loginErrorMessage = '';

            if(!kIsWeb){

              OSPermissionSubscriptionState subscriptionState = await OneSignal.shared.getPermissionSubscriptionState();
              String playerId = subscriptionState.subscriptionStatus.userId;
              if(playerId != null){
                GlobalFunctions.saveDeviceToken(playerId);
              }

            }






            if(user.termsAccepted && user.forcePasswordReset == false) {
              _navigationService.navigateToReplacement(routes.TransferReportPageRoute);

            } else if(user.termsAccepted && user.forcePasswordReset == true){

              _navigationService.navigateToReplacement(routes.ChangePasswordPageRoute);

            } else {
              _navigationService.navigateToReplacement(routes.TermsConditionsPageRoute);


            }


          } else {
            _loginErrorMessage = 'Your account has been suspended, please contact your system administrator';
          }
        }

      }

    } on TimeoutException catch (_) {

      _loginErrorMessage = 'Network Timeout communicating with the server, please try again';

    } catch (error) {

      String errorMessage = error.toString();

      if(errorMessage.contains('invalid-email')){

        _loginErrorMessage = 'Invalid Email Address';
      } else if(errorMessage.contains('user-not-found')){

        _loginErrorMessage = 'No account exists with the provided credentials';
      } else if(errorMessage.contains('wrong-password')){

        _loginErrorMessage = 'Incorrect Password';

      } else if(errorMessage.contains('user-disabled')){

        _loginErrorMessage = 'Your account has been disabled by an administrator';
      } else if(errorMessage.contains('too-many-requests')){

        _loginErrorMessage = 'Too many unsuccessful login attempts. Please try again in a few minutes';
      } else if(errorMessage.contains('network-request-failed')){

        _loginErrorMessage = 'No data connection, please try again when you have a valid connection';
      } else {
        print(errorMessage);
        _loginErrorMessage = 'Something went wrong. Please try again';
      }


    }

    _isLoadingLogin = false;
    notifyListeners();


  }

  Future <void> autoLogin() async{

    _isLoading = true;
    if(kIsWeb){
      await Future.delayed(Duration(seconds: 2));
    }
    final bool rememberMe = sharedPreferences.getBool(Strings.rememberMe);
    final bool termsAccepted = sharedPreferences.getBool(Strings.termsAccepted);


    //If remember me is true & terms have been accepted begin auto login otherwise show login screen

    if(rememberMe != null && rememberMe == true) {


      ConnectivityResult connectivityResult = await Connectivity().checkConnectivity();

      //Check for connection, if present check for active token, otherwise login offline with stored credentials
      if (connectivityResult != ConnectivityResult.none) {

        bool isTokenExpired = GlobalFunctions.isTokenExpired();


        try {

          String token;
          User firebaseUser;
          String uid;
          String email = kIsWeb ? GlobalFunctions.decryptString(sharedPreferences.getString(Strings.email)) : await _secureStorage.readSecureData('email');

          //if token is expired get a new token otherwise user stored token to save getting token unnecessarily
        if (isTokenExpired) {

          if(kIsWeb){

            if(FirebaseAuth.instance.currentUser != null){
              token = await FirebaseAuth.instance.currentUser.getIdToken(true);
              uid = FirebaseAuth.instance.currentUser.uid;
            }
          } else {
            String password = await _secureStorage.readSecureData('password');
            UserCredential authResult = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password).timeout(Duration(seconds: 60));
            firebaseUser = authResult.user;
            IdTokenResult tokenResult = await firebaseUser.getIdTokenResult(true);
            token = tokenResult.token;
            uid = firebaseUser.uid;
          }

        } else {

          token = sharedPreferences.getString(Strings.token);
          uid = sharedPreferences.getString(Strings.uid);
        }


            if(token != null){

              DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
              Map<String, dynamic> snapshotData = snapshot.data();

              if(snapshotData['suspended'] == false) {


                String expiryTimeString = sharedPreferences.getString(Strings.tokenExpiryTime);

                if(isTokenExpired){
                  final DateTime expiryTime = DateTime.now().add(Duration(seconds: 3300));
                  expiryTimeString = expiryTime.toIso8601String();

                }

                await createOnlineAuthenticatedUser(uid: uid, email: email, token: token, tokenExpiryTime: expiryTimeString, snapshotData: snapshotData);
                //if(!isWeb) await createTemporaryForms();

                if(!isWeb){
                  OSPermissionSubscriptionState subscriptionState = await OneSignal.shared.getPermissionSubscriptionState();
                  String playerId = subscriptionState.subscriptionStatus.userId;
                  if(playerId != null){
                    GlobalFunctions.saveDeviceToken(playerId);
                  }
                }


              } else {

                GlobalFunctions.showToast('Your account has been suspended, please contact your system admininistrator');
                sharedPreferences.setBool(Strings.rememberMe, false);
                
              }

            }

          } on TimeoutException catch (_) {

              await getOfflineAuthenticatedUser();


        } catch (error) {

            String errorMessage = error.toString();

            if(errorMessage.contains('invalid-email')){

              GlobalFunctions.showToast('Account credentials not found. Please login with a valid email & password');
              sharedPreferences.setBool(Strings.rememberMe, false);


            } else if(errorMessage.contains('user-not-found')){

              GlobalFunctions.showToast('Account credentials not found. Please login with a valid email & password');
              sharedPreferences.setBool(Strings.rememberMe, false);


            } else if(errorMessage.contains('wrong-password')){

              GlobalFunctions.showToast('Account credentials not found. Please login with a valid email & password');
              sharedPreferences.setBool(Strings.rememberMe, false);


            } else if(errorMessage.contains('user-disabled')){

              GlobalFunctions.showToast('Your account has been suspended, please contact your administrator');
              sharedPreferences.setBool(Strings.rememberMe, false);


            } else if(errorMessage.contains('too-many-requests')){

              GlobalFunctions.showToast('Account credentials not found. Please login with a valid email & password');
              sharedPreferences.setBool(Strings.rememberMe, false);


            } else if(errorMessage.contains('network-request-failed')){

              await getOfflineAuthenticatedUser();

            } else {
              print(errorMessage);
              GlobalFunctions.showToast(errorMessage);
              //GlobalFunctions.showToast('Something went wrong. Please login with your email & password');
              sharedPreferences.setBool(Strings.rememberMe, false);
            }

          }

      } else {

        await getOfflineAuthenticatedUser();

      }
    }

    _isLoading = false;
    notifyListeners();
  }


  Future <bool> reAuthenticate() async {

    bool success = false;
    String email = kIsWeb ? GlobalFunctions.decryptString(sharedPreferences.getString(Strings.email)) : await _secureStorage.readSecureData('email');
    String password;
    if(!kIsWeb) password = await _secureStorage.readSecureData('password');


    String token;

    try{

      if(kIsWeb){
        token = await FirebaseAuth.instance.currentUser.getIdToken(true);


      } else {
        UserCredential authResult = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password).timeout(Duration(seconds: 60));
        User firebaseUser = authResult.user;
        IdTokenResult tokenResult = await firebaseUser.getIdTokenResult(true);
        token = tokenResult.token;
      }


      if(token != null){

        DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid).get();
        Map<String, dynamic> snapshotData = snapshot.data();

        if(snapshotData['suspended'] == false) {

          final DateTime expiryTime = DateTime.now().add(Duration(seconds: 3300));
          String expiryTimeString = expiryTime.toIso8601String();
          await createOnlineAuthenticatedUser(uid: FirebaseAuth.instance.currentUser.uid, email: email, token: token, tokenExpiryTime: expiryTimeString, snapshotData: snapshotData);
          success = true;

        } else {

          GlobalFunctions.showToast('Your account has been suspended, please contact your system admininistrator');
          await logout();

        }

      } else {
        GlobalFunctions.showToast('Something went wrong. Please try again');
      }

    } on TimeoutException catch (_) {

      await getOfflineAuthenticatedUser();


    } catch (error) {

      String errorMessage = error.toString();

      if(errorMessage.contains('invalid-email')){

        GlobalFunctions.showToast('Account credentials not found. Please login with a valid email & password');
        await logout();


      } else if(errorMessage.contains('user-not-found')){

        GlobalFunctions.showToast('Account credentials not found. Please login with a valid email & password');
        await logout();


      } else if(errorMessage.contains('wrong-password')){

        GlobalFunctions.showToast('Account credentials not found. Please login with a valid email & password');
        await logout();


      } else if(errorMessage.contains('user-disabled')){

        GlobalFunctions.showToast('Your account has been suspended, please contact your administrator');
        await logout();


      } else if(errorMessage.contains('too-many-requests')){

        GlobalFunctions.showToast('Account credentials not found. Please login with a valid email & password');
        await logout();


      } else if(errorMessage.contains('network-request-failed')){

        GlobalFunctions.showToast('No data connection, please try again when you have a valid connection');

      } else {

        GlobalFunctions.showToast('Something went wrong. Please login with your email & password');
        await logout();

      }

    }

    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future <void> logout() async {
    _navigationService.navigateToReplacement(routes.LoginPageRoute);
    user = null;
    sharedPreferences.remove(Strings.rememberMe);
    if(!kIsWeb){
      _secureStorage.deleteSecureData('email');
      _secureStorage.deleteSecureData('password');
    } else {
      sharedPreferences.remove(Strings.email);

    }
    getLocation = true;
    notifyListeners();
  }


  Future<void> getOfflineAuthenticatedUser() async{

    String email = await _secureStorage.readSecureData('email');

    dynamic groupsValue = sharedPreferences.get(Strings.groups);
    List<String> groups = [];

    if(groupsValue != null){

      List<dynamic> groupsDynamic = jsonDecode(groupsValue);
      if(groupsDynamic.isNotEmpty){
        groups = groupsDynamic.map((value) => value as String).toList();
      }

    }

    user = AuthenticatedUser(
        uid: sharedPreferences.get(Strings.uid),
        email: email,
        name: GlobalFunctions.decryptString(sharedPreferences.get(Strings.name)),
        nameLowercase: GlobalFunctions.decryptString(sharedPreferences.get(Strings.nameLowercase)),
        groups: groups.isEmpty ? null : groups,
        mobile: GlobalFunctions.decryptString(sharedPreferences.get(Strings.mobile)),
        role: sharedPreferences.get(Strings.role),
        token: sharedPreferences.get(Strings.token),
        tokenExpiryTime: sharedPreferences.get(Strings.tokenExpiryTime),
        suspended: sharedPreferences.getBool(Strings.suspended),
        deleted: sharedPreferences.getBool(Strings.deleted),
        termsAccepted: sharedPreferences.getBool(Strings.termsAccepted),
        forcePasswordReset: sharedPreferences.getBool(Strings.forcePasswordReset),
        profilePicture: sharedPreferences.get(Strings.profilePicture),

    );
  }



  Future<void> createOnlineAuthenticatedUser ({@required String uid, @required String email, @required String token, @required String tokenExpiryTime, @required Map<String, dynamic> snapshotData}) async {

    List<dynamic> groupsDynamic = [];
    if(snapshotData[Strings.groups] != null) groupsDynamic = snapshotData[Strings.groups];
    List<String> groups = [];
    if(groupsDynamic.isNotEmpty){
      groups = groupsDynamic.map((value) => value as String).toList();
    }

    user = AuthenticatedUser(
      uid: GlobalFunctions.databaseValueString(uid),
      email: GlobalFunctions.databaseValueString(email),
      name: GlobalFunctions.databaseValueString(snapshotData[Strings.name]),
      nameLowercase: GlobalFunctions.databaseValueString(snapshotData[Strings.nameLowercase]),
      groups: groups.isEmpty ? null : groups,
      mobile: GlobalFunctions.databaseValueString(snapshotData[Strings.mobile]),
      role: GlobalFunctions.databaseValueString(snapshotData[Strings.role]),
      token: GlobalFunctions.databaseValueString(token),
      tokenExpiryTime: GlobalFunctions.databaseValueString(tokenExpiryTime),
      suspended: GlobalFunctions.databaseValueBool(snapshotData[Strings.suspended]),
      deleted: GlobalFunctions.databaseValueBool(snapshotData[Strings.deleted]),
      termsAccepted: GlobalFunctions.databaseValueBool(snapshotData[Strings.termsAccepted]),
      forcePasswordReset: GlobalFunctions.databaseValueBool(snapshotData[Strings.forcePasswordReset]),
      profilePicture: snapshotData[Strings.profilePicture] == null ? null : snapshotData[Strings.profilePicture]
    );


    //Store user information in shared preferences
    sharedPreferences.setString(Strings.uid, uid);
    if(kIsWeb){
      sharedPreferences.setString(Strings.email, GlobalFunctions.encryptString(user.email));
    }
    sharedPreferences.setString(Strings.name, GlobalFunctions.encryptString(user.name));
    sharedPreferences.setString(Strings.nameLowercase, GlobalFunctions.encryptString(user.nameLowercase));
    sharedPreferences.setString(Strings.groups, groups.isEmpty ? null : jsonEncode(groups));
    sharedPreferences.setString(Strings.mobile, GlobalFunctions.encryptString(user.mobile));
    sharedPreferences.setString(Strings.role, user.role);
    sharedPreferences.setString(Strings.token, token);
    sharedPreferences.setString(Strings.tokenExpiryTime, tokenExpiryTime);
    sharedPreferences.setBool(Strings.suspended, user.suspended);
    sharedPreferences.setBool(Strings.deleted, user.deleted);
    sharedPreferences.setBool(Strings.termsAccepted, user.termsAccepted);
    sharedPreferences.setBool(Strings.forcePasswordReset, user.forcePasswordReset);
    sharedPreferences.setBool(Strings.rememberMe, true);
    sharedPreferences.setString(Strings.profilePicture, user.profilePicture);


      //Store user information in local database
      Map<String, dynamic> localData = {
        Strings.uid: GlobalFunctions.databaseValueString(uid),
        Strings.email: GlobalFunctions.encryptString(snapshotData[Strings.email]),
        Strings.name: GlobalFunctions.encryptString(snapshotData[Strings.name]),
        Strings.nameLowercase: GlobalFunctions.encryptString(snapshotData[Strings.nameLowercase]),
        Strings.groups: groups.isEmpty ? null : jsonEncode(groups),
        Strings.mobile: GlobalFunctions.encryptString(snapshotData[Strings.mobile]),
        Strings.role: GlobalFunctions.databaseValueString(snapshotData[Strings.role]),
        Strings.suspended: GlobalFunctions.boolToTinyInt(snapshotData[Strings.suspended]),
        Strings.deleted: GlobalFunctions.boolToTinyInt(snapshotData[Strings.deleted]),
        Strings.termsAccepted: GlobalFunctions.boolToTinyInt(snapshotData[Strings.termsAccepted]),
        Strings.forcePasswordReset: GlobalFunctions.boolToTinyInt(snapshotData[Strings.forcePasswordReset]),
        Strings.profilePicture: snapshotData[Strings.profilePicture] == null ? null : snapshotData[Strings.profilePicture]

      };





    //Sembast
      bool existingUser = false;
      final Db.Finder finder = Db.Finder(filter: Db.Filter.equals(Strings.uid, uid));
      List records = await _usersStore.find(
      await _db,
      finder: finder,
    );

    if(records.length > 0) existingUser = true;

    if(existingUser){
      await _usersStore.update(await _db, localData,
          finder: finder);

    } else {
      int _id = DateTime.now().millisecondsSinceEpoch + int.parse(random_string.randomNumeric(2));
      await _usersStore.record(_id).put(await _db,
          localData);
    }



      // int existingUser = await _databaseHelper.checkUserExists(user.uid);
      //
      // if(existingUser == 0){
      //   print('user not exist');
      //   await _databaseHelper.add(Strings.usersTable, localData);
      // } else {
      //   print('user exist');
      //   await _databaseHelper.updateRow(Strings.usersTable, localData, Strings.uid, user.uid);
      // }

  }




  Future <void> sendPasswordResetEmail(String email) async{

    GlobalFunctions.showLoadingDialog('Sending password reset email');
    bool hasConnection = await GlobalFunctions.hasDataConnection();
    bool error = false;
    String message = '';

    if(hasConnection){



      try {

        await FirebaseAuth.instance.sendPasswordResetEmail(email: email).timeout(Duration(seconds: 30));


      } on TimeoutException catch (_) {


      } catch(e){

        error = true;
        String errorMessage = error.toString();

        if(errorMessage.contains('invalid-email')){

          message = 'Account credentials not found. Please login with a valid email & password';

        } else if(errorMessage.contains('user-not-found')){

          message = 'Account credentials not found. Please enter a registered email';

        } else if(errorMessage.contains('user-disabled')){

          message = 'Your account has been suspended, please contact your administrator';

        } else if(errorMessage.contains('network-request-failed')){

          message = 'No data connection, please try again when you have a valid connection';

        } else {

          message = 'Something went wrong. Please try again';
        }
      }


    } else {
      message = 'No data connection, please try again when you have a valid connection';
    }
    GlobalFunctions.dismissLoadingDialog();
    if(!error) {
      _navigationService.goBack();
      message = 'Reset Password E-mail sent';
    }
    GlobalFunctions.showToast(message);
  }

  Future<bool> changePassword(String newPassword) async {

    String message = '';
    GlobalFunctions.showLoadingDialog('Changing Password...');
    bool success = false;

    bool hasDataConnection = await GlobalFunctions.hasDataConnection();

    if(hasDataConnection) {

      bool authenticated = await reAuthenticate();

      if(authenticated){

        try {

          await FirebaseAuth.instance.currentUser.updatePassword(newPassword).timeout(Duration(seconds: 60));
          _secureStorage.writeSecureData('password', newPassword);
          await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
              {Strings.forcePasswordReset: false}).timeout(Duration(seconds: 60));

          user.forcePasswordReset = false;
          sharedPreferences.setBool(Strings.forcePasswordReset, false);

          //Sembast
          final Db.Finder finder = Db.Finder(filter: Db.Filter.equals(Strings.uid, user.uid));
          await _usersStore.update(await _db, {
            Strings.forcePasswordReset: GlobalFunctions.boolToTinyInt(false)
          },
              finder: finder);


          // await _databaseHelper.updateRow(Strings.usersTable, {
          //   Strings.forcePasswordReset: GlobalFunctions.boolToTinyInt(false)
          // }, Strings.uid, user.uid);




          message = 'Password successfully changed';
          success = true;


        } on TimeoutException catch (_) {

          message = 'Network Timeout communicating with the server, unable edit password';

        } catch(error){

          print(error);
          message = 'Something went wrong. Please try again';

        }

      }
    } else {
      message = 'No data connection, unable to change password';
    }

    GlobalFunctions.dismissLoadingDialog();
    GlobalFunctions.showToast(message);
    return success;


  }

  Future<void> setTermsAccepted() async {

    String message = '';
    GlobalFunctions.showLoadingDialog('Accepting Terms...');
    bool success = false;
    bool hasDataConnection = await GlobalFunctions.hasDataConnection();

    if(hasDataConnection) {

      bool authenticated = await reAuthenticate();

      if(authenticated){

        try {


          await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            Strings.termsAccepted: true
          }).timeout(Duration(seconds: 60));

          user.termsAccepted = true;
          sharedPreferences.setBool(Strings.termsAccepted, true);
          //Sembast
          final Db.Finder finder = Db.Finder(filter: Db.Filter.equals(Strings.uid, user.uid));
          await _usersStore.update(await _db, {
            Strings.termsAccepted: GlobalFunctions.boolToTinyInt(true)
          },
              finder: finder);

          // await _databaseHelper.updateRow(Strings.usersTable, {
          //   Strings.termsAccepted: GlobalFunctions.boolToTinyInt(true)
          // }, Strings.uid, user.uid);
          success = true;



        } on TimeoutException catch (_) {
          // A timeout occurred.
          message = 'Network Timeout communicating with the server, unable to accept terms';
        } catch(error){
          print(error);

          if(error.toString().contains('Missing or insufficient permissions')) print('ok i need to login again');
        }

      }

    } else {

      message = 'No data connection, unable to change password';
    }

    GlobalFunctions.dismissLoadingDialog();
    if(message != '') GlobalFunctions.showToast(message);
    if(success && user.forcePasswordReset == false){
      _navigationService.navigateToReplacement(routes.TransferReportPageRoute);

    } else if(success && user.forcePasswordReset == true){
      _navigationService.navigateToReplacement(routes.ChangePasswordPageRoute);
    }

  }


  // Future<void> createTemporaryForms() async {
  //   final int existingTemporaryTransferReport = await _databaseHelper.checkTemporaryTransferReportExists(false, user.uid, '1');
  //   if(existingTemporaryTransferReport == 0){
  //     await _databaseHelper.add(Strings.temporaryTransferReportTable, {Strings.uid : user.uid, Strings.formVersion: 1, Strings.jobId : '1'});
  //   }
  //   final int existingTemporaryIncidentReport = await _databaseHelper.checkTemporaryIncidentReportExists(false, user.uid, '1');
  //   if(existingTemporaryIncidentReport == 0){
  //     await _databaseHelper.add(Strings.temporaryIncidentReportTable, {Strings.uid : user.uid, Strings.formVersion: 1, Strings.jobId : '1'});
  //   }
  //   final int existingTemporaryBookingForm = await _databaseHelper.checkTemporaryBookingFormExists(false, user.uid, '1');
  //   if(existingTemporaryBookingForm == 0){
  //     await _databaseHelper.add(Strings.temporaryBookingFormTable, {Strings.uid : user.uid, Strings.formVersion: 1, Strings.jobId : '1'});
  //   }
  //   final int existingTemporaryObservationBooking = await _databaseHelper.checkTemporaryObservationBookingExists(false, user.uid, '1');
  //   if(existingTemporaryObservationBooking == 0){
  //     await _databaseHelper.add(Strings.temporaryObservationBookingTable, {Strings.uid : user.uid, Strings.formVersion: 1, Strings.jobId : '1'});
  //   }
  // }



}



class AuthenticatedUser {
  String uid;
  String email;
  String name;
  String nameLowercase;
  List<String> groups;
  String mobile;
  String role;
  String token;
  String tokenExpiryTime;
  bool suspended;
  bool deleted;
  bool termsAccepted;
  bool forcePasswordReset;
  String profilePicture;

  AuthenticatedUser(
      {@required this.uid,
      @required this.email,
      @required this.name,
      @required this.nameLowercase,
      @required this.groups,
      @required this.mobile,
      @required this.role,
      @required this.token,
      @required this.tokenExpiryTime,
      @required this.suspended,
      @required this.deleted,
      @required this.termsAccepted,
      @required this.forcePasswordReset,
      @required this.profilePicture});
}

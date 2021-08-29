import 'dart:convert';
import 'dart:io' show Directory, File, FileSystemEntity, Platform;
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pegasus_medical_1808/utils/database_helper.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:random_string/random_string.dart';
import 'package:encrypt/encrypt.dart' as Encrypt;
import 'package:bot_toast/bot_toast.dart';
import 'dart:async';
import '../shared/global_config.dart';
import '../shared/strings.dart';
import 'package:intl/intl.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:overlay_support/overlay_support.dart' as Notification;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../utils/database.dart';
import 'package:sembast/sembast.dart' as Db;
import 'package:random_string/random_string.dart' as random_string;






import 'global_config.dart';

class GlobalFunctions {

  static void showToast(String message) {
    BotToast.showText(text: message, align: Alignment.center, duration: Duration(milliseconds: 2500));
  }


  static Future <bool> hasDataConnection() async {

    bool connected = false;
    ConnectivityResult connectivityResult = await Connectivity().checkConnectivity();

    if(connectivityResult != ConnectivityResult.none){
      connected = true;
    }

    return connected;
  }


  static bool isTokenExpired()  {

    bool result = false;
    final DateTime parsedExpiryTime = DateTime.parse(sharedPreferences.getString(Strings.tokenExpiryTime));
    if (parsedExpiryTime.isBefore(DateTime.now())) {
      //renew the session
      result = true;
    }
    return result;
  }

  static String getFirebaseAppId () {
    String firebaseAppId;
    if(kIsWeb){
      if(!releaseMode) firebaseAppId = firebaseAppIdWebDev;
    } else {
      if(releaseMode && Platform.isIOS) firebaseAppId = firebaseAppIdIosLive;
      if(!releaseMode && Platform.isIOS) firebaseAppId = firebaseAppIdIosDev;
      if(releaseMode && Platform.isAndroid) firebaseAppId = firebaseAppIdAndroidLive;
      if(!releaseMode && Platform.isAndroid) firebaseAppId = firebaseAppIdAndroidDev;
    }
    return firebaseAppId;
  }


  static String encryptString(String value) {
    String encryptedValueIv;

    if (value == null || value == '' || value.isEmpty) {
      encryptedValueIv = '';
    } else {
      final Encrypt.IV initializationVector = Encrypt.IV.fromUtf8(randomAlpha(8));
      final encrypter = Encrypt.Encrypter(Encrypt.AES(encryptionKey));
      Encrypt.Encrypted encryptedValue = encrypter.encrypt(value, iv: initializationVector);
      String encryptedStringValue = encryptedValue.base16;
      encryptedValueIv = encryptedStringValue + initializationVector.base16;
    }

    return encryptedValueIv;
  }

  static Future<Uint8List> encryptSignature(Uint8List value) async {
    Uint8List encryptedValueIv;

    if (value == null) {
      encryptedValueIv = null;
    } else {
      String jsonString = await compute(jsonEncode, value);

      final Encrypt.IV initializationVector = Encrypt.IV.fromUtf8(randomAlphaNumeric(8));

      final encrypter = Encrypt.Encrypter(Encrypt.AES(encryptionKey));
      Encrypt.Encrypted encryptedValue = encrypter.encrypt(jsonString, iv: initializationVector);

      Uint8List encryptedStringValue = encryptedValue.bytes;

      encryptedValueIv =
          Uint8List.fromList(encryptedStringValue + initializationVector.bytes);
    }

    return encryptedValueIv;
  }

  static String decryptString(String value) {
    String decryptedValue;

    if (value == null || value == '' || value.isEmpty) {
      decryptedValue = '';
    } else {
      int valueLength = value.length;
      int valueRequired = valueLength - 16;
      int startOfIv = valueLength - 16;
      String valueToDecrypt = value.substring(0, valueRequired);
      final Encrypt.IV initializationVector = Encrypt.IV.fromBase16(value.substring(startOfIv));
      final encrypter = Encrypt.Encrypter(Encrypt.AES(encryptionKey));
      decryptedValue = encrypter.decrypt(Encrypt.Encrypted.fromBase16(valueToDecrypt), iv: initializationVector);
    }

    return decryptedValue;
  }

  static Future<Uint8List> decryptSignature(List<dynamic> value) async {
    Uint8List decryptedValue;

    if (value != null) {
      List<dynamic> partsDynamic = value.toList();
      List<int> parts = partsDynamic.cast<int>();

      List<int> ivList = parts.getRange(parts.length - 8, parts.length)
          .toList();

      parts.removeRange(parts.length - 8, parts.length);

      final Encrypt.IV initializationVector = Encrypt.IV(
          Uint8List.fromList(ivList));

      final encrypter = Encrypt.Encrypter(Encrypt.AES(encryptionKey));


      Uint8List onlySignature = Uint8List.fromList(parts);

      String jsonString = encrypter.decrypt(Encrypt.Encrypted(onlySignature), iv: initializationVector);

      dynamic jsonDecodedObject = await compute(jsonDecode, jsonString);

      List<int> intList = jsonDecodedObject.cast<int>();

      decryptedValue = Uint8List.fromList(intList);
    }

    return decryptedValue;
  }



  static void showLocalNotification(String text){
    Notification.OverlaySupportEntry notification;

    notification = Notification.showSimpleNotification(
        Text(text, style: TextStyle(color: Colors.white, fontSize: 12),maxLines: 3, overflow: TextOverflow.ellipsis,),
        leading: Icon(Icons.message, size: 35, color: Colors.white,),
        background: bluePurple,
        autoDismiss: true,
        slideDismissDirection: DismissDirection.up,
        );
  }






  
  static void showLoadingDialog(String message){

    BotToast.showAnimationWidget(
        clickClose: false,
        allowClick: false,
        onlyOne: true,
        crossPage: true,
        wrapToastAnimation: (controller, cancel, child) => Stack(
          children: <Widget>[
            AnimatedBuilder(
              builder: (_, child) => Opacity(
                opacity: controller.value,
                child: child,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.black26),
                child: SizedBox.expand(),
              ),
              animation: controller,
            ),
            CustomOffsetAnimation(
              controller: controller,
              child: child,
            )
          ],
        ),
        toastBuilder: (cancelFunc) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(32.0))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    darkBlue),
              ),
              SizedBox(
                height: 20.0,
              ),
              new Text(
                message,
                style: TextStyle(fontSize: 20.0), textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        animationDuration: Duration(milliseconds: 300));
    
  }

  static void dismissLoadingDialog(){

    BotToast.cleanAll();

  }


  static bool tinyIntToBool(var databaseValue) {
    bool value = false;

    if (databaseValue != null &&
        databaseValue != 'null') {
      if (databaseValue == 1) {
        value = true;
      }
    }

    return value;
  }

  static int boolToTinyInt(var boolValue) {
    int value = 0;

    if (boolValue != null) {
      if (boolValue == true) {
        value = 1;
      }
    }

    return value;
  }

  static String databaseValueString(var databaseValue) {
    String value = databaseValue == null ||
        databaseValue == 'null'
        ? '' : databaseValue;
    return value;
  }


  static String databaseValueDate(var databaseValue, [bool decrypt = false]) {
    final dateFormat = DateFormat("dd/MM/yyyy");
    String value;

    if(databaseValue == null || databaseValue == 'null' || databaseValue == ''){
      value = '';
    } else {
      if(decrypt){
        value = dateFormat.format(DateTime.parse(GlobalFunctions.decryptString(databaseValue)));

      } else {
        value = dateFormat.format(DateTime.parse(databaseValue));

      }
    }
    return value;
  }

  static String databaseValueTime(var databaseValue, [bool decrypt = false]) {

    final timeFormat = DateFormat("HH:mm");
    String value;

    if(databaseValue == null || databaseValue == 'null' || databaseValue == ''){
      value = '';
    } else {
      if(decrypt){
        value = timeFormat.format(DateTime.parse(GlobalFunctions.decryptString(databaseValue)));

      } else {
        value = timeFormat.format(DateTime.parse(databaseValue));

      }
    }
    return value;
  }

  static String databaseValueDateTime(var databaseValue, [bool decrypt = false]) {
    final dateFormat = DateFormat("dd/MM/yyyy HH:mm");
    String value;

    if(databaseValue == null || databaseValue == 'null' || databaseValue == ''){
      value = '';
    } else {
      if(decrypt){
        value = dateFormat.format(DateTime.parse(GlobalFunctions.decryptString(databaseValue)));

      } else {
        value = dateFormat.format(DateTime.parse(databaseValue));

      }
    }
    return value;
  }



  static bool databaseValueBool(var databaseValue) {
    bool value = databaseValue == null ||
        databaseValue == false
        ? false : true;
    return value;
  }

  static bool databaseValueTinyInt(var databaseValue) {
    bool value = false;
    if (databaseValue != null &&
        databaseValue != 'null') {
      if (databaseValue == 1) {
        value = true;
      }
    }
    return value;
  }

  static Future<List<int>> getImageBytes(File image) async {
    List<int> imageBytes = await FlutterImageCompress.compressWithFile(
        image.absolute.path, quality: 90, keepExif: true);
    return imageBytes;
  }

  static String getBase64Image(List<int> imageBytes) {
    String base64Image = base64Encode(imageBytes);
    return base64Image;
  }

  static checkFirebaseStorageFail(DatabaseHelper databaseHelper) async {

    final _firebaseStorageUrlStore = Db.intMapStoreFactory.store(FIREBASE_STORAGE_URL_STORE_NAME);

    final Db.Finder finder = Db.Finder(filter: Db.Filter.equals(Strings.uid, user.uid));

    List records = await _firebaseStorageUrlStore.find(
      await _db,
      finder: finder,
    );

    if(records.length > 0){

      List<dynamic> urlList = await jsonDecode(records[0].value['url_list']);

      for (String url in urlList) {
        if(kIsWeb){
          await FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/' + url).delete();
        } else {
          await FirebaseStorage.instance.ref().child(url).delete();
        }
      }

      await _firebaseStorageUrlStore.delete(await _db,
          finder: finder);
      }
    }

  // static checkFirebaseStorageFail(DatabaseHelper databaseHelper) async {
  //   final int existingFirebaseStorageRow = await databaseHelper
  //       .checkFirebaseStorageRowExists(user.uid);
  //
  //   if (existingFirebaseStorageRow != 0) {
  //     List<Map<String, dynamic>> storageRows = [];
  //
  //     storageRows = await databaseHelper.getRowsWhere(
  //         Strings.firebaseStorageUrlTable, Strings.uid, user.uid);
  //
  //     if (storageRows.length > 0) {
  //       Map<String, dynamic> row = storageRows[0];
  //
  //       List<dynamic> urlList = await jsonDecode(row['url_list']);
  //
  //       for (String url in urlList) {
  //         await FirebaseStorage.instance.ref().child(url).delete();
  //       }
  //
  //       databaseHelper.deleteFirebaseRow(
  //           Strings.firebaseStorageUrlTable, user.uid);
  //     }
  //   }
  // }

  static Future<Db.Database> get _db async => await AppDatabase.instance.database;

  static checkAddFirebaseStorageRow(List<String> storageUrlList,
      DatabaseHelper databaseHelper) async {

    final _firebaseStorageUrlStore = Db.intMapStoreFactory.store(FIREBASE_STORAGE_URL_STORE_NAME);

    if (storageUrlList != null && storageUrlList.length > 0) {
      String storageUrlJson = await compute(jsonEncode, storageUrlList);

      int _id = DateTime.now().millisecondsSinceEpoch + int.parse(random_string.randomNumeric(2));
      await _firebaseStorageUrlStore.record(_id).put(await _db,
          {'uid': user.uid, 'url_list': storageUrlJson});

      // await databaseHelper.add(
      //   Strings.firebaseStorageUrlTable,
      //   {'uid': user.uid, 'url_list': storageUrlJson},
      // );
    }
  }

  static RichText boldTitleText(String title, String field, BuildContext context){

    return RichText(
      text: TextSpan(
        text: title,
        style: TextStyle(fontFamily: 'Open Sans', fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.caption.color,),
        children: [
          TextSpan(
              text: field,
              style: TextStyle(fontFamily: 'Open Sans',
                fontWeight: FontWeight.normal,
                color: Theme.of(context).textTheme.caption.color,)
          ),
        ],
      ),
    );

  }


  static Future<void> deleteActivityLogImages() async {
    final Directory extDir = await getApplicationDocumentsDirectory();

    final String dirPath = '${extDir.path}/images${user.uid}/activityLogs';
    Directory dir = Directory(dirPath);

    if (dir.existsSync()) {
      print('it clearly exists');
      dir.deleteSync(recursive: true);
    } else {
      print('doe not exist');
    }
  }

  static getSelectedValue(Map<String, dynamic> object, TextEditingController controller, String value){
    if (object[value] != null) {
      controller.text =
          GlobalFunctions.databaseValueString(object[value]);
    } else {
      controller.text = '';
    }
  }

  static getSelectedValueDate(Map<String, dynamic> object, TextEditingController controller, String value){
    final dateFormat = DateFormat("dd/MM/yyyy");

    if (object[value] != null && object[value] != '') {
      controller.text =
          dateFormat.format(DateTime.parse(object[value]));
    } else {
      controller.text = '';
    }
  }
  static getSelectedValueTime(Map<String, dynamic> object, TextEditingController controller, String value){
    final timeFormat = DateFormat("HH:mm");

    if (object[value] != null && object[value] != '') {
      controller.text =
          timeFormat.format(DateTime.parse(object[value]));
    } else {
      controller.text = '';
    }
  }

  static getTemporaryValue(Map<String, dynamic> object, TextEditingController controller, String value, [bool decrypt = true]){
    if (object[value] != null) {
      if(decrypt){
        controller.text = GlobalFunctions.decryptString(
            object[value]);
      } else {
        controller.text = GlobalFunctions.databaseValueString(
            object[value]);
      }

    } else {
      controller.text = '';
    }
  }

  static getTemporaryValueDate(Map<String, dynamic> object, TextEditingController controller, String value, [bool decrypt = false]){
    final dateFormat = DateFormat("dd/MM/yyyy");

    if (object[value] != null) {
      if(decrypt){
        controller.text =
            dateFormat.format(DateTime.parse(GlobalFunctions.decryptString(object[value])));
      } else {
        controller.text =
            dateFormat.format(DateTime.parse(object[value]));
      }

    } else {
      controller.text = '';
    }
  }

  static getTemporaryValueTime(Map<String, dynamic> object, TextEditingController controller, String value){
    final timeFormat = DateFormat("HH:mm");
    if (object[value] != null) {
      controller.text =
          timeFormat.format(DateTime.parse(object[value]));
    } else {
      controller.text = '';
    }
  }

  static getTemporaryValueDateTime(Map<String, dynamic> object, TextEditingController controller, String value, [bool decrypt = false]){
    final dateFormat = DateFormat("dd/MM/yyyy HH:mm");

    if (object[value] != null) {
      if(decrypt){
        controller.text =
            dateFormat.format(DateTime.parse(GlobalFunctions.decryptString(object[value])));
      } else {
        controller.text =
            dateFormat.format(DateTime.parse(object[value]));
      }

    } else {
      controller.text = '';
    }
  }

  static IconData buildShareIconForms(String option){
    IconData returnedIcon = Icons.clear;
    if(option == 'Email Report') returnedIcon = Icons.email;
    if(option == 'Email Results') returnedIcon = Icons.email;
    if(option == 'Email Invoices') returnedIcon = Icons.email;
    if(option == 'Print') returnedIcon = Icons.print;
    if(option == 'Share') returnedIcon = Icons.share;
    if(option == 'Edit') returnedIcon = Icons.edit;
    if(option == 'Download') returnedIcon = Icons.download_sharp;
    if(option == 'Delete') returnedIcon = Icons.delete;

    return returnedIcon;

  }

  static Future<void> saveDeviceToken([String playerId]) async {

    if(playerId != null){

      var playerIdRef = FirebaseFirestore.instance.collection('users')
          .doc(user.uid)
          .collection('player_ids')
          .doc(playerId);

      await playerIdRef.set({
        'token': playerId,
        'created_at': FieldValue.serverTimestamp(),
        'platform': Platform.operatingSystem
      }).timeout(Duration(seconds: 60));
    }

  }

  static Future<void> sendPushNotification(String userDocumentId, String title,
      String body) async {


    QuerySnapshot playerIdSnapshot = await FirebaseFirestore.instance.collection('users').doc(userDocumentId).collection('player_ids').get();

    List<String> playerIds = [];


    if (playerIdSnapshot.docs.length > 0) {
      for (DocumentSnapshot snap in playerIdSnapshot.docs) {
        playerIds.add(snap.id);
      }
    }

    if (playerIds.length > 0) {

      OSCreateNotification notification = OSCreateNotification(
        playerIds: playerIds,
        content: body,
        heading: title,
      );


      try{
        Map<String, dynamic> response = await OneSignal.shared.postNotification(notification);

        print('this is the response:');

        print(response);
      } catch(e){
        print('this is the error');
        print(e);
      }

    }

  }

}




class CustomOffsetAnimation extends StatefulWidget {
  final AnimationController controller;
  final Widget child;

  const CustomOffsetAnimation({Key key, this.controller, this.child})
      : super(key: key);

  @override
  _CustomOffsetAnimationState createState() => _CustomOffsetAnimationState();
}

class _CustomOffsetAnimationState extends State<CustomOffsetAnimation> {
  Tween<Offset> tweenOffset;
  Tween<double> tweenScale;

  Animation<double> animation;

  @override
  void initState() {
    tweenOffset = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    );
    tweenScale = Tween<double>(begin: 0.3, end: 1.0);
    animation =
        CurvedAnimation(parent: widget.controller, curve: Curves.decelerate);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      child: widget.child,
      animation: widget.controller,
      builder: (BuildContext context, Widget child) {
        return FractionalTranslation(
            translation: tweenOffset.evaluate(animation),
            child: ClipRect(
              child: Transform.scale(
                scale: tweenScale.evaluate(animation),
                child: Opacity(
                  child: child,
                  opacity: animation.value,
                ),
              ),
            ));
      },
    );
  }
}
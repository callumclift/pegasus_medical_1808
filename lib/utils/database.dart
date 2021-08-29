import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:pegasus_medical_1808/shared/global_config.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast_web/sembast_web.dart';
import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';
import 'encrypt_codec.dart';
import 'package:pegasus_medical_1808/shared/global_functions.dart';

class AppDatabase {
  // Singleton instance
  static final AppDatabase _singleton = AppDatabase._();
  // Singleton accessor
  static AppDatabase get instance => _singleton;

  // Completer is used for transforming synchronous code into asynchronous code.
  Completer<Database> _dbOpenCompleter;

  // A private constructor. Allows us to create instances of AppDatabase
  // only from within the AppDatabase class itself.
  AppDatabase._();

  // Database object accessor
  Future<Database> get database async {
    // If completer is null, AppDatabaseClass is newly instantiated, so database is not yet opened
    if (_dbOpenCompleter == null) {
      _dbOpenCompleter = Completer();
      // Calling _openDatabase will also complete the completer with database instance
      _openDatabase();
    }
    // If the database is already opened, awaiting the future will happen instantly.
    // Otherwise, awaiting the returned future will take some time - until complete() is called
    // on the Completer in _openDatabase() below.
    return _dbOpenCompleter.future;
  }


  Future _openDatabase() async {



    String dbPath;

    if(!kIsWeb){
      // Get a platform-specific directory where persistent app data can be stored
      final appDocumentDir = await getApplicationDocumentsDirectory();
      // Path with the form: /platform-specific-directory/demo.db
      //dbPath = appDocumentDir.path + 'appdatabase.db';
      dbPath = join(appDocumentDir.path, 'appdatabase.db');

    }



    var codec = getEncryptSembastCodec(password: databasePassword);

    Database database;

    if(kIsWeb){
      database = await databaseFactoryWeb.openDatabase('appdatabase', codec: codec);
    } else {
      try {
        //database = await databaseFactoryIo.openDatabase(dbPath, codec: codec);
        database = await databaseFactoryIo.openDatabase(dbPath, codec: codec);
      } catch(e) {
        print(e.toString());
      }
    }

    // Any code awaiting the Completer's future will now start executing
    _dbOpenCompleter.complete(database);
  }
}
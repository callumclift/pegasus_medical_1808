import 'dart:io' show Platform;
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:pegasus_medical_1808/pages/login_page/change_password_page.dart';
import 'package:pegasus_medical_1808/pages/login_page/terms_conditions_page.dart';
import 'package:pegasus_medical_1808/pages/messaging/messaging.dart';
import 'package:pegasus_medical_1808/pages/transfer_report/transfer_report_overall.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pegasus_medical_1808/services/navigation_service.dart';
import 'package:pegasus_medical_1808/shared/global_config.dart';
import 'package:provider/provider.dart';
import './models/authentication_model.dart';
import 'models/booking_form_model.dart';
import 'models/chat_model.dart';
import 'models/incident_report_model.dart';
import 'models/observation_booking_model.dart';
import 'models/spot_checks_model.dart';
import 'models/transfer_report_model.dart';
import 'models/users_model.dart';
import 'pages/home_page/home_page.dart';
import 'pages/login_page/login_page.dart';
import 'package:bot_toast/bot_toast.dart';
import './shared/global_config.dart';
import './shared/global_functions.dart';
import './locator.dart';
import './router.dart' as router;
import './constants/route_paths.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_strategy/url_strategy.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;





void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sharedPreferences = await SharedPreferences.getInstance();
  setupLocator();
  String firebaseAppId = GlobalFunctions.getFirebaseAppId();
  final FirebaseOptions firebaseOptions = FirebaseOptions(
    storageBucket: firebaseStorageBucket,
    appId: firebaseAppId,
    apiKey: firebaseApiKey,
    projectId: firebaseProjectId,
    messagingSenderId: firebaseMessagingSenderId,
  );

  Firebase.initializeApp(options: firebaseOptions);

  setPathUrlStrategy();
  runApp(MyApp());
}


class MyApp extends StatefulWidget {

  MyApp();

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  AuthenticationModel _authenticationModel = AuthenticationModel();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _authenticationModel.autoLogin();
    if(!kIsWeb){
      initOneSignal();
    }
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    print('didChangeDependancies');
  }

  @override
  void dispose() {
    super.dispose();
  }


  Future<void> initOneSignal() async {

    await OneSignal.shared.init(
        oneSignalAppId,
        iOSSettings: {
          OSiOSSettings.autoPrompt: false,
          OSiOSSettings.inAppLaunchUrl: true
        }
    );

    OneSignal.shared.setNotificationReceivedHandler((OSNotification notification) {
      // will be called whenever a notification is received
      print('value of on messages');
      print(onMessages);
      if(showLocalNotification && onMessages == false){
        GlobalFunctions.showLocalNotification(notification.payload.body);
      } else if(showLocalNotification && onMessages == true) {
        // use navigation service instead
        // Navigator.pushReplacement(
        //   context,
        //   PageRouteBuilder(
        //     pageBuilder: (context, animation1, animation2) => MessagesPage(),
        //     transitionDuration: Duration(seconds: 0),
        //   ),
        // );
      }
      showLocalNotification = true;
    });

    OneSignal.shared.setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      // will be called whenever a notification is opened/button pressed.
      print('opened');
      showLocalNotification = false;
      notificationReceived = true;
        locator<NavigationService>().navigateToReplacement(MessagesRoute);
    });

    OneSignal.shared
        .setInFocusDisplayType(OSNotificationDisplayType.none);

  }

  Widget chooseHomePage(){
    Widget returnedRoute;
    if(user == null){
      returnedRoute = LoginPage();
    } else if(user.termsAccepted == false) {
      returnedRoute = TermsConditionsPage();
    } else if(user.forcePasswordReset == true) {
      returnedRoute = ChangePasswordPage();
    } else if(notificationReceived) {
      returnedRoute = MessagesPage();
    } else
    {
      returnedRoute = HomePage();
    }
    return returnedRoute;
  }


  Widget chooseHomePageWeb() {
    return StreamBuilder<FirebaseAuth.User>(
      stream: FirebaseAuth.FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, snapshot) {
        Widget returnedRoute;
        if (snapshot.hasData) {
          returnedRoute = chooseHomePage();
        } else if(!snapshot.hasData && user != null) {
          return Container(
            decoration: BoxDecoration(gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [purpleDesign, purpleDesign])
            ),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),);
        } else {
          returnedRoute = LoginPage();
        }
        return returnedRoute;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics analytics = FirebaseAnalytics();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthenticationModel>(create: (_) => _authenticationModel),
        ChangeNotifierProxyProvider<AuthenticationModel, UsersModel>(
          update: (context, authenticationModel, usersModel) => UsersModel(authenticationModel),
        ),
        ChangeNotifierProxyProvider<AuthenticationModel, TransferReportModel>(
          update: (context, authenticationModel, transferReportModel) => TransferReportModel(authenticationModel),
        ),
        ChangeNotifierProxyProvider<AuthenticationModel, IncidentReportModel>(
          update: (context, authenticationModel, incidentReportModel) => IncidentReportModel(authenticationModel),
        ),
        ChangeNotifierProxyProvider<AuthenticationModel, ObservationBookingModel>(
          update: (context, authenticationModel, observationBookingModel) => ObservationBookingModel(authenticationModel),
        ),
        ChangeNotifierProxyProvider<AuthenticationModel, SpotChecksModel>(
          update: (context, authenticationModel, spotChecksModel) => SpotChecksModel(authenticationModel),
        ),
        ChangeNotifierProxyProvider<AuthenticationModel, BookingFormModel>(
          update: (context, authenticationModel, bookingFormModel) => BookingFormModel(authenticationModel),
        ),
        ChangeNotifierProxyProvider<AuthenticationModel, ChatModel>(
          update: (context, authenticationModel, chatModel) => ChatModel(authenticationModel),
        ),
      ],
      child: OverlaySupport(child: MaterialApp(
        onGenerateRoute: router.generateRoute,
        initialRoute: HomePageRoute,
        navigatorKey: locator<NavigationService>().navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Pegasus Medical',
        builder: BotToastInit(),
        navigatorObservers: [
          BotToastNavigatorObserver(),
          FirebaseAnalyticsObserver(analytics: analytics),
        ],
        theme: ThemeData(
          fontFamily: 'Open Sans',
          primarySwatch: Colors.indigo,
          primaryColor: bluePurple,
          buttonColor: blueDesign,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Consumer<AuthenticationModel>(
            builder: (BuildContext context, model, child) {
              return model.isLoading? Container(
                decoration: BoxDecoration(gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [purpleDesign, purpleDesign])
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),) : kIsWeb ? chooseHomePageWeb() : chooseHomePage();
            }),
      )),
    );
  }
}




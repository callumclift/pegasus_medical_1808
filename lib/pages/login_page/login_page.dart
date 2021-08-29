import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pegasus_medical_1808/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import '../../locator.dart';
import '../../shared/global_config.dart';
import '../../models/authentication_model.dart';
import 'reset_password.dart';
import '../../constants/route_paths.dart' as routes;
import 'package:after_layout/after_layout.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;



class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with AfterLayoutMixin<LoginPage> {
  GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final NavigationService _navigationService = locator<NavigationService>();



  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _passwordController.addListener(() {
      if((RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
          .hasMatch(_emailController.text)) && _passwordController.text.length > 7){
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          context.read<AuthenticationModel>().setLoginButtonEnabledTrue();
        });

      } else {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          context.read<AuthenticationModel>().setLoginButtonEnabledFalse();
        });

      }
    });
    _emailController.addListener(() {
      if((RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
          .hasMatch(_emailController.text)) && _passwordController.text.length > 7){
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          context.read<AuthenticationModel>().setLoginButtonEnabledTrue();
        });

      } else {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          context.read<AuthenticationModel>().setLoginButtonEnabledFalse();
        });

      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    // Calling the same function "after layout" to resolve the issue.
//    if(Theme.of(context).brightness == Brightness.dark){
//      GlobalFunctions.setLightMode(context);
//    }

  if(!kIsWeb){
    if(Platform.isIOS)  OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {
      print("Accepted permission: $accepted");
    });
  }
  }

  void _submitForm() async {
    FocusScope.of(context).unfocus();
    await context.read<AuthenticationModel>().login(_emailController.text, _passwordController.text);
  }

  Widget _buildEmailTextField() {
    return TextFormField(
      autofillHints: [AutofillHints.email],
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(color: pegasusPurple, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
          contentPadding: EdgeInsets.all(20),
          focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: pegasusBlue, width: 3.0),
              borderRadius: BorderRadius.circular(50)),
          errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: pegasusBlue, width: 1.5),
              borderRadius: BorderRadius.circular(50)),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: pegasusBlue, width: 1.5),
              borderRadius: BorderRadius.circular(50)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: pegasusBlue, width: 3.0),
              borderRadius: BorderRadius.circular(50)),
          labelStyle: TextStyle(color: pegasusPurple),
          hintText: 'Email',
          hintStyle: TextStyle(color: pegasusPurple.withOpacity(0.6)),
          filled: true,
          fillColor: Colors.white),
      validator: (String value) {
        return (!RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
            .hasMatch(value))
            ? 'Please enter a valid email/username'
            : null;
      },
    );
  }

  Widget _buildPasswordTextField() {
    return TextFormField(
      autofillHints: [AutofillHints.password],
      onEditingComplete: () => TextInput.finishAutofillContext(),
      controller: _passwordController,
      style: TextStyle(color: pegasusPurple, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
          contentPadding: EdgeInsets.all(20),
          focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: pegasusBlue, width: 3.0),
              borderRadius: BorderRadius.circular(50)),
          errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: pegasusBlue, width: 1.5),
              borderRadius: BorderRadius.circular(50)),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: pegasusBlue, width: 1.5),
              borderRadius: BorderRadius.circular(50)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: pegasusBlue, width: 3.0),
              borderRadius: BorderRadius.circular(50)),
          labelStyle: TextStyle(color: pegasusBlue),
          hintText: 'Password',
          hintStyle: TextStyle(color: pegasusPurple.withOpacity(0.6)),
          filled: true,
          fillColor: Colors.white),
      obscureText: true,
      autocorrect: false,
      validator: (String value) {
        return (value.isEmpty && value.trim().length <= 0) || value.length < 8
            ? 'Password must be at least 4 characters long'
            : null;
      },
    );
  }

  Widget _buildLoadingLogin() {
    Widget returnedWidget;

    if (context.read<AuthenticationModel>().isLoading) {
      returnedWidget = Column(
        children: <Widget>[
          CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(blueDesign),
          ),
          SizedBox(
            height: 10.0,
          )
        ],
      );
    } else {
      returnedWidget = Theme(
        data: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          fontFamily: 'Open Sans',
        ),
        child: Consumer<AuthenticationModel>(
          builder: (context, authenticationModel, child) => authenticationModel.isLoadingLogin ? CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
                blueDesign),
          ) :ElevatedButton(
            style: ButtonStyle(padding: MaterialStateProperty.resolveWith((states) => EdgeInsets.fromLTRB(20, 5, 20, 5)),
              overlayColor: authenticationModel.loginButtonEnabled ? MaterialStateColor.resolveWith((states) => pegasusGray) : MaterialStateProperty.all(Colors.transparent),
              elevation: MaterialStateProperty.resolveWith((states) => 0),
              shape: MaterialStateProperty.resolveWith((states) => RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
              )),
              backgroundColor: authenticationModel.loginButtonEnabled ? MaterialStateColor.resolveWith((states) => pegasusBlue) : MaterialStateColor.resolveWith((states) => pegasusGray),
            ),
            onPressed: () => authenticationModel.loginButtonEnabled ? _submitForm() : null,
            child: Text('Login', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
          ),
        ),
      );
    }

    return returnedWidget;
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double deviceHeight = MediaQuery.of(context).size.height;
    final double targetWidth =
        deviceWidth > 800.0 ? deviceWidth * 0.5 : deviceWidth * 0.9;
    return Scaffold(
      body: Container(
          decoration: BoxDecoration(
              color: pegasusPurple),
          padding: EdgeInsets.all(10.0),
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(10.0)),
                padding: EdgeInsets.all(10.0),
                width: targetWidth,
                child: Form(
                  key: _loginFormKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/images/pegasusPurple.png',
                        height: deviceHeight * 0.14,
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      AutofillGroup(child: Column(
                        children: [
                          _buildEmailTextField(),
                          SizedBox(
                            height: 10.0,
                          ),
                          _buildPasswordTextField(),
                        ],
                      )),
                      SizedBox(
                        height: 10.0,
                      ),
                      //_buildRememberMeListTile(),
                      _buildLoadingLogin(),
                      SizedBox(
                        height: 10,
                      ),
                      Consumer<AuthenticationModel>(
                        builder: (context, authenticationModel, child) => Text(authenticationModel.loginErrorMessage, style: TextStyle(color: Colors.red), textAlign: TextAlign.center,),
                      ),
                      SizedBox(height: 10,),
                      Row(
                          children: <Widget>[
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                            showDialog(barrierDismissible: false,
                                context: context,
                                builder: (BuildContext context) {
                                  return ResetPassword();
                                });
                                },
                                child: Text(
                                  'Forgot Password?',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ),
                          ],
                        ),
//                            RaisedButton(onPressed: _handleSignIn),
                    ],
                  ),
                ),
              ),
            ),
          )),
    );
  }
}

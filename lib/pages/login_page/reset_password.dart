import 'package:pegasus_medical_1808/models/authentication_model.dart';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../../shared/global_config.dart';
import '../../shared/global_functions.dart';

class ResetPassword extends StatefulWidget {
  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailFieldController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();

  Color _emailLabelColor = Colors.grey;

  @override
  void initState() {
    _emailFocusNode.addListener(() {
      if (mounted) {
        if (_emailFocusNode.hasFocus) {
          setState(() {
            _emailLabelColor = blueDesign;
          });
        } else {
          setState(() {
            _emailLabelColor = Colors.grey;
          });
        }
      }
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _emailFieldController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32.0))),
      contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
      titlePadding: EdgeInsets.all(0),
      title: Container(
        padding: EdgeInsets.only(top: 10, bottom: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [pegasusPurple, pegasusPurple]),
              //colors: [purpleDesign, purpleDesign]),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
        ),
        child: Center(child: Text("Reset Password", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),),
      ),
      content: Form(
          key: _formKey,
          child: SingleChildScrollView(child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                  'Please enter your E-mail, used in registration with us.'),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Flexible(
                      child: TextFormField(
                        validator: (String value) {
                          String message;
                          if (value == '' || value.isEmpty || value.trim().length > 0 &&
                              !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                                  .hasMatch(value)) {
                            message =  'Please enter a valid email';
                          }
                          return message;
                        },
                        keyboardType: TextInputType.emailAddress,
                        focusNode: _emailFocusNode,
                        decoration: InputDecoration(
                            labelStyle: TextStyle(color: _emailLabelColor),
                            labelText: 'Email',
                            suffixIcon: _emailFieldController.text == ''
                                ? null
                                : IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    SchedulerBinding.instance.addPostFrameCallback((_) {
                                    FocusScope.of(context).unfocus();
                                    _emailFieldController.clear();
                                    });
                                  });
                                })
                        ),
                        controller: _emailFieldController,
                      )),
                ],
              ),
            ],
          ),)),
      actions: <Widget>[
        FlatButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(color: blueDesign, fontWeight: FontWeight.bold),
          ),
        ),
        FlatButton(
          onPressed: () async {

            print('validation status');
            print(_formKey.currentState.validate());
            print(_emailFieldController.text);

            if(_formKey.currentState.validate()){

              ConnectivityResult connectivityResult = await Connectivity().checkConnectivity();

              if (connectivityResult == ConnectivityResult.none) {

              } else {

                await context.read<AuthenticationModel>().sendPasswordResetEmail(_emailFieldController.text);

              }

            }

          },
          child: Text(
            'OK',
            style: TextStyle(color: blueDesign, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}


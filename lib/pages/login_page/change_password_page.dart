import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pegasus_medical_1808/models/authentication_model.dart';
import 'package:pegasus_medical_1808/services/navigation_service.dart';
import 'package:pegasus_medical_1808/shared/global_config.dart';
import 'package:pegasus_medical_1808/widgets/app_bar_gradient.dart';
import 'package:pegasus_medical_1808/widgets/gradient_button.dart';
import '../../locator.dart';
import 'package:provider/provider.dart';
import '../../constants/route_paths.dart' as routes;


class ChangePasswordPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ChangePasswordPageState();
  }
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {

  final NavigationService _navigationService = locator<NavigationService>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final FocusNode _newPasswordFocusNode = new FocusNode();
  final FocusNode _confirmPasswordFocusNode = new FocusNode();

  Color _newPasswordLabelColor = Colors.grey;
  Color _confirmPasswordLabelColor = Colors.grey;

  @override
  void initState() {
    _setupFocusNodes();
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _newPasswordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  _setupFocusNodes() {
    _newPasswordFocusNode.addListener(() {
      if (mounted) {
        if (_newPasswordFocusNode.hasFocus) {
          setState(() {
            _newPasswordLabelColor = blueDesign;
          });
        } else {
          setState(() {
            _newPasswordLabelColor = Colors.grey;
          });
        }
      }
    });
    _confirmPasswordFocusNode.addListener(() {
      if (mounted) {
        if (_confirmPasswordFocusNode.hasFocus) {
          setState(() {
            _confirmPasswordLabelColor = blueDesign;
          });
        } else {
          setState(() {
            _confirmPasswordLabelColor = Colors.grey;
          });
        }
      }
    });
  }

  Widget _buildNewPasswordField() {
    return TextFormField(
      obscureText: true, focusNode: _newPasswordFocusNode,
      decoration: InputDecoration(
        labelStyle: TextStyle(color: _newPasswordLabelColor),
        labelText: 'New Password',
          suffixIcon: _newPasswordController.text == ''
              ? null
              : IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    FocusScope.of(context).unfocus();
                    _newPasswordController.clear();
                  });
                });
              })
      ),
      controller: _newPasswordController,
      //initialValue: product == null ? '' : product.title,
      validator: (String value) {
        String message;
        if (value.trim().length <= 0 && value.isEmpty) {
          message = 'Please enter a new password';
        }
        if (value.length < 8) {
          message = 'Password must be at least 8 characters long';
        }
        if (value != _confirmPasswordController.text) {
          message = 'New password and confirm new password fields should match';
        }
        return message;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      obscureText: true, focusNode: _confirmPasswordFocusNode,
      decoration: InputDecoration(
        labelStyle: TextStyle(color: _confirmPasswordLabelColor),
        labelText: 'Confirm Password',
          suffixIcon: _confirmPasswordController.text == ''
              ? null
              : IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    FocusScope.of(context).unfocus();
                    _confirmPasswordController.clear();
                  });
                });
              })
      ),
      controller: _confirmPasswordController,
      validator: (String value) {
        String message;
        if (value.trim().length <= 0 && value.isEmpty) {
          message = 'Please re-enter the new password';
        }
        if (value.length < 8) {
          message = 'Password must be at least 8 characters long';
        }
        if (value != _newPasswordController.text) {
          message = 'New password and confirm new password fields should match';
        }
        return message;
      },
    );
  }

  Widget _buildSubmitButton() {
    return Center(
        child: GradientButton('Change Password', () => _changePassword()));
  }

  void _changePassword() async{
    FocusScope.of(context).unfocus();
    if (_formKey.currentState.validate()) {
      bool success = await context.read<AuthenticationModel>().changePassword(_newPasswordController.text);
      if(success) _navigationService.navigateToReplacement(routes.TransferReportPageRoute);
    }
  }

  Widget _buildPageContent(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 768.0 ? 600.0 : deviceWidth * 0.95;
    final double targetPadding = deviceWidth - targetWidth;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        margin: EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: targetPadding / 2),
            child: Column(
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Change Password',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18.0),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10.0,
                ),
                Container(
                    decoration: BoxDecoration(border: Border.all(width: 2.0)),
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                      padding: EdgeInsets.all(5.0),
                      color: Colors.grey,
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.info),
                          SizedBox(
                            width: 5.0,
                          ),
                          Flexible(
                              child: Text(
                                  'To change your password, enter your new password details below. Your new password must be at least 8 characters in length.'))
                        ],
                      ),
                    )),
                _buildNewPasswordField(),
                _buildConfirmPasswordField(),
                SizedBox(
                  height: 10.0,
                ),
                _buildSubmitButton()
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password', style: TextStyle(fontWeight: FontWeight.bold),),
        flexibleSpace: AppBarGradient(),
        actions: [IconButton(icon: Icon(Icons.logout), onPressed: () => context.read<AuthenticationModel>().logout(),)],
      ),
      body: _buildPageContent(context),
    );
  }
}

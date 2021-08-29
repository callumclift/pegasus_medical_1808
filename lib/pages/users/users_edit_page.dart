import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:pegasus_medical_1808/models/users_model.dart';
import 'package:pegasus_medical_1808/widgets/app_bar_gradient.dart';
import 'package:pegasus_medical_1808/widgets/gradient_button.dart';
import '../../shared/global_config.dart';
import '../../widgets/dropdown_form_field.dart';
import 'dart:io';
import 'package:provider/provider.dart';

class UsersEditPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _UsersEditPageState();
  }
}

class _UsersEditPageState extends State<UsersEditPage> {

  bool loading = false;
  final TextEditingController _nameTextController = TextEditingController();
  final TextEditingController _emailFieldController = TextEditingController();
  final TextEditingController _mobileTextController = TextEditingController();


  String _roleValue;
  final List<String> _roleDrop = ['Super User', 'Enhanced User', 'Normal User'];

  final FocusNode _nameFocusNode = new FocusNode();
  final FocusNode _emailFocusNode = new FocusNode();
  final FocusNode _mobileFocusNode = new FocusNode();

  Color _nameLabelColor = Colors.grey;
  Color _emailLabelColor = Colors.grey;
  Color _mobileLabelColor = Colors.grey;



  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  initState(){
    _setupTextControllerValues();
    _setupFocusNodes();
    super.initState();
  }

  @override
  void dispose() {
    _nameTextController.dispose();
    _emailFieldController.dispose();
    _mobileTextController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _mobileFocusNode.dispose();
    super.dispose();
  }

  _setupTextControllerValues(){

    if(context.read<UsersModel>().selectedUser == null){

      _nameTextController.text = '';
      _emailFieldController.text = '';
      _mobileTextController.text = '';



    } else {

      if(context.read<UsersModel>().selectedUser.name == null || context.read<UsersModel>().selectedUser.name == ''){
        _nameTextController.text = '';

      } else {
        _nameTextController.text = context.read<UsersModel>().selectedUser.name;
      }
      if(context.read<UsersModel>().selectedUser.email == null || context.read<UsersModel>().selectedUser.email == ''){
        _emailFieldController.text = '';

      } else {
        _emailFieldController.text = context.read<UsersModel>().selectedUser.email;
      }
      if(context.read<UsersModel>().selectedUser.mobile == null || context.read<UsersModel>().selectedUser.mobile == ''){
        _mobileTextController.text = '';

      } else {
        _mobileTextController.text = context.read<UsersModel>().selectedUser.mobile;
      }
    }

  }


  _setupFocusNodes(){

    _nameFocusNode.addListener((){
      if(mounted) {
        if (_nameFocusNode.hasFocus) {
          setState(() {
            _nameLabelColor = bluePurple;
          });
        } else {
          setState(() {
            _nameLabelColor = Colors.grey;
          });
        }
      }
    });

    _emailFocusNode.addListener((){
      if(mounted) {
        if (_emailFocusNode.hasFocus) {
          setState(() {
            _emailLabelColor = bluePurple;
          });
        } else {
          setState(() {
            _emailLabelColor = Colors.grey;
          });
        }
      }
    });

    _mobileFocusNode.addListener((){
      if(mounted) {
        if (_mobileFocusNode.hasFocus) {
          setState(() {
            _mobileLabelColor = bluePurple;
          });
        } else {
          setState(() {
            _mobileLabelColor = Colors.grey;
          });
        }
      }
    });
  }


  Widget _buildNameTextField() {
    return TextFormField(
      validator: (String value) {
        String message;
        if (value == '' || value.isEmpty || value.trim().length < 1) {
          message =  'Name must not be empty';
        }
        return message;
      },
      focusNode: _nameFocusNode,
      decoration: InputDecoration(
          labelStyle: TextStyle(color: _nameLabelColor),
          labelText: 'Name',
          suffixIcon: _nameTextController.text == ''
              ? null
              : IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    FocusScope.of(context).unfocus();
                    _nameTextController.clear();
                  });
                });
              })
      ),
      controller: _nameTextController,
    );
  }

  TextInputType textInputType(){
    TextInputType type;
    if(kIsWeb){
      type = TextInputType.phone;
    } else if(Platform.isIOS) {
      type = TextInputType.numberWithOptions(signed: true);
    } else {
      type = TextInputType.phone;
    }
    return type;
  }

  Widget _buildMobileTextField() {
    return TextFormField(
      keyboardType: textInputType(),
      validator: (String value) {
        String message;
        if (value == '' || value.isEmpty || value.trim().length < 1) {
          message =  'Mobile must not be empty';
        }
        return message;
      },
      focusNode: _mobileFocusNode,
      decoration: InputDecoration(
          labelStyle: TextStyle(color: _mobileLabelColor),
          labelText: 'Mobile',
          suffixIcon: _mobileTextController.text == ''
              ? null
              : IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    FocusScope.of(context).unfocus();
                    _mobileTextController.clear();
                  });
                });
              })
      ),
      controller: _mobileTextController,
    );
  }



  Widget _buildEmailTextField() {
    return TextFormField(
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
    );
  }

  Widget _buildRoleDrop() {

    String _buildRoleValue() {
      String value;

      if (context.read<UsersModel>().selectedUser != null && _roleValue == null) {
        value = context.read<UsersModel>().selectedUser.role;
        _roleValue = context.read<UsersModel>().selectedUser.role;
      } else if (context.read<UsersModel>().selectedUser == null) {
        value = _roleValue;
      } else if (context.read<UsersModel>().selectedUser != null && _roleValue != null) {
        value = _roleValue;
      }
      return value;
    }

    return DropdownFormField(expanded: false,
      hint: 'Role',
      value: _buildRoleValue(),
      items: _roleDrop.toList(),
      onChanged: (val) => setState(() {
        FocusScope.of(context).requestFocus(new FocusNode());
        _roleValue = val;
      }),
      validator: (val) =>
      (val == null || val.isEmpty) ? 'Please choose a role' : null,
      initialValue: context.read<UsersModel>().selectedUser == null ? '' : context.read<UsersModel>().selectedUser.role,
      onSaved: (val) => setState(() {
        _roleValue = val;
      }),
    );
  }

  Widget _buildSubmitButton() {
    return Consumer<UsersModel>(
        builder: (BuildContext context, UsersModel model, _) {
          return SizedBox(width: 100, child: GradientButton(context.read<UsersModel>().selectedUser == null ? 'Save' : 'Edit', () => _saveUser()),);
        });
  }

  Widget test(){
    return MaterialButton(
      onPressed: () => _saveUser(),
      child: Ink(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [purpleDesign, purpleDesign]),
          borderRadius: BorderRadius.circular(30.0),
        ),
        child:
        Container(
            constraints: BoxConstraints(
                maxWidth: 200.0,
                minHeight: 50.0),
            alignment: Alignment.center,
          child: Text(context.read<UsersModel>().selectedUser == null ? 'Save' : 'Edit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        ),
      ),
      splashColor: Colors.black12,
      padding: EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(32.0),
      ),
    );
  }

  Widget _buildPageContent() {
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
            child: Column(children: <Widget>[
              _buildNameTextField(),
              _buildEmailTextField(),
              _buildMobileTextField(),
              _buildRoleDrop(),
              SizedBox(
                height: 10.0,
              ),
              _buildSubmitButton(),
            ],),
          ),
        ),
      ),
    );
  }

  void _saveUser() async {

    FocusScope.of(context).requestFocus(new FocusNode());
    if (_formKey.currentState.validate()) {

      if(context.read<UsersModel>().selectedUser!= null){
        await context.read<UsersModel>().editUser(_emailFieldController.text, _nameTextController.text, _mobileTextController.text, _roleValue);
      } else {
        await context.read<UsersModel>().addUser(_emailFieldController.text, _nameTextController.text, _mobileTextController.text, _roleValue);

      }

    }


  }

  @override
  Widget build(BuildContext context) {
    print('[Product Create Page] - build page');
    // TODO: implement build
    return Material(
      child: Consumer<UsersModel>(
        builder: (context, model, child) {
          final Widget pageContent = loading ? Center(child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(bluePurple),
          ),): _buildPageContent();
          return model.selectedUser == null
              ? pageContent
              : Scaffold(
            appBar: AppBar(
              title: Text('Edit User', style: TextStyle(fontWeight: FontWeight.bold),),
              flexibleSpace: AppBarGradient(),
            ),
            body: pageContent,
          );
        },
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:pegasus_medical_1808/pages/settings/profile_picture_edit.dart';
import 'package:pegasus_medical_1808/services/secure_storage.dart';
import 'package:pegasus_medical_1808/shared/strings.dart';
import 'package:pegasus_medical_1808/widgets/app_bar_gradient.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pegasus_medical_1808/widgets/gradient_button.dart';
import '../../models/authentication_model.dart';
import '../../models/incident_report_model.dart';
import '../../models/transfer_report_model.dart';
import '../../models/booking_form_model.dart';
import '../../models/observation_booking_model.dart';
import '../../widgets/side_drawer.dart';
import '../../shared/global_config.dart';
import '../../shared/global_functions.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SettingsPageState();
  }
}

class _SettingsPageState extends State<SettingsPage>{

  final SecureStorage _secureStorage = SecureStorage();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey3 = GlobalKey<FormState>();
  bool okPressed = false;

  final TextEditingController _currentPasswordFieldController =
  TextEditingController();
  final TextEditingController _newPasswordFieldController =
  TextEditingController();
  final TextEditingController _confirmPasswordFieldController =
  TextEditingController();

  final FocusNode _currentPasswordFocusNode = new FocusNode();
  final FocusNode _newPasswordFocusNode = new FocusNode();
  final FocusNode _confirmPasswordFocusNode = new FocusNode();

  Color _currentPasswordLabelColor = Colors.grey;
  Color _newPasswordLabelColor = Colors.grey;
  Color _confirmPasswordLabelColor = Colors.grey;

  String _currentPasswordValidationMessage;
  String club = 'Select One';
  List<String> clubDrop = ['Select One'];


  bool transferReports = false;
  bool incidentReports = false;
  bool observationBookings = false;
  bool bookingForms = false;

  @override
  void initState() {

    // TODO: implement initState
    super.initState();
    _setupFocusNodes();
  }

  @override
  void dispose() {
    _currentPasswordFieldController.dispose();
    _newPasswordFieldController.dispose();
    _confirmPasswordFieldController.dispose();
    _currentPasswordFocusNode.dispose();
    _newPasswordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();

    super.dispose();
  }

  _setupFocusNodes(){

    _currentPasswordFocusNode.addListener((){
      if(mounted) {
        if (_currentPasswordFocusNode.hasFocus) {
          setState(() {
            _currentPasswordLabelColor = bluePurple;
          });
        } else {
          setState(() {
            _currentPasswordLabelColor = Colors.grey;
          });
        }
      }
    });
    _newPasswordFocusNode.addListener((){
      if(mounted) {
        if (_newPasswordFocusNode.hasFocus) {
          setState(() {
            _newPasswordLabelColor = bluePurple;
          });
        } else {
          setState(() {
            _newPasswordLabelColor = Colors.grey;
          });
        }
      }
    });
    _confirmPasswordFocusNode.addListener((){
      if(mounted) {
        if (_confirmPasswordFocusNode.hasFocus) {
          setState(() {
            _confirmPasswordLabelColor = bluePurple;
          });
        } else {
          setState(() {
            _confirmPasswordLabelColor = Colors.grey;
          });
        }
      }
    });
  }



  Widget _buildCurrentPasswordTextField() {
    return TextFormField(
      validator: (String value) {
        return _currentPasswordValidationMessage;
      },
      obscureText: true,
      autocorrect: false,
      focusNode: _currentPasswordFocusNode,
      decoration: InputDecoration(
          labelStyle: TextStyle(color: _currentPasswordLabelColor),
          labelText: 'Password',
          suffixIcon: _currentPasswordFieldController.text == ''
              ? null
              : IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    FocusScope.of(context).unfocus();
                    _currentPasswordFieldController.clear();
                  });
                });
              })
      ),
      controller: _currentPasswordFieldController,
    );
  }

  Widget _buildNewPasswordTextField() {
    return TextFormField(
        validator: (String value) {
          String message;
          if (value.trim().length <= 0 && value.isEmpty) {
            message = 'Please enter a new password';
          }
          if (value.length < 8) {
            message = 'Password must be at least 8 characters long';
          }
          if(value != _confirmPasswordFieldController.text){
            message = 'New password and confirm new password fields should match';
          }
          return message;
        },
      obscureText: true,
      autocorrect: false,
      focusNode: _newPasswordFocusNode,
      decoration: InputDecoration(
          labelStyle: TextStyle(color: _newPasswordLabelColor),
          labelText: 'New Password',
          suffixIcon: _newPasswordFieldController.text == ''
              ? null
              : IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    FocusScope.of(context).unfocus();
                    _newPasswordFieldController.clear();
                  });
                });
              })
      ),
      controller: _newPasswordFieldController,
    );
  }

  Widget _buildConfirmPasswordTextField() {
    return TextFormField(
      validator: (String value) {
        String message;
        if (value.trim().length <= 0 && value.isEmpty) {
          message = 'Please enter a new password';
        }
        if (value.length < 8) {
          message = 'Password must be at least 8 characters long';
        }
        if(value != _newPasswordFieldController.text){
          message = 'New password and confirm new password fields should match';
        }
        return message;
      },
      obscureText: true,
      autocorrect: false,
      focusNode: _confirmPasswordFocusNode,
      decoration: InputDecoration(
          labelStyle: TextStyle(color: _confirmPasswordLabelColor),
          labelText: 'Confirm Password',
          suffixIcon: _confirmPasswordFieldController.text == ''
              ? null
              : IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    FocusScope.of(context).unfocus();
                    _confirmPasswordFieldController.clear();
                  });
                });
              })
      ),
      controller: _confirmPasswordFieldController,
    );
  }

  Widget _buildSubmitButton() {
    return Center(
        child: SizedBox(width: 150, child: GradientButton('Change Password', () async => _changePassword()),),
    );

  }

  Widget _buildClearDataButton() {
    return Center(
      child: SizedBox(width: 150, child: GradientButton('Clear App Data', () => _clearAppData()),),
    );
  }

  Widget _buildDeleteDatabaseButton() {
    return Center(
      child: SizedBox(width: 150, child: GradientButton('Delete Records', () => _deleteRecords()),),
    );
  }

  void _deleteRecords(){
    
    showDialog(
        context: context,
        builder: (BuildContext context) {
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
                    colors: [purpleDesign, purpleDesign]),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
              ),
              child: Center(child: Text("Delete Records", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),),
            ),
            content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Text('Are you sure you wish to delete these records?', textAlign: TextAlign.left,),
              SizedBox(height: 10.0,),
            ],),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: () {

                  setState(() {
                    okPressed = true;
                  });

                  Navigator.pop(context);

                },
                child: Text(
                  'OK',
                  style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        }).then((_) async{

      if(okPressed){

        DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
        DateTime lastYear = today.subtract(Duration(days: 365));

        GlobalFunctions.showLoadingDialog('Deleting Records...');
        if(transferReports){
          QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('transfer_reports').where(Strings.date, isLessThanOrEqualTo: lastYear).get().timeout(Duration(seconds: 60));

          if(snapshot.docs.length > 1){
            for(DocumentSnapshot snap in snapshot.docs){
              await FirebaseFirestore.instance.collection('transfer_reports').doc(snap.id).delete().timeout(Duration(seconds: 60));
              if(kIsWeb){
                try {
                  await FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + snap.id + '/collectionSignature.jpg').delete();
                } catch(e) {
                }
                try {
                  await FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + snap.id + '/incidentSignature.jpg').delete();
                } catch(e) {
                }
                try {
                  await FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + snap.id + '/destinationSignature.jpg').delete();
                } catch(e) {
                }
                try {
                  await FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + snap.id + '/patientReportSignature.jpg').delete();
                } catch(e) {
                }
                try {
                  await FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + snap.id + '/bodyMapImage.jpg').delete();
                } catch(e) {
                }

              } else {
                try {
                  await FirebaseStorage.instance.ref().child('transferReportImages/' + snap.id + '/collectionSignature.jpg').delete();
                } catch(e) {
                }
                try {
                  await FirebaseStorage.instance.ref().child('transferReportImages/' + snap.id + '/incidentSignature.jpg').delete();
                } catch(e) {
                }
                try {
                  await FirebaseStorage.instance.ref().child('transferReportImages/' + snap.id + '/destinationSignature.jpg').delete();
                } catch(e) {
                }
                try {
                  await FirebaseStorage.instance.ref().child('transferReportImages/' + snap.id + '/patientReportSignature.jpg').delete();
                } catch(e) {
                }
                try {
                  await FirebaseStorage.instance.ref().child('transferReportImages/' + snap.id + '/bodyMapImage.jpg').delete();
                } catch(e) {
                }
              }
            }
          }
        }
        if(incidentReports){
          QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('incident_reports').where(Strings.incidentDate, isLessThanOrEqualTo: lastYear).get().timeout(Duration(seconds: 60));

          if(snapshot.docs.length > 1){
            for(DocumentSnapshot snap in snapshot.docs){
              await FirebaseFirestore.instance.collection('incident_reports').doc(snap.id).delete().timeout(Duration(seconds: 60));
              if(kIsWeb){
                try {
                  await FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/incidentReportImages/' + snap.id + '/incidentSignature.jpg').delete();
                } catch(e) {
                }
              } else {
                try {
                  await FirebaseStorage.instance.ref().child('incidentReportImages/' + snap.id + '/incidentSignature.jpg').delete();
                } catch(e){
                }
              }
            }
          }
        }
        if(observationBookings){
          QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('observation_bookings').where(Strings.obJobDate, isLessThanOrEqualTo: lastYear).get().timeout(Duration(seconds: 60));

          if(snapshot.docs.length > 1){
            for(DocumentSnapshot snap in snapshot.docs){
              await FirebaseFirestore.instance.collection('observation_bookings').doc(snap.id).delete().timeout(Duration(seconds: 60));
            }
          }
        }
        if(bookingForms){
          QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('booking_forms').where(Strings.bfJobDate, isLessThanOrEqualTo: lastYear).get().timeout(Duration(seconds: 60));

          if(snapshot.docs.length > 1){
            for(DocumentSnapshot snap in snapshot.docs){
              await FirebaseFirestore.instance.collection('booking_forms').doc(snap.id).delete().timeout(Duration(seconds: 60));
            }
          }
        }
        GlobalFunctions.dismissLoadingDialog();

        setState(() {
          okPressed = false;
        });
      }});
  }


  void _clearAppData(){

    showDialog(
        context: context,
        builder: (BuildContext context) {
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
                    colors: [purpleDesign, purpleDesign]),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
              ),
              child: Center(child: Text("Clear App Data", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),),
            ),
            content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Text('Are you sure you wish to clear local app data?', textAlign: TextAlign.left,),
              SizedBox(height: 10.0,),
            ],),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: () {

                  setState(() {
                    okPressed = true;
                  });

                  Navigator.pop(context);

                },
                child: Text(
                  'OK',
                  style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        }).then((_) async{

      if(okPressed){

        GlobalFunctions.showLoadingDialog('Deleting Data...');
        await context.read<IncidentReportModel>().deleteAllRows();
        await context.read<TransferReportModel>().deleteAllRows();
        await context.read<ObservationBookingModel>().deleteAllRows();
        await context.read<BookingFormModel>().deleteAllRows();
        imageCache.clear();
        GlobalFunctions.dismissLoadingDialog();

        setState(() {
          okPressed = false;
        });
      }});
  }

  _changePassword() async {

    String _currentPassword = await _secureStorage.readSecureData('password');

    if(_currentPasswordFieldController.text.trim().length <= 0 && _currentPasswordFieldController.text.isEmpty) {

        _currentPasswordValidationMessage = 'Please enter your current password';

    } else if(_currentPasswordFieldController.text != _currentPassword) {
      _currentPasswordValidationMessage = 'Current password is incorrect';
      _currentPassword = '';
    } else {
      _currentPasswordValidationMessage = null;
    }



    if (!_formKey.currentState.validate()) {
      return;
    }

    bool success = await context.read<AuthenticationModel>().changePassword(_newPasswordFieldController.text);
    if(success) {
      setState(() {
        _currentPasswordFieldController.clear();
        _newPasswordFieldController.clear();
        _confirmPasswordFieldController.clear();
        FocusScope.of(context).requestFocus(new FocusNode());
      });
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
          child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: targetPadding / 2), child: Column(children: <Widget>[
            Form(
              key: _formKey,
              child: Column(children: <Widget>[
                Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                  GestureDetector(
                  onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (BuildContext context) {
                return ProfilePictureEdit();
              })).then((_){
                    setState(() {
                      user.profilePicture = user.profilePicture;
                    });
                  }),
            child: user.profilePicture == null ? CircleAvatar(
              radius: MediaQuery.of(context).size.width *0.15,
              backgroundColor: bluePurple,
              child: FittedBox(
                  fit: BoxFit.fitHeight,
                  child: Text(user.name[0], style: TextStyle(fontSize: 1000), textAlign: TextAlign.start,)
              ),
            ) : CircleAvatar(
              radius: MediaQuery.of(context).size.width * 0.15,
              backgroundImage: NetworkImage(user.profilePicture),
            ),),

                ],),
                SizedBox(height: 10.0,),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (BuildContext context) {
                          return ProfilePictureEdit();
                        })).then((_){
                          setState(() {
                            user.profilePicture = user.profilePicture;
                          });
                    }),
                    child: Text('Edit', style: TextStyle(color: bluePurple), textAlign: TextAlign.center,),),

                ],),
                SizedBox(height: 20.0,),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                  Text('Change Password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),),

                ],),
                SizedBox(height: 10.0,),
                Container(decoration: BoxDecoration(border: Border.all(width: 2.0)), width: MediaQuery.of(context).size.width, child: Container(padding: EdgeInsets.all(5.0),color: Colors.grey, child: Row(children: <Widget>[
                  Icon(Icons.info),
                  SizedBox(width: 5.0,),
                  Flexible(child: Text('To change your password, enter your existing password along with your new password details below. Your new password must be at least 8 characters in length.'))

                ],),)),
                _buildCurrentPasswordTextField(),
                _buildNewPasswordTextField(),
                _buildConfirmPasswordTextField(),
                SizedBox(height: 10.0,),
                _buildSubmitButton(),
                SizedBox(height: 10.0,),
                Divider(),
              ],),
            ),
            user.role == 'Super User' ? Column(children: <Widget>[
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                Text('Delete Database Records', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),),

              ],),
              SizedBox(height: 10.0,),
              Container(decoration: BoxDecoration(border: Border.all(width: 2.0)), width: MediaQuery.of(context).size.width, child: Container(padding: EdgeInsets.all(5.0),color: Colors.grey, child: Row(children: <Widget>[
                Icon(Icons.info),
                SizedBox(width: 5.0,),
                Flexible(child: Text('Choose the forms you want to delete from the database. This will delete all matching records more than 1 year old.'))

              ],),)),
              SizedBox(height: 10.0,),
              CheckboxListTile(title: Text('Transfer Report'), value: transferReports, onChanged: (val) => setState((){
                transferReports = val;
              }),),
              CheckboxListTile(title: Text('Incident Report'), value: incidentReports, onChanged: (val) => setState((){
                incidentReports = val;
              }),),
              CheckboxListTile(title: Text('Observation Booking'), value: observationBookings, onChanged: (val) => setState((){
                observationBookings = val;
              }),),
              CheckboxListTile(title: Text('Transport Booking'), value: bookingForms, onChanged: (val) => setState((){
                bookingForms = val;
              }),),
              _buildDeleteDatabaseButton(),
              SizedBox(height: 10.0,),
              Divider(),
            ],) : Container(),
            Form(
              key: _formKey3,
              child: Column(children: <Widget>[
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                  Text('Clear App Data', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),),

                ],),
                SizedBox(height: 10.0,),
                Container(decoration: BoxDecoration(border: Border.all(width: 2.0)), width: MediaQuery.of(context).size.width, child: Container(padding: EdgeInsets.all(5.0),color: Colors.grey, child: Row(children: <Widget>[
                  Icon(Icons.info),
                  SizedBox(width: 5.0,),
                  Flexible(child: Text('If you want to reduce the amount of space the app is using you can clear all of the local data on this device, all previous succesfully submitted'
                      ' forms will be available to download from the server.'))

                ],),)),
                SizedBox(height: 10.0,),
                _buildClearDataButton(),
                SizedBox(height: 10.0,),
              ],),
            ),
          ],
          ))
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(appBar: AppBar(
      iconTheme: IconThemeData(color: Colors.white),
      flexibleSpace: AppBarGradient(),
      title: FittedBox(fit:BoxFit.fitWidth,
          child: Text('Settings', style: TextStyle(fontWeight: FontWeight.bold),)),
    ),drawer: SideDrawer(), body: _buildPageContent(context),);
  }
}
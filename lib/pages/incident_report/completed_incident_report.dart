import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pegasus_medical_1808/models/incident_report_model.dart';
import 'package:pegasus_medical_1808/models/share_option.dart';
import 'package:pegasus_medical_1808/services/navigation_service.dart';
import 'package:pegasus_medical_1808/shared/global_config.dart';
import 'package:pegasus_medical_1808/shared/global_functions.dart';
import 'package:pegasus_medical_1808/shared/strings.dart';
import 'package:pegasus_medical_1808/widgets/app_bar_gradient.dart';
import 'package:provider/provider.dart';

import '../../locator.dart';
import 'incident_report.dart';
import '../../constants/route_paths.dart' as routes;



class CompletedIncidentReport extends StatefulWidget {

  @override
  _CompletedIncidentReportState createState() => _CompletedIncidentReportState();
}

class _CompletedIncidentReportState extends State<CompletedIncidentReport> {

  bool _loadingTemporary = false;
  IncidentReportModel incidentReportModel;
  Uint8List incidentImageBytes;
  Uint8List destinationImageBytes;
  bool okPressed = false;

  @override
  void initState() {
    // TODO: implement initState
    _loadingTemporary = true;
    incidentReportModel = Provider.of<IncidentReportModel>(context, listen: false);
    _getTemporaryIncidentReport();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
              child: Center(child: Text("Delete Record", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),),
            ),
            content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Text('Are you sure you wish to delete this record?', textAlign: TextAlign.left,),
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

        GlobalFunctions.showLoadingDialog('Deleting Record...');
        await FirebaseFirestore.instance.collection('incident_reports').doc(incidentReportModel.selectedIncidentReport[Strings.documentId]).delete().timeout(Duration(seconds: 60));
        if(kIsWeb){
          try {
            await FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/incidentReportImages/' + incidentReportModel.selectedIncidentReport[Strings.documentId] + '/incidentSignature.jpg').delete();
          } catch(e){
            print(e);
          }
        } else {
          try {
            await FirebaseStorage.instance.ref().child('incidentReportImages/' + incidentReportModel.selectedIncidentReport[Strings.documentId] + '/incidentSignature.jpg').delete();
          } catch(e) {
          }
        }
        GlobalFunctions.dismissLoadingDialog();

        setState(() {
          okPressed = false;
        });
        incidentReportModel.clearIncidentReports();
        final NavigationService _navigationService = locator<NavigationService>();
        _navigationService.navigateToReplacement(routes.IncidentReportListPageRoute);
      }});
  }

  _getTemporaryIncidentReport() async {
    if (mounted) {
      if (incidentReportModel.selectedIncidentReport[Strings.incidentSignature] != null) {
        incidentImageBytes = await GlobalFunctions.decryptSignature(incidentReportModel.selectedIncidentReport[Strings.incidentSignature]);
      }
      if (mounted) {
        setState(() {
          _loadingTemporary = false;
        });
      }

    }
  }

  Widget _buildIncidentSignatureRow() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 10.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              "Signature",
              textAlign: TextAlign.left,
            ),
          ],
        ),
        SizedBox(
          height: 10.0,
        ),
        Container(
          child: Center(
            child: incidentReportModel.selectedIncidentReport[Strings.incidentSignature] == null
                ? Text('No signature found')
                : Image.memory(incidentImageBytes),

          ),
        )
      ],
    );
  }

  Widget _textFormField(String label, String value) {
    return InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: SelectableText(value, style: TextStyle(fontSize: 16),),
    );
  }

  Widget _buildDateField(String label, String value) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Flexible(
              child: IgnorePointer(
                child: InputDecorator(
                  decoration: InputDecoration(labelText: label),
                  child: Text(value, style: TextStyle(fontSize: 16),),
                ),
              ),
            ),
            IconButton(
                icon: Icon(Icons.access_time),
                onPressed: null)
          ],
        ),
      ],
    );
  }

  Widget _buildTimeField(String label, String value) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Flexible(
              child: IgnorePointer(
                child: InputDecorator(
                  decoration: InputDecoration(labelText: label),
                  child: Text(value, style: TextStyle(fontSize: 16),),
                ),
              ),
            ),
            IconButton(
                icon: Icon(Icons.access_time),
                onPressed: null)
          ],
        ),
      ],
    );
  }

  _generatePdf(BuildContext context) async {
    showDialog(barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return EmailDialog(incidentReportModel);
        });
  }

  Widget _buildShareButton(BuildContext context) {
    String email = 'Email Report';
    String print = 'Print';
    String share = 'Share';
    String edit = 'Edit';
    String delete = 'Delete';
    String download = 'Download';

    List<String> _shareOptions = [];

    if(user.role == 'Super User'){
      if(kIsWeb){
        _shareOptions = [edit, download, print, delete];
      } else {
        _shareOptions = [edit, email, print, share, delete];
      }
    } else if(user.role == 'Enhanced User') {
      if(kIsWeb){
        _shareOptions = [edit, download, print];
      } else {
        _shareOptions = [edit, email, print, share];
      }
    } else {
      if(kIsWeb){
        _shareOptions = [edit, download, print];
      } else {
        _shareOptions = [edit, print, share];
      }
    }

    return PopupMenuButton(
        onSelected: (String value) async{

          ConnectivityResult connectivityResult = await Connectivity().checkConnectivity();

          if (value == email) {
            _generatePdf(context);
          } else if (value == print) {

            if (connectivityResult == ConnectivityResult.none) {
              GlobalFunctions.showToast(
                  'No data connection unable to search for Printer');
            } else {

              await incidentReportModel.sharePdf(ShareOption.Print);

            }
          } if (value == share) {

            if (connectivityResult == ConnectivityResult.none) {
              GlobalFunctions.showToast(
                  'No data connection unable to share form');
            } else {

              await incidentReportModel.sharePdf(ShareOption.Share);

            }

          } if (value == download) {

            if (connectivityResult == ConnectivityResult.none) {
              GlobalFunctions.showToast(
                  'No data connection unable to download form');
            } else {

              await incidentReportModel.sharePdf(ShareOption.Download);

            }

          } else if(value == edit){

            //Sembast
            await context.read<IncidentReportModel>().setUpEditedRecord();

            //Sqlflite
            //await context.read<IncidentReportModel>().setUpEditedIncidentReport();

            Navigator.of(context).push(
                MaterialPageRoute(builder: (BuildContext context) {
                  return IncidentReport(false, '1', false, true);
                })).then((_) {

                  //Sembast
                  context.read<IncidentReportModel>().deleteEditedRecord();

                  //Sqlflite
                  //context.read<IncidentReportModel>().deleteEditedIncidentReport();
            });
          } else if(value == delete){
            _deleteRecords();
          }
        },
        icon: Icon(Icons.more_vert),
        itemBuilder: (BuildContext context) {
          return _shareOptions.map((String option) {

            return PopupMenuItem<String>(value: option, child: Row(children: <Widget>[

              Expanded(child: Text(option),),
              Icon(GlobalFunctions.buildShareIconForms(option), color: bluePurple,),
            ],));

          }).toList();
        });
  }




  Widget _buildPageContent(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 768.0 ? 600.0 : deviceWidth * 0.95;
    final double targetPadding = deviceWidth - targetWidth;

    return incidentReportModel.selectedIncidentReport == null ? Container() : GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        margin: EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: targetPadding / 2),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('INCIDENT REPORT', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),),
                ],),
                SizedBox(height: 20,),
                _textFormField('Job Ref', GlobalFunctions.databaseValueString(incidentReportModel.selectedIncidentReport[Strings.jobRef])),
                _buildDateField('Date', GlobalFunctions.databaseValueDate(incidentReportModel.selectedIncidentReport[Strings.incidentDate], false)),
                _buildTimeField('Time', GlobalFunctions.databaseValueTime(incidentReportModel.selectedIncidentReport[Strings.incidentTime])),
                _textFormField('Incident Details', GlobalFunctions.decryptString(incidentReportModel.selectedIncidentReport[Strings.incidentDetails])),
                _textFormField('Location', GlobalFunctions.decryptString(incidentReportModel.selectedIncidentReport[Strings.incidentLocation])),
                _textFormField('What action did you take?', GlobalFunctions.decryptString(incidentReportModel.selectedIncidentReport[Strings.incidentAction])),
                _textFormField('Staff involved', GlobalFunctions.decryptString(incidentReportModel.selectedIncidentReport[Strings.incidentStaffInvolved])),
                _buildIncidentSignatureRow(),
                SizedBox(height: 20,),
                _buildDateField('Date', GlobalFunctions.databaseValueDate(incidentReportModel.selectedIncidentReport[Strings.incidentSignatureDate], false)),
                _textFormField('Print Name', GlobalFunctions.decryptString(incidentReportModel.selectedIncidentReport[Strings.incidentPrintName])),
                SizedBox(height: 20,),
              ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(backgroundColor: greyDesign1,
        iconTheme: IconThemeData(color: Colors.white),
        flexibleSpace: AppBarGradient(),
        title: FittedBox(fit:BoxFit.fitWidth,
            child: Text('Incident Report', style: TextStyle(fontWeight: FontWeight.bold),)),
        actions: <Widget>[
          _buildShareButton(context)
        ],
      ),
      body: _loadingTemporary
          ? Center(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(bluePurple),
        ),
      )
          : _buildPageContent(context),
    );
  }
}


class EmailDialog extends StatefulWidget {

  final incidentReportModel;

  EmailDialog(this.incidentReportModel);

  @override
  _EmailDialogState createState() => new _EmailDialogState();
}

class _EmailDialogState extends State<EmailDialog> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();



  final TextEditingController _emailTextController = new TextEditingController();

  @override
  void initState() {

    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _emailTextController.dispose();
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
              colors: [purpleDesign, purpleDesign]),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
        ),
        child: Center(child: Text("Enter email addresses", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),),
      ),
      content: Form(
          key: _formKey,
          child: SingleChildScrollView(child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(width: 350, child: Text(
                  'Use the textbox below to add the email addresses of anyone you want to receive this Form, use a comma to separate the emails'),),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Flexible(
                      child: TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            labelText: 'Emails'),
                        controller: _emailTextController,
                        validator: (String value) {
                          String returnValue;
                          if (value.trim().length <= 0 && value.isEmpty) {
                            returnValue = 'Please enter an email';
                          }
                          return returnValue;
                        },
                      )),
                ],
              ),
            ],
          ),)),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(color: bluePurple),
          ),
        ),
        TextButton(
          onPressed: () async {

            if(_formKey.currentState.validate()){
              FocusScope.of(context).requestFocus(new FocusNode());

              List<String> emailList = _emailTextController.text.split(',');
              print(emailList);

              List<String> emailListTrimmed = [];

              if(emailList.length > 0){

                emailList.forEach((String email){

                  if(email != null && email != '' && RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                      .hasMatch(email)) emailListTrimmed.add(email.trim());
                });

              }


              ConnectivityResult connectivityResult =
              await Connectivity().checkConnectivity();

              if (connectivityResult == ConnectivityResult.none) {
                GlobalFunctions.showToast(
                    'No data connection to email PDF');
              } else {

                GlobalFunctions.showLoadingDialog('Sending Email');

                bool success = await widget.incidentReportModel.sharePdf(ShareOption.Email, emailListTrimmed);

                GlobalFunctions.dismissLoadingDialog();

                if(success == true){
                  Navigator.of(context).pop();
                  GlobalFunctions.showToast(
                      'email successfully sent');
                } else {
                  GlobalFunctions.showToast(
                      'unable email PDF');
                }



              }

            }

          },
          child: Text(
            'OK',
            style: TextStyle(color: bluePurple),
          ),
        ),
      ],
    );
  }
}

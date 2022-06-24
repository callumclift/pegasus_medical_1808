import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pegasus_medical_1808/models/share_option.dart';
import 'package:pegasus_medical_1808/models/transfer_report_model.dart';
import 'package:pegasus_medical_1808/services/navigation_service.dart';
import 'package:pegasus_medical_1808/shared/strings.dart';
import 'package:pegasus_medical_1808/widgets/app_bar_gradient.dart';
import 'package:provider/provider.dart';
import '../../locator.dart';
import 'completed_transfer_report_section1.dart';
import 'completed_transfer_report_section2.dart';
import 'completed_transfer_report_section3.dart';
import 'completed_transfer_report_section4.dart';
import 'completed_transfer_report_section5.dart';
import 'transfer_report_overall.dart';
import '../../widgets/side_drawer.dart';
import '../../shared/global_config.dart';
import '../../shared/global_functions.dart';
import 'package:provider/provider.dart';
import '../../constants/route_paths.dart' as routes;


class CompletedTransferReportOverall extends StatefulWidget {

  CompletedTransferReportOverall();

  @override
  _CompletedTransferReportOverallState createState() => _CompletedTransferReportOverallState();
}

class _CompletedTransferReportOverallState extends State<CompletedTransferReportOverall> with SingleTickerProviderStateMixin {

  TabController tabController;
  TransferReportModel transferReportModel;
  bool okPressed = false;



  @override
  void initState(){
    tabController = TabController(length: 5, vsync: this);
    transferReportModel = Provider.of<TransferReportModel>(context, listen: false);
    tabController.addListener(() {
      FocusScope.of(context).requestFocus(new FocusNode()); //remove focus
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    tabController.dispose();
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
        await FirebaseFirestore.instance.collection('transfer_reports').doc(transferReportModel.selectedTransferReport[Strings.documentId]).delete().timeout(Duration(seconds: 60));
        if(kIsWeb){
          try {
            await FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + transferReportModel.selectedTransferReport[Strings.documentId] + '/collectionSignature.jpg').delete();
          } catch(e) {
          }
          try {
            await FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + transferReportModel.selectedTransferReport[Strings.documentId] + '/incidentSignature.jpg').delete();
          } catch(e) {
          }
          try {
            await FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + transferReportModel.selectedTransferReport[Strings.documentId] + '/destinationSignature.jpg').delete();
          } catch(e) {
          }
          try {
            await FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + transferReportModel.selectedTransferReport[Strings.documentId] + '/patientReportSignature.jpg').delete();
          } catch(e) {
          }
          try {
            await FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/transferReportImages/' + transferReportModel.selectedTransferReport[Strings.documentId] + '/bodyMapImage.jpg').delete();
          } catch(e) {
          }

        } else {
          try {
            await FirebaseStorage.instance.ref().child('transferReportImages/' + transferReportModel.selectedTransferReport[Strings.documentId] + '/collectionSignature.jpg').delete();
          } catch(e) {
          }
          try {
            await FirebaseStorage.instance.ref().child('transferReportImages/' + transferReportModel.selectedTransferReport[Strings.documentId] + '/incidentSignature.jpg').delete();
          } catch(e) {
          }
          try {
            await FirebaseStorage.instance.ref().child('transferReportImages/' + transferReportModel.selectedTransferReport[Strings.documentId] + '/destinationSignature.jpg').delete();
          } catch(e) {
          }
          try {
            await FirebaseStorage.instance.ref().child('transferReportImages/' + transferReportModel.selectedTransferReport[Strings.documentId] + '/patientReportSignature.jpg').delete();
          } catch(e) {
          }
          try {
            await FirebaseStorage.instance.ref().child('transferReportImages/' + transferReportModel.selectedTransferReport[Strings.documentId] + '/bodyMapImage.jpg').delete();
          } catch(e) {
          }
        }
        GlobalFunctions.dismissLoadingDialog();

        setState(() {
          okPressed = false;
        });
        transferReportModel.clearTransferReports();
        final NavigationService _navigationService = locator<NavigationService>();
        _navigationService.navigateToReplacement(routes.TransferReportListPageRoute);
      }});
  }

  @override
  Widget build(BuildContext context) {



    _generatePdf(BuildContext context) async {
      showDialog(barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return EmailDialog(transferReportModel);
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

                await transferReportModel.sharePdf(ShareOption.Print);

              }
            } if (value == share) {

              if (connectivityResult == ConnectivityResult.none) {
                GlobalFunctions.showToast(
                    'No data connection unable to share form');
              } else {

                await transferReportModel.sharePdf(ShareOption.Share);

              }

            } if (value == download) {

              if (connectivityResult == ConnectivityResult.none) {
                GlobalFunctions.showToast(
                    'No data connection unable to download form');
              } else {

                await transferReportModel.sharePdf(ShareOption.Download);

              }

            } else if(value == edit){
              //Sembast
              await context.read<TransferReportModel>().setUpEditedRecord();

              //Sqlflite
              //await context.read<TransferReportModel>().setUpEditedTransferReport();

              Navigator.of(context).push(
                  MaterialPageRoute(builder: (BuildContext context) {
                    return TransferReportOverall(0, false, '1', false, true);
                  })).then((_) {

                //Sembast
                //context.read<TransferReportModel>().deleteEditedRecord();

                //Sqlflite
                //context.read<TransferReportModel>().deleteEditedTransferReport();
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















    void _resetTransferReport() {
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
                child: Center(child: Text("Reset Transfer Report", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),),
              ),
              content: Text('Are you sure you wish to reset this form?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'No',
                    style: TextStyle(color: blueDesign, fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Yes',
                    style: TextStyle(color: blueDesign, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          });
    }

    // TODO: implement build
    return Scaffold(
      appBar: AppBar(backgroundColor: greyDesign1,
        iconTheme: IconThemeData(color: Colors.white),
        flexibleSpace: AppBarGradient(),
        title: FittedBox(fit:BoxFit.fitWidth,
            child: Text('Transfer Report', style: TextStyle(fontWeight: FontWeight.bold),)),
        bottom: TabBar(
          controller: tabController,
          isScrollable: true, indicatorColor: Colors.white,
          tabs: <Widget>[
            Tab(
              text: 'Job Details',
            ),
            Tab(
              text: 'Patient Details',
            ),
            Tab(
              text: 'Section Checklist',
            ),
            Tab(
              text: 'Feedback',
            ),
            Tab(
              text: 'Vehicle Checklist',
            ),
          ],
        ),actions: <Widget>[
          _buildShareButton(context)
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
        child: kIsWeb ? TabBarView(
          physics: NeverScrollableScrollPhysics(),
          controller: tabController,
          children: <Widget>[
            CompletedTransferReportSection1(),
            CompletedTransferReportSection2(),
            CompletedTransferReportSection3(),
            CompletedTransferReportSection4(),
            CompletedTransferReportSection5(),
          ],
        ) : TabBarView(
          controller: tabController,
          children: <Widget>[
            CompletedTransferReportSection1(),
            CompletedTransferReportSection2(),
            CompletedTransferReportSection3(),
            CompletedTransferReportSection4(),
            CompletedTransferReportSection5(),
          ],
        ),
      ),
    );
  }
}

class EmailDialog extends StatefulWidget {

  final transferReportModel;

  EmailDialog(this.transferReportModel);

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

                bool success = await widget.transferReportModel.sharePdf(ShareOption.Email, emailListTrimmed);

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

import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pegasus_medical_1808/models/spot_checks_model.dart';
import 'package:pegasus_medical_1808/models/share_option.dart';
import 'package:pegasus_medical_1808/services/navigation_service.dart';
import 'package:pegasus_medical_1808/shared/global_config.dart';
import 'package:pegasus_medical_1808/shared/global_functions.dart';
import 'package:pegasus_medical_1808/shared/strings.dart';
import 'package:pegasus_medical_1808/widgets/app_bar_gradient.dart';
import 'package:provider/provider.dart';

import '../../locator.dart';
import 'spot_checks.dart';
import '../../constants/route_paths.dart' as routes;



class CompletedSpotChecks extends StatefulWidget {

  @override
  _CompletedSpotChecksState createState() => _CompletedSpotChecksState();
}

class _CompletedSpotChecksState extends State<CompletedSpotChecks> {

  bool _loadingTemporary = false;
  SpotChecksModel spotChecksModel;
  bool okPressed = false;
  Uint8List scImageBytes;


  @override
  void initState() {
    // TODO: implement initState
    _loadingTemporary = true;
    spotChecksModel = Provider.of<SpotChecksModel>(context, listen: false);
    _getTemporarySpotChecks();
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
        await FirebaseFirestore.instance.collection('spot_checks').doc(spotChecksModel.selectedSpotChecks[Strings.documentId]).delete().timeout(Duration(seconds: 60));
        GlobalFunctions.dismissLoadingDialog();

        setState(() {
          okPressed = false;
        });
        spotChecksModel.clearSpotChecks();
        final NavigationService _navigationService = locator<NavigationService>();
        _navigationService.navigateToReplacement(routes.SpotChecksListPageRoute);
      }});
  }

  _getTemporarySpotChecks() async {
    if (mounted) {
      if (spotChecksModel.selectedSpotChecks[Strings.scSignature] != null) {
        scImageBytes = await GlobalFunctions.decryptSignature(spotChecksModel.selectedSpotChecks[Strings.scSignature]);
      }
      if (mounted) {
        setState(() {
          _loadingTemporary = false;
        });
      }

    }
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


  Widget _scOnTimeRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Did staff arrive to base on time?', style: TextStyle(color: Colors.grey, fontSize: 12),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: spotChecksModel.selectedSpotChecks[Strings.scOnTimeYes] == null || spotChecksModel.selectedSpotChecks[Strings.scOnTimeYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: spotChecksModel.selectedSpotChecks[Strings.scOnTimeNo] == null || spotChecksModel.selectedSpotChecks[Strings.scOnTimeNo] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }

  Widget _scCorrectUniformRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Were staff in correct uniform?', style: TextStyle(color: Colors.grey, fontSize: 12),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: spotChecksModel.selectedSpotChecks[Strings.scCorrectUniformYes] == null || spotChecksModel.selectedSpotChecks[Strings.scCorrectUniformYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: spotChecksModel.selectedSpotChecks[Strings.scCorrectUniformNo] == null || spotChecksModel.selectedSpotChecks[Strings.scCorrectUniformNo] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }

  Widget _scPegasusBadgeRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Were all staff wearing Pegasus ID badge?', style: TextStyle(color: Colors.grey, fontSize: 12),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: spotChecksModel.selectedSpotChecks[Strings.scPegasusBadgeYes] == null || spotChecksModel.selectedSpotChecks[Strings.scPegasusBadgeYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: spotChecksModel.selectedSpotChecks[Strings.scPegasusBadgeNo] == null || spotChecksModel.selectedSpotChecks[Strings.scPegasusBadgeNo] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }

  Widget _scVehicleChecksRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Were pre vehicle checks completed prior to leaving base?', style: TextStyle(color: Colors.grey, fontSize: 12),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: spotChecksModel.selectedSpotChecks[Strings.scVehicleChecksYes] == null || spotChecksModel.selectedSpotChecks[Strings.scVehicleChecksYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: spotChecksModel.selectedSpotChecks[Strings.scVehicleChecksNo] == null || spotChecksModel.selectedSpotChecks[Strings.scVehicleChecksNo] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }

  Widget _scCollectionStaffIntroduceRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('On arrival to collection unit did all staff introduce themselves?', style: TextStyle(color: Colors.grey, fontSize: 12),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: spotChecksModel.selectedSpotChecks[Strings.scCollectionStaffIntroduceYes] == null || spotChecksModel.selectedSpotChecks[Strings.scCollectionStaffIntroduceYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: spotChecksModel.selectedSpotChecks[Strings.scCollectionStaffIntroduceNo] == null || spotChecksModel.selectedSpotChecks[Strings.scCollectionStaffIntroduceNo] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }

  Widget _scCollectionTransferReportRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Was the transfer report completed fully and a detailed handover of the patient received?', style: TextStyle(color: Colors.grey, fontSize: 12),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: spotChecksModel.selectedSpotChecks[Strings.scCollectionTransferReportYes] == null || spotChecksModel.selectedSpotChecks[Strings.scCollectionTransferReportYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: spotChecksModel.selectedSpotChecks[Strings.scCollectionTransferReportNo] == null || spotChecksModel.selectedSpotChecks[Strings.scCollectionTransferReportNo] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }

  Widget _scStaffEngageRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('During the journey did staff engage with patient appropriately treating them with dignity and respect?', style: TextStyle(color: Colors.grey, fontSize: 12),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: spotChecksModel.selectedSpotChecks[Strings.scStaffEngageYes] == null || spotChecksModel.selectedSpotChecks[Strings.scStaffEngageYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: spotChecksModel.selectedSpotChecks[Strings.scStaffEngageNo] == null || spotChecksModel.selectedSpotChecks[Strings.scStaffEngageNo] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }

  Widget _scArrivalStaffIntroduceRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('On arrival to destination unit did staff introduce themselves?', style: TextStyle(color: Colors.grey, fontSize: 12),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: spotChecksModel.selectedSpotChecks[Strings.scArrivalStaffIntroduceYes] == null || spotChecksModel.selectedSpotChecks[Strings.scArrivalStaffIntroduceYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: spotChecksModel.selectedSpotChecks[Strings.scArrivalStaffIntroduceNo] == null || spotChecksModel.selectedSpotChecks[Strings.scArrivalStaffIntroduceNo] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }

  Widget _scArrivalTransferReportRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Was the transfer report completed fully and a detailed handover of the patient given?', style: TextStyle(color: Colors.grey, fontSize: 12),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: spotChecksModel.selectedSpotChecks[Strings.scArrivalTransferReportYes] == null || spotChecksModel.selectedSpotChecks[Strings.scArrivalTransferReportYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: spotChecksModel.selectedSpotChecks[Strings.scArrivalTransferReportNo] == null || spotChecksModel.selectedSpotChecks[Strings.scArrivalTransferReportNo] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }

  Widget _scPhysicalInterventionRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('If physical intervention was used was this used utilised for the least amount of time possible in keeping with least restrictive principle?', style: TextStyle(color: Colors.grey, fontSize: 12),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: spotChecksModel.selectedSpotChecks[Strings.scPhysicalInterventionYes] == null || spotChecksModel.selectedSpotChecks[Strings.scPhysicalInterventionYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: spotChecksModel.selectedSpotChecks[Strings.scPhysicalInterventionNo] == null || spotChecksModel.selectedSpotChecks[Strings.scPhysicalInterventionNo] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }

  Widget _scInfectionControl1Row() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Did staff carry out infection control procedures during transfer i.e. handwashing?', style: TextStyle(color: Colors.grey, fontSize: 12),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: spotChecksModel.selectedSpotChecks[Strings.scInfectionControl1Yes] == null || spotChecksModel.selectedSpotChecks[Strings.scInfectionControl1Yes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: spotChecksModel.selectedSpotChecks[Strings.scInfectionControl1No] == null || spotChecksModel.selectedSpotChecks[Strings.scInfectionControl1No] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }

  Widget _scInfectionControl2Row() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Following transfer did staff use infection control procedures to clean vehicle, i.e. touch point, seat?', style: TextStyle(color: Colors.grey, fontSize: 12),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: spotChecksModel.selectedSpotChecks[Strings.scInfectionControl2Yes] == null || spotChecksModel.selectedSpotChecks[Strings.scInfectionControl2Yes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: spotChecksModel.selectedSpotChecks[Strings.scInfectionControl2No] == null || spotChecksModel.selectedSpotChecks[Strings.scInfectionControl2No] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }

  Widget _scVehicleTidyRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Was the vehicle left clean and tidy?', style: TextStyle(color: Colors.grey, fontSize: 12),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: spotChecksModel.selectedSpotChecks[Strings.scVehicleTidyYes] == null || spotChecksModel.selectedSpotChecks[Strings.scVehicleTidyYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: spotChecksModel.selectedSpotChecks[Strings.scVehicleTidyNo] == null || spotChecksModel.selectedSpotChecks[Strings.scVehicleTidyNo] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }

  Widget _scCompletedTransferReportRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Was the transfer report fully completed at the end of the journey?', style: TextStyle(color: Colors.grey, fontSize: 12),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: spotChecksModel.selectedSpotChecks[Strings.scCompletedTransferReportYes] == null || spotChecksModel.selectedSpotChecks[Strings.scCompletedTransferReportYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: spotChecksModel.selectedSpotChecks[Strings.scCompletedTransferReportNo] == null || spotChecksModel.selectedSpotChecks[Strings.scCompletedTransferReportNo] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }

  Widget _buildScSignatureRow() {
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
            child: spotChecksModel.selectedSpotChecks[Strings.scSignature] == null
                ? Text('No signature found')
                : Image.memory(scImageBytes),

          ),
        )
      ],
    );
  }





  _generatePdf(BuildContext context) async {
    showDialog(barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return EmailDialog(spotChecksModel);
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

              await spotChecksModel.sharePdf(ShareOption.Print);

            }
          } if (value == share) {

            if (connectivityResult == ConnectivityResult.none) {
              GlobalFunctions.showToast(
                  'No data connection unable to share form');
            } else {

              await spotChecksModel.sharePdf(ShareOption.Share);

            }

          } if (value == download) {

            if (connectivityResult == ConnectivityResult.none) {
              GlobalFunctions.showToast(
                  'No data connection unable to download form');
            } else {

              await spotChecksModel.sharePdf(ShareOption.Download);

            }

          } else if(value == edit){

            //Sembast
            await context.read<SpotChecksModel>().setUpEditedRecord();

            //Sqlflite
            //await context.read<SpotChecksModel>().setUpEditedSpotChecks();

            Navigator.of(context).push(
                MaterialPageRoute(builder: (BuildContext context) {
                  return SpotChecks(false, '1', false, true);
                })).then((_) {

              //Sembast
              context.read<SpotChecksModel>().deleteEditedRecord();

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

    return spotChecksModel.selectedSpotChecks == null ? Container() : GestureDetector(
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
                _textFormField('Reference', GlobalFunctions.databaseValueString(spotChecksModel.selectedSpotChecks[Strings.jobRef])),
                SizedBox(height: 10,),
                Text('Staff on Duty', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 18),),
                _textFormField('Name', GlobalFunctions.decryptString(spotChecksModel.selectedSpotChecks[Strings.scStaff1])),
                spotChecksModel.selectedSpotChecks[Strings.scStaff2] != null && spotChecksModel.selectedSpotChecks[Strings.scStaff2] != '' ?
                _textFormField('Name', GlobalFunctions.decryptString(spotChecksModel.selectedSpotChecks[Strings.scStaff2])) : Container(),
                spotChecksModel.selectedSpotChecks[Strings.scStaff3] != null && spotChecksModel.selectedSpotChecks[Strings.scStaff3] != '' ?
                _textFormField('Name', GlobalFunctions.decryptString(spotChecksModel.selectedSpotChecks[Strings.scStaff3])) : Container(),
                spotChecksModel.selectedSpotChecks[Strings.scStaff4] != null && spotChecksModel.selectedSpotChecks[Strings.scStaff4] != '' ?
                _textFormField('Name', GlobalFunctions.decryptString(spotChecksModel.selectedSpotChecks[Strings.scStaff4])) : Container(),
                spotChecksModel.selectedSpotChecks[Strings.scStaff5] != null && spotChecksModel.selectedSpotChecks[Strings.scStaff5] != '' ?
                _textFormField('Name', GlobalFunctions.decryptString(spotChecksModel.selectedSpotChecks[Strings.scStaff5])) : Container(),
                spotChecksModel.selectedSpotChecks[Strings.scStaff6] != null && spotChecksModel.selectedSpotChecks[Strings.scStaff6] != '' ?
                _textFormField('Name', GlobalFunctions.decryptString(spotChecksModel.selectedSpotChecks[Strings.scStaff6])) : Container(),
                spotChecksModel.selectedSpotChecks[Strings.scStaff7] != null && spotChecksModel.selectedSpotChecks[Strings.scStaff7] != '' ?
                _textFormField('Name', GlobalFunctions.decryptString(spotChecksModel.selectedSpotChecks[Strings.scStaff7])) : Container(),
                spotChecksModel.selectedSpotChecks[Strings.scStaff8] != null && spotChecksModel.selectedSpotChecks[Strings.scStaff8] != '' ?
                _textFormField('Name', GlobalFunctions.decryptString(spotChecksModel.selectedSpotChecks[Strings.scStaff8])) : Container(),
                spotChecksModel.selectedSpotChecks[Strings.scStaff9] != null && spotChecksModel.selectedSpotChecks[Strings.scStaff9] != '' ?
                _textFormField('Name', GlobalFunctions.decryptString(spotChecksModel.selectedSpotChecks[Strings.scStaff9])) : Container(),
                spotChecksModel.selectedSpotChecks[Strings.scStaff10] != null && spotChecksModel.selectedSpotChecks[Strings.scStaff10] != '' ?
                _textFormField('Name', GlobalFunctions.decryptString(spotChecksModel.selectedSpotChecks[Strings.scStaff10])) : Container(),
                SizedBox(height: 10,),
                _scOnTimeRow(),
                SizedBox(height: 10,),
                _scCorrectUniformRow(),
                SizedBox(height: 10,),
                _scPegasusBadgeRow(),
                SizedBox(height: 10,),
                _scVehicleChecksRow(),
                SizedBox(height: 10,),
                _scCollectionStaffIntroduceRow(),
                SizedBox(height: 10,),
                _scCollectionTransferReportRow(),
                SizedBox(height: 10,),
                _scStaffEngageRow(),
                SizedBox(height: 10,),
                _scArrivalStaffIntroduceRow(),
                SizedBox(height: 10,),
                _scArrivalTransferReportRow(),
                SizedBox(height: 10,),
                _scPhysicalInterventionRow(),
                SizedBox(height: 10,),
                _scInfectionControl1Row(),
                SizedBox(height: 10,),
                _scInfectionControl2Row(),
                SizedBox(height: 10,),
                _scVehicleTidyRow(),
                SizedBox(height: 10,),
                _scCompletedTransferReportRow(),
                SizedBox(height: 10,),
                _textFormField('Issues Identified', GlobalFunctions.decryptString(spotChecksModel.selectedSpotChecks[Strings.scIssuesIdentified])),
                _textFormField('Action Taken', GlobalFunctions.decryptString(spotChecksModel.selectedSpotChecks[Strings.scActionTaken])),
                _textFormField('Areas of good practice', GlobalFunctions.decryptString(spotChecksModel.selectedSpotChecks[Strings.scGoodPractice])),
                _textFormField('Name', GlobalFunctions.decryptString(spotChecksModel.selectedSpotChecks[Strings.scName])),
                _buildScSignatureRow(),
                SizedBox(height: 20,),
                _buildDateField('Date', GlobalFunctions.databaseValueDate(spotChecksModel.selectedSpotChecks[Strings.scDate], false)),


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
            child: Text('Spot Checks', style: TextStyle(fontWeight: FontWeight.bold),)),
        actions: <Widget>[
          _buildShareButton(context)
        ],
      ),
      body: _loadingTemporary
          ? Center(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(bluePurple),
        ),
      ) : _buildPageContent(context),
    );
  }
}


class EmailDialog extends StatefulWidget {

  final spotChecksModel;

  EmailDialog(this.spotChecksModel);

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

                bool success = await widget.spotChecksModel.sharePdf(ShareOption.Email, emailListTrimmed);

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

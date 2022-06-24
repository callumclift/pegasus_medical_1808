import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:pegasus_medical_1808/models/job_refs_model.dart';
import 'package:pegasus_medical_1808/models/observation_booking_model.dart';
import 'package:pegasus_medical_1808/models/spot_checks_model.dart';
import 'package:pegasus_medical_1808/shared/global_config.dart';
import 'package:pegasus_medical_1808/shared/global_functions.dart';
import 'package:pegasus_medical_1808/shared/strings.dart';
import 'package:pegasus_medical_1808/utils/database_helper.dart';
import 'package:pegasus_medical_1808/widgets/app_bar_gradient.dart';
import 'package:pegasus_medical_1808/widgets/dropdown_form_field.dart';
import 'package:pegasus_medical_1808/widgets/gradient_button.dart';
import 'package:pegasus_medical_1808/widgets/side_drawer.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:signature/signature.dart';


class SpotChecks extends StatefulWidget {
  final bool fromJob;
  final String jobId;
  final bool fillDetails;
  final bool edit;

  SpotChecks(
      [this.fromJob = false,
        this.jobId = '1',
        this.fillDetails = false,
        this.edit = false]);

  @override
  _SpotChecksState createState() => _SpotChecksState();
}

class _SpotChecksState extends State<SpotChecks> {

  bool _loadingTemporary = false;
  //DatabaseHelper _databaseHelper = DatabaseHelper();
  SpotChecksModel spotChecksModel;
  JobRefsModel jobRefsModel;
  final dateFormat = DateFormat("dd/MM/yyyy");
  final dateTimeFormat = DateFormat("dd/MM/yyyy HH:mm");
  final timeFormat = DateFormat("HH:mm");
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController jobRef = TextEditingController();
  final TextEditingController scStaff1 = TextEditingController();
  final TextEditingController scStaff2 = TextEditingController();
  final TextEditingController scStaff3 = TextEditingController();
  final TextEditingController scStaff4 = TextEditingController();
  final TextEditingController scStaff5 = TextEditingController();
  final TextEditingController scStaff6 = TextEditingController();
  final TextEditingController scStaff7 = TextEditingController();
  final TextEditingController scStaff8 = TextEditingController();
  final TextEditingController scStaff9 = TextEditingController();
  final TextEditingController scStaff10 = TextEditingController();
  bool scOnTimeYes = false;
  bool scOnTimeNo = false;
  bool scCorrectUniformYes = false;
  bool scCorrectUniformNo = false;
  bool scPegasusBadgeYes = false;
  bool scPegasusBadgeNo = false;
  bool scVehicleChecksYes = false;
  bool scVehicleChecksNo = false;
  bool scCollectionStaffIntroduceYes = false;
  bool scCollectionStaffIntroduceNo = false;
  bool scCollectionTransferReportYes = false;
  bool scCollectionTransferReportNo = false;
  bool scStaffEngageYes = false;
  bool scStaffEngageNo = false;
  bool scArrivalStaffIntroduceYes = false;
  bool scArrivalStaffIntroduceNo = false;
  bool scArrivalTransferReportYes = false;
  bool scArrivalTransferReportNo = false;
  bool scPhysicalInterventionYes = false;
  bool scPhysicalInterventionNo = false;
  bool scInfectionControl1Yes = false;
  bool scInfectionControl1No = false;
  bool scInfectionControl2Yes = false;
  bool scInfectionControl2No = false;
  bool scVehicleTidyYes = false;
  bool scVehicleTidyNo = false;
  bool scCompletedTransferReportYes = false;
  bool scCompletedTransferReportNo = false;
  final TextEditingController scIssuesIdentified = TextEditingController();
  final TextEditingController scActionTaken = TextEditingController();
  final TextEditingController scGoodPractice = TextEditingController();
  final TextEditingController scName = TextEditingController();
  final TextEditingController scDate = TextEditingController();

  List<Point> scSignaturePoints = [];
  Signature scSignature;
  Uint8List scImageBytes;

  int rowCount = 1;
  int roleCount = 1;

  String jobRefRef = 'Select One';

  List<String> jobRefDrop = [
    'Select One',
  ];

  @override
  void initState() {
    // TODO: implement initState
    _loadingTemporary = true;
    spotChecksModel = Provider.of<SpotChecksModel>(context, listen: false);
    jobRefsModel = context.read<JobRefsModel>();
    _setUpTextControllerListeners();
    _getTemporarySpotChecks();
    super.initState();
  }

  @override
  void dispose() {
    jobRef.dispose();
    scStaff1.dispose();
    scStaff2.dispose();
    scStaff3.dispose();
    scStaff4.dispose();
    scStaff5.dispose();
    scStaff6.dispose();
    scStaff7.dispose();
    scStaff8.dispose();
    scStaff9.dispose();
    scStaff10.dispose();
    scIssuesIdentified.dispose();
    scActionTaken.dispose();
    scGoodPractice.dispose();
    scName.dispose();
    scDate.dispose();
    super.dispose();
  }




  _addListener(TextEditingController controller, String value, [bool encrypt = true, bool capitalise = false, bool isName = false]){

    controller.addListener(() {
      setState(() {
      });

      String controllerText = controller.text;

      if(capitalise){
        controllerText = controllerText.toUpperCase();
      }

      if(isName){
        String newString = '';
        List<String> parts = controllerText.split(' ');
        for(String part in parts){
          if(part.isNotEmpty) part = part[0].toUpperCase() + part.substring(1);
          if(newString.isEmpty){
            newString += part;
          } else {
            newString = newString + ' ' + part;
          }
        }

        controllerText = newString;
      }

      //Sembast
      spotChecksModel.updateTemporaryRecord(widget.edit, value, encrypt ? GlobalFunctions.encryptString(controllerText) : GlobalFunctions.databaseValueString(controllerText), widget.jobId);

      // _databaseHelper.updateTemporarySpotChecksField(widget.edit, {
      //   value:
      //   encrypt ? GlobalFunctions.encryptString(controllerText) : GlobalFunctions.databaseValueString(controllerText)
      // }, user.uid, widget.jobId);
    });
  }

  _setUpTextControllerListeners() {

    _addListener(jobRef, Strings.jobRefNo, false, true);
    _addListener(scStaff1, Strings.scStaff1, true, false, true);
    _addListener(scStaff2, Strings.scStaff2, true, false, true);
    _addListener(scStaff3, Strings.scStaff3, true, false, true);
    _addListener(scStaff4, Strings.scStaff4, true, false, true);
    _addListener(scStaff5, Strings.scStaff5, true, false, true);
    _addListener(scStaff6, Strings.scStaff6, true, false, true);
    _addListener(scStaff7, Strings.scStaff7, true, false, true);
    _addListener(scStaff8, Strings.scStaff8, true, false, true);
    _addListener(scStaff9, Strings.scStaff9, true, false, true);
    _addListener(scStaff10, Strings.scStaff10, true, false, true);
    _addListener(scIssuesIdentified, Strings.scIssuesIdentified);
    _addListener(scActionTaken, Strings.scActionTaken);
    _addListener(scGoodPractice, Strings.scGoodPractice);
    _addListener(scName, Strings.scName, true, false, true);
  }

  _getTemporarySpotChecks() async {

    if (mounted) {

      await jobRefsModel.getJobRefs();

      if(jobRefsModel.allJobRefs.isNotEmpty){
        for(Map<String, dynamic> jobRefMap in jobRefsModel.allJobRefs){
          jobRefDrop.add(jobRefMap['job_ref']);
        }
      }





      await spotChecksModel.setupTemporaryRecord();

      bool hasRecord = await spotChecksModel.checkRecordExists(widget.edit, widget.jobId);


      if (hasRecord) {
        Map<String, dynamic> spotChecks = await spotChecksModel.getTemporaryRecord(widget.edit, widget.jobId);

        if (spotChecks[Strings.scSignature] != null) {
          if (mounted) {

            Uint8List decryptedSignature = await GlobalFunctions.decryptSignature(spotChecks[Strings.scSignature]);
            setState(() {
              scImageBytes = decryptedSignature;
            });
          }
        } else {
          scSignature = null;
          scImageBytes = null;
        }
        if (spotChecks[Strings.scSignaturePoints] != null) {
          if (mounted) {
            String decryptedPoints = GlobalFunctions.decryptString(spotChecks[Strings.scSignaturePoints]);
            setState(() {
              List<dynamic> fetchedSignaturePoints = jsonDecode(decryptedPoints);
              fetchedSignaturePoints.forEach((dynamic pointMap) {
                if (pointMap['pointType'] == 'tap') {
                  scSignaturePoints.add(Point(
                      Offset(pointMap['dx'], pointMap['dy']),
                      PointType.tap));
                } else if (pointMap['pointType'] == 'move') {
                  scSignaturePoints.add(Point(
                      Offset(pointMap['dx'], pointMap['dy']),
                      PointType.move));
                }
              });
            });
          }
        } else {
          scSignaturePoints = [];

        }



        if (spotChecks[Strings.jobRefNo] != null) {
          jobRef.text = GlobalFunctions.databaseValueString(
              spotChecks[Strings.jobRefNo]);
        } else {
          jobRef.text = '';
        }

        if (spotChecks[Strings.jobRefRef] != null) {

          if(jobRefDrop.contains(GlobalFunctions.databaseValueString(spotChecks[Strings.jobRefRef]))){
            jobRefRef = GlobalFunctions.databaseValueString(spotChecks[Strings.jobRefRef]);
          } else {
            jobRefRef = 'Select One';
          }

        }

        GlobalFunctions.getTemporaryValue(spotChecks, scStaff1, Strings.scStaff1);
        GlobalFunctions.getTemporaryValue(spotChecks, scStaff2, Strings.scStaff2);
        GlobalFunctions.getTemporaryValue(spotChecks, scStaff3, Strings.scStaff3);
        GlobalFunctions.getTemporaryValue(spotChecks, scStaff4, Strings.scStaff4);
        GlobalFunctions.getTemporaryValue(spotChecks, scStaff5, Strings.scStaff5);
        GlobalFunctions.getTemporaryValue(spotChecks, scStaff6, Strings.scStaff6);
        GlobalFunctions.getTemporaryValue(spotChecks, scStaff7, Strings.scStaff7);
        GlobalFunctions.getTemporaryValue(spotChecks, scStaff8, Strings.scStaff8);
        GlobalFunctions.getTemporaryValue(spotChecks, scStaff9, Strings.scStaff9);
        GlobalFunctions.getTemporaryValue(spotChecks, scStaff10, Strings.scStaff10);
        GlobalFunctions.getTemporaryValue(spotChecks, scIssuesIdentified, Strings.scIssuesIdentified);
        GlobalFunctions.getTemporaryValue(spotChecks, scActionTaken, Strings.scActionTaken);
        GlobalFunctions.getTemporaryValue(spotChecks, scGoodPractice, Strings.scGoodPractice);
        GlobalFunctions.getTemporaryValue(spotChecks, scName, Strings.scName);


        if (spotChecks[Strings.scDate] != null) {
          scDate.text =
              dateFormat.format(DateTime.parse(spotChecks[Strings.scDate]));
        } else {
          scDate.text = '';
        }
        if (spotChecks[Strings.scOnTimeYes] != null) {
          if (mounted) {
            setState(() {
              scOnTimeYes = GlobalFunctions.tinyIntToBool(spotChecks[Strings.scOnTimeYes]);
            });
          }
        }
        if (spotChecks[Strings.scOnTimeNo] != null) {
          if (mounted) {
            setState(() {
              scOnTimeNo = GlobalFunctions.tinyIntToBool(spotChecks[Strings.scOnTimeNo]);
            });
          }
        }
        if (spotChecks[Strings.scCorrectUniformYes] != null) {
          if (mounted) {
            setState(() {
              scCorrectUniformYes = GlobalFunctions.tinyIntToBool(spotChecks[Strings.scCorrectUniformYes]);
            });
          }
        }
        if (spotChecks[Strings.scCorrectUniformNo] != null) {
          if (mounted) {
            setState(() {
              scCorrectUniformNo = GlobalFunctions.tinyIntToBool(spotChecks[Strings.scCorrectUniformNo]);
            });
          }
        }
        if (spotChecks[Strings.scPegasusBadgeYes] != null) {
          if (mounted) {
            setState(() {
              scPegasusBadgeYes = GlobalFunctions.tinyIntToBool(spotChecks[Strings.scPegasusBadgeYes]);
            });
          }
        }
        if (spotChecks[Strings.scPegasusBadgeNo] != null) {
          if (mounted) {
            setState(() {
              scPegasusBadgeNo = GlobalFunctions.tinyIntToBool(spotChecks[Strings.scPegasusBadgeNo]);
            });
          }
        }
        if (spotChecks[Strings.scVehicleChecksYes] != null) {
          if (mounted) {
            setState(() {
              scVehicleChecksYes = GlobalFunctions.tinyIntToBool(spotChecks[Strings.scVehicleChecksYes]);
            });
          }
        }
        if (spotChecks[Strings.scVehicleChecksNo] != null) {
          if (mounted) {
            setState(() {
              scVehicleChecksNo = GlobalFunctions.tinyIntToBool(spotChecks[Strings.scVehicleChecksNo]);
            });
          }
        }
        if (spotChecks[Strings.scCollectionStaffIntroduceYes] != null) {
          if (mounted) {
            setState(() {
              scCollectionStaffIntroduceYes = GlobalFunctions.tinyIntToBool(spotChecks[Strings.scCollectionStaffIntroduceYes]);
            });
          }
        }
        if (spotChecks[Strings.scCollectionStaffIntroduceNo] != null) {
          if (mounted) {
            setState(() {
              scCollectionStaffIntroduceNo = GlobalFunctions.tinyIntToBool(spotChecks[Strings.scCollectionStaffIntroduceNo]);
            });
          }
        }
        if (spotChecks[Strings.scCollectionTransferReportYes] != null) {
          if (mounted) {
            setState(() {
              scCollectionTransferReportYes = GlobalFunctions.tinyIntToBool(spotChecks[Strings.scCollectionTransferReportYes]);
            });
          }
        }
        if (spotChecks[Strings.scCollectionTransferReportNo] != null) {
          if (mounted) {
            setState(() {
              scCollectionTransferReportNo = GlobalFunctions.tinyIntToBool(spotChecks[Strings.scCollectionTransferReportNo]);
            });
          }
        }
        if (spotChecks[Strings.scStaffEngageYes] != null) {
          if (mounted) {
            setState(() {
              scStaffEngageYes = GlobalFunctions.tinyIntToBool(spotChecks[Strings.scStaffEngageYes]);
            });
          }
        }
        if (spotChecks[Strings.scStaffEngageNo] != null) {
          if (mounted) {
            setState(() {
              scStaffEngageNo = GlobalFunctions.tinyIntToBool(spotChecks[Strings.scStaffEngageNo]);
            });
          }
        }
        if (spotChecks[Strings.scArrivalStaffIntroduceYes] != null) {
          if (mounted) {
            setState(() {
              scArrivalStaffIntroduceYes = GlobalFunctions.tinyIntToBool(spotChecks[Strings.scArrivalStaffIntroduceYes]);
            });
          }
        }
        if (spotChecks[Strings.scArrivalStaffIntroduceNo] != null) {
          if (mounted) {
            setState(() {
              scArrivalStaffIntroduceNo = GlobalFunctions.tinyIntToBool(spotChecks[Strings.scArrivalStaffIntroduceNo]);
            });
          }
        }

        if (spotChecks[Strings.scArrivalTransferReportYes] != null) {
          if (mounted) {
            setState(() {
              scArrivalTransferReportYes = GlobalFunctions.tinyIntToBool(spotChecks[Strings.scArrivalTransferReportYes]);
            });
          }
        }
        if (spotChecks[Strings.scArrivalTransferReportNo] != null) {
          if (mounted) {
            setState(() {
              scArrivalTransferReportNo = GlobalFunctions.tinyIntToBool(spotChecks[Strings.scArrivalTransferReportNo]);
            });
          }
        }

        if (spotChecks[Strings.scPhysicalInterventionYes] != null) {
          if (mounted) {
            setState(() {
              scPhysicalInterventionYes = GlobalFunctions.tinyIntToBool(spotChecks[Strings.scPhysicalInterventionYes]);
            });
          }
        }
        if (spotChecks[Strings.scPhysicalInterventionNo] != null) {
          if (mounted) {
            setState(() {
              scPhysicalInterventionNo = GlobalFunctions.tinyIntToBool(spotChecks[Strings.scPhysicalInterventionNo]);
            });
          }
        }

        if (spotChecks[Strings.scInfectionControl1Yes] != null) {
          if (mounted) {
            setState(() {
              scInfectionControl1Yes = GlobalFunctions.tinyIntToBool(spotChecks[Strings.scInfectionControl1Yes]);
            });
          }
        }
        if (spotChecks[Strings.scInfectionControl1No] != null) {
          if (mounted) {
            setState(() {
              scInfectionControl1No = GlobalFunctions.tinyIntToBool(spotChecks[Strings.scInfectionControl1No]);
            });
          }
        }

        if (spotChecks[Strings.scInfectionControl2Yes] != null) {
          if (mounted) {
            setState(() {
              scInfectionControl2Yes = GlobalFunctions.tinyIntToBool(spotChecks[Strings.scInfectionControl2Yes]);
            });
          }
        }
        if (spotChecks[Strings.scInfectionControl2No] != null) {
          if (mounted) {
            setState(() {
              scInfectionControl2No = GlobalFunctions.tinyIntToBool(spotChecks[Strings.scInfectionControl2No]);
            });
          }
        }

        if (spotChecks[Strings.scVehicleTidyYes] != null) {
          if (mounted) {
            setState(() {
              scVehicleTidyYes = GlobalFunctions.tinyIntToBool(spotChecks[Strings.scVehicleTidyYes]);
            });
          }
        }
        if (spotChecks[Strings.scVehicleTidyNo] != null) {
          if (mounted) {
            setState(() {
              scVehicleTidyNo = GlobalFunctions.tinyIntToBool(spotChecks[Strings.scVehicleTidyNo]);
            });
          }
        }

        if (spotChecks[Strings.scCompletedTransferReportYes] != null) {
          if (mounted) {
            setState(() {
              scCompletedTransferReportYes = GlobalFunctions.tinyIntToBool(spotChecks[Strings.scCompletedTransferReportYes]);
            });
          }
        }
        if (spotChecks[Strings.scCompletedTransferReportNo] != null) {
          if (mounted) {
            setState(() {
              scCompletedTransferReportNo = GlobalFunctions.tinyIntToBool(spotChecks[Strings.scCompletedTransferReportNo]);
            });
          }
        }

        if (spotChecks[Strings.scStaff2] != null && spotChecks[Strings.scStaff2] != '') {
          setState(() {
            roleCount += 1;
          });
        }
        if (spotChecks[Strings.scStaff3] != null && spotChecks[Strings.scStaff3] != '') {
          setState(() {
            roleCount += 1;
          });
        }
        if (spotChecks[Strings.scStaff4] != null && spotChecks[Strings.scStaff4] != '') {
          setState(() {
            roleCount += 1;
          });
        }
        if (spotChecks[Strings.scStaff5] != null && spotChecks[Strings.scStaff5] != '') {
          setState(() {
            roleCount += 1;
          });
        }
        if (spotChecks[Strings.scStaff6] != null && spotChecks[Strings.scStaff6] != '') {
          setState(() {
            roleCount += 1;
          });
        }
        if (spotChecks[Strings.scStaff7] != null && spotChecks[Strings.scStaff7] != '') {
          setState(() {
            roleCount += 1;
          });
        }
        if (spotChecks[Strings.scStaff8] != null && spotChecks[Strings.scStaff8] != '') {
          setState(() {
            roleCount += 1;
          });
        }
        if (spotChecks[Strings.scStaff9] != null && spotChecks[Strings.scStaff9] != '') {
          setState(() {
            roleCount += 1;
          });
        }
        if (spotChecks[Strings.scStaff10] != null && spotChecks[Strings.scStaff10] != '') {
          setState(() {
            roleCount += 1;
          });
        }

        setState(() {
          rowCount = roleCount;
        });

        if (mounted) {
          setState(() {
            _loadingTemporary = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _loadingTemporary = false;
          });
        }
      }
    }
  }

  _increaseRowCount(){
    if(rowCount == 10){
      GlobalFunctions.showToast('Maximum staff added');
    } else {
      setState(() {
        rowCount +=1;
      });
    }
  }

  _decreaseRowCount(){
    if(rowCount == 1){
      GlobalFunctions.showToast('Unable to remove');
    } else {
      setState(() {
        if(rowCount == 2) scStaff2.clear();
        if(rowCount == 3) scStaff3.clear();
        if(rowCount == 4) scStaff4.clear();
        if(rowCount == 5) scStaff5.clear();
        if(rowCount == 6) scStaff6.clear();
        if(rowCount == 7) scStaff7.clear();
        if(rowCount == 8) scStaff8.clear();
        if(rowCount == 9) scStaff9.clear();
        if(rowCount == 10) scStaff10.clear();
        rowCount -=1;
      });
    }
  }

  Widget _buildJobRefDrop() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
              text: 'Reference',
              style: TextStyle(
                  fontSize: 16.0, fontFamily: 'Open Sans', color: bluePurple),
              children:
              [
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 16.0),
                ),                                           ]
          ),
        ),
        Container(
          color: jobRefRef == 'Select One' ? Color(0xFF0000).withOpacity(0.3) : null,
          child: DropdownFormField(
            expanded: false,
            value: jobRefRef,
            items: jobRefDrop.toList(),
            onChanged: (val) => setState(() {
              jobRefRef = val;
              if(val == 'Select One'){
                spotChecksModel.updateTemporaryRecord(widget.edit, Strings.jobRefRef, null, widget.jobId);
              } else {
                spotChecksModel.updateTemporaryRecord(widget.edit, Strings.jobRefRef, val, widget.jobId);
              }

              FocusScope.of(context).unfocus();
            }),
            initialValue: jobRefRef,
          ),
        ),
        SizedBox(height: 15,),
      ],
    );
  }

  Widget _buildScSignatureRow() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 10.0,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                      text: 'Signed',
                      style: TextStyle(
                          fontSize: 16.0, fontFamily: 'Open Sans', color: bluePurple),
                      children:
                      [
                        TextSpan(
                          text: ' *',
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: 16.0, fontFamily: 'Open Sans'),
                        ),                                           ]
                  ),
                )
              ],),
          ],
        ),
        SizedBox(
          height: 10.0,
        ),
        Container(
          color: scImageBytes == null ? Color(0xFF0000).withOpacity(0.3) : null,
child: Center(
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
                if(widget.edit){
                  GlobalFunctions.showToast('Signatures cannot be amended on already submitted forms');
                } else {
                  showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        scSignature = Signature(
                          points: scSignaturePoints,
                          height: 99,
                          width: 280.0,
                          backgroundColor: Colors.white,
                        );

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
                            child: Center(child: Text("Signature", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            //mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    border: new Border.all(
                                        color: Colors.black, width: 2.0)),
                                height: 100.0,
                                child: scSignature,
                              )
                            ],
                          ),
                          actions: <Widget>[
                            TextButton(
                                onPressed: () {
                                  scSignature
                                      .clear();

                                  //Sembast

                                  spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scSignaturePoints, null, widget.jobId);
                                  spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scSignature, null, widget.jobId);

                                  setState(() {
                                    scSignaturePoints = [];
                                    scImageBytes =
                                    null;
                                  });
                                },
                                child: Text(
                                  'Clear',
                                  style: TextStyle(color: bluePurple),
                                )),
                            TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(color: bluePurple),
                                )),
                            TextButton(
                                onPressed: () async {
                                  List<Map<String, dynamic>> pointsMap = [];

                                  scSignaturePoints =
                                      scSignature
                                          .exportPoints();

                                  if (scSignaturePoints.length > 0) {
                                    scSignaturePoints.forEach((
                                        Point p) {
                                      if (p.type == PointType.move) {
                                        pointsMap.add({
                                          'pointType': 'move',
                                          'dx': p.offset.dx,
                                          'dy': p.offset.dy
                                        });
                                      } else if (p.type == PointType.tap) {
                                        pointsMap.add({
                                          'pointType': 'tap',
                                          'dx': p.offset.dx,
                                          'dy': p.offset.dy
                                        });
                                      }
                                    });

                                    var encodedPoints = jsonEncode(pointsMap);

                                    String encryptedPoints = GlobalFunctions
                                        .encryptString(encodedPoints);

                                    //Sembast
                                    spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scSignaturePoints, encryptedPoints, widget.jobId);

                                    Uint8List signatureBytes = await scSignature
                                        .exportBytes();

                                    setState(() {
                                      scImageBytes =
                                          signatureBytes;
                                    });

                                    Uint8List encryptedSignature = await GlobalFunctions
                                        .encryptSignature(scImageBytes);

                                    //Sembast
                                    spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scSignature, encryptedSignature, widget.jobId);

                                    Navigator.of(context).pop();
                                  } else {
                                    Navigator.of(context).pop();
                                  }
                                },
                                child: Text(
                                  'OK',
                                  style: TextStyle(color: bluePurple),
                                ))
                          ],
                        );
                      });
                }
              },
              child: scImageBytes == null
                  ? Icon(
                Icons.border_color,
                color: bluePurple,
                size: 40.0,
              )
                  : Image.memory(scImageBytes),
            ),
          ),
        )
      ],
    );
  }

  Widget _textFormField(String label, TextEditingController controller, [int lines = 1, bool required = false, TextInputType textInputType = TextInputType.text]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
              text: label,
              style: TextStyle(
                  fontSize: 16.0, fontFamily: 'Open Sans', color: bluePurple),
              children:
              [
                TextSpan(
                  text: required ? ' *' : '',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 16.0),
                ),                                           ]
          ),
        ),
        TextFormField(
          keyboardType: textInputType,
          inputFormatters: textInputType == TextInputType.number ? <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
          ] : null,
          validator: (String value) {
            String message;
            if(required){
              if (value.trim().length <= 0 && value.isEmpty) {
                message = "Required";
              }
            }
            return message;
          },
          maxLines: lines,
          decoration: InputDecoration(
              filled: required && controller.text.isEmpty ? true : false, fillColor: Color(0xFF0000).withOpacity(0.3),

              suffixIcon: controller.text == ''
                  ? null
                  : IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      SchedulerBinding.instance.addPostFrameCallback((_) {
                        FocusScope.of(context).unfocus();
                        controller.clear();
                      });
                    });
                  })),
          controller: controller,
        ),
        SizedBox(height: 15,),
      ],
    );
  }

  Widget _buildDateField(String label, TextEditingController controller, String value, [bool required = false, bool encrypt = false]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: label,
              style: TextStyle(
                  fontSize: 16.0, fontFamily: 'Open Sans', color: bluePurple),
              children:
              [
                TextSpan(
                  text: required ? ' *' : '',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16.0, fontFamily: 'Open Sans',),
                ),                                           ]
          ),
        ),
        Row(
          children: <Widget>[
            Flexible(
              child: IgnorePointer(
                child: TextFormField(
                  decoration: InputDecoration(              filled: required && controller.text.isEmpty ? true : false, fillColor: Color(0xFF0000).withOpacity(0.3),
                  ),
                  enabled: true,
                  initialValue: null,
                  controller: controller,
                  onSaved: (String value) {
                    setState(() {
                      controller.text = value;
                    });
                  },

                ),
              ),
            ),
            IconButton(
                color: Colors.grey,
                icon: Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    controller.clear();
                    spotChecksModel.updateTemporaryRecord(widget.edit, value, null, widget.jobId);

                    // _databaseHelper.updateTemporarySpotChecksField(widget.edit,
                    //     {value : null}, user.uid, widget.jobId);

                  });
                }),
            IconButton(
                icon: Icon(Icons.access_time,
                    color: bluePurple),
                onPressed: () async{
                  FocusScope.of(context).unfocus();
                  await Future.delayed(Duration(milliseconds: 100));
                  showDatePicker(
                      builder: (BuildContext context, Widget child) {
                        return Theme(
                          data: ThemeData.light().copyWith(
                            colorScheme: ColorScheme.light().copyWith(
                              primary: bluePurple,
                            ),
                          ),
                          child: child,
                        );
                      },
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1920),
                      lastDate: DateTime(2100))
                      .then((DateTime newDate) {
                    if (newDate != null) {
                      String dateTime = dateFormat.format(newDate);
                      setState(() {
                        controller.text = dateTime;
                        if(encrypt){

                          spotChecksModel.updateTemporaryRecord(widget.edit, value, GlobalFunctions.encryptString(DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String()), widget.jobId);


                          // _databaseHelper.updateTemporarySpotChecksField(widget.edit,
                          //     {value : GlobalFunctions.encryptString(DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String())}, user.uid, widget.jobId);
                        } else {

                          spotChecksModel.updateTemporaryRecord(widget.edit, value, DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String(), widget.jobId);


                          // _databaseHelper.updateTemporarySpotChecksField(widget.edit,
                          //     {value : DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String()}, user.uid, widget.jobId);
                        }



                      });
                    }
                  });
                })
          ],
        ),
        SizedBox(height: 15,),
      ],
    );
  }
  Widget _buildTimeField(String label, TextEditingController controller, String value, [bool required = false, bool encrypt = false]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: label,
              style: TextStyle(
                  fontSize: 16.0, fontFamily: 'Open Sans', color: bluePurple),
              children:
              [
                TextSpan(
                  text: required ? ' *' : '',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 16.0, fontFamily: 'Open Sans'),
                ),                                           ]
          ),
        ),
        Row(
          children: <Widget>[
            Flexible(
              child: IgnorePointer(
                child: TextFormField(
                  decoration: InputDecoration(              filled: required && controller.text.isEmpty ? true : false, fillColor: Color(0xFF0000).withOpacity(0.3),
                  ),
                  enabled: true,
                  initialValue: null,
                  controller: controller,
                  onSaved: (String value) {
                    setState(() {
                      controller.text = value;
                    });
                  },

                ),
              ),
            ),
            IconButton(
                color: Colors.grey,
                icon: Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    controller.clear();
                    spotChecksModel.updateTemporaryRecord(widget.edit, value, null, widget.jobId);

                    // _databaseHelper.updateTemporarySpotChecksField(widget.edit,
                    //     {value : null}, user.uid, widget.jobId);
                  });
                }),
            IconButton(
                icon: Icon(Icons.access_time,
                    color: bluePurple),
                onPressed: () async{
                  FocusScope.of(context).unfocus();
                  await Future.delayed(Duration(milliseconds: 100));
                  showTimePicker(
                      initialTime: TimeOfDay.now(),
                      builder: (BuildContext context, Widget child) {
                        return Theme(
                          data: ThemeData.light().copyWith(
                            colorScheme: ColorScheme.light().copyWith(
                              primary: bluePurple,
                            ),
                          ),
                          child: child,
                        );
                      },
                      context: context)
                      .then((TimeOfDay time) {
                    if (time != null) {
                      DateTime today = new DateTime.now();
                      DateTime newDate = new DateTime(today.year, today.month, today.day);
                      newDate = newDate.add(Duration(hours: time.hour, minutes: time.minute));
                      String dateTime = timeFormat.format(newDate);
                      setState(() {
                        controller.text = dateTime;
                        if(encrypt){
                         spotChecksModel.updateTemporaryRecord(widget.edit, value, GlobalFunctions.encryptString(DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String()), widget.jobId);

                          // _databaseHelper.updateTemporarySpotChecksField(widget.edit,
                          //     {value : GlobalFunctions.encryptString(DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String())}, user.uid, widget.jobId);
                        } else {
                          spotChecksModel.updateTemporaryRecord(widget.edit, value, DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String(), widget.jobId);

                          // _databaseHelper.updateTemporarySpotChecksField(widget.edit,
                          //     {value : DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String()}, user.uid, widget.jobId);
                        }
                      });
                    }
                  });
                })
          ],
        ),
        SizedBox(height: 15,)
      ],
    );
  }

  Widget _scOnTimeCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: 'Did staff arrive to base on time?',
              style: TextStyle(
                  fontSize: 16.0, fontFamily: 'Open Sans', color: bluePurple),
              children:
              [
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 16.0),
                ),                                           ]
          ),
        ),
        Container(
          color: scOnTimeYes == false && scOnTimeNo == false ? Color(0xFF0000).withOpacity(0.3) : null,
          child: Row(
            children: <Widget>[
              Text(
                'Yes',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: scOnTimeYes,
                  onChanged: (bool value) => setState(() {
                    scOnTimeYes = value;
                    spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scOnTimeYes, GlobalFunctions.boolToTinyInt(value), widget.jobId);

                    if (scOnTimeNo == true){
                      scOnTimeNo = false;
                      spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scOnTimeNo, null, widget.jobId);
                    }
                  })),
              Text(
                'No',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: scOnTimeNo,
                  onChanged: (bool value) => setState(() {
                    scOnTimeNo = value;
                    spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scOnTimeNo, GlobalFunctions.boolToTinyInt(value), widget.jobId);

                    if (scOnTimeYes == true){
                      scOnTimeYes = false;
                      spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scOnTimeYes, null, widget.jobId);
                    }
                  }))
            ],
          ),
        )
      ],
    );

  }

  Widget _scCorrectUniformCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: 'Were staff in correct uniform?',
              style: TextStyle(
                  fontSize: 16.0, fontFamily: 'Open Sans', color: bluePurple),
              children:
              [
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 16.0),
                ),                                           ]
          ),
        ),
        Container(
          color: scCorrectUniformYes == false && scCorrectUniformNo == false ? Color(0xFF0000).withOpacity(0.3) : null,
          child: Row(
            children: <Widget>[
              Text(
                'Yes',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: scCorrectUniformYes,
                  onChanged: (bool value) => setState(() {
                    scCorrectUniformYes = value;
                    spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scCorrectUniformYes, GlobalFunctions.boolToTinyInt(value), widget.jobId);

                    if (scCorrectUniformNo == true){
                      scCorrectUniformNo = false;
                      spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scCorrectUniformNo, null, widget.jobId);
                    }
                  })),
              Text(
                'No',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: scCorrectUniformNo,
                  onChanged: (bool value) => setState(() {
                    scCorrectUniformNo = value;
                    spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scCorrectUniformNo, GlobalFunctions.boolToTinyInt(value), widget.jobId);

                    if (scCorrectUniformYes == true){
                      scCorrectUniformYes = false;
                      spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scCorrectUniformYes, null, widget.jobId);
                    }
                  }))
            ],
          ),
        )
      ],
    );

  }

  Widget _scPegasusBadgeCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: 'Were all staff wearing Pegasus ID badge?',
              style: TextStyle(
                  fontSize: 16.0, fontFamily: 'Open Sans', color: bluePurple),
              children:
              [
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 16.0),
                ),                                           ]
          ),
        ),
        Container(
          color: scPegasusBadgeYes == false && scPegasusBadgeNo == false ? Color(0xFF0000).withOpacity(0.3) : null,
          child: Row(
            children: <Widget>[
              Text(
                'Yes',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: scPegasusBadgeYes,
                  onChanged: (bool value) => setState(() {
                    scPegasusBadgeYes = value;
                    spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scPegasusBadgeYes, GlobalFunctions.boolToTinyInt(value), widget.jobId);

                    if (scPegasusBadgeNo == true){
                      scPegasusBadgeNo = false;
                      spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scPegasusBadgeNo, null, widget.jobId);
                    }
                  })),
              Text(
                'No',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: scPegasusBadgeNo,
                  onChanged: (bool value) => setState(() {
                    scPegasusBadgeNo = value;
                    spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scPegasusBadgeNo, GlobalFunctions.boolToTinyInt(value), widget.jobId);

                    if (scPegasusBadgeYes == true){
                      scPegasusBadgeYes = false;
                      spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scPegasusBadgeYes, null, widget.jobId);
                    }
                  }))
            ],
          ),
        )
      ],
    );

  }

  Widget _scVehicleChecksCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: 'Were pre vehicle checks completed prior to leaving base?',
              style: TextStyle(
                  fontSize: 16.0, fontFamily: 'Open Sans', color: bluePurple),
              children:
              [
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 16.0),
                ),                                           ]
          ),
        ),
        Container(
          color: scVehicleChecksYes == false && scVehicleChecksNo == false ? Color(0xFF0000).withOpacity(0.3) : null,
          child: Row(
            children: <Widget>[
              Text(
                'Yes',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: scVehicleChecksYes,
                  onChanged: (bool value) => setState(() {
                    scVehicleChecksYes = value;
                    spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scVehicleChecksYes, GlobalFunctions.boolToTinyInt(value), widget.jobId);

                    if (scVehicleChecksNo == true){
                      scVehicleChecksNo = false;
                      spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scVehicleChecksNo, null, widget.jobId);
                    }
                  })),
              Text(
                'No',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: scVehicleChecksNo,
                  onChanged: (bool value) => setState(() {
                    scVehicleChecksNo = value;
                    spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scVehicleChecksNo, GlobalFunctions.boolToTinyInt(value), widget.jobId);

                    if (scVehicleChecksYes == true){
                      scVehicleChecksYes = false;
                      spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scVehicleChecksYes, null, widget.jobId);
                    }
                  }))
            ],
          ),
        )
      ],
    );

  }

  Widget _scCollectionStaffIntroduceCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: 'On arrival to collection unit did all staff introduce themselves?',
              style: TextStyle(
                  fontSize: 16.0, fontFamily: 'Open Sans', color: bluePurple),
              children:
              [
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 16.0),
                ),                                           ]
          ),
        ),
        Container(
          color: scCollectionStaffIntroduceYes == false && scCollectionStaffIntroduceNo == false ? Color(0xFF0000).withOpacity(0.3) : null,
          child: Row(
            children: <Widget>[
              Text(
                'Yes',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: scCollectionStaffIntroduceYes,
                  onChanged: (bool value) => setState(() {
                    scCollectionStaffIntroduceYes = value;
                    spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scCollectionStaffIntroduceYes, GlobalFunctions.boolToTinyInt(value), widget.jobId);

                    if (scCollectionStaffIntroduceNo == true){
                      scCollectionStaffIntroduceNo = false;
                      spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scCollectionStaffIntroduceNo, null, widget.jobId);
                    }
                  })),
              Text(
                'No',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: scCollectionStaffIntroduceNo,
                  onChanged: (bool value) => setState(() {
                    scCollectionStaffIntroduceNo = value;
                    spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scCollectionStaffIntroduceNo, GlobalFunctions.boolToTinyInt(value), widget.jobId);

                    if (scCollectionStaffIntroduceYes == true){
                      scCollectionStaffIntroduceYes = false;
                      spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scCollectionStaffIntroduceYes, null, widget.jobId);
                    }
                  }))
            ],
          ),
        )
      ],
    );

  }

  Widget _scCollectionTransferReportCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: 'Was the transfer report completed fully and a detailed handover of the patient received?',
              style: TextStyle(
                  fontSize: 16.0, fontFamily: 'Open Sans', color: bluePurple),
              children:
              [
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 16.0),
                ),                                           ]
          ),
        ),
        Container(
          color: scCollectionTransferReportYes == false && scCollectionTransferReportNo == false ? Color(0xFF0000).withOpacity(0.3) : null,
          child: Row(
            children: <Widget>[
              Text(
                'Yes',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: scCollectionTransferReportYes,
                  onChanged: (bool value) => setState(() {
                    scCollectionTransferReportYes = value;
                    spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scCollectionTransferReportYes, GlobalFunctions.boolToTinyInt(value), widget.jobId);

                    if (scCollectionTransferReportNo == true){
                      scCollectionTransferReportNo = false;
                      spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scCollectionTransferReportNo, null, widget.jobId);
                    }
                  })),
              Text(
                'No',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: scCollectionTransferReportNo,
                  onChanged: (bool value) => setState(() {
                    scCollectionTransferReportNo = value;
                    spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scCollectionTransferReportNo, GlobalFunctions.boolToTinyInt(value), widget.jobId);

                    if (scCollectionTransferReportYes == true){
                      scCollectionTransferReportYes = false;
                      spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scCollectionTransferReportYes, null, widget.jobId);
                    }
                  }))
            ],
          ),
        )
      ],
    );

  }

  Widget _scStaffEngageCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: 'During the journey did staff engage with patient appropriately treating them with dignity and respect?',
              style: TextStyle(
                  fontSize: 16.0, fontFamily: 'Open Sans', color: bluePurple),
              children:
              [
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 16.0),
                ),                                           ]
          ),
        ),
        Container(
          color: scStaffEngageYes == false && scStaffEngageNo == false ? Color(0xFF0000).withOpacity(0.3) : null,
          child: Row(
            children: <Widget>[
              Text(
                'Yes',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: scStaffEngageYes,
                  onChanged: (bool value) => setState(() {
                    scStaffEngageYes = value;
                    spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scStaffEngageYes, GlobalFunctions.boolToTinyInt(value), widget.jobId);

                    if (scStaffEngageNo == true){
                      scStaffEngageNo = false;
                      spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scStaffEngageNo, null, widget.jobId);
                    }
                  })),
              Text(
                'No',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: scStaffEngageNo,
                  onChanged: (bool value) => setState(() {
                    scStaffEngageNo = value;
                    spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scStaffEngageNo, GlobalFunctions.boolToTinyInt(value), widget.jobId);

                    if (scStaffEngageYes == true){
                      scStaffEngageYes = false;
                      spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scStaffEngageYes, null, widget.jobId);
                    }
                  }))
            ],
          ),
        )
      ],
    );

  }

  Widget _scArrivalStaffIntroduceCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: 'On arrival to destination unit did staff introduce themselves?',
              style: TextStyle(
                  fontSize: 16.0, fontFamily: 'Open Sans', color: bluePurple),
              children:
              [
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 16.0),
                ),                                           ]
          ),
        ),
        Container(
          color: scArrivalStaffIntroduceYes == false && scArrivalStaffIntroduceNo == false ? Color(0xFF0000).withOpacity(0.3) : null,
          child: Row(
            children: <Widget>[
              Text(
                'Yes',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: scArrivalStaffIntroduceYes,
                  onChanged: (bool value) => setState(() {
                    scArrivalStaffIntroduceYes = value;
                    spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scArrivalStaffIntroduceYes, GlobalFunctions.boolToTinyInt(value), widget.jobId);

                    if (scArrivalStaffIntroduceNo == true){
                      scArrivalStaffIntroduceNo = false;
                      spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scArrivalStaffIntroduceNo, null, widget.jobId);
                    }
                  })),
              Text(
                'No',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: scArrivalStaffIntroduceNo,
                  onChanged: (bool value) => setState(() {
                    scArrivalStaffIntroduceNo = value;
                    spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scArrivalStaffIntroduceNo, GlobalFunctions.boolToTinyInt(value), widget.jobId);

                    if (scArrivalStaffIntroduceYes == true){
                      scArrivalStaffIntroduceYes = false;
                      spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scArrivalStaffIntroduceYes, null, widget.jobId);
                    }
                  }))
            ],
          ),
        )
      ],
    );

  }

  Widget _scArrivalTransferReportCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: 'Was the transfer report completed fully and a detailed handover of the patient given?',
              style: TextStyle(
                  fontSize: 16.0, fontFamily: 'Open Sans', color: bluePurple),
              children:
              [
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 16.0),
                ),                                           ]
          ),
        ),
        Container(
          color: scArrivalTransferReportYes == false && scArrivalTransferReportNo == false ? Color(0xFF0000).withOpacity(0.3) : null,
          child: Row(
            children: <Widget>[
              Text(
                'Yes',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: scArrivalTransferReportYes,
                  onChanged: (bool value) => setState(() {
                    scArrivalTransferReportYes = value;
                    spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scArrivalTransferReportYes, GlobalFunctions.boolToTinyInt(value), widget.jobId);

                    if (scArrivalTransferReportNo == true){
                      scArrivalTransferReportNo = false;
                      spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scArrivalTransferReportNo, null, widget.jobId);
                    }
                  })),
              Text(
                'No',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: scArrivalTransferReportNo,
                  onChanged: (bool value) => setState(() {
                    scArrivalTransferReportNo = value;
                    spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scArrivalTransferReportNo, GlobalFunctions.boolToTinyInt(value), widget.jobId);

                    if (scArrivalTransferReportYes == true){
                      scArrivalTransferReportYes = false;
                      spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scArrivalTransferReportYes, null, widget.jobId);
                    }
                  }))
            ],
          ),
        )
      ],
    );

  }

  Widget _scPhysicalInterventionCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: 'If physical intervention was used was this used utilised for the least amount of time possible in keeping with least restrictive principle?',
              style: TextStyle(
                  fontSize: 16.0, fontFamily: 'Open Sans', color: bluePurple),
              children:
              [
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 16.0),
                ),                                           ]
          ),
        ),
        Container(
          color: scPhysicalInterventionYes == false && scPhysicalInterventionNo == false ? Color(0xFF0000).withOpacity(0.3) : null,
          child: Row(
            children: <Widget>[
              Text(
                'Yes',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: scPhysicalInterventionYes,
                  onChanged: (bool value) => setState(() {
                    scPhysicalInterventionYes = value;
                    spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scPhysicalInterventionYes, GlobalFunctions.boolToTinyInt(value), widget.jobId);

                    if (scPhysicalInterventionNo == true){
                      scPhysicalInterventionNo = false;
                      spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scPhysicalInterventionNo, null, widget.jobId);
                    }
                  })),
              Text(
                'No',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: scPhysicalInterventionNo,
                  onChanged: (bool value) => setState(() {
                    scPhysicalInterventionNo = value;
                    spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scPhysicalInterventionNo, GlobalFunctions.boolToTinyInt(value), widget.jobId);

                    if (scPhysicalInterventionYes == true){
                      scPhysicalInterventionYes = false;
                      spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scPhysicalInterventionYes, null, widget.jobId);
                    }
                  }))
            ],
          ),
        )
      ],
    );

  }

  Widget _scInfectionControl1Checkboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: 'Did staff carry out infection control procedures during transfer i.e. handwashing?',
              style: TextStyle(
                  fontSize: 16.0, fontFamily: 'Open Sans', color: bluePurple),
              children:
              [
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 16.0),
                ),                                           ]
          ),
        ),
        Container(
          color: scInfectionControl1Yes == false && scInfectionControl1No == false ? Color(0xFF0000).withOpacity(0.3) : null,
          child: Row(
            children: <Widget>[
              Text(
                'Yes',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: scInfectionControl1Yes,
                  onChanged: (bool value) => setState(() {
                    scInfectionControl1Yes = value;
                    spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scInfectionControl1Yes, GlobalFunctions.boolToTinyInt(value), widget.jobId);

                    if (scInfectionControl1No == true){
                      scInfectionControl1No = false;
                      spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scInfectionControl1No, null, widget.jobId);
                    }
                  })),
              Text(
                'No',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: scInfectionControl1No,
                  onChanged: (bool value) => setState(() {
                    scInfectionControl1No = value;
                    spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scInfectionControl1No, GlobalFunctions.boolToTinyInt(value), widget.jobId);

                    if (scInfectionControl1Yes == true){
                      scInfectionControl1Yes = false;
                      spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scInfectionControl1Yes, null, widget.jobId);
                    }
                  }))
            ],
          ),
        )
      ],
    );

  }

  Widget _scInfectionControl2Checkboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: 'Following transfer did staff use infection control procedures to clean vehicle, i.e. touch point, seat?',
              style: TextStyle(
                  fontSize: 16.0, fontFamily: 'Open Sans', color: bluePurple),
              children:
              [
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 16.0),
                ),                                           ]
          ),
        ),
        Container(
          color: scInfectionControl2Yes == false && scInfectionControl2No == false ? Color(0xFF0000).withOpacity(0.3) : null,
          child: Row(
            children: <Widget>[
              Text(
                'Yes',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: scInfectionControl2Yes,
                  onChanged: (bool value) => setState(() {
                    scInfectionControl2Yes = value;
                    spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scInfectionControl2Yes, GlobalFunctions.boolToTinyInt(value), widget.jobId);

                    if (scInfectionControl2No == true){
                      scInfectionControl2No = false;
                      spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scInfectionControl2No, null, widget.jobId);
                    }
                  })),
              Text(
                'No',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: scInfectionControl2No,
                  onChanged: (bool value) => setState(() {
                    scInfectionControl2No = value;
                    spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scInfectionControl2No, GlobalFunctions.boolToTinyInt(value), widget.jobId);

                    if (scInfectionControl2Yes == true){
                      scInfectionControl2Yes = false;
                      spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scInfectionControl2Yes, null, widget.jobId);
                    }
                  }))
            ],
          ),
        )
      ],
    );

  }

  Widget _scVehicleTidyCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: 'Was the vehicle left clean and tidy?',
              style: TextStyle(
                  fontSize: 16.0, fontFamily: 'Open Sans', color: bluePurple),
              children:
              [
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 16.0),
                ),                                           ]
          ),
        ),
        Container(
          color: scVehicleTidyYes == false && scVehicleTidyNo == false ? Color(0xFF0000).withOpacity(0.3) : null,
          child: Row(
            children: <Widget>[
              Text(
                'Yes',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: scVehicleTidyYes,
                  onChanged: (bool value) => setState(() {
                    scVehicleTidyYes = value;
                    spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scVehicleTidyYes, GlobalFunctions.boolToTinyInt(value), widget.jobId);

                    if (scVehicleTidyNo == true){
                      scVehicleTidyNo = false;
                      spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scVehicleTidyNo, null, widget.jobId);
                    }
                  })),
              Text(
                'No',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: scVehicleTidyNo,
                  onChanged: (bool value) => setState(() {
                    scVehicleTidyNo = value;
                    spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scVehicleTidyNo, GlobalFunctions.boolToTinyInt(value), widget.jobId);

                    if (scVehicleTidyYes == true){
                      scVehicleTidyYes = false;
                      spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scVehicleTidyYes, null, widget.jobId);
                    }
                  }))
            ],
          ),
        )
      ],
    );

  }

  Widget _scCompletedTransferReportCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: 'Was the transfer report fully completed at the end of the journey?',
              style: TextStyle(
                  fontSize: 16.0, fontFamily: 'Open Sans', color: bluePurple),
              children:
              [
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 16.0),
                ),                                           ]
          ),
        ),
        Container(
          color: scCompletedTransferReportYes == false && scCompletedTransferReportNo == false ? Color(0xFF0000).withOpacity(0.3) : null,
          child: Row(
            children: <Widget>[
              Text(
                'Yes',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: scCompletedTransferReportYes,
                  onChanged: (bool value) => setState(() {
                    scCompletedTransferReportYes = value;
                    spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scCompletedTransferReportYes, GlobalFunctions.boolToTinyInt(value), widget.jobId);

                    if (scCompletedTransferReportNo == true){
                      scCompletedTransferReportNo = false;
                      spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scCompletedTransferReportNo, null, widget.jobId);
                    }
                  })),
              Text(
                'No',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: scCompletedTransferReportNo,
                  onChanged: (bool value) => setState(() {
                    scCompletedTransferReportNo = value;
                    spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scCompletedTransferReportNo, GlobalFunctions.boolToTinyInt(value), widget.jobId);

                    if (scCompletedTransferReportYes == true){
                      scCompletedTransferReportYes = false;
                      spotChecksModel.updateTemporaryRecord(widget.edit, Strings.scCompletedTransferReportYes, null, widget.jobId);
                    }
                  }))
            ],
          ),
        )
      ],
    );

  }

  void _resetForm() {
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
              child: Center(child: Text("Reset Spot Checks", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),),
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
                  context.read<SpotChecksModel>().resetTemporaryRecord(widget.jobId);
                  //context.read<SpotChecksModel>().resetTemporarySpotChecks(widget.jobId);
                  FocusScope.of(context).requestFocus(new FocusNode());
                  setState(() {
                    jobRef.clear();
                    jobRefRef = 'Select One';
                    scStaff1.clear();
                    scStaff2.clear();
                    scStaff3.clear();
                    scStaff4.clear();
                    scStaff5.clear();
                    scStaff6.clear();
                    scStaff7.clear();
                    scStaff8.clear();
                    scStaff9.clear();
                    scStaff10.clear();
                    scOnTimeYes = false;
                    scOnTimeNo  = false;
                    scCorrectUniformYes = false;
                    scCorrectUniformNo  = false;
                    scPegasusBadgeYes = false;
                    scPegasusBadgeNo  = false;
                    scVehicleChecksYes  = false;
                    scVehicleChecksNo = false;
                    scCollectionStaffIntroduceYes = false;
                    scCollectionStaffIntroduceNo  = false;
                    scCollectionTransferReportYes = false;
                    scCollectionTransferReportNo  = false;
                    scStaffEngageYes  = false;
                    scStaffEngageNo = false;
                    scArrivalStaffIntroduceYes  = false;
                    scArrivalStaffIntroduceNo = false;
                    scArrivalTransferReportYes  = false;
                    scArrivalTransferReportNo = false;
                    scPhysicalInterventionYes = false;
                    scPhysicalInterventionNo  = false;
                    scInfectionControl1Yes  = false;
                    scInfectionControl1No = false;
                    scInfectionControl2Yes  = false;
                    scInfectionControl2No = false;
                    scVehicleTidyYes  = false;
                    scVehicleTidyNo = false;
                    scCompletedTransferReportYes  = false;
                    scCompletedTransferReportNo = false;
                    scIssuesIdentified.clear();
                    scActionTaken.clear();
                    scGoodPractice.clear();
                    scName.clear();
                    scDate.clear();
                    scSignature = null;
                    scImageBytes = null;
                    scSignaturePoints = [];
                    rowCount = 1;
                    roleCount = 1;
                  });
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

  void _submitForm() async {
    FocusScope.of(context).unfocus();

    bool continueSubmit = await spotChecksModel.validateSpotChecks(widget.jobId, widget.edit);


    if (!continueSubmit) {

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
                child: Center(child: Text("Check Form", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                        text: 'Please ensure you have filled in all required fields marked with a',
                        style: TextStyle(color: Colors.black, fontSize: 16, fontFamily: 'Open Sans'),
                        children:
                        [
                          TextSpan(
                            text: ' *',
                            style: TextStyle(
                                color: Colors.red, fontSize: 16, fontFamily: 'Open Sans'),
                          ),                                           ]
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'OK',
                    style: TextStyle(color: blueDesign, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          });



    } else {

      bool submitForm = await showDialog(
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
                child: Center(child: Text("Submit Spot Checks", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),),
              ),
              content: Text('Are you sure you wish to submit this form?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    Navigator.of(context).pop(false);
                  },
                  child: Text(
                    'No',
                    style: TextStyle(color: blueDesign, fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: () async{
                    Navigator.of(context).pop(true);
                  },
                  child: Text(
                    'Yes',
                    style: TextStyle(color: blueDesign, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          });



      if(submitForm){

        bool success;

        if(widget.edit){
          success = await context.read<SpotChecksModel>().editSpotChecks(widget.jobId);
          FocusScope.of(context).requestFocus(new FocusNode());

        } else {
          success = await context.read<SpotChecksModel>().submitSpotChecks(widget.jobId);
          FocusScope.of(context).requestFocus(new FocusNode());
        }

        if(success){
          setState(() {
            jobRef.clear();
            jobRefRef = 'Select One';
            scStaff1.clear();
            scStaff2.clear();
            scStaff3.clear();
            scStaff4.clear();
            scStaff5.clear();
            scStaff6.clear();
            scStaff7.clear();
            scStaff8.clear();
            scStaff9.clear();
            scStaff10.clear();
            scOnTimeYes = false;
            scOnTimeNo  = false;
            scCorrectUniformYes = false;
            scCorrectUniformNo  = false;
            scPegasusBadgeYes = false;
            scPegasusBadgeNo  = false;
            scVehicleChecksYes  = false;
            scVehicleChecksNo = false;
            scCollectionStaffIntroduceYes = false;
            scCollectionStaffIntroduceNo  = false;
            scCollectionTransferReportYes = false;
            scCollectionTransferReportNo  = false;
            scStaffEngageYes  = false;
            scStaffEngageNo = false;
            scArrivalStaffIntroduceYes  = false;
            scArrivalStaffIntroduceNo = false;
            scArrivalTransferReportYes  = false;
            scArrivalTransferReportNo = false;
            scPhysicalInterventionYes = false;
            scPhysicalInterventionNo  = false;
            scInfectionControl1Yes  = false;
            scInfectionControl1No = false;
            scInfectionControl2Yes  = false;
            scInfectionControl2No = false;
            scVehicleTidyYes  = false;
            scVehicleTidyNo = false;
            scCompletedTransferReportYes  = false;
            scCompletedTransferReportNo = false;
            scIssuesIdentified.clear();
            scActionTaken.clear();
            scGoodPractice.clear();
            scName.clear();
            scDate.clear();
            scSignature = null;
            scImageBytes = null;
            scSignaturePoints = [];
            rowCount = 1;
            roleCount = 1;
            FocusScope.of(context).requestFocus(new FocusNode());
          });
        }


      }
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: [
                      Flexible(child: _buildJobRefDrop()),
                      Container(width: 10,),
                      Flexible(child: _textFormField('', jobRef, 1, true, TextInputType.number),),
                    ],
                  ),
                  SizedBox(height: 10,),
                  Text('Staff on Duty', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 18),),
                  SizedBox(height: 10,),
                  _textFormField('Name', scStaff1),
                  rowCount >= 2 ? _textFormField('Name', scStaff2) : Container(),
                  rowCount >= 3 ? _textFormField('Name', scStaff3) : Container(),
                  rowCount >= 4 ? _textFormField('Name', scStaff4) : Container(),
                  rowCount >= 5 ? _textFormField('Name', scStaff5) : Container(),
                  rowCount >= 6 ? _textFormField('Name', scStaff6) : Container(),
                  rowCount >= 7 ? _textFormField('Name', scStaff7) : Container(),
                  rowCount >= 8 ? _textFormField('Name', scStaff8) : Container(),
                  rowCount >= 9 ? _textFormField('Name', scStaff9) : Container(),
                  rowCount >= 10 ? _textFormField('Name', scStaff10) : Container(),

                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    rowCount < 2 ? Container() :
                    SizedBox(width: 150, child: GradientButton('Remove Staff', () => _decreaseRowCount()),),
                    SizedBox(width: 10,),
                    SizedBox(width: 150, child: GradientButton('Add Staff', () => _increaseRowCount()),),
                  ],),
                  SizedBox(height: 10,),
                  _scOnTimeCheckboxes(),
                  _scCorrectUniformCheckboxes(),
                  _scPegasusBadgeCheckboxes(),
                  _scVehicleChecksCheckboxes(),
                  _scCollectionStaffIntroduceCheckboxes(),
                  _scCollectionTransferReportCheckboxes(),
                  _scStaffEngageCheckboxes(),
                  _scArrivalStaffIntroduceCheckboxes(),
                  _scArrivalTransferReportCheckboxes(),
                  _scPhysicalInterventionCheckboxes(),
                  _scInfectionControl1Checkboxes(),
                  _scInfectionControl2Checkboxes(),
                  _scVehicleTidyCheckboxes(),
                  _scCompletedTransferReportCheckboxes(),
                  SizedBox(height: 10,),
                  _textFormField('Issues Identified', scIssuesIdentified, 4, false, TextInputType.multiline),
                  _textFormField('Action Taken', scActionTaken, 4, false, TextInputType.multiline),
                  _textFormField('Areas of good practice', scGoodPractice, 4, false, TextInputType.multiline),
                  _textFormField('Name', scName, 1, true),
                  _buildDateField('Date', scDate, Strings.scDate, true, false),
                  _buildScSignatureRow(),
                  SizedBox(height: 20,),
                ]),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      drawer: widget.edit ? null : SideDrawer(),
      appBar: AppBar(
        flexibleSpace: AppBarGradient(),
        title: FittedBox(fit:BoxFit.fitWidth,
            child: Text('Pegasus Spot Checks', style: TextStyle(fontWeight: FontWeight.bold),)),
        actions: <Widget>[
          widget.edit ? Container() : IconButton(icon: Icon(Icons.refresh), onPressed: _resetForm),
          IconButton(icon: Icon(Icons.send), onPressed: _submitForm)
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

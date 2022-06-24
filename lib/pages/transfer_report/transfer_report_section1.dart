import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:pegasus_medical_1808/models/job_refs_model.dart';
import 'package:pegasus_medical_1808/models/transfer_report_model.dart';
import 'package:pegasus_medical_1808/shared/global_config.dart';
import 'package:pegasus_medical_1808/shared/global_functions.dart';
import 'package:pegasus_medical_1808/shared/strings.dart';
import 'package:pegasus_medical_1808/utils/database_helper.dart';
import 'package:pegasus_medical_1808/widgets/gradient_button.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:signature/signature.dart';
import 'package:after_layout/after_layout.dart';
import 'package:pegasus_medical_1808/widgets/dropdown_form_field.dart';
import 'package:flutter/foundation.dart' show kIsWeb;



class TransferReportSection1 extends StatefulWidget {

  final bool fromJob;
  final String jobId;
  final bool fillDetails;
  final bool edit;
  final bool saved;
  final int savedId;

  TransferReportSection1(
      [
        this.fromJob = false,
        this.jobId = '1',
        this.fillDetails = false,
        this.edit = false,
        this.saved = false,
        this.savedId = 0
      ]
      );

  @override
  _TransferReportSection1State createState() => _TransferReportSection1State();
}

class _TransferReportSection1State extends State<TransferReportSection1> with AfterLayoutMixin<TransferReportSection1> {

  bool _loadingTemporary = false;
  //DatabaseHelper _databaseHelper = DatabaseHelper();
  TransferReportModel transferReportModel;
  JobRefsModel jobRefsModel;


  //Vehicle Checklist
  bool ambulanceTidyYes1 = false;
  bool ambulanceTidyNo1 = false;
  bool lightsWorkingYes = false;
  bool lightsWorkingNo = false;
  bool tyresInflatedYes = false;
  bool tyresInflatedNo = false;
  bool warningSignsYes = false;
  bool warningSignsNo = false;
  bool vehicleDamageYes = false;
  bool vehicleDamageNo = false;
  bool ambulanceTidyYes2 = false;
  bool ambulanceTidyNo2 = false;
  bool sanitiserCleanYes = false;
  bool sanitiserCleanNo = false;
  final TextEditingController vehicleCompletedBy1 = TextEditingController();
  final TextEditingController ambulanceReg = TextEditingController();
  final TextEditingController vehicleStartMileage = TextEditingController();
  final TextEditingController vehicleCompletedBy2 = TextEditingController();
  final TextEditingController finishMileage = TextEditingController();
  final TextEditingController totalMileage = TextEditingController();
  final TextEditingController issuesFaults = TextEditingController();
  final TextEditingController vehicleDate = TextEditingController();
  final TextEditingController vehicleTime = TextEditingController();
  String nearestTank1 = 'Select One';
  String nearestTank2 = 'Select One';
  List<String> nearestTankDrop = [
    'Select One',
    '1/4',
    '1/2',
    '3/4 ',
    'Full'];

  bool showPopup = false;
  bool mandatoryIssuesFaults;

  //Start of Job Details
  final dateFormat = DateFormat("dd/MM/yyyy");
  final timeFormat = DateFormat("HH:mm");
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController jobRef = TextEditingController();
  final TextEditingController date = TextEditingController();
  final TextEditingController startTime = TextEditingController();
  final TextEditingController finishTime = TextEditingController();
  final TextEditingController totalHours = TextEditingController();
  final TextEditingController collectionDetails = TextEditingController();
  final TextEditingController collectionPostcode = TextEditingController();
  final TextEditingController collectionContactNo = TextEditingController();
  final TextEditingController destinationDetails = TextEditingController();
  final TextEditingController destinationPostcode = TextEditingController();
  final TextEditingController destinationContactNo = TextEditingController();
  final TextEditingController collectionArrivalTime = TextEditingController();
  final TextEditingController collectionDepartureTime = TextEditingController();
  final TextEditingController destinationArrivalTime = TextEditingController();
  final TextEditingController destinationDepartureTime = TextEditingController();
  final TextEditingController vehicleRegNo = TextEditingController();
  final TextEditingController startMileage = TextEditingController();
  final TextEditingController name1 = TextEditingController();
  final TextEditingController other1 = TextEditingController();
  final TextEditingController drivingTimes1_1 = TextEditingController();
  final TextEditingController drivingTimes1_2 = TextEditingController();
  final TextEditingController name2 = TextEditingController();
  final TextEditingController other2 = TextEditingController();
  final TextEditingController drivingTimes2_1 = TextEditingController();
  final TextEditingController drivingTimes2_2 = TextEditingController();
  final TextEditingController name3 = TextEditingController();
  final TextEditingController other3 = TextEditingController();
  final TextEditingController drivingTimes3_1 = TextEditingController();
  final TextEditingController drivingTimes3_2 = TextEditingController();
  final TextEditingController name4 = TextEditingController();
  final TextEditingController other4 = TextEditingController();
  final TextEditingController drivingTimes4_1 = TextEditingController();
  final TextEditingController drivingTimes4_2 = TextEditingController();
  final TextEditingController name5 = TextEditingController();
  final TextEditingController other5 = TextEditingController();
  final TextEditingController drivingTimes5_1 = TextEditingController();
  final TextEditingController drivingTimes5_2 = TextEditingController();
  final TextEditingController name6 = TextEditingController();
  final TextEditingController other6 = TextEditingController();
  final TextEditingController drivingTimes6_1 = TextEditingController();
  final TextEditingController drivingTimes6_2 = TextEditingController();
  final TextEditingController name7 = TextEditingController();
  final TextEditingController other7 = TextEditingController();
  final TextEditingController drivingTimes7_1 = TextEditingController();
  final TextEditingController drivingTimes7_2 = TextEditingController();
  final TextEditingController name8 = TextEditingController();
  final TextEditingController other8 = TextEditingController();
  final TextEditingController drivingTimes8_1 = TextEditingController();
  final TextEditingController drivingTimes8_2 = TextEditingController();
  final TextEditingController name9 = TextEditingController();
  final TextEditingController other9 = TextEditingController();
  final TextEditingController drivingTimes9_1 = TextEditingController();
  final TextEditingController drivingTimes9_2 = TextEditingController();
  final TextEditingController name10 = TextEditingController();
  final TextEditingController other10 = TextEditingController();
  final TextEditingController drivingTimes10_1 = TextEditingController();
  final TextEditingController drivingTimes10_2 = TextEditingController();
  final TextEditingController name11 = TextEditingController();
  final TextEditingController other11 = TextEditingController();
  final TextEditingController drivingTimes11_1 = TextEditingController();
  final TextEditingController drivingTimes11_2 = TextEditingController();
  final TextEditingController collectionUnit = TextEditingController();
  final TextEditingController collectionPosition = TextEditingController();
  final TextEditingController collectionPrintName = TextEditingController();
  final TextEditingController collectionArrivalTimeEnd = TextEditingController();
  final TextEditingController destinationUnit = TextEditingController();
  final TextEditingController destinationPosition = TextEditingController();
  final TextEditingController destinationPrintName = TextEditingController();
  final TextEditingController destinationArrivalTimeEnd = TextEditingController();

  List<Point> collectionSignaturePoints = [];
  Signature collectionSignature;
  Uint8List collectionImageBytes;

  List<Point> destinationSignaturePoints = [];
  Signature destinationSignature;
  Uint8List destinationImageBytes;

  String role1 = 'Select One';
  String role2 = 'Select One';
  String role3 = 'Select One';
  String role4 = 'Select One';
  String role5 = 'Select One';
  String role6 = 'Select One';
  String role7 = 'Select One';
  String role8 = 'Select One';
  String role9 = 'Select One';
  String role10 = 'Select One';
  String role11 = 'Select One';




  List<String> roleDrop = [
    'Select One',
    'RMN',
    'HCA',
    'Other'];

  int rowCount = 1;
  int roleCount = 1;

  String jobRefRef = 'Select One';

  List<String> jobRefDrop = [
    'Select One',
  ];





  @override
  void initState() {
    // TODO: implement initState
    //if(!isWeb) _loadingTemporary = true;
    _loadingTemporary = true;
    transferReportModel = Provider.of<TransferReportModel>(context, listen: false);
    jobRefsModel = context.read<JobRefsModel>();
    _setUpTextControllerListeners();
    _getTemporaryTransferReport();
    super.initState();
  }

  @override
  void dispose() {

    vehicleCompletedBy1.dispose();
    ambulanceReg.dispose();
    vehicleStartMileage.dispose();
    vehicleCompletedBy2.dispose();
    finishMileage.dispose();
    totalMileage.dispose();
    issuesFaults.dispose();
    vehicleDate.dispose();
    vehicleTime.dispose();

    jobRef.dispose();
    date.dispose();
    startTime.dispose();
    finishTime.dispose();
    totalHours.dispose();
    collectionDetails.dispose();
    collectionPostcode.dispose();
    collectionContactNo.dispose();
    destinationDetails.dispose();
    destinationPostcode.dispose();
    destinationContactNo.dispose();
    collectionArrivalTime.dispose();
    collectionDepartureTime.dispose();
    destinationArrivalTime.dispose();
    destinationDepartureTime.dispose();
    vehicleRegNo.dispose();
    startMileage.dispose();
    name1.dispose();
    other1.dispose();
    drivingTimes1_1.dispose();
    drivingTimes1_2.dispose();
    name2.dispose();
    other2.dispose();
    drivingTimes2_1.dispose();
    drivingTimes2_2.dispose();
    name3.dispose();
    other3.dispose();
    drivingTimes3_1.dispose();
    drivingTimes3_2.dispose();
    name4.dispose();
    other4.dispose();
    drivingTimes4_1.dispose();
    drivingTimes4_2.dispose();
    name5.dispose();
    other5.dispose();
    drivingTimes5_1.dispose();
    drivingTimes5_2.dispose();
    name6.dispose();
    other6.dispose();
    drivingTimes6_1.dispose();
    drivingTimes6_2.dispose();
    name7.dispose();
    other7.dispose();
    drivingTimes7_1.dispose();
    drivingTimes7_2.dispose();
    name8.dispose();
    other8.dispose();
    drivingTimes8_1.dispose();
    drivingTimes8_2.dispose();
    name9.dispose();
    other9.dispose();
    drivingTimes9_1.dispose();
    drivingTimes9_2.dispose();
    name10.dispose();
    other10.dispose();
    drivingTimes10_1.dispose();
    drivingTimes10_2.dispose();
    name11.dispose();
    other11.dispose();
    drivingTimes11_1.dispose();
    drivingTimes11_2.dispose();
    collectionUnit.dispose();
    collectionPosition.dispose();
    collectionPrintName.dispose();
    collectionArrivalTimeEnd.dispose();
    destinationUnit.dispose();
    destinationPosition.dispose();
    destinationPrintName.dispose();
    destinationArrivalTimeEnd.dispose();
    super.dispose();
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    if(!kIsWeb) {
      if (Platform.isIOS) OneSignal.shared
          .promptUserForPushNotificationPermission().then((accepted) {
        print("Accepted permission: $accepted");
      });
    }
  }

  void showIssuesDialog(){
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
              child: Center(child: Text("Explain Issue / Fault", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    text: 'Please explain in issues / faults box at the bottom of the Vehicle Checklist page',
                    style: TextStyle(color: Colors.black, fontSize: 16, fontFamily: 'Open Sans'),
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
      transferReportModel.updateTemporaryRecord(widget.edit, value, encrypt ? GlobalFunctions.encryptString(controllerText) : GlobalFunctions.databaseValueString(controllerText), widget.jobId, widget.saved, widget.savedId);

        // _databaseHelper.updateTemporaryTransferReportField(widget.edit, {
        //   value:
        //   encrypt ? GlobalFunctions.encryptString(controllerText) : GlobalFunctions.databaseValueString(controllerText)
        // }, user.uid, widget.jobId, widget.saved, widget.savedId);
    });
  }

  _setUpTextControllerListeners() {

    _addListener(vehicleCompletedBy1, Strings.vehicleCompletedBy1, true, false, true);
    _addListener(ambulanceReg, Strings.ambulanceReg, true, true);
    _addListener(vehicleStartMileage, Strings.vehicleStartMileage);
    _addListener(vehicleCompletedBy2, Strings.vehicleCompletedBy2, true, false, true);
    _addListener(issuesFaults, Strings.issuesFaults);
    _addListener(jobRef, Strings.jobRefNo, false, true);
    _addListener(totalHours, Strings.totalHours, false);
    _addListener(collectionDetails, Strings.collectionDetails);
    _addListener(collectionPostcode, Strings.collectionPostcode, true, true);
    _addListener(collectionContactNo, Strings.collectionContactNo);
    _addListener(destinationDetails, Strings.destinationDetails);
    _addListener(destinationPostcode, Strings.destinationPostcode, true, true);
    _addListener(destinationContactNo, Strings.destinationContactNo);
    _addListener(vehicleRegNo, Strings.vehicleRegNo, true, true);

    startMileage.addListener(() async{

      Map<String, dynamic> transferReport = await transferReportModel.getTemporaryRecord(widget.edit, widget.jobId, widget.saved, widget.savedId);
      //Map<String, dynamic> transferReport = await _databaseHelper.getTemporaryTransferReport(widget.edit, user.uid, widget.jobId, widget.saved, widget.savedId);
      if(transferReport[Strings.finishMileage] != null){
        double startMileageDouble = double.tryParse(startMileage.text);
        double finishMileageDouble = double.tryParse(GlobalFunctions.decryptString(transferReport[Strings.finishMileage]));

        if(startMileageDouble != null && finishMileageDouble != null){
          double totalMileageDouble = finishMileageDouble - startMileageDouble;
          num totalNumber = totalMileageDouble % 1 == 0 ? totalMileageDouble.toInt() : totalMileageDouble;

          if(totalMileageDouble != null){
            transferReportModel.updateTemporaryRecord(widget.edit, Strings.totalMileage, GlobalFunctions.encryptString(totalNumber.toString()), widget.jobId, widget.saved, widget.savedId);
            // _databaseHelper.updateTemporaryTransferReportField(widget.edit, {
            //   Strings.totalMileage:
            //   GlobalFunctions.encryptString(totalNumber.toString())
            // }, user.uid, widget.jobId, widget.saved, widget.savedId);
          }

        } else {
          transferReportModel.updateTemporaryRecord(widget.edit, Strings.totalMileage, GlobalFunctions.encryptString(''), widget.jobId, widget.saved, widget.savedId);

          // _databaseHelper.updateTemporaryTransferReportField(widget.edit, {
          //   Strings.totalMileage:
          //   GlobalFunctions.encryptString('')
          // }, user.uid, widget.jobId, widget.saved, widget.savedId);
        }
      }

      setState(() {
      });
      transferReportModel.updateTemporaryRecord(widget.edit, Strings.startMileage, GlobalFunctions.encryptString(startMileage.text), widget.jobId, widget.saved, widget.savedId);

      // _databaseHelper.updateTemporaryTransferReportField(widget.edit, {
      //   Strings.startMileage:
      //   GlobalFunctions.encryptString(startMileage.text)
      // }, user.uid, widget.jobId, widget.saved, widget.savedId);
    });


    _addListener(finishMileage, Strings.finishMileage);
    _addListener(totalMileage, Strings.totalMileage);
    _addListener(name1, Strings.name1, true, false, true);
    _addListener(other1, Strings.role1);
    _addListener(name2, Strings.name2, true, false, true);
    _addListener(other2, Strings.role2);
    _addListener(name3, Strings.name3, true, false, true);
    _addListener(other3, Strings.role3);
    _addListener(name4, Strings.name4, true, false, true);
    _addListener(other4, Strings.role4);
    _addListener(name5, Strings.name5, true, false, true);
    _addListener(other5, Strings.role5);
    _addListener(name6, Strings.name6, true, false, true);
    _addListener(other6, Strings.role6);
    _addListener(name7, Strings.name7, true, false, true);
    _addListener(other7, Strings.role7);
    _addListener(name8, Strings.name8, true, false, true);
    _addListener(other8, Strings.role8);
    _addListener(name9, Strings.name9, true, false, true);
    _addListener(other9, Strings.role9);
    _addListener(name10, Strings.name10, true, false, true);
    _addListener(other10, Strings.role10);
    _addListener(name11, Strings.name11, true, false, true);
    _addListener(other11, Strings.role11);
    _addListener(collectionUnit, Strings.collectionUnit);
    _addListener(collectionPosition, Strings.collectionPosition);
    _addListener(collectionPrintName, Strings.collectionPrintName, true, false, true);
    _addListener(destinationUnit, Strings.destinationUnit);
    _addListener(destinationPosition, Strings.destinationPosition);
    _addListener(destinationPrintName, Strings.destinationPrintName, true, false, true);

  }

  _getTemporaryTransferReport() async {

    if (mounted) {

      await jobRefsModel.getJobRefs();

      if(jobRefsModel.allJobRefs.isNotEmpty){
        for(Map<String, dynamic> jobRefMap in jobRefsModel.allJobRefs){
          jobRefDrop.add(jobRefMap['job_ref']);
        }
      }

      await transferReportModel.setupTemporaryRecord();

      bool hasRecord = await transferReportModel.checkRecordExists(widget.edit, widget.jobId, widget.saved, widget.savedId);

      if(hasRecord){
        Map<String, dynamic> transferReport = await transferReportModel.getTemporaryRecord(widget.edit, widget.jobId, widget.saved, widget.savedId);

        if (transferReport[Strings.collectionSignature] != null) {
          if (mounted) {
            Uint8List decryptedSignature = await GlobalFunctions.decryptSignature(transferReport[Strings.collectionSignature]);
            setState(() {
              collectionImageBytes = decryptedSignature;
            });
          }
        } else {
          collectionSignature = null;
          collectionImageBytes = null;
        }
        if (transferReport[Strings.collectionSignaturePoints] != null) {
          if (mounted) {
            String decryptedPoints = GlobalFunctions.decryptString(transferReport[Strings.collectionSignaturePoints]);
            setState(() {
              List<dynamic> fetchedSignaturePoints = jsonDecode(decryptedPoints);
              fetchedSignaturePoints.forEach((dynamic pointMap) {
                if (pointMap['pointType'] == 'tap') {
                  collectionSignaturePoints.add(Point(
                      Offset(pointMap['dx'], pointMap['dy']),
                      PointType.tap));
                } else if (pointMap['pointType'] == 'move') {
                  collectionSignaturePoints.add(Point(
                      Offset(pointMap['dx'], pointMap['dy']),
                      PointType.move));
                }
              });
            });
          }
        } else {
          collectionSignaturePoints = [];

        }
        if (transferReport[Strings.destinationSignature] != null) {
          if (mounted) {
            Uint8List decryptedSignature = await GlobalFunctions.decryptSignature(transferReport[Strings.destinationSignature]);
            setState(() {
              destinationImageBytes = decryptedSignature;
            });
          }
        } else {
          destinationSignature = null;
          destinationImageBytes = null;
        }
        if (transferReport[Strings.destinationSignaturePoints] != null) {
          if (mounted) {
            String decryptedPoints = GlobalFunctions.decryptString(transferReport[Strings.destinationSignaturePoints]);
            setState(() {
              List<dynamic> fetchedSignaturePoints = jsonDecode(decryptedPoints);
              fetchedSignaturePoints.forEach((dynamic pointMap) {
                if (pointMap['pointType'] == 'tap') {
                  destinationSignaturePoints.add(Point(
                      Offset(pointMap['dx'], pointMap['dy']),
                      PointType.tap));
                } else if (pointMap['pointType'] == 'move') {
                  destinationSignaturePoints.add(Point(
                      Offset(pointMap['dx'], pointMap['dy']),
                      PointType.move));
                }
              });
            });
          }
        } else {
          destinationSignaturePoints = [];

        }


        //Vehicle Checklist



        if(transferReport[Strings.vehicleCompletedBy1] == null){
          vehicleCompletedBy1.text = user.name;
          transferReportModel.updateTemporaryRecord(widget.edit, Strings.vehicleCompletedBy1, GlobalFunctions.encryptString(vehicleCompletedBy1.text), widget.jobId, widget.saved, widget.savedId);

          // _databaseHelper.updateTemporaryTransferReportField(widget.edit, {
          //   Strings.vehicleCompletedBy1: GlobalFunctions.encryptString(vehicleCompletedBy1.text)
          // }, user.uid, widget.jobId, widget.saved, widget.savedId);
        } else {
          GlobalFunctions.getTemporaryValue(transferReport, vehicleCompletedBy1, Strings.vehicleCompletedBy1);
        }
        GlobalFunctions.getTemporaryValue(transferReport, ambulanceReg, Strings.ambulanceReg);
        GlobalFunctions.getTemporaryValue(transferReport, vehicleStartMileage, Strings.vehicleStartMileage);
        if (transferReport[Strings.nearestTank1] != null) {
          nearestTank1 = GlobalFunctions.decryptString(transferReport[Strings.nearestTank1]);
        }
        if(transferReport[Strings.vehicleCompletedBy2] == null){
          vehicleCompletedBy2.text = user.name;
          transferReportModel.updateTemporaryRecord(widget.edit, Strings.vehicleCompletedBy2, GlobalFunctions.encryptString(vehicleCompletedBy2.text), widget.jobId, widget.saved, widget.savedId);

          // _databaseHelper.updateTemporaryTransferReportField(widget.edit, {
          //   Strings.vehicleCompletedBy2: GlobalFunctions.encryptString(vehicleCompletedBy2.text)
          // }, user.uid, widget.jobId, widget.saved, widget.savedId);
        } else {
          GlobalFunctions.getTemporaryValue(transferReport, vehicleCompletedBy2, Strings.vehicleCompletedBy2);
        }
        if (transferReport[Strings.nearestTank2] != null) {
          nearestTank2 = GlobalFunctions.decryptString(transferReport[Strings.nearestTank2]);
        }
        GlobalFunctions.getTemporaryValue(transferReport, finishMileage, Strings.finishMileage);
        GlobalFunctions.getTemporaryValue(transferReport, totalMileage, Strings.totalMileage);
        GlobalFunctions.getTemporaryValue(transferReport, issuesFaults, Strings.issuesFaults);
        GlobalFunctions.getTemporaryValueDate(transferReport, vehicleDate, Strings.vehicleDate);
        GlobalFunctions.getTemporaryValueTime(transferReport, vehicleTime, Strings.vehicleTime);

        if (transferReport[Strings.ambulanceTidyYes1] != null) {
          if (mounted) {
            setState(() {
              ambulanceTidyYes1 = GlobalFunctions.tinyIntToBool(transferReport[Strings.ambulanceTidyYes1]);
            });
          }
        }
        if (transferReport[Strings.ambulanceTidyNo1] != null) {
          if (mounted) {
            setState(() {
              ambulanceTidyNo1 = GlobalFunctions.tinyIntToBool(transferReport[Strings.ambulanceTidyNo1]);
              if(ambulanceTidyNo1) mandatoryIssuesFaults = true;
            });
          }
        }
        if (transferReport[Strings.lightsWorkingYes] != null) {
          if (mounted) {
            setState(() {
              lightsWorkingYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.lightsWorkingYes]);
            });
          }
        }
        if (transferReport[Strings.lightsWorkingNo] != null) {
          if (mounted) {
            setState(() {
              lightsWorkingNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.lightsWorkingNo]);
              if(lightsWorkingNo) mandatoryIssuesFaults = true;

            });
          }
        }
        if (transferReport[Strings.tyresInflatedYes] != null) {
          if (mounted) {
            setState(() {
              tyresInflatedYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.tyresInflatedYes]);
            });
          }
        }
        if (transferReport[Strings.tyresInflatedNo] != null) {
          if (mounted) {
            setState(() {
              tyresInflatedNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.tyresInflatedNo]);
              if(tyresInflatedNo) mandatoryIssuesFaults = true;
            });
          }
        }
        if (transferReport[Strings.warningSignsYes] != null) {
          if (mounted) {
            setState(() {
              warningSignsYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.warningSignsYes]);
              if(warningSignsYes) mandatoryIssuesFaults = true;

            });
          }
        }
        if (transferReport[Strings.warningSignsNo] != null) {
          if (mounted) {
            setState(() {
              warningSignsNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.warningSignsNo]);
            });
          }
        }
        if (transferReport[Strings.vehicleDamageYes] != null) {
          if (mounted) {
            setState(() {
              vehicleDamageYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.vehicleDamageYes]);
              if(vehicleDamageYes) mandatoryIssuesFaults = true;

            });
          }
        }
        if (transferReport[Strings.vehicleDamageNo] != null) {
          if (mounted) {
            setState(() {
              vehicleDamageNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.vehicleDamageNo]);
            });
          }
        }
        if (transferReport[Strings.ambulanceTidyYes2] != null) {
          if (mounted) {
            setState(() {
              ambulanceTidyYes2 = GlobalFunctions.tinyIntToBool(transferReport[Strings.ambulanceTidyYes2]);
            });
          }
        }
        if (transferReport[Strings.ambulanceTidyNo2] != null) {
          if (mounted) {
            setState(() {
              ambulanceTidyNo2 = GlobalFunctions.tinyIntToBool(transferReport[Strings.ambulanceTidyNo2]);
              if(ambulanceTidyNo2) mandatoryIssuesFaults = true;

            });
          }
        }
        if (transferReport[Strings.sanitiserCleanYes] != null) {
          if (mounted) {
            setState(() {
              sanitiserCleanYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.sanitiserCleanYes]);
            });
          }
        }
        if (transferReport[Strings.sanitiserCleanNo] != null) {
          if (mounted) {
            setState(() {
              sanitiserCleanNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.sanitiserCleanNo]);
              if(sanitiserCleanNo) mandatoryIssuesFaults = true;

            });
          }
        }




        //Normal Fields

        if (transferReport[Strings.jobRefNo] != null) {
          jobRef.text = GlobalFunctions.databaseValueString(
              transferReport[Strings.jobRefNo]);
        } else {
          jobRef.text = '';
        }

        if (transferReport[Strings.jobRefRef] != null) {

          if(jobRefDrop.contains(GlobalFunctions.databaseValueString(transferReport[Strings.jobRefRef]))){
            jobRefRef = GlobalFunctions.databaseValueString(transferReport[Strings.jobRefRef]);
          } else {
            jobRefRef = 'Select One';
          }

        }
        if (transferReport[Strings.date] != null) {
          date.text =
              dateFormat.format(DateTime.parse(transferReport[Strings.date]));
        } else {
          date.text = '';
        }

        GlobalFunctions.getTemporaryValue(transferReport, totalHours, Strings.totalHours, false);
        GlobalFunctions.getTemporaryValue(transferReport, collectionDetails, Strings.collectionDetails);
        GlobalFunctions.getTemporaryValue(transferReport, collectionPostcode, Strings.collectionPostcode);
        GlobalFunctions.getTemporaryValue(transferReport, collectionContactNo, Strings.collectionContactNo);
        GlobalFunctions.getTemporaryValue(transferReport, destinationDetails, Strings.destinationDetails);
        GlobalFunctions.getTemporaryValue(transferReport, destinationPostcode, Strings.destinationPostcode);
        GlobalFunctions.getTemporaryValue(transferReport, destinationContactNo, Strings.destinationContactNo);
        GlobalFunctions.getTemporaryValue(transferReport, vehicleRegNo, Strings.vehicleRegNo);
        GlobalFunctions.getTemporaryValue(transferReport, startMileage, Strings.startMileage);
        GlobalFunctions.getTemporaryValue(transferReport, finishMileage, Strings.finishMileage);
        GlobalFunctions.getTemporaryValue(transferReport, name1, Strings.name1);
        if (transferReport[Strings.role1] != null) {
          setState(() {
            roleCount += 1;
          });
          String decryptedRole = GlobalFunctions.decryptString(transferReport[Strings.role1]);
          bool inDrop = false;

          for(String role in roleDrop){
            if(decryptedRole == role){
              inDrop = true;
              role1 = decryptedRole;
            }
          }

          if(!inDrop){
            role1  = 'Other';
            other1.text = decryptedRole;
          }
        }
        if (transferReport[Strings.role2] != null) {
          setState(() {
            roleCount += 1;
          });
          String decryptedRole = GlobalFunctions.decryptString(transferReport[Strings.role2]);
          bool inDrop = false;

          for(String role in roleDrop){
            if(decryptedRole == role){
              inDrop = true;
              role2 = decryptedRole;
            }
          }

          if(!inDrop){
            role2  = 'Other';
            other2.text = decryptedRole;
          }
        }
        if (transferReport[Strings.role3] != null) {
          setState(() {
            roleCount += 1;
          });
          String decryptedRole = GlobalFunctions.decryptString(transferReport[Strings.role3]);
          bool inDrop = false;

          for(String role in roleDrop){
            if(decryptedRole == role){
              inDrop = true;
              role3 = decryptedRole;
            }
          }

          if(!inDrop){
            role3  = 'Other';
            other3.text = decryptedRole;
          }
        }
        if (transferReport[Strings.role4] != null) {
          setState(() {
            roleCount += 1;
          });
          String decryptedRole = GlobalFunctions.decryptString(transferReport[Strings.role4]);
          bool inDrop = false;

          for(String role in roleDrop){
            if(decryptedRole == role){
              inDrop = true;
              role4 = decryptedRole;
            }
          }

          if(!inDrop){
            role4  = 'Other';
            other4.text = decryptedRole;
          }
        }
        if (transferReport[Strings.role5] != null) {
          setState(() {
            roleCount += 1;
          });
          String decryptedRole = GlobalFunctions.decryptString(transferReport[Strings.role5]);
          bool inDrop = false;

          for(String role in roleDrop){
            if(decryptedRole == role){
              inDrop = true;
              role5 = decryptedRole;
            }
          }

          if(!inDrop){
            role5  = 'Other';
            other5.text = decryptedRole;
          }
        }
        if (transferReport[Strings.role6] != null) {
          setState(() {
            roleCount += 1;
          });
          String decryptedRole = GlobalFunctions.decryptString(transferReport[Strings.role6]);
          bool inDrop = false;

          for(String role in roleDrop){
            if(decryptedRole == role){
              inDrop = true;
              role6 = decryptedRole;
            }
          }

          if(!inDrop){
            role6  = 'Other';
            other6.text = decryptedRole;
          }
        }
        if (transferReport[Strings.role7] != null) {
          setState(() {
            roleCount += 1;
          });
          String decryptedRole = GlobalFunctions.decryptString(transferReport[Strings.role7]);
          bool inDrop = false;

          for(String role in roleDrop){
            if(decryptedRole == role){
              inDrop = true;
              role7 = decryptedRole;
            }
          }

          if(!inDrop){
            role7  = 'Other';
            other7.text = decryptedRole;
          }
        }
        if (transferReport[Strings.role8] != null) {
          setState(() {
            roleCount += 1;
          });
          String decryptedRole = GlobalFunctions.decryptString(transferReport[Strings.role8]);
          bool inDrop = false;

          for(String role in roleDrop){
            if(decryptedRole == role){
              inDrop = true;
              role8 = decryptedRole;
            }
          }

          if(!inDrop){
            role8  = 'Other';
            other8.text = decryptedRole;
          }
        }
        if (transferReport[Strings.role9] != null) {
          setState(() {
            roleCount += 1;
          });
          String decryptedRole = GlobalFunctions.decryptString(transferReport[Strings.role9]);
          bool inDrop = false;

          for(String role in roleDrop){
            if(decryptedRole == role){
              inDrop = true;
              role9 = decryptedRole;
            }
          }

          if(!inDrop){
            role9  = 'Other';
            other9.text = decryptedRole;
          }
        }
        if (transferReport[Strings.role10] != null) {
          setState(() {
            roleCount += 1;
          });
          String decryptedRole = GlobalFunctions.decryptString(transferReport[Strings.role10]);
          bool inDrop = false;

          for(String role in roleDrop){
            if(decryptedRole == role){
              inDrop = true;
              role10 = decryptedRole;
            }
          }

          if(!inDrop){
            role10  = 'Other';
            other10.text = decryptedRole;
          }
        }
        if (transferReport[Strings.role11] != null) {
          setState(() {
            roleCount += 1;
          });
          String decryptedRole = GlobalFunctions.decryptString(transferReport[Strings.role11]);
          bool inDrop = false;

          for(String role in roleDrop){
            if(decryptedRole == role){
              inDrop = true;
              role11 = decryptedRole;
            }
          }

          if(!inDrop){
            role11  = 'Other';
            other11.text = decryptedRole;
          }
        }
        setState(() {
          rowCount = roleCount;
        });
        GlobalFunctions.getTemporaryValue(transferReport, name2, Strings.name2);
        //GlobalFunctions.getTemporaryValue(transferReport, role2, Strings.role2);
        GlobalFunctions.getTemporaryValue(transferReport, name3, Strings.name3);
        //GlobalFunctions.getTemporaryValue(transferReport, role3, Strings.role3);
        GlobalFunctions.getTemporaryValue(transferReport, name4, Strings.name4);
        //GlobalFunctions.getTemporaryValue(transferReport, role4, Strings.role4);
        GlobalFunctions.getTemporaryValue(transferReport, name5, Strings.name5);
        //GlobalFunctions.getTemporaryValue(transferReport, role5, Strings.role5);
        GlobalFunctions.getTemporaryValue(transferReport, name6, Strings.name6);
        //GlobalFunctions.getTemporaryValue(transferReport, role6, Strings.role6);
        GlobalFunctions.getTemporaryValue(transferReport, name7, Strings.name7);
        //GlobalFunctions.getTemporaryValue(transferReport, role7, Strings.role7);
        GlobalFunctions.getTemporaryValue(transferReport, name8, Strings.name8);
        //GlobalFunctions.getTemporaryValue(transferReport, role8, Strings.role8);
        GlobalFunctions.getTemporaryValue(transferReport, name9, Strings.name9);
        //GlobalFunctions.getTemporaryValue(transferReport, role9, Strings.role9);
        GlobalFunctions.getTemporaryValue(transferReport, name10, Strings.name10);
        //GlobalFunctions.getTemporaryValue(transferReport, role10, Strings.role10);
        GlobalFunctions.getTemporaryValue(transferReport, name11, Strings.name11);
        //GlobalFunctions.getTemporaryValue(transferReport, role11, Strings.role11);
        GlobalFunctions.getTemporaryValue(transferReport, collectionUnit, Strings.collectionUnit);
        GlobalFunctions.getTemporaryValue(transferReport, collectionPosition, Strings.collectionPosition);
        GlobalFunctions.getTemporaryValue(transferReport, collectionPrintName, Strings.collectionPrintName);
        GlobalFunctions.getTemporaryValue(transferReport, destinationUnit, Strings.destinationUnit);
        GlobalFunctions.getTemporaryValue(transferReport, destinationPosition, Strings.destinationPosition);
        GlobalFunctions.getTemporaryValue(transferReport, destinationPrintName, Strings.destinationPrintName);
        // if(transferReport[Strings.destinationPrintName] == null){
        //   destinationPrintName.text = user.name;
        //   _databaseHelper.updateTemporaryTransferReportField(widget.edit, {
        //     Strings.destinationPrintName: GlobalFunctions.encryptString(destinationPrintName.text)
        //   }, user.uid, widget.jobId, widget.saved, widget.savedId);
        // } else {
        //   GlobalFunctions.getTemporaryValue(transferReport, destinationPrintName, Strings.destinationPrintName);
        // }
        GlobalFunctions.getTemporaryValueTime(transferReport, startTime, Strings.startTime);
        GlobalFunctions.getTemporaryValueTime(transferReport, finishTime, Strings.finishTime);
        GlobalFunctions.getTemporaryValueTime(transferReport, collectionArrivalTime, Strings.collectionArrivalTime);
        GlobalFunctions.getTemporaryValueTime(transferReport, collectionDepartureTime, Strings.collectionDepartureTime);
        GlobalFunctions.getTemporaryValueTime(transferReport, destinationArrivalTime, Strings.destinationArrivalTime);
        GlobalFunctions.getTemporaryValueTime(transferReport, destinationDepartureTime, Strings.destinationDepartureTime);
        GlobalFunctions.getTemporaryValueTime(transferReport, drivingTimes1_1, Strings.drivingTimes1_1);
        GlobalFunctions.getTemporaryValueTime(transferReport, drivingTimes1_2, Strings.drivingTimes1_2);
        GlobalFunctions.getTemporaryValueTime(transferReport, drivingTimes2_1, Strings.drivingTimes2_1);
        GlobalFunctions.getTemporaryValueTime(transferReport, drivingTimes2_2, Strings.drivingTimes2_2);
        GlobalFunctions.getTemporaryValueTime(transferReport, drivingTimes3_1, Strings.drivingTimes3_1);
        GlobalFunctions.getTemporaryValueTime(transferReport, drivingTimes3_2, Strings.drivingTimes3_2);
        GlobalFunctions.getTemporaryValueTime(transferReport, drivingTimes4_1, Strings.drivingTimes4_1);
        GlobalFunctions.getTemporaryValueTime(transferReport, drivingTimes4_2, Strings.drivingTimes4_2);
        GlobalFunctions.getTemporaryValueTime(transferReport, drivingTimes5_1, Strings.drivingTimes5_1);
        GlobalFunctions.getTemporaryValueTime(transferReport, drivingTimes5_2, Strings.drivingTimes5_2);
        GlobalFunctions.getTemporaryValueTime(transferReport, drivingTimes6_1, Strings.drivingTimes6_1);
        GlobalFunctions.getTemporaryValueTime(transferReport, drivingTimes6_2, Strings.drivingTimes6_2);
        GlobalFunctions.getTemporaryValueTime(transferReport, drivingTimes7_1, Strings.drivingTimes7_1);
        GlobalFunctions.getTemporaryValueTime(transferReport, drivingTimes7_2, Strings.drivingTimes7_2);
        GlobalFunctions.getTemporaryValueTime(transferReport, drivingTimes8_1, Strings.drivingTimes8_1);
        GlobalFunctions.getTemporaryValueTime(transferReport, drivingTimes8_2, Strings.drivingTimes8_2);
        GlobalFunctions.getTemporaryValueTime(transferReport, drivingTimes9_1, Strings.drivingTimes9_1);
        GlobalFunctions.getTemporaryValueTime(transferReport, drivingTimes9_2, Strings.drivingTimes9_2);
        GlobalFunctions.getTemporaryValueTime(transferReport, drivingTimes10_1, Strings.drivingTimes10_1);
        GlobalFunctions.getTemporaryValueTime(transferReport, drivingTimes10_2, Strings.drivingTimes10_2);
        GlobalFunctions.getTemporaryValueTime(transferReport, drivingTimes11_1, Strings.drivingTimes11_1);
        GlobalFunctions.getTemporaryValueTime(transferReport, drivingTimes11_2, Strings.drivingTimes11_2);
        GlobalFunctions.getTemporaryValueTime(transferReport, collectionArrivalTimeEnd, Strings.collectionArrivalTimeEnd);
        GlobalFunctions.getTemporaryValueTime(transferReport, destinationArrivalTimeEnd, Strings.destinationArrivalTimeEnd);

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
    if(rowCount == 6){
      GlobalFunctions.showToast('Maximum staff added');
    } else {
      setState(() {
        rowCount +=1;
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
                transferReportModel.updateTemporaryRecord(widget.edit, Strings.jobRefRef, null, widget.jobId, widget.saved, widget.savedId);
              } else {
                transferReportModel.updateTemporaryRecord(widget.edit, Strings.jobRefRef, val, widget.jobId, widget.saved, widget.savedId);
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

  Widget _buildNearestTank1Drop() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
              text: 'Fuel to the nearest 1/4 tank',
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
          color: nearestTank1 == 'Select One' ? Color(0xFF0000).withOpacity(0.3) : null,
          child: DropdownFormField(
            expanded: true,
            value: nearestTank1,
            items: nearestTankDrop.toList(),
            onChanged: (val) => setState(() {
              nearestTank1 = val;
              if(val == 'Select One'){
                transferReportModel.updateTemporaryRecord(widget.edit, Strings.nearestTank1, null, widget.jobId, widget.saved, widget.savedId);
              } else {
                transferReportModel.updateTemporaryRecord(widget.edit, Strings.nearestTank1, GlobalFunctions.encryptString(val), widget.jobId, widget.saved, widget.savedId);
              }

              FocusScope.of(context).unfocus();
            }),
            initialValue: nearestTank1,
          ),
        ),
        SizedBox(height: 15,),
      ],
    );
  }

  _getBookingFormData() async{

    String searchRef = (jobRefRef + jobRef.text).toLowerCase();

    QuerySnapshot snapshotOld = await FirebaseFirestore.instance.collection('booking_forms').where(Strings.jobRefLowercase, isEqualTo: searchRef).where(Strings.assignedUserId, isEqualTo: user.uid).orderBy('timestamp', descending: true).limit(10).get().timeout(Duration(seconds: 90));

    QuerySnapshot snapshotNew = await FirebaseFirestore.instance.collection('booking_forms').where(Strings.jobRefLowercase, isEqualTo: searchRef).where(Strings.assignedUsers, arrayContains: user.uid).orderBy('timestamp', descending: true).limit(10).get().timeout(Duration(seconds: 90));



    if(snapshotOld.docs.length > 0 || snapshotNew.docs.length > 0){

      Map<String, dynamic> localRecord = {};

      if(snapshotNew.docs.length > 0) {
        localRecord = snapshotNew.docs[0].data();
      } else {
        localRecord = snapshotOld.docs[0].data();
      }



      Map<String, dynamic> bookingForm = {

        Strings.bfJobDate: localRecord[Strings.bfJobDate] == null ? null : DateTime.fromMillisecondsSinceEpoch(localRecord[Strings.bfJobDate].millisecondsSinceEpoch).toIso8601String(),
        Strings.bfJobTime: localRecord[Strings.bfJobTime],
        Strings.bfCollectionAddress: localRecord[Strings.bfCollectionAddress],
        Strings.bfCollectionPostcode: localRecord[Strings.bfCollectionPostcode],
        Strings.bfCollectionTel: localRecord[Strings.bfCollectionTel],
        Strings.bfDestinationAddress: localRecord[Strings.bfDestinationAddress],
        Strings.bfDestinationPostcode: localRecord[Strings.bfDestinationPostcode],
        Strings.bfDestinationTel: localRecord[Strings.bfDestinationTel],
        Strings.bfAmbulanceRegistration: localRecord[Strings.bfAmbulanceRegistration],
        Strings.bfPatientName: localRecord[Strings.bfPatientName],
        Strings.bfGender: localRecord[Strings.bfGender],
        Strings.bfEthnicity: localRecord[Strings.bfEthnicity],
        Strings.bfLegalStatus: localRecord[Strings.bfLegalStatus],
        Strings.bfCurrentPresentation: localRecord[Strings.bfCurrentPresentation],
        Strings.bfDateOfBirth: localRecord[Strings.bfDateOfBirth],
        Strings.bfGenderConcernsYes: localRecord[Strings.bfGenderConcernsYes],
        Strings.bfGenderConcernsNo: localRecord[Strings.bfGenderConcernsNo],
        Strings.bfGenderConcerns: localRecord[Strings.bfGenderConcerns],
        Strings.bfSafeguardingConcernsYes: localRecord[Strings.bfSafeguardingConcernsYes],
        Strings.bfSafeguardingConcernsNo: localRecord[Strings.bfSafeguardingConcernsNo],
        Strings.bfSafeguardingConcerns: localRecord[Strings.bfSafeguardingConcerns],
        Strings.bfRmn1: localRecord[Strings.bfRmn1],
        Strings.bfHca1: localRecord[Strings.bfHca1],
        Strings.bfHca2: localRecord[Strings.bfHca2],
        Strings.bfHca3: localRecord[Strings.bfHca3],
        Strings.bfHca4: localRecord[Strings.bfHca4],
        Strings.bfHca5: localRecord[Strings.bfHca5],



      };

      setState(() {
        date.text = dateFormat.format(DateTime.parse(bookingForm[Strings.bfJobDate]));
        startTime.text = timeFormat.format(DateTime.parse(bookingForm[Strings.bfJobTime]));
        collectionDetails.text = GlobalFunctions.decryptString(bookingForm[Strings.bfCollectionAddress]);
        collectionPostcode.text = GlobalFunctions.decryptString(bookingForm[Strings.bfCollectionPostcode]);
        collectionContactNo.text = GlobalFunctions.decryptString(bookingForm[Strings.bfCollectionTel]);
        destinationDetails.text = GlobalFunctions.decryptString(bookingForm[Strings.bfDestinationAddress]);
        destinationPostcode.text = GlobalFunctions.decryptString(bookingForm[Strings.bfDestinationPostcode]);
        destinationContactNo.text = GlobalFunctions.decryptString(bookingForm[Strings.bfDestinationTel]);
        vehicleRegNo.text = GlobalFunctions.decryptString(bookingForm[Strings.bfAmbulanceRegistration]);
        ambulanceReg.text = GlobalFunctions.decryptString(bookingForm[Strings.bfAmbulanceRegistration]);
        int rows = 1;
        if(bookingForm[Strings.bfRmn1] != ''){
          role1 = 'RMN';
          name1.text = GlobalFunctions.decryptString(bookingForm[Strings.bfRmn1]);

          if(bookingForm[Strings.bfHca1] != ''){
            rows ++;
            role2 = 'HCA';
            name2.text = GlobalFunctions.decryptString(bookingForm[Strings.bfHca1]);
          }
          if(bookingForm[Strings.bfHca2] != ''){
            rows ++;
            role3 = 'HCA';
            name3.text = GlobalFunctions.decryptString(bookingForm[Strings.bfHca2]);
          }
          if(bookingForm[Strings.bfHca3] != ''){
            rows ++;
            role4 = 'HCA';
            name4.text = GlobalFunctions.decryptString(bookingForm[Strings.bfHca3]);
          }
          if(bookingForm[Strings.bfHca4] != ''){
            rows ++;
            role5 = 'HCA';
            name5.text = GlobalFunctions.decryptString(bookingForm[Strings.bfHca4]);
          }
          if(bookingForm[Strings.bfHca5] != ''){
            rows ++;
            role6 = 'HCA';
            name6.text = GlobalFunctions.decryptString(bookingForm[Strings.bfHca5]);
          }
          } else {

          if(bookingForm[Strings.bfHca1] != ''){
            role1 = 'HCA';
            name1.text = GlobalFunctions.decryptString(bookingForm[Strings.bfHca1]);
          }
          if(bookingForm[Strings.bfHca2] != ''){
            rows ++;
            role2 = 'HCA';
            name2.text = GlobalFunctions.decryptString(bookingForm[Strings.bfHca2]);
          }
          if(bookingForm[Strings.bfHca3] != ''){
            rows ++;
            role3 = 'HCA';
            name3.text = GlobalFunctions.decryptString(bookingForm[Strings.bfHca3]);
          }
          if(bookingForm[Strings.bfHca4] != ''){
            rows ++;
            role4 = 'HCA';
            name4.text = GlobalFunctions.decryptString(bookingForm[Strings.bfHca4]);
          }
          if(bookingForm[Strings.bfHca5] != ''){
            rows ++;
            role5 = 'HCA';
            name5.text = GlobalFunctions.decryptString(bookingForm[Strings.bfHca5]);
          }
        }
        rowCount = rows;

      });


      transferReportModel.updateTemporaryRecord(widget.edit, Strings.date, DateTime.fromMillisecondsSinceEpoch(localRecord[Strings.bfJobDate].millisecondsSinceEpoch).toIso8601String(), widget.jobId, widget.saved, widget.savedId);
      // _databaseHelper.updateTemporaryTransferReportField(widget.edit,
      //     {Strings.date : DateTime.fromMillisecondsSinceEpoch(localRecord[Strings.bfJobDate].millisecondsSinceEpoch).toIso8601String()}, user.uid, widget.jobId, widget.saved, widget.savedId);

      transferReportModel.updateTemporaryRecord(widget.edit, Strings.startTime, bookingForm[Strings.bfJobTime], widget.jobId, widget.saved, widget.savedId);
      // _databaseHelper.updateTemporaryTransferReportField(widget.edit,
      //     {Strings.startTime : bookingForm[Strings.bfJobTime]}, user.uid, widget.jobId, widget.saved, widget.savedId);

      transferReportModel.updateTemporaryRecord(widget.edit, Strings.collectionDetails, bookingForm[Strings.bfCollectionAddress], widget.jobId, widget.saved, widget.savedId);
      // _databaseHelper.updateTemporaryTransferReportField(widget.edit,
      //     {Strings.collectionDetails : bookingForm[Strings.bfCollectionAddress]}, user.uid, widget.jobId, widget.saved, widget.savedId);

      transferReportModel.updateTemporaryRecord(widget.edit, Strings.collectionPostcode, bookingForm[Strings.bfCollectionPostcode], widget.jobId, widget.saved, widget.savedId);
      // _databaseHelper.updateTemporaryTransferReportField(widget.edit,
      //     {Strings.collectionPostcode : bookingForm[Strings.bfCollectionPostcode]}, user.uid, widget.jobId, widget.saved, widget.savedId);

      transferReportModel.updateTemporaryRecord(widget.edit, Strings.collectionContactNo, bookingForm[Strings.bfCollectionTel], widget.jobId, widget.saved, widget.savedId);
      // _databaseHelper.updateTemporaryTransferReportField(widget.edit,
      //     {Strings.collectionContactNo : bookingForm[Strings.bfCollectionTel]}, user.uid, widget.jobId, widget.saved, widget.savedId);

      transferReportModel.updateTemporaryRecord(widget.edit, Strings.destinationDetails, bookingForm[Strings.bfDestinationAddress], widget.jobId, widget.saved, widget.savedId);
      // _databaseHelper.updateTemporaryTransferReportField(widget.edit,
      //     {Strings.destinationDetails : bookingForm[Strings.bfDestinationAddress]}, user.uid, widget.jobId, widget.saved, widget.savedId);

      transferReportModel.updateTemporaryRecord(widget.edit, Strings.destinationPostcode, bookingForm[Strings.bfDestinationPostcode], widget.jobId, widget.saved, widget.savedId);
      // _databaseHelper.updateTemporaryTransferReportField(widget.edit,
      //     {Strings.destinationPostcode : bookingForm[Strings.bfDestinationPostcode]}, user.uid, widget.jobId, widget.saved, widget.savedId);

      transferReportModel.updateTemporaryRecord(widget.edit, Strings.destinationContactNo, bookingForm[Strings.bfDestinationTel], widget.jobId, widget.saved, widget.savedId);
      // _databaseHelper.updateTemporaryTransferReportField(widget.edit,
      //     {Strings.destinationContactNo : bookingForm[Strings.bfDestinationTel]}, user.uid, widget.jobId, widget.saved, widget.savedId);

      transferReportModel.updateTemporaryRecord(widget.edit, Strings.vehicleRegNo, bookingForm[Strings.bfAmbulanceRegistration], widget.jobId, widget.saved, widget.savedId);
      // _databaseHelper.updateTemporaryTransferReportField(widget.edit,
      //     {Strings.vehicleRegNo : bookingForm[Strings.bfAmbulanceRegistration]}, user.uid, widget.jobId, widget.saved, widget.savedId);

      transferReportModel.updateTemporaryRecord(widget.edit, Strings.ambulanceReg, bookingForm[Strings.bfAmbulanceRegistration], widget.jobId, widget.saved, widget.savedId);
      // _databaseHelper.updateTemporaryTransferReportField(widget.edit,
      //     {Strings.ambulanceReg : bookingForm[Strings.bfAmbulanceRegistration]}, user.uid, widget.jobId, widget.saved, widget.savedId);



      if(bookingForm[Strings.bfRmn1] != ''){

        transferReportModel.updateTemporaryRecord(widget.edit, Strings.role1, GlobalFunctions.encryptString('RMN'), widget.jobId, widget.saved, widget.savedId);
        transferReportModel.updateTemporaryRecord(widget.edit, Strings.name1, bookingForm[Strings.bfRmn1], widget.jobId, widget.saved, widget.savedId);

        if(bookingForm[Strings.bfHca1] != ''){

          transferReportModel.updateTemporaryRecord(widget.edit, Strings.role2, GlobalFunctions.encryptString('HCA'), widget.jobId, widget.saved, widget.savedId);
          transferReportModel.updateTemporaryRecord(widget.edit, Strings.name2, bookingForm[Strings.bfHca1], widget.jobId, widget.saved, widget.savedId);
        }
        if(bookingForm[Strings.bfHca2] != ''){

          transferReportModel.updateTemporaryRecord(widget.edit, Strings.role3, GlobalFunctions.encryptString('HCA'), widget.jobId, widget.saved, widget.savedId);
          transferReportModel.updateTemporaryRecord(widget.edit, Strings.name3, bookingForm[Strings.bfHca2], widget.jobId, widget.saved, widget.savedId);
        }
        if(bookingForm[Strings.bfHca3] != ''){

          transferReportModel.updateTemporaryRecord(widget.edit, Strings.role4, GlobalFunctions.encryptString('HCA'), widget.jobId, widget.saved, widget.savedId);
          transferReportModel.updateTemporaryRecord(widget.edit, Strings.name4, bookingForm[Strings.bfHca3], widget.jobId, widget.saved, widget.savedId);
        }
        if(bookingForm[Strings.bfHca4] != ''){

          transferReportModel.updateTemporaryRecord(widget.edit, Strings.role5, GlobalFunctions.encryptString('HCA'), widget.jobId, widget.saved, widget.savedId);
          transferReportModel.updateTemporaryRecord(widget.edit, Strings.name5, bookingForm[Strings.bfHca4], widget.jobId, widget.saved, widget.savedId);
        }
        if(bookingForm[Strings.bfHca5] != ''){
          transferReportModel.updateTemporaryRecord(widget.edit, Strings.role6, GlobalFunctions.encryptString('HCA'), widget.jobId, widget.saved, widget.savedId);
          transferReportModel.updateTemporaryRecord(widget.edit, Strings.name6, bookingForm[Strings.bfHca5], widget.jobId, widget.saved, widget.savedId);
        }
      } else {

        if(bookingForm[Strings.bfHca1] != ''){

          transferReportModel.updateTemporaryRecord(widget.edit, Strings.role1, GlobalFunctions.encryptString('HCA'), widget.jobId, widget.saved, widget.savedId);
          transferReportModel.updateTemporaryRecord(widget.edit, Strings.name1, bookingForm[Strings.bfHca1], widget.jobId, widget.saved, widget.savedId);
        }
        if(bookingForm[Strings.bfHca2] != ''){

          transferReportModel.updateTemporaryRecord(widget.edit, Strings.role2, GlobalFunctions.encryptString('HCA'), widget.jobId, widget.saved, widget.savedId);
          transferReportModel.updateTemporaryRecord(widget.edit, Strings.name2, bookingForm[Strings.bfHca2], widget.jobId, widget.saved, widget.savedId);
        }
        if(bookingForm[Strings.bfHca3] != ''){

          transferReportModel.updateTemporaryRecord(widget.edit, Strings.role3, GlobalFunctions.encryptString('HCA'), widget.jobId, widget.saved, widget.savedId);
          transferReportModel.updateTemporaryRecord(widget.edit, Strings.name3, bookingForm[Strings.bfHca3], widget.jobId, widget.saved, widget.savedId);
        }
        if(bookingForm[Strings.bfHca4] != ''){

          transferReportModel.updateTemporaryRecord(widget.edit, Strings.role4, GlobalFunctions.encryptString('HCA'), widget.jobId, widget.saved, widget.savedId);
          transferReportModel.updateTemporaryRecord(widget.edit, Strings.name4, bookingForm[Strings.bfHca4], widget.jobId, widget.saved, widget.savedId);
        }
        if(bookingForm[Strings.bfHca5] != ''){
          transferReportModel.updateTemporaryRecord(widget.edit, Strings.role5, GlobalFunctions.encryptString('HCA'), widget.jobId, widget.saved, widget.savedId);
          transferReportModel.updateTemporaryRecord(widget.edit, Strings.name5, bookingForm[Strings.bfHca5], widget.jobId, widget.saved, widget.savedId);
        }
      }


      transferReportModel.updateTemporaryRecord(widget.edit, Strings.patientName, bookingForm[Strings.bfPatientName], widget.jobId, widget.saved, widget.savedId);
      // _databaseHelper.updateTemporaryTransferReportField(widget.edit,
      //     {Strings.patientName : bookingForm[Strings.bfPatientName]}, user.uid, widget.jobId, widget.saved, widget.savedId);

      transferReportModel.updateTemporaryRecord(widget.edit, Strings.gender, bookingForm[Strings.bfGender], widget.jobId, widget.saved, widget.savedId);
      // _databaseHelper.updateTemporaryTransferReportField(widget.edit,
      //     {Strings.gender : bookingForm[Strings.bfGender]}, user.uid, widget.jobId, widget.saved, widget.savedId);

      transferReportModel.updateTemporaryRecord(widget.edit, Strings.ethnicity, bookingForm[Strings.bfEthnicity], widget.jobId, widget.saved, widget.savedId);
      // _databaseHelper.updateTemporaryTransferReportField(widget.edit,
      //     {Strings.ethnicity : bookingForm[Strings.bfEthnicity]}, user.uid, widget.jobId, widget.saved, widget.savedId);

      transferReportModel.updateTemporaryRecord(widget.edit, Strings.mhaMcaDetails, bookingForm[Strings.bfLegalStatus], widget.jobId, widget.saved, widget.savedId);
      // _databaseHelper.updateTemporaryTransferReportField(widget.edit,
      //     {Strings.mhaMcaDetails : bookingForm[Strings.bfLegalStatus]}, user.uid, widget.jobId, widget.saved, widget.savedId);

      transferReportModel.updateTemporaryRecord(widget.edit, Strings.currentPresentation, bookingForm[Strings.bfCurrentPresentation], widget.jobId, widget.saved, widget.savedId);
      // _databaseHelper.updateTemporaryTransferReportField(widget.edit,
      //     {Strings.currentPresentation : bookingForm[Strings.bfCurrentPresentation]}, user.uid, widget.jobId, widget.saved, widget.savedId);


      transferReportModel.updateTemporaryRecord(widget.edit, Strings.dateOfBirth, bookingForm[Strings.bfDateOfBirth], widget.jobId, widget.saved, widget.savedId);
      // _databaseHelper.updateTemporaryTransferReportField(widget.edit,
      //     {Strings.dateOfBirth : bookingForm[Strings.bfDateOfBirth]}, user.uid, widget.jobId, widget.saved, widget.savedId);


      transferReportModel.updateTemporaryRecord(widget.edit, Strings.racialGenderConcernsYes, bookingForm[Strings.bfGenderConcernsYes], widget.jobId, widget.saved, widget.savedId);
      // _databaseHelper.updateTemporaryTransferReportField(widget.edit,
      //     {Strings.racialGenderConcernsYes : bookingForm[Strings.bfGenderConcernsYes]}, user.uid, widget.jobId, widget.saved, widget.savedId);

      transferReportModel.updateTemporaryRecord(widget.edit, Strings.racialGenderConcernsNo, bookingForm[Strings.bfGenderConcernsNo], widget.jobId, widget.saved, widget.savedId);
      // _databaseHelper.updateTemporaryTransferReportField(widget.edit,
      //     {Strings.racialGenderConcernsNo : bookingForm[Strings.bfGenderConcernsNo]}, user.uid, widget.jobId, widget.saved, widget.savedId);

      transferReportModel.updateTemporaryRecord(widget.edit, Strings.racialGenderConcerns, bookingForm[Strings.bfGenderConcerns], widget.jobId, widget.saved, widget.savedId);
      // _databaseHelper.updateTemporaryTransferReportField(widget.edit,
      //     {Strings.racialGenderConcerns : bookingForm[Strings.bfGenderConcerns]}, user.uid, widget.jobId, widget.saved, widget.savedId);

      transferReportModel.updateTemporaryRecord(widget.edit, Strings.safeguardingYes, bookingForm[Strings.bfSafeguardingConcernsYes], widget.jobId, widget.saved, widget.savedId);
      // _databaseHelper.updateTemporaryTransferReportField(widget.edit,
      //     {Strings.safeguardingYes : bookingForm[Strings.bfSafeguardingConcernsYes]}, user.uid, widget.jobId, widget.saved, widget.savedId);

      transferReportModel.updateTemporaryRecord(widget.edit, Strings.safeguardingNo, bookingForm[Strings.bfSafeguardingConcernsNo], widget.jobId, widget.saved, widget.savedId);
      // _databaseHelper.updateTemporaryTransferReportField(widget.edit,
      //     {Strings.safeguardingNo : bookingForm[Strings.bfSafeguardingConcernsNo]}, user.uid, widget.jobId, widget.saved, widget.savedId);

      transferReportModel.updateTemporaryRecord(widget.edit, Strings.safeguarding, bookingForm[Strings.bfSafeguardingConcerns], widget.jobId, widget.saved, widget.savedId);
      // _databaseHelper.updateTemporaryTransferReportField(widget.edit,
      //     {Strings.safeguarding : bookingForm[Strings.bfSafeguardingConcerns]}, user.uid, widget.jobId, widget.saved, widget.savedId);

    } else {
      GlobalFunctions.showToast('No results found');
    }

  }

  Widget _buildCheckboxRowAmbulanceTidyYes1(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: text,
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
        ),        Container(
          color: ambulanceTidyYes1 == false && ambulanceTidyNo1 == false ? Color(0xFF0000).withOpacity(0.3) : null,

          child: Row(
            children: <Widget>[
              Text(
                'Yes',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: ambulanceTidyYes1,
                  onChanged: (bool value) => setState(() {
                    ambulanceTidyYes1 = value;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.ambulanceTidyYes1, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                    if (ambulanceTidyNo1 == true){
                      ambulanceTidyNo1 = false;
                      transferReportModel.updateTemporaryRecord(widget.edit, Strings.ambulanceTidyNo1, null, widget.jobId, widget.saved, widget.savedId);
                    }

                    if(
                    (ambulanceTidyNo1 == null || ambulanceTidyNo1 == false) &&
                        (lightsWorkingNo == null || lightsWorkingNo == false) &&
                        (tyresInflatedNo == null || tyresInflatedNo == false) &&
                        (warningSignsYes == null || warningSignsYes == false) &&
                        (vehicleDamageYes == null || vehicleDamageYes == false) &&
                        (ambulanceTidyNo2 == null || ambulanceTidyNo2 == false) &&
                        (sanitiserCleanNo == null || sanitiserCleanNo == false)
                    ) {
                      mandatoryIssuesFaults = false;
                    }
                  })),
              Text(
                'No',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: ambulanceTidyNo1,
                  onChanged: (bool value) => setState(() {
                    ambulanceTidyNo1 = value;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.ambulanceTidyNo1, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                    if (ambulanceTidyYes1 == true){
                      ambulanceTidyYes1 = false;
                      transferReportModel.updateTemporaryRecord(widget.edit, Strings.ambulanceTidyYes1, null, widget.jobId, widget.saved, widget.savedId);
                    }

                    if(ambulanceTidyNo1 == true){
                      mandatoryIssuesFaults = true;
                      if(issuesFaults.text.isEmpty) showIssuesDialog();
                    } else if(
                    (ambulanceTidyNo1 == null || ambulanceTidyNo1 == false) &&
                        (lightsWorkingNo == null || lightsWorkingNo == false) &&
                        (tyresInflatedNo == null || tyresInflatedNo == false) &&
                        (warningSignsYes == null || warningSignsYes == false) &&
                        (vehicleDamageYes == null || vehicleDamageYes == false) &&
                        (ambulanceTidyNo2 == null || ambulanceTidyNo2 == false) &&
                        (sanitiserCleanNo == null || sanitiserCleanNo == false)
                    ) {
                      mandatoryIssuesFaults = false;
                    }


                  }))
            ],
          ),
        )
      ],
    );
  }
  Widget _buildCheckboxRowLightsWorkingYes(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: text,
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
        ),        Container(
          color: lightsWorkingYes == false && lightsWorkingNo == false ? Color(0xFF0000).withOpacity(0.3) : null,

          child: Row(
            children: <Widget>[
              Text(
                'Yes',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: lightsWorkingYes,
                  onChanged: (bool value) => setState(() {
                    lightsWorkingYes = value;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.lightsWorkingYes, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                    if (lightsWorkingNo == true){
                      lightsWorkingNo = false;
                      transferReportModel.updateTemporaryRecord(widget.edit, Strings.lightsWorkingNo, null, widget.jobId, widget.saved, widget.savedId);
                    }

                    if(
                    (ambulanceTidyNo1 == null || ambulanceTidyNo1 == false) &&
                        (lightsWorkingNo == null || lightsWorkingNo == false) &&
                        (tyresInflatedNo == null || tyresInflatedNo == false) &&
                        (warningSignsYes == null || warningSignsYes == false) &&
                        (vehicleDamageYes == null || vehicleDamageYes == false) &&
                        (ambulanceTidyNo2 == null || ambulanceTidyNo2 == false) &&
                        (sanitiserCleanNo == null || sanitiserCleanNo == false)
                    ) {
                      mandatoryIssuesFaults = false;
                    }
                  })),
              Text(
                'No',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: lightsWorkingNo,
                  onChanged: (bool value) => setState(() {
                    lightsWorkingNo = value;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.lightsWorkingNo, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                    if (lightsWorkingYes == true){
                      lightsWorkingYes = false;
                      transferReportModel.updateTemporaryRecord(widget.edit, Strings.lightsWorkingYes, null, widget.jobId, widget.saved, widget.savedId);
                    }

                    if(lightsWorkingNo == true){
                      mandatoryIssuesFaults = true;
                      if(issuesFaults.text.isEmpty) showIssuesDialog();

                    } else if(
                    (ambulanceTidyNo1 == null || ambulanceTidyNo1 == false) &&
                        (lightsWorkingNo == null || lightsWorkingNo == false) &&
                        (tyresInflatedNo == null || tyresInflatedNo == false) &&
                        (warningSignsYes == null || warningSignsYes == false) &&
                        (vehicleDamageYes == null || vehicleDamageYes == false) &&
                        (ambulanceTidyNo2 == null || ambulanceTidyNo2 == false) &&
                        (sanitiserCleanNo == null || sanitiserCleanNo == false)
                    ) {
                      mandatoryIssuesFaults = false;
                    }
                  }))
            ],
          ),
        )
      ],
    );
  }
  Widget _buildCheckboxRowTyresInflatedYes(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: text,
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
        ),        Container(
          color: tyresInflatedYes == false && tyresInflatedNo == false ? Color(0xFF0000).withOpacity(0.3) : null,

          child: Row(
            children: <Widget>[
              Text(
                'Yes',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: tyresInflatedYes,
                  onChanged: (bool value) => setState(() {
                    tyresInflatedYes = value;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.tyresInflatedYes, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                    if (tyresInflatedNo == true){
                      tyresInflatedNo = false;
                      transferReportModel.updateTemporaryRecord(widget.edit, Strings.tyresInflatedNo, null, widget.jobId, widget.saved, widget.savedId);
                    }

                    if(
                    (ambulanceTidyNo1 == null || ambulanceTidyNo1 == false) &&
                        (lightsWorkingNo == null || lightsWorkingNo == false) &&
                        (tyresInflatedNo == null || tyresInflatedNo == false) &&
                        (warningSignsYes == null || warningSignsYes == false) &&
                        (vehicleDamageYes == null || vehicleDamageYes == false) &&
                        (ambulanceTidyNo2 == null || ambulanceTidyNo2 == false) &&
                        (sanitiserCleanNo == null || sanitiserCleanNo == false)
                    ) {
                      mandatoryIssuesFaults = false;
                    }


                  })),
              Text(
                'No',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: tyresInflatedNo,
                  onChanged: (bool value) => setState(() {
                    tyresInflatedNo = value;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.tyresInflatedNo, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                    if (tyresInflatedYes == true){
                      tyresInflatedYes = false;
                      transferReportModel.updateTemporaryRecord(widget.edit, Strings.tyresInflatedYes, null, widget.jobId, widget.saved, widget.savedId);
                    }

                    if(tyresInflatedNo == true){
                      mandatoryIssuesFaults = true;
                      if(issuesFaults.text.isEmpty) showIssuesDialog();

                    } else if(
                    (ambulanceTidyNo1 == null || ambulanceTidyNo1 == false) &&
                        (lightsWorkingNo == null || lightsWorkingNo == false) &&
                        (tyresInflatedNo == null || tyresInflatedNo == false) &&
                        (warningSignsYes == null || warningSignsYes == false) &&
                        (vehicleDamageYes == null || vehicleDamageYes == false) &&
                        (ambulanceTidyNo2 == null || ambulanceTidyNo2 == false) &&
                        (sanitiserCleanNo == null || sanitiserCleanNo == false)
                    ) {
                      mandatoryIssuesFaults = false;
                    }
                  }))
            ],
          ),
        )
      ],
    );
  }
  Widget _buildCheckboxRowWarningSignsYes(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: text,
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
        ),        Container(
          color: warningSignsYes == false && warningSignsNo == false ? Color(0xFF0000).withOpacity(0.3) : null,

          child: Row(
            children: <Widget>[
              Text(
                'Yes',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: warningSignsYes,
                  onChanged: (bool value) => setState(() {
                    warningSignsYes = value;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.warningSignsYes, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                    if (warningSignsNo == true){
                      warningSignsNo = false;
                      transferReportModel.updateTemporaryRecord(widget.edit, Strings.warningSignsNo, null, widget.jobId, widget.saved, widget.savedId);
                    }

                    if(warningSignsYes == true){
                      mandatoryIssuesFaults = true;
                      if(issuesFaults.text.isEmpty) showIssuesDialog();

                    } else if(
                    (ambulanceTidyNo1 == null || ambulanceTidyNo1 == false) &&
                        (lightsWorkingNo == null || lightsWorkingNo == false) &&
                        (tyresInflatedNo == null || tyresInflatedNo == false) &&
                        (warningSignsYes == null || warningSignsYes == false) &&
                        (vehicleDamageYes == null || vehicleDamageYes == false) &&
                        (ambulanceTidyNo2 == null || ambulanceTidyNo2 == false) &&
                        (sanitiserCleanNo == null || sanitiserCleanNo == false)
                    ) {
                      mandatoryIssuesFaults = false;
                    }
                  })),
              Text(
                'No',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: warningSignsNo,
                  onChanged: (bool value) => setState(() {
                    warningSignsNo = value;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.warningSignsNo, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                    if (warningSignsYes == true){
                      warningSignsYes = false;
                      transferReportModel.updateTemporaryRecord(widget.edit, Strings.warningSignsYes, null, widget.jobId, widget.saved, widget.savedId);
                    }

                    if(
                    (ambulanceTidyNo1 == null || ambulanceTidyNo1 == false) &&
                        (lightsWorkingNo == null || lightsWorkingNo == false) &&
                        (tyresInflatedNo == null || tyresInflatedNo == false) &&
                        (warningSignsYes == null || warningSignsYes == false) &&
                        (vehicleDamageYes == null || vehicleDamageYes == false) &&
                        (ambulanceTidyNo2 == null || ambulanceTidyNo2 == false) &&
                        (sanitiserCleanNo == null || sanitiserCleanNo == false)
                    ) {
                      mandatoryIssuesFaults = false;
                    }
                  }))
            ],
          ),
        )
      ],
    );
  }
  Widget _buildCheckboxRowVehicleDamageYes(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: text,
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
        ),        Container(
          color: vehicleDamageYes == false && vehicleDamageNo == false ? Color(0xFF0000).withOpacity(0.3) : null,

          child: Row(
            children: <Widget>[
              Text(
                'Yes',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: vehicleDamageYes,
                  onChanged: (bool value) => setState(() {
                    vehicleDamageYes = value;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.vehicleDamageYes, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                    if (vehicleDamageNo == true){
                      vehicleDamageNo = false;
                      transferReportModel.updateTemporaryRecord(widget.edit, Strings.vehicleDamageNo, null, widget.jobId, widget.saved, widget.savedId);
                    }

                    if(vehicleDamageYes == true){
                      mandatoryIssuesFaults = true;
                      if(issuesFaults.text.isEmpty) showIssuesDialog();

                    } else if(
                    (ambulanceTidyNo1 == null || ambulanceTidyNo1 == false) &&
                        (lightsWorkingNo == null || lightsWorkingNo == false) &&
                        (tyresInflatedNo == null || tyresInflatedNo == false) &&
                        (warningSignsYes == null || warningSignsYes == false) &&
                        (vehicleDamageYes == null || vehicleDamageYes == false) &&
                        (ambulanceTidyNo2 == null || ambulanceTidyNo2 == false) &&
                        (sanitiserCleanNo == null || sanitiserCleanNo == false)
                    ) {
                      mandatoryIssuesFaults = false;
                    }
                  })),
              Text(
                'No',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: vehicleDamageNo,
                  onChanged: (bool value) => setState(() {
                    vehicleDamageNo = value;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.vehicleDamageNo, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                    if (vehicleDamageYes == true){
                      vehicleDamageYes = false;
                      transferReportModel.updateTemporaryRecord(widget.edit, Strings.vehicleDamageYes, null, widget.jobId, widget.saved, widget.savedId);
                    }

                    if(
                    (ambulanceTidyNo1 == null || ambulanceTidyNo1 == false) &&
                        (lightsWorkingNo == null || lightsWorkingNo == false) &&
                        (tyresInflatedNo == null || tyresInflatedNo == false) &&
                        (warningSignsNo == null || warningSignsNo == false) &&
                        (vehicleDamageYes == null || vehicleDamageYes == false) &&
                        (ambulanceTidyNo2 == null || ambulanceTidyNo2 == false) &&
                        (sanitiserCleanNo == null || sanitiserCleanNo == false)
                    ) {
                      mandatoryIssuesFaults = false;
                    }
                  }))
            ],
          ),
        )
      ],
    );
  }
  Widget _buildCheckboxRowAmbulanceTidyYes2(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: text,
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
          color: ambulanceTidyYes2 == false && ambulanceTidyNo2 == false ? Color(0xFF0000).withOpacity(0.3) : null,
          child: Row(
            children: <Widget>[
              Text(
                'Yes',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: ambulanceTidyYes2,
                  onChanged: (bool value) => setState(() {
                    ambulanceTidyYes2 = value;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.ambulanceTidyYes2, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                    if (ambulanceTidyNo2 == true){
                      ambulanceTidyNo2 = false;
                      transferReportModel.updateTemporaryRecord(widget.edit, Strings.ambulanceTidyNo2, null, widget.jobId, widget.saved, widget.savedId);
                    }

                    if(
                    (ambulanceTidyNo1 == null || ambulanceTidyNo1 == false) &&
                        (lightsWorkingNo == null || lightsWorkingNo == false) &&
                        (tyresInflatedNo == null || tyresInflatedNo == false) &&
                        (warningSignsYes == null || warningSignsYes == false) &&
                        (vehicleDamageYes == null || vehicleDamageYes == false) &&
                        (ambulanceTidyNo2 == null || ambulanceTidyNo2 == false) &&
                        (sanitiserCleanNo == null || sanitiserCleanNo == false)
                    ) {
                      mandatoryIssuesFaults = false;
                    }
                  })),
              Text(
                'No',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: ambulanceTidyNo2,
                  onChanged: (bool value) => setState(() {
                    ambulanceTidyNo2 = value;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.ambulanceTidyNo2, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                    if (ambulanceTidyYes2 == true){
                      ambulanceTidyYes2 = false;
                      transferReportModel.updateTemporaryRecord(widget.edit, Strings.ambulanceTidyYes2, null, widget.jobId, widget.saved, widget.savedId);
                    }

                    if(ambulanceTidyNo2 == true){
                      mandatoryIssuesFaults = true;
                      if(issuesFaults.text.isEmpty) showIssuesDialog();

                    } else if(
                    (ambulanceTidyNo1 == null || ambulanceTidyNo1 == false) &&
                        (lightsWorkingNo == null || lightsWorkingNo == false) &&
                        (tyresInflatedNo == null || tyresInflatedNo == false) &&
                        (warningSignsYes == null || warningSignsYes == false) &&
                        (vehicleDamageYes == null || vehicleDamageYes == false) &&
                        (ambulanceTidyNo2 == null || ambulanceTidyNo2 == false) &&
                        (sanitiserCleanNo == null || sanitiserCleanNo == false)
                    ) {
                      mandatoryIssuesFaults = false;
                    }
                  }))
            ],
          ),
        )
      ],
    );
  }
  Widget _buildCheckboxRowSanitiserCleanYes(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: text,
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
          color: sanitiserCleanYes == false && sanitiserCleanNo == false ? Color(0xFF0000).withOpacity(0.3) : null,
          child: Row(
            children: <Widget>[
              Text(
                'Yes',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: sanitiserCleanYes,
                  onChanged: (bool value) => setState(() {
                    sanitiserCleanYes = value;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.sanitiserCleanYes, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                    if (sanitiserCleanNo == true){
                      sanitiserCleanNo = false;
                      transferReportModel.updateTemporaryRecord(widget.edit, Strings.sanitiserCleanNo, null, widget.jobId, widget.saved, widget.savedId);
                    }

                    if(
                    (ambulanceTidyNo1 == null || ambulanceTidyNo1 == false) &&
                        (lightsWorkingNo == null || lightsWorkingNo == false) &&
                        (tyresInflatedNo == null || tyresInflatedNo == false) &&
                        (warningSignsYes == null || warningSignsYes == false) &&
                        (vehicleDamageYes == null || vehicleDamageYes == false) &&
                        (ambulanceTidyNo2 == null || ambulanceTidyNo2 == false) &&
                        (sanitiserCleanNo == null || sanitiserCleanNo == false)
                    ) {
                      mandatoryIssuesFaults = false;
                    }
                  })),
              Text(
                'No',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: sanitiserCleanNo,
                  onChanged: (bool value) => setState(() {
                    sanitiserCleanNo = value;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.sanitiserCleanNo, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                    if (sanitiserCleanYes == true){
                      sanitiserCleanYes = false;
                      transferReportModel.updateTemporaryRecord(widget.edit, Strings.sanitiserCleanYes, null, widget.jobId, widget.saved, widget.savedId);
                    }

                    if(sanitiserCleanNo == true){
                      mandatoryIssuesFaults = true;
                      if(issuesFaults.text.isEmpty) showIssuesDialog();

                    } else if(
                    (ambulanceTidyNo1 == null || ambulanceTidyNo1 == false) &&
                        (lightsWorkingNo == null || lightsWorkingNo == false) &&
                        (tyresInflatedNo == null || tyresInflatedNo == false) &&
                        (warningSignsYes == null || warningSignsYes == false) &&
                        (vehicleDamageYes == null || vehicleDamageYes == false) &&
                        (ambulanceTidyNo2 == null || ambulanceTidyNo2 == false) &&
                        (sanitiserCleanNo == null || sanitiserCleanNo == false)
                    ) {
                      mandatoryIssuesFaults = false;
                    }
                  }))
            ],
          ),
        )
      ],
    );
  }


  Widget _buildRoleDrop1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Role', style: TextStyle(
            fontSize: 16.0, color: bluePurple),),
        DropdownFormField(
          expanded: true,
          value: role1,
          items: roleDrop.toList(),
          onChanged: (val) => setState(() {
            role1 = val;
            if(val == 'Select One'){
              transferReportModel.updateTemporaryRecord(widget.edit, Strings.role1, null, widget.jobId, widget.saved, widget.savedId);
            } else {
              transferReportModel.updateTemporaryRecord(widget.edit, Strings.role1, GlobalFunctions.encryptString(val), widget.jobId, widget.saved, widget.savedId);
            }
            FocusScope.of(context).unfocus();
          }),
          initialValue: role1,
        ),
        SizedBox(height: 15,),
      ],
    );
  }

  Widget _buildRoleDrop2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Role', style: TextStyle(
            fontSize: 16.0, color: bluePurple),),
        DropdownFormField(
          expanded: true,
          value: role2,
          items: roleDrop.toList(),
          onChanged: (val) => setState(() {
            role2 = val;
            if(val == 'Select One'){
              transferReportModel.updateTemporaryRecord(widget.edit, Strings.role2, null, widget.jobId, widget.saved, widget.savedId);
            } else {
              transferReportModel.updateTemporaryRecord(widget.edit, Strings.role2, GlobalFunctions.encryptString(val), widget.jobId, widget.saved, widget.savedId);
            }

            FocusScope.of(context).unfocus();
          }),
          initialValue: role2,
        ),
        SizedBox(height: 15,),
      ],
    );
  }

  Widget _buildRoleDrop3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Role', style: TextStyle(
            fontSize: 16.0, color: bluePurple),),
        DropdownFormField(
          expanded: true,
          value: role3,
          items: roleDrop.toList(),
          onChanged: (val) => setState(() {
            role3 = val;
            if(val == 'Select One'){
              transferReportModel.updateTemporaryRecord(widget.edit, Strings.role3, null, widget.jobId, widget.saved, widget.savedId);
            } else {
              transferReportModel.updateTemporaryRecord(widget.edit, Strings.role3, GlobalFunctions.encryptString(val), widget.jobId, widget.saved, widget.savedId);
            }

            FocusScope.of(context).unfocus();
          }),
          initialValue: role3,
        ),
        SizedBox(height: 15,),
      ],
    );
  }

  Widget _buildRoleDrop4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Role', style: TextStyle(
            fontSize: 16.0, color: bluePurple),),
        DropdownFormField(
          expanded: true,
          value: role4,
          items: roleDrop.toList(),
          onChanged: (val) => setState(() {
            role4 = val;
            if(val == 'Select One'){
              transferReportModel.updateTemporaryRecord(widget.edit, Strings.role4, null, widget.jobId, widget.saved, widget.savedId);
            } else {
              transferReportModel.updateTemporaryRecord(widget.edit, Strings.role4, GlobalFunctions.encryptString(val), widget.jobId, widget.saved, widget.savedId);
            }

            FocusScope.of(context).unfocus();
          }),
          initialValue: role4,
        ),
        SizedBox(height: 15,),
      ],
    );
  }

  Widget _buildRoleDrop5() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Role', style: TextStyle(
            fontSize: 16.0, color: bluePurple),),
        DropdownFormField(
          expanded: true,
          value: role5,
          items: roleDrop.toList(),
          onChanged: (val) => setState(() {
            role5 = val;
            if(val == 'Select One'){
              transferReportModel.updateTemporaryRecord(widget.edit, Strings.role5, null, widget.jobId, widget.saved, widget.savedId);
            } else {
              transferReportModel.updateTemporaryRecord(widget.edit, Strings.role5, GlobalFunctions.encryptString(val), widget.jobId, widget.saved, widget.savedId);
            }

            FocusScope.of(context).unfocus();
          }),
          initialValue: role5,
        ),
        SizedBox(height: 15,),
      ],
    );
  }

  Widget _buildRoleDrop6() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Role', style: TextStyle(
            fontSize: 16.0, color: bluePurple),),
        DropdownFormField(
          expanded: true,
          value: role6,
          items: roleDrop.toList(),
          onChanged: (val) => setState(() {
            role6 = val;
            if(val == 'Select One'){
              transferReportModel.updateTemporaryRecord(widget.edit, Strings.role6, null, widget.jobId, widget.saved, widget.savedId);
            } else {
              transferReportModel.updateTemporaryRecord(widget.edit, Strings.role6, GlobalFunctions.encryptString(val), widget.jobId, widget.saved, widget.savedId);
            }

            FocusScope.of(context).unfocus();
          }),
          initialValue: role6,
        ),
        SizedBox(height: 15,),
      ],
    );
  }

  // Widget _buildRoleDrop6() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text('Role', style: TextStyle(
  //           fontSize: 16.0, color: bluePurple),),
  //       DropdownFormField(
  //         expanded: true,
  //         value: role6,
  //         items: roleDrop.toList(),
  //         onChanged: (val) => setState(() {
  //           role6 = val;
  //           if(val == 'Select One'){
  //             _databaseHelper.updateTemporaryTransferReportField(widget.edit,
  //                 {Strings.role6 : null}, user.uid, widget.jobId, widget.saved, widget.savedId);
  //           } else {
  //             _databaseHelper.updateTemporaryTransferReportField(widget.edit,
  //                 {Strings.role6 : GlobalFunctions.encryptString(val)}, user.uid, widget.jobId, widget.saved, widget.savedId);
  //           }
  //
  //           FocusScope.of(context).unfocus();
  //         }),
  //         initialValue: role6,
  //       ),
  //       SizedBox(height: 15,),
  //     ],
  //   );
  // }
  //
  // Widget _buildRoleDrop7() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text('Role', style: TextStyle(
  //           fontSize: 16.0, color: bluePurple),),
  //       DropdownFormField(
  //         expanded: true,
  //         value: role7,
  //         items: roleDrop.toList(),
  //         onChanged: (val) => setState(() {
  //           role7 = val;
  //           if(val == 'Select One'){
  //             _databaseHelper.updateTemporaryTransferReportField(widget.edit,
  //                 {Strings.role7 : null}, user.uid, widget.jobId, widget.saved, widget.savedId);
  //           } else {
  //             _databaseHelper.updateTemporaryTransferReportField(widget.edit,
  //                 {Strings.role7 : GlobalFunctions.encryptString(val)}, user.uid, widget.jobId, widget.saved, widget.savedId);
  //           }
  //
  //           FocusScope.of(context).unfocus();
  //         }),
  //         initialValue: role7,
  //       ),
  //       SizedBox(height: 15,),
  //     ],
  //   );
  // }
  //
  // Widget _buildRoleDrop8() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text('Role', style: TextStyle(
  //           fontSize: 16.0, color: bluePurple),),
  //       DropdownFormField(
  //         expanded: true,
  //         value: role8,
  //         items: roleDrop.toList(),
  //         onChanged: (val) => setState(() {
  //           role8 = val;
  //           if(val == 'Select One'){
  //             _databaseHelper.updateTemporaryTransferReportField(widget.edit,
  //                 {Strings.role8 : null}, user.uid, widget.jobId, widget.saved, widget.savedId);
  //           } else {
  //             _databaseHelper.updateTemporaryTransferReportField(widget.edit,
  //                 {Strings.role8 : GlobalFunctions.encryptString(val)}, user.uid, widget.jobId, widget.saved, widget.savedId);
  //           }
  //
  //           FocusScope.of(context).unfocus();
  //         }),
  //         initialValue: role8,
  //       ),
  //       SizedBox(height: 15,),
  //     ],
  //   );
  // }
  //
  // Widget _buildRoleDrop9() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text('Role', style: TextStyle(
  //           fontSize: 16.0, color: bluePurple),),
  //       DropdownFormField(
  //         expanded: true,
  //         value: role9,
  //         items: roleDrop.toList(),
  //         onChanged: (val) => setState(() {
  //           role9 = val;
  //           if(val == 'Select One'){
  //             _databaseHelper.updateTemporaryTransferReportField(widget.edit,
  //                 {Strings.role9 : null}, user.uid, widget.jobId, widget.saved, widget.savedId);
  //           } else {
  //             _databaseHelper.updateTemporaryTransferReportField(widget.edit,
  //                 {Strings.role9 : GlobalFunctions.encryptString(val)}, user.uid, widget.jobId, widget.saved, widget.savedId);
  //           }
  //
  //           FocusScope.of(context).unfocus();
  //         }),
  //         initialValue: role9,
  //       ),
  //       SizedBox(height: 15,),
  //     ],
  //   );
  // }
  //
  // Widget _buildRoleDrop10() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text('Role', style: TextStyle(
  //           fontSize: 16.0, color: bluePurple),),
  //       DropdownFormField(
  //         expanded: true,
  //         value: role10,
  //         items: roleDrop.toList(),
  //         onChanged: (val) => setState(() {
  //           role10 = val;
  //           if(val == 'Select One'){
  //             _databaseHelper.updateTemporaryTransferReportField(widget.edit,
  //                 {Strings.role10 : null}, user.uid, widget.jobId, widget.saved, widget.savedId);
  //           } else {
  //             _databaseHelper.updateTemporaryTransferReportField(widget.edit,
  //                 {Strings.role10 : GlobalFunctions.encryptString(val)}, user.uid, widget.jobId, widget.saved, widget.savedId);
  //           }
  //
  //           FocusScope.of(context).unfocus();
  //         }),
  //         initialValue: role10,
  //       ),
  //       SizedBox(height: 15,),
  //     ],
  //   );
  // }
  //
  // Widget _buildRoleDrop11() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text('Role', style: TextStyle(
  //           fontSize: 16.0, color: bluePurple),),
  //       DropdownFormField(
  //         expanded: true,
  //         value: role11,
  //         items: roleDrop.toList(),
  //         onChanged: (val) => setState(() {
  //           role11 = val;
  //           if(val == 'Select One'){
  //             _databaseHelper.updateTemporaryTransferReportField(widget.edit,
  //                 {Strings.role11 : null}, user.uid, widget.jobId, widget.saved, widget.savedId);
  //           } else {
  //             _databaseHelper.updateTemporaryTransferReportField(widget.edit,
  //                 {Strings.role11 : GlobalFunctions.encryptString(val)}, user.uid, widget.jobId, widget.saved, widget.savedId);
  //           }
  //
  //           FocusScope.of(context).unfocus();
  //         }),
  //         initialValue: role11,
  //       ),
  //       SizedBox(height: 15,),
  //     ],
  //   );
  // }






  Widget _buildCollectionSignatureRow() {
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
                    text: 'Signature',
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
          color: collectionImageBytes == null ? Color(0xFF0000).withOpacity(0.3) : null,
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
                        collectionSignature = Signature(
                          points: collectionSignaturePoints,
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
                                child: collectionSignature,
                              )
                            ],
                          ),
                          actions: <Widget>[
                            TextButton(
                                onPressed: () {
                                  collectionSignature
                                      .clear();
                                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.collectionSignaturePoints, null, widget.jobId, widget.saved, widget.savedId);
                                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.collectionSignature, null, widget.jobId, widget.saved, widget.savedId);
                                  setState(() {
                                    collectionSignaturePoints = [];
                                    collectionImageBytes =
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

                                  collectionSignaturePoints =
                                      collectionSignature
                                          .exportPoints();

                                  if (collectionSignaturePoints.length > 0) {
                                    collectionSignaturePoints.forEach((
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

                                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.collectionSignaturePoints, encryptedPoints, widget.jobId, widget.saved, widget.savedId);


                                    Uint8List signatureBytes = await collectionSignature
                                        .exportBytes();

                                    setState(() {
                                      collectionImageBytes =
                                          signatureBytes;
                                    });

                                    Uint8List encryptedSignature = await GlobalFunctions
                                        .encryptSignature(collectionImageBytes);

                                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.collectionSignature, encryptedSignature, widget.jobId, widget.saved, widget.savedId);


                                  }

                                  Navigator.of(context).pop();

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
              child: collectionImageBytes == null
                  ? Icon(
                Icons.border_color,
                color: bluePurple,
                size: 40.0,
              )
                  : Image.memory(collectionImageBytes),
            ),
          ),
        )
      ],
    );
  }
  Widget _buildDestinationSignatureRow() {
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
                      text: 'Signature',
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
          color: destinationImageBytes == null ? Color(0xFF0000).withOpacity(0.3) : null,
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
                        destinationSignature = Signature(
                          points: destinationSignaturePoints,
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
                                child: destinationSignature,
                              )
                            ],
                          ),
                          actions: <Widget>[
                            TextButton(
                                onPressed: () {
                                  destinationSignature
                                      .clear();

                                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.destinationSignaturePoints, null, widget.jobId, widget.saved, widget.savedId);
                                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.destinationSignature, null, widget.jobId, widget.saved, widget.savedId);
                                  setState(() {
                                    destinationSignaturePoints = [];
                                    destinationImageBytes =
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

                                  destinationSignaturePoints =
                                      destinationSignature
                                          .exportPoints();

                                  if (destinationSignaturePoints.length > 0) {
                                    destinationSignaturePoints.forEach((
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

                                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.destinationSignaturePoints, encryptedPoints, widget.jobId, widget.saved, widget.savedId);

                                    Uint8List signatureBytes = await destinationSignature
                                        .exportBytes();

                                    setState(() {
                                      destinationImageBytes =
                                          signatureBytes;
                                    });

                                    Uint8List encryptedSignature = await GlobalFunctions
                                        .encryptSignature(destinationImageBytes);

                                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.destinationSignature, encryptedSignature, widget.jobId, widget.saved, widget.savedId);

                                  }
                                  Navigator.of(context).pop();

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
              child: destinationImageBytes == null
                  ? Icon(
                Icons.border_color,
                color: bluePurple,
                size: 40.0,
              )
                  : Image.memory(destinationImageBytes),
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
          decoration: InputDecoration(filled: required && controller.text.isEmpty ? true : false, fillColor: Color(0xFF0000).withOpacity(0.3),
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
  Widget _buildStartDateTimeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: 'Start Time',
              style: TextStyle(
                  fontSize: 16.0, fontFamily: 'Open Sans', color: bluePurple),
              children:
              [
                TextSpan(
                  text: ' *',
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
                  decoration: InputDecoration(filled: startTime.text.isEmpty ? true : false, fillColor: Color(0xFF0000).withOpacity(0.3)),
                  enabled: true,
                  initialValue: null,
                  controller: startTime,
                  onSaved: (String value) {
                    setState(() {
                      startTime.text = value;
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
                    startTime.clear();
                    totalHours.clear();
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.startTime, null, widget.jobId, widget.saved, widget.savedId);
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.totalHours, null, widget.jobId, widget.saved, widget.savedId);
                  });
                }),
            IconButton(
                icon: Icon(Icons.access_time,
                    color: bluePurple),
                onPressed: () async{
                  FocusScope.of(context).unfocus();
                  await Future.delayed(Duration(milliseconds: 100));
                  DateTime newDate = await showDatePicker(
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
                      lastDate: DateTime(2100));
                    if (newDate != null) {
                      TimeOfDay time = await showTimePicker(
                          context: context, initialTime: TimeOfDay.now());
                        if (time != null) {
                          newDate = DateTime(newDate.year, newDate.month, newDate.day);
                          newDate = newDate.add(
                              Duration(hours: time.hour, minutes: time.minute));
                          String dateTime = timeFormat.format(newDate);
                          setState(() {
                            startTime.text = dateTime;
                          });

                          await transferReportModel.updateTemporaryRecord(widget.edit, Strings.startTime, DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String(), widget.jobId, widget.saved, widget.savedId);


                          Map<String, dynamic> transferReport = await transferReportModel.getTemporaryRecord(widget.edit, widget.jobId, widget.saved, widget.savedId);

                              if(transferReport[Strings.finishTime] != null){

                                DateTime finishDateTime = DateTime.parse(transferReport[Strings.finishTime]);

                                int minutes = finishDateTime
                                    .difference(newDate)
                                    .inMinutes;
                                String totalHoursString;

                                if (minutes < 180) {
                                  totalHoursString = '3';
                                } else {
                                  totalHoursString = (minutes / 60).toStringAsFixed(1).replaceAll(RegExp(r"([.]*0)(?!.*\d)"), "");
                                }

                                setState(() {
                                  totalHours.text = totalHoursString;
                                });
                                await transferReportModel.updateTemporaryRecord(widget.edit, Strings.totalHours, totalHoursString, widget.jobId, widget.saved, widget.savedId);
                              }
                        }
                    }

                })
          ],
        ),
      ],
    );
  }



  Widget _buildFinishDateTimeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: 'Finish Time',
              style: TextStyle(
                  fontSize: 16.0, fontFamily: 'Open Sans', color: bluePurple),
              children:
              [
                TextSpan(
                  text: ' *',
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
                  decoration: InputDecoration(filled: finishTime.text.isEmpty ? true : false, fillColor: Color(0xFF0000).withOpacity(0.3)),
                  enabled: true,
                  initialValue: null,
                  controller: finishTime,
                  onSaved: (String value) {
                    setState(() {
                      finishTime.text = value;
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
                    finishTime.clear();
                    totalHours.clear();
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.finishTime, null, widget.jobId, widget.saved, widget.savedId);
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.totalHours, null, widget.jobId, widget.saved, widget.savedId);
                  });
                }),
            IconButton(
                icon: Icon(Icons.access_time,
                    color: bluePurple),
                onPressed: () async{
                  FocusScope.of(context).unfocus();
                  await Future.delayed(Duration(milliseconds: 100));
                  DateTime newDate = await showDatePicker(
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
                      lastDate: DateTime(2100));
                  if (newDate != null) {
                    TimeOfDay time = await showTimePicker(
                        context: context, initialTime: TimeOfDay.now());
                    if (time != null) {
                      newDate = DateTime(newDate.year, newDate.month, newDate.day);
                      newDate = newDate.add(
                          Duration(hours: time.hour, minutes: time.minute));
                      String dateTime = timeFormat.format(newDate);
                      setState(() {
                        finishTime.text = dateTime;
                      });

                      await transferReportModel.updateTemporaryRecord(widget.edit, Strings.finishTime, DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String(), widget.jobId, widget.saved, widget.savedId);


                      Map<String, dynamic> transferReport = await transferReportModel.getTemporaryRecord(widget.edit, widget.jobId, widget.saved, widget.savedId);

                      if(transferReport[Strings.startTime] != null){

                        DateTime startDateTime = DateTime.parse(transferReport[Strings.startTime]);

                        int minutes = newDate
                            .difference(startDateTime)
                            .inMinutes;
                        String totalHoursString;

                        if (minutes < 180) {
                          totalHoursString = '3';
                        } else {
                          totalHoursString = (minutes / 60).toStringAsFixed(1).replaceAll(RegExp(r"([.]*0)(?!.*\d)"), "");
                        }

                        setState(() {
                          totalHours.text = totalHoursString;
                        });

                        await transferReportModel.updateTemporaryRecord(widget.edit, Strings.totalHours, totalHoursString, widget.jobId, widget.saved, widget.savedId);
                      }
                    }
                  }

                })
          ],
        ),
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
                  decoration: InputDecoration(filled: required && controller.text.isEmpty ? true : false, fillColor: Color(0xFF0000).withOpacity(0.3)),
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
                    transferReportModel.updateTemporaryRecord(widget.edit, value, null, widget.jobId, widget.saved, widget.savedId);
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
                          transferReportModel.updateTemporaryRecord(widget.edit, value, GlobalFunctions.encryptString(DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String()), widget.jobId, widget.saved, widget.savedId);
                        } else {
                          transferReportModel.updateTemporaryRecord(widget.edit, value, DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String(), widget.jobId, widget.saved, widget.savedId);
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
                  decoration: InputDecoration(filled: required && controller.text.isEmpty ? true : false, fillColor: Color(0xFF0000).withOpacity(0.3)),
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
                    transferReportModel.updateTemporaryRecord(widget.edit, value, null, widget.jobId, widget.saved, widget.savedId);
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
                          transferReportModel.updateTemporaryRecord(widget.edit, value, GlobalFunctions.encryptString(DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String()), widget.jobId, widget.saved, widget.savedId);
                        } else {
                          transferReportModel.updateTemporaryRecord(widget.edit, value, DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String(), widget.jobId, widget.saved, widget.savedId);
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
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('TRANSFER REPORT', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 18),),
                  ],),
                  SizedBox(height: 20,),
                  Row(
                    children: [
                      Flexible(child: _buildJobRefDrop()),
                      Container(width: 10,),
                      Flexible(child: _textFormField('', jobRef, 1, true, TextInputType.number),),
                      Container(width: 10,),
                      SizedBox(width: 100, child: GradientButton('Search', () => _getBookingFormData()),)
                    ],
                  ),
                  _buildDateField('Date', date, Strings.date, true, false),
                  SizedBox(height: 20,),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('PRE-TRANSFER VEHICLE CHECKLIST', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 18),),
                  ],),
                  SizedBox(height: 20,),
                  _textFormField('Completed by', vehicleCompletedBy1, 1, true),
                  _textFormField('Ambulance Reg', ambulanceReg, 1, true),
                  //_textFormField('Start Mileage', vehicleStartMileage, 1, true),
                  _buildNearestTank1Drop(),
                  _buildDateField('Date', vehicleDate, Strings.vehicleDate, true),
                  _buildTimeField('Time', vehicleTime, Strings.vehicleTime, true),
                  SizedBox(height: 10,),
                  _buildCheckboxRowAmbulanceTidyYes1('• Was the ambulance left clean and tidy?'),
                  _buildCheckboxRowLightsWorkingYes('• Ambulance lights working?'),
                  _buildCheckboxRowTyresInflatedYes('• Tyres appear inflated fully?'),
                  _buildCheckboxRowWarningSignsYes('• Vehicle warning signs showing?'),
                  _buildCheckboxRowVehicleDamageYes('• Any damage to vehicle / bodywork?'),
                  SizedBox(height: 20,),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('JOB DETAILS', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 18),),
                  ],),
                  SizedBox(height: 20,),
                  _buildStartDateTimeField(),
                  SizedBox(height: 10,),
                  _buildFinishDateTimeField(),
                  SizedBox(height: 10,),
                  _textFormField('Total Hours', totalHours),
                  _textFormField('Collection Details', collectionDetails, 4, false, TextInputType.multiline),
                  _textFormField('Postcode', collectionPostcode),
                  _textFormField('Contact No.', collectionContactNo),
                  _textFormField('Destination Details', destinationDetails, 4, false, TextInputType.multiline),
                  _textFormField('Postcode', destinationPostcode),
                  _textFormField('Contact No.', destinationContactNo),
                  _buildTimeField('Collection arrival time', collectionArrivalTime, Strings.collectionArrivalTime),
                  _buildTimeField('Collection departure time', collectionDepartureTime, Strings.collectionDepartureTime),
                  _buildTimeField('Destination arrival time', destinationArrivalTime, Strings.destinationArrivalTime),
                  _buildTimeField('Destination departure time', destinationDepartureTime, Strings.destinationDepartureTime),
                  _textFormField('Vehicle Reg No.', vehicleRegNo),
                  _textFormField('Start Mileage', startMileage, 1, true, TextInputType.numberWithOptions(decimal: true)),
                  //_textFormField('Finish Mileage', finishMileage),
                  //_textFormField('Total Mileage', totalMileage),
                  _textFormField('Name', name1),
                  _buildRoleDrop1(),
                  role1 == 'Other' ? _textFormField('Type role here', other1) : Container(),
                  _buildTimeField('Driving Times', drivingTimes1_1, Strings.drivingTimes1_1),
                  _buildTimeField('Driving Times', drivingTimes1_2, Strings.drivingTimes1_2),
                  rowCount >= 2 ? Column(
                    children: [
                      _textFormField('Name', name2),
                      _buildRoleDrop2(),
                      role2 == 'Other' ? _textFormField('Type role here', other2) : Container(),
                      _buildTimeField('Driving Times', drivingTimes2_1, Strings.drivingTimes2_1),
                      _buildTimeField('Driving Times', drivingTimes2_2, Strings.drivingTimes2_2),
                    ],
                  ) : Container(),
                  rowCount >= 3 ? Column(
                    children: [
                      _textFormField('Name', name3),
                      _buildRoleDrop3(),
                      role3 == 'Other' ? _textFormField('Type role here', other3) : Container(),
                      _buildTimeField('Driving Times', drivingTimes3_1, Strings.drivingTimes3_1),
                      _buildTimeField('Driving Times', drivingTimes3_2, Strings.drivingTimes3_2),
                    ],
                  ) : Container(),
                  rowCount >= 4 ? Column(
                    children: [
                      _textFormField('Name', name4),
                      _buildRoleDrop4(),
                      role4 == 'Other' ? _textFormField('Type role here', other4) : Container(),
                      _buildTimeField('Driving Times', drivingTimes4_1, Strings.drivingTimes4_1),
                      _buildTimeField('Driving Times', drivingTimes4_2, Strings.drivingTimes4_2),
                    ],
                  ) : Container(),
                  rowCount >= 5 ? Column(
                    children: [
                      _textFormField('Name', name5),
                      _buildRoleDrop5(),
                      role5 == 'Other' ? _textFormField('Type role here', other5) : Container(),
                      _buildTimeField('Driving Times', drivingTimes5_1, Strings.drivingTimes5_1),
                      _buildTimeField('Driving Times', drivingTimes5_2, Strings.drivingTimes5_2),
                    ],
                  ) : Container(),
                  rowCount >= 6 ? Column(
                    children: [
                      _textFormField('Name', name6),
                      _buildRoleDrop6(),
                      role6 == 'Other' ? _textFormField('Type role here', other6) : Container(),
                      _buildTimeField('Driving Times', drivingTimes6_1, Strings.drivingTimes6_1),
                      _buildTimeField('Driving Times', drivingTimes6_2, Strings.drivingTimes6_2),
                    ],
                  ) : Container(),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    SizedBox(width: 150, child: GradientButton('Add Staff', () => _increaseRowCount()),),
                  ],),
                  // _textFormField('Name', name6),
                  // _textFormField('Role', other6),
                  // _buildTimeField('Driving Times', drivingTimes6_1, Strings.drivingTimes6_1),
                  // _buildTimeField('Driving Times', drivingTimes6_2, Strings.drivingTimes6_2),
                  // _textFormField('Name', name7),
                  // _textFormField('Role', other7),
                  // _buildTimeField('Driving Times', drivingTimes7_1, Strings.drivingTimes7_1),
                  // _buildTimeField('Driving Times', drivingTimes7_2, Strings.drivingTimes7_2),
                  // _textFormField('Name', name8),
                  // _textFormField('Role', other8),
                  // _buildTimeField('Driving Times', drivingTimes8_1, Strings.drivingTimes8_1),
                  // _buildTimeField('Driving Times', drivingTimes8_2, Strings.drivingTimes8_2),
                  // _textFormField('Name', name9),
                  // _textFormField('Role', other9),
                  // _buildTimeField('Driving Times', drivingTimes9_1, Strings.drivingTimes9_1),
                  // _buildTimeField('Driving Times', drivingTimes9_2, Strings.drivingTimes9_2),
                  // _textFormField('Name', name10),
                  // _textFormField('Role', other10),
                  // _buildTimeField('Driving Times', drivingTimes10_1, Strings.drivingTimes10_1),
                  // _buildTimeField('Driving Times', drivingTimes10_2, Strings.drivingTimes10_2),
                  // _textFormField('Name', name11),
                  // _textFormField('Role', other11),
                  // _buildTimeField('Driving Times', drivingTimes11_1, Strings.drivingTimes11_1),
                  // _buildTimeField('Driving Times', drivingTimes11_2, Strings.drivingTimes11_2),
                  SizedBox(height: 20,),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('TRANSFER REPORT', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 18),),
                  ],),
                  SizedBox(height: 20,),
                  Text('Collection Details', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold),),
                  SizedBox(height: 10,),
                  Text('This is a legal and binding document and will be retained by the company for reference of any incidents that may occur in the event that we have been given any incorrect information. By signing this form, you are satisfied that all property, section papers and documents listed within this report have been handed over from Pegasus Medical (1808) Ltd.', style: TextStyle(color: bluePurple),),
                  SizedBox(height: 10,),
                  Text('Section Papers handed over if required', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold),),
                  SizedBox(height: 20,),
                  _textFormField('Unit', collectionUnit, 1, true),
                  _textFormField('Position', collectionPosition, 1, true),
                  _textFormField('Print Name', collectionPrintName, 1, true),
                  _buildCollectionSignatureRow(),
                  SizedBox(height: 20,),

                  _buildTimeField('Arrival Time', collectionArrivalTimeEnd, Strings.collectionArrivalTimeEnd, true),
                  SizedBox(height: 10,),
                  Text('Destination Details', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold),),
                  SizedBox(height: 10,),
                  Text('This is a legal and binding document and will be retained by the company for reference of any incidents that may occur in the event that we have been given any incorrect information. By signing this form, you are satisfied that all property, section papers and documents listed within this report have been handed over from Pegasus Medical (1808) Ltd.', style: TextStyle(color: bluePurple),),
                  SizedBox(height: 10,),
                  Text('Section Papers handed over if required', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold),),
                  SizedBox(height: 20,),
                  _textFormField('Unit', destinationUnit, 1, true),
                  _textFormField('Position', destinationPosition, 1, true),
                  _textFormField('Print Name', destinationPrintName, 1, true),
                  _buildDestinationSignatureRow(),
                  SizedBox(height: 20,),
                  _buildTimeField('Arrival Time', destinationArrivalTimeEnd, Strings.destinationArrivalTimeEnd, true),
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

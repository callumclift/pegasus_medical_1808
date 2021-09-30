import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
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
  final TextEditingController finishMileage = TextEditingController();
  final TextEditingController totalMileage = TextEditingController();
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




  @override
  void initState() {
    // TODO: implement initState
    if(!isWeb) _loadingTemporary = true;
    transferReportModel = Provider.of<TransferReportModel>(context, listen: false);
    _setUpTextControllerListeners();
    _getTemporaryTransferReport();
    super.initState();
  }

  @override
  void dispose() {
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
    finishMileage.dispose();
    totalMileage.dispose();
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

    _addListener(jobRef, Strings.jobRef, false, true);
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

        if (transferReport[Strings.jobRef] != null) {
          jobRef.text = GlobalFunctions.databaseValueString(
              transferReport[Strings.jobRef]);
        } else {
          jobRef.text = '';
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
        GlobalFunctions.getTemporaryValue(transferReport, totalMileage, Strings.totalMileage);
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
        // if(transferReport[Strings.collectionPrintName] == null){
        //   collectionPrintName.text = user.name;
        //   _databaseHelper.updateTemporaryTransferReportField(widget.edit, {
        //     Strings.collectionPrintName: GlobalFunctions.encryptString(collectionPrintName.text)
        //   }, user.uid, widget.jobId, widget.saved, widget.savedId);
        // } else {
        //   GlobalFunctions.getTemporaryValue(transferReport, collectionPrintName, Strings.collectionPrintName);
        // }
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




    // if (mounted) {
    //   int result = await _databaseHelper.checkTemporaryTransferReportExists(widget.edit,
    //       user.uid, widget.jobId, widget.saved, widget.savedId);
    //   if (result != 0) {
    //     Map<String, dynamic> transferReport = await _databaseHelper
    //         .getTemporaryTransferReport(widget.edit, user.uid, widget.jobId, widget.saved, widget.savedId);
    //
    //     if (transferReport[Strings.collectionSignature] != null) {
    //       if (mounted) {
    //         Uint8List decryptedSignature = await GlobalFunctions.decryptSignature(transferReport[Strings.collectionSignature]);
    //         setState(() {
    //           collectionImageBytes = decryptedSignature;
    //         });
    //       }
    //     } else {
    //       collectionSignature = null;
    //       collectionImageBytes = null;
    //     }
    //     if (transferReport[Strings.collectionSignaturePoints] != null) {
    //       if (mounted) {
    //         String decryptedPoints = GlobalFunctions.decryptString(transferReport[Strings.collectionSignaturePoints]);
    //         setState(() {
    //           List<dynamic> fetchedSignaturePoints = jsonDecode(decryptedPoints);
    //           fetchedSignaturePoints.forEach((dynamic pointMap) {
    //             if (pointMap['pointType'] == 'tap') {
    //               collectionSignaturePoints.add(Point(
    //                   Offset(pointMap['dx'], pointMap['dy']),
    //                   PointType.tap));
    //             } else if (pointMap['pointType'] == 'move') {
    //               collectionSignaturePoints.add(Point(
    //                   Offset(pointMap['dx'], pointMap['dy']),
    //                   PointType.move));
    //             }
    //           });
    //         });
    //       }
    //     } else {
    //       collectionSignaturePoints = [];
    //
    //     }
    //     if (transferReport[Strings.destinationSignature] != null) {
    //       if (mounted) {
    //         Uint8List decryptedSignature = await GlobalFunctions.decryptSignature(transferReport[Strings.destinationSignature]);
    //         setState(() {
    //           destinationImageBytes = decryptedSignature;
    //         });
    //       }
    //     } else {
    //       destinationSignature = null;
    //       destinationImageBytes = null;
    //     }
    //     if (transferReport[Strings.destinationSignaturePoints] != null) {
    //       if (mounted) {
    //         String decryptedPoints = GlobalFunctions.decryptString(transferReport[Strings.destinationSignaturePoints]);
    //         setState(() {
    //           List<dynamic> fetchedSignaturePoints = jsonDecode(decryptedPoints);
    //           fetchedSignaturePoints.forEach((dynamic pointMap) {
    //             if (pointMap['pointType'] == 'tap') {
    //               destinationSignaturePoints.add(Point(
    //                   Offset(pointMap['dx'], pointMap['dy']),
    //                   PointType.tap));
    //             } else if (pointMap['pointType'] == 'move') {
    //               destinationSignaturePoints.add(Point(
    //                   Offset(pointMap['dx'], pointMap['dy']),
    //                   PointType.move));
    //             }
    //           });
    //         });
    //       }
    //     } else {
    //       destinationSignaturePoints = [];
    //
    //     }
    //
    //     if (transferReport[Strings.jobRef] != null) {
    //       jobRef.text = GlobalFunctions.databaseValueString(
    //           transferReport[Strings.jobRef]);
    //     } else {
    //       jobRef.text = '';
    //     }
    //     if (transferReport[Strings.date] != null) {
    //       date.text =
    //           dateFormat.format(DateTime.parse(transferReport[Strings.date]));
    //     } else {
    //       date.text = '';
    //     }
    //
    //     print(transferReport[Strings.jobRef]);
    //
    //     GlobalFunctions.getTemporaryValue(transferReport, totalHours, Strings.totalHours, false);
    //     GlobalFunctions.getTemporaryValue(transferReport, collectionDetails, Strings.collectionDetails);
    //     GlobalFunctions.getTemporaryValue(transferReport, collectionPostcode, Strings.collectionPostcode);
    //     GlobalFunctions.getTemporaryValue(transferReport, collectionContactNo, Strings.collectionContactNo);
    //     GlobalFunctions.getTemporaryValue(transferReport, destinationDetails, Strings.destinationDetails);
    //     GlobalFunctions.getTemporaryValue(transferReport, destinationPostcode, Strings.destinationPostcode);
    //     GlobalFunctions.getTemporaryValue(transferReport, destinationContactNo, Strings.destinationContactNo);
    //     GlobalFunctions.getTemporaryValue(transferReport, vehicleRegNo, Strings.vehicleRegNo);
    //     GlobalFunctions.getTemporaryValue(transferReport, startMileage, Strings.startMileage);
    //     GlobalFunctions.getTemporaryValue(transferReport, finishMileage, Strings.finishMileage);
    //     GlobalFunctions.getTemporaryValue(transferReport, totalMileage, Strings.totalMileage);
    //     GlobalFunctions.getTemporaryValue(transferReport, name1, Strings.name1);
    //     if (transferReport[Strings.role1] != null) {
    //       setState(() {
    //         roleCount += 1;
    //       });
    //       String decryptedRole = GlobalFunctions.decryptString(transferReport[Strings.role1]);
    //       print(decryptedRole);
    //       bool inDrop = false;
    //
    //       for(String role in roleDrop){
    //         if(decryptedRole == role){
    //           inDrop = true;
    //           role1 = decryptedRole;
    //         }
    //       }
    //
    //       if(!inDrop){
    //         role1  = 'Other';
    //         other1.text = decryptedRole;
    //       }
    //     }
    //     if (transferReport[Strings.role2] != null) {
    //       setState(() {
    //         roleCount += 1;
    //       });
    //       String decryptedRole = GlobalFunctions.decryptString(transferReport[Strings.role2]);
    //       print(decryptedRole);
    //       bool inDrop = false;
    //
    //       for(String role in roleDrop){
    //         if(decryptedRole == role){
    //           inDrop = true;
    //           role2 = decryptedRole;
    //         }
    //       }
    //
    //       if(!inDrop){
    //         role2  = 'Other';
    //         other2.text = decryptedRole;
    //       }
    //     }
    //     if (transferReport[Strings.role3] != null) {
    //       setState(() {
    //         roleCount += 1;
    //       });
    //       String decryptedRole = GlobalFunctions.decryptString(transferReport[Strings.role3]);
    //       print(decryptedRole);
    //       bool inDrop = false;
    //
    //       for(String role in roleDrop){
    //         if(decryptedRole == role){
    //           inDrop = true;
    //           role3 = decryptedRole;
    //         }
    //       }
    //
    //       if(!inDrop){
    //         role3  = 'Other';
    //         other3.text = decryptedRole;
    //       }
    //     }
    //     if (transferReport[Strings.role4] != null) {
    //       setState(() {
    //         roleCount += 1;
    //       });
    //       String decryptedRole = GlobalFunctions.decryptString(transferReport[Strings.role4]);
    //       print(decryptedRole);
    //       bool inDrop = false;
    //
    //       for(String role in roleDrop){
    //         if(decryptedRole == role){
    //           inDrop = true;
    //           role4 = decryptedRole;
    //         }
    //       }
    //
    //       if(!inDrop){
    //         role4  = 'Other';
    //         other4.text = decryptedRole;
    //       }
    //     }
    //     if (transferReport[Strings.role5] != null) {
    //       setState(() {
    //         roleCount += 1;
    //       });
    //       String decryptedRole = GlobalFunctions.decryptString(transferReport[Strings.role5]);
    //       print(decryptedRole);
    //       bool inDrop = false;
    //
    //       for(String role in roleDrop){
    //         if(decryptedRole == role){
    //           inDrop = true;
    //           role5 = decryptedRole;
    //         }
    //       }
    //
    //       if(!inDrop){
    //         role5  = 'Other';
    //         other5.text = decryptedRole;
    //       }
    //     }
    //     if (transferReport[Strings.role6] != null) {
    //       setState(() {
    //         roleCount += 1;
    //       });
    //       String decryptedRole = GlobalFunctions.decryptString(transferReport[Strings.role6]);
    //       print(decryptedRole);
    //       bool inDrop = false;
    //
    //       for(String role in roleDrop){
    //         if(decryptedRole == role){
    //           inDrop = true;
    //           role6 = decryptedRole;
    //         }
    //       }
    //
    //       if(!inDrop){
    //         role6  = 'Other';
    //         other6.text = decryptedRole;
    //       }
    //     }
    //     if (transferReport[Strings.role7] != null) {
    //       setState(() {
    //         roleCount += 1;
    //       });
    //       String decryptedRole = GlobalFunctions.decryptString(transferReport[Strings.role7]);
    //       print(decryptedRole);
    //       bool inDrop = false;
    //
    //       for(String role in roleDrop){
    //         if(decryptedRole == role){
    //           inDrop = true;
    //           role7 = decryptedRole;
    //         }
    //       }
    //
    //       if(!inDrop){
    //         role7  = 'Other';
    //         other7.text = decryptedRole;
    //       }
    //     }
    //     if (transferReport[Strings.role8] != null) {
    //       setState(() {
    //         roleCount += 1;
    //       });
    //       String decryptedRole = GlobalFunctions.decryptString(transferReport[Strings.role8]);
    //       print(decryptedRole);
    //       bool inDrop = false;
    //
    //       for(String role in roleDrop){
    //         if(decryptedRole == role){
    //           inDrop = true;
    //           role8 = decryptedRole;
    //         }
    //       }
    //
    //       if(!inDrop){
    //         role8  = 'Other';
    //         other8.text = decryptedRole;
    //       }
    //     }
    //     if (transferReport[Strings.role9] != null) {
    //       setState(() {
    //         roleCount += 1;
    //       });
    //       String decryptedRole = GlobalFunctions.decryptString(transferReport[Strings.role9]);
    //       print(decryptedRole);
    //       bool inDrop = false;
    //
    //       for(String role in roleDrop){
    //         if(decryptedRole == role){
    //           inDrop = true;
    //           role9 = decryptedRole;
    //         }
    //       }
    //
    //       if(!inDrop){
    //         role9  = 'Other';
    //         other9.text = decryptedRole;
    //       }
    //     }
    //     if (transferReport[Strings.role10] != null) {
    //       setState(() {
    //         roleCount += 1;
    //       });
    //       String decryptedRole = GlobalFunctions.decryptString(transferReport[Strings.role10]);
    //       print(decryptedRole);
    //       bool inDrop = false;
    //
    //       for(String role in roleDrop){
    //         if(decryptedRole == role){
    //           inDrop = true;
    //           role10 = decryptedRole;
    //         }
    //       }
    //
    //       if(!inDrop){
    //         role10  = 'Other';
    //         other10.text = decryptedRole;
    //       }
    //     }
    //     if (transferReport[Strings.role11] != null) {
    //       setState(() {
    //         roleCount += 1;
    //       });
    //       String decryptedRole = GlobalFunctions.decryptString(transferReport[Strings.role11]);
    //       print(decryptedRole);
    //       bool inDrop = false;
    //
    //       for(String role in roleDrop){
    //         if(decryptedRole == role){
    //           inDrop = true;
    //           role11 = decryptedRole;
    //         }
    //       }
    //
    //       if(!inDrop){
    //         role11  = 'Other';
    //         other11.text = decryptedRole;
    //       }
    //     }
    //     setState(() {
    //       rowCount = roleCount;
    //     });
    //     GlobalFunctions.getTemporaryValue(transferReport, name2, Strings.name2);
    //     //GlobalFunctions.getTemporaryValue(transferReport, role2, Strings.role2);
    //     GlobalFunctions.getTemporaryValue(transferReport, name3, Strings.name3);
    //     //GlobalFunctions.getTemporaryValue(transferReport, role3, Strings.role3);
    //     GlobalFunctions.getTemporaryValue(transferReport, name4, Strings.name4);
    //     //GlobalFunctions.getTemporaryValue(transferReport, role4, Strings.role4);
    //     GlobalFunctions.getTemporaryValue(transferReport, name5, Strings.name5);
    //     //GlobalFunctions.getTemporaryValue(transferReport, role5, Strings.role5);
    //     GlobalFunctions.getTemporaryValue(transferReport, name6, Strings.name6);
    //     //GlobalFunctions.getTemporaryValue(transferReport, role6, Strings.role6);
    //     GlobalFunctions.getTemporaryValue(transferReport, name7, Strings.name7);
    //     //GlobalFunctions.getTemporaryValue(transferReport, role7, Strings.role7);
    //     GlobalFunctions.getTemporaryValue(transferReport, name8, Strings.name8);
    //     //GlobalFunctions.getTemporaryValue(transferReport, role8, Strings.role8);
    //     GlobalFunctions.getTemporaryValue(transferReport, name9, Strings.name9);
    //     //GlobalFunctions.getTemporaryValue(transferReport, role9, Strings.role9);
    //     GlobalFunctions.getTemporaryValue(transferReport, name10, Strings.name10);
    //     //GlobalFunctions.getTemporaryValue(transferReport, role10, Strings.role10);
    //     GlobalFunctions.getTemporaryValue(transferReport, name11, Strings.name11);
    //     //GlobalFunctions.getTemporaryValue(transferReport, role11, Strings.role11);
    //     GlobalFunctions.getTemporaryValue(transferReport, collectionUnit, Strings.collectionUnit);
    //     GlobalFunctions.getTemporaryValue(transferReport, collectionPosition, Strings.collectionPosition);
    //     GlobalFunctions.getTemporaryValue(transferReport, collectionPrintName, Strings.collectionPrintName);
    //     // if(transferReport[Strings.collectionPrintName] == null){
    //     //   collectionPrintName.text = user.name;
    //     //   _databaseHelper.updateTemporaryTransferReportField(widget.edit, {
    //     //     Strings.collectionPrintName: GlobalFunctions.encryptString(collectionPrintName.text)
    //     //   }, user.uid, widget.jobId, widget.saved, widget.savedId);
    //     // } else {
    //     //   GlobalFunctions.getTemporaryValue(transferReport, collectionPrintName, Strings.collectionPrintName);
    //     // }
    //     GlobalFunctions.getTemporaryValue(transferReport, destinationUnit, Strings.destinationUnit);
    //     GlobalFunctions.getTemporaryValue(transferReport, destinationPosition, Strings.destinationPosition);
    //     GlobalFunctions.getTemporaryValue(transferReport, destinationPrintName, Strings.destinationPrintName);
    //     // if(transferReport[Strings.destinationPrintName] == null){
    //     //   destinationPrintName.text = user.name;
    //     //   _databaseHelper.updateTemporaryTransferReportField(widget.edit, {
    //     //     Strings.destinationPrintName: GlobalFunctions.encryptString(destinationPrintName.text)
    //     //   }, user.uid, widget.jobId, widget.saved, widget.savedId);
    //     // } else {
    //     //   GlobalFunctions.getTemporaryValue(transferReport, destinationPrintName, Strings.destinationPrintName);
    //     // }
    //     GlobalFunctions.getTemporaryValueTime(transferReport, startTime, Strings.startTime);
    //     GlobalFunctions.getTemporaryValueTime(transferReport, finishTime, Strings.finishTime);
    //     GlobalFunctions.getTemporaryValueTime(transferReport, collectionArrivalTime, Strings.collectionArrivalTime);
    //     GlobalFunctions.getTemporaryValueTime(transferReport, collectionDepartureTime, Strings.collectionDepartureTime);
    //     GlobalFunctions.getTemporaryValueTime(transferReport, destinationArrivalTime, Strings.destinationArrivalTime);
    //     GlobalFunctions.getTemporaryValueTime(transferReport, destinationDepartureTime, Strings.destinationDepartureTime);
    //     GlobalFunctions.getTemporaryValueTime(transferReport, drivingTimes1_1, Strings.drivingTimes1_1);
    //     GlobalFunctions.getTemporaryValueTime(transferReport, drivingTimes1_2, Strings.drivingTimes1_2);
    //     GlobalFunctions.getTemporaryValueTime(transferReport, drivingTimes2_1, Strings.drivingTimes2_1);
    //     GlobalFunctions.getTemporaryValueTime(transferReport, drivingTimes2_2, Strings.drivingTimes2_2);
    //     GlobalFunctions.getTemporaryValueTime(transferReport, drivingTimes3_1, Strings.drivingTimes3_1);
    //     GlobalFunctions.getTemporaryValueTime(transferReport, drivingTimes3_2, Strings.drivingTimes3_2);
    //     GlobalFunctions.getTemporaryValueTime(transferReport, drivingTimes4_1, Strings.drivingTimes4_1);
    //     GlobalFunctions.getTemporaryValueTime(transferReport, drivingTimes4_2, Strings.drivingTimes4_2);
    //     GlobalFunctions.getTemporaryValueTime(transferReport, drivingTimes5_1, Strings.drivingTimes5_1);
    //     GlobalFunctions.getTemporaryValueTime(transferReport, drivingTimes5_2, Strings.drivingTimes5_2);
    //     GlobalFunctions.getTemporaryValueTime(transferReport, drivingTimes6_1, Strings.drivingTimes6_1);
    //     GlobalFunctions.getTemporaryValueTime(transferReport, drivingTimes6_2, Strings.drivingTimes6_2);
    //     GlobalFunctions.getTemporaryValueTime(transferReport, drivingTimes7_1, Strings.drivingTimes7_1);
    //     GlobalFunctions.getTemporaryValueTime(transferReport, drivingTimes7_2, Strings.drivingTimes7_2);
    //     GlobalFunctions.getTemporaryValueTime(transferReport, drivingTimes8_1, Strings.drivingTimes8_1);
    //     GlobalFunctions.getTemporaryValueTime(transferReport, drivingTimes8_2, Strings.drivingTimes8_2);
    //     GlobalFunctions.getTemporaryValueTime(transferReport, drivingTimes9_1, Strings.drivingTimes9_1);
    //     GlobalFunctions.getTemporaryValueTime(transferReport, drivingTimes9_2, Strings.drivingTimes9_2);
    //     GlobalFunctions.getTemporaryValueTime(transferReport, drivingTimes10_1, Strings.drivingTimes10_1);
    //     GlobalFunctions.getTemporaryValueTime(transferReport, drivingTimes10_2, Strings.drivingTimes10_2);
    //     GlobalFunctions.getTemporaryValueTime(transferReport, drivingTimes11_1, Strings.drivingTimes11_1);
    //     GlobalFunctions.getTemporaryValueTime(transferReport, drivingTimes11_2, Strings.drivingTimes11_2);
    //     GlobalFunctions.getTemporaryValueTime(transferReport, collectionArrivalTimeEnd, Strings.collectionArrivalTimeEnd);
    //     GlobalFunctions.getTemporaryValueTime(transferReport, destinationArrivalTimeEnd, Strings.destinationArrivalTimeEnd);
    //
    //     if (mounted) {
    //       setState(() {
    //         _loadingTemporary = false;
    //       });
    //     }
    //   } else {
    //     if (mounted) {
    //       setState(() {
    //         _loadingTemporary = false;
    //       });
    //     }
    //   }
    // }
  }

  _increaseRowCount(){
    if(rowCount == 5){
      GlobalFunctions.showToast('Maximum staff added');
    } else {
      setState(() {
        rowCount +=1;
      });
    }
  }

  _getBookingFormData() async{

    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('booking_forms').where(Strings.jobRef, isEqualTo: jobRef.text.toUpperCase()).where(Strings.assignedUserId, isEqualTo: user.uid).orderBy('timestamp', descending: true).limit(10).get().timeout(Duration(seconds: 90));


    if(snapshot.docs.length > 0){

      Map<String, dynamic> localRecord = snapshot.docs[0].data();

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
                  Row(children: [
                    Expanded(
                      child: _textFormField('Job Ref', jobRef, 1, true),
                    ),
                    SizedBox(width: 100, child: GradientButton('Search', () => _getBookingFormData()),)
                  ],),
                  _buildDateField('Date', date, Strings.date, true, false),
                  SizedBox(height: 20,),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('TRANSFER REPORT', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 18),),
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
                  Text('This is a legal and binding document and will be retained by the company for reference of any incidents that may occur in the event that we have been given any incorrect information. By signing this form, you are satisfied that all property, section papers and documents listed within this report have been handed over to Pegasus Medical (1808) Ltd.', style: TextStyle(color: bluePurple),),
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
                  Text('This is a legal and binding document and will be retained by the company for reference of any incidents that may occur in the event that we have been given any incorrect information. By signing this form, you are satisfied that all property, section papers and documents listed within this report have been handed over to Pegasus Medical (1808) Ltd.', style: TextStyle(color: bluePurple),),
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

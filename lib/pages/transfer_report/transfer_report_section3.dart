import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pegasus_medical_1808/models/transfer_report_model.dart';
import 'package:pegasus_medical_1808/shared/global_config.dart';
import 'package:pegasus_medical_1808/shared/global_functions.dart';
import 'package:pegasus_medical_1808/shared/strings.dart';
import 'package:pegasus_medical_1808/utils/database_helper.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:signature/signature.dart';

class TransferReportSection3 extends StatefulWidget {
  final bool fromJob;
  final String jobId;
  final bool fillDetails;
  final bool edit;
  final bool saved;
  final int savedId;

  TransferReportSection3(
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
  _TransferReportSection3State createState() => _TransferReportSection3State();
}

class _TransferReportSection3State extends State<TransferReportSection3> {

  bool _loadingTemporary = false;
  //DatabaseHelper _databaseHelper = DatabaseHelper();
  TransferReportModel transferReportModel;
  final dateFormat = DateFormat("dd/MM/yyyy");
  List<bool> boolValues = [];
  bool hasSection2Checklist = false;
  bool hasSection3Checklist = false;
  bool hasSection3TransferChecklist = false;
  bool patientCorrectYes1 = false;
  bool patientCorrectNo1 = false;
  bool hospitalCorrectYes1 = false;
  bool hospitalCorrectNo1 = false;
  bool applicationFormYes1 = false;
  bool applicationFormNo1 = false;
  bool applicationSignedYes1 = false;
  bool applicationSignedNo1 = false;
  bool within14DaysYes1 = false;
  bool within14DaysNo1 = false;
  bool localAuthorityNameYes1 = false;
  bool localAuthorityNameNo1 = false;
  bool medicalRecommendationsFormYes1 = false;
  bool medicalRecommendationsFormNo1 = false;
  bool medicalRecommendationsSignedYes1 = false;
  bool medicalRecommendationsSignedNo1 = false;
  bool datesSignatureSignedYes = false;
  bool datesSignatureSignedNo = false;
  bool signatureDatesOnBeforeYes1 = false;
  bool signatureDatesOnBeforeNo1 = false;
  bool practitionersNameYes1 = false;
  bool practitionersNameNo1 = false;
  bool patientCorrectYes2 = false;
  bool patientCorrectNo2 = false;
  bool hospitalCorrectYes2 = false;
  bool hospitalCorrectNo2 = false;
  bool applicationFormYes2 = false;
  bool applicationFormNo2 = false;
  bool applicationSignedYes2 = false;
  bool applicationSignedNo2 = false;
  bool amhpIdentifiedYes = false;
  bool amhpIdentifiedNo = false;
  bool medicalRecommendationsFormYes2 = false;
  bool medicalRecommendationsFormNo2 = false;
  bool medicalRecommendationsSignedYes2 = false;
  bool medicalRecommendationsSignedNo2 = false;
  bool clearDaysYes2 = false;
  bool clearDaysNo2 = false;
  bool signatureDatesOnBeforeYes2 = false;
  bool signatureDatesOnBeforeNo2 = false;
  bool practitionersNameYes2 = false;
  bool practitionersNameNo2 = false;
  bool doctorsAgreeYes = false;
  bool doctorsAgreeNo = false;
  bool separateMedicalRecommendationsYes = false;
  bool separateMedicalRecommendationsNo = false;
  bool patientCorrectYes3 = false;
  bool patientCorrectNo3 = false;
  bool hospitalCorrectYes3 = false;
  bool hospitalCorrectNo3 = false;
  bool h4Yes = false;
  bool h4No = false;
  bool currentConsentYes = false;
  bool currentConsentNo = false;
  bool applicationFormYes3 = false;
  bool applicationFormNo3 = false;
  bool applicationSignedYes3 = false;
  bool applicationSignedNo3 = false;
  bool within14DaysYes3 = false;
  bool within14DaysNo3 = false;
  bool localAuthorityNameYes3 = false;
  bool localAuthorityNameNo3 = false;
  bool nearestRelativeYes = false;
  bool nearestRelativeNo = false;
  bool amhpConsultationYes = false;
  bool amhpConsultationNo = false;
  bool knewPatientYes = false;
  bool knewPatientNo = false;
  bool medicalRecommendationsFormYes3 = false;
  bool medicalRecommendationsFormNo3 = false;
  bool medicalRecommendationsSignedYes3 = false;
  bool medicalRecommendationsSignedNo3 = false;
  bool clearDaysYes3 = false;
  bool clearDaysNo3 = false;
  bool approvedSection12Yes = false;
  bool approvedSection12No = false;
  bool signatureDatesOnBeforeYes3 = false;
  bool signatureDatesOnBeforeNo3 = false;
  bool practitionersNameYes3 = false;
  bool practitionersNameNo3 = false;
  bool previouslyAcquaintedYes = false;
  bool previouslyAcquaintedNo = false;
  bool acquaintedIfNoYes = false;
  bool acquaintedIfNoNo = false;
  bool recommendationsDifferentTeamsYes = false;
  bool recommendationsDifferentTeamsNo = false;
  bool originalDetentionPapersYes = false;
  bool originalDetentionPapersNo = false;

  List<Point> transferInSignaturePoints1 = [];
  Signature transferInSignature1;
  Uint8List transferInImageBytes1;

  List<Point> transferInSignaturePoints2 = [];
  Signature transferInSignature2;
  Uint8List transferInImageBytes2;

  List<Point> transferInSignaturePoints3 = [];
  Signature transferInSignature3;
  Uint8List transferInImageBytes3;

  final TextEditingController patientName = TextEditingController();
  final TextEditingController transferInCheckedBy1 = TextEditingController();
  final TextEditingController transferInDate1 = TextEditingController();
  final TextEditingController transferInDesignation1 = TextEditingController();
  final TextEditingController transferInCheckedBy2 = TextEditingController();
  final TextEditingController transferInDate2 = TextEditingController();
  final TextEditingController transferInDesignation2 = TextEditingController();
  final TextEditingController transferInCheckedBy3 = TextEditingController();
  final TextEditingController transferInDate3 = TextEditingController();
  final TextEditingController transferInDesignation3 = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    _loadingTemporary = true;
    transferReportModel = Provider.of<TransferReportModel>(context, listen: false);
    _setUpTextControllerListeners();
    _getTemporaryTransferReport();
    super.initState();
  }

  @override
  void dispose() {
    patientName.dispose();
    transferInCheckedBy1.dispose();
    transferInDate1.dispose();
    transferInDesignation1.dispose();
    transferInCheckedBy2.dispose();
    transferInDate2.dispose();
    transferInDesignation2.dispose();
    transferInCheckedBy3.dispose();
    transferInDate3.dispose();
    transferInDesignation3.dispose();
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

      transferReportModel.updateTemporaryRecord(widget.edit, value, encrypt ? GlobalFunctions.encryptString(controllerText) : GlobalFunctions.databaseValueString(controllerText), widget.jobId, widget.saved, widget.savedId);
      // _databaseHelper.updateTemporaryTransferReportField(widget.edit, {
      //   value:
      //   encrypt ? GlobalFunctions.encryptString(controllerText) : GlobalFunctions.databaseValueString(controllerText)
      // }, user.uid, widget.jobId, widget.saved, widget.savedId);
    });
  }

  _setUpTextControllerListeners() {
    _addListener(patientName, Strings.patientName, true, false, true);
    _addListener(transferInCheckedBy1, Strings.transferInCheckedBy1, true, false, true);
    _addListener(transferInDesignation1, Strings.transferInDesignation1);
    _addListener(patientName, Strings.patientName, true, false, true);
    _addListener(transferInCheckedBy2, Strings.transferInCheckedBy2, true, false, true);
    _addListener(transferInDesignation2, Strings.transferInDesignation2);
    _addListener(patientName, Strings.patientName, true, false, true);
    _addListener(transferInCheckedBy3, Strings.transferInCheckedBy3, true, false, true);
    _addListener(transferInDesignation3, Strings.transferInDesignation3);
  }





  _getTemporaryTransferReport() async {

    if (mounted) {
      bool hasRecord = await transferReportModel.checkRecordExists(widget.edit, widget.jobId, widget.saved, widget.savedId);

      if(hasRecord){
        Map<String, dynamic> transferReport = await transferReportModel.getTemporaryRecord(widget.edit, widget.jobId, widget.saved, widget.savedId);

        if (transferReport[Strings.transferInSignature1] != null) {
          if (mounted) {
            Uint8List decryptedSignature = await GlobalFunctions.decryptSignature(transferReport[Strings.transferInSignature1]);
            setState(() {
              transferInImageBytes1 = decryptedSignature;
            });
          }
        } else {
          transferInSignature1 = null;
          transferInImageBytes1 = null;
        }
        if (transferReport[Strings.transferInSignaturePoints1] != null) {
          if (mounted) {
            String decryptedPoints = GlobalFunctions.decryptString(transferReport[Strings.transferInSignaturePoints1]);
            setState(() {
              List<dynamic> fetchedSignaturePoints = jsonDecode(decryptedPoints);
              fetchedSignaturePoints.forEach((dynamic pointMap) {
                if (pointMap['pointType'] == 'tap') {
                  transferInSignaturePoints1.add(Point(
                      Offset(pointMap['dx'], pointMap['dy']),
                      PointType.tap));
                } else if (pointMap['pointType'] == 'move') {
                  transferInSignaturePoints1.add(Point(
                      Offset(pointMap['dx'], pointMap['dy']),
                      PointType.move));
                }
              });
            });
          }
        } else {
          transferInSignaturePoints1 = [];

        }
        if (transferReport[Strings.transferInSignature2] != null) {
          if (mounted) {
            Uint8List decryptedSignature = await GlobalFunctions.decryptSignature(transferReport[Strings.transferInSignature2]);
            setState(() {
              transferInImageBytes2 = decryptedSignature;
            });
          }
        } else {
          transferInSignature2 = null;
          transferInImageBytes2 = null;
        }
        if (transferReport[Strings.transferInSignaturePoints2] != null) {
          if (mounted) {
            String decryptedPoints = GlobalFunctions.decryptString(transferReport[Strings.transferInSignaturePoints2]);
            setState(() {
              List<dynamic> fetchedSignaturePoints = jsonDecode(decryptedPoints);
              fetchedSignaturePoints.forEach((dynamic pointMap) {
                if (pointMap['pointType'] == 'tap') {
                  transferInSignaturePoints2.add(Point(
                      Offset(pointMap['dx'], pointMap['dy']),
                      PointType.tap));
                } else if (pointMap['pointType'] == 'move') {
                  transferInSignaturePoints2.add(Point(
                      Offset(pointMap['dx'], pointMap['dy']),
                      PointType.move));
                }
              });
            });
          }
        } else {
          transferInSignaturePoints2 = [];

        }
        if (transferReport[Strings.transferInSignature3] != null) {
          if (mounted) {
            Uint8List decryptedSignature = await GlobalFunctions.decryptSignature(transferReport[Strings.transferInSignature3]);
            setState(() {
              transferInImageBytes3 = decryptedSignature;
            });
          }
        } else {
          transferInSignature3 = null;
          transferInImageBytes3 = null;
        }
        if (transferReport[Strings.transferInSignaturePoints3] != null) {
          if (mounted) {
            String decryptedPoints = GlobalFunctions.decryptString(transferReport[Strings.transferInSignaturePoints3]);
            setState(() {
              List<dynamic> fetchedSignaturePoints = jsonDecode(decryptedPoints);
              fetchedSignaturePoints.forEach((dynamic pointMap) {
                if (pointMap['pointType'] == 'tap') {
                  transferInSignaturePoints3.add(Point(
                      Offset(pointMap['dx'], pointMap['dy']),
                      PointType.tap));
                } else if (pointMap['pointType'] == 'move') {
                  transferInSignaturePoints3.add(Point(
                      Offset(pointMap['dx'], pointMap['dy']),
                      PointType.move));
                }
              });
            });
          }
        } else {
          transferInSignaturePoints3 = [];

        }


        if (transferReport[Strings.hasSection2Checklist] != null) {
          if (mounted) {
            setState(() {
              hasSection2Checklist = GlobalFunctions.tinyIntToBool(transferReport[Strings.hasSection2Checklist]);
            });
          }
        }
        if (transferReport[Strings.hasSection3Checklist] != null) {
          if (mounted) {
            setState(() {
              hasSection3Checklist = GlobalFunctions.tinyIntToBool(transferReport[Strings.hasSection3Checklist]);
            });
          }
        }
        if (transferReport[Strings.hasSection3TransferChecklist] != null) {
          if (mounted) {
            setState(() {
              hasSection3TransferChecklist = GlobalFunctions.tinyIntToBool(transferReport[Strings.hasSection3TransferChecklist]);
            });
          }
        }


        GlobalFunctions.getTemporaryValue(transferReport, patientName, Strings.patientName);
        GlobalFunctions.getTemporaryValue(transferReport, transferInCheckedBy1, Strings.transferInCheckedBy1);
        GlobalFunctions.getTemporaryValue(transferReport, transferInDesignation1, Strings.transferInDesignation1);
        GlobalFunctions.getTemporaryValue(transferReport, patientName, Strings.patientName);
        GlobalFunctions.getTemporaryValue(transferReport, transferInCheckedBy2, Strings.transferInCheckedBy2);
        GlobalFunctions.getTemporaryValue(transferReport, transferInDesignation2, Strings.transferInDesignation2);
        GlobalFunctions.getTemporaryValue(transferReport, patientName, Strings.patientName);
        GlobalFunctions.getTemporaryValue(transferReport, transferInCheckedBy3, Strings.transferInCheckedBy3);
        GlobalFunctions.getTemporaryValue(transferReport, transferInDesignation3, Strings.transferInDesignation3);
        GlobalFunctions.getTemporaryValueDate(transferReport, transferInDate1, Strings.transferInDate1);
        GlobalFunctions.getTemporaryValueDate(transferReport, transferInDate2, Strings.transferInDate2);
        GlobalFunctions.getTemporaryValueDate(transferReport, transferInDate3, Strings.transferInDate3);

        if (transferReport[Strings.patientCorrectYes1] != null) {
          if (mounted) {
            setState(() {
              patientCorrectYes1 = GlobalFunctions.tinyIntToBool(transferReport[Strings.patientCorrectYes1]);
            });
          }
        }
        if (transferReport[Strings.patientCorrectNo1] != null) {
          if (mounted) {
            setState(() {
              patientCorrectNo1 = GlobalFunctions.tinyIntToBool(transferReport[Strings.patientCorrectNo1]);
            });
          }
        }
        if (transferReport[Strings.hospitalCorrectYes1] != null) {
          if (mounted) {
            setState(() {
              hospitalCorrectYes1 = GlobalFunctions.tinyIntToBool(transferReport[Strings.hospitalCorrectYes1]);
            });
          }
        }
        if (transferReport[Strings.hospitalCorrectNo1] != null) {
          if (mounted) {
            setState(() {
              hospitalCorrectNo1 = GlobalFunctions.tinyIntToBool(transferReport[Strings.hospitalCorrectNo1]);
            });
          }
        }
        if (transferReport[Strings.applicationFormYes1] != null) {
          if (mounted) {
            setState(() {
              applicationFormYes1 = GlobalFunctions.tinyIntToBool(transferReport[Strings.applicationFormYes1]);
            });
          }
        }
        if (transferReport[Strings.applicationFormNo1] != null) {
          if (mounted) {
            setState(() {
              applicationFormNo1 = GlobalFunctions.tinyIntToBool(transferReport[Strings.applicationFormNo1]);
            });
          }
        }
        if (transferReport[Strings.applicationSignedYes1] != null) {
          if (mounted) {
            setState(() {
              applicationSignedYes1 = GlobalFunctions.tinyIntToBool(transferReport[Strings.applicationSignedYes1]);
            });
          }
        }
        if (transferReport[Strings.applicationSignedNo1] != null) {
          if (mounted) {
            setState(() {
              applicationSignedNo1 = GlobalFunctions.tinyIntToBool(transferReport[Strings.applicationSignedNo1]);
            });
          }
        }
        if (transferReport[Strings.within14DaysYes1] != null) {
          if (mounted) {
            setState(() {
              within14DaysYes1 = GlobalFunctions.tinyIntToBool(transferReport[Strings.within14DaysYes1]);
            });
          }
        }
        if (transferReport[Strings.within14DaysNo1] != null) {
          if (mounted) {
            setState(() {
              within14DaysNo1 = GlobalFunctions.tinyIntToBool(transferReport[Strings.within14DaysNo1]);
            });
          }
        }
        if (transferReport[Strings.localAuthorityNameYes1] != null) {
          if (mounted) {
            setState(() {
              localAuthorityNameYes1 = GlobalFunctions.tinyIntToBool(transferReport[Strings.localAuthorityNameYes1]);
            });
          }
        }
        if (transferReport[Strings.localAuthorityNameNo1] != null) {
          if (mounted) {
            setState(() {
              localAuthorityNameNo1 = GlobalFunctions.tinyIntToBool(transferReport[Strings.localAuthorityNameNo1]);
            });
          }
        }
        if (transferReport[Strings.medicalRecommendationsFormYes1] != null) {
          if (mounted) {
            setState(() {
              medicalRecommendationsFormYes1 = GlobalFunctions.tinyIntToBool(transferReport[Strings.medicalRecommendationsFormYes1]);
            });
          }
        }
        if (transferReport[Strings.medicalRecommendationsFormNo1] != null) {
          if (mounted) {
            setState(() {
              medicalRecommendationsFormNo1 = GlobalFunctions.tinyIntToBool(transferReport[Strings.medicalRecommendationsFormNo1]);
            });
          }
        }
        if (transferReport[Strings.medicalRecommendationsSignedYes1] != null) {
          if (mounted) {
            setState(() {
              medicalRecommendationsSignedYes1 = GlobalFunctions.tinyIntToBool(transferReport[Strings.medicalRecommendationsSignedYes1]);
            });
          }
        }
        if (transferReport[Strings.medicalRecommendationsSignedNo1] != null) {
          if (mounted) {
            setState(() {
              medicalRecommendationsSignedNo1 = GlobalFunctions.tinyIntToBool(transferReport[Strings.medicalRecommendationsSignedNo1]);
            });
          }
        }
        if (transferReport[Strings.datesSignatureSignedYes] != null) {
          if (mounted) {
            setState(() {
              datesSignatureSignedYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.datesSignatureSignedYes]);
            });
          }
        }
        if (transferReport[Strings.datesSignatureSignedNo] != null) {
          if (mounted) {
            setState(() {
              datesSignatureSignedNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.datesSignatureSignedNo]);
            });
          }
        }
        if (transferReport[Strings.signatureDatesOnBeforeYes1] != null) {
          if (mounted) {
            setState(() {
              signatureDatesOnBeforeYes1 = GlobalFunctions.tinyIntToBool(transferReport[Strings.signatureDatesOnBeforeYes1]);
            });
          }
        }
        if (transferReport[Strings.signatureDatesOnBeforeNo1] != null) {
          if (mounted) {
            setState(() {
              signatureDatesOnBeforeNo1 = GlobalFunctions.tinyIntToBool(transferReport[Strings.signatureDatesOnBeforeNo1]);
            });
          }
        }
        if (transferReport[Strings.practitionersNameYes1] != null) {
          if (mounted) {
            setState(() {
              practitionersNameYes1 = GlobalFunctions.tinyIntToBool(transferReport[Strings.practitionersNameYes1]);
            });
          }
        }
        if (transferReport[Strings.practitionersNameNo1] != null) {
          if (mounted) {
            setState(() {
              practitionersNameNo1 = GlobalFunctions.tinyIntToBool(transferReport[Strings.practitionersNameNo1]);
            });
          }
        }
        if (transferReport[Strings.patientCorrectYes2] != null) {
          if (mounted) {
            setState(() {
              patientCorrectYes2 = GlobalFunctions.tinyIntToBool(transferReport[Strings.patientCorrectYes2]);
            });
          }
        }
        if (transferReport[Strings.patientCorrectNo2] != null) {
          if (mounted) {
            setState(() {
              patientCorrectNo2 = GlobalFunctions.tinyIntToBool(transferReport[Strings.patientCorrectNo2]);
            });
          }
        }
        if (transferReport[Strings.hospitalCorrectYes2] != null) {
          if (mounted) {
            setState(() {
              hospitalCorrectYes2 = GlobalFunctions.tinyIntToBool(transferReport[Strings.hospitalCorrectYes2]);
            });
          }
        }
        if (transferReport[Strings.hospitalCorrectNo2] != null) {
          if (mounted) {
            setState(() {
              hospitalCorrectNo2 = GlobalFunctions.tinyIntToBool(transferReport[Strings.hospitalCorrectNo2]);
            });
          }
        }
        if (transferReport[Strings.applicationFormYes2] != null) {
          if (mounted) {
            setState(() {
              applicationFormYes2 = GlobalFunctions.tinyIntToBool(transferReport[Strings.applicationFormYes2]);
            });
          }
        }
        if (transferReport[Strings.applicationFormNo2] != null) {
          if (mounted) {
            setState(() {
              applicationFormNo2 = GlobalFunctions.tinyIntToBool(transferReport[Strings.applicationFormNo2]);
            });
          }
        }
        if (transferReport[Strings.applicationSignedYes2] != null) {
          if (mounted) {
            setState(() {
              applicationSignedYes2 = GlobalFunctions.tinyIntToBool(transferReport[Strings.applicationSignedYes2]);
            });
          }
        }
        if (transferReport[Strings.applicationSignedNo2] != null) {
          if (mounted) {
            setState(() {
              applicationSignedNo2 = GlobalFunctions.tinyIntToBool(transferReport[Strings.applicationSignedNo2]);
            });
          }
        }
        if (transferReport[Strings.amhpIdentifiedYes] != null) {
          if (mounted) {
            setState(() {
              amhpIdentifiedYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.amhpIdentifiedYes]);
            });
          }
        }
        if (transferReport[Strings.amhpIdentifiedNo] != null) {
          if (mounted) {
            setState(() {
              amhpIdentifiedNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.amhpIdentifiedNo]);
            });
          }
        }
        if (transferReport[Strings.medicalRecommendationsFormYes2] != null) {
          if (mounted) {
            setState(() {
              medicalRecommendationsFormYes2 = GlobalFunctions.tinyIntToBool(transferReport[Strings.medicalRecommendationsFormYes2]);
            });
          }
        }
        if (transferReport[Strings.medicalRecommendationsFormNo2] != null) {
          if (mounted) {
            setState(() {
              medicalRecommendationsFormNo2 = GlobalFunctions.tinyIntToBool(transferReport[Strings.medicalRecommendationsFormNo2]);
            });
          }
        }
        if (transferReport[Strings.medicalRecommendationsSignedYes2] != null) {
          if (mounted) {
            setState(() {
              medicalRecommendationsSignedYes2 = GlobalFunctions.tinyIntToBool(transferReport[Strings.medicalRecommendationsSignedYes2]);
            });
          }
        }
        if (transferReport[Strings.medicalRecommendationsSignedNo2] != null) {
          if (mounted) {
            setState(() {
              medicalRecommendationsSignedNo2 = GlobalFunctions.tinyIntToBool(transferReport[Strings.medicalRecommendationsSignedNo2]);
            });
          }
        }
        if (transferReport[Strings.clearDaysYes2] != null) {
          if (mounted) {
            setState(() {
              clearDaysYes2 = GlobalFunctions.tinyIntToBool(transferReport[Strings.clearDaysYes2]);
            });
          }
        }
        if (transferReport[Strings.clearDaysNo2] != null) {
          if (mounted) {
            setState(() {
              clearDaysNo2 = GlobalFunctions.tinyIntToBool(transferReport[Strings.clearDaysNo2]);
            });
          }
        }
        if (transferReport[Strings.signatureDatesOnBeforeYes2] != null) {
          if (mounted) {
            setState(() {
              signatureDatesOnBeforeYes2 = GlobalFunctions.tinyIntToBool(transferReport[Strings.signatureDatesOnBeforeYes2]);
            });
          }
        }
        if (transferReport[Strings.signatureDatesOnBeforeNo2] != null) {
          if (mounted) {
            setState(() {
              signatureDatesOnBeforeNo2 = GlobalFunctions.tinyIntToBool(transferReport[Strings.signatureDatesOnBeforeNo2]);
            });
          }
        }
        if (transferReport[Strings.practitionersNameYes2] != null) {
          if (mounted) {
            setState(() {
              practitionersNameYes2 = GlobalFunctions.tinyIntToBool(transferReport[Strings.practitionersNameYes2]);
            });
          }
        }
        if (transferReport[Strings.practitionersNameNo2] != null) {
          if (mounted) {
            setState(() {
              practitionersNameNo2 = GlobalFunctions.tinyIntToBool(transferReport[Strings.practitionersNameNo2]);
            });
          }
        }
        if (transferReport[Strings.doctorsAgreeYes] != null) {
          if (mounted) {
            setState(() {
              doctorsAgreeYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.doctorsAgreeYes]);
            });
          }
        }
        if (transferReport[Strings.doctorsAgreeNo] != null) {
          if (mounted) {
            setState(() {
              doctorsAgreeNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.doctorsAgreeNo]);
            });
          }
        }
        if (transferReport[Strings.separateMedicalRecommendationsYes] != null) {
          if (mounted) {
            setState(() {
              separateMedicalRecommendationsYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.separateMedicalRecommendationsYes]);
            });
          }
        }
        if (transferReport[Strings.separateMedicalRecommendationsNo] != null) {
          if (mounted) {
            setState(() {
              separateMedicalRecommendationsNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.separateMedicalRecommendationsNo]);
            });
          }
        }
        if (transferReport[Strings.patientCorrectYes3] != null) {
          if (mounted) {
            setState(() {
              patientCorrectYes3 = GlobalFunctions.tinyIntToBool(transferReport[Strings.patientCorrectYes3]);
            });
          }
        }
        if (transferReport[Strings.patientCorrectNo3] != null) {
          if (mounted) {
            setState(() {
              patientCorrectNo3 = GlobalFunctions.tinyIntToBool(transferReport[Strings.patientCorrectNo3]);
            });
          }
        }
        if (transferReport[Strings.hospitalCorrectYes3] != null) {
          if (mounted) {
            setState(() {
              hospitalCorrectYes3 = GlobalFunctions.tinyIntToBool(transferReport[Strings.hospitalCorrectYes3]);
            });
          }
        }
        if (transferReport[Strings.hospitalCorrectNo3] != null) {
          if (mounted) {
            setState(() {
              hospitalCorrectNo3 = GlobalFunctions.tinyIntToBool(transferReport[Strings.hospitalCorrectNo3]);
            });
          }
        }
        if (transferReport[Strings.h4Yes] != null) {
          if (mounted) {
            setState(() {
              h4Yes = GlobalFunctions.tinyIntToBool(transferReport[Strings.h4Yes]);
            });
          }
        }
        if (transferReport[Strings.h4No] != null) {
          if (mounted) {
            setState(() {
              h4No = GlobalFunctions.tinyIntToBool(transferReport[Strings.h4No]);
            });
          }
        }
        if (transferReport[Strings.currentConsentYes] != null) {
          if (mounted) {
            setState(() {
              currentConsentYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.currentConsentYes]);
            });
          }
        }
        if (transferReport[Strings.currentConsentNo] != null) {
          if (mounted) {
            setState(() {
              currentConsentNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.currentConsentNo]);
            });
          }
        }
        if (transferReport[Strings.applicationFormYes3] != null) {
          if (mounted) {
            setState(() {
              applicationFormYes3 = GlobalFunctions.tinyIntToBool(transferReport[Strings.applicationFormYes3]);
            });
          }
        }
        if (transferReport[Strings.applicationFormNo3] != null) {
          if (mounted) {
            setState(() {
              applicationFormNo3 = GlobalFunctions.tinyIntToBool(transferReport[Strings.applicationFormNo3]);
            });
          }
        }
        if (transferReport[Strings.applicationSignedYes3] != null) {
          if (mounted) {
            setState(() {
              applicationSignedYes3 = GlobalFunctions.tinyIntToBool(transferReport[Strings.applicationSignedYes3]);
            });
          }
        }
        if (transferReport[Strings.applicationSignedNo3] != null) {
          if (mounted) {
            setState(() {
              applicationSignedNo3 = GlobalFunctions.tinyIntToBool(transferReport[Strings.applicationSignedNo3]);
            });
          }
        }
        if (transferReport[Strings.within14DaysYes3] != null) {
          if (mounted) {
            setState(() {
              within14DaysYes3 = GlobalFunctions.tinyIntToBool(transferReport[Strings.within14DaysYes3]);
            });
          }
        }
        if (transferReport[Strings.within14DaysNo3] != null) {
          if (mounted) {
            setState(() {
              within14DaysNo3 = GlobalFunctions.tinyIntToBool(transferReport[Strings.within14DaysNo3]);
            });
          }
        }
        if (transferReport[Strings.localAuthorityNameYes3] != null) {
          if (mounted) {
            setState(() {
              localAuthorityNameYes3 = GlobalFunctions.tinyIntToBool(transferReport[Strings.localAuthorityNameYes3]);
            });
          }
        }
        if (transferReport[Strings.localAuthorityNameNo3] != null) {
          if (mounted) {
            setState(() {
              localAuthorityNameNo3 = GlobalFunctions.tinyIntToBool(transferReport[Strings.localAuthorityNameNo3]);
            });
          }
        }
        if (transferReport[Strings.nearestRelativeYes] != null) {
          if (mounted) {
            setState(() {
              nearestRelativeYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.nearestRelativeYes]);
            });
          }
        }
        if (transferReport[Strings.nearestRelativeNo] != null) {
          if (mounted) {
            setState(() {
              nearestRelativeNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.nearestRelativeNo]);
            });
          }
        }
        if (transferReport[Strings.amhpConsultationYes] != null) {
          if (mounted) {
            setState(() {
              amhpConsultationYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.amhpConsultationYes]);
            });
          }
        }
        if (transferReport[Strings.amhpConsultationNo] != null) {
          if (mounted) {
            setState(() {
              amhpConsultationNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.amhpConsultationNo]);
            });
          }
        }
        if (transferReport[Strings.knewPatientYes] != null) {
          if (mounted) {
            setState(() {
              knewPatientYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.knewPatientYes]);
            });
          }
        }
        if (transferReport[Strings.knewPatientNo] != null) {
          if (mounted) {
            setState(() {
              knewPatientNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.knewPatientNo]);
            });
          }
        }
        if (transferReport[Strings.medicalRecommendationsFormYes3] != null) {
          if (mounted) {
            setState(() {
              medicalRecommendationsFormYes3 = GlobalFunctions.tinyIntToBool(transferReport[Strings.medicalRecommendationsFormYes3]);
            });
          }
        }
        if (transferReport[Strings.medicalRecommendationsFormNo3] != null) {
          if (mounted) {
            setState(() {
              medicalRecommendationsFormNo3 = GlobalFunctions.tinyIntToBool(transferReport[Strings.medicalRecommendationsFormNo3]);
            });
          }
        }
        if (transferReport[Strings.medicalRecommendationsSignedYes3] != null) {
          if (mounted) {
            setState(() {
              medicalRecommendationsSignedYes3 = GlobalFunctions.tinyIntToBool(transferReport[Strings.medicalRecommendationsSignedYes3]);
            });
          }
        }
        if (transferReport[Strings.medicalRecommendationsSignedNo3] != null) {
          if (mounted) {
            setState(() {
              medicalRecommendationsSignedNo3 = GlobalFunctions.tinyIntToBool(transferReport[Strings.medicalRecommendationsSignedNo3]);
            });
          }
        }
        if (transferReport[Strings.clearDaysYes3] != null) {
          if (mounted) {
            setState(() {
              clearDaysYes3 = GlobalFunctions.tinyIntToBool(transferReport[Strings.clearDaysYes3]);
            });
          }
        }
        if (transferReport[Strings.clearDaysNo3] != null) {
          if (mounted) {
            setState(() {
              clearDaysNo3= GlobalFunctions.tinyIntToBool(transferReport[Strings.clearDaysNo3]);
            });
          }
        }
        if (transferReport[Strings.approvedSection12Yes] != null) {
          if (mounted) {
            setState(() {
              approvedSection12Yes = GlobalFunctions.tinyIntToBool(transferReport[Strings.approvedSection12Yes]);
            });
          }
        }
        if (transferReport[Strings.approvedSection12No] != null) {
          if (mounted) {
            setState(() {
              approvedSection12No = GlobalFunctions.tinyIntToBool(transferReport[Strings.approvedSection12No]);
            });
          }
        }
        if (transferReport[Strings.signatureDatesOnBeforeYes3] != null) {
          if (mounted) {
            setState(() {
              signatureDatesOnBeforeYes3 = GlobalFunctions.tinyIntToBool(transferReport[Strings.signatureDatesOnBeforeYes3]);
            });
          }
        }
        if (transferReport[Strings.signatureDatesOnBeforeNo3] != null) {
          if (mounted) {
            setState(() {
              signatureDatesOnBeforeNo3 = GlobalFunctions.tinyIntToBool(transferReport[Strings.signatureDatesOnBeforeNo3]);
            });
          }
        }
        if (transferReport[Strings.practitionersNameYes3] != null) {
          if (mounted) {
            setState(() {
              practitionersNameYes3 = GlobalFunctions.tinyIntToBool(transferReport[Strings.practitionersNameYes3]);
            });
          }
        }
        if (transferReport[Strings.practitionersNameNo3] != null) {
          if (mounted) {
            setState(() {
              practitionersNameNo3 = GlobalFunctions.tinyIntToBool(transferReport[Strings.practitionersNameNo3]);
            });
          }
        }
        if (transferReport[Strings.previouslyAcquaintedYes] != null) {
          if (mounted) {
            setState(() {
              previouslyAcquaintedYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.previouslyAcquaintedYes]);
            });
          }
        }
        if (transferReport[Strings.previouslyAcquaintedNo] != null) {
          if (mounted) {
            setState(() {
              previouslyAcquaintedNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.previouslyAcquaintedNo]);
            });
          }
        }
        if (transferReport[Strings.acquaintedIfNoYes] != null) {
          if (mounted) {
            setState(() {
              acquaintedIfNoYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.acquaintedIfNoYes]);
            });
          }
        }
        if (transferReport[Strings.acquaintedIfNoNo] != null) {
          if (mounted) {
            setState(() {
              acquaintedIfNoNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.acquaintedIfNoNo]);
            });
          }
        }
        if (transferReport[Strings.recommendationsDifferentTeamsYes] != null) {
          if (mounted) {
            setState(() {
              recommendationsDifferentTeamsYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.recommendationsDifferentTeamsYes]);
            });
          }
        }
        if (transferReport[Strings.recommendationsDifferentTeamsNo] != null) {
          if (mounted) {
            setState(() {
              recommendationsDifferentTeamsNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.recommendationsDifferentTeamsNo]);
            });
          }
        }
        if (transferReport[Strings.originalDetentionPapersYes] != null) {
          if (mounted) {
            setState(() {
              originalDetentionPapersYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.originalDetentionPapersYes]);
            });
          }
        }
        if (transferReport[Strings.originalDetentionPapersNo] != null) {
          if (mounted) {
            setState(() {
              originalDetentionPapersNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.originalDetentionPapersNo]);
            });
          }
        }

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
    //     Map<String, dynamic> transferReport = await _databaseHelper.getTemporaryTransferReport(widget.edit, user.uid, widget.jobId, widget.saved, widget.savedId);
    //
    //     if (transferReport[Strings.transferInSignature1] != null) {
    //       if (mounted) {
    //         Uint8List decryptedSignature = await GlobalFunctions.decryptSignature(transferReport[Strings.transferInSignature1]);
    //         setState(() {
    //           transferInImageBytes1 = decryptedSignature;
    //         });
    //       }
    //     } else {
    //       transferInSignature1 = null;
    //       transferInImageBytes1 = null;
    //     }
    //     if (transferReport[Strings.transferInSignaturePoints1] != null) {
    //       if (mounted) {
    //         String decryptedPoints = GlobalFunctions.decryptString(transferReport[Strings.transferInSignaturePoints1]);
    //         setState(() {
    //           List<dynamic> fetchedSignaturePoints = jsonDecode(decryptedPoints);
    //           fetchedSignaturePoints.forEach((dynamic pointMap) {
    //             if (pointMap['pointType'] == 'tap') {
    //               transferInSignaturePoints1.add(Point(
    //                   Offset(pointMap['dx'], pointMap['dy']),
    //                   PointType.tap));
    //             } else if (pointMap['pointType'] == 'move') {
    //               transferInSignaturePoints1.add(Point(
    //                   Offset(pointMap['dx'], pointMap['dy']),
    //                   PointType.move));
    //             }
    //           });
    //         });
    //       }
    //     } else {
    //       transferInSignaturePoints1 = [];
    //
    //     }
    //     if (transferReport[Strings.transferInSignature2] != null) {
    //       if (mounted) {
    //         Uint8List decryptedSignature = await GlobalFunctions.decryptSignature(transferReport[Strings.transferInSignature2]);
    //         setState(() {
    //           transferInImageBytes2 = decryptedSignature;
    //         });
    //       }
    //     } else {
    //       transferInSignature2 = null;
    //       transferInImageBytes2 = null;
    //     }
    //     if (transferReport[Strings.transferInSignaturePoints2] != null) {
    //       if (mounted) {
    //         String decryptedPoints = GlobalFunctions.decryptString(transferReport[Strings.transferInSignaturePoints2]);
    //         setState(() {
    //           List<dynamic> fetchedSignaturePoints = jsonDecode(decryptedPoints);
    //           fetchedSignaturePoints.forEach((dynamic pointMap) {
    //             if (pointMap['pointType'] == 'tap') {
    //               transferInSignaturePoints2.add(Point(
    //                   Offset(pointMap['dx'], pointMap['dy']),
    //                   PointType.tap));
    //             } else if (pointMap['pointType'] == 'move') {
    //               transferInSignaturePoints2.add(Point(
    //                   Offset(pointMap['dx'], pointMap['dy']),
    //                   PointType.move));
    //             }
    //           });
    //         });
    //       }
    //     } else {
    //       transferInSignaturePoints2 = [];
    //
    //     }
    //     if (transferReport[Strings.transferInSignature3] != null) {
    //       if (mounted) {
    //         Uint8List decryptedSignature = await GlobalFunctions.decryptSignature(transferReport[Strings.transferInSignature3]);
    //         setState(() {
    //           transferInImageBytes3 = decryptedSignature;
    //         });
    //       }
    //     } else {
    //       transferInSignature3 = null;
    //       transferInImageBytes3 = null;
    //     }
    //     if (transferReport[Strings.transferInSignaturePoints3] != null) {
    //       if (mounted) {
    //         String decryptedPoints = GlobalFunctions.decryptString(transferReport[Strings.transferInSignaturePoints3]);
    //         setState(() {
    //           List<dynamic> fetchedSignaturePoints = jsonDecode(decryptedPoints);
    //           fetchedSignaturePoints.forEach((dynamic pointMap) {
    //             if (pointMap['pointType'] == 'tap') {
    //               transferInSignaturePoints3.add(Point(
    //                   Offset(pointMap['dx'], pointMap['dy']),
    //                   PointType.tap));
    //             } else if (pointMap['pointType'] == 'move') {
    //               transferInSignaturePoints3.add(Point(
    //                   Offset(pointMap['dx'], pointMap['dy']),
    //                   PointType.move));
    //             }
    //           });
    //         });
    //       }
    //     } else {
    //       transferInSignaturePoints3 = [];
    //
    //     }
    //
    //
    //     if (transferReport[Strings.hasSection2Checklist] != null) {
    //       if (mounted) {
    //         setState(() {
    //           hasSection2Checklist = GlobalFunctions.tinyIntToBool(transferReport[Strings.hasSection2Checklist]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.hasSection3Checklist] != null) {
    //       if (mounted) {
    //         setState(() {
    //           hasSection3Checklist = GlobalFunctions.tinyIntToBool(transferReport[Strings.hasSection3Checklist]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.hasSection3TransferChecklist] != null) {
    //       if (mounted) {
    //         setState(() {
    //           hasSection3TransferChecklist = GlobalFunctions.tinyIntToBool(transferReport[Strings.hasSection3TransferChecklist]);
    //         });
    //       }
    //     }
    //
    //
    //     GlobalFunctions.getTemporaryValue(transferReport, patientName, Strings.patientName);
    //     GlobalFunctions.getTemporaryValue(transferReport, transferInCheckedBy1, Strings.transferInCheckedBy1);
    //     GlobalFunctions.getTemporaryValue(transferReport, transferInDesignation1, Strings.transferInDesignation1);
    //     GlobalFunctions.getTemporaryValue(transferReport, patientName, Strings.patientName);
    //     GlobalFunctions.getTemporaryValue(transferReport, transferInCheckedBy2, Strings.transferInCheckedBy2);
    //     GlobalFunctions.getTemporaryValue(transferReport, transferInDesignation2, Strings.transferInDesignation2);
    //     GlobalFunctions.getTemporaryValue(transferReport, patientName, Strings.patientName);
    //     GlobalFunctions.getTemporaryValue(transferReport, transferInCheckedBy3, Strings.transferInCheckedBy3);
    //     GlobalFunctions.getTemporaryValue(transferReport, transferInDesignation3, Strings.transferInDesignation3);
    //     GlobalFunctions.getTemporaryValueDate(transferReport, transferInDate1, Strings.transferInDate1);
    //     GlobalFunctions.getTemporaryValueDate(transferReport, transferInDate2, Strings.transferInDate2);
    //     GlobalFunctions.getTemporaryValueDate(transferReport, transferInDate3, Strings.transferInDate3);
    //
    //     if (transferReport[Strings.patientCorrectYes1] != null) {
    //       if (mounted) {
    //         setState(() {
    //           patientCorrectYes1 = GlobalFunctions.tinyIntToBool(transferReport[Strings.patientCorrectYes1]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.patientCorrectNo1] != null) {
    //       if (mounted) {
    //         setState(() {
    //           patientCorrectNo1 = GlobalFunctions.tinyIntToBool(transferReport[Strings.patientCorrectNo1]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.hospitalCorrectYes1] != null) {
    //       if (mounted) {
    //         setState(() {
    //           hospitalCorrectYes1 = GlobalFunctions.tinyIntToBool(transferReport[Strings.hospitalCorrectYes1]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.hospitalCorrectNo1] != null) {
    //       if (mounted) {
    //         setState(() {
    //           hospitalCorrectNo1 = GlobalFunctions.tinyIntToBool(transferReport[Strings.hospitalCorrectNo1]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.applicationFormYes1] != null) {
    //       if (mounted) {
    //         setState(() {
    //           applicationFormYes1 = GlobalFunctions.tinyIntToBool(transferReport[Strings.applicationFormYes1]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.applicationFormNo1] != null) {
    //       if (mounted) {
    //         setState(() {
    //           applicationFormNo1 = GlobalFunctions.tinyIntToBool(transferReport[Strings.applicationFormNo1]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.applicationSignedYes1] != null) {
    //       if (mounted) {
    //         setState(() {
    //           applicationSignedYes1 = GlobalFunctions.tinyIntToBool(transferReport[Strings.applicationSignedYes1]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.applicationSignedNo1] != null) {
    //       if (mounted) {
    //         setState(() {
    //           applicationSignedNo1 = GlobalFunctions.tinyIntToBool(transferReport[Strings.applicationSignedNo1]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.within14DaysYes1] != null) {
    //       if (mounted) {
    //         setState(() {
    //           within14DaysYes1 = GlobalFunctions.tinyIntToBool(transferReport[Strings.within14DaysYes1]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.within14DaysNo1] != null) {
    //       if (mounted) {
    //         setState(() {
    //           within14DaysNo1 = GlobalFunctions.tinyIntToBool(transferReport[Strings.within14DaysNo1]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.localAuthorityNameYes1] != null) {
    //       if (mounted) {
    //         setState(() {
    //           localAuthorityNameYes1 = GlobalFunctions.tinyIntToBool(transferReport[Strings.localAuthorityNameYes1]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.localAuthorityNameNo1] != null) {
    //       if (mounted) {
    //         setState(() {
    //           localAuthorityNameNo1 = GlobalFunctions.tinyIntToBool(transferReport[Strings.localAuthorityNameNo1]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.medicalRecommendationsFormYes1] != null) {
    //       if (mounted) {
    //         setState(() {
    //           medicalRecommendationsFormYes1 = GlobalFunctions.tinyIntToBool(transferReport[Strings.medicalRecommendationsFormYes1]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.medicalRecommendationsFormNo1] != null) {
    //       if (mounted) {
    //         setState(() {
    //           medicalRecommendationsFormNo1 = GlobalFunctions.tinyIntToBool(transferReport[Strings.medicalRecommendationsFormNo1]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.medicalRecommendationsSignedYes1] != null) {
    //       if (mounted) {
    //         setState(() {
    //           medicalRecommendationsSignedYes1 = GlobalFunctions.tinyIntToBool(transferReport[Strings.medicalRecommendationsSignedYes1]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.medicalRecommendationsSignedNo1] != null) {
    //       if (mounted) {
    //         setState(() {
    //           medicalRecommendationsSignedNo1 = GlobalFunctions.tinyIntToBool(transferReport[Strings.medicalRecommendationsSignedNo1]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.datesSignatureSignedYes] != null) {
    //       if (mounted) {
    //         setState(() {
    //           datesSignatureSignedYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.datesSignatureSignedYes]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.datesSignatureSignedNo] != null) {
    //       if (mounted) {
    //         setState(() {
    //           datesSignatureSignedNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.datesSignatureSignedNo]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.signatureDatesOnBeforeYes1] != null) {
    //       if (mounted) {
    //         setState(() {
    //           signatureDatesOnBeforeYes1 = GlobalFunctions.tinyIntToBool(transferReport[Strings.signatureDatesOnBeforeYes1]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.signatureDatesOnBeforeNo1] != null) {
    //       if (mounted) {
    //         setState(() {
    //           signatureDatesOnBeforeNo1 = GlobalFunctions.tinyIntToBool(transferReport[Strings.signatureDatesOnBeforeNo1]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.practitionersNameYes1] != null) {
    //       if (mounted) {
    //         setState(() {
    //           practitionersNameYes1 = GlobalFunctions.tinyIntToBool(transferReport[Strings.practitionersNameYes1]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.practitionersNameNo1] != null) {
    //       if (mounted) {
    //         setState(() {
    //           practitionersNameNo1 = GlobalFunctions.tinyIntToBool(transferReport[Strings.practitionersNameNo1]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.patientCorrectYes2] != null) {
    //       if (mounted) {
    //         setState(() {
    //           patientCorrectYes2 = GlobalFunctions.tinyIntToBool(transferReport[Strings.patientCorrectYes2]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.patientCorrectNo2] != null) {
    //       if (mounted) {
    //         setState(() {
    //           patientCorrectNo2 = GlobalFunctions.tinyIntToBool(transferReport[Strings.patientCorrectNo2]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.hospitalCorrectYes2] != null) {
    //       if (mounted) {
    //         setState(() {
    //           hospitalCorrectYes2 = GlobalFunctions.tinyIntToBool(transferReport[Strings.hospitalCorrectYes2]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.hospitalCorrectNo2] != null) {
    //       if (mounted) {
    //         setState(() {
    //           hospitalCorrectNo2 = GlobalFunctions.tinyIntToBool(transferReport[Strings.hospitalCorrectNo2]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.applicationFormYes2] != null) {
    //       if (mounted) {
    //         setState(() {
    //           applicationFormYes2 = GlobalFunctions.tinyIntToBool(transferReport[Strings.applicationFormYes2]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.applicationFormNo2] != null) {
    //       if (mounted) {
    //         setState(() {
    //           applicationFormNo2 = GlobalFunctions.tinyIntToBool(transferReport[Strings.applicationFormNo2]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.applicationSignedYes2] != null) {
    //       if (mounted) {
    //         setState(() {
    //           applicationSignedYes2 = GlobalFunctions.tinyIntToBool(transferReport[Strings.applicationSignedYes2]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.applicationSignedNo2] != null) {
    //       if (mounted) {
    //         setState(() {
    //           applicationSignedNo2 = GlobalFunctions.tinyIntToBool(transferReport[Strings.applicationSignedNo2]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.amhpIdentifiedYes] != null) {
    //       if (mounted) {
    //         setState(() {
    //           amhpIdentifiedYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.amhpIdentifiedYes]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.amhpIdentifiedNo] != null) {
    //       if (mounted) {
    //         setState(() {
    //           amhpIdentifiedNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.amhpIdentifiedNo]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.medicalRecommendationsFormYes2] != null) {
    //       if (mounted) {
    //         setState(() {
    //           medicalRecommendationsFormYes2 = GlobalFunctions.tinyIntToBool(transferReport[Strings.medicalRecommendationsFormYes2]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.medicalRecommendationsFormNo2] != null) {
    //       if (mounted) {
    //         setState(() {
    //           medicalRecommendationsFormNo2 = GlobalFunctions.tinyIntToBool(transferReport[Strings.medicalRecommendationsFormNo2]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.medicalRecommendationsSignedYes2] != null) {
    //       if (mounted) {
    //         setState(() {
    //           medicalRecommendationsSignedYes2 = GlobalFunctions.tinyIntToBool(transferReport[Strings.medicalRecommendationsSignedYes2]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.medicalRecommendationsSignedNo2] != null) {
    //       if (mounted) {
    //         setState(() {
    //           medicalRecommendationsSignedNo2 = GlobalFunctions.tinyIntToBool(transferReport[Strings.medicalRecommendationsSignedNo2]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.clearDaysYes2] != null) {
    //       if (mounted) {
    //         setState(() {
    //           clearDaysYes2 = GlobalFunctions.tinyIntToBool(transferReport[Strings.clearDaysYes2]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.clearDaysNo2] != null) {
    //       if (mounted) {
    //         setState(() {
    //           clearDaysNo2 = GlobalFunctions.tinyIntToBool(transferReport[Strings.clearDaysNo2]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.signatureDatesOnBeforeYes2] != null) {
    //       if (mounted) {
    //         setState(() {
    //           signatureDatesOnBeforeYes2 = GlobalFunctions.tinyIntToBool(transferReport[Strings.signatureDatesOnBeforeYes2]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.signatureDatesOnBeforeNo2] != null) {
    //       if (mounted) {
    //         setState(() {
    //           signatureDatesOnBeforeNo2 = GlobalFunctions.tinyIntToBool(transferReport[Strings.signatureDatesOnBeforeNo2]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.practitionersNameYes2] != null) {
    //       if (mounted) {
    //         setState(() {
    //           practitionersNameYes2 = GlobalFunctions.tinyIntToBool(transferReport[Strings.practitionersNameYes2]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.practitionersNameNo2] != null) {
    //       if (mounted) {
    //         setState(() {
    //           practitionersNameNo2 = GlobalFunctions.tinyIntToBool(transferReport[Strings.practitionersNameNo2]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.doctorsAgreeYes] != null) {
    //       if (mounted) {
    //         setState(() {
    //           doctorsAgreeYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.doctorsAgreeYes]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.doctorsAgreeNo] != null) {
    //       if (mounted) {
    //         setState(() {
    //           doctorsAgreeNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.doctorsAgreeNo]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.separateMedicalRecommendationsYes] != null) {
    //       if (mounted) {
    //         setState(() {
    //           separateMedicalRecommendationsYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.separateMedicalRecommendationsYes]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.separateMedicalRecommendationsNo] != null) {
    //       if (mounted) {
    //         setState(() {
    //           separateMedicalRecommendationsNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.separateMedicalRecommendationsNo]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.patientCorrectYes3] != null) {
    //       if (mounted) {
    //         setState(() {
    //           patientCorrectYes3 = GlobalFunctions.tinyIntToBool(transferReport[Strings.patientCorrectYes3]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.patientCorrectNo3] != null) {
    //       if (mounted) {
    //         setState(() {
    //           patientCorrectNo3 = GlobalFunctions.tinyIntToBool(transferReport[Strings.patientCorrectNo3]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.hospitalCorrectYes3] != null) {
    //       if (mounted) {
    //         setState(() {
    //           hospitalCorrectYes3 = GlobalFunctions.tinyIntToBool(transferReport[Strings.hospitalCorrectYes3]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.hospitalCorrectNo3] != null) {
    //       if (mounted) {
    //         setState(() {
    //           hospitalCorrectNo3 = GlobalFunctions.tinyIntToBool(transferReport[Strings.hospitalCorrectNo3]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.h4Yes] != null) {
    //       if (mounted) {
    //         setState(() {
    //           h4Yes = GlobalFunctions.tinyIntToBool(transferReport[Strings.h4Yes]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.h4No] != null) {
    //       if (mounted) {
    //         setState(() {
    //           h4No = GlobalFunctions.tinyIntToBool(transferReport[Strings.h4No]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.currentConsentYes] != null) {
    //       if (mounted) {
    //         setState(() {
    //           currentConsentYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.currentConsentYes]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.currentConsentNo] != null) {
    //       if (mounted) {
    //         setState(() {
    //           currentConsentNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.currentConsentNo]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.applicationFormYes3] != null) {
    //       if (mounted) {
    //         setState(() {
    //           applicationFormYes3 = GlobalFunctions.tinyIntToBool(transferReport[Strings.applicationFormYes3]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.applicationFormNo3] != null) {
    //       if (mounted) {
    //         setState(() {
    //           applicationFormNo3 = GlobalFunctions.tinyIntToBool(transferReport[Strings.applicationFormNo3]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.applicationSignedYes3] != null) {
    //       if (mounted) {
    //         setState(() {
    //           applicationSignedYes3 = GlobalFunctions.tinyIntToBool(transferReport[Strings.applicationSignedYes3]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.applicationSignedNo3] != null) {
    //       if (mounted) {
    //         setState(() {
    //           applicationSignedNo3 = GlobalFunctions.tinyIntToBool(transferReport[Strings.applicationSignedNo3]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.within14DaysYes3] != null) {
    //       if (mounted) {
    //         setState(() {
    //           within14DaysYes3 = GlobalFunctions.tinyIntToBool(transferReport[Strings.within14DaysYes3]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.within14DaysNo3] != null) {
    //       if (mounted) {
    //         setState(() {
    //           within14DaysNo3 = GlobalFunctions.tinyIntToBool(transferReport[Strings.within14DaysNo3]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.localAuthorityNameYes3] != null) {
    //       if (mounted) {
    //         setState(() {
    //           localAuthorityNameYes3 = GlobalFunctions.tinyIntToBool(transferReport[Strings.localAuthorityNameYes3]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.localAuthorityNameNo3] != null) {
    //       if (mounted) {
    //         setState(() {
    //           localAuthorityNameNo3 = GlobalFunctions.tinyIntToBool(transferReport[Strings.localAuthorityNameNo3]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.nearestRelativeYes] != null) {
    //       if (mounted) {
    //         setState(() {
    //           nearestRelativeYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.nearestRelativeYes]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.nearestRelativeNo] != null) {
    //       if (mounted) {
    //         setState(() {
    //           nearestRelativeNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.nearestRelativeNo]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.amhpConsultationYes] != null) {
    //       if (mounted) {
    //         setState(() {
    //           amhpConsultationYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.amhpConsultationYes]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.amhpConsultationNo] != null) {
    //       if (mounted) {
    //         setState(() {
    //           amhpConsultationNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.amhpConsultationNo]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.knewPatientYes] != null) {
    //       if (mounted) {
    //         setState(() {
    //           knewPatientYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.knewPatientYes]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.knewPatientNo] != null) {
    //       if (mounted) {
    //         setState(() {
    //           knewPatientNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.knewPatientNo]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.medicalRecommendationsFormYes3] != null) {
    //       if (mounted) {
    //         setState(() {
    //           medicalRecommendationsFormYes3 = GlobalFunctions.tinyIntToBool(transferReport[Strings.medicalRecommendationsFormYes3]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.medicalRecommendationsFormNo3] != null) {
    //       if (mounted) {
    //         setState(() {
    //           medicalRecommendationsFormNo3 = GlobalFunctions.tinyIntToBool(transferReport[Strings.medicalRecommendationsFormNo3]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.medicalRecommendationsSignedYes3] != null) {
    //       if (mounted) {
    //         setState(() {
    //           medicalRecommendationsSignedYes3 = GlobalFunctions.tinyIntToBool(transferReport[Strings.medicalRecommendationsSignedYes3]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.medicalRecommendationsSignedNo3] != null) {
    //       if (mounted) {
    //         setState(() {
    //           medicalRecommendationsSignedNo3 = GlobalFunctions.tinyIntToBool(transferReport[Strings.medicalRecommendationsSignedNo3]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.clearDaysYes3] != null) {
    //       if (mounted) {
    //         setState(() {
    //           clearDaysYes3 = GlobalFunctions.tinyIntToBool(transferReport[Strings.clearDaysYes3]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.clearDaysNo3] != null) {
    //       if (mounted) {
    //         setState(() {
    //           clearDaysNo3= GlobalFunctions.tinyIntToBool(transferReport[Strings.clearDaysNo3]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.approvedSection12Yes] != null) {
    //       if (mounted) {
    //         setState(() {
    //           approvedSection12Yes = GlobalFunctions.tinyIntToBool(transferReport[Strings.approvedSection12Yes]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.approvedSection12No] != null) {
    //       if (mounted) {
    //         setState(() {
    //           approvedSection12No = GlobalFunctions.tinyIntToBool(transferReport[Strings.approvedSection12No]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.signatureDatesOnBeforeYes3] != null) {
    //       if (mounted) {
    //         setState(() {
    //           signatureDatesOnBeforeYes3 = GlobalFunctions.tinyIntToBool(transferReport[Strings.signatureDatesOnBeforeYes3]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.signatureDatesOnBeforeNo3] != null) {
    //       if (mounted) {
    //         setState(() {
    //           signatureDatesOnBeforeNo3 = GlobalFunctions.tinyIntToBool(transferReport[Strings.signatureDatesOnBeforeNo3]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.practitionersNameYes3] != null) {
    //       if (mounted) {
    //         setState(() {
    //           practitionersNameYes3 = GlobalFunctions.tinyIntToBool(transferReport[Strings.practitionersNameYes3]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.practitionersNameNo3] != null) {
    //       if (mounted) {
    //         setState(() {
    //           practitionersNameNo3 = GlobalFunctions.tinyIntToBool(transferReport[Strings.practitionersNameNo3]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.previouslyAcquaintedYes] != null) {
    //       if (mounted) {
    //         setState(() {
    //           previouslyAcquaintedYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.previouslyAcquaintedYes]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.previouslyAcquaintedNo] != null) {
    //       if (mounted) {
    //         setState(() {
    //           previouslyAcquaintedNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.previouslyAcquaintedNo]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.acquaintedIfNoYes] != null) {
    //       if (mounted) {
    //         setState(() {
    //           acquaintedIfNoYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.acquaintedIfNoYes]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.acquaintedIfNoNo] != null) {
    //       if (mounted) {
    //         setState(() {
    //           acquaintedIfNoNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.acquaintedIfNoNo]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.recommendationsDifferentTeamsYes] != null) {
    //       if (mounted) {
    //         setState(() {
    //           recommendationsDifferentTeamsYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.recommendationsDifferentTeamsYes]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.recommendationsDifferentTeamsNo] != null) {
    //       if (mounted) {
    //         setState(() {
    //           recommendationsDifferentTeamsNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.recommendationsDifferentTeamsNo]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.originalDetentionPapersYes] != null) {
    //       if (mounted) {
    //         setState(() {
    //           originalDetentionPapersYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.originalDetentionPapersYes]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.originalDetentionPapersNo] != null) {
    //       if (mounted) {
    //         setState(() {
    //           originalDetentionPapersNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.originalDetentionPapersNo]);
    //         });
    //       }
    //     }
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

  // Widget _buildTransferInSignature1Row() {
  //   return Column(
  //     children: <Widget>[
  //       SizedBox(
  //         height: 10.0,
  //       ),
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.start,
  //         children: <Widget>[
  //           Text(
  //             "Signature",
  //             textAlign: TextAlign.left,
  //             style: TextStyle(
  //                 fontSize: 16.0, color: bluePurple),
  //           ),
  //         ],
  //       ),
  //       SizedBox(
  //         height: 10.0,
  //       ),
  //       Container(
  //         child: Center(
  //           child: GestureDetector(
  //             onTap: () {
  //               FocusScope.of(context).unfocus();
  //               if(widget.edit){
  //                 GlobalFunctions.showToast('Signatures cannot be amended on already submitted forms');
  //               } else {
  //                 showDialog(
  //                     context: context,
  //                     barrierDismissible: false,
  //                     builder: (BuildContext context) {
  //                       transferInSignature1 = Signature(
  //                         points: transferInSignaturePoints1,
  //                         height: 99,
  //                         width: 280.0,
  //                         backgroundColor: Colors.white,
  //                       );
  //
  //                       return AlertDialog(
  //                         shape: RoundedRectangleBorder(
  //                             borderRadius: BorderRadius.all(Radius.circular(32.0))),
  //                         contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
  //                         titlePadding: EdgeInsets.all(0),
  //                         title: Container(
  //                           padding: EdgeInsets.only(top: 10, bottom: 10),
  //                           decoration: BoxDecoration(
  //                             gradient: LinearGradient(
  //                                 begin: Alignment.topCenter,
  //                                 end: Alignment.bottomCenter,
  //                                 colors: [purpleDesign, purpleDesign]),
  //                             borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
  //                           ),
  //                           child: Center(child: Text("Signature", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),),
  //                         ),
  //                         content: Column(
  //                           mainAxisSize: MainAxisSize.min,
  //                           mainAxisAlignment: MainAxisAlignment.center,
  //                           //mainAxisSize: MainAxisSize.min,
  //                           children: [
  //                             Container(
  //                               decoration: BoxDecoration(
  //                                   border: new Border.all(
  //                                       color: Colors.black, width: 2.0)),
  //                               height: 100.0,
  //                               child: transferInSignature1,
  //                             )
  //                           ],
  //                         ),
  //                         actions: <Widget>[
  //                           TextButton(
  //                               onPressed: () {
  //                                 transferInSignature1
  //                                     .clear();
  //                                 _databaseHelper
  //                                     .updateTemporaryTransferReportField(widget.edit,
  //                                     {Strings.transferInSignaturePoints1: null},
  //                                     user.uid,
  //                                     widget.jobId, widget.saved, widget.savedId);
  //                                 _databaseHelper
  //                                     .updateTemporaryTransferReportField(widget.edit,
  //                                     {Strings.transferInSignature1: null}, user.uid,
  //                                     widget.jobId, widget.saved, widget.savedId);
  //                                 setState(() {
  //                                   transferInSignaturePoints1 = [];
  //                                   transferInImageBytes1 =
  //                                   null;
  //                                 });
  //                               },
  //                               child: Text(
  //                                 'Clear',
  //                                 style: TextStyle(color: bluePurple),
  //                               )),
  //                           TextButton(
  //                               onPressed: () => Navigator.of(context).pop(),
  //                               child: Text(
  //                                 'Cancel',
  //                                 style: TextStyle(color: bluePurple),
  //                               )),
  //                           TextButton(
  //                               onPressed: () async {
  //                                 List<Map<String, dynamic>> pointsMap = [];
  //
  //                                 transferInSignaturePoints1 =
  //                                     transferInSignature1
  //                                         .exportPoints();
  //
  //                                 if (transferInSignaturePoints1.length > 0) {
  //                                   transferInSignaturePoints1.forEach((
  //                                       Point p) {
  //                                     if (p.type == PointType.move) {
  //                                       pointsMap.add({
  //                                         'pointType': 'move',
  //                                         'dx': p.offset.dx,
  //                                         'dy': p.offset.dy
  //                                       });
  //                                     } else if (p.type == PointType.tap) {
  //                                       pointsMap.add({
  //                                         'pointType': 'tap',
  //                                         'dx': p.offset.dx,
  //                                         'dy': p.offset.dy
  //                                       });
  //                                     }
  //                                   });
  //
  //                                   var encodedPoints = jsonEncode(pointsMap);
  //
  //                                   String encryptedPoints = GlobalFunctions
  //                                       .encryptString(encodedPoints);
  //
  //                                   _databaseHelper
  //                                       .updateTemporaryTransferReportField(widget.edit,
  //                                       {
  //                                         Strings.transferInSignaturePoints1:
  //                                         encryptedPoints
  //                                       },
  //                                       user.uid,
  //                                       widget.jobId, widget.saved, widget.savedId);
  //
  //                                   Uint8List signatureBytes = await transferInSignature1
  //                                       .exportBytes();
  //
  //                                   setState(() {
  //                                     transferInImageBytes1 =
  //                                         signatureBytes;
  //                                   });
  //
  //                                   Uint8List encryptedSignature = await GlobalFunctions
  //                                       .encryptSignature(transferInImageBytes1);
  //
  //                                   _databaseHelper
  //                                       .updateTemporaryTransferReportField(widget.edit, {
  //                                     Strings.transferInSignature1: encryptedSignature
  //                                   }, user.uid,
  //                                       widget.jobId, widget.saved, widget.savedId);
  //
  //                                 }
  //                                 Navigator.of(context).pop();
  //                               },
  //                               child: Text(
  //                                 'OK',
  //                                 style: TextStyle(color: bluePurple),
  //                               ))
  //                         ],
  //                       );
  //                     });
  //               }
  //             },
  //             child: transferInImageBytes1 == null
  //                 ? Icon(
  //               Icons.border_color,
  //               color: bluePurple,
  //               size: 40.0,
  //             )
  //                 : Image.memory(transferInImageBytes1),
  //           ),
  //         ),
  //       )
  //     ],
  //   );
  // }
  // Widget _buildTransferInSignature2Row() {
  //   return Column(
  //     children: <Widget>[
  //       SizedBox(
  //         height: 10.0,
  //       ),
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.start,
  //         children: <Widget>[
  //           Text(
  //             "Signature",
  //             textAlign: TextAlign.left,
  //             style: TextStyle(
  //                 fontSize: 16.0, color: bluePurple),
  //           ),
  //         ],
  //       ),
  //       SizedBox(
  //         height: 10.0,
  //       ),
  //       Container(
  //         child: Center(
  //           child: GestureDetector(
  //             onTap: () {
  //               FocusScope.of(context).unfocus();
  //               if(widget.edit){
  //                 GlobalFunctions.showToast('Signatures cannot be amended on already submitted forms');
  //               } else {
  //                 showDialog(
  //                     context: context,
  //                     barrierDismissible: false,
  //                     builder: (BuildContext context) {
  //                       transferInSignature2 = Signature(
  //                         points: transferInSignaturePoints2,
  //                         height: 99,
  //                         width: 280.0,
  //                         backgroundColor: Colors.white,
  //                       );
  //
  //                       return AlertDialog(
  //                         shape: RoundedRectangleBorder(
  //                             borderRadius: BorderRadius.all(Radius.circular(32.0))),
  //                         contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
  //                         titlePadding: EdgeInsets.all(0),
  //                         title: Container(
  //                           padding: EdgeInsets.only(top: 10, bottom: 10),
  //                           decoration: BoxDecoration(
  //                             gradient: LinearGradient(
  //                                 begin: Alignment.topCenter,
  //                                 end: Alignment.bottomCenter,
  //                                 colors: [purpleDesign, purpleDesign]),
  //                             borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
  //                           ),
  //                           child: Center(child: Text("Signature", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),),
  //                         ),
  //                         content: Column(
  //                           mainAxisSize: MainAxisSize.min,
  //                           mainAxisAlignment: MainAxisAlignment.center,
  //                           //mainAxisSize: MainAxisSize.min,
  //                           children: [
  //                             Container(
  //                               decoration: BoxDecoration(
  //                                   border: new Border.all(
  //                                       color: Colors.black, width: 2.0)),
  //                               height: 100.0,
  //                               child: transferInSignature2,
  //                             )
  //                           ],
  //                         ),
  //                         actions: <Widget>[
  //                           TextButton(
  //                               onPressed: () {
  //                                 transferInSignature2
  //                                     .clear();
  //                                 _databaseHelper
  //                                     .updateTemporaryTransferReportField(widget.edit,
  //                                     {Strings.transferInSignaturePoints2: null},
  //                                     user.uid,
  //                                     widget.jobId, widget.saved, widget.savedId);
  //                                 _databaseHelper
  //                                     .updateTemporaryTransferReportField(widget.edit,
  //                                     {Strings.transferInSignature2: null}, user.uid,
  //                                     widget.jobId, widget.saved, widget.savedId);
  //                                 setState(() {
  //                                   transferInSignaturePoints2 = [];
  //                                   transferInImageBytes2 =
  //                                   null;
  //                                 });
  //                               },
  //                               child: Text(
  //                                 'Clear',
  //                                 style: TextStyle(color: bluePurple),
  //                               )),
  //                           TextButton(
  //                               onPressed: () => Navigator.of(context).pop(),
  //                               child: Text(
  //                                 'Cancel',
  //                                 style: TextStyle(color: bluePurple),
  //                               )),
  //                           TextButton(
  //                               onPressed: () async {
  //                                 List<Map<String, dynamic>> pointsMap = [];
  //
  //                                 transferInSignaturePoints2 =
  //                                     transferInSignature2
  //                                         .exportPoints();
  //
  //                                 if (transferInSignaturePoints2.length > 0) {
  //                                   transferInSignaturePoints2.forEach((
  //                                       Point p) {
  //                                     if (p.type == PointType.move) {
  //                                       pointsMap.add({
  //                                         'pointType': 'move',
  //                                         'dx': p.offset.dx,
  //                                         'dy': p.offset.dy
  //                                       });
  //                                     } else if (p.type == PointType.tap) {
  //                                       pointsMap.add({
  //                                         'pointType': 'tap',
  //                                         'dx': p.offset.dx,
  //                                         'dy': p.offset.dy
  //                                       });
  //                                     }
  //                                   });
  //
  //                                   var encodedPoints = jsonEncode(pointsMap);
  //
  //                                   String encryptedPoints = GlobalFunctions
  //                                       .encryptString(encodedPoints);
  //
  //                                   _databaseHelper
  //                                       .updateTemporaryTransferReportField(widget.edit,
  //                                       {
  //                                         Strings.transferInSignaturePoints2:
  //                                         encryptedPoints
  //                                       },
  //                                       user.uid,
  //                                       widget.jobId, widget.saved, widget.savedId);
  //
  //                                   Uint8List signatureBytes = await transferInSignature2
  //                                       .exportBytes();
  //
  //                                   setState(() {
  //                                     transferInImageBytes2 =
  //                                         signatureBytes;
  //                                   });
  //
  //                                   Uint8List encryptedSignature = await GlobalFunctions
  //                                       .encryptSignature(transferInImageBytes2);
  //
  //                                   _databaseHelper
  //                                       .updateTemporaryTransferReportField(widget.edit, {
  //                                     Strings.transferInSignature2: encryptedSignature
  //                                   }, user.uid,
  //                                       widget.jobId, widget.saved, widget.savedId);
  //
  //                                 }
  //                                 Navigator.of(context).pop();
  //                               },
  //                               child: Text(
  //                                 'OK',
  //                                 style: TextStyle(color: bluePurple),
  //                               ))
  //                         ],
  //                       );
  //                     });
  //               }
  //             },
  //             child: transferInImageBytes2 == null
  //                 ? Icon(
  //               Icons.border_color,
  //               color: bluePurple,
  //               size: 40.0,
  //             )
  //                 : Image.memory(transferInImageBytes2),
  //           ),
  //         ),
  //       )
  //     ],
  //   );
  // }
  // Widget _buildTransferInSignature3Row() {
  //   return Column(
  //     children: <Widget>[
  //       SizedBox(
  //         height: 10.0,
  //       ),
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.start,
  //         children: <Widget>[
  //           Text(
  //             "Signature",
  //             textAlign: TextAlign.left,
  //             style: TextStyle(
  //                 fontSize: 16.0, color: bluePurple),
  //           ),
  //         ],
  //       ),
  //       SizedBox(
  //         height: 10.0,
  //       ),
  //       Container(
  //         child: Center(
  //           child: GestureDetector(
  //             onTap: () {
  //               FocusScope.of(context).unfocus();
  //               if(widget.edit){
  //                 GlobalFunctions.showToast('Signatures cannot be amended on already submitted forms');
  //               } else {
  //                 showDialog(
  //                     context: context,
  //                     barrierDismissible: false,
  //                     builder: (BuildContext context) {
  //                       transferInSignature3 = Signature(
  //                         points: transferInSignaturePoints3,
  //                         height: 99,
  //                         width: 280.0,
  //                         backgroundColor: Colors.white,
  //                       );
  //
  //                       return AlertDialog(
  //                         shape: RoundedRectangleBorder(
  //                             borderRadius: BorderRadius.all(Radius.circular(32.0))),
  //                         contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
  //                         titlePadding: EdgeInsets.all(0),
  //                         title: Container(
  //                           padding: EdgeInsets.only(top: 10, bottom: 10),
  //                           decoration: BoxDecoration(
  //                             gradient: LinearGradient(
  //                                 begin: Alignment.topCenter,
  //                                 end: Alignment.bottomCenter,
  //                                 colors: [purpleDesign, purpleDesign]),
  //                             borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
  //                           ),
  //                           child: Center(child: Text("Signature", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),),
  //                         ),
  //                         content: Column(
  //                           mainAxisSize: MainAxisSize.min,
  //                           mainAxisAlignment: MainAxisAlignment.center,
  //                           //mainAxisSize: MainAxisSize.min,
  //                           children: [
  //                             Container(
  //                               decoration: BoxDecoration(
  //                                   border: new Border.all(
  //                                       color: Colors.black, width: 2.0)),
  //                               height: 100.0,
  //                               child: transferInSignature3,
  //                             )
  //                           ],
  //                         ),
  //                         actions: <Widget>[
  //                           TextButton(
  //                               onPressed: () {
  //                                 transferInSignature3
  //                                     .clear();
  //                                 _databaseHelper
  //                                     .updateTemporaryTransferReportField(widget.edit,
  //                                     {Strings.transferInSignaturePoints3: null},
  //                                     user.uid,
  //                                     widget.jobId, widget.saved, widget.savedId);
  //                                 _databaseHelper
  //                                     .updateTemporaryTransferReportField(widget.edit,
  //                                     {Strings.transferInSignature3: null}, user.uid,
  //                                     widget.jobId, widget.saved, widget.savedId);
  //                                 setState(() {
  //                                   transferInSignaturePoints3 = [];
  //                                   transferInImageBytes3 =
  //                                   null;
  //                                 });
  //                               },
  //                               child: Text(
  //                                 'Clear',
  //                                 style: TextStyle(color: bluePurple),
  //                               )),
  //                           TextButton(
  //                               onPressed: () => Navigator.of(context).pop(),
  //                               child: Text(
  //                                 'Cancel',
  //                                 style: TextStyle(color: bluePurple),
  //                               )),
  //                           TextButton(
  //                               onPressed: () async {
  //                                 List<Map<String, dynamic>> pointsMap = [];
  //
  //                                 transferInSignaturePoints3 =
  //                                     transferInSignature3
  //                                         .exportPoints();
  //
  //                                 if (transferInSignaturePoints3.length > 0) {
  //                                   transferInSignaturePoints3.forEach((
  //                                       Point p) {
  //                                     if (p.type == PointType.move) {
  //                                       pointsMap.add({
  //                                         'pointType': 'move',
  //                                         'dx': p.offset.dx,
  //                                         'dy': p.offset.dy
  //                                       });
  //                                     } else if (p.type == PointType.tap) {
  //                                       pointsMap.add({
  //                                         'pointType': 'tap',
  //                                         'dx': p.offset.dx,
  //                                         'dy': p.offset.dy
  //                                       });
  //                                     }
  //                                   });
  //
  //                                   var encodedPoints = jsonEncode(pointsMap);
  //
  //                                   String encryptedPoints = GlobalFunctions
  //                                       .encryptString(encodedPoints);
  //
  //                                   _databaseHelper
  //                                       .updateTemporaryTransferReportField(widget.edit,
  //                                       {
  //                                         Strings.transferInSignaturePoints3:
  //                                         encryptedPoints
  //                                       },
  //                                       user.uid,
  //                                       widget.jobId, widget.saved, widget.savedId);
  //
  //                                   Uint8List signatureBytes = await transferInSignature3
  //                                       .exportBytes();
  //
  //                                   setState(() {
  //                                     transferInImageBytes3 =
  //                                         signatureBytes;
  //                                   });
  //
  //                                   Uint8List encryptedSignature = await GlobalFunctions
  //                                       .encryptSignature(transferInImageBytes3);
  //
  //                                   _databaseHelper
  //                                       .updateTemporaryTransferReportField(widget.edit, {
  //                                     Strings.transferInSignature3: encryptedSignature
  //                                   }, user.uid,
  //                                       widget.jobId, widget.saved, widget.savedId);
  //
  //                                 }
  //                                 Navigator.of(context).pop();
  //
  //                               },
  //                               child: Text(
  //                                 'OK',
  //                                 style: TextStyle(color: bluePurple),
  //                               ))
  //                         ],
  //                       );
  //                     });
  //               }
  //             },
  //             child: transferInImageBytes3 == null
  //                 ? Icon(
  //               Icons.border_color,
  //               color: bluePurple,
  //               size: 40.0,
  //             )
  //                 : Image.memory(transferInImageBytes3),
  //           ),
  //         ),
  //       )
  //     ],
  //   );
  // }


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


  // Widget _buildDateField(String label, TextEditingController controller, String value, [bool required = false, bool encrypt = false]) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: <Widget>[
  //       RichText(
  //         text: TextSpan(
  //             text: label,
  //             style: TextStyle(
  //                 fontSize: 16.0, fontFamily: 'Open Sans', color: bluePurple),
  //             children:
  //             [
  //               TextSpan(
  //                 text: required ? ' *' : '',
  //                 style: TextStyle(
  //                   color: Colors.red,
  //                   fontSize: 16.0, fontFamily: 'Open Sans',),
  //               ),                                           ]
  //         ),
  //       ),
  //       Row(
  //         children: <Widget>[
  //           Flexible(
  //             child: IgnorePointer(
  //               child: TextFormField(
  //                 enabled: true,
  //                 initialValue: null,
  //                 controller: controller,
  //                 onSaved: (String value) {
  //                   setState(() {
  //                     controller.text = value;
  //                   });
  //                 },
  //
  //               ),
  //             ),
  //           ),
  //           IconButton(
  //               color: Colors.grey,
  //               icon: Icon(Icons.clear),
  //               onPressed: () {
  //                 setState(() {
  //                   controller.clear();
  //                   _databaseHelper.updateTemporaryTransferReportField(widget.edit,
  //                       {value : null}, user.uid, widget.jobId, widget.saved, widget.savedId);
  //
  //                 });
  //               }),
  //           IconButton(
  //               icon: Icon(Icons.access_time,
  //                   color: bluePurple),
  //               onPressed: () async{
  //                 FocusScope.of(context).unfocus();
  //                 await Future.delayed(Duration(milliseconds: 100));
  //                 showDatePicker(
  //                     builder: (BuildContext context, Widget child) {
  //                       return Theme(
  //                         data: ThemeData.light().copyWith(
  //                           colorScheme: ColorScheme.light().copyWith(
  //                             primary: bluePurple,
  //                           ),
  //                         ),
  //                         child: child,
  //                       );
  //                     },
  //                     context: context,
  //                     initialDate: DateTime.now(),
  //                     firstDate: DateTime(1920),
  //                     lastDate: DateTime(2100))
  //                     .then((DateTime newDate) {
  //                   if (newDate != null) {
  //                     String dateTime = dateFormat.format(newDate);
  //                     setState(() {
  //                       controller.text = dateTime;
  //                       if(encrypt){
  //                         _databaseHelper.updateTemporaryTransferReportField(widget.edit,
  //                             {value : GlobalFunctions.encryptString(DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String())}, user.uid, widget.jobId, widget.saved, widget.savedId);
  //                       } else {
  //                         _databaseHelper.updateTemporaryTransferReportField(widget.edit,
  //                             {value : DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String()}, user.uid, widget.jobId, widget.saved, widget.savedId);
  //                       }
  //
  //
  //
  //                     });
  //                   }
  //                 });
  //               })
  //         ],
  //       ),
  //       SizedBox(height: 15,),
  //     ],
  //   );
  // }




  Widget _buildFormCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text('Section 2 Checklist', style: TextStyle(color: bluePurple, fontSize: 16),),
            Checkbox(
                activeColor: bluePurple,
                value: hasSection2Checklist,
                onChanged: (bool value) => setState(() {
                  hasSection2Checklist = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.hasSection2Checklist, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  //_databaseHelper.updateTemporaryTransferReportField(widget.edit, {Strings.hasSection2Checklist : GlobalFunctions.boolToTinyInt(value)}, user.uid, widget.jobId, widget.saved, widget.savedId);
                  if (hasSection2Checklist == true){
                    hasSection3Checklist = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.hasSection3Checklist, null, widget.jobId, widget.saved, widget.savedId);
                    //_databaseHelper.updateTemporaryTransferReportField(widget.edit, {Strings.hasSection3Checklist : null}, user.uid, widget.jobId, widget.saved, widget.savedId);
                    hasSection3TransferChecklist = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.hasSection3TransferChecklist, null, widget.jobId, widget.saved, widget.savedId);
                    //_databaseHelper.updateTemporaryTransferReportField(widget.edit, {Strings.hasSection3TransferChecklist : null}, user.uid, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        ),
        Row(
          children: <Widget>[
            Text('Section 3 Checklist', style: TextStyle(color: bluePurple, fontSize: 16),),
            Checkbox(
                activeColor: bluePurple,
                value: hasSection3Checklist,
                onChanged: (bool value) => setState(() {
                  hasSection3Checklist = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.hasSection3Checklist, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  //_databaseHelper.updateTemporaryTransferReportField(widget.edit, {Strings.hasSection3Checklist : GlobalFunctions.boolToTinyInt(value)}, user.uid, widget.jobId, widget.saved, widget.savedId);
                  if (hasSection3Checklist == true){
                    hasSection2Checklist = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.hasSection2Checklist, null, widget.jobId, widget.saved, widget.savedId);
                    //_databaseHelper.updateTemporaryTransferReportField(widget.edit, {Strings.hasSection2Checklist : null}, user.uid, widget.jobId, widget.saved, widget.savedId);
                    hasSection3TransferChecklist = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.hasSection3TransferChecklist, null, widget.jobId, widget.saved, widget.savedId);
                    //_databaseHelper.updateTemporaryTransferReportField(widget.edit, {Strings.hasSection3TransferChecklist : null}, user.uid, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        ),
        Row(
          children: <Widget>[
            Text('Section 3 Transfer Checklist', style: TextStyle(color: bluePurple, fontSize: 16),),
            Checkbox(
                activeColor: bluePurple,
                value: hasSection3TransferChecklist,
                onChanged: (bool value) => setState(() {
                  hasSection3TransferChecklist = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.hasSection3TransferChecklist, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  //_databaseHelper.updateTemporaryTransferReportField(widget.edit, {Strings.hasSection3TransferChecklist : GlobalFunctions.boolToTinyInt(value)}, user.uid, widget.jobId, widget.saved, widget.savedId);
                  if (hasSection3TransferChecklist == true){
                    hasSection3Checklist = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.hasSection3Checklist, null, widget.jobId, widget.saved, widget.savedId);
                    //_databaseHelper.updateTemporaryTransferReportField(widget.edit, {Strings.hasSection3Checklist : null}, user.uid, widget.jobId, widget.saved, widget.savedId);
                    hasSection2Checklist = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.hasSection2Checklist, null, widget.jobId, widget.saved, widget.savedId);
                    //_databaseHelper.updateTemporaryTransferReportField(widget.edit, {Strings.hasSection2Checklist : null}, user.uid, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        )
      ],
    );
  }







  Widget _buildCheckboxRowPatientCorrectYes1(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
Text(text, style: TextStyle(color: bluePurple, fontSize: 16),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: patientCorrectYes1,
                onChanged: (bool value) => setState(() {
                  patientCorrectYes1 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.patientCorrectYes1, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (patientCorrectNo1 == true){
                    patientCorrectNo1 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.patientCorrectNo1, null, widget.jobId, widget.saved, widget.savedId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: patientCorrectNo1,
                onChanged: (bool value) => setState(() {
                  patientCorrectNo1 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.patientCorrectNo1, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (patientCorrectYes1 == true){
                    patientCorrectYes1 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.patientCorrectYes1, null, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowHospitalCorrectYes1(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
Text(text, style: TextStyle(color: bluePurple, fontSize: 16),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: hospitalCorrectYes1,
                onChanged: (bool value) => setState(() {
                  hospitalCorrectYes1 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.hospitalCorrectYes1, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (hospitalCorrectNo1 == true){
                    hospitalCorrectNo1 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.hospitalCorrectNo1, null, widget.jobId, widget.saved, widget.savedId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: hospitalCorrectNo1,
                onChanged: (bool value) => setState(() {
                  hospitalCorrectNo1 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.hospitalCorrectNo1, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (hospitalCorrectYes1 == true){
                    hospitalCorrectYes1 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.hospitalCorrectYes1, null, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowApplicationFormYes1(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
Text(text, style: TextStyle(color: bluePurple, fontSize: 16),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: applicationFormYes1,
                onChanged: (bool value) => setState(() {
                  applicationFormYes1 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.applicationFormYes1, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (applicationFormNo1 == true){
                    applicationFormNo1 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.applicationFormNo1, null, widget.jobId, widget.saved, widget.savedId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: applicationFormNo1,
                onChanged: (bool value) => setState(() {
                  applicationFormNo1 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.applicationFormNo1, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (applicationFormYes1 == true){
                    applicationFormYes1 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.applicationFormYes1, null, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowApplicationSignedYes1(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
Text(text, style: TextStyle(color: bluePurple, fontSize: 16),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: applicationSignedYes1,
                onChanged: (bool value) => setState(() {
                  applicationSignedYes1 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.applicationSignedYes1, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (applicationSignedNo1 == true){
                    applicationSignedNo1 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.applicationSignedNo1, null, widget.jobId, widget.saved, widget.savedId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: applicationSignedNo1,
                onChanged: (bool value) => setState(() {
                  applicationSignedNo1 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.applicationSignedNo1, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (applicationSignedYes1 == true){
                    applicationSignedYes1 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.applicationSignedYes1, null, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowWithin14DaysYes1(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
Text(text, style: TextStyle(color: bluePurple, fontSize: 16),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: within14DaysYes1,
                onChanged: (bool value) => setState(() {
                  within14DaysYes1 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.within14DaysYes1, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (within14DaysNo1 == true){
                    within14DaysNo1 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.within14DaysNo1, null, widget.jobId, widget.saved, widget.savedId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: within14DaysNo1,
                onChanged: (bool value) => setState(() {
                  within14DaysNo1 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.within14DaysNo1, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (within14DaysYes1 == true){
                    within14DaysYes1 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.within14DaysYes1, null, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowLocalAuthorityNameYes1(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
Text(text, style: TextStyle(color: bluePurple, fontSize: 16),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: localAuthorityNameYes1,
                onChanged: (bool value) => setState(() {
                  localAuthorityNameYes1 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.localAuthorityNameYes1, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (localAuthorityNameNo1 == true){
                    localAuthorityNameNo1 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.localAuthorityNameNo1, null, widget.jobId, widget.saved, widget.savedId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: localAuthorityNameNo1,
                onChanged: (bool value) => setState(() {
                  localAuthorityNameNo1 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.localAuthorityNameNo1, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (localAuthorityNameYes1 == true){
                    localAuthorityNameYes1 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.localAuthorityNameYes1, null, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowMedicalRecommendationsFormYes1(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
Text(text, style: TextStyle(color: bluePurple, fontSize: 16),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: medicalRecommendationsFormYes1,
                onChanged: (bool value) => setState(() {
                  medicalRecommendationsFormYes1 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.medicalRecommendationsFormYes1, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (medicalRecommendationsFormNo1 == true){
                    medicalRecommendationsFormNo1 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.medicalRecommendationsFormNo1, null, widget.jobId, widget.saved, widget.savedId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: medicalRecommendationsFormNo1,
                onChanged: (bool value) => setState(() {
                  medicalRecommendationsFormNo1 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.medicalRecommendationsFormNo1, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (medicalRecommendationsFormYes1 == true){
                    medicalRecommendationsFormYes1 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.medicalRecommendationsFormYes1, null, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowMedicalRecommendationsSignedYes1(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
Text(text, style: TextStyle(color: bluePurple, fontSize: 16),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: medicalRecommendationsSignedYes1,
                onChanged: (bool value) => setState(() {
                  medicalRecommendationsSignedYes1 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.medicalRecommendationsSignedYes1, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (medicalRecommendationsSignedNo1 == true){
                    medicalRecommendationsSignedNo1 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.medicalRecommendationsSignedNo1, null, widget.jobId, widget.saved, widget.savedId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: medicalRecommendationsSignedNo1,
                onChanged: (bool value) => setState(() {
                  medicalRecommendationsSignedNo1 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.medicalRecommendationsSignedNo1, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (medicalRecommendationsSignedYes1 == true){
                    medicalRecommendationsSignedYes1 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.medicalRecommendationsSignedYes1, null, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowDatesSignatureSignedYes(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
Text(text, style: TextStyle(color: bluePurple, fontSize: 16),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: datesSignatureSignedYes,
                onChanged: (bool value) => setState(() {
                  datesSignatureSignedYes = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.datesSignatureSignedYes, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (datesSignatureSignedNo == true){
                    datesSignatureSignedNo = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.datesSignatureSignedNo, null, widget.jobId, widget.saved, widget.savedId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: datesSignatureSignedNo,
                onChanged: (bool value) => setState(() {
                  datesSignatureSignedNo = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.datesSignatureSignedNo, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (datesSignatureSignedYes == true){
                    datesSignatureSignedYes = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.datesSignatureSignedYes, null, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowSignatureDatesOnBeforeYes1(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
Text(text, style: TextStyle(color: bluePurple, fontSize: 16),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: signatureDatesOnBeforeYes1,
                onChanged: (bool value) => setState(() {
                  signatureDatesOnBeforeYes1 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.signatureDatesOnBeforeYes1, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (signatureDatesOnBeforeNo1 == true){
                    signatureDatesOnBeforeNo1 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.signatureDatesOnBeforeNo1, null, widget.jobId, widget.saved, widget.savedId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: signatureDatesOnBeforeNo1,
                onChanged: (bool value) => setState(() {
                  signatureDatesOnBeforeNo1 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.signatureDatesOnBeforeNo1, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (signatureDatesOnBeforeYes1 == true){
                    signatureDatesOnBeforeYes1 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.signatureDatesOnBeforeYes1, null, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowPractitionersNameYes1(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
Text(text, style: TextStyle(color: bluePurple, fontSize: 16),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: practitionersNameYes1,
                onChanged: (bool value) => setState(() {
                  practitionersNameYes1 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.practitionersNameYes1, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (practitionersNameNo1 == true){
                    practitionersNameNo1 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.practitionersNameNo1, null, widget.jobId, widget.saved, widget.savedId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: practitionersNameNo1,
                onChanged: (bool value) => setState(() {
                  practitionersNameNo1 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.practitionersNameNo1, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (practitionersNameYes1 == true){
                    practitionersNameYes1 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.practitionersNameYes1, null, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowPatientCorrectYes2(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
Text(text, style: TextStyle(color: bluePurple, fontSize: 16),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: patientCorrectYes2,
                onChanged: (bool value) => setState(() {
                  patientCorrectYes2 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.patientCorrectYes2, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (patientCorrectNo2 == true){
                    patientCorrectNo2 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.patientCorrectNo2, null, widget.jobId, widget.saved, widget.savedId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: patientCorrectNo2,
                onChanged: (bool value) => setState(() {
                  patientCorrectNo2 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.patientCorrectNo2, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (patientCorrectYes2 == true){
                    patientCorrectYes2 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.patientCorrectYes2, null, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowHospitalCorrectYes2(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
Text(text, style: TextStyle(color: bluePurple, fontSize: 16),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: hospitalCorrectYes2,
                onChanged: (bool value) => setState(() {
                  hospitalCorrectYes2 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.hospitalCorrectYes2, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (hospitalCorrectNo2 == true){
                    hospitalCorrectNo2 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.hospitalCorrectNo2, null, widget.jobId, widget.saved, widget.savedId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: hospitalCorrectNo2,
                onChanged: (bool value) => setState(() {
                  hospitalCorrectNo2 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.hospitalCorrectNo2, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (hospitalCorrectYes2 == true){
                    hospitalCorrectYes2 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.hospitalCorrectYes2, null, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowApplicationFormYes2(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
Text(text, style: TextStyle(color: bluePurple, fontSize: 16),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: applicationFormYes2,
                onChanged: (bool value) => setState(() {
                  applicationFormYes2 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.applicationFormYes2, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (applicationFormNo2 == true){
                    applicationFormNo2 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.applicationFormNo2, null, widget.jobId, widget.saved, widget.savedId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: applicationFormNo2,
                onChanged: (bool value) => setState(() {
                  applicationFormNo2 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.applicationFormNo2, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (applicationFormYes2 == true){
                    applicationFormYes2 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.applicationFormYes2, null, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowApplicationSignedYes2(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
Text(text, style: TextStyle(color: bluePurple, fontSize: 16),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: applicationSignedYes2,
                onChanged: (bool value) => setState(() {
                  applicationSignedYes2 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.applicationSignedYes2, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (applicationSignedNo2 == true){
                    applicationSignedNo2 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.applicationSignedNo2, null, widget.jobId, widget.saved, widget.savedId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: applicationSignedNo2,
                onChanged: (bool value) => setState(() {
                  applicationSignedNo2 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.applicationSignedNo2, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (applicationSignedYes2 == true){
                    applicationSignedYes2 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.applicationSignedYes2, null, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowAmhpIdentifiedYes(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
Text(text, style: TextStyle(color: bluePurple, fontSize: 16),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: amhpIdentifiedYes,
                onChanged: (bool value) => setState(() {
                  amhpIdentifiedYes = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.amhpIdentifiedYes, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (amhpIdentifiedNo == true){
                    amhpIdentifiedNo = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.amhpIdentifiedNo, null, widget.jobId, widget.saved, widget.savedId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: amhpIdentifiedNo,
                onChanged: (bool value) => setState(() {
                  amhpIdentifiedNo = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.amhpIdentifiedNo, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (amhpIdentifiedYes == true){
                    amhpIdentifiedYes = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.amhpIdentifiedYes, null, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowMedicalRecommendationsFormYes2(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
Text(text, style: TextStyle(color: bluePurple, fontSize: 16),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: medicalRecommendationsFormYes2,
                onChanged: (bool value) => setState(() {
                  medicalRecommendationsFormYes2 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.medicalRecommendationsFormYes2, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (medicalRecommendationsFormNo2 == true){
                    medicalRecommendationsFormNo2 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.medicalRecommendationsFormNo2, null, widget.jobId, widget.saved, widget.savedId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: medicalRecommendationsFormNo2,
                onChanged: (bool value) => setState(() {
                  medicalRecommendationsFormNo2 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.medicalRecommendationsFormNo2, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (medicalRecommendationsFormYes2 == true){
                    medicalRecommendationsFormYes2 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.medicalRecommendationsFormYes2, null, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowMedicalRecommendationsSignedYes2(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
Text(text, style: TextStyle(color: bluePurple, fontSize: 16),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: medicalRecommendationsSignedYes2,
                onChanged: (bool value) => setState(() {
                  medicalRecommendationsSignedYes2 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.medicalRecommendationsSignedYes2, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (medicalRecommendationsSignedNo2 == true){
                    medicalRecommendationsSignedNo2 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.medicalRecommendationsSignedNo2, null, widget.jobId, widget.saved, widget.savedId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: medicalRecommendationsSignedNo2,
                onChanged: (bool value) => setState(() {
                  medicalRecommendationsSignedNo2 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.medicalRecommendationsSignedNo2, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (medicalRecommendationsSignedYes2 == true){
                    medicalRecommendationsSignedYes2 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.medicalRecommendationsSignedYes2, null, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowClearDaysYes2(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
Text(text, style: TextStyle(color: bluePurple, fontSize: 16),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: clearDaysYes2,
                onChanged: (bool value) => setState(() {
                  clearDaysYes2 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.clearDaysYes2, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (clearDaysNo2 == true){
                    clearDaysNo2 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.clearDaysNo2, null, widget.jobId, widget.saved, widget.savedId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: clearDaysNo2,
                onChanged: (bool value) => setState(() {
                  clearDaysNo2 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.clearDaysNo2, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (clearDaysYes2 == true){
                    clearDaysYes2 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.clearDaysYes2, null, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowSignatureDatesOnBeforeYes2(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
Text(text, style: TextStyle(color: bluePurple, fontSize: 16),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: signatureDatesOnBeforeYes2,
                onChanged: (bool value) => setState(() {
                  signatureDatesOnBeforeYes2 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.signatureDatesOnBeforeYes2, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (signatureDatesOnBeforeNo2 == true){
                    signatureDatesOnBeforeNo2 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.signatureDatesOnBeforeNo2, null, widget.jobId, widget.saved, widget.savedId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: signatureDatesOnBeforeNo2,
                onChanged: (bool value) => setState(() {
                  signatureDatesOnBeforeNo2 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.signatureDatesOnBeforeNo2, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (signatureDatesOnBeforeYes2 == true){
                    signatureDatesOnBeforeYes2 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.signatureDatesOnBeforeYes2, null, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowPractitionersNameYes2(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
Text(text, style: TextStyle(color: bluePurple, fontSize: 16),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: practitionersNameYes2,
                onChanged: (bool value) => setState(() {
                  practitionersNameYes2 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.practitionersNameYes2, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (practitionersNameNo2 == true){
                    practitionersNameNo2 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.practitionersNameNo2, null, widget.jobId, widget.saved, widget.savedId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: practitionersNameNo2,
                onChanged: (bool value) => setState(() {
                  practitionersNameNo2 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.practitionersNameNo2, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (practitionersNameYes2 == true){
                    practitionersNameYes2 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.practitionersNameYes2, null, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowDoctorsAgreeYes(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
Text(text, style: TextStyle(color: bluePurple, fontSize: 16),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: doctorsAgreeYes,
                onChanged: (bool value) => setState(() {
                  doctorsAgreeYes = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.doctorsAgreeYes, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (doctorsAgreeNo == true){
                    doctorsAgreeNo = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.doctorsAgreeNo, null, widget.jobId, widget.saved, widget.savedId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: doctorsAgreeNo,
                onChanged: (bool value) => setState(() {
                  doctorsAgreeNo = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.doctorsAgreeNo, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (doctorsAgreeYes == true){
                    doctorsAgreeYes = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.doctorsAgreeYes, null, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowSeparateMedicalRecommendationsYes(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
Text(text, style: TextStyle(color: bluePurple, fontSize: 16),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: separateMedicalRecommendationsYes,
                onChanged: (bool value) => setState(() {
                  separateMedicalRecommendationsYes = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.separateMedicalRecommendationsYes, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (separateMedicalRecommendationsNo == true){
                    separateMedicalRecommendationsNo = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.separateMedicalRecommendationsNo, null, widget.jobId, widget.saved, widget.savedId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: separateMedicalRecommendationsNo,
                onChanged: (bool value) => setState(() {
                  separateMedicalRecommendationsNo = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.separateMedicalRecommendationsNo, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (separateMedicalRecommendationsYes == true){
                    separateMedicalRecommendationsYes = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.separateMedicalRecommendationsYes, null, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowPatientCorrectYes3(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
Text(text, style: TextStyle(color: bluePurple, fontSize: 16),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: patientCorrectYes3,
                onChanged: (bool value) => setState(() {
                  patientCorrectYes3 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.patientCorrectYes3, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (patientCorrectNo3 == true){
                    patientCorrectNo3 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.patientCorrectNo3, null, widget.jobId, widget.saved, widget.savedId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: patientCorrectNo3,
                onChanged: (bool value) => setState(() {
                  patientCorrectNo3 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.patientCorrectNo3, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (patientCorrectYes3 == true){
                    patientCorrectYes3 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.patientCorrectYes3, null, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowHospitalCorrectYes3(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
Text(text, style: TextStyle(color: bluePurple, fontSize: 16),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: hospitalCorrectYes3,
                onChanged: (bool value) => setState(() {
                  hospitalCorrectYes3 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.hospitalCorrectYes3, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (hospitalCorrectNo3 == true){
                    hospitalCorrectNo3 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.hospitalCorrectNo3, null, widget.jobId, widget.saved, widget.savedId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: hospitalCorrectNo3,
                onChanged: (bool value) => setState(() {
                  hospitalCorrectNo3 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.hospitalCorrectNo3, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (hospitalCorrectYes3 == true){
                    hospitalCorrectYes3 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.hospitalCorrectYes3, null, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowH4Yes(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
Text(text, style: TextStyle(color: bluePurple, fontSize: 16),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: h4Yes,
                onChanged: (bool value) => setState(() {
                  h4Yes = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.h4Yes, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (h4No == true){
                    h4No = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.h4No, null, widget.jobId, widget.saved, widget.savedId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: h4No,
                onChanged: (bool value) => setState(() {
                  h4No = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.h4No, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (h4Yes == true){
                    h4Yes = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.h4Yes, null, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowCurrentConsentYes(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
Text(text, style: TextStyle(color: bluePurple, fontSize: 16),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: currentConsentYes,
                onChanged: (bool value) => setState(() {
                  currentConsentYes = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.currentConsentYes, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (currentConsentNo == true){
                    currentConsentNo = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.currentConsentNo, null, widget.jobId, widget.saved, widget.savedId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: currentConsentNo,
                onChanged: (bool value) => setState(() {
                  currentConsentNo = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.currentConsentNo, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (currentConsentYes == true){
                    currentConsentYes = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.currentConsentYes, null, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowApplicationFormYes3(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
Text(text, style: TextStyle(color: bluePurple, fontSize: 16),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: applicationFormYes3,
                onChanged: (bool value) => setState(() {
                  applicationFormYes3 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.applicationFormYes3, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (applicationFormNo3 == true){
                    applicationFormNo3 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.applicationFormNo3, null, widget.jobId, widget.saved, widget.savedId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: applicationFormNo3,
                onChanged: (bool value) => setState(() {
                  applicationFormNo3 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.applicationFormNo3, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (applicationFormYes3 == true){
                    applicationFormYes3 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.applicationFormYes3, null, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowApplicationSignedYes3(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
Text(text, style: TextStyle(color: bluePurple, fontSize: 16),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: applicationSignedYes3,
                onChanged: (bool value) => setState(() {
                  applicationSignedYes3 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.applicationSignedYes3, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (applicationSignedNo3 == true){
                    applicationSignedNo3 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.applicationSignedNo3, null, widget.jobId, widget.saved, widget.savedId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: applicationSignedNo3,
                onChanged: (bool value) => setState(() {
                  applicationSignedNo3 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.applicationSignedNo3, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (applicationSignedYes3 == true){
                    applicationSignedYes3 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.applicationSignedYes3, null, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowWithin14DaysYes3(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
Text(text, style: TextStyle(color: bluePurple, fontSize: 16),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: within14DaysYes3,
                onChanged: (bool value) => setState(() {
                  within14DaysYes3 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.within14DaysYes3, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (within14DaysNo3 == true){
                    within14DaysNo3 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.within14DaysNo3, null, widget.jobId, widget.saved, widget.savedId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: within14DaysNo3,
                onChanged: (bool value) => setState(() {
                  within14DaysNo3 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.within14DaysNo3, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (within14DaysYes3 == true){
                    within14DaysYes3 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.within14DaysYes3, null, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowLocalAuthorityNameYes3(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
Text(text, style: TextStyle(color: bluePurple, fontSize: 16),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: localAuthorityNameYes3,
                onChanged: (bool value) => setState(() {
                  localAuthorityNameYes3 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.localAuthorityNameYes3, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (localAuthorityNameNo3 == true){
                    localAuthorityNameNo3 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.localAuthorityNameNo3, null, widget.jobId, widget.saved, widget.savedId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: localAuthorityNameNo3,
                onChanged: (bool value) => setState(() {
                  localAuthorityNameNo3 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.localAuthorityNameNo3, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (localAuthorityNameYes3 == true){
                    localAuthorityNameYes3 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.localAuthorityNameYes3, null, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowNearestRelativeYes(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
Text(text, style: TextStyle(color: bluePurple, fontSize: 16),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: nearestRelativeYes,
                onChanged: (bool value) => setState(() {
                  nearestRelativeYes = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.nearestRelativeYes, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (nearestRelativeNo == true){
                    nearestRelativeNo = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.nearestRelativeNo, null, widget.jobId, widget.saved, widget.savedId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: nearestRelativeNo,
                onChanged: (bool value) => setState(() {
                  nearestRelativeNo = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.nearestRelativeNo, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (nearestRelativeYes == true){
                    nearestRelativeYes = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.nearestRelativeYes, null, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowAmhpConsultationYes(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
Text(text, style: TextStyle(color: bluePurple, fontSize: 16),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: amhpConsultationYes,
                onChanged: (bool value) => setState(() {
                  amhpConsultationYes = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.amhpConsultationYes, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (amhpConsultationNo == true){
                    amhpConsultationNo = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.amhpConsultationNo, null, widget.jobId, widget.saved, widget.savedId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: amhpConsultationNo,
                onChanged: (bool value) => setState(() {
                  amhpConsultationNo = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.amhpConsultationNo, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (amhpConsultationYes == true){
                    amhpConsultationYes = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.amhpConsultationYes, null, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowKnewPatientYes(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
Text(text, style: TextStyle(color: bluePurple, fontSize: 16),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: knewPatientYes,
                onChanged: (bool value) => setState(() {
                  knewPatientYes = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.knewPatientYes, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (knewPatientNo == true){
                    knewPatientNo = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.knewPatientNo, null, widget.jobId, widget.saved, widget.savedId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: knewPatientNo,
                onChanged: (bool value) => setState(() {
                  knewPatientNo = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.knewPatientNo, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (knewPatientYes == true){
                    knewPatientYes = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.knewPatientYes, null, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowMedicalRecommendationsFormYes3(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
Text(text, style: TextStyle(color: bluePurple, fontSize: 16),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: medicalRecommendationsFormYes3,
                onChanged: (bool value) => setState(() {
                  medicalRecommendationsFormYes3 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.medicalRecommendationsFormYes3, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (medicalRecommendationsFormNo3 == true){
                    medicalRecommendationsFormNo3 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.medicalRecommendationsFormNo3, null, widget.jobId, widget.saved, widget.savedId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: medicalRecommendationsFormNo3,
                onChanged: (bool value) => setState(() {
                  medicalRecommendationsFormNo3 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.medicalRecommendationsFormNo3, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (medicalRecommendationsFormYes3 == true){
                    medicalRecommendationsFormYes3 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.medicalRecommendationsFormYes3, null, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowMedicalRecommendationsSignedYes3(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
Text(text, style: TextStyle(color: bluePurple, fontSize: 16),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: medicalRecommendationsSignedYes3,
                onChanged: (bool value) => setState(() {
                  medicalRecommendationsSignedYes3 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.medicalRecommendationsSignedYes3, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (medicalRecommendationsSignedNo3 == true){
                    medicalRecommendationsSignedNo3 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.medicalRecommendationsSignedNo3, null, widget.jobId, widget.saved, widget.savedId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: medicalRecommendationsSignedNo3,
                onChanged: (bool value) => setState(() {
                  medicalRecommendationsSignedNo3 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.medicalRecommendationsSignedNo3, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (medicalRecommendationsSignedYes3 == true){
                    medicalRecommendationsSignedYes3 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.medicalRecommendationsSignedYes3, null, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowClearDaysYes3(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
Text(text, style: TextStyle(color: bluePurple, fontSize: 16),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: clearDaysYes3,
                onChanged: (bool value) => setState(() {
                  clearDaysYes3 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.clearDaysYes3, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (clearDaysNo3 == true){
                    clearDaysNo3 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.clearDaysNo3, null, widget.jobId, widget.saved, widget.savedId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: clearDaysNo3,
                onChanged: (bool value) => setState(() {
                  clearDaysNo3 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.clearDaysNo3, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (clearDaysYes3 == true){
                    clearDaysYes3 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.clearDaysYes3, null, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowApprovedSection12Yes(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
Text(text, style: TextStyle(color: bluePurple, fontSize: 16),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: approvedSection12Yes,
                onChanged: (bool value) => setState(() {
                  approvedSection12Yes = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.approvedSection12Yes, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (approvedSection12No == true){
                    approvedSection12No = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.approvedSection12No, null, widget.jobId, widget.saved, widget.savedId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: approvedSection12No,
                onChanged: (bool value) => setState(() {
                  approvedSection12No = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.approvedSection12No, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (approvedSection12Yes == true){
                    approvedSection12Yes = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.approvedSection12Yes, null, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowSignatureDatesOnBeforeYes3(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
Text(text, style: TextStyle(color: bluePurple, fontSize: 16),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: signatureDatesOnBeforeYes3,
                onChanged: (bool value) => setState(() {
                  signatureDatesOnBeforeYes3 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.signatureDatesOnBeforeYes3, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (signatureDatesOnBeforeNo3 == true){
                    signatureDatesOnBeforeNo3 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.signatureDatesOnBeforeNo3, null, widget.jobId, widget.saved, widget.savedId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: signatureDatesOnBeforeNo3,
                onChanged: (bool value) => setState(() {
                  signatureDatesOnBeforeNo3 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.signatureDatesOnBeforeNo3, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (signatureDatesOnBeforeYes3 == true){
                    signatureDatesOnBeforeYes3 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.signatureDatesOnBeforeYes3, null, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowPractitionersNameYes3(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
Text(text, style: TextStyle(color: bluePurple, fontSize: 16),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: practitionersNameYes3,
                onChanged: (bool value) => setState(() {
                  practitionersNameYes3 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.practitionersNameYes3, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (practitionersNameNo3 == true){
                    practitionersNameNo3 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.practitionersNameNo3, null, widget.jobId, widget.saved, widget.savedId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: practitionersNameNo3,
                onChanged: (bool value) => setState(() {
                  practitionersNameNo3 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.practitionersNameNo3, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (practitionersNameYes3 == true){
                    practitionersNameYes3 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.practitionersNameYes3, null, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowPreviouslyAcquaintedYes(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
Text(text, style: TextStyle(color: bluePurple, fontSize: 16),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: previouslyAcquaintedYes,
                onChanged: (bool value) => setState(() {
                  previouslyAcquaintedYes = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.previouslyAcquaintedYes, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (previouslyAcquaintedNo == true){
                    previouslyAcquaintedNo = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.previouslyAcquaintedNo, null, widget.jobId, widget.saved, widget.savedId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: previouslyAcquaintedNo,
                onChanged: (bool value) => setState(() {
                  previouslyAcquaintedNo = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.previouslyAcquaintedNo, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (previouslyAcquaintedYes == true){
                    previouslyAcquaintedYes = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.previouslyAcquaintedYes, null, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowAcquaintedIfNoYes(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
Text(text, style: TextStyle(color: bluePurple, fontSize: 16),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: acquaintedIfNoYes,
                onChanged: (bool value) => setState(() {
                  acquaintedIfNoYes = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.acquaintedIfNoYes, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (acquaintedIfNoNo == true){
                    acquaintedIfNoNo = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.acquaintedIfNoNo, null, widget.jobId, widget.saved, widget.savedId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: acquaintedIfNoNo,
                onChanged: (bool value) => setState(() {
                  acquaintedIfNoNo = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.acquaintedIfNoNo, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (acquaintedIfNoYes == true){
                    acquaintedIfNoYes = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.acquaintedIfNoYes, null, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowRecommendationsDifferentTeamsYes(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
Text(text, style: TextStyle(color: bluePurple, fontSize: 16),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: recommendationsDifferentTeamsYes,
                onChanged: (bool value) => setState(() {
                  recommendationsDifferentTeamsYes = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.recommendationsDifferentTeamsYes, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (recommendationsDifferentTeamsNo == true){
                    recommendationsDifferentTeamsNo = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.recommendationsDifferentTeamsNo, null, widget.jobId, widget.saved, widget.savedId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: recommendationsDifferentTeamsNo,
                onChanged: (bool value) => setState(() {
                  recommendationsDifferentTeamsNo = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.recommendationsDifferentTeamsNo, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (recommendationsDifferentTeamsYes == true){
                    recommendationsDifferentTeamsYes = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.recommendationsDifferentTeamsYes, null, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowOriginalDetentionPapersYes(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
Text(text, style: TextStyle(color: bluePurple, fontSize: 16),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: originalDetentionPapersYes,
                onChanged: (bool value) => setState(() {
                  originalDetentionPapersYes = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.originalDetentionPapersYes, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (originalDetentionPapersNo == true){
                    originalDetentionPapersNo = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.originalDetentionPapersNo, null, widget.jobId, widget.saved, widget.savedId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: originalDetentionPapersNo,
                onChanged: (bool value) => setState(() {
                  originalDetentionPapersNo = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.originalDetentionPapersNo, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (originalDetentionPapersYes == true){
                    originalDetentionPapersYes = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.originalDetentionPapersYes, null, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        )
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
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: targetPadding / 2),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[


                _buildFormCheckboxes(),

                hasSection2Checklist ? Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('SECTION 2', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 18),),
                    ],),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('CHECKLIST', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 18),),
                    ],),
                    SizedBox(height: 20,),
                    _textFormField('Name of Patient', patientName),
                    SizedBox(height: 20,),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: bluePurple,
                        ),
                        children: <TextSpan>[
                          TextSpan(text: 'FOR ALL DOCUMENTS', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: ' (please put an x in the appropriate box)',),
                        ],
                      ),
                    ),
                    SizedBox(height: 10,),
                    _buildCheckboxRowPatientCorrectYes1("• is the patient correct name and address the same on all documents"),
                    _buildCheckboxRowHospitalCorrectYes1("• is the hospital name and address the same on the A1/A2"),
                    SizedBox(height: 20,),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: bluePurple,
                        ),
                        children: <TextSpan>[
                          TextSpan(text: 'APPLICATION', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: ' (please put an x in the appropriate box)',),
                        ],
                      ),
                    ),
                    _buildCheckboxRowApplicationFormYes1('• *is there an application on a Form A2?'),
                    _buildCheckboxRowApplicationSignedYes1('*is there Application A2 signed and dated by an Approved Mental Health Practitioner (AMHP)?'),
                    _buildCheckboxRowWithin14DaysYes1('• *is the date on which the applicant last saw the patient within 14 days of the date of application?'),
                    _buildCheckboxRowLocalAuthorityNameYes1('• is the local authority name?'),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: bluePurple,
                        ),
                        children: <TextSpan>[
                          TextSpan(text: 'MEDICAL RECOMMENDATIONS', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: ' (please put an x in the appropriate box)',),
                        ],
                      ),
                    ),
                    _buildCheckboxRowMedicalRecommendationsFormYes1('• *have two medical recommendations been received, either on a Form A3 or two A4s?'),
                    _buildCheckboxRowMedicalRecommendationsSignedYes1('• *have the medical recommendations been signed by the two doctors?'),
                    _buildCheckboxRowDatesSignatureSignedYes('• *are the dates of the signature been signed by the two doctors?'),
                    _buildCheckboxRowSignatureDatesOnBeforeYes1('• *are the dates of signature on both medical recommendations on or before the date of the application on Form A2?'),
                    _buildCheckboxRowPractitionersNameYes1('• have the medical practitioners entered their full name and address?'),
                    SizedBox(height: 20,),
                    Text('*Indicates non-rectifiable errors. If the answer to question marked with * is NO, the documents must be declared invalid and there is no authority to detain the patient. New forms will have to be provided.', style: TextStyle(color: bluePurple),),
                    // SizedBox(height: 20,),
                    // _textFormField('Checked By', transferInCheckedBy1),
                    // SizedBox(height: 10,),
                    // _buildTransferInSignature1Row(),
                    // _buildDateField('Date', transferInDate1, Strings.transferInDate1),
                    // _textFormField('Designation', transferInDesignation1),


                    SizedBox(height: 20,),
                  ],
                ) : Container(),

                hasSection3Checklist ? Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('SECTION 3', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 18),),
                    ],),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('CHECKLIST', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 18),),
                    ],),
                    SizedBox(height: 20,),
                    _textFormField('Name of Patient', patientName),
                    SizedBox(height: 20,),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: bluePurple,
                        ),
                        children: <TextSpan>[
                          TextSpan(text: 'FOR ALL DOCUMENTS', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: ' (please put an x in the appropriate box)',),
                        ],
                      ),
                    ),
                    SizedBox(height: 10,),
                    _buildCheckboxRowPatientCorrectYes2("• is the patient correct name and address the same on all documents"),
                    _buildCheckboxRowHospitalCorrectYes2("• Is the hospital name and address the same on the A5/A6? (and H3 if the patient is detained at collection address)"),
                    SizedBox(height: 20,),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: bluePurple,
                        ),
                        children: <TextSpan>[
                          TextSpan(text: 'APPLICATION', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: ' (please put an x in the appropriate box)',),
                        ],
                      ),
                    ),
                    _buildCheckboxRowApplicationFormYes2('• *Is there an application on a Form A6?'),
                    _buildCheckboxRowApplicationSignedYes2('• *Is there Application A6 signed and dated by an Approved Mental Health Practitioner (AMHP)?'),
                    _buildCheckboxRowAmhpIdentifiedYes('• Is the AMHP identified by name and address?'),
                    SizedBox(height: 20,),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: bluePurple,
                        ),
                        children: <TextSpan>[
                          TextSpan(text: 'MEDICAL RECOMMENDATIONS', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: ' (please put an x in the appropriate box)',),
                        ],
                      ),
                    ),
                    _buildCheckboxRowMedicalRecommendationsFormYes2('• *Have two medical recommendations been received, either on a Form A7 or two A8s?'),
                    _buildCheckboxRowMedicalRecommendationsSignedYes2('• *Have the medical recommendations been signed by the two doctors?'),
                    _buildCheckboxRowClearDaysYes2('• *Are there no more than 5 clear days between the dates of the two medical examinations?'),
                    _buildCheckboxRowSignatureDatesOnBeforeYes2('• *Are the dates of signature on both medical recommendations on or before the date of the application on Form A6?'),
                    _buildCheckboxRowPractitionersNameYes2('• Have the medical practitioners entered their full name and address?'),
                    _buildCheckboxRowDoctorsAgreeYes('• Do the two doctors agree on the hospital/unit where appropriate treatment is to be delivered?'),
                    _buildCheckboxRowSeparateMedicalRecommendationsYes('• If separate medical recommendations have been completed have both doctors specified the location in writing on the A8'),
                    SizedBox(height: 20,),
                    Text('*Indicates non-rectifiable errors. If the answer to question marked with * is NO, the documents must be declared invalid and there is no authority to detain the patient. New forms will have to be provided.', style: TextStyle(color: bluePurple),),
                    // SizedBox(height: 20,),
                    // _textFormField('Checked By', transferInCheckedBy2),
                    // SizedBox(height: 20,),
                    // _buildTransferInSignature2Row(),
                    // _buildDateField('Date', transferInDate2, Strings.transferInDate2),
                    // _textFormField('Designation', transferInDesignation2),

                    SizedBox(height: 20,),
                  ],
                ) : Container(),

                hasSection3TransferChecklist ? Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('SECTION 3', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 18),),
                    ],),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('TRANSFER CHECKLIST', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 18),),
                    ],),
                    SizedBox(height: 20,),
                    _textFormField('Name of Patient', patientName),
                    SizedBox(height: 20,),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: bluePurple,
                        ),
                        children: <TextSpan>[
                          TextSpan(text: 'FOR ALL DOCUMENTS', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: ' (please put an x in the appropriate box)',),
                        ],
                      ),
                    ),
                    SizedBox(height: 10,),
                    _buildCheckboxRowPatientCorrectYes3('• Is the patient correct name and address the same on all documents'),
                    _buildCheckboxRowHospitalCorrectYes3('• Is the hospital name and address the same on the A5/A6 and H3'),
                    _buildCheckboxRowH4Yes('• Is there a H4 (Section 19 transfer) with Part 1 completed by transferring hospital made out from and to the correct hospitals?'),
                    _buildCheckboxRowCurrentConsentYes('• Is there a current consent to treatment document (T2 or T3)'),
                    SizedBox(height: 20,),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: bluePurple,
                        ),
                        children: <TextSpan>[
                          TextSpan(text: 'ON THE ORIGINAL APPLICATION', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: ' (please put an x in the appropriate box)',),
                        ],
                      ),
                    ),
                    _buildCheckboxRowApplicationFormYes3('• *Is there an application on a Form A6?'),
                    _buildCheckboxRowApplicationSignedYes3('• *Is there Application A6 signed and dated by an Approved Mental Health Practitioner (AMHP)?'),
                    _buildCheckboxRowWithin14DaysYes3('• *Is the date on which the applicant last saw the patient within 14 days of the date of application?'),
                    _buildCheckboxRowLocalAuthorityNameYes3('• Is the local authority named?'),
                    _buildCheckboxRowNearestRelativeYes('• Has the nearest relative been consulted by the AMHP and has the full name and address of the nearest relative been entered on the form?'),
                    _buildCheckboxRowAmhpConsultationYes('• If not, has the AMHP identified why consultation did not take place?'),
                    _buildCheckboxRowKnewPatientYes('• If neither medical practitioners completing the recommendations knew the patient prior to the application, does the application form contain an explanation?'),
                    SizedBox(height: 20,),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: bluePurple,
                        ),
                        children: <TextSpan>[
                          TextSpan(text: 'MEDICAL RECOMMENDATIONS', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: ' (please put an x in the appropriate box)',),
                        ],
                      ),
                    ),
                    _buildCheckboxRowMedicalRecommendationsFormYes3('• *Have two medical recommendations been received, either on a Form A7 or two A8s?'),
                    _buildCheckboxRowMedicalRecommendationsSignedYes3('• *Have the medical recommendations been signed by the two doctors?'),
                    _buildCheckboxRowClearDaysYes3('• *Are there no more than 5 clear days between the between the dates of the two medical examinations?'),
                    _buildCheckboxRowApprovedSection12Yes('• *Is one of the medical recommendations signed by doctor approved for the purpose of the Section 12 of the Act'),
                    _buildCheckboxRowSignatureDatesOnBeforeYes3('• *Are the dates of signature on both medical recommendations on or before the date application on Form A6?'),
                    _buildCheckboxRowPractitionersNameYes3('• Have the medical practitioners entered their full name and address?'),
                    _buildCheckboxRowPreviouslyAcquaintedYes('• Is one of the medical recommendations signed by doctor previously acquainted with the patient?'),
                    _buildCheckboxRowAcquaintedIfNoYes('• If NO, has the paragraph set aside on Form A6 been completed, explaining why this is not so?'),
                    _buildCheckboxRowRecommendationsDifferentTeamsYes('• Are the two doctors making the recommendations from different teams?'),
                    _buildCheckboxRowOriginalDetentionPapersYes('• On the original detention papers is the name of the hospital/unit specified where appropriate treatment is to be delivered?'),
                    SizedBox(height: 20,),
                    Text('*Indicates non-rectifiable errors. If the answer to question marked with * is NO, the documents must be declared invalid and there is no authority to detain the patient. New forms will have to be provided.', style: TextStyle(color: bluePurple),),
                    SizedBox(height: 20,),
                    // _textFormField('Checked By', transferInCheckedBy3),
                    // _buildTransferInSignature3Row(),
                    // _buildDateField('Date', transferInDate3, Strings.transferInDate3),
                    // _textFormField('Designation', transferInDesignation3),
                  ],
                ) : Container(),
              ]),
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

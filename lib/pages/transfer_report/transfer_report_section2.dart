import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:pegasus_medical_1808/models/transfer_report_model.dart';
import 'package:pegasus_medical_1808/shared/global_config.dart';
import 'package:pegasus_medical_1808/shared/global_functions.dart';
import 'package:pegasus_medical_1808/shared/strings.dart';
import 'package:pegasus_medical_1808/utils/database_helper.dart';
import 'package:pegasus_medical_1808/widgets/dropdown_form_field.dart';
import 'package:pegasus_medical_1808/widgets/gradient_button.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:signature/signature.dart';

class TransferReportSection2 extends StatefulWidget {
  final bool fromJob;
  final String jobId;
  final bool fillDetails;
  final bool edit;
  final bool saved;
  final int savedId;

  TransferReportSection2(
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
  _TransferReportSection2State createState() => _TransferReportSection2State();
}

class _TransferReportSection2State extends State<TransferReportSection2> {

  bool _loadingTemporary = false;
  //DatabaseHelper _databaseHelper = DatabaseHelper();
  TransferReportModel transferReportModel;
  final dateFormat = DateFormat("dd/MM/yyyy");
  final timeFormat = DateFormat("HH:mm");
  //String gender = 'Select One';
  bool riskYes = false;
  bool riskNo = false;
  bool forensicHistoryYes = false;
  bool forensicHistoryNo = false;
  bool racialGenderConcernsYes = false;
  bool racialGenderConcernsNo = false;
  bool violenceAggressionYes = false;
  bool violenceAggressionNo = false;
  bool selfHarmYes = false;
  bool selfHarmNo = false;
  bool alcoholSubstanceYes = false;
  bool alcoholSubstanceNo = false;
  bool virusesYes = false;
  bool virusesNo = false;
  bool safeguardingYes = false;
  bool safeguardingNo = false;
  bool physicalHealthConditionsYes = false;
  bool physicalHealthConditionsNo = false;
  bool useOfWeaponYes = false;
  bool useOfWeaponNo = false;
  bool absconsionRiskYes = false;
  bool absconsionRiskNo = false;
  bool patientPropertyYes = false;
  bool patientPropertyNo = false;
  bool patientSearchedYes = false;
  bool patientSearchedNo = false;
  bool patientPropertyReceivedYes = false;
  bool patientPropertyReceivedNo = false;
  bool patientNotesReceivedYes = false;
  bool patientNotesReceivedNo = false;
  bool medicalAttentionYes = false;
  bool medicalAttentionNo = false;
  bool relevantInformationYes = false;
  bool relevantInformationNo = false;
  bool acceptPpeYes = false;
  bool acceptPpeNo = false;
  bool itemsRemovedYes = false;
  bool itemsRemovedNo = false;
  bool handcuffsUsedYes = false;
  bool handcuffsUsedNo = false;
  bool physicalInterventionYes = false;
  bool physicalInterventionNo = false;
  String physicalIntervention = 'Select One';
  // List<String> genderDrop = [
  //   'Select One',
  //   'Female',
  //   'Male',
  //   'Other'];
  List<String> physicalInterventionDrop = [
    'Select One',
    'Pro-Active',
    'Transfer to Seclusion',
    'Transfer to Delivery Unit',
    'Transfer from Collection Unit',
    'Reactive',
    ];

  List<Point> patientReportSignaturePoints = [];
  Signature patientReportSignature;
  Uint8List patientReportImageBytes;

  List<Point> incidentSignaturePoints = [];
  Signature incidentSignature;
  Uint8List incidentImageBytes;



  List<Point> bodyMapPoints = [];
  Signature bodyMapSignature;
  Uint8List bodyMapImageBytes;


  var scr= new GlobalKey();

  final TextEditingController patientName = TextEditingController();
  final TextEditingController dateOfBirth = TextEditingController();
  final TextEditingController ethnicity = TextEditingController();
  final TextEditingController gender = TextEditingController();
  final TextEditingController mhaMcaDetails = TextEditingController();
  final TextEditingController diagnosis = TextEditingController();
  final TextEditingController currentPresentation = TextEditingController();
  final TextEditingController riskExplanation = TextEditingController();
  final TextEditingController forensicHistory = TextEditingController();
  final TextEditingController racialGenderConcerns = TextEditingController();
  final TextEditingController violenceAggression = TextEditingController();
  final TextEditingController selfHarm = TextEditingController();
  final TextEditingController alcoholSubstance = TextEditingController();
  final TextEditingController viruses = TextEditingController();
  final TextEditingController safeguarding = TextEditingController();
  final TextEditingController physicalHealthConditions = TextEditingController();
  final TextEditingController useOfWeapon = TextEditingController();
  final TextEditingController absconsionRisk = TextEditingController();
  final TextEditingController patientPropertyExplanation = TextEditingController();
  final TextEditingController patientPropertyReceived = TextEditingController();
  final TextEditingController patientNotesReceived = TextEditingController();
  final TextEditingController patientSearched = TextEditingController();
  final TextEditingController itemsRemoved = TextEditingController();
  final TextEditingController patientInformed = TextEditingController();
  final TextEditingController injuriesNoted = TextEditingController();
  final TextEditingController medicalAttention = TextEditingController();
  final TextEditingController currentMedication = TextEditingController();
  final TextEditingController physicalObservations = TextEditingController();
  final TextEditingController relevantInformation = TextEditingController();
  final TextEditingController patientReport = TextEditingController();
  final TextEditingController patientReportPrintName = TextEditingController();
  final TextEditingController patientReportRole = TextEditingController();
  final TextEditingController patientReportDate = TextEditingController();
  final TextEditingController patientReportTime = TextEditingController();
  final TextEditingController handcuffsDate = TextEditingController();
  final TextEditingController handcuffsTime = TextEditingController();
  final TextEditingController handcuffsAuthorisedBy = TextEditingController();
  final TextEditingController handcuffsAppliedBy = TextEditingController();
  final TextEditingController handcuffsRemovedTime = TextEditingController();
  final TextEditingController whyInterventionRequired = TextEditingController();
  final TextEditingController techniqueName1 = TextEditingController();
  final TextEditingController techniqueName2 = TextEditingController();
  final TextEditingController techniqueName3 = TextEditingController();
  final TextEditingController techniqueName4 = TextEditingController();
  final TextEditingController techniqueName5 = TextEditingController();
  final TextEditingController techniqueName6 = TextEditingController();
  final TextEditingController techniqueName7 = TextEditingController();
  final TextEditingController techniqueName8 = TextEditingController();
  final TextEditingController techniqueName9 = TextEditingController();
  final TextEditingController techniqueName10 = TextEditingController();
  final TextEditingController technique1 = TextEditingController();
  final TextEditingController technique2 = TextEditingController();
  final TextEditingController technique3 = TextEditingController();
  final TextEditingController technique4 = TextEditingController();
  final TextEditingController technique5 = TextEditingController();
  final TextEditingController technique6 = TextEditingController();
  final TextEditingController technique7 = TextEditingController();
  final TextEditingController technique8 = TextEditingController();
  final TextEditingController technique9 = TextEditingController();
  final TextEditingController technique10 = TextEditingController();
  final TextEditingController techniquePosition1 = TextEditingController();
  final TextEditingController techniquePosition2 = TextEditingController();
  final TextEditingController techniquePosition3 = TextEditingController();
  final TextEditingController techniquePosition4 = TextEditingController();
  final TextEditingController techniquePosition5 = TextEditingController();
  final TextEditingController techniquePosition6 = TextEditingController();
  final TextEditingController techniquePosition7 = TextEditingController();
  final TextEditingController techniquePosition8 = TextEditingController();
  final TextEditingController techniquePosition9 = TextEditingController();
  final TextEditingController techniquePosition10 = TextEditingController();
  final TextEditingController timeInterventionCommenced = TextEditingController();
  final TextEditingController timeInterventionCompleted = TextEditingController();
  final TextEditingController incidentDate = TextEditingController();
  final TextEditingController incidentTime = TextEditingController();
  final TextEditingController incidentDetails = TextEditingController();
  final TextEditingController incidentLocation = TextEditingController();
  final TextEditingController incidentAction = TextEditingController();
  final TextEditingController incidentStaffInvolved = TextEditingController();
  final TextEditingController incidentSignatureDate = TextEditingController();
  final TextEditingController incidentPrintName = TextEditingController();


  int rowCount = 1;
  int roleCount = 1;




  @override
  void initState() {
    // TODO: implement initState
    _loadingTemporary = true;
    transferReportModel =
        Provider.of<TransferReportModel>(context, listen: false);
    _setUpTextControllerListeners();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      bodyMapSignature = Signature(onChanged: (_) => _onChangedBodyMap(),
        points: bodyMapPoints,
        height: buildSignatureHeightWidth(true),
        width: buildSignatureHeightWidth(false),
        backgroundColor: Colors.transparent,
      );
    });

    _getTemporaryTransferReport();


    super.initState();
  }

  double buildSignatureHeightWidth(bool height){
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 768.0 ? 600.0 : deviceWidth * 0.95;
    return height ? targetWidth * 0.85 : targetWidth;
  }


  void _onChangedBodyMap() async {

    RenderRepaintBoundary boundary = scr.currentContext.findRenderObject();
    var image = await boundary.toImage();
    var byteData = await image.toByteData(format: ImageByteFormat.png);
    setState(() {
      bodyMapImageBytes = byteData.buffer.asUint8List();

    });

    Uint8List encryptedImage = await GlobalFunctions
        .encryptSignature(bodyMapImageBytes);

    transferReportModel.updateTemporaryRecord(widget.edit, Strings.bodyMapImage, encryptedImage, widget.jobId, widget.saved, widget.savedId);


    // _databaseHelper
    //     .updateTemporaryTransferReportField(widget.edit, {
    //   Strings.bodyMapImage: encryptedImage
    // }, user.uid,
    //     widget.jobId, widget.saved, widget.savedId);

    List<Map<String, dynamic>> pointsMap = [];

    bodyMapPoints =
        bodyMapSignature
            .exportPoints();

    if (bodyMapPoints.length > 0) {
      bodyMapPoints.forEach((
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

      transferReportModel.updateTemporaryRecord(widget.edit, Strings.bodyMapPoints, encryptedPoints, widget.jobId, widget.saved, widget.savedId);


      // _databaseHelper
      //     .updateTemporaryTransferReportField(widget.edit,
      //     {
      //       Strings.bodyMapPoints:
      //       encryptedPoints
      //     },
      //     user.uid,
      //     widget.jobId, widget.saved, widget.savedId);

    }
  }

  @override
  void dispose() {
    patientName.dispose();
    dateOfBirth.dispose();
    ethnicity.dispose();
    gender.dispose();
    mhaMcaDetails.dispose();
    diagnosis.dispose();
    currentPresentation.dispose();
    riskExplanation.dispose();
    forensicHistory.dispose();
    racialGenderConcerns.dispose();
    violenceAggression.dispose();
    selfHarm.dispose();
    alcoholSubstance.dispose();
    viruses.dispose();
    safeguarding.dispose();
    physicalHealthConditions.dispose();
    useOfWeapon.dispose();
    absconsionRisk.dispose();
    patientPropertyExplanation.dispose();
    patientPropertyReceived.dispose();
    patientNotesReceived.dispose();
    patientSearched.dispose();
    itemsRemoved.dispose();
    patientInformed.dispose();
    injuriesNoted.dispose();
    medicalAttention.dispose();
    currentMedication.dispose();
    physicalObservations.dispose();
    relevantInformation.dispose();
    patientReport.dispose();
    patientReportPrintName.dispose();
    patientReportRole.dispose();
    patientReportDate.dispose();
    patientReportTime.dispose();
    handcuffsDate.dispose();
    handcuffsTime.dispose();
    handcuffsAuthorisedBy.dispose();
    handcuffsAppliedBy.dispose();
    handcuffsRemovedTime.dispose();
    whyInterventionRequired.dispose();
    techniqueName1.dispose();
    techniqueName2.dispose();
    techniqueName3.dispose();
    techniqueName4.dispose();
    techniqueName5.dispose();
    techniqueName6.dispose();
    techniqueName7.dispose();
    techniqueName8.dispose();
    techniqueName9.dispose();
    techniqueName10.dispose();
    technique1.dispose();
    technique2.dispose();
    technique3.dispose();
    technique4.dispose();
    technique5.dispose();
    technique6.dispose();
    technique7.dispose();
    technique8.dispose();
    technique9.dispose();
    technique10.dispose();
    techniquePosition1.dispose();
    techniquePosition2.dispose();
    techniquePosition3.dispose();
    techniquePosition4.dispose();
    techniquePosition5.dispose();
    techniquePosition6.dispose();
    techniquePosition7.dispose();
    techniquePosition8.dispose();
    techniquePosition9.dispose();
    techniquePosition10.dispose();
    timeInterventionCommenced.dispose();
    timeInterventionCompleted.dispose();
    incidentDate.dispose();
    incidentTime.dispose();
    incidentDetails.dispose();
    incidentLocation.dispose();
    incidentAction.dispose();
    incidentStaffInvolved.dispose();
    incidentPrintName.dispose();
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
    _addListener(ethnicity, Strings.ethnicity);
    _addListener(gender, Strings.gender);
    _addListener(mhaMcaDetails, Strings.mhaMcaDetails);
    _addListener(diagnosis, Strings.diagnosis);
    _addListener(currentPresentation, Strings.currentPresentation);
    _addListener(riskExplanation, Strings.riskExplanation);
    _addListener(forensicHistory, Strings.forensicHistory);
    _addListener(racialGenderConcerns, Strings.racialGenderConcerns);
    _addListener(violenceAggression, Strings.violenceAggression);
    _addListener(selfHarm, Strings.selfHarm);
    _addListener(alcoholSubstance, Strings.alcoholSubstance);
    _addListener(viruses, Strings.viruses);
    _addListener(safeguarding, Strings.safeguarding);
    _addListener(physicalHealthConditions, Strings.physicalHealthConditions);
    _addListener(useOfWeapon, Strings.useOfWeapon);
    _addListener(absconsionRisk, Strings.absconsionRisk);
    _addListener(patientPropertyExplanation, Strings.patientPropertyExplanation);
    _addListener(patientPropertyReceived, Strings.patientPropertyReceived);
    _addListener(patientNotesReceived, Strings.patientNotesReceived);
    _addListener(patientSearched, Strings.patientSearched);
    _addListener(itemsRemoved, Strings.itemsRemoved);
    _addListener(patientInformed, Strings.patientInformed);
    _addListener(injuriesNoted, Strings.injuriesNoted);
    _addListener(medicalAttention, Strings.medicalAttention);
    _addListener(currentMedication, Strings.currentMedication);
    _addListener(physicalObservations, Strings.physicalObservations);
    _addListener(relevantInformation, Strings.relevantInformation);
    _addListener(patientReport, Strings.patientReport);
    _addListener(patientReportPrintName, Strings.patientReportPrintName, true, false, true);
    _addListener(patientReportRole, Strings.patientReportRole);
    _addListener(handcuffsAuthorisedBy, Strings.handcuffsAuthorisedBy, true, false, true);
    _addListener(handcuffsAppliedBy, Strings.handcuffsAppliedBy, true, false, true);
    _addListener(whyInterventionRequired, Strings.whyInterventionRequired);
    _addListener(techniqueName1, Strings.techniqueName1, true, false, true);
    _addListener(techniqueName2, Strings.techniqueName2, true, false, true);
    _addListener(techniqueName3, Strings.techniqueName3, true, false, true);
    _addListener(techniqueName4, Strings.techniqueName4, true, false, true);
    _addListener(techniqueName5, Strings.techniqueName5, true, false, true);
    _addListener(techniqueName6, Strings.techniqueName6, true, false, true);
    _addListener(techniqueName7, Strings.techniqueName7, true, false, true);
    _addListener(techniqueName8, Strings.techniqueName8, true, false, true);
    _addListener(techniqueName9, Strings.techniqueName9, true, false, true);
    _addListener(techniqueName10, Strings.techniqueName10, true, false, true);
    _addListener(technique1, Strings.technique1);
    _addListener(technique2, Strings.technique2);
    _addListener(technique3, Strings.technique3);
    _addListener(technique4, Strings.technique4);
    _addListener(technique5, Strings.technique5);
    _addListener(technique6, Strings.technique6);
    _addListener(technique7, Strings.technique7);
    _addListener(technique8, Strings.technique8);
    _addListener(technique9, Strings.technique9);
    _addListener(technique10, Strings.technique10);
    _addListener(techniquePosition1, Strings.techniquePosition1);
    _addListener(techniquePosition2, Strings.techniquePosition2);
    _addListener(techniquePosition3, Strings.techniquePosition3);
    _addListener(techniquePosition4, Strings.techniquePosition4);
    _addListener(techniquePosition5, Strings.techniquePosition5);
    _addListener(techniquePosition6, Strings.techniquePosition6);
    _addListener(techniquePosition7, Strings.techniquePosition7);
    _addListener(techniquePosition8, Strings.techniquePosition8);
    _addListener(techniquePosition9, Strings.techniquePosition9);
    _addListener(techniquePosition10, Strings.techniquePosition10);
    _addListener(incidentDetails, Strings.incidentDetails);
    _addListener(incidentLocation, Strings.incidentLocation);
    _addListener(incidentAction, Strings.incidentAction);
    _addListener(incidentStaffInvolved, Strings.incidentStaffInvolved);
    _addListener(incidentPrintName, Strings.incidentPrintName, true, false, true);

  }


  _getTemporaryTransferReport() async {

    if (mounted) {
      bool hasRecord = await transferReportModel.checkRecordExists(widget.edit, widget.jobId, widget.saved, widget.savedId);

      if(hasRecord){
        Map<String, dynamic> transferReport = await transferReportModel.getTemporaryRecord(widget.edit, widget.jobId, widget.saved, widget.savedId);


        if (transferReport[Strings.incidentSignature] != null) {
          if (mounted) {
            Uint8List decryptedSignature = await GlobalFunctions.decryptSignature(transferReport[Strings.incidentSignature]);
            setState(() {
              incidentImageBytes = decryptedSignature;
            });
          }
        } else {
          incidentSignature = null;
          incidentImageBytes = null;
        }
        if (transferReport[Strings.incidentSignaturePoints] != null) {
          if (mounted) {
            String decryptedPoints = GlobalFunctions.decryptString(transferReport[Strings.incidentSignaturePoints]);
            setState(() {
              List<dynamic> fetchedSignaturePoints = jsonDecode(decryptedPoints);
              fetchedSignaturePoints.forEach((dynamic pointMap) {
                if (pointMap['pointType'] == 'tap') {
                  incidentSignaturePoints.add(Point(
                      Offset(pointMap['dx'], pointMap['dy']),
                      PointType.tap));
                } else if (pointMap['pointType'] == 'move') {
                  incidentSignaturePoints.add(Point(
                      Offset(pointMap['dx'], pointMap['dy']),
                      PointType.move));
                }
              });
            });
          }
        } else {
          incidentSignaturePoints = [];

        }

        if (transferReport[Strings.incidentDate] != null) {
          incidentDate.text =
              dateFormat.format(DateTime.parse(transferReport[Strings.incidentDate]));
        } else {
          incidentDate.text = '';
        }
        GlobalFunctions.getTemporaryValueTime(transferReport, incidentTime, Strings.incidentTime);
        GlobalFunctions.getTemporaryValue(transferReport, incidentDetails, Strings.incidentDetails);
        GlobalFunctions.getTemporaryValue(transferReport, incidentLocation, Strings.incidentLocation);
        GlobalFunctions.getTemporaryValue(transferReport, incidentAction, Strings.incidentAction);
        GlobalFunctions.getTemporaryValue(transferReport, incidentStaffInvolved, Strings.incidentStaffInvolved);
        GlobalFunctions.getTemporaryValue(transferReport, incidentPrintName, Strings.incidentPrintName);
        GlobalFunctions.getTemporaryValueDate(transferReport, incidentSignatureDate, Strings.incidentSignatureDate);

        if (transferReport[Strings.patientReportSignature] != null) {
          if (mounted) {
            Uint8List decryptedSignature = await GlobalFunctions.decryptSignature(transferReport[Strings.patientReportSignature]);
            setState(() {
              patientReportImageBytes = decryptedSignature;
            });
          }
        } else {
          patientReportSignature = null;
          patientReportImageBytes = null;
        }
        if (transferReport[Strings.patientReportSignaturePoints] != null) {
          if (mounted) {
            String decryptedPoints = GlobalFunctions.decryptString(transferReport[Strings.patientReportSignaturePoints]);
            setState(() {
              List<dynamic> fetchedSignaturePoints = jsonDecode(decryptedPoints);
              fetchedSignaturePoints.forEach((dynamic pointMap) {
                if (pointMap['pointType'] == 'tap') {
                  patientReportSignaturePoints.add(Point(
                      Offset(pointMap['dx'], pointMap['dy']),
                      PointType.tap));
                } else if (pointMap['pointType'] == 'move') {
                  patientReportSignaturePoints.add(Point(
                      Offset(pointMap['dx'], pointMap['dy']),
                      PointType.move));
                }
              });
            });
          }
        } else {
          patientReportSignaturePoints = [];

        }

        if (transferReport[Strings.bodyMapPoints] != null) {
          if (mounted) {
            String decryptedPoints = GlobalFunctions.decryptString(transferReport[Strings.bodyMapPoints]);
            setState(() {
              List<dynamic> fetchedSignaturePoints = jsonDecode(decryptedPoints);
              fetchedSignaturePoints.forEach((dynamic pointMap) {
                if (pointMap['pointType'] == 'tap') {
                  bodyMapPoints.add(Point(
                      Offset(pointMap['dx'], pointMap['dy']),
                      PointType.tap));
                } else if (pointMap['pointType'] == 'move') {
                  bodyMapPoints.add(Point(
                      Offset(pointMap['dx'], pointMap['dy']),
                      PointType.move));
                }
              });
            });
          }
        } else {
          bodyMapPoints = [];

        }

        GlobalFunctions.getTemporaryValue(transferReport, patientName, Strings.patientName);
        GlobalFunctions.getTemporaryValueDate(transferReport, dateOfBirth, Strings.dateOfBirth, true);
        GlobalFunctions.getTemporaryValue(transferReport, ethnicity, Strings.ethnicity);
        GlobalFunctions.getTemporaryValue(transferReport, gender, Strings.gender);
        GlobalFunctions.getTemporaryValue(transferReport, mhaMcaDetails, Strings.mhaMcaDetails);
        GlobalFunctions.getTemporaryValue(transferReport, diagnosis, Strings.diagnosis);
        GlobalFunctions.getTemporaryValue(transferReport, currentPresentation, Strings.currentPresentation);
        if (transferReport[Strings.riskYes] != null) {
          if (mounted) {
            setState(() {
              riskYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.riskYes]);
            });
          }
        }
        if (transferReport[Strings.riskNo] != null) {
          if (mounted) {
            setState(() {
              riskNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.riskNo]);
            });
          }
        }
        GlobalFunctions.getTemporaryValue(transferReport, riskExplanation, Strings.riskExplanation);
        if (transferReport[Strings.forensicHistoryYes] != null) {
          if (mounted) {
            setState(() {
              forensicHistoryYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.forensicHistoryYes]);
            });
          }
        }
        if (transferReport[Strings.forensicHistoryNo] != null) {
          if (mounted) {
            setState(() {
              forensicHistoryNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.forensicHistoryNo]);
            });
          }
        }
        if (transferReport[Strings.racialGenderConcernsYes] != null) {
          if (mounted) {
            setState(() {
              racialGenderConcernsYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.racialGenderConcernsYes]);
            });
          }
        }
        if (transferReport[Strings.racialGenderConcernsNo] != null) {
          if (mounted) {
            setState(() {
              racialGenderConcernsNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.racialGenderConcernsNo]);
            });
          }
        }
        if (transferReport[Strings.violenceAggressionYes] != null) {
          if (mounted) {
            setState(() {
              violenceAggressionYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.violenceAggressionYes]);
            });
          }
        }
        if (transferReport[Strings.violenceAggressionNo] != null) {
          if (mounted) {
            setState(() {
              violenceAggressionNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.violenceAggressionNo]);
            });
          }
        }
        if (transferReport[Strings.selfHarmYes] != null) {
          if (mounted) {
            setState(() {
              selfHarmYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.selfHarmYes]);
            });
          }
        }
        if (transferReport[Strings.selfHarmNo] != null) {
          if (mounted) {
            setState(() {
              selfHarmNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.selfHarmNo]);
            });
          }
        }
        if (transferReport[Strings.alcoholSubstanceYes] != null) {
          if (mounted) {
            setState(() {
              alcoholSubstanceYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.alcoholSubstanceYes]);
            });
          }
        }
        if (transferReport[Strings.alcoholSubstanceNo] != null) {
          if (mounted) {
            setState(() {
              alcoholSubstanceNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.alcoholSubstanceNo]);
            });
          }
        }
        if (transferReport[Strings.virusesYes] != null) {
          if (mounted) {
            setState(() {
              virusesYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.virusesYes]);
            });
          }
        }
        if (transferReport[Strings.virusesNo] != null) {
          if (mounted) {
            setState(() {
              virusesNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.virusesNo]);
            });
          }
        }
        if (transferReport[Strings.safeguardingYes] != null) {
          if (mounted) {
            setState(() {
              safeguardingYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.safeguardingYes]);
            });
          }
        }
        if (transferReport[Strings.safeguardingNo] != null) {
          if (mounted) {
            setState(() {
              safeguardingNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.safeguardingNo]);
            });
          }
        }
        if (transferReport[Strings.physicalHealthConditionsYes] != null) {
          if (mounted) {
            setState(() {
              physicalHealthConditionsYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.physicalHealthConditionsYes]);
            });
          }
        }
        if (transferReport[Strings.physicalHealthConditionsNo] != null) {
          if (mounted) {
            setState(() {
              physicalHealthConditionsNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.physicalHealthConditionsNo]);
            });
          }
        }
        if (transferReport[Strings.useOfWeaponYes] != null) {
          if (mounted) {
            setState(() {
              useOfWeaponYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.useOfWeaponYes]);
            });
          }
        }
        if (transferReport[Strings.useOfWeaponNo] != null) {
          if (mounted) {
            setState(() {
              useOfWeaponNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.useOfWeaponNo]);
            });
          }
        }
        if (transferReport[Strings.absconsionRiskYes] != null) {
          if (mounted) {
            setState(() {
              absconsionRiskYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.absconsionRiskYes]);
            });
          }
        }
        if (transferReport[Strings.absconsionRiskNo] != null) {
          if (mounted) {
            setState(() {
              absconsionRiskNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.absconsionRiskNo]);
            });
          }
        }
        GlobalFunctions.getTemporaryValue(transferReport, forensicHistory, Strings.forensicHistory);
        GlobalFunctions.getTemporaryValue(transferReport, racialGenderConcerns, Strings.racialGenderConcerns);
        GlobalFunctions.getTemporaryValue(transferReport, violenceAggression, Strings.violenceAggression);
        GlobalFunctions.getTemporaryValue(transferReport, selfHarm, Strings.selfHarm);
        GlobalFunctions.getTemporaryValue(transferReport, alcoholSubstance, Strings.alcoholSubstance);
        GlobalFunctions.getTemporaryValue(transferReport, viruses, Strings.viruses);
        GlobalFunctions.getTemporaryValue(transferReport, safeguarding, Strings.safeguarding);
        GlobalFunctions.getTemporaryValue(transferReport, physicalHealthConditions, Strings.physicalHealthConditions);
        GlobalFunctions.getTemporaryValue(transferReport, useOfWeapon, Strings.useOfWeapon);
        GlobalFunctions.getTemporaryValue(transferReport, absconsionRisk, Strings.absconsionRisk);
        if (transferReport[Strings.patientPropertyYes] != null) {
          if (mounted) {
            setState(() {
              patientPropertyYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.patientPropertyYes]);
            });
          }
        }
        if (transferReport[Strings.patientPropertyNo] != null) {
          if (mounted) {
            setState(() {
              patientPropertyNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.patientPropertyNo]);
            });
          }
        }
        GlobalFunctions.getTemporaryValue(transferReport, patientPropertyExplanation, Strings.patientPropertyExplanation);
        if (transferReport[Strings.patientPropertyReceivedYes] != null) {
          if (mounted) {
            setState(() {
              patientPropertyReceivedYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.patientPropertyReceivedYes]);
            });
          }
        }
        if (transferReport[Strings.patientPropertyReceivedNo] != null) {
          if (mounted) {
            setState(() {
              patientPropertyReceivedNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.patientPropertyReceivedNo]);
            });
          }
        }
        GlobalFunctions.getTemporaryValue(transferReport, patientPropertyReceived, Strings.patientPropertyReceived);

        if (transferReport[Strings.patientNotesReceivedYes] != null) {
          if (mounted) {
            setState(() {
              patientNotesReceivedYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.patientNotesReceivedYes]);
            });
          }
        }
        if (transferReport[Strings.patientNotesReceivedNo] != null) {
          if (mounted) {
            setState(() {
              patientNotesReceivedNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.patientNotesReceivedNo]);
            });
          }
        }

        GlobalFunctions.getTemporaryValue(transferReport, patientNotesReceived, Strings.patientNotesReceived);
        if (transferReport[Strings.patientSearchedYes] != null) {
          if (mounted) {
            setState(() {
              patientSearchedYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.patientSearchedYes]);
            });
          }
        }
        if (transferReport[Strings.patientSearchedNo] != null) {
          if (mounted) {
            setState(() {
              patientSearchedNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.patientSearchedNo]);
            });
          }
        }
        if (transferReport[Strings.itemsRemovedYes] != null) {
          if (mounted) {
            setState(() {
              itemsRemovedYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.itemsRemovedYes]);
            });
          }
        }
        if (transferReport[Strings.itemsRemovedNo] != null) {
          if (mounted) {
            setState(() {
              itemsRemovedNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.itemsRemovedNo]);
            });
          }
        }
        GlobalFunctions.getTemporaryValue(transferReport, itemsRemoved, Strings.itemsRemoved);
        GlobalFunctions.getTemporaryValue(transferReport, patientInformed, Strings.patientInformed);
        GlobalFunctions.getTemporaryValue(transferReport, injuriesNoted, Strings.injuriesNoted);
        if (transferReport[Strings.medicalAttentionYes] != null) {
          if (mounted) {
            setState(() {
              medicalAttentionYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.medicalAttentionYes]);
            });
          }
        }
        if (transferReport[Strings.medicalAttentionNo] != null) {
          if (mounted) {
            setState(() {
              medicalAttentionNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.medicalAttentionNo]);
            });
          }
        }
        GlobalFunctions.getTemporaryValue(transferReport, medicalAttention, Strings.medicalAttention);
        GlobalFunctions.getTemporaryValue(transferReport, currentMedication, Strings.currentMedication);
        GlobalFunctions.getTemporaryValue(transferReport, physicalObservations, Strings.physicalObservations);
        if (transferReport[Strings.relevantInformationYes] != null) {
          if (mounted) {
            setState(() {
              relevantInformationYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.relevantInformationYes]);
            });
          }
        }
        if (transferReport[Strings.relevantInformationNo] != null) {
          if (mounted) {
            setState(() {
              relevantInformationNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.relevantInformationNo]);
            });
          }
        }
        GlobalFunctions.getTemporaryValue(transferReport, relevantInformation, Strings.relevantInformation);
        if (transferReport[Strings.acceptPpeYes] != null) {
          if (mounted) {
            setState(() {
              acceptPpeYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.acceptPpeYes]);
            });
          }
        }
        if (transferReport[Strings.acceptPpeNo] != null) {
          if (mounted) {
            setState(() {
              acceptPpeNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.acceptPpeNo]);
            });
          }
        }
        GlobalFunctions.getTemporaryValue(transferReport, patientReport, Strings.patientReport);
        if(transferReport[Strings.patientReportPrintName] == null){
          patientReportPrintName.text = user.name;
          transferReportModel.updateTemporaryRecord(widget.edit, Strings.patientReportPrintName, GlobalFunctions.encryptString(patientReportPrintName.text), widget.jobId, widget.saved, widget.savedId);

          // _databaseHelper.updateTemporaryTransferReportField(widget.edit, {
          //   Strings.patientReportPrintName: GlobalFunctions.encryptString(patientReportPrintName.text)
          // }, user.uid, widget.jobId, widget.saved, widget.savedId);
        } else {
          GlobalFunctions.getTemporaryValue(transferReport, patientReportPrintName, Strings.patientReportPrintName);
        }
        GlobalFunctions.getTemporaryValue(transferReport, patientReportRole, Strings.patientReportRole);
        GlobalFunctions.getTemporaryValueDate(transferReport, patientReportDate, Strings.patientReportDate);
        GlobalFunctions.getTemporaryValueTime(transferReport, patientReportTime, Strings.patientReportTime);
        if (transferReport[Strings.handcuffsUsedNo] != null) {
          if (mounted) {
            setState(() {
              handcuffsUsedNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.handcuffsUsedNo]);
            });
          }
        }
        if (transferReport[Strings.handcuffsUsedYes] != null) {
          if (mounted) {
            setState(() {
              handcuffsUsedYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.handcuffsUsedYes]);
            });
          }
        }
        if (transferReport[Strings.physicalInterventionNo] != null) {
          if (mounted) {
            setState(() {
              physicalInterventionNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.physicalInterventionNo]);
            });
          }
        }
        if (transferReport[Strings.physicalInterventionYes] != null) {
          if (mounted) {
            setState(() {
              physicalInterventionYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.physicalInterventionYes]);
            });
          }
        }
        GlobalFunctions.getTemporaryValueDate(transferReport, handcuffsDate, Strings.handcuffsDate);
        GlobalFunctions.getTemporaryValueTime(transferReport, handcuffsTime, Strings.handcuffsTime);
        GlobalFunctions.getTemporaryValue(transferReport, handcuffsAuthorisedBy, Strings.handcuffsAuthorisedBy);
        GlobalFunctions.getTemporaryValue(transferReport, handcuffsAppliedBy, Strings.handcuffsAppliedBy);
        GlobalFunctions.getTemporaryValueTime(transferReport, handcuffsRemovedTime, Strings.handcuffsRemovedTime);
        if (transferReport[Strings.physicalIntervention] != null) {
          physicalIntervention = GlobalFunctions.decryptString(transferReport[Strings.physicalIntervention]);
        }
        GlobalFunctions.getTemporaryValue(transferReport, whyInterventionRequired, Strings.whyInterventionRequired);


        if (transferReport[Strings.techniqueName1] != null) {
          setState(() {
            roleCount += 1;
          });
        }
        if (transferReport[Strings.techniqueName2] != null) {
          setState(() {
            roleCount += 1;
          });
        }
        if (transferReport[Strings.techniqueName3] != null) {
          setState(() {
            roleCount += 1;
          });
        }
        if (transferReport[Strings.techniqueName4] != null) {
          setState(() {
            roleCount += 1;
          });
        }
        if (transferReport[Strings.techniqueName4] != null) {
          setState(() {
            roleCount += 1;
          });
        }
        if (transferReport[Strings.techniqueName5] != null) {
          setState(() {
            roleCount += 1;
          });
        }
        if (transferReport[Strings.techniqueName6] != null) {
          setState(() {
            roleCount += 1;
          });
        }
        if (transferReport[Strings.techniqueName6] != null) {
          setState(() {
            roleCount += 1;
          });
        }
        if (transferReport[Strings.techniqueName7] != null) {
          setState(() {
            roleCount += 1;
          });
        }
        if (transferReport[Strings.techniqueName8] != null) {
          setState(() {
            roleCount += 1;
          });
        }
        if (transferReport[Strings.techniqueName9] != null) {
          setState(() {
            roleCount += 1;
          });
        }
        if (transferReport[Strings.techniqueName10] != null) {
          setState(() {
            roleCount += 1;
          });
        }
        setState(() {
          rowCount = roleCount;
        });
        GlobalFunctions.getTemporaryValue(transferReport, techniqueName1, Strings.techniqueName1);
        GlobalFunctions.getTemporaryValue(transferReport, techniqueName2, Strings.techniqueName2);
        GlobalFunctions.getTemporaryValue(transferReport, techniqueName3, Strings.techniqueName3);
        GlobalFunctions.getTemporaryValue(transferReport, techniqueName4, Strings.techniqueName4);
        GlobalFunctions.getTemporaryValue(transferReport, techniqueName5, Strings.techniqueName5);
        GlobalFunctions.getTemporaryValue(transferReport, techniqueName6, Strings.techniqueName6);
        GlobalFunctions.getTemporaryValue(transferReport, techniqueName7, Strings.techniqueName7);
        GlobalFunctions.getTemporaryValue(transferReport, techniqueName8, Strings.techniqueName8);
        GlobalFunctions.getTemporaryValue(transferReport, techniqueName9, Strings.techniqueName9);
        GlobalFunctions.getTemporaryValue(transferReport, techniqueName10, Strings.techniqueName10);
        GlobalFunctions.getTemporaryValue(transferReport, technique1, Strings.technique1);
        GlobalFunctions.getTemporaryValue(transferReport, technique2, Strings.technique2);
        GlobalFunctions.getTemporaryValue(transferReport, technique3, Strings.technique3);
        GlobalFunctions.getTemporaryValue(transferReport, technique4, Strings.technique4);
        GlobalFunctions.getTemporaryValue(transferReport, technique5, Strings.technique5);
        GlobalFunctions.getTemporaryValue(transferReport, technique6, Strings.technique6);
        GlobalFunctions.getTemporaryValue(transferReport, technique7, Strings.technique7);
        GlobalFunctions.getTemporaryValue(transferReport, technique8, Strings.technique8);
        GlobalFunctions.getTemporaryValue(transferReport, technique9, Strings.technique9);
        GlobalFunctions.getTemporaryValue(transferReport, technique10, Strings.technique10);
        GlobalFunctions.getTemporaryValue(transferReport, techniquePosition1, Strings.techniquePosition1);
        GlobalFunctions.getTemporaryValue(transferReport, techniquePosition2, Strings.techniquePosition2);
        GlobalFunctions.getTemporaryValue(transferReport, techniquePosition3, Strings.techniquePosition3);
        GlobalFunctions.getTemporaryValue(transferReport, techniquePosition4, Strings.techniquePosition4);
        GlobalFunctions.getTemporaryValue(transferReport, techniquePosition5, Strings.techniquePosition5);
        GlobalFunctions.getTemporaryValue(transferReport, techniquePosition6, Strings.techniquePosition6);
        GlobalFunctions.getTemporaryValue(transferReport, techniquePosition7, Strings.techniquePosition7);
        GlobalFunctions.getTemporaryValue(transferReport, techniquePosition8, Strings.techniquePosition8);
        GlobalFunctions.getTemporaryValue(transferReport, techniquePosition9, Strings.techniquePosition9);
        GlobalFunctions.getTemporaryValue(transferReport, techniquePosition10, Strings.techniquePosition10);
        GlobalFunctions.getTemporaryValueTime(transferReport, timeInterventionCommenced, Strings.timeInterventionCommenced);
        GlobalFunctions.getTemporaryValueTime(transferReport, timeInterventionCompleted, Strings.timeInterventionCompleted);



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
    //
    //     if (transferReport[Strings.incidentSignature] != null) {
    //       if (mounted) {
    //         Uint8List decryptedSignature = await GlobalFunctions.decryptSignature(transferReport[Strings.incidentSignature]);
    //         setState(() {
    //           incidentImageBytes = decryptedSignature;
    //         });
    //       }
    //     } else {
    //       incidentSignature = null;
    //       incidentImageBytes = null;
    //     }
    //     if (transferReport[Strings.incidentSignaturePoints] != null) {
    //       if (mounted) {
    //         String decryptedPoints = GlobalFunctions.decryptString(transferReport[Strings.incidentSignaturePoints]);
    //         setState(() {
    //           List<dynamic> fetchedSignaturePoints = jsonDecode(decryptedPoints);
    //           fetchedSignaturePoints.forEach((dynamic pointMap) {
    //             if (pointMap['pointType'] == 'tap') {
    //               incidentSignaturePoints.add(Point(
    //                   Offset(pointMap['dx'], pointMap['dy']),
    //                   PointType.tap));
    //             } else if (pointMap['pointType'] == 'move') {
    //               incidentSignaturePoints.add(Point(
    //                   Offset(pointMap['dx'], pointMap['dy']),
    //                   PointType.move));
    //             }
    //           });
    //         });
    //       }
    //     } else {
    //       incidentSignaturePoints = [];
    //
    //     }
    //
    //     if (transferReport[Strings.incidentDate] != null) {
    //       incidentDate.text =
    //           dateFormat.format(DateTime.parse(transferReport[Strings.incidentDate]));
    //     } else {
    //       incidentDate.text = '';
    //     }
    //     GlobalFunctions.getTemporaryValueTime(transferReport, incidentTime, Strings.incidentTime);
    //     GlobalFunctions.getTemporaryValue(transferReport, incidentDetails, Strings.incidentDetails);
    //     GlobalFunctions.getTemporaryValue(transferReport, incidentLocation, Strings.incidentLocation);
    //     GlobalFunctions.getTemporaryValue(transferReport, incidentAction, Strings.incidentAction);
    //     GlobalFunctions.getTemporaryValue(transferReport, incidentStaffInvolved, Strings.incidentStaffInvolved);
    //     GlobalFunctions.getTemporaryValue(transferReport, incidentPrintName, Strings.incidentPrintName);
    //     GlobalFunctions.getTemporaryValueDate(transferReport, incidentSignatureDate, Strings.incidentSignatureDate);
    //
    //     if (transferReport[Strings.patientReportSignature] != null) {
    //       if (mounted) {
    //         Uint8List decryptedSignature = await GlobalFunctions.decryptSignature(transferReport[Strings.patientReportSignature]);
    //         setState(() {
    //           patientReportImageBytes = decryptedSignature;
    //         });
    //       }
    //     } else {
    //       patientReportSignature = null;
    //       patientReportImageBytes = null;
    //     }
    //     if (transferReport[Strings.patientReportSignaturePoints] != null) {
    //       if (mounted) {
    //         String decryptedPoints = GlobalFunctions.decryptString(transferReport[Strings.patientReportSignaturePoints]);
    //         setState(() {
    //           List<dynamic> fetchedSignaturePoints = jsonDecode(decryptedPoints);
    //           fetchedSignaturePoints.forEach((dynamic pointMap) {
    //             if (pointMap['pointType'] == 'tap') {
    //               patientReportSignaturePoints.add(Point(
    //                   Offset(pointMap['dx'], pointMap['dy']),
    //                   PointType.tap));
    //             } else if (pointMap['pointType'] == 'move') {
    //               patientReportSignaturePoints.add(Point(
    //                   Offset(pointMap['dx'], pointMap['dy']),
    //                   PointType.move));
    //             }
    //           });
    //         });
    //       }
    //     } else {
    //       patientReportSignaturePoints = [];
    //
    //     }
    //
    //     if (transferReport[Strings.bodyMapPoints] != null) {
    //       if (mounted) {
    //         String decryptedPoints = GlobalFunctions.decryptString(transferReport[Strings.bodyMapPoints]);
    //         setState(() {
    //           List<dynamic> fetchedSignaturePoints = jsonDecode(decryptedPoints);
    //           fetchedSignaturePoints.forEach((dynamic pointMap) {
    //             if (pointMap['pointType'] == 'tap') {
    //               bodyMapPoints.add(Point(
    //                   Offset(pointMap['dx'], pointMap['dy']),
    //                   PointType.tap));
    //             } else if (pointMap['pointType'] == 'move') {
    //               bodyMapPoints.add(Point(
    //                   Offset(pointMap['dx'], pointMap['dy']),
    //                   PointType.move));
    //             }
    //           });
    //         });
    //       }
    //     } else {
    //       bodyMapPoints = [];
    //
    //     }
    //
    //     GlobalFunctions.getTemporaryValue(transferReport, patientName, Strings.patientName);
    //     GlobalFunctions.getTemporaryValueDate(transferReport, dateOfBirth, Strings.dateOfBirth, true);
    //     GlobalFunctions.getTemporaryValue(transferReport, ethnicity, Strings.ethnicity);
    //     GlobalFunctions.getTemporaryValue(transferReport, gender, Strings.gender);
    //     GlobalFunctions.getTemporaryValue(transferReport, mhaMcaDetails, Strings.mhaMcaDetails);
    //     GlobalFunctions.getTemporaryValue(transferReport, diagnosis, Strings.diagnosis);
    //     GlobalFunctions.getTemporaryValue(transferReport, currentPresentation, Strings.currentPresentation);
    //     if (transferReport[Strings.riskYes] != null) {
    //       if (mounted) {
    //         setState(() {
    //           riskYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.riskYes]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.riskNo] != null) {
    //       if (mounted) {
    //         setState(() {
    //           riskNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.riskNo]);
    //         });
    //       }
    //     }
    //     GlobalFunctions.getTemporaryValue(transferReport, riskExplanation, Strings.riskExplanation);
    //     if (transferReport[Strings.forensicHistoryYes] != null) {
    //       if (mounted) {
    //         setState(() {
    //           forensicHistoryYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.forensicHistoryYes]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.forensicHistoryNo] != null) {
    //       if (mounted) {
    //         setState(() {
    //           forensicHistoryNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.forensicHistoryNo]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.racialGenderConcernsYes] != null) {
    //       if (mounted) {
    //         setState(() {
    //           racialGenderConcernsYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.racialGenderConcernsYes]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.racialGenderConcernsNo] != null) {
    //       if (mounted) {
    //         setState(() {
    //           racialGenderConcernsNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.racialGenderConcernsNo]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.violenceAggressionYes] != null) {
    //       if (mounted) {
    //         setState(() {
    //           violenceAggressionYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.violenceAggressionYes]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.violenceAggressionNo] != null) {
    //       if (mounted) {
    //         setState(() {
    //           violenceAggressionNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.violenceAggressionNo]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.selfHarmYes] != null) {
    //       if (mounted) {
    //         setState(() {
    //           selfHarmYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.selfHarmYes]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.selfHarmNo] != null) {
    //       if (mounted) {
    //         setState(() {
    //           selfHarmNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.selfHarmNo]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.alcoholSubstanceYes] != null) {
    //       if (mounted) {
    //         setState(() {
    //           alcoholSubstanceYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.alcoholSubstanceYes]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.alcoholSubstanceNo] != null) {
    //       if (mounted) {
    //         setState(() {
    //           alcoholSubstanceNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.alcoholSubstanceNo]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.virusesYes] != null) {
    //       if (mounted) {
    //         setState(() {
    //           virusesYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.virusesYes]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.virusesNo] != null) {
    //       if (mounted) {
    //         setState(() {
    //           virusesNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.virusesNo]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.safeguardingYes] != null) {
    //       if (mounted) {
    //         setState(() {
    //           safeguardingYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.safeguardingYes]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.safeguardingNo] != null) {
    //       if (mounted) {
    //         setState(() {
    //           safeguardingNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.safeguardingNo]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.physicalHealthConditionsYes] != null) {
    //       if (mounted) {
    //         setState(() {
    //           physicalHealthConditionsYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.physicalHealthConditionsYes]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.physicalHealthConditionsNo] != null) {
    //       if (mounted) {
    //         setState(() {
    //           physicalHealthConditionsNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.physicalHealthConditionsNo]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.useOfWeaponYes] != null) {
    //       if (mounted) {
    //         setState(() {
    //           useOfWeaponYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.useOfWeaponYes]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.useOfWeaponNo] != null) {
    //       if (mounted) {
    //         setState(() {
    //           useOfWeaponNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.useOfWeaponNo]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.absconsionRiskYes] != null) {
    //       if (mounted) {
    //         setState(() {
    //           absconsionRiskYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.absconsionRiskYes]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.absconsionRiskNo] != null) {
    //       if (mounted) {
    //         setState(() {
    //           absconsionRiskNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.absconsionRiskNo]);
    //         });
    //       }
    //     }
    //     GlobalFunctions.getTemporaryValue(transferReport, forensicHistory, Strings.forensicHistory);
    //     GlobalFunctions.getTemporaryValue(transferReport, racialGenderConcerns, Strings.racialGenderConcerns);
    //     GlobalFunctions.getTemporaryValue(transferReport, violenceAggression, Strings.violenceAggression);
    //     GlobalFunctions.getTemporaryValue(transferReport, selfHarm, Strings.selfHarm);
    //     GlobalFunctions.getTemporaryValue(transferReport, alcoholSubstance, Strings.alcoholSubstance);
    //     GlobalFunctions.getTemporaryValue(transferReport, viruses, Strings.viruses);
    //     GlobalFunctions.getTemporaryValue(transferReport, safeguarding, Strings.safeguarding);
    //     GlobalFunctions.getTemporaryValue(transferReport, physicalHealthConditions, Strings.physicalHealthConditions);
    //     GlobalFunctions.getTemporaryValue(transferReport, useOfWeapon, Strings.useOfWeapon);
    //     GlobalFunctions.getTemporaryValue(transferReport, absconsionRisk, Strings.absconsionRisk);
    //     if (transferReport[Strings.patientPropertyYes] != null) {
    //       if (mounted) {
    //         setState(() {
    //           patientPropertyYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.patientPropertyYes]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.patientPropertyNo] != null) {
    //       if (mounted) {
    //         setState(() {
    //           patientPropertyNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.patientPropertyNo]);
    //         });
    //       }
    //     }
    //     GlobalFunctions.getTemporaryValue(transferReport, patientPropertyExplanation, Strings.patientPropertyExplanation);
    //     if (transferReport[Strings.patientPropertyReceivedYes] != null) {
    //       if (mounted) {
    //         setState(() {
    //           patientPropertyReceivedYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.patientPropertyReceivedYes]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.patientPropertyReceivedNo] != null) {
    //       if (mounted) {
    //         setState(() {
    //           patientPropertyReceivedNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.patientPropertyReceivedNo]);
    //         });
    //       }
    //     }
    //     GlobalFunctions.getTemporaryValue(transferReport, patientPropertyReceived, Strings.patientPropertyReceived);
    //     GlobalFunctions.getTemporaryValue(transferReport, patientNotesReceived, Strings.patientNotesReceived);
    //     if (transferReport[Strings.patientSearchedYes] != null) {
    //       if (mounted) {
    //         setState(() {
    //           patientSearchedYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.patientSearchedYes]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.patientSearchedNo] != null) {
    //       if (mounted) {
    //         setState(() {
    //           patientSearchedNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.patientSearchedNo]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.itemsRemovedYes] != null) {
    //       if (mounted) {
    //         setState(() {
    //           itemsRemovedYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.itemsRemovedYes]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.itemsRemovedNo] != null) {
    //       if (mounted) {
    //         setState(() {
    //           itemsRemovedNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.itemsRemovedNo]);
    //         });
    //       }
    //     }
    //     GlobalFunctions.getTemporaryValue(transferReport, itemsRemoved, Strings.itemsRemoved);
    //     GlobalFunctions.getTemporaryValue(transferReport, patientInformed, Strings.patientInformed);
    //     GlobalFunctions.getTemporaryValue(transferReport, injuriesNoted, Strings.injuriesNoted);
    //     if (transferReport[Strings.medicalAttentionYes] != null) {
    //       if (mounted) {
    //         setState(() {
    //           medicalAttentionYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.medicalAttentionYes]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.medicalAttentionNo] != null) {
    //       if (mounted) {
    //         setState(() {
    //           medicalAttentionNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.medicalAttentionNo]);
    //         });
    //       }
    //     }
    //     GlobalFunctions.getTemporaryValue(transferReport, medicalAttention, Strings.medicalAttention);
    //     GlobalFunctions.getTemporaryValue(transferReport, currentMedication, Strings.currentMedication);
    //     GlobalFunctions.getTemporaryValue(transferReport, physicalObservations, Strings.physicalObservations);
    //     if (transferReport[Strings.relevantInformationYes] != null) {
    //       if (mounted) {
    //         setState(() {
    //           relevantInformationYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.relevantInformationYes]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.relevantInformationNo] != null) {
    //       if (mounted) {
    //         setState(() {
    //           relevantInformationNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.relevantInformationNo]);
    //         });
    //       }
    //     }
    //     GlobalFunctions.getTemporaryValue(transferReport, relevantInformation, Strings.relevantInformation);
    //     GlobalFunctions.getTemporaryValue(transferReport, patientReport, Strings.patientReport);
    //     if(transferReport[Strings.patientReportPrintName] == null){
    //       patientReportPrintName.text = user.name;
    //       _databaseHelper.updateTemporaryTransferReportField(widget.edit, {
    //         Strings.patientReportPrintName: GlobalFunctions.encryptString(patientReportPrintName.text)
    //       }, user.uid, widget.jobId, widget.saved, widget.savedId);
    //     } else {
    //       GlobalFunctions.getTemporaryValue(transferReport, patientReportPrintName, Strings.patientReportPrintName);
    //     }
    //     GlobalFunctions.getTemporaryValue(transferReport, patientReportRole, Strings.patientReportRole);
    //     GlobalFunctions.getTemporaryValueDate(transferReport, patientReportDate, Strings.patientReportDate);
    //     GlobalFunctions.getTemporaryValueTime(transferReport, patientReportTime, Strings.patientReportTime);
    //     if (transferReport[Strings.handcuffsUsedNo] != null) {
    //       if (mounted) {
    //         setState(() {
    //           handcuffsUsedNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.handcuffsUsedNo]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.handcuffsUsedYes] != null) {
    //       if (mounted) {
    //         setState(() {
    //           handcuffsUsedYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.handcuffsUsedYes]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.physicalInterventionNo] != null) {
    //       if (mounted) {
    //         setState(() {
    //           physicalInterventionNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.physicalInterventionNo]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.physicalInterventionYes] != null) {
    //       if (mounted) {
    //         setState(() {
    //           physicalInterventionYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.physicalInterventionYes]);
    //         });
    //       }
    //     }
    //     GlobalFunctions.getTemporaryValueDate(transferReport, handcuffsDate, Strings.handcuffsDate);
    //     GlobalFunctions.getTemporaryValueTime(transferReport, handcuffsTime, Strings.handcuffsTime);
    //     GlobalFunctions.getTemporaryValue(transferReport, handcuffsAuthorisedBy, Strings.handcuffsAuthorisedBy);
    //     GlobalFunctions.getTemporaryValue(transferReport, handcuffsAppliedBy, Strings.handcuffsAppliedBy);
    //     GlobalFunctions.getTemporaryValueTime(transferReport, handcuffsRemovedTime, Strings.handcuffsRemovedTime);
    //     if (transferReport[Strings.physicalIntervention] != null) {
    //       physicalIntervention = GlobalFunctions.decryptString(transferReport[Strings.physicalIntervention]);
    //     }
    //     GlobalFunctions.getTemporaryValue(transferReport, whyInterventionRequired, Strings.whyInterventionRequired);
    //
    //
    //     if (transferReport[Strings.techniqueName1] != null) {
    //       setState(() {
    //         roleCount += 1;
    //       });
    //     }
    //     if (transferReport[Strings.techniqueName2] != null) {
    //       setState(() {
    //         roleCount += 1;
    //       });
    //     }
    //     if (transferReport[Strings.techniqueName3] != null) {
    //       setState(() {
    //         roleCount += 1;
    //       });
    //     }
    //     if (transferReport[Strings.techniqueName4] != null) {
    //       setState(() {
    //         roleCount += 1;
    //       });
    //     }
    //     if (transferReport[Strings.techniqueName4] != null) {
    //       setState(() {
    //         roleCount += 1;
    //       });
    //     }
    //     if (transferReport[Strings.techniqueName5] != null) {
    //       setState(() {
    //         roleCount += 1;
    //       });
    //     }
    //     if (transferReport[Strings.techniqueName6] != null) {
    //       setState(() {
    //         roleCount += 1;
    //       });
    //     }
    //     if (transferReport[Strings.techniqueName6] != null) {
    //       setState(() {
    //         roleCount += 1;
    //       });
    //     }
    //     if (transferReport[Strings.techniqueName7] != null) {
    //       setState(() {
    //         roleCount += 1;
    //       });
    //     }
    //     if (transferReport[Strings.techniqueName8] != null) {
    //       setState(() {
    //         roleCount += 1;
    //       });
    //     }
    //     if (transferReport[Strings.techniqueName9] != null) {
    //       setState(() {
    //         roleCount += 1;
    //       });
    //     }
    //     if (transferReport[Strings.techniqueName10] != null) {
    //       setState(() {
    //         roleCount += 1;
    //       });
    //     }
    //     setState(() {
    //       rowCount = roleCount;
    //     });
    //     GlobalFunctions.getTemporaryValue(transferReport, techniqueName1, Strings.techniqueName1);
    //     GlobalFunctions.getTemporaryValue(transferReport, techniqueName2, Strings.techniqueName2);
    //     GlobalFunctions.getTemporaryValue(transferReport, techniqueName3, Strings.techniqueName3);
    //     GlobalFunctions.getTemporaryValue(transferReport, techniqueName4, Strings.techniqueName4);
    //     GlobalFunctions.getTemporaryValue(transferReport, techniqueName5, Strings.techniqueName5);
    //     GlobalFunctions.getTemporaryValue(transferReport, techniqueName6, Strings.techniqueName6);
    //     GlobalFunctions.getTemporaryValue(transferReport, techniqueName7, Strings.techniqueName7);
    //     GlobalFunctions.getTemporaryValue(transferReport, techniqueName8, Strings.techniqueName8);
    //     GlobalFunctions.getTemporaryValue(transferReport, techniqueName9, Strings.techniqueName9);
    //     GlobalFunctions.getTemporaryValue(transferReport, techniqueName10, Strings.techniqueName10);
    //     GlobalFunctions.getTemporaryValue(transferReport, technique1, Strings.technique1);
    //     GlobalFunctions.getTemporaryValue(transferReport, technique2, Strings.technique2);
    //     GlobalFunctions.getTemporaryValue(transferReport, technique3, Strings.technique3);
    //     GlobalFunctions.getTemporaryValue(transferReport, technique4, Strings.technique4);
    //     GlobalFunctions.getTemporaryValue(transferReport, technique5, Strings.technique5);
    //     GlobalFunctions.getTemporaryValue(transferReport, technique6, Strings.technique6);
    //     GlobalFunctions.getTemporaryValue(transferReport, technique7, Strings.technique7);
    //     GlobalFunctions.getTemporaryValue(transferReport, technique8, Strings.technique8);
    //     GlobalFunctions.getTemporaryValue(transferReport, technique9, Strings.technique9);
    //     GlobalFunctions.getTemporaryValue(transferReport, technique10, Strings.technique10);
    //     GlobalFunctions.getTemporaryValue(transferReport, techniquePosition1, Strings.techniquePosition1);
    //     GlobalFunctions.getTemporaryValue(transferReport, techniquePosition2, Strings.techniquePosition2);
    //     GlobalFunctions.getTemporaryValue(transferReport, techniquePosition3, Strings.techniquePosition3);
    //     GlobalFunctions.getTemporaryValue(transferReport, techniquePosition4, Strings.techniquePosition4);
    //     GlobalFunctions.getTemporaryValue(transferReport, techniquePosition5, Strings.techniquePosition5);
    //     GlobalFunctions.getTemporaryValue(transferReport, techniquePosition6, Strings.techniquePosition6);
    //     GlobalFunctions.getTemporaryValue(transferReport, techniquePosition7, Strings.techniquePosition7);
    //     GlobalFunctions.getTemporaryValue(transferReport, techniquePosition8, Strings.techniquePosition8);
    //     GlobalFunctions.getTemporaryValue(transferReport, techniquePosition9, Strings.techniquePosition9);
    //     GlobalFunctions.getTemporaryValue(transferReport, techniquePosition10, Strings.techniquePosition10);
    //     GlobalFunctions.getTemporaryValueTime(transferReport, timeInterventionCommenced, Strings.timeInterventionCommenced);
    //     GlobalFunctions.getTemporaryValueTime(transferReport, timeInterventionCompleted, Strings.timeInterventionCompleted);
    //
    //
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
    if(rowCount == 10){
      GlobalFunctions.showToast('Maximum staff added');
    } else {
      setState(() {
        rowCount +=1;
      });
    }
  }

  Widget _buildIncidentSignatureRow() {
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
          color: incidentImageBytes == null ? Color(0xFF0000).withOpacity(0.3) : null,
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
                        incidentSignature = Signature(
                          points: incidentSignaturePoints,
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
                                child: incidentSignature,
                              )
                            ],
                          ),
                          actions: <Widget>[
                            TextButton(
                                onPressed: () {
                                  incidentSignature
                                      .clear();

                                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.incidentSignaturePoints, null, widget.jobId, widget.saved, widget.savedId);
                                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.incidentSignature, null, widget.jobId, widget.saved, widget.savedId);


                                  // _databaseHelper
                                  //     .updateTemporaryTransferReportField(widget.edit,
                                  //     {Strings.incidentSignaturePoints: null},
                                  //     user.uid,
                                  //     widget.jobId, widget.saved, widget.savedId);
                                  // _databaseHelper
                                  //     .updateTemporaryTransferReportField(widget.edit,
                                  //     {Strings.incidentSignature: null}, user.uid,
                                  //     widget.jobId, widget.saved, widget.savedId);
                                  setState(() {
                                    incidentSignaturePoints = [];
                                    incidentImageBytes =
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

                                  incidentSignaturePoints =
                                      incidentSignature
                                          .exportPoints();

                                  if (incidentSignaturePoints.length > 0) {
                                    incidentSignaturePoints.forEach((
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

                                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.incidentSignaturePoints, encryptedPoints, widget.jobId, widget.saved, widget.savedId);


                                    // _databaseHelper
                                    //     .updateTemporaryTransferReportField(widget.edit,
                                    //     {
                                    //       Strings.incidentSignaturePoints:
                                    //       encryptedPoints
                                    //     },
                                    //     user.uid,
                                    //     widget.jobId, widget.saved, widget.savedId);

                                    Uint8List signatureBytes = await incidentSignature
                                        .exportBytes();

                                    setState(() {
                                      incidentImageBytes =
                                          signatureBytes;
                                    });

                                    Uint8List encryptedSignature = await GlobalFunctions
                                        .encryptSignature(incidentImageBytes);

                                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.incidentSignature, encryptedSignature, widget.jobId, widget.saved, widget.savedId);


                                    // _databaseHelper
                                    //     .updateTemporaryTransferReportField(widget.edit, {
                                    //   Strings.incidentSignature: encryptedSignature
                                    // }, user.uid,
                                    //     widget.jobId, widget.saved, widget.savedId);

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
              child: incidentImageBytes == null
                  ? Icon(
                Icons.border_color,
                color: bluePurple,
                size: 40.0,
              )
                  : Image.memory(incidentImageBytes),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildPatientReportSignatureRow() {
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
          color: patientReportImageBytes == null ? Color(0xFF0000).withOpacity(0.3) : null,
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
                        patientReportSignature = Signature(
                          points: patientReportSignaturePoints,
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
                            child: Center(child: Text("Signed", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),),
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
                                child: patientReportSignature,
                              )
                            ],
                          ),
                          actions: <Widget>[
                            TextButton(
                                onPressed: () {
                                  patientReportSignature
                                      .clear();

                                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.patientReportSignaturePoints, null, widget.jobId, widget.saved, widget.savedId);
                                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.patientReportSignature, null, widget.jobId, widget.saved, widget.savedId);
                                  // _databaseHelper
                                  //     .updateTemporaryTransferReportField(widget.edit,
                                  //     {Strings.patientReportSignaturePoints: null},
                                  //     user.uid,
                                  //     widget.jobId, widget.saved, widget.savedId);
                                  // _databaseHelper
                                  //     .updateTemporaryTransferReportField(widget.edit,
                                  //     {Strings.patientReportSignature: null}, user.uid,
                                  //     widget.jobId, widget.saved, widget.savedId);
                                  setState(() {
                                    patientReportSignaturePoints = [];
                                    patientReportImageBytes =
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

                                  patientReportSignaturePoints =
                                      patientReportSignature
                                          .exportPoints();

                                  if (patientReportSignaturePoints.length > 0) {
                                    patientReportSignaturePoints.forEach((
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

                                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.patientReportSignaturePoints, encryptedPoints, widget.jobId, widget.saved, widget.savedId);

                                    Uint8List signatureBytes = await patientReportSignature
                                        .exportBytes();

                                    setState(() {
                                      patientReportImageBytes =
                                          signatureBytes;
                                    });

                                    Uint8List encryptedSignature = await GlobalFunctions
                                        .encryptSignature(patientReportImageBytes);

                                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.patientReportSignature, encryptedSignature, widget.jobId, widget.saved, widget.savedId);

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
              child: patientReportImageBytes == null
                  ? Icon(
                Icons.border_color,
                color: bluePurple,
                size: 40.0,
              )
                  : Image.memory(patientReportImageBytes),
            ),
          ),
        )
      ],
    );
  }
  Widget _textFormField(String label, TextEditingController controller, [int lines = 1, bool required = false, TextInputType textInputType = TextInputType.text, bool patientReport = false]) {
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
                  text: required && patientReport == false ? ' *' : '',
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

  // Widget _buildGenderDrop() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text('Gender', style: TextStyle(
  //           fontSize: 16.0, color: bluePurple),),
  //       DropdownFormField(
  //         expanded: true,
  //         value: gender,
  //         items: genderDrop.toList(),
  //         onChanged: (val) => setState(() {
  //           gender = val;
  //           if(val == 'Select One'){
  //             _databaseHelper.updateTemporaryTransferReportField(widget.edit,
  //                 {Strings.gender : null}, user.uid, widget.jobId, widget.saved, widget.savedId);
  //           } else {
  //             _databaseHelper.updateTemporaryTransferReportField(widget.edit,
  //                 {Strings.gender : GlobalFunctions.encryptString(val)}, user.uid, widget.jobId, widget.saved, widget.savedId);
  //           }
  //
  //           FocusScope.of(context).unfocus();
  //         }),
  //         initialValue: gender,
  //       ),
  //       SizedBox(height: 15,),
  //     ],
  //   );
  // }

  Widget _buildPhysicalInterventionDrop() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownFormField(
          expanded: true,
          value: physicalIntervention,
          items: physicalInterventionDrop.toList(),
          onChanged: (val) => setState(() {
            physicalIntervention = val;
            if(val == 'Select One'){
              transferReportModel.updateTemporaryRecord(widget.edit, Strings.physicalIntervention, null, widget.jobId, widget.saved, widget.savedId);
            } else {
              transferReportModel.updateTemporaryRecord(widget.edit, Strings.physicalIntervention, GlobalFunctions.encryptString(val), widget.jobId, widget.saved, widget.savedId);
            }

            FocusScope.of(context).unfocus();
          }),
          initialValue: physicalIntervention,
        ),
        SizedBox(height: 15,),
      ],
    );
  }


  Widget _buildPatientSearchedCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: 'Patient Been Searched/Wanded',
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
          color: patientSearchedYes == false && patientSearchedNo == false ? Color(0xFF0000).withOpacity(0.3) : null,
          child: Row(
            children: <Widget>[
              Text(
                'Yes',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: patientSearchedYes,
                  onChanged: (bool value) => setState(() {
                    patientSearchedYes = value;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.patientSearchedYes, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                    if (patientSearchedNo == true){
                      patientSearchedNo = false;
                      transferReportModel.updateTemporaryRecord(widget.edit, Strings.patientSearchedNo, null, widget.jobId, widget.saved, widget.savedId);
                    }
                  })),
              Text(
                'No',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: patientSearchedNo,
                  onChanged: (bool value) => setState(() {
                    patientSearchedNo = value;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.patientSearchedNo, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                    if (patientSearchedYes == true){
                      patientSearchedYes = false;
                      transferReportModel.updateTemporaryRecord(widget.edit, Strings.patientSearchedYes, null, widget.jobId, widget.saved, widget.savedId);
                    }
                  }))
            ],
          ),
        )
      ],
    );

  }

  Widget _buildItemsRemovedCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: 'Any Items Removed',
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
          color: itemsRemovedYes == false && itemsRemovedNo == false ? Color(0xFF0000).withOpacity(0.3) : null,
          child: Row(
            children: <Widget>[
              Text(
                'Yes',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: itemsRemovedYes,
                  onChanged: (bool value) => setState(() {
                    itemsRemovedYes = value;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.itemsRemovedYes, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                    if (itemsRemovedNo == true){
                      itemsRemovedNo = false;
                      transferReportModel.updateTemporaryRecord(widget.edit, Strings.itemsRemovedNo, null, widget.jobId, widget.saved, widget.savedId);
                    }
                  })),
              Text(
                'No',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: itemsRemovedNo,
                  onChanged: (bool value) => setState(() {
                    itemsRemovedNo = value;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.itemsRemovedNo, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                    if (itemsRemovedYes == true){
                      itemsRemovedYes = false;
                      transferReportModel.updateTemporaryRecord(widget.edit, Strings.itemsRemovedYes, null, widget.jobId, widget.saved, widget.savedId);
                    }
                  }))
            ],
          ),
        )
      ],
    );

  }

  Widget _buildForensicHistoryCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: 'Forensic History',
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
          color: forensicHistoryYes == false && forensicHistoryNo == false ? Color(0xFF0000).withOpacity(0.3) : null,
          child: Row(
            children: <Widget>[
              Text(
                'Yes',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: forensicHistoryYes,
                  onChanged: (bool value) => setState(() {
                    forensicHistoryYes = value;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.forensicHistoryYes, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                    if (forensicHistoryNo == true){
                      forensicHistoryNo = false;
                      transferReportModel.updateTemporaryRecord(widget.edit, Strings.forensicHistoryNo, null, widget.jobId, widget.saved, widget.savedId);
                    }
                  })),
              Text(
                'No',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: forensicHistoryNo,
                  onChanged: (bool value) => setState(() {
                    forensicHistoryNo = value;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.forensicHistoryNo, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                    if (forensicHistoryYes == true){
                      forensicHistoryYes = false;
                      transferReportModel.updateTemporaryRecord(widget.edit, Strings.forensicHistoryYes, null, widget.jobId, widget.saved, widget.savedId);
                    }
                  }))
            ],
          ),
        )
      ],
    );

  }

  Widget _buildRacialGenderConcernsCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: 'Any Racial or Gender Concerns',
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
          color: racialGenderConcernsYes == false && racialGenderConcernsNo == false ? Color(0xFF0000).withOpacity(0.3) : null,
          child: Row(
            children: <Widget>[
              Text(
                'Yes',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: racialGenderConcernsYes,
                  onChanged: (bool value) => setState(() {
                    racialGenderConcernsYes = value;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.racialGenderConcernsYes, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                    if (racialGenderConcernsNo == true){
                      racialGenderConcernsNo = false;
                      transferReportModel.updateTemporaryRecord(widget.edit, Strings.racialGenderConcernsNo, null, widget.jobId, widget.saved, widget.savedId);
                    }
                  })),
              Text(
                'No',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: racialGenderConcernsNo,
                  onChanged: (bool value) => setState(() {
                    racialGenderConcernsNo = value;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.racialGenderConcernsNo, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                    if (racialGenderConcernsYes == true){
                      racialGenderConcernsYes = false;
                      transferReportModel.updateTemporaryRecord(widget.edit, Strings.racialGenderConcernsYes, null, widget.jobId, widget.saved, widget.savedId);
                    }
                  }))
            ],
          ),
        )
      ],
    );

  }

  Widget _buildViolenceAggressionCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: 'Violence or Aggression (Actual or Potential)',
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
          color: violenceAggressionYes == false && violenceAggressionNo == false ? Color(0xFF0000).withOpacity(0.3) : null,
          child: Row(
            children: <Widget>[
              Text(
                'Yes',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: violenceAggressionYes,
                  onChanged: (bool value) => setState(() {
                    violenceAggressionYes = value;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.violenceAggressionYes, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                    if (violenceAggressionNo == true){
                      violenceAggressionNo = false;
                      transferReportModel.updateTemporaryRecord(widget.edit, Strings.violenceAggressionNo, null, widget.jobId, widget.saved, widget.savedId);
                    }
                  })),
              Text(
                'No',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: violenceAggressionNo,
                  onChanged: (bool value) => setState(() {
                    violenceAggressionNo = value;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.violenceAggressionNo, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                    if (violenceAggressionYes == true){
                      violenceAggressionYes = false;
                      transferReportModel.updateTemporaryRecord(widget.edit, Strings.violenceAggressionYes, null, widget.jobId, widget.saved, widget.savedId);
                    }
                  }))
            ],
          ),
        )
      ],
    );

  }

  Widget _buildSelfHarmCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: 'Self Harm/Attempted Suicide',
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
          color: selfHarmYes == false && selfHarmNo == false ? Color(0xFF0000).withOpacity(0.3) : null,
          child: Row(
            children: <Widget>[
              Text(
                'Yes',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: selfHarmYes,
                  onChanged: (bool value) => setState(() {
                    selfHarmYes = value;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.selfHarmYes, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                    if (selfHarmNo == true){
                      selfHarmNo = false;
                      transferReportModel.updateTemporaryRecord(widget.edit, Strings.selfHarmNo, null, widget.jobId, widget.saved, widget.savedId);
                    }
                  })),
              Text(
                'No',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: selfHarmNo,
                  onChanged: (bool value) => setState(() {
                    selfHarmNo = value;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.selfHarmNo, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                    if (selfHarmYes == true){
                      selfHarmYes = false;
                      transferReportModel.updateTemporaryRecord(widget.edit, Strings.selfHarmYes, null, widget.jobId, widget.saved, widget.savedId);
                    }
                  }))
            ],
          ),
        )
      ],
    );

  }

  Widget _buildAlcoholSubstanceCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: 'Alcohol / Substance Abuse',
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
          color: alcoholSubstanceYes == false && alcoholSubstanceNo == false ? Color(0xFF0000).withOpacity(0.3) : null,
          child: Row(
            children: <Widget>[
              Text(
                'Yes',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: alcoholSubstanceYes,
                  onChanged: (bool value) => setState(() {
                    alcoholSubstanceYes = value;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.alcoholSubstanceYes, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                    if (alcoholSubstanceNo == true){
                      alcoholSubstanceNo = false;
                      transferReportModel.updateTemporaryRecord(widget.edit, Strings.alcoholSubstanceNo, null, widget.jobId, widget.saved, widget.savedId);
                    }
                  })),
              Text(
                'No',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: alcoholSubstanceNo,
                  onChanged: (bool value) => setState(() {
                    alcoholSubstanceNo = value;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.alcoholSubstanceNo, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                    if (alcoholSubstanceYes == true){
                      alcoholSubstanceYes = false;
                      transferReportModel.updateTemporaryRecord(widget.edit, Strings.alcoholSubstanceYes, null, widget.jobId, widget.saved, widget.savedId);
                    }
                  }))
            ],
          ),
        )
      ],
    );

  }

  Widget _buildVirusesCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: 'Any known Blood Borne Viruses',
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
          color: virusesYes == false && virusesNo == false ? Color(0xFF0000).withOpacity(0.3) : null,
          child: Row(
            children: <Widget>[
              Text(
                'Yes',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: virusesYes,
                  onChanged: (bool value) => setState(() {
                    virusesYes = value;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.virusesYes, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                    if (virusesNo == true){
                      virusesNo = false;
                      transferReportModel.updateTemporaryRecord(widget.edit, Strings.virusesNo, null, widget.jobId, widget.saved, widget.savedId);
                    }
                  })),
              Text(
                'No',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: virusesNo,
                  onChanged: (bool value) => setState(() {
                    virusesNo = value;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.virusesNo, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                    if (virusesYes == true){
                      virusesYes = false;
                      transferReportModel.updateTemporaryRecord(widget.edit, Strings.virusesYes, null, widget.jobId, widget.saved, widget.savedId);
                    }
                  }))
            ],
          ),
        )
      ],
    );

  }

  Widget _buildSafeguardingCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: 'Safeguarding Concerns',
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
          color: safeguardingYes == false && safeguardingNo == false ? Color(0xFF0000).withOpacity(0.3) : null,
          child: Row(
            children: <Widget>[
              Text(
                'Yes',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: safeguardingYes,
                  onChanged: (bool value) => setState(() {
                    safeguardingYes = value;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.safeguardingYes, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                    if (safeguardingNo == true){
                      safeguardingNo = false;
                      transferReportModel.updateTemporaryRecord(widget.edit, Strings.safeguardingNo, null, widget.jobId, widget.saved, widget.savedId);
                    }
                  })),
              Text(
                'No',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: safeguardingNo,
                  onChanged: (bool value) => setState(() {
                    safeguardingNo = value;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.safeguardingNo, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                    if (safeguardingYes == true){
                      safeguardingYes = false;
                      transferReportModel.updateTemporaryRecord(widget.edit, Strings.safeguardingYes, null, widget.jobId, widget.saved, widget.savedId);
                    }
                  }))
            ],
          ),
        )
      ],
    );

  }

  Widget _buildPhysicalHealthConditionsCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: 'Physical Health Conditions',
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
          color: physicalHealthConditionsYes == false && physicalHealthConditionsNo == false ? Color(0xFF0000).withOpacity(0.3) : null,
          child: Row(
            children: <Widget>[
              Text(
                'Yes',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: physicalHealthConditionsYes,
                  onChanged: (bool value) => setState(() {
                    physicalHealthConditionsYes = value;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.physicalHealthConditionsYes, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                    if (physicalHealthConditionsNo == true){
                      physicalHealthConditionsNo = false;
                      transferReportModel.updateTemporaryRecord(widget.edit, Strings.physicalHealthConditionsNo, null, widget.jobId, widget.saved, widget.savedId);
                    }
                  })),
              Text(
                'No',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: physicalHealthConditionsNo,
                  onChanged: (bool value) => setState(() {
                    physicalHealthConditionsNo = value;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.physicalHealthConditionsNo, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                    if (physicalHealthConditionsYes == true){
                      physicalHealthConditionsYes = false;
                      transferReportModel.updateTemporaryRecord(widget.edit, Strings.physicalHealthConditionsYes, null, widget.jobId, widget.saved, widget.savedId);
                    }
                  }))
            ],
          ),
        )
      ],
    );

  }

  Widget _buildUseOfWeaponCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: 'Use of Weapon(s)',
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
          color: useOfWeaponYes == false && useOfWeaponNo == false ? Color(0xFF0000).withOpacity(0.3) : null,
          child: Row(
            children: <Widget>[
              Text(
                'Yes',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: useOfWeaponYes,
                  onChanged: (bool value) => setState(() {
                    useOfWeaponYes = value;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.useOfWeaponYes, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                    if (useOfWeaponNo == true){
                      useOfWeaponNo = false;
                      transferReportModel.updateTemporaryRecord(widget.edit, Strings.useOfWeaponNo, null, widget.jobId, widget.saved, widget.savedId);
                    }
                  })),
              Text(
                'No',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: useOfWeaponNo,
                  onChanged: (bool value) => setState(() {
                    useOfWeaponNo = value;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.useOfWeaponNo, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                    if (useOfWeaponYes == true){
                      useOfWeaponYes = false;
                      transferReportModel.updateTemporaryRecord(widget.edit, Strings.useOfWeaponYes, null, widget.jobId, widget.saved, widget.savedId);
                    }
                  }))
            ],
          ),
        )
      ],
    );

  }

  Widget _buildAbsconsionRiskCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: 'Absconsion Risk',
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
          color: absconsionRiskYes == false && absconsionRiskNo == false ? Color(0xFF0000).withOpacity(0.3) : null,
          child: Row(
            children: <Widget>[
              Text(
                'Yes',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: absconsionRiskYes,
                  onChanged: (bool value) => setState(() {
                    absconsionRiskYes = value;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.absconsionRiskYes, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                    if (absconsionRiskNo == true){
                      absconsionRiskNo = false;
                      transferReportModel.updateTemporaryRecord(widget.edit, Strings.absconsionRiskNo, null, widget.jobId, widget.saved, widget.savedId);
                    }
                  })),
              Text(
                'No',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: absconsionRiskNo,
                  onChanged: (bool value) => setState(() {
                    absconsionRiskNo = value;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.absconsionRiskNo, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                    if (absconsionRiskYes == true){
                      absconsionRiskYes = false;
                      transferReportModel.updateTemporaryRecord(widget.edit, Strings.absconsionRiskYes, null, widget.jobId, widget.saved, widget.savedId);
                    }
                  }))
            ],
          ),
        )
      ],
    );

  }

  Widget _buildMedicalAttentionCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: 'Received medical attention in the last 24 hours',
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
          color: medicalAttentionYes == false && medicalAttentionNo == false ? Color(0xFF0000).withOpacity(0.3) : null,
          child: Row(
            children: <Widget>[
              Text(
                'Yes',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: medicalAttentionYes,
                  onChanged: (bool value) => setState(() {
                    medicalAttentionYes = value;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.medicalAttentionYes, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                    if (medicalAttentionNo == true){
                      medicalAttentionNo = false;
                      transferReportModel.updateTemporaryRecord(widget.edit, Strings.medicalAttentionNo, null, widget.jobId, widget.saved, widget.savedId);
                    }
                  })),
              Text(
                'No',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: medicalAttentionNo,
                  onChanged: (bool value) => setState(() {
                    medicalAttentionNo = value;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.medicalAttentionNo, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                    if (medicalAttentionYes == true){
                      medicalAttentionYes = false;
                      transferReportModel.updateTemporaryRecord(widget.edit, Strings.medicalAttentionYes, null, widget.jobId, widget.saved, widget.savedId);
                    }
                  }))
            ],
          ),
        )
      ],
    );

  }

  Widget _buildRelevantInformationCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: 'Any other Relevant Information (including rapid tranquilisation)',
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
          color: relevantInformationYes == false && relevantInformationNo == false ? Color(0xFF0000).withOpacity(0.3) : null,
          child: Row(
            children: <Widget>[
              Text(
                'Yes',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: relevantInformationYes,
                  onChanged: (bool value) => setState(() {
                    relevantInformationYes = value;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.relevantInformationYes, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                    if (relevantInformationNo == true){
                      relevantInformationNo = false;
                      transferReportModel.updateTemporaryRecord(widget.edit, Strings.relevantInformationNo, null, widget.jobId, widget.saved, widget.savedId);
                    }
                  })),
              Text(
                'No',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: relevantInformationNo,
                  onChanged: (bool value) => setState(() {
                    relevantInformationNo = value;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.relevantInformationNo, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                    if (relevantInformationYes == true){
                      relevantInformationYes = false;
                      transferReportModel.updateTemporaryRecord(widget.edit, Strings.relevantInformationYes, null, widget.jobId, widget.saved, widget.savedId);
                    }
                  }))
            ],
          ),
        )
      ],
    );

  }

  Widget _buildAcceptPpeCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: 'Did patient accept PPE?',
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
          color: acceptPpeYes == false && acceptPpeNo == false ? Color(0xFF0000).withOpacity(0.3) : null,
          child: Row(
            children: <Widget>[
              Text(
                'Yes',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: acceptPpeYes,
                  onChanged: (bool value) => setState(() {
                    acceptPpeYes = value;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.acceptPpeYes, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                    if (acceptPpeNo == true){
                      acceptPpeNo = false;
                      transferReportModel.updateTemporaryRecord(widget.edit, Strings.acceptPpeNo, null, widget.jobId, widget.saved, widget.savedId);
                    }
                  })),
              Text(
                'No',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: acceptPpeNo,
                  onChanged: (bool value) => setState(() {
                    acceptPpeNo = value;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.acceptPpeNo, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                    if (acceptPpeYes == true){
                      acceptPpeYes = false;
                      transferReportModel.updateTemporaryRecord(widget.edit, Strings.acceptPpeYes, null, widget.jobId, widget.saved, widget.savedId);
                    }
                  }))
            ],
          ),
        )
      ],
    );

  }




  Widget _buildHandcuffsUsedRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Handcuffs used', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: handcuffsUsedYes,
                onChanged: (bool value) => setState(() {
                  handcuffsUsedYes = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.handcuffsUsedYes, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (handcuffsUsedNo == true){
                    handcuffsUsedNo = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.handcuffsUsedNo, null, widget.jobId, widget.saved, widget.savedId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: handcuffsUsedNo,
                onChanged: (bool value) => setState(() {
                  handcuffsUsedNo = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.handcuffsUsedNo, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (handcuffsUsedYes == true){
                    handcuffsUsedYes = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.handcuffsUsedYes, null, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        )
      ],
    );

  }

  Widget _buildRiskCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: riskYes,
                onChanged: (bool value) => setState(() {
                  riskYes = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.riskYes, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (riskNo == true){
                    riskNo = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.riskNo, null, widget.jobId, widget.saved, widget.savedId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: riskNo,
                onChanged: (bool value) => setState(() {
                  riskNo = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.riskNo, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (riskYes == true){
                    riskYes = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.riskYes, null, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        )
      ],
    );

  }

  Widget _buildPatientPropertyCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          color: patientPropertyYes == false && patientPropertyNo == false ? Color(0xFF0000).withOpacity(0.3) : null,
          child: Row(
            children: <Widget>[
              Text(
                'Yes',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: patientPropertyYes,
                  onChanged: (bool value) => setState(() {
                    patientPropertyYes = value;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.patientPropertyYes, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                    if (patientPropertyNo == true){
                      patientPropertyNo = false;
                      transferReportModel.updateTemporaryRecord(widget.edit, Strings.patientPropertyNo, null, widget.jobId, widget.saved, widget.savedId);
                    }
                  })),
              Text(
                'No',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: patientPropertyNo,
                  onChanged: (bool value) => setState(() {
                    patientPropertyNo = value;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.patientPropertyNo, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                    if (patientPropertyYes == true){
                      patientPropertyYes = false;
                      transferReportModel.updateTemporaryRecord(widget.edit, Strings.patientPropertyYes, null, widget.jobId, widget.saved, widget.savedId);
                    }
                  })),
              RichText(
                text: TextSpan(
                  text: '*',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 16.0),
                ),
              ),
            ],
          ),
        )
      ],
    );

  }



  Widget _buildPatientPropertyReceivedCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: 'Patient Property Received',
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
          color: patientPropertyReceivedYes == false && patientPropertyReceivedNo == false ? Color(0xFF0000).withOpacity(0.3) : null,
          child: Row(
            children: <Widget>[
              Text(
                'Yes',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: patientPropertyReceivedYes,
                  onChanged: (bool value) => setState(() {
                    patientPropertyReceivedYes = value;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.patientPropertyReceivedYes, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                    if (patientPropertyReceivedNo == true){
                      patientPropertyReceivedNo = false;
                      transferReportModel.updateTemporaryRecord(widget.edit, Strings.patientPropertyReceivedNo, null, widget.jobId, widget.saved, widget.savedId);
                    }
                  })),
              Text(
                'No',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: patientPropertyReceivedNo,
                  onChanged: (bool value) => setState(() {
                    patientPropertyReceivedNo = value;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.patientPropertyReceivedNo, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                    if (patientPropertyReceivedYes == true){
                      patientPropertyReceivedYes = false;
                      transferReportModel.updateTemporaryRecord(widget.edit, Strings.patientPropertyReceivedYes, null, widget.jobId, widget.saved, widget.savedId);
                    }
                  }))
            ],
          ),
        )
      ],
    );

  }

  Widget _buildPatientNotesReceivedCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: 'Patient Notes Received',
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
          color: patientNotesReceivedYes == false && patientNotesReceivedNo == false ? Color(0xFF0000).withOpacity(0.3) : null,
          child: Row(
            children: <Widget>[
              Text(
                'Yes',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: patientNotesReceivedYes,
                  onChanged: (bool value) => setState(() {
                    patientNotesReceivedYes = value;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.patientNotesReceivedYes, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                    if (patientNotesReceivedNo == true){
                      patientNotesReceivedNo = false;
                      transferReportModel.updateTemporaryRecord(widget.edit, Strings.patientNotesReceivedNo, null, widget.jobId, widget.saved, widget.savedId);
                    }
                  })),
              Text(
                'No',
              ),
              Checkbox(
                  activeColor: bluePurple,
                  value: patientNotesReceivedNo,
                  onChanged: (bool value) => setState(() {
                    patientNotesReceivedNo = value;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.patientNotesReceivedNo, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                    if (patientNotesReceivedYes == true){
                      patientNotesReceivedYes = false;
                      transferReportModel.updateTemporaryRecord(widget.edit, Strings.patientNotesReceivedYes, null, widget.jobId, widget.saved, widget.savedId);
                    }
                  }))
            ],
          ),
        )
      ],
    );

  }




  Widget _buildPhysicalInterventionRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Physical Intervention', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: physicalInterventionYes,
                onChanged: (bool value) => setState(() {
                  physicalInterventionYes = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.physicalInterventionYes, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (physicalInterventionNo == true){
                    physicalInterventionNo = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.physicalInterventionNo, null, widget.jobId, widget.saved, widget.savedId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: physicalInterventionNo,
                onChanged: (bool value) => setState(() {
                  physicalInterventionNo = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.physicalInterventionNo, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (physicalInterventionYes == true){
                    physicalInterventionYes = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.physicalInterventionYes, null, widget.jobId, widget.saved, widget.savedId);
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
                SizedBox(height: 20,),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('TRANSFER REPORT', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 18),),
                ],),
                SizedBox(height: 20,),
                _textFormField('Name', patientName, 1, true),
                _buildDateField('Date of Birth', dateOfBirth, Strings.dateOfBirth, true, true),
                _textFormField('Ethnicity', ethnicity, 1, true),
                _textFormField('Gender', gender, 1, true),
                _textFormField('Legal Status', mhaMcaDetails, 2, true, TextInputType.multiline),
                _textFormField('Diagnosis', diagnosis, 2, true, TextInputType.multiline),
                _textFormField('Current Presentation', currentPresentation, 2, true, TextInputType.multiline),
                SizedBox(height: 20,),
                Text('RISK', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 18),),
                SizedBox(height: 20,),
                // _buildRiskCheckboxes(),
                // riskYes ? _textFormField('Explanation', riskExplanation) : Container(),

                _buildForensicHistoryCheckboxes(),
                forensicHistoryYes ? _textFormField('Details', forensicHistory, 1, forensicHistoryYes) : Container(),
                _buildRacialGenderConcernsCheckboxes(),
                racialGenderConcernsYes ? _textFormField('Details', racialGenderConcerns, 1, racialGenderConcernsYes) : Container(),
                _buildViolenceAggressionCheckboxes(),
                violenceAggressionYes ? _textFormField('Details', violenceAggression, 1, violenceAggressionYes) : Container(),
                _buildSelfHarmCheckboxes(),
                selfHarmYes ? _textFormField('Details', selfHarm, 1, selfHarmYes) : Container(),
                _buildAlcoholSubstanceCheckboxes(),
                alcoholSubstanceYes ? _textFormField('Details', alcoholSubstance, 1, alcoholSubstanceYes) : Container(),
                _buildVirusesCheckboxes(),
                virusesYes ? _textFormField('Details', viruses, 1, virusesYes) : Container(),
                _buildSafeguardingCheckboxes(),
                safeguardingYes ? _textFormField('Details', safeguarding, 1, safeguardingYes) : Container(),
                _buildPhysicalHealthConditionsCheckboxes(),
                physicalHealthConditionsYes ? _textFormField('Details', physicalHealthConditions, 1, physicalHealthConditionsYes) : Container(),
                _buildUseOfWeaponCheckboxes(),
                useOfWeaponYes ? _textFormField('Details', useOfWeapon, 1, useOfWeaponYes) : Container(),
                _buildAbsconsionRiskCheckboxes(),
                absconsionRiskYes ? _textFormField('Details', absconsionRisk, 1, absconsionRiskYes) : Container(),
                SizedBox(height: 20,),
                Text('PATIENT PROPERTY', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 18),),
                SizedBox(height: 10,),
                _buildPatientPropertyCheckboxes(),
                patientPropertyYes ? Column(
                  children: [
                    _buildPatientPropertyReceivedCheckboxes(),
                    patientPropertyReceivedYes ? _textFormField('Details', patientPropertyReceived, 1, patientPropertyReceivedYes) : Container()
                  ],
                ) : Container(),
                _buildPatientNotesReceivedCheckboxes(),
                patientNotesReceivedYes ? _textFormField('Details', patientNotesReceived, 1, patientNotesReceivedYes) : Container(),
                SizedBox(height: 20,),
                Text('PATIENT CHECKS', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 18),),
                SizedBox(height: 10,),
                _buildPatientSearchedCheckboxes(),
                SizedBox(height: 10,),
                _buildItemsRemovedCheckboxes(),
                SizedBox(height: 10,),
                itemsRemovedYes ? _textFormField('Details', itemsRemoved, 2, itemsRemovedYes, TextInputType.multiline) : Container(),
                _textFormField('Patient informed and understands what is happening and involved in decision making', patientInformed, 1, true),
                _textFormField('Injuries noted at collection', injuriesNoted, 2, true, TextInputType.multiline),
                SizedBox(height: 20,),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('BODY MAP', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 18),),
                ],),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Flexible(child: Text('To be used before leaving the unit with any patient', style: TextStyle(color: bluePurple, fontSize: 16),),),
                ],),
                SizedBox(height: 20,),
                RepaintBoundary(
                    key: scr,
                    child: GestureDetector(
                      onVerticalDragUpdate: (_) {},
                      onHorizontalDragUpdate: (_){},
                      child: Stack(
                        children: [
                          Positioned(
                            child: Center(child: Image.asset(
                              'assets/images/bodyMap.png',
                              width: targetWidth,
                            ),),
                          ),
                          bodyMapSignature,



                        ],
                      ),
                    )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                  TextButton(
                      onPressed: () {
                        bodyMapSignature
                            .clear();
                        transferReportModel.updateTemporaryRecord(widget.edit, Strings.bodyMapPoints, null, widget.jobId, widget.saved, widget.savedId);

                        // _databaseHelper
                        //     .updateTemporaryTransferReportField(widget.edit,
                        //     {Strings.bodyMapPoints: null},
                        //     user.uid,
                        //     widget.jobId, widget.saved, widget.savedId);

                        transferReportModel.updateTemporaryRecord(widget.edit, Strings.bodyMapImage, null, widget.jobId, widget.saved, widget.savedId);

                        // _databaseHelper
                        //     .updateTemporaryTransferReportField(widget.edit,
                        //     {Strings.bodyMapImage: null}, user.uid,
                        //     widget.jobId, widget.saved, widget.savedId);
                        // setState(() {
                        //   bodyMapPoints = [];
                        //   bodyMapImageBytes =
                        //   null;
                        // });
                      },
                      child: Text(
                        'Clear',
                        style: TextStyle(color: bluePurple),
                      ))
                ],),
                SizedBox(height: 20,),
                _buildMedicalAttentionCheckboxes(),
                medicalAttentionYes ? _textFormField('Details', medicalAttention, 2, medicalAttentionYes, TextInputType.multiline) : Container(),
                _textFormField('Current Medication (inc. time last administered)', currentMedication, 2, true, TextInputType.multiline),
                _textFormField('Last Recorded Physical Observations', physicalObservations, 2, true, TextInputType.multiline),
                _buildRelevantInformationCheckboxes(),
                relevantInformationYes ? _textFormField('Details', relevantInformation, 4, relevantInformationYes, TextInputType.multiline) : Container(),
                SizedBox(height: 20,),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('TRANSFER REPORT', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 18),),
                ],),
                SizedBox(height: 20,),
                SizedBox(height: 20,),
          RichText(
              text: TextSpan(
                  text: 'Patient Report - please include: mental state, risk, physical health concerns, delays',
                  style: TextStyle(
                      fontSize: 16.0, fontFamily: 'Open Sans', color: bluePurple, fontWeight: FontWeight.bold),
                  children:
                  [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 16.0, fontFamily: 'Open Sans'),
                    ),                                           ]
              ),
          ),
              //Text('Patient Report - please include: mental state, risk, physical health concerns, delays', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),),
                SizedBox(height: 10,),
                _textFormField('', patientReport, 8, true, TextInputType.multiline, true),
                _buildAcceptPpeCheckboxes(),
                SizedBox(height: 10,),
                _textFormField('Print Name', patientReportPrintName, 1, true),
                _textFormField('Role', patientReportRole, 1, true),
                _buildPatientReportSignatureRow(),
                _buildDateField('Date', patientReportDate, Strings.patientReportDate, true),
                _buildTimeField('Time', patientReportTime, Strings.patientReportTime, true),
                SizedBox(height: 20,),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('TRANSFER REPORT', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 18),),
                ],),
                SizedBox(height: 10,),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('HANDCUFF FORM', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 18),),
                ],),
                SizedBox(height: 20,),
                _buildHandcuffsUsedRow(),
                handcuffsUsedNo ? Container() : Column(children: [
                  SizedBox(height: 20,),
                  Text('If yes please complete incident form', style: TextStyle(color: bluePurple),),
                  SizedBox(height: 10,),
                  _buildDateField('Date', handcuffsDate, Strings.handcuffsDate, handcuffsUsedYes),
                  _buildTimeField('Time Handcuffs Applied', handcuffsTime, Strings.handcuffsTime, handcuffsUsedYes),
                  _textFormField('Authorised by', handcuffsAuthorisedBy, 1, handcuffsUsedYes),
                  _textFormField('Handcuffs Applied by', handcuffsAppliedBy, 1, handcuffsUsedYes),
                  _buildTimeField('Time Handcuffs Removed', handcuffsRemovedTime, Strings.handcuffsRemovedTime, handcuffsUsedYes),
                ],),
                SizedBox(height: 20,),
                _buildPhysicalInterventionRow(),
                SizedBox(height: 10,),
                physicalInterventionYes ? Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('PHYSICAL INTERVENTION: PLEASE SELECT', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold , fontSize: 18),),
                    SizedBox(height: 10,),
                    _buildPhysicalInterventionDrop(),
                    _textFormField('Why was the intervention required?', whyInterventionRequired, 4, physicalInterventionYes, TextInputType.multiline),
                    _textFormField('Staff Name', techniqueName1),
                    _textFormField('Technique', technique1),
                    _textFormField('Position', techniquePosition1),

                    rowCount >= 2 ? Column(
                      children: [
                        _textFormField('Staff Name', techniqueName2),
                        _textFormField('Technique', technique2),
                        _textFormField('Position', techniquePosition2),
                      ],
                    ) : Container(),
                    rowCount >= 3 ? Column(
                      children: [
                        _textFormField('Staff Name', techniqueName3),
                        _textFormField('Technique', technique3),
                        _textFormField('Position', techniquePosition3),
                      ],
                    ) : Container(),
                    rowCount >= 4 ? Column(
                      children: [
                        _textFormField('Staff Name', techniqueName4),
                        _textFormField('Technique', technique4),
                        _textFormField('Position', techniquePosition4),
                      ],
                    ) : Container(),
                    rowCount >= 5 ? Column(
                      children: [
                        _textFormField('Staff Name', techniqueName5),
                        _textFormField('Technique', technique5),
                        _textFormField('Position', techniquePosition5),
                      ],
                    ) : Container(),
                    rowCount >= 6 ? Column(
                      children: [
                        _textFormField('Staff Name', techniqueName6),
                        _textFormField('Technique', technique6),
                        _textFormField('Position', techniquePosition6),
                      ],
                    ) : Container(),
                    rowCount >= 7 ? Column(
                      children: [
                        _textFormField('Staff Name', techniqueName7),
                        _textFormField('Technique', technique7),
                        _textFormField('Position', techniquePosition7),
                      ],
                    ) : Container(),
                    rowCount >= 8 ? Column(
                      children: [
                        _textFormField('Staff Name', techniqueName8),
                        _textFormField('Technique', technique8),
                        _textFormField('Position', techniquePosition8),
                      ],
                    ) : Container(),
                    rowCount >= 9 ? Column(
                      children: [
                        _textFormField('Staff Name', techniqueName9),
                        _textFormField('Technique', technique9),
                        _textFormField('Position', techniquePosition9),
                      ],
                    ) : Container(),
                    rowCount >= 10 ? Column(
                      children: [
                        _textFormField('Staff Name', techniqueName10),
                        _textFormField('Technique', technique10),
                        _textFormField('Position', techniquePosition10),
                      ],
                    ) : Container(),
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      GradientButton('Add Staff', () => _increaseRowCount()),
                    ],),
                    SizedBox(height: 10,),
                    _buildTimeField('Time Intervention Commenced', timeInterventionCommenced, Strings.timeInterventionCommenced, physicalInterventionYes),
                    _buildTimeField('Time Intervention Completed', timeInterventionCompleted, Strings.timeInterventionCompleted, physicalInterventionYes),
                    SizedBox(height: 20,)

                  ],
                ) : Container(),
                handcuffsUsedYes ? Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('INCIDENT REPORT FORM', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 18),),
                    ],),
                    SizedBox(height: 20,),
                    _buildDateField('Date', incidentDate, Strings.incidentDate, true, false),
                    _buildTimeField('Time', incidentTime, Strings.incidentTime, true),
                    _textFormField('Incident Details', incidentDetails, 4, true, TextInputType.multiline),
                    _textFormField('Location', incidentLocation, 2, false, TextInputType.multiline),
                    _textFormField('What action did you take?', incidentAction, 4, false, TextInputType.multiline),
                    _textFormField('Staff involved', incidentStaffInvolved, 4, false, TextInputType.multiline),
                    _buildIncidentSignatureRow(),
                    SizedBox(height: 20,),
                    _buildDateField('Date', incidentSignatureDate, Strings.incidentSignatureDate, true, false),
                    _textFormField('Print Name', incidentPrintName, 1, true),
                    SizedBox(height: 20,),
                  ],
                ) : Container(),
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

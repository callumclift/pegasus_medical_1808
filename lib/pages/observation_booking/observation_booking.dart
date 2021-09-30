import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:pegasus_medical_1808/models/observation_booking_model.dart';
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


class ObservationBooking extends StatefulWidget {
  final bool fromJob;
  final String jobId;
  final bool fillDetails;
  final bool edit;
  final bool saved;
  final int savedId;

  ObservationBooking(
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
  _ObservationBookingState createState() => _ObservationBookingState();
}

class _ObservationBookingState extends State<ObservationBooking> {

  bool _loadingTemporary = false;
  //DatabaseHelper _databaseHelper = DatabaseHelper();
  ObservationBookingModel observationBookingModel;
  final dateFormat = DateFormat("dd/MM/yyyy");
  final dateTimeFormat = DateFormat("dd/MM/yyyy HH:mm");
  final timeFormat = DateFormat("HH:mm");
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController jobRef = TextEditingController();
  final TextEditingController obRequestedBy = TextEditingController();
  final TextEditingController obJobTitle = TextEditingController();
  final TextEditingController obJobContact = TextEditingController();
  final TextEditingController obJobAuthorisingManager = TextEditingController();
  final TextEditingController obJobDate = TextEditingController();
  final TextEditingController obJobTime = TextEditingController();
  final TextEditingController obBookingCoordinator = TextEditingController();
  final TextEditingController obPatientLocation = TextEditingController();
  final TextEditingController obPostcode = TextEditingController();
  final TextEditingController obLocationTel = TextEditingController();
  final TextEditingController obInvoiceDetails = TextEditingController();
  final TextEditingController obCostCode = TextEditingController();
  final TextEditingController obPurchaseOrder = TextEditingController();
  final TextEditingController obStartDateTime = TextEditingController();
  bool obMhaAssessmentYes = false;
  bool obMhaAssessmentNo = false;
  bool obBedIdentifiedYes = false;
  bool obBedIdentifiedNo = false;
  bool obWrapDocumentationYes = false;
  bool obWrapDocumentationNo = false;
  final TextEditingController obShiftRequired = TextEditingController();
  final TextEditingController obPatientName = TextEditingController();
  final TextEditingController obLegalStatus = TextEditingController();
  final TextEditingController obDateOfBirth = TextEditingController();
  final TextEditingController obNhsNumber = TextEditingController();
  final TextEditingController obGender = TextEditingController();
  final TextEditingController obEthnicity = TextEditingController();
  final TextEditingController obCovidStatus = TextEditingController();
  final TextEditingController obHca1 = TextEditingController();
  final TextEditingController obHca2 = TextEditingController();
  final TextEditingController obHca3 = TextEditingController();
  final TextEditingController obHca4 = TextEditingController();
  final TextEditingController obHca5 = TextEditingController();
  final TextEditingController obCurrentPresentation = TextEditingController();
  bool obSpecificCarePlanYes = false;
  bool obSpecificCarePlanNo = false;
  final TextEditingController obSpecificCarePlan = TextEditingController();
  bool obPatientWarningsYes = false;
  bool obPatientWarningsNo = false;
  final TextEditingController obPatientWarnings = TextEditingController();
  final TextEditingController obPresentingRisks = TextEditingController();
  final TextEditingController obPreviousRisks = TextEditingController();
  bool obGenderConcernsYes = false;
  bool obGenderConcernsNo = false;
  final TextEditingController obGenderConcerns = TextEditingController();
  bool obSafeguardingConcernsYes = false;
  bool obSafeguardingConcernsNo = false;
  final TextEditingController obSafeguardingConcerns = TextEditingController();
  final TextEditingController obTimeDue = TextEditingController();
  final TextEditingController obStaffDate1 = TextEditingController();
  final TextEditingController obStaffDate2 = TextEditingController();
  final TextEditingController obStaffDate3 = TextEditingController();
  final TextEditingController obStaffDate4 = TextEditingController();
  final TextEditingController obStaffDate5 = TextEditingController();
  final TextEditingController obStaffDate6 = TextEditingController();
  final TextEditingController obStaffDate7 = TextEditingController();
  final TextEditingController obStaffDate8 = TextEditingController();
  final TextEditingController obStaffDate9 = TextEditingController();
  final TextEditingController obStaffDate10 = TextEditingController();
  final TextEditingController obStaffDate11 = TextEditingController();
  final TextEditingController obStaffDate12 = TextEditingController();
  final TextEditingController obStaffDate13 = TextEditingController();
  final TextEditingController obStaffDate14 = TextEditingController();
  final TextEditingController obStaffDate15 = TextEditingController();
  final TextEditingController obStaffDate16 = TextEditingController();
  final TextEditingController obStaffDate17 = TextEditingController();
  final TextEditingController obStaffDate18 = TextEditingController();
  final TextEditingController obStaffDate19 = TextEditingController();
  final TextEditingController obStaffDate20 = TextEditingController();
  final TextEditingController obStaffStartTime1 = TextEditingController();
  final TextEditingController obStaffStartTime2 = TextEditingController();
  final TextEditingController obStaffStartTime3 = TextEditingController();
  final TextEditingController obStaffStartTime4 = TextEditingController();
  final TextEditingController obStaffStartTime5 = TextEditingController();
  final TextEditingController obStaffStartTime6 = TextEditingController();
  final TextEditingController obStaffStartTime7 = TextEditingController();
  final TextEditingController obStaffStartTime8 = TextEditingController();
  final TextEditingController obStaffStartTime9 = TextEditingController();
  final TextEditingController obStaffStartTime10 = TextEditingController();
  final TextEditingController obStaffStartTime11 = TextEditingController();
  final TextEditingController obStaffStartTime12 = TextEditingController();
  final TextEditingController obStaffStartTime13 = TextEditingController();
  final TextEditingController obStaffStartTime14 = TextEditingController();
  final TextEditingController obStaffStartTime15 = TextEditingController();
  final TextEditingController obStaffStartTime16 = TextEditingController();
  final TextEditingController obStaffStartTime17 = TextEditingController();
  final TextEditingController obStaffStartTime18 = TextEditingController();
  final TextEditingController obStaffStartTime19 = TextEditingController();
  final TextEditingController obStaffStartTime20 = TextEditingController();
  final TextEditingController obStaffEndTime1 = TextEditingController();
  final TextEditingController obStaffEndTime2 = TextEditingController();
  final TextEditingController obStaffEndTime3 = TextEditingController();
  final TextEditingController obStaffEndTime4 = TextEditingController();
  final TextEditingController obStaffEndTime5 = TextEditingController();
  final TextEditingController obStaffEndTime6 = TextEditingController();
  final TextEditingController obStaffEndTime7 = TextEditingController();
  final TextEditingController obStaffEndTime8 = TextEditingController();
  final TextEditingController obStaffEndTime9 = TextEditingController();
  final TextEditingController obStaffEndTime10 = TextEditingController();
  final TextEditingController obStaffEndTime11 = TextEditingController();
  final TextEditingController obStaffEndTime12 = TextEditingController();
  final TextEditingController obStaffEndTime13 = TextEditingController();
  final TextEditingController obStaffEndTime14 = TextEditingController();
  final TextEditingController obStaffEndTime15 = TextEditingController();
  final TextEditingController obStaffEndTime16 = TextEditingController();
  final TextEditingController obStaffEndTime17 = TextEditingController();
  final TextEditingController obStaffEndTime18 = TextEditingController();
  final TextEditingController obStaffEndTime19 = TextEditingController();
  final TextEditingController obStaffEndTime20 = TextEditingController();
  final TextEditingController obStaffName1 = TextEditingController();
  final TextEditingController obStaffName2 = TextEditingController();
  final TextEditingController obStaffName3 = TextEditingController();
  final TextEditingController obStaffName4 = TextEditingController();
  final TextEditingController obStaffName5 = TextEditingController();
  final TextEditingController obStaffName6 = TextEditingController();
  final TextEditingController obStaffName7 = TextEditingController();
  final TextEditingController obStaffName8 = TextEditingController();
  final TextEditingController obStaffName9 = TextEditingController();
  final TextEditingController obStaffName10 = TextEditingController();
  final TextEditingController obStaffName11 = TextEditingController();
  final TextEditingController obStaffName12 = TextEditingController();
  final TextEditingController obStaffName13 = TextEditingController();
  final TextEditingController obStaffName14 = TextEditingController();
  final TextEditingController obStaffName15 = TextEditingController();
  final TextEditingController obStaffName16 = TextEditingController();
  final TextEditingController obStaffName17 = TextEditingController();
  final TextEditingController obStaffName18 = TextEditingController();
  final TextEditingController obStaffName19 = TextEditingController();
  final TextEditingController obStaffName20 = TextEditingController();
  final TextEditingController obUsefulDetails = TextEditingController();

  String obRmn = 'Select One';
  String obHca = 'Select One';

  List<String> obRmnDrop = [
    'Select One',
    '0',
    '1'
  ];

  List<String> obHcaDrop = [
    'Select One',
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
  ];

  String obStaffRmn1 = 'Select One';
  String obStaffRmn2 = 'Select One';
  String obStaffRmn3 = 'Select One';
  String obStaffRmn4 = 'Select One';
  String obStaffRmn5 = 'Select One';
  String obStaffRmn6 = 'Select One';
  String obStaffRmn7 = 'Select One';
  String obStaffRmn8 = 'Select One';
  String obStaffRmn9 = 'Select One';
  String obStaffRmn10 = 'Select One';
  String obStaffRmn11 = 'Select One';
  String obStaffRmn12 = 'Select One';
  String obStaffRmn13 = 'Select One';
  String obStaffRmn14 = 'Select One';
  String obStaffRmn15 = 'Select One';
  String obStaffRmn16 = 'Select One';
  String obStaffRmn17 = 'Select One';
  String obStaffRmn18 = 'Select One';
  String obStaffRmn19 = 'Select One';
  String obStaffRmn20 = 'Select One';

  List<String> obStaffRmnDrop = [
    'Select One',
    'RMN',
    'HCA',
  ];


  int rowCount = 1;
  int roleCount = 1;

  @override
  void initState() {
    // TODO: implement initState
    _loadingTemporary = true;
    observationBookingModel = Provider.of<ObservationBookingModel>(context, listen: false);
    _setUpTextControllerListeners();
    _getTemporaryObservationBooking();
    super.initState();
  }

  @override
  void dispose() {
    jobRef.dispose();
    obRequestedBy.dispose();
    obJobTitle.dispose();
    obJobContact.dispose();
    obJobAuthorisingManager.dispose();
    obJobDate.dispose();
    obJobTime.dispose();
    obBookingCoordinator.dispose();
    obPatientLocation.dispose();
    obPostcode.dispose();
    obLocationTel.dispose();
    obInvoiceDetails.dispose();
    obCostCode.dispose();
    obPurchaseOrder.dispose();
    obStartDateTime.dispose();
    obShiftRequired.dispose();
    obPatientName.dispose();
    obLegalStatus.dispose();
    obDateOfBirth.dispose();
    obNhsNumber.dispose();
    obGender.dispose();
    obEthnicity.dispose();
    obCovidStatus.dispose();
    obHca1.dispose();
    obHca2.dispose();
    obHca3.dispose();
    obHca4.dispose();
    obHca5.dispose();
    obCurrentPresentation.dispose();
    obSpecificCarePlan.dispose();
    obPatientWarnings.dispose();
    obPresentingRisks.dispose();
    obPreviousRisks.dispose();
    obGenderConcerns.dispose();
    obSafeguardingConcerns.dispose();
    obTimeDue.dispose();
    obStaffDate1.dispose();
    obStaffDate2.dispose();
    obStaffDate3.dispose();
    obStaffDate4.dispose();
    obStaffDate5.dispose();
    obStaffDate6.dispose();
    obStaffDate7.dispose();
    obStaffDate8.dispose();
    obStaffDate9.dispose();
    obStaffDate10.dispose();
    obStaffDate11.dispose();
    obStaffDate12.dispose();
    obStaffDate13.dispose();
    obStaffDate14.dispose();
    obStaffDate15.dispose();
    obStaffDate16.dispose();
    obStaffDate17.dispose();
    obStaffDate18.dispose();
    obStaffDate19.dispose();
    obStaffDate20.dispose();
    obStaffStartTime1.dispose();
    obStaffStartTime2.dispose();
    obStaffStartTime3.dispose();
    obStaffStartTime4.dispose();
    obStaffStartTime5.dispose();
    obStaffStartTime6.dispose();
    obStaffStartTime7.dispose();
    obStaffStartTime8.dispose();
    obStaffStartTime9.dispose();
    obStaffStartTime10.dispose();
    obStaffStartTime11.dispose();
    obStaffStartTime12.dispose();
    obStaffStartTime13.dispose();
    obStaffStartTime14.dispose();
    obStaffStartTime15.dispose();
    obStaffStartTime16.dispose();
    obStaffStartTime17.dispose();
    obStaffStartTime18.dispose();
    obStaffStartTime19.dispose();
    obStaffStartTime20.dispose();
    obStaffEndTime1.dispose();
    obStaffEndTime2.dispose();
    obStaffEndTime3.dispose();
    obStaffEndTime4.dispose();
    obStaffEndTime5.dispose();
    obStaffEndTime6.dispose();
    obStaffEndTime7.dispose();
    obStaffEndTime8.dispose();
    obStaffEndTime9.dispose();
    obStaffEndTime10.dispose();
    obStaffEndTime11.dispose();
    obStaffEndTime12.dispose();
    obStaffEndTime13.dispose();
    obStaffEndTime14.dispose();
    obStaffEndTime15.dispose();
    obStaffEndTime16.dispose();
    obStaffEndTime17.dispose();
    obStaffEndTime18.dispose();
    obStaffEndTime19.dispose();
    obStaffEndTime20.dispose();
    obStaffName1.dispose();
    obStaffName2.dispose();
    obStaffName3.dispose();
    obStaffName4.dispose();
    obStaffName5.dispose();
    obStaffName6.dispose();
    obStaffName7.dispose();
    obStaffName8.dispose();
    obStaffName9.dispose();
    obStaffName10.dispose();
    obStaffName11.dispose();
    obStaffName12.dispose();
    obStaffName13.dispose();
    obStaffName14.dispose();
    obStaffName15.dispose();
    obStaffName16.dispose();
    obStaffName17.dispose();
    obStaffName18.dispose();
    obStaffName19.dispose();
    obStaffName20.dispose();
    obUsefulDetails.dispose();
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
      observationBookingModel.updateTemporaryRecord(widget.edit, value, encrypt ? GlobalFunctions.encryptString(controllerText) : GlobalFunctions.databaseValueString(controllerText), widget.jobId, widget.saved, widget.savedId);

      // _databaseHelper.updateTemporaryObservationBookingField(widget.edit, {
      //   value:
      //   encrypt ? GlobalFunctions.encryptString(controllerText) : GlobalFunctions.databaseValueString(controllerText)
      // }, user.uid, widget.jobId, widget.saved, widget.savedId);
    });
  }

  _setUpTextControllerListeners() {

    _addListener(jobRef, Strings.jobRef, false, true);
    _addListener(obRequestedBy, Strings.obRequestedBy);
    _addListener(obJobTitle, Strings.obJobTitle);
    _addListener(obJobContact, Strings.obJobContact);
    _addListener(obJobAuthorisingManager, Strings.obJobAuthorisingManager);
    _addListener(obBookingCoordinator, Strings.obBookingCoordinator);
    _addListener(obPatientLocation, Strings.obPatientLocation);
    _addListener(obPostcode, Strings.obPostcode, true, true);
    _addListener(obLocationTel, Strings.obLocationTel);
    _addListener(obInvoiceDetails, Strings.obInvoiceDetails);
    _addListener(obCostCode, Strings.obCostCode);
    _addListener(obPurchaseOrder, Strings.obPurchaseOrder);
    _addListener(obShiftRequired, Strings.obShiftRequired);
    _addListener(obPatientName, Strings.obPatientName, true, false, true);
    _addListener(obLegalStatus, Strings.obLegalStatus);
    _addListener(obNhsNumber, Strings.obNhsNumber);
    _addListener(obGender, Strings.obGender);
    _addListener(obEthnicity, Strings.obEthnicity);
    _addListener(obCovidStatus, Strings.obCovidStatus);
    _addListener(obHca1, Strings.obHca1);
    _addListener(obHca2, Strings.obHca2);
    _addListener(obHca3, Strings.obHca3);
    _addListener(obHca4, Strings.obHca4);
    _addListener(obHca5, Strings.obHca5);
    _addListener(obCurrentPresentation, Strings.obCurrentPresentation);
    _addListener(obSpecificCarePlan, Strings.obSpecificCarePlan);
    _addListener(obPatientWarnings, Strings.obPatientWarnings);
    _addListener(obPresentingRisks, Strings.obPresentingRisks);
    _addListener(obPreviousRisks, Strings.obPreviousRisks);
    _addListener(obGenderConcerns, Strings.obGenderConcerns);
    _addListener(obSafeguardingConcerns, Strings.obSafeguardingConcerns);
    _addListener(obStaffName1, Strings.obStaffName1, true, false, true);
    _addListener(obStaffName2, Strings.obStaffName2, true, false, true);
    _addListener(obStaffName3, Strings.obStaffName3, true, false, true);
    _addListener(obStaffName4, Strings.obStaffName4, true, false, true);
    _addListener(obStaffName5, Strings.obStaffName5, true, false, true);
    _addListener(obStaffName6, Strings.obStaffName6, true, false, true);
    _addListener(obStaffName7, Strings.obStaffName7, true, false, true);
    _addListener(obStaffName8, Strings.obStaffName8, true, false, true);
    _addListener(obStaffName9, Strings.obStaffName9, true, false, true);
    _addListener(obStaffName10, Strings.obStaffName10, true, false, true);
    _addListener(obStaffName11, Strings.obStaffName11, true, false, true);
    _addListener(obStaffName12, Strings.obStaffName12, true, false, true);
    _addListener(obStaffName13, Strings.obStaffName13, true, false, true);
    _addListener(obStaffName14, Strings.obStaffName14, true, false, true);
    _addListener(obStaffName15, Strings.obStaffName15, true, false, true);
    _addListener(obStaffName16, Strings.obStaffName16, true, false, true);
    _addListener(obStaffName17, Strings.obStaffName17, true, false, true);
    _addListener(obStaffName18, Strings.obStaffName18, true, false, true);
    _addListener(obStaffName19, Strings.obStaffName19, true, false, true);
    _addListener(obStaffName20, Strings.obStaffName20, true, false, true);
    _addListener(obUsefulDetails, Strings.obUsefulDetails);
  }

  _getTemporaryObservationBooking() async {

    if (mounted) {

      await observationBookingModel.setupTemporaryRecord();

      bool hasRecord = await observationBookingModel.checkRecordExists(widget.edit, widget.jobId, widget.saved, widget.savedId);


      if (hasRecord) {
        Map<String, dynamic> observationBooking = await observationBookingModel.getTemporaryRecord(widget.edit, widget.jobId, widget.saved, widget.savedId);



        if (observationBooking[Strings.jobRef] != null) {
          jobRef.text = GlobalFunctions.databaseValueString(
              observationBooking[Strings.jobRef]);
        } else {
          jobRef.text = '';
        }

        GlobalFunctions.getTemporaryValue(observationBooking, obRequestedBy, Strings.obRequestedBy);
        GlobalFunctions.getTemporaryValue(observationBooking, obJobTitle, Strings.obJobTitle);
        GlobalFunctions.getTemporaryValue(observationBooking, obJobContact, Strings.obJobContact);
        GlobalFunctions.getTemporaryValue(observationBooking, obJobAuthorisingManager, Strings.obJobAuthorisingManager);
        if (observationBooking[Strings.obJobDate] != null) {
          obJobDate.text =
              dateFormat.format(DateTime.parse(observationBooking[Strings.obJobDate]));
        } else {
          obJobDate.text = '';
        }
        GlobalFunctions.getTemporaryValueTime(observationBooking, obJobTime, Strings.obJobTime);
        GlobalFunctions.getTemporaryValue(observationBooking, obBookingCoordinator, Strings.obBookingCoordinator);
        GlobalFunctions.getTemporaryValue(observationBooking, obPatientLocation, Strings.obPatientLocation);
        GlobalFunctions.getTemporaryValue(observationBooking, obPostcode, Strings.obPostcode);
        GlobalFunctions.getTemporaryValue(observationBooking, obLocationTel, Strings.obLocationTel);
        GlobalFunctions.getTemporaryValue(observationBooking, obInvoiceDetails, Strings.obInvoiceDetails);
        GlobalFunctions.getTemporaryValue(observationBooking, obCostCode, Strings.obCostCode);
        GlobalFunctions.getTemporaryValue(observationBooking, obPurchaseOrder, Strings.obPurchaseOrder);
        GlobalFunctions.getTemporaryValueDateTime(observationBooking, obStartDateTime, Strings.obStartDateTime);
        if (observationBooking[Strings.obMhaAssessmentYes] != null) {
          if (mounted) {
            setState(() {
              obMhaAssessmentYes = GlobalFunctions.tinyIntToBool(observationBooking[Strings.obMhaAssessmentYes]);
            });
          }
        }
        if (observationBooking[Strings.obMhaAssessmentNo] != null) {
          if (mounted) {
            setState(() {
              obMhaAssessmentNo = GlobalFunctions.tinyIntToBool(observationBooking[Strings.obMhaAssessmentNo]);
            });
          }
        }
        if (observationBooking[Strings.obBedIdentifiedYes] != null) {
          if (mounted) {
            setState(() {
              obBedIdentifiedYes = GlobalFunctions.tinyIntToBool(observationBooking[Strings.obBedIdentifiedYes]);
            });
          }
        }
        if (observationBooking[Strings.obBedIdentifiedNo] != null) {
          if (mounted) {
            setState(() {
              obBedIdentifiedNo = GlobalFunctions.tinyIntToBool(observationBooking[Strings.obBedIdentifiedNo]);
            });
          }
        }
        if (observationBooking[Strings.obWrapDocumentationYes] != null) {
          if (mounted) {
            setState(() {
              obWrapDocumentationYes = GlobalFunctions.tinyIntToBool(observationBooking[Strings.obWrapDocumentationYes]);
            });
          }
        }
        if (observationBooking[Strings.obWrapDocumentationNo] != null) {
          if (mounted) {
            setState(() {
              obWrapDocumentationNo = GlobalFunctions.tinyIntToBool(observationBooking[Strings.obWrapDocumentationNo]);
            });
          }
        }
        GlobalFunctions.getTemporaryValue(observationBooking, obShiftRequired, Strings.obShiftRequired);
        GlobalFunctions.getTemporaryValue(observationBooking, obPatientName, Strings.obPatientName);
        GlobalFunctions.getTemporaryValue(observationBooking, obLegalStatus, Strings.obLegalStatus);
        GlobalFunctions.getTemporaryValueDate(observationBooking, obDateOfBirth, Strings.obDateOfBirth, true);
        GlobalFunctions.getTemporaryValue(observationBooking, obNhsNumber, Strings.obNhsNumber);
        GlobalFunctions.getTemporaryValue(observationBooking, obGender, Strings.obGender);
        GlobalFunctions.getTemporaryValue(observationBooking, obEthnicity, Strings.obEthnicity);
        GlobalFunctions.getTemporaryValue(observationBooking, obCovidStatus, Strings.obCovidStatus);
        if (observationBooking[Strings.obRmn] != null) {
          obRmn = GlobalFunctions.decryptString(observationBooking[Strings.obRmn]);
        }
        if (observationBooking[Strings.obHca] != null) {
          obHca = GlobalFunctions.decryptString(observationBooking[Strings.obHca]);
        }
        GlobalFunctions.getTemporaryValue(observationBooking, obHca1, Strings.obHca1);
        GlobalFunctions.getTemporaryValue(observationBooking, obHca2, Strings.obHca2);
        GlobalFunctions.getTemporaryValue(observationBooking, obHca3, Strings.obHca3);
        GlobalFunctions.getTemporaryValue(observationBooking, obHca4, Strings.obHca4);
        GlobalFunctions.getTemporaryValue(observationBooking, obHca5, Strings.obHca5);
        GlobalFunctions.getTemporaryValue(observationBooking, obCurrentPresentation, Strings.obCurrentPresentation);
        if (observationBooking[Strings.obSpecificCarePlanYes] != null) {
          if (mounted) {
            setState(() {
              obSpecificCarePlanYes = GlobalFunctions.tinyIntToBool(observationBooking[Strings.obSpecificCarePlanYes]);
            });
          }
        }
        if (observationBooking[Strings.obSpecificCarePlanNo] != null) {
          if (mounted) {
            setState(() {
              obSpecificCarePlanNo = GlobalFunctions.tinyIntToBool(observationBooking[Strings.obSpecificCarePlanNo]);
            });
          }
        }
        GlobalFunctions.getTemporaryValue(observationBooking, obSpecificCarePlan, Strings.obSpecificCarePlan);
        if (observationBooking[Strings.obPatientWarningsYes] != null) {
          if (mounted) {
            setState(() {
              obPatientWarningsYes = GlobalFunctions.tinyIntToBool(observationBooking[Strings.obPatientWarningsYes]);
            });
          }
        }
        if (observationBooking[Strings.obPatientWarningsNo] != null) {
          if (mounted) {
            setState(() {
              obPatientWarningsNo = GlobalFunctions.tinyIntToBool(observationBooking[Strings.obPatientWarningsNo]);
            });
          }
        }
        GlobalFunctions.getTemporaryValue(observationBooking, obPatientWarnings, Strings.obPatientWarnings);
        GlobalFunctions.getTemporaryValue(observationBooking, obPresentingRisks, Strings.obPresentingRisks);
        GlobalFunctions.getTemporaryValue(observationBooking, obPreviousRisks, Strings.obPreviousRisks);
        if (observationBooking[Strings.obGenderConcernsYes] != null) {
          if (mounted) {
            setState(() {
              obGenderConcernsYes = GlobalFunctions.tinyIntToBool(observationBooking[Strings.obGenderConcernsYes]);
            });
          }
        }
        if (observationBooking[Strings.obGenderConcernsNo] != null) {
          if (mounted) {
            setState(() {
              obGenderConcernsNo = GlobalFunctions.tinyIntToBool(observationBooking[Strings.obGenderConcernsNo]);
            });
          }
        }
        GlobalFunctions.getTemporaryValue(observationBooking, obGenderConcerns, Strings.obGenderConcerns);
        if (observationBooking[Strings.obSafeguardingConcernsYes] != null) {
          if (mounted) {
            setState(() {
              obSafeguardingConcernsYes = GlobalFunctions.tinyIntToBool(observationBooking[Strings.obSafeguardingConcernsYes]);
            });
          }
        }
        if (observationBooking[Strings.obSafeguardingConcernsNo] != null) {
          if (mounted) {
            setState(() {
              obSafeguardingConcernsNo = GlobalFunctions.tinyIntToBool(observationBooking[Strings.obSafeguardingConcernsNo]);
            });
          }
        }
        GlobalFunctions.getTemporaryValue(observationBooking, obSafeguardingConcerns, Strings.obSafeguardingConcerns);
        GlobalFunctions.getTemporaryValueTime(observationBooking, obTimeDue, Strings.obTimeDue);


        if (observationBooking[Strings.obStaffDate2] != null ||
            observationBooking[Strings.obStaffStartTime2] != null ||
            observationBooking[Strings.obStaffEndTime2] != null ||
            (observationBooking[Strings.obStaffName2] != null && observationBooking[Strings.obStaffName2] != '') ||
            observationBooking[Strings.obStaffRmn2] != null) {
          setState(() {

            print(observationBooking[Strings.obStaffDate2]);
            print(observationBooking[Strings.obStaffStartTime2]);
            print(observationBooking[Strings.obStaffEndTime2]);
            print(observationBooking[Strings.obStaffName2]);
            print(observationBooking[Strings.obStaffRmn2]);

            print('inside here should not be');
            roleCount += 1;
          });
        }
        if (observationBooking[Strings.obStaffDate3] != null ||
            observationBooking[Strings.obStaffStartTime3] != null ||
            observationBooking[Strings.obStaffEndTime3] != null ||
            (observationBooking[Strings.obStaffName3] != null && observationBooking[Strings.obStaffName3] != '') ||
            observationBooking[Strings.obStaffRmn3] != null) {
          setState(() {
            roleCount += 1;
          });
        }
        if (observationBooking[Strings.obStaffDate4] != null ||
            observationBooking[Strings.obStaffStartTime4] != null ||
            observationBooking[Strings.obStaffEndTime4] != null ||
            (observationBooking[Strings.obStaffName4] != null && observationBooking[Strings.obStaffName4] != '') ||
            observationBooking[Strings.obStaffRmn4] != null) {
          setState(() {
            roleCount += 1;
          });
        }
        if (observationBooking[Strings.obStaffDate5] != null ||
            observationBooking[Strings.obStaffStartTime5] != null ||
            observationBooking[Strings.obStaffEndTime5] != null ||
            (observationBooking[Strings.obStaffName5] != null && observationBooking[Strings.obStaffName5] != '') ||
            observationBooking[Strings.obStaffRmn5] != null) {
          setState(() {
            roleCount += 1;
          });
        }
        if (observationBooking[Strings.obStaffDate6] != null ||
            observationBooking[Strings.obStaffStartTime6] != null ||
            observationBooking[Strings.obStaffEndTime6] != null ||
            (observationBooking[Strings.obStaffName6] != null && observationBooking[Strings.obStaffName6] != '') ||
            observationBooking[Strings.obStaffRmn6] != null) {
          setState(() {
            roleCount += 1;
          });
        }
        if (observationBooking[Strings.obStaffDate7] != null ||
            observationBooking[Strings.obStaffStartTime7] != null ||
            observationBooking[Strings.obStaffEndTime7] != null ||
            (observationBooking[Strings.obStaffName7] != null && observationBooking[Strings.obStaffName7] != '') ||
            observationBooking[Strings.obStaffRmn7] != null) {
          setState(() {
            roleCount += 1;
          });
        }
        if (observationBooking[Strings.obStaffDate8] != null ||
            observationBooking[Strings.obStaffStartTime8] != null ||
            observationBooking[Strings.obStaffEndTime8] != null ||
            (observationBooking[Strings.obStaffName8] != null && observationBooking[Strings.obStaffName8] != '') ||
            observationBooking[Strings.obStaffRmn8] != null) {
          setState(() {
            roleCount += 1;
          });
        }
        if (observationBooking[Strings.obStaffDate9] != null ||
            observationBooking[Strings.obStaffStartTime9] != null ||
            observationBooking[Strings.obStaffEndTime9] != null ||
            (observationBooking[Strings.obStaffName9] != null && observationBooking[Strings.obStaffName9] != '') ||
            observationBooking[Strings.obStaffRmn9] != null) {
          setState(() {
            roleCount += 1;
          });
        }
        if (observationBooking[Strings.obStaffDate10] != null ||
            observationBooking[Strings.obStaffStartTime10] != null ||
            observationBooking[Strings.obStaffEndTime10] != null ||
            (observationBooking[Strings.obStaffName10] != null && observationBooking[Strings.obStaffName10] != '') ||
            observationBooking[Strings.obStaffRmn10] != null) {
          setState(() {
            roleCount += 1;
          });
        }
        if (observationBooking[Strings.obStaffDate11] != null ||
            observationBooking[Strings.obStaffStartTime11] != null ||
            observationBooking[Strings.obStaffEndTime11] != null ||
            (observationBooking[Strings.obStaffName11] != null && observationBooking[Strings.obStaffName11] != '') ||
            observationBooking[Strings.obStaffRmn11] != null) {
          setState(() {
            roleCount += 1;
          });
        }
        if (observationBooking[Strings.obStaffDate12] != null ||
            observationBooking[Strings.obStaffStartTime12] != null ||
            observationBooking[Strings.obStaffEndTime12] != null ||
            (observationBooking[Strings.obStaffName12] != null && observationBooking[Strings.obStaffName12] != '') ||
            observationBooking[Strings.obStaffRmn12] != null) {
          setState(() {
            roleCount += 1;
          });
        }
        if (observationBooking[Strings.obStaffDate13] != null ||
            observationBooking[Strings.obStaffStartTime13] != null ||
            observationBooking[Strings.obStaffEndTime13] != null ||
            (observationBooking[Strings.obStaffName13] != null && observationBooking[Strings.obStaffName13] != '') ||
            observationBooking[Strings.obStaffRmn13] != null) {
          setState(() {
            roleCount += 1;
          });
        }
        if (observationBooking[Strings.obStaffDate14] != null ||
            observationBooking[Strings.obStaffStartTime14] != null ||
            observationBooking[Strings.obStaffEndTime14] != null ||
            (observationBooking[Strings.obStaffName14] != null && observationBooking[Strings.obStaffName14] != '') ||
            observationBooking[Strings.obStaffRmn14] != null) {
          setState(() {
            roleCount += 1;
          });
        }
        if (observationBooking[Strings.obStaffDate15] != null ||
            observationBooking[Strings.obStaffStartTime15] != null ||
            observationBooking[Strings.obStaffEndTime15] != null ||
            (observationBooking[Strings.obStaffName15] != null && observationBooking[Strings.obStaffName15] != '') ||
            observationBooking[Strings.obStaffRmn15] != null) {
          setState(() {
            roleCount += 1;
          });
        }
        if (observationBooking[Strings.obStaffDate16] != null ||
            observationBooking[Strings.obStaffStartTime16] != null ||
            observationBooking[Strings.obStaffEndTime16] != null ||
            (observationBooking[Strings.obStaffName16] != null && observationBooking[Strings.obStaffName16] != '') ||
            observationBooking[Strings.obStaffRmn16] != null) {
          setState(() {
            roleCount += 1;
          });
        }
        if (observationBooking[Strings.obStaffDate17] != null ||
            observationBooking[Strings.obStaffStartTime17] != null ||
            observationBooking[Strings.obStaffEndTime17] != null ||
            (observationBooking[Strings.obStaffName17] != null && observationBooking[Strings.obStaffName17] != '') ||
            observationBooking[Strings.obStaffRmn17] != null) {
          setState(() {
            roleCount += 1;
          });
        }
        if (observationBooking[Strings.obStaffDate18] != null ||
            observationBooking[Strings.obStaffStartTime18] != null ||
            observationBooking[Strings.obStaffEndTime18] != null ||
            (observationBooking[Strings.obStaffName18] != null && observationBooking[Strings.obStaffName18] != '') ||
            observationBooking[Strings.obStaffRmn18] != null) {
          setState(() {
            roleCount += 1;
          });
        }
        if (observationBooking[Strings.obStaffDate19] != null ||
            observationBooking[Strings.obStaffStartTime19] != null ||
            observationBooking[Strings.obStaffEndTime19] != null ||
            (observationBooking[Strings.obStaffName19] != null && observationBooking[Strings.obStaffName19] != '') ||
            observationBooking[Strings.obStaffRmn19] != null) {
          setState(() {
            roleCount += 1;
          });
        }
        if (observationBooking[Strings.obStaffDate20] != null ||
            observationBooking[Strings.obStaffStartTime20] != null ||
            observationBooking[Strings.obStaffEndTime20] != null ||
            (observationBooking[Strings.obStaffName20] != null && observationBooking[Strings.obStaffName20] != '') ||
            observationBooking[Strings.obStaffRmn20] != null) {
          setState(() {
            roleCount += 1;
          });
        }
        setState(() {
          rowCount = roleCount;
        });
        GlobalFunctions.getTemporaryValueDate(observationBooking, obStaffDate1, Strings.obStaffDate1);
        GlobalFunctions.getTemporaryValueDate(observationBooking, obStaffDate2, Strings.obStaffDate2);
        GlobalFunctions.getTemporaryValueDate(observationBooking, obStaffDate3, Strings.obStaffDate3);
        GlobalFunctions.getTemporaryValueDate(observationBooking, obStaffDate4, Strings.obStaffDate4);
        GlobalFunctions.getTemporaryValueDate(observationBooking, obStaffDate5, Strings.obStaffDate5);
        GlobalFunctions.getTemporaryValueDate(observationBooking, obStaffDate6, Strings.obStaffDate6);
        GlobalFunctions.getTemporaryValueDate(observationBooking, obStaffDate7, Strings.obStaffDate7);
        GlobalFunctions.getTemporaryValueDate(observationBooking, obStaffDate8, Strings.obStaffDate8);
        GlobalFunctions.getTemporaryValueDate(observationBooking, obStaffDate9, Strings.obStaffDate9);
        GlobalFunctions.getTemporaryValueDate(observationBooking, obStaffDate10, Strings.obStaffDate10);
        GlobalFunctions.getTemporaryValueDate(observationBooking, obStaffDate11, Strings.obStaffDate11);
        GlobalFunctions.getTemporaryValueDate(observationBooking, obStaffDate12, Strings.obStaffDate12);
        GlobalFunctions.getTemporaryValueDate(observationBooking, obStaffDate13, Strings.obStaffDate13);
        GlobalFunctions.getTemporaryValueDate(observationBooking, obStaffDate14, Strings.obStaffDate14);
        GlobalFunctions.getTemporaryValueDate(observationBooking, obStaffDate15, Strings.obStaffDate15);
        GlobalFunctions.getTemporaryValueDate(observationBooking, obStaffDate16, Strings.obStaffDate16);
        GlobalFunctions.getTemporaryValueDate(observationBooking, obStaffDate17, Strings.obStaffDate17);
        GlobalFunctions.getTemporaryValueDate(observationBooking, obStaffDate18, Strings.obStaffDate18);
        GlobalFunctions.getTemporaryValueDate(observationBooking, obStaffDate19, Strings.obStaffDate19);
        GlobalFunctions.getTemporaryValueDate(observationBooking, obStaffDate20, Strings.obStaffDate20);
        GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffStartTime1, Strings.obStaffStartTime1);
        GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffStartTime2, Strings.obStaffStartTime2);
        GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffStartTime3, Strings.obStaffStartTime3);
        GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffStartTime4, Strings.obStaffStartTime4);
        GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffStartTime5, Strings.obStaffStartTime5);
        GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffStartTime6, Strings.obStaffStartTime6);
        GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffStartTime7, Strings.obStaffStartTime7);
        GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffStartTime8, Strings.obStaffStartTime8);
        GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffStartTime9, Strings.obStaffStartTime9);
        GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffStartTime10, Strings.obStaffStartTime10);
        GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffStartTime11, Strings.obStaffStartTime11);
        GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffStartTime12, Strings.obStaffStartTime12);
        GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffStartTime13, Strings.obStaffStartTime13);
        GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffStartTime14, Strings.obStaffStartTime14);
        GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffStartTime15, Strings.obStaffStartTime15);
        GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffStartTime16, Strings.obStaffStartTime16);
        GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffStartTime17, Strings.obStaffStartTime17);
        GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffStartTime18, Strings.obStaffStartTime18);
        GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffStartTime19, Strings.obStaffStartTime19);
        GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffStartTime20, Strings.obStaffStartTime20);
        GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffEndTime1, Strings.obStaffEndTime1);
        GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffEndTime2, Strings.obStaffEndTime2);
        GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffEndTime3, Strings.obStaffEndTime3);
        GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffEndTime4, Strings.obStaffEndTime4);
        GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffEndTime5, Strings.obStaffEndTime5);
        GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffEndTime6, Strings.obStaffEndTime6);
        GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffEndTime7, Strings.obStaffEndTime7);
        GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffEndTime8, Strings.obStaffEndTime8);
        GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffEndTime9, Strings.obStaffEndTime9);
        GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffEndTime10, Strings.obStaffEndTime10);
        GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffEndTime11, Strings.obStaffEndTime11);
        GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffEndTime12, Strings.obStaffEndTime12);
        GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffEndTime13, Strings.obStaffEndTime13);
        GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffEndTime14, Strings.obStaffEndTime14);
        GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffEndTime15, Strings.obStaffEndTime15);
        GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffEndTime16, Strings.obStaffEndTime16);
        GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffEndTime17, Strings.obStaffEndTime17);
        GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffEndTime18, Strings.obStaffEndTime18);
        GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffEndTime19, Strings.obStaffEndTime19);
        GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffEndTime20, Strings.obStaffEndTime20);
        GlobalFunctions.getTemporaryValue(observationBooking, obStaffName1, Strings.obStaffName1);
        GlobalFunctions.getTemporaryValue(observationBooking, obStaffName2, Strings.obStaffName2);
        GlobalFunctions.getTemporaryValue(observationBooking, obStaffName3, Strings.obStaffName3);
        GlobalFunctions.getTemporaryValue(observationBooking, obStaffName4, Strings.obStaffName4);
        GlobalFunctions.getTemporaryValue(observationBooking, obStaffName5, Strings.obStaffName5);
        GlobalFunctions.getTemporaryValue(observationBooking, obStaffName6, Strings.obStaffName6);
        GlobalFunctions.getTemporaryValue(observationBooking, obStaffName7, Strings.obStaffName7);
        GlobalFunctions.getTemporaryValue(observationBooking, obStaffName8, Strings.obStaffName8);
        GlobalFunctions.getTemporaryValue(observationBooking, obStaffName9, Strings.obStaffName9);
        GlobalFunctions.getTemporaryValue(observationBooking, obStaffName10, Strings.obStaffName10);
        GlobalFunctions.getTemporaryValue(observationBooking, obStaffName11, Strings.obStaffName11);
        GlobalFunctions.getTemporaryValue(observationBooking, obStaffName12, Strings.obStaffName12);
        GlobalFunctions.getTemporaryValue(observationBooking, obStaffName13, Strings.obStaffName13);
        GlobalFunctions.getTemporaryValue(observationBooking, obStaffName14, Strings.obStaffName14);
        GlobalFunctions.getTemporaryValue(observationBooking, obStaffName15, Strings.obStaffName15);
        GlobalFunctions.getTemporaryValue(observationBooking, obStaffName16, Strings.obStaffName16);
        GlobalFunctions.getTemporaryValue(observationBooking, obStaffName17, Strings.obStaffName17);
        GlobalFunctions.getTemporaryValue(observationBooking, obStaffName18, Strings.obStaffName18);
        GlobalFunctions.getTemporaryValue(observationBooking, obStaffName19, Strings.obStaffName19);
        GlobalFunctions.getTemporaryValue(observationBooking, obStaffName20, Strings.obStaffName20);
        if (observationBooking[Strings.obStaffRmn1] != null) {
          obStaffRmn1 = GlobalFunctions.decryptString(observationBooking[Strings.obStaffRmn1]);
        }
        if (observationBooking[Strings.obStaffRmn2] != null) {
          obStaffRmn2 = GlobalFunctions.decryptString(observationBooking[Strings.obStaffRmn2]);
        }
        if (observationBooking[Strings.obStaffRmn3] != null) {
          obStaffRmn3 = GlobalFunctions.decryptString(observationBooking[Strings.obStaffRmn3]);
        }
        if (observationBooking[Strings.obStaffRmn4] != null) {
          obStaffRmn4 = GlobalFunctions.decryptString(observationBooking[Strings.obStaffRmn4]);
        }
        if (observationBooking[Strings.obStaffRmn5] != null) {
          obStaffRmn5 = GlobalFunctions.decryptString(observationBooking[Strings.obStaffRmn5]);
        }
        if (observationBooking[Strings.obStaffRmn6] != null) {
          obStaffRmn6 = GlobalFunctions.decryptString(observationBooking[Strings.obStaffRmn6]);
        }
        if (observationBooking[Strings.obStaffRmn7] != null) {
          obStaffRmn7 = GlobalFunctions.decryptString(observationBooking[Strings.obStaffRmn7]);
        }
        if (observationBooking[Strings.obStaffRmn8] != null) {
          obStaffRmn8 = GlobalFunctions.decryptString(observationBooking[Strings.obStaffRmn8]);
        }
        if (observationBooking[Strings.obStaffRmn9] != null) {
          obStaffRmn9 = GlobalFunctions.decryptString(observationBooking[Strings.obStaffRmn9]);
        }
        if (observationBooking[Strings.obStaffRmn10] != null) {
          obStaffRmn10 = GlobalFunctions.decryptString(observationBooking[Strings.obStaffRmn10]);
        }
        if (observationBooking[Strings.obStaffRmn11] != null) {
          obStaffRmn11 = GlobalFunctions.decryptString(observationBooking[Strings.obStaffRmn11]);
        }
        if (observationBooking[Strings.obStaffRmn12] != null) {
          obStaffRmn12 = GlobalFunctions.decryptString(observationBooking[Strings.obStaffRmn12]);
        }
        if (observationBooking[Strings.obStaffRmn13] != null) {
          obStaffRmn13 = GlobalFunctions.decryptString(observationBooking[Strings.obStaffRmn13]);
        }
        if (observationBooking[Strings.obStaffRmn14] != null) {
          obStaffRmn14 = GlobalFunctions.decryptString(observationBooking[Strings.obStaffRmn14]);
        }
        if (observationBooking[Strings.obStaffRmn15] != null) {
          obStaffRmn15 = GlobalFunctions.decryptString(observationBooking[Strings.obStaffRmn15]);
        }
        if (observationBooking[Strings.obStaffRmn16] != null) {
          obStaffRmn16 = GlobalFunctions.decryptString(observationBooking[Strings.obStaffRmn16]);
        }
        if (observationBooking[Strings.obStaffRmn17] != null) {
          obStaffRmn17 = GlobalFunctions.decryptString(observationBooking[Strings.obStaffRmn17]);
        }
        if (observationBooking[Strings.obStaffRmn18] != null) {
          obStaffRmn18 = GlobalFunctions.decryptString(observationBooking[Strings.obStaffRmn18]);
        }
        if (observationBooking[Strings.obStaffRmn19] != null) {
          obStaffRmn19 = GlobalFunctions.decryptString(observationBooking[Strings.obStaffRmn19]);
        }
        if (observationBooking[Strings.obStaffRmn20] != null) {
          obStaffRmn20 = GlobalFunctions.decryptString(observationBooking[Strings.obStaffRmn20]);
        }
        GlobalFunctions.getTemporaryValue(observationBooking, obUsefulDetails, Strings.obUsefulDetails);

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
    //   int result = await _databaseHelper.checkTemporaryObservationBookingExists(widget.edit,
    //       user.uid, widget.jobId, widget.saved, widget.savedId);
    //   if (result != 0) {
    //     Map<String, dynamic> observationBooking = await _databaseHelper
    //         .getTemporaryObservationBooking(widget.edit, user.uid, widget.jobId, widget.saved, widget.savedId);
    //
    //
    //     if (observationBooking[Strings.jobRef] != null) {
    //       jobRef.text = GlobalFunctions.databaseValueString(
    //           observationBooking[Strings.jobRef]);
    //     } else {
    //       jobRef.text = '';
    //     }
    //
    //     GlobalFunctions.getTemporaryValue(observationBooking, obRequestedBy, Strings.obRequestedBy);
    //     GlobalFunctions.getTemporaryValue(observationBooking, obJobTitle, Strings.obJobTitle);
    //     GlobalFunctions.getTemporaryValue(observationBooking, obJobContact, Strings.obJobContact);
    //     GlobalFunctions.getTemporaryValue(observationBooking, obJobAuthorisingManager, Strings.obJobAuthorisingManager);
    //     if (observationBooking[Strings.obJobDate] != null) {
    //       obJobDate.text =
    //           dateFormat.format(DateTime.parse(observationBooking[Strings.obJobDate]));
    //     } else {
    //       obJobDate.text = '';
    //     }
    //     GlobalFunctions.getTemporaryValueTime(observationBooking, obJobTime, Strings.obJobTime);
    //     GlobalFunctions.getTemporaryValue(observationBooking, obBookingCoordinator, Strings.obBookingCoordinator);
    //     GlobalFunctions.getTemporaryValue(observationBooking, obPatientLocation, Strings.obPatientLocation);
    //     GlobalFunctions.getTemporaryValue(observationBooking, obPostcode, Strings.obPostcode);
    //     GlobalFunctions.getTemporaryValue(observationBooking, obLocationTel, Strings.obLocationTel);
    //     GlobalFunctions.getTemporaryValue(observationBooking, obInvoiceDetails, Strings.obInvoiceDetails);
    //     GlobalFunctions.getTemporaryValue(observationBooking, obCostCode, Strings.obCostCode);
    //     GlobalFunctions.getTemporaryValue(observationBooking, obPurchaseOrder, Strings.obPurchaseOrder);
    //     GlobalFunctions.getTemporaryValueDateTime(observationBooking, obStartDateTime, Strings.obStartDateTime);
    //     if (observationBooking[Strings.obMhaAssessmentYes] != null) {
    //       if (mounted) {
    //         setState(() {
    //           obMhaAssessmentYes = GlobalFunctions.tinyIntToBool(observationBooking[Strings.obMhaAssessmentYes]);
    //         });
    //       }
    //     }
    //     if (observationBooking[Strings.obMhaAssessmentNo] != null) {
    //       if (mounted) {
    //         setState(() {
    //           obMhaAssessmentNo = GlobalFunctions.tinyIntToBool(observationBooking[Strings.obMhaAssessmentNo]);
    //         });
    //       }
    //     }
    //     if (observationBooking[Strings.obBedIdentifiedYes] != null) {
    //       if (mounted) {
    //         setState(() {
    //           obBedIdentifiedYes = GlobalFunctions.tinyIntToBool(observationBooking[Strings.obBedIdentifiedYes]);
    //         });
    //       }
    //     }
    //     if (observationBooking[Strings.obBedIdentifiedNo] != null) {
    //       if (mounted) {
    //         setState(() {
    //           obBedIdentifiedNo = GlobalFunctions.tinyIntToBool(observationBooking[Strings.obBedIdentifiedNo]);
    //         });
    //       }
    //     }
    //     if (observationBooking[Strings.obWrapDocumentationYes] != null) {
    //       if (mounted) {
    //         setState(() {
    //           obWrapDocumentationYes = GlobalFunctions.tinyIntToBool(observationBooking[Strings.obWrapDocumentationYes]);
    //         });
    //       }
    //     }
    //     if (observationBooking[Strings.obWrapDocumentationNo] != null) {
    //       if (mounted) {
    //         setState(() {
    //           obWrapDocumentationNo = GlobalFunctions.tinyIntToBool(observationBooking[Strings.obWrapDocumentationNo]);
    //         });
    //       }
    //     }
    //     GlobalFunctions.getTemporaryValue(observationBooking, obShiftRequired, Strings.obShiftRequired);
    //     GlobalFunctions.getTemporaryValue(observationBooking, obPatientName, Strings.obPatientName);
    //     GlobalFunctions.getTemporaryValue(observationBooking, obLegalStatus, Strings.obLegalStatus);
    //     GlobalFunctions.getTemporaryValueDate(observationBooking, obDateOfBirth, Strings.obDateOfBirth, true);
    //     GlobalFunctions.getTemporaryValue(observationBooking, obNhsNumber, Strings.obNhsNumber);
    //     GlobalFunctions.getTemporaryValue(observationBooking, obGender, Strings.obGender);
    //     GlobalFunctions.getTemporaryValue(observationBooking, obEthnicity, Strings.obEthnicity);
    //     GlobalFunctions.getTemporaryValue(observationBooking, obCovidStatus, Strings.obCovidStatus);
    //     if (observationBooking[Strings.obRmn] != null) {
    //       obRmn = GlobalFunctions.decryptString(observationBooking[Strings.obRmn]);
    //     }
    //     if (observationBooking[Strings.obHca] != null) {
    //       obHca = GlobalFunctions.decryptString(observationBooking[Strings.obHca]);
    //     }
    //     GlobalFunctions.getTemporaryValue(observationBooking, obHca1, Strings.obHca1);
    //     GlobalFunctions.getTemporaryValue(observationBooking, obHca2, Strings.obHca2);
    //     GlobalFunctions.getTemporaryValue(observationBooking, obHca3, Strings.obHca3);
    //     GlobalFunctions.getTemporaryValue(observationBooking, obHca4, Strings.obHca4);
    //     GlobalFunctions.getTemporaryValue(observationBooking, obHca5, Strings.obHca5);
    //     GlobalFunctions.getTemporaryValue(observationBooking, obCurrentPresentation, Strings.obCurrentPresentation);
    //     if (observationBooking[Strings.obSpecificCarePlanYes] != null) {
    //       if (mounted) {
    //         setState(() {
    //           obSpecificCarePlanYes = GlobalFunctions.tinyIntToBool(observationBooking[Strings.obSpecificCarePlanYes]);
    //         });
    //       }
    //     }
    //     if (observationBooking[Strings.obSpecificCarePlanNo] != null) {
    //       if (mounted) {
    //         setState(() {
    //           obSpecificCarePlanNo = GlobalFunctions.tinyIntToBool(observationBooking[Strings.obSpecificCarePlanNo]);
    //         });
    //       }
    //     }
    //     GlobalFunctions.getTemporaryValue(observationBooking, obSpecificCarePlan, Strings.obSpecificCarePlan);
    //     if (observationBooking[Strings.obPatientWarningsYes] != null) {
    //       if (mounted) {
    //         setState(() {
    //           obPatientWarningsYes = GlobalFunctions.tinyIntToBool(observationBooking[Strings.obPatientWarningsYes]);
    //         });
    //       }
    //     }
    //     if (observationBooking[Strings.obPatientWarningsNo] != null) {
    //       if (mounted) {
    //         setState(() {
    //           obPatientWarningsNo = GlobalFunctions.tinyIntToBool(observationBooking[Strings.obPatientWarningsNo]);
    //         });
    //       }
    //     }
    //     GlobalFunctions.getTemporaryValue(observationBooking, obPatientWarnings, Strings.obPatientWarnings);
    //     GlobalFunctions.getTemporaryValue(observationBooking, obPresentingRisks, Strings.obPresentingRisks);
    //     GlobalFunctions.getTemporaryValue(observationBooking, obPreviousRisks, Strings.obPreviousRisks);
    //     if (observationBooking[Strings.obGenderConcernsYes] != null) {
    //       if (mounted) {
    //         setState(() {
    //           obGenderConcernsYes = GlobalFunctions.tinyIntToBool(observationBooking[Strings.obGenderConcernsYes]);
    //         });
    //       }
    //     }
    //     if (observationBooking[Strings.obGenderConcernsNo] != null) {
    //       if (mounted) {
    //         setState(() {
    //           obGenderConcernsNo = GlobalFunctions.tinyIntToBool(observationBooking[Strings.obGenderConcernsNo]);
    //         });
    //       }
    //     }
    //     GlobalFunctions.getTemporaryValue(observationBooking, obGenderConcerns, Strings.obGenderConcerns);
    //     if (observationBooking[Strings.obSafeguardingConcernsYes] != null) {
    //       if (mounted) {
    //         setState(() {
    //           obSafeguardingConcernsYes = GlobalFunctions.tinyIntToBool(observationBooking[Strings.obSafeguardingConcernsYes]);
    //         });
    //       }
    //     }
    //     if (observationBooking[Strings.obSafeguardingConcernsNo] != null) {
    //       if (mounted) {
    //         setState(() {
    //           obSafeguardingConcernsNo = GlobalFunctions.tinyIntToBool(observationBooking[Strings.obSafeguardingConcernsNo]);
    //         });
    //       }
    //     }
    //     GlobalFunctions.getTemporaryValue(observationBooking, obSafeguardingConcerns, Strings.obSafeguardingConcerns);
    //     GlobalFunctions.getTemporaryValueTime(observationBooking, obTimeDue, Strings.obTimeDue);
    //
    //
    //     if (observationBooking[Strings.obStaffDate2] != null ||
    //         observationBooking[Strings.obStaffStartTime2] != null ||
    //         observationBooking[Strings.obStaffEndTime2] != null ||
    //         (observationBooking[Strings.obStaffName2] != null && observationBooking[Strings.obStaffName2] != '') ||
    //         observationBooking[Strings.obStaffRmn2] != null) {
    //       setState(() {
    //
    //         print(observationBooking[Strings.obStaffDate2]);
    //         print(observationBooking[Strings.obStaffStartTime2]);
    //         print(observationBooking[Strings.obStaffEndTime2]);
    //         print(observationBooking[Strings.obStaffName2]);
    //         print(observationBooking[Strings.obStaffRmn2]);
    //
    //         print('inside here should not be');
    //         roleCount += 1;
    //       });
    //     }
    //     if (observationBooking[Strings.obStaffDate3] != null ||
    //         observationBooking[Strings.obStaffStartTime3] != null ||
    //         observationBooking[Strings.obStaffEndTime3] != null ||
    //         (observationBooking[Strings.obStaffName3] != null && observationBooking[Strings.obStaffName3] != '') ||
    //         observationBooking[Strings.obStaffRmn3] != null) {
    //       setState(() {
    //         roleCount += 1;
    //       });
    //     }
    //     if (observationBooking[Strings.obStaffDate4] != null ||
    //         observationBooking[Strings.obStaffStartTime4] != null ||
    //         observationBooking[Strings.obStaffEndTime4] != null ||
    //         (observationBooking[Strings.obStaffName4] != null && observationBooking[Strings.obStaffName4] != '') ||
    //         observationBooking[Strings.obStaffRmn4] != null) {
    //       setState(() {
    //         roleCount += 1;
    //       });
    //     }
    //     if (observationBooking[Strings.obStaffDate5] != null ||
    //         observationBooking[Strings.obStaffStartTime5] != null ||
    //         observationBooking[Strings.obStaffEndTime5] != null ||
    //         (observationBooking[Strings.obStaffName5] != null && observationBooking[Strings.obStaffName5] != '') ||
    //         observationBooking[Strings.obStaffRmn5] != null) {
    //       setState(() {
    //         roleCount += 1;
    //       });
    //     }
    //     if (observationBooking[Strings.obStaffDate6] != null ||
    //         observationBooking[Strings.obStaffStartTime6] != null ||
    //         observationBooking[Strings.obStaffEndTime6] != null ||
    //         (observationBooking[Strings.obStaffName6] != null && observationBooking[Strings.obStaffName6] != '') ||
    //         observationBooking[Strings.obStaffRmn6] != null) {
    //       setState(() {
    //         roleCount += 1;
    //       });
    //     }
    //     if (observationBooking[Strings.obStaffDate7] != null ||
    //         observationBooking[Strings.obStaffStartTime7] != null ||
    //         observationBooking[Strings.obStaffEndTime7] != null ||
    //         (observationBooking[Strings.obStaffName7] != null && observationBooking[Strings.obStaffName7] != '') ||
    //         observationBooking[Strings.obStaffRmn7] != null) {
    //       setState(() {
    //         roleCount += 1;
    //       });
    //     }
    //     if (observationBooking[Strings.obStaffDate8] != null ||
    //         observationBooking[Strings.obStaffStartTime8] != null ||
    //         observationBooking[Strings.obStaffEndTime8] != null ||
    //         (observationBooking[Strings.obStaffName8] != null && observationBooking[Strings.obStaffName8] != '') ||
    //         observationBooking[Strings.obStaffRmn8] != null) {
    //       setState(() {
    //         roleCount += 1;
    //       });
    //     }
    //     if (observationBooking[Strings.obStaffDate9] != null ||
    //         observationBooking[Strings.obStaffStartTime9] != null ||
    //         observationBooking[Strings.obStaffEndTime9] != null ||
    //         (observationBooking[Strings.obStaffName9] != null && observationBooking[Strings.obStaffName9] != '') ||
    //         observationBooking[Strings.obStaffRmn9] != null) {
    //       setState(() {
    //         roleCount += 1;
    //       });
    //     }
    //     if (observationBooking[Strings.obStaffDate10] != null ||
    //         observationBooking[Strings.obStaffStartTime10] != null ||
    //         observationBooking[Strings.obStaffEndTime10] != null ||
    //         (observationBooking[Strings.obStaffName10] != null && observationBooking[Strings.obStaffName10] != '') ||
    //         observationBooking[Strings.obStaffRmn10] != null) {
    //       setState(() {
    //         roleCount += 1;
    //       });
    //     }
    //     if (observationBooking[Strings.obStaffDate11] != null ||
    //         observationBooking[Strings.obStaffStartTime11] != null ||
    //         observationBooking[Strings.obStaffEndTime11] != null ||
    //         (observationBooking[Strings.obStaffName11] != null && observationBooking[Strings.obStaffName11] != '') ||
    //         observationBooking[Strings.obStaffRmn11] != null) {
    //       setState(() {
    //         roleCount += 1;
    //       });
    //     }
    //     if (observationBooking[Strings.obStaffDate12] != null ||
    //         observationBooking[Strings.obStaffStartTime12] != null ||
    //         observationBooking[Strings.obStaffEndTime12] != null ||
    //         (observationBooking[Strings.obStaffName12] != null && observationBooking[Strings.obStaffName12] != '') ||
    //         observationBooking[Strings.obStaffRmn12] != null) {
    //       setState(() {
    //         roleCount += 1;
    //       });
    //     }
    //     if (observationBooking[Strings.obStaffDate13] != null ||
    //         observationBooking[Strings.obStaffStartTime13] != null ||
    //         observationBooking[Strings.obStaffEndTime13] != null ||
    //         (observationBooking[Strings.obStaffName13] != null && observationBooking[Strings.obStaffName13] != '') ||
    //         observationBooking[Strings.obStaffRmn13] != null) {
    //       setState(() {
    //         roleCount += 1;
    //       });
    //     }
    //     if (observationBooking[Strings.obStaffDate14] != null ||
    //         observationBooking[Strings.obStaffStartTime14] != null ||
    //         observationBooking[Strings.obStaffEndTime14] != null ||
    //         (observationBooking[Strings.obStaffName14] != null && observationBooking[Strings.obStaffName14] != '') ||
    //         observationBooking[Strings.obStaffRmn14] != null) {
    //       setState(() {
    //         roleCount += 1;
    //       });
    //     }
    //     if (observationBooking[Strings.obStaffDate15] != null ||
    //         observationBooking[Strings.obStaffStartTime15] != null ||
    //         observationBooking[Strings.obStaffEndTime15] != null ||
    //         (observationBooking[Strings.obStaffName15] != null && observationBooking[Strings.obStaffName15] != '') ||
    //         observationBooking[Strings.obStaffRmn15] != null) {
    //       setState(() {
    //         roleCount += 1;
    //       });
    //     }
    //     if (observationBooking[Strings.obStaffDate16] != null ||
    //         observationBooking[Strings.obStaffStartTime16] != null ||
    //         observationBooking[Strings.obStaffEndTime16] != null ||
    //         (observationBooking[Strings.obStaffName16] != null && observationBooking[Strings.obStaffName16] != '') ||
    //         observationBooking[Strings.obStaffRmn16] != null) {
    //       setState(() {
    //         roleCount += 1;
    //       });
    //     }
    //     if (observationBooking[Strings.obStaffDate17] != null ||
    //         observationBooking[Strings.obStaffStartTime17] != null ||
    //         observationBooking[Strings.obStaffEndTime17] != null ||
    //         (observationBooking[Strings.obStaffName17] != null && observationBooking[Strings.obStaffName17] != '') ||
    //         observationBooking[Strings.obStaffRmn17] != null) {
    //       setState(() {
    //         roleCount += 1;
    //       });
    //     }
    //     if (observationBooking[Strings.obStaffDate18] != null ||
    //         observationBooking[Strings.obStaffStartTime18] != null ||
    //         observationBooking[Strings.obStaffEndTime18] != null ||
    //         (observationBooking[Strings.obStaffName18] != null && observationBooking[Strings.obStaffName18] != '') ||
    //         observationBooking[Strings.obStaffRmn18] != null) {
    //       setState(() {
    //         roleCount += 1;
    //       });
    //     }
    //     if (observationBooking[Strings.obStaffDate19] != null ||
    //         observationBooking[Strings.obStaffStartTime19] != null ||
    //         observationBooking[Strings.obStaffEndTime19] != null ||
    //         (observationBooking[Strings.obStaffName19] != null && observationBooking[Strings.obStaffName19] != '') ||
    //         observationBooking[Strings.obStaffRmn19] != null) {
    //       setState(() {
    //         roleCount += 1;
    //       });
    //     }
    //     if (observationBooking[Strings.obStaffDate20] != null ||
    //         observationBooking[Strings.obStaffStartTime20] != null ||
    //         observationBooking[Strings.obStaffEndTime20] != null ||
    //         (observationBooking[Strings.obStaffName20] != null && observationBooking[Strings.obStaffName20] != '') ||
    //         observationBooking[Strings.obStaffRmn20] != null) {
    //       setState(() {
    //         roleCount += 1;
    //       });
    //     }
    //     setState(() {
    //       rowCount = roleCount;
    //     });
    //     GlobalFunctions.getTemporaryValueDate(observationBooking, obStaffDate1, Strings.obStaffDate1);
    //     GlobalFunctions.getTemporaryValueDate(observationBooking, obStaffDate2, Strings.obStaffDate2);
    //     GlobalFunctions.getTemporaryValueDate(observationBooking, obStaffDate3, Strings.obStaffDate3);
    //     GlobalFunctions.getTemporaryValueDate(observationBooking, obStaffDate4, Strings.obStaffDate4);
    //     GlobalFunctions.getTemporaryValueDate(observationBooking, obStaffDate5, Strings.obStaffDate5);
    //     GlobalFunctions.getTemporaryValueDate(observationBooking, obStaffDate6, Strings.obStaffDate6);
    //     GlobalFunctions.getTemporaryValueDate(observationBooking, obStaffDate7, Strings.obStaffDate7);
    //     GlobalFunctions.getTemporaryValueDate(observationBooking, obStaffDate8, Strings.obStaffDate8);
    //     GlobalFunctions.getTemporaryValueDate(observationBooking, obStaffDate9, Strings.obStaffDate9);
    //     GlobalFunctions.getTemporaryValueDate(observationBooking, obStaffDate10, Strings.obStaffDate10);
    //     GlobalFunctions.getTemporaryValueDate(observationBooking, obStaffDate11, Strings.obStaffDate11);
    //     GlobalFunctions.getTemporaryValueDate(observationBooking, obStaffDate12, Strings.obStaffDate12);
    //     GlobalFunctions.getTemporaryValueDate(observationBooking, obStaffDate13, Strings.obStaffDate13);
    //     GlobalFunctions.getTemporaryValueDate(observationBooking, obStaffDate14, Strings.obStaffDate14);
    //     GlobalFunctions.getTemporaryValueDate(observationBooking, obStaffDate15, Strings.obStaffDate15);
    //     GlobalFunctions.getTemporaryValueDate(observationBooking, obStaffDate16, Strings.obStaffDate16);
    //     GlobalFunctions.getTemporaryValueDate(observationBooking, obStaffDate17, Strings.obStaffDate17);
    //     GlobalFunctions.getTemporaryValueDate(observationBooking, obStaffDate18, Strings.obStaffDate18);
    //     GlobalFunctions.getTemporaryValueDate(observationBooking, obStaffDate19, Strings.obStaffDate19);
    //     GlobalFunctions.getTemporaryValueDate(observationBooking, obStaffDate20, Strings.obStaffDate20);
    //     GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffStartTime1, Strings.obStaffStartTime1);
    //     GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffStartTime2, Strings.obStaffStartTime2);
    //     GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffStartTime3, Strings.obStaffStartTime3);
    //     GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffStartTime4, Strings.obStaffStartTime4);
    //     GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffStartTime5, Strings.obStaffStartTime5);
    //     GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffStartTime6, Strings.obStaffStartTime6);
    //     GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffStartTime7, Strings.obStaffStartTime7);
    //     GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffStartTime8, Strings.obStaffStartTime8);
    //     GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffStartTime9, Strings.obStaffStartTime9);
    //     GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffStartTime10, Strings.obStaffStartTime10);
    //     GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffStartTime11, Strings.obStaffStartTime11);
    //     GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffStartTime12, Strings.obStaffStartTime12);
    //     GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffStartTime13, Strings.obStaffStartTime13);
    //     GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffStartTime14, Strings.obStaffStartTime14);
    //     GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffStartTime15, Strings.obStaffStartTime15);
    //     GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffStartTime16, Strings.obStaffStartTime16);
    //     GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffStartTime17, Strings.obStaffStartTime17);
    //     GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffStartTime18, Strings.obStaffStartTime18);
    //     GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffStartTime19, Strings.obStaffStartTime19);
    //     GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffStartTime20, Strings.obStaffStartTime20);
    //     GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffEndTime1, Strings.obStaffEndTime1);
    //     GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffEndTime2, Strings.obStaffEndTime2);
    //     GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffEndTime3, Strings.obStaffEndTime3);
    //     GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffEndTime4, Strings.obStaffEndTime4);
    //     GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffEndTime5, Strings.obStaffEndTime5);
    //     GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffEndTime6, Strings.obStaffEndTime6);
    //     GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffEndTime7, Strings.obStaffEndTime7);
    //     GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffEndTime8, Strings.obStaffEndTime8);
    //     GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffEndTime9, Strings.obStaffEndTime9);
    //     GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffEndTime10, Strings.obStaffEndTime10);
    //     GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffEndTime11, Strings.obStaffEndTime11);
    //     GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffEndTime12, Strings.obStaffEndTime12);
    //     GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffEndTime13, Strings.obStaffEndTime13);
    //     GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffEndTime14, Strings.obStaffEndTime14);
    //     GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffEndTime15, Strings.obStaffEndTime15);
    //     GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffEndTime16, Strings.obStaffEndTime16);
    //     GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffEndTime17, Strings.obStaffEndTime17);
    //     GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffEndTime18, Strings.obStaffEndTime18);
    //     GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffEndTime19, Strings.obStaffEndTime19);
    //     GlobalFunctions.getTemporaryValueTime(observationBooking, obStaffEndTime20, Strings.obStaffEndTime20);
    //     GlobalFunctions.getTemporaryValue(observationBooking, obStaffName1, Strings.obStaffName1);
    //     GlobalFunctions.getTemporaryValue(observationBooking, obStaffName2, Strings.obStaffName2);
    //     GlobalFunctions.getTemporaryValue(observationBooking, obStaffName3, Strings.obStaffName3);
    //     GlobalFunctions.getTemporaryValue(observationBooking, obStaffName4, Strings.obStaffName4);
    //     GlobalFunctions.getTemporaryValue(observationBooking, obStaffName5, Strings.obStaffName5);
    //     GlobalFunctions.getTemporaryValue(observationBooking, obStaffName6, Strings.obStaffName6);
    //     GlobalFunctions.getTemporaryValue(observationBooking, obStaffName7, Strings.obStaffName7);
    //     GlobalFunctions.getTemporaryValue(observationBooking, obStaffName8, Strings.obStaffName8);
    //     GlobalFunctions.getTemporaryValue(observationBooking, obStaffName9, Strings.obStaffName9);
    //     GlobalFunctions.getTemporaryValue(observationBooking, obStaffName10, Strings.obStaffName10);
    //     GlobalFunctions.getTemporaryValue(observationBooking, obStaffName11, Strings.obStaffName11);
    //     GlobalFunctions.getTemporaryValue(observationBooking, obStaffName12, Strings.obStaffName12);
    //     GlobalFunctions.getTemporaryValue(observationBooking, obStaffName13, Strings.obStaffName13);
    //     GlobalFunctions.getTemporaryValue(observationBooking, obStaffName14, Strings.obStaffName14);
    //     GlobalFunctions.getTemporaryValue(observationBooking, obStaffName15, Strings.obStaffName15);
    //     GlobalFunctions.getTemporaryValue(observationBooking, obStaffName16, Strings.obStaffName16);
    //     GlobalFunctions.getTemporaryValue(observationBooking, obStaffName17, Strings.obStaffName17);
    //     GlobalFunctions.getTemporaryValue(observationBooking, obStaffName18, Strings.obStaffName18);
    //     GlobalFunctions.getTemporaryValue(observationBooking, obStaffName19, Strings.obStaffName19);
    //     GlobalFunctions.getTemporaryValue(observationBooking, obStaffName20, Strings.obStaffName20);
    //     if (observationBooking[Strings.obStaffRmn1] != null) {
    //       obStaffRmn1 = GlobalFunctions.decryptString(observationBooking[Strings.obStaffRmn1]);
    //     }
    //     if (observationBooking[Strings.obStaffRmn2] != null) {
    //       obStaffRmn2 = GlobalFunctions.decryptString(observationBooking[Strings.obStaffRmn2]);
    //     }
    //     if (observationBooking[Strings.obStaffRmn3] != null) {
    //       obStaffRmn3 = GlobalFunctions.decryptString(observationBooking[Strings.obStaffRmn3]);
    //     }
    //     if (observationBooking[Strings.obStaffRmn4] != null) {
    //       obStaffRmn4 = GlobalFunctions.decryptString(observationBooking[Strings.obStaffRmn4]);
    //     }
    //     if (observationBooking[Strings.obStaffRmn5] != null) {
    //       obStaffRmn5 = GlobalFunctions.decryptString(observationBooking[Strings.obStaffRmn5]);
    //     }
    //     if (observationBooking[Strings.obStaffRmn6] != null) {
    //       obStaffRmn6 = GlobalFunctions.decryptString(observationBooking[Strings.obStaffRmn6]);
    //     }
    //     if (observationBooking[Strings.obStaffRmn7] != null) {
    //       obStaffRmn7 = GlobalFunctions.decryptString(observationBooking[Strings.obStaffRmn7]);
    //     }
    //     if (observationBooking[Strings.obStaffRmn8] != null) {
    //       obStaffRmn8 = GlobalFunctions.decryptString(observationBooking[Strings.obStaffRmn8]);
    //     }
    //     if (observationBooking[Strings.obStaffRmn9] != null) {
    //       obStaffRmn9 = GlobalFunctions.decryptString(observationBooking[Strings.obStaffRmn9]);
    //     }
    //     if (observationBooking[Strings.obStaffRmn10] != null) {
    //       obStaffRmn10 = GlobalFunctions.decryptString(observationBooking[Strings.obStaffRmn10]);
    //     }
    //     if (observationBooking[Strings.obStaffRmn11] != null) {
    //       obStaffRmn11 = GlobalFunctions.decryptString(observationBooking[Strings.obStaffRmn11]);
    //     }
    //     if (observationBooking[Strings.obStaffRmn12] != null) {
    //       obStaffRmn12 = GlobalFunctions.decryptString(observationBooking[Strings.obStaffRmn12]);
    //     }
    //     if (observationBooking[Strings.obStaffRmn13] != null) {
    //       obStaffRmn13 = GlobalFunctions.decryptString(observationBooking[Strings.obStaffRmn13]);
    //     }
    //     if (observationBooking[Strings.obStaffRmn14] != null) {
    //       obStaffRmn14 = GlobalFunctions.decryptString(observationBooking[Strings.obStaffRmn14]);
    //     }
    //     if (observationBooking[Strings.obStaffRmn15] != null) {
    //       obStaffRmn15 = GlobalFunctions.decryptString(observationBooking[Strings.obStaffRmn15]);
    //     }
    //     if (observationBooking[Strings.obStaffRmn16] != null) {
    //       obStaffRmn16 = GlobalFunctions.decryptString(observationBooking[Strings.obStaffRmn16]);
    //     }
    //     if (observationBooking[Strings.obStaffRmn17] != null) {
    //       obStaffRmn17 = GlobalFunctions.decryptString(observationBooking[Strings.obStaffRmn17]);
    //     }
    //     if (observationBooking[Strings.obStaffRmn18] != null) {
    //       obStaffRmn18 = GlobalFunctions.decryptString(observationBooking[Strings.obStaffRmn18]);
    //     }
    //     if (observationBooking[Strings.obStaffRmn19] != null) {
    //       obStaffRmn19 = GlobalFunctions.decryptString(observationBooking[Strings.obStaffRmn19]);
    //     }
    //     if (observationBooking[Strings.obStaffRmn20] != null) {
    //       obStaffRmn20 = GlobalFunctions.decryptString(observationBooking[Strings.obStaffRmn20]);
    //     }
    //     GlobalFunctions.getTemporaryValue(observationBooking, obUsefulDetails, Strings.obUsefulDetails);
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
    if(rowCount == 20){
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
        rowCount -=1;
      });
    }
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
                    observationBookingModel.updateTemporaryRecord(widget.edit, value, null, widget.jobId, widget.saved, widget.savedId);

                    // _databaseHelper.updateTemporaryObservationBookingField(widget.edit,
                    //     {value : null}, user.uid, widget.jobId, widget.saved, widget.savedId);

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

                          observationBookingModel.updateTemporaryRecord(widget.edit, value, GlobalFunctions.encryptString(DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String()), widget.jobId, widget.saved, widget.savedId);


                          // _databaseHelper.updateTemporaryObservationBookingField(widget.edit,
                          //     {value : GlobalFunctions.encryptString(DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String())}, user.uid, widget.jobId, widget.saved, widget.savedId);
                        } else {

                          observationBookingModel.updateTemporaryRecord(widget.edit, value, DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String(), widget.jobId, widget.saved, widget.savedId);


                          // _databaseHelper.updateTemporaryObservationBookingField(widget.edit,
                          //     {value : DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String()}, user.uid, widget.jobId, widget.saved, widget.savedId);
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
                    observationBookingModel.updateTemporaryRecord(widget.edit, value, null, widget.jobId, widget.saved, widget.savedId);

                    // _databaseHelper.updateTemporaryObservationBookingField(widget.edit,
                    //     {value : null}, user.uid, widget.jobId, widget.saved, widget.savedId);
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
                         observationBookingModel.updateTemporaryRecord(widget.edit, value, GlobalFunctions.encryptString(DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String()), widget.jobId, widget.saved, widget.savedId);

                          // _databaseHelper.updateTemporaryObservationBookingField(widget.edit,
                          //     {value : GlobalFunctions.encryptString(DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String())}, user.uid, widget.jobId, widget.saved, widget.savedId);
                        } else {
                          observationBookingModel.updateTemporaryRecord(widget.edit, value, DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String(), widget.jobId, widget.saved, widget.savedId);

                          // _databaseHelper.updateTemporaryObservationBookingField(widget.edit,
                          //     {value : DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String()}, user.uid, widget.jobId, widget.saved, widget.savedId);
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

  Widget _buildStartDateTimeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: 'Start Date & Time',
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
                  controller: obStartDateTime,
                  onSaved: (String value) {
                    setState(() {
                      obStartDateTime.text = value;
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
                    obStartDateTime.clear();
                    observationBookingModel.updateTemporaryRecord(widget.edit, Strings.obStartDateTime, null, widget.jobId, widget.saved, widget.savedId);


                    // _databaseHelper.updateTemporaryObservationBookingField(widget.edit,
                    //     {Strings.obStartDateTime : null}, user.uid, widget.jobId, widget.saved, widget.savedId);

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
                      String dateTime = dateTimeFormat.format(newDate);
                      setState(() {
                        obStartDateTime.text = dateTime;
                      });

                      await observationBookingModel.updateTemporaryRecord(widget.edit, Strings.obStartDateTime, DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String(), widget.jobId, widget.saved, widget.savedId);

                      // await _databaseHelper.updateTemporaryObservationBookingField(widget.edit,
                      //     {Strings.obStartDateTime : DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String()}, user.uid, widget.jobId, widget.saved, widget.savedId);
                    }
                  }

                })
          ],
        ),
      ],
    );
  }

  Widget _buildMhaAssessmentCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: 'Is the patient awaiting a MHA Assessment?',
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
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: obMhaAssessmentYes,
                onChanged: (bool value) => setState(() {
                  obMhaAssessmentYes = value;
                  observationBookingModel.updateTemporaryRecord(widget.edit, Strings.obMhaAssessmentYes, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);

                  //_databaseHelper.updateTemporaryObservationBookingField(widget.edit, {Strings.obMhaAssessmentYes : GlobalFunctions.boolToTinyInt(value)}, user.uid, widget.jobId, widget.saved, widget.savedId);
                  if (obMhaAssessmentNo == true){
                    obMhaAssessmentNo = false;
                    observationBookingModel.updateTemporaryRecord(widget.edit, Strings.obMhaAssessmentNo, null, widget.jobId, widget.saved, widget.savedId);

                    //_databaseHelper.updateTemporaryObservationBookingField(widget.edit, {Strings.obMhaAssessmentNo : null}, user.uid, widget.jobId, widget.saved, widget.savedId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: obMhaAssessmentNo,
                onChanged: (bool value) => setState(() {
                  obMhaAssessmentNo = value;
                  observationBookingModel.updateTemporaryRecord(widget.edit, Strings.obMhaAssessmentNo, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);

                  //_databaseHelper.updateTemporaryObservationBookingField(widget.edit, {Strings.obMhaAssessmentNo : GlobalFunctions.boolToTinyInt(value)}, user.uid, widget.jobId, widget.saved, widget.savedId);
                  if (obMhaAssessmentYes == true){
                    obMhaAssessmentYes = false;
                    observationBookingModel.updateTemporaryRecord(widget.edit, Strings.obMhaAssessmentYes, null, widget.jobId, widget.saved, widget.savedId);


                    //_databaseHelper.updateTemporaryObservationBookingField(widget.edit, {Strings.obMhaAssessmentYes : null}, user.uid, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        )
      ],
    );

  }

  Widget _buildBedIdentifiedCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: 'Has a bed been identified?',
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
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: obBedIdentifiedYes,
                onChanged: (bool value) => setState(() {
                  obBedIdentifiedYes = value;

                  observationBookingModel.updateTemporaryRecord(widget.edit, Strings.obBedIdentifiedYes, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);

                  //_databaseHelper.updateTemporaryObservationBookingField(widget.edit, {Strings.obBedIdentifiedYes : GlobalFunctions.boolToTinyInt(value)}, user.uid, widget.jobId, widget.saved, widget.savedId);
                  if (obBedIdentifiedNo == true){
                    obBedIdentifiedNo = false;

                    observationBookingModel.updateTemporaryRecord(widget.edit, Strings.obBedIdentifiedNo, null, widget.jobId, widget.saved, widget.savedId);

                    //_databaseHelper.updateTemporaryObservationBookingField(widget.edit, {Strings.obBedIdentifiedNo : null}, user.uid, widget.jobId, widget.saved, widget.savedId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: obBedIdentifiedNo,
                onChanged: (bool value) => setState(() {
                  obBedIdentifiedNo = value;
                  observationBookingModel.updateTemporaryRecord(widget.edit, Strings.obBedIdentifiedNo, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);

                  //_databaseHelper.updateTemporaryObservationBookingField(widget.edit, {Strings.obBedIdentifiedNo : GlobalFunctions.boolToTinyInt(value)}, user.uid, widget.jobId, widget.saved, widget.savedId);
                  if (obBedIdentifiedYes == true){
                    obBedIdentifiedYes = false;

                    observationBookingModel.updateTemporaryRecord(widget.edit, Strings.obBedIdentifiedYes, null, widget.jobId, widget.saved, widget.savedId);

                    //_databaseHelper.updateTemporaryObservationBookingField(widget.edit, {Strings.obBedIdentifiedYes : null}, user.uid, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        )
      ],
    );

  }

  Widget _buildWrapDocumentationCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: 'Wrap documentation available?',
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
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: obWrapDocumentationYes,
                onChanged: (bool value) => setState(() {
                  obWrapDocumentationYes = value;
                  observationBookingModel.updateTemporaryRecord(widget.edit, Strings.obWrapDocumentationYes, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);

                  //_databaseHelper.updateTemporaryObservationBookingField(widget.edit, {Strings.obWrapDocumentationYes : GlobalFunctions.boolToTinyInt(value)}, user.uid, widget.jobId, widget.saved, widget.savedId);
                  if (obWrapDocumentationNo == true){
                    obWrapDocumentationNo = false;
                    observationBookingModel.updateTemporaryRecord(widget.edit, Strings.obWrapDocumentationNo, null, widget.jobId, widget.saved, widget.savedId);

                    //_databaseHelper.updateTemporaryObservationBookingField(widget.edit, {Strings.obWrapDocumentationNo : null}, user.uid, widget.jobId, widget.saved, widget.savedId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: obWrapDocumentationNo,
                onChanged: (bool value) => setState(() {
                  obWrapDocumentationNo = value;
                  observationBookingModel.updateTemporaryRecord(widget.edit, Strings.obWrapDocumentationNo, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);

                  //_databaseHelper.updateTemporaryObservationBookingField(widget.edit, {Strings.obWrapDocumentationNo : GlobalFunctions.boolToTinyInt(value)}, user.uid, widget.jobId, widget.saved, widget.savedId);
                  if (obWrapDocumentationYes == true){
                    obWrapDocumentationYes = false;
                    observationBookingModel.updateTemporaryRecord(widget.edit, Strings.obWrapDocumentationYes, null, widget.jobId, widget.saved, widget.savedId);

                    //_databaseHelper.updateTemporaryObservationBookingField(widget.edit, {Strings.obWrapDocumentationYes : null}, user.uid, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        )
      ],
    );

  }

  Widget _buildSpecificCarePlanCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: 'Specific Care Plan',
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
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: obSpecificCarePlanYes,
                onChanged: (bool value) => setState(() {
                  obSpecificCarePlanYes = value;
                  observationBookingModel.updateTemporaryRecord(widget.edit, Strings.obSpecificCarePlanYes, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);

                  //_databaseHelper.updateTemporaryObservationBookingField(widget.edit, {Strings.obSpecificCarePlanYes : GlobalFunctions.boolToTinyInt(value)}, user.uid, widget.jobId, widget.saved, widget.savedId);
                  if (obSpecificCarePlanNo == true){
                    obSpecificCarePlanNo = false;
                    observationBookingModel.updateTemporaryRecord(widget.edit, Strings.obSpecificCarePlanNo, null, widget.jobId, widget.saved, widget.savedId);

                    //_databaseHelper.updateTemporaryObservationBookingField(widget.edit, {Strings.obSpecificCarePlanNo : null}, user.uid, widget.jobId, widget.saved, widget.savedId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: obSpecificCarePlanNo,
                onChanged: (bool value) => setState(() {
                  obSpecificCarePlanNo = value;
                  observationBookingModel.updateTemporaryRecord(widget.edit, Strings.obSpecificCarePlanNo, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);

                  //_databaseHelper.updateTemporaryObservationBookingField(widget.edit, {Strings.obSpecificCarePlanNo : GlobalFunctions.boolToTinyInt(value)}, user.uid, widget.jobId, widget.saved, widget.savedId);
                  if (obSpecificCarePlanYes == true){
                    obSpecificCarePlanYes = false;
                    observationBookingModel.updateTemporaryRecord(widget.edit, Strings.obSpecificCarePlanYes, null, widget.jobId, widget.saved, widget.savedId);

                    //_databaseHelper.updateTemporaryObservationBookingField(widget.edit, {Strings.obSpecificCarePlanYes : null}, user.uid, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        )
      ],
    );

  }

  Widget _buildPatientWarningsCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: 'Patient warnings/markers',
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
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: obPatientWarningsYes,
                onChanged: (bool value) => setState(() {
                  obPatientWarningsYes = value;
                  observationBookingModel.updateTemporaryRecord(widget.edit, Strings.obPatientWarningsYes, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);

                  //_databaseHelper.updateTemporaryObservationBookingField(widget.edit, {Strings.obPatientWarningsYes : GlobalFunctions.boolToTinyInt(value)}, user.uid, widget.jobId, widget.saved, widget.savedId);
                  if (obPatientWarningsNo == true){
                    obPatientWarningsNo = false;
                    observationBookingModel.updateTemporaryRecord(widget.edit, Strings.obPatientWarningsNo, null, widget.jobId, widget.saved, widget.savedId);

                    //_databaseHelper.updateTemporaryObservationBookingField(widget.edit, {Strings.obPatientWarningsNo : null}, user.uid, widget.jobId, widget.saved, widget.savedId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: obPatientWarningsNo,
                onChanged: (bool value) => setState(() {
                  obPatientWarningsNo = value;
                  observationBookingModel.updateTemporaryRecord(widget.edit, Strings.obPatientWarningsNo, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);

                  //_databaseHelper.updateTemporaryObservationBookingField(widget.edit, {Strings.obPatientWarningsNo : GlobalFunctions.boolToTinyInt(value)}, user.uid, widget.jobId, widget.saved, widget.savedId);
                  if (obPatientWarningsYes == true){
                    obPatientWarningsYes = false;
                    observationBookingModel.updateTemporaryRecord(widget.edit, Strings.obPatientWarningsYes, null, widget.jobId, widget.saved, widget.savedId);

                    //_databaseHelper.updateTemporaryObservationBookingField(widget.edit, {Strings.obPatientWarningsYes : null}, user.uid, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        )
      ],
    );

  }

  Widget _buildGenderConcernsCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: 'Gender/Race/sexual Behaviour concerns',
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
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: obGenderConcernsYes,
                onChanged: (bool value) => setState(() {
                  obGenderConcernsYes = value;
                  observationBookingModel.updateTemporaryRecord(widget.edit, Strings.obGenderConcernsYes, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);

                  //_databaseHelper.updateTemporaryObservationBookingField(widget.edit, {Strings.obGenderConcernsYes : GlobalFunctions.boolToTinyInt(value)}, user.uid, widget.jobId, widget.saved, widget.savedId);
                  if (obGenderConcernsNo == true){
                    obGenderConcernsNo = false;
                    observationBookingModel.updateTemporaryRecord(widget.edit, Strings.obGenderConcernsNo, null, widget.jobId, widget.saved, widget.savedId);

                    //_databaseHelper.updateTemporaryObservationBookingField(widget.edit, {Strings.obGenderConcernsNo : null}, user.uid, widget.jobId, widget.saved, widget.savedId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: obGenderConcernsNo,
                onChanged: (bool value) => setState(() {
                  obGenderConcernsNo = value;
                  observationBookingModel.updateTemporaryRecord(widget.edit, Strings.obGenderConcernsNo, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);

                  //_databaseHelper.updateTemporaryObservationBookingField(widget.edit, {Strings.obGenderConcernsNo : GlobalFunctions.boolToTinyInt(value)}, user.uid, widget.jobId, widget.saved, widget.savedId);
                  if (obGenderConcernsYes == true){
                    obGenderConcernsYes = false;
                    observationBookingModel.updateTemporaryRecord(widget.edit, Strings.obGenderConcernsYes, null, widget.jobId, widget.saved, widget.savedId);

                    //_databaseHelper.updateTemporaryObservationBookingField(widget.edit, {Strings.obGenderConcernsYes : null}, user.uid, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        )
      ],
    );

  }

  Widget _buildSafeguardingConcernsCheckboxes() {
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
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: obSafeguardingConcernsYes,
                onChanged: (bool value) => setState(() {
                  obSafeguardingConcernsYes = value;
                  observationBookingModel.updateTemporaryRecord(widget.edit, Strings.obSafeguardingConcernsYes, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);

                  //_databaseHelper.updateTemporaryObservationBookingField(widget.edit, {Strings.obSafeguardingConcernsYes : GlobalFunctions.boolToTinyInt(value)}, user.uid, widget.jobId, widget.saved, widget.savedId);
                  if (obSafeguardingConcernsNo == true){
                    obSafeguardingConcernsNo = false;
                    observationBookingModel.updateTemporaryRecord(widget.edit, Strings.obSafeguardingConcernsNo, null, widget.jobId, widget.saved, widget.savedId);

                    //_databaseHelper.updateTemporaryObservationBookingField(widget.edit, {Strings.obSafeguardingConcernsNo : null}, user.uid, widget.jobId, widget.saved, widget.savedId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: obSafeguardingConcernsNo,
                onChanged: (bool value) => setState(() {
                  obSafeguardingConcernsNo = value;
                  observationBookingModel.updateTemporaryRecord(widget.edit, Strings.obSafeguardingConcernsNo, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);

                  //_databaseHelper.updateTemporaryObservationBookingField(widget.edit, {Strings.obSafeguardingConcernsNo : GlobalFunctions.boolToTinyInt(value)}, user.uid, widget.jobId, widget.saved, widget.savedId);
                  if (obSafeguardingConcernsYes == true){
                    obSafeguardingConcernsYes = false;
                    observationBookingModel.updateTemporaryRecord(widget.edit, Strings.obSafeguardingConcernsYes, null, widget.jobId, widget.saved, widget.savedId);

                    //_databaseHelper.updateTemporaryObservationBookingField(widget.edit, {Strings.obSafeguardingConcernsYes : null}, user.uid, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        )
      ],
    );

  }

  Widget _buildRmnDrop() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('RMN', style: TextStyle(fontSize: 16.0, color: bluePurple),),
        DropdownFormField(
          expanded: true,
          value: obRmn,
          items: obRmnDrop.toList(),
          onChanged: (val) => setState(() {
            obRmn = val;
            if(val == 'Select One'){
              observationBookingModel.updateTemporaryRecord(widget.edit,
                  Strings.obRmn, null, widget.jobId, widget.saved, widget.savedId);
            } else {
              observationBookingModel.updateTemporaryRecord(widget.edit,
                  Strings.obRmn, GlobalFunctions.encryptString(val), widget.jobId, widget.saved, widget.savedId);
            }

            FocusScope.of(context).unfocus();
          }),
          initialValue: obRmn,
        ),
        SizedBox(height: 15,),
      ],
    );
  }

  Widget _buildHcaDrop() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("HCA's", style: TextStyle(fontSize: 16.0, color: bluePurple),),
        DropdownFormField(
          expanded: true,
          value: obHca,
          items: obHcaDrop.toList(),
          onChanged: (val) => setState(() {
            obHca = val;
            if(val == 'Select One'){
              observationBookingModel.updateTemporaryRecord(widget.edit,
                  Strings.obHca, null, widget.jobId, widget.saved, widget.savedId);
            } else {
              observationBookingModel.updateTemporaryRecord(widget.edit,
                  Strings.obHca, GlobalFunctions.encryptString(val), widget.jobId, widget.saved, widget.savedId);
            }

            FocusScope.of(context).unfocus();
          }),
          initialValue: obHca,
        ),
        SizedBox(height: 15,),
      ],
    );
  }

  Widget _buildStaffRmn1Drop() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("RMN/HCA", style: TextStyle(fontSize: 16.0, color: bluePurple),),
        DropdownFormField(
          expanded: true,
          value: obStaffRmn1,
          items: obStaffRmnDrop.toList(),
          onChanged: (val) => setState(() {
            obStaffRmn1 = val;
            if(val == 'Select One'){
              observationBookingModel.updateTemporaryRecord(widget.edit,
                  Strings.obStaffRmn1, null, widget.jobId, widget.saved, widget.savedId);
            } else {
              observationBookingModel.updateTemporaryRecord(widget.edit,
                  Strings.obStaffRmn1, GlobalFunctions.encryptString(val), widget.jobId, widget.saved, widget.savedId);
            }

            FocusScope.of(context).unfocus();
          }),
          initialValue: obStaffRmn1,
        ),
        SizedBox(height: 15,),
      ],
    );
  }
  Widget _buildStaffRmn2Drop() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("RMN/HCA", style: TextStyle(fontSize: 16.0, color: bluePurple),),
        DropdownFormField(
          expanded: true,
          value: obStaffRmn2,
          items: obStaffRmnDrop.toList(),
          onChanged: (val) => setState(() {
            obStaffRmn2 = val;
            if(val == 'Select One'){
              observationBookingModel.updateTemporaryRecord(widget.edit,
                  Strings.obStaffRmn2, null, widget.jobId, widget.saved, widget.savedId);
            } else {
              observationBookingModel.updateTemporaryRecord(widget.edit,
                  Strings.obStaffRmn2, GlobalFunctions.encryptString(val), widget.jobId, widget.saved, widget.savedId);
            }

            FocusScope.of(context).unfocus();
          }),
          initialValue: obStaffRmn2,
        ),
        SizedBox(height: 15,),
      ],
    );
  }
  Widget _buildStaffRmn3Drop() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("RMN/HCA", style: TextStyle(fontSize: 16.0, color: bluePurple),),
        DropdownFormField(
          expanded: true,
          value: obStaffRmn3,
          items: obStaffRmnDrop.toList(),
          onChanged: (val) => setState(() {
            obStaffRmn3 = val;
            if(val == 'Select One'){
              observationBookingModel.updateTemporaryRecord(widget.edit,
                  Strings.obStaffRmn3, null, widget.jobId, widget.saved, widget.savedId);
            } else {
              observationBookingModel.updateTemporaryRecord(widget.edit,
                  Strings.obStaffRmn3, GlobalFunctions.encryptString(val), widget.jobId, widget.saved, widget.savedId);
            }

            FocusScope.of(context).unfocus();
          }),
          initialValue: obStaffRmn3,
        ),
        SizedBox(height: 15,),
      ],
    );
  }
  Widget _buildStaffRmn4Drop() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("RMN/HCA", style: TextStyle(fontSize: 16.0, color: bluePurple),),
        DropdownFormField(
          expanded: true,
          value: obStaffRmn4,
          items: obStaffRmnDrop.toList(),
          onChanged: (val) => setState(() {
            obStaffRmn4 = val;
            if(val == 'Select One'){
              observationBookingModel.updateTemporaryRecord(widget.edit,
                  Strings.obStaffRmn4, null, widget.jobId, widget.saved, widget.savedId);
            } else {
              observationBookingModel.updateTemporaryRecord(widget.edit,
                  Strings.obStaffRmn4, GlobalFunctions.encryptString(val), widget.jobId, widget.saved, widget.savedId);
            }

            FocusScope.of(context).unfocus();
          }),
          initialValue: obStaffRmn4,
        ),
        SizedBox(height: 15,),
      ],
    );
  }
  Widget _buildStaffRmn5Drop() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("RMN/HCA", style: TextStyle(fontSize: 16.0, color: bluePurple),),
        DropdownFormField(
          expanded: true,
          value: obStaffRmn5,
          items: obStaffRmnDrop.toList(),
          onChanged: (val) => setState(() {
            obStaffRmn5 = val;
            if(val == 'Select One'){
              observationBookingModel.updateTemporaryRecord(widget.edit,
                  Strings.obStaffRmn5, null, widget.jobId, widget.saved, widget.savedId);
            } else {
              observationBookingModel.updateTemporaryRecord(widget.edit,
                  Strings.obStaffRmn5, GlobalFunctions.encryptString(val), widget.jobId, widget.saved, widget.savedId);
            }

            FocusScope.of(context).unfocus();
          }),
          initialValue: obStaffRmn5,
        ),
        SizedBox(height: 15,),
      ],
    );
  }
  Widget _buildStaffRmn6Drop() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("RMN/HCA", style: TextStyle(fontSize: 16.0, color: bluePurple),),
        DropdownFormField(
          expanded: true,
          value: obStaffRmn6,
          items: obStaffRmnDrop.toList(),
          onChanged: (val) => setState(() {
            obStaffRmn6 = val;
            if(val == 'Select One'){
              observationBookingModel.updateTemporaryRecord(widget.edit,
                  Strings.obStaffRmn6, null, widget.jobId, widget.saved, widget.savedId);
            } else {
              observationBookingModel.updateTemporaryRecord(widget.edit,
                  Strings.obStaffRmn6, GlobalFunctions.encryptString(val), widget.jobId, widget.saved, widget.savedId);
            }

            FocusScope.of(context).unfocus();
          }),
          initialValue: obStaffRmn6,
        ),
        SizedBox(height: 15,),
      ],
    );
  }
  Widget _buildStaffRmn7Drop() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("RMN/HCA", style: TextStyle(fontSize: 16.0, color: bluePurple),),
        DropdownFormField(
          expanded: true,
          value: obStaffRmn7,
          items: obStaffRmnDrop.toList(),
          onChanged: (val) => setState(() {
            obStaffRmn7 = val;
            if(val == 'Select One'){
              observationBookingModel.updateTemporaryRecord(widget.edit,
                  Strings.obStaffRmn7, null, widget.jobId, widget.saved, widget.savedId);
            } else {
              observationBookingModel.updateTemporaryRecord(widget.edit,
                  Strings.obStaffRmn7, GlobalFunctions.encryptString(val), widget.jobId, widget.saved, widget.savedId);
            }

            FocusScope.of(context).unfocus();
          }),
          initialValue: obStaffRmn7,
        ),
        SizedBox(height: 15,),
      ],
    );
  }
  Widget _buildStaffRmn8Drop() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("RMN/HCA", style: TextStyle(fontSize: 16.0, color: bluePurple),),
        DropdownFormField(
          expanded: true,
          value: obStaffRmn8,
          items: obStaffRmnDrop.toList(),
          onChanged: (val) => setState(() {
            obStaffRmn8 = val;
            if(val == 'Select One'){
              observationBookingModel.updateTemporaryRecord(widget.edit,
                  Strings.obStaffRmn8, null, widget.jobId, widget.saved, widget.savedId);
            } else {
              observationBookingModel.updateTemporaryRecord(widget.edit,
                  Strings.obStaffRmn8, GlobalFunctions.encryptString(val), widget.jobId, widget.saved, widget.savedId);
            }

            FocusScope.of(context).unfocus();
          }),
          initialValue: obStaffRmn8,
        ),
        SizedBox(height: 15,),
      ],
    );
  }
  Widget _buildStaffRmn9Drop() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("RMN/HCA", style: TextStyle(fontSize: 16.0, color: bluePurple),),
        DropdownFormField(
          expanded: true,
          value: obStaffRmn9,
          items: obStaffRmnDrop.toList(),
          onChanged: (val) => setState(() {
            obStaffRmn9 = val;
            if(val == 'Select One'){
              observationBookingModel.updateTemporaryRecord(widget.edit,
                  Strings.obStaffRmn9, null, widget.jobId, widget.saved, widget.savedId);
            } else {
              observationBookingModel.updateTemporaryRecord(widget.edit,
                  Strings.obStaffRmn9, GlobalFunctions.encryptString(val), widget.jobId, widget.saved, widget.savedId);
            }

            FocusScope.of(context).unfocus();
          }),
          initialValue: obStaffRmn9,
        ),
        SizedBox(height: 15,),
      ],
    );
  }
  Widget _buildStaffRmn10Drop() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("RMN/HCA", style: TextStyle(fontSize: 16.0, color: bluePurple),),
        DropdownFormField(
          expanded: true,
          value: obStaffRmn10,
          items: obStaffRmnDrop.toList(),
          onChanged: (val) => setState(() {
            obStaffRmn10 = val;
            if(val == 'Select One'){
              observationBookingModel.updateTemporaryRecord(widget.edit,
                  Strings.obStaffRmn10, null, widget.jobId, widget.saved, widget.savedId);
            } else {
              observationBookingModel.updateTemporaryRecord(widget.edit,
                  Strings.obStaffRmn10, GlobalFunctions.encryptString(val), widget.jobId, widget.saved, widget.savedId);
            }

            FocusScope.of(context).unfocus();
          }),
          initialValue: obStaffRmn10,
        ),
        SizedBox(height: 15,),
      ],
    );
  }
  Widget _buildStaffRmn11Drop() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("RMN/HCA", style: TextStyle(fontSize: 16.0, color: bluePurple),),
        DropdownFormField(
          expanded: true,
          value: obStaffRmn11,
          items: obStaffRmnDrop.toList(),
          onChanged: (val) => setState(() {
            obStaffRmn11 = val;
            if(val == 'Select One'){
              observationBookingModel.updateTemporaryRecord(widget.edit,
                  Strings.obStaffRmn11, null, widget.jobId, widget.saved, widget.savedId);
            } else {
              observationBookingModel.updateTemporaryRecord(widget.edit,
                  Strings.obStaffRmn11, GlobalFunctions.encryptString(val), widget.jobId, widget.saved, widget.savedId);
            }

            FocusScope.of(context).unfocus();
          }),
          initialValue: obStaffRmn11,
        ),
        SizedBox(height: 15,),
      ],
    );
  }
  Widget _buildStaffRmn12Drop() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("RMN/HCA", style: TextStyle(fontSize: 16.0, color: bluePurple),),
        DropdownFormField(
          expanded: true,
          value: obStaffRmn12,
          items: obStaffRmnDrop.toList(),
          onChanged: (val) => setState(() {
            obStaffRmn12 = val;
            if(val == 'Select One'){
              observationBookingModel.updateTemporaryRecord(widget.edit,
                  Strings.obStaffRmn12, null, widget.jobId, widget.saved, widget.savedId);
            } else {
              observationBookingModel.updateTemporaryRecord(widget.edit,
                  Strings.obStaffRmn12, GlobalFunctions.encryptString(val), widget.jobId, widget.saved, widget.savedId);
            }

            FocusScope.of(context).unfocus();
          }),
          initialValue: obStaffRmn12,
        ),
        SizedBox(height: 15,),
      ],
    );
  }
  Widget _buildStaffRmn13Drop() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("RMN/HCA", style: TextStyle(fontSize: 16.0, color: bluePurple),),
        DropdownFormField(
          expanded: true,
          value: obStaffRmn13,
          items: obStaffRmnDrop.toList(),
          onChanged: (val) => setState(() {
            obStaffRmn13 = val;
            if(val == 'Select One'){
              observationBookingModel.updateTemporaryRecord(widget.edit,
                  Strings.obStaffRmn13, null, widget.jobId, widget.saved, widget.savedId);
            } else {
              observationBookingModel.updateTemporaryRecord(widget.edit,
                  Strings.obStaffRmn13, GlobalFunctions.encryptString(val), widget.jobId, widget.saved, widget.savedId);
            }

            FocusScope.of(context).unfocus();
          }),
          initialValue: obStaffRmn13,
        ),
        SizedBox(height: 15,),
      ],
    );
  }
  Widget _buildStaffRmn14Drop() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("RMN/HCA", style: TextStyle(fontSize: 16.0, color: bluePurple),),
        DropdownFormField(
          expanded: true,
          value: obStaffRmn14,
          items: obStaffRmnDrop.toList(),
          onChanged: (val) => setState(() {
            obStaffRmn14 = val;
            if(val == 'Select One'){
              observationBookingModel.updateTemporaryRecord(widget.edit,
                  Strings.obStaffRmn14, null, widget.jobId, widget.saved, widget.savedId);
            } else {
              observationBookingModel.updateTemporaryRecord(widget.edit,
                  Strings.obStaffRmn14, GlobalFunctions.encryptString(val), widget.jobId, widget.saved, widget.savedId);
            }

            FocusScope.of(context).unfocus();
          }),
          initialValue: obStaffRmn14,
        ),
        SizedBox(height: 15,),
      ],
    );
  }
  Widget _buildStaffRmn15Drop() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("RMN/HCA", style: TextStyle(fontSize: 16.0, color: bluePurple),),
        DropdownFormField(
          expanded: true,
          value: obStaffRmn15,
          items: obStaffRmnDrop.toList(),
          onChanged: (val) => setState(() {
            obStaffRmn15 = val;
            if(val == 'Select One'){
              observationBookingModel.updateTemporaryRecord(widget.edit,
                  Strings.obStaffRmn15, null, widget.jobId, widget.saved, widget.savedId);
            } else {
              observationBookingModel.updateTemporaryRecord(widget.edit,
                  Strings.obStaffRmn15, GlobalFunctions.encryptString(val), widget.jobId, widget.saved, widget.savedId);
            }

            FocusScope.of(context).unfocus();
          }),
          initialValue: obStaffRmn15,
        ),
        SizedBox(height: 15,),
      ],
    );
  }
  Widget _buildStaffRmn16Drop() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("RMN/HCA", style: TextStyle(fontSize: 16.0, color: bluePurple),),
        DropdownFormField(
          expanded: true,
          value: obStaffRmn16,
          items: obStaffRmnDrop.toList(),
          onChanged: (val) => setState(() {
            obStaffRmn16 = val;
            if(val == 'Select One'){
              observationBookingModel.updateTemporaryRecord(widget.edit,
                  Strings.obStaffRmn16, null, widget.jobId, widget.saved, widget.savedId);
            } else {
              observationBookingModel.updateTemporaryRecord(widget.edit,
                  Strings.obStaffRmn16, GlobalFunctions.encryptString(val), widget.jobId, widget.saved, widget.savedId);
            }

            FocusScope.of(context).unfocus();
          }),
          initialValue: obStaffRmn16,
        ),
        SizedBox(height: 15,),
      ],
    );
  }
  Widget _buildStaffRmn17Drop() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("RMN/HCA", style: TextStyle(fontSize: 16.0, color: bluePurple),),
        DropdownFormField(
          expanded: true,
          value: obStaffRmn17,
          items: obStaffRmnDrop.toList(),
          onChanged: (val) => setState(() {
            obStaffRmn17 = val;
            if(val == 'Select One'){
              observationBookingModel.updateTemporaryRecord(widget.edit,
                  Strings.obStaffRmn17, null, widget.jobId, widget.saved, widget.savedId);
            } else {
              observationBookingModel.updateTemporaryRecord(widget.edit,
                  Strings.obStaffRmn17, GlobalFunctions.encryptString(val), widget.jobId, widget.saved, widget.savedId);
            }

            FocusScope.of(context).unfocus();
          }),
          initialValue: obStaffRmn17,
        ),
        SizedBox(height: 15,),
      ],
    );
  }
  Widget _buildStaffRmn18Drop() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("RMN/HCA", style: TextStyle(fontSize: 16.0, color: bluePurple),),
        DropdownFormField(
          expanded: true,
          value: obStaffRmn18,
          items: obStaffRmnDrop.toList(),
          onChanged: (val) => setState(() {
            obStaffRmn18 = val;
            if(val == 'Select One'){
              observationBookingModel.updateTemporaryRecord(widget.edit,
                  Strings.obStaffRmn18, null, widget.jobId, widget.saved, widget.savedId);
            } else {
              observationBookingModel.updateTemporaryRecord(widget.edit,
                  Strings.obStaffRmn18, GlobalFunctions.encryptString(val), widget.jobId, widget.saved, widget.savedId);
            }

            FocusScope.of(context).unfocus();
          }),
          initialValue: obStaffRmn18,
        ),
        SizedBox(height: 15,),
      ],
    );
  }
  Widget _buildStaffRmn19Drop() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("RMN/HCA", style: TextStyle(fontSize: 16.0, color: bluePurple),),
        DropdownFormField(
          expanded: true,
          value: obStaffRmn19,
          items: obStaffRmnDrop.toList(),
          onChanged: (val) => setState(() {
            obStaffRmn19 = val;
            if(val == 'Select One'){
              observationBookingModel.updateTemporaryRecord(widget.edit,
                  Strings.obStaffRmn19, null, widget.jobId, widget.saved, widget.savedId);
            } else {
              observationBookingModel.updateTemporaryRecord(widget.edit,
                  Strings.obStaffRmn19, GlobalFunctions.encryptString(val), widget.jobId, widget.saved, widget.savedId);
            }

            FocusScope.of(context).unfocus();
          }),
          initialValue: obStaffRmn19,
        ),
        SizedBox(height: 15,),
      ],
    );
  }
  Widget _buildStaffRmn20Drop() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("RMN/HCA", style: TextStyle(fontSize: 16.0, color: bluePurple),),
        DropdownFormField(
          expanded: true,
          value: obStaffRmn20,
          items: obStaffRmnDrop.toList(),
          onChanged: (val) => setState(() {
            obStaffRmn20 = val;
            if(val == 'Select One'){
              observationBookingModel.updateTemporaryRecord(widget.edit,
                  Strings.obStaffRmn20, null, widget.jobId, widget.saved, widget.savedId);
            } else {
              observationBookingModel.updateTemporaryRecord(widget.edit,
                  Strings.obStaffRmn20, GlobalFunctions.encryptString(val), widget.jobId, widget.saved, widget.savedId);
            }

            FocusScope.of(context).unfocus();
          }),
          initialValue: obStaffRmn20,
        ),
        SizedBox(height: 15,),
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
              child: Center(child: Text("Reset Observation Booking", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),),
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
                  context.read<ObservationBookingModel>().resetTemporaryRecord(widget.jobId, widget.saved, widget.savedId);
                  //context.read<ObservationBookingModel>().resetTemporaryObservationBooking(widget.jobId, widget.saved, widget.savedId);
                  FocusScope.of(context).requestFocus(new FocusNode());
                  setState(() {
                    jobRef.clear();
                    obRequestedBy.clear();
                    obJobTitle.clear();
                    obJobContact.clear();
                    obJobAuthorisingManager.clear();
                    obJobDate.clear();
                    obJobTime.clear();
                    obBookingCoordinator.clear();
                    obPatientLocation.clear();
                    obPostcode.clear();
                    obLocationTel.clear();
                    obInvoiceDetails.clear();
                    obCostCode.clear();
                    obPurchaseOrder.clear();
                    obStartDateTime.clear();
                    obMhaAssessmentYes = false;
                    obMhaAssessmentNo = false;
                    obBedIdentifiedYes = false;
                    obBedIdentifiedNo = false;
                    obWrapDocumentationYes = false;
                    obWrapDocumentationNo = false;
                    obShiftRequired.clear();
                    obPatientName.clear();
                    obLegalStatus.clear();
                    obDateOfBirth.clear();
                    obNhsNumber.clear();
                    obGender.clear();
                    obEthnicity.clear();
                    obCovidStatus.clear();
                    obRmn = 'Select One';
                    obHca = 'Select One';
                    obHca1.clear();
                    obHca2.clear();
                    obHca3.clear();
                    obHca4.clear();
                    obHca5.clear();
                    obCurrentPresentation.clear();
                    obSpecificCarePlanYes = false;
                    obSpecificCarePlanNo = false;
                    obSpecificCarePlan.clear();
                    obPatientWarningsYes = false;
                    obPatientWarningsNo = false;
                    obPatientWarnings.clear();
                    obPresentingRisks.clear();
                    obPreviousRisks.clear();
                    obGenderConcernsYes = false;
                    obGenderConcernsNo = false;
                    obGenderConcerns.clear();
                    obSafeguardingConcernsYes = false;
                    obSafeguardingConcernsNo = false;
                    obSafeguardingConcerns.clear();
                    obTimeDue.clear();
                    obStaffDate1.clear();
                    obStaffDate2.clear();
                    obStaffDate3.clear();
                    obStaffDate4.clear();
                    obStaffDate5.clear();
                    obStaffDate6.clear();
                    obStaffDate7.clear();
                    obStaffDate8.clear();
                    obStaffDate9.clear();
                    obStaffDate10.clear();
                    obStaffDate11.clear();
                    obStaffDate12.clear();
                    obStaffDate13.clear();
                    obStaffDate14.clear();
                    obStaffDate15.clear();
                    obStaffDate16.clear();
                    obStaffDate17.clear();
                    obStaffDate18.clear();
                    obStaffDate19.clear();
                    obStaffDate20.clear();
                    obStaffStartTime1.clear();
                    obStaffStartTime2.clear();
                    obStaffStartTime3.clear();
                    obStaffStartTime4.clear();
                    obStaffStartTime5.clear();
                    obStaffStartTime6.clear();
                    obStaffStartTime7.clear();
                    obStaffStartTime8.clear();
                    obStaffStartTime9.clear();
                    obStaffStartTime10.clear();
                    obStaffStartTime11.clear();
                    obStaffStartTime12.clear();
                    obStaffStartTime13.clear();
                    obStaffStartTime14.clear();
                    obStaffStartTime15.clear();
                    obStaffStartTime16.clear();
                    obStaffStartTime17.clear();
                    obStaffStartTime18.clear();
                    obStaffStartTime19.clear();
                    obStaffStartTime20.clear();
                    obStaffEndTime1.clear();
                    obStaffEndTime2.clear();
                    obStaffEndTime3.clear();
                    obStaffEndTime4.clear();
                    obStaffEndTime5.clear();
                    obStaffEndTime6.clear();
                    obStaffEndTime7.clear();
                    obStaffEndTime8.clear();
                    obStaffEndTime9.clear();
                    obStaffEndTime10.clear();
                    obStaffEndTime11.clear();
                    obStaffEndTime12.clear();
                    obStaffEndTime13.clear();
                    obStaffEndTime14.clear();
                    obStaffEndTime15.clear();
                    obStaffEndTime16.clear();
                    obStaffEndTime17.clear();
                    obStaffEndTime18.clear();
                    obStaffEndTime19.clear();
                    obStaffEndTime20.clear();
                    obStaffName1.clear();
                    obStaffName2.clear();
                    obStaffName3.clear();
                    obStaffName4.clear();
                    obStaffName5.clear();
                    obStaffName6.clear();
                    obStaffName7.clear();
                    obStaffName8.clear();
                    obStaffName9.clear();
                    obStaffName10.clear();
                    obStaffName11.clear();
                    obStaffName12.clear();
                    obStaffName13.clear();
                    obStaffName14.clear();
                    obStaffName15.clear();
                    obStaffName16.clear();
                    obStaffName17.clear();
                    obStaffName18.clear();
                    obStaffName19.clear();
                    obStaffName20.clear();
                    obStaffRmn1 = 'Select One';
                    obStaffRmn2 = 'Select One';
                    obStaffRmn3 = 'Select One';
                    obStaffRmn4 = 'Select One';
                    obStaffRmn5 = 'Select One';
                    obStaffRmn6 = 'Select One';
                    obStaffRmn7 = 'Select One';
                    obStaffRmn8 = 'Select One';
                    obStaffRmn9 = 'Select One';
                    obStaffRmn10 = 'Select One';
                    obStaffRmn11 = 'Select One';
                    obStaffRmn12 = 'Select One';
                    obStaffRmn13 = 'Select One';
                    obStaffRmn14 = 'Select One';
                    obStaffRmn15 = 'Select One';
                    obStaffRmn16 = 'Select One';
                    obStaffRmn17 = 'Select One';
                    obStaffRmn18 = 'Select One';
                    obStaffRmn19 = 'Select One';
                    obStaffRmn20 = 'Select One';
                    obUsefulDetails.clear();
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

  void _saveForLater() async {
    FocusScope.of(context).unfocus();

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
                borderRadius: BorderRadius.only(topLeft: Radius.circular(32),
                    topRight: Radius.circular(32)),
              ),
              child: Center(child: Text("Save for later", style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),),),
            ),
            content: Text(
                'This form will be moved to your saved list, do you wish to proceed?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                  Navigator.of(context).pop(false);
                },
                child: Text(
                  'No',
                  style: TextStyle(
                      color: blueDesign, fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(true);
                },
                child: Text(
                  'Yes',
                  style: TextStyle(
                      color: blueDesign, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        });


    if (submitForm) {
      bool success = await context.read<ObservationBookingModel>().saveForLater(
          widget.jobId, widget.saved, widget.savedId);
      FocusScope.of(context).requestFocus(new FocusNode());


      if (success) {
        setState(() {
          jobRef.clear();
          obRequestedBy.clear();
          obJobTitle.clear();
          obJobContact.clear();
          obJobAuthorisingManager.clear();
          obJobDate.clear();
          obJobTime.clear();
          obBookingCoordinator.clear();
          obPatientLocation.clear();
          obPostcode.clear();
          obLocationTel.clear();
          obInvoiceDetails.clear();
          obCostCode.clear();
          obPurchaseOrder.clear();
          obStartDateTime.clear();
          obMhaAssessmentYes = false;
          obMhaAssessmentNo = false;
          obBedIdentifiedYes = false;
          obBedIdentifiedNo = false;
          obWrapDocumentationYes = false;
          obWrapDocumentationNo = false;
          obShiftRequired.clear();
          obPatientName.clear();
          obLegalStatus.clear();
          obDateOfBirth.clear();
          obNhsNumber.clear();
          obGender.clear();
          obEthnicity.clear();
          obCovidStatus.clear();
          obRmn = 'Select One';
          obHca = 'Select One';
          obHca1.clear();
          obHca2.clear();
          obHca3.clear();
          obHca4.clear();
          obHca5.clear();
          obCurrentPresentation.clear();
          obSpecificCarePlanYes = false;
          obSpecificCarePlanNo = false;
          obSpecificCarePlan.clear();
          obPatientWarningsYes = false;
          obPatientWarningsNo = false;
          obPatientWarnings.clear();
          obPresentingRisks.clear();
          obPreviousRisks.clear();
          obGenderConcernsYes = false;
          obGenderConcernsNo = false;
          obGenderConcerns.clear();
          obSafeguardingConcernsYes = false;
          obSafeguardingConcernsNo = false;
          obSafeguardingConcerns.clear();
          obTimeDue.clear();
          obStaffDate1.clear();
          obStaffDate2.clear();
          obStaffDate3.clear();
          obStaffDate4.clear();
          obStaffDate5.clear();
          obStaffDate6.clear();
          obStaffDate7.clear();
          obStaffDate8.clear();
          obStaffDate9.clear();
          obStaffDate10.clear();
          obStaffDate11.clear();
          obStaffDate12.clear();
          obStaffDate13.clear();
          obStaffDate14.clear();
          obStaffDate15.clear();
          obStaffDate16.clear();
          obStaffDate17.clear();
          obStaffDate18.clear();
          obStaffDate19.clear();
          obStaffDate20.clear();
          obStaffStartTime1.clear();
          obStaffStartTime2.clear();
          obStaffStartTime3.clear();
          obStaffStartTime4.clear();
          obStaffStartTime5.clear();
          obStaffStartTime6.clear();
          obStaffStartTime7.clear();
          obStaffStartTime8.clear();
          obStaffStartTime9.clear();
          obStaffStartTime10.clear();
          obStaffStartTime11.clear();
          obStaffStartTime12.clear();
          obStaffStartTime13.clear();
          obStaffStartTime14.clear();
          obStaffStartTime15.clear();
          obStaffStartTime16.clear();
          obStaffStartTime17.clear();
          obStaffStartTime18.clear();
          obStaffStartTime19.clear();
          obStaffStartTime20.clear();
          obStaffEndTime1.clear();
          obStaffEndTime2.clear();
          obStaffEndTime3.clear();
          obStaffEndTime4.clear();
          obStaffEndTime5.clear();
          obStaffEndTime6.clear();
          obStaffEndTime7.clear();
          obStaffEndTime8.clear();
          obStaffEndTime9.clear();
          obStaffEndTime10.clear();
          obStaffEndTime11.clear();
          obStaffEndTime12.clear();
          obStaffEndTime13.clear();
          obStaffEndTime14.clear();
          obStaffEndTime15.clear();
          obStaffEndTime16.clear();
          obStaffEndTime17.clear();
          obStaffEndTime18.clear();
          obStaffEndTime19.clear();
          obStaffEndTime20.clear();
          obStaffName1.clear();
          obStaffName2.clear();
          obStaffName3.clear();
          obStaffName4.clear();
          obStaffName5.clear();
          obStaffName6.clear();
          obStaffName7.clear();
          obStaffName8.clear();
          obStaffName9.clear();
          obStaffName10.clear();
          obStaffName11.clear();
          obStaffName12.clear();
          obStaffName13.clear();
          obStaffName14.clear();
          obStaffName15.clear();
          obStaffName16.clear();
          obStaffName17.clear();
          obStaffName18.clear();
          obStaffName19.clear();
          obStaffName20.clear();
          obStaffRmn1 = 'Select One';
          obStaffRmn2 = 'Select One';
          obStaffRmn3 = 'Select One';
          obStaffRmn4 = 'Select One';
          obStaffRmn5 = 'Select One';
          obStaffRmn6 = 'Select One';
          obStaffRmn7 = 'Select One';
          obStaffRmn8 = 'Select One';
          obStaffRmn9 = 'Select One';
          obStaffRmn10 = 'Select One';
          obStaffRmn11 = 'Select One';
          obStaffRmn12 = 'Select One';
          obStaffRmn13 = 'Select One';
          obStaffRmn14 = 'Select One';
          obStaffRmn15 = 'Select One';
          obStaffRmn16 = 'Select One';
          obStaffRmn17 = 'Select One';
          obStaffRmn18 = 'Select One';
          obStaffRmn19 = 'Select One';
          obStaffRmn20 = 'Select One';
          obUsefulDetails.clear();
          FocusScope.of(context).requestFocus(new FocusNode());
        });
      }
    }
  }

  void _submitForm() async {
    FocusScope.of(context).unfocus();

    bool continueSubmit = await observationBookingModel.validateObservationBooking(widget.jobId, widget.edit, widget.saved, widget.savedId);


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
                child: Center(child: Text("Submit Observation Booking", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),),
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
          success = await context.read<ObservationBookingModel>().editObservationBooking(widget.jobId);
          FocusScope.of(context).requestFocus(new FocusNode());

        } else {
          success = await context.read<ObservationBookingModel>().submitObservationBooking(widget.jobId, widget.edit, widget.saved, widget.savedId);
          FocusScope.of(context).requestFocus(new FocusNode());
        }

        if(success){
          setState(() {
            jobRef.clear();
            obRequestedBy.clear();
            obJobTitle.clear();
            obJobContact.clear();
            obJobAuthorisingManager.clear();
            obJobDate.clear();
            obJobTime.clear();
            obBookingCoordinator.clear();
            obPatientLocation.clear();
            obPostcode.clear();
            obLocationTel.clear();
            obInvoiceDetails.clear();
            obCostCode.clear();
            obPurchaseOrder.clear();
            obStartDateTime.clear();
            obMhaAssessmentYes = false;
            obMhaAssessmentNo = false;
            obBedIdentifiedYes = false;
            obBedIdentifiedNo = false;
            obWrapDocumentationYes = false;
            obWrapDocumentationNo = false;
            obShiftRequired.clear();
            obPatientName.clear();
            obLegalStatus.clear();
            obDateOfBirth.clear();
            obNhsNumber.clear();
            obGender.clear();
            obEthnicity.clear();
            obCovidStatus.clear();
            obRmn = 'Select One';
            obHca = 'Select One';
            obHca1.clear();
            obHca2.clear();
            obHca3.clear();
            obHca4.clear();
            obHca5.clear();
            obCurrentPresentation.clear();
            obSpecificCarePlanYes = false;
            obSpecificCarePlanNo = false;
            obSpecificCarePlan.clear();
            obPatientWarningsYes = false;
            obPatientWarningsNo = false;
            obPatientWarnings.clear();
            obPresentingRisks.clear();
            obPreviousRisks.clear();
            obGenderConcernsYes = false;
            obGenderConcernsNo = false;
            obGenderConcerns.clear();
            obSafeguardingConcernsYes = false;
            obSafeguardingConcernsNo = false;
            obSafeguardingConcerns.clear();
            obTimeDue.clear();
            obStaffDate1.clear();
            obStaffDate2.clear();
            obStaffDate3.clear();
            obStaffDate4.clear();
            obStaffDate5.clear();
            obStaffDate6.clear();
            obStaffDate7.clear();
            obStaffDate8.clear();
            obStaffDate9.clear();
            obStaffDate10.clear();
            obStaffDate11.clear();
            obStaffDate12.clear();
            obStaffDate13.clear();
            obStaffDate14.clear();
            obStaffDate15.clear();
            obStaffDate16.clear();
            obStaffDate17.clear();
            obStaffDate18.clear();
            obStaffDate19.clear();
            obStaffDate20.clear();
            obStaffStartTime1.clear();
            obStaffStartTime2.clear();
            obStaffStartTime3.clear();
            obStaffStartTime4.clear();
            obStaffStartTime5.clear();
            obStaffStartTime6.clear();
            obStaffStartTime7.clear();
            obStaffStartTime8.clear();
            obStaffStartTime9.clear();
            obStaffStartTime10.clear();
            obStaffStartTime11.clear();
            obStaffStartTime12.clear();
            obStaffStartTime13.clear();
            obStaffStartTime14.clear();
            obStaffStartTime15.clear();
            obStaffStartTime16.clear();
            obStaffStartTime17.clear();
            obStaffStartTime18.clear();
            obStaffStartTime19.clear();
            obStaffStartTime20.clear();
            obStaffEndTime1.clear();
            obStaffEndTime2.clear();
            obStaffEndTime3.clear();
            obStaffEndTime4.clear();
            obStaffEndTime5.clear();
            obStaffEndTime6.clear();
            obStaffEndTime7.clear();
            obStaffEndTime8.clear();
            obStaffEndTime9.clear();
            obStaffEndTime10.clear();
            obStaffEndTime11.clear();
            obStaffEndTime12.clear();
            obStaffEndTime13.clear();
            obStaffEndTime14.clear();
            obStaffEndTime15.clear();
            obStaffEndTime16.clear();
            obStaffEndTime17.clear();
            obStaffEndTime18.clear();
            obStaffEndTime19.clear();
            obStaffEndTime20.clear();
            obStaffName1.clear();
            obStaffName2.clear();
            obStaffName3.clear();
            obStaffName4.clear();
            obStaffName5.clear();
            obStaffName6.clear();
            obStaffName7.clear();
            obStaffName8.clear();
            obStaffName9.clear();
            obStaffName10.clear();
            obStaffName11.clear();
            obStaffName12.clear();
            obStaffName13.clear();
            obStaffName14.clear();
            obStaffName15.clear();
            obStaffName16.clear();
            obStaffName17.clear();
            obStaffName18.clear();
            obStaffName19.clear();
            obStaffName20.clear();
            obStaffRmn1 = 'Select One';
            obStaffRmn2 = 'Select One';
            obStaffRmn3 = 'Select One';
            obStaffRmn4 = 'Select One';
            obStaffRmn5 = 'Select One';
            obStaffRmn6 = 'Select One';
            obStaffRmn7 = 'Select One';
            obStaffRmn8 = 'Select One';
            obStaffRmn9 = 'Select One';
            obStaffRmn10 = 'Select One';
            obStaffRmn11 = 'Select One';
            obStaffRmn12 = 'Select One';
            obStaffRmn13 = 'Select One';
            obStaffRmn14 = 'Select One';
            obStaffRmn15 = 'Select One';
            obStaffRmn16 = 'Select One';
            obStaffRmn17 = 'Select One';
            obStaffRmn18 = 'Select One';
            obStaffRmn19 = 'Select One';
            obStaffRmn20 = 'Select One';
            obUsefulDetails.clear();
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
                  _textFormField('Reference', jobRef, 1, true),
                  _textFormField('Requested by', obRequestedBy, 1, true),
                  _textFormField('Job Title', obJobTitle, 1, true),
                  _textFormField('Contact Telephone Number', obJobContact, 1, true),
                  _textFormField('Authorising Manager', obJobAuthorisingManager, 1, true),
                  _buildDateField('Date', obJobDate, Strings.obJobDate, true, false),
                  _buildTimeField('Time', obJobTime, Strings.obJobTime, true),
                  _textFormField('Invoice Details', obInvoiceDetails, 4, false, TextInputType.multiline),
                  _textFormField('Cost code', obCostCode),
                  _textFormField('Purchase Order no', obPurchaseOrder),
                  _textFormField('Booking Coordinator', obBookingCoordinator, 1, true),
                  _textFormField('Patient Location Address', obPatientLocation, 2, true, TextInputType.multiline),
                  _textFormField('Postcode', obPostcode, 1, true),
                  _textFormField('Location Tel', obLocationTel, 1, true),
                  _buildStartDateTimeField(),
                  SizedBox(height: 10,),
                  _buildMhaAssessmentCheckboxes(),
                  _buildBedIdentifiedCheckboxes(),
                  _buildWrapDocumentationCheckboxes(),
                  _textFormField('What shift do you require?', obShiftRequired, 1, true),
                  SizedBox(height: 10,),
                  Text('Patient Details', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 18),),
                  SizedBox(height: 5,),
                  _textFormField('Name', obPatientName, 1, true),
                  _textFormField('Legal Status', obLegalStatus, 1, true),
                  _buildDateField('Date of birth', obDateOfBirth, Strings.obDateOfBirth, true, true),
                  _textFormField('NHS Number', obNhsNumber, 1, true),
                  _textFormField('Gender', obGender, 1, true),
                  _textFormField('Ethnicity', obEthnicity, 1, true),
                  _textFormField('Covid Status', obCovidStatus, 1, true),
                  _textFormField('Current Presentation: (Reason for attending ED/Acute Hospital)', obCurrentPresentation, 3, true, TextInputType.multiline),
                  _buildRmnDrop(),
                  _buildHcaDrop(),
                  obHca == '1' ? Column(children: [
                    _textFormField('1.', obHca1),

                  ],) : Container(),
                  obHca == '2' ? Column(children: [
                    _textFormField('1.', obHca1),
                    _textFormField('2.', obHca2),

                  ],) : Container(),
                  obHca == '3' ? Column(children: [
                    _textFormField('1.', obHca1),
                    _textFormField('2.', obHca2),
                    _textFormField('3.', obHca3),

                  ],) : Container(),
                  obHca == '4' ? Column(children: [
                    _textFormField('1.', obHca1),
                    _textFormField('2.', obHca2),
                    _textFormField('3.', obHca3),
                    _textFormField('4.', obHca4),

                  ],) : Container(),
                  obHca == '5' ? Column(children: [
                    _textFormField('1.', obHca1),
                    _textFormField('2.', obHca2),
                    _textFormField('3.', obHca3),
                    _textFormField('4.', obHca4),
                    _textFormField('5.', obHca5),

                  ],) : Container(),
                  _buildSpecificCarePlanCheckboxes(),
                  obSpecificCarePlanYes ? _textFormField('Details', obSpecificCarePlan, 2, obSpecificCarePlanYes, TextInputType.multiline)
                  : Container(),
                  _buildPatientWarningsCheckboxes(),
                  obPatientWarningsYes ? _textFormField('Details', obPatientWarnings, 2, obPatientWarningsYes, TextInputType.multiline)
                      : Container(),
                  _textFormField('Presenting Risks: (inc physical health, covid symptoms)', obPresentingRisks, 2, true, TextInputType.multiline),
                  _textFormField('Previous Risk History: (inc physical health, covid symptoms)', obPreviousRisks, 2, true, TextInputType.multiline),
                  _buildGenderConcernsCheckboxes(),
                  obGenderConcernsYes ? _textFormField('Details', obGenderConcerns, 2, obGenderConcernsYes, TextInputType.multiline)
                      : Container(),
                  _buildSafeguardingConcernsCheckboxes(),
                  obSafeguardingConcernsYes ? _textFormField('Details', obSafeguardingConcerns, 2, obSafeguardingConcernsYes, TextInputType.multiline)
                      : Container(),
                  _buildTimeField('Time Due at Location', obTimeDue, Strings.obTimeDue, true),
                  SizedBox(height: 10,),
                  Text('Staffing', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 18),),
                  SizedBox(height: 5,),
                  Container(decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey)
                  ),
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        _buildDateField('Date', obStaffDate1, Strings.obStaffDate1),
                        _buildTimeField('Start Time', obStaffStartTime1, Strings.obStaffStartTime1),
                        _buildTimeField('End Time', obStaffEndTime1, Strings.obStaffEndTime1),
                        _textFormField('Name', obStaffName1),
                        _buildStaffRmn1Drop(),
                      ],
                    ),),
                  SizedBox(height: 10,),
                  rowCount >= 2 ? Column(
                    children: [
                      Container(decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey)
                      ),
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          _buildDateField('Date', obStaffDate2, Strings.obStaffDate2),
                          _buildTimeField('Start Time', obStaffStartTime2, Strings.obStaffStartTime2),
                          _buildTimeField('End Time', obStaffEndTime2, Strings.obStaffEndTime2),
                          _textFormField('Name', obStaffName2),
                          _buildStaffRmn2Drop(),
                        ],
                      ),),
                      SizedBox(height: 10,),
                    ],
                  ) : Container(),
                  rowCount >= 3 ? Column(
                    children: [
                      Container(decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey)
                      ),
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            _buildDateField('Date', obStaffDate3, Strings.obStaffDate3),
                            _buildTimeField('Start Time', obStaffStartTime3, Strings.obStaffStartTime3),
                            _buildTimeField('End Time', obStaffEndTime3, Strings.obStaffEndTime3),
                            _textFormField('Name', obStaffName3),
                            _buildStaffRmn3Drop(),
                          ],
                        ),),
                      SizedBox(height: 10,),
                    ],
                  ) : Container(),
                  rowCount >= 4 ? Column(
                    children: [
                      Container(decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey)
                      ),
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            _buildDateField('Date', obStaffDate4, Strings.obStaffDate4),
                            _buildTimeField('Start Time', obStaffStartTime4, Strings.obStaffStartTime4),
                            _buildTimeField('End Time', obStaffEndTime4, Strings.obStaffEndTime4),
                            _textFormField('Name', obStaffName4),
                            _buildStaffRmn4Drop(),
                          ],
                        ),),
                      SizedBox(height: 10,),
                    ],
                  ) : Container(),
                  rowCount >= 5 ? Column(
                    children: [
                      Container(decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey)
                      ),
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            _buildDateField('Date', obStaffDate5, Strings.obStaffDate5),
                            _buildTimeField('Start Time', obStaffStartTime5, Strings.obStaffStartTime5),
                            _buildTimeField('End Time', obStaffEndTime5, Strings.obStaffEndTime5),
                            _textFormField('Name', obStaffName5),
                            _buildStaffRmn5Drop(),
                          ],
                        ),),
                      SizedBox(height: 10,),
                    ],
                  ) : Container(),
                  rowCount >= 6 ? Column(
                    children: [
                      Container(decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey)
                      ),
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            _buildDateField('Date', obStaffDate6, Strings.obStaffDate6),
                            _buildTimeField('Start Time', obStaffStartTime6, Strings.obStaffStartTime6),
                            _buildTimeField('End Time', obStaffEndTime6, Strings.obStaffEndTime6),
                            _textFormField('Name', obStaffName6),
                            _buildStaffRmn6Drop(),
                          ],
                        ),),
                      SizedBox(height: 10,),
                    ],
                  ) : Container(),
                  rowCount >= 7 ? Column(
                    children: [
                      Container(decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey)
                      ),
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            _buildDateField('Date', obStaffDate7, Strings.obStaffDate7),
                            _buildTimeField('Start Time', obStaffStartTime7, Strings.obStaffStartTime7),
                            _buildTimeField('End Time', obStaffEndTime7, Strings.obStaffEndTime7),
                            _textFormField('Name', obStaffName7),
                            _buildStaffRmn7Drop(),
                          ],
                        ),),
                      SizedBox(height: 10,),
                    ],
                  ) : Container(),
                  rowCount >= 8 ? Column(
                    children: [
                      Container(decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey)
                      ),
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            _buildDateField('Date', obStaffDate8, Strings.obStaffDate8),
                            _buildTimeField('Start Time', obStaffStartTime8, Strings.obStaffStartTime8),
                            _buildTimeField('End Time', obStaffEndTime8, Strings.obStaffEndTime8),
                            _textFormField('Name', obStaffName8),
                            _buildStaffRmn8Drop(),
                          ],
                        ),),
                      SizedBox(height: 10,),
                    ],
                  ) : Container(),
                  rowCount >= 9 ? Column(
                    children: [
                      Container(decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey)
                      ),
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            _buildDateField('Date', obStaffDate9, Strings.obStaffDate9),
                            _buildTimeField('Start Time', obStaffStartTime9, Strings.obStaffStartTime9),
                            _buildTimeField('End Time', obStaffEndTime9, Strings.obStaffEndTime9),
                            _textFormField('Name', obStaffName9),
                            _buildStaffRmn9Drop(),
                          ],
                        ),),
                      SizedBox(height: 10,),
                    ],
                  ) : Container(),
                  rowCount >= 10 ? Column(
                    children: [
                      Container(decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey)
                      ),
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            _buildDateField('Date', obStaffDate10, Strings.obStaffDate10),
                            _buildTimeField('Start Time', obStaffStartTime10, Strings.obStaffStartTime10),
                            _buildTimeField('End Time', obStaffEndTime10, Strings.obStaffEndTime10),
                            _textFormField('Name', obStaffName10),
                            _buildStaffRmn10Drop(),
                          ],
                        ),),
                      SizedBox(height: 10,),
                    ],
                  ) : Container(),
                  rowCount >= 11 ? Column(
                    children: [
                      Container(decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey)
                      ),
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            _buildDateField('Date', obStaffDate11, Strings.obStaffDate11),
                            _buildTimeField('Start Time', obStaffStartTime11, Strings.obStaffStartTime11),
                            _buildTimeField('End Time', obStaffEndTime11, Strings.obStaffEndTime11),
                            _textFormField('Name', obStaffName11),
                            _buildStaffRmn11Drop(),
                          ],
                        ),),
                      SizedBox(height: 10,),
                    ],
                  ) : Container(),
                  rowCount >= 12 ? Column(
                    children: [
                      Container(decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey)
                      ),
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            _buildDateField('Date', obStaffDate12, Strings.obStaffDate12),
                            _buildTimeField('Start Time', obStaffStartTime12, Strings.obStaffStartTime12),
                            _buildTimeField('End Time', obStaffEndTime12, Strings.obStaffEndTime12),
                            _textFormField('Name', obStaffName12),
                            _buildStaffRmn12Drop(),
                          ],
                        ),),
                      SizedBox(height: 10,),
                    ],
                  ) : Container(),
                  rowCount >= 13 ? Column(
                    children: [
                      Container(decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey)
                      ),
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            _buildDateField('Date', obStaffDate13, Strings.obStaffDate13),
                            _buildTimeField('Start Time', obStaffStartTime13, Strings.obStaffStartTime13),
                            _buildTimeField('End Time', obStaffEndTime13, Strings.obStaffEndTime13),
                            _textFormField('Name', obStaffName13),
                            _buildStaffRmn13Drop(),
                          ],
                        ),),
                      SizedBox(height: 10,),
                    ],
                  ) : Container(),
                  rowCount >= 14 ? Column(
                    children: [
                      Container(decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey)
                      ),
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            _buildDateField('Date', obStaffDate14, Strings.obStaffDate14),
                            _buildTimeField('Start Time', obStaffStartTime14, Strings.obStaffStartTime14),
                            _buildTimeField('End Time', obStaffEndTime14, Strings.obStaffEndTime14),
                            _textFormField('Name', obStaffName14),
                            _buildStaffRmn14Drop(),
                          ],
                        ),),
                      SizedBox(height: 10,),
                    ],
                  ) : Container(),
                  rowCount >= 15 ? Column(
                    children: [
                      Container(decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey)
                      ),
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            _buildDateField('Date', obStaffDate15, Strings.obStaffDate15),
                            _buildTimeField('Start Time', obStaffStartTime15, Strings.obStaffStartTime15),
                            _buildTimeField('End Time', obStaffEndTime15, Strings.obStaffEndTime15),
                            _textFormField('Name', obStaffName15),
                            _buildStaffRmn15Drop(),
                          ],
                        ),),
                      SizedBox(height: 10,),
                    ],
                  ) : Container(),
                  rowCount >= 16 ? Column(
                    children: [
                      Container(decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey)
                      ),
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            _buildDateField('Date', obStaffDate16, Strings.obStaffDate16),
                            _buildTimeField('Start Time', obStaffStartTime16, Strings.obStaffStartTime16),
                            _buildTimeField('End Time', obStaffEndTime16, Strings.obStaffEndTime16),
                            _textFormField('Name', obStaffName16),
                            _buildStaffRmn16Drop(),
                          ],
                        ),),
                      SizedBox(height: 10,),
                    ],
                  ) : Container(),
                  rowCount >= 17 ? Column(
                    children: [
                      Container(decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey)
                      ),
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            _buildDateField('Date', obStaffDate17, Strings.obStaffDate17),
                            _buildTimeField('Start Time', obStaffStartTime17, Strings.obStaffStartTime17),
                            _buildTimeField('End Time', obStaffEndTime17, Strings.obStaffEndTime17),
                            _textFormField('Name', obStaffName17),
                            _buildStaffRmn17Drop(),
                          ],
                        ),),
                      SizedBox(height: 10,),
                    ],
                  ) : Container(),
                  rowCount >= 18 ? Column(
                    children: [
                      Container(decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey)
                      ),
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            _buildDateField('Date', obStaffDate18, Strings.obStaffDate18),
                            _buildTimeField('Start Time', obStaffStartTime18, Strings.obStaffStartTime18),
                            _buildTimeField('End Time', obStaffEndTime18, Strings.obStaffEndTime18),
                            _textFormField('Name', obStaffName18),
                            _buildStaffRmn18Drop(),
                          ],
                        ),),
                      SizedBox(height: 10,),
                    ],
                  ) : Container(),
                  rowCount >= 19 ? Column(
                    children: [
                      Container(decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey)
                      ),
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            _buildDateField('Date', obStaffDate19, Strings.obStaffDate19),
                            _buildTimeField('Start Time', obStaffStartTime19, Strings.obStaffStartTime19),
                            _buildTimeField('End Time', obStaffEndTime19, Strings.obStaffEndTime19),
                            _textFormField('Name', obStaffName19),
                            _buildStaffRmn19Drop(),
                          ],
                        ),),
                      SizedBox(height: 10,),
                    ],
                  ) : Container(),
                  rowCount >= 20 ? Column(
                    children: [
                      Container(decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey)
                      ),
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            _buildDateField('Date', obStaffDate20, Strings.obStaffDate20),
                            _buildTimeField('Start Time', obStaffStartTime20, Strings.obStaffStartTime20),
                            _buildTimeField('End Time', obStaffEndTime20, Strings.obStaffEndTime20),
                            _textFormField('Name', obStaffName20),
                            _buildStaffRmn20Drop(),
                          ],
                        ),),
                      SizedBox(height: 10,),
                    ],
                  ) : Container(),



                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    rowCount < 2 ? Container() :
                    SizedBox(width: 150, child: GradientButton('Remove Staff', () => _decreaseRowCount()),),
                    SizedBox(width: 10,),
                    SizedBox(width: 150, child: GradientButton('Add Staff', () => _increaseRowCount()),),
                  ],),
                  SizedBox(height: 10,),

                  _textFormField('Useful Details', obUsefulDetails, 4, false, TextInputType.multiline),

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
      drawer: widget.edit || widget.saved ? null : SideDrawer(),
      appBar: AppBar(
        flexibleSpace: AppBarGradient(),
        title: FittedBox(fit:BoxFit.fitWidth,
            child: Text('Observation Booking', style: TextStyle(fontWeight: FontWeight.bold),)),
        actions: <Widget>[
          widget.edit || widget.saved ? Container() : IconButton(icon: Icon(Icons.refresh), onPressed: _resetForm),
          widget.saved || widget.edit ? Container() : IconButton(icon: Icon(Icons.watch_later_outlined), onPressed: _saveForLater),
          IconButton(icon: Icon(Icons.send), onPressed: _submitForm),
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

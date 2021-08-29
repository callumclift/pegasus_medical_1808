import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:pegasus_medical_1808/models/booking_form_model.dart';
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


class BookingForm extends StatefulWidget {
  final bool fromJob;
  final String jobId;
  final bool fillDetails;
  final bool edit;

  BookingForm(
      [this.fromJob = false,
        this.jobId = '1',
        this.fillDetails = false,
        this.edit = false]);

  @override
  _BookingFormState createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {

  bool _loadingTemporary = false;
  //DatabaseHelper _databaseHelper = DatabaseHelper();
  BookingFormModel bookingFormModel;
  final dateFormat = DateFormat("dd/MM/yyyy");
  final dateTimeFormat = DateFormat("dd/MM/yyyy HH:mm");
  final timeFormat = DateFormat("HH:mm");
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController jobRef = TextEditingController();
  final TextEditingController bfRequestedBy = TextEditingController();
  final TextEditingController bfJobTitle = TextEditingController();
  final TextEditingController bfJobContact = TextEditingController();
  final TextEditingController bfJobAuthorisingManager = TextEditingController();
  final TextEditingController bfJobDate = TextEditingController();
  final TextEditingController bfJobTime = TextEditingController();
  final TextEditingController bfTransportCoordinator = TextEditingController();
  final TextEditingController bfCollectionAddress = TextEditingController();
  final TextEditingController bfCollectionPostcode = TextEditingController();
  final TextEditingController bfCollectionTel = TextEditingController();
  final TextEditingController bfDestinationAddress = TextEditingController();
  final TextEditingController bfDestinationPostcode = TextEditingController();
  final TextEditingController bfDestinationTel = TextEditingController();
  final TextEditingController bfInvoiceDetails = TextEditingController();
  final TextEditingController bfCostCode = TextEditingController();
  final TextEditingController bfPurchaseOrder = TextEditingController();
  final TextEditingController bfCollectionDateTime = TextEditingController();
  final TextEditingController bfPatientName = TextEditingController();
  final TextEditingController bfLegalStatus = TextEditingController();
  final TextEditingController bfDateOfBirth = TextEditingController();
  final TextEditingController bfNhsNumber = TextEditingController();
  final TextEditingController bfGender = TextEditingController();
  final TextEditingController bfEthnicity = TextEditingController();
  final TextEditingController bfCovidStatus = TextEditingController();
  final TextEditingController bfHca1 = TextEditingController();
  final TextEditingController bfHca2 = TextEditingController();
  final TextEditingController bfHca3 = TextEditingController();
  final TextEditingController bfHca4 = TextEditingController();
  final TextEditingController bfHca5 = TextEditingController();
  final TextEditingController bfCurrentPresentation = TextEditingController();
  bool bfSpecificCarePlanYes = false;
  bool bfSpecificCarePlanNo = false;
  final TextEditingController bfSpecificCarePlan = TextEditingController();
  bool bfPatientWarningsYes = false;
  bool bfPatientWarningsNo = false;
  final TextEditingController bfPatientWarnings = TextEditingController();
  final TextEditingController bfPresentingRisks = TextEditingController();
  final TextEditingController bfPreviousRisks = TextEditingController();
  bool bfGenderConcernsYes = false;
  bool bfGenderConcernsNo = false;
  final TextEditingController bfGenderConcerns = TextEditingController();
  bool bfSafeguardingConcernsYes = false;
  bool bfSafeguardingConcernsNo = false;
  final TextEditingController bfSafeguardingConcerns = TextEditingController();
  final TextEditingController bfTimeDue = TextEditingController();
  final TextEditingController bfAmbulanceRegistration = TextEditingController();

  String bfRmn = 'Select One';
  String bfHca = 'Select One';

  List<String> bfRmnDrop = [
    'Select One',
    '0',
    '1'
  ];

  List<String> bfHcaDrop = [
    'Select One',
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
  ];

  Map<String, dynamic> selectedUser;

  @override
  void initState() {
    // TODO: implement initState
    _loadingTemporary = true;
    bookingFormModel = Provider.of<BookingFormModel>(context, listen: false);
    _setUpTextControllerListeners();
    _getTemporaryBookingForm();
    super.initState();
  }

  @override
  void dispose() {
    jobRef.dispose();
    bfRequestedBy.dispose();
    bfJobTitle.dispose();
    bfJobContact.dispose();
    bfJobAuthorisingManager.dispose();
    bfJobDate.dispose();
    bfJobTime.dispose();
    bfTransportCoordinator.dispose();
    bfCollectionAddress.dispose();
    bfCollectionPostcode.dispose();
    bfCollectionTel.dispose();
    bfDestinationAddress.dispose();
    bfDestinationPostcode.dispose();
    bfDestinationTel.dispose();
    bfInvoiceDetails.dispose();
    bfCostCode.dispose();
    bfPurchaseOrder.dispose();
    bfCollectionDateTime.dispose();
    bfPatientName.dispose();
    bfLegalStatus.dispose();
    bfDateOfBirth.dispose();
    bfNhsNumber.dispose();
    bfGender.dispose();
    bfEthnicity.dispose();
    bfCovidStatus.dispose();
    bfHca1.dispose();
    bfHca2.dispose();
    bfHca3.dispose();
    bfHca4.dispose();
    bfHca5.dispose();
    bfCurrentPresentation.dispose();
    bfSpecificCarePlan.dispose();
    bfPatientWarnings.dispose();
    bfPresentingRisks.dispose();
    bfPreviousRisks.dispose();
    bfGenderConcerns.dispose();
    bfSafeguardingConcerns.dispose();
    bfTimeDue.dispose();
    bfAmbulanceRegistration.dispose();
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
      bookingFormModel.updateTemporaryRecord(widget.edit, value, encrypt ? GlobalFunctions.encryptString(controllerText) : GlobalFunctions.databaseValueString(controllerText), widget.jobId);

      // _databaseHelper.updateTemporaryBookingFormField(widget.edit, {
      //   value:
      //   encrypt ? GlobalFunctions.encryptString(controllerText) : GlobalFunctions.databaseValueString(controllerText)
      // }, user.uid, widget.jobId);
    });
  }

  _setUpTextControllerListeners() {

    _addListener(jobRef, Strings.jobRef, false, true);
    _addListener(bfRequestedBy, Strings.bfRequestedBy);
    _addListener(bfJobTitle, Strings.bfJobTitle);
    _addListener(bfJobContact, Strings.bfJobContact);
    _addListener(bfJobAuthorisingManager, Strings.bfJobAuthorisingManager);
    _addListener(bfTransportCoordinator, Strings.bfTransportCoordinator);
    _addListener(bfCollectionAddress, Strings.bfCollectionAddress);
    _addListener(bfCollectionPostcode, Strings.bfCollectionPostcode, true, true);
    _addListener(bfCollectionTel, Strings.bfCollectionTel);
    _addListener(bfDestinationAddress, Strings.bfDestinationAddress);
    _addListener(bfDestinationPostcode, Strings.bfDestinationPostcode, true, true);
    _addListener(bfDestinationTel, Strings.bfDestinationTel);
    _addListener(bfInvoiceDetails, Strings.bfInvoiceDetails);
    _addListener(bfCostCode, Strings.bfCostCode);
    _addListener(bfPurchaseOrder, Strings.bfPurchaseOrder);
    _addListener(bfPatientName, Strings.bfPatientName, true, false, true);
    _addListener(bfLegalStatus, Strings.bfLegalStatus);
    _addListener(bfNhsNumber, Strings.bfNhsNumber);
    _addListener(bfGender, Strings.bfGender);
    _addListener(bfEthnicity, Strings.bfEthnicity);
    _addListener(bfCovidStatus, Strings.bfCovidStatus);
    _addListener(bfHca1, Strings.bfHca1);
    _addListener(bfHca2, Strings.bfHca2);
    _addListener(bfHca3, Strings.bfHca3);
    _addListener(bfHca4, Strings.bfHca4);
    _addListener(bfHca5, Strings.bfHca5);
    _addListener(bfCurrentPresentation, Strings.bfCurrentPresentation);
    _addListener(bfSpecificCarePlan, Strings.bfSpecificCarePlan);
    _addListener(bfPatientWarnings, Strings.bfPatientWarnings);
    _addListener(bfPresentingRisks, Strings.bfPresentingRisks);
    _addListener(bfPreviousRisks, Strings.bfPreviousRisks);
    _addListener(bfGenderConcerns, Strings.bfGenderConcerns);
    _addListener(bfSafeguardingConcerns, Strings.bfSafeguardingConcerns);
    _addListener(bfAmbulanceRegistration, Strings.bfAmbulanceRegistration, true, true);
  }

  _getTemporaryBookingForm() async {

    //Sembast
    if (mounted) {

    await bookingFormModel.setupTemporaryRecord();

    bool hasRecord = await bookingFormModel.checkRecordExists(widget.edit, widget.jobId);

    if(hasRecord){
      Map<String, dynamic> bookingForm = await bookingFormModel.getTemporaryRecord(widget.edit, widget.jobId);

      if (bookingForm[Strings.jobRef] != null) {
          jobRef.text = GlobalFunctions.databaseValueString(
              bookingForm[Strings.jobRef]);
        } else {
          jobRef.text = '';
        }

        GlobalFunctions.getTemporaryValue(bookingForm, bfRequestedBy, Strings.bfRequestedBy);
        GlobalFunctions.getTemporaryValue(bookingForm, bfJobTitle, Strings.bfJobTitle);
        GlobalFunctions.getTemporaryValue(bookingForm, bfJobContact, Strings.bfJobContact);
        GlobalFunctions.getTemporaryValue(bookingForm, bfJobAuthorisingManager, Strings.bfJobAuthorisingManager);
        if (bookingForm[Strings.bfJobDate] != null) {
          bfJobDate.text =
              dateFormat.format(DateTime.parse(bookingForm[Strings.bfJobDate]));
        } else {
          bfJobDate.text = '';
        }
        GlobalFunctions.getTemporaryValueTime(bookingForm, bfJobTime, Strings.bfJobTime);
        GlobalFunctions.getTemporaryValue(bookingForm, bfTransportCoordinator, Strings.bfTransportCoordinator);
        GlobalFunctions.getTemporaryValue(bookingForm, bfCollectionAddress, Strings.bfCollectionAddress);
        GlobalFunctions.getTemporaryValue(bookingForm, bfCollectionPostcode, Strings.bfCollectionPostcode);
        GlobalFunctions.getTemporaryValue(bookingForm, bfCollectionTel, Strings.bfCollectionTel);
        GlobalFunctions.getTemporaryValue(bookingForm, bfDestinationAddress, Strings.bfDestinationAddress);
        GlobalFunctions.getTemporaryValue(bookingForm, bfDestinationPostcode, Strings.bfDestinationPostcode);
        GlobalFunctions.getTemporaryValue(bookingForm, bfDestinationTel, Strings.bfDestinationTel);
        GlobalFunctions.getTemporaryValue(bookingForm, bfInvoiceDetails, Strings.bfInvoiceDetails);
        GlobalFunctions.getTemporaryValue(bookingForm, bfCostCode, Strings.bfCostCode);
        GlobalFunctions.getTemporaryValue(bookingForm, bfPurchaseOrder, Strings.bfPurchaseOrder);
        GlobalFunctions.getTemporaryValueDateTime(bookingForm, bfCollectionDateTime, Strings.bfCollectionDateTime);

        GlobalFunctions.getTemporaryValue(bookingForm, bfPatientName, Strings.bfPatientName);
        GlobalFunctions.getTemporaryValue(bookingForm, bfLegalStatus, Strings.bfLegalStatus);
        GlobalFunctions.getTemporaryValueDate(bookingForm, bfDateOfBirth, Strings.bfDateOfBirth, true);
        GlobalFunctions.getTemporaryValue(bookingForm, bfNhsNumber, Strings.bfNhsNumber);
        GlobalFunctions.getTemporaryValue(bookingForm, bfGender, Strings.bfGender);
        GlobalFunctions.getTemporaryValue(bookingForm, bfEthnicity, Strings.bfEthnicity);
        GlobalFunctions.getTemporaryValue(bookingForm, bfCovidStatus, Strings.bfCovidStatus);
        if (bookingForm[Strings.bfRmn] != null) {
          bfRmn = GlobalFunctions.decryptString(bookingForm[Strings.bfRmn]);
        }
        if (bookingForm[Strings.bfHca] != null) {
          bfHca = GlobalFunctions.decryptString(bookingForm[Strings.bfHca]);
        }
        GlobalFunctions.getTemporaryValue(bookingForm, bfHca1, Strings.bfHca1);
        GlobalFunctions.getTemporaryValue(bookingForm, bfHca2, Strings.bfHca2);
        GlobalFunctions.getTemporaryValue(bookingForm, bfHca3, Strings.bfHca3);
        GlobalFunctions.getTemporaryValue(bookingForm, bfHca4, Strings.bfHca4);
        GlobalFunctions.getTemporaryValue(bookingForm, bfHca5, Strings.bfHca5);
        GlobalFunctions.getTemporaryValue(bookingForm, bfCurrentPresentation, Strings.bfCurrentPresentation);
        if (bookingForm[Strings.bfSpecificCarePlanYes] != null) {
          if (mounted) {
            setState(() {
              bfSpecificCarePlanYes = GlobalFunctions.tinyIntToBool(bookingForm[Strings.bfSpecificCarePlanYes]);
            });
          }
        }
        if (bookingForm[Strings.bfSpecificCarePlanNo] != null) {
          if (mounted) {
            setState(() {
              bfSpecificCarePlanNo = GlobalFunctions.tinyIntToBool(bookingForm[Strings.bfSpecificCarePlanNo]);
            });
          }
        }
        GlobalFunctions.getTemporaryValue(bookingForm, bfSpecificCarePlan, Strings.bfSpecificCarePlan);
        if (bookingForm[Strings.bfPatientWarningsYes] != null) {
          if (mounted) {
            setState(() {
              bfPatientWarningsYes = GlobalFunctions.tinyIntToBool(bookingForm[Strings.bfPatientWarningsYes]);
            });
          }
        }
        if (bookingForm[Strings.bfPatientWarningsNo] != null) {
          if (mounted) {
            setState(() {
              bfPatientWarningsNo = GlobalFunctions.tinyIntToBool(bookingForm[Strings.bfPatientWarningsNo]);
            });
          }
        }
        GlobalFunctions.getTemporaryValue(bookingForm, bfPatientWarnings, Strings.bfPatientWarnings);
        GlobalFunctions.getTemporaryValue(bookingForm, bfPresentingRisks, Strings.bfPresentingRisks);
        GlobalFunctions.getTemporaryValue(bookingForm, bfPreviousRisks, Strings.bfPreviousRisks);
        if (bookingForm[Strings.bfGenderConcernsYes] != null) {
          if (mounted) {
            setState(() {
              bfGenderConcernsYes = GlobalFunctions.tinyIntToBool(bookingForm[Strings.bfGenderConcernsYes]);
            });
          }
        }
        if (bookingForm[Strings.bfGenderConcernsNo] != null) {
          if (mounted) {
            setState(() {
              bfGenderConcernsNo = GlobalFunctions.tinyIntToBool(bookingForm[Strings.bfGenderConcernsNo]);
            });
          }
        }
        GlobalFunctions.getTemporaryValue(bookingForm, bfGenderConcerns, Strings.bfGenderConcerns);
        if (bookingForm[Strings.bfSafeguardingConcernsYes] != null) {
          if (mounted) {
            setState(() {
              bfSafeguardingConcernsYes = GlobalFunctions.tinyIntToBool(bookingForm[Strings.bfSafeguardingConcernsYes]);
            });
          }
        }
        if (bookingForm[Strings.bfSafeguardingConcernsNo] != null) {
          if (mounted) {
            setState(() {
              bfSafeguardingConcernsNo = GlobalFunctions.tinyIntToBool(bookingForm[Strings.bfSafeguardingConcernsNo]);
            });
          }
        }
        GlobalFunctions.getTemporaryValue(bookingForm, bfSafeguardingConcerns, Strings.bfSafeguardingConcerns);
        GlobalFunctions.getTemporaryValueTime(bookingForm, bfTimeDue, Strings.bfTimeDue);
        GlobalFunctions.getTemporaryValue(bookingForm, bfAmbulanceRegistration, Strings.bfAmbulanceRegistration);

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
    //   int result = await _databaseHelper.checkTemporaryBookingFormExists(widget.edit,
    //       user.uid, widget.jobId);
    //   if (result != 0) {
    //     Map<String, dynamic> bookingForm = await _databaseHelper
    //         .getTemporaryBookingForm(widget.edit, user.uid, widget.jobId);
    //
    //
    //     if (bookingForm[Strings.jobRef] != null) {
    //       jobRef.text = GlobalFunctions.databaseValueString(
    //           bookingForm[Strings.jobRef]);
    //     } else {
    //       jobRef.text = '';
    //     }
    //
    //     GlobalFunctions.getTemporaryValue(bookingForm, bfRequestedBy, Strings.bfRequestedBy);
    //     GlobalFunctions.getTemporaryValue(bookingForm, bfJobTitle, Strings.bfJobTitle);
    //     GlobalFunctions.getTemporaryValue(bookingForm, bfJobContact, Strings.bfJobContact);
    //     GlobalFunctions.getTemporaryValue(bookingForm, bfJobAuthorisingManager, Strings.bfJobAuthorisingManager);
    //     if (bookingForm[Strings.bfJobDate] != null) {
    //       bfJobDate.text =
    //           dateFormat.format(DateTime.parse(bookingForm[Strings.bfJobDate]));
    //     } else {
    //       bfJobDate.text = '';
    //     }
    //     GlobalFunctions.getTemporaryValueTime(bookingForm, bfJobTime, Strings.bfJobTime);
    //     GlobalFunctions.getTemporaryValue(bookingForm, bfTransportCoordinator, Strings.bfTransportCoordinator);
    //     GlobalFunctions.getTemporaryValue(bookingForm, bfCollectionAddress, Strings.bfCollectionAddress);
    //     GlobalFunctions.getTemporaryValue(bookingForm, bfCollectionPostcode, Strings.bfCollectionPostcode);
    //     GlobalFunctions.getTemporaryValue(bookingForm, bfCollectionTel, Strings.bfCollectionTel);
    //     GlobalFunctions.getTemporaryValue(bookingForm, bfDestinationAddress, Strings.bfDestinationAddress);
    //     GlobalFunctions.getTemporaryValue(bookingForm, bfDestinationPostcode, Strings.bfDestinationPostcode);
    //     GlobalFunctions.getTemporaryValue(bookingForm, bfDestinationTel, Strings.bfDestinationTel);
    //     GlobalFunctions.getTemporaryValue(bookingForm, bfInvoiceDetails, Strings.bfInvoiceDetails);
    //     GlobalFunctions.getTemporaryValue(bookingForm, bfCostCode, Strings.bfCostCode);
    //     GlobalFunctions.getTemporaryValue(bookingForm, bfPurchaseOrder, Strings.bfPurchaseOrder);
    //     GlobalFunctions.getTemporaryValueDateTime(bookingForm, bfCollectionDateTime, Strings.bfCollectionDateTime);
    //
    //     GlobalFunctions.getTemporaryValue(bookingForm, bfPatientName, Strings.bfPatientName);
    //     GlobalFunctions.getTemporaryValue(bookingForm, bfLegalStatus, Strings.bfLegalStatus);
    //     GlobalFunctions.getTemporaryValueDate(bookingForm, bfDateOfBirth, Strings.bfDateOfBirth, true);
    //     GlobalFunctions.getTemporaryValue(bookingForm, bfNhsNumber, Strings.bfNhsNumber);
    //     GlobalFunctions.getTemporaryValue(bookingForm, bfGender, Strings.bfGender);
    //     GlobalFunctions.getTemporaryValue(bookingForm, bfEthnicity, Strings.bfEthnicity);
    //     GlobalFunctions.getTemporaryValue(bookingForm, bfCovidStatus, Strings.bfCovidStatus);
    //     if (bookingForm[Strings.bfRmn] != null) {
    //       bfRmn = GlobalFunctions.decryptString(bookingForm[Strings.bfRmn]);
    //     }
    //     if (bookingForm[Strings.bfHca] != null) {
    //       bfHca = GlobalFunctions.decryptString(bookingForm[Strings.bfHca]);
    //     }
    //     GlobalFunctions.getTemporaryValue(bookingForm, bfHca1, Strings.bfHca1);
    //     GlobalFunctions.getTemporaryValue(bookingForm, bfHca2, Strings.bfHca2);
    //     GlobalFunctions.getTemporaryValue(bookingForm, bfHca3, Strings.bfHca3);
    //     GlobalFunctions.getTemporaryValue(bookingForm, bfHca4, Strings.bfHca4);
    //     GlobalFunctions.getTemporaryValue(bookingForm, bfHca5, Strings.bfHca5);
    //     GlobalFunctions.getTemporaryValue(bookingForm, bfCurrentPresentation, Strings.bfCurrentPresentation);
    //     if (bookingForm[Strings.bfSpecificCarePlanYes] != null) {
    //       if (mounted) {
    //         setState(() {
    //           bfSpecificCarePlanYes = GlobalFunctions.tinyIntToBool(bookingForm[Strings.bfSpecificCarePlanYes]);
    //         });
    //       }
    //     }
    //     if (bookingForm[Strings.bfSpecificCarePlanNo] != null) {
    //       if (mounted) {
    //         setState(() {
    //           bfSpecificCarePlanNo = GlobalFunctions.tinyIntToBool(bookingForm[Strings.bfSpecificCarePlanNo]);
    //         });
    //       }
    //     }
    //     GlobalFunctions.getTemporaryValue(bookingForm, bfSpecificCarePlan, Strings.bfSpecificCarePlan);
    //     if (bookingForm[Strings.bfPatientWarningsYes] != null) {
    //       if (mounted) {
    //         setState(() {
    //           bfPatientWarningsYes = GlobalFunctions.tinyIntToBool(bookingForm[Strings.bfPatientWarningsYes]);
    //         });
    //       }
    //     }
    //     if (bookingForm[Strings.bfPatientWarningsNo] != null) {
    //       if (mounted) {
    //         setState(() {
    //           bfPatientWarningsNo = GlobalFunctions.tinyIntToBool(bookingForm[Strings.bfPatientWarningsNo]);
    //         });
    //       }
    //     }
    //     GlobalFunctions.getTemporaryValue(bookingForm, bfPatientWarnings, Strings.bfPatientWarnings);
    //     GlobalFunctions.getTemporaryValue(bookingForm, bfPresentingRisks, Strings.bfPresentingRisks);
    //     GlobalFunctions.getTemporaryValue(bookingForm, bfPreviousRisks, Strings.bfPreviousRisks);
    //     if (bookingForm[Strings.bfGenderConcernsYes] != null) {
    //       if (mounted) {
    //         setState(() {
    //           bfGenderConcernsYes = GlobalFunctions.tinyIntToBool(bookingForm[Strings.bfGenderConcernsYes]);
    //         });
    //       }
    //     }
    //     if (bookingForm[Strings.bfGenderConcernsNo] != null) {
    //       if (mounted) {
    //         setState(() {
    //           bfGenderConcernsNo = GlobalFunctions.tinyIntToBool(bookingForm[Strings.bfGenderConcernsNo]);
    //         });
    //       }
    //     }
    //     GlobalFunctions.getTemporaryValue(bookingForm, bfGenderConcerns, Strings.bfGenderConcerns);
    //     if (bookingForm[Strings.bfSafeguardingConcernsYes] != null) {
    //       if (mounted) {
    //         setState(() {
    //           bfSafeguardingConcernsYes = GlobalFunctions.tinyIntToBool(bookingForm[Strings.bfSafeguardingConcernsYes]);
    //         });
    //       }
    //     }
    //     if (bookingForm[Strings.bfSafeguardingConcernsNo] != null) {
    //       if (mounted) {
    //         setState(() {
    //           bfSafeguardingConcernsNo = GlobalFunctions.tinyIntToBool(bookingForm[Strings.bfSafeguardingConcernsNo]);
    //         });
    //       }
    //     }
    //     GlobalFunctions.getTemporaryValue(bookingForm, bfSafeguardingConcerns, Strings.bfSafeguardingConcerns);
    //     GlobalFunctions.getTemporaryValueTime(bookingForm, bfTimeDue, Strings.bfTimeDue);
    //     GlobalFunctions.getTemporaryValue(bookingForm, bfAmbulanceRegistration, Strings.bfAmbulanceRegistration);
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
                    bookingFormModel.updateTemporaryRecord(widget.edit, value, null, widget.jobId);

                    // _databaseHelper.updateTemporaryBookingFormField(widget.edit,
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
                          bookingFormModel.updateTemporaryRecord(widget.edit, value, GlobalFunctions.encryptString(DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String()), widget.jobId);

                          // _databaseHelper.updateTemporaryBookingFormField(widget.edit,
                          //     {value : GlobalFunctions.encryptString(DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String())}, user.uid, widget.jobId);
                        } else {

                          bookingFormModel.updateTemporaryRecord(widget.edit, value, DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String(), widget.jobId);

                          // _databaseHelper.updateTemporaryBookingFormField(widget.edit,
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
                    bookingFormModel.updateTemporaryRecord(widget.edit, value, null, widget.jobId);

                    // _databaseHelper.updateTemporaryBookingFormField(widget.edit,
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
                          bookingFormModel.updateTemporaryRecord(widget.edit, value, GlobalFunctions.encryptString(DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String()), widget.jobId);

                          // _databaseHelper.updateTemporaryBookingFormField(widget.edit,
                          //     {value : GlobalFunctions.encryptString(DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String())}, user.uid, widget.jobId);
                        } else {
                          bookingFormModel.updateTemporaryRecord(widget.edit, value, DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String(), widget.jobId);

                          // _databaseHelper.updateTemporaryBookingFormField(widget.edit,
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
                  controller: bfCollectionDateTime,
                  onSaved: (String value) {
                    setState(() {
                      bfCollectionDateTime.text = value;
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
                    bfCollectionDateTime.clear();
                    bookingFormModel.updateTemporaryRecord(widget.edit, Strings.bfCollectionDateTime, null, widget.jobId);

                    // _databaseHelper.updateTemporaryBookingFormField(widget.edit,
                    //     {Strings.bfCollectionDateTime : null}, user.uid, widget.jobId);

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
                        bfCollectionDateTime.text = dateTime;
                      });
                      bookingFormModel.updateTemporaryRecord(widget.edit, Strings.bfCollectionDateTime, DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String(), widget.jobId);
                      // await _databaseHelper.updateTemporaryBookingFormField(widget.edit,
                      //     {Strings.bfCollectionDateTime : DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String()}, user.uid, widget.jobId);
                    }
                  }

                })
          ],
        ),
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
          ),
        ),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: bfSpecificCarePlanYes,
                onChanged: (bool value) => setState(() {
                  bfSpecificCarePlanYes = value;
                  bookingFormModel.updateTemporaryRecord(widget.edit, Strings.bfSpecificCarePlanYes, GlobalFunctions.boolToTinyInt(value), widget.jobId);
                  if (bfSpecificCarePlanNo == true){
                    bfSpecificCarePlanNo = false;
                    bookingFormModel.updateTemporaryRecord(widget.edit, Strings.bfSpecificCarePlanNo, null, widget.jobId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: bfSpecificCarePlanNo,
                onChanged: (bool value) => setState(() {
                  bfSpecificCarePlanNo = value;
                  bookingFormModel.updateTemporaryRecord(widget.edit, Strings.bfSpecificCarePlanNo, GlobalFunctions.boolToTinyInt(value), widget.jobId);
                  if (bfSpecificCarePlanYes == true){
                    bfSpecificCarePlanYes = false;
                    bookingFormModel.updateTemporaryRecord(widget.edit, Strings.bfSpecificCarePlanYes, null, widget.jobId);
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
          ),
        ),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: bfPatientWarningsYes,
                onChanged: (bool value) => setState(() {
                  bfPatientWarningsYes = value;
                  bookingFormModel.updateTemporaryRecord(widget.edit, Strings.bfPatientWarningsYes, GlobalFunctions.boolToTinyInt(value), widget.jobId);
                  if (bfPatientWarningsNo == true){
                    bfPatientWarningsNo = false;
                    bookingFormModel.updateTemporaryRecord(widget.edit, Strings.bfPatientWarningsNo, null, widget.jobId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: bfPatientWarningsNo,
                onChanged: (bool value) => setState(() {
                  bfPatientWarningsNo = value;
                  bookingFormModel.updateTemporaryRecord(widget.edit, Strings.bfPatientWarningsNo, GlobalFunctions.boolToTinyInt(value), widget.jobId);
                  if (bfPatientWarningsYes == true){
                    bfPatientWarningsYes = false;
                    bookingFormModel.updateTemporaryRecord(widget.edit, Strings.bfPatientWarningsYes, null, widget.jobId);
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
                value: bfGenderConcernsYes,
                onChanged: (bool value) => setState(() {
                  bfGenderConcernsYes = value;
                  bookingFormModel.updateTemporaryRecord(widget.edit, Strings.bfGenderConcernsYes, GlobalFunctions.boolToTinyInt(value), widget.jobId);
                  if (bfGenderConcernsNo == true){
                    bfGenderConcernsNo = false;
                    bookingFormModel.updateTemporaryRecord(widget.edit, Strings.bfGenderConcernsNo, null, widget.jobId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: bfGenderConcernsNo,
                onChanged: (bool value) => setState(() {
                  bfGenderConcernsNo = value;
                  bookingFormModel.updateTemporaryRecord(widget.edit, Strings.bfGenderConcernsNo, GlobalFunctions.boolToTinyInt(value), widget.jobId);
                  if (bfGenderConcernsYes == true){
                    bfGenderConcernsYes = false;
                    bookingFormModel.updateTemporaryRecord(widget.edit, Strings.bfGenderConcernsYes, null, widget.jobId);
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
                value: bfSafeguardingConcernsYes,
                onChanged: (bool value) => setState(() {
                  bfSafeguardingConcernsYes = value;
                  bookingFormModel.updateTemporaryRecord(widget.edit, Strings.bfSafeguardingConcernsYes, GlobalFunctions.boolToTinyInt(value), widget.jobId);
                  if (bfSafeguardingConcernsNo == true){
                    bfSafeguardingConcernsNo = false;
                    bookingFormModel.updateTemporaryRecord(widget.edit, Strings.bfSafeguardingConcernsNo, null, widget.jobId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: bfSafeguardingConcernsNo,
                onChanged: (bool value) => setState(() {
                  bfSafeguardingConcernsNo = value;
                  bookingFormModel.updateTemporaryRecord(widget.edit, Strings.bfSafeguardingConcernsNo, GlobalFunctions.boolToTinyInt(value), widget.jobId);
                  if (bfSafeguardingConcernsYes == true){
                    bfSafeguardingConcernsYes = false;
                    bookingFormModel.updateTemporaryRecord(widget.edit, Strings.bfSafeguardingConcernsYes, null, widget.jobId);
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
          value: bfRmn,
          items: bfRmnDrop.toList(),
          onChanged: (val) => setState(() {
            bfRmn = val;
            if(val == 'Select One'){
              bookingFormModel.updateTemporaryRecord(widget.edit, Strings.bfRmn, null, widget.jobId);
            } else {
              bookingFormModel.updateTemporaryRecord(widget.edit, Strings.bfRmn, GlobalFunctions.encryptString(val), widget.jobId);
            }

            FocusScope.of(context).unfocus();
          }),
          initialValue: bfRmn,
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
          value: bfHca,
          items: bfHcaDrop.toList(),
          onChanged: (val) => setState(() {
            bfHca = val;
            if(val == 'Select One'){
              bookingFormModel.updateTemporaryRecord(widget.edit, Strings.bfHca, null, widget.jobId);
            } else {
              bookingFormModel.updateTemporaryRecord(widget.edit, Strings.bfHca, GlobalFunctions.encryptString(val), widget.jobId);
            }

            FocusScope.of(context).unfocus();
          }),
          initialValue: bfHca,
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
              child: Center(child: Text("Reset Transport Booking", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),),
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
                  context.read<BookingFormModel>().resetTemporaryRecord(widget.jobId);
                  //context.read<BookingFormModel>().resetTemporaryBookingForm(widget.jobId);
                  FocusScope.of(context).requestFocus(new FocusNode());
                  setState(() {
                    jobRef.clear();
                    bfRequestedBy.clear();
                    bfJobTitle.clear();
                    bfJobContact.clear();
                    bfJobAuthorisingManager.clear();
                    bfJobDate.clear();
                    bfJobTime.clear();
                    bfTransportCoordinator.clear();
                    bfCollectionAddress.clear();
                    bfCollectionPostcode.clear();
                    bfCollectionTel.clear();
                    bfDestinationAddress.clear();
                    bfDestinationPostcode.clear();
                    bfDestinationTel.clear();
                    bfInvoiceDetails.clear();
                    bfCostCode.clear();
                    bfPurchaseOrder.clear();
                    bfCollectionDateTime.clear();
                    bfPatientName.clear();
                    bfLegalStatus.clear();
                    bfDateOfBirth.clear();
                    bfNhsNumber.clear();
                    bfGender.clear();
                    bfEthnicity.clear();
                    bfCovidStatus.clear();
                    bfRmn = 'Select One';
                    bfHca = 'Select One';
                    bfHca1.clear();
                    bfHca2.clear();
                    bfHca3.clear();
                    bfHca4.clear();
                    bfHca5.clear();
                    bfCurrentPresentation.clear();
                    bfSpecificCarePlanYes = false;
                    bfSpecificCarePlanNo = false;
                    bfSpecificCarePlan.clear();
                    bfPatientWarningsYes = false;
                    bfPatientWarningsNo = false;
                    bfPatientWarnings.clear();
                    bfPresentingRisks.clear();
                    bfPreviousRisks.clear();
                    bfGenderConcernsYes = false;
                    bfGenderConcernsNo = false;
                    bfGenderConcerns.clear();
                    bfSafeguardingConcernsYes = false;
                    bfSafeguardingConcernsNo = false;
                    bfSafeguardingConcerns.clear();
                    bfTimeDue.clear();
                    bfAmbulanceRegistration.clear();
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


    bool continueSubmit = await bookingFormModel.validateBookingForm(widget.jobId, widget.edit);


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
                child: Center(child: Text("Submit Transport Booking", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),),
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



        bool hasSelectedUser = await showDialog(
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
                  child: Center(child: Text("Assign User", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),),
                ),
                content: Container(
                  width: double.maxFinite,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('users').orderBy(Strings.nameLowercase, descending: false).snapshots(),
                    builder: (context, snapshot) {


                      if (snapshot.hasData) {

                        if (snapshot.data.docs.isEmpty) {
                          return Center(child: Text('Unable to load users'));
                        }

                        return ListView.builder(shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {

                            return Column(
                              children: <Widget>[
                                user == null ? Container() : ListTile(
                                  onTap: () async {

                                    await bookingFormModel.updateTemporaryRecord(widget.edit, Strings.assignedUserId, snapshot.data.docs[index].id, widget.jobId);

                                    // await _databaseHelper.updateTemporaryBookingFormField(widget.edit,
                                    //     {Strings.assignedUserId : snapshot.data.docs[index].id}, user.uid, widget.jobId);

                                    await bookingFormModel.updateTemporaryRecord(widget.edit, Strings.assignedUserName, snapshot.data.docs[index].data()[Strings.name], widget.jobId);


                                    // await _databaseHelper.updateTemporaryBookingFormField(widget.edit,
                                    //     {Strings.assignedUserName : snapshot.data.docs[index].data()[Strings.name]}, user.uid, widget.jobId);

                                    Navigator.of(context).pop(true);


                                  },
                                  leading: Icon(Icons.person, color: bluePurple,),
                                  title: Text(snapshot.data.docs[index].data()[Strings.name]),
                                ),
                                Divider(),
                              ],
                            );
                          },
                          itemCount: snapshot.data.docs.length,
                        );
                      }

                      if (snapshot.hasError) {
                        return Text(snapshot.error.toString());
                      }

                      return Container(height: 100, child: Center(child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            bluePurple),
                      ),),);
                    },
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      FocusScope.of(context).requestFocus(new FocusNode());
                      Navigator.of(context).pop(false);
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: blueDesign, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              );
            });


        if(hasSelectedUser){

          bool success;

          if(widget.edit){
            success = await context.read<BookingFormModel>().editBookingForm(widget.jobId);
            FocusScope.of(context).requestFocus(new FocusNode());

          } else {
            success = await context.read<BookingFormModel>().submitBookingForm(widget.jobId);
            FocusScope.of(context).requestFocus(new FocusNode());
          }

          if(success){
            setState(() {
              jobRef.clear();
              bfRequestedBy.clear();
              bfJobTitle.clear();
              bfJobContact.clear();
              bfJobAuthorisingManager.clear();
              bfJobDate.clear();
              bfJobTime.clear();
              bfTransportCoordinator.clear();
              bfCollectionAddress.clear();
              bfCollectionPostcode.clear();
              bfCollectionTel.clear();
              bfDestinationAddress.clear();
              bfDestinationPostcode.clear();
              bfDestinationTel.clear();
              bfInvoiceDetails.clear();
              bfCostCode.clear();
              bfPurchaseOrder.clear();
              bfCollectionDateTime.clear();
              bfPatientName.clear();
              bfLegalStatus.clear();
              bfDateOfBirth.clear();
              bfNhsNumber.clear();
              bfGender.clear();
              bfEthnicity.clear();
              bfCovidStatus.clear();
              bfRmn = 'Select One';
              bfHca = 'Select One';
              bfHca1.clear();
              bfHca2.clear();
              bfHca3.clear();
              bfHca4.clear();
              bfHca5.clear();
              bfCurrentPresentation.clear();
              bfSpecificCarePlanYes = false;
              bfSpecificCarePlanNo = false;
              bfSpecificCarePlan.clear();
              bfPatientWarningsYes = false;
              bfPatientWarningsNo = false;
              bfPatientWarnings.clear();
              bfPresentingRisks.clear();
              bfPreviousRisks.clear();
              bfGenderConcernsYes = false;
              bfGenderConcernsNo = false;
              bfGenderConcerns.clear();
              bfSafeguardingConcernsYes = false;
              bfSafeguardingConcernsNo = false;
              bfSafeguardingConcerns.clear();
              bfTimeDue.clear();
              bfAmbulanceRegistration.clear();
              FocusScope.of(context).requestFocus(new FocusNode());
            });
          }

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
                  _textFormField('Requested by', bfRequestedBy, 1, true),
                  _textFormField('Job Title', bfJobTitle, 1, true),
                  _textFormField('Contact Telephone Number', bfJobContact, 1, true),
                  _textFormField('Authorising Managers Name', bfJobAuthorisingManager, 1, true),
                  _buildDateField('Date', bfJobDate, Strings.bfJobDate, true, false),
                  _buildTimeField('Time', bfJobTime, Strings.bfJobTime, true),
                  _textFormField('Invoice Details', bfInvoiceDetails, 4, false, TextInputType.multiline),
                  _textFormField('Cost code', bfCostCode),
                  _textFormField('Purchase Order no', bfPurchaseOrder),
                  _textFormField('Transport Coordinator Name', bfTransportCoordinator, 1, true),
                  _buildStartDateTimeField(),
                  _textFormField('Patient Collection Address', bfCollectionAddress, 2, true, TextInputType.multiline),
                  _textFormField('Postcode', bfCollectionPostcode, 1, true),
                  _textFormField('Tel', bfCollectionTel, 1, true),
                  _textFormField('Patient Destination Address', bfDestinationAddress, 1, true),
                  _textFormField('Postcode', bfDestinationPostcode, 1, true),
                  _textFormField('Tel', bfDestinationTel),
                  SizedBox(height: 10,),
                  Text('Patient Details', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 18),),
                  SizedBox(height: 5,),
                  _textFormField('Name', bfPatientName, 1, true),
                  _textFormField('Legal Status', bfLegalStatus, 1, true),
                  _buildDateField('Date of birth', bfDateOfBirth, Strings.bfDateOfBirth, true, true),
                  _textFormField('NHS Number', bfNhsNumber, 1, true),
                  _textFormField('Gender', bfGender, 1, true),
                  _textFormField('Ethnicity', bfEthnicity, 1, true),
                  _textFormField('Covid Status', bfCovidStatus, 1, true),
                  _textFormField('Current Presentation', bfCurrentPresentation, 3, true, TextInputType.multiline),
                  _buildRmnDrop(),
                  _buildHcaDrop(),
                  bfHca == '1' ? Column(children: [
                    _textFormField('1.', bfHca1),

                  ],) : Container(),
                  bfHca == '2' ? Column(children: [
                    _textFormField('1.', bfHca1),
                    _textFormField('2.', bfHca2),

                  ],) : Container(),
                  bfHca == '3' ? Column(children: [
                    _textFormField('1.', bfHca1),
                    _textFormField('2.', bfHca2),
                    _textFormField('3.', bfHca3),

                  ],) : Container(),
                  bfHca == '4' ? Column(children: [
                    _textFormField('1.', bfHca1),
                    _textFormField('2.', bfHca2),
                    _textFormField('3.', bfHca3),
                    _textFormField('4.', bfHca4),

                  ],) : Container(),
                  bfHca == '5' ? Column(children: [
                    _textFormField('1.', bfHca1),
                    _textFormField('2.', bfHca2),
                    _textFormField('3.', bfHca3),
                    _textFormField('4.', bfHca4),
                    _textFormField('5.', bfHca5),

                  ],) : Container(),
                  _buildSpecificCarePlanCheckboxes(),
                  bfSpecificCarePlanYes ? _textFormField('Details', bfSpecificCarePlan, 2, bfSpecificCarePlanYes, TextInputType.multiline)
                      : Container(),
                  _buildPatientWarningsCheckboxes(),
                  bfPatientWarningsYes ? _textFormField('Details', bfPatientWarnings, 2, bfPatientWarningsYes, TextInputType.multiline)
                      : Container(),
                  _textFormField('Presenting Risks: (inc physical health, covid symptoms)', bfPresentingRisks, 2, true, TextInputType.multiline),
                  _textFormField('Previous Risk History: (inc physical health, covid symptoms)', bfPreviousRisks, 2, true, TextInputType.multiline),
                  _buildGenderConcernsCheckboxes(),
                  bfGenderConcernsYes ? _textFormField('Details', bfGenderConcerns, 2, bfGenderConcernsYes, TextInputType.multiline)
                      : Container(),
                  _buildSafeguardingConcernsCheckboxes(),
                  bfSafeguardingConcernsYes ? _textFormField('Details', bfSafeguardingConcerns, 2, bfSafeguardingConcernsYes, TextInputType.multiline)
                      : Container(),
                  _textFormField('Ambulance Registration', bfAmbulanceRegistration, 1, true),
                  _buildTimeField('Time Due at Base', bfTimeDue, Strings.bfTimeDue, true),
                  SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(child: Text('•	Please ensure that all members of staff have had sufficient rest prior to this transfer', style: TextStyle(color: Colors.black, fontSize: 16),),),
                    ],
                  ),
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
            child: Text('Transport Booking', style: TextStyle(fontWeight: FontWeight.bold),)),
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

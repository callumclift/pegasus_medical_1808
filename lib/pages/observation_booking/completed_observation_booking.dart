import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pegasus_medical_1808/models/observation_booking_model.dart';
import 'package:pegasus_medical_1808/models/share_option.dart';
import 'package:pegasus_medical_1808/services/navigation_service.dart';
import 'package:pegasus_medical_1808/shared/global_config.dart';
import 'package:pegasus_medical_1808/shared/global_functions.dart';
import 'package:pegasus_medical_1808/shared/strings.dart';
import 'package:pegasus_medical_1808/widgets/app_bar_gradient.dart';
import 'package:provider/provider.dart';

import '../../locator.dart';
import 'observation_booking.dart';
import '../../constants/route_paths.dart' as routes;



class CompletedObservationBooking extends StatefulWidget {

  @override
  _CompletedObservationBookingState createState() => _CompletedObservationBookingState();
}

class _CompletedObservationBookingState extends State<CompletedObservationBooking> {

  ObservationBookingModel observationBookingModel;
  bool okPressed = false;

  @override
  void initState() {
    // TODO: implement initState
    observationBookingModel = Provider.of<ObservationBookingModel>(context, listen: false);
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
        await FirebaseFirestore.instance.collection('observation_bookings').doc(observationBookingModel.selectedObservationBooking[Strings.documentId]).delete().timeout(Duration(seconds: 60));
        GlobalFunctions.dismissLoadingDialog();

        setState(() {
          okPressed = false;
        });
        observationBookingModel.clearObservationBookings();
        final NavigationService _navigationService = locator<NavigationService>();
        _navigationService.navigateToReplacement(routes.ObservationBookingListPageRoute);
      }});
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


  Widget _buildMhaAssessmentRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Is the patient awaiting a MHA Assessment?', style: TextStyle(color: Colors.grey, fontSize: 12),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: observationBookingModel.selectedObservationBooking[Strings.obMhaAssessmentYes] == null || observationBookingModel.selectedObservationBooking[Strings.obMhaAssessmentYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: observationBookingModel.selectedObservationBooking[Strings.obMhaAssessmentNo] == null || observationBookingModel.selectedObservationBooking[Strings.obMhaAssessmentNo] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }

  Widget _buildBedIdentifiedRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Has a bed been identified?', style: TextStyle(color: Colors.grey, fontSize: 12),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: observationBookingModel.selectedObservationBooking[Strings.obBedIdentifiedYes] == null || observationBookingModel.selectedObservationBooking[Strings.obBedIdentifiedYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: observationBookingModel.selectedObservationBooking[Strings.obBedIdentifiedNo] == null || observationBookingModel.selectedObservationBooking[Strings.obBedIdentifiedNo] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }

  Widget _buildWrapDocumentationRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Wrap documentation available?', style: TextStyle(color: Colors.grey, fontSize: 12),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: observationBookingModel.selectedObservationBooking[Strings.obWrapDocumentationYes] == null || observationBookingModel.selectedObservationBooking[Strings.obWrapDocumentationYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: observationBookingModel.selectedObservationBooking[Strings.obWrapDocumentationNo] == null || observationBookingModel.selectedObservationBooking[Strings.obWrapDocumentationNo] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }

  Widget _buildSpecificCarePlanRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Specific Care Plan', style: TextStyle(color: Colors.grey, fontSize: 12),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: observationBookingModel.selectedObservationBooking[Strings.obSpecificCarePlanYes] == null || observationBookingModel.selectedObservationBooking[Strings.obSpecificCarePlanYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: observationBookingModel.selectedObservationBooking[Strings.obSpecificCarePlanNo] == null || observationBookingModel.selectedObservationBooking[Strings.obSpecificCarePlanNo] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }

  Widget _buildPatientWarningsRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Patient warnings/markers', style: TextStyle(color: Colors.grey, fontSize: 12),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: observationBookingModel.selectedObservationBooking[Strings.obPatientWarningsYes] == null || observationBookingModel.selectedObservationBooking[Strings.obPatientWarningsYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: observationBookingModel.selectedObservationBooking[Strings.obPatientWarningsNo] == null || observationBookingModel.selectedObservationBooking[Strings.obPatientWarningsNo] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }

  Widget _buildGenderConcernsRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Gender/Race/sexual Behaviour concerns', style: TextStyle(color: Colors.grey, fontSize: 12),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: observationBookingModel.selectedObservationBooking[Strings.obGenderConcernsYes] == null || observationBookingModel.selectedObservationBooking[Strings.obGenderConcernsYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: observationBookingModel.selectedObservationBooking[Strings.obGenderConcernsNo] == null || observationBookingModel.selectedObservationBooking[Strings.obGenderConcernsNo] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }

  Widget _buildSafeguardingConcernsRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Safeguarding Concerns', style: TextStyle(color: Colors.grey, fontSize: 12),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: observationBookingModel.selectedObservationBooking[Strings.obSafeguardingConcernsYes] == null || observationBookingModel.selectedObservationBooking[Strings.obSafeguardingConcernsYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: observationBookingModel.selectedObservationBooking[Strings.obSafeguardingConcernsNo] == null || observationBookingModel.selectedObservationBooking[Strings.obSafeguardingConcernsNo] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }



  _generatePdf(BuildContext context) async {
    showDialog(barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return EmailDialog(observationBookingModel);
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

              await observationBookingModel.sharePdf(ShareOption.Print);

            }
          } if (value == share) {

            if (connectivityResult == ConnectivityResult.none) {
              GlobalFunctions.showToast(
                  'No data connection unable to share form');
            } else {

              await observationBookingModel.sharePdf(ShareOption.Share);

            }

          } if (value == download) {

            if (connectivityResult == ConnectivityResult.none) {
              GlobalFunctions.showToast(
                  'No data connection unable to download form');
            } else {

              await observationBookingModel.sharePdf(ShareOption.Download);

            }

          } else if(value == edit){

            //Sembast
            await context.read<ObservationBookingModel>().setUpEditedRecord();

            //Sqlflite
            //await context.read<ObservationBookingModel>().setUpEditedObservationBooking();

            Navigator.of(context).push(
                MaterialPageRoute(builder: (BuildContext context) {
                  return ObservationBooking(false, '1', false, true);
                })).then((_) {

              //Sembast
              context.read<ObservationBookingModel>().deleteEditedRecord();

              //Sqlflite
              //context.read<ObservationBookingModel>().deleteEditedObservationBooking();
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

    return observationBookingModel.selectedObservationBooking == null ? Container() : GestureDetector(
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
                _textFormField('Reference', GlobalFunctions.databaseValueString(observationBookingModel.selectedObservationBooking[Strings.jobRef])),
                _textFormField('Requested by', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obRequestedBy])),
                _textFormField('Job Title', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obJobTitle])),
                _textFormField('Contact Telephone Number', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obJobContact])),
                _textFormField('Authorising Manager', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obJobAuthorisingManager])),
                _buildDateField('Date', GlobalFunctions.databaseValueDate(observationBookingModel.selectedObservationBooking[Strings.obJobDate], false)),
                _buildTimeField('Time', GlobalFunctions.databaseValueTime(observationBookingModel.selectedObservationBooking[Strings.obJobTime])),
                _textFormField('Invoice Details', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obInvoiceDetails])),
                _textFormField('Cost code', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obCostCode])),
                _textFormField('Purchase Order no', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obPurchaseOrder])),
                _textFormField('Booking Coordinator', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obBookingCoordinator])),
                _textFormField('Patient Location Address', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obPatientLocation])),
                _textFormField('Postcode', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obPostcode])),
                _textFormField('Location Tel', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obLocationTel])),
                _buildDateField('Start Date & Time', GlobalFunctions.databaseValueDateTime(observationBookingModel.selectedObservationBooking[Strings.obStartDateTime], false)),
                SizedBox(height: 10,),
                _buildMhaAssessmentRow(),
                SizedBox(height: 10,),
                _buildBedIdentifiedRow(),
                SizedBox(height: 10,),
                _buildWrapDocumentationRow(),
                SizedBox(height: 10,),
                _textFormField('What shift do you require?', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obShiftRequired])),
                SizedBox(height: 10,),
                Text('Patient Details', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),),
                SizedBox(height: 10,),
                _textFormField('Name', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obPatientName])),
                _textFormField('Legal Status', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obLegalStatus])),
                _buildDateField('Date of birth', GlobalFunctions.databaseValueDate(observationBookingModel.selectedObservationBooking[Strings.obDateOfBirth], true)),
                _textFormField('NHS Number', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obNhsNumber])),
                _textFormField('Gender', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obGender])),
                _textFormField('Ethnicity', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obEthnicity])),
                _textFormField('Covid Status', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obCovidStatus])),
                _textFormField('Current Presentation: (Reason for attending ED/Acute Hospital)', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obCurrentPresentation])),
                _textFormField('RMN', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obRmn])),
                _textFormField("HCA's", GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obHca])),
                observationBookingModel.selectedObservationBooking[Strings.obHca1] != null && observationBookingModel.selectedObservationBooking[Strings.obHca1] != '' ? _textFormField('1.', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obHca1])) : Container(),
                observationBookingModel.selectedObservationBooking[Strings.obHca2] != null && observationBookingModel.selectedObservationBooking[Strings.obHca2] != '' ? _textFormField('2.', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obHca2])) : Container(),
                observationBookingModel.selectedObservationBooking[Strings.obHca3] != null && observationBookingModel.selectedObservationBooking[Strings.obHca3] != '' ? _textFormField('3.', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obHca3])) : Container(),
                observationBookingModel.selectedObservationBooking[Strings.obHca4] != null && observationBookingModel.selectedObservationBooking[Strings.obHca4] != '' ? _textFormField('4.', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obHca4])) : Container(),
                observationBookingModel.selectedObservationBooking[Strings.obHca5] != null && observationBookingModel.selectedObservationBooking[Strings.obHca5] != '' ? _textFormField('5.', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obHca5])) : Container(),
                Container(),
                SizedBox(height: 10,),
                _buildSpecificCarePlanRow(),
                observationBookingModel.selectedObservationBooking[Strings.obSpecificCarePlanYes] == 1 ? _textFormField('', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obSpecificCarePlan])) :
                Container(),
                SizedBox(height: 10,),
                _buildPatientWarningsRow(),
                observationBookingModel.selectedObservationBooking[Strings.obPatientWarningsYes] == 1 ? _textFormField('', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obPatientWarnings])) :
                Container(),
                SizedBox(height: 10,),
                _textFormField('Presenting Risks: (inc physical health, covid symptoms)', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obPresentingRisks])),
                _textFormField('Previous Risk History: (inc physical health, covid symptoms)', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obPreviousRisks])),
                SizedBox(height: 10,),
                _buildGenderConcernsRow(),
                observationBookingModel.selectedObservationBooking[Strings.obGenderConcernsYes] == 1 ? _textFormField('', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obGenderConcerns])) :
                Container(),
                SizedBox(height: 10,),
                _buildSafeguardingConcernsRow(),
                observationBookingModel.selectedObservationBooking[Strings.obSafeguardingConcernsYes] == 1 ? _textFormField('', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obSafeguardingConcerns])) :
                Container(),
                SizedBox(height: 10,),
                _buildTimeField('Time Due at Location', GlobalFunctions.databaseValueTime(observationBookingModel.selectedObservationBooking[Strings.obTimeDue])),
                SizedBox(height: 10,),
                Text('Staffing', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),),
                SizedBox(height: 5,),
                Column(children: [
                  Container(decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey)
                  ),
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        _buildDateField('Date', GlobalFunctions.databaseValueDate(observationBookingModel.selectedObservationBooking[Strings.obStaffDate1])),
                        _buildTimeField('Start Time', GlobalFunctions.databaseValueTime(observationBookingModel.selectedObservationBooking[Strings.obStaffStartTime1])),
                        _buildTimeField('End Time', GlobalFunctions.databaseValueTime(observationBookingModel.selectedObservationBooking[Strings.obStaffEndTime1])),
                        _textFormField('Name', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obStaffName1])),
                        _textFormField('RMN/HCA', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obStaffRmn1])),
                      ],
                    ),),
                  SizedBox(height: 10,),
                ],),

                observationBookingModel.selectedObservationBooking[Strings.obStaffName2] != null && observationBookingModel.selectedObservationBooking[Strings.obStaffName2] != '' ?
                Column(children: [
                  Container(decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey)
                  ),
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        _buildDateField('Date', GlobalFunctions.databaseValueDate(observationBookingModel.selectedObservationBooking[Strings.obStaffDate2])),
                        _buildTimeField('Start Time', GlobalFunctions.databaseValueTime(observationBookingModel.selectedObservationBooking[Strings.obStaffStartTime2])),
                        _buildTimeField('End Time', GlobalFunctions.databaseValueTime(observationBookingModel.selectedObservationBooking[Strings.obStaffEndTime2])),
                        _textFormField('Name', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obStaffName2])),
                        _textFormField('RMN/HCA', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obStaffRmn2])),
                      ],
                    ),),
                  SizedBox(height: 10,),
                ],) : Container(),
                observationBookingModel.selectedObservationBooking[Strings.obStaffName3] != null && observationBookingModel.selectedObservationBooking[Strings.obStaffName3] != '' ?
                Column(children: [
                  Container(decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey)
                  ),
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        _buildDateField('Date', GlobalFunctions.databaseValueDate(observationBookingModel.selectedObservationBooking[Strings.obStaffDate3])),
                        _buildTimeField('Start Time', GlobalFunctions.databaseValueTime(observationBookingModel.selectedObservationBooking[Strings.obStaffStartTime3])),
                        _buildTimeField('End Time', GlobalFunctions.databaseValueTime(observationBookingModel.selectedObservationBooking[Strings.obStaffEndTime3])),
                        _textFormField('Name', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obStaffName3])),
                        _textFormField('RMN/HCA', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obStaffRmn3])),
                      ],
                    ),),
                  SizedBox(height: 10,),
                ],) : Container(),
                observationBookingModel.selectedObservationBooking[Strings.obStaffName4] != null && observationBookingModel.selectedObservationBooking[Strings.obStaffName4] != '' ?
                Column(children: [
                  Container(decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey)
                  ),
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        _buildDateField('Date', GlobalFunctions.databaseValueDate(observationBookingModel.selectedObservationBooking[Strings.obStaffDate4])),
                        _buildTimeField('Start Time', GlobalFunctions.databaseValueTime(observationBookingModel.selectedObservationBooking[Strings.obStaffStartTime4])),
                        _buildTimeField('End Time', GlobalFunctions.databaseValueTime(observationBookingModel.selectedObservationBooking[Strings.obStaffEndTime4])),
                        _textFormField('Name', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obStaffName4])),
                        _textFormField('RMN/HCA', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obStaffRmn4])),
                      ],
                    ),),
                  SizedBox(height: 10,),
                ],) : Container(),
                observationBookingModel.selectedObservationBooking[Strings.obStaffName5] != null && observationBookingModel.selectedObservationBooking[Strings.obStaffName5] != '' ?
                Column(children: [
                  Container(decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey)
                  ),
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        _buildDateField('Date', GlobalFunctions.databaseValueDate(observationBookingModel.selectedObservationBooking[Strings.obStaffDate5])),
                        _buildTimeField('Start Time', GlobalFunctions.databaseValueTime(observationBookingModel.selectedObservationBooking[Strings.obStaffStartTime5])),
                        _buildTimeField('End Time', GlobalFunctions.databaseValueTime(observationBookingModel.selectedObservationBooking[Strings.obStaffEndTime5])),
                        _textFormField('Name', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obStaffName5])),
                        _textFormField('RMN/HCA', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obStaffRmn5])),
                      ],
                    ),),
                  SizedBox(height: 10,),
                ],) : Container(),
                observationBookingModel.selectedObservationBooking[Strings.obStaffName6] != null && observationBookingModel.selectedObservationBooking[Strings.obStaffName6] != '' ?
                Column(children: [
                  Container(decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey)
                  ),
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        _buildDateField('Date', GlobalFunctions.databaseValueDate(observationBookingModel.selectedObservationBooking[Strings.obStaffDate6])),
                        _buildTimeField('Start Time', GlobalFunctions.databaseValueTime(observationBookingModel.selectedObservationBooking[Strings.obStaffStartTime6])),
                        _buildTimeField('End Time', GlobalFunctions.databaseValueTime(observationBookingModel.selectedObservationBooking[Strings.obStaffEndTime6])),
                        _textFormField('Name', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obStaffName6])),
                        _textFormField('RMN/HCA', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obStaffRmn6])),
                      ],
                    ),),
                  SizedBox(height: 10,),
                ],) : Container(),
                observationBookingModel.selectedObservationBooking[Strings.obStaffName7] != null && observationBookingModel.selectedObservationBooking[Strings.obStaffName7] != '' ?
                Column(children: [
                  Container(decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey)
                  ),
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        _buildDateField('Date', GlobalFunctions.databaseValueDate(observationBookingModel.selectedObservationBooking[Strings.obStaffDate7])),
                        _buildTimeField('Start Time', GlobalFunctions.databaseValueTime(observationBookingModel.selectedObservationBooking[Strings.obStaffStartTime7])),
                        _buildTimeField('End Time', GlobalFunctions.databaseValueTime(observationBookingModel.selectedObservationBooking[Strings.obStaffEndTime7])),
                        _textFormField('Name', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obStaffName7])),
                        _textFormField('RMN/HCA', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obStaffRmn7])),
                      ],
                    ),),
                  SizedBox(height: 10,),
                ],) : Container(),
                observationBookingModel.selectedObservationBooking[Strings.obStaffName8] != null && observationBookingModel.selectedObservationBooking[Strings.obStaffName8] != '' ?
                Column(children: [
                  Container(decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey)
                  ),
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        _buildDateField('Date', GlobalFunctions.databaseValueDate(observationBookingModel.selectedObservationBooking[Strings.obStaffDate8])),
                        _buildTimeField('Start Time', GlobalFunctions.databaseValueTime(observationBookingModel.selectedObservationBooking[Strings.obStaffStartTime8])),
                        _buildTimeField('End Time', GlobalFunctions.databaseValueTime(observationBookingModel.selectedObservationBooking[Strings.obStaffEndTime8])),
                        _textFormField('Name', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obStaffName8])),
                        _textFormField('RMN/HCA', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obStaffRmn8])),
                      ],
                    ),),
                  SizedBox(height: 10,),
                ],) : Container(),
                observationBookingModel.selectedObservationBooking[Strings.obStaffName9] != null && observationBookingModel.selectedObservationBooking[Strings.obStaffName9] != '' ?
                Column(children: [
                  Container(decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey)
                  ),
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        _buildDateField('Date', GlobalFunctions.databaseValueDate(observationBookingModel.selectedObservationBooking[Strings.obStaffDate9])),
                        _buildTimeField('Start Time', GlobalFunctions.databaseValueTime(observationBookingModel.selectedObservationBooking[Strings.obStaffStartTime9])),
                        _buildTimeField('End Time', GlobalFunctions.databaseValueTime(observationBookingModel.selectedObservationBooking[Strings.obStaffEndTime9])),
                        _textFormField('Name', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obStaffName9])),
                        _textFormField('RMN/HCA', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obStaffRmn9])),
                      ],
                    ),),
                  SizedBox(height: 10,),
                ],) : Container(),
                observationBookingModel.selectedObservationBooking[Strings.obStaffName10] != null && observationBookingModel.selectedObservationBooking[Strings.obStaffName10] != '' ?
                Column(children: [
                  Container(decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey)
                  ),
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        _buildDateField('Date', GlobalFunctions.databaseValueDate(observationBookingModel.selectedObservationBooking[Strings.obStaffDate10])),
                        _buildTimeField('Start Time', GlobalFunctions.databaseValueTime(observationBookingModel.selectedObservationBooking[Strings.obStaffStartTime10])),
                        _buildTimeField('End Time', GlobalFunctions.databaseValueTime(observationBookingModel.selectedObservationBooking[Strings.obStaffEndTime10])),
                        _textFormField('Name', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obStaffName10])),
                        _textFormField('RMN/HCA', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obStaffRmn10])),
                      ],
                    ),),
                  SizedBox(height: 10,),
                ],) : Container(),
                observationBookingModel.selectedObservationBooking[Strings.obStaffName11] != null && observationBookingModel.selectedObservationBooking[Strings.obStaffName11] != '' ?
                Column(children: [
                  Container(decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey)
                  ),
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        _buildDateField('Date', GlobalFunctions.databaseValueDate(observationBookingModel.selectedObservationBooking[Strings.obStaffDate11])),
                        _buildTimeField('Start Time', GlobalFunctions.databaseValueTime(observationBookingModel.selectedObservationBooking[Strings.obStaffStartTime11])),
                        _buildTimeField('End Time', GlobalFunctions.databaseValueTime(observationBookingModel.selectedObservationBooking[Strings.obStaffEndTime11])),
                        _textFormField('Name', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obStaffName11])),
                        _textFormField('RMN/HCA', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obStaffRmn11])),
                      ],
                    ),),
                  SizedBox(height: 10,),
                ],) : Container(),
                observationBookingModel.selectedObservationBooking[Strings.obStaffName12] != null && observationBookingModel.selectedObservationBooking[Strings.obStaffName12] != '' ?
                Column(children: [
                  Container(decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey)
                  ),
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        _buildDateField('Date', GlobalFunctions.databaseValueDate(observationBookingModel.selectedObservationBooking[Strings.obStaffDate12])),
                        _buildTimeField('Start Time', GlobalFunctions.databaseValueTime(observationBookingModel.selectedObservationBooking[Strings.obStaffStartTime12])),
                        _buildTimeField('End Time', GlobalFunctions.databaseValueTime(observationBookingModel.selectedObservationBooking[Strings.obStaffEndTime12])),
                        _textFormField('Name', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obStaffName12])),
                        _textFormField('RMN/HCA', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obStaffRmn12])),
                      ],
                    ),),
                  SizedBox(height: 10,),
                ],) : Container(),
                observationBookingModel.selectedObservationBooking[Strings.obStaffName13] != null && observationBookingModel.selectedObservationBooking[Strings.obStaffName13] != '' ?
                Column(children: [
                  Container(decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey)
                  ),
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        _buildDateField('Date', GlobalFunctions.databaseValueDate(observationBookingModel.selectedObservationBooking[Strings.obStaffDate13])),
                        _buildTimeField('Start Time', GlobalFunctions.databaseValueTime(observationBookingModel.selectedObservationBooking[Strings.obStaffStartTime13])),
                        _buildTimeField('End Time', GlobalFunctions.databaseValueTime(observationBookingModel.selectedObservationBooking[Strings.obStaffEndTime13])),
                        _textFormField('Name', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obStaffName13])),
                        _textFormField('RMN/HCA', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obStaffRmn13])),
                      ],
                    ),),
                  SizedBox(height: 10,),
                ],) : Container(),
                observationBookingModel.selectedObservationBooking[Strings.obStaffName14] != null && observationBookingModel.selectedObservationBooking[Strings.obStaffName14] != '' ?
                Column(children: [
                  Container(decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey)
                  ),
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        _buildDateField('Date', GlobalFunctions.databaseValueDate(observationBookingModel.selectedObservationBooking[Strings.obStaffDate14])),
                        _buildTimeField('Start Time', GlobalFunctions.databaseValueTime(observationBookingModel.selectedObservationBooking[Strings.obStaffStartTime14])),
                        _buildTimeField('End Time', GlobalFunctions.databaseValueTime(observationBookingModel.selectedObservationBooking[Strings.obStaffEndTime14])),
                        _textFormField('Name', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obStaffName14])),
                        _textFormField('RMN/HCA', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obStaffRmn14])),
                      ],
                    ),),
                  SizedBox(height: 10,),
                ],) : Container(),
                observationBookingModel.selectedObservationBooking[Strings.obStaffName15] != null && observationBookingModel.selectedObservationBooking[Strings.obStaffName15] != '' ?
                Column(children: [
                  Container(decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey)
                  ),
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        _buildDateField('Date', GlobalFunctions.databaseValueDate(observationBookingModel.selectedObservationBooking[Strings.obStaffDate15])),
                        _buildTimeField('Start Time', GlobalFunctions.databaseValueTime(observationBookingModel.selectedObservationBooking[Strings.obStaffStartTime15])),
                        _buildTimeField('End Time', GlobalFunctions.databaseValueTime(observationBookingModel.selectedObservationBooking[Strings.obStaffEndTime15])),
                        _textFormField('Name', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obStaffName15])),
                        _textFormField('RMN/HCA', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obStaffRmn15])),
                      ],
                    ),),
                  SizedBox(height: 10,),
                ],) : Container(),
                observationBookingModel.selectedObservationBooking[Strings.obStaffName16] != null && observationBookingModel.selectedObservationBooking[Strings.obStaffName16] != '' ?
                Column(children: [
                  Container(decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey)
                  ),
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        _buildDateField('Date', GlobalFunctions.databaseValueDate(observationBookingModel.selectedObservationBooking[Strings.obStaffDate16])),
                        _buildTimeField('Start Time', GlobalFunctions.databaseValueTime(observationBookingModel.selectedObservationBooking[Strings.obStaffStartTime16])),
                        _buildTimeField('End Time', GlobalFunctions.databaseValueTime(observationBookingModel.selectedObservationBooking[Strings.obStaffEndTime16])),
                        _textFormField('Name', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obStaffName16])),
                        _textFormField('RMN/HCA', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obStaffRmn16])),
                      ],
                    ),),
                  SizedBox(height: 10,),
                ],) : Container(),
                observationBookingModel.selectedObservationBooking[Strings.obStaffName17] != null && observationBookingModel.selectedObservationBooking[Strings.obStaffName17] != '' ?
                Column(children: [
                  Container(decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey)
                  ),
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        _buildDateField('Date', GlobalFunctions.databaseValueDate(observationBookingModel.selectedObservationBooking[Strings.obStaffDate17])),
                        _buildTimeField('Start Time', GlobalFunctions.databaseValueTime(observationBookingModel.selectedObservationBooking[Strings.obStaffStartTime17])),
                        _buildTimeField('End Time', GlobalFunctions.databaseValueTime(observationBookingModel.selectedObservationBooking[Strings.obStaffEndTime17])),
                        _textFormField('Name', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obStaffName17])),
                        _textFormField('RMN/HCA', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obStaffRmn17])),
                      ],
                    ),),
                  SizedBox(height: 10,),
                ],) : Container(),
                observationBookingModel.selectedObservationBooking[Strings.obStaffName18] != null && observationBookingModel.selectedObservationBooking[Strings.obStaffName18] != '' ?
                Column(children: [
                  Container(decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey)
                  ),
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        _buildDateField('Date', GlobalFunctions.databaseValueDate(observationBookingModel.selectedObservationBooking[Strings.obStaffDate18])),
                        _buildTimeField('Start Time', GlobalFunctions.databaseValueTime(observationBookingModel.selectedObservationBooking[Strings.obStaffStartTime18])),
                        _buildTimeField('End Time', GlobalFunctions.databaseValueTime(observationBookingModel.selectedObservationBooking[Strings.obStaffEndTime18])),
                        _textFormField('Name', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obStaffName18])),
                        _textFormField('RMN/HCA', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obStaffRmn18])),
                      ],
                    ),),
                  SizedBox(height: 10,),
                ],) : Container(),
                observationBookingModel.selectedObservationBooking[Strings.obStaffName19] != null && observationBookingModel.selectedObservationBooking[Strings.obStaffName19] != '' ?
                Column(children: [
                  Container(decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey)
                  ),
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        _buildDateField('Date', GlobalFunctions.databaseValueDate(observationBookingModel.selectedObservationBooking[Strings.obStaffDate19])),
                        _buildTimeField('Start Time', GlobalFunctions.databaseValueTime(observationBookingModel.selectedObservationBooking[Strings.obStaffStartTime19])),
                        _buildTimeField('End Time', GlobalFunctions.databaseValueTime(observationBookingModel.selectedObservationBooking[Strings.obStaffEndTime19])),
                        _textFormField('Name', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obStaffName19])),
                        _textFormField('RMN/HCA', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obStaffRmn19])),
                      ],
                    ),),
                  SizedBox(height: 10,),
                ],) : Container(),
                observationBookingModel.selectedObservationBooking[Strings.obStaffName20] != null && observationBookingModel.selectedObservationBooking[Strings.obStaffName20] != '' ?
                Column(children: [
                  Container(decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey)
                  ),
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        _buildDateField('Date', GlobalFunctions.databaseValueDate(observationBookingModel.selectedObservationBooking[Strings.obStaffDate20])),
                        _buildTimeField('Start Time', GlobalFunctions.databaseValueTime(observationBookingModel.selectedObservationBooking[Strings.obStaffStartTime20])),
                        _buildTimeField('End Time', GlobalFunctions.databaseValueTime(observationBookingModel.selectedObservationBooking[Strings.obStaffEndTime20])),
                        _textFormField('Name', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obStaffName20])),
                        _textFormField('RMN/HCA', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obStaffRmn20])),
                      ],
                    ),),
                  SizedBox(height: 10,),
                ],) : Container(),
                _textFormField('Useful Details', GlobalFunctions.decryptString(observationBookingModel.selectedObservationBooking[Strings.obUsefulDetails])),
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
            child: Text('Observation Booking', style: TextStyle(fontWeight: FontWeight.bold),)),
        actions: <Widget>[
          _buildShareButton(context)
        ],
      ),
      body: _buildPageContent(context),
    );
  }
}


class EmailDialog extends StatefulWidget {

  final observationBookingModel;

  EmailDialog(this.observationBookingModel);

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

                bool success = await widget.observationBookingModel.sharePdf(ShareOption.Email, emailListTrimmed);

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

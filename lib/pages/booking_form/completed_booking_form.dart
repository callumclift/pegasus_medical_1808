import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pegasus_medical_1808/models/booking_form_model.dart';
import 'package:pegasus_medical_1808/models/share_option.dart';
import 'package:pegasus_medical_1808/services/navigation_service.dart';
import 'package:pegasus_medical_1808/shared/global_config.dart';
import 'package:pegasus_medical_1808/shared/global_functions.dart';
import 'package:pegasus_medical_1808/shared/strings.dart';
import 'package:pegasus_medical_1808/widgets/app_bar_gradient.dart';
import 'package:provider/provider.dart';

import '../../locator.dart';
import 'booking_form.dart';
import '../../constants/route_paths.dart' as routes;



class CompletedBookingForm extends StatefulWidget {

  @override
  _CompletedBookingFormState createState() => _CompletedBookingFormState();
}

class _CompletedBookingFormState extends State<CompletedBookingForm> {

  BookingFormModel bookingFormModel;
  bool okPressed = false;

  @override
  void initState() {
    // TODO: implement initState
    bookingFormModel = Provider.of<BookingFormModel>(context, listen: false);
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
        await FirebaseFirestore.instance.collection('booking_forms').doc(bookingFormModel.selectedBookingForm[Strings.documentId]).delete().timeout(Duration(seconds: 60));
        GlobalFunctions.dismissLoadingDialog();

        setState(() {
          okPressed = false;
        });
        bookingFormModel.clearBookingForms();
        final NavigationService _navigationService = locator<NavigationService>();
        _navigationService.navigateToReplacement(routes.BookingFormListPageRoute);
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
                value: bookingFormModel.selectedBookingForm[Strings.bfSpecificCarePlanYes] == null || bookingFormModel.selectedBookingForm[Strings.bfSpecificCarePlanYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: bookingFormModel.selectedBookingForm[Strings.bfSpecificCarePlanNo] == null || bookingFormModel.selectedBookingForm[Strings.bfSpecificCarePlanNo] == 0 ? false : true,
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
                value: bookingFormModel.selectedBookingForm[Strings.bfPatientWarningsYes] == null || bookingFormModel.selectedBookingForm[Strings.bfPatientWarningsYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: bookingFormModel.selectedBookingForm[Strings.bfPatientWarningsNo] == null || bookingFormModel.selectedBookingForm[Strings.bfPatientWarningsNo] == 0 ? false : true,
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
                value: bookingFormModel.selectedBookingForm[Strings.bfGenderConcernsYes] == null || bookingFormModel.selectedBookingForm[Strings.bfGenderConcernsYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: bookingFormModel.selectedBookingForm[Strings.bfGenderConcernsNo] == null || bookingFormModel.selectedBookingForm[Strings.bfGenderConcernsNo] == 0 ? false : true,
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
                value: bookingFormModel.selectedBookingForm[Strings.bfSafeguardingConcernsYes] == null || bookingFormModel.selectedBookingForm[Strings.bfSafeguardingConcernsYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: bookingFormModel.selectedBookingForm[Strings.bfSafeguardingConcernsNo] == null || bookingFormModel.selectedBookingForm[Strings.bfSafeguardingConcernsNo] == 0 ? false : true,
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
          return EmailDialog(bookingFormModel);
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

              await bookingFormModel.sharePdf(ShareOption.Print);

            }
          } if (value == share) {

            if (connectivityResult == ConnectivityResult.none) {
              GlobalFunctions.showToast(
                  'No data connection unable to share form');
            } else {

              await bookingFormModel.sharePdf(ShareOption.Share);

            }

          } if (value == download) {

            if (connectivityResult == ConnectivityResult.none) {
              GlobalFunctions.showToast(
                  'No data connection unable to download form');
            } else {

              await bookingFormModel.sharePdf(ShareOption.Download);

            }

          } else if(value == edit){

            //Sembast
            await context.read<BookingFormModel>().setUpEditedRecord();

            //Sqlflite
            //await context.read<BookingFormModel>().setUpEditedBookingForm();

            Navigator.of(context).push(
                MaterialPageRoute(builder: (BuildContext context) {
                  return BookingForm(false, '1', false, true);
                })).then((_) {

              //Sembast
              context.read<BookingFormModel>().deleteEditedRecord();

              //Sqlflite
              //context.read<BookingFormModel>().deleteEditedBookingForm();
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

    return bookingFormModel.selectedBookingForm == null ? Container() : GestureDetector(
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
                _textFormField('Reference', GlobalFunctions.databaseValueString(bookingFormModel.selectedBookingForm[Strings.jobRef])),
                _textFormField('Requested by', GlobalFunctions.decryptString(bookingFormModel.selectedBookingForm[Strings.bfRequestedBy])),
                _textFormField('Job Title', GlobalFunctions.decryptString(bookingFormModel.selectedBookingForm[Strings.bfJobTitle])),
                _textFormField('Contact Telephone Number', GlobalFunctions.decryptString(bookingFormModel.selectedBookingForm[Strings.bfJobContact])),
                _textFormField('Authorising Managers Name', GlobalFunctions.decryptString(bookingFormModel.selectedBookingForm[Strings.bfJobAuthorisingManager])),
                _buildDateField('Date', GlobalFunctions.databaseValueDate(bookingFormModel.selectedBookingForm[Strings.bfJobDate], false)),
                _buildTimeField('Time', GlobalFunctions.databaseValueTime(bookingFormModel.selectedBookingForm[Strings.bfJobTime])),
                _textFormField('Invoice Details', GlobalFunctions.decryptString(bookingFormModel.selectedBookingForm[Strings.bfInvoiceDetails])),
                _textFormField('Cost code', GlobalFunctions.decryptString(bookingFormModel.selectedBookingForm[Strings.bfCostCode])),
                _textFormField('Purchase Order no', GlobalFunctions.decryptString(bookingFormModel.selectedBookingForm[Strings.bfPurchaseOrder])),
                _textFormField('Transport Coordinator Name', GlobalFunctions.decryptString(bookingFormModel.selectedBookingForm[Strings.bfTransportCoordinator])),
                _buildDateField('Start Date & Time', GlobalFunctions.databaseValueDateTime(bookingFormModel.selectedBookingForm[Strings.bfCollectionDateTime], false)),
                _textFormField('Patient Collection Address', GlobalFunctions.decryptString(bookingFormModel.selectedBookingForm[Strings.bfCollectionAddress])),
                _textFormField('Postcode', GlobalFunctions.decryptString(bookingFormModel.selectedBookingForm[Strings.bfCollectionPostcode])),
                _textFormField('Tel', GlobalFunctions.decryptString(bookingFormModel.selectedBookingForm[Strings.bfCollectionTel])),
                _textFormField('Patient Destination Address', GlobalFunctions.decryptString(bookingFormModel.selectedBookingForm[Strings.bfDestinationAddress])),
                _textFormField('Postcode', GlobalFunctions.decryptString(bookingFormModel.selectedBookingForm[Strings.bfDestinationPostcode])),
                _textFormField('Tel', GlobalFunctions.decryptString(bookingFormModel.selectedBookingForm[Strings.bfDestinationTel])),

                SizedBox(height: 10,),
                Text('Patient Details', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),),
                SizedBox(height: 10,),
                _textFormField('Name', GlobalFunctions.decryptString(bookingFormModel.selectedBookingForm[Strings.bfPatientName])),
                _textFormField('Legal Status', GlobalFunctions.decryptString(bookingFormModel.selectedBookingForm[Strings.bfLegalStatus])),
                _buildDateField('Date of birth', GlobalFunctions.databaseValueDate(bookingFormModel.selectedBookingForm[Strings.bfDateOfBirth], true)),
                _textFormField('NHS Number', GlobalFunctions.decryptString(bookingFormModel.selectedBookingForm[Strings.bfNhsNumber])),
                _textFormField('Gender', GlobalFunctions.decryptString(bookingFormModel.selectedBookingForm[Strings.bfGender])),
                _textFormField('Ethnicity', GlobalFunctions.decryptString(bookingFormModel.selectedBookingForm[Strings.bfEthnicity])),
                _textFormField('Covid Status', GlobalFunctions.decryptString(bookingFormModel.selectedBookingForm[Strings.bfCovidStatus])),
                _textFormField('Current Presentation', GlobalFunctions.decryptString(bookingFormModel.selectedBookingForm[Strings.bfCurrentPresentation])),
                _textFormField('RMN', GlobalFunctions.decryptString(bookingFormModel.selectedBookingForm[Strings.bfRmn])),
                _textFormField("HCA's", GlobalFunctions.decryptString(bookingFormModel.selectedBookingForm[Strings.bfHca])),
                bookingFormModel.selectedBookingForm[Strings.bfHca1] != null && bookingFormModel.selectedBookingForm[Strings.bfHca1] != '' ? _textFormField('1.', GlobalFunctions.decryptString(bookingFormModel.selectedBookingForm[Strings.bfHca1])) : Container(),
                bookingFormModel.selectedBookingForm[Strings.bfHca2] != null && bookingFormModel.selectedBookingForm[Strings.bfHca2] != '' ? _textFormField('2.', GlobalFunctions.decryptString(bookingFormModel.selectedBookingForm[Strings.bfHca2])) : Container(),
                bookingFormModel.selectedBookingForm[Strings.bfHca3] != null && bookingFormModel.selectedBookingForm[Strings.bfHca3] != '' ? _textFormField('3.', GlobalFunctions.decryptString(bookingFormModel.selectedBookingForm[Strings.bfHca3])) : Container(),
                bookingFormModel.selectedBookingForm[Strings.bfHca4] != null && bookingFormModel.selectedBookingForm[Strings.bfHca4] != '' ? _textFormField('4.', GlobalFunctions.decryptString(bookingFormModel.selectedBookingForm[Strings.bfHca4])) : Container(),
                bookingFormModel.selectedBookingForm[Strings.bfHca5] != null && bookingFormModel.selectedBookingForm[Strings.bfHca5] != '' ? _textFormField('5.', GlobalFunctions.decryptString(bookingFormModel.selectedBookingForm[Strings.bfHca5])) : Container(),
                Container(),
                SizedBox(height: 10,),
                _buildSpecificCarePlanRow(),
                bookingFormModel.selectedBookingForm[Strings.bfSpecificCarePlanYes] == 1 ? _textFormField('', GlobalFunctions.decryptString(bookingFormModel.selectedBookingForm[Strings.bfSpecificCarePlan])) :
                Container(),
                SizedBox(height: 10,),
                _buildPatientWarningsRow(),
                bookingFormModel.selectedBookingForm[Strings.bfPatientWarningsYes] == 1 ? _textFormField('', GlobalFunctions.decryptString(bookingFormModel.selectedBookingForm[Strings.bfPatientWarnings])) :
                Container(),
                SizedBox(height: 10,),
                _textFormField('Presenting Risks: (inc physical health, covid symptoms)', GlobalFunctions.decryptString(bookingFormModel.selectedBookingForm[Strings.bfPresentingRisks])),
                _textFormField('Previous Risk History: (inc physical health, covid symptoms)', GlobalFunctions.decryptString(bookingFormModel.selectedBookingForm[Strings.bfPreviousRisks])),
                SizedBox(height: 10,),
                _buildGenderConcernsRow(),
                bookingFormModel.selectedBookingForm[Strings.bfGenderConcernsYes] == 1 ? _textFormField('', GlobalFunctions.decryptString(bookingFormModel.selectedBookingForm[Strings.bfGenderConcerns])) :
                Container(),
                SizedBox(height: 10,),
                _buildSafeguardingConcernsRow(),
                bookingFormModel.selectedBookingForm[Strings.bfSafeguardingConcernsYes] == 1 ? _textFormField('', GlobalFunctions.decryptString(bookingFormModel.selectedBookingForm[Strings.bfSafeguardingConcerns])) :
                Container(),
                SizedBox(height: 10,),
                _textFormField('Ambulance Registration', GlobalFunctions.decryptString(bookingFormModel.selectedBookingForm[Strings.bfAmbulanceRegistration])),
                _buildTimeField('Time Due at Location', GlobalFunctions.databaseValueTime(bookingFormModel.selectedBookingForm[Strings.bfTimeDue])),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(child: Text('•	Please ensure that all members of staff have had sufficient rest prior to this transfer', style: TextStyle(color: Colors.black, fontSize: 16),),),
                  ],
                ),                SizedBox(height: 20,),
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
            child: Text('Transport Booking', style: TextStyle(fontWeight: FontWeight.bold),)),
        actions: <Widget>[
          _buildShareButton(context)
        ],
      ),
      body: _buildPageContent(context),
    );
  }
}


class EmailDialog extends StatefulWidget {

  final bookingFormModel;

  EmailDialog(this.bookingFormModel);

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

                bool success = await widget.bookingFormModel.sharePdf(ShareOption.Email, emailListTrimmed);

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

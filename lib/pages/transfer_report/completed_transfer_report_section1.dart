import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pegasus_medical_1808/models/transfer_report_model.dart';
import 'package:pegasus_medical_1808/shared/global_config.dart';
import 'package:pegasus_medical_1808/shared/global_functions.dart';
import 'package:pegasus_medical_1808/shared/strings.dart';
import 'package:provider/provider.dart';


class CompletedTransferReportSection1 extends StatefulWidget {

  @override
  _CompletedTransferReportSection1State createState() => _CompletedTransferReportSection1State();
}

class _CompletedTransferReportSection1State extends State<CompletedTransferReportSection1> {

  bool _loadingTemporary = false;
  TransferReportModel transferReportModel;
  Uint8List collectionImageBytes;
  Uint8List destinationImageBytes;

  @override
  void initState() {
    // TODO: implement initState
    _loadingTemporary = true;
    transferReportModel = Provider.of<TransferReportModel>(context, listen: false);
    _getTemporaryTransferReport();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _getTemporaryTransferReport() async {
    if (mounted) {
        if (transferReportModel.selectedTransferReport[Strings.collectionSignature] != null) {
            collectionImageBytes = await GlobalFunctions.decryptSignature(transferReportModel.selectedTransferReport[Strings.collectionSignature]);
        }
        if (transferReportModel.selectedTransferReport[Strings.destinationSignature] != null) {
          destinationImageBytes = await GlobalFunctions.decryptSignature(transferReportModel.selectedTransferReport[Strings.destinationSignature]);
        }
        if (mounted) {
          setState(() {
            _loadingTemporary = false;
          });
        }

    }
  }

  Widget _buildCollectionSignatureRow() {
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
            child: transferReportModel.selectedTransferReport[Strings.collectionSignature] == null
                ? Text('No signature found')
                : Image.memory(collectionImageBytes),

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
            child: transferReportModel.selectedTransferReport[Strings.destinationSignature] == null
                ? Text('No signature found')
                : Image.memory(destinationImageBytes),

          ),
        )
      ],
    );
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


  Widget _buildCheckboxRowAmbulanceTidyYes1(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(text, style: TextStyle(color: bluePurple),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.ambulanceTidyYes1] == null || transferReportModel.selectedTransferReport[Strings.ambulanceTidyYes1] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.ambulanceTidyNo1] == null || transferReportModel.selectedTransferReport[Strings.ambulanceTidyNo1] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowLightsWorkingYes(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(text, style: TextStyle(color: bluePurple),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.lightsWorkingYes] == null || transferReportModel.selectedTransferReport[Strings.lightsWorkingYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.lightsWorkingNo] == null || transferReportModel.selectedTransferReport[Strings.lightsWorkingNo] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowTyresInflatedYes(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(text, style: TextStyle(color: bluePurple),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.tyresInflatedYes] == null || transferReportModel.selectedTransferReport[Strings.tyresInflatedYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.tyresInflatedNo] == null || transferReportModel.selectedTransferReport[Strings.tyresInflatedNo] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowWarningSignsYes(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(text, style: TextStyle(color: bluePurple),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.warningSignsYes] == null || transferReportModel.selectedTransferReport[Strings.warningSignsYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.warningSignsNo] == null || transferReportModel.selectedTransferReport[Strings.warningSignsNo] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }

  Widget _buildCheckboxRowVehicleDamageYes(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(text, style: TextStyle(color: bluePurple),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.vehicleDamageYes] == null || transferReportModel.selectedTransferReport[Strings.vehicleDamageYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.vehicleDamageNo] == null || transferReportModel.selectedTransferReport[Strings.vehicleDamageNo] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }



  Widget _buildPageContent(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 768.0 ? 600.0 : deviceWidth * 0.95;
    final double targetPadding = deviceWidth - targetWidth;

    return transferReportModel.selectedTransferReport == null ? Container() : GestureDetector(
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
                SizedBox(height: 10,),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('TRANSFER REPORT', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),),
                ],),
                SizedBox(height: 10,),
                _textFormField('Job Ref', GlobalFunctions.databaseValueString(transferReportModel.selectedTransferReport[Strings.jobRef])),
                _buildDateField('Date', GlobalFunctions.databaseValueDate(transferReportModel.selectedTransferReport[Strings.date], false)),
                SizedBox(height: 20,),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('PRE-TRANSFER VEHICLE CHECKLIST', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),),
                ],),
                SizedBox(height: 20,),
                _textFormField('Completed by', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.vehicleCompletedBy1])),
                _textFormField('Ambulance Reg', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.ambulanceReg])),
                //_textFormField('Start Mileage', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.vehicleStartMileage])),
                _textFormField('Fuel to the nearest 1/4 tank', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.nearestTank1])),
                _buildDateField('Date', GlobalFunctions.databaseValueDate(transferReportModel.selectedTransferReport[Strings.vehicleDate])),
                _buildTimeField('Time', GlobalFunctions.databaseValueTime(transferReportModel.selectedTransferReport[Strings.vehicleTime])),
                SizedBox(height: 10,),
                _buildCheckboxRowAmbulanceTidyYes1('• Was the ambulance left clean and tidy?'),
                _buildCheckboxRowLightsWorkingYes('• Ambulance lights working?'),
                _buildCheckboxRowTyresInflatedYes('• Tyres appear inflated fully?'),
                _buildCheckboxRowWarningSignsYes('• Vehicle warning signs showing?'),
                _buildCheckboxRowVehicleDamageYes('• Any damage to vehicle / bodywork?'),
                SizedBox(height: 20,),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('JOB DETAILS', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),),
                ],),
                SizedBox(height: 20,),
                _buildTimeField('Start Time', GlobalFunctions.databaseValueTime(transferReportModel.selectedTransferReport[Strings.startTime])),
                _buildTimeField('Finish Time', GlobalFunctions.databaseValueTime(transferReportModel.selectedTransferReport[Strings.finishTime])),
                _textFormField('Total Hours', GlobalFunctions.databaseValueString(transferReportModel.selectedTransferReport[Strings.totalHours])),
                _textFormField('Collection Details', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.collectionDetails])),
                _textFormField('Postcode', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.collectionPostcode])),
                _textFormField('Contact No.', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.collectionContactNo])),
                _textFormField('Destination Details', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.destinationDetails])),
                _textFormField('Postcode', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.destinationPostcode])),
                _textFormField('Contact No.', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.destinationContactNo])),
                _buildTimeField('Collection arrival time', GlobalFunctions.databaseValueTime(transferReportModel.selectedTransferReport[Strings.collectionArrivalTime])),
                _buildTimeField('Collection departure time', GlobalFunctions.databaseValueTime(transferReportModel.selectedTransferReport[Strings.collectionDepartureTime])),
                _buildTimeField('Destination arrival time', GlobalFunctions.databaseValueTime(transferReportModel.selectedTransferReport[Strings.destinationArrivalTime])),
                _buildTimeField('Destination departure time', GlobalFunctions.databaseValueTime(transferReportModel.selectedTransferReport[Strings.destinationDepartureTime])),
                _textFormField('Vehicle Reg No.', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.vehicleRegNo])),
                _textFormField('Start Mileage', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.startMileage])),
                //_textFormField('Finish Mileage', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.finishMileage])),
                //_textFormField('Total Mileage', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.totalMileage])),
                _textFormField('Name', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.name1])),
                _textFormField('Role', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.role1])),
                _buildTimeField('Driving Times', GlobalFunctions.databaseValueTime(transferReportModel.selectedTransferReport[Strings.drivingTimes1_1])),
                _buildTimeField('Driving Times', GlobalFunctions.databaseValueTime(transferReportModel.selectedTransferReport[Strings.drivingTimes1_2])),

                transferReportModel.selectedTransferReport[Strings.name2] == null || transferReportModel.selectedTransferReport[Strings.name2] == '' ?
                    Container() : Column(
                  children: [
                    _textFormField('Name', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.name2])),
                    _textFormField('Role', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.role2])),
                    _buildTimeField('Driving Times', GlobalFunctions.databaseValueTime(transferReportModel.selectedTransferReport[Strings.drivingTimes2_1])),
                    _buildTimeField('Driving Times', GlobalFunctions.databaseValueTime(transferReportModel.selectedTransferReport[Strings.drivingTimes2_2])),
                  ],
                ),
                transferReportModel.selectedTransferReport[Strings.name3] == null || transferReportModel.selectedTransferReport[Strings.name3] == '' ?
                Container() : Column(
                  children: [
                    _textFormField('Name', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.name3])),
                    _textFormField('Role', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.role3])),
                    _buildTimeField('Driving Times', GlobalFunctions.databaseValueTime(transferReportModel.selectedTransferReport[Strings.drivingTimes3_1])),
                    _buildTimeField('Driving Times', GlobalFunctions.databaseValueTime(transferReportModel.selectedTransferReport[Strings.drivingTimes3_2])),
                  ],
                ),
                transferReportModel.selectedTransferReport[Strings.name4] == null || transferReportModel.selectedTransferReport[Strings.name4] == '' ?
                Container() : Column(
                  children: [
                    _textFormField('Name', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.name4])),
                    _textFormField('Role', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.role4])),
                    _buildTimeField('Driving Times', GlobalFunctions.databaseValueTime(transferReportModel.selectedTransferReport[Strings.drivingTimes4_1])),
                    _buildTimeField('Driving Times', GlobalFunctions.databaseValueTime(transferReportModel.selectedTransferReport[Strings.drivingTimes4_2])),
                  ],
                ),
                transferReportModel.selectedTransferReport[Strings.name5] == null || transferReportModel.selectedTransferReport[Strings.name5] == '' ?
                Container() : Column(
                  children: [
                    _textFormField('Name', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.name5])),
                    _textFormField('Role', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.role5])),
                    _buildTimeField('Driving Times', GlobalFunctions.databaseValueTime(transferReportModel.selectedTransferReport[Strings.drivingTimes5_1])),
                    _buildTimeField('Driving Times', GlobalFunctions.databaseValueTime(transferReportModel.selectedTransferReport[Strings.drivingTimes5_2])),
                  ],
                ),
                transferReportModel.selectedTransferReport[Strings.name6] == null || transferReportModel.selectedTransferReport[Strings.name6] == '' ?
                Container() : Column(
                  children: [
                    _textFormField('Name', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.name6])),
                    _textFormField('Role', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.role6])),
                    _buildTimeField('Driving Times', GlobalFunctions.databaseValueTime(transferReportModel.selectedTransferReport[Strings.drivingTimes6_1])),
                    _buildTimeField('Driving Times', GlobalFunctions.databaseValueTime(transferReportModel.selectedTransferReport[Strings.drivingTimes6_2])),
                  ],
                ),





                //_textFormField('Name', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.name6])),
                // _textFormField('Role', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.role6])),
                // _buildTimeField('Driving Times', GlobalFunctions.databaseValueTime(transferReportModel.selectedTransferReport[Strings.drivingTimes6_1])),
                // _buildTimeField('Driving Times', GlobalFunctions.databaseValueTime(transferReportModel.selectedTransferReport[Strings.drivingTimes6_2])),
                // _textFormField('Name', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.name7])),
                // _textFormField('Role', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.role7])),
                // _buildTimeField('Driving Times', GlobalFunctions.databaseValueTime(transferReportModel.selectedTransferReport[Strings.drivingTimes7_1])),
                // _buildTimeField('Driving Times', GlobalFunctions.databaseValueTime(transferReportModel.selectedTransferReport[Strings.drivingTimes7_2])),
                // _textFormField('Name', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.name8])),
                // _textFormField('Role', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.role8])),
                // _buildTimeField('Driving Times', GlobalFunctions.databaseValueTime(transferReportModel.selectedTransferReport[Strings.drivingTimes8_1])),
                // _buildTimeField('Driving Times', GlobalFunctions.databaseValueTime(transferReportModel.selectedTransferReport[Strings.drivingTimes8_2])),
                // _textFormField('Name', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.name9])),
                // _textFormField('Role', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.role9])),
                // _buildTimeField('Driving Times', GlobalFunctions.databaseValueTime(transferReportModel.selectedTransferReport[Strings.drivingTimes9_1])),
                // _buildTimeField('Driving Times', GlobalFunctions.databaseValueTime(transferReportModel.selectedTransferReport[Strings.drivingTimes9_2])),
                // _textFormField('Name', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.name10])),
                // _textFormField('Role', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.role10])),
                // _buildTimeField('Driving Times', GlobalFunctions.databaseValueTime(transferReportModel.selectedTransferReport[Strings.drivingTimes10_1])),
                // _buildTimeField('Driving Times', GlobalFunctions.databaseValueTime(transferReportModel.selectedTransferReport[Strings.drivingTimes10_2])),
                // _textFormField('Name', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.name11])),
                // _textFormField('Role', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.role11])),
                // _buildTimeField('Driving Times', GlobalFunctions.databaseValueTime(transferReportModel.selectedTransferReport[Strings.drivingTimes11_1])),
                // _buildTimeField('Driving Times', GlobalFunctions.databaseValueTime(transferReportModel.selectedTransferReport[Strings.drivingTimes11_2])),
                SizedBox(height: 20,),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('TRANSFER REPORT', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),),
                ],),
                SizedBox(height: 20,),
                Text('Collection Details', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold),),
                SizedBox(height: 10,),
                Text('This is a legal and binding document and will be retained by the company for reference of any incidents that may occur in the event that we have been given any incorrect information. By signing this form, you are satisfied that all property, section papers and documents listed within this report have been handed over from Pegasus Medical (1808) Ltd.', style: TextStyle(color: bluePurple),),
                SizedBox(height: 10,),
                Text('Section Papers handed over if required', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold),),
                _textFormField('Unit', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.collectionUnit])),
                _textFormField('Position', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.collectionPosition])),
                _textFormField('Print Name', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.collectionPrintName])),
                _buildCollectionSignatureRow(),
                _buildTimeField('Arrival Time', GlobalFunctions.databaseValueTime(transferReportModel.selectedTransferReport[Strings.collectionArrivalTimeEnd])),
                SizedBox(height: 10,),
                Text('Destination Details', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold),),
                SizedBox(height: 10,),
                Text('This is a legal and binding document and will be retained by the company for reference of any incidents that may occur in the event that we have been given any incorrect information. By signing this form, you are satisfied that all property, section papers and documents listed within this report have been handed over from Pegasus Medical (1808) Ltd.', style: TextStyle(color: bluePurple),),
                SizedBox(height: 10,),
                Text('Section Papers handed over if required', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold),),
                _textFormField('Unit', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.destinationUnit])),
                _textFormField('Position', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.destinationPosition])),
                _textFormField('Print Name', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.destinationPrintName])),
                _buildDestinationSignatureRow(),
                _buildTimeField('Arrival Time', GlobalFunctions.databaseValueTime(transferReportModel.selectedTransferReport[Strings.destinationArrivalTimeEnd])),
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

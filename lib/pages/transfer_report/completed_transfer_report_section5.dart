import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pegasus_medical_1808/models/transfer_report_model.dart';
import 'package:pegasus_medical_1808/shared/global_config.dart';
import 'package:pegasus_medical_1808/shared/global_functions.dart';
import 'package:pegasus_medical_1808/shared/strings.dart';
import 'package:provider/provider.dart';


class CompletedTransferReportSection5 extends StatefulWidget {

  @override
  _CompletedTransferReportSection5State createState() => _CompletedTransferReportSection5State();
}

class _CompletedTransferReportSection5State extends State<CompletedTransferReportSection5> {

  bool _loadingTemporary = false;
  TransferReportModel transferReportModel;

  @override
  void initState() {
    // TODO: implement initState
    transferReportModel = Provider.of<TransferReportModel>(context, listen: false);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
  Widget _buildCheckboxRowAmbulanceTidyYes2(String text) {
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
                value: transferReportModel.selectedTransferReport[Strings.ambulanceTidyYes2] == null || transferReportModel.selectedTransferReport[Strings.ambulanceTidyYes2] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.ambulanceTidyNo2] == null || transferReportModel.selectedTransferReport[Strings.ambulanceTidyNo2] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowSanitiserCleanYes(String text) {
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
                value: transferReportModel.selectedTransferReport[Strings.sanitiserCleanYes] == null || transferReportModel.selectedTransferReport[Strings.sanitiserCleanYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.sanitiserCleanNo] == null || transferReportModel.selectedTransferReport[Strings.sanitiserCleanNo] == 0 ? false : true,
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
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('TRANSFER REPORT', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),),
                ],),
                SizedBox(height: 10,),
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
                SizedBox(height: 20,),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('POST-TRANSFER VEHICLE CHECKLIST', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),),
                ],),
                SizedBox(height: 20,),
                _textFormField('Completed by', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.vehicleCompletedBy2])),
                _textFormField('Finish Mileage', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.finishMileage])),
                _textFormField('Total Mileage', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.totalMileage])),
                _textFormField('Fuel to the nearest 1/4 tank', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.nearestTank2])),
                SizedBox(height: 10,),
                _buildCheckboxRowAmbulanceTidyYes2('• Was the ambulance left clean and tidy?'),
                _buildCheckboxRowSanitiserCleanYes('• General clean & touch points'),
                SizedBox(height: 20,),
                Text('ANY ISSUES OR FAULTS PLEASE REPORT BELOW', style: TextStyle(color: bluePurple),),
                SizedBox(height: 10,),
                _textFormField('', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.issuesFaults])),
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

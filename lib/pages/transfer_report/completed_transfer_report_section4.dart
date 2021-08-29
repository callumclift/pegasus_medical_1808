import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pegasus_medical_1808/models/transfer_report_model.dart';
import 'package:pegasus_medical_1808/shared/global_config.dart';
import 'package:pegasus_medical_1808/shared/global_functions.dart';
import 'package:pegasus_medical_1808/shared/strings.dart';
import 'package:provider/provider.dart';


class CompletedTransferReportSection4 extends StatefulWidget {

  @override
  _CompletedTransferReportSection4State createState() => _CompletedTransferReportSection4State();
}

class _CompletedTransferReportSection4State extends State<CompletedTransferReportSection4> {

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

  Widget _buildCheckboxRowFeltSafeYes(String text) {
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
                value: transferReportModel.selectedTransferReport[Strings.feltSafeYes] == null || transferReportModel.selectedTransferReport[Strings.feltSafeYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.feltSafeNo] == null || transferReportModel.selectedTransferReport[Strings.feltSafeNo] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowStaffIntroducedYes(String text) {
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
                value: transferReportModel.selectedTransferReport[Strings.staffIntroducedYes] == null || transferReportModel.selectedTransferReport[Strings.staffIntroducedYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.staffIntroducedNo] == null || transferReportModel.selectedTransferReport[Strings.staffIntroducedNo] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowExperiencePositiveYes(String text) {
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
                value: transferReportModel.selectedTransferReport[Strings.experiencePositiveYes] == null || transferReportModel.selectedTransferReport[Strings.experiencePositiveYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.experiencePositiveNo] == null || transferReportModel.selectedTransferReport[Strings.experiencePositiveNo] == 0 ? false : true,
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
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('PATIENT FEEDBACK FORM', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),),
                ],),
                SizedBox(height: 20,),
                _buildCheckboxRowFeltSafeYes("• Whilst travelling with us today have you felt safe?"),
                _buildCheckboxRowStaffIntroducedYes("• Staff introduced themselves to me and they were friendly?"),
                _buildCheckboxRowExperiencePositiveYes("• My overall experience was positive?"),
                SizedBox(height: 20,),
                Text('PLEASE SHARE ANY OTHER COMMENTS', style: TextStyle(color: bluePurple),),
                SizedBox(height: 10,),
                _textFormField('', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.otherComments])),
                SizedBox(height: 10,),
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

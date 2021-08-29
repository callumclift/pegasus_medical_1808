import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pegasus_medical_1808/models/transfer_report_model.dart';
import 'package:pegasus_medical_1808/shared/global_config.dart';
import 'package:pegasus_medical_1808/shared/global_functions.dart';
import 'package:pegasus_medical_1808/shared/strings.dart';
import 'package:provider/provider.dart';


class CompletedTransferReportSection3 extends StatefulWidget {

  @override
  _CompletedTransferReportSection3State createState() => _CompletedTransferReportSection3State();
}

class _CompletedTransferReportSection3State extends State<CompletedTransferReportSection3> {

  bool _loadingTemporary = false;
  TransferReportModel transferReportModel;
  Uint8List transferInImageBytes1;
  Uint8List transferInImageBytes2;
  Uint8List transferInImageBytes3;

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
      if (transferReportModel.selectedTransferReport[Strings.transferInSignature1] != null) {
        transferInImageBytes1 = await GlobalFunctions.decryptSignature(transferReportModel.selectedTransferReport[Strings.transferInSignature1]);
      }
      if (transferReportModel.selectedTransferReport[Strings.transferInSignature2] != null) {
        transferInImageBytes2 = await GlobalFunctions.decryptSignature(transferReportModel.selectedTransferReport[Strings.transferInSignature2]);
      }
      if (transferReportModel.selectedTransferReport[Strings.transferInSignature3] != null) {
        transferInImageBytes3 = await GlobalFunctions.decryptSignature(transferReportModel.selectedTransferReport[Strings.transferInSignature3]);
      }
      if (mounted) {
        setState(() {
          _loadingTemporary = false;
        });
      }

    }
  }
  Widget _buildTransferInSignature1Row() {
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
            child: transferReportModel.selectedTransferReport[Strings.transferInSignature1] == null
                ? Text('No signature found')
                : Image.memory(transferInImageBytes1),

          ),
        )
      ],
    );
  }
  Widget _buildTransferInSignature2Row() {
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
            child: transferReportModel.selectedTransferReport[Strings.transferInSignature2] == null
                ? Text('No signature found')
                : Image.memory(transferInImageBytes2),

          ),
        )
      ],
    );
  }
  Widget _buildTransferInSignature3Row() {
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
            child: transferReportModel.selectedTransferReport[Strings.transferInSignature3] == null
                ? Text('No signature found')
                : Image.memory(transferInImageBytes3),

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

  Widget _buildCheckboxRowPatientCorrectYes1(String text) {
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
                value: transferReportModel.selectedTransferReport[Strings.patientCorrectYes1] == null || transferReportModel.selectedTransferReport[Strings.patientCorrectYes1] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.patientCorrectNo1] == null || transferReportModel.selectedTransferReport[Strings.patientCorrectNo1] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowHospitalCorrectYes1(String text) {
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
                value: transferReportModel.selectedTransferReport[Strings.hospitalCorrectYes1] == null || transferReportModel.selectedTransferReport[Strings.hospitalCorrectYes1] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.hospitalCorrectNo1] == null || transferReportModel.selectedTransferReport[Strings.hospitalCorrectNo1] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowApplicationFormYes1(String text) {
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
                value: transferReportModel.selectedTransferReport[Strings.applicationFormYes1] == null || transferReportModel.selectedTransferReport[Strings.applicationFormYes1] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.applicationFormNo1] == null || transferReportModel.selectedTransferReport[Strings.applicationFormNo1] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowApplicationSignedYes1(String text) {
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
                value: transferReportModel.selectedTransferReport[Strings.applicationSignedYes1] == null || transferReportModel.selectedTransferReport[Strings.applicationSignedYes1] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.applicationSignedNo1] == null || transferReportModel.selectedTransferReport[Strings.applicationSignedNo1] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowWithin14DaysYes1(String text) {
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
                value: transferReportModel.selectedTransferReport[Strings.within14DaysYes1] == null || transferReportModel.selectedTransferReport[Strings.within14DaysYes1] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.within14DaysNo1] == null || transferReportModel.selectedTransferReport[Strings.within14DaysNo1] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowLocalAuthorityNameYes1(String text) {
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
                value: transferReportModel.selectedTransferReport[Strings.localAuthorityNameYes1] == null || transferReportModel.selectedTransferReport[Strings.localAuthorityNameYes1] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.localAuthorityNameNo1] == null || transferReportModel.selectedTransferReport[Strings.localAuthorityNameNo1] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowMedicalRecommendationsFormYes1(String text) {
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
                value: transferReportModel.selectedTransferReport[Strings.medicalRecommendationsFormYes1] == null || transferReportModel.selectedTransferReport[Strings.medicalRecommendationsFormYes1] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.medicalRecommendationsFormNo1] == null || transferReportModel.selectedTransferReport[Strings.medicalRecommendationsFormNo1] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowMedicalRecommendationsSignedYes1(String text) {
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
                value: transferReportModel.selectedTransferReport[Strings.medicalRecommendationsSignedYes1] == null || transferReportModel.selectedTransferReport[Strings.medicalRecommendationsSignedYes1] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.medicalRecommendationsSignedNo1] == null || transferReportModel.selectedTransferReport[Strings.medicalRecommendationsSignedNo1] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowDatesSignatureSignedYes(String text) {
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
                value: transferReportModel.selectedTransferReport[Strings.datesSignatureSignedYes] == null || transferReportModel.selectedTransferReport[Strings.datesSignatureSignedYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.datesSignatureSignedNo] == null || transferReportModel.selectedTransferReport[Strings.datesSignatureSignedNo] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowSignatureDatesOnBeforeYes1(String text) {
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
                value: transferReportModel.selectedTransferReport[Strings.signatureDatesOnBeforeYes1] == null || transferReportModel.selectedTransferReport[Strings.signatureDatesOnBeforeYes1] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.signatureDatesOnBeforeNo1] == null || transferReportModel.selectedTransferReport[Strings.signatureDatesOnBeforeNo1] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowPractitionersNameYes1(String text) {
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
                value: transferReportModel.selectedTransferReport[Strings.practitionersNameYes1] == null || transferReportModel.selectedTransferReport[Strings.practitionersNameYes1] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.practitionersNameNo1] == null || transferReportModel.selectedTransferReport[Strings.practitionersNameNo1] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowPatientCorrectYes2(String text) {
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
                value: transferReportModel.selectedTransferReport[Strings.patientCorrectYes2] == null || transferReportModel.selectedTransferReport[Strings.patientCorrectYes2] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.patientCorrectNo2] == null || transferReportModel.selectedTransferReport[Strings.patientCorrectNo2] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowHospitalCorrectYes2(String text) {
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
                value: transferReportModel.selectedTransferReport[Strings.hospitalCorrectYes2] == null || transferReportModel.selectedTransferReport[Strings.hospitalCorrectYes2] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.hospitalCorrectNo2] == null || transferReportModel.selectedTransferReport[Strings.hospitalCorrectNo2] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowApplicationFormYes2(String text) {
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
                value: transferReportModel.selectedTransferReport[Strings.applicationFormYes2] == null || transferReportModel.selectedTransferReport[Strings.applicationFormYes2] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.applicationFormNo2] == null || transferReportModel.selectedTransferReport[Strings.applicationFormNo2] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowApplicationSignedYes2(String text) {
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
                value: transferReportModel.selectedTransferReport[Strings.applicationSignedYes2] == null || transferReportModel.selectedTransferReport[Strings.applicationSignedYes2] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.applicationSignedNo2] == null || transferReportModel.selectedTransferReport[Strings.applicationSignedNo2] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowAmhpIdentifiedYes(String text) {
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
                value: transferReportModel.selectedTransferReport[Strings.amhpIdentifiedYes] == null || transferReportModel.selectedTransferReport[Strings.amhpIdentifiedYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.amhpIdentifiedNo] == null || transferReportModel.selectedTransferReport[Strings.amhpIdentifiedNo] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowMedicalRecommendationsFormYes2(String text) {
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
                value: transferReportModel.selectedTransferReport[Strings.medicalRecommendationsFormYes2] == null || transferReportModel.selectedTransferReport[Strings.medicalRecommendationsFormYes2] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.medicalRecommendationsFormNo2] == null || transferReportModel.selectedTransferReport[Strings.medicalRecommendationsFormNo2] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowMedicalRecommendationsSignedYes2(String text) {
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
                value: transferReportModel.selectedTransferReport[Strings.medicalRecommendationsSignedYes2] == null || transferReportModel.selectedTransferReport[Strings.medicalRecommendationsSignedYes2] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.medicalRecommendationsSignedNo2] == null || transferReportModel.selectedTransferReport[Strings.medicalRecommendationsSignedNo2] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowClearDaysYes2(String text) {
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
                value: transferReportModel.selectedTransferReport[Strings.clearDaysYes2] == null || transferReportModel.selectedTransferReport[Strings.clearDaysYes2] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.clearDaysNo2] == null || transferReportModel.selectedTransferReport[Strings.clearDaysNo2] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowSignatureDatesOnBeforeYes2(String text) {
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
                value: transferReportModel.selectedTransferReport[Strings.signatureDatesOnBeforeYes2] == null || transferReportModel.selectedTransferReport[Strings.signatureDatesOnBeforeYes2] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.signatureDatesOnBeforeNo2] == null || transferReportModel.selectedTransferReport[Strings.signatureDatesOnBeforeNo2] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowPractitionersNameYes2(String text) {
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
                value: transferReportModel.selectedTransferReport[Strings.practitionersNameYes2] == null || transferReportModel.selectedTransferReport[Strings.practitionersNameYes2] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.practitionersNameNo2] == null || transferReportModel.selectedTransferReport[Strings.practitionersNameNo2] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowDoctorsAgreeYes(String text) {
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
                value: transferReportModel.selectedTransferReport[Strings.doctorsAgreeYes] == null || transferReportModel.selectedTransferReport[Strings.doctorsAgreeYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.doctorsAgreeNo] == null || transferReportModel.selectedTransferReport[Strings.doctorsAgreeNo] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowSeparateMedicalRecommendationsYes(String text) {
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
                value: transferReportModel.selectedTransferReport[Strings.separateMedicalRecommendationsYes] == null || transferReportModel.selectedTransferReport[Strings.separateMedicalRecommendationsYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.separateMedicalRecommendationsNo] == null || transferReportModel.selectedTransferReport[Strings.separateMedicalRecommendationsNo] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowPatientCorrectYes3(String text) {
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
                value: transferReportModel.selectedTransferReport[Strings.patientCorrectYes3] == null || transferReportModel.selectedTransferReport[Strings.patientCorrectYes3] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.patientCorrectNo3] == null || transferReportModel.selectedTransferReport[Strings.patientCorrectNo3] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowHospitalCorrectYes3(String text) {
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
                value: transferReportModel.selectedTransferReport[Strings.hospitalCorrectYes3] == null || transferReportModel.selectedTransferReport[Strings.hospitalCorrectYes3] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.hospitalCorrectNo3] == null || transferReportModel.selectedTransferReport[Strings.hospitalCorrectNo3] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowH4Yes(String text) {
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
                value: transferReportModel.selectedTransferReport[Strings.h4Yes] == null || transferReportModel.selectedTransferReport[Strings.h4Yes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.h4No] == null || transferReportModel.selectedTransferReport[Strings.h4No] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowCurrentConsentYes(String text) {
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
                value: transferReportModel.selectedTransferReport[Strings.currentConsentYes] == null || transferReportModel.selectedTransferReport[Strings.currentConsentYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.currentConsentNo] == null || transferReportModel.selectedTransferReport[Strings.currentConsentNo] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowApplicationFormYes3(String text) {
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
                value: transferReportModel.selectedTransferReport[Strings.applicationFormYes3] == null || transferReportModel.selectedTransferReport[Strings.applicationFormYes3] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.applicationFormNo3] == null || transferReportModel.selectedTransferReport[Strings.applicationFormNo3] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowApplicationSignedYes3(String text) {
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
                value: transferReportModel.selectedTransferReport[Strings.applicationSignedYes3] == null || transferReportModel.selectedTransferReport[Strings.applicationSignedYes3] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.applicationSignedNo3] == null || transferReportModel.selectedTransferReport[Strings.applicationSignedNo3] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowWithin14DaysYes3(String text) {
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
                value: transferReportModel.selectedTransferReport[Strings.within14DaysYes3] == null || transferReportModel.selectedTransferReport[Strings.within14DaysYes3] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.within14DaysNo3] == null || transferReportModel.selectedTransferReport[Strings.within14DaysNo3] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowLocalAuthorityNameYes3(String text) {
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
                value: transferReportModel.selectedTransferReport[Strings.localAuthorityNameYes3] == null || transferReportModel.selectedTransferReport[Strings.localAuthorityNameYes3] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.localAuthorityNameNo3] == null || transferReportModel.selectedTransferReport[Strings.localAuthorityNameNo3] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowNearestRelativeYes(String text) {
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
                value: transferReportModel.selectedTransferReport[Strings.nearestRelativeYes] == null || transferReportModel.selectedTransferReport[Strings.nearestRelativeYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.nearestRelativeNo] == null || transferReportModel.selectedTransferReport[Strings.nearestRelativeNo] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowAmhpConsultationYes(String text) {
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
                value: transferReportModel.selectedTransferReport[Strings.amhpConsultationYes] == null || transferReportModel.selectedTransferReport[Strings.amhpConsultationYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.amhpConsultationNo] == null || transferReportModel.selectedTransferReport[Strings.amhpConsultationNo] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowKnewPatientYes(String text) {
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
                value: transferReportModel.selectedTransferReport[Strings.knewPatientYes] == null || transferReportModel.selectedTransferReport[Strings.knewPatientYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.knewPatientNo] == null || transferReportModel.selectedTransferReport[Strings.knewPatientNo] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowMedicalRecommendationsFormYes3(String text) {
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
                value: transferReportModel.selectedTransferReport[Strings.medicalRecommendationsFormYes3] == null || transferReportModel.selectedTransferReport[Strings.medicalRecommendationsFormYes3] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.medicalRecommendationsFormNo3] == null || transferReportModel.selectedTransferReport[Strings.medicalRecommendationsFormNo3] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowMedicalRecommendationsSignedYes3(String text) {
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
                value: transferReportModel.selectedTransferReport[Strings.medicalRecommendationsSignedYes3] == null || transferReportModel.selectedTransferReport[Strings.medicalRecommendationsSignedYes3] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.medicalRecommendationsSignedNo3] == null || transferReportModel.selectedTransferReport[Strings.medicalRecommendationsSignedNo3] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowClearDaysYes3(String text) {
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
                value: transferReportModel.selectedTransferReport[Strings.clearDaysYes3] == null || transferReportModel.selectedTransferReport[Strings.clearDaysYes3] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.clearDaysNo3] == null || transferReportModel.selectedTransferReport[Strings.clearDaysNo3] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowApprovedSection12Yes(String text) {
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
                value: transferReportModel.selectedTransferReport[Strings.approvedSection12Yes] == null || transferReportModel.selectedTransferReport[Strings.approvedSection12Yes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.approvedSection12No] == null || transferReportModel.selectedTransferReport[Strings.approvedSection12No] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowSignatureDatesOnBeforeYes3(String text) {
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
                value: transferReportModel.selectedTransferReport[Strings.signatureDatesOnBeforeYes3] == null || transferReportModel.selectedTransferReport[Strings.signatureDatesOnBeforeYes3] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.signatureDatesOnBeforeNo3] == null || transferReportModel.selectedTransferReport[Strings.signatureDatesOnBeforeNo3] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowPractitionersNameYes3(String text) {
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
                value: transferReportModel.selectedTransferReport[Strings.practitionersNameYes3] == null || transferReportModel.selectedTransferReport[Strings.practitionersNameYes3] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.practitionersNameNo3] == null || transferReportModel.selectedTransferReport[Strings.practitionersNameNo3] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowPreviouslyAcquaintedYes(String text) {
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
                value: transferReportModel.selectedTransferReport[Strings.previouslyAcquaintedYes] == null || transferReportModel.selectedTransferReport[Strings.previouslyAcquaintedYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.previouslyAcquaintedNo] == null || transferReportModel.selectedTransferReport[Strings.previouslyAcquaintedNo] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowAcquaintedIfNoYes(String text) {
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
                value: transferReportModel.selectedTransferReport[Strings.acquaintedIfNoYes] == null || transferReportModel.selectedTransferReport[Strings.acquaintedIfNoYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.acquaintedIfNoNo] == null || transferReportModel.selectedTransferReport[Strings.acquaintedIfNoNo] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowRecommendationsDifferentTeamsYes(String text) {
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
                value: transferReportModel.selectedTransferReport[Strings.recommendationsDifferentTeamsYes] == null || transferReportModel.selectedTransferReport[Strings.recommendationsDifferentTeamsYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.recommendationsDifferentTeamsNo] == null || transferReportModel.selectedTransferReport[Strings.recommendationsDifferentTeamsNo] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowOriginalDetentionPapersYes(String text) {
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
                value: transferReportModel.selectedTransferReport[Strings.originalDetentionPapersYes] == null || transferReportModel.selectedTransferReport[Strings.originalDetentionPapersYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.originalDetentionPapersNo] == null || transferReportModel.selectedTransferReport[Strings.originalDetentionPapersNo] == 0 ? false : true,
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


          transferReportModel.selectedTransferReport[Strings.hasSection2Checklist] != null && transferReportModel.selectedTransferReport[Strings.hasSection2Checklist] == 1 ?
              Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('SECTION 2', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),),
                  ],),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('CHECKLIST', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),),
                  ],),
                  _textFormField('Name of Patient', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.patientName])),
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
                  // _textFormField('Checked By', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.transferInCheckedBy1])),
                  // SizedBox(height: 10,),
                  // _buildTransferInSignature1Row(),
                  // _buildDateField('Date', GlobalFunctions.databaseValueDate(transferReportModel.selectedTransferReport[Strings.transferInDate1])),
                  // _textFormField('Designation', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.transferInDesignation1])),


                  SizedBox(height: 20,),
                ],
              ) : Container(),



                transferReportModel.selectedTransferReport[Strings.hasSection3Checklist] != null && transferReportModel.selectedTransferReport[Strings.hasSection3Checklist] == 1 ?
                    Column(
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text('SECTION 3', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),),
                        ],),
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text('CHECKLIST', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),),
                        ],),
                        SizedBox(height: 20,),
                        _textFormField('Name of Patient', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.patientName])),
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
                        // _textFormField('Checked By', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.transferInCheckedBy2])),
                        // SizedBox(height: 20,),
                        // _buildTransferInSignature2Row(),
                        // _buildDateField('Date', GlobalFunctions.databaseValueDate(transferReportModel.selectedTransferReport[Strings.transferInDate2])),
                        // _textFormField('Designation', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.transferInDesignation2])),

                        SizedBox(height: 20,),
                      ],
                    ) : Container(),


                transferReportModel.selectedTransferReport[Strings.hasSection3TransferChecklist] != null && transferReportModel.selectedTransferReport[Strings.hasSection3TransferChecklist] == 1 ?
                    Column(children: [
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text('SECTION 3', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),),
                      ],),
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text('TRANSFER CHECKLIST', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),),
                      ],),
                      SizedBox(height: 20,),
                      _textFormField('Name of Patient', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.patientName])),
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
                      // _textFormField('Checked By', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.transferInCheckedBy3])),
                      // _buildTransferInSignature3Row(),
                      // _buildDateField('Date', GlobalFunctions.databaseValueDate(transferReportModel.selectedTransferReport[Strings.transferInDate3])),
                      // _textFormField('Designation', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.transferInDesignation3])),
                    ],) : Container(),
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

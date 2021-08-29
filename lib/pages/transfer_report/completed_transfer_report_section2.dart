import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pegasus_medical_1808/models/transfer_report_model.dart';
import 'package:pegasus_medical_1808/shared/global_config.dart';
import 'package:pegasus_medical_1808/shared/global_functions.dart';
import 'package:pegasus_medical_1808/shared/strings.dart';
import 'package:provider/provider.dart';


class CompletedTransferReportSection2 extends StatefulWidget {

  @override
  _CompletedTransferReportSection2State createState() => _CompletedTransferReportSection2State();
}

class _CompletedTransferReportSection2State extends State<CompletedTransferReportSection2> {

  bool _loadingTemporary = false;
  TransferReportModel transferReportModel;
  Uint8List incidentImageBytes;
  Uint8List patientReportImageBytes;
  Uint8List bodyMapImageBytes;
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
      if (transferReportModel.selectedTransferReport[Strings.patientReportSignature] != null) {
        patientReportImageBytes = await GlobalFunctions.decryptSignature(transferReportModel.selectedTransferReport[Strings.patientReportSignature]);
      }
      if (transferReportModel.selectedTransferReport[Strings.incidentSignature] != null) {
        incidentImageBytes = await GlobalFunctions.decryptSignature(transferReportModel.selectedTransferReport[Strings.incidentSignature]);
      }
      if (transferReportModel.selectedTransferReport[Strings.bodyMapImage] != null) {
        bodyMapImageBytes = await GlobalFunctions.decryptSignature(transferReportModel.selectedTransferReport[Strings.bodyMapImage]);
      }
      if (mounted) {
        setState(() {
          _loadingTemporary = false;
        });
      }

    }
  }

  Widget _buildIncidentSignatureRow() {
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
            child: transferReportModel.selectedTransferReport[Strings.incidentSignature] == null
                ? Text('No signature found')
                : Image.memory(incidentImageBytes),

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
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              "Signed",
              textAlign: TextAlign.left,
            ),
          ],
        ),
        SizedBox(
          height: 10.0,
        ),
        Container(
          child: Center(
            child: transferReportModel.selectedTransferReport[Strings.patientReportSignature] == null
                ? Text('No signature found')
                : Image.memory(patientReportImageBytes),

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

  Widget _buildHandcuffsUsedRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Handcuffs used', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.handcuffsUsedYes] == null || transferReportModel.selectedTransferReport[Strings.handcuffsUsedYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.handcuffsUsedNo] == null || transferReportModel.selectedTransferReport[Strings.handcuffsUsedNo] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }

  Widget _buildRiskRow() {
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
                value: transferReportModel.selectedTransferReport[Strings.riskYes] == null || transferReportModel.selectedTransferReport[Strings.riskYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.riskNo] == null || transferReportModel.selectedTransferReport[Strings.riskNo] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }

  Widget _buildPatientPropertyRow() {
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
                value: transferReportModel.selectedTransferReport[Strings.patientPropertyYes] == null || transferReportModel.selectedTransferReport[Strings.patientPropertyYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.patientPropertyNo] == null || transferReportModel.selectedTransferReport[Strings.patientPropertyNo] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }

  Widget _buildPatientPropertyReceivedRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Patient Property Received', style: TextStyle(color: Colors.grey, fontSize: 12),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.patientPropertyReceivedYes] == null || transferReportModel.selectedTransferReport[Strings.patientPropertyReceivedYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.patientPropertyReceivedNo] == null || transferReportModel.selectedTransferReport[Strings.patientPropertyReceivedNo] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }

  Widget _buildPatientNotesReceivedRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Patient Notes Received', style: TextStyle(color: Colors.grey, fontSize: 12),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.patientNotesReceivedYes] == null || transferReportModel.selectedTransferReport[Strings.patientNotesReceivedYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.patientNotesReceivedNo] == null || transferReportModel.selectedTransferReport[Strings.patientNotesReceivedNo] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }


  Widget _buildForensicHistoryRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Forensic History', style: TextStyle(color: Colors.grey, fontSize: 12),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.forensicHistoryYes] == null || transferReportModel.selectedTransferReport[Strings.forensicHistoryYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.forensicHistoryNo] == null || transferReportModel.selectedTransferReport[Strings.forensicHistoryNo] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }

  Widget _buildRacialGenderConcernsRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Any Racial of Gender Concerns', style: TextStyle(color: Colors.grey, fontSize: 12),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.racialGenderConcernsYes] == null || transferReportModel.selectedTransferReport[Strings.racialGenderConcernsYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.racialGenderConcernsNo] == null || transferReportModel.selectedTransferReport[Strings.racialGenderConcernsNo] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }


  Widget _buildViolenceAggressionRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Violence or Aggression (Actual or Potential)', style: TextStyle(color: Colors.grey, fontSize: 12),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.violenceAggressionYes] == null || transferReportModel.selectedTransferReport[Strings.violenceAggressionYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.violenceAggressionNo] == null || transferReportModel.selectedTransferReport[Strings.violenceAggressionNo] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }

  Widget _buildSelfHarmRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Self Harm/Attempted Suicide', style: TextStyle(color: Colors.grey, fontSize: 12),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.selfHarmYes] == null || transferReportModel.selectedTransferReport[Strings.selfHarmYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.selfHarmNo] == null || transferReportModel.selectedTransferReport[Strings.selfHarmNo] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }

  Widget _buildAlcoholSubstanceRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Alcohol / Substance Abuse', style: TextStyle(color: Colors.grey, fontSize: 12),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.alcoholSubstanceYes] == null || transferReportModel.selectedTransferReport[Strings.alcoholSubstanceYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.alcoholSubstanceNo] == null || transferReportModel.selectedTransferReport[Strings.alcoholSubstanceNo] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }

  Widget _buildVirusesRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Any known Blood Borne Viruses', style: TextStyle(color: Colors.grey, fontSize: 12),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.virusesYes] == null || transferReportModel.selectedTransferReport[Strings.virusesYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.virusesNo] == null || transferReportModel.selectedTransferReport[Strings.virusesNo] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }

  Widget _buildSafeguardingRow() {
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
                value: transferReportModel.selectedTransferReport[Strings.safeguardingYes] == null || transferReportModel.selectedTransferReport[Strings.safeguardingYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.safeguardingNo] == null || transferReportModel.selectedTransferReport[Strings.safeguardingNo] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }

  Widget _buildPhysicalHealthConditionsRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Physical Health Conditions', style: TextStyle(color: Colors.grey, fontSize: 12),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.physicalHealthConditionsYes] == null || transferReportModel.selectedTransferReport[Strings.physicalHealthConditionsYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.physicalHealthConditionsNo] == null || transferReportModel.selectedTransferReport[Strings.physicalHealthConditionsNo] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }

  Widget _buildUseOfWeaponRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Use of Weapon(s)', style: TextStyle(color: Colors.grey, fontSize: 12),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.useOfWeaponYes] == null || transferReportModel.selectedTransferReport[Strings.useOfWeaponYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.useOfWeaponNo] == null || transferReportModel.selectedTransferReport[Strings.useOfWeaponNo] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }

  Widget _buildAbsconsionRiskRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Absconsion Risk', style: TextStyle(color: Colors.grey, fontSize: 12),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.absconsionRiskYes] == null || transferReportModel.selectedTransferReport[Strings.absconsionRiskYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.absconsionRiskNo] == null || transferReportModel.selectedTransferReport[Strings.absconsionRiskNo] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }

  Widget _buildMedicalAttentionRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Received medical attention in the last 24 hours', style: TextStyle(color: Colors.grey, fontSize: 12),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.medicalAttentionYes] == null || transferReportModel.selectedTransferReport[Strings.medicalAttentionYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.medicalAttentionNo] == null || transferReportModel.selectedTransferReport[Strings.medicalAttentionNo] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }

  Widget _buildRelevantInformationRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Any other Relevant Information (including rapid tranquilisation)', style: TextStyle(color: Colors.grey, fontSize: 12),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.relevantInformationYes] == null || transferReportModel.selectedTransferReport[Strings.relevantInformationYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.relevantInformationNo] == null || transferReportModel.selectedTransferReport[Strings.relevantInformationNo] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }




  Widget _buildPatientSearchedRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Patient Been Searched/Wanded', style: TextStyle(color: Colors.grey, fontSize: 12),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.patientSearchedYes] == null || transferReportModel.selectedTransferReport[Strings.patientSearchedYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.patientSearchedNo] == null || transferReportModel.selectedTransferReport[Strings.patientSearchedNo] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }

  Widget _buildItemsRemovedRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Any Items Removed', style: TextStyle(color: Colors.grey, fontSize: 12),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.itemsRemovedYes] == null || transferReportModel.selectedTransferReport[Strings.itemsRemovedYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.itemsRemovedNo] == null || transferReportModel.selectedTransferReport[Strings.itemsRemovedNo] == 0 ? false : true,
                onChanged: (bool value){}),
          ],
        )
      ],
    );
  }

  Widget _buildPhysicalInterventionRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Physical Intervention', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.physicalInterventionYes] == null || transferReportModel.selectedTransferReport[Strings.physicalInterventionYes] == 0 ? false : true,
                onChanged: (bool value){}),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: transferReportModel.selectedTransferReport[Strings.physicalInterventionNo] == null || transferReportModel.selectedTransferReport[Strings.physicalInterventionNo] == 0 ? false : true,
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
                SizedBox(height: 20,),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('TRANSFER REPORT', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),),
                ],),
                SizedBox(height: 20,),
                _textFormField('Name', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.patientName])),
                _buildDateField('Date of Birth', GlobalFunctions.databaseValueDate(transferReportModel.selectedTransferReport[Strings.dateOfBirth], true)),
                _textFormField('Ethnicity', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.ethnicity])),
                _textFormField('Gender', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.gender])),
                _textFormField('Legal Status', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.mhaMcaDetails])),
                _textFormField('Diagnosis', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.diagnosis])),
                _textFormField('Current Presentation', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.currentPresentation])),
                SizedBox(height: 20,),
                Text('RISK', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold),),
                SizedBox(height: 10,),
                // _buildRiskRow(),
                // transferReportModel.selectedTransferReport[Strings.riskYes] == 1 ? _textFormField('Explanation', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.riskExplanation])) :
                // Container(),

                _buildForensicHistoryRow(),
                transferReportModel.selectedTransferReport[Strings.forensicHistoryYes] == 1 ? _textFormField('', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.forensicHistory])) :
                Container(),
                SizedBox(height: 10,),
                _buildRacialGenderConcernsRow(),
                transferReportModel.selectedTransferReport[Strings.racialGenderConcernsYes] == 1 ? _textFormField('', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.racialGenderConcerns])) :
                Container(),
                SizedBox(height: 10,),
                _buildViolenceAggressionRow(),
                transferReportModel.selectedTransferReport[Strings.violenceAggressionYes] == 1 ? _textFormField('', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.violenceAggression])) :
                Container(),
                SizedBox(height: 10,),
                _buildSelfHarmRow(),
                transferReportModel.selectedTransferReport[Strings.selfHarmYes] == 1 ? _textFormField('', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.selfHarm])) :
                Container(),
                SizedBox(height: 10,),
                _buildAlcoholSubstanceRow(),
                transferReportModel.selectedTransferReport[Strings.alcoholSubstanceYes] == 1 ? _textFormField('', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.alcoholSubstance])) :
                Container(),
                SizedBox(height: 10,),
                _buildVirusesRow(),
                transferReportModel.selectedTransferReport[Strings.virusesYes] == 1 ? _textFormField('', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.viruses])) :
                Container(),
                SizedBox(height: 10,),
                _buildSafeguardingRow(),
                transferReportModel.selectedTransferReport[Strings.safeguardingYes] == 1 ? _textFormField('', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.safeguarding])) :
                Container(),
                SizedBox(height: 10,),
                _buildPhysicalHealthConditionsRow(),
                transferReportModel.selectedTransferReport[Strings.physicalHealthConditionsYes] == 1 ? _textFormField('', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.physicalHealthConditions])) :
                Container(),
                SizedBox(height: 10,),
                _buildUseOfWeaponRow(),
                transferReportModel.selectedTransferReport[Strings.useOfWeaponYes] == 1 ? _textFormField('', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.useOfWeapon])) :
                Container(),
                SizedBox(height: 10,),
                _buildAbsconsionRiskRow(),
                transferReportModel.selectedTransferReport[Strings.absconsionRiskYes] == 1 ? _textFormField('', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.absconsionRisk])) :
                Container(),
                SizedBox(height: 20,),
                Text('PATIENT PROPERTY', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold),),
                SizedBox(height: 10,),
                _buildPatientPropertyRow(),
                transferReportModel.selectedTransferReport[Strings.patientPropertyYes] == 1 ?
                Column (children: [
                  _buildPatientPropertyReceivedRow(),
                  SizedBox(height: 10,),
                  transferReportModel.selectedTransferReport[Strings.patientPropertyReceivedYes] == 1 ? _textFormField('', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.patientPropertyReceived]))
                  : Container(),

                ],):
                Container(),
                SizedBox(height: 10,),

                _buildPatientNotesReceivedRow(),
                SizedBox(height: 10,),
                transferReportModel.selectedTransferReport[Strings.patientNotesReceivedYes] == 1 ? _textFormField('', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.patientNotesReceived])) :
                Container(),
                SizedBox(height: 20,),
                Text('PATIENT CHECKS', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold),),
                SizedBox(height: 10,),
                _buildPatientSearchedRow(),
                SizedBox(height: 10,),
                _buildItemsRemovedRow(),
                transferReportModel.selectedTransferReport[Strings.itemsRemovedYes] == 1 ? _textFormField('', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.itemsRemoved])) :
                Container(),
                _textFormField('Patient informed and understands what is happening and involved in decision making', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.patientInformed])),
                _textFormField('Injuries noted at collection', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.injuriesNoted])),
                SizedBox(height: 20,),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('BODY MAP', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),),
                ],),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Flexible(child: Text('To be used before leaving the unit with any patient', style: TextStyle(color: bluePurple),),),
                ],),
                SizedBox(height: 20,),
                transferReportModel.selectedTransferReport[Strings.bodyMapImage] == null ? Center(child: Image.asset(
                  'assets/images/bodyMap.png',
                  width: MediaQuery.of(context).size.width * 0.8,
                ),) : Center(child: Image.memory(
                  bodyMapImageBytes,
                  width: MediaQuery.of(context).size.width * 0.8,
                ),),
                SizedBox(height: 20,),
                SizedBox(height: 10,),
                _buildMedicalAttentionRow(),
                transferReportModel.selectedTransferReport[Strings.medicalAttentionYes] == 1 ? _textFormField('', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.medicalAttention])) :
                Container(),
                _textFormField('Current Medication (inc. time last administered)', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.currentMedication])),
                _textFormField('Last Recorded Physical Observations', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.physicalObservations])),
                SizedBox(height: 10,),
                _buildRelevantInformationRow(),
                transferReportModel.selectedTransferReport[Strings.relevantInformationYes] == 1 ? _textFormField('', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.relevantInformation])) :
                Container(),
                SizedBox(height: 20,),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('TRANSFER REPORT', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),),
                ],),
                SizedBox(height: 20,),
                SizedBox(height: 20,),
                Text('Patient Report - please include: mental state, risk, physical health concerns, delays', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold),),
                SizedBox(height: 10,),
                _textFormField('', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.patientReport])),
                _textFormField('Print Name', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.patientReportPrintName])),
                _textFormField('Role', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.patientReportRole])),
                _buildPatientReportSignatureRow(),
                _buildDateField('Date', GlobalFunctions.databaseValueDate(transferReportModel.selectedTransferReport[Strings.patientReportDate])),
                _buildTimeField('Time', GlobalFunctions.databaseValueTime(transferReportModel.selectedTransferReport[Strings.patientReportTime])),
                SizedBox(height: 20,),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('TRANSFER REPORT', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),),
                ],),
                SizedBox(height: 10,),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('HANDCUFF FORM', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),),
                ],),
                SizedBox(height: 20,),
                _buildHandcuffsUsedRow(),
                SizedBox(height: 20,),
                Text('If yes please complete incident form', style: TextStyle(color: bluePurple),),
                SizedBox(height: 10,),
                _buildDateField('Date', GlobalFunctions.databaseValueDate(transferReportModel.selectedTransferReport[Strings.handcuffsDate])),
                _buildTimeField('Time Handcuffs Applied', GlobalFunctions.databaseValueTime(transferReportModel.selectedTransferReport[Strings.handcuffsTime])),
                _textFormField('Authorised by', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.handcuffsAuthorisedBy])),
                _textFormField('Handcuffs Applied by', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.handcuffsAppliedBy])),
                _buildTimeField('Time Handcuffs Removed', GlobalFunctions.databaseValueTime(transferReportModel.selectedTransferReport[Strings.handcuffsRemovedTime])),
                SizedBox(height: 20,),
                _buildPhysicalInterventionRow(),
                SizedBox(height: 10,),
                transferReportModel.selectedTransferReport[Strings.physicalInterventionYes] == 1 ?
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('PHYSICAL INTERVENTION: PLEASE SELECT', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold),),
                    SizedBox(height: 10,),
                    _textFormField('Physical Intervention', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.physicalIntervention])),
                    _textFormField('Why was the intervention required?', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.whyInterventionRequired])),
                    _textFormField('Staff Name', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.techniqueName1])),
                    _textFormField('Technique', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.technique1])),
                    _textFormField('Position', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.techniquePosition1])),

                    transferReportModel.selectedTransferReport[Strings.techniqueName2] == null || transferReportModel.selectedTransferReport[Strings.techniqueName2] == '' ? Container() :
                        Column(
                          children: [
                            _textFormField('Staff Name', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.techniqueName2])),
                            _textFormField('Technique', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.technique2])),
                            _textFormField('Position', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.techniquePosition2])),
                          ],
                        ),
                    transferReportModel.selectedTransferReport[Strings.techniqueName3] == null || transferReportModel.selectedTransferReport[Strings.techniqueName3] == '' ? Container() :
                    Column(
                      children: [
                        _textFormField('Staff Name', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.techniqueName3])),
                        _textFormField('Technique', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.technique3])),
                        _textFormField('Position', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.techniquePosition3])),
                      ],
                    ),
                    transferReportModel.selectedTransferReport[Strings.techniqueName4] == null || transferReportModel.selectedTransferReport[Strings.techniqueName4] == '' ? Container() :
                    Column(
                      children: [
                        _textFormField('Staff Name', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.techniqueName4])),
                        _textFormField('Technique', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.technique4])),
                        _textFormField('Position', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.techniquePosition4])),
                      ],
                    ),
                    transferReportModel.selectedTransferReport[Strings.techniqueName5] == null || transferReportModel.selectedTransferReport[Strings.techniqueName5] == '' ? Container() :
                    Column(
                      children: [
                        _textFormField('Staff Name', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.techniqueName5])),
                        _textFormField('Technique', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.technique5])),
                        _textFormField('Position', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.techniquePosition5])),
                      ],
                    ),
                    transferReportModel.selectedTransferReport[Strings.techniqueName6] == null || transferReportModel.selectedTransferReport[Strings.techniqueName6] == '' ? Container() :
                    Column(
                      children: [
                        _textFormField('Staff Name', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.techniqueName6])),
                        _textFormField('Technique', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.technique6])),
                        _textFormField('Position', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.techniquePosition6])),
                      ],
                    ),
                    transferReportModel.selectedTransferReport[Strings.techniqueName7] == null || transferReportModel.selectedTransferReport[Strings.techniqueName7] == '' ? Container() :
                    Column(
                      children: [
                        _textFormField('Staff Name', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.techniqueName7])),
                        _textFormField('Technique', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.technique7])),
                        _textFormField('Position', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.techniquePosition7])),
                      ],
                    ),
                    transferReportModel.selectedTransferReport[Strings.techniqueName8] == null || transferReportModel.selectedTransferReport[Strings.techniqueName8] == '' ? Container() :
                    Column(
                      children: [
                        _textFormField('Staff Name', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.techniqueName8])),
                        _textFormField('Technique', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.technique8])),
                        _textFormField('Position', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.techniquePosition8])),
                      ],
                    ),
                    transferReportModel.selectedTransferReport[Strings.techniqueName9] == null || transferReportModel.selectedTransferReport[Strings.techniqueName9] == '' ? Container() :
                    Column(
                      children: [
                        _textFormField('Staff Name', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.techniqueName9])),
                        _textFormField('Technique', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.technique9])),
                        _textFormField('Position', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.techniquePosition9])),
                      ],
                    ),
                    transferReportModel.selectedTransferReport[Strings.techniqueName10] == null || transferReportModel.selectedTransferReport[Strings.techniqueName10] == '' ? Container() :
                    Column(
                      children: [
                        _textFormField('Staff Name', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.techniqueName10])),
                        _textFormField('Technique', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.technique10])),
                        _textFormField('Position', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.techniquePosition10])),
                      ],
                    ),
                    _buildTimeField('Time Intervention Commenced', GlobalFunctions.databaseValueTime(transferReportModel.selectedTransferReport[Strings.timeInterventionCommenced])),
                    _buildTimeField('Time Intervention Completed', GlobalFunctions.databaseValueTime(transferReportModel.selectedTransferReport[Strings.timeInterventionCompleted])),
                    SizedBox(height: 10,)
                  ],) : Container(),
                transferReportModel.selectedTransferReport[Strings.handcuffsUsedYes] == 1 ? Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('INCIDENT REPORT', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),),
                    ],),
                    SizedBox(height: 20,),
                    _textFormField('Job Ref', GlobalFunctions.databaseValueString(transferReportModel.selectedTransferReport[Strings.jobRef])),
                    _buildDateField('Date', GlobalFunctions.databaseValueDate(transferReportModel.selectedTransferReport[Strings.incidentDate], false)),
                    _buildTimeField('Time', GlobalFunctions.databaseValueTime(transferReportModel.selectedTransferReport[Strings.incidentTime])),
                    _textFormField('Incident Details', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.incidentDetails])),
                    _textFormField('Location', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.incidentLocation])),
                    _textFormField('What action did you take?', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.incidentAction])),
                    _textFormField('Staff involved', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.incidentStaffInvolved])),
                    _buildIncidentSignatureRow(),
                    SizedBox(height: 20,),
                    _buildDateField('Date', GlobalFunctions.databaseValueDate(transferReportModel.selectedTransferReport[Strings.incidentSignatureDate], false)),
                    _textFormField('Print Name', GlobalFunctions.decryptString(transferReportModel.selectedTransferReport[Strings.incidentPrintName])),
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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pegasus_medical_1808/models/patient_observation_model.dart';
import 'package:pegasus_medical_1808/widgets/app_bar_gradient.dart';
import '../../shared/global_config.dart';
import '../../shared/global_functions.dart';
import 'package:provider/provider.dart';
import 'completed_patient_observation.dart';



class PatientObservationSearchResults extends StatefulWidget {

  final DateTime dateFrom;
  final DateTime dateTo;

  PatientObservationSearchResults(this.dateFrom, this.dateTo);


  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _PatientObservationSearchResultsState();
  }
}

class _PatientObservationSearchResultsState extends State<PatientObservationSearchResults> {

  PatientObservationModel patientObservationModel;

  @override
  initState() {
    patientObservationModel = Provider.of<PatientObservationModel>(context, listen: false);
    super.initState();
  }

  void _viewPatientObservation(int index){
    patientObservationModel.selectPatientObservation(patientObservationModel.allPatientObservations[index]['document_id']);
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return CompletedPatientObservation();
    })).then((_) {
      patientObservationModel.selectPatientObservation(null);
    });
  }

  Widget _buildListTile(int index, List<Map<String, dynamic>> patientObservations) {
    final dateFormat = DateFormat("dd/MM/yyyy HH:mm");
    return Column(
      children: <Widget>[
        InkWell(onTap: () => _viewPatientObservation(index),
          child: ListTile(
            leading: Icon(Icons.library_books_sharp, color: bluePurple,),
            title: GlobalFunctions.boldTitleText('Job Ref: ', patientObservations[index]['job_ref'], context),
            subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              GlobalFunctions.boldTitleText('Date: ', dateFormat.format(
                  DateTime.parse(patientObservations[index]['timestamp'])), context),
            ],),
          ),),
        Divider(),
      ],
    );

  }


  Widget _buildPageContent(List<Map<String, dynamic>> patientObservations) {

    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        return _buildListTile(index, patientObservations);
      },
      itemCount: patientObservations.length >= 10 ? patientObservations.length + 1 : patientObservations.length,
    );
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Consumer<PatientObservationModel>(
      builder: (context, model, child) {
        List<Map<String, dynamic>> patientObservations = model.allPatientObservations;
        return Scaffold(
            appBar: AppBar(backgroundColor: greyDesign1,
              iconTheme: IconThemeData(color: Colors.white),
              flexibleSpace: AppBarGradient(),
              title: FittedBox(fit:BoxFit.fitWidth,
                  child: Text('Patient Observation Timesheet List', style: TextStyle(fontWeight: FontWeight.bold),)),
            ),
            body: _buildPageContent(patientObservations));
      },
    );
  }
}



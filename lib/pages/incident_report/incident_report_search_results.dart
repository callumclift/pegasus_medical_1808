import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pegasus_medical_1808/models/incident_report_model.dart';
import 'package:pegasus_medical_1808/widgets/app_bar_gradient.dart';
import '../../shared/global_config.dart';
import '../../shared/global_functions.dart';
import 'package:provider/provider.dart';
import 'completed_incident_report.dart';



class IncidentReportSearchResults extends StatefulWidget {

  final DateTime dateFrom;
  final DateTime dateTo;

  IncidentReportSearchResults(this.dateFrom, this.dateTo);


  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _IncidentReportSearchResultsState();
  }
}

class _IncidentReportSearchResultsState extends State<IncidentReportSearchResults> {

  IncidentReportModel incidentReportModel;


  @override
  initState() {
    incidentReportModel = Provider.of<IncidentReportModel>(context, listen: false);
    super.initState();
  }


  void _viewIncidentReport(int index){
    incidentReportModel.selectIncidentReport(incidentReportModel.allIncidentReports[index]['document_id']);
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return CompletedIncidentReport();
    })).then((_) {
      incidentReportModel.selectIncidentReport(null);
    });
  }

  Widget _buildListTile(int index, List<Map<String, dynamic>> incidentReports) {
    final dateFormat = DateFormat("dd/MM/yyyy HH:mm");
    Widget returnedWidget;
      returnedWidget = Column(
        children: <Widget>[
          InkWell(onTap: () => _viewIncidentReport(index),
            child: ListTile(
              leading: Icon(Icons.library_books_sharp, color: bluePurple,),
              title: GlobalFunctions.boldTitleText('Job Ref: ', incidentReports[index]['job_ref'], context),
              subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                GlobalFunctions.boldTitleText('Date: ', dateFormat.format(
                    DateTime.parse(incidentReports[index]['timestamp'])), context),
              ],),
            ),),
          Divider(),
        ],
      );
    //}
    return returnedWidget;

  }


  Widget _buildPageContent(List<Map<String, dynamic>> incidentReports) {

    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        return _buildListTile(index, incidentReports);
      },
      itemCount: incidentReports.length,
    );
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Consumer<IncidentReportModel>(
      builder: (context, model, child) {
        List<Map<String, dynamic>> incidentReports = model.allIncidentReports;
        return Scaffold(
            appBar: AppBar(backgroundColor: greyDesign1,
              iconTheme: IconThemeData(color: Colors.white),
              flexibleSpace: AppBarGradient(),
              title: FittedBox(fit:BoxFit.fitWidth,
                  child: Text('Incident Report List', style: TextStyle(fontWeight: FontWeight.bold),)),
            ),
            body: _buildPageContent(incidentReports));
      },
    );
  }
}



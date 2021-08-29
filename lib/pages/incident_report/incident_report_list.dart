import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pegasus_medical_1808/models/incident_report_model.dart';
import 'package:pegasus_medical_1808/widgets/app_bar_gradient.dart';
import 'package:pegasus_medical_1808/widgets/gradient_button.dart';
import '../../widgets/side_drawer.dart';
import '../../shared/global_config.dart';
import '../../shared/global_functions.dart';
import 'package:provider/provider.dart';
import 'completed_incident_report.dart';

class CompletedIncidentReportsListPage extends StatefulWidget {


  CompletedIncidentReportsListPage();

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _CompletedIncidentReportsListPageState();
  }
}

class _CompletedIncidentReportsListPageState extends State<CompletedIncidentReportsListPage> {

  bool _loadingMore = false;
  IncidentReportModel incidentReportModel;


  @override
  initState() {

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      incidentReportModel = context.read<IncidentReportModel>();

      incidentReportModel.getIncidentReports();
    });
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

  void loadMore() async {
    setState(() {
      _loadingMore = true;

    });
    await incidentReportModel.getMoreIncidentReports();
    setState(() {
      _loadingMore = false;
    });
  }

  Widget _buildListTile(int index, List<Map<String, dynamic>> incidentReports) {
    final dateFormat = DateFormat("dd/MM/yyyy HH:mm");
    Widget returnedWidget;

    if (incidentReports.length >= 10 && index == incidentReports.length) {
      if (_loadingMore) {
        returnedWidget = Center(child: Center(child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
              bluePurple),
        ),),);
      } else {
        returnedWidget = Container(
          child: Center(child: Container(width: MediaQuery.of(context).size.width * 0.5, child: GradientButton('Load More', loadMore),),),
        );
      }
    } else {
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
    }
    return returnedWidget;

  }

  Widget _buildPageContent(List<Map<String, dynamic>> incidentReports, IncidentReportModel model) {
    final double deviceHeight = MediaQuery.of(context).size.height;

    if (model.isLoading) {
      return Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      bluePurple),
                ),
                SizedBox(height: 20.0),
                Text('Fetching Incident Reports')
              ]));
    } else if (incidentReports.length == 0) {
      return RefreshIndicator(
          color: bluePurple,
          child: ListView(padding: EdgeInsets.all(10.0), children: <Widget>[
            Container(
                height: deviceHeight * 0.9,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'No Incident Reports available pull down to refresh',
                      textAlign: TextAlign.center,
                    ),
                    Icon(
                      Icons.warning,
                      size: 40.0,
                      color: bluePurple,
                    )
                  ],
                ))
          ]),
          onRefresh: () => model.getIncidentReports());
    } else {
      return RefreshIndicator(
        color: bluePurple,
        child: ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return _buildListTile(index, incidentReports);
          },
          itemCount: incidentReports.length >= 10 ? incidentReports.length + 1 : incidentReports.length,
        ),
        onRefresh: () => model.getIncidentReports(),
      );
    }
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
            drawer: SideDrawer(),
            body: _buildPageContent(incidentReports, model));
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pegasus_medical_1808/models/transfer_report_model.dart';
import 'package:pegasus_medical_1808/widgets/app_bar_gradient.dart';
import '../../shared/global_config.dart';
import '../../shared/global_functions.dart';
import 'package:provider/provider.dart';
import 'completed_transfer_report_overall.dart';



class TransferReportSearchResults extends StatefulWidget {

  final DateTime dateFrom;
  final DateTime dateTo;

  TransferReportSearchResults(this.dateFrom, this.dateTo);


  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _TransferReportSearchResultsState();
  }
}

class _TransferReportSearchResultsState extends State<TransferReportSearchResults> {

  TransferReportModel transferReportModel;


  @override
  initState() {
    transferReportModel = Provider.of<TransferReportModel>(context, listen: false);
    super.initState();
  }


  void _viewTransferReport(int index){
    transferReportModel.selectTransferReport(transferReportModel.allTransferReports[index]['document_id']);
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return CompletedTransferReportOverall();
    })).then((_) {
      transferReportModel.selectTransferReport(null);
    });
  }

  Widget _buildListTile(int index, List<Map<String, dynamic>> transferReports) {
    final dateFormat = DateFormat("dd/MM/yyyy HH:mm");
    Widget returnedWidget;
      returnedWidget = Column(
        children: <Widget>[
          InkWell(onTap: () => _viewTransferReport(index),
            child: ListTile(
              leading: Icon(Icons.library_books_sharp, color: bluePurple,),
              title: GlobalFunctions.boldTitleText('Job Ref: ', transferReports[index]['job_ref'], context),
              subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                GlobalFunctions.boldTitleText('Date: ', dateFormat.format(
                    DateTime.parse(transferReports[index]['timestamp'])), context),
              ],),
            ),),
          Divider(),
        ],
      );
    //}
    return returnedWidget;

  }


  Widget _buildPageContent(List<Map<String, dynamic>> transferReports) {

    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        return _buildListTile(index, transferReports);
      },
      itemCount: transferReports.length,
    );
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Consumer<TransferReportModel>(
      builder: (context, model, child) {
        List<Map<String, dynamic>> transferReports = model.allTransferReports;
        return Scaffold(
            appBar: AppBar(backgroundColor: greyDesign1,
              iconTheme: IconThemeData(color: Colors.white),
              flexibleSpace: AppBarGradient(),
              title: FittedBox(fit:BoxFit.fitWidth,
                  child: Text('Transfer Report List', style: TextStyle(fontWeight: FontWeight.bold),)),
            ),
            body: _buildPageContent(transferReports));
      },
    );
  }
}



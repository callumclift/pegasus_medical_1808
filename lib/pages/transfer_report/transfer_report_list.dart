import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pegasus_medical_1808/models/transfer_report_model.dart';
import 'package:pegasus_medical_1808/widgets/app_bar_gradient.dart';
import 'package:pegasus_medical_1808/widgets/gradient_button.dart';
import '../../widgets/side_drawer.dart';
import '../../shared/global_config.dart';
import '../../shared/global_functions.dart';
import 'package:provider/provider.dart';

import 'completed_transfer_report_overall.dart';

class CompletedTransferReportsListPage extends StatefulWidget {


  CompletedTransferReportsListPage();

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _CompletedTransferReportsListPageState();
  }
}

class _CompletedTransferReportsListPageState extends State<CompletedTransferReportsListPage> {

  bool _loadingMore = false;
  TransferReportModel transferReportModel;


  @override
  initState() {

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      transferReportModel = context.read<TransferReportModel>();

      transferReportModel.getTransferReports();
    });
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

  void loadMore() async {
    setState(() {
      _loadingMore = true;

    });
    await transferReportModel.getMoreTransferReports();
    setState(() {
      _loadingMore = false;
    });
  }

  Widget _buildListTile(int index, List<Map<String, dynamic>> transferReports) {
    final dateFormat = DateFormat("dd/MM/yyyy HH:mm");
    Widget returnedWidget;

    if (transferReports.length >= 10 && index == transferReports.length) {
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
    }
    return returnedWidget;

  }

  Widget _buildPageContent(List<Map<String, dynamic>> transferReports, TransferReportModel model) {
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
                Text('Fetching Transfer Reports')
              ]));
    } else if (transferReports.length == 0) {
      return RefreshIndicator(
          color: bluePurple,
          child: ListView(padding: EdgeInsets.all(10.0), children: <Widget>[
            Container(
                height: deviceHeight * 0.9,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'No Transfer Reports available pull down to refresh',
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
          onRefresh: () => model.getTransferReports());
    } else {
      return RefreshIndicator(
        color: bluePurple,
        child: ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return _buildListTile(index, transferReports);
          },
          itemCount: transferReports.length >= 10 ? transferReports.length + 1 : transferReports.length,
        ),
        onRefresh: () => model.getTransferReports(),
      );
    }
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
            drawer: SideDrawer(),
            body: _buildPageContent(transferReports, model));
      },
    );
  }
}

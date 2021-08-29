import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:pegasus_medical_1808/pages/transfer_report/transfer_report_overall.dart';
import 'package:pegasus_medical_1808/widgets/app_bar_gradient.dart';
import '../../models/authentication_model.dart';
import 'package:provider/provider.dart';
import '../../widgets/side_drawer.dart';
import '../../shared/global_config.dart';

class HomePage extends StatefulWidget {

  final String argument;

  const HomePage({this.argument});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AfterLayoutMixin<HomePage> {

  @override
  void afterFirstLayout(BuildContext context) async {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => TransferReportOverall(),
        transitionDuration: Duration(seconds: 0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('', style: TextStyle(fontWeight: FontWeight.bold),),
        flexibleSpace: AppBarGradient(),
      ),
      drawer: SideDrawer(),
      body: Center(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(bluePurple),
        ),
      ),
    );
  }
}





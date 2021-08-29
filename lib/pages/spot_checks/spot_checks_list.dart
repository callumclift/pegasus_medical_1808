import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pegasus_medical_1808/models/observation_booking_model.dart';
import 'package:pegasus_medical_1808/models/spot_checks_model.dart';
import 'package:pegasus_medical_1808/widgets/app_bar_gradient.dart';
import 'package:pegasus_medical_1808/widgets/gradient_button.dart';
import '../../widgets/side_drawer.dart';
import '../../shared/global_config.dart';
import '../../shared/global_functions.dart';
import 'package:provider/provider.dart';
import 'completed_spot_checks.dart';

class CompletedSpotChecksListPage extends StatefulWidget {


  CompletedSpotChecksListPage();

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _CompletedSpotChecksListPageState();
  }
}

class _CompletedSpotChecksListPageState extends State<CompletedSpotChecksListPage> {

  bool _loadingMore = false;
  SpotChecksModel spotChecksModel;


  @override
  initState() {

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      spotChecksModel = context.read<SpotChecksModel>();

      spotChecksModel.getSpotChecks();
    });
  }



  void _viewSpotChecks(int index){
    spotChecksModel.selectSpotChecks(spotChecksModel.allSpotChecks[index]['document_id']);
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return CompletedSpotChecks();
    })).then((_) {
      spotChecksModel.selectSpotChecks(null);
    });
  }

  void loadMore() async {
    setState(() {
      _loadingMore = true;

    });
    await spotChecksModel.getMoreSpotChecks();
    setState(() {
      _loadingMore = false;
    });
  }

  Widget _buildListTile(int index, List<Map<String, dynamic>> spotChecks) {
    final dateFormat = DateFormat("dd/MM/yyyy HH:mm");
    Widget returnedWidget;

    if (spotChecks.length >= 10 && index == spotChecks.length) {
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
          InkWell(onTap: () => _viewSpotChecks(index),
            child: ListTile(
              leading: Icon(Icons.library_books_sharp, color: bluePurple,),
              title: GlobalFunctions.boldTitleText('Job Ref: ', spotChecks[index]['job_ref'], context),
              subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                GlobalFunctions.boldTitleText('Date: ', dateFormat.format(
                    DateTime.parse(spotChecks[index]['timestamp'])), context),
              ],),
            ),),
          Divider(),
        ],
      );
    }
    return returnedWidget;

  }

  Widget _buildPageContent(List<Map<String, dynamic>> spotChecks, SpotChecksModel model) {
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
                Text('Fetching Spot Checks')
              ]));
    } else if (spotChecks.length == 0) {
      return RefreshIndicator(
          color: bluePurple,
          child: ListView(padding: EdgeInsets.all(10.0), children: <Widget>[
            Container(
                height: deviceHeight * 0.9,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'No Spot Checks available pull down to refresh',
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
          onRefresh: () => model.getSpotChecks());
    } else {
      return RefreshIndicator(
        color: bluePurple,
        child: ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return _buildListTile(index, spotChecks);
          },
          itemCount: spotChecks.length >= 10 ? spotChecks.length + 1 : spotChecks.length,
        ),
        onRefresh: () => model.getSpotChecks(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Consumer<SpotChecksModel>(
      builder: (context, model, child) {
        List<Map<String, dynamic>> spotChecks = model.allSpotChecks;
        return Scaffold(
            appBar: AppBar(backgroundColor: greyDesign1,
              iconTheme: IconThemeData(color: Colors.white),
              flexibleSpace: AppBarGradient(),
              title: FittedBox(fit:BoxFit.fitWidth,
                  child: Text('Spot Checks List', style: TextStyle(fontWeight: FontWeight.bold),)),
            ),
            drawer: SideDrawer(),
            body: _buildPageContent(spotChecks, model));
      },
    );
  }
}

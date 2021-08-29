import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pegasus_medical_1808/models/spot_checks_model.dart';
import 'package:pegasus_medical_1808/widgets/app_bar_gradient.dart';
import '../../shared/global_config.dart';
import '../../shared/global_functions.dart';
import 'package:provider/provider.dart';
import 'package:pegasus_medical_1808/widgets/gradient_button.dart';
import 'completed_spot_checks.dart';



class SpotChecksSearchResults extends StatefulWidget {

  final DateTime dateFrom;
  final DateTime dateTo;

  SpotChecksSearchResults(this.dateFrom, this.dateTo);


  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SpotChecksSearchResultsState();
  }
}

class _SpotChecksSearchResultsState extends State<SpotChecksSearchResults> {

  SpotChecksModel spotChecksModel;
  bool _loadingMore = false;



  @override
  initState() {
    spotChecksModel = Provider.of<SpotChecksModel>(context, listen: false);
    super.initState();
  }


  void loadMore() async {
    setState(() {
      _loadingMore = true;

    });
    await spotChecksModel.searchMoreSpotChecks(widget.dateFrom, widget.dateTo);
    setState(() {
      _loadingMore = false;
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

  Widget _buildListTile(int index, List<Map<String, dynamic>> spotChecks) {
    final dateFormat = DateFormat("dd/MM/yyyy HH:mm");
    Widget returnedWidget;

    // if (spotChecks.length >= 10 && index == spotChecks.length) {
    //   if (_loadingMore) {
    //     returnedWidget = Center(child: Center(child: CircularProgressIndicator(
    //       valueColor: AlwaysStoppedAnimation<Color>(
    //           bluePurple),
    //     ),),);
    //   } else {
    //     returnedWidget = Container(
    //       child: Center(child: Container(width: MediaQuery.of(context).size.width * 0.5, child: GradientButton('Load More', loadMore),),),
    //     );
    //   }
    // } else {
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
    //}
    return returnedWidget;

  }


  Widget _buildPageContent(List<Map<String, dynamic>> spotChecks) {

    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        return _buildListTile(index, spotChecks);
      },
      itemCount: spotChecks.length >= 10 ? spotChecks.length + 1 : spotChecks.length,
    );
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
            body: _buildPageContent(spotChecks));
      },
    );
  }
}



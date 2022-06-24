import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pegasus_medical_1808/models/bed_rota_model.dart';
import 'package:pegasus_medical_1808/widgets/app_bar_gradient.dart';
import 'package:pegasus_medical_1808/widgets/gradient_button.dart';
import '../../widgets/side_drawer.dart';
import '../../shared/global_config.dart';
import '../../shared/global_functions.dart';
import 'package:provider/provider.dart';
import 'completed_bed_rota.dart';

class CompletedBedRotasListPage extends StatefulWidget {


  CompletedBedRotasListPage();

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _CompletedBedRotasListPageState();
  }
}

class _CompletedBedRotasListPageState extends State<CompletedBedRotasListPage> {

  bool _loadingMore = false;
  BedRotaModel bedRotaModel;


  @override
  initState() {

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      bedRotaModel = context.read<BedRotaModel>();

      bedRotaModel.getBedRotas();
    });
  }



  void _viewBedRota(int index){
    bedRotaModel.selectBedRota(bedRotaModel.allBedRotas[index]['document_id']);
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return CompletedBedRota();
    })).then((_) {
      bedRotaModel.selectBedRota(null);
    });
  }

  void loadMore() async {
    setState(() {
      _loadingMore = true;

    });
    await bedRotaModel.getMoreBedRotas();
    setState(() {
      _loadingMore = false;
    });
  }

  Widget _buildListTile(int index, List<Map<String, dynamic>> bedRotas) {
    final dateFormat = DateFormat("dd/MM/yyyy HH:mm");
    Widget returnedWidget;

    if (bedRotas.length >= 10 && index == bedRotas.length) {
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
          InkWell(onTap: () => _viewBedRota(index),
            child: ListTile(
              leading: Icon(Icons.library_books_sharp, color: bluePurple,),
              title: GlobalFunctions.boldTitleText('Job Ref: ', bedRotas[index]['job_ref'], context),
              subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                GlobalFunctions.boldTitleText('Date: ', dateFormat.format(
                    DateTime.parse(bedRotas[index]['timestamp'])), context),
              ],),
            ),),
          Divider(),
        ],
      );
    }
    return returnedWidget;

  }

  Widget _buildPageContent(List<Map<String, dynamic>> bedRotas, BedRotaModel model) {
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
                Text('Fetching Bed Watch Rotas')
              ]));
    } else if (bedRotas.length == 0) {
      return RefreshIndicator(
          color: bluePurple,
          child: ListView(padding: EdgeInsets.all(10.0), children: <Widget>[
            Container(
                height: deviceHeight * 0.9,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'No Bed Watch Rotas available pull down to refresh',
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
          onRefresh: () => model.getBedRotas());
    } else {
      return RefreshIndicator(
        color: bluePurple,
        child: ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return _buildListTile(index, bedRotas);
          },
          itemCount: bedRotas.length >= 10 ? bedRotas.length + 1 : bedRotas.length,
        ),
        onRefresh: () => model.getBedRotas(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Consumer<BedRotaModel>(
      builder: (context, model, child) {
        List<Map<String, dynamic>> bedRotas = model.allBedRotas;
        return Scaffold(
            appBar: AppBar(backgroundColor: greyDesign1,
              iconTheme: IconThemeData(color: Colors.white),
              flexibleSpace: AppBarGradient(),
              title: FittedBox(fit:BoxFit.fitWidth,
                  child: Text('Bed Watch Rota List', style: TextStyle(fontWeight: FontWeight.bold),)),
            ),
            drawer: SideDrawer(),
            body: _buildPageContent(bedRotas, model));
      },
    );
  }
}

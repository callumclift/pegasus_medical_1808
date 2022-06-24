import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pegasus_medical_1808/models/bed_rota_model.dart';
import 'package:pegasus_medical_1808/widgets/app_bar_gradient.dart';
import '../../shared/global_config.dart';
import '../../shared/global_functions.dart';
import 'package:provider/provider.dart';
import 'completed_bed_rota.dart';



class BedRotaSearchResults extends StatefulWidget {

  final DateTime dateFrom;
  final DateTime dateTo;

  BedRotaSearchResults(this.dateFrom, this.dateTo);


  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _BedRotaSearchResultsState();
  }
}

class _BedRotaSearchResultsState extends State<BedRotaSearchResults> {

  BedRotaModel bedRotaModel;


  @override
  initState() {
    bedRotaModel = Provider.of<BedRotaModel>(context, listen: false);
    super.initState();
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

  Widget _buildListTile(int index, List<Map<String, dynamic>> bedRotas) {
    final dateFormat = DateFormat("dd/MM/yyyy HH:mm");
    Widget returnedWidget;
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
    //}
    return returnedWidget;

  }


  Widget _buildPageContent(List<Map<String, dynamic>> bedRotas) {

    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        return _buildListTile(index, bedRotas);
      },
      itemCount: bedRotas.length,
    );
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
            body: _buildPageContent(bedRotas));
      },
    );
  }
}



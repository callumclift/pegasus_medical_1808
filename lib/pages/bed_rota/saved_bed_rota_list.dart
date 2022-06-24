import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pegasus_medical_1808/models/bed_rota_model.dart';
import 'package:pegasus_medical_1808/shared/strings.dart';
import 'package:pegasus_medical_1808/widgets/app_bar_gradient.dart';
import '../../widgets/side_drawer.dart';
import '../../shared/global_config.dart';
import '../../shared/global_functions.dart';
import 'package:provider/provider.dart';
import 'bed_rota.dart';

class SavedBedRotasListPage extends StatefulWidget {


  SavedBedRotasListPage();

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SavedBedRotasListPageState();
  }
}

class _SavedBedRotasListPageState extends State<SavedBedRotasListPage> {

  BedRotaModel bedRotaModel;

  @override
  initState() {

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      bedRotaModel = context.read<BedRotaModel>();
      bedRotaModel.getSavedRecordsList();
    });
  }



  void _viewBedRota(int index, int id){
    Navigator.of(context).push(
        MaterialPageRoute(builder: (BuildContext context) {
          return BedRota(false, '1', false, false, true, id);
        })).then((_) {
        bedRotaModel.getSavedRecordsList();
    });
  }

  void _deleteForm(int id) async {

    bool delete = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0))),
            contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
            titlePadding: EdgeInsets.all(0),
            title: Container(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [purpleDesign, purpleDesign]),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(32),
                    topRight: Radius.circular(32)),
              ),
              child: Center(child: Text("Delete Record", style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),),),
            ),
            content: Text(
                'Are you sure you want to delete this record?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                  Navigator.of(context).pop(false);
                },
                child: Text(
                  'No',
                  style: TextStyle(
                      color: blueDesign, fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(true);
                },
                child: Text(
                  'Yes',
                  style: TextStyle(
                      color: blueDesign, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        });

    if(delete) await bedRotaModel.deleteSavedRecord(id);
  }



  Widget _buildListTile(int index, List<Map<String, dynamic>> bedRotas) {
    final dateFormat = DateFormat("dd/MM/yyyy");

    return Column(
      children: <Widget>[
        InkWell(onTap: () => _viewBedRota(index, bedRotas[index][Strings.localId]),
          child: ListTile(
            leading: Icon(Icons.library_books_sharp, color: bluePurple,),
            trailing: IconButton(icon: Icon(Icons.delete, color: bluePurple,), onPressed: () => _deleteForm(bedRotas[index][Strings.localId]),),
            title: GlobalFunctions.boldTitleText('Job Ref: ', GlobalFunctions.buildJobRef(bedRotas[index]['job_ref_ref'], bedRotas[index]['job_ref_no']), context),
            subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              GlobalFunctions.boldTitleText('Date: ', bedRotas[index][Strings.weekCommencing] == null ? '' : dateFormat.format(
                  DateTime.parse(bedRotas[index][Strings.weekCommencing])), context),
            ],),
          ),),
        Divider(),
      ],
    );

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
      return ListView(padding: EdgeInsets.all(10.0), children: <Widget>[
        Container(
            height: deviceHeight * 0.9,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'No saved Bed Watch Rotas available',
                  textAlign: TextAlign.center,
                ),
                Icon(
                  Icons.warning,
                  size: 40.0,
                  color: bluePurple,
                )
              ],
            ))
      ]);
    } else {
      return ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return _buildListTile(index, bedRotas);
        },
        itemCount: bedRotas.length,
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
                  child: Text('Saved Bed Watch Rotas', style: TextStyle(fontWeight: FontWeight.bold),)),
            ),
            drawer: SideDrawer(),
            body: _buildPageContent(bedRotas, model));
      },
    );
  }
}

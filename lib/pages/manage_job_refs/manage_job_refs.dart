import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pegasus_medical_1808/models/incident_report_model.dart';
import 'package:pegasus_medical_1808/models/job_refs_model.dart';
import 'package:pegasus_medical_1808/widgets/app_bar_gradient.dart';
import 'package:pegasus_medical_1808/widgets/gradient_button.dart';
import '../../widgets/side_drawer.dart';
import '../../shared/global_config.dart';
import '../../shared/global_functions.dart';
import 'package:provider/provider.dart';

class ManageJobRefsPage extends StatefulWidget {


  ManageJobRefsPage();

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ManageJobRefsPageState();
  }
}

class _ManageJobRefsPageState extends State<ManageJobRefsPage> {

  JobRefsModel jobRefsModel;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _refTextController = new TextEditingController();


  @override
  initState() {

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      jobRefsModel = context.read<JobRefsModel>();

      jobRefsModel.getJobRefs();
    });
  }

  @override
  void dispose() {
    _refTextController.dispose();
    super.dispose();
  }

  void _addRef() async{

    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) { return AlertDialog(
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
                borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
              ),
              child: Center(child: Text("Add Job Ref", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),),
            ),
            content: Form(
                key: _formKey,
                child: SingleChildScrollView(child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(width: 350, child: Text(
                        'Use the textbox below to add a job ref to the job ref dropdown for all forms'),),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Flexible(
                            child: TextFormField(
                              decoration: InputDecoration(
                                  labelText: 'Job Ref'),
                              controller: _refTextController,
                              validator: (String value) {
                                String returnValue;
                                if (value.trim().length <= 0 && value.isEmpty) {
                                  returnValue = 'Please enter a Job Ref';
                                }
                                return returnValue;
                              },
                            )),
                      ],
                    ),
                  ],
                ),)),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: bluePurple),
                ),
              ),
              TextButton(
                onPressed: () async {

                  if(_formKey.currentState.validate()){

                    FocusScope.of(context).requestFocus(new FocusNode());
                    ConnectivityResult connectivityResult =
                    await Connectivity().checkConnectivity();

                    if (connectivityResult == ConnectivityResult.none) {
                      GlobalFunctions.showToast(
                          'No data connection to add job ref');
                    } else {

                      GlobalFunctions.showLoadingDialog('Adding Job Ref');

                      bool success = await jobRefsModel.addJobRef(_refTextController.text.toUpperCase());

                      GlobalFunctions.dismissLoadingDialog();

                      if(success == true){
                        Navigator.of(context).pop();
                        GlobalFunctions.showToast(
                            'Job Ref successfully added');
                      } else {
                        GlobalFunctions.showToast(
                            'unable add Job Ref');
                      }



                    }

                  }

                },
                child: Text(
                  'OK',
                  style: TextStyle(color: bluePurple),
                ),
              ),
            ],
          );});
        });


  }




  Widget _buildListTile(int index, List<Map<String, dynamic>> jobRefs) {
      return Column(
        children: <Widget>[
          ListTile(
            title: Text(jobRefs[index]['job_ref']),
            trailing: IconButton(onPressed: () => jobRefsModel.deleteJobRef(jobRefs[index]['document_id']), icon: Icon(Icons.delete, color: bluePurple,)),
          ),
          Divider(),
        ],
      );
  }

  Widget _buildPageContent(List<Map<String, dynamic>> jobRefs, JobRefsModel model) {
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
                Text('Fetching Job Refs')
              ]));
    } else if (jobRefs.length == 0) {
      return RefreshIndicator(
          color: bluePurple,
          child: ListView(padding: EdgeInsets.all(10.0), children: <Widget>[
            Container(
                height: deviceHeight * 0.9,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'No Job Refs available pull down to refresh',
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
          onRefresh: () => model.getJobRefs());
    } else {
      return RefreshIndicator(
        color: bluePurple,
        child: ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return _buildListTile(index, jobRefs);
          },
          itemCount: jobRefs.length,
        ),
        onRefresh: () => model.getJobRefs(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Consumer<JobRefsModel>(
      builder: (context, model, child) {
        List<Map<String, dynamic>> jobRefs = model.allJobRefs;
        return Scaffold(
            appBar: AppBar(
              flexibleSpace: AppBarGradient(),
              title: FittedBox(fit:BoxFit.fitWidth,
                  child: Text('Manage Job Refs', style: TextStyle(fontWeight: FontWeight.bold),)),
              actions: <Widget>[
                IconButton(icon: Icon(Icons.add), onPressed: _addRef),
              ],
            ),
            drawer: SideDrawer(),
            body: _buildPageContent(jobRefs, model));
      },
    );
  }
}


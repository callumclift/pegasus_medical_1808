import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pegasus_medical_1808/models/incident_report_model.dart';
import 'package:pegasus_medical_1808/models/job_refs_model.dart';
import 'package:pegasus_medical_1808/pages/incident_report/incident_report_search_results.dart';
import 'package:pegasus_medical_1808/widgets/dropdown_form_field.dart';
import '../../shared/global_config.dart';
import 'package:pegasus_medical_1808/widgets/app_bar_gradient.dart';
import '../../widgets/side_drawer.dart';
import 'package:pegasus_medical_1808/widgets/gradient_button.dart';
import 'package:provider/provider.dart';





class IncidentReportSearch extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _IncidentReportSearchState();
  }
}

class _IncidentReportSearchState
    extends State<IncidentReportSearch> {

  final dateFormat = DateFormat("dd/MM/yyyy");
  final timeFormat = DateFormat("HH:mm");
  DateTime dateFrom;
  DateTime dateTo;
  final TextEditingController dateFromController = TextEditingController();
  final TextEditingController dateToController = TextEditingController();
  final TextEditingController jobRef = TextEditingController();
  String selectedUser;
  int jobRefNo;
  JobRefsModel jobRefsModel;
  String jobRefRef = 'Select One';
  List<String> jobRefDrop = [
    'Select One',
  ];

  bool _loadingJobRefs = false;



  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String infoText = 'Use the below filters to search for completed Incident Reports. Dates are based upon the day a report was originally submitted';

  @override
  initState() {
    _loadingJobRefs = true;
    jobRefsModel = context.read<JobRefsModel>();
    _getJobRefs();
    super.initState();
  }

  @override
  void dispose() {
    jobRef.dispose();
    dateFromController.dispose();
    dateToController.dispose();
    super.dispose();
  }

  _getJobRefs() async {
    await jobRefsModel.getJobRefs();

    if(jobRefsModel.allJobRefs.isNotEmpty){
      for(Map<String, dynamic> jobRefMap in jobRefsModel.allJobRefs){
        jobRefDrop.add(jobRefMap['job_ref']);
      }
    }
    setState(() {
      _loadingJobRefs = false;
    });
  }

  Widget _buildJobRefDrop() {
    return DropdownFormField(
      hint: 'Ref',
      expanded: false,
      value: jobRefRef,
      items: jobRefDrop.toList(),
      onChanged: (val) => setState(() {
        jobRefRef = val;
        FocusScope.of(context).unfocus();
      }),
      initialValue: jobRefRef,
    );
  }


  Widget _buildDateFromField() {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Flexible(
              child: IgnorePointer(
                child: TextFormField(
                  enabled: true,
                  decoration: InputDecoration(labelText: 'Date From:'),
                  initialValue: null,
                  controller: dateFromController,
                ),
              ),
            ),
            dateFromController.text == ''
                ? Container()
                : IconButton(
                color: Colors.grey,
                icon: Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    dateFromController.text = '';
                    dateFrom = null;

                  });
                }),
            IconButton(
                icon: Icon(Icons.access_time,
                    color: bluePurple),
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  showDatePicker(
                      builder: (BuildContext context, Widget child) {
                        return Theme(
                          data: ThemeData.light().copyWith(
                            colorScheme: ColorScheme.light().copyWith(
                              primary: bluePurple,
                            ),
                          ),
                          child: child,
                        );
                      },
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1920),
                      lastDate: DateTime(2100))
                      .then((DateTime newDate) {
                    if (newDate != null) {
                      String dateTime = dateFormat.format(newDate);
                      setState(() {
                        dateFromController.text = dateTime;
                        dateFrom = newDate;
                      });
                    }
                  });
                })
          ],
        ),
      ],
    );
  }

  Widget _buildDateToField() {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Flexible(
              child: IgnorePointer(
                child: TextFormField(
                  enabled: true,
                  decoration: InputDecoration(labelText: 'Date To:'),
                  initialValue: null,
                  controller: dateToController,
                ),
              ),
            ),
            dateToController.text == ''
                ? Container()
                : IconButton(
                color: Colors.grey,
                icon: Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    dateToController.text = '';
                    dateTo = null;

                  });
                }),
            IconButton(
                icon: Icon(Icons.access_time,
                    color: bluePurple),
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  showDatePicker(
                      builder: (BuildContext context, Widget child) {
                        return Theme(
                          data: ThemeData.light().copyWith(
                            colorScheme: ColorScheme.light().copyWith(
                              primary: bluePurple,
                            ),
                          ),
                          child: child,
                        );
                      },
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1920),
                      lastDate: DateTime(2100))
                      .then((DateTime newDate) {
                    if (newDate != null) {
                      newDate = newDate.add(Duration(hours: 23, minutes: 59, seconds: 59));
                      String dateTime = dateFormat.format(newDate);
                      setState(() {
                        dateToController.text = dateTime;
                        dateTo = newDate;
                      });
                    }
                  });
                })
          ],
        ),
      ],
    );
  }


  Widget _textFormField() {
    return TextFormField(
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
      ],
      decoration: InputDecoration(
          labelText: 'Job Ref',
          suffixIcon: jobRef.text == ''
              ? null
              : IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    FocusScope.of(context).unfocus();
                    jobRef.clear();
                  });
                });
              })),
      controller: jobRef,
    );
  }

  void _resetFormSearch() {
    showDialog(
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
                borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
              ),
              child: Center(child: Text("Notice", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),),
            ),
            content: Text('Are you sure you wish to reset this form?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'No',
                  style: TextStyle(color: bluePurple),
                ),
              ),
              GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  child: TextButton(
                    onPressed: () {

                      setState(() {
                        dateFrom = null;
                        dateTo = null;
                        dateFromController.text = '';
                        dateToController.text = '';
                        jobRef.clear();
                        jobRefRef = 'Select One';
                        jobRefNo = null;
                        selectedUser = null;
                      });
                      FocusScope.of(context).requestFocus(new FocusNode());
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Yes',
                      style: TextStyle(color: bluePurple),
                    ),
                  ),
                  onTap: () {
                    FocusScope.of(context).requestFocus(new FocusNode());
                  }),
            ],
          );
        });
  }



  Widget _buildSubmitButton() {
    return Center(child: GradientButton('Search', () => _submitForm()),);
  }

  void _submitForm() async{

    if((selectedUser == null && jobRefRef == 'Select One' && jobRef.text.isEmpty && dateFromController.text.isEmpty && dateToController.text.isEmpty) || (dateFromController.text.isEmpty && dateToController.text.isNotEmpty) || (dateToController.text.isEmpty && dateFromController.text.isNotEmpty) || (dateFrom != null &&  dateTo != null && dateFrom.isAfter(dateTo))){
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(shape: RoundedRectangleBorder(
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
                child: Center(child: Text("Notice", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),),
              ),
              content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                Text('Please ensure you have completed the following fields:', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold),),
                SizedBox(height: 10.0,),
                selectedUser == null && jobRefRef == 'Select One' && jobRef.text.isEmpty && dateFromController.text.isEmpty && dateToController.text.isEmpty ? Text("- Please enter some data", textAlign: TextAlign.left,) : Container(),
                dateFromController.text.isEmpty && dateToController.text.isNotEmpty ? Text("- Date From", textAlign: TextAlign.left,) : Container(),
                dateToController.text.isEmpty && dateFromController.text.isNotEmpty ? Text("- Date To", textAlign: TextAlign.left,) : Container(),
                dateFrom != null &&  dateTo != null && dateFrom.isAfter(dateTo) ? Text("- Date From cannot be after Date To", textAlign: TextAlign.left,) : Container(),

              ],),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK', style: TextStyle(color: bluePurple),),
                ),
              ],
            );
          });
    } else {

      bool success = await context.read<IncidentReportModel>().searchIncidentReports(dateFrom, dateTo, jobRefRef, jobRef.text.isNotEmpty ? int.parse(jobRef.text) : null, selectedUser);

      if(success) Navigator.of(context)
          .push(MaterialPageRoute(builder: (BuildContext context) {
        return IncidentReportSearchResults(dateFrom, dateTo);
      }));

    }

  }

  Widget _buildPageContent(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 768.0 ? 600.0 : deviceWidth * 0.95;
    final double targetPadding = deviceWidth - targetWidth;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        margin: EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: targetPadding / 2),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                      decoration: BoxDecoration(border: Border.all(width: 2.0)),
                      width: MediaQuery.of(context).size.width,
                      child: Container(
                        padding: EdgeInsets.all(5.0),
                        color: Colors.grey,
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.info),
                            SizedBox(
                              width: 5.0,
                            ),
                            Flexible(
                                child: Text(
                                    infoText))
                          ],
                        ),
                      )),
                  Row(children: [
                    Flexible(child: _buildJobRefDrop()),
                    Container(width: 10,),
                    Flexible(child: _textFormField()),
                  ],),
                  user != null && user.role == 'Super User' ? StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection("users").where('deleted', isEqualTo: false).orderBy('name_lowercase', descending: false).snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData)
                          return Container();
                        else {
                          List<DropdownMenuItem> userItems = [
                            DropdownMenuItem(
                              child: Text(
                                'Any',
                              ),
                              value: "Any",
                            )
                          ];
                          for (int i = 0; i < snapshot.data.docs.length; i++) {
                            DocumentSnapshot snap = snapshot.data.docs[i];
                            userItems.add(
                              DropdownMenuItem(
                                child: Text(
                                  snap.get('name'),
                                ),
                                value: "${snap.id}",
                              ),
                            );
                          }
                          return Container(
                            height: 70,
                            child: DropdownButton(underline: Divider(color: Colors.black,),
                              items: userItems,
                              onChanged: (value) {

                                if(value == 'Any'){
                                  setState(() {
                                    selectedUser = null;
                                  });
                                } else {
                                  setState(() {
                                    selectedUser = value;
                                  });
                                }

                              },
                              value: selectedUser,
                              isExpanded: true,

                              hint: Text(
                                "User",
                              ),
                            ),
                          );
                        }
                      }) : Container(),
                  _buildDateFromField(),
                  _buildDateToField(),
                  SizedBox(height: 10.0,),
                  _buildSubmitButton()
                ]),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(drawer: SideDrawer(),
      appBar: AppBar(
        flexibleSpace: AppBarGradient(),
        title: FittedBox(fit:BoxFit.fitWidth,
            child: Text('Incident Report Search', style: TextStyle(fontWeight: FontWeight.bold),)),
        actions: <Widget>[IconButton(icon: Icon(Icons.refresh), onPressed: _resetFormSearch)],
      ),
      body: _loadingJobRefs
          ? Center(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(bluePurple),
        ),
      ) : _buildPageContent(context),
    );
  }
}

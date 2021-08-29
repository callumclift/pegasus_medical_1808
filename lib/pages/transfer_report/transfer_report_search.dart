import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pegasus_medical_1808/models/transfer_report_model.dart';
import 'package:pegasus_medical_1808/pages/transfer_report/transfer_report_search_results.dart';
import '../../shared/global_config.dart';
import '../../shared/global_functions.dart';
import 'package:pegasus_medical_1808/widgets/app_bar_gradient.dart';
import '../../widgets/side_drawer.dart';
import 'package:pegasus_medical_1808/widgets/gradient_button.dart';
import 'package:provider/provider.dart';





class TransferReportSearch extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _TransferReportSearchState();
  }
}

class _TransferReportSearchState
    extends State<TransferReportSearch> {

  final dateFormat = DateFormat("dd/MM/yyyy");
  final timeFormat = DateFormat("HH:mm");
  DateTime dateFrom;
  DateTime dateTo;
  final TextEditingController dateFromController = TextEditingController();
  final TextEditingController dateToController = TextEditingController();
  final TextEditingController jobRef = TextEditingController();
  String selectedUser;
  String selectedGender;
  bool handcuffs = false;
  bool physicalIntervention = false;
  List<DropdownMenuItem> genderItems = [
    DropdownMenuItem(
      child: Text(
        'Any',
      ),
      value: "Any",
    ),
    DropdownMenuItem(
      child: Text(
        'Female',
      ),
      value: "Female",
    ),
    DropdownMenuItem(
      child: Text(
        'Male',
      ),
      value: "Male",
    ),
    DropdownMenuItem(
      child: Text(
        'Other',
      ),
      value: "Other",
    )
  ];


  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String infoText = 'Use the below filters to search for completed Transfer Reports. Dates are based upon the day a report was originally submitted';

  @override
  initState() {
    super.initState();
  }

  @override
  void dispose() {
    print('dispose');
    jobRef.dispose();
    dateFromController.dispose();
    dateToController.dispose();
    super.dispose();
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
                        handcuffs = false;
                        physicalIntervention = false;
                        selectedUser = null;
                        selectedGender = null;
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

    if((handcuffs == false && physicalIntervention == false && selectedGender == null && selectedUser == null && jobRef.text.isEmpty && dateFromController.text.isEmpty && dateToController.text.isEmpty) || (dateFromController.text.isEmpty && dateToController.text.isNotEmpty) || (dateToController.text.isEmpty && dateFromController.text.isNotEmpty) || (dateFrom != null &&  dateTo != null && dateFrom.isAfter(dateTo))){
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
                handcuffs == false && physicalIntervention == false && selectedGender == null && selectedUser == null && jobRef.text.isEmpty && dateFromController.text.isEmpty && dateToController.text.isEmpty ? Text("- Please enter some data", textAlign: TextAlign.left,) : Container(),
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

      bool success = await context.read<TransferReportModel>().searchTransferReports(dateFrom, dateTo, jobRef.text, selectedGender, selectedUser, handcuffs, physicalIntervention);

      if(success) Navigator.of(context)
          .push(MaterialPageRoute(builder: (BuildContext context) {
        return TransferReportSearchResults(dateFrom, dateTo);
      }));

    }

  }

  Widget _buildHandcuffsRow() {
    return Row(
      children: <Widget>[
        Text(
          'Handcuffs?', style: TextStyle(fontSize: 16),
        ),
        Checkbox(
            activeColor: bluePurple,
            value: handcuffs,
            onChanged: (bool value) => setState(() {
              handcuffs = value;
            })),
      ],
    );
  }

  Widget _buildPhysicalInterventionRow() {
    return Row(
      children: <Widget>[
        Text(
          'Physical Intervention?', style: TextStyle(fontSize: 16),
        ),
        Checkbox(
            activeColor: bluePurple,
            value: physicalIntervention,
            onChanged: (bool value) => setState(() {
              physicalIntervention = value;
            })),
      ],
    );
  }

  Widget _buildPageContent(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 768.0 ? 600.0 : deviceWidth * 0.95;
    final double targetPadding = deviceWidth - targetWidth;

    print('building page content');

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
                  _textFormField(),
                  user != null && user.role == 'Super User' ? StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection("users").orderBy('name_lowercase', descending: false).snapshots(),
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
                                  snap.data()['name'],
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
                  // Container(
                  //   height: 70,
                  //   child: DropdownButton(underline: Divider(color: Colors.black,),
                  //     items: genderItems,
                  //     onChanged: (value) {
                  //     if(value == 'Any'){
                  //       setState(() {
                  //         selectedGender = null;
                  //       });
                  //     } else {
                  //       setState(() {
                  //         selectedGender = value;
                  //       });
                  //     }
                  //
                  //     },
                  //     value: selectedGender,
                  //     isExpanded: true,
                  //
                  //     hint: Text(
                  //       "Patient Gender",
                  //     ),
                  //   ),
                  // ),
                  _buildHandcuffsRow(),
                  _buildPhysicalInterventionRow(),
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

    print('[Search Forms] - build page');

    // TODO: implement build
    return Scaffold(drawer: SideDrawer(),
      appBar: AppBar(
          flexibleSpace: AppBarGradient(),
          title: FittedBox(fit:BoxFit.fitWidth,
              child: Text('Transfer Report Search', style: TextStyle(fontWeight: FontWeight.bold),)),
        actions: <Widget>[IconButton(icon: Icon(Icons.refresh), onPressed: _resetFormSearch)],
      ),
      body: _buildPageContent(context),
    );
  }
}

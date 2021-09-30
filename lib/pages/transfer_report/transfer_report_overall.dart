import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pegasus_medical_1808/models/authentication_model.dart';
import 'package:pegasus_medical_1808/models/transfer_report_model.dart';
import 'package:pegasus_medical_1808/utils/database_helper.dart';
import 'package:pegasus_medical_1808/widgets/app_bar_gradient.dart';
import 'package:provider/provider.dart';
import 'transfer_report_section1.dart';
import 'transfer_report_section2.dart';
import 'transfer_report_section3.dart';
import 'transfer_report_section4.dart';
import 'transfer_report_section5.dart';
import '../../widgets/side_drawer.dart';
import '../../shared/global_config.dart';
import 'package:pegasus_medical_1808/shared/strings.dart';
import 'package:intl/intl.dart';



class TransferReportOverall extends StatefulWidget {

  final int initialIndex;
  final bool fromJob;
  final String jobId;
  final bool fillDetails;
  final bool edit;
  final bool saved;
  final int savedId;

  TransferReportOverall(
      [
        this.initialIndex = 0,
        this.fromJob = false,
        this.jobId = '1',
        this.fillDetails = false,
        this.edit = false,
        this.saved = false,
        this.savedId = 0
      ]
      );

  @override
  _TransferReportOverallState createState() => _TransferReportOverallState();
}

class _TransferReportOverallState extends State<TransferReportOverall> with SingleTickerProviderStateMixin {

  TabController tabController;
  //DatabaseHelper _databaseHelper = DatabaseHelper();
  final timeFormat = DateFormat("HH:mm");
  int tabIndex;


  @override
  void initState(){
    tabController = TabController(length: 5, vsync: this, initialIndex: widget.initialIndex);
    tabController.addListener(() {
      tabIndex = tabController.index;
      FocusScope.of(context).requestFocus(new FocusNode()); //remove focus
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {


    void _resetTransferReport() {
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
                child: Center(child: Text("Reset Transfer Report", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),),
              ),
              content: Text('Are you sure you wish to reset this form?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'No',
                    style: TextStyle(color: blueDesign, fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    await context.read<TransferReportModel>().resetTemporaryRecord(widget.jobId, widget.saved, widget.savedId);
                    if(kIsWeb){
                      await context.read<TransferReportModel>().resetTemporaryRecord(widget.jobId, widget.saved, widget.savedId);
                    }
                    //context.read<TransferReportModel>().resetTemporaryTransferReport(widget.jobId, widget.saved, widget.savedId);
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) => TransferReportOverall(tabIndex == null ? widget.initialIndex : tabIndex),
                        transitionDuration: Duration(seconds: 0),
                      ),
                    );
                  },
                  child: Text(
                    'Yes',
                    style: TextStyle(color: blueDesign, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          });
    }

    void _submitForm() async{
      FocusScope.of(context).unfocus();
      bool submitForm = await showDialog(
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
                child: Center(child: Text("Submit Transfer Report", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),),
              ),
              content: Text('Are you sure you wish to submit this form?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    Navigator.of(context).pop(false);
                  },
                  child: Text(
                    'No',
                    style: TextStyle(color: blueDesign, fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: () async{
                    Navigator.of(context).pop(true);
                  },
                  child: Text(
                    'Yes',
                    style: TextStyle(color: blueDesign, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          });



      if(submitForm){


        bool hasStartTime = true;
        bool hasFinishTime = true;



        Map<String, dynamic> transferReport = await context.read<TransferReportModel>().getTemporaryRecord(widget.edit, widget.jobId, widget.saved, widget.savedId);
        if(transferReport[Strings.startTime] == null) hasStartTime = false;
        if(transferReport[Strings.finishTime] == null) hasFinishTime = false;




        if(!hasStartTime && !hasFinishTime){

          //Get Start Time

          await showDialog(
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
                    child: Center(child: Text("Start Time", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Please enter a Start Time', style: TextStyle(color: bluePurple),),
                    ],
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () async{
                        FocusScope.of(context).requestFocus(new FocusNode());
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'OK',
                        style: TextStyle(color: blueDesign, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                );
              });

          await Future.delayed(Duration(milliseconds: 100));

          DateTime startTime = await showDatePicker(
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
              lastDate: DateTime(2100));

            if (startTime != null) {
              TimeOfDay startTimeTime = await showTimePicker(
                  context: context, initialTime: TimeOfDay.now());

              if (startTimeTime != null) {
                startTime =
                    DateTime(startTime.year, startTime.month, startTime.day);
                startTime = startTime.add(
                    Duration(hours: startTimeTime.hour, minutes: startTimeTime.minute));

                await context.read<TransferReportModel>().updateTemporaryRecord(widget.edit, Strings.startTime, DateTime.fromMillisecondsSinceEpoch(
                    startTime.millisecondsSinceEpoch).toIso8601String(), widget.jobId, widget.saved, widget.savedId);

                // await _databaseHelper.updateTemporaryTransferReportField(
                //     widget.edit,
                //     {
                //       Strings.startTime: DateTime.fromMillisecondsSinceEpoch(
                //           startTime.millisecondsSinceEpoch).toIso8601String()
                //     }, user.uid, widget.jobId, widget.saved, widget.savedId);

                hasStartTime = true;
              }
            }

            //Get Finish Time

          if(hasStartTime){



            await showDialog(
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
                      child: Center(child: Text("Finish Time", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Please enter a Finish Time', style: TextStyle(color: bluePurple),),
                      ],
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () async{
                          FocusScope.of(context).requestFocus(new FocusNode());
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'OK',
                          style: TextStyle(color: blueDesign, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  );
                });

            await Future.delayed(Duration(milliseconds: 100));

            DateTime finishTime = await showDatePicker(
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
                lastDate: DateTime(2100));

            if (finishTime != null) {
              TimeOfDay finishTimeTime = await showTimePicker(
                  context: context, initialTime: TimeOfDay.now());

              if (finishTimeTime != null) {
                finishTime =
                    DateTime(finishTime.year, finishTime.month, finishTime.day);
                finishTime = finishTime.add(
                    Duration(hours: finishTimeTime.hour, minutes: finishTimeTime.minute));

                await context.read<TransferReportModel>().updateTemporaryRecord(widget.edit, Strings.finishTime, DateTime.fromMillisecondsSinceEpoch(
                    finishTime.millisecondsSinceEpoch).toIso8601String(), widget.jobId, widget.saved, widget.savedId);

                // await _databaseHelper.updateTemporaryTransferReportField(
                //     widget.edit,
                //     {
                //       Strings.finishTime: DateTime.fromMillisecondsSinceEpoch(
                //           finishTime.millisecondsSinceEpoch).toIso8601String()
                //     }, user.uid, widget.jobId, widget.saved, widget.savedId);

                hasFinishTime = true;



                  int minutes = finishTime
                      .difference(startTime)
                      .inMinutes;
                  String totalHours;

                  if (minutes < 180) {
                    totalHours = '3';
                  } else {
                    totalHours = (minutes / 60).toStringAsFixed(1).replaceAll(RegExp(r"([.]*0)(?!.*\d)"), "");
                  }

                await context.read<TransferReportModel>().updateTemporaryRecord(widget.edit, Strings.totalHours, totalHours, widget.jobId, widget.saved, widget.savedId);

                  // await _databaseHelper.updateTemporaryTransferReportField(
                  //     widget.edit,
                  //     {Strings.totalHours: totalHours}, user.uid, widget.jobId, widget.saved, widget.savedId);

              } else {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) => TransferReportOverall(tabIndex == null ? widget.initialIndex : tabIndex),
                    transitionDuration: Duration(seconds: 0),
                  ),
                );
              }
            } else {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) => TransferReportOverall(tabIndex == null ? widget.initialIndex : tabIndex),
                  transitionDuration: Duration(seconds: 0),
                ),
              );
            }

          }



        } else if(!hasStartTime) {



          //Get Start Time

          await showDialog(
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
                    child: Center(child: Text("Start Time", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Please enter a Start Time', style: TextStyle(color: bluePurple),),
                    ],
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () async{
                        FocusScope.of(context).requestFocus(new FocusNode());
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'OK',
                        style: TextStyle(color: blueDesign, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                );
              });

          await Future.delayed(Duration(milliseconds: 100));

          DateTime startTime = await showDatePicker(
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
              lastDate: DateTime(2100));

          if (startTime != null) {
            TimeOfDay startTimeTime = await showTimePicker(
                context: context, initialTime: TimeOfDay.now());

            if (startTimeTime != null) {
              startTime =
                  DateTime(startTime.year, startTime.month, startTime.day);
              startTime = startTime.add(
                  Duration(hours: startTimeTime.hour, minutes: startTimeTime.minute));

              await context.read<TransferReportModel>().updateTemporaryRecord(widget.edit, Strings.startTime, DateTime.fromMillisecondsSinceEpoch(
                        startTime.millisecondsSinceEpoch).toIso8601String(), widget.jobId, widget.saved, widget.savedId);


              // await _databaseHelper.updateTemporaryTransferReportField(
              //     widget.edit,
              //     {
              //       Strings.startTime: DateTime.fromMillisecondsSinceEpoch(
              //           startTime.millisecondsSinceEpoch).toIso8601String()
              //     }, user.uid, widget.jobId, widget.saved, widget.savedId);

              hasStartTime = true;

              DateTime finishTime = DateTime.parse(transferReport[Strings.finishTime]);

              int minutes = finishTime
                  .difference(startTime)
                  .inMinutes;
              String totalHours;

              if (minutes < 180) {
                totalHours = '3';
              } else {
                totalHours = (minutes / 60).toStringAsFixed(1).replaceAll(RegExp(r"([.]*0)(?!.*\d)"), "");
              }

              await context.read<TransferReportModel>().updateTemporaryRecord(widget.edit, Strings.totalHours, totalHours, widget.jobId, widget.saved, widget.savedId);

              // await _databaseHelper.updateTemporaryTransferReportField(
              //     widget.edit,
              //     {Strings.totalHours: totalHours}, user.uid, widget.jobId, widget.saved, widget.savedId);


            }
          }

        } else if(!hasFinishTime){


          //Get Finish Time

          await showDialog(
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
                    child: Center(child: Text("Finish Time", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Please enter a Finish Time', style: TextStyle(color: bluePurple),),
                    ],
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () async{
                        FocusScope.of(context).requestFocus(new FocusNode());
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'OK',
                        style: TextStyle(color: blueDesign, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                );
              });

          await Future.delayed(Duration(milliseconds: 100));

          DateTime finishTime = await showDatePicker(
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
              lastDate: DateTime(2100));

          if (finishTime != null) {
            TimeOfDay finishTimeTime = await showTimePicker(
                context: context, initialTime: TimeOfDay.now());

            if (finishTimeTime != null) {
              finishTime =
                  DateTime(finishTime.year, finishTime.month, finishTime.day);
              finishTime = finishTime.add(
                  Duration(hours: finishTimeTime.hour, minutes: finishTimeTime.minute));

              await context.read<TransferReportModel>().updateTemporaryRecord(widget.edit, Strings.finishTime, DateTime.fromMillisecondsSinceEpoch(
                  finishTime.millisecondsSinceEpoch).toIso8601String(), widget.jobId, widget.saved, widget.savedId);


              // await _databaseHelper.updateTemporaryTransferReportField(
              //     widget.edit,
              //     {
              //       Strings.finishTime: DateTime.fromMillisecondsSinceEpoch(
              //           finishTime.millisecondsSinceEpoch).toIso8601String()
              //     }, user.uid, widget.jobId, widget.saved, widget.savedId);

              hasFinishTime = true;

              DateTime startTime = DateTime.parse(transferReport[Strings.startTime]);

              int minutes = finishTime
                  .difference(startTime)
                  .inMinutes;
              String totalHours;

              if (minutes < 180) {
                totalHours = '3';
              } else {
                totalHours = (minutes / 60).toStringAsFixed(1).replaceAll(RegExp(r"([.]*0)(?!.*\d)"), "");
              }

              await context.read<TransferReportModel>().updateTemporaryRecord(widget.edit, Strings.totalHours, totalHours, widget.jobId, widget.saved, widget.savedId);

              // await _databaseHelper.updateTemporaryTransferReportField(
              //     widget.edit,
              //     {Strings.totalHours: totalHours}, user.uid, widget.jobId, widget.saved, widget.savedId);


            }
          }
        }


        if(hasStartTime && hasFinishTime) {


          Map<String, dynamic> validationResult = await context.read<TransferReportModel>().validateTransferReport(widget.jobId, widget.edit, widget.saved, widget.savedId);
          if(validationResult['successJobDetails'] == false || validationResult['successVehicleChecklist'] == false || validationResult['successPatientDetails'] == false){
            //Navigator.of(context).pop();
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
                      child: Center(child: Text("Check Form", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                              text: 'Please ensure you have filled in all required fields marked with a',
                              style: TextStyle(color: Colors.black, fontSize: 16, fontFamily: 'Open Sans'),
                              children:
                              [
                                TextSpan(
                                  text: ' *',
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 16, fontFamily: 'Open Sans'),
                                ),                                           ]
                          ),
                        ),
                        SizedBox(height: 10,),
                        Text('Missing fields in the following sections:', style: TextStyle(color: Colors.black),),
                        SizedBox(height: 10,),
                        validationResult['successJobDetails'] == false ? Text('- Job Details', style: TextStyle(color: Colors.black),) : Container(),
                        validationResult['successPatientDetails'] == false ? Text('- Patient Details', style: TextStyle(color: Colors.black),) : Container(),
                        validationResult['successVehicleChecklist'] == false ? Text('- Vehicle Checklist', style: TextStyle(color: Colors.black),) : Container(),
                      ],
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          FocusScope.of(context).requestFocus(new FocusNode());
                          Navigator.of(context).pop();
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation1, animation2) => TransferReportOverall(tabIndex == null ? widget.initialIndex : tabIndex),
                              transitionDuration: Duration(seconds: 0),
                            ),
                          );
                        },
                        child: Text(
                          'OK',
                          style: TextStyle(color: blueDesign, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  );
                });

          } else {

            if(widget.edit){
              bool success = await context.read<TransferReportModel>().editTransferReport(widget.jobId);
              FocusScope.of(context).requestFocus(new FocusNode());
              if(success){
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) => TransferReportOverall(tabIndex == null ? widget.initialIndex : tabIndex),
                    transitionDuration: Duration(seconds: 0),
                  ),
                );
              } else {
                Navigator.of(context).pop();

              }

            } else {
              bool success = await context.read<TransferReportModel>().submitTransferReport(widget.jobId, widget.edit, widget.saved, widget.savedId);
              FocusScope.of(context).requestFocus(new FocusNode());
              if(success){
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) => TransferReportOverall(tabIndex == null ? widget.initialIndex : tabIndex),
                    transitionDuration: Duration(seconds: 0),
                  ),
                );
              } else {
                Navigator.of(context).pop();

              }
            }

          }

        }


      }



    }


    void _saveForLater() async {
      FocusScope.of(context).unfocus();

      bool submitForm = await showDialog(
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
                child: Center(child: Text("Save for later", style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),),),
              ),
              content: Text(
                  'This form will be moved to your saved list, do you wish to proceed?'),
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


      if (submitForm) {
        bool success = await context.read<TransferReportModel>().saveForLater(widget.jobId, widget.saved, widget.savedId);
        FocusScope.of(context).requestFocus(new FocusNode());
        if(success){
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => TransferReportOverall(tabIndex == null ? widget.initialIndex : tabIndex),
              transitionDuration: Duration(seconds: 0),
            ),
          );
        }
      }
    }
    // TODO: implement build
    return Scaffold(
        drawer: widget.edit || widget.saved ? null : SideDrawer(),
      appBar: AppBar(backgroundColor: greyDesign1,

        iconTheme: IconThemeData(color: Colors.white),
        flexibleSpace: AppBarGradient(),
        title: FittedBox(fit:BoxFit.fitWidth,
            child: Text('Transfer Report', style: TextStyle(fontWeight: FontWeight.bold),)),
        bottom: TabBar(
          controller: tabController,
          isScrollable: true, indicatorColor: Colors.white,
          tabs: <Widget>[
            Tab(
              text: 'Job Details',
            ),
            Tab(
              text: 'Patient Details',
            ),
            Tab(
              text: 'Section Checklist',
            ),
            Tab(
              text: 'Feedback',
            ),
            Tab(
              text: 'Vehicle Checklist',
            ),
          ],
        ),actions: <Widget>[
          widget.edit || widget.saved ? Container() : IconButton(icon: Icon(Icons.refresh), onPressed: _resetTransferReport),
          widget.saved || widget.edit ? Container() : IconButton(icon: Icon(Icons.watch_later_outlined), onPressed: _saveForLater),
          IconButton(icon: Icon(Icons.send), onPressed: _submitForm),
        ],
      ),
      body: Consumer<AuthenticationModel>(
        builder: (BuildContext context, model, child) {
          return user == null ? Center(
            child: CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ) : GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
            child: kIsWeb ? TabBarView(
              physics: NeverScrollableScrollPhysics(),
              controller: tabController,
              children: <Widget>[
                TransferReportSection1(widget.fromJob, widget.jobId, widget.fillDetails, widget.edit, widget.saved, widget.savedId),
                TransferReportSection2(widget.fromJob, widget.jobId, widget.fillDetails, widget.edit, widget.saved, widget.savedId),
                TransferReportSection3(widget.fromJob, widget.jobId, widget.fillDetails, widget.edit, widget.saved, widget.savedId),
                TransferReportSection4(widget.fromJob, widget.jobId, widget.fillDetails, widget.edit, widget.saved, widget.savedId),
                TransferReportSection5(widget.fromJob, widget.jobId, widget.fillDetails, widget.edit, widget.saved, widget.savedId),
              ],
            ) : TabBarView(
              controller: tabController,
              children: <Widget>[
                TransferReportSection1(widget.fromJob, widget.jobId, widget.fillDetails, widget.edit, widget.saved, widget.savedId),
                TransferReportSection2(widget.fromJob, widget.jobId, widget.fillDetails, widget.edit, widget.saved, widget.savedId),
                TransferReportSection3(widget.fromJob, widget.jobId, widget.fillDetails, widget.edit, widget.saved, widget.savedId),
                TransferReportSection4(widget.fromJob, widget.jobId, widget.fillDetails, widget.edit, widget.saved, widget.savedId),
                TransferReportSection5(widget.fromJob, widget.jobId, widget.fillDetails, widget.edit, widget.saved, widget.savedId),
              ],
            ),
          );
        }
      )
    );
  }
}

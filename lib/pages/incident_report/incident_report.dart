import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:pegasus_medical_1808/models/incident_report_model.dart';
import 'package:pegasus_medical_1808/shared/global_config.dart';
import 'package:pegasus_medical_1808/shared/global_functions.dart';
import 'package:pegasus_medical_1808/shared/strings.dart';
import 'package:pegasus_medical_1808/utils/database_helper.dart';
import 'package:pegasus_medical_1808/widgets/app_bar_gradient.dart';
import 'package:pegasus_medical_1808/widgets/gradient_button.dart';
import 'package:pegasus_medical_1808/widgets/side_drawer.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:signature/signature.dart';
import 'package:after_layout/after_layout.dart';


class IncidentReport extends StatefulWidget {
  final bool fromJob;
  final String jobId;
  final bool fillDetails;
  final bool edit;

  IncidentReport(
      [this.fromJob = false,
        this.jobId = '1',
        this.fillDetails = false,
        this.edit = false]);

  @override
  _IncidentReportState createState() => _IncidentReportState();
}

class _IncidentReportState extends State<IncidentReport> with AfterLayoutMixin<IncidentReport> {

  bool _loadingTemporary = false;
  DatabaseHelper _databaseHelper = DatabaseHelper();
  IncidentReportModel incidentReportModel;
  final dateFormat = DateFormat("dd/MM/yyyy");
  final timeFormat = DateFormat("HH:mm");
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController jobRef = TextEditingController();
  final TextEditingController incidentDate = TextEditingController();
  final TextEditingController incidentTime = TextEditingController();
  final TextEditingController incidentDetails = TextEditingController();
  final TextEditingController incidentLocation = TextEditingController();
  final TextEditingController incidentAction = TextEditingController();
  final TextEditingController incidentStaffInvolved = TextEditingController();
  final TextEditingController incidentSignatureDate = TextEditingController();
  final TextEditingController incidentPrintName = TextEditingController();

  List<Point> incidentSignaturePoints = [];
  Signature incidentSignature;
  Uint8List incidentImageBytes;





  @override
  void initState() {
    // TODO: implement initState
    _loadingTemporary = true;
    incidentReportModel = Provider.of<IncidentReportModel>(context, listen: false);
    _setUpTextControllerListeners();
    _getTemporaryIncidentReport();
    super.initState();
  }

  @override
  void dispose() {
    jobRef.dispose();
    incidentDate.dispose();
    incidentTime.dispose();
    incidentDetails.dispose();
    incidentLocation.dispose();
    incidentAction.dispose();
    incidentStaffInvolved.dispose();
    incidentPrintName.dispose();
    super.dispose();
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    //  await Future.delayed(Duration(milliseconds: 100));
    // _formKey.currentState.validate();
  }


  _addListener(TextEditingController controller, String value, [bool encrypt = true, bool capitalise = false, bool isName = false]){

    controller.addListener(() {
      setState(() {
      });

      String controllerText = controller.text;

      if(capitalise){
        controllerText = controllerText.toUpperCase();
      }

      if(isName){
        String newString = '';
        List<String> parts = controllerText.split(' ');
        for(String part in parts){
          if(part.isNotEmpty) part = part[0].toUpperCase() + part.substring(1);
          if(newString.isEmpty){
            newString += part;
          } else {
            newString = newString + ' ' + part;
          }
        }

        controllerText = newString;
      }

      //Sembast
      incidentReportModel.updateTemporaryRecord(widget.edit, value, encrypt ? GlobalFunctions.encryptString(controllerText) : GlobalFunctions.databaseValueString(controllerText), widget.jobId);

      //Sqlflite
      // _databaseHelper.updateTemporaryIncidentReportField(widget.edit, {
      //   value:
      //   encrypt ? GlobalFunctions.encryptString(controllerText) : GlobalFunctions.databaseValueString(controllerText)
      // }, user.uid, widget.jobId);
    });
  }

  _setUpTextControllerListeners() {

    _addListener(jobRef, Strings.jobRef, false, true);
    _addListener(incidentDetails, Strings.incidentDetails);
    _addListener(incidentLocation, Strings.incidentLocation);
    _addListener(incidentAction, Strings.incidentAction);
    _addListener(incidentStaffInvolved, Strings.incidentStaffInvolved);
    _addListener(incidentPrintName, Strings.incidentPrintName, true, false, true);

  }

  _getTemporaryIncidentReport() async {

    //Sembast
    if (mounted) {

      await incidentReportModel.setupTemporaryRecord();

      bool hasRecord = await incidentReportModel.checkRecordExists(widget.edit, widget.jobId);

      if(hasRecord){
        Map<String, dynamic> incidentReport = await incidentReportModel.getTemporaryRecord(widget.edit, widget.jobId);

        if (incidentReport[Strings.incidentSignature] != null) {
          if (mounted) {

            Uint8List decryptedSignature = await GlobalFunctions.decryptSignature(incidentReport[Strings.incidentSignature]);
            setState(() {
              incidentImageBytes = decryptedSignature;
            });
          }
        } else {
          incidentSignature = null;
          incidentImageBytes = null;
        }
        if (incidentReport[Strings.incidentSignaturePoints] != null) {
          if (mounted) {
            String decryptedPoints = GlobalFunctions.decryptString(incidentReport[Strings.incidentSignaturePoints]);
            setState(() {
              List<dynamic> fetchedSignaturePoints = jsonDecode(decryptedPoints);
              fetchedSignaturePoints.forEach((dynamic pointMap) {
                if (pointMap['pointType'] == 'tap') {
                  incidentSignaturePoints.add(Point(
                      Offset(pointMap['dx'], pointMap['dy']),
                      PointType.tap));
                } else if (pointMap['pointType'] == 'move') {
                  incidentSignaturePoints.add(Point(
                      Offset(pointMap['dx'], pointMap['dy']),
                      PointType.move));
                }
              });
            });
          }
        } else {
          incidentSignaturePoints = [];

        }

        if (incidentReport[Strings.jobRef] != null) {
          jobRef.text = GlobalFunctions.databaseValueString(
              incidentReport[Strings.jobRef]);
        } else {
          jobRef.text = '';
        }
        if (incidentReport[Strings.incidentDate] != null) {
          incidentDate.text =
              dateFormat.format(DateTime.parse(incidentReport[Strings.incidentDate]));
        } else {
          incidentDate.text = '';
        }
        GlobalFunctions.getTemporaryValueTime(incidentReport, incidentTime, Strings.incidentTime);
        GlobalFunctions.getTemporaryValue(incidentReport, incidentDetails, Strings.incidentDetails);
        GlobalFunctions.getTemporaryValue(incidentReport, incidentLocation, Strings.incidentLocation);
        GlobalFunctions.getTemporaryValue(incidentReport, incidentAction, Strings.incidentAction);
        GlobalFunctions.getTemporaryValue(incidentReport, incidentStaffInvolved, Strings.incidentStaffInvolved);
        GlobalFunctions.getTemporaryValue(incidentReport, incidentPrintName, Strings.incidentPrintName);
        GlobalFunctions.getTemporaryValueDate(incidentReport, incidentSignatureDate, Strings.incidentSignatureDate);


        if (mounted) {
          setState(() {
            _loadingTemporary = false;
          });
        }




      } else {
        if (mounted) {
          setState(() {
            _loadingTemporary = false;
          });
        }
      }

    }

    //Sqlflite

    // if (mounted) {
    //   int result = await _databaseHelper.checkTemporaryIncidentReportExists(widget.edit,
    //       user.uid, widget.jobId);
    //   if (result != 0) {
    //     Map<String, dynamic> incidentReport = await _databaseHelper
    //         .getTemporaryIncidentReport(widget.edit, user.uid, widget.jobId);
    //
    //     if (incidentReport[Strings.incidentSignature] != null) {
    //       if (mounted) {
    //         Uint8List decryptedSignature = await GlobalFunctions.decryptSignature(incidentReport[Strings.incidentSignature]);
    //         setState(() {
    //           incidentImageBytes = decryptedSignature;
    //         });
    //       }
    //     } else {
    //       incidentSignature = null;
    //       incidentImageBytes = null;
    //     }
    //     if (incidentReport[Strings.incidentSignaturePoints] != null) {
    //       if (mounted) {
    //         String decryptedPoints = GlobalFunctions.decryptString(incidentReport[Strings.incidentSignaturePoints]);
    //         setState(() {
    //           List<dynamic> fetchedSignaturePoints = jsonDecode(decryptedPoints);
    //           fetchedSignaturePoints.forEach((dynamic pointMap) {
    //             if (pointMap['pointType'] == 'tap') {
    //               incidentSignaturePoints.add(Point(
    //                   Offset(pointMap['dx'], pointMap['dy']),
    //                   PointType.tap));
    //             } else if (pointMap['pointType'] == 'move') {
    //               incidentSignaturePoints.add(Point(
    //                   Offset(pointMap['dx'], pointMap['dy']),
    //                   PointType.move));
    //             }
    //           });
    //         });
    //       }
    //     } else {
    //       incidentSignaturePoints = [];
    //
    //     }
    //
    //     if (incidentReport[Strings.jobRef] != null) {
    //       jobRef.text = GlobalFunctions.databaseValueString(
    //           incidentReport[Strings.jobRef]);
    //     } else {
    //       jobRef.text = '';
    //     }
    //     if (incidentReport[Strings.incidentDate] != null) {
    //       incidentDate.text =
    //           dateFormat.format(DateTime.parse(incidentReport[Strings.incidentDate]));
    //     } else {
    //       incidentDate.text = '';
    //     }
    //     GlobalFunctions.getTemporaryValueTime(incidentReport, incidentTime, Strings.incidentTime);
    //     GlobalFunctions.getTemporaryValue(incidentReport, incidentDetails, Strings.incidentDetails);
    //     GlobalFunctions.getTemporaryValue(incidentReport, incidentLocation, Strings.incidentLocation);
    //     GlobalFunctions.getTemporaryValue(incidentReport, incidentAction, Strings.incidentAction);
    //     GlobalFunctions.getTemporaryValue(incidentReport, incidentStaffInvolved, Strings.incidentStaffInvolved);
    //     GlobalFunctions.getTemporaryValue(incidentReport, incidentPrintName, Strings.incidentPrintName);
    //     GlobalFunctions.getTemporaryValueDate(incidentReport, incidentSignatureDate, Strings.incidentSignatureDate);
    //
    //
    //     if (mounted) {
    //       setState(() {
    //         _loadingTemporary = false;
    //       });
    //     }
    //   } else {
    //     if (mounted) {
    //       setState(() {
    //         _loadingTemporary = false;
    //       });
    //     }
    //   }
    // }
  }

  Widget _buildIncidentSignatureRow() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 10.0,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                      text: 'Signed',
                      style: TextStyle(
                          fontSize: 16.0, fontFamily: 'Open Sans', color: bluePurple),
                      children:
                      [
                        TextSpan(
                          text: ' *',
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: 16.0, fontFamily: 'Open Sans'),
                        ),                                           ]
                  ),
                )
              ],),
          ],
        ),
        SizedBox(
          height: 10.0,
        ),
        Container(
          child: Center(
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
                if(widget.edit){
                  GlobalFunctions.showToast('Signatures cannot be amended on already submitted forms');
                } else {
                  showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        incidentSignature = Signature(
                          points: incidentSignaturePoints,
                          height: 99,
                          width: 280.0,
                          backgroundColor: Colors.white,
                        );

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
                            child: Center(child: Text("Signature", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            //mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    border: new Border.all(
                                        color: Colors.black, width: 2.0)),
                                height: 100.0,
                                child: incidentSignature,
                              )
                            ],
                          ),
                          actions: <Widget>[
                            TextButton(
                                onPressed: () {
                                  incidentSignature
                                      .clear();

                                  //Sembast

                                  incidentReportModel.updateTemporaryRecord(widget.edit, Strings.incidentSignaturePoints, null, widget.jobId);
                                  incidentReportModel.updateTemporaryRecord(widget.edit, Strings.incidentSignature, null, widget.jobId);

                                  //Sqlflite

                                  // _databaseHelper
                                  //     .updateTemporaryIncidentReportField(widget.edit,
                                  //     {Strings.incidentSignaturePoints: null},
                                  //     user.uid,
                                  //     widget.jobId);
                                  // _databaseHelper
                                  //     .updateTemporaryIncidentReportField(widget.edit,
                                  //     {Strings.incidentSignature: null}, user.uid,
                                  //     widget.jobId);
                                  setState(() {
                                    incidentSignaturePoints = [];
                                    incidentImageBytes =
                                    null;
                                  });
                                },
                                child: Text(
                                  'Clear',
                                  style: TextStyle(color: bluePurple),
                                )),
                            TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(color: bluePurple),
                                )),
                            TextButton(
                                onPressed: () async {
                                  List<Map<String, dynamic>> pointsMap = [];

                                  incidentSignaturePoints =
                                      incidentSignature
                                          .exportPoints();

                                  if (incidentSignaturePoints.length > 0) {
                                    incidentSignaturePoints.forEach((
                                        Point p) {
                                      if (p.type == PointType.move) {
                                        pointsMap.add({
                                          'pointType': 'move',
                                          'dx': p.offset.dx,
                                          'dy': p.offset.dy
                                        });
                                      } else if (p.type == PointType.tap) {
                                        pointsMap.add({
                                          'pointType': 'tap',
                                          'dx': p.offset.dx,
                                          'dy': p.offset.dy
                                        });
                                      }
                                    });

                                    var encodedPoints = jsonEncode(pointsMap);

                                    String encryptedPoints = GlobalFunctions
                                        .encryptString(encodedPoints);

                                    //Sembast
                                    incidentReportModel.updateTemporaryRecord(widget.edit, Strings.incidentSignaturePoints, encryptedPoints, widget.jobId);

                                    //Sqlflite
                                    // _databaseHelper
                                    //     .updateTemporaryIncidentReportField(widget.edit,
                                    //     {
                                    //       Strings.incidentSignaturePoints:
                                    //       encryptedPoints
                                    //     },
                                    //     user.uid,
                                    //     widget.jobId);

                                    Uint8List signatureBytes = await incidentSignature
                                        .exportBytes();

                                    setState(() {
                                      incidentImageBytes =
                                          signatureBytes;
                                    });

                                    Uint8List encryptedSignature = await GlobalFunctions
                                        .encryptSignature(incidentImageBytes);

                                    //Sembast
                                    incidentReportModel.updateTemporaryRecord(widget.edit, Strings.incidentSignature, encryptedSignature, widget.jobId);

                                    //Sqlflite
                                    // _databaseHelper
                                    //     .updateTemporaryIncidentReportField(widget.edit, {
                                    //   Strings.incidentSignature: encryptedSignature
                                    // }, user.uid,
                                    //     widget.jobId);

                                    Navigator.of(context).pop();
                                  } else {
                                    Navigator.of(context).pop();
                                  }
                                },
                                child: Text(
                                  'OK',
                                  style: TextStyle(color: bluePurple),
                                ))
                          ],
                        );
                      });
                }
              },
              child: incidentImageBytes == null
                  ? Icon(
                Icons.border_color,
                color: bluePurple,
                size: 40.0,
              )
                  : Image.memory(incidentImageBytes),
            ),
          ),
        )
      ],
    );
  }

  Widget _textFormField(String label, TextEditingController controller, [int lines = 1, bool required = false, TextInputType textInputType = TextInputType.text]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
              text: label,
              style: TextStyle(
                  fontSize: 16.0, fontFamily: 'Open Sans', color: bluePurple),
              children:
              [
                TextSpan(
                  text: required ? ' *' : '',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 16.0),
                ),                                           ]
          ),
        ),
        TextFormField(
          keyboardType: textInputType,
          validator: (String value) {
            String message;
            if(required){
              if (value.trim().length <= 0 && value.isEmpty) {
                message = "Required";
              }
            }
            return message;
          },
          maxLines: lines,
          decoration: InputDecoration(
              suffixIcon: controller.text == ''
                  ? null
                  : IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      SchedulerBinding.instance.addPostFrameCallback((_) {
                        FocusScope.of(context).unfocus();
                        controller.clear();
                      });
                    });
                  })),
          controller: controller,
        ),
        SizedBox(height: 15,),
      ],
    );
  }

  Widget _buildDateField(String label, TextEditingController controller, String value, [bool required = false, bool encrypt = false]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: label,
              style: TextStyle(
                  fontSize: 16.0, fontFamily: 'Open Sans', color: bluePurple),
              children:
              [
                TextSpan(
                  text: required ? ' *' : '',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16.0, fontFamily: 'Open Sans',),
                ),                                           ]
          ),
        ),
        Row(
          children: <Widget>[
            Flexible(
              child: IgnorePointer(
                child: TextFormField(
                  enabled: true,
                  initialValue: null,
                  controller: controller,
                  onSaved: (String value) {
                    setState(() {
                      controller.text = value;
                    });
                  },

                ),
              ),
            ),
            IconButton(
                color: Colors.grey,
                icon: Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    controller.clear();
                    //Sembast
                    incidentReportModel.updateTemporaryRecord(widget.edit, value, null, widget.jobId);

                    //Sqlflite
                    // _databaseHelper.updateTemporaryIncidentReportField(widget.edit,
                    //     {value : null}, user.uid, widget.jobId);

                  });
                }),
            IconButton(
                icon: Icon(Icons.access_time,
                    color: bluePurple),
                onPressed: () async{
                  FocusScope.of(context).unfocus();
                  await Future.delayed(Duration(milliseconds: 100));
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
                        controller.text = dateTime;
                        if(encrypt){
                          //Sembast
                          incidentReportModel.updateTemporaryRecord(widget.edit, value, GlobalFunctions.encryptString(DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String()), widget.jobId);

                          //Sqlflite
                          // _databaseHelper.updateTemporaryIncidentReportField(widget.edit,
                          //     {value : GlobalFunctions.encryptString(DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String())}, user.uid, widget.jobId);
                        } else {

                          //Sembast
                          incidentReportModel.updateTemporaryRecord(widget.edit, value, DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String(), widget.jobId);

                          //Sqlflite
                          // _databaseHelper.updateTemporaryIncidentReportField(widget.edit,
                          //     {value : DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String()}, user.uid, widget.jobId);
                        }



                      });
                    }
                  });
                })
          ],
        ),
        SizedBox(height: 15,),
      ],
    );
  }
  Widget _buildTimeField(String label, TextEditingController controller, String value, [bool required = false, bool encrypt = false]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: label,
              style: TextStyle(
                  fontSize: 16.0, fontFamily: 'Open Sans', color: bluePurple),
              children:
              [
                TextSpan(
                  text: required ? ' *' : '',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 16.0, fontFamily: 'Open Sans'),
                ),                                           ]
          ),
        ),
        Row(
          children: <Widget>[
            Flexible(
              child: IgnorePointer(
                child: TextFormField(
                  enabled: true,
                  initialValue: null,
                  controller: controller,
                  onSaved: (String value) {
                    setState(() {
                      controller.text = value;
                    });
                  },

                ),
              ),
            ),
            IconButton(
                color: Colors.grey,
                icon: Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    controller.clear();
                    //Sembast
                    incidentReportModel.updateTemporaryRecord(widget.edit, value, null, widget.jobId);

                    //Sqlflite
                    // _databaseHelper.updateTemporaryIncidentReportField(widget.edit,
                    //     {value : null}, user.uid, widget.jobId);
                  });
                }),
            IconButton(
                icon: Icon(Icons.access_time,
                    color: bluePurple),
                onPressed: () async{
                  FocusScope.of(context).unfocus();
                  await Future.delayed(Duration(milliseconds: 100));
                  showTimePicker(
                      initialTime: TimeOfDay.now(),
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
                      context: context)
                      .then((TimeOfDay time) {
                    if (time != null) {
                      DateTime today = new DateTime.now();
                      DateTime newDate = new DateTime(today.year, today.month, today.day);
                      newDate = newDate.add(Duration(hours: time.hour, minutes: time.minute));
                      String dateTime = timeFormat.format(newDate);
                      setState(() {
                        controller.text = dateTime;
                        if(encrypt){
                          //Sembast
                          incidentReportModel.updateTemporaryRecord(widget.edit, value, GlobalFunctions.encryptString(DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String()), widget.jobId);

                          //Sqlflite
                          // _databaseHelper.updateTemporaryIncidentReportField(widget.edit,
                          //     {value : GlobalFunctions.encryptString(DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String())}, user.uid, widget.jobId);
                        } else {
                          //Sembast
                          incidentReportModel.updateTemporaryRecord(widget.edit, value, DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String(), widget.jobId);

                          //Sqlflite
                          // _databaseHelper.updateTemporaryIncidentReportField(widget.edit,
                          //     {value : DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String()}, user.uid, widget.jobId);
                        }
                      });
                    }
                  });
                })
          ],
        ),
        SizedBox(height: 15,)
      ],
    );
  }


  void _resetForm() {
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
              child: Center(child: Text("Reset Incident Report", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),),
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
                onPressed: () {
                  context.read<IncidentReportModel>().resetTemporaryRecord(widget.jobId);

                  //Sqlflite
                  //context.read<IncidentReportModel>().resetTemporaryIncidentReport(widget.jobId);
                  FocusScope.of(context).requestFocus(new FocusNode());
                  setState(() {
                    jobRef.clear();
                    incidentDate.clear();
                    incidentTime.clear();
                    incidentDetails.clear();
                    incidentLocation.clear();
                    incidentAction.clear();
                    incidentStaffInvolved.clear();
                    incidentSignature = null;
                    incidentImageBytes = null;
                    incidentSignaturePoints = [];
                    incidentSignatureDate.clear();
                    incidentPrintName.clear();
                  });
                  Navigator.of(context).pop();
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

  void _submitForm() async {

    FocusScope.of(context).unfocus();
    if (incidentImageBytes == null || incidentDate.text.isEmpty || incidentTime.text.isEmpty || incidentDetails.text.isEmpty || incidentSignatureDate.text.isEmpty || incidentPrintName.text.isEmpty) {
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
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
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



    } else {

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
                child: Center(child: Text("Submit Incident Report", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),),
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

        bool success;

        if(widget.edit){
          success = await context.read<IncidentReportModel>().editIncidentReport(widget.jobId);
          FocusScope.of(context).requestFocus(new FocusNode());

        } else {
          success = await context.read<IncidentReportModel>().submitIncidentReport(widget.jobId);
          FocusScope.of(context).requestFocus(new FocusNode());
        }

        if(success){
          setState(() {
            jobRef.clear();
            incidentDate.clear();
            incidentTime.clear();
            incidentDetails.clear();
            incidentLocation.clear();
            incidentAction.clear();
            incidentStaffInvolved.clear();
            incidentSignature = null;
            incidentImageBytes = null;
            incidentSignaturePoints = [];
            incidentSignatureDate.clear();
            incidentPrintName.clear();
            FocusScope.of(context).requestFocus(new FocusNode());

          });
        }


      }
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
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('INCIDENT REPORT FORM', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 18),),
                  ],),
                  SizedBox(height: 20,),
                  _textFormField('Job Ref', jobRef, 1, true),
                  _buildDateField('Date', incidentDate, Strings.incidentDate, true, false),
                  _buildTimeField('Time', incidentTime, Strings.incidentTime, true),
                  _textFormField('Incident Details', incidentDetails, 4, true, TextInputType.multiline),
                  _textFormField('Location', incidentLocation, 2, false, TextInputType.multiline),
                  _textFormField('What action did you take?', incidentAction, 4, false, TextInputType.multiline),
                  _textFormField('Staff involved', incidentStaffInvolved, 4, false, TextInputType.multiline),
                  _buildIncidentSignatureRow(),
                  SizedBox(height: 20,),
                  _buildDateField('Date', incidentSignatureDate, Strings.incidentSignatureDate, true, false),
                  _textFormField('Print Name', incidentPrintName, 1, true),
                  SizedBox(height: 20,),
                  SizedBox(height: 20,),

                ]),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      drawer: widget.edit ? null : SideDrawer(),
      appBar: AppBar(
        flexibleSpace: AppBarGradient(),
        title: FittedBox(fit:BoxFit.fitWidth,
            child: Text('Incident Report', style: TextStyle(fontWeight: FontWeight.bold),)),
        actions: <Widget>[
          widget.edit ? Container() : IconButton(icon: Icon(Icons.refresh), onPressed: _resetForm),
          IconButton(icon: Icon(Icons.send), onPressed: _submitForm)
        ],
      ),
      body: _loadingTemporary
          ? Center(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(bluePurple),
        ),
      )
          : _buildPageContent(context),
    );
  }
}

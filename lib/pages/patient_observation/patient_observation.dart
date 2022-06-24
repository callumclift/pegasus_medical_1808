import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:pegasus_medical_1808/models/job_refs_model.dart';
import 'package:pegasus_medical_1808/models/patient_observation_model.dart';
import 'package:pegasus_medical_1808/shared/global_config.dart';
import 'package:pegasus_medical_1808/shared/global_functions.dart';
import 'package:pegasus_medical_1808/shared/strings.dart';
import 'package:pegasus_medical_1808/widgets/app_bar_gradient.dart';
import 'package:pegasus_medical_1808/widgets/dropdown_form_field.dart';
import 'package:pegasus_medical_1808/widgets/side_drawer.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:signature/signature.dart';


class PatientObservation extends StatefulWidget {
  final bool fromJob;
  final String jobId;
  final bool fillDetails;
  final bool edit;
  final bool saved;
  final int savedId;

  PatientObservation(
      [
        this.fromJob = false,
        this.jobId = '1',
        this.fillDetails = false,
        this.edit = false,
        this.saved = false,
        this.savedId = 0
      ]
      );

  @override
  _PatientObservationState createState() => _PatientObservationState();
}

class _PatientObservationState extends State<PatientObservation> {

  bool _loadingTemporary = false;
  PatientObservationModel patientObservationModel;
  JobRefsModel jobRefsModel;

  final dateFormat = DateFormat("dd/MM/yyyy");
  final timeFormat = DateFormat("HH:mm");
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController jobRef = TextEditingController();
  final TextEditingController patientObservationDate = TextEditingController();
  final TextEditingController patientObservationHospital = TextEditingController();
  final TextEditingController patientObservationWard = TextEditingController();
  final TextEditingController patientObservationStartTime = TextEditingController();
  final TextEditingController patientObservationFinishTime = TextEditingController();
  final TextEditingController patientObservationTotalHours = TextEditingController();
  final TextEditingController patientObservationName = TextEditingController();
  final TextEditingController patientObservationPosition = TextEditingController();
  final TextEditingController patientObservationAuthorisedDate = TextEditingController();


  List<Point> patientObservationSignaturePoints = [];
  Signature patientObservationSignature;
  Uint8List patientObservationImageBytes;

  String jobRefRef = 'Select One';

  List<String> jobRefDrop = [
    'Select One',
  ];


  @override
  void initState() {
    // TODO: implement initState
    _loadingTemporary = true;
    patientObservationModel = Provider.of<PatientObservationModel>(context, listen: false);
    jobRefsModel = context.read<JobRefsModel>();
    _setUpTextControllerListeners();
    _getTemporaryPatientObservation();
    super.initState();
  }

  @override
  void dispose() {
    jobRef.dispose();
    patientObservationDate.dispose();
    patientObservationHospital.dispose();
    patientObservationWard.dispose();
    patientObservationStartTime.dispose();
    patientObservationFinishTime.dispose();
    patientObservationTotalHours.dispose();
    patientObservationName.dispose();
    patientObservationPosition.dispose();
    patientObservationAuthorisedDate.dispose();
    super.dispose();
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
      patientObservationModel.updateTemporaryRecord(widget.edit, value, encrypt ? GlobalFunctions.encryptString(controllerText) : GlobalFunctions.databaseValueString(controllerText), widget.jobId, widget.saved, widget.savedId);
    });
  }

  _setUpTextControllerListeners() {

    _addListener(jobRef, Strings.jobRefNo, false, true);
    _addListener(patientObservationHospital, Strings.patientObservationHospital);
    _addListener(patientObservationWard, Strings.patientObservationWard);
    _addListener(patientObservationName, Strings.patientObservationName, true, false, true);
    _addListener(patientObservationPosition, Strings.patientObservationPosition);

  }

  _getTemporaryPatientObservation() async {

    //Sembast
    if (mounted) {

      await jobRefsModel.getJobRefs();

      if(jobRefsModel.allJobRefs.isNotEmpty){
        for(Map<String, dynamic> jobRefMap in jobRefsModel.allJobRefs){
          jobRefDrop.add(jobRefMap['job_ref']);
        }
      }

      await patientObservationModel.setupTemporaryRecord();

      bool hasRecord = await patientObservationModel.checkRecordExists(widget.edit, widget.jobId, widget.saved, widget.savedId);

      if(hasRecord){
        Map<String, dynamic> patientObservation = await patientObservationModel.getTemporaryRecord(widget.edit, widget.jobId, widget.saved, widget.savedId);

        if (patientObservation[Strings.patientObservationSignature] != null) {
          if (mounted) {

            Uint8List decryptedSignature = await GlobalFunctions.decryptSignature(patientObservation[Strings.patientObservationSignature]);
            setState(() {
              patientObservationImageBytes = decryptedSignature;
            });
          }
        } else {
          patientObservationSignature = null;
          patientObservationImageBytes = null;
        }
        if (patientObservation[Strings.patientObservationSignaturePoints] != null) {
          if (mounted) {
            String decryptedPoints = GlobalFunctions.decryptString(patientObservation[Strings.patientObservationSignaturePoints]);
            setState(() {
              List<dynamic> fetchedSignaturePoints = jsonDecode(decryptedPoints);
              fetchedSignaturePoints.forEach((dynamic pointMap) {
                if (pointMap['pointType'] == 'tap') {
                  patientObservationSignaturePoints.add(Point(
                      Offset(pointMap['dx'], pointMap['dy']),
                      PointType.tap));
                } else if (pointMap['pointType'] == 'move') {
                  patientObservationSignaturePoints.add(Point(
                      Offset(pointMap['dx'], pointMap['dy']),
                      PointType.move));
                }
              });
            });
          }
        } else {
          patientObservationSignaturePoints = [];

        }

        if (patientObservation[Strings.jobRefNo] != null) {
          jobRef.text = GlobalFunctions.databaseValueString(
              patientObservation[Strings.jobRefNo]);
        } else {
          jobRef.text = '';
        }

        if (patientObservation[Strings.jobRefRef] != null) {

          if(jobRefDrop.contains(GlobalFunctions.databaseValueString(patientObservation[Strings.jobRefRef]))){
            jobRefRef = GlobalFunctions.databaseValueString(patientObservation[Strings.jobRefRef]);
          } else {
            jobRefRef = 'Select One';
          }

        }
        if (patientObservation[Strings.patientObservationDate] != null) {
          patientObservationDate.text =
              dateFormat.format(DateTime.parse(patientObservation[Strings.patientObservationDate]));
        } else {
          patientObservationDate.text = '';
        }

        GlobalFunctions.getTemporaryValue(patientObservation, patientObservationHospital, Strings.patientObservationHospital);
        GlobalFunctions.getTemporaryValue(patientObservation, patientObservationWard, Strings.patientObservationWard);
        GlobalFunctions.getTemporaryValueTime(patientObservation, patientObservationStartTime, Strings.patientObservationStartTime);
        GlobalFunctions.getTemporaryValueTime(patientObservation, patientObservationFinishTime, Strings.patientObservationFinishTime);
        GlobalFunctions.getTemporaryValue(patientObservation, patientObservationTotalHours, Strings.patientObservationTotalHours, false);
        GlobalFunctions.getTemporaryValue(patientObservation, patientObservationName, Strings.patientObservationName);
        GlobalFunctions.getTemporaryValue(patientObservation, patientObservationPosition, Strings.patientObservationPosition);
        GlobalFunctions.getTemporaryValueDate(patientObservation, patientObservationAuthorisedDate, Strings.patientObservationAuthorisedDate);


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
  }

  Widget _buildJobRefDrop() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
              text: 'Reference',
              style: TextStyle(
                  fontSize: 16.0, fontFamily: 'Open Sans', color: bluePurple),
              children:
              [
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 16.0),
                ),                                           ]
          ),
        ),
        Container(
          color: jobRefRef == 'Select One' ? Color(0xFF0000).withOpacity(0.3) : null,
          child: DropdownFormField(
            expanded: false,
            value: jobRefRef,
            items: jobRefDrop.toList(),
            onChanged: (val) => setState(() {
              jobRefRef = val;
              if(val == 'Select One'){
                patientObservationModel.updateTemporaryRecord(widget.edit, Strings.jobRefRef, null, widget.jobId, widget.saved, widget.savedId);
              } else {
                patientObservationModel.updateTemporaryRecord(widget.edit, Strings.jobRefRef, val, widget.jobId, widget.saved, widget.savedId);
              }

              FocusScope.of(context).unfocus();
            }),
            initialValue: jobRefRef,
          ),
        ),
        SizedBox(height: 15,),
      ],
    );
  }

  Widget _buildPatientObservationSignatureRow() {
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
          color: patientObservationImageBytes == null ? Color(0xFF0000).withOpacity(0.3) : null,
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
                        patientObservationSignature = Signature(
                          points: patientObservationSignaturePoints,
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
                                child: patientObservationSignature,
                              )
                            ],
                          ),
                          actions: <Widget>[
                            TextButton(
                                onPressed: () {
                                  patientObservationSignature
                                      .clear();

                                  //Sembast

                                  patientObservationModel.updateTemporaryRecord(widget.edit, Strings.patientObservationSignaturePoints, null, widget.jobId, widget.saved, widget.savedId);
                                  patientObservationModel.updateTemporaryRecord(widget.edit, Strings.patientObservationSignature, null, widget.jobId, widget.saved, widget.savedId);

                                  setState(() {
                                    patientObservationSignaturePoints = [];
                                    patientObservationImageBytes =
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

                                  patientObservationSignaturePoints =
                                      patientObservationSignature
                                          .exportPoints();

                                  if (patientObservationSignaturePoints.length > 0) {
                                    patientObservationSignaturePoints.forEach((
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
                                    patientObservationModel.updateTemporaryRecord(widget.edit, Strings.patientObservationSignaturePoints, encryptedPoints, widget.jobId, widget.saved, widget.savedId);

                                    Uint8List signatureBytes = await patientObservationSignature
                                        .exportBytes();

                                    setState(() {
                                      patientObservationImageBytes =
                                          signatureBytes;
                                    });

                                    Uint8List encryptedSignature = await GlobalFunctions
                                        .encryptSignature(patientObservationImageBytes);

                                    //Sembast
                                    patientObservationModel.updateTemporaryRecord(widget.edit, Strings.patientObservationSignature, encryptedSignature, widget.jobId, widget.saved, widget.savedId);

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
              child: patientObservationImageBytes == null
                  ? Icon(
                Icons.border_color,
                color: bluePurple,
                size: 40.0,
              )
                  : Image.memory(patientObservationImageBytes),
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
          inputFormatters: textInputType == TextInputType.number ? <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
          ] : null,
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
              filled: required && controller.text.isEmpty ? true : false, fillColor: Color(0xFF0000).withOpacity(0.3),

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
                  decoration: InputDecoration(              filled: required && controller.text.isEmpty ? true : false, fillColor: Color(0xFF0000).withOpacity(0.3),
                  ),
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
                    patientObservationModel.updateTemporaryRecord(widget.edit, value, null, widget.jobId, widget.saved, widget.savedId);

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
                          patientObservationModel.updateTemporaryRecord(widget.edit, value, GlobalFunctions.encryptString(DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String()), widget.jobId, widget.saved, widget.savedId);
                        } else {

                          //Sembast
                          patientObservationModel.updateTemporaryRecord(widget.edit, value, DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String(), widget.jobId, widget.saved, widget.savedId);
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
                    patientObservationModel.updateTemporaryRecord(widget.edit, value, null, widget.jobId, widget.saved, widget.savedId);
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
                          patientObservationModel.updateTemporaryRecord(widget.edit, value, GlobalFunctions.encryptString(DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String()), widget.jobId, widget.saved, widget.savedId);
                        } else {
                          //Sembast
                          patientObservationModel.updateTemporaryRecord(widget.edit, value, DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String(), widget.jobId, widget.saved, widget.savedId);
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

  Widget _buildStartDateTimeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: 'Start Time',
              style: TextStyle(
                  fontSize: 16.0, fontFamily: 'Open Sans', color: bluePurple),
              children:
              [
                TextSpan(
                  text: ' *',
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
                  decoration: InputDecoration(              filled: patientObservationStartTime.text.isEmpty ? true : false, fillColor: Color(0xFF0000).withOpacity(0.3),
                  ),
                  enabled: true,
                  initialValue: null,
                  controller: patientObservationStartTime,
                  onSaved: (String value) {
                    setState(() {
                      patientObservationStartTime.text = value;
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
                    patientObservationStartTime.clear();
                    patientObservationTotalHours.clear();
                    patientObservationModel.updateTemporaryRecord(widget.edit, Strings.patientObservationStartTime, null, widget.jobId, widget.saved, widget.savedId);
                    patientObservationModel.updateTemporaryRecord(widget.edit, Strings.patientObservationTotalHours, null, widget.jobId, widget.saved, widget.savedId);
                  });
                }),
            IconButton(
                icon: Icon(Icons.access_time,
                    color: bluePurple),
                onPressed: () async{
                  FocusScope.of(context).unfocus();
                  await Future.delayed(Duration(milliseconds: 100));
                  DateTime newDate = await showDatePicker(
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
                  if (newDate != null) {
                    TimeOfDay time = await showTimePicker(
                        context: context, initialTime: TimeOfDay.now());
                    if (time != null) {
                      newDate = DateTime(newDate.year, newDate.month, newDate.day);
                      newDate = newDate.add(
                          Duration(hours: time.hour, minutes: time.minute));
                      String dateTime = timeFormat.format(newDate);
                      setState(() {
                        patientObservationStartTime.text = dateTime;
                      });

                      await patientObservationModel.updateTemporaryRecord(widget.edit, Strings.patientObservationStartTime, DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String(), widget.jobId, widget.saved, widget.savedId);


                      Map<String, dynamic> patientObservation = await patientObservationModel.getTemporaryRecord(widget.edit, widget.jobId, widget.saved, widget.savedId);

                      if(patientObservation[Strings.patientObservationFinishTime] != null){

                        DateTime finishDateTime = DateTime.parse(patientObservation[Strings.patientObservationFinishTime]);

                        int minutes = finishDateTime
                            .difference(newDate)
                            .inMinutes;
                        String patientObservationTotalHoursString;

                        if (minutes < 180) {
                          patientObservationTotalHoursString = '3';
                        } else {
                          patientObservationTotalHoursString = (minutes / 60).toStringAsFixed(1).replaceAll(RegExp(r"([.]*0)(?!.*\d)"), "");
                        }

                        setState(() {
                          patientObservationTotalHours.text = patientObservationTotalHoursString;
                        });
                        await patientObservationModel.updateTemporaryRecord(widget.edit, Strings.patientObservationTotalHours, patientObservationTotalHoursString, widget.jobId, widget.saved, widget.savedId);
                      }
                    }
                  }

                })
          ],
        ),
      ],
    );
  }



  Widget _buildFinishDateTimeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: 'Finish Time',
              style: TextStyle(
                  fontSize: 16.0, fontFamily: 'Open Sans', color: bluePurple),
              children:
              [
                TextSpan(
                  text: ' *',
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
                  decoration: InputDecoration(              filled: patientObservationFinishTime.text.isEmpty ? true : false, fillColor: Color(0xFF0000).withOpacity(0.3),
                  ),
                  enabled: true,
                  initialValue: null,
                  controller: patientObservationFinishTime,
                  onSaved: (String value) {
                    setState(() {
                      patientObservationFinishTime.text = value;
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
                    patientObservationFinishTime.clear();
                    patientObservationTotalHours.clear();
                    patientObservationModel.updateTemporaryRecord(widget.edit, Strings.patientObservationFinishTime, null, widget.jobId, widget.saved, widget.savedId);
                    patientObservationModel.updateTemporaryRecord(widget.edit, Strings.patientObservationTotalHours, null, widget.jobId, widget.saved, widget.savedId);
                  });
                }),
            IconButton(
                icon: Icon(Icons.access_time,
                    color: bluePurple),
                onPressed: () async{
                  FocusScope.of(context).unfocus();
                  await Future.delayed(Duration(milliseconds: 100));
                  DateTime newDate = await showDatePicker(
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
                  if (newDate != null) {
                    TimeOfDay time = await showTimePicker(
                        context: context, initialTime: TimeOfDay.now());
                    if (time != null) {
                      newDate = DateTime(newDate.year, newDate.month, newDate.day);
                      newDate = newDate.add(
                          Duration(hours: time.hour, minutes: time.minute));
                      String dateTime = timeFormat.format(newDate);
                      setState(() {
                        patientObservationFinishTime.text = dateTime;
                      });

                      await patientObservationModel.updateTemporaryRecord(widget.edit, Strings.patientObservationFinishTime, DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String(), widget.jobId, widget.saved, widget.savedId);


                      Map<String, dynamic> patientObservation = await patientObservationModel.getTemporaryRecord(widget.edit, widget.jobId, widget.saved, widget.savedId);

                      if(patientObservation[Strings.patientObservationStartTime] != null){

                        DateTime startDateTime = DateTime.parse(patientObservation[Strings.patientObservationStartTime]);

                        int minutes = newDate
                            .difference(startDateTime)
                            .inMinutes;
                        String patientObservationTotalHoursString;

                        if (minutes < 180) {
                          patientObservationTotalHoursString = '3';
                        } else {
                          patientObservationTotalHoursString = (minutes / 60).toStringAsFixed(1).replaceAll(RegExp(r"([.]*0)(?!.*\d)"), "");
                        }

                        setState(() {
                          patientObservationTotalHours.text = patientObservationTotalHoursString;
                        });

                        await patientObservationModel.updateTemporaryRecord(widget.edit, Strings.patientObservationTotalHours, patientObservationTotalHoursString, widget.jobId, widget.saved, widget.savedId);
                      }
                    }
                  }

                })
          ],
        ),
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
              child: Center(child: Text("Reset Patient Observation Timesheet", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),),),
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
                  context.read<PatientObservationModel>().resetTemporaryRecord(widget.jobId, widget.saved, widget.savedId);

                  //Sqlflite
                  FocusScope.of(context).requestFocus(new FocusNode());
                  setState(() {
                    jobRef.clear();
                    jobRefRef = 'Select One';
                    patientObservationDate.clear();
                    patientObservationHospital.clear();
                    patientObservationWard.clear();
                    patientObservationStartTime.clear();
                    patientObservationFinishTime.clear();
                    patientObservationTotalHours.clear();
                    patientObservationName.clear();
                    patientObservationPosition.clear();
                    patientObservationAuthorisedDate.clear();
                    patientObservationSignature = null;
                    patientObservationImageBytes = null;
                    patientObservationSignaturePoints = [];
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
      bool success = await context.read<PatientObservationModel>().saveForLater(
          widget.jobId, widget.saved, widget.savedId);
      FocusScope.of(context).requestFocus(new FocusNode());


      if (success) {
        setState(() {
          jobRef.clear();
          jobRefRef = 'Select One';
          patientObservationDate.clear();
          patientObservationHospital.clear();
          patientObservationWard.clear();
          patientObservationStartTime.clear();
          patientObservationFinishTime.clear();
          patientObservationTotalHours.clear();
          patientObservationName.clear();
          patientObservationPosition.clear();
          patientObservationAuthorisedDate.clear();
          patientObservationSignature = null;
          patientObservationImageBytes = null;
          patientObservationSignaturePoints = [];
          FocusScope.of(context).requestFocus(new FocusNode());

        });
      }
    }
  }

  void _submitForm() async {

    FocusScope.of(context).unfocus();
    if (patientObservationImageBytes == null || jobRef.text.isEmpty || jobRefRef == 'Select One' || patientObservationDate.text.isEmpty || patientObservationHospital.text.isEmpty || patientObservationWard.text.isEmpty || patientObservationStartTime.text.isEmpty || patientObservationFinishTime.text.isEmpty || patientObservationName.text.isEmpty || patientObservationPosition.text.isEmpty || patientObservationAuthorisedDate.text.isEmpty) {
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
                child: Center(child: Text("Submit Patient Observation Timesheet", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),),),
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
          success = await context.read<PatientObservationModel>().editPatientObservation(widget.jobId);
          FocusScope.of(context).requestFocus(new FocusNode());

        } else {
          success = await context.read<PatientObservationModel>().submitPatientObservation(widget.jobId, widget.edit, widget.saved, widget.savedId);
          FocusScope.of(context).requestFocus(new FocusNode());
        }

        if(success){
          setState(() {
            jobRef.clear();
            jobRefRef = 'Select One';
            patientObservationDate.clear();
            patientObservationHospital.clear();
            patientObservationWard.clear();
            patientObservationStartTime.clear();
            patientObservationFinishTime.clear();
            patientObservationTotalHours.clear();
            patientObservationName.clear();
            patientObservationPosition.clear();
            patientObservationAuthorisedDate.clear();
            patientObservationSignature = null;
            patientObservationImageBytes = null;
            patientObservationSignaturePoints = [];
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
                    Text('PATIENT OBSERVATION TIMESHEET', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 18),),
                  ],),
                  SizedBox(height: 20,),
                  Row(
                    children: [
                      Flexible(child: _buildJobRefDrop()),
                      Container(width: 10,),
                      Flexible(child: _textFormField('', jobRef, 1, true, TextInputType.number),),
                    ],
                  ),
                  _buildDateField('Date', patientObservationDate, Strings.patientObservationDate, true, false),
                  _textFormField('Hospital', patientObservationHospital, 1, true),
                  _textFormField('Ward', patientObservationWard, 1, true),
                  _buildStartDateTimeField(),
                  SizedBox(height: 10,),
                  _buildFinishDateTimeField(),
                  SizedBox(height: 10,),
                  _textFormField('Total Hours', patientObservationTotalHours, 1, true),
                  SizedBox(height: 10,),
                  Text('Authorised By', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold),),
                  SizedBox(height: 10,),
                  _textFormField('Name', patientObservationName, 1, true),
                  _textFormField('Position', patientObservationPosition, 1, true),
                  _buildPatientObservationSignatureRow(),
                  SizedBox(height: 20,),
                  _buildDateField('Date', patientObservationAuthorisedDate, Strings.patientObservationAuthorisedDate, true, false),
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
      drawer: widget.edit || widget.saved ? null : SideDrawer(),
      appBar: AppBar(
        flexibleSpace: AppBarGradient(),
        title: FittedBox(fit:BoxFit.fitWidth,
            child: Text('Patient Observation Timesheet', style: TextStyle(fontWeight: FontWeight.bold),)),
        actions: <Widget>[
          widget.edit || widget.saved ? Container() : IconButton(icon: Icon(Icons.refresh), onPressed: _resetForm),
          widget.saved || widget.edit ? Container() : IconButton(icon: Icon(Icons.watch_later_outlined), onPressed: _saveForLater),
          IconButton(icon: Icon(Icons.send), onPressed: _submitForm),
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

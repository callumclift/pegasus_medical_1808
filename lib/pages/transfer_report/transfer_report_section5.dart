import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pegasus_medical_1808/models/transfer_report_model.dart';
import 'package:pegasus_medical_1808/shared/global_config.dart';
import 'package:pegasus_medical_1808/shared/global_functions.dart';
import 'package:pegasus_medical_1808/shared/strings.dart';
import 'package:pegasus_medical_1808/utils/database_helper.dart';
import 'package:pegasus_medical_1808/widgets/dropdown_form_field.dart';
import 'package:provider/provider.dart';

class TransferReportSection5 extends StatefulWidget {
  final bool fromJob;
  final String jobId;
  final bool fillDetails;
  final bool edit;
  final bool saved;
  final int savedId;

  TransferReportSection5(
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
  _TransferReportSection5State createState() => _TransferReportSection5State();
}

class _TransferReportSection5State extends State<TransferReportSection5> {

  bool _loadingTemporary = false;
  //DatabaseHelper _databaseHelper = DatabaseHelper();
  TransferReportModel transferReportModel;
  bool ambulanceTidyYes1 = false;
  bool ambulanceTidyNo1 = false;
  bool lightsWorkingYes = false;
  bool lightsWorkingNo = false;
  bool tyresInflatedYes = false;
  bool tyresInflatedNo = false;
  bool warningSignsYes = false;
  bool warningSignsNo = false;
  bool ambulanceTidyYes2 = false;
  bool ambulanceTidyNo2 = false;
  bool sanitiserCleanYes = false;
  bool sanitiserCleanNo = false;
  final TextEditingController vehicleCompletedBy1 = TextEditingController();
  final TextEditingController ambulanceReg = TextEditingController();
  final TextEditingController vehicleStartMileage = TextEditingController();
  final TextEditingController vehicleCompletedBy2 = TextEditingController();
  final TextEditingController finishMileage = TextEditingController();
  final TextEditingController totalMileage = TextEditingController();
  final TextEditingController issuesFaults = TextEditingController();
  final TextEditingController vehicleDate = TextEditingController();
  final TextEditingController vehicleTime = TextEditingController();
  final dateFormat = DateFormat("dd/MM/yyyy");
  final timeFormat = DateFormat("HH:mm");


  String nearestTank1 = 'Select One';
  String nearestTank2 = 'Select One';
  List<String> nearestTankDrop = [
    'Select One',
    '1/4',
    '1/2',
    '3/4 ',
    'Full'];

  bool showPopup = false;
  bool mandatoryIssuesFaults;


  @override
  void initState() {
    // TODO: implement initState
    _loadingTemporary = true;
    transferReportModel = Provider.of<TransferReportModel>(context, listen: false);
    _setUpTextControllerListeners();
    _getTemporaryTransferReport();
    super.initState();
  }

  @override
  void dispose() {
    vehicleCompletedBy1.dispose();
    ambulanceReg.dispose();
    vehicleStartMileage.dispose();
    vehicleCompletedBy2.dispose();
    finishMileage.dispose();
    totalMileage.dispose();
    issuesFaults.dispose();
    vehicleDate.dispose();
    vehicleTime.dispose();
    super.dispose();
  }

  void showIssuesDialog(){
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
              child: Center(child: Text("Explain Issue / Fault", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                      text: 'Please explain in issues / faults box at the bottom of this page',
                      style: TextStyle(color: Colors.black, fontSize: 16, fontFamily: 'Open Sans'),
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

      transferReportModel.updateTemporaryRecord(widget.edit, value, encrypt ? GlobalFunctions.encryptString(controllerText) : GlobalFunctions.databaseValueString(controllerText), widget.jobId, widget.saved, widget.savedId);


      // _databaseHelper.updateTemporaryTransferReportField(widget.edit, {
      //   value:
      //   encrypt ? GlobalFunctions.encryptString(controllerText) : GlobalFunctions.databaseValueString(controllerText)
      // }, user.uid, widget.jobId, widget.saved, widget.savedId);
    });
  }

  _setUpTextControllerListeners() {
    _addListener(vehicleCompletedBy1, Strings.vehicleCompletedBy1, true, false, true);
    _addListener(ambulanceReg, Strings.ambulanceReg, true, true);
    _addListener(vehicleStartMileage, Strings.vehicleStartMileage);
    _addListener(vehicleCompletedBy2, Strings.vehicleCompletedBy2, true, false, true);
    //_addListener(finishMileage, Strings.finishMileage);


    finishMileage.addListener(() async{

      //Map<String, dynamic> transferReport = await _databaseHelper.getTemporaryTransferReport(widget.edit, user.uid, widget.jobId, widget.saved, widget.savedId);
      Map<String, dynamic> transferReport = await transferReportModel.getTemporaryRecord(widget.edit, widget.jobId, widget.saved, widget.savedId);

      if(transferReport[Strings.startMileage] != null){
        double startMileageDouble = double.tryParse(GlobalFunctions.decryptString(transferReport[Strings.startMileage]));
        double finishMileageDouble = double.tryParse(finishMileage.text);

        if(startMileageDouble != null && finishMileageDouble != null){
          double totalMileageDouble = finishMileageDouble - startMileageDouble;
          num totalNumber = totalMileageDouble % 1 == 0 ? totalMileageDouble.toInt() : totalMileageDouble;

          if(totalMileageDouble != null){
            totalMileage.text = totalNumber.toString();
            transferReportModel.updateTemporaryRecord(widget.edit, Strings.totalMileage, GlobalFunctions.encryptString(totalMileage.text), widget.jobId, widget.saved, widget.savedId);

            // _databaseHelper.updateTemporaryTransferReportField(widget.edit, {
            //   Strings.totalMileage:
            //   GlobalFunctions.encryptString(totalMileage.text)
            // }, user.uid, widget.jobId, widget.saved, widget.savedId);
          }

        } else {
          totalMileage.text = '';
          transferReportModel.updateTemporaryRecord(widget.edit, Strings.totalMileage, GlobalFunctions.encryptString(''), widget.jobId, widget.saved, widget.savedId);

          // _databaseHelper.updateTemporaryTransferReportField(widget.edit, {
          //   Strings.totalMileage:
          //   GlobalFunctions.encryptString('')
          // }, user.uid, widget.jobId, widget.saved, widget.savedId);
        }
      }

      setState(() {
      });
      transferReportModel.updateTemporaryRecord(widget.edit, Strings.finishMileage, GlobalFunctions.encryptString(finishMileage.text), widget.jobId, widget.saved, widget.savedId);

      // _databaseHelper.updateTemporaryTransferReportField(widget.edit, {
      //   Strings.finishMileage:
      //   GlobalFunctions.encryptString(finishMileage.text)
      // }, user.uid, widget.jobId, widget.saved, widget.savedId);
    });



    _addListener(totalMileage, Strings.totalMileage);
    _addListener(issuesFaults, Strings.issuesFaults);
  }

  _getTemporaryTransferReport() async {

    if (mounted) {
      await transferReportModel.setupTemporaryRecord();

      bool hasRecord = await transferReportModel.checkRecordExists(widget.edit, widget.jobId, widget.saved, widget.savedId);

      if(hasRecord){
        Map<String, dynamic> transferReport = await transferReportModel.getTemporaryRecord(widget.edit, widget.jobId, widget.saved, widget.savedId);

        if(transferReport[Strings.vehicleCompletedBy1] == null){
          vehicleCompletedBy1.text = user.name;
          transferReportModel.updateTemporaryRecord(widget.edit, Strings.vehicleCompletedBy1, GlobalFunctions.encryptString(vehicleCompletedBy1.text), widget.jobId, widget.saved, widget.savedId);

          // _databaseHelper.updateTemporaryTransferReportField(widget.edit, {
          //   Strings.vehicleCompletedBy1: GlobalFunctions.encryptString(vehicleCompletedBy1.text)
          // }, user.uid, widget.jobId, widget.saved, widget.savedId);
        } else {
          GlobalFunctions.getTemporaryValue(transferReport, vehicleCompletedBy1, Strings.vehicleCompletedBy1);
        }
        GlobalFunctions.getTemporaryValue(transferReport, ambulanceReg, Strings.ambulanceReg);
        GlobalFunctions.getTemporaryValue(transferReport, vehicleStartMileage, Strings.vehicleStartMileage);
        if (transferReport[Strings.nearestTank1] != null) {
          nearestTank1 = GlobalFunctions.decryptString(transferReport[Strings.nearestTank1]);
        }
        if(transferReport[Strings.vehicleCompletedBy2] == null){
          vehicleCompletedBy2.text = user.name;
          transferReportModel.updateTemporaryRecord(widget.edit, Strings.vehicleCompletedBy2, GlobalFunctions.encryptString(vehicleCompletedBy2.text), widget.jobId, widget.saved, widget.savedId);

          // _databaseHelper.updateTemporaryTransferReportField(widget.edit, {
          //   Strings.vehicleCompletedBy2: GlobalFunctions.encryptString(vehicleCompletedBy2.text)
          // }, user.uid, widget.jobId, widget.saved, widget.savedId);
        } else {
          GlobalFunctions.getTemporaryValue(transferReport, vehicleCompletedBy2, Strings.vehicleCompletedBy2);
        }
        if (transferReport[Strings.nearestTank2] != null) {
          nearestTank2 = GlobalFunctions.decryptString(transferReport[Strings.nearestTank2]);
        }
        GlobalFunctions.getTemporaryValue(transferReport, finishMileage, Strings.finishMileage);
        GlobalFunctions.getTemporaryValue(transferReport, totalMileage, Strings.totalMileage);
        GlobalFunctions.getTemporaryValue(transferReport, issuesFaults, Strings.issuesFaults);
        GlobalFunctions.getTemporaryValueDate(transferReport, vehicleDate, Strings.vehicleDate);
        GlobalFunctions.getTemporaryValueTime(transferReport, vehicleTime, Strings.vehicleTime);

        if (transferReport[Strings.ambulanceTidyYes1] != null) {
          if (mounted) {
            setState(() {
              ambulanceTidyYes1 = GlobalFunctions.tinyIntToBool(transferReport[Strings.ambulanceTidyYes1]);
            });
          }
        }
        if (transferReport[Strings.ambulanceTidyNo1] != null) {
          if (mounted) {
            setState(() {
              ambulanceTidyNo1 = GlobalFunctions.tinyIntToBool(transferReport[Strings.ambulanceTidyNo1]);
              if(ambulanceTidyNo1) mandatoryIssuesFaults = true;
            });
          }
        }
        if (transferReport[Strings.lightsWorkingYes] != null) {
          if (mounted) {
            setState(() {
              lightsWorkingYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.lightsWorkingYes]);
            });
          }
        }
        if (transferReport[Strings.lightsWorkingNo] != null) {
          if (mounted) {
            setState(() {
              lightsWorkingNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.lightsWorkingNo]);
              if(lightsWorkingNo) mandatoryIssuesFaults = true;

            });
          }
        }
        if (transferReport[Strings.tyresInflatedYes] != null) {
          if (mounted) {
            setState(() {
              tyresInflatedYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.tyresInflatedYes]);
            });
          }
        }
        if (transferReport[Strings.tyresInflatedNo] != null) {
          if (mounted) {
            setState(() {
              tyresInflatedNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.tyresInflatedNo]);
              if(tyresInflatedNo) mandatoryIssuesFaults = true;
            });
          }
        }
        if (transferReport[Strings.warningSignsYes] != null) {
          if (mounted) {
            setState(() {
              warningSignsYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.warningSignsYes]);
              if(warningSignsYes) mandatoryIssuesFaults = true;

            });
          }
        }
        if (transferReport[Strings.warningSignsNo] != null) {
          if (mounted) {
            setState(() {
              warningSignsNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.warningSignsNo]);
            });
          }
        }
        if (transferReport[Strings.ambulanceTidyYes2] != null) {
          if (mounted) {
            setState(() {
              ambulanceTidyYes2 = GlobalFunctions.tinyIntToBool(transferReport[Strings.ambulanceTidyYes2]);
            });
          }
        }
        if (transferReport[Strings.ambulanceTidyNo2] != null) {
          if (mounted) {
            setState(() {
              ambulanceTidyNo2 = GlobalFunctions.tinyIntToBool(transferReport[Strings.ambulanceTidyNo2]);
              if(ambulanceTidyNo2) mandatoryIssuesFaults = true;

            });
          }
        }
        if (transferReport[Strings.sanitiserCleanYes] != null) {
          if (mounted) {
            setState(() {
              sanitiserCleanYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.sanitiserCleanYes]);
            });
          }
        }
        if (transferReport[Strings.sanitiserCleanNo] != null) {
          if (mounted) {
            setState(() {
              sanitiserCleanNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.sanitiserCleanNo]);
              if(sanitiserCleanNo) mandatoryIssuesFaults = true;

            });
          }
        }

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

    // if (mounted) {
    //   int result = await _databaseHelper.checkTemporaryTransferReportExists(widget.edit,
    //       user.uid, widget.jobId, widget.saved, widget.savedId);
    //   if (result != 0) {
    //     Map<String, dynamic> transferReport = await _databaseHelper.getTemporaryTransferReport(widget.edit, user.uid, widget.jobId, widget.saved, widget.savedId);
    //     if(transferReport[Strings.vehicleCompletedBy1] == null){
    //       vehicleCompletedBy1.text = user.name;
    //       _databaseHelper.updateTemporaryTransferReportField(widget.edit, {
    //         Strings.vehicleCompletedBy1: GlobalFunctions.encryptString(vehicleCompletedBy1.text)
    //       }, user.uid, widget.jobId, widget.saved, widget.savedId);
    //     } else {
    //       GlobalFunctions.getTemporaryValue(transferReport, vehicleCompletedBy1, Strings.vehicleCompletedBy1);
    //     }
    //     GlobalFunctions.getTemporaryValue(transferReport, ambulanceReg, Strings.ambulanceReg);
    //     GlobalFunctions.getTemporaryValue(transferReport, vehicleStartMileage, Strings.vehicleStartMileage);
    //     if (transferReport[Strings.nearestTank1] != null) {
    //       nearestTank1 = GlobalFunctions.decryptString(transferReport[Strings.nearestTank1]);
    //     }
    //     if(transferReport[Strings.vehicleCompletedBy2] == null){
    //       vehicleCompletedBy2.text = user.name;
    //       _databaseHelper.updateTemporaryTransferReportField(widget.edit, {
    //         Strings.vehicleCompletedBy2: GlobalFunctions.encryptString(vehicleCompletedBy2.text)
    //       }, user.uid, widget.jobId, widget.saved, widget.savedId);
    //     } else {
    //       GlobalFunctions.getTemporaryValue(transferReport, vehicleCompletedBy2, Strings.vehicleCompletedBy2);
    //     }
    //     if (transferReport[Strings.nearestTank2] != null) {
    //       nearestTank2 = GlobalFunctions.decryptString(transferReport[Strings.nearestTank2]);
    //     }
    //     GlobalFunctions.getTemporaryValue(transferReport, finishMileage, Strings.finishMileage);
    //     GlobalFunctions.getTemporaryValue(transferReport, totalMileage, Strings.totalMileage);
    //     GlobalFunctions.getTemporaryValue(transferReport, issuesFaults, Strings.issuesFaults);
    //     GlobalFunctions.getTemporaryValueDate(transferReport, vehicleDate, Strings.vehicleDate);
    //     GlobalFunctions.getTemporaryValueTime(transferReport, vehicleTime, Strings.vehicleTime);
    //
    //     if (transferReport[Strings.ambulanceTidyYes1] != null) {
    //       if (mounted) {
    //         setState(() {
    //           ambulanceTidyYes1 = GlobalFunctions.tinyIntToBool(transferReport[Strings.ambulanceTidyYes1]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.ambulanceTidyNo1] != null) {
    //       if (mounted) {
    //         setState(() {
    //           ambulanceTidyNo1 = GlobalFunctions.tinyIntToBool(transferReport[Strings.ambulanceTidyNo1]);
    //           if(ambulanceTidyNo1) mandatoryIssuesFaults = true;
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.lightsWorkingYes] != null) {
    //       if (mounted) {
    //         setState(() {
    //           lightsWorkingYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.lightsWorkingYes]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.lightsWorkingNo] != null) {
    //       if (mounted) {
    //         setState(() {
    //           lightsWorkingNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.lightsWorkingNo]);
    //           if(lightsWorkingNo) mandatoryIssuesFaults = true;
    //
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.tyresInflatedYes] != null) {
    //       if (mounted) {
    //         setState(() {
    //           tyresInflatedYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.tyresInflatedYes]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.tyresInflatedNo] != null) {
    //       if (mounted) {
    //         setState(() {
    //           tyresInflatedNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.tyresInflatedNo]);
    //           if(tyresInflatedNo) mandatoryIssuesFaults = true;
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.warningSignsYes] != null) {
    //       if (mounted) {
    //         setState(() {
    //           warningSignsYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.warningSignsYes]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.warningSignsNo] != null) {
    //       if (mounted) {
    //         setState(() {
    //           warningSignsNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.warningSignsNo]);
    //           if(warningSignsNo) mandatoryIssuesFaults = true;
    //
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.ambulanceTidyYes2] != null) {
    //       if (mounted) {
    //         setState(() {
    //           ambulanceTidyYes2 = GlobalFunctions.tinyIntToBool(transferReport[Strings.ambulanceTidyYes2]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.ambulanceTidyNo2] != null) {
    //       if (mounted) {
    //         setState(() {
    //           ambulanceTidyNo2 = GlobalFunctions.tinyIntToBool(transferReport[Strings.ambulanceTidyNo2]);
    //           if(ambulanceTidyNo2) mandatoryIssuesFaults = true;
    //
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.sanitiserCleanYes] != null) {
    //       if (mounted) {
    //         setState(() {
    //           sanitiserCleanYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.sanitiserCleanYes]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.sanitiserCleanNo] != null) {
    //       if (mounted) {
    //         setState(() {
    //           sanitiserCleanNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.sanitiserCleanNo]);
    //           if(sanitiserCleanNo) mandatoryIssuesFaults = true;
    //
    //         });
    //       }
    //     }
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

  Widget _buildNearestTank1Drop() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
              text: 'Fuel to the nearest 1/4 tank',
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
        DropdownFormField(
          expanded: true,
          value: nearestTank1,
          items: nearestTankDrop.toList(),
          onChanged: (val) => setState(() {
            nearestTank1 = val;
            if(val == 'Select One'){
              transferReportModel.updateTemporaryRecord(widget.edit, Strings.nearestTank1, null, widget.jobId, widget.saved, widget.savedId);
            } else {
              transferReportModel.updateTemporaryRecord(widget.edit, Strings.nearestTank1, GlobalFunctions.encryptString(val), widget.jobId, widget.saved, widget.savedId);
            }

            FocusScope.of(context).unfocus();
          }),
          initialValue: nearestTank1,
        ),
        SizedBox(height: 15,),
      ],
    );
  }

  Widget _buildNearestTank2Drop() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
              text: 'Fuel to the nearest 1/4 tank',
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
        DropdownFormField(
          expanded: true,
          value: nearestTank2,
          items: nearestTankDrop.toList(),
          onChanged: (val) => setState(() {
            nearestTank2 = val;
            if(val == 'Select One'){
              transferReportModel.updateTemporaryRecord(widget.edit, Strings.nearestTank2, null, widget.jobId, widget.saved, widget.savedId);
            } else {
              transferReportModel.updateTemporaryRecord(widget.edit, Strings.nearestTank2, GlobalFunctions.encryptString(val), widget.jobId, widget.saved, widget.savedId);
            }

            FocusScope.of(context).unfocus();
          }),
          initialValue: nearestTank2,
        ),
        SizedBox(height: 15,),
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
                    transferReportModel.updateTemporaryRecord(widget.edit, value, null, widget.jobId, widget.saved, widget.savedId);
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
                          transferReportModel.updateTemporaryRecord(widget.edit, value, GlobalFunctions.encryptString(DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String()), widget.jobId, widget.saved, widget.savedId);
                        } else {
                          transferReportModel.updateTemporaryRecord(widget.edit, value, DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String(), widget.jobId, widget.saved, widget.savedId);
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
                    transferReportModel.updateTemporaryRecord(widget.edit, value, null, widget.jobId, widget.saved, widget.savedId);
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
                          transferReportModel.updateTemporaryRecord(widget.edit, value, GlobalFunctions.encryptString(DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String()), widget.jobId, widget.saved, widget.savedId);
                        } else {
                          transferReportModel.updateTemporaryRecord(widget.edit, value, DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String(), widget.jobId, widget.saved, widget.savedId);
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

  Widget _buildCheckboxRowAmbulanceTidyYes1(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: text,
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
        ),        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: ambulanceTidyYes1,
                onChanged: (bool value) => setState(() {
                  ambulanceTidyYes1 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.ambulanceTidyYes1, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (ambulanceTidyNo1 == true){
                    ambulanceTidyNo1 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.ambulanceTidyNo1, null, widget.jobId, widget.saved, widget.savedId);
                  }

                  if(
                  (ambulanceTidyNo1 == null || ambulanceTidyNo1 == false) &&
                      (lightsWorkingNo == null || lightsWorkingNo == false) &&
                      (tyresInflatedNo == null || tyresInflatedNo == false) &&
                      (warningSignsYes == null || warningSignsYes == false) &&
                      (ambulanceTidyNo2 == null || ambulanceTidyNo2 == false) &&
                      (sanitiserCleanNo == null || sanitiserCleanNo == false)
                  ) {
                    mandatoryIssuesFaults = false;
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: ambulanceTidyNo1,
                onChanged: (bool value) => setState(() {
                  ambulanceTidyNo1 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.ambulanceTidyNo1, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (ambulanceTidyYes1 == true){
                    ambulanceTidyYes1 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.ambulanceTidyYes1, null, widget.jobId, widget.saved, widget.savedId);
                  }

                  if(ambulanceTidyNo1 == true){
                    mandatoryIssuesFaults = true;
                    if(issuesFaults.text.isEmpty) showIssuesDialog();
                  } else if(
                  (ambulanceTidyNo1 == null || ambulanceTidyNo1 == false) &&
                      (lightsWorkingNo == null || lightsWorkingNo == false) &&
                      (tyresInflatedNo == null || tyresInflatedNo == false) &&
                      (warningSignsYes == null || warningSignsYes == false) &&
                      (ambulanceTidyNo2 == null || ambulanceTidyNo2 == false) &&
                      (sanitiserCleanNo == null || sanitiserCleanNo == false)
                  ) {
                    mandatoryIssuesFaults = false;
                  }


                }))
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowLightsWorkingYes(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: text,
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
        ),        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: lightsWorkingYes,
                onChanged: (bool value) => setState(() {
                  lightsWorkingYes = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.lightsWorkingYes, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (lightsWorkingNo == true){
                    lightsWorkingNo = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.lightsWorkingNo, null, widget.jobId, widget.saved, widget.savedId);
                  }

                  if(
                  (ambulanceTidyNo1 == null || ambulanceTidyNo1 == false) &&
                      (lightsWorkingNo == null || lightsWorkingNo == false) &&
                      (tyresInflatedNo == null || tyresInflatedNo == false) &&
                      (warningSignsYes == null || warningSignsYes == false) &&
                      (ambulanceTidyNo2 == null || ambulanceTidyNo2 == false) &&
                      (sanitiserCleanNo == null || sanitiserCleanNo == false)
                  ) {
                    mandatoryIssuesFaults = false;
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: lightsWorkingNo,
                onChanged: (bool value) => setState(() {
                  lightsWorkingNo = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.lightsWorkingNo, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (lightsWorkingYes == true){
                    lightsWorkingYes = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.lightsWorkingYes, null, widget.jobId, widget.saved, widget.savedId);
                  }

                  if(lightsWorkingNo == true){
                    mandatoryIssuesFaults = true;
                    if(issuesFaults.text.isEmpty) showIssuesDialog();

                  } else if(
                  (ambulanceTidyNo1 == null || ambulanceTidyNo1 == false) &&
                      (lightsWorkingNo == null || lightsWorkingNo == false) &&
                      (tyresInflatedNo == null || tyresInflatedNo == false) &&
                      (warningSignsYes == null || warningSignsYes == false) &&
                      (ambulanceTidyNo2 == null || ambulanceTidyNo2 == false) &&
                      (sanitiserCleanNo == null || sanitiserCleanNo == false)
                  ) {
                    mandatoryIssuesFaults = false;
                  }
                }))
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowTyresInflatedYes(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: text,
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
        ),        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: tyresInflatedYes,
                onChanged: (bool value) => setState(() {
                  tyresInflatedYes = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.tyresInflatedYes, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (tyresInflatedNo == true){
                    tyresInflatedNo = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.tyresInflatedNo, null, widget.jobId, widget.saved, widget.savedId);
                  }

                  if(
                  (ambulanceTidyNo1 == null || ambulanceTidyNo1 == false) &&
                      (lightsWorkingNo == null || lightsWorkingNo == false) &&
                      (tyresInflatedNo == null || tyresInflatedNo == false) &&
                      (warningSignsYes == null || warningSignsYes == false) &&
                      (ambulanceTidyNo2 == null || ambulanceTidyNo2 == false) &&
                      (sanitiserCleanNo == null || sanitiserCleanNo == false)
                  ) {
                    mandatoryIssuesFaults = false;
                  }


                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: tyresInflatedNo,
                onChanged: (bool value) => setState(() {
                  tyresInflatedNo = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.tyresInflatedNo, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (tyresInflatedYes == true){
                    tyresInflatedYes = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.tyresInflatedYes, null, widget.jobId, widget.saved, widget.savedId);
                  }

                  if(tyresInflatedNo == true){
                    mandatoryIssuesFaults = true;
                    if(issuesFaults.text.isEmpty) showIssuesDialog();

                  } else if(
                  (ambulanceTidyNo1 == null || ambulanceTidyNo1 == false) &&
                      (lightsWorkingNo == null || lightsWorkingNo == false) &&
                      (tyresInflatedNo == null || tyresInflatedNo == false) &&
                      (warningSignsYes == null || warningSignsYes == false) &&
                      (ambulanceTidyNo2 == null || ambulanceTidyNo2 == false) &&
                      (sanitiserCleanNo == null || sanitiserCleanNo == false)
                  ) {
                    mandatoryIssuesFaults = false;
                  }
                }))
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowWarningSignsYes(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: text,
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
        ),        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: warningSignsYes,
                onChanged: (bool value) => setState(() {
                  warningSignsYes = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.warningSignsYes, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (warningSignsNo == true){
                    warningSignsNo = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.warningSignsNo, null, widget.jobId, widget.saved, widget.savedId);
                  }

                  if(warningSignsYes == true){
                    mandatoryIssuesFaults = true;
                    if(issuesFaults.text.isEmpty) showIssuesDialog();

                  } else if(
                  (ambulanceTidyNo1 == null || ambulanceTidyNo1 == false) &&
                      (lightsWorkingNo == null || lightsWorkingNo == false) &&
                      (tyresInflatedNo == null || tyresInflatedNo == false) &&
                      (warningSignsYes == null || warningSignsYes == false) &&
                      (ambulanceTidyNo2 == null || ambulanceTidyNo2 == false) &&
                      (sanitiserCleanNo == null || sanitiserCleanNo == false)
                  ) {
                    mandatoryIssuesFaults = false;
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: warningSignsNo,
                onChanged: (bool value) => setState(() {
                  warningSignsNo = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.warningSignsNo, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (warningSignsYes == true){
                    warningSignsYes = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.warningSignsYes, null, widget.jobId, widget.saved, widget.savedId);
                  }

                  if(
                  (ambulanceTidyNo1 == null || ambulanceTidyNo1 == false) &&
                      (lightsWorkingNo == null || lightsWorkingNo == false) &&
                      (tyresInflatedNo == null || tyresInflatedNo == false) &&
                      (warningSignsYes == null || warningSignsYes == false) &&
                      (ambulanceTidyNo2 == null || ambulanceTidyNo2 == false) &&
                      (sanitiserCleanNo == null || sanitiserCleanNo == false)
                  ) {
                    mandatoryIssuesFaults = false;
                  }
                }))
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowAmbulanceTidyYes2(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: text,
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
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: ambulanceTidyYes2,
                onChanged: (bool value) => setState(() {
                  ambulanceTidyYes2 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.ambulanceTidyYes2, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (ambulanceTidyNo2 == true){
                    ambulanceTidyNo2 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.ambulanceTidyNo2, null, widget.jobId, widget.saved, widget.savedId);
                  }

                  if(
                  (ambulanceTidyNo1 == null || ambulanceTidyNo1 == false) &&
                      (lightsWorkingNo == null || lightsWorkingNo == false) &&
                      (tyresInflatedNo == null || tyresInflatedNo == false) &&
                      (warningSignsYes == null || warningSignsYes == false) &&
                      (ambulanceTidyNo2 == null || ambulanceTidyNo2 == false) &&
                      (sanitiserCleanNo == null || sanitiserCleanNo == false)
                  ) {
                    mandatoryIssuesFaults = false;
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: ambulanceTidyNo2,
                onChanged: (bool value) => setState(() {
                  ambulanceTidyNo2 = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.ambulanceTidyNo2, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (ambulanceTidyYes2 == true){
                    ambulanceTidyYes2 = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.ambulanceTidyYes2, null, widget.jobId, widget.saved, widget.savedId);
                  }

                  if(ambulanceTidyNo2 == true){
                    mandatoryIssuesFaults = true;
                    if(issuesFaults.text.isEmpty) showIssuesDialog();

                  } else if(
                  (ambulanceTidyNo1 == null || ambulanceTidyNo1 == false) &&
                      (lightsWorkingNo == null || lightsWorkingNo == false) &&
                      (tyresInflatedNo == null || tyresInflatedNo == false) &&
                      (warningSignsYes == null || warningSignsYes == false) &&
                      (ambulanceTidyNo2 == null || ambulanceTidyNo2 == false) &&
                      (sanitiserCleanNo == null || sanitiserCleanNo == false)
                  ) {
                    mandatoryIssuesFaults = false;
                  }
                }))
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowSanitiserCleanYes(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
              text: text,
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
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: sanitiserCleanYes,
                onChanged: (bool value) => setState(() {
                  sanitiserCleanYes = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.sanitiserCleanYes, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (sanitiserCleanNo == true){
                    sanitiserCleanNo = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.sanitiserCleanNo, null, widget.jobId, widget.saved, widget.savedId);
                  }

                  if(
                  (ambulanceTidyNo1 == null || ambulanceTidyNo1 == false) &&
                      (lightsWorkingNo == null || lightsWorkingNo == false) &&
                      (tyresInflatedNo == null || tyresInflatedNo == false) &&
                      (warningSignsYes == null || warningSignsYes == false) &&
                      (ambulanceTidyNo2 == null || ambulanceTidyNo2 == false) &&
                      (sanitiserCleanNo == null || sanitiserCleanNo == false)
                  ) {
                    mandatoryIssuesFaults = false;
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: sanitiserCleanNo,
                onChanged: (bool value) => setState(() {
                  sanitiserCleanNo = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.sanitiserCleanNo, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (sanitiserCleanYes == true){
                    sanitiserCleanYes = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.sanitiserCleanYes, null, widget.jobId, widget.saved, widget.savedId);
                  }

                  if(sanitiserCleanNo == true){
                    mandatoryIssuesFaults = true;
                    if(issuesFaults.text.isEmpty) showIssuesDialog();

                  } else if(
                  (ambulanceTidyNo1 == null || ambulanceTidyNo1 == false) &&
                      (lightsWorkingNo == null || lightsWorkingNo == false) &&
                      (tyresInflatedNo == null || tyresInflatedNo == false) &&
                      (warningSignsYes == null || warningSignsYes == false) &&
                      (ambulanceTidyNo2 == null || ambulanceTidyNo2 == false) &&
                      (sanitiserCleanNo == null || sanitiserCleanNo == false)
                  ) {
                    mandatoryIssuesFaults = false;
                  }
                }))
          ],
        )
      ],
    );
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
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: targetPadding / 2),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('TRANSFER REPORT', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 18),),
                ],),
                SizedBox(height: 10,),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('PRE-TRANSFER VEHICLE CHECKLIST', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 18),),
                ],),
                SizedBox(height: 20,),
                _textFormField('Completed by', vehicleCompletedBy1, 1, true),
                _textFormField('Ambulance Reg', ambulanceReg, 1, true),
                //_textFormField('Start Mileage', vehicleStartMileage, 1, true),
                _buildNearestTank1Drop(),
                _buildDateField('Date', vehicleDate, Strings.vehicleDate, true),
                _buildTimeField('Time', vehicleTime, Strings.vehicleTime, true),
                SizedBox(height: 10,),
                _buildCheckboxRowAmbulanceTidyYes1('• Was the ambulance left clean and tidy?'),
                _buildCheckboxRowLightsWorkingYes('• Ambulance lights working?'),
                _buildCheckboxRowTyresInflatedYes('• Tyres appear inflated fully?'),
                _buildCheckboxRowWarningSignsYes('• Vehicle warning signs showing?'),
                SizedBox(height: 20,),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('POST-TRANSFER VEHICLE CHECKLIST', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 18),),
                ],),
                SizedBox(height: 20,),
                _textFormField('Completed by', vehicleCompletedBy2, 1, true),
                _textFormField('Finish Mileage', finishMileage, 1, true, TextInputType.numberWithOptions(decimal: true)),
                _textFormField('Total Mileage', totalMileage, 1, true),
                _buildNearestTank2Drop(),
                SizedBox(height: 10,),
                _buildCheckboxRowAmbulanceTidyYes2('• Was the ambulance left clean and tidy?'),
                _buildCheckboxRowSanitiserCleanYes('• General clean & touch points'),
                SizedBox(height: 20,),
                mandatoryIssuesFaults == null || mandatoryIssuesFaults == false ? RichText(
                  text: TextSpan(
                    text: 'ANY ISSUES OR FAULTS PLEASE REPORT BELOW',
                    style: TextStyle(
                        fontSize: 16.0, fontFamily: 'Open Sans', color: bluePurple),
                  ),
                ) : RichText(
                  text: TextSpan(
                      text: 'ANY ISSUES OR FAULTS PLEASE REPORT BELOW',
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
                SizedBox(height: 10,),
                _textFormField('', issuesFaults, 5, false, TextInputType.multiline),
                SizedBox(height: 10,),
              ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
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

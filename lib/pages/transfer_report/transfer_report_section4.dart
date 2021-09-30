import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pegasus_medical_1808/models/transfer_report_model.dart';
import 'package:pegasus_medical_1808/shared/global_config.dart';
import 'package:pegasus_medical_1808/shared/global_functions.dart';
import 'package:pegasus_medical_1808/shared/strings.dart';
import 'package:pegasus_medical_1808/utils/database_helper.dart';
import 'package:provider/provider.dart';

class TransferReportSection4 extends StatefulWidget {
  final bool fromJob;
  final String jobId;
  final bool fillDetails;
  final bool edit;
  final bool saved;
  final int savedId;

  TransferReportSection4(
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
  _TransferReportSection4State createState() => _TransferReportSection4State();
}

class _TransferReportSection4State extends State<TransferReportSection4> {

  bool _loadingTemporary = false;
  //DatabaseHelper _databaseHelper = DatabaseHelper();
  TransferReportModel transferReportModel;
  bool feltSafeYes = false;
  bool feltSafeNo = false;
  bool staffIntroducedYes = false;
  bool staffIntroducedNo = false;
  bool experiencePositiveYes = false;
  bool experiencePositiveNo = false;
  final TextEditingController otherComments = TextEditingController();


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
    otherComments.dispose();
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

      transferReportModel.updateTemporaryRecord(widget.edit, value, encrypt ? GlobalFunctions.encryptString(controllerText) : GlobalFunctions.databaseValueString(controllerText), widget.jobId, widget.saved, widget.savedId);


      // _databaseHelper.updateTemporaryTransferReportField(widget.edit, {
      //   value:
      //   encrypt ? GlobalFunctions.encryptString(controllerText) : GlobalFunctions.databaseValueString(controllerText)
      // }, user.uid, widget.jobId, widget.saved, widget.savedId);
    });
  }

  _setUpTextControllerListeners() {
    _addListener(otherComments, Strings.otherComments);
  }



  _getSelectedTransferReport() async {
    if (mounted) {
      Map<String, dynamic> transferReport = transferReportModel.selectedTransferReport;
      GlobalFunctions.getSelectedValue(transferReport, otherComments, Strings.otherComments);

      if (transferReport[Strings.feltSafeYes] != null) {
        if (mounted) {
          setState(() {
            feltSafeYes = GlobalFunctions.databaseValueBool(transferReport[Strings.feltSafeYes]);
          });
        }
      }
      if (transferReport[Strings.feltSafeNo] != null) {
        if (mounted) {
          setState(() {
            feltSafeNo = GlobalFunctions.databaseValueBool(transferReport[Strings.feltSafeNo]);
          });
        }
      }
      if (transferReport[Strings.staffIntroducedYes] != null) {
        if (mounted) {
          setState(() {
            staffIntroducedYes = GlobalFunctions.databaseValueBool(transferReport[Strings.staffIntroducedYes]);
          });
        }
      }
      if (transferReport[Strings.staffIntroducedNo] != null) {
        if (mounted) {
          setState(() {
            staffIntroducedNo = GlobalFunctions.databaseValueBool(transferReport[Strings.staffIntroducedNo]);
          });
        }
      }
      if (transferReport[Strings.experiencePositiveYes] != null) {
        if (mounted) {
          setState(() {
            experiencePositiveYes = GlobalFunctions.databaseValueBool(transferReport[Strings.experiencePositiveYes]);
          });
        }
      }
      if (transferReport[Strings.experiencePositiveNo] != null) {
        if (mounted) {
          setState(() {
            experiencePositiveNo = GlobalFunctions.databaseValueBool(transferReport[Strings.experiencePositiveNo]);
          });
        }
      }

      if (mounted) {
        setState(() {
          _loadingTemporary = false;
        });
      }
    }
  }


  _getTemporaryTransferReport() async {

    if (mounted) {
      await transferReportModel.setupTemporaryRecord();

      bool hasRecord = await transferReportModel.checkRecordExists(widget.edit, widget.jobId, widget.saved, widget.savedId);

      if(hasRecord){
        Map<String, dynamic> transferReport = await transferReportModel.getTemporaryRecord(widget.edit, widget.jobId, widget.saved, widget.savedId);
        GlobalFunctions.getTemporaryValue(transferReport, otherComments, Strings.otherComments);
        if (transferReport[Strings.feltSafeYes] != null) {
          if (mounted) {
            setState(() {
              feltSafeYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.feltSafeYes]);
            });
          }
        }
        if (transferReport[Strings.feltSafeNo] != null) {
          if (mounted) {
            setState(() {
              feltSafeNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.feltSafeNo]);
            });
          }
        }
        if (transferReport[Strings.staffIntroducedYes] != null) {
          if (mounted) {
            setState(() {
              staffIntroducedYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.staffIntroducedYes]);
            });
          }
        }
        if (transferReport[Strings.staffIntroducedNo] != null) {
          if (mounted) {
            setState(() {
              staffIntroducedNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.staffIntroducedNo]);
            });
          }
        }
        if (transferReport[Strings.experiencePositiveYes] != null) {
          if (mounted) {
            setState(() {
              experiencePositiveYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.experiencePositiveYes]);
            });
          }
        }
        if (transferReport[Strings.experiencePositiveNo] != null) {
          if (mounted) {
            setState(() {
              experiencePositiveNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.experiencePositiveNo]);
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
    //
    //     Map<String, dynamic> transferReport = await _databaseHelper.getTemporaryTransferReport(widget.edit, user.uid, widget.jobId, widget.saved, widget.savedId);
    //     GlobalFunctions.getTemporaryValue(transferReport, otherComments, Strings.otherComments);
    //     if (transferReport[Strings.feltSafeYes] != null) {
    //       if (mounted) {
    //         setState(() {
    //           feltSafeYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.feltSafeYes]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.feltSafeNo] != null) {
    //       if (mounted) {
    //         setState(() {
    //           feltSafeNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.feltSafeNo]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.staffIntroducedYes] != null) {
    //       if (mounted) {
    //         setState(() {
    //           staffIntroducedYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.staffIntroducedYes]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.staffIntroducedNo] != null) {
    //       if (mounted) {
    //         setState(() {
    //           staffIntroducedNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.staffIntroducedNo]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.experiencePositiveYes] != null) {
    //       if (mounted) {
    //         setState(() {
    //           experiencePositiveYes = GlobalFunctions.tinyIntToBool(transferReport[Strings.experiencePositiveYes]);
    //         });
    //       }
    //     }
    //     if (transferReport[Strings.experiencePositiveNo] != null) {
    //       if (mounted) {
    //         setState(() {
    //           experiencePositiveNo = GlobalFunctions.tinyIntToBool(transferReport[Strings.experiencePositiveNo]);
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
  Widget _buildCheckboxRowFeltSafeYes(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
Text(text, style: TextStyle(color: bluePurple, fontSize: 16),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: feltSafeYes,
                onChanged: (bool value) => setState(() {
                  feltSafeYes = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.feltSafeYes, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (feltSafeNo == true){
                    feltSafeNo = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.feltSafeNo, null, widget.jobId, widget.saved, widget.savedId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: feltSafeNo,
                onChanged: (bool value) => setState(() {
                  feltSafeNo = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.feltSafeNo, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (feltSafeYes == true){
                    feltSafeYes = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.feltSafeYes, null, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowStaffIntroducedYes(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
Text(text, style: TextStyle(color: bluePurple, fontSize: 16),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: staffIntroducedYes,
                onChanged: (bool value) => setState(() {
                  staffIntroducedYes = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.staffIntroducedYes, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (staffIntroducedNo == true){
                    staffIntroducedNo = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.staffIntroducedNo, null, widget.jobId, widget.saved, widget.savedId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: staffIntroducedNo,
                onChanged: (bool value) => setState(() {
                  staffIntroducedNo = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.staffIntroducedNo, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (staffIntroducedYes == true){
                    staffIntroducedYes = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.staffIntroducedYes, null, widget.jobId, widget.saved, widget.savedId);
                  }
                }))
          ],
        )
      ],
    );
  }
  Widget _buildCheckboxRowExperiencePositiveYes(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
Text(text, style: TextStyle(color: bluePurple, fontSize: 16),),
        Row(
          children: <Widget>[
            Text(
              'Yes',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: experiencePositiveYes,
                onChanged: (bool value) => setState(() {
                  experiencePositiveYes = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.experiencePositiveYes, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (experiencePositiveNo == true){
                    experiencePositiveNo = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.experiencePositiveNo, null, widget.jobId, widget.saved, widget.savedId);
                  }
                })),
            Text(
              'No',
            ),
            Checkbox(
                activeColor: bluePurple,
                value: experiencePositiveNo,
                onChanged: (bool value) => setState(() {
                  experiencePositiveNo = value;
                  transferReportModel.updateTemporaryRecord(widget.edit, Strings.experiencePositiveNo, GlobalFunctions.boolToTinyInt(value), widget.jobId, widget.saved, widget.savedId);
                  if (experiencePositiveYes == true){
                    experiencePositiveYes = false;
                    transferReportModel.updateTemporaryRecord(widget.edit, Strings.experiencePositiveYes, null, widget.jobId, widget.saved, widget.savedId);
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
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('PATIENT FEEDBACK FORM', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 18),),
                ],),
                SizedBox(height: 20,),
                _buildCheckboxRowFeltSafeYes("• Whilst travelling with us today have you felt safe?"),
                _buildCheckboxRowStaffIntroducedYes("• Staff introduced themselves to me and they were friendly?"),
                _buildCheckboxRowExperiencePositiveYes("• My overall experience was positive?"),
                SizedBox(height: 20,),
                Text('PLEASE SHARE ANY OTHER COMMENTS', style: TextStyle(color: bluePurple),),
                SizedBox(height: 10,),
                _textFormField('', otherComments, 5, false, TextInputType.multiline,),
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

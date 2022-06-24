import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pegasus_medical_1808/models/bed_rota_model.dart';
import 'package:pegasus_medical_1808/models/share_option.dart';
import 'package:pegasus_medical_1808/services/navigation_service.dart';
import 'package:pegasus_medical_1808/shared/global_config.dart';
import 'package:pegasus_medical_1808/shared/global_functions.dart';
import 'package:pegasus_medical_1808/shared/strings.dart';
import 'package:pegasus_medical_1808/widgets/app_bar_gradient.dart';
import 'package:provider/provider.dart';

import '../../locator.dart';
import 'bed_rota.dart';
import '../../constants/route_paths.dart' as routes;



class CompletedBedRota extends StatefulWidget {

  @override
  _CompletedBedRotaState createState() => _CompletedBedRotaState();
}

class _CompletedBedRotaState extends State<CompletedBedRota> {

  BedRotaModel bedRotaModel;
  bool okPressed = false;

  @override
  void initState() {
    // TODO: implement initState
    bedRotaModel = Provider.of<BedRotaModel>(context, listen: false);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _deleteRecords(){

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
              child: Center(child: Text("Delete Record", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),),
            ),
            content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Text('Are you sure you wish to delete this record?', textAlign: TextAlign.left,),
              SizedBox(height: 10.0,),
            ],),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: () {

                  setState(() {
                    okPressed = true;
                  });

                  Navigator.pop(context);

                },
                child: Text(
                  'OK',
                  style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        }).then((_) async{

      if(okPressed){

        GlobalFunctions.showLoadingDialog('Deleting Record...');
        await FirebaseFirestore.instance.collection('bed_rotas').doc(bedRotaModel.selectedBedRota[Strings.documentId]).delete().timeout(Duration(seconds: 60));
        GlobalFunctions.dismissLoadingDialog();

        setState(() {
          okPressed = false;
        });
        bedRotaModel.clearBedRotas();
        final NavigationService _navigationService = locator<NavigationService>();
        _navigationService.navigateToReplacement(routes.BedRotaListPageRoute);
      }});
  }



  Widget _textFormField(String label, String value) {
    return InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: SelectableText(value, style: TextStyle(fontSize: 16),),
    );
  }

  Widget _buildDateField(String label, String value) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Flexible(
              child: IgnorePointer(
                child: InputDecorator(
                  decoration: InputDecoration(labelText: label),
                  child: Text(value, style: TextStyle(fontSize: 16),),
                ),
              ),
            ),
            IconButton(
                icon: Icon(Icons.access_time),
                onPressed: null)
          ],
        ),
      ],
    );
  }

  Widget _buildTimeField(String label, String value) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Flexible(
              child: IgnorePointer(
                child: InputDecorator(
                  decoration: InputDecoration(labelText: label),
                  child: Text(value, style: TextStyle(fontSize: 16),),
                ),
              ),
            ),
            IconButton(
                icon: Icon(Icons.access_time),
                onPressed: null)
          ],
        ),
      ],
    );
  }




  _generatePdf(BuildContext context) async {
    showDialog(barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return EmailDialog(bedRotaModel);
        });
  }

  Widget _buildShareButton(BuildContext context) {
    String email = 'Email Report';
    String print = 'Print';
    String share = 'Share';
    String edit = 'Edit';
    String delete = 'Delete';
    String download = 'Download';

    List<String> _shareOptions = [];

    if(user.role == 'Super User'){
      if(kIsWeb){
        _shareOptions = [edit, download, print, delete];
      } else {
        _shareOptions = [edit, email, print, share, delete];
      }
    } else if(user.role == 'Enhanced User') {
      if(kIsWeb){
        _shareOptions = [edit, download, print];
      } else {
        _shareOptions = [edit, email, print, share];
      }
    } else {
      if(kIsWeb){
        _shareOptions = [edit, download, print];
      } else {
        _shareOptions = [edit, print, share];
      }
    }

    return PopupMenuButton(
        onSelected: (String value) async{

          ConnectivityResult connectivityResult = await Connectivity().checkConnectivity();

          if (value == email) {
            _generatePdf(context);
          } else if (value == print) {

            if (connectivityResult == ConnectivityResult.none) {
              GlobalFunctions.showToast(
                  'No data connection unable to search for Printer');
            } else {

              await bedRotaModel.sharePdf(ShareOption.Print);

            }
          } if (value == share) {

            if (connectivityResult == ConnectivityResult.none) {
              GlobalFunctions.showToast(
                  'No data connection unable to share form');
            } else {

              await bedRotaModel.sharePdf(ShareOption.Share);

            }

          } if (value == download) {

            if (connectivityResult == ConnectivityResult.none) {
              GlobalFunctions.showToast(
                  'No data connection unable to download form');
            } else {

              await bedRotaModel.sharePdf(ShareOption.Download);

            }

          } else if(value == edit){
            await context.read<BedRotaModel>().setUpEditedRecord();
            Navigator.of(context).push(
                MaterialPageRoute(builder: (BuildContext context) {
                  return BedRota(false, '1', false, true);
                })).then((_) {
                  context.read<BedRotaModel>().deleteEditedRecord();
            });
          } else if(value == delete){
            _deleteRecords();
          }
        },
        icon: Icon(Icons.more_vert),
        itemBuilder: (BuildContext context) {
          return _shareOptions.map((String option) {

            return PopupMenuItem<String>(value: option, child: Row(children: <Widget>[

              Expanded(child: Text(option),),
              Icon(GlobalFunctions.buildShareIconForms(option), color: bluePurple,),
            ],));

          }).toList();
        });
  }




  Widget _buildPageContent(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 768.0 ? 600.0 : deviceWidth * 0.95;
    final double targetPadding = deviceWidth - targetWidth;

    return bedRotaModel.selectedBedRota == null ? Container() : GestureDetector(
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
                _textFormField('Reference', GlobalFunctions.databaseValueString(bedRotaModel.selectedBedRota[Strings.jobRef])),
                _buildDateField('Week Commencing', GlobalFunctions.databaseValueDate(bedRotaModel.selectedBedRota[Strings.weekCommencing], false)),
                Text('Monday', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 18),),
                SizedBox(height: 5,),
                Container(decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey)
                ),
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                        Text('AM', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),)
                      ],),
                      SizedBox(height: 10,),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey)
                        ),
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.mondayAmName1])),
                            _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.mondayAmFrom1])),
                            _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.mondayAmTo1])),
                          ],
                        ),
                      ),
                      bedRotaModel.selectedBedRota[Strings.mondayAmName2] != null && bedRotaModel.selectedBedRota[Strings.mondayAmName2] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.mondayAmName2])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.mondayAmFrom2])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.mondayAmTo2])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.mondayAmName3] != null && bedRotaModel.selectedBedRota[Strings.mondayAmName3] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.mondayAmName3])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.mondayAmFrom3])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.mondayAmTo3])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.mondayAmName4] != null && bedRotaModel.selectedBedRota[Strings.mondayAmName4] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.mondayAmName4])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.mondayAmFrom4])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.mondayAmTo4])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.mondayAmName5] != null && bedRotaModel.selectedBedRota[Strings.mondayAmName5] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.mondayAmName5])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.mondayAmFrom5])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.mondayAmTo5])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      SizedBox(height: 10,),


                      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                        Text('PM', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),)
                      ],),
                      SizedBox(height: 10,),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey)
                        ),
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.mondayPmName1])),
                            _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.mondayPmFrom1])),
                            _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.mondayPmTo1])),
                          ],
                        ),
                      ),
                      bedRotaModel.selectedBedRota[Strings.mondayPmName2] != null && bedRotaModel.selectedBedRota[Strings.mondayPmName2] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.mondayPmName2])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.mondayPmFrom2])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.mondayPmTo2])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.mondayPmName3] != null && bedRotaModel.selectedBedRota[Strings.mondayPmName3] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.mondayPmName3])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.mondayPmFrom3])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.mondayPmTo3])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.mondayPmName4] != null && bedRotaModel.selectedBedRota[Strings.mondayPmName4] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.mondayPmName4])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.mondayPmFrom4])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.mondayPmTo4])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.mondayPmName5] != null && bedRotaModel.selectedBedRota[Strings.mondayPmName5] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.mondayPmName5])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.mondayPmFrom5])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.mondayPmTo5])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      SizedBox(height: 10,),
                      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                        Text('Night', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),)
                      ],),
                      SizedBox(height: 10,),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey)
                        ),
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.mondayNightName1])),
                            _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.mondayNightFrom1])),
                            _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.mondayNightTo1])),
                          ],
                        ),
                      ),
                      bedRotaModel.selectedBedRota[Strings.mondayNightName2] != null && bedRotaModel.selectedBedRota[Strings.mondayNightName2] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.mondayNightName2])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.mondayNightFrom2])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.mondayNightTo2])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.mondayNightName3] != null && bedRotaModel.selectedBedRota[Strings.mondayNightName3] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.mondayNightName3])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.mondayNightFrom3])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.mondayNightTo3])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.mondayNightName4] != null && bedRotaModel.selectedBedRota[Strings.mondayNightName4] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.mondayNightName4])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.mondayNightFrom4])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.mondayNightTo4])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.mondayNightName5] != null && bedRotaModel.selectedBedRota[Strings.mondayNightName5] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.mondayNightName5])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.mondayNightFrom5])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.mondayNightTo5])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                    ],
                  ),
                ),
                SizedBox(height: 10,),

                Text('Tuesday', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 18),),
                SizedBox(height: 5,),
                Container(decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey)
                ),
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                        Text('AM', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),)
                      ],),
                      SizedBox(height: 10,),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey)
                        ),
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.tuesdayAmName1])),
                            _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.tuesdayAmFrom1])),
                            _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.tuesdayAmTo1])),
                          ],
                        ),
                      ),
                      bedRotaModel.selectedBedRota[Strings.tuesdayAmName2] != null && bedRotaModel.selectedBedRota[Strings.tuesdayAmName2] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.tuesdayAmName2])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.tuesdayAmFrom2])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.tuesdayAmTo2])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.tuesdayAmName3] != null && bedRotaModel.selectedBedRota[Strings.tuesdayAmName3] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.tuesdayAmName3])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.tuesdayAmFrom3])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.tuesdayAmTo3])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.tuesdayAmName4] != null && bedRotaModel.selectedBedRota[Strings.tuesdayAmName4] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.tuesdayAmName4])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.tuesdayAmFrom4])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.tuesdayAmTo4])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.tuesdayAmName5] != null && bedRotaModel.selectedBedRota[Strings.tuesdayAmName5] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.tuesdayAmName5])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.tuesdayAmFrom5])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.tuesdayAmTo5])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      SizedBox(height: 10,),


                      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                        Text('PM', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),)
                      ],),
                      SizedBox(height: 10,),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey)
                        ),
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.tuesdayPmName1])),
                            _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.tuesdayPmFrom1])),
                            _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.tuesdayPmTo1])),
                          ],
                        ),
                      ),
                      bedRotaModel.selectedBedRota[Strings.tuesdayPmName2] != null && bedRotaModel.selectedBedRota[Strings.tuesdayPmName2] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.tuesdayPmName2])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.tuesdayPmFrom2])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.tuesdayPmTo2])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.tuesdayPmName3] != null && bedRotaModel.selectedBedRota[Strings.tuesdayPmName3] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.tuesdayPmName3])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.tuesdayPmFrom3])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.tuesdayPmTo3])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.tuesdayPmName4] != null && bedRotaModel.selectedBedRota[Strings.tuesdayPmName4] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.tuesdayPmName4])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.tuesdayPmFrom4])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.tuesdayPmTo4])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.tuesdayPmName5] != null && bedRotaModel.selectedBedRota[Strings.tuesdayPmName5] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.tuesdayPmName5])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.tuesdayPmFrom5])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.tuesdayPmTo5])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      SizedBox(height: 10,),
                      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                        Text('Night', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),)
                      ],),
                      SizedBox(height: 10,),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey)
                        ),
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.tuesdayNightName1])),
                            _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.tuesdayNightFrom1])),
                            _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.tuesdayNightTo1])),
                          ],
                        ),
                      ),
                      bedRotaModel.selectedBedRota[Strings.tuesdayNightName2] != null && bedRotaModel.selectedBedRota[Strings.tuesdayNightName2] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.tuesdayNightName2])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.tuesdayNightFrom2])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.tuesdayNightTo2])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.tuesdayNightName3] != null && bedRotaModel.selectedBedRota[Strings.tuesdayNightName3] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.tuesdayNightName3])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.tuesdayNightFrom3])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.tuesdayNightTo3])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.tuesdayNightName4] != null && bedRotaModel.selectedBedRota[Strings.tuesdayNightName4] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.tuesdayNightName4])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.tuesdayNightFrom4])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.tuesdayNightTo4])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.tuesdayNightName5] != null && bedRotaModel.selectedBedRota[Strings.tuesdayNightName5] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.tuesdayNightName5])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.tuesdayNightFrom5])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.tuesdayNightTo5])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                    ],
                  ),
                ),
                SizedBox(height: 10,),

                Text('Wednesday', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 18),),
                SizedBox(height: 5,),
                Container(decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey)
                ),
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                        Text('AM', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),)
                      ],),
                      SizedBox(height: 10,),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey)
                        ),
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.wednesdayAmName1])),
                            _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.wednesdayAmFrom1])),
                            _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.wednesdayAmTo1])),
                          ],
                        ),
                      ),
                      bedRotaModel.selectedBedRota[Strings.wednesdayAmName2] != null && bedRotaModel.selectedBedRota[Strings.wednesdayAmName2] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.wednesdayAmName2])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.wednesdayAmFrom2])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.wednesdayAmTo2])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.wednesdayAmName3] != null && bedRotaModel.selectedBedRota[Strings.wednesdayAmName3] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.wednesdayAmName3])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.wednesdayAmFrom3])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.wednesdayAmTo3])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.wednesdayAmName4] != null && bedRotaModel.selectedBedRota[Strings.wednesdayAmName4] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.wednesdayAmName4])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.wednesdayAmFrom4])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.wednesdayAmTo4])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.wednesdayAmName5] != null && bedRotaModel.selectedBedRota[Strings.wednesdayAmName5] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.wednesdayAmName5])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.wednesdayAmFrom5])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.wednesdayAmTo5])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      SizedBox(height: 10,),


                      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                        Text('PM', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),)
                      ],),
                      SizedBox(height: 10,),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey)
                        ),
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.wednesdayPmName1])),
                            _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.wednesdayPmFrom1])),
                            _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.wednesdayPmTo1])),
                          ],
                        ),
                      ),
                      bedRotaModel.selectedBedRota[Strings.wednesdayPmName2] != null && bedRotaModel.selectedBedRota[Strings.wednesdayPmName2] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.wednesdayPmName2])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.wednesdayPmFrom2])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.wednesdayPmTo2])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.wednesdayPmName3] != null && bedRotaModel.selectedBedRota[Strings.wednesdayPmName3] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.wednesdayPmName3])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.wednesdayPmFrom3])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.wednesdayPmTo3])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.wednesdayPmName4] != null && bedRotaModel.selectedBedRota[Strings.wednesdayPmName4] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.wednesdayPmName4])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.wednesdayPmFrom4])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.wednesdayPmTo4])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.wednesdayPmName5] != null && bedRotaModel.selectedBedRota[Strings.wednesdayPmName5] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.wednesdayPmName5])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.wednesdayPmFrom5])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.wednesdayPmTo5])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      SizedBox(height: 10,),
                      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                        Text('Night', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),)
                      ],),
                      SizedBox(height: 10,),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey)
                        ),
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.wednesdayNightName1])),
                            _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.wednesdayNightFrom1])),
                            _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.wednesdayNightTo1])),
                          ],
                        ),
                      ),
                      bedRotaModel.selectedBedRota[Strings.wednesdayNightName2] != null && bedRotaModel.selectedBedRota[Strings.wednesdayNightName2] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.wednesdayNightName2])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.wednesdayNightFrom2])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.wednesdayNightTo2])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.wednesdayNightName3] != null && bedRotaModel.selectedBedRota[Strings.wednesdayNightName3] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.wednesdayNightName3])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.wednesdayNightFrom3])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.wednesdayNightTo3])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.wednesdayNightName4] != null && bedRotaModel.selectedBedRota[Strings.wednesdayNightName4] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.wednesdayNightName4])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.wednesdayNightFrom4])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.wednesdayNightTo4])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.wednesdayNightName5] != null && bedRotaModel.selectedBedRota[Strings.wednesdayNightName5] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.wednesdayNightName5])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.wednesdayNightFrom5])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.wednesdayNightTo5])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                    ],
                  ),
                ),
                SizedBox(height: 10,),

                Text('Thursday', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 18),),
                SizedBox(height: 5,),
                Container(decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey)
                ),
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                        Text('AM', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),)
                      ],),
                      SizedBox(height: 10,),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey)
                        ),
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.thursdayAmName1])),
                            _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.thursdayAmFrom1])),
                            _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.thursdayAmTo1])),
                          ],
                        ),
                      ),
                      bedRotaModel.selectedBedRota[Strings.thursdayAmName2] != null && bedRotaModel.selectedBedRota[Strings.thursdayAmName2] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.thursdayAmName2])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.thursdayAmFrom2])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.thursdayAmTo2])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.thursdayAmName3] != null && bedRotaModel.selectedBedRota[Strings.thursdayAmName3] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.thursdayAmName3])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.thursdayAmFrom3])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.thursdayAmTo3])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.thursdayAmName4] != null && bedRotaModel.selectedBedRota[Strings.thursdayAmName4] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.thursdayAmName4])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.thursdayAmFrom4])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.thursdayAmTo4])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.thursdayAmName5] != null && bedRotaModel.selectedBedRota[Strings.thursdayAmName5] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.thursdayAmName5])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.thursdayAmFrom5])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.thursdayAmTo5])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      SizedBox(height: 10,),


                      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                        Text('PM', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),)
                      ],),
                      SizedBox(height: 10,),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey)
                        ),
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.thursdayPmName1])),
                            _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.thursdayPmFrom1])),
                            _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.thursdayPmTo1])),
                          ],
                        ),
                      ),
                      bedRotaModel.selectedBedRota[Strings.thursdayPmName2] != null && bedRotaModel.selectedBedRota[Strings.thursdayPmName2] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.thursdayPmName2])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.thursdayPmFrom2])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.thursdayPmTo2])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.thursdayPmName3] != null && bedRotaModel.selectedBedRota[Strings.thursdayPmName3] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.thursdayPmName3])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.thursdayPmFrom3])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.thursdayPmTo3])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.thursdayPmName4] != null && bedRotaModel.selectedBedRota[Strings.thursdayPmName4] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.thursdayPmName4])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.thursdayPmFrom4])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.thursdayPmTo4])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.thursdayPmName5] != null && bedRotaModel.selectedBedRota[Strings.thursdayPmName5] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.thursdayPmName5])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.thursdayPmFrom5])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.thursdayPmTo5])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      SizedBox(height: 10,),
                      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                        Text('Night', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),)
                      ],),
                      SizedBox(height: 10,),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey)
                        ),
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.thursdayNightName1])),
                            _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.thursdayNightFrom1])),
                            _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.thursdayNightTo1])),
                          ],
                        ),
                      ),
                      bedRotaModel.selectedBedRota[Strings.thursdayNightName2] != null && bedRotaModel.selectedBedRota[Strings.thursdayNightName2] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.thursdayNightName2])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.thursdayNightFrom2])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.thursdayNightTo2])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.thursdayNightName3] != null && bedRotaModel.selectedBedRota[Strings.thursdayNightName3] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.thursdayNightName3])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.thursdayNightFrom3])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.thursdayNightTo3])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.thursdayNightName4] != null && bedRotaModel.selectedBedRota[Strings.thursdayNightName4] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.thursdayNightName4])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.thursdayNightFrom4])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.thursdayNightTo4])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.thursdayNightName5] != null && bedRotaModel.selectedBedRota[Strings.thursdayNightName5] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.thursdayNightName5])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.thursdayNightFrom5])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.thursdayNightTo5])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                    ],
                  ),
                ),
                SizedBox(height: 10,),

                Text('Friday', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 18),),
                SizedBox(height: 5,),
                Container(decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey)
                ),
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                        Text('AM', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),)
                      ],),
                      SizedBox(height: 10,),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey)
                        ),
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.fridayAmName1])),
                            _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.fridayAmFrom1])),
                            _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.fridayAmTo1])),
                          ],
                        ),
                      ),
                      bedRotaModel.selectedBedRota[Strings.fridayAmName2] != null && bedRotaModel.selectedBedRota[Strings.fridayAmName2] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.fridayAmName2])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.fridayAmFrom2])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.fridayAmTo2])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.fridayAmName3] != null && bedRotaModel.selectedBedRota[Strings.fridayAmName3] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.fridayAmName3])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.fridayAmFrom3])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.fridayAmTo3])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.fridayAmName4] != null && bedRotaModel.selectedBedRota[Strings.fridayAmName4] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.fridayAmName4])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.fridayAmFrom4])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.fridayAmTo4])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.fridayAmName5] != null && bedRotaModel.selectedBedRota[Strings.fridayAmName5] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.fridayAmName5])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.fridayAmFrom5])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.fridayAmTo5])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      SizedBox(height: 10,),


                      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                        Text('PM', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),)
                      ],),
                      SizedBox(height: 10,),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey)
                        ),
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.fridayPmName1])),
                            _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.fridayPmFrom1])),
                            _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.fridayPmTo1])),
                          ],
                        ),
                      ),
                      bedRotaModel.selectedBedRota[Strings.fridayPmName2] != null && bedRotaModel.selectedBedRota[Strings.fridayPmName2] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.fridayPmName2])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.fridayPmFrom2])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.fridayPmTo2])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.fridayPmName3] != null && bedRotaModel.selectedBedRota[Strings.fridayPmName3] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.fridayPmName3])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.fridayPmFrom3])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.fridayPmTo3])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.fridayPmName4] != null && bedRotaModel.selectedBedRota[Strings.fridayPmName4] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.fridayPmName4])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.fridayPmFrom4])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.fridayPmTo4])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.fridayPmName5] != null && bedRotaModel.selectedBedRota[Strings.fridayPmName5] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.fridayPmName5])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.fridayPmFrom5])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.fridayPmTo5])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      SizedBox(height: 10,),
                      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                        Text('Night', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),)
                      ],),
                      SizedBox(height: 10,),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey)
                        ),
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.fridayNightName1])),
                            _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.fridayNightFrom1])),
                            _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.fridayNightTo1])),
                          ],
                        ),
                      ),
                      bedRotaModel.selectedBedRota[Strings.fridayNightName2] != null && bedRotaModel.selectedBedRota[Strings.fridayNightName2] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.fridayNightName2])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.fridayNightFrom2])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.fridayNightTo2])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.fridayNightName3] != null && bedRotaModel.selectedBedRota[Strings.fridayNightName3] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.fridayNightName3])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.fridayNightFrom3])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.fridayNightTo3])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.fridayNightName4] != null && bedRotaModel.selectedBedRota[Strings.fridayNightName4] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.fridayNightName4])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.fridayNightFrom4])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.fridayNightTo4])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.fridayNightName5] != null && bedRotaModel.selectedBedRota[Strings.fridayNightName5] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.fridayNightName5])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.fridayNightFrom5])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.fridayNightTo5])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                    ],
                  ),
                ),
                SizedBox(height: 10,),

                Text('Saturday', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 18),),
                SizedBox(height: 5,),
                Container(decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey)
                ),
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                        Text('AM', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),)
                      ],),
                      SizedBox(height: 10,),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey)
                        ),
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.saturdayAmName1])),
                            _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.saturdayAmFrom1])),
                            _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.saturdayAmTo1])),
                          ],
                        ),
                      ),
                      bedRotaModel.selectedBedRota[Strings.saturdayAmName2] != null && bedRotaModel.selectedBedRota[Strings.saturdayAmName2] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.saturdayAmName2])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.saturdayAmFrom2])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.saturdayAmTo2])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.saturdayAmName3] != null && bedRotaModel.selectedBedRota[Strings.saturdayAmName3] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.saturdayAmName3])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.saturdayAmFrom3])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.saturdayAmTo3])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.saturdayAmName4] != null && bedRotaModel.selectedBedRota[Strings.saturdayAmName4] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.saturdayAmName4])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.saturdayAmFrom4])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.saturdayAmTo4])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.saturdayAmName5] != null && bedRotaModel.selectedBedRota[Strings.saturdayAmName5] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.saturdayAmName5])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.saturdayAmFrom5])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.saturdayAmTo5])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      SizedBox(height: 10,),


                      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                        Text('PM', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),)
                      ],),
                      SizedBox(height: 10,),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey)
                        ),
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.saturdayPmName1])),
                            _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.saturdayPmFrom1])),
                            _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.saturdayPmTo1])),
                          ],
                        ),
                      ),
                      bedRotaModel.selectedBedRota[Strings.saturdayPmName2] != null && bedRotaModel.selectedBedRota[Strings.saturdayPmName2] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.saturdayPmName2])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.saturdayPmFrom2])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.saturdayPmTo2])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.saturdayPmName3] != null && bedRotaModel.selectedBedRota[Strings.saturdayPmName3] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.saturdayPmName3])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.saturdayPmFrom3])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.saturdayPmTo3])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.saturdayPmName4] != null && bedRotaModel.selectedBedRota[Strings.saturdayPmName4] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.saturdayPmName4])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.saturdayPmFrom4])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.saturdayPmTo4])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.saturdayPmName5] != null && bedRotaModel.selectedBedRota[Strings.saturdayPmName5] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.saturdayPmName5])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.saturdayPmFrom5])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.saturdayPmTo5])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      SizedBox(height: 10,),
                      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                        Text('Night', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),)
                      ],),
                      SizedBox(height: 10,),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey)
                        ),
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.saturdayNightName1])),
                            _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.saturdayNightFrom1])),
                            _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.saturdayNightTo1])),
                          ],
                        ),
                      ),
                      bedRotaModel.selectedBedRota[Strings.saturdayNightName2] != null && bedRotaModel.selectedBedRota[Strings.saturdayNightName2] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.saturdayNightName2])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.saturdayNightFrom2])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.saturdayNightTo2])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.saturdayNightName3] != null && bedRotaModel.selectedBedRota[Strings.saturdayNightName3] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.saturdayNightName3])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.saturdayNightFrom3])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.saturdayNightTo3])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.saturdayNightName4] != null && bedRotaModel.selectedBedRota[Strings.saturdayNightName4] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.saturdayNightName4])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.saturdayNightFrom4])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.saturdayNightTo4])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.saturdayNightName5] != null && bedRotaModel.selectedBedRota[Strings.saturdayNightName5] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.saturdayNightName5])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.saturdayNightFrom5])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.saturdayNightTo5])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                    ],
                  ),
                ),
                SizedBox(height: 10,),

                Text('Sunday', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 18),),
                SizedBox(height: 5,),
                Container(decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey)
                ),
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                        Text('AM', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),)
                      ],),
                      SizedBox(height: 10,),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey)
                        ),
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.sundayAmName1])),
                            _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.sundayAmFrom1])),
                            _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.sundayAmTo1])),
                          ],
                        ),
                      ),
                      bedRotaModel.selectedBedRota[Strings.sundayAmName2] != null && bedRotaModel.selectedBedRota[Strings.sundayAmName2] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.sundayAmName2])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.sundayAmFrom2])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.sundayAmTo2])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.sundayAmName3] != null && bedRotaModel.selectedBedRota[Strings.sundayAmName3] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.sundayAmName3])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.sundayAmFrom3])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.sundayAmTo3])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.sundayAmName4] != null && bedRotaModel.selectedBedRota[Strings.sundayAmName4] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.sundayAmName4])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.sundayAmFrom4])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.sundayAmTo4])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.sundayAmName5] != null && bedRotaModel.selectedBedRota[Strings.sundayAmName5] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.sundayAmName5])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.sundayAmFrom5])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.sundayAmTo5])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      SizedBox(height: 10,),


                      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                        Text('PM', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),)
                      ],),
                      SizedBox(height: 10,),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey)
                        ),
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.sundayPmName1])),
                            _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.sundayPmFrom1])),
                            _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.sundayPmTo1])),
                          ],
                        ),
                      ),
                      bedRotaModel.selectedBedRota[Strings.sundayPmName2] != null && bedRotaModel.selectedBedRota[Strings.sundayPmName2] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.sundayPmName2])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.sundayPmFrom2])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.sundayPmTo2])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.sundayPmName3] != null && bedRotaModel.selectedBedRota[Strings.sundayPmName3] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.sundayPmName3])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.sundayPmFrom3])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.sundayPmTo3])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.sundayPmName4] != null && bedRotaModel.selectedBedRota[Strings.sundayPmName4] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.sundayPmName4])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.sundayPmFrom4])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.sundayPmTo4])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.sundayPmName5] != null && bedRotaModel.selectedBedRota[Strings.sundayPmName5] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.sundayPmName5])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.sundayPmFrom5])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.sundayPmTo5])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      SizedBox(height: 10,),
                      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                        Text('Night', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),)
                      ],),
                      SizedBox(height: 10,),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey)
                        ),
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.sundayNightName1])),
                            _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.sundayNightFrom1])),
                            _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.sundayNightTo1])),
                          ],
                        ),
                      ),
                      bedRotaModel.selectedBedRota[Strings.sundayNightName2] != null && bedRotaModel.selectedBedRota[Strings.sundayNightName2] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.sundayNightName2])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.sundayNightFrom2])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.sundayNightTo2])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.sundayNightName3] != null && bedRotaModel.selectedBedRota[Strings.sundayNightName3] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.sundayNightName3])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.sundayNightFrom3])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.sundayNightTo3])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.sundayNightName4] != null && bedRotaModel.selectedBedRota[Strings.sundayNightName4] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.sundayNightName4])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.sundayNightFrom4])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.sundayNightTo4])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                      bedRotaModel.selectedBedRota[Strings.sundayNightName5] != null && bedRotaModel.selectedBedRota[Strings.sundayNightName5] != ''  ? Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _textFormField('Name', GlobalFunctions.decryptString(bedRotaModel.selectedBedRota[Strings.sundayNightName5])),
                                _buildTimeField('Shift Start', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.sundayNightFrom5])),
                                _buildTimeField('Shift End', GlobalFunctions.databaseValueTime(bedRotaModel.selectedBedRota[Strings.sundayNightTo5])),
                              ],
                            ),
                          ),
                        ],
                      ) : Container(),
                    ],
                  ),
                ),
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
      appBar: AppBar(backgroundColor: greyDesign1,
        iconTheme: IconThemeData(color: Colors.white),
        flexibleSpace: AppBarGradient(),
        title: FittedBox(fit:BoxFit.fitWidth,
            child: Text('Bed Watch Rota', style: TextStyle(fontWeight: FontWeight.bold),)),
        actions: <Widget>[
          _buildShareButton(context)
        ],
      ),
      body: _buildPageContent(context),
    );
  }
}


class EmailDialog extends StatefulWidget {

  final bedRotaModel;

  EmailDialog(this.bedRotaModel);

  @override
  _EmailDialogState createState() => new _EmailDialogState();
}

class _EmailDialogState extends State<EmailDialog> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();



  final TextEditingController _emailTextController = new TextEditingController();

  @override
  void initState() {

    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _emailTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        child: Center(child: Text("Enter email addresses", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),),
      ),
      content: Form(
          key: _formKey,
          child: SingleChildScrollView(child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(width: 350, child: Text(
                  'Use the textbox below to add the email addresses of anyone you want to receive this Form, use a comma to separate the emails'),),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Flexible(
                      child: TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            labelText: 'Emails'),
                        controller: _emailTextController,
                        validator: (String value) {
                          String returnValue;
                          if (value.trim().length <= 0 && value.isEmpty) {
                            returnValue = 'Please enter an email';
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

              List<String> emailList = _emailTextController.text.split(',');
              print(emailList);

              List<String> emailListTrimmed = [];

              if(emailList.length > 0){

                emailList.forEach((String email){

                  if(email != null && email != '' && RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                      .hasMatch(email)) emailListTrimmed.add(email.trim());
                });

              }


              ConnectivityResult connectivityResult =
              await Connectivity().checkConnectivity();

              if (connectivityResult == ConnectivityResult.none) {
                GlobalFunctions.showToast(
                    'No data connection to email PDF');
              } else {

                GlobalFunctions.showLoadingDialog('Sending Email');

                bool success = await widget.bedRotaModel.sharePdf(ShareOption.Email, emailListTrimmed);

                GlobalFunctions.dismissLoadingDialog();

                if(success == true){
                  Navigator.of(context).pop();
                  GlobalFunctions.showToast(
                      'email successfully sent');
                } else {
                  GlobalFunctions.showToast(
                      'unable email PDF');
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
    );
  }
}

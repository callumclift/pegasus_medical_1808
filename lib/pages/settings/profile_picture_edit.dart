import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pegasus_medical_1808/shared/global_config.dart';
import 'package:pegasus_medical_1808/shared/global_functions.dart';
import 'package:pegasus_medical_1808/shared/strings.dart';
import 'package:pegasus_medical_1808/widgets/app_bar_gradient.dart';
import 'package:photo_view/photo_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:universal_html/html.dart' as html;




class ProfilePictureEdit extends StatefulWidget {
  @override
  _ProfilePictureEditState createState() => _ProfilePictureEditState();
}

class _ProfilePictureEditState extends State<ProfilePictureEdit> {

  File _image;
  Uint8List _imageWeb;
  final picker = ImagePicker();
  bool loading = false;
  bool deleteImage = false;

  Future getImage() async {

    if(kIsWeb){
      final pickedFile = await picker.getImage(imageQuality: 50);

      Uint8List pickedFileWeb = await pickedFile.readAsBytes();

      setState(() {
        loading = true;
        if (pickedFileWeb != null) {
          _imageWeb = pickedFileWeb;
        } else {
          _imageWeb = null;
        }
      });
    } else {
      final pickedFile = await picker.getImage(source: ImageSource.gallery, imageQuality: 50);

      setState(() {
        loading = true;
        if (pickedFile != null) {
          _image = File(pickedFile.path);
        } else {
          _image = null;
        }
      });
    }
  }


  double _buildBottomSheetHeight(bool hasImage) {
    double _deviceHeight = MediaQuery.of(context).size.height;

    double height;

    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      height = hasImage == false ? _deviceHeight * 0.15 : _deviceHeight * 0.2;
    } else {
      height = hasImage == false ? _deviceHeight * 0.3 : _deviceHeight * 0.4;
    }

    return height;
  }


  Future<Widget> _showBottomSheet(bool hasImage) async {

    FocusScope.of(context).requestFocus(new FocusNode());

    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            padding: EdgeInsets.only(bottom: 10.0),
            height: _buildBottomSheetHeight(hasImage),
            child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  double sheetHeight = constraints.maxHeight;

                  return Container(
                    height: sheetHeight,
                    child: Column(
                      children: <Widget>[
                        Container(width: constraints.maxWidth,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [purpleDesign, purpleDesign]),
                            ),
                            height: sheetHeight * 0.25,
                            child: Center(child: Text(
                              'Pick an Image',
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),)),
                        InkWell(onTap: () async {
                          await getImage();
                          Navigator.of(context).pop();

                        }, child: Container(
                            decoration: BoxDecoration(border: Border(top: BorderSide(color: Color.fromARGB(255, 217, 211, 210)))),
                            height: sheetHeight * 0.283,
                            child: Center(child: Text('Use Gallery', style: TextStyle(color: bluePurple),),)),),
                        user.profilePicture == null
                            ? Container()
                            : InkWell(onTap: () {
                              Navigator.of(context).pop();
                              setState(() {
                                _image = null;
                                _imageWeb = null;
                                deleteImage = true;
                                loading = true;
                              });
                        }, child: Container(
                            decoration: BoxDecoration(border: Border(top: BorderSide(color: Color.fromARGB(255, 217, 211, 210)))),
                            height: sheetHeight * 0.283,
                            child: Center(child: Text('Delete Image', style: TextStyle(color: bluePurple),),)),),
                      ],
                    ),
                  );
                }),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        flexibleSpace: AppBarGradient(),
        actions: [
          TextButton(onPressed: () async{
            await _showBottomSheet(true);
            if(_image != null || _imageWeb != null){

                ConnectivityResult connectivityResult = await Connectivity().checkConnectivity();

                if(connectivityResult != ConnectivityResult.none) {
                  try {

                    Reference storageRef =
                    FirebaseStorage.instance.ref().child('profilePictures/' + '${user.uid}/' + 'profilePicture.jpg');

                    if(kIsWeb){
                      storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/profilePictures/' + '${user.uid}/' + 'profilePicture.jpg');
                    }


                    UploadTask uploadTask;

                    if(kIsWeb){
                      uploadTask = storageRef.putData(
                        _imageWeb,
                        SettableMetadata(
                          contentType: 'image/jpg',
                        ),
                      );
                    } else {
                      uploadTask = storageRef.putFile(
                        _image,
                        SettableMetadata(
                          contentType: 'image/jpg',
                        ),
                      );
                    }

                    final TaskSnapshot downloadUrl =
                    (await uploadTask);

                    String profilePictureUrl = (await downloadUrl.ref.getDownloadURL());

                    if(profilePictureUrl != null){

                      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
                          {Strings.profilePicture : profilePictureUrl}).timeout(Duration(seconds: 60));

                      user.profilePicture = profilePictureUrl;
                      sharedPreferences.setString(Strings.profilePicture, profilePictureUrl);

                    }

                  } on TimeoutException catch(_){

                    GlobalFunctions.showToast('Connection timed out, unable to change profile picture');
                  } catch(e) {
                    print(e);
                  }
                } else {
                  GlobalFunctions.showToast('No data connection, unable to change profile picture');
                }
              setState(() {
                user.profilePicture = user.profilePicture;
                loading = false;
                _image = null;
                _imageWeb = null;
              });
            } else if(deleteImage == true){

              ConnectivityResult connectivityResult = await Connectivity().checkConnectivity();

              if(connectivityResult != ConnectivityResult.none) {
                try {

                  Reference storageRef =
                  FirebaseStorage.instance.ref().child('profilePictures/' + '${user.uid}/' + 'profilePicture.jpg');

                  if(kIsWeb){
                    storageRef = FirebaseStorage.instance.ref().child(firebaseStorageBucket + '/profilePictures/' + '${user.uid}/' + 'profilePicture.jpg');
                  }

                  await storageRef.delete();

                    await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
                        {Strings.profilePicture : null}).timeout(Duration(seconds: 60));

                    user.profilePicture = null;
                    sharedPreferences.setString(Strings.profilePicture, '');


                } on TimeoutException catch(_){

                  GlobalFunctions.showToast('Connection timed out, unable to change delete picture');
                } catch(e) {
                  print(e);
                }
              } else {
                GlobalFunctions.showToast('No data connection, unable to change delete picture');
              }

              setState(() {
                user.profilePicture = user.profilePicture;
                deleteImage = false;
                loading = false;
              });
            }


          }, child: Text('Edit', style: TextStyle(color: Colors.white),),)
        ],
        title: FittedBox(fit:BoxFit.fitWidth,
            child: Text('Profile Photo', style: TextStyle(fontWeight: FontWeight.bold),)),
      ),
      body: loading ? Container(color: Colors.black, child: Center(child: CircularProgressIndicator(
        valueColor: new AlwaysStoppedAnimation<Color>(bluePurple),
      ),),) : user.profilePicture == null || user.profilePicture == '' ? Container(color: Colors.black, child: Center(child: CircleAvatar(
        radius: MediaQuery.of(context).size.width *0.4,
        backgroundColor: bluePurple,
        child: FittedBox(
            fit: BoxFit.fitHeight,
            child: Text(user.name[0], style: TextStyle(fontSize: 1000), textAlign: TextAlign.start,)
        ),
      )),) : Container(
          child: PhotoView(
            minScale: PhotoViewComputedScale.contained,
            initialScale: PhotoViewComputedScale.contained,
            imageProvider: NetworkImage(user.profilePicture),
          )
      ),
    );
  }
}

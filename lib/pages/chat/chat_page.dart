import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:pegasus_medical_1808/models/chat_model.dart';
import 'package:pegasus_medical_1808/pages/chat/widgets/chat_message.dart';
import 'package:pegasus_medical_1808/pages/chat/widgets/chat_message_other.dart';
import 'package:pegasus_medical_1808/pages/chat/widgets/send_image.dart';
import 'package:pegasus_medical_1808/services/navigation_service.dart';
import 'package:pegasus_medical_1808/shared/global_functions.dart';
import 'package:pegasus_medical_1808/shared/strings.dart';
import 'package:pegasus_medical_1808/widgets/app_bar_gradient.dart';
import 'package:pegasus_medical_1808/widgets/side_drawer.dart';
import '../../locator.dart';
import '../../shared/global_config.dart';
import 'widgets/profile_picture.dart';
import 'package:flutter/material.dart';
import 'widgets/message_form.dart';
import 'widgets/message_wall.dart';
import 'package:provider/provider.dart';
import '../../constants/route_paths.dart' as routes;
import 'package:share/share.dart';
import 'package:photo_view/photo_view.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as Path;
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:dio/dio.dart';
//import 'package:image_picker_web/image_picker_web.dart';






class ChatPage extends StatefulWidget {
  ChatPage({Key key, this.title, this.groupId, this.id, this.groupPicture, this.isGroup}) : super(key: key);

  final String title;
  final String groupId;
  final String id;
  final String groupPicture;
  final bool isGroup;
  final store = FirebaseFirestore.instance.collection('chat_messages');

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  final NavigationService _navigationService = locator<NavigationService>();
  ScrollController _scrollController;
  int maxMessageToDisplay;
  final _controller = TextEditingController();
  String _message;
  FocusNode messageFocusNode;
  String replyMessageId;
  String replyMessageImage;
  String replyMessageString;
  String replyAuthor;
  bool replying = false;
  File _image;
  final picker = ImagePicker();




  @override
  void initState() {
    onMessages = false;
    messageFocusNode = FocusNode();
    maxMessageToDisplay = 20;
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        print('inside');
        setState(() {
          maxMessageToDisplay += 20;
          print(maxMessageToDisplay);
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    messageFocusNode.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  Future<File> getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery, imageQuality: 50);
    File image;

    setState(() {
      if (pickedFile != null) {
        image = File(pickedFile.path);
      } else {
        image = null;
        print('No image selected.');
      }
    });
    return image;
  }

  void _onPressed() async{
    ConnectivityResult connectivityResult = await Connectivity().checkConnectivity();

    if(connectivityResult != ConnectivityResult.none) {
      context.read<ChatModel>().addMessage(_controller.text, widget.groupId, replyMessageImage, replyMessageString, replyMessageId, replyAuthor, replying);
      setState(() {
        _message = '';
        _controller.clear();
          replying = false;
          replyMessageId = null;
          replyMessageString = null;
          replyMessageImage = null;
          replyAuthor = null;

      });

    } else {
      GlobalFunctions.showToast('No Data Connection, unable to send message');
    }
  }


  Widget groupAvatar(){
    return CircleAvatar(
      backgroundImage: AssetImage('assets/images/pegasusIcon.png'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: greyDesign1,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios, color: Colors.white,), onPressed: (){
          if(Navigator.canPop(context))Navigator.of(context).pop();
          _navigationService.navigateToReplacement(routes.MessagesRoute);
        },),
        iconTheme: IconThemeData(color: Colors.white),
        flexibleSpace: AppBarGradient(),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (BuildContext context) {
                    return ProfilePicture(title: widget.title, id: widget.id, groupPicture: widget.groupPicture, isGroup: widget.isGroup);
                  })),
              child: widget.isGroup ? groupAvatar() : StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('users').doc(widget.id).snapshots(),
                builder: (context, userSnapshot) {

                  print(userSnapshot.hasData);

                  if (userSnapshot.hasData) {

                    return userSnapshot.data[Strings.profilePicture] == null || userSnapshot.data[Strings.profilePicture] == '' ? CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Text(widget.title[0], style: TextStyle(color: bluePurple),),
                    ) : CircleAvatar(
                      backgroundImage: NetworkImage(userSnapshot.data[Strings.profilePicture]),
                    );

                  }

                  if (userSnapshot.hasError) {
                    return CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Text(widget.title[0], style: TextStyle(color: bluePurple),),
                    );
                  }

                  return CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(widget.title[0], style: TextStyle(color: bluePurple),),
                  );
                },
              ),),
            SizedBox(width: 10,),
            Expanded(child: Text(widget.title, overflow: TextOverflow.clip ,style: TextStyle(fontWeight: FontWeight.bold),))
          ],
        ),
        actions: <Widget>[
        ],
      ),
      backgroundColor: Color(0xffdee2d6),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onTap: ()=> FocusScope.of(context).unfocus(),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('chat_messages').doc(widget.groupId).collection('messages').limit(maxMessageToDisplay).orderBy('timestamp', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data.docs.isEmpty) {
                      return Center(child: Text('No messages to display'));
                    }

                    // Timer(
                    //   Duration(milliseconds: 250),
                    //       () => _scrollController.jumpTo(_scrollController.position.minScrollExtent),
                    // );

                    return ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      itemCount: snapshot.data.docs.length + 1,
                      itemBuilder: (context, index) {

                        if(index == snapshot.data.docs.length){
                          return Container();
                        }


                        final data = snapshot.data.docs[index].data() as Map<String, dynamic>;
                        final messageId = snapshot.data.docs[index].id;
                        final user = FirebaseAuth.instance.currentUser;

                        if (user != null && user.uid == data['author_id']) {
                          return FocusedMenuHolder(
                            menuWidth: MediaQuery.of(context).size.width*0.50,
                            blurSize: 5.0,
                            menuItemExtent: 45,
                            menuBoxDecoration: BoxDecoration(color: Colors.grey,borderRadius: BorderRadius.all(Radius.circular(15.0))),
                            duration: Duration(milliseconds: 100),
                            animateMenuItems: true,
                            blurBackgroundColor: Colors.black54,
                            openWithTap: false, // Open Focused-Menu on Tap rather than Long Press
                            menuOffset: 10.0, // Offset value to show menuItem from the selected item
                            bottomOffsetHeight: 80.0, // Offset height to consider, for showing the menu item ( for example bottom navigation bar), so that the popup menu will be shown on top of selected item.
                            menuItems: <FocusedMenuItem>[
                              // Add Each FocusedMenuItem  for Menu Options
                              FocusedMenuItem(title: Text("Copy Text"),trailingIcon: Icon(Icons.copy, color: bluePurple,) ,onPressed: (){
                                Clipboard.setData(new ClipboardData(text: data['value']));


                              }),
                              // FocusedMenuItem(title: Text("Share",),trailingIcon: Icon(Icons.share, color: bluePurple,) ,onPressed: (){
                              //   Share.share(data['value']);
                              //
                              // }),
                              FocusedMenuItem(title: Text("Delete",),trailingIcon: Icon(Icons.delete, color: bluePurple,) ,onPressed: (){
                                context.read<ChatModel>().deleteMessage(snapshot.data.docs[index].id, widget.groupId, data['image']);

                              }),
                            ],
                            onPressed: (){},
                            child: ChatMessage(
                              index: index,
                              data: data,
                            ),
                          );
                        }

                        return FocusedMenuHolder(
                          menuWidth: MediaQuery.of(context).size.width*0.50,
                          blurSize: 5.0,
                          menuItemExtent: 45,
                          menuBoxDecoration: BoxDecoration(color: Colors.grey,borderRadius: BorderRadius.all(Radius.circular(15.0))),
                          duration: Duration(milliseconds: 100),
                          animateMenuItems: true,
                          blurBackgroundColor: Colors.black54,
                          openWithTap: false, // Open Focused-Menu on Tap rather than Long Press
                          menuOffset: 10.0, // Offset value to show menuItem from the selected item
                          bottomOffsetHeight: 80.0, // Offset height to consider, for showing the menu item ( for example bottom navigation bar), so that the popup menu will be shown on top of selected item.
                          menuItems: <FocusedMenuItem>[
                            // Add Each FocusedMenuItem  for Menu Options
                            FocusedMenuItem(title: Text("Reply"),trailingIcon: Icon(Icons.reply, color: bluePurple,) ,onPressed: (){
                              messageFocusNode.requestFocus();
                              setState(() {
                                replyMessageId = messageId;
                                replyMessageImage = data['image'];
                                replyMessageString = data['value'];
                                replyAuthor = data['author'];
                                replying = true;
                              });
                            }),
                            FocusedMenuItem(title: Text("Copy Text"),trailingIcon: Icon(Icons.copy, color: bluePurple,) ,onPressed: (){
                              Clipboard.setData(new ClipboardData(text: data['value']));

                            }),
                            // FocusedMenuItem(title: Text("Share",),trailingIcon: Icon(Icons.share, color: bluePurple,) ,onPressed: (){
                            //   Share.share(data['value']);
                            //
                            // }),
                            if(data['image'] != null) FocusedMenuItem(title: Text("Save",),trailingIcon: Icon(Icons.save_alt, color: bluePurple,) ,onPressed: ()async {


                              var response = await Dio().get(
                                  data['image'],
                                  options: Options(responseType: ResponseType.bytes));
                              final result = await ImageGallerySaver.saveImage(
                                  Uint8List.fromList(response.data),
                                  quality: 60,
                                  name: replyMessageId);
                              print(result);





                              // var response = await http.get(data['image']);
                              // Directory documentDirectory = await getApplicationDocumentsDirectory();
                              // File file = new File(Path.join(documentDirectory.path, 'imagetest.png'));
                              // file.writeAsBytesSync(response.bodyBytes);

                            })
                          ],
                          onPressed: (){},
                          child: ChatMessageOther(
                            index: index,
                            data: data,
                          ),
                        );
                      },
                    );
                  }

                  if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  }

                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
          ),
          replying ? Container(height: 70, decoration: BoxDecoration(color: Colors.black, border: Border(left: BorderSide(width: 5, color: Colors.white))),
          child: Column(
            children: [
              Row(children: [
                Container(width: 10,),
                Text(replyAuthor, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
              ],),
              Row(children: [
                Container(width: 10,),
                Icon(Icons.reply, color: Colors.white,),
                Container(width: 10,),
                replyMessageImage == null ? Container() : Container(width: 30, child: Image.network(replyMessageImage),),
                Container(width: 10,),
                Expanded(child: Text(replyMessageString, style: TextStyle(color: Colors.white), overflow: TextOverflow.ellipsis,),),
                IconButton(icon: Icon(Icons.cancel_outlined, color: Colors.white,), onPressed: (){
                  setState(() {
                    replying = false;
                    replyMessageId = null;
                    replyMessageString = null;
                    replyMessageImage = null;
                    replyAuthor = null;
                  });
                },)
              ],)
            ],
          ),) : Container(),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    focusNode: messageFocusNode,
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(10),
                    ),
                    minLines: 1,
                    maxLines: 10,
                    onChanged: (value) {
                      setState(() {
                        _message = value;
                      });
                    },
                  ),
                ),
                SizedBox(width: 5),
                IconButton(icon: Icon(Icons.photo, color: bluePurple,), onPressed: () async{

                  File image;
                  Uint8List imageWeb;

                  if(kIsWeb){
                    final pickedFile = await picker.getImage(imageQuality: 50);

                    imageWeb = await pickedFile.readAsBytes();
                  } else {
                    image = await getImage();
                  }
                  if(image != null || imageWeb != null){
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (BuildContext context) {
                          return SendImage(image: image, imageWeb: imageWeb, groupId: widget.groupId, replyMessageImage: replyMessageImage, replyMessageString: replyMessageString, replyMessageId: replyMessageId, replyAuthor: replyAuthor, replying: replying);
                        })).then((_){
                      setState(() {
                        replying = false;
                        replyMessageId = null;
                        replyMessageString = null;
                        replyMessageImage = null;
                        replyAuthor = null;
                      });
                    });
                  }



                },),
                RawMaterialButton(
                  onPressed: _controller.text == null || _controller.text.isEmpty ? null : _onPressed,
                  fillColor: _controller.text == null || _controller.text.isEmpty
                      ? Colors.blueGrey
                      : Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'SEND',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )

        ],
      ),
    );
  }
}
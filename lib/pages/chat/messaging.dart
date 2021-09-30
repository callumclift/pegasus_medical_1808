import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:pegasus_medical_1808/models/chat_model.dart';
import 'package:pegasus_medical_1808/models/users_model.dart';
import 'package:pegasus_medical_1808/pages/chat/chat_page.dart';
import 'package:pegasus_medical_1808/shared/global_functions.dart';
import 'package:pegasus_medical_1808/shared/strings.dart';
import 'package:pegasus_medical_1808/widgets/app_bar_gradient.dart';
import 'package:pegasus_medical_1808/widgets/side_drawer.dart';
import '../../shared/global_config.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';


class MessagesPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MessagesPageState();
  }
}

class _MessagesPageState extends State<MessagesPage> {

  bool _loadingMore = false;
  String userControllerLastValue;
  UsersModel usersModel;
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> userGroups = [];
  bool loading = true;
  bool loadingChat = false;

  @override
  initState() {
    super.initState();
    onMessages = true;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      usersModel = context.read<UsersModel>();
      usersModel.searchControllerValue = '';
      //usersModel.getUsers();
      _setUpSearchController();
      _getGroups();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    usersModel.searchControllerValue = '';
    onMessages = false;
    super.dispose();
  }

  _getGroups() async{

    DocumentSnapshot currentUserSnapShot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    dynamic currentUserCurrentGroups = currentUserSnapShot.data()[Strings.groups];
    List<String> currentUserCurrentGroupsListString = [];
    if(currentUserCurrentGroups != null){
      List<dynamic> currentUserCurrentGroupsListDynamic = currentUserSnapShot.data()[Strings.groups];
      currentUserCurrentGroupsListString = currentUserCurrentGroupsListDynamic.map((value) => value as String).toList();

    }
    user.groups = currentUserCurrentGroupsListString;
    if(user.groups != null) sharedPreferences.setString(Strings.groups, jsonEncode(currentUserCurrentGroupsListString));


    if(user.groups != null && user.groups.length > 0){
      for(String group in user.groups){

        try {

          DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('chat_groups').doc(group).get();

          if(snapshot.exists){
            userGroups.add({'id': group, 'modified_at': snapshot.data()['modified_at']});
          }

        } on TimeoutException catch (_) {
          // A timeout occurred.
          GlobalFunctions.showToast('Network Timeout, unable to fetch messages');

        } catch (e) {
          print(e);

        }

      }

      if(userGroups.isNotEmpty){
        userGroups.sort((Map<String, dynamic> b,
            Map<String, dynamic> a) =>
            a['modified_at'].compareTo(b['modified_at']));
      }




    }

    setState(() {
      loading = false;
    });

  }

  _setUpSearchController(){
    _searchController.addListener((){
      usersModel.searchControllerValue = _searchController.text;

      if(_searchController.text.length <= 2 && userControllerLastValue != null && userControllerLastValue.length == 3){
        usersModel.shouldUpdateUsers = false;
        usersModel.getUsers();

      } else if(_searchController.text != userControllerLastValue && _searchController.text.length > 2){
        usersModel.shouldUpdateUsers = true;
        usersModel.searchUsers();
      }
      userControllerLastValue = _searchController.text;
    });

  }



  Widget _buildEditButton(UsersModel model, int index, BuildContext context, User userData) {

    String edit = 'Edit';
    String suspend = '';
    String delete = 'Delete';

    if (userData.suspended) {
      suspend = 'Resume';
    } else {
      suspend = 'Suspend';
    }

    final List<String> _userOptions = [edit];

    if (userData.uid != 'v8otBR0o4Cdp3E0Kq8Ud6r1tjE13' && userData.uid != user.uid) _userOptions.addAll([suspend, delete]);

    return PopupMenuButton(
        onSelected: (String value) async {
          FocusScope.of(context).requestFocus(new FocusNode());
          if (value == 'Delete') {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(32.0))),
                    title: Text('Notice'),
                    content: Text('Are you sure you wish to delete this user?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'cancel', style: TextStyle(color: bluePurple),),
                      ),
                      TextButton(
                        onPressed: () async {
                          model.selectUser(
                              model.allUsers[index].uid);
                          Navigator.of(context).pop();
                          await model.deleteUser(userData);
                        },
                        child: Text(
                          'ok', style: TextStyle(color: bluePurple),),
                      )
                    ],
                  );
                });
          } else if (value == 'Suspend' || value == 'Resume') {
            model.suspendResumeUser(userData);
          } else if (value == 'Edit') {
            model.selectUser(model.allUsers[index].uid);
            // Navigator.of(context).push(
            //     MaterialPageRoute(builder: (BuildContext context) {
            //       return UsersEditPage();
            //     })).then((_) {
            //   model.selectUser(null);
            // });
          }
        },
        icon: Icon(Icons.more_horiz, color: bluePurple,),
        itemBuilder: (BuildContext context) {
          return _userOptions.map((String option) {
            return PopupMenuItem<String>(
                value: option, child: Row(children: <Widget>[
              Expanded(child: Text(option)),
              Icon(_buildOptionIcon(option), color: bluePurple,)
            ],));

          }).toList();
        });
  }

  IconData _buildOptionIcon(String option){

    IconData returnedIcon;

    if(option == 'Edit') returnedIcon = Icons.person;
    if(option == 'Suspend') returnedIcon = Icons.warning;
    if(option == 'Resume') returnedIcon = Icons.check;
    if(option == 'Delete') returnedIcon = Icons.delete;

    return returnedIcon;


  }

  String _buildListSubtitle(String role, bool isSuspended){
    String subtitle;
    isSuspended ? subtitle = role + ' - (Suspended)': subtitle = role;
    return subtitle;
  }


  Widget _buildStartChatView(UsersModel model){
    final double deviceHeight = MediaQuery.of(context).size.height;

    Widget returnedWidget;
    if(model.allUsers.length < 1){

      returnedWidget = Expanded(
        child: RefreshIndicator(
            color: bluePurple,
            child: ListView(padding: EdgeInsets.all(10.0), children: <Widget>[
              Container(
                  height: deviceHeight * 0.6,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'No Users found pull down to refresh',
                        textAlign: TextAlign.center,
                      ),
                      Icon(
                        Icons.warning,
                        size: 40.0,
                        color: bluePurple,
                      )
                    ],
                  ))
            ]),
            onRefresh: () => model.getUsers().then((_){
              if(mounted){
                _searchController.clear();
                model.searchControllerValue = '';
              }
            })),
      );
    } else {

      returnedWidget = Expanded(child: ListView.builder(shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          return _buildListTileStartChat(index, model);
        },
        itemCount: model.allUsers.length >= 20 ? model.allUsers.length + 1 : model.allUsers.length,
      ));
    }

    return returnedWidget;


  }

  Widget _buildListView(UsersModel model, List<String> participants){
    final double deviceHeight = MediaQuery.of(context).size.height;

    Widget returnedWidget;
    if(model.allUsers.length < 1){

      returnedWidget = Expanded(
        child: RefreshIndicator(
            color: bluePurple,
            child: ListView(padding: EdgeInsets.all(10.0), children: <Widget>[
              Container(
                  height: deviceHeight * 0.6,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'No Users found pull down to refresh',
                        textAlign: TextAlign.center,
                      ),
                      Icon(
                        Icons.warning,
                        size: 40.0,
                        color: bluePurple,
                      )
                    ],
                  ))
            ]),
            onRefresh: () => model.getUsers().then((_){
              if(mounted){
                _searchController.clear();
                model.searchControllerValue = '';
              }
            })),
      );
    } else {

      returnedWidget = Expanded(child: RefreshIndicator(
        color: bluePurple,
        child: ListView.builder(shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            return _buildListTile(index, model, participants);
          },
          itemCount: model.allUsers.length >= 20 ? model.allUsers.length + 1 : model.allUsers.length,
        ),
        onRefresh: () => model.getUsers(),
      ));
    }

    return returnedWidget;


  }


  Widget _buildListViewGroup(){
    final double deviceHeight = MediaQuery.of(context).size.height;

    Widget returnedWidget;
    if(userGroups == null || userGroups.isEmpty){

      returnedWidget = Expanded(
        child: ListView(padding: EdgeInsets.all(10.0), children: <Widget>[
          Container(
              height: deviceHeight * 0.6,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'No active chats found',
                    textAlign: TextAlign.center,
                  ),
                  Icon(
                    Icons.warning,
                    size: 40.0,
                    color: bluePurple,
                  )
                ],
              ))
        ]),
      );
    } else {

      returnedWidget = Expanded(child: ListView.builder(shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          return _buildListTileGroup(index);
        },
        itemCount: userGroups.length,
      ));
    }
    return returnedWidget;
    
  }
  
  Map<String, dynamic> chatName(String memberId1, String memberId2, String memberName1, String memberName2){


    String returnedString;
    String returnedId;
    
    if(memberId1 == user.uid){
      returnedString = memberName2;
      returnedId = memberId2;
    } else {
      returnedString = memberName1;
      returnedId = memberId1;

    }


    return {'name': returnedString, 'id': returnedId};
    
  }

  Widget buildIconGroup(AsyncSnapshot<DocumentSnapshot> snapshot, Map<String, dynamic> nameOfChat) {
    return CircleAvatar(
      backgroundImage: AssetImage('assets/images/pegasusIcon.png'),
    );
  }




  Widget _buildListTileGroup(int index) {

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('chat_groups').doc(userGroups[index]['id']).snapshots(),
      builder: (context, snapshot) {

         if (snapshot.hasData) {

             Map<String, dynamic> recentMessage = snapshot.data['recent_message'];
             recentMessage[user.uid] = true;

             bool hasImage = false;


             Widget buildSubtitle(){

               Widget returnedWidget;
               if(snapshot.data['type'] == 1){

                 if(snapshot.data['recent_message']['image'] != null){
                   returnedWidget = Row(
                     children: [
                       Container(width: 30, child: Image.network(snapshot.data['recent_message']['image']),),
                       SizedBox(width: 5,),
                       Text(snapshot.data['recent_message']['value'], maxLines: 2, overflow: TextOverflow.ellipsis)
                     ],
                   );
                 } else {
                   returnedWidget = Text(snapshot.data['recent_message']['value'], maxLines: 2, overflow: TextOverflow.ellipsis);
                 }

               } else {


                 if(snapshot.data['recent_message']['image'] != null){
                   returnedWidget = Row(
                     children: [
                       Container(width: 30, child: Image.network(snapshot.data['recent_message']['image']),),
                       SizedBox(width: 5,),
                       Text(snapshot.data['recent_message']['name'] + ': ' + snapshot.data['recent_message']['value'], maxLines: 2, overflow: TextOverflow.ellipsis,),
                     ],
                   );
                 } else {
                   returnedWidget = Text(snapshot.data['recent_message']['name'] + ': ' + snapshot.data['recent_message']['value'], maxLines: 2, overflow: TextOverflow.ellipsis,);

                 }

               }
               return returnedWidget;
             }


             Map<String,dynamic> nameOfChat = chatName(snapshot.data['member_ids'][0], snapshot.data['member_ids'][1], snapshot.data['member_names'][0], snapshot.data['member_names'][1]);
             DateTime now = DateTime.now();
             bool beforeToday = DateTime.fromMillisecondsSinceEpoch(snapshot.data['recent_message']['timestamp']).isBefore(DateTime(now.year, now.month, now.day));
             return Column(
               children: [
                 ListTile(
                   onTap: () {
                     FirebaseFirestore.instance.collection('chat_groups').doc(userGroups[index]['id']).update(
                         {'recent_message': recentMessage});
                     Navigator.of(context).push(
                         MaterialPageRoute(builder: (BuildContext context) {
                           return ChatPage(title: snapshot.data['type'] == 1 ? nameOfChat['name'] : snapshot.data['name'], groupId: snapshot.data.id, id: nameOfChat['id'], groupPicture: snapshot.data['type'] == 1 ? null : snapshot.data['group_picture'], isGroup: snapshot.data['type'] == 1 ? false : true);
                         }));
                   },
                   leading: Row(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                       user == null || snapshot.data['recent_message'][user.uid] == null || snapshot.data['recent_message'][user.uid] == true ? Container(width: 10,) : Container(
                         width: 10,
                         height: 10,
                         decoration: BoxDecoration(
                           color: bluePurple,
                           shape: BoxShape.circle,
                         ),
                       ),
                       snapshot.data['type'] == 2 ? buildIconGroup(snapshot, nameOfChat) : StreamBuilder<DocumentSnapshot>(
                         stream: FirebaseFirestore.instance.collection('users').doc(nameOfChat['id'].toString()).snapshots(),
                         builder: (context, userSnapshot) {

                           print(userSnapshot.hasData);

                           if (userSnapshot.hasData) {

                             return userSnapshot.data[Strings.profilePicture] == null ? CircleAvatar(
                               backgroundColor: bluePurple,
                               child: Text(userSnapshot.data['name'][0]),
                             ) : CircleAvatar(
                               backgroundImage: NetworkImage(userSnapshot.data[Strings.profilePicture]),
                             );

                           }

                           if (userSnapshot.hasError) {
                             return CircleAvatar(
                               backgroundColor: bluePurple,
                               child: Text(snapshot.data['name'][0]),
                             );
                           }

                           return CircleAvatar(
                             backgroundColor: bluePurple,
                             child: Text(snapshot.data['name'][0]),
                           );
                         },
                       )
                     ],),
                   title: Text(snapshot.data['type'] == 1 ? nameOfChat['name'] : snapshot.data['name']),
                   subtitle: buildSubtitle(),
                   trailing: Text(beforeToday ? DateFormat("dd/MM/yyyy").format(DateTime.fromMillisecondsSinceEpoch(snapshot.data['recent_message']['timestamp'])) : DateFormat("HH:mm").format(DateTime.fromMillisecondsSinceEpoch(snapshot.data['recent_message']['timestamp']))),
                 ),
                 Divider()
               ],
             );


        }

        if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }

        return Center(child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
              bluePurple),
        ),);
      },
    );
  }
  
  
  
  
  
  

  Widget _buildListTileStartChat(int index, UsersModel model) {
    Widget returnedWidget;

    if (model.allUsers.length >= 20 && index == model.allUsers.length) {
      if (_loadingMore) {
        returnedWidget = Center(child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
              bluePurple),
        ),);
      } else {
        returnedWidget = Container(
          child: Center(child: MaterialButton(
            onPressed: () async {
              setState(() {
                _loadingMore = true;

              });
              await model.getMoreUsers();
              setState(() {
                _loadingMore = false;
              });
            },
            child: Ink(
              width: MediaQuery.of(context).size.width * 0.4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [purpleDesign, purpleDesign]),
                borderRadius: BorderRadius.circular(30.0),
              ),
              child:
              Container(
                constraints: BoxConstraints(
                    maxWidth: 88.0,
                    minHeight: 36.0),
                alignment: Alignment.center,
                child: Text('Load More', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
              ),
            ),
            splashColor: Colors.black12,
            padding: EdgeInsets.all(0),
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(32.0),
            ),
          ),),
        );
      }
    } else if (model.allUsers[index].uid == user.uid){

      return Container();

    } else {
      returnedWidget = Column(
        children: <Widget>[
          user == null ? Container() : ListTile(
            onTap: () async {


              Map<String, dynamic> result = await context.read<ChatModel>().addConversation(model.allUsers[index]);

              if(result['success'] == true){
                Navigator.pop(context);
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (BuildContext context) {
                      return ChatPage(title: model.allUsers[index].name, groupId: result['refId'], id: model.allUsers[index].uid, groupPicture: null, isGroup: false);
                    }));
              }
            },
            leading: Icon(Icons.person, color: bluePurple,),
            title: Text(model.allUsers[index].name),
          ),
          Divider(),
        ],
      );
    }
    return returnedWidget;

  }


  Widget _buildListTile(int index, UsersModel model, List<String> participants) {
    Widget returnedWidget;

    if (model.allUsers.length >= 20 && index == model.allUsers.length) {
      if (_loadingMore) {
        returnedWidget = Center(child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
              bluePurple),
        ),);
      } else {
        returnedWidget = Container(
          child: Center(child: MaterialButton(
            onPressed: () async {
              setState(() {
                _loadingMore = true;

              });
              await model.getMoreUsers();
              setState(() {
                _loadingMore = false;
              });
            },
            child: Ink(
              width: MediaQuery.of(context).size.width * 0.4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [purpleDesign, purpleDesign]),
                borderRadius: BorderRadius.circular(30.0),
              ),
              child:
              Container(
                constraints: BoxConstraints(
                    maxWidth: 88.0,
                    minHeight: 36.0),
                alignment: Alignment.center,
                child: Text('Load More', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
              ),
            ),
            splashColor: Colors.black12,
            padding: EdgeInsets.all(0),
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(32.0),
            ),
          ),),
        );
      }
    } else {
      returnedWidget = Column(
        children: <Widget>[
          user == null ? Container() : ListTile(
            leading: Icon(Icons.person, color: bluePurple,),
            title: Text(model.allUsers[index].name),
            subtitle: Text(_buildListSubtitle(model.allUsers[index].role, model.allUsers[index].suspended)),
            trailing: user == null ? Container() : _buildEditButton(model, index, context, model.allUsers[index]),
          ),
          Divider(),
        ],
      );
    }
    return returnedWidget;

  }

  Widget _buildListTileStartGroup(int index,  List<QueryDocumentSnapshot> userSnapshots) {
    Widget returnedWidget;

    if (userSnapshots[index].data()[Strings.uid] == user.uid){

      return Container();

    } else {
      returnedWidget = Column(
        children: <Widget>[
          user == null ? Container() : ListTile(
            onTap: () async {


              // Map<String, dynamic> result = await context.read<ChatModel>().addGroup(model.allUsers[index]);
              //
              // if(result['success'] == true){
              //   Navigator.pop(context);
              //   Navigator.of(context).push(
              //       MaterialPageRoute(builder: (BuildContext context) {
              //         return ChatPage(title: model.allUsers[index].name, groupId: result['refId'],);
              //       }));
              // }
            },
            leading: Icon(Icons.person, color: bluePurple,),
            title: Text(userSnapshots[index].data()[Strings.name]),
          ),
          Divider(),
        ],
      );
    }
    return returnedWidget;

  }

  startChat(UsersModel model) {

    model.getUsers();


    showModalBottomSheet(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0))),
      context: context,
      builder: (BuildContext _) {




        return Container(
          height: MediaQuery.of(context).size.height * 0.95,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Cancel', style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor),),
                    Text('New Chat', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),),
                    TextButton(child: Text('Cancel', style: TextStyle(color: bluePurple),), onPressed: () => Navigator.pop(context),),

                  ],
                ),
              ),
              // Container(margin: EdgeInsets.all(5), decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(20)),padding: EdgeInsets.only(left: 5, right: 5), child: Row(children: <Widget>[
              //   SizedBox(width: 5,),
              //   Icon(Icons.search, color: Colors.grey,),
              //   SizedBox(width: 5,),
              //   Expanded(child: TextFormField(
              //     decoration: InputDecoration(
              //         focusedBorder: InputBorder.none,
              //         border: InputBorder.none,
              //         hintText: 'Search'
              //     ),
              //     controller: _searchController,)),
              //   IconButton(icon: Icon(Icons.cancel, size: 15, color: Colors.grey), onPressed: _searchController.clear)
              // ],),),
              Divider(),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').orderBy(Strings.nameLowercase, descending: false).snapshots(),
                builder: (context, snapshot) {


                  if (snapshot.hasData) {

                    if (snapshot.data.docs.isEmpty) {
                      return Center(child: Text('Unable to load users'));
                    }

                    return Expanded(child: ListView.builder(shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {

                        return snapshot.data.docs[index].id == user.uid ?
                        Container() : Column(
                          children: <Widget>[
                            user == null ? Container() : ListTile(
                              onTap: () async {

                                if(loadingChat){
                                  return;
                                } else {
                                  loadingChat = true;
                                  Map<String, dynamic> result = await context.read<ChatModel>().addConversation(model.allUsers[index]);
                                  loadingChat = false;


                                  if(result['success'] == true){


                                    Navigator.pop(context);
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: (BuildContext context) {
                                          return ChatPage(title: model.allUsers[index].name, groupId: result['refId'], id: model.allUsers[index].uid, groupPicture: null, isGroup: false);
                                        }));
                                  }
                                }
                              },
                              leading: Icon(Icons.person, color: bluePurple,),
                              title: Text(snapshot.data.docs[index].data()[Strings.name]),
                            ),
                            Divider(),
                          ],
                        );
                      },
                      itemCount: snapshot.data.docs.length,
                    ),);
                  }

                  if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  }

                  return Center(child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        bluePurple),
                  ),);
                },
              )

              //
              //
              //
              // Consumer<UsersModel>(
              //   builder: (BuildContext context, UsersModel model, _) {
              //
              //     return model.isLoading ? Center(
              //         child: Column(
              //             mainAxisAlignment: MainAxisAlignment.center,
              //             children: <Widget>[
              //               SizedBox(height: 20.0),
              //               CircularProgressIndicator(
              //                 valueColor: AlwaysStoppedAnimation<Color>(
              //                     bluePurple),
              //               ),
              //               SizedBox(height: 20.0),
              //               Text('Fetching Users')
              //             ])) : _buildStartChatView(model);
              //   },
              // )

            ],
          ),
        );
      },
      isScrollControlled: true,
    );
  }

  createGroup(UsersModel model) {
    showModalBottomSheet(
      isDismissible: false,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0))),
      context: context,
      builder: (BuildContext _) {
        return GroupBottomSheet();
      },
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages', style: TextStyle(fontWeight: FontWeight.bold),),
        flexibleSpace: AppBarGradient(),
        actions: [
          IconButton(icon: Icon(Icons.create), onPressed: () => startChat(usersModel),)
        ],
      ),drawer: SideDrawer(),
      body: Consumer<UsersModel>(
        builder: (BuildContext context, UsersModel model, _) {

          return Column(children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
              TextButton(onPressed: () => createGroup(model), child: Text('New Group', style: TextStyle(color: bluePurple),),)
            ],),
            Divider(),
             loading ? Center(child: CircularProgressIndicator(
               valueColor: AlwaysStoppedAnimation<Color>(
                   bluePurple),
             ),) : _buildListViewGroup()
          ],);
        },
      ),
    );
  }
}

class GroupBottomSheet extends StatefulWidget {

  @override
  _GroupBottomSheetState createState() => _GroupBottomSheetState();
}

class _GroupBottomSheetState extends State<GroupBottomSheet> {

  List<Map<String, dynamic>> participants = [];
  bool loadingChat = false;



  TextEditingController _searchController = TextEditingController();
  TextEditingController _groupName = TextEditingController();
  bool hasName = false;
  bool selectAll = false;



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _groupName.dispose();
    super.dispose();
  }

  createGroup() {
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.95,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(child: Text('Cancel', style: TextStyle(color: bluePurple),), onPressed: () => Navigator.pop(context),),
                Text('Add Participants', style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 16),),
                TextButton(child: Text('Create', style: TextStyle(color: bluePurple),), onPressed: () async {
                  if(loadingChat){
                  return;
                  } else {
                  loadingChat = true;
                  if(_groupName.text.isNotEmpty && participants.length > 0){
                    FocusScope.of(context).unfocus();


                    Map<String, dynamic> result = await context.read<ChatModel>().addGroup(participants, _groupName.text);

                    if(result['success'] == true){
                      Navigator.pop(context);
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (BuildContext context) {
                            return ChatPage(title: _groupName.text, groupId: result['refId'], id: null, groupPicture: null, isGroup: true);
                          }));
                    }

                  }


                  }
                }),

              ],
            ),
          ),
          // Container(margin: EdgeInsets.all(5), decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(20)),padding: EdgeInsets.only(left: 5, right: 5), child: Row(children: <Widget>[
          //   SizedBox(width: 5,),
          //   Icon(Icons.search, color: Colors.grey,),
          //   SizedBox(width: 5,),
          //   Expanded(child: TextFormField(
          //     decoration: InputDecoration(
          //         focusedBorder: InputBorder.none,
          //         border: InputBorder.none,
          //         hintText: 'Search'
          //     ),
          //     controller: _searchController,)),
          //   IconButton(icon: Icon(Icons.cancel, size: 15, color: Colors.grey), onPressed: _searchController.clear)
          // ],),),
          Divider(),
          participants.length < 1 ? Container() : Column(
            children: [

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Participants', style: TextStyle(fontWeight: FontWeight.bold, color: bluePurple, fontSize: 16),)
                ],
              ),
              SizedBox(height: 5,),
              Wrap(crossAxisAlignment: WrapCrossAlignment.start,
                direction: Axis.horizontal,
                alignment: WrapAlignment.start,
                spacing: 10,
                children: [
                  SizedBox(width: 10,),
                  for(Map<String, dynamic> participant in participants ) Text(participant['name']),
                ],),
              SizedBox(height: 5,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Group Name', style: TextStyle(fontWeight: FontWeight.bold, color: bluePurple, fontSize: 16),)
                ],
              ),
              SizedBox(height: 5,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container( width: MediaQuery.of(context).size.width * 0.8, margin: EdgeInsets.all(5), decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(20)),padding: EdgeInsets.only(left: 5, right: 5), child: Row(children: <Widget>[
                    SizedBox(width: 5,),
                    Expanded(child: TextFormField(
                      decoration: InputDecoration(
                          focusedBorder: InputBorder.none,
                          border: InputBorder.none,
                          hintText: 'Name'
                      ),
                      controller: _groupName,)),
                    IconButton(icon: Icon(Icons.cancel, size: 15, color: Colors.grey), onPressed: _groupName.clear)
                  ],),)
                ],
              ),
              SizedBox(height: 5,),
              Divider()
            ],
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').orderBy(Strings.nameLowercase, descending: false).snapshots(),
            builder: (context, snapshot) {


              if (snapshot.hasData) {

                if (snapshot.data.docs.isEmpty) {
                  return Center(child: Text('Unable to load users'));
                }

                return Expanded(child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('Select All', style: TextStyle(color: bluePurple),),
                        SizedBox(width: 5,),
                        Checkbox(
                          activeColor: bluePurple,
                          value: selectAll,
                          onChanged: (bool value) => setState(() {
                          if(value == true){
                            for(QueryDocumentSnapshot snap in snapshot.data.docs){
                              participants.add({'id': snap.id, 'name': snap.data()['name'], 'groups': snap.data()['groups']});
                            }
                            selectAll = true;
                          } else {
                            for(QueryDocumentSnapshot snap in snapshot.data.docs){
                              participants.removeWhere((element) => element['id'] == snap.id);
                            }
                            selectAll = false;
                          }
                        })),
                        SizedBox(width: 15,),
                      ],
                    ),
                    Divider(),
                    Expanded(child: ListView.builder(shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {


                        int present = participants.indexWhere((element) => element['id'] == snapshot.data.docs[index].id);
                        bool inList = present == - 1 ? false : true;

                        return snapshot.data.docs[index].id == user.uid ?
                        Container() : Column(
                          children: <Widget>[
                            user == null ? Container() : ListTile(
                              leading: Icon(Icons.person, color: bluePurple,),
                              title: Text(snapshot.data.docs[index].data()[Strings.name]),
                              trailing: Checkbox(
                                  activeColor: bluePurple,
                                  value: inList,
                                  onChanged: (bool value) => setState(() {
                                    if(value == true){
                                      participants.add({'id': snapshot.data.docs[index].id, 'name': snapshot.data.docs[index].data()['name'], 'groups': snapshot.data.docs[index].data()['groups']});
                                      inList = true;
                                    } else {
                                      participants.removeWhere((element) => element['id'] == snapshot.data.docs[index].id);
                                      inList = false;
                                    }
                                  })),
                            ),
                            Divider(),
                          ],
                        );








                      },
                      itemCount: snapshot.data.docs.length,
                    ),)
                  ],
                ));
              }

              if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              }

              return Center(child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    bluePurple),
              ),);
            },
          )
          //_buildListView(model, participants)

        ],
      ),
    );
  }
}


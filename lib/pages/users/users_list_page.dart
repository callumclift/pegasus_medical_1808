import 'package:flutter/material.dart';
import 'package:pegasus_medical_1808/models/users_model.dart';
import './users_edit_page.dart';
import '../../shared/global_config.dart';
import 'package:provider/provider.dart';
import 'package:after_layout/after_layout.dart';


class UsersListPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _UsersListPageState();
  }
}

class _UsersListPageState extends State<UsersListPage> {

  bool _loadingMore = false;
  String userControllerLastValue;
  UsersModel usersModel;
  TextEditingController _searchController = TextEditingController();


  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      usersModel = context.read<UsersModel>();
      usersModel.searchControllerValue = '';
      usersModel.getUsers();
      _setUpSearchController();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    usersModel.searchControllerValue = '';
    super.dispose();
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
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (BuildContext context) {
                    return UsersEditPage();
                  })).then((_) {
                model.selectUser(null);
              });
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

  Widget _buildListView(UsersModel model){
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
            return _buildListTile(index, model);
          },
          itemCount: model.allUsers.length >= 20 ? model.allUsers.length + 1 : model.allUsers.length,
        ),
        onRefresh: () => model.getUsers(),
      ));
    }

    return returnedWidget;


  }


  Widget _buildListTile(int index, UsersModel model) {
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
            leading: model.allUsers[index].profilePicture == null || model.allUsers[index].profilePicture == '' ? CircleAvatar(
              backgroundColor: bluePurple,
              child: Text(model.allUsers[index].name[0]),
            ) : CircleAvatar(
              backgroundImage: NetworkImage(model.allUsers[index].profilePicture),
            ),
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

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Consumer<UsersModel>(
      builder: (BuildContext context, UsersModel model, _) {

        return Column(children: <Widget>[
          Container(margin: EdgeInsets.all(5), decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(20)),padding: EdgeInsets.only(left: 5, right: 5), child: Row(children: <Widget>[
            SizedBox(width: 5,),
            Icon(Icons.search, color: Colors.grey,),
            SizedBox(width: 5,),
            Expanded(child: TextFormField(
              decoration: InputDecoration(
                  focusedBorder: InputBorder.none,
                  border: InputBorder.none,
                  hintText: 'Search Users'
              ),
              controller: _searchController,)),
            IconButton(icon: Icon(Icons.cancel, size: 15, color: Colors.grey), onPressed: _searchController.clear)
          ],),),
          model.isLoading ? Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 20.0),
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          bluePurple),
                    ),
                    SizedBox(height: 20.0),
                    Text('Fetching Users')
                  ])) : _buildListView(model)
        ],);
      },
    );
  }
}

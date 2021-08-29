import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pegasus_medical_1808/shared/global_config.dart';
import 'package:pegasus_medical_1808/widgets/app_bar_gradient.dart';
import 'package:pegasus_medical_1808/widgets/side_drawer.dart';
import './users_edit_page.dart';
import './users_list_page.dart';



class UsersAdminPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          drawer: SideDrawer(),
          appBar: AppBar(
            flexibleSpace: AppBarGradient(),
            title: FittedBox(fit:BoxFit.fitWidth,
                child: Text('Manage Users', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),)),
            bottom: TabBar(indicatorColor: Colors.white,
              tabs: <Widget>[
                Tab(child: Text('Registered Users', style: TextStyle(color: Colors.white),),
                  icon: Icon(Icons.list),
                ),
                Tab(child: Text('Create User', style: TextStyle(color: Colors.white),),
                  icon: Icon(Icons.create),
                ),
              ],
            ),
          ),
          body: kIsWeb ? TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              UsersListPage(),
              UsersEditPage(),
            ],
          ) : TabBarView(
            children: <Widget>[
              UsersListPage(),
              UsersEditPage(),
            ],
          ),
        ));
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pegasus_medical_1808/shared/global_config.dart';
import 'package:pegasus_medical_1808/shared/strings.dart';
import 'package:pegasus_medical_1808/widgets/app_bar_gradient.dart';
import 'package:photo_view/photo_view.dart';

class ProfilePicture extends StatefulWidget {

  ProfilePicture({Key key, this.title, this.id, this.groupPicture, this.isGroup}) : super(key: key);

  final String title;
  final String id;
  final String groupPicture;
  final bool isGroup;

  @override
  _ProfilePictureState createState() => _ProfilePictureState();
}

class _ProfilePictureState extends State<ProfilePicture> {



  Widget buildGroup(){
    return Container(
        child: PhotoView(
          minScale: PhotoViewComputedScale.contained,
          initialScale: PhotoViewComputedScale.contained,
          imageProvider: AssetImage('assets/images/pegasusIcon.png'),
        )
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        flexibleSpace: AppBarGradient(),
        title: FittedBox(fit:BoxFit.fitWidth,
            child: Text('Contact Info', style: TextStyle(fontWeight: FontWeight.bold),)),
      ),
      body: widget.isGroup ? buildGroup() : StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(widget.id).snapshots(),
        builder: (context, userSnapshot) {

          print(userSnapshot.hasData);

          if (userSnapshot.hasData) {

            return userSnapshot.data[Strings.profilePicture] == null || userSnapshot.data[Strings.profilePicture] == '' ? Container(color: Colors.black, child: Center(child: CircleAvatar(
              radius: MediaQuery.of(context).size.width *0.4,
              backgroundColor: bluePurple,
              child: FittedBox(
                  fit: BoxFit.fitHeight,
                  child: Text(widget.title[0], style: TextStyle(fontSize: 1000), textAlign: TextAlign.start,)
              ),
            )),) : Container(
                child: PhotoView(
                  minScale: PhotoViewComputedScale.contained,
                  initialScale: PhotoViewComputedScale.contained,
                  imageProvider: NetworkImage(userSnapshot.data[Strings.profilePicture]),
                )
            );

          }

          if (userSnapshot.hasError) {
            return Container(color: Colors.black, child: Center(child: CircleAvatar(
              radius: MediaQuery.of(context).size.width *0.4,
              backgroundColor: bluePurple,
              child: FittedBox(
                  fit: BoxFit.fitHeight,
                  child: Text(widget.title[0], style: TextStyle(fontSize: 1000), textAlign: TextAlign.start,)
              ),
            )),);
          }

          return Container(color: Colors.black, child: Center(child: CircleAvatar(
            radius: MediaQuery.of(context).size.width *0.4,
            backgroundColor: bluePurple,
            child: FittedBox(
                fit: BoxFit.fitHeight,
                child: Text(widget.title[0], style: TextStyle(fontSize: 1000), textAlign: TextAlign.start,)
            ),
          )),);
        },
      ),
    );
  }
}

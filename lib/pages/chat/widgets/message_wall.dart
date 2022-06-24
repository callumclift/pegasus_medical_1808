import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';

import 'chat_message_other.dart';
import 'chat_message.dart';

class MessageWall extends StatelessWidget {
  final List<QueryDocumentSnapshot> messages;
  final ValueChanged<String> onDelete;

  const MessageWall({
    Key key,
    this.messages,
    this.onDelete,
  }) : super(key: key);

  bool shouldDisplayAvatar(int idx) {
    if (idx == 0) return true;

    final previousId = messages[idx - 1].get('author_id');
    final authorId = messages[idx].get('author_id');
    return authorId != previousId;
  }

  @override
  Widget build(BuildContext context) {

    final _controller = ScrollController();
    Timer(
      Duration(milliseconds: 250),
          () => _controller.jumpTo(_controller.position.maxScrollExtent),
    );





    return ListView.builder(
      controller: _controller,
      itemCount: messages.length + 1,
      itemBuilder: (context, index) {

        if(index == messages.length){
          return Container();
        }


        final data = messages[index].data() as Map<String, dynamic>;
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
            openWithTap: true, // Open Focused-Menu on Tap rather than Long Press
            menuOffset: 10.0, // Offset value to show menuItem from the selected item
            bottomOffsetHeight: 80.0, // Offset height to consider, for showing the menu item ( for example bottom navigation bar), so that the popup menu will be shown on top of selected item.
            menuItems: <FocusedMenuItem>[
              // Add Each FocusedMenuItem  for Menu Options
              FocusedMenuItem(title: Text("Open"),trailingIcon: Icon(Icons.open_in_new) ,onPressed: (){
              }),
              FocusedMenuItem(title: Text("Share"),trailingIcon: Icon(Icons.share) ,onPressed: (){}),
              FocusedMenuItem(title: Text("Favorite"),trailingIcon: Icon(Icons.favorite_border) ,onPressed: (){}),
              FocusedMenuItem(title: Text("Delete",style: TextStyle(color: Colors.redAccent),),trailingIcon: Icon(Icons.delete,color: Colors.redAccent,) ,onPressed: (){}),
            ],
            onPressed: (){},
            child: ChatMessage(
              index: index,
              data: data,
            ),
          );
        }

        return ChatMessageOther(
          index: index,
          data: data,
        );
      },
    );
  }
}
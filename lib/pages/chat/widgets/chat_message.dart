import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pegasus_medical_1808/shared/global_config.dart';

import 'image_view.dart';


class ChatMessage extends StatelessWidget {
  final int index;
  final Map<String, dynamic> data;
  final bool hasPadding;

  const ChatMessage({
    Key key,
    this.index,
    this.data,
    this.hasPadding = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {


    DateTime now = DateTime.now();
    bool beforeToday = DateTime.fromMillisecondsSinceEpoch(data['timestamp']).isBefore(DateTime(now.year, now.month, now.day));
    print(beforeToday);

    return Container(
      margin: EdgeInsets.only(
        top: hasPadding == true ? 15 : 5,
        bottom: 5,
        left: 10,
        right: 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: 300),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [purpleDesign, purpleDesign]),
              borderRadius: BorderRadius.circular(5)
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 12,
            ),
            child: Column(
              children: [
                data['is_reply'] == true ? Container(
                  decoration: BoxDecoration(border: Border(left: BorderSide(width: 5, color: Colors.white))),
                  child: Column(children: [
                    Row(children: [
                      Container(width: 10,),
                      Text(data['reply_author'], style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10))
                    ],),
                    Row(children: [
                      Container(width: 10,),
                      Icon(Icons.reply, color: Colors.white,),
                      Container(width: 10,),
                      data['reply_message_image'] == null ? Container() : Container(width: 30, child: Image.network(data['reply_message_image']),),
                      Container(width: 10,),
                      Text(data['reply_message'], style: TextStyle(color: Colors.white, fontSize: 10), overflow: TextOverflow.ellipsis,),
                    ],),
                    Container(height: 10,),
                  ],),
                ) : Container(),
                data['image'] == null ? Container() : Column(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (BuildContext context) {
                            return ImageView(image: data['image'],);
                          })),
                      child: Container(child: Image.network(data['image']),),
                    ),
                    Container(height: 10,)
                  ],
                ),
                Align(alignment: Alignment.centerLeft, child: Text(
                  data['value'],
                  style: TextStyle(color: Colors.white),
                ),),
                SizedBox(height: 5,),
                Align(alignment: Alignment.centerRight, child: Text(beforeToday ? DateFormat("dd/MM/yyyy HH:mm").format(DateTime.fromMillisecondsSinceEpoch(data['timestamp'])) : DateFormat("HH:mm").format(DateTime.fromMillisecondsSinceEpoch(data['timestamp'])),
                  style: TextStyle(color: Colors.white),
                ),),

              ],
            ),
          )
        ],
      ),
    );
  }
}
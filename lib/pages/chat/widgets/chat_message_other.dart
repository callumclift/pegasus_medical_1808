import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pegasus_medical_1808/shared/global_config.dart';
import 'image_view.dart';

class ChatMessageOther extends StatelessWidget {
  final int index;
  final Map<String, dynamic> data;
  final bool showAvatar;

  const ChatMessageOther(
      {Key key, this.index, this.data, this.showAvatar = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {

    DateTime now = DateTime.now();
    bool beforeToday = DateTime.fromMillisecondsSinceEpoch(data['timestamp']).isBefore(DateTime(now.year, now.month, now.day));
    print(beforeToday);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 10),
          Container(
            constraints: BoxConstraints(
              maxWidth: 300,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              children: [
                data['is_reply'] == true ? Container(
                  decoration: BoxDecoration(border: Border(left: BorderSide(width: 5, color: bluePurple))),
                  child: Column(children: [
                    Row(children: [
                      Container(width: 10,),
                      Text(data['reply_author'], style: TextStyle(color: bluePurple, fontWeight: FontWeight.bold, fontSize: 10))
                    ],),
                    Row(children: [
                      Container(width: 10,),
                      Icon(Icons.reply, color: bluePurple,),
                      Container(width: 10,),
                      data['reply_message_image'] == null ? Container() : Container(width: 30, child: Image.network(data['reply_message_image']),),
                      Container(width: 10,),
                      Text(data['reply_message'], style: TextStyle(color: bluePurple, fontSize: 10), overflow: TextOverflow.ellipsis,),
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
                  '${data['author']}:',
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontStyle: FontStyle.italic,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),),
                Align(alignment: Alignment.centerLeft, child: Text(
                  data['value'],
                  style: TextStyle(color: bluePurple),
                ),),
                SizedBox(height: 5,),
                Align(alignment: Alignment.centerRight, child: Text(beforeToday ? DateFormat("dd/MM/yyyy HH:mm").format(DateTime.fromMillisecondsSinceEpoch(data['timestamp'])) : DateFormat("HH:mm").format(DateTime.fromMillisecondsSinceEpoch(data['timestamp'])),
                  style: TextStyle(color: bluePurple),
                ),),

              ],
            ),
          )
        ],
      ),
    );
  }
}
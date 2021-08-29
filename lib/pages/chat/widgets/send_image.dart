import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:pegasus_medical_1808/models/chat_model.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:pegasus_medical_1808/shared/global_config.dart';
import 'package:pegasus_medical_1808/shared/global_functions.dart';
import 'package:pegasus_medical_1808/shared/strings.dart';
import 'package:pegasus_medical_1808/widgets/app_bar_gradient.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';


class SendImage extends StatefulWidget {

  SendImage({Key key, this.image, this.imageWeb, this.groupId, this.id, this.groupPicture, this.isGroup, this.replyMessageImage, this.replyMessageString, this.replyMessageId, this.replyAuthor, this.replying}) : super(key: key);

  final File image;
  final Uint8List imageWeb;
  final String groupId;
  final String id;
  final String groupPicture;
  final bool isGroup;
  final String replyMessageImage;
  final String replyMessageString;
  final String replyMessageId;
  final String replyAuthor;
  final bool replying;

  @override
  _SendImageState createState() => _SendImageState();
}

class _SendImageState extends State<SendImage> {

  final _controller = TextEditingController();

  void _onPressed(File image, Uint8List imageWeb) async{
    FocusScope.of(context).unfocus();
    ConnectivityResult connectivityResult = await Connectivity().checkConnectivity();
    if(connectivityResult != ConnectivityResult.none) {
      GlobalFunctions.showLoadingDialog('Sending...');
      if(kIsWeb){
        await context.read<ChatModel>().addMessage(_controller.text, widget.groupId, widget.replyMessageImage, widget.replyMessageString, widget.replyMessageId, widget.replyAuthor, widget.replying, image, imageWeb);
      } else {
        await context.read<ChatModel>().addMessage(_controller.text, widget.groupId, widget.replyMessageImage, widget.replyMessageString, widget.replyMessageId, widget.replyAuthor, widget.replying, image);

      }
      setState(() {
        _controller.clear();
      });

      GlobalFunctions.dismissLoadingDialog();
      Navigator.of(context).pop();

    } else {
      GlobalFunctions.showToast('No Data Connection, unable to send message');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        flexibleSpace: AppBarGradient(),
        title: FittedBox(fit:BoxFit.fitWidth,
            child: Text('Send Image', style: TextStyle(fontWeight: FontWeight.bold),)),
      ),
      body: Stack(
        children: [
          Container(
              child: PhotoView(
                minScale: PhotoViewComputedScale.contained,
                initialScale: PhotoViewComputedScale.contained,
                imageProvider: kIsWeb ? MemoryImage(widget.imageWeb) : FileImage(widget.image),
              )
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
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
                    ),
                  ),
                  SizedBox(width: 5),
                  RawMaterialButton(
                    onPressed: () => _onPressed(widget.image, widget.imageWeb),
                    fillColor: Theme.of(context).primaryColor,
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
            ),
          )
        ],
      ),
    );
  }
}

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:pegasus_medical_1808/shared/global_functions.dart';

class MessageForm extends StatefulWidget {
  final ValueChanged<String> onSubmit;

  MessageForm({Key key, this.onSubmit}) : super(key: key);

  @override
  _MessageFormState createState() => _MessageFormState();
}

class _MessageFormState extends State<MessageForm> {
  final _controller = TextEditingController();

  String _message;

  FocusNode messageFocusNode;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    messageFocusNode = FocusNode();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    messageFocusNode.dispose();

    super.dispose();
  }

  void _onPressed() async{
    ConnectivityResult connectivityResult = await Connectivity().checkConnectivity();

    if(connectivityResult != ConnectivityResult.none) {
      widget.onSubmit(_controller.text);
      setState(() {
        _message = '';
        _controller.clear();
      });

    } else {
      GlobalFunctions.showToast('No Data Connection, unable to send message');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.blue,
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
              onChanged: (value) {
                setState(() {
                  _message = value;
                });
              },
            ),
          ),
          SizedBox(width: 5),
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
    );
  }
}
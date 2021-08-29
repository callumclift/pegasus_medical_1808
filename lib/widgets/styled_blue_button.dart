import 'package:flutter/material.dart';
import '../shared/global_config.dart';

class StyledBlueButton extends StatelessWidget {

  final String text;
  final Function function;
  final bool disabled;

  StyledBlueButton(this.text, this.function, [this.disabled = false]);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.0),
      ),
      color: darkBlue,
      textColor: whiteGreen,
      child: Text(text, style: TextStyle(fontWeight: FontWeight.bold),),
      onPressed: () => disabled ? null : function(),
    );
  }
}

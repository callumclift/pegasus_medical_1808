import 'package:flutter/material.dart';
import 'package:pegasus_medical_1808/shared/global_config.dart';

class GradientButton extends StatelessWidget {

  final String text;
  final Function function;
  final bool disabled;

  GradientButton(this.text, this.function, [this.disabled = false]);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () => disabled ? null : function(),
      child: Ink(
        width: MediaQuery.of(context).size.width * 0.4,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [purpleDesign, purpleDesign]),
              //colors: [purpleDesign, purpleDesign]),
          borderRadius: BorderRadius.circular(30.0),
        ),
        child:
        Container(
          constraints: BoxConstraints(
              maxWidth: 88.0,
              minHeight: 36.0),
          alignment: Alignment.center,
          child: Text(text, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        ),
      ),
      splashColor: Colors.black12,
      padding: EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(32.0),
      ),
    );
  }
}

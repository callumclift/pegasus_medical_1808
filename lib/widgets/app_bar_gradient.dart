import 'package:flutter/material.dart';
import 'package:pegasus_medical_1808/shared/global_config.dart';

class AppBarGradient extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [pegasusPurple, pegasusPurple])
              //colors: [purpleDesign, purpleDesign])
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../shared/global_config.dart';
import 'package:flutter/services.dart';

class StandardTextFormField extends StatefulWidget {
  final FocusNode focusNode;
  final Color labelColor;
  final String labelText;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType textInputType;
  final String validatorMessage;
  final List<TextInputFormatter> inputFormatter;
  final bool validationFail;
  final bool obscureText;

  StandardTextFormField(
      {this.focusNode,
        this.labelColor,
        this.labelText,
        this.controller,
        this.maxLines = 1,
        this.textInputType = TextInputType.text,
        this.validatorMessage,
        this.inputFormatter,
        this.validationFail = false,
        this.obscureText = false});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _StandardTextFormFieldState();
  }
}

class _StandardTextFormFieldState extends State<StandardTextFormField> {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return TextFormField(
      inputFormatters: widget.inputFormatter,
      validator: widget.validatorMessage == null
          ? null
          : (String value) {
        String returnedValue;
        if (value.trim().length <= 0 && value.isEmpty) {
          returnedValue = widget.validatorMessage;
        }
        return returnedValue;
      },
      keyboardType: widget.textInputType,
      obscureText: widget.obscureText,
      maxLines: widget.maxLines,
      focusNode: widget.focusNode,
      decoration: InputDecoration(
          labelStyle: TextStyle(color: widget.labelColor),
          labelText: widget.labelText,
          suffixIcon: widget.controller.text == ''
              ? null
              : IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                  FocusScope.of(context).unfocus();
                  widget.controller.clear();
                  });
                });
              })
      ),
      controller: widget.controller,
    );
  }
}

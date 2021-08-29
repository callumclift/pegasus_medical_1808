import 'package:flutter/material.dart';

class DropdownFormField extends StatefulWidget {
  final String hint;
  final String value;
  final List<String> items;
  final Function onChanged;
  final Function validator;
  final Function onSaved;
  final String initialValue;
  final bool expanded;

  DropdownFormField({
    @required this.hint,
    @required this.value,
    @required this.items,
    @required this.onChanged,
    @required this.validator,
    @required this.initialValue,
    @required this.onSaved,
    @required this.expanded
  });

  @override
  State<StatefulWidget> createState() {
    return _DropdownFormField();
  }
}

class _DropdownFormField extends State<DropdownFormField> {
  @override
  Widget build(BuildContext context) {
    return FormField(
      initialValue: widget.initialValue,
      onSaved: (val) => widget.onSaved,
      validator: widget.validator,
      builder: (FormFieldState state) {
        return InputDecorator(
          decoration: InputDecoration(
            labelText: widget.hint,
            errorText: state.hasError ? state.errorText : null,
          ),
          isEmpty: widget.value == '' || widget.value == null,
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
              isExpanded: true,
              value: widget.value,
              isDense: widget.expanded ? false : true,
              onChanged: (dynamic newValue) {
                state.didChange(newValue);
                widget.onChanged(newValue);
              },
              items: widget.items.map((dynamic value) {
                return DropdownMenuItem(
                  value: value,
                  child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[Container(child: Flexible(child: Text(value)))],),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

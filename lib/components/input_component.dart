import 'package:flutter/material.dart';

class InputComponent extends StatefulWidget {
  final String title;
  final TextEditingController controller;
  final int? maxLength;
  final TextInputAction? action;
  final Function? onSubmit;
  final FocusNode? focusNode;

  const InputComponent({
    super.key, 
    required this.title,
    required this.controller,
    this.maxLength,
    this.action,
    this.onSubmit,
    this.focusNode
  });

  @override
  State<InputComponent> createState() => _InputComponentState();
}

class _InputComponentState extends State<InputComponent> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      cursorColor: Colors.blue,
      maxLines: null,
      maxLength: widget.maxLength,
      textInputAction: widget.action,
      decoration: InputDecoration(
        label: Text(widget.title),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey
          )
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.blue
          )
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red
          )
        )
      ),
      onSubmitted: (_) {
        if (widget.onSubmit != null) {
          widget.onSubmit!();
        }
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpInputComponent extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool autoFocus;
  final Function(String value) onChange;
  final Function onPrevious;

  const OtpInputComponent({
    super.key,
    required this.controller,
    required this.focusNode,
    this.autoFocus = false,
    required this.onChange,
    required this.onPrevious
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      width: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[200]
      ),
      child: Center(
        child: Focus(
          onKeyEvent: (node, event) {
            if (
              event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace &&
              controller.text.isEmpty
            ) {
              onPrevious();
            }
            return KeyEventResult.ignored;
          },
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            autofocus: autoFocus,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
            ),
            style: TextStyle(
              fontSize: 25
            ),
            inputFormatters: [
              LengthLimitingTextInputFormatter(1),
              FilteringTextInputFormatter.digitsOnly
            ],
            onChanged: (value) {
              onChange(value);
            },
          ),
        ),
      ),
    );
  }
}
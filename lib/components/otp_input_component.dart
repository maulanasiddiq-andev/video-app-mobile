import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpInputComponent extends StatelessWidget {
  final TextEditingController controller;
  final Function(String value) onChange;

  const OtpInputComponent({
    super.key,
    required this.controller,
    required this.onChange
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
        child: TextField(
          controller: controller,
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
    );
  }
}
import 'package:flutter/material.dart';

class DialogContainerComponent extends StatelessWidget {
  final Widget message;
  final List<DialogResponseModel> responses;

  const DialogContainerComponent({
    super.key,
    required this.message,
    required this.responses
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
      child: Wrap(
        children: [
          message,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ...responses.map((response) {
                return TextButton(
                  onPressed: () {
                    response.response();
                  }, 
                  child: Text(
                    response.title,
                    style: TextStyle(
                      color: response.color,
                    ),
                  )
                );
              })
            ],
          )
        ],
      ),
    );
  }
}

class DialogResponseModel {
  final String title;
  final Function response;
  final MaterialColor color;

  DialogResponseModel({
    required this.title,
    required this.response,
    required this.color
  });
}
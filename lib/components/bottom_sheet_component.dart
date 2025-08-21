import 'package:flutter/material.dart';

class BottomSheetComponent extends StatelessWidget {
  final List<BottomSheetMenuModel> menus;
  const BottomSheetComponent({super.key, required this.menus});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            child: Center(child: Text('Pilihan')),
          ),
          Divider(thickness: 1, color: Colors.black, height: 1),
          ...menus.map((menu) {
            return menu.isVisible 
              ? SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      Navigator.pop(context);
                      menu.onTap();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        spacing: 10,
                        children: [
                          Icon(menu.icon),
                          Text(menu.title)
                        ],
                      ),
                    ),
                  ),
                )
              : SizedBox();
          }),
        ],
      ),
    );
  }
}

class BottomSheetMenuModel {
  final String title;
  final IconData icon;
  final Function onTap;
  final bool isVisible;

  BottomSheetMenuModel({
    required this.icon,
    required this.onTap,
    required this.title,
    this.isVisible = true
  });
}
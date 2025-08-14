import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_app/components/profile_image_component.dart';
import 'package:video_app/constants/env.dart';
import 'package:video_app/controllers/profile_controller.dart';
import 'package:video_app/pages/histories/histories_list_page.dart';
import 'package:video_app/pages/profile/profile_page.dart';
import 'package:video_app/pages/videos/video_list_page.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  final ProfileController profileController = Get.find<ProfileController>();
  String baseUri = ApiPoint.baseUrl;
  int _currentIndex = 0;

  final List<Widget> _screens = [VideoListPage(), HistoriesListPage(), ProfilePage()];
  final List<BottomMenuModel> menus = [
    BottomMenuModel(
      title: 'Beranda',
      icon: Icons.home,
    ),
    BottomMenuModel(
      title: 'Riwayat',
      icon: Icons.history
    ),
    BottomMenuModel(
      title: 'Profile',
    )
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: _onTabTapped,
        currentIndex: _currentIndex,
        backgroundColor: Colors.blue,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[400],
        items: menus.map((menu) {
          if (menu.icon != null) {
            return BottomNavigationBarItem(
              icon: Icon(menu.icon),
              label: menu.title
            );            
          }

          return BottomNavigationBarItem(
            icon: Obx(() {
              var imageUrl = profileController.user.value?.profileImage;

              return ProfileImageComponent(
                profileImage: imageUrl,
                radius: 11,
              );
            }),
            label: menu.title
          );
        }).toList()
      ),
    );
  }
}

class BottomMenuModel {
  String title;
  IconData? icon;

  BottomMenuModel({
    required this.title,
    this.icon,
  });
}

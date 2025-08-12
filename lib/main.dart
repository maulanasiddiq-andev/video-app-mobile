import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_app/controllers/auth_controller.dart';
import 'package:video_app/pages/auth/login_page.dart';
import 'package:video_app/pages/root_page.dart';
import 'package:video_app/pages/splash_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  MyApp({super.key});

  final AuthController authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Video App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<bool>(
        future: authController.checkAuth(), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SplashPage();
          } else {
            if (snapshot.data == true) {
              return RootPage();
            } else {
              return LoginPage();
            }
          }
        }
      ),
    );
  }
}

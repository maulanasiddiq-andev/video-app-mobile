import 'package:flutter/material.dart';
import 'package:video_app/constants/env.dart';

class ProfileImageComponent extends StatelessWidget {
  final String? profileImage;
  final double radius;
  const ProfileImageComponent({
    super.key,
    this.profileImage,
    this.radius = 15
  });

  @override
  Widget build(BuildContext context) {
    final String uri = ApiPoint.baseUrl;
    
    return CircleAvatar(
      radius: radius,
      backgroundImage: profileImage == null
        ? AssetImage('assets/images/profile.png')
        : NetworkImage('$uri$profileImage'),
    );
  }
}
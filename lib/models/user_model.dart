import 'package:video_app/models/video_model.dart';

class UserModel {
  final String id;
  final String name;
  final String username;
  final String email;
  final String recordStatus;
  final List<VideoModel> videos;
  String? profileImage;

  UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.recordStatus,
    required this.videos,
    this.profileImage
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'], 
    name: json['name'], 
    username: json['username'], 
    email: json['email'], 
    recordStatus: json['record_status'], 
    videos: json['videos'] ?? [],
    profileImage: json['profile_image']
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'username': username,
    'email': email,
    'record_status': recordStatus,
    'profile_image': profileImage
  };
}
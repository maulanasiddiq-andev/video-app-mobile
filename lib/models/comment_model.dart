import 'package:video_app/models/user_model.dart';

class CommentModel {
  final String id;
  String text;
  final String recordStatus;
  final String userId;
  final String videoId;
  final UserModel user;
  final DateTime createdAt;
  bool isBeingEdited;

  CommentModel({
    required this.id,
    required this.text,
    required this.recordStatus,
    required this.user,
    required this.userId,
    required this.videoId,
    required this.createdAt,
    required this.isBeingEdited
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
    id: json['id'], 
    text: json['text'], 
    recordStatus: json['recordStatus'], 
    user: UserModel.fromJson(json['user']), 
    userId: json['userId'], 
    videoId: json['videoId'],
    createdAt: DateTime.parse(json['createdAt']).toLocal(),
    isBeingEdited: false
  );
}
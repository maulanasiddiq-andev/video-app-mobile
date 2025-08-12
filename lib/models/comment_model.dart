import 'package:video_app/models/user_model.dart';

class CommentModel {
  final String id;
  final String text;
  final String recordStatus;
  final String userId;
  final String videoId;
  final UserModel user;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.text,
    required this.recordStatus,
    required this.user,
    required this.userId,
    required this.videoId,
    required this.createdAt
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
    id: json['id'], 
    text: json['text'], 
    recordStatus: json['record_status'], 
    user: UserModel.fromJson(json['user']), 
    userId: json['user_id'], 
    videoId: json['video_id'],
    createdAt: DateTime.parse(json['created_at']).toLocal()
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'record_status': recordStatus,
    'user': user,
    'user_id': userId,
    'video_id': videoId
  };
}
import 'package:video_app/models/comment_model.dart';
import 'package:video_app/models/history_model.dart';
import 'package:video_app/models/user_model.dart';

class VideoModel {
  final String id;
  final String title;
  final String description;
  final String recordStatus;
  final String userId;
  final UserModel? user;
  final int? commentsCount;
  final DateTime createdAt;
  final CommentModel? comment;
  final String? image;
  final String? video;
  final String? duration;
  final HistoryModel? history;
  final int? historiesCount;

  VideoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.recordStatus,
    required this.userId,
    this.user,
    required this.commentsCount,
    required this.createdAt,
    this.comment,
    this.image,
    this.video,
    this.duration,
    this.history,
    required this.historiesCount
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) => VideoModel(
    id: json['id'], 
    title: json['title'], 
    description: json['description'], 
    recordStatus: json['recordStatus'], 
    userId: json['userId'],
    user: UserModel.fromJson(json['user']),
    commentsCount: json['commentsCount'],
    comment: json['comment'] != null ? CommentModel.fromJson(json['comment']) : null,
    createdAt: DateTime.parse(json['createdAt']).toLocal(),
    image: json['image'],
    video: json['video'],
    duration: json['duration'],
    history: json['history'] != null ? HistoryModel.fromJson(json['history']) : null,
    historiesCount: json['historiesCount']
  );

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'record_status': recordStatus
  };
}
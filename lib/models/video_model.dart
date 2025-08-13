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
  final List<CommentModel> comments;
  final String? image;
  final String? video;
  final String? duration;
  HistoryModel? history;
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
    required this.comments,
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
    recordStatus: json['record_status'], 
    userId: json['user_id'],
    user: UserModel.fromJson(json['user']),
    commentsCount: json['comments_count'],
    comments: json['comments'] == null ? [] : (json['comments'] as List).map((data) => CommentModel.fromJson(data)).toList(),
    createdAt: DateTime.parse(json['created_at']).toLocal(),
    image: json['image'],
    video: json['video'],
    duration: json['duration'],
    history:json['history'] != null ? HistoryModel.fromJson(json['history']) : null,
    historiesCount: json['histories_count']
  );

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'record_status': recordStatus
  };
}
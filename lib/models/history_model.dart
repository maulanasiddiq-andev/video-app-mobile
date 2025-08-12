import 'package:video_app/models/video_model.dart';

class HistoryModel {
  final String id;
  final String userId;
  final String videoId;
  final String duration;
  final String position;
  final DateTime createdAt;
  final VideoModel? video;

  HistoryModel({
    required this.id,
    required this.userId,
    required this.videoId,
    required this.duration,
    required this.position,
    required this.createdAt,
    this.video
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) => HistoryModel(
    id: json['id'], 
    userId: json['user_id'], 
    videoId: json['video_id'], 
    duration: json['duration'], 
    position: json['position'],
    createdAt: DateTime.parse(json['created_at']).toLocal(),
    video: json['video'] != null ? VideoModel.fromJson(json['video']) : null
  );
}
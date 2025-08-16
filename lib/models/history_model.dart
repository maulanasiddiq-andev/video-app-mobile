import 'package:video_app/models/video_model.dart';

class HistoryModel {
  final String id;
  final String userId;
  final String videoId;
  final String duration;
  final String position;
  final String recordStatus;
  final DateTime createdAt;
  final VideoModel? video;

  HistoryModel({
    required this.id,
    required this.userId,
    required this.videoId,
    required this.duration,
    required this.position,
    required this.createdAt,
    required this.recordStatus,
    this.video
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) => HistoryModel(
    id: json['id'], 
    userId: json['userId'], 
    videoId: json['videoId'], 
    duration: json['duration'], 
    position: json['position'],
    createdAt: DateTime.parse(json['createdAt']).toLocal(),
    video: json['video'] != null ? VideoModel.fromJson(json['video']) : null,
    recordStatus: json['recordStatus']
  );
}
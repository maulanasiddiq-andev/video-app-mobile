import 'package:video_app/models/user_model.dart';

class TokenModel {
  String? token;
  UserModel? user;

  TokenModel({
    this.token,
    this.user
  });

  factory TokenModel.fromJson(Map<String, dynamic> json) => TokenModel(
    token: json['token'],
    user: json['user'] != null ? UserModel.fromJson(json['user']) : null
  );
}
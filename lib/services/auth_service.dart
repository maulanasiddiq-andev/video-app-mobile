import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:video_app/constants/env.dart';
import 'package:video_app/exceptions/api_exception.dart';
import 'package:video_app/models/base_response.dart';
import 'package:video_app/models/token_model.dart';
import 'package:video_app/models/user_model.dart';

class AuthService {
  static const storage = FlutterSecureStorage();
  static const url = ApiPoint.url;

  static Future<BaseResponse<TokenModel>> login(String email, String password) async {
    final baseUri = Uri.parse('${url}login');
    final body = jsonEncode({"email": email, "password": password});

    final response = await http.post(
      baseUri,
      headers: {'Content-Type': 'application/json'},
      body: body
    );

    final responseJson = jsonDecode(response.body);
    final BaseResponse<TokenModel> result = BaseResponse.fromJson(
      responseJson,
      (data) => TokenModel.fromJson(data)
    );

    if (result.succeed == false) throw ApiException(result.messages[0]);

    return result;
  }

  static Future<BaseResponse<UserModel>> register(String email, String name, String username, String password) async {
    final baseUri = Uri.parse('${url}register');
    final body = {
      'email': email,
      'name': name,
      'username': username,
      'password': password
    };

    final response = await http.post(
      baseUri,
      headers: {
        'Content-Type': 'application/json'
      },
      body: jsonEncode(body)
    );

    final responseJson = jsonDecode(response.body);
    final BaseResponse<UserModel> result = BaseResponse.fromJson(
      responseJson, 
      (data) => UserModel.fromJson(data)
    );

    if (result.succeed == false) throw ApiException(result.messages[0]);

    return result;
  }

  static Future<BaseResponse<UserModel>> verifyAccount(String otpCode, String userId) async {
    final baseUrl = Uri.parse('${url}verify-account');

    final body = {
      'user_id': userId,
      'otp_code': otpCode
    };

    final response = await http.post(
      baseUrl,
      headers: {
        'Content-Type': 'application/json'
      },
      body: jsonEncode(body)
    );

    final responseJson = jsonDecode(response.body);
    final BaseResponse<UserModel> result = BaseResponse.fromJson(
      responseJson, 
      (data) => UserModel.fromJson(data)
    );

    if (result.succeed == false) throw ApiException(result.messages[0]);

    return result;
  }

  static Future<BaseResponse<UserModel>> resendOtpCode(String userId) async {
    final baseUrl = Uri.parse('${url}resend-otp');

    final response = await http.post(
      baseUrl,
      headers: {
        'Content-Type': 'application/json'
      },
      body: jsonEncode({'user_id': userId})
    );

    final responseJson = jsonDecode(response.body);
    final BaseResponse<UserModel> result = BaseResponse.fromJson(
      responseJson, 
      (data) => UserModel.fromJson(data)
    );

    if (result.succeed == false) throw ApiException(result.messages[0]);

    return result;
  }

  static Future<BaseResponse<UserModel>> checkAuth(String token) async {
    final url = Uri.parse('${ApiPoint.url}profile/get-self');
    var response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      }
    );

    var responseJson = jsonDecode(response.body);
    final BaseResponse<UserModel> result = BaseResponse.fromJson(
      responseJson, 
      (data) => UserModel.fromJson(data)
    );

    if (result.succeed == false) throw ApiException(result.messages[0]);

    return result;
  }
}
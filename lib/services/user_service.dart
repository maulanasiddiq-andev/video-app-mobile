import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:video_app/constants/env.dart';
import 'package:video_app/exceptions/api_exception.dart';
import 'package:video_app/models/base_response.dart';
import 'package:video_app/models/comment_model.dart';
import 'package:video_app/models/search_response.dart';
import 'package:video_app/models/video_model.dart';

class UserService {
  static const storage = FlutterSecureStorage();
  static String url = '${ApiPoint.url}user';

  static Future<BaseResponse<SearchResponse<VideoModel>>> getUserVideos(
    String id,
    int pageSize,
    int page,
  ) async {
    final baseUri = Uri.parse('$url/$id/get-videos');
    final uri = baseUri.replace(
      queryParameters: {
        'pageSize': pageSize.toString(),
        'page': page.toString(),
      },
    );
    final token = await storage.read(key: 'token');

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    final responseJson = jsonDecode(response.body);
    final result = BaseResponse.fromJson(
      responseJson,
      (data) =>
          SearchResponse.fromJson(data, (item) => VideoModel.fromJson(item)),
    );

    if (result.succeed == false) throw ApiException(result.messages[0]);

    return result;
  }

  static Future<BaseResponse<SearchResponse<CommentModel>>> getUserComments(
    String id,
    int pageSize,
    int page,
  ) async {
    final baseUri = Uri.parse('$url/$id/get-comments');
    final uri = baseUri.replace(
      queryParameters: {
        'pageSize': pageSize.toString(),
        'page': page.toString(),
      },
    );
    final token = await storage.read(key: 'token');

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    final responseJson = jsonDecode(response.body);
    final result = BaseResponse.fromJson(
      responseJson,
      (data) =>
          SearchResponse.fromJson(data, (item) => CommentModel.fromJson(item)),
    );

    if (result.succeed == false) throw ApiException(result.messages[0]);

    return result;
  }
}

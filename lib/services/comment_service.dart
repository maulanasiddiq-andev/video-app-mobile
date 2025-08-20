import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:video_app/constants/env.dart';
import 'package:video_app/constants/record_status_constant.dart';
import 'package:video_app/exceptions/api_exception.dart';
import 'package:video_app/models/base_response.dart';
import 'package:video_app/models/comment_model.dart';
import 'package:video_app/models/search_response.dart';

class CommentService {
  static const storage = FlutterSecureStorage();
  static String url = '${ApiPoint.url}comment';

  static Future<BaseResponse<SearchResponse<CommentModel>>> getComments(
    String videoId,
    int page,
    int pageSize
  ) async {
    final baseUri = Uri.parse(url);
    final uri = baseUri.replace(queryParameters: {
      'video_id': videoId,
      'page': page.toString(),
      'page_size': pageSize.toString()
    });

    var token = await storage.read(key: 'token');
    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      }  
    );

    final dynamic responseJson = jsonDecode(response.body);
    final BaseResponse<SearchResponse<CommentModel>> result = BaseResponse.fromJson(
      responseJson, 
      (data) => SearchResponse.fromJson(
        data, 
        (item) => CommentModel.fromJson(item)
      )
    );

    if (result.succeed == false) throw ApiException(result.messages[0]);

    return result;
  }

  static Future<BaseResponse<CommentModel>> createComment(String text, String videoId) async {
    final uri = Uri.parse(url);
    final body = {
      'text': text,
      'video_id': videoId,
      'record_status': RecordstatusConstant.active
    };

    var token = await storage.read(key: 'token');
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept': 'application/json'
      },  
      body: jsonEncode(body)
    );

    final responseJson = jsonDecode(response.body);
    print(responseJson);
    final BaseResponse<CommentModel> result = BaseResponse.fromJson(
      responseJson, 
      (data) => CommentModel.fromJson(data)
    );

    if (result.succeed == false) throw ApiException(result.messages[0]);

    return result;
  }

  static Future<BaseResponse<CommentModel>> editComment(String commentId, String text) async {
    final uri = Uri.parse('$url/$commentId');
    var token = await storage.read(key: 'token');
    final response = await http.put(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      }, 
      body: jsonEncode({'text': text})
    );

    final responseJson = jsonDecode(response.body);
    final BaseResponse<CommentModel> result = BaseResponse.fromJson(
      responseJson, 
      (data) => CommentModel.fromJson(data)
    );

    if (result.succeed == false) throw ApiException(result.messages[0]);

    return result;
  }

  static Future<BaseResponse<CommentModel>> deleteComment(String id) async {
    final uri = Uri.parse('$url/$id');
    var token = await storage.read(key: 'token');
    final response = await http.delete(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json'
      }, 
    );

    final responseJson = jsonDecode(response.body);
    final BaseResponse<CommentModel> result = BaseResponse.fromJson(
      responseJson, 
      (data) => CommentModel.fromJson(data)
    );

    if (result.succeed == false) throw ApiException(result.messages[0]);

    return result;
  }
}
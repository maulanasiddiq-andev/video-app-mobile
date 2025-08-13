import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:video_app/constants/env.dart';
import 'package:video_app/exceptions/api_exception.dart';
import 'package:video_app/models/base_response.dart';
import 'package:video_app/models/history_model.dart';
import 'package:video_app/models/search_response.dart';

class HistoryService {
  static const storage = FlutterSecureStorage();
  static const String url = '${ApiPoint.url}history';

  static Future<BaseResponse<SearchResponse<HistoryModel>>> getHistories(
    int page,
    int pageSize
  ) async {
    final baseUri = Uri.parse(url);
    final uri = baseUri.replace(queryParameters: {
      'page': page.toString(),
      'page_size': pageSize.toString()
    });

    var token = await storage.read(key: 'token');
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token'
      }  
    );

    final dynamic responseJson = jsonDecode(response.body);
    final BaseResponse<SearchResponse<HistoryModel>> result = BaseResponse.fromJson(
      responseJson, 
      (data) => SearchResponse.fromJson(
        data, 
        (item) => HistoryModel.fromJson(item)
      )
    );

    if (result.succeed == false) throw ApiException(result.messages[0]);

    return result;
  }

  static Future<BaseResponse<HistoryModel>> createHistory(
    String videoId,
    String duration,
    String position
  ) async {
    final uri = Uri.parse(url);

    final body = {
      'video_id': videoId,
      'duration': duration,
      'position': position
    };
    final encodedBody = jsonEncode(body);

    var token = await storage.read(key: 'token');
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: encodedBody
    );

    final responseJson = jsonDecode(response.body);
    final BaseResponse<HistoryModel> result = BaseResponse.fromJson(
      responseJson, 
      (data) => HistoryModel.fromJson(data)
    );

    if (result.succeed == false) throw ApiException(result.messages[0]);

    return result;
  }

  static Future<BaseResponse<HistoryModel>> deleteHistory(String historyId) async {
    final uri = Uri.parse('$url/$historyId');

    var token = await storage.read(key: 'token');
    final response = await http.delete(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      }
    );

    final responseJson = jsonDecode(response.body);
    final BaseResponse<HistoryModel> result = BaseResponse.fromJson(
      responseJson, 
      (data) => HistoryModel.fromJson(data)
    );

    if (result.succeed == false) throw ApiException(result.messages[0]);

    return result;
  }
}
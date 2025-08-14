import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:video_app/constants/env.dart';
import 'package:video_app/constants/record_status_constant.dart';
import 'package:video_app/exceptions/api_exception.dart';
import 'package:video_app/models/base_response.dart';
import 'package:video_app/models/search_response.dart';
import 'package:video_app/models/video_model.dart';
import 'package:video_app/utils/convert_media_type.dart';

class VideoService {
  static const storage = FlutterSecureStorage();
  static String url = '${ApiPoint.url}video';
  
  static Future<BaseResponse<SearchResponse<VideoModel>>> getVideos(
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

    final BaseResponse<SearchResponse<VideoModel>> result = BaseResponse.fromJson(
      responseJson, 
      (data) => SearchResponse.fromJson(
        data, 
        (item) => VideoModel.fromJson(item)
      )
    );

    if (result.succeed == false) throw ApiException(result.messages[0]);

    return result;
  }

  static Future<BaseResponse<VideoModel>> getVideoById(String id) async {
    final token = await storage.read(key: 'token');
    final response = await http.get(
      Uri.parse('$url/$id'),
      headers: {
        'Authorization': 'Bearer $token'
      }  
    );

    final dynamic responseJson = jsonDecode(response.body);
    final BaseResponse<VideoModel> result = BaseResponse.fromJson(
      responseJson, 
      (data) => VideoModel.fromJson(data)
    );

    if (result.succeed == false) throw ApiException(result.messages[0]);

    return result;
  }

  static Future<BaseResponse<VideoModel>> createVideo(
    String title,
    String description,
    File? image,
    File? video,
    String duration
  ) async {
    var token = await storage.read(key: 'token');
    final uri = Uri.parse(url);

    var request = http.MultipartRequest('POST', uri);
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    });

    request.fields.addAll({
      'title': title,
      'description': description,
      'record_status': RecordstatusConstant.active
    });

    if (image != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'image', 
          image.path,
          contentType: convertPathToMediaType(image.path)
        )
      ); 
    }

    if (video != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'video', 
          video.path,
          contentType: convertPathToMediaType(video.path)
        )
      );

      request.fields['duration'] = duration;
    }

    final streamedBody = await request.send();
    final response = await streamedBody.stream.bytesToString();
    final responseJson = jsonDecode(response);

    var result = BaseResponse.fromJson(
      responseJson, 
      (data) => VideoModel.fromJson(data)
    );

    if (result.succeed == false) throw ApiException(result.messages[0]);

    return result;
  }

  static Future<BaseResponse<VideoModel>> editVideoById(
    String videoId,
    String title,
    String description,
    File? newImage,
    String? oldImage,
    File? newVideo,
    String? oldVideo,
    String duration
  ) async {
    var token = await storage.read(key: 'token');
    final uri = Uri.parse('$url/${videoId.toString()}');

    // some api doesnt accept mutltipart/form-data with PUT
    var request = http.MultipartRequest('POST', uri);
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    });

    // '_method': 'PUT' make the api consider POST as PUT
    final body = {
      'title': title,
      'description': description,
      'record_status': RecordstatusConstant.active,
      '_method': 'PUT'
    };

    request.fields.addAll(body);

    if (newImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'image', 
          newImage.path,
          contentType: convertPathToMediaType(newImage.path)
        )
      ); 
    } else {
      if (oldImage != null) request.fields['image'] = oldImage;
    }

    if (newVideo != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'video', 
          newVideo.path,
          contentType: convertPathToMediaType(newVideo.path)
        )
      );
    } else {
      if (oldVideo != null) {
        request.fields['video'] = oldVideo;
      }
    }

    request.fields['duration'] = duration;

    final streamedBody = await request.send();
    final response = await streamedBody.stream.bytesToString();
    final responseJson = jsonDecode(response);

    var result = BaseResponse.fromJson(
      responseJson, 
      (data) => VideoModel.fromJson(data)
    );

    if (result.succeed == false) throw ApiException(result.messages[0]);

    return result;
  }

  static Future<BaseResponse<VideoModel>> deleteVideo(String id) async {
    final token = await storage.read(key: 'token');
    final response = await http.delete(
      Uri.parse('$url/$id'),
      headers: {
        'Authorization': 'Bearer $token'
      }  
    );

    final dynamic responseJson = jsonDecode(response.body);
    final BaseResponse<VideoModel> result = BaseResponse.fromJson(
      responseJson, 
      (data) => VideoModel.fromJson(data)
    );

    if (result.succeed == false) throw ApiException(result.messages[0]);

    return result;
  }
}
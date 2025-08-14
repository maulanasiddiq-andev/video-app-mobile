import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:video_app/constants/env.dart';
import 'package:video_app/exceptions/api_exception.dart';
import 'package:video_app/models/user_model.dart';
import 'package:video_app/models/base_response.dart';

class ProfileService {
  static const storage = FlutterSecureStorage();
  static String url = '${ApiPoint.url}profile';

  static Future<BaseResponse<UserModel>> editProfileImage(
    UserModel? user,
    File? image
  ) async {
    final token = await storage.read(key: 'token');
    final uri = Uri.parse('$url/edit-profile-image');

    var request = http.MultipartRequest('POST', uri);
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    });

    if (user?.profileImage != null) {
      request.fields["old_image"] = user!.profileImage!;
    }

    final mimeType = lookupMimeType(image!.path);
    final mediaType = mimeType?.split('/');

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        image.path,  
        contentType: MediaType(mediaType![0], mediaType[1])
      )
    );

    var streamedBody = await request.send();
    var response = await streamedBody.stream.bytesToString();
    var responseJson = jsonDecode(response);
    final BaseResponse<UserModel> result = BaseResponse.fromJson(
      responseJson, 
      (data) => UserModel.fromJson(data)
    );

    if (result.succeed == false) throw ApiException(result.messages[0]);

    return result;
  }
}
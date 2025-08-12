import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_app/constants/env.dart';
import 'package:video_app/exceptions/api_exception.dart';
import 'package:video_app/models/base_response.dart';
import 'package:video_app/models/user_model.dart';
import 'package:video_app/services/profile_service.dart';

class ProfileController extends GetxController {
  final baseUri = '${ApiPoint.url}profile';
  final storage = FlutterSecureStorage();
  var user = Rxn<UserModel>();

  // edit profile image
  var isLoadingEditImage = false.obs;
  ImagePicker picker = ImagePicker();
  var pickedImage = Rxn<File>();

  @override
  void onInit() async {
    super.onInit();

    final existingUser = await storage.read(key: 'user');

    if (existingUser != null) {
      final decodedUser = jsonDecode(existingUser); 
      user.value = UserModel.fromJson(decodedUser);
    }
  }

  Future<void> pickImage(ImageSource source) async {
    XFile? pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      final croppedImage = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Atur Gambar',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            aspectRatioPresets: [
              CropAspectRatioPreset.square
            ]
          )
        ]
      );

      if (croppedImage != null) {
        pickedImage.value = File(croppedImage.path); 
      }
    }
  }

  Future<void> editProfileImage() async {
    isLoadingEditImage(true);

    try {
      final BaseResponse<UserModel> result = await ProfileService.editProfileImage(user.value, pickedImage.value);

      user.value = result.data;
      pickedImage.value = null;
      Fluttertoast.showToast(msg: result.messages[0]);
    } on ApiException catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      isLoadingEditImage(false);
    }
  }

  void emptyImage() {
    pickedImage.value = null;
  }
}
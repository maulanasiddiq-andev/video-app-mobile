import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_app/exceptions/api_exception.dart';
import 'package:video_app/models/base_response.dart';
import 'package:video_app/models/comment_model.dart';
import 'package:video_app/models/search_response.dart';
import 'package:video_app/models/video_model.dart';
import 'package:video_app/services/video_service.dart';

class VideoController extends GetxController {
  // videos list
  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  var isRefreshing = false.obs;
  var videos = <VideoModel>[].obs;
  var pageSize = 5;
  var page = 1;
  var hasNextPage = false;

  // video detail
  var isDetailLoading = false.obs;
  var video = Rxn<VideoModel>();
  var firstComment = Rxn<CommentModel>();

  // create video
  final ImagePicker picker = ImagePicker();
  var pickedImage = Rxn<File>();
  var pickedVideo = Rxn<File>();
  var duration = Rxn<Duration>();
  var isLoadingCreate = false.obs;

  // edit video
  var isLoadingEdit = false.obs;

  Future<void> getVideos() async {
    if (page == 1) {
      if (isRefreshing.value == false) isLoading(true); 
    } else {
      isLoadingMore(true);
    }

    try {
      final BaseResponse<SearchResponse<VideoModel>> result = await VideoService.getVideos(page, pageSize);

      if (result.data != null) {
        var items = result.data!.items;
        for (var item in items) {
          videos.add(item);
        }

        hasNextPage = result.data!.hasNextPage;
      }
      
    } on ApiException catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      isLoading(false);
      isLoadingMore(false);
    }
  }

  Future<void> loadMore() async {
    if (isLoading.value == true || isLoadingMore.value == true) return;

    if (hasNextPage) {
      page++;
      await getVideos(); 
    }
  }

  Future<void> refreshData() async {
    page = 1;
    videos.clear();
    isRefreshing(true);

    await getVideos();

    isRefreshing(false);
  }

  Future<void> getVideoById(String id) async {
    isDetailLoading(true);

    try {
      final BaseResponse<VideoModel> result = await VideoService.getVideoById(id);

      video.value = result.data;
      if (video.value!.comments.isNotEmpty) {
        firstComment.value = video.value?.comments[0]; 
      }
    } on ApiException catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      isDetailLoading(false);
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final XFile? pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      final croppedImage = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Atur Gambar',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.ratio16x9,
            lockAspectRatio: true,
            aspectRatioPresets: [
              CropAspectRatioPreset.ratio16x9
            ]
          )
        ]
      );

      if (croppedImage != null) {
        pickedImage.value = File(croppedImage.path); 
      }
    }
  }

  Future<void> pickVideo(ImageSource source) async {
    final XFile? pickedFile = await picker.pickVideo(source: source);

    try {
      if (pickedFile != null) {
        pickedVideo.value = File(pickedFile.path);
      } 
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  void emptyFiles() {
    pickedImage.value = null;
    pickedVideo.value = null;
  }

  Future<void> createData(String title, String description, String duration) async {
    isLoadingCreate(true);

    try {
      final BaseResponse<VideoModel> result = await VideoService.createVideo(title, description, pickedImage.value, pickedVideo.value, duration);

      emptyFiles();
      
      Get.back();
      Fluttertoast.showToast(msg: result.messages[0]);
    } on ApiException catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      isLoadingCreate(false);
    }
  }

  Future<void> editData(
    String videoId,
    String title, 
    String description,
    String? image,
    String? video,
    String duration
  ) async {
    isLoadingEdit(true);

    try {
      final BaseResponse<VideoModel> result = await VideoService.editVideoById(
        videoId, 
        title, 
        description, 
        pickedImage.value,  // new image
        image,              // old image
        pickedVideo.value,  // new video
        video,              // old video
        duration
      );
        
      Fluttertoast.showToast(msg: result.messages[0]);

      pickedImage.value = null;
      pickedVideo.value = null;

      Get.back();
    } on ApiException catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      isLoadingEdit(false);
    }
  }

  Future<bool> deleteVideo(String id) async {
    isLoading(true);

    try {
      final response = await VideoService.deleteVideo(id);

      videos.value = videos.where((video) => video.id != id).toList();
      Fluttertoast.showToast(msg: response.messages[0]);

      return true;
    } on ApiException catch (e) {
      Fluttertoast.showToast(msg: e.toString());

      return false;
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      return false;
    } finally {
      isLoading(false);
    }
  }
}
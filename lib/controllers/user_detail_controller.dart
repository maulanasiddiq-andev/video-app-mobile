import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:video_app/exceptions/api_exception.dart';
import 'package:video_app/models/comment_model.dart';
import 'package:video_app/models/video_model.dart';
import 'package:video_app/services/user_service.dart';

class UserDetailController extends GetxController {
  late String userId;

  var isLoadingVideos = false.obs;
  var isLoadingMoreVideos = false.obs;
  var videosCount = 0.obs;
  var videos = <VideoModel>[].obs;
  int videosPageSize = 5;
  int videoPage = 1;
  bool videoHasNextPage = false;

  Future<void> getUserVideos(String id) async {
    userId = id;
    if (videoPage == 1) {
      isLoadingVideos(true);
    } else {
      isLoadingMoreVideos(true);
    }

    try {
      final result = await UserService.getUserVideos(id, videosPageSize, videoPage);

      if (result.data != null) {
        for (var item in result.data!.items) {
          videos.add(item);
        }

        videosCount.value = result.data!.totalItem;
        videoHasNextPage = result.data!.hasNextPage;
      }
    } on ApiException catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      isLoadingVideos(false);
      isLoadingMoreVideos(false);
    }
  }

  Future<void> refreshVideos() async {
    videoPage = 1;
    videos.clear();
    videosCount.value = 0;

    await getUserVideos(userId);
  }

  Future<void> loadMoreVideos() async {
    if (isLoadingVideos.value || isLoadingMoreVideos.value) return;

    videoPage++;
    await getUserVideos(userId);
  }
  
  var isLoadingComments = false.obs;
  var isLoadingMoreComments = false.obs;
  var commentsCount = 0.obs;
  var comments = <CommentModel>[].obs;
  int commentsPageSize = 5;
  int commentPage = 1;
  bool commentHasNextPage = false;

  Future<void> getUserComments(String id) async {
    userId = id;
    if (commentPage == 1) {
      isLoadingComments(true);
    } else {
      isLoadingMoreComments(true);
    }

    try {
      final result = await UserService.getUserComments(id, commentsPageSize, commentPage);

      if (result.data != null) {
        for (var item in result.data!.items) {
          comments.add(item);
        }

        commentsCount.value = result.data!.totalItem;
        commentHasNextPage = result.data!.hasNextPage;
      }
    } on ApiException catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      isLoadingComments(false);
      isLoadingMoreComments(false);
    }
  }

  Future<void> refreshComments() async {
    commentPage = 1;
    comments.clear();
    commentsCount.value = 0;

    await getUserComments(userId);
  }

  Future<void> loadMoreComments() async {
    if (isLoadingComments.value || isLoadingMoreComments.value) return;

    commentPage++;
    await getUserComments(userId);
  }
}
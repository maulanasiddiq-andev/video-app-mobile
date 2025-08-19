import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:video_app/exceptions/api_exception.dart';
import 'package:video_app/models/base_response.dart';
import 'package:video_app/models/comment_model.dart';
import 'package:video_app/models/search_response.dart';
import 'package:video_app/models/user_model.dart';
import 'package:video_app/models/video_model.dart';
import 'package:video_app/services/comment_service.dart';
import 'package:video_app/services/history_service.dart';
import 'package:video_app/services/video_service.dart';

class VideoDetailController extends GetxController {
  var isLoading = false.obs;
  var video = Rxn<VideoModel>();

  late String videoId;
  var isLoadingComment = false.obs;
  var isLoadingMoreComments = false.obs;
  var comments = <CommentModel>[].obs;
  int page = 1;
  int pageSize = 10;
  bool hasNextPage = false;

  var isLoadingCreateComment = false.obs;

  var editedComment = Rxn<CommentModel>();

  Future<void> getVideoById(String id) async {
    isLoading(true);

    try {
      final BaseResponse<VideoModel> result = await VideoService.getVideoById(id);

      video.value = result.data;
    } on ApiException catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> getComments(String id) async {
    videoId = id;

    if (page == 1) {
      isLoadingComment(true);
    } else {
      isLoadingMoreComments(true);
    }

    try {
      final BaseResponse<SearchResponse<CommentModel>> result = await CommentService.getComments(videoId, page, pageSize);        

      if (result.data !=  null) {
        var items = result.data!.items;
      
        for (var item in items) {
          comments.add(item);
        }

        hasNextPage = result.data!.hasNextPage;
      }
    } on ApiException catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      isLoadingComment(false);
      isLoadingMoreComments(false);
    }
  }

  Future<void> loadMoreComment() async {
    if (isLoadingComment.value == true || isLoadingMoreComments.value == true) return;

    if (hasNextPage) {
      page++;
      await getComments(videoId); 
    }
  }

  Future<void> createComment(String text, String videoId, UserModel user) async {
    isLoadingCreateComment(true);

    try {
      CommentModel newComment = CommentModel(
        id: "temporary", 
        text: text, 
        recordStatus: "active", 
        user: user, 
        userId: user.id, 
        videoId: videoId, 
        createdAt: DateTime.now(),
        isBeingEdited: true
      );
      comments.insert(0, newComment);

      var result = await CommentService.createComment(text, videoId);
      comments[0] = result.data!;
      Fluttertoast.showToast(msg: result.messages[0]);
    } on ApiException catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      isLoadingCreateComment(false);
    }
  }

  void assignCommentForEdit(CommentModel comment) {
    editedComment.value = comment;
  }

  Future<void> editComment(String text) async {
    try {
      // find the comment which will be edited
      final index = comments.indexWhere((comment) => comment.id == editedComment.value?.id);

      if (index != -1) {
        comments[index].isBeingEdited = true;
        comments[index].text = text;

        final result = await CommentService.editComment(editedComment.value!.id, text);
        comments[index] = result.data!;

        Fluttertoast.showToast(msg: result.messages[0]);
      }
    } on ApiException catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      // set the edited comment to null
      editedComment.value = null;
    }
  }

  Future<void> deleteComment(String id) async {
    try {
      var result = await CommentService.deleteComment(id);
      Fluttertoast.showToast(msg: result.messages[0]);

      comments.value = comments.where((comment) => comment.id != id).toList();
    } on ApiException catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future<void> createHistory(String videoId, String duration, String position) async {
    try {
      await HistoryService.createHistory(videoId, duration, position);
    } on ApiException catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  void emptyFiles() {
    video.value = null;
  }
}
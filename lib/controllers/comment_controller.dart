import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:video_app/exceptions/api_exception.dart';
import 'package:video_app/models/base_response.dart';
import 'package:video_app/models/comment_model.dart';
import 'package:video_app/models/search_response.dart';
import 'package:video_app/models/user_model.dart';
import 'package:video_app/services/comment_service.dart';

class CommentController extends GetxController {  
  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  var comments = <CommentModel>[].obs;
  var pageSize = 10;
  var page = 1;
  var hasNextPage = false;

  late String storedVideoId;

  var isLoadingCreate = false.obs;

  var editedComment = Rxn<CommentModel>();

  Future<void> getDatas(String videoId) async {
    storedVideoId = videoId;

    if (page == 1) {
      isLoading(true);
    } else {
      isLoadingMore(true);
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
      isLoading(false);
      isLoadingMore(false);
    }
  }

  Future<void> loadMore() async {
    if (isLoading.value == true || isLoadingMore.value == true) return;

    if (hasNextPage) {
      page++;
      await getDatas(storedVideoId); 
    }
  }

  Future<void> refreshData() async {
    page = 1;
    comments.clear();

    await getDatas(storedVideoId);
  }

  Future<void> createData(String text, String videoId, UserModel user) async {
    isLoadingCreate(true);

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
      isLoadingCreate(false);
    }
  }

  void assignCommentForEdit(CommentModel comment) {
    editedComment.value = comment;
  }

  Future<void> editData(String text) async {
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

  Future<void> deleteData(String id) async {
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
}
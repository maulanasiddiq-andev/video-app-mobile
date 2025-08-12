import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:video_app/exceptions/api_exception.dart';
import 'package:video_app/models/base_response.dart';
import 'package:video_app/models/history_model.dart';
import 'package:video_app/models/search_response.dart';
import 'package:video_app/services/history_service.dart';

class HistoryController extends GetxController {
  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  var isRefreshing = false.obs;
  var videos = <HistoryModel>[].obs;
  var pageSize = 5;
  var page = 1;
  var hasNextPage = false;

  Future<void> getHistories() async {
    if (page == 1) {
      if (isRefreshing.value == false) isLoading(true); 
    } else {
      isLoadingMore(true);
    }

    try {
      final BaseResponse<SearchResponse<HistoryModel>> result = await HistoryService.getHistories(page, pageSize);

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
      await getHistories(); 
    }
  }

  Future<void> refreshData() async {
    page = 1;
    videos.clear();
    isRefreshing(true);

    await getHistories();

    isRefreshing(false);
  }

  Future<void> createHistory(String videoId, String duration, String position) async {
    try {
      await HistoryService.createHistory(videoId, duration, position);
    } on ApiException catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future<void> editHistory(int videoId, String position) async {
    try {
      await HistoryService.editHistory(videoId, position);
    } on ApiException catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }
}
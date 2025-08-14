import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_app/components/video_component.dart';
import 'package:video_app/controllers/video_controller.dart';
import 'package:video_app/pages/user/user_detail_page.dart';
import 'package:video_app/pages/videos/video_create_page.dart';

class VideoListPage extends StatefulWidget {
  const VideoListPage({super.key});

  @override
  State<VideoListPage> createState() => _VideoListPageState();
}

class _VideoListPageState extends State<VideoListPage> {
  final VideoController videoController = Get.find<VideoController>();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    videoController.getVideos();

    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 50) {
        videoController.loadMore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("Video App", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.search, color: Colors.white),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => videoController.refreshData(),
        child: Obx(() {
          if (videoController.isLoading.value == true) {
            return Center(child: CircularProgressIndicator());
          }

          var videos = videoController.videos;

          return SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsetsGeometry.symmetric(vertical: 10),
                  child: GestureDetector(
                    onTap: () {
                      Get.to(() => VideoCreatePage());
                    },
                    child: Row(
                      spacing: 10,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: Colors.blue),
                        Text(
                          'Buat video',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                ...videos.map((video) {
                  return VideoComponent(
                    video: video,
                    goToDetail: () => Get.to(() => UserDetailPage(user: video.user!)),  
                  );
                }),
                Obx(() {
                  var isLoadingMore = videoController.isLoadingMore.value;

                  return isLoadingMore ?
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Center(child: CircularProgressIndicator()),
                    ) :
                    SizedBox();
                })
              ],
            ),
          );
        }),
      ),
    );
  }
}

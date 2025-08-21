import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_app/components/video_item_component.dart';
import 'package:video_app/controllers/video_detail_controller.dart';

class SuggestedVideosContainer extends StatelessWidget {
  SuggestedVideosContainer({super.key});

  final VideoDetailController videoDetailController = Get.find<VideoDetailController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 15),
      child: Obx(() {
        if (videoDetailController.isLoadingSuggestedVideos.value) {
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Column(
              spacing: 10,
              children: [
                Container(
                  width: double.infinity,
                  color: Colors.grey,
                  child: AspectRatio(aspectRatio: 16 / 9),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 10,
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.grey,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          spacing: 10,
                          children: [
                            Container(height: 16, color: Colors.grey),
                            Container(height: 16, color: Colors.grey),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            ...videoDetailController.suggestedVideos.map((video) {
              return VideoItemComponent(video: video, goToDetail: () {});
            }),
          ],
        );
      }),
    );
  }
}

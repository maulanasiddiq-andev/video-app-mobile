import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_app/controllers/profile_controller.dart';
import 'package:video_app/controllers/video_controller.dart';
import 'package:video_app/models/video_model.dart';
import 'package:video_app/pages/videos/video_edit_page.dart';

class VideoOptionBottomSheet extends StatelessWidget {
  final VideoModel video;

  VideoOptionBottomSheet({super.key, required this.video});

  final VideoController  videoController = Get.find<VideoController>();
  final ProfileController profileController = Get.find<ProfileController>();

  void openConfirmDelete() async {
    final result = await Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
          child: Wrap(
            children: [
              Text.rich(
                TextSpan(
                  style: TextStyle(
                    fontSize: 15
                  ),
                  children: [
                    TextSpan(
                      text: 'Apakah anda yakin ingin menghapus video "',
                    ),
                    TextSpan(
                      text: video.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold
                      )
                    ),
                    TextSpan(
                      text: '"?'
                    )
                  ]
                )
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Get.back(result: true);
                    }, 
                    child: Text(
                      'Ya',
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    )
                  ),
                  TextButton(
                    onPressed: () {
                      Get.back(result: false);
                    }, 
                    child: Text(
                      'Batal',
                      style: TextStyle(
                        color: Colors.red
                      ),
                    )
                  ),
                ],
              )
            ],
          ),
        ),
      )
    );

    if (result == true) {
      videoController.deleteVideo(video.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Wrap(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            child: Center(child: Text('Pilihan')),
          ),
          Divider(thickness: 1, color: Colors.black, height: 1),
          Column(
            children: [
              Obx(() {
                var user = profileController.user.value;

                return user != null && user.id == video.userId 
                  ? Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              Navigator.pop(context);
                              Get.to(() => VideoEditPage(video: video));
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                spacing: 10,
                                children: [
                                  Icon(Icons.edit),
                                  Text('Edit video')
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              Navigator.pop(context);
                              openConfirmDelete();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                spacing: 10,
                                children: [
                                  Icon(Icons.delete),
                                  Text('Hapus video')
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ) 
                    : SizedBox();
              }),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  spacing: 10,
                  children: [
                    Icon(Icons.timelapse),
                    Text('Tonton nanti')
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_app/components/bottom_sheet_component.dart';
import 'package:video_app/components/profile_image_component.dart';
import 'package:video_app/constants/env.dart';
import 'package:video_app/controllers/profile_controller.dart';
import 'package:video_app/controllers/video_controller.dart';
import 'package:video_app/models/video_model.dart';
import 'package:video_app/pages/videos/video_detail_page.dart';
import 'package:video_app/pages/videos/video_edit_page.dart';
import 'package:video_app/utils/convert_duration.dart';

class VideoItemComponent extends StatefulWidget {
  final VideoModel video;
  final Function goToDetail;

  const VideoItemComponent({
    super.key,
    required this.video,
    required this.goToDetail,
  });

  @override
  State<VideoItemComponent> createState() => _VideoItemComponentState();
}

class _VideoItemComponentState extends State<VideoItemComponent> {
  final VideoController videoController = Get.find<VideoController>();
  final ProfileController profileController = Get.find<ProfileController>();
  final String uri = ApiPoint.baseUrl;
  late final bool imageExist;
  late final Duration duration;
  late final Duration position;
  late final String name;
  late final int viewCount;
  late final String viewText;

  @override
  void initState() {
    super.initState();

    imageExist = widget.video.image != null;

    var history = widget.video.history;
    duration = convertStringToDuration(widget.video.duration);
    position = convertStringToDuration(history?.position);

    name = widget.video.user!.name;

    viewCount = widget.video.historiesCount ?? 0;
    viewText = viewCount > 0 ? 'views' : 'view';
  }

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
                      text: widget.video.title,
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
      videoController.deleteVideo(widget.video.id);
    }
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => BottomSheetComponent(
        menus: [
          BottomSheetMenuModel(
            icon: Icons.edit, 
            onTap: () {
              Get.to(() => VideoEditPage(video: widget.video));
            }, 
            title: "Edit video",
            isVisible: widget.video.userId == profileController.user.value?.id
          ),
          BottomSheetMenuModel(
            icon: Icons.delete, 
            onTap: () {
              openConfirmDelete();
            }, 
            title: "Hapus video",
            isVisible: widget.video.userId == profileController.user.value?.id
          ),
          BottomSheetMenuModel(
            icon: Icons.timelapse, 
            onTap: () {}, 
            title: "Tonton nanti",
          ),
        ]
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => VideoDetailPage(video: widget.video));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.grey[100]),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                children: [
                  Center(
                    child: imageExist
                        ? Image(
                            image: NetworkImage('$uri${widget.video.image!}'),
                          )
                        : Image(image: AssetImage('assets/images/mobil.jfif')),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: SizedBox()),
                            Container(
                              padding: EdgeInsetsDirectional.all(5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                color: Colors.black,
                              ),
                              margin: EdgeInsets.only(right: 5, bottom: 5),
                              child: Text(
                                (widget.video.duration?.isNotEmpty ?? false)
                                    ? widget.video.duration!
                                    : '00:00',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          height: 5,
                          width:
                              (position.inMicroseconds /
                                      duration.inMicroseconds)
                                  .isNaN
                              ? 0
                              : MediaQuery.of(context).size.width *
                                    (position.inMicroseconds /
                                        duration.inMicroseconds),
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                GestureDetector(
                  onTap: () => widget.goToDetail(),
                  child: ProfileImageComponent(
                    profileImage: widget.video.user?.profileImage,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.video.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('$name | $viewCount $viewText'),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _showOptions(context);
                  },
                  child: Icon(Icons.more_vert),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

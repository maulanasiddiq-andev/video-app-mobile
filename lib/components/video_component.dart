import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_app/components/video_option_bottom_sheet.dart';
import 'package:video_app/constants/env.dart';
import 'package:video_app/models/video_model.dart';
import 'package:video_app/pages/videos/video_detail_page.dart';
import 'package:video_app/utils/convert_duration.dart';

class VideoComponent extends StatefulWidget {
  final VideoModel video;

  const VideoComponent({super.key, required this.video});

  @override
  State<VideoComponent> createState() => _VideoComponentState();
}

class _VideoComponentState extends State<VideoComponent> {
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

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context, 
      builder: (context) => VideoOptionBottomSheet(video: widget.video)
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
            decoration: BoxDecoration(
              color: Colors.grey[100]
            ),
            child: AspectRatio(
              aspectRatio: 16/9,
              child: Stack(
                children: [
                  Center(
                    child: imageExist ? 
                      Image(image: NetworkImage('$uri${widget.video.image!}')) :
                      Image(image: AssetImage('assets/images/mobil.jfif')),
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
                                color: Colors.black
                              ),
                              margin: EdgeInsets.only(right: 5, bottom: 5),
                              child: Text(
                                (widget.video.duration?.isNotEmpty ?? false) ? widget.video.duration! : '00:00',
                                style: TextStyle(
                                  color: Colors.white
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          height: 5,
                          width: (position.inMicroseconds / duration.inMicroseconds).isNaN
                            ? 0
                            : MediaQuery.of(context).size.width * (position.inMicroseconds / duration.inMicroseconds),
                          color: Colors.red,
                        )
                      ],
                    )
                  )
                ],
              )
            )
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundImage: widget.video.user?.profileImage == null
                    ? AssetImage('assets/images/profile.png')
                    : NetworkImage('$uri${widget.video.user!.profileImage}'),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.video.title,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                )
              ],
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

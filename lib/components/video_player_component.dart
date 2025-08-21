import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:video_app/constants/env.dart';
import 'package:video_app/controllers/video_detail_controller.dart';
import 'package:video_app/models/history_model.dart';
import 'package:video_app/utils/convert_duration.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerComponent extends StatefulWidget {
  final String videoId;
  final String? duration;
  final String? video;
  final HistoryModel? history;

  const VideoPlayerComponent({
    super.key,
    required this.videoId,
    this.duration,
    this.video,
    this.history
  });

  @override
  State<VideoPlayerComponent> createState() => _VideoPlayerComponentState();
}

class _VideoPlayerComponentState extends State<VideoPlayerComponent> with SingleTickerProviderStateMixin {
  final VideoDetailController videoDetailController = Get.find<VideoDetailController>();
  static int maxFadingSecond = 4;
  
  VideoPlayerController? videoPlayerController;
  final String baseUri = ApiPoint.baseUrl;

  late AnimationController fadingController;
  late Animation<double> fadingAnimation;
  bool isVideoOptionVisible = false;
  Timer? fadingTimer;
  int fadingSecond = maxFadingSecond;

  @override
  void initState() {
    super.initState();

    fadingController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200)
    );
    fadingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(fadingController);

    initVideo();
  }

  @override
  void dispose() {
    final position = videoPlayerController?.value.position;
    saveHistory(position);
    videoPlayerController?.dispose();
    
    fadingTimer?.cancel();

    super.dispose();
  }

  Future<void> initVideo() async {
    if (widget.video != null) {
      final uri = Uri.parse(baseUri + widget.video!);
      videoPlayerController = VideoPlayerController.networkUrl(uri);

      try {
        await videoPlayerController?.initialize();

        setState(() {
          if (widget.history != null) {
            // if the user has watched the video before
            Duration position = convertStringToDuration(widget.history?.position);

            videoPlayerController?.seekTo(position);
            videoPlayerController?.play();
          } else {
            // the user has not watched the video
            videoPlayerController?.play();
          }
        }); 

        videoPlayerController?.addListener(() {
          setState(() {});
        });
      } catch (e) {
        Fluttertoast.showToast(msg: e.toString());
        Get.back();
      }
    }
  }

  void saveHistory(Duration? position) {
    var convertedPosition = convertDurationToString(position);

    if (convertedPosition != "00:00") {
      videoDetailController.createHistory(widget.videoId, widget.duration!, convertedPosition);
    }
  }

  void fadeVideoOptionIn() async {
    fadingController.forward();
    
    setState(() {
      isVideoOptionVisible = true;
    });
  }

  void fadeVideoOptionOut() {
    fadingController.reverse();

    setState(() {
      isVideoOptionVisible = false;
    });
  }

  void startFadingTimer() {
    fadeVideoOptionIn();
    fadingTimer = Timer.periodic(Duration(seconds: 1), (_) {
      if (fadingSecond > 0) {
        setState(() => fadingSecond--);
      } else {
        fadingTimer?.cancel();
        fadeVideoOptionOut();
      }
    });
  }

  void restartFadingTimer() {
    fadingTimer?.cancel();
    setState(() => fadingSecond = maxFadingSecond);
    startFadingTimer();
  }

  void stopFadingTimer() {
    fadingTimer?.cancel();
    setState(() => fadingSecond = 0);
    fadeVideoOptionOut();
  }

  @override
  Widget build(BuildContext context) {
    return videoPlayerController != null && videoPlayerController!.value.isInitialized 
    ? Stack(
        children: [
          GestureDetector(
            onTap: () {
              if (fadingTimer == null) {
                startFadingTimer();
              } else {
                restartFadingTimer();
              }
            },
            child: SizedBox(
              width: double.infinity,
              child: Center(
                child: AspectRatio(
                  aspectRatio: videoPlayerController!.value.aspectRatio,
                  child: VideoPlayer(videoPlayerController!),
                ),
              ),
            ),
          ),
          isVideoOptionVisible == true
          ? Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  stopFadingTimer();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(100)
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                if (videoPlayerController!.value.isPlaying) {
                                  videoPlayerController!.pause();
                                } else {
                                  videoPlayerController!.play();
                                }
                              });
                            },
                            child: videoPlayerController!.value.isPlaying 
                            ? Icon(
                                Icons.pause, 
                                size: 65, 
                                color: Colors.white
                              ) 
                            : Icon(
                                Icons.play_arrow, 
                                size: 65, 
                                color: Colors.white
                              ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                        child: Row(
                          spacing: 10,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              convertDurationToString(videoPlayerController!.value.position),
                              style: TextStyle(
                                color: Colors.white
                              ),  
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  VideoProgressIndicator(videoPlayerController!, allowScrubbing: true),
                                  SizedBox(height: 4)
                                ],
                              )
                            ),
                            Text(
                              convertDurationToString(videoPlayerController!.value.duration),
                              style: TextStyle(
                                color: Colors.white
                              ),  
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )
            )
          : SizedBox()
        ]
      ) 
    : Center(
        child: CircularProgressIndicator(color: Colors.blue)
      );
  }
}
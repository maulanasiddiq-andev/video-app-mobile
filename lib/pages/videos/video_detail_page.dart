import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_app/components/comment_container_component.dart';
import 'package:video_app/constants/env.dart';
import 'package:video_app/controllers/comment_controller.dart';
import 'package:video_app/controllers/history_controller.dart';
import 'package:video_app/controllers/video_controller.dart';
import 'package:video_app/models/comment_model.dart';
import 'package:video_app/models/video_model.dart';
import 'package:video_app/utils/convert_duration.dart';
import 'package:video_app/utils/format_date.dart';
import 'package:video_player/video_player.dart';

class VideoDetailPage extends StatefulWidget {
  final VideoModel video;

  const VideoDetailPage({super.key, required this.video});

  @override
  State<VideoDetailPage> createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage> with SingleTickerProviderStateMixin {
  static int maxFadingSecond = 4;

  final VideoController videoController = Get.find<VideoController>();
  final HistoryController historyController = Get.find<HistoryController>();
  final CommentController commentController = Get.find<CommentController>();

  VideoPlayerController? videoPlayerController;

  late AnimationController fadingController;
  late Animation<double> fadingAnimation;
  bool isVideoOptionVisible = false;
  Timer? fadingTimer;
  int fadingSecond = maxFadingSecond;

  final baseUri = ApiPoint.baseUrl;

  bool isCommentShowed = false;

  late final String formattedDate;

  @override
  void initState() {
    super.initState();

    formattedDate = formatDate(widget.video.createdAt);

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
    videoController.emptyFiles();

    super.dispose();
  }

  Future<void> initVideo() async {
    await videoController.getVideoById(widget.video.id);
    var video = videoController.video.value;

    if (widget.video.video != null) {
      final uri = Uri.parse(baseUri + widget.video.video!);
      videoPlayerController = VideoPlayerController.networkUrl(uri);

      try {
        await videoPlayerController?.initialize();

        setState(() {
          if (video != null && video.history != null) {
            // if the user has watched the video before
            Duration position = convertStringToDuration(video.history?.position);

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

  void saveHistory(Duration? position) {
    var convertedPosition = convertDurationToString(position);

    if (convertedPosition != "00:00") {
      historyController.createHistory(widget.video.id, widget.video.duration!, convertedPosition);
    }
  }

  void toggleShowComments(BuildContext context) {
    if (commentController.comments.isEmpty) {
      commentController.getDatas(widget.video.id);
    }
    
    setState(() {
      isCommentShowed = !isCommentShowed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final videoHeight = (MediaQuery.of(context).size.width / 16) * 9;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final systemBottomHeight = MediaQuery.of(context).padding.bottom;
    final commentBoxHeight = screenHeight - videoHeight - statusBarHeight - systemBottomHeight;

    return PopScope(
      canPop: !isCommentShowed,
      onPopInvokedWithResult: (didPop, result) {
        if (isCommentShowed == true) toggleShowComments(context);
      },
      child: Scaffold(
        body: Padding(
          padding: EdgeInsetsGeometry.only(top: statusBarHeight),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                color: Colors.grey[100],
                child: AspectRatio(
                  aspectRatio: 16/9,
                  child: Obx(() {
                    var isLoading = videoController.isDetailLoading.value;
          
                    if (isLoading) {
                      return Center(
                        child: CircularProgressIndicator(color: Colors.blue),
                      );
                    }
          
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
                  }) 
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Obx(() {
                              var isLoading = videoController.isDetailLoading.value;
                                  
                              if (isLoading) {
                                return Shimmer.fromColors(
                                  baseColor: Colors.grey.shade300, 
                                  highlightColor: Colors.grey.shade100,
                                  child: Column(
                                    spacing: 10,
                                    children: [
                                      Container(
                                        height: 25,
                                        color: Colors.grey,
                                      ),
                                      Container(
                                        height: 13,
                                        color: Colors.grey,
                                      ),
                                      Container(
                                        height: 20,
                                        color: Colors.grey,
                                      ),
                                      Container(
                                        height: 70,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          color: Colors.grey
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              }
                    
                              var count = widget.video.historiesCount;
                              var viewText = count > 1 ? 'views' : 'view';
                                  
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 10,
                                children: [
                                  Text(
                                    widget.video.title,
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                  Row(
                                    spacing: 10,
                                    children: [
                                      Text('$count $viewText'), 
                                      Text(formattedDate)
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(15),
                                          color: Colors.grey[200],
                                        ),
                                        child: Row(
                                          spacing: 5,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.only(right: 5),
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  right: BorderSide(color: Colors.black),
                                                ),
                                              ),
                                              child: Row(
                                                spacing: 5,
                                                children: [
                                                  Icon(Icons.thumb_up, size: 15),
                                                  Text('200'),
                                                ],
                                              ),
                                            ),
                                            Icon(Icons.thumb_down, size: 15),
                                            Text('100'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    spacing: 10,
                                    children: [
                                      CircleAvatar(
                                        radius: 15,
                                        backgroundImage: AssetImage('assets/images/profile.png'),
                                      ),
                                      Text(widget.video.user!.name),
                                      Expanded(
                                        child: Text(
                                          'Follow',
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () => toggleShowComments(context),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      width: double.infinity,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        spacing: 5,
                                        children: [
                                          Text(
                                            'Comments (${widget.video.commentsCount})',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Obx(() {
                                            CommentModel? comment =
                                                videoController.firstComment.value;
                                    
                                            if (comment != null) {
                                              return Row(
                                                spacing: 10,
                                                children: [
                                                  CircleAvatar(
                                                    radius: 15,
                                                    backgroundImage: AssetImage(
                                                      'assets/images/profile.png',
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      comment.text,
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }
                                    
                                            return SizedBox();
                                          }),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                    AnimatedPositioned(
                      duration: Duration(milliseconds: 200),
                      top: isCommentShowed ? 0 : commentBoxHeight,
                      child: CommentContainerComponent(
                        height: commentBoxHeight, 
                        width: MediaQuery.of(context).size.width, 
                        bottomInset: MediaQuery.of(context).viewInsets.bottom + 10,
                        video: widget.video
                      ), 
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

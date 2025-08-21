import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_app/components/comment_container_component.dart';
import 'package:video_app/components/profile_image_component.dart';
import 'package:video_app/components/video_player_component.dart';
import 'package:video_app/controllers/video_detail_controller.dart';
import 'package:video_app/models/comment_model.dart';
import 'package:video_app/models/video_model.dart';
import 'package:video_app/utils/format_date.dart';

class VideoDetailPage extends StatefulWidget {
  final VideoModel video;

  const VideoDetailPage({super.key, required this.video});

  @override
  State<VideoDetailPage> createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage> with SingleTickerProviderStateMixin {
  final VideoDetailController videoDetailController = Get.find<VideoDetailController>();
  bool isCommentShowed = false;

  @override
  void initState() {
    super.initState();

    videoDetailController.getLatestComment(widget.video.id);
  }

  void toggleShowComments(BuildContext context) {
    if (videoDetailController.comments.isEmpty) {
      videoDetailController.getComments(widget.video.id);
    }
    
    setState(() {
      isCommentShowed = !isCommentShowed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate = formatDate(widget.video.createdAt);

    final screenHeight = MediaQuery.of(context).size.height;
    final videoHeight = (MediaQuery.of(context).size.width / 16) * 9;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final systemBottomHeight = MediaQuery.of(context).padding.bottom;
    final commentBoxHeight = screenHeight - videoHeight - statusBarHeight - systemBottomHeight;

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.blue,
      statusBarIconBrightness: Brightness.light
    ));

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
                    var isLoading = videoDetailController.isLoading.value;
          
                    if (isLoading) {
                      return Center(
                        child: CircularProgressIndicator(color: Colors.blue),
                      );
                    }
          
                    return VideoPlayerComponent(
                      videoId: widget.video.id,
                      duration: widget.video.duration,
                      history: widget.video.history,
                      video: widget.video.video,
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
                              var isLoading = videoDetailController.isLoadingLatestComment.value;
                                  
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
                    
                              var count = widget.video.historiesCount ?? 0;
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
                                      ProfileImageComponent(
                                        profileImage: widget.video.user?.profileImage,
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
                                            CommentModel? comment = videoDetailController.latestComment.value;
                                    
                                            if (comment != null) {
                                              return Row(
                                                spacing: 10,
                                                children: [
                                                  ProfileImageComponent(
                                                    profileImage: comment.user.profileImage,
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

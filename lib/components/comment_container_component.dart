import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_app/components/comment_item_component.dart';
import 'package:video_app/controllers/profile_controller.dart';
import 'package:video_app/controllers/video_detail_controller.dart';
import 'package:video_app/models/video_model.dart';

class CommentContainerComponent extends StatefulWidget {
  final double height;
  final double width;
  final double bottomInset;
  final VideoModel video;

  const CommentContainerComponent({
    super.key,
    required this.height,
    required this.width,
    required this.video,
    required this.bottomInset
  });

  @override
  State<CommentContainerComponent> createState() => _CommentContainerComponentState();
}

class _CommentContainerComponentState extends State<CommentContainerComponent> {
  final VideoDetailController videoDetailController = Get.find<VideoDetailController>();
  final ProfileController profileController = Get.find<ProfileController>();
  
  final ScrollController scrollController = ScrollController();
  final TextEditingController commentFieldController = TextEditingController();
  final FocusNode commentNode = FocusNode();

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 10) {
        videoDetailController.loadMoreComment();
      }
    });
  }

  void onSubmitComment() {
    var text = commentFieldController.text;
    if (text.isEmpty) return;

    if (videoDetailController.editedComment.value == null) {
      videoDetailController.createComment(text, widget.video.id, profileController.user.value!);
    } else {
      videoDetailController.editComment(text);
    }

    commentNode.unfocus();
    commentFieldController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10), 
          topRight: Radius.circular(10)
        )
      ),
      child: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (videoDetailController.isLoadingComment.value) {
                return Center(
                  child: CircularProgressIndicator(color: Colors.blue),
                ); 
              }
            
              return ListView.builder(
                padding: EdgeInsets.only(top: 15),
                controller: scrollController,
                itemCount: videoDetailController.comments.length + 1,
                itemBuilder: (context, index) {
                  if (index < videoDetailController.comments.length) {
                    var comment = videoDetailController.comments[index];
                
                    return CommentItemComponent(
                      comment: comment,
                      onDelete: () {
                        videoDetailController.deleteComment(comment.id);
                      },
                      onEdit: () {
                        commentFieldController.text = comment.text;
                        videoDetailController.assignCommentForEdit(comment);
                        FocusScope.of(context).requestFocus(commentNode);
                      },
                    );
                  }
                  
                  return  videoDetailController.isLoadingMoreComments.value
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Center(
                          child: CircularProgressIndicator(color: Colors.blue),
                        ),
                      )
                    : SizedBox();
                }
              );
            })
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
              10, 
              10, 
              10, 
              widget.bottomInset
            ),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.black,
                  width: 1
                )
              ),
              color: Colors.white
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    controller: commentFieldController,
                    focusNode: commentNode,
                    minLines: 1,
                    maxLines: 4,
                    onChanged: (value) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Tulis komentar anda',
                      isDense: true
                    ),
                  ),
                ),
                Obx(() {
                  return videoDetailController.isLoadingCreateComment.value
                    ? SizedBox(
                        height: 15,
                        width: 15,
                        child: Center(
                          child: CircularProgressIndicator(color: Colors.blue, strokeWidth: 3),
                        ),
                      )
                    : GestureDetector(
                        onTap: () {
                          onSubmitComment();
                        },
                        child: Icon(Icons.send, color: Colors.blue)
                      );
                }),
              ],
            ),
          )
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_app/components/comment_item_component.dart';
import 'package:video_app/controllers/comment_controller.dart';
import 'package:video_app/controllers/profile_controller.dart';
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
  final CommentController commentController = Get.find<CommentController>();
  final ProfileController profileController = Get.find<ProfileController>();
  final ScrollController scrollController = ScrollController();
  final TextEditingController commentFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
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
              if (commentController.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(color: Colors.blue),
                ); 
              }
            
              return ListView.builder(
                padding: EdgeInsets.only(top: 15),
                controller: scrollController,
                itemCount: commentController.comments.length + 1,
                itemBuilder: (context, index) {
                  if (index < commentController.comments.length) {
                    var comment = commentController.comments[index];
                
                    return CommentItemComponent(
                      comment: comment,
                      onDelete: () {
                        commentController.deleteData(comment.id);
                      },
                    );
                  }
                  
                  return 
                  commentController.isLoadingMore.value
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.blue),
                      ),
                    )
                  : 
                  SizedBox();
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
              )
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    controller: commentFieldController,
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
                GestureDetector(
                  onTap: () {
                    var text = commentFieldController.text;
                    if (text.isNotEmpty) {
                      FocusScope.of(context).unfocus();
                      commentController.createData(text, widget.video.id, profileController.user.value!);
                      commentFieldController.clear();
                    }
                  },
                  child: Obx(() {
                    return commentController.isLoadingCreate.value
                      ? SizedBox(
                          height: 15,
                          width: 15,
                          child: Center(
                            child: CircularProgressIndicator(color: Colors.blue, strokeWidth: 3),
                          ),
                        )
                      : Icon(Icons.send, color: Colors.blue);
                  })
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
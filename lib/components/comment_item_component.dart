import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_app/constants/env.dart';
import 'package:video_app/controllers/profile_controller.dart';
import 'package:video_app/models/comment_model.dart';
import 'package:video_app/utils/format_date.dart';

class CommentItemComponent extends StatelessWidget {
  final ProfileController profileController = Get.find<ProfileController>();

  final CommentModel comment;
  final Function? onDelete;
  final Function? onEdit;
  CommentItemComponent({super.key, required this.comment, this.onDelete, this.onEdit});

  final String baseUrl = ApiPoint.baseUrl;

  void showBottomSheetOption(BuildContext context) {
    showModalBottomSheet(
      context: context, 
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5)
          ),
          child: Wrap(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Get.back();
                  if (onDelete != null) onDelete!();
                },
                child: Padding(
                  padding: EdgeInsetsGeometry.symmetric(vertical: 5, horizontal: 10),
                  child: Row(
                    spacing: 10,
                    children: [
                      Icon(Icons.delete),
                      Text('Hapus')
                    ],
                  ),  
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Get.back();
                  if (onEdit != null) onEdit!();
                },
                child: Padding(
                  padding: EdgeInsetsGeometry.symmetric(vertical: 5, horizontal: 10),
                  child: Row(
                    spacing: 10,
                    children: [
                      Icon(Icons.edit),
                      Text('Edit')
                    ],
                  ),  
                ),
              )
            ],
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = formatDate(comment.createdAt);

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
      child: Row(
          spacing: 10,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 15,
              backgroundImage: comment.user.profileImage != null
                ? NetworkImage('$baseUrl${comment.user.profileImage}')
                : AssetImage('assets/images/profile.png',),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${comment.user.name} - $formattedDate',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600]
                    ),  
                  ),
                  Text(comment.text),
                  SizedBox(height: 5),
                  Row(
                    spacing: 10,
                    children: [
                      Icon(Icons.thumb_up, size: 15),
                      Icon(Icons.thumb_down, size: 15)
                    ],
                  )
                ],
              ),
            ),
            comment.isBeingEdited 
              ? Center(
                  child: SizedBox(
                    height: 15,
                    width: 15,
                    child: CircularProgressIndicator(
                      color: Colors.blue, 
                      strokeWidth: 3
                    ),
                  ),
                )
              : profileController.user.value!.id == comment.userId
                ? GestureDetector(
                    onTap: () {
                      showBottomSheetOption(context);
                    }, 
                    child: Icon(Icons.more_vert)
                  )
                : SizedBox()
          ],
        ),
    ); 
  }
}
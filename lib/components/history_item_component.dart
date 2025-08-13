import 'package:flutter/material.dart';
import 'package:video_app/models/history_model.dart';
import 'package:video_app/utils/format_date.dart';

class HistoryItemComponent extends StatelessWidget {
  final HistoryModel history;
  final double videoImageWidth;
  final String baseUrl;

  const HistoryItemComponent({
    super.key,
    required this.history,
    required this.videoImageWidth,
    required this.baseUrl
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          spacing: 10,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadiusGeometry.circular(10),
              child: SizedBox(
                width: videoImageWidth,
                child: AspectRatio(
                  aspectRatio: 16/9,
                  child: Stack(
                    children: [
                      Image(
                        image: NetworkImage('$baseUrl${history.video?.image}'),
                        fit: BoxFit.fill,  
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    history.video?.title ?? 'Judul',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  Text(
                    history.video?.user?.name ?? 'User',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey[600]
                    ),
                  ),
                  Text(
                    formatDate(history.video?.createdAt ?? DateTime.now()),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey[600]
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
        SizedBox(height: 15)
      ],
    );
  }
}
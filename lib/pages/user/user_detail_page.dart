import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_app/components/comment_item_component.dart';
import 'package:video_app/components/profile_image_component.dart';
import 'package:video_app/components/video_component.dart';
import 'package:video_app/controllers/user_detail_controller.dart';
import 'package:video_app/models/user_model.dart';

class UserDetailPage extends StatefulWidget {
  final UserModel user;
  const UserDetailPage({
    super.key,
    required this.user
  });

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> with SingleTickerProviderStateMixin {
  final UserDetailController userDetailController = Get.find<UserDetailController>();
  final ScrollController videoScrollController = ScrollController();
  final ScrollController commentScrollController = ScrollController();
  late TabController tabController;

  @override
  void initState() {
    super.initState();

    videoScrollController.addListener(() {
      if (videoScrollController.position.pixels >= videoScrollController.position.maxScrollExtent - 50) {
        userDetailController.loadMoreVideos();
      }
    });

    commentScrollController.addListener(() {
      if (commentScrollController.position.pixels >= commentScrollController.position.maxScrollExtent - 10) {
        userDetailController.loadMoreComments();
      }
    });

    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      if (!tabController.indexIsChanging && tabController.index == 1) {
        getUserComments();
      }
    });

    userDetailController.getUserVideos(widget.user.id);
  }

  void getUserComments() {
    if (userDetailController.comments.isEmpty) {
      userDetailController.getUserComments(widget.user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.user.name,
          style: TextStyle(
            color: Colors.white
          ),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () => userDetailController.refreshVideos(),
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBosIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    spacing: 15,
                    children: [
                      ProfileImageComponent(
                        profileImage: widget.user.profileImage,
                        radius: 40,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.user.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          Obx(() {
                            var count = userDetailController.videosCount;
                            return Text("$count video");
                          })
                        ],
                      )
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: tabController,
                    indicatorColor: Colors.blue,
                    labelColor: Colors.blue,
                    unselectedLabelColor: Colors.black,
                    tabs: [
                      Tab(text: "Video"),
                      Tab(text: "Komentar"),
                    ]
                  )
                )
              )
            ];
          }, 
          body: TabBarView(
            controller: tabController,
            children: [
              Obx(() {
                if (userDetailController.isLoadingVideos.value) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Colors.blue,
                    ),
                  );
                }

                if (userDetailController.videos.isEmpty) {
                  return Center(
                    child: Text('Belum ada video'),
                  );
                }
        
                return ListView.builder(
                  controller: videoScrollController,
                  itemCount: userDetailController.videos.length,
                  itemBuilder: (context, index) {
                    var video = userDetailController.videos[index];
        
                    return VideoComponent(
                      video: video, 
                      goToDetail: () {}
                    );
                  }
                );
              }),
              Obx(() {
                if (userDetailController.isLoadingComments.value) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Colors.blue,
                    ),
                  );
                }

                if (userDetailController.comments.isEmpty) {
                  return Center(
                    child: Text('Belum ada comment'),
                  );
                }
        
                return ListView.builder(
                  padding: EdgeInsets.only(top: 10),
                  controller: commentScrollController,
                  itemCount: userDetailController.comments.length,
                  itemBuilder: (context, index) {
                    var comment = userDetailController.comments[index];
        
                    return CommentItemComponent(comment: comment);
                  }
                );
              }),
            ]
          )
        ),
      )
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _SliverAppBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
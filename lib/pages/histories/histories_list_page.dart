import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:video_app/components/history_item_component.dart';
import 'package:video_app/constants/env.dart';
import 'package:video_app/controllers/history_controller.dart';

class HistoriesListPage extends StatefulWidget {
  const HistoriesListPage({super.key});

  @override
  State<HistoriesListPage> createState() => _HistoriesListPageState();
}

class _HistoriesListPageState extends State<HistoriesListPage> {
  final HistoryController historyController = Get.find<HistoryController>();
  final ScrollController scrollController = ScrollController();
  final baseUrl = ApiPoint.baseUrl;

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 50) {
        historyController.loadMore();
      }
    });

    initHistoriesList();
  }

  void initHistoriesList() {
    historyController.getHistories();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var videoImageWidth = screenWidth / 2 - 20;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Riwayat Tontonan',
          style: TextStyle(
            color: Colors.white
          ),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () => historyController.refreshData(),
        child: Obx(() {
          if (historyController.isLoading.value) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            );
          }

          var histories = historyController.historiesByDate;

          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: Obx(() {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ...histories.asMap().entries.map((value) {

                    //   var history = value.value;

                    //   return HistoryItemComponent(
                    //     history: history, 
                    //     videoImageWidth: videoImageWidth, 
                    //     baseUrl: baseUrl
                    //   );
                    // })
                    for (final dateKey in histories.value!.keys) ...[
                      Text(
                        dateKey,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      SizedBox(height: 10),
                      ...histories.value![dateKey]!.map((history) {
                        return Slidable(
                          endActionPane: ActionPane(
                            motion: StretchMotion(), 
                            children: [
                              SlidableAction(
                                onPressed: (context) {
                                  historyController.deleteData(history);
                                },
                                backgroundColor: Colors.red,
                                icon: Icons.delete,
                                label: 'Hapus',
                              )
                            ]
                          ),
                          child: HistoryItemComponent(
                            history: history, 
                            videoImageWidth: videoImageWidth, 
                            baseUrl: baseUrl
                          ),
                        );
                      })
                    ],
                    historyController.isLoadingMore.value
                      ? Center(
                          child: CircularProgressIndicator(
                            color: Colors.blue,
                          ),
                        )
                      : SizedBox()
                  ],
                );
              }),
            ),
          );
        }),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_app/components/input_component.dart';
import 'package:video_app/controllers/video_controller.dart';
import 'package:video_app/utils/convert_duration.dart';
import 'package:video_player/video_player.dart';

class VideoCreatePage extends StatefulWidget {
  const VideoCreatePage({super.key});

  @override
  State<VideoCreatePage> createState() => _VideoCreatePageState();
}

class _VideoCreatePageState extends State<VideoCreatePage> {
  final VideoController videoController = Get.find<VideoController>();
  
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final FocusNode titleNode = FocusNode();
  final FocusNode descriptionNode = FocusNode();

  VideoPlayerController? videoPlayerController;

  @override
  void dispose() {
    titleNode.unfocus();
    descriptionNode.unfocus();

    videoController.emptyFiles();

    super.dispose();
  }

  void onSubmit() {
    var title = titleController.text;
    var description = descriptionController.text;
    var duration = convertDurationToString(videoPlayerController?.value.duration);
              
    videoController.createData(title, description, duration);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Video', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                child: Column(
                  spacing: 10,
                  children: [
                    Obx(() {
                      var image = videoController.pickedImage.value;
            
                      return Container(
                          width: double.infinity,
                          color: Colors.grey[100],
                          child: AspectRatio(
                            aspectRatio: 16/9,
                            child: image != null 
                            ? Image(
                                height: 250,
                                image: FileImage(image)
                              ) 
                            : Center(
                                child: Text('Belum ada gambar')
                              ),
                          ),
                        );
                    }),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            videoController.pickImage(ImageSource.gallery);
                          }, 
                          icon: Icon(Icons.image),
                        ),
                        IconButton(
                          onPressed: () {
                            videoController.pickImage(ImageSource.camera);
                          }, 
                          icon: Icon(Icons.camera),
                        ),
                      ],
                    ),
                    Container(
                      width: double.infinity,
                      color: Colors.grey[100],
                      child: AspectRatio(
                        aspectRatio: 16/9,
                        child: videoPlayerController != null && videoPlayerController!.value.isInitialized ?
                          Stack(
                            children: [
                              Center(
                                child: AspectRatio(
                                  aspectRatio: videoPlayerController!.value.aspectRatio,
                                  child: VideoPlayer(videoPlayerController!),
                                ),
                              ),
                              Positioned.fill(
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
                                        )
                                  ),
                                )
                              )
                            ]
                          ) :
                          Center(
                            child: Text('Belum ada video')
                          ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () async {
                            await videoController.pickVideo(ImageSource.gallery);
                            var video = videoController.pickedVideo.value;
            
                            if (video != null) {
                              videoPlayerController?.dispose();
            
                              videoPlayerController = VideoPlayerController.file(video)..initialize().then((_) {
                                setState(() {});
                              });
                            }
                          }, 
                          child: Text(
                            'Ambil dari gallery',
                            style: TextStyle(
                              color: Colors.blue
                            ),
                          )
                        ),
                        TextButton(
                          onPressed: () {
                            videoController.pickVideo(ImageSource.camera);
                          }, 
                          child: Text(
                            'Ambil dari kamera',
                            style: TextStyle(
                              color: Colors.blue
                            ),
                          )
                        ),
                      ],
                    ),
                    InputComponent(
                      title: 'Judul', 
                      controller: titleController,
                      maxLength: 100,
                      action: TextInputAction.next,
                      focusNode: titleNode,
                      onSubmit: () {
                        FocusScope.of(context).requestFocus(descriptionNode);
                      },
                    ),
                    InputComponent(
                      title: 'Deskripsi', 
                      controller: descriptionController,
                      action: TextInputAction.done,
                      focusNode: descriptionNode,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: GestureDetector(
              onTap: () {
                onSubmit();
              }, 
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(5)
                ),
                child: Center(
                  child: Obx(() {
                    var isLoading = videoController.isLoadingCreate.value;

                    return isLoading 
                      ? SizedBox(
                          height: 25,
                          width: 25,
                          child: CircularProgressIndicator()
                        ) 
                      : Text(
                          'Buat', 
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16
                          ),  
                        );
                  }),
                )
              ),
            ),
          ),
        ],
      ),
    );
  }
}
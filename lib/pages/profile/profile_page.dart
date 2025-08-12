import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_app/constants/env.dart';
import 'package:video_app/controllers/auth_controller.dart';
import 'package:video_app/controllers/profile_controller.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileController profileController = Get.find<ProfileController>();
  final AuthController authController = Get.find<AuthController>();
  final baseUri = ApiPoint.baseUrl;

  void openPickImageOption(BuildContext context) {
    showModalBottomSheet(
      context: context, 
      builder: (context) {
        return Container(
          padding: EdgeInsetsDirectional.symmetric(vertical: 15, horizontal: 10),
          width: MediaQuery.of(context).size.width,
          child: Wrap(
            children: [
              GestureDetector(
                onTap: () async {
                  Navigator.pop(context);
                  await profileController.pickImage(ImageSource.gallery);
                  openConfirmImageDialog();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    spacing: 10,
                    children: [
                      Icon(Icons.image),
                      Text(
                        'Ambil dari gallery',
                        style: TextStyle(
                          fontSize: 15
                        ),
                      )
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  Navigator.pop(context);
                  await profileController.pickImage(ImageSource.camera);
                  openConfirmImageDialog();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    spacing: 10,
                    children: [
                      Icon(Icons.camera),
                      Text(
                        'Ambil dari kamera',
                        style: TextStyle(
                          fontSize: 15
                        ),
                      )
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

  void openConfirmImageDialog() async {
    if (profileController.pickedImage.value != null) {
      await Get.dialog(
        AlertDialog(
          content: SizedBox(
            width: MediaQuery.of(context).size.width / 0.8,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Wrap(
                spacing: 15,
                children: [
                  Stack(
                    children: [
                      SizedBox(
                        height: 200,
                        child: Center(
                          child: Image(image: FileImage(profileController.pickedImage.value!)),
                        ),
                      ),
                      Obx(() {
                        return profileController.isLoadingEditImage.value 
                          ? Positioned.fill(
                              child: Center(
                                child: CircularProgressIndicator(color: Colors.white),
                              )
                            )
                          : SizedBox();
                      }),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () async {
                            await profileController.editProfileImage();
                            Get.back();
                          }, 
                          child: Text(
                            'Konfirmasi',
                            style: TextStyle(
                              color: Colors.blue
                            ),
                          )
                        )
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            profileController.emptyImage();
                            Get.back();
                          }, 
                          child: Text(
                            'Batal',
                            style: TextStyle(
                              color: Colors.red
                            ),
                          )
                        )
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        )
      ); 

      profileController.emptyImage();
    }
  }

  void confirmLogout() {
    Get.dialog(
      AlertDialog(
        content: SizedBox(
          width: MediaQuery.of(context).size.width / 0.8,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Wrap(
              children: [
                Text(
                  "Yakin ingin keluar?",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: 15,
                  children: [
                    TextButton(
                      onPressed: () {
                        authController.logout();
                      }, 
                      child: Text(
                        "Ya",
                        style: TextStyle(
                          color: Colors.blue
                        ),
                      )
                    ),
                    TextButton(
                      onPressed: () {
                        Get.back();
                      }, 
                      child: Text(
                        "Tidak",
                        style: TextStyle(
                          color: Colors.red
                        ),
                      )
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            onPressed: () {
              confirmLogout();
            }, 
            icon: Icon(Icons.logout, color: Colors.white)
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            spacing: 15,
            children: [
              Column(
                children: [
                  Obx(() {
                    var image = profileController.user.value?.profileImage;
              
                    return Center(
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: image != null
                          ? NetworkImage(baseUri + image)
                          : AssetImage('assets/images/profile.png'),
                      ),
                    );
                  }),
                  SizedBox(height: 10),
                  Row(
                    spacing: 10,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          openPickImageOption(context);
                        },
                        child: Icon(Icons.edit),
                      ),
                      GestureDetector(
                        onTap: () {
                          
                        },
                        child: Icon(Icons.delete),
                      ),
                    ],
                  )
                ],
              ),
              Text(
                profileController.user.value?.email ?? 'email'
              ),
              Obx(() {
                var name = profileController.user.value?.name;

                return Row(
                  spacing: 10,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name ?? 'User',
                      style: TextStyle(
                        fontSize: 20
                      ),
                    ),
                    Icon(Icons.edit, size: 18)
                  ],
                );
              })
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_app/controllers/auth_controller.dart';
import 'package:video_app/pages/auth/login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  bool obscureText = true;

  void onSubmit() {
    final email = emailController.text;
    final name = nameController.text;
    final username = usernameController.text;
    final password = passwordController.text;

    authController.register(email, name, username, password);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.blue,
      body: SingleChildScrollView(
        child: Container(
          height: screenHeight,
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 60),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  'Register',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 45
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  'MS Developer video app',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20
                  ),
                ),
              ),
              SizedBox(height: 30),
              Expanded(
                child: Container(
                  padding: EdgeInsets.fromLTRB(30, 50, 30, 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(60),
                      topRight: Radius.circular(60)
                    )
                  ),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromRGBO(26, 120, 194, 0.4),
                              blurRadius: 20,
                              offset: Offset(0, 10)
                            ),
                          ],
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey.shade200
                                  )
                                )
                              ),
                              child: TextField(
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  isDense: true,
                                  hintText: 'Email',
                                  hintStyle: TextStyle(
                                    color: Colors.grey
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(0)
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey.shade200
                                  )
                                )
                              ),
                              child: TextField(
                                controller: nameController,
                                textInputAction: TextInputAction.next,
                                textCapitalization: TextCapitalization.sentences,
                                decoration: InputDecoration(
                                  isDense: true,
                                  hintText: 'Nama',
                                  hintStyle: TextStyle(
                                    color: Colors.grey
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(0)
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey.shade200
                                  )
                                )
                              ),
                              child: TextField(
                                controller: usernameController,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  isDense: true,
                                  hintText: 'Username',
                                  hintStyle: TextStyle(
                                    color: Colors.grey
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(0)
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: passwordController,
                                      obscureText: obscureText,
                                      textInputAction: TextInputAction.done,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        hintText: 'Password',
                                        hintStyle: TextStyle(
                                          color: Colors.grey
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.all(0),
                                      ),
                                      onSubmitted: (_) {
                                        FocusScope.of(context).unfocus();
                                        onSubmit();
                                      },
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        obscureText = !obscureText;
                                      });
                                    }, 
                                    child: Icon(obscureText ? Icons.visibility_off : Icons.visibility)
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 50),
                      GestureDetector(
                        onTap: () {
                          onSubmit();
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(25)
                          ),
                          child: Center(
                            child: Obx(() {
                              if (authController.isLoadingRegister.value == true) {
                                return SizedBox(
                                  height: 45,
                                  width: 45,
                                  child: Center(
                                    child: CircularProgressIndicator(color: Colors.white)
                                  ),
                                );
                              }
        
                              return Text(
                                'Register',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Sudah punya akun? ',
                            style: TextStyle(
                              color: Colors.grey
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Get.offAll(() => LoginPage());
                            },
                            child: Text(
                              'Masuk',
                              style: TextStyle(
                                color: Colors.blue
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                )
              )
            ],
          ),
        ),
      ),
    );
  }
}
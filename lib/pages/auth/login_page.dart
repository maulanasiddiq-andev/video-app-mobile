import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_app/controllers/auth_controller.dart';
import 'package:video_app/pages/auth/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthController authController = Get.find<AuthController>();
  TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
  }

  void _onSubmitText() {
    String email = _emailController.value.text;
    String password = _passwordController.value.text;

    authController.login(email, password);
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
                  'Login',
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
                              child: Autocomplete(
                                optionsBuilder: (TextEditingValue value) async {
                                  if (value.text.isEmpty) {
                                    return const Iterable<String>.empty();
                                  }
                                  var emails = await authController.showSubmittedEmails();

                                  return emails.where((email) {
                                    return email.toLowerCase().contains(value.text.toLowerCase());
                                  }).take(4);
                                },
                                fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                                  _emailController = textEditingController;

                                  return TextField(
                                    controller: textEditingController,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    focusNode: focusNode,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      hintText: 'Email',
                                      hintStyle: TextStyle(
                                        color: Colors.grey
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.all(0)
                                    ),
                                  );
                                },
                              ),
                              // TextField(
                              //   controller: _emailController,
                              //   keyboardType: TextInputType.emailAddress,
                              //   textInputAction: TextInputAction.next,
                              //   decoration: InputDecoration(
                              //     isDense: true,
                              //     hintText: 'Email',
                              //     hintStyle: TextStyle(
                              //       color: Colors.grey
                              //     ),
                              //     border: InputBorder.none,
                              //     contentPadding: EdgeInsets.all(0)
                              //   ),
                              // ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _passwordController,
                                      obscureText: _obscureText,
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
                                        _onSubmitText();
                                      },
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _obscureText = !_obscureText;
                                      });
                                    }, 
                                    child: Icon(_obscureText ? Icons.visibility_off : Icons.visibility)
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 40),
                      Text(
                        'Lupa Password?',
                        style: TextStyle(
                          color: Colors.grey
                        ),
                      ),
                      SizedBox(height: 50),
                      GestureDetector(
                        onTap: () {
                          _onSubmitText();
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(25)
                          ),
                          child: Center(
                            child: Obx(() {
                              if (authController.isLoading.value == true) {
                                return SizedBox(
                                  height: 45,
                                  width: 45,
                                  child: Center(
                                    child: CircularProgressIndicator(color: Colors.white)
                                  ),
                                );
                              }
        
                              return Text(
                                'Login',
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
                            'Belum punya akun? ',
                            style: TextStyle(
                              color: Colors.grey
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Get.offAll(() => RegisterPage());
                            },
                            child: Text(
                              'Daftar',
                              style: TextStyle(
                                color: Colors.blue
                              ),
                            ),
                          )
                        ],
                      ),
                      Expanded(child: SizedBox()),
                      // GestureDetector(
                      //   onTap: () {
                      //     handleSignInWithGoogle();
                      //   },
                      //   child: Container(
                      //     height: 50,
                      //     decoration: BoxDecoration(
                      //       color: Colors.blue,
                      //       borderRadius: BorderRadius.circular(25)
                      //     ),
                      //     child: Center(
                      //       child: Obx(() {
                      //         if (authController.isLoadingLoginWithGoogle.value == true) {
                      //           return SizedBox(
                      //             height: 45,
                      //             width: 45,
                      //             child: Center(
                      //               child: CircularProgressIndicator(color: Colors.white)
                      //             ),
                      //           );
                      //         }
        
                      //         return Text(
                      //           'Login With Google',
                      //           style: TextStyle(
                      //             color: Colors.white,
                      //             fontSize: 16,
                      //             fontWeight: FontWeight.bold
                      //           ),
                      //         );
                      //       }),
                      //     ),
                      //   ),
                      // ),
                      SizedBox(height: 25),
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
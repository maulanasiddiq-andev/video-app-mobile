import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_app/components/otp_input_component.dart';
import 'package:video_app/controllers/auth_controller.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  static final maxSeconds = 15 * 60;

  final AuthController authController = Get.find<AuthController>();
  final List<TextEditingController> controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(4, (_) => FocusNode());
  int seconds = maxSeconds;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      if (seconds > 0) {
        setState(() => seconds--);
      } else {
        timer?.cancel();
      }
    });
  }

  void resetTimer() {
    timer?.cancel();
    setState(() => seconds = maxSeconds);
  }

  void restartTimer() {
    resetTimer();
    startTimer();
  }

  String timeFormatted() {
    var minute = (seconds ~/ 60).toString().padLeft(2, '0');
    var second = (seconds % 60).toString().padLeft(2, '0');

    return '$minute:$second';
  }

  void onSubmitOtpCode() {
    String otpCode = '';

    for (var c in controllers) {
      otpCode += c.text;
      c.text = '';
    }

    authController.verifyAccount(otpCode);
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
                  'Verifikasi OTP',
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
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(60),
                      topRight: Radius.circular(60)
                    )
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 60),
                      Text(
                        'Cek email Anda untuk mengetahui kode OTP yang telah dikirimkan.',
                        style: TextStyle(
                          fontSize: 17
                        ),  
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ...controllers.asMap().entries.map((c) {
                            var controller = c.value;
                            var index = c.key;

                            return OtpInputComponent(
                              controller: controller,
                              focusNode: focusNodes[index],
                              autoFocus: index < 1,
                              onChange: (value) {
                                if (value.length == 1) {
                                  if (index < 3) {
                                    focusNodes[index + 1].requestFocus();
                                  } else {
                                    focusNodes[index].unfocus();
                                    onSubmitOtpCode();
                                  }
                                }
                              },
                              onPrevious: () {
                                if (index > 0) {
                                  focusNodes[index - 1].requestFocus();
                                  controllers[index - 1].text = '';
                                }
                              },
                            );
                          })
                          ,
                        ],
                      ),
                      SizedBox(height: 40),
                      Text(
                        'Kode OTP akan berakhir pada:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        timeFormatted(),
                        style: TextStyle(
                          fontSize: 20
                        ),
                      ),
                      SizedBox(height: 45),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Belum menerima kode OTP? '),
                          GestureDetector(
                            onTap: () {
                              restartTimer();
                              authController.resendOtp();
                            },
                            child: Text(
                              'Kirim ulang.',
                              style: TextStyle(
                                color: Colors.blue
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 30),
                      authController.isLoadingVerifyAccount.value
                        ? CircularProgressIndicator(color: Colors.blue)
                        : SizedBox()
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
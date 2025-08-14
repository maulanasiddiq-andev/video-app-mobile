import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_app/controllers/comment_controller.dart';
import 'package:video_app/controllers/history_controller.dart';
import 'package:video_app/controllers/profile_controller.dart';
import 'package:video_app/controllers/video_controller.dart';
import 'package:video_app/exceptions/api_exception.dart';
import 'package:video_app/models/base_response.dart';
import 'package:video_app/models/token_model.dart';
import 'package:video_app/models/user_model.dart';
import 'package:video_app/pages/auth/login_page.dart';
import 'package:video_app/pages/auth/verification_page.dart';
import 'package:video_app/pages/root_page.dart';
import 'package:video_app/services/auth_service.dart';

class AuthController extends GetxController {
  var storage = FlutterSecureStorage();

  var isAuthenticated = false.obs;

  // profile image
  final ImagePicker picker = ImagePicker();
  var pickedImage = Rxn<File>();

  var isLoading = false.obs;
  var isLoadingLoginWithGoogle = false.obs;
  var isLoadingRegister = false.obs;
  var isLoadingVerifyAccount = false.obs;

  var registeredAccount = Rxn<UserModel>();

  Future<void> login(String email, String password) async {
    isLoading(true);

    try {
      final BaseResponse<TokenModel> result = await AuthService.login(email, password);

      await storage.write(key: 'token', value: result.data!.token);

      final userJson = jsonEncode(result.data!.user);
      await storage.write(key: 'user', value: userJson);

      registerController();
      saveSubmittedEmail(email);

      Get.offAll(() => RootPage());
    } on ApiException catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<bool> checkAuth() async {
    try {
      var token = await storage.read(key: 'token');

      if (token == null) {
        isAuthenticated(false);

        return false;
      }

      final BaseResponse<UserModel> result = await AuthService.checkAuth(token);

      var encodedUser = jsonEncode(result.data?.toJson());
      await storage.write(key: 'user', value: encodedUser);

      registerController();

      return true;
    } on ApiException catch (_) {
      return false;
    }
  }

  Future<void> register(String email, String name, String username, String password) async {
    isLoadingRegister(true);

    try {
      var result = await AuthService.register(email, name, username, password);

      Fluttertoast.showToast(msg: result.messages[0]);
      registeredAccount.value = result.data;

      Get.to(() => VerificationPage());
    } on ApiException catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      isLoadingRegister(false);
    }
  }

  Future<void> verifyAccount(String otpCode) async {
    isLoadingVerifyAccount(true);
    try {
      final result = await AuthService.verifyAccount(otpCode, registeredAccount.value!.id);

      Fluttertoast.showToast(msg: result.messages[0]);
      registeredAccount.value = null;
      Get.offAll(() => LoginPage());
    } on ApiException catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      isLoadingVerifyAccount(false);
    }
  }

  Future<void> resendOtp() async {
    try {
      final result = await AuthService.resendOtpCode(registeredAccount.value!.id);

      Fluttertoast.showToast(msg: result.messages[0]);
    } on ApiException catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future<void> saveSubmittedEmail(String email) async {
    if (email == '') return;

    var emailsJson = await storage.read(key: 'emails');
    List<String> emails = [];

    if (emailsJson != null) emails = List<String>.from(jsonDecode(emailsJson));

    if (!emails.contains(email)) emails.add(email);

    await storage.write(key: 'emails', value: jsonEncode(emails));
  }

  Future<List<String>> showSubmittedEmails() async {
    var emailsJson = await storage.read(key: 'emails');
    List<String> emails = [];

    if (emailsJson != null) {
      emails = List<String>.from(jsonDecode(emailsJson));
    }

    return emails;
  }

  Future<void> logout() async {
    await storage.delete(key: 'token');
    await storage.delete(key: 'user');

    deleteController();
      
    Get.offAll(() => LoginPage());
  }

  void registerController() {
    if (!Get.isRegistered<VideoController>()) {
      Get.lazyPut(() => VideoController());
    }

    if (!Get.isRegistered<ProfileController>()) {
      Get.lazyPut(() => ProfileController());
    }
    
    /**
     * the history controller will be deleted once it is not used
     * fenix: true makes the controller again if it is needed
     */
    if (!Get.isRegistered<HistoryController>()) {
      Get.lazyPut(() => HistoryController(), fenix: true);
    }
    
    if (!Get.isRegistered<CommentController>()) {
      Get.lazyPut(() => CommentController(), fenix: true);
    }
  }

  void deleteController() {
    if (Get.isRegistered<VideoController>()) {
      Get.delete<VideoController>();
    }
    
    if (Get.isRegistered<ProfileController>()) {
      Get.delete<ProfileController>();
    }

    if (Get.isRegistered<HistoryController>()) {
      Get.delete<HistoryController>();
    }
    
    if (Get.isRegistered<CommentController>()) {
      Get.delete<CommentController>();
    }
  }
}
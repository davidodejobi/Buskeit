import 'dart:developer';

import 'package:buskeit/modules/dashboard_flow/screens/flow_selection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../constant/constant.dart';
import '../../../core/core.dart';
import '../../../locator.dart';
import '../../../shared/shared.dart';

class SigninProvider with ChangeNotifier {
  StorageService storageService = getIt<StorageService>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  startLoading() {
    isLoading = true;
    notifyListeners();
  }

  stopLoading() {
    isLoading = false;
    notifyListeners();
  }

  Future login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    startLoading();
    try {
      ResponseModel responseModel = ResponseModel();
      await connect().post("/auth/token", data: {
        "email": email,
        "password": password,
      }).then((value) async {
        if (value.statusCode == 200) {
          // responseModel = ResponseModel.fromJson(value.data);

          storeToken(value);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const FlowSelection(),
            ),
          );
        }
        // Response response = await connect().get("/user/me");
        // if (response.statusCode == 200) {
        //   storeUserDetails(response);
        // }
      });

      stopLoading();
      // await futureAwait();
      // print('responseModel: ${responseModel.message}');
      return responseModel;
    } on HttpException catch (e) {
      stopLoading();
      print('HttpException: ${e.message}');
      return e.message;
    } on DioError catch (e) {
      stopLoading();
      var errorMessage =
          'We could not process your request at this time, please try again later';
      showAlertDialog(context: context, message: errorMessage);
      log('e: ${e.message}');
      return errorModelFromJson(e.response!.data);
    } catch (e) {
      stopLoading();
      print('Exception: ${e.toString()}');
      return e.toString();
    }
  }

  storeToken(response) {
    ResponseModel res = responseModelFromJson(response.data);
    String myToken = res.tokens!.access;

    storageService.storeItem(key: token, value: myToken);
    // read token from storage
    storageService.readItem(key: token).then((value) {});
  }

  removeToken() {
    storageService.deleteItem(key: token);
  }

  storeUserDetails(response) {
    ResponseModel res = responseModelFromJson(response.data);
    UserModel user = UserModel.fromJson(res.user);

    // userService.credentials = user;
    storageService.storeItem(
        key: individualDetails, value: userModelToJson(user));
  }
}

  // bool btnActive = false;
  // set _btnActive(bool state) {
  //   btnActive = state;
  //   notifyListeners();
  // }

  
  // validator() {
  //   if (passwordController.text.isNotEmpty && emailController.text.isNotEmpty) {
  //     _btnActive = true;
  //   } else {
  //     _btnActive = false;
  //   }
  // }
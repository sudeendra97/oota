import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Authenticate with ChangeNotifier {
  var baseUrl = 'https://projectoota.herokuapp.com/';

  var _token;

  bool get isAuth {
    return _token != null;
  }

  get token {
    return _token;
  }

  Future<int> signUp(var data) async {
    final url = Uri.parse('${baseUrl}api/v1/rest-auth/registration/');
    // print(data);
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8",
        },
        body: json.encode(data),
      );

      print(response.statusCode);
      print(response.body);
      if (response.statusCode != 200) {
        errorHandling(response);
      }
      return response.statusCode;
    } on SocketException catch (e) {
      EasyLoading.dismiss();

      Get.showSnackbar(GetSnackBar(
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.blue.withOpacity(0.5),
        message: 'Something Went Wrong Please try Again',
        title: 'Failed',
      ));

      throw Exception(e);
    }
  }

  Future<Map<String, dynamic>> logIn(var data) async {
    final url = Uri.parse('${baseUrl}api/v1/rest-auth/login/');
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8",
        },
        body: json.encode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseData = json.decode(response.body);
        _token = responseData['key'];
        // print(_token);
        final prefs = await SharedPreferences.getInstance();
        final userData = json.encode(
          {
            'token': _token,
          },
        );
        prefs.setString('userData', userData);
      } else {
        errorHandling(response);

        return {
          'StatusCode': response.statusCode,
        };
      }

      // print(response.statusCode);
      // print(response.body);
      return {'StatusCode': response.statusCode, 'Body': {}};
    } catch (e) {
      EasyLoading.dismiss();

      Get.showSnackbar(GetSnackBar(
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.blue.withOpacity(0.5),
        message: 'Something Went Wrong Please try Again',
        title: 'Failed',
      ));
      rethrow;
    }
  }

  Future<int> forgetPassword(var data) async {
    final url = Uri.parse('${baseUrl}api/v1/rest-auth/login/');
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8",
        },
        body: json.encode(data),
      );

      // print(response.statusCode);
      // print(response.body);
      return response.statusCode;
    } catch (e) {
      EasyLoading.dismiss();

      Get.showSnackbar(GetSnackBar(
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.blue.withOpacity(0.5),
        message: 'Something Went Wrong Please try Again',
        title: 'Failed',
      ));

      rethrow;
    }
  }

  Future<bool> tryAutoLogin() async {
    // logout();
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extratedUserData =
        //we should use dynamic as a another value not a Object
        json.decode(prefs.getString('userData')!) as Map<String, dynamic>;
    // final expiryDate =
    //     DateTime.parse(extratedUserData['expiryDate'].toString());

    // if (expiryDate.isBefore(DateTime.now())) {
    //   return false;
    // }
    if (extratedUserData["token"] == null) {
      return false;
    }
    _token = extratedUserData["token"];

    notifyListeners();
    // _autoLogOut();
    return true;
  }

  Future<void> logout() async {
    _token = null;

    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('userData')) {
      prefs.remove('userData');
    }
    if (prefs.containsKey('CustomerProfile')) {
      prefs.remove('CustomerProfile');
    }

    notifyListeners();
  }

  void errorHandling(var response) {
    final responseData = json.decode(response.body) as Map<String, dynamic>;

    List temp = [];
    responseData.forEach((key, value) {
      temp.add(value);
    });
    print(temp);

    print(EasyLoading.isShow.toString());

    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    Get.defaultDialog(
      title: 'Alert',
      middleText: temp[0][0].toString(),
      confirm: TextButton(
        onPressed: () {
          Get.back();
        },
        child: Text('ok'),
      ),
    );
  }
}

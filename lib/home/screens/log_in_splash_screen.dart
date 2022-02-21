import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:oota/authentication/providers/api_calls.dart';
import 'package:oota/home/screens/nav_bar_screen.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogInSplashScreen extends StatefulWidget {
  LogInSplashScreen({Key? key}) : super(key: key);
  static const routeName = '/LogInSplashScreen';

  @override
  State<LogInSplashScreen> createState() => _LogInSplashScreenState();
}

class _LogInSplashScreenState extends State<LogInSplashScreen> {
  @override
  void initState() {
    super.initState();

    var data = Get.arguments;
    sendFcmDevice(data['value'], data['token']);
  }

  Map<String, dynamic> fcmDeviceModel = {
    'registration_id': '',
    'name': '',
    'device_id': '',
    'type': '',
  };

  Future<String?> _getId() async {
    print('Getting Id');
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      // import 'dart:io'
      fcmDeviceModel['type'] = 'ios';
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else {
      fcmDeviceModel['type'] = 'android';
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.androidId; // unique ID on Android
    }
  }

  Future<void> sendFcmDevice(Map<String, dynamic> value, var token) async {
    final profilePrefs = await SharedPreferences.getInstance();
    final userData = json.encode(
      {
        'profileId': value['Response_Body'][0]['Profile_Id'],
      },
    );
    profilePrefs.setString('profile', userData);
    String? deviceId = await _getId();
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('FCM')) {
      return;
    }
    final extratedUserData =
        json.decode(prefs.getString('FCM')!) as Map<String, dynamic>;
    fcmDeviceModel['registration_id'] = extratedUserData['token'];
    fcmDeviceModel['name'] = value['Response_Body'][0]['Profile_Code'];

    fcmDeviceModel['device_id'] = deviceId;

    await Provider.of<ApiCalls>(context, listen: false)
        .sendFCMDeviceModel(fcmDeviceModel, token)
        .then((value) {
      if (value == 200 || value == 201) {
        print('Fcm success');
        EasyLoading.dismiss();
        // Get.showSnackbar(GetSnackBar(
        //   duration: const Duration(seconds: 2),
        //   backgroundColor: Colors.blue.withOpacity(0.5),
        //   message: 'Successfully logged in',
        //   title: 'Success',
        // ));
        Get.toNamed(NavBarScreen.routeName);
      } else {
        EasyLoading.dismiss();
        Get.toNamed(NavBarScreen.routeName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
        body: Container(
      width: size.width,
      height: size.height,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(
              semanticsLabel: 'Setting Things Up',
              color: Colors.orange,
            ),
            SizedBox(
              height: 10,
            ),
            Text('Setting Things up')
          ],
        ),
      ),
      // Image.asset(
      //   'assets/images/splashImage.jpeg',
      //   fit: BoxFit.cover,
      // ),
    ));
  }
}

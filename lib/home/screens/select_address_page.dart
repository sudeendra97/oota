import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oota/home/screens/map_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectAddressPage extends StatefulWidget {
  SelectAddressPage({Key? key}) : super(key: key);

  static const routeName = '/SelectAddressPage';

  @override
  State<SelectAddressPage> createState() => _SelectAddressPageState();
}

class _SelectAddressPageState extends State<SelectAddressPage> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  TextEditingController latitudeController = TextEditingController();
  TextEditingController longitudeController = TextEditingController();
  TextEditingController consumerAddressController = TextEditingController();

  var result;
  var validate = true;

  double errorHeight = 70;

  @override
  void initState() {
    super.initState();
  }

  Map<String, dynamic> userProfileSetUp = {
    'First_Name': '',
    'Last_Name': '',
    'Mobile': '',
    'Street': '',
    // 'City': '',
    // 'State': '',
    // 'Zip_Code': '',
    // 'Description': '',
    'User': '',
    // 'Image': '',
    'Latitude': '',
    'Longitude': '',
    'Profile_Code': '',
  };

  Map<String, dynamic> fcmDeviceModel = {
    'registration_id': '',
    'name': '',
    'device_id': '',
    'type': '',
  };

  var imageFile;
  List<dynamic> _fileBytes = [];
  Image? _imageWidget;
  Image? _imageWidgetFile;
  var fileName = '';
  var fileBase64;
  var token;
  var isloading = false;
  final ImagePicker _picker = ImagePicker();

  String getRandom(int length) {
    const ch = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz';
    Random r = Random();
    return String.fromCharCodes(
        Iterable.generate(length, (_) => ch.codeUnitAt(r.nextInt(ch.length))));
  }

  Future<void> getMultipleImageInfos() async {
    XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    // var mediaData = await ImagePickerWeb.getImageInfo;
    // String? mimeType = mime(Path.basename(mediaData.fileName!));
    // html.File mediaFile =
    //     html.File(mediaData.data!, mediaData.fileName!, {'type': mimeType});

    if (image != null) {
      File? croppedFile = await ImageCropper.cropImage(
          sourcePath: image.path,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9
          ],
          androidUiSettings: const AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.black,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          iosUiSettings: const IOSUiSettings(
            minimumAspectRatio: 1.0,
          )).then((croppedImage) {
        if (croppedImage == null) {
          return;
        }
        croppedImage.readAsBytes().then((value) {
          _fileBytes = value;
          setState(() {
            imageFile = croppedImage;
            fileName = image.name;

            // print(_fileBytes);
            // _cloudFile = mediaFile;
            // _fileBytes = mediaData.data!;
            // _imageWidget = Image.memory(mediaData.data!);
            // fileName = mediaData.fileName!;
            // fileBase64 = mediaData.base64;
          });
        });
      });
    }
  }

  Future<String?> _getId() async {
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

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  // Future<void> save() async {
  //   validate = _formKey.currentState!.validate();
  //   if (validate != true) {
  //     setState(() {
  //       validate = false;
  //     });
  //     return;
  //   }
  //   _formKey.currentState!.save();
  //   userProfileSetUp['Profile_Code'] = getRandom(5);

  //   // EasyLoading.show();

  //   Provider.of<Authenticate>(context, listen: false)
  //       .tryAutoLogin()
  //       .then((value) {
  //     var token = Provider.of<Authenticate>(context, listen: false).token;
  //     Provider.of<ApiCalls>(context, listen: false)
  //         .fetchUser(token)
  //         .then((value) {
  //       if (value['Status_Code'] == 200 || value['Status_Code'] == 201) {
  //         print(value);
  //         userProfileSetUp['User'] = value['Id'];
  //         print(userProfileSetUp);
  //         Provider.of<ApiCalls>(context, listen: false)
  //             .addCustomerProfile(
  //           userProfileSetUp,
  //           userProfileSetUp['User'],
  //           token,
  //         )
  //             .then((value) async {
  //           if (value['StatusCode'] == 201) {
  //             EasyLoading.showSuccess('Successfully added Your Profile');
  //             Get.back(result: 'Success');

  //             // EasyLoading.show();
  //             // // print(value['Id']);
  //             // String? deviceId = await _getId();
  //             // final prefs = await SharedPreferences.getInstance();
  //             // if (!prefs.containsKey('FCM')) {
  //             //   return false;
  //             // }
  //             // final extratedUserData =
  //             //     json.decode(prefs.getString('FCM')!) as Map<String, dynamic>;
  //             // fcmDeviceModel['registration_id'] = extratedUserData['token'];
  //             // fcmDeviceModel['name'] = userProfileSetUp['Profile_Code'];

  //             // fcmDeviceModel['device_id'] = deviceId;

  //             // Provider.of<ApiCalls>(context, listen: false)
  //             //     .sendFCMDeviceModel(fcmDeviceModel, token)
  //             //     .then((value) {
  //             //   if (value == 200 || value == 201) {
  //             //     EasyLoading.showSuccess(
  //             //         'Successfully Updated Your Profile for notifications');
  //             //     Get.back();
  //             //     // Get.toNamed(HomePageScreen.routeName);
  //             //   } else {
  //             //     EasyLoading.dismiss();
  //             //     Get.back();
  //             //   }
  //             // });
  //           } else {
  //             EasyLoading.dismiss();
  //             Get.showSnackbar(GetSnackBar(
  //               duration: const Duration(seconds: 2),
  //               backgroundColor: Theme.of(context).backgroundColor,
  //               message: 'Something Went Wrong',
  //               title: 'Profile SetUp Failed',
  //             ));
  //           }
  //         });
  //       }
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var topPadding = MediaQuery.of(context).padding.top;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Address',
          style: GoogleFonts.roboto(
            textStyle: const TextStyle(
              color: Colors.black,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Row(
                  //   children: [
                  //     Text(
                  //       'Add Address',
                  //       style: GoogleFonts.roboto(
                  //           textStyle: const TextStyle(
                  //               fontSize: 34, fontWeight: FontWeight.w500)),
                  //     ),
                  //   ],
                  // ),

                  Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: width / 1.2,
                          padding: const EdgeInsets.only(bottom: 12),
                          child: const Text.rich(TextSpan(children: [
                            TextSpan(text: 'First Name'),
                            TextSpan(
                                text: '*', style: TextStyle(color: Colors.red))
                          ])),
                        ),
                        Container(
                          width: width / 1.2,
                          height: validate == true ? 40 : errorHeight,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                            border: Border.all(color: Colors.black26),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                            child: TextFormField(
                              decoration: const InputDecoration(
                                  hintText: 'First Name',
                                  border: InputBorder.none),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  // showError('FirmCode');
                                  return 'First name cannot be empty';
                                }
                              },
                              onSaved: (value) {
                                userProfileSetUp['First_Name'] = value;
                                // signUp['email'] = value;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: width / 1.2,
                          padding: const EdgeInsets.only(bottom: 12),
                          child: const Text('Last Name'),
                        ),
                        Container(
                          width: width / 1.2,
                          height: validate == true ? 40 : errorHeight,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                            border: Border.all(color: Colors.black26),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                            child: TextFormField(
                              decoration: const InputDecoration(
                                  hintText: 'Last Name',
                                  border: InputBorder.none),
                              // validator: (value) {
                              //   if (value!.isEmpty) {
                              //     // showError('FirmCode');
                              //     return '';
                              //   }
                              // },
                              onSaved: (value) {
                                userProfileSetUp['Last_Name'] = value;
                                // signUp['email'] = value;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: width / 1.2,
                          padding: const EdgeInsets.only(bottom: 12),
                          child: const Text.rich(TextSpan(children: [
                            TextSpan(text: 'Mobile Number'),
                            TextSpan(
                                text: '*', style: TextStyle(color: Colors.red))
                          ])),
                        ),
                        Container(
                          width: width / 1.2,
                          height: validate == true ? 40 : errorHeight,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                            border: Border.all(color: Colors.black26),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                            child: TextFormField(
                              decoration: const InputDecoration(
                                  hintText: 'mobile', border: InputBorder.none),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  // showError('FirmCode');
                                  return 'Mobile Number cannot be empty';
                                }
                              },
                              onSaved: (value) {
                                userProfileSetUp['Mobile'] = value;
                                // signUp['email'] = value;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: width / 1.2,
                          padding: const EdgeInsets.only(bottom: 12),
                          child: const Text.rich(TextSpan(children: [
                            TextSpan(text: 'Street Address'),
                            TextSpan(
                                text: '*', style: TextStyle(color: Colors.red))
                          ])),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: width / 1.5,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.white,
                                border: Border.all(color: Colors.black26),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: TextFormField(
                                  controller: consumerAddressController,
                                  decoration: const InputDecoration(
                                      hintText: 'Street Address',
                                      border: InputBorder.none),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      // showError('FirmCode');
                                      return 'Address Cannot be Empty';
                                    }
                                  },
                                  onSaved: (value) {
                                    userProfileSetUp['Street'] = value;
                                    // signUp['email'] = value;
                                  },
                                ),
                              ),
                            ),
                            IconButton(
                                onPressed: () async {
                                  result =
                                      await Get.toNamed(MapScreen.routeName);
                                  if (result['address'] != null) {
                                    setState(() {
                                      consumerAddressController.text =
                                          result['address'];
                                      userProfileSetUp['Latitude'] =
                                          result['latitude'];
                                      userProfileSetUp['Longitude'] =
                                          result['longitude'];

                                      print(
                                          '${userProfileSetUp['Latitude']}, ${userProfileSetUp['Longitude']}, ');
                                    });
                                  }
                                },
                                icon: const Icon(
                                  Icons.map,
                                  size: 40,
                                ))
                          ],
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.orange)),
                        onPressed: () async {
                          validate = _formKey.currentState!.validate();
                          if (validate != true) {
                            setState(() {
                              validate = false;
                            });
                            return;
                          }
                          _formKey.currentState!.save();
                          final prefs = await SharedPreferences.getInstance();
                          final userData = json.encode(
                            {
                              'First_Name': userProfileSetUp['First_Name'],
                              'Last_Name': userProfileSetUp['Last_Name'],
                              'Mobile': userProfileSetUp['Mobile'],
                              'Street': userProfileSetUp['Street'],
                              'User': userProfileSetUp['User'],
                              'Latitude': userProfileSetUp['Latitude'],
                              'Longitude': userProfileSetUp['Longitude'],
                              'Profile_Code': userProfileSetUp['Profile_Code'],
                            },
                          );
                          prefs.setString('WorkAddress', userData);
                          Get.back(result: {
                            'Status': 'Success',
                          });
                        },
                        child: const Text('Save')),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:geolocator/geolocator.dart';

class SelectAddressScreen extends StatefulWidget {
  SelectAddressScreen({Key? key}) : super(key: key);

  static const routeName = '/SelectAddressScreen';

  @override
  _SelectAddressScreenState createState() => _SelectAddressScreenState();
}

class _SelectAddressScreenState extends State<SelectAddressScreen> {
  GlobalKey<FormState> _formKey = GlobalKey();
  double horizontalPadding = 20;
  double verticalPadding = 10;

  double errorHeight = 60;

  TextEditingController latitudeController = TextEditingController();
  TextEditingController longitudeController = TextEditingController();

  Map<String, dynamic> address = {
    'Name': '',
    'Street': '',
    'City': '',
    'State': '',
    'Zip_Code': '',
    'Latitude': '',
    'Longitude': '',
  };

  bool validate = true;

  // / Determine the current position of the device.
  // /
  // / When the location services are not enabled or permissions
  // / are denied the `Future` will return an error.
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

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Address'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: verticalPadding, horizontal: horizontalPadding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: width - horizontalPadding,
                      padding: const EdgeInsets.only(bottom: 12),
                      child: const Text('Name'),
                    ),
                    Container(
                      width: width - horizontalPadding,
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
                          // initialValue: initValues['Preparation_Time'],
                          decoration: const InputDecoration(
                              hintText: 'Name', border: InputBorder.none),
                          validator: (value) {
                            if (value!.isEmpty) {
                              // showError('FirmCode');
                              return 'name cannot be empty';
                            }
                          },
                          onSaved: (value) {
                            address['Name'] = value;
                            // itemDetails['Preparation_Time'] = value;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: verticalPadding, horizontal: horizontalPadding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: width - horizontalPadding,
                      padding: const EdgeInsets.only(bottom: 12),
                      child: const Text('Street'),
                    ),
                    Container(
                      width: width - horizontalPadding,
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
                          // initialValue: initValues['Preparation_Time'],
                          decoration: const InputDecoration(
                              hintText: 'Street', border: InputBorder.none),
                          validator: (value) {
                            if (value!.isEmpty) {
                              // showError('FirmCode');
                              return 'street cannot be empty';
                            }
                          },
                          onSaved: (value) {
                            address['Street'] = value;
                            // itemDetails['Preparation_Time'] = value;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: verticalPadding, horizontal: horizontalPadding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: width - horizontalPadding,
                      padding: const EdgeInsets.only(bottom: 12),
                      child: const Text('City'),
                    ),
                    Container(
                      width: width - horizontalPadding,
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
                          // initialValue: initValues['Preparation_Time'],
                          decoration: const InputDecoration(
                              hintText: 'City', border: InputBorder.none),
                          validator: (value) {
                            if (value!.isEmpty) {
                              // showError('FirmCode');
                              return 'city cannot be empty';
                            }
                          },
                          onSaved: (value) {
                            address['City'] = value;
                            // itemDetails['Preparation_Time'] = value;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: verticalPadding, horizontal: horizontalPadding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: width - horizontalPadding,
                      padding: const EdgeInsets.only(bottom: 12),
                      child: const Text('State'),
                    ),
                    Container(
                      width: width - horizontalPadding,
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
                          // initialValue: initValues['Preparation_Time'],
                          decoration: const InputDecoration(
                              hintText: 'State', border: InputBorder.none),
                          validator: (value) {
                            if (value!.isEmpty) {
                              // showError('FirmCode');
                              return 'State cannot be empty';
                            }
                          },
                          onSaved: (value) {
                            address['State'] = value;
                            // itemDetails['Preparation_Time'] = value;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: verticalPadding, horizontal: horizontalPadding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: width - horizontalPadding,
                      padding: const EdgeInsets.only(bottom: 12),
                      child: const Text('Zip_Code'),
                    ),
                    Container(
                      width: width - horizontalPadding,
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
                          // initialValue: initValues['Preparation_Time'],
                          decoration: const InputDecoration(
                              hintText: 'Zip code', border: InputBorder.none),
                          validator: (value) {
                            if (value!.isEmpty) {
                              // showError('FirmCode');
                              return 'Zip code Cannot be empty';
                            }
                          },
                          onSaved: (value) {
                            address['Zip_Code'] = value;
                            // itemDetails['Preparation_Time'] = value;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(
                color: Colors.black,
              ),
              ElevatedButton(
                  onPressed: () {
                    _determinePosition().then((value) {
                      setState(() {
                        latitudeController.text = value.latitude.toString();
                        longitudeController.text = value.longitude.toString();
                        address['Latitude'] = value.latitude;
                        address['Longitude'] = value.longitude;
                      });
                      print(value.latitude);
                      print(value.longitude);
                    });
                    ;
                  },
                  child: const Text('Get Current Location')),
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: verticalPadding, horizontal: horizontalPadding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: width - horizontalPadding,
                      padding: const EdgeInsets.only(bottom: 12),
                      child: const Text('Latitude'),
                    ),
                    Container(
                      width: width - horizontalPadding,
                      height: 40,
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
                          controller: latitudeController,
                          // initialValue: initValues['Preparation_Time'],
                          decoration: const InputDecoration(
                              hintText: 'Latitude', border: InputBorder.none),

                          onSaved: (value) {
                            // itemDetails['Preparation_Time'] = value;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: verticalPadding, horizontal: horizontalPadding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: width - horizontalPadding,
                      padding: const EdgeInsets.only(bottom: 12),
                      child: const Text('longitude'),
                    ),
                    Container(
                      width: width - horizontalPadding,
                      height: 40,
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
                          controller: longitudeController,
                          // initialValue: initValues['Preparation_Time'],
                          decoration: const InputDecoration(
                              hintText: 'longitude', border: InputBorder.none),

                          onSaved: (value) {
                            // itemDetails['Preparation_Time'] = value;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
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
                            'address': address,
                          },
                        );
                        prefs.setString('Address', userData);

                        print(address);
                        Get.back(result: 'success',);
                      },
                      child: const Text('Save')),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

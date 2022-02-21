import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oota/authentication/providers/api_calls.dart';
import 'package:oota/authentication/providers/authenticate.dart';
import 'package:oota/authentication/screens/profile_setup_page.dart';
import 'package:oota/helper/helperfunctions.dart';
import 'package:oota/home/screens/edit_profile_setup.dart';
import 'package:oota/home/screens/nav_bar_screen.dart';
import 'package:oota/home/screens/order_info_page.dart';
import 'package:oota/home/screens/select_address_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'package:http/http.dart' as http;

enum payment { payOnDelivery, debitOrCredit }

class CheckOutPage extends StatefulWidget {
  CheckOutPage({Key? key}) : super(key: key);

  static const routeName = '/checkOurPage';

  @override
  State<CheckOutPage> createState() => _CheckOutPageState();
}

class _CheckOutPageState extends State<CheckOutPage> {
  payment paymentSelected = payment.debitOrCredit;
  bool _homeAddressSelected = true;
  bool _officeAddressSelected = true;
  Map<String, dynamic>? paymentIntentData;
  Map<String, dynamic> orderDetails = {
    // 'Business_Name':'',
    'Order_Code': '',
    'User': '',
    'Price': '',
    'name': '',
    'Items': [],
    'Name': '',
    'Email': 'sudeendrapacharya@gmail.com',
    'Street': '',
    'City': '',
    'State': '',
    'Zip_Code': '',
    'Is_Paid': true,
    'Is_Shipped': false,
    'Latitude': '',
    'Longitude': '',
    'Service_fee': '0',
    'Payment_Type': 'Using credit/debit card',
  };

  Map<String, dynamic> newAddress = {
    'Name': '',
    'Street': '',
    'City': '',
    'State': '',
    'Zip_Code': '',
    'Latitude': '',
    'Longitude': '',
  };

  Map<String, dynamic> userProfileSetUp = {
    'First_Name': '',
    'Last_Name': '',
    'Mobile': '',
    'Street': '',
    'User': '',
    'Latitude': '',
    'Longitude': '',
    'Profile_Code': '',
  };

  var _customerName;

  var _customerStreet;

  var _customerCity;

  var _customerZipCode;

  var _customerState;

  var _customerLatitude;

  var _customerLongitude;

  bool _consumerProfile = true;

  double totalFoodPrice = 0;

  bool _workAddress = false;

  var _profileId;

  var _profileCode;

  var _userId;

  Map<String, dynamic> fcmDeviceModel = {
    'registration_id': '',
    'name': '',
    'device_id': '',
    'type': '',
  };

  var _customerProfileCode;

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

  Future<void> sendFcmDeviceModel() async {
    String? deviceId = await _getId();
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('FCM')) {
      return;
    }
    final extratedUserData =
        json.decode(prefs.getString('FCM')!) as Map<String, dynamic>;
    fcmDeviceModel['registration_id'] = extratedUserData['token'];
    fcmDeviceModel['name'] = _customerProfileCode;
    fcmDeviceModel['device_id'] = deviceId;
    print(fcmDeviceModel);
    Provider.of<Authenticate>(context, listen: false)
        .tryAutoLogin()
        .then((value) async {
      var token = Provider.of<Authenticate>(context, listen: false).token;
      Provider.of<ApiCalls>(context, listen: false)
          .sendFCMDeviceModel(fcmDeviceModel, token)
          .then((value) {
        if (value == 200 || value == 201) {
          print('Fcm Sent Successfully');
          // Get.toNamed(HomePageScreen.routeName);
        }
      });
      // Provider.of<ApiCalls>(context, listen: false)
      //     .fetchBusinessProfileDetails(token)
      //     .then((value) async {
      //   if (value == 200 || value == 201) {}
      // });
    });
  }

  Future<bool> getProfileDetails() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('CustomerProfile')) {
      _consumerProfile = false;
      print(' Consumer Profile $_consumerProfile');
      return false;
    }
    final extratedUserData =
        //we should use dynamic as a another value not a Object
        json.decode(prefs.getString('CustomerProfile')!)
            as Map<String, dynamic>;

    orderDetails['Name'] = extratedUserData['First_Name'];
    orderDetails['Street'] = extratedUserData['Street'];
    orderDetails['City'] = extratedUserData['City'];
    orderDetails['Zip_Code'] = extratedUserData['Zip_Code'];
    orderDetails['State'] = extratedUserData['State'];
    orderDetails['Latitude'] = extratedUserData['Latitude'];
    orderDetails['Longitude'] = extratedUserData['Longitude'];

    _customerName = extratedUserData['First_Name'];
    _customerStreet = extratedUserData['Street'];
    _customerCity = extratedUserData['City'];
    _customerZipCode = extratedUserData['Zip_Code'];
    _customerState = extratedUserData['State'];
    _customerLatitude = extratedUserData['Latitude'];
    _customerLongitude = extratedUserData['Longitude'];
    _customerProfileCode = extratedUserData['Profile_Code'];
    _consumerProfile = true;
    print('Consumer Profile $_consumerProfile');
    return true;
  }

  @override
  void initState() {
    data = Get.arguments;
    _profileId = data['Profile_Id'];
    _profileCode = data['Profile_Code'];
    _userId = data['User_Id'];
    if (data.isNotEmpty) {
      for (var data in data['Order_Items']) {
        totalFoodPrice =
            totalFoodPrice + double.parse(data['Total_Food_Price'].toString());
      }
    }
    print('Total $totalFoodPrice');

    getWorkAddress();

    getProfileDetails().then((value) {
      if (value == true) {
        reRun();
      } else {
        Provider.of<Authenticate>(context, listen: false)
            .tryAutoLogin()
            .then((value) {
          var token = Provider.of<Authenticate>(context, listen: false).token;
          Provider.of<ApiCalls>(context, listen: false)
              .fetchUser(token)
              .then((value) {
            if (value['Status_Code'] == 200 || value['Status_Code'] == 201) {
              Provider.of<ApiCalls>(context, listen: false)
                  .fetchCustomerProfile(value['Id'], token)
                  .then((value) {
                if (value['StatusCode'] == 200) {
                  if (value['Body'] == null) {
                    refresh();
                  } else {
                    getProfileDetails().then((value) {
                      reRun();
                    });
                  }
                }
              });
            }
          });
        });
      }
    });

    super.initState();
  }

  void refresh() {
    setState(() {
      _consumerProfile = false;
    });
  }

  void reRun() {
    setState(() {});
  }

  Map<String, dynamic> data = {};

  Map<String, dynamic> workAddress = {
    'First_Name': '',
    'Last_Name': '',
    'Mobile': '',
    'Street': '',
    'User': '',
    'Latitude': '',
    'Longitude': '',
    'Profile_Code': '',
  };

  String getRandom(int length) {
    const ch = '1234567890';
    Random r = Random();
    return String.fromCharCodes(
        Iterable.generate(length, (_) => ch.codeUnitAt(r.nextInt(ch.length))));
  }

  Future<void> getWorkAddress() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('WorkAddress')) {
      _workAddress = false;
      return;
    }
    final extratedUserData =
        //we should use dynamic as a another value not a Object
        json.decode(prefs.getString('WorkAddress')!) as Map<String, dynamic>;

    workAddress = {
      'First_Name': extratedUserData['First_Name'],
      'Last_Name': extratedUserData['Last_Name'],
      'Mobile': extratedUserData['Mobile'],
      'Street': extratedUserData['Street'],
      'User': extratedUserData['User'],
      'Latitude': extratedUserData['Latitude'],
      'Longitude': extratedUserData['Longitude'],
      'Profile_Code': extratedUserData['Profile_Code'],
    };
    _workAddress = true;
  }

  void homeAddressSelected() {
    setState(() {
      _homeAddressSelected = true;
      _officeAddressSelected = false;
    });
  }

  void officeAddressSelected() {
    setState(() {
      _homeAddressSelected = false;
      _officeAddressSelected = true;
    });
  }

  Future<void> orderFood() async {
    var email = await HelperFunctions.getUserNameSharedPreference();
    print('helperfunction ${email}');
    if (_homeAddressSelected == true) {
      orderDetails = {
        'Order_Code': 'Order-${getRandom(5)}',
        'Profile': _profileId,
        'name': _profileCode,
        'Price': totalFoodPrice.toString(),
        'User': _userId,
        // 'name': _profileId,
        'Items': data['Order_Items'],
        'Name': _customerName,
        'Email': email,
        'Street': _customerStreet,
        'City': _customerCity,
        'State': _customerState,
        'Zip_Code': _customerZipCode,
        'Is_Paid': true,
        'Is_Shipped': false,
        'Latitude': _customerLatitude,
        'Longitude': _customerLongitude,
        'Payment_Type': orderDetails['Payment_Type'],
        'Service_fee': '0',
      };
      print(orderDetails);
    } else {
      orderDetails = {
        'Order_Code': 'Order-${getRandom(5)}',
        'Profile': _profileId,
        'name': _profileCode,
        'Price': totalFoodPrice.toString(),
        'User': _userId,
        // 'name': _profileId,
        'Items': data['Order_Items'],
        'Name': workAddress['First_Name'],
        'Email': email,
        'Street': workAddress['Street'],
        'City': '',
        'State': '',
        'Zip_Code': 0,
        'Is_Paid': true,
        'Is_Shipped': false,
        'Latitude': workAddress['Latitude'],
        'Longitude': workAddress['Longitude'],
        'Payment_Type': orderDetails['Payment_Type'],
        'Service_fee': '0',
      };
      print(orderDetails);
    }
    Provider.of<Authenticate>(context, listen: false)
        .tryAutoLogin()
        .then((value) async {
      var token = Provider.of<Authenticate>(context, listen: false).token;
      EasyLoading.show();
      Provider.of<ApiCalls>(context, listen: false)
          .bookFood(orderDetails['User'], orderDetails, token)
          .then((value) async {
        if (value['Status_Code'] == 200 || value['Status_Code'] == 201) {
          Get.offAllNamed(OrderInfoFirstPage.routeName,
              arguments: value['Body'],
              predicate: (route) =>
                  route ==
                  MaterialPageRoute(
                      builder: (BuildContext context) => NavBarScreen()));

          EasyLoading.showSuccess('Successfully Order Placed');
        } else {
          EasyLoading.showError('Order Failed Please try again');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var topPadding = MediaQuery.of(context).padding.top;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'Check Out',
          style: GoogleFonts.roboto(
            textStyle: const TextStyle(
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 90,
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 25,
                  ),
                  Text(
                    'Delivery',
                    style: GoogleFonts.roboto(
                        textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    )),
                  ),
                  const SizedBox(
                    width: 25,
                  ),
                  _consumerProfile == false
                      ? const Text('N/A')
                      : Container(
                          height: 70,
                          width: width * 0.5,
                          alignment: Alignment.center,
                          child: _homeAddressSelected == true
                              ? Text(
                                  '${_customerName ?? ''},${_customerStreet ?? ''},${_customerCity ?? ''},${_customerZipCode ?? ''}')
                              : Text(
                                  '${workAddress['First_Name'] ?? ''},${workAddress['Last_Name'] ?? ''},${workAddress['Street'] ?? ''},'),
                        ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                          onPressed: () async {
                            // var result =
                            // await Get.toNamed(ProfileSetUpPage.routeName);
                            // if(result=='Success')
                            // {

                            // }

                            showBottomSheet(width);
                          },
                          child: Image.asset(
                            'assets/images/address.png',
                            width: 30,
                            height: 30,
                            fit: BoxFit.contain,
                          )),
                    ),
                  )
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Divider(
                color: Colors.black,
              ),
            ),
            Row(
              children: [
                const Icon(
                  Icons.shopping_bag_rounded,
                  color: Colors.black,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  'Your Order',
                  style: GoogleFonts.roboto(
                      textStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data['Order_Items'].length,
              itemBuilder: (BuildContext context, int index) {
                // totalFoodPrice = totalFoodPrice +
                //     double.parse(
                //         _orderItems[index]['Total_Food_Price'].toString());
                // print(totalFoodPrice);
                print(
                    data['Order_Items'][index]['Total_Food_Price'].toString());
                return Padding(
                  padding: const EdgeInsets.only(top: 12.0, left: 38),
                  child: Row(
                    // mainAxisAlignment:
                    //     MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                          width: width * 0.3,
                          child: Text(
                            data['Order_Items'][index]['Food_Name'],
                            style: GoogleFonts.roboto(
                                textStyle: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500)),
                          )),
                      const SizedBox(
                        width: 20,
                      ),
                      SizedBox(
                        width: 20,
                        child: Text(data['Order_Items'][index]['Food_Quantity']
                            .toString()),
                      ),
                      const SizedBox(width: 20, child: Text('X')),
                      SizedBox(
                        width: 40,
                        child: Text(
                            '${data['Order_Items'][index]['Food_Price'].toString()} \$'),
                      ),
                      const SizedBox(width: 20, child: Text('=')),
                      SizedBox(
                        width: 60,
                        child: Text(
                            '${data['Order_Items'][index]['Total_Food_Price'].toString()} \$'),
                      ),
                    ],
                  ),
                );
              },
            ),
            const Padding(
              padding: EdgeInsets.only(top: 25.0),
              child: Divider(
                color: Colors.black,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: width * 0.09),
                  child: Text(
                    'Total Food Price',
                    style: GoogleFonts.roboto(
                        fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: width * 0.13),
                  child: Text(
                    '${totalFoodPrice.toString()} \$',
                    style: GoogleFonts.roboto(
                        fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: width * 0.09),
                    child: Text(
                      'Service Fee',
                      style: GoogleFonts.roboto(
                          fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: width * 0.13),
                    child: Text(
                      '0 \$',
                      style: GoogleFonts.roboto(
                          fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: Divider(
                color: Colors.black,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: width * 0.09),
                  child: Text(
                    'Grand Total',
                    style: GoogleFonts.roboto(
                        fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: width * 0.13),
                  child: Text(
                    '${totalFoodPrice.toString()} \$',
                    style: GoogleFonts.roboto(
                        fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.payment,
                    color: Colors.black,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Payment Type',
                    style: GoogleFonts.roboto(
                        textStyle: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  Radio(
                      activeColor: Colors.orange,
                      value: payment.debitOrCredit,
                      groupValue: paymentSelected,
                      onChanged: (value) {
                        setState(() {
                          paymentSelected = value as payment;
                          orderDetails['Payment_Type'] =
                              'Using credit/debit card';
                          print(orderDetails['Payment_Type']);
                        });
                      }),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Debit or Credit card',
                    style: GoogleFonts.roboto(
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w400)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  Radio(
                      activeColor: Colors.orange,
                      value: payment.payOnDelivery,
                      groupValue: paymentSelected,
                      onChanged: (value) {
                        setState(() {
                          paymentSelected = value as payment;
                          orderDetails['Payment_Type'] = 'Paid on Delivery';
                          print(orderDetails['Payment_Type']);
                        });
                      }),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Pay on delivery(POD)',
                    style: GoogleFonts.roboto(
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w400)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.only(bottom: 10.0, right: 20, left: 20),
        child: GestureDetector(
          onTap: () async {
            if (_consumerProfile == false) {
              Get.defaultDialog(
                  title: 'Alert',
                  middleText: 'Select the Delivery Address First',
                  confirm: TextButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: const Text('Ok')));
            } else {
              if (paymentSelected == payment.debitOrCredit) {
                await makePayment().then((value) {});
              } else {
                sendFcmDeviceModel();
                orderFood();
              }
            }
          },
          child: Container(
            width: width - 40,
            height: 45,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10), color: Colors.orange),
            alignment: Alignment.center,
            child: Text(
              'Order',
              style: GoogleFonts.roboto(
                  textStyle:
                      const TextStyle(color: Colors.white, fontSize: 25)),
            ),
          ),
        ),
      ),
    );
  }

  void showBottomSheet(var width) {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return StatefulBuilder(
            builder: (BuildContext context, setState) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'Saved Address',
                          style: GoogleFonts.roboto(
                            textStyle: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    _consumerProfile == false
                        ? const SizedBox()
                        : GestureDetector(
                            onTap: () {
                              homeAddressSelected();
                              Get.back();
                            },
                            child: Container(
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.home,
                                  ),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'Home',
                                            style: GoogleFonts.roboto(
                                                textStyle: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.w500)),
                                          ),
                                          // SizedBox(
                                          //   width: width * 0.2,
                                          // ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10.0),
                                            child: IconButton(
                                                onPressed: () async {
                                                  var result =
                                                      await Get.toNamed(
                                                          EditProfileSetUp
                                                              .routeName);

                                                  if (result == 'Success') {
                                                    Provider.of<Authenticate>(
                                                            context,
                                                            listen: false)
                                                        .tryAutoLogin()
                                                        .then((value) {
                                                      var token = Provider.of<
                                                                  Authenticate>(
                                                              context,
                                                              listen: false)
                                                          .token;
                                                      Provider.of<ApiCalls>(
                                                              context,
                                                              listen: false)
                                                          .fetchUser(token)
                                                          .then((value) {
                                                        if (value['Status_Code'] ==
                                                                200 ||
                                                            value['Status_Code'] ==
                                                                201) {
                                                          Provider.of<ApiCalls>(
                                                                  context,
                                                                  listen: false)
                                                              .fetchCustomerProfile(
                                                                  value['Id'],
                                                                  token)
                                                              .then((value) {
                                                            if (value[
                                                                    'StatusCode'] ==
                                                                200) {
                                                              if (value[
                                                                      'Body'] ==
                                                                  null) {
                                                                refresh();
                                                              } else {
                                                                getProfileDetails()
                                                                    .then(
                                                                        (value) {
                                                                  reRun();
                                                                  setState(
                                                                      () {});
                                                                });
                                                              }
                                                            }
                                                          });
                                                        }
                                                      });
                                                    });
                                                  }
                                                },
                                                icon: const Icon(Icons.edit)),
                                          )
                                        ],
                                      ),
                                      Container(
                                        width: width * 0.7,
                                        height: 60,
                                        child: Text(
                                            '${_customerName ?? ''},${_customerStreet ?? ''},${_customerCity ?? ''},${_customerZipCode ?? ''}'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                    _workAddress == false
                        ? const SizedBox()
                        : GestureDetector(
                            onTap: () {
                              officeAddressSelected();
                              Get.back();
                            },
                            child: Container(
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.work,
                                  ),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        'Office',
                                        style: GoogleFonts.roboto(
                                            textStyle: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w500)),
                                      ),
                                      Container(
                                        width: width * 0.7,
                                        height: 60,
                                        child: Text(
                                            '${workAddress['First_Name'] ?? ''},${workAddress['Last_Name'] ?? ''},${workAddress['Street'] ?? ''},'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                    _consumerProfile == false
                        ? GestureDetector(
                            onTap: () async {
                              var result =
                                  await Get.toNamed(ProfileSetUpPage.routeName);
                              if (result == 'Success') {
                                Provider.of<Authenticate>(context,
                                        listen: false)
                                    .tryAutoLogin()
                                    .then((value) {
                                  var token = Provider.of<Authenticate>(context,
                                          listen: false)
                                      .token;
                                  Provider.of<ApiCalls>(context, listen: false)
                                      .fetchUser(token)
                                      .then((value) {
                                    if (value['Status_Code'] == 200 ||
                                        value['Status_Code'] == 201) {
                                      Provider.of<ApiCalls>(context,
                                              listen: false)
                                          .fetchCustomerProfile(
                                              value['Id'], token)
                                          .then((value) {
                                        if (value['StatusCode'] == 200) {
                                          if (value['Body'] == null) {
                                            refresh();
                                          } else {
                                            getProfileDetails().then((value) {
                                              reRun();
                                              setState(() {});
                                            });
                                          }
                                        }
                                      });
                                    }
                                  });
                                });
                              }
                            },
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.add,
                                  color: Colors.red,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'Add Address',
                                  style: GoogleFonts.roboto(
                                      textStyle: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500)),
                                )
                              ],
                            ),
                          )
                        : GestureDetector(
                            onTap: () async {
                              var result = await Get.toNamed(
                                  SelectAddressPage.routeName);
                              if (result['Status'] == 'Success') {
                                getWorkAddress().then((value) {
                                  setState(() {});
                                });
                              }
                            },
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.add,
                                  color: Colors.red,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'Add Address',
                                  style: GoogleFonts.roboto(
                                      textStyle: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500)),
                                )
                              ],
                            ),
                          ),
                  ],
                ),
              );
            },
          );
        });
  }

  Future<void> makePayment() async {
    EasyLoading.show();

    print(totalFoodPrice);
    String amount = double.parse(totalFoodPrice.toString()).round().toString();
    print(amount);
    try {
      paymentIntentData = await createPaymentIntent(amount, 'INR');
      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: paymentIntentData!['client_secret'],
        // applePay: true,
        // googlePay: true,
        style: ThemeMode.system,
        merchantCountryCode: 'INR',
        merchantDisplayName: 'Sudeendra',
      ))
          .then((value) {
        EasyLoading.dismiss();
      });

      displayPaymentSheet();
    } catch (e) {
      print(e.toString());
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card'
      };

      var response = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body,
          headers: {
            'Authorization':
                'Bearer sk_test_51KMUpeSAYfEkrbYeQ3eCEngsqbEttKwR70hXYZu8NqujZtztkgApac69MCvHQTxCbFMzN6Jjor23WA6QsFen80UJ00tOUGbTcu',
            'Content-Type': 'application/x-www-form-urlencoded',
          });

      return jsonDecode(response.body.toString());
    } catch (e) {
      print(e.toString());
    }
  }

  calculateAmount(String amount) {
    final price = int.parse(amount) * 100;
    return price.toString();
  }

  void displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet(
          parameters: PresentPaymentSheetParameters(
        clientSecret: paymentIntentData!['client_secret'],
        confirmPayment: true,
      ));
      setState(() {
        paymentIntentData = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Paid Successfully'),
        ),
      );
      sendFcmDeviceModel();
      orderFood();
    } on StripeException catch (e) {
      print(e.toString());

      Get.defaultDialog(title: 'Alert', middleText: 'Cancelled');
    }
  }
}

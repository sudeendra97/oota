import 'dart:convert';
import 'dart:developer';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oota/authentication/providers/api_calls.dart';
import 'package:oota/authentication/providers/authenticate.dart';
import 'package:oota/authentication/screens/profile_setup_page.dart';
import 'package:oota/home/screens/check_outpage.dart';
import 'package:oota/home/screens/select_address.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletons/skeletons.dart';

enum status { home, newAddress }

class MenuPageScreen extends StatefulWidget {
  MenuPageScreen({Key? key}) : super(key: key);

  static const routeName = '/MenuPage';

  @override
  _MenuPageScreenState createState() => _MenuPageScreenState();
}

class _MenuPageScreenState extends State<MenuPageScreen> {
  status statusSelected = status.home;
  var _profileId;

  List menuList = [];

  num horizontalPadding = 20;

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
  };

  List<Map<String, dynamic>> _orderItems = [];

  var orderItemLength = 0.obs;

  var _userName;

  double _totalFoodPrice = 0;

  var data;

  var _userId;

  var _profilCode;

  var _customerName;

  var _customerStreet;

  var _customerCity;

  var _customerZipCode;

  var _customerState;

  var _customerLatitude;

  var _customerLongitude;

  // @override
  // void didChangeDependencies() {
  //   if (data == 'success') {
  //     print('success');
  //     getAddress();
  //   }
  //   super.didChangeDependencies();
  // }

  Map<String, dynamic> newAddress = {
    'Name': '',
    'Street': '',
    'City': '',
    'State': '',
    'Zip_Code': '',
    'Latitude': '',
    'Longitude': '',
  };

  var _businessName;

  String getRandom(int length) {
    const ch = '1234567890';
    Random r = Random();
    return String.fromCharCodes(
        Iterable.generate(length, (_) => ch.codeUnitAt(r.nextInt(ch.length))));
  }

  Future<void> getAddress() async {
    final prefs = await SharedPreferences.getInstance();
    final extratedUserData =
        //we should use dynamic as a another value not a Object
        json.decode(prefs.getString('Address')!) as Map<String, dynamic>;
    print(extratedUserData);
    orderDetails['Name'] = extratedUserData['address']['Name'];
    orderDetails['Street'] = extratedUserData['address']['Street'];
    orderDetails['City'] = extratedUserData['address']['City'];
    orderDetails['State'] = extratedUserData['address']['State'];
    orderDetails['Zip_Code'] = extratedUserData['address']['Zip_Code'];
    orderDetails['Latitude'] = extratedUserData['address']['Latitude'];
    orderDetails['Longitude'] = extratedUserData['address']['Longitude'];
    newAddress['Name'] = extratedUserData['address']['Name'];
    newAddress['Street'] = extratedUserData['address']['Street'];
    newAddress['City'] = extratedUserData['address']['City'];
    newAddress['State'] = extratedUserData['address']['State'];
    newAddress['Zip_Code'] = extratedUserData['address']['Zip_Code'];
    newAddress['Latitude'] = extratedUserData['address']['Latitude'];
    newAddress['Longitude'] = extratedUserData['address']['Longitude'];
  }

  void recordOrder(Map<String, dynamic> data) {
    bool valueChanged = false;

    if (_orderItems.isEmpty) {
      _orderItems.add(data);
      _totalFoodPrice = double.parse(data['Total_Food_Price'].toString());
      orderItemLength.value = _orderItems.length;
    } else {
      print('running');

      for (int i = 0; i < _orderItems.length; i++) {
        if (_orderItems[i]['Food_Id'] == data['Food_Id']) {
          print('InIf');

          _orderItems[i]['Food_Quantity'] = data['Food_Quantity'];

          if (_orderItems[i]['Food_Quantity'] == 0) {
            _totalFoodPrice = _totalFoodPrice -
                double.parse(_orderItems[i]['Food_Price'].toString());
            _orderItems.removeAt(i);
            orderItemLength.value = _orderItems.length;
            return;
          } else {
            if (_orderItems[i]['Food_Quantity'] >= 2) {
              _orderItems[i]['Total_Food_Price'] =
                  int.parse(_orderItems[i]['Food_Quantity'].toString()) *
                      double.parse(_orderItems[i]['Food_Price'].toString());
              _totalFoodPrice = _totalFoodPrice +
                  double.parse(_orderItems[i]['Food_Price'].toString());
            } else {
              _orderItems[i]['Total_Food_Price'] = data['Food_Price'];
              _totalFoodPrice = _totalFoodPrice +
                  double.parse(_orderItems[i]['Total_Food_Price'].toString());
            }
          }

          valueChanged = true;
        }
      }

      if (valueChanged == false) {
        _orderItems.add(data);
        _totalFoodPrice =
            _totalFoodPrice + double.parse(data['Total_Food_Price'].toString());
        orderItemLength.value = _orderItems.length;
      }
    }
    print(_orderItems);
    print(_totalFoodPrice);
  }

  Route createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(-1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeIn;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  Future<void> getProfileDetails() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('CustomerProfile')) {
      return;
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
  }

  @override
  void initState() {
    getProfileDetails();
    var data = Get.arguments;
    _profileId = data['Profile_Id'];
    _userName = data['UserName'];
    _profilCode = data['Profile_Code'];
    _businessName = data['Business_Name'];
    Provider.of<Authenticate>(context, listen: false)
        .tryAutoLogin()
        .then((value) {
      var token = Provider.of<Authenticate>(context, listen: false).token;
      Provider.of<ApiCalls>(context, listen: false)
          .fetchUser(token)
          .then((value) {
        if (value['Status_Code'] == 200 || value['Status_Code'] == 201) {
          _userId = value['Id'];
          orderDetails['User'] = value['Id'];
        }
      });

      Provider.of<ApiCalls>(context, listen: false)
          .fetchMenuItems(
        token,
        _profileId,
      )
          .then((value) {
        if (value['Status_Code'] == 200 || value['Status_Code'] == 201) {
          if (value['Response_Body'].isEmpty) {
            setState(() {
              _menuList = false;
            });
          }
        }
      });

      // Provider.of<ApiCalls>(context, listen: false)
      //     .fetchProfileDetails(token)
      //     .then((value) {
      //   if (value == 200 || value == 201) {
      //     // _profileId = value['Response_Body'][0]['Profile_Id'];

      //     print(value);

      //   }
      // });
    });

    super.initState();
  }

  bool _menuList = true;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    menuList = Provider.of<ApiCalls>(context).menuList;
    return WillPopScope(
      onWillPop: () async {
        menuList.clear();
        return true;
      },
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black),
            // automaticallyImplyLeading: false,
            title: Text(
              'Menu',
              style: GoogleFonts.roboto(
                textStyle: const TextStyle(color: Colors.black),
              ),
            ),
          ),
          body: menuList.isEmpty && _menuList == true
              ? skeletonDesign()
              : _menuList == false
                  ? Center(
                      child: Text(
                        'No Items To Display',
                        style: GoogleFonts.roboto(
                            textStyle: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500)),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(bottom: 60.0),
                      child: ListView.builder(
                        itemCount: menuList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return MenuItem(
                            foodName: menuList[index]['Food_Name'],
                            description: menuList[index]['Description'],
                            price: menuList[index]['Price'],
                            image: menuList[index]['Food_Image'],
                            allergen: menuList[index]['Allergen'],
                            foodId: menuList[index]['Food_Id'],
                            ingrediants: menuList[index]['Ingredients'],
                            preparationTime:
                                menuList[index]['Preparation_Time'].toString(),
                            profile: menuList[index]['Profile'],
                            inStock: menuList[index]['In_Stock'],
                            key: UniqueKey(),
                            data: recordOrder,
                            recommended: menuList[index]['Recommended'],
                          );
                        },
                      ),
                    ),
          bottomSheet: Container(
            width: width,
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 50,
                  width: width - horizontalPadding,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(10)),
                  child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.black)),
                      onPressed: () {
                        if (_orderItems.isEmpty) {
                          Get.defaultDialog(
                              title: 'Alert',
                              middleText: 'Select the Items First',
                              confirm: TextButton(
                                  onPressed: () {
                                    Get.back();
                                  },
                                  child: const Text('Ok')));
                        } else {
                          Get.toNamed(CheckOutPage.routeName, arguments: {
                            'Order_Items': _orderItems,
                            'Profile_Id': _profileId,
                            'Profile_Code': _profilCode,
                            'User_Id': _userId
                          });
                        }

                        // _modalBottomSheetMenu();
                      },
                      child: Obx(() => Text(
                            'Next(${orderItemLength})',
                            style: GoogleFonts.roboto(fontSize: 18),
                          ))),
                ),
              ],
            ),
          )),
    );
  }

  SkeletonListView skeletonDesign() => SkeletonListView(
        item: SkeletonListTile(
          hasLeading: false,
          trailing: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 74,
                height: 108,
                alignment: Alignment.topCenter,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    shape: BoxShape.rectangle,
                    border: Border.all(color: Colors.grey)),
              ),
            ),
          ),
          verticalSpacing: 12,
          leadingStyle: SkeletonAvatarStyle(
              width: 64, height: 64, shape: BoxShape.circle),
          titleStyle: SkeletonLineStyle(
              height: 80,
              minLength: MediaQuery.of(context).size.width / 2,
              randomLength: true,
              borderRadius: BorderRadius.circular(12)),
          subtitleStyle: SkeletonLineStyle(
              height: 25,
              minLength: MediaQuery.of(context).size.width * 2 / 3,
              randomLength: true,
              borderRadius: BorderRadius.circular(12)),
          hasSubtitle: true,
        ),
      );

  void _modalBottomSheetMenu() {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return StatefulBuilder(
            builder: (BuildContext context, setState) {
              var width = MediaQuery.of(context).size.width;
              double totalFoodPrice = 0;
              return Container(
                height: 800.0,
                color: Colors
                    .transparent, //could change this to Color(0xFF737373),
                //so you don't have to change MaterialApp canvasColor
                child: Container(
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0))),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 20),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Order Details',
                            style: GoogleFonts.roboto(
                                textStyle: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w500)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Card(
                              elevation: 3,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 13),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: _orderItems.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        totalFoodPrice = totalFoodPrice +
                                            double.parse(_orderItems[index]
                                                    ['Total_Food_Price']
                                                .toString());
                                        print(totalFoodPrice);
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(top: 12.0),
                                          child: Row(
                                            // mainAxisAlignment:
                                            //     MainAxisAlignment.spaceAround,
                                            children: [
                                              SizedBox(
                                                  width: width * 0.3,
                                                  child: Text(
                                                    _orderItems[index]
                                                        ['Food_Name'],
                                                    style: GoogleFonts.roboto(
                                                        textStyle:
                                                            const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500)),
                                                  )),
                                              const SizedBox(
                                                width: 20,
                                              ),
                                              SizedBox(
                                                width: 20,
                                                child: Text(_orderItems[index]
                                                        ['Food_Quantity']
                                                    .toString()),
                                              ),
                                              const SizedBox(
                                                  width: 20, child: Text('X')),
                                              SizedBox(
                                                width: 40,
                                                child: Text(_orderItems[index]
                                                        ['Food_Price']
                                                    .toString()),
                                              ),
                                              const SizedBox(
                                                  width: 20, child: Text('=')),
                                              SizedBox(
                                                width: 60,
                                                child: Text(_orderItems[index]
                                                        ['Total_Food_Price']
                                                    .toString()),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(top: 8),
                                      child: Divider(
                                        color: Colors.black,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 12.0),
                                      child: Row(
                                        children: [
                                          const SizedBox(
                                            width: 140,
                                          ),
                                          Text(
                                            'Total',
                                            style: GoogleFonts.roboto(
                                                textStyle: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w500)),
                                          ),
                                          const SizedBox(
                                            width: 60,
                                          ),
                                          Text(
                                            _totalFoodPrice.toString(),
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 18.0),
                            child: Column(
                              children: [
                                Text(
                                  'Delivery Address',
                                  style: GoogleFonts.roboto(
                                      textStyle: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 18)),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Radio(
                                        value: status.home,
                                        groupValue: statusSelected,
                                        onChanged: (value) {
                                          setState(() {
                                            statusSelected = value as status;
                                            getProfileDetails();
                                          });
                                        }),
                                    Expanded(
                                      child: Text(
                                          'Name:${_customerName}, Street:${_customerStreet}, City: ${_customerCity}, Zip_Code: ${_customerZipCode}'),
                                    ),
                                  ],
                                ),
                                data == null
                                    ? SizedBox()
                                    : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Radio(
                                              value: status.newAddress,
                                              groupValue: statusSelected,
                                              onChanged: (value) {
                                                setState(() {
                                                  statusSelected =
                                                      value as status;
                                                  getAddress();
                                                });
                                              }),
                                          Expanded(
                                            child: Text(
                                                'Name:${newAddress['Name']}, Street:${newAddress['Street']}, City: ${newAddress['City']}, Zip_Code: ${newAddress['Zip_Code']}'),
                                          ),
                                        ],
                                      )
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  data = await Get.toNamed(
                                      SelectAddressScreen.routeName);

                                  if (data == 'success') {
                                    getAddress().then((value) {
                                      setState(() {});
                                    });
                                  }

                                  // for (var data in _orderItems) {
                                  //   _totalFoodPrice = _totalFoodPrice +
                                  //       double.parse(
                                  //           data['Total_Food_Price'].toString());
                                  // }

                                  // orderDetails = {
                                  //   'profile': _profileId,
                                  //   'Price': _totalFoodPrice.toString(),
                                  //   'name': _userName,
                                  //   'items': _orderItems,

                                  // };
                                  // print(orderDetails);

                                  // Provider.of<Authenticate>(context, listen: false)
                                  //     .tryAutoLogin()
                                  //     .then((value) {
                                  //   var token = Provider.of<Authenticate>(context,
                                  //           listen: false)
                                  //       .token;

                                  //   Provider.of<ApiCalls>(context, listen: false)
                                  //       .bookFood(orderDetails, token)
                                  //       .then((value) async {
                                  //     if (value == 200 || value == 201) {}
                                  //   });
                                  // });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 20.0),
                                  child: Container(
                                    width: 100,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.red,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Add Address',
                                      style: GoogleFonts.roboto(
                                          textStyle: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500)),
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  EasyLoading.show();
                                  // for (var data in _orderItems) {
                                  //   _totalFoodPrice = _totalFoodPrice +
                                  //       double.parse(data['Total_Food_Price']
                                  //           .toString());
                                  // }

                                  orderDetails = {
                                    'Order_Code': 'Order-${getRandom(5)}',
                                    'Profile': _profileId,
                                    'name': _profilCode,
                                    'Price': _totalFoodPrice.toString(),
                                    'User': orderDetails['User'],
                                    // 'name': _profileId,
                                    'Items': _orderItems,
                                    'Name': orderDetails['Name'],
                                    'Email': 'sudeendrapacharya@gmail.com',
                                    'Street': orderDetails['Street'],
                                    'City': orderDetails['City'],
                                    'State': orderDetails['State'],
                                    'Zip_Code': orderDetails['Zip_Code'],
                                    'Is_Paid': true,
                                    'Is_Shipped': false,
                                    'Latitude': orderDetails['Latitude'],
                                    'Longitude': orderDetails['Longitude'],
                                  };
                                  print(orderDetails);

                                  Provider.of<Authenticate>(context,
                                          listen: false)
                                      .tryAutoLogin()
                                      .then((value) async {
                                    var token = Provider.of<Authenticate>(
                                            context,
                                            listen: false)
                                        .token;
                                    await Provider.of<ApiCalls>(context,
                                            listen: false)
                                        .fetchUser(token)
                                        .then((value) async {
                                      if (value['Status_Code'] == 200 ||
                                          value['Status_Code'] == 201) {
                                        // Get.toNamed(HomePageScreen.routeName);
                                        // Get.toNamed(ProfileSetUpPage.routeName)
                                        // ;

                                        Provider.of<ApiCalls>(context,
                                                listen: false)
                                            .fetchCustomerProfile(
                                                value['Id'], token)
                                            .then((value) {
                                          if (value['StatusCode'] == 200) {
                                            if (value['Body'] == null) {
                                              // EasyLoading.dismiss();
                                              Get.toNamed(
                                                  ProfileSetUpPage.routeName);
                                            } else {
                                              // EasyLoading.dismiss();
                                              // EasyLoading.dismiss();

                                            }
                                          } else {
                                            EasyLoading.showError(
                                                'Something Went Wrong Please Try Again');
                                          }
                                        });
                                      } else {
                                        EasyLoading.showError(
                                            'Something Went Wrong Please Try Again');
                                      }
                                    });

                                    Provider.of<ApiCalls>(context,
                                            listen: false)
                                        .bookFood(orderDetails['User'],
                                            orderDetails, token)
                                        .then((value) async {
                                      if (value == 200 || value == 201) {
                                        Get.back();
                                        EasyLoading.showSuccess(
                                            'Success Order Placed ');
                                      } else {
                                        EasyLoading.showError(
                                            'Order Failed Please try again');
                                      }
                                    });
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 20.0),
                                  child: Container(
                                    width: 100,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.red,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Order',
                                      style: GoogleFonts.roboto(
                                          textStyle: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500)),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        });
  }
}

class MenuItem extends StatefulWidget {
  MenuItem(
      {Key? key,
      required this.foodName,
      required this.description,
      required this.price,
      required this.image,
      required this.foodId,
      required this.profile,
      required this.ingrediants,
      required this.allergen,
      required this.preparationTime,
      required this.inStock,
      required this.data,
      required this.recommended})
      : super(key: key);

  final String foodName;
  final String description;
  final String price;
  final String image;
  final int foodId;
  final int profile;
  final String ingrediants;
  final String allergen;
  final String preparationTime;
  bool inStock;
  bool recommended;
  final ValueChanged<Map<String, dynamic>> data;

  @override
  _MenuItemState createState() => _MenuItemState();
}

class _MenuItemState extends State<MenuItem> {
  Map<String, dynamic> orderDetails = {
    'Price': '',
    'Name': '',
    'Items': [],
  };

  List _orderItems = [];

  bool _isExpanded = false;

  var count = 0;

  TextStyle headingStyle() {
    return GoogleFonts.roboto(
        textStyle: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
    ));
  }

  void refreshCount(int data) {
    setState(() {
      count = data;
    });
  }

  void order() {}

  void _modalBottomSheetMenu(var count, ValueChanged<int> changed) {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return StatefulBuilder(
            builder: (BuildContext context, setState) {
              return Container(
                height: 500.0,
                color: Colors
                    .transparent, //could change this to Color(0xFF737373),
                //so you don't have to change MaterialApp canvasColor
                child: Container(
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0))),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text('Image'),
                        Padding(
                          padding: const EdgeInsets.only(top: 50.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text('Item Name'),
                              Padding(
                                padding: const EdgeInsets.only(top: 15.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.red),
                                      borderRadius: BorderRadius.circular(8)),
                                  width: 120,
                                  height: 30,
                                  child: Row(
                                    // crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          if (count == null || count == 0) {
                                            return;
                                          } else {
                                            setState(() {
                                              count = count - 1;
                                              widget.data({
                                                'Food_Id': widget.foodId,
                                                'Food_Quantity': count,
                                                'Food_Price': widget.price,
                                                'Food_Name': widget.foodName,
                                              });
                                            });
                                          }

                                          // changed(count);
                                        },
                                        child: Container(
                                            // alignment: Alignment.topCenter,
                                            child: const Icon(Icons
                                                .remove_circle_outline_outlined)),
                                      ),
                                      Text(count.toString()),
                                      GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              count = count + 1;
                                              widget.data({
                                                'Food_Id': widget.foodId,
                                                'Food_Quantity': count,
                                                'Food_Price': widget.price,
                                                'Food_Name': widget.foodName,
                                              });
                                            });
                                            // count = count + 1;
                                            // changed(count);
                                          },
                                          child: const Icon(Icons.add)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Container(
                              width: 100,
                              height: 30,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.red,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text('Save'),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    print(widget.inStock.toString());
    var width = MediaQuery.of(context).size.width;
    return _isExpanded == true
        ? Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (_isExpanded == true) {
                    _isExpanded = false;
                  } else {
                    _isExpanded = true;
                  }
                });
              },
              child: Container(
                width: width,
                height: 375,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          height: 180,
                          width: width - 20,
                          child: CachedNetworkImage(
                            placeholder: (context, url) => Center(
                              child: Container(
                                width: 30,
                                height: 30,
                                child: const CircularProgressIndicator(),
                              ),
                            ),
                            imageUrl: widget.image,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          // mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 3.0),
                              child: Text(
                                widget.foodName,
                                style: headingStyle(),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 3.0),
                              child: Text(
                                  '${String.fromCharCodes(Runes('\u0024'))}${widget.price}'),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 3.0),
                              child: Text(widget.description),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 3.0),
                              child: Text('${widget.allergen}(Allergen)'),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 3.0),
                              child: Text(
                                  '${widget.preparationTime}(Preparation Time)'),
                            ),
                          ],
                        ),
                      ),
                      const Divider(
                        color: Colors.black,
                      ),
                      SizedBox(
                        height: 30,
                        child: Row(
                          // mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            widget.recommended == true
                                ? Row(
                                    children: const [
                                      Icon(
                                        Icons.thumb_up,
                                        size: 18,
                                        color: Colors.green,
                                      ),
                                      Text(' Recommended'),
                                    ],
                                  )
                                : Row(
                                    children: const [
                                      Icon(
                                        Icons.thumb_up_alt_outlined,
                                        size: 18,
                                        // color: Colors.green,
                                      ),
                                      Text(' Recommended'),
                                    ],
                                  ),
                            Row(
                              children: [
                                widget.inStock == true
                                    ? const Text('In Stock')
                                    : const Text('Out Of Stock')
                              ],
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.red),
                                  borderRadius: BorderRadius.circular(8)),
                              width: 100,
                              height: 30,
                              child: Row(
                                // crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  GestureDetector(
                                    onTap: widget.inStock == false
                                        ? () {}
                                        : () {
                                            if (count == 0) {
                                              return;
                                            } else {
                                              setState(() {
                                                count = count - 1;
                                                widget.data({
                                                  'Food_Id': widget.foodId,
                                                  'Food_Quantity': count,
                                                  'Food_Price': widget.price,
                                                  'Food_Name': widget.foodName,
                                                  'Total_Food_Price':
                                                      widget.price,
                                                });
                                              });
                                            }

                                            // changed(count);
                                          },
                                    child: Container(
                                        // alignment: Alignment.topCenter,
                                        child: const Icon(Icons
                                            .remove_circle_outline_outlined)),
                                  ),
                                  Text(count.toString()),
                                  GestureDetector(
                                      onTap: widget.inStock == false
                                          ? () {}
                                          : () {
                                              setState(() {
                                                count = count + 1;
                                                widget.data({
                                                  'Food_Id': widget.foodId,
                                                  'Food_Quantity': count,
                                                  'Food_Price': widget.price,
                                                  'Food_Name': widget.foodName,
                                                  'Total_Food_Price':
                                                      widget.price,
                                                });
                                              });
                                              // count = count + 1;
                                              // changed(count);
                                            },
                                      child: Icon(Icons.add)),
                                ],
                              ),
                            ),
                            // GestureDetector(
                            //   onTap: () {},
                            //   child: Row(
                            //     mainAxisAlignment: MainAxisAlignment.start,
                            //     children: const [
                            //       Icon(Icons.add),
                            //       Text('Add'),
                            //     ],
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                      const Divider(
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        : GestureDetector(
            onTap: () {
              setState(() {
                if (_isExpanded == true) {
                  _isExpanded = false;
                } else {
                  _isExpanded = true;
                }
              });
              // _modalBottomSheetMenu();
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Container(
                width: width,
                height: 180,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            // mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 3.0),
                                child: Text(
                                  widget.foodName,
                                  style: headingStyle(),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 3.0),
                                child: Text(
                                    '${String.fromCharCodes(Runes('\u0024'))}${widget.price}'),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 3.0),
                                child: Text(widget.description),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 100,
                                height: 100,
                                child: CachedNetworkImage(
                                  placeholder: (context, url) => Center(
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      child: const CircularProgressIndicator(),
                                    ),
                                  ),
                                  imageUrl: widget.image,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      const Divider(
                        color: Colors.black,
                      ),
                      SizedBox(
                        height: 30,
                        child: Row(
                          // mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            widget.recommended == true
                                ? Row(
                                    children: const [
                                      Icon(
                                        Icons.thumb_up,
                                        size: 18,
                                        color: Colors.green,
                                      ),
                                      Text(' Recommended'),
                                    ],
                                  )
                                : Row(
                                    children: const [
                                      Icon(
                                        Icons.thumb_up_alt_outlined,
                                        size: 18,
                                        // color: Colors.green,
                                      ),
                                      Text(' Recommended'),
                                    ],
                                  ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                widget.inStock == true
                                    ? const Text('In Stock')
                                    : const Text('Out Of Stock')
                              ],
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.red),
                                  borderRadius: BorderRadius.circular(8)),
                              width: 100,
                              height: 30,
                              child: Row(
                                // crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  GestureDetector(
                                    onTap: widget.inStock == false
                                        ? () {}
                                        : () {
                                            if (count == 0) {
                                              return;
                                            } else {
                                              setState(() {
                                                count = count - 1;
                                                widget.data({
                                                  'Food_Id': widget.foodId,
                                                  'Food_Quantity': count,
                                                  'Food_Price': widget.price,
                                                  'Food_Name': widget.foodName,
                                                  'Total_Food_Price':
                                                      widget.price,
                                                });
                                              });
                                            }

                                            // changed(count);
                                          },
                                    child: Container(
                                        // alignment: Alignment.topCenter,
                                        child: const Icon(Icons
                                            .remove_circle_outline_outlined)),
                                  ),
                                  Text(count.toString()),
                                  GestureDetector(
                                      onTap: widget.inStock == false
                                          ? () {}
                                          : () {
                                              setState(() {
                                                count = count + 1;
                                                widget.data({
                                                  'Food_Id': widget.foodId,
                                                  'Food_Quantity': count,
                                                  'Food_Price': widget.price,
                                                  'Food_Name': widget.foodName,
                                                  'Total_Food_Price':
                                                      widget.price,
                                                });
                                              });
                                              // count = count + 1;
                                              // changed(count);
                                            },
                                      child: Icon(Icons.add)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }

  Future<void> updateStock(var data) async {
    Provider.of<Authenticate>(context, listen: false)
        .tryAutoLogin()
        .then((value) {
      var token = Provider.of<Authenticate>(context, listen: false).token;

      Provider.of<ApiCalls>(context, listen: false)
          .updateStockValue(data, widget.foodId, token)
          .then((value) {
        if (value != 202) {
          Get.showSnackbar(GetSnackBar(
            duration: const Duration(seconds: 2),
            backgroundColor: Theme.of(context).backgroundColor,
            message: 'Something went wrong Please try again',
            title: 'Failed',
          ));
          setState(() {
            widget.inStock = false;
          });
        } else {
          Get.showSnackbar(GetSnackBar(
            duration: const Duration(seconds: 2),
            backgroundColor: Theme.of(context).backgroundColor,
            message: 'Successfully Updated your Menu List',
            title: 'Success',
          ));
        }
      });
    });
  }

  Future<dynamic> alertDialogs(
      BuildContext context, var alertMessage, var booleanValue) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Alert'),
        content: Text(alertMessage),
        actions: [
          FlatButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Cancel'),
          ),
          FlatButton(
            onPressed: () {
              setState(() {
                widget.inStock = booleanValue;
                updateStock(booleanValue);
              });

              Navigator.of(ctx).pop();
            },
            child: const Text('ok'),
          )
        ],
      ),
    );
  }
}

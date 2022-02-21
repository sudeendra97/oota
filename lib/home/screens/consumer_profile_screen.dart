import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oota/authentication/providers/api_calls.dart';
import 'package:oota/authentication/providers/authenticate.dart';
import 'package:oota/authentication/screens/log_in.dart';
import 'package:oota/home/screens/order_history.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chat_history.dart';
import 'edit_profile_setup.dart';

class ConsumerProfileScreen extends StatefulWidget {
  ConsumerProfileScreen({Key? key}) : super(key: key);

  static const routeName = '/ConsumerProfileScreen';

  @override
  _ConsumerProfileScreenState createState() => _ConsumerProfileScreenState();
}

class _ConsumerProfileScreenState extends State<ConsumerProfileScreen> {
  var token;

  var firstName;

  var lastName;

  var mobile;

  var street;

  var city;

  var state;

  var zipCode;

  Map<String, dynamic> consumerProfile = {};

  var consumerId;

  var width;

  @override
  void initState() {
    getConsumerDetails();
    super.initState();
  }

  Future<void> getConsumerDetails() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('CustomerProfile')) {
      print('Entering Memory');
      var responseData = json.decode(prefs.getString('CustomerProfile')!)
          as Map<String, dynamic>;

      firstName = responseData['First_Name'];
      lastName = responseData['Last_Name'];
      mobile = responseData['Mobile'];
      street = responseData['Street'];
      city = responseData['City'];
      state = responseData['State'];
      zipCode = responseData['Zip_Code'];

      setState(() {});
    } else {
      Provider.of<Authenticate>(context, listen: false)
          .tryAutoLogin()
          .then((value) {
        token = Provider.of<Authenticate>(context, listen: false).token;

        Provider.of<ApiCalls>(context, listen: false)
            .fetchUser(token)
            .then((value) {
          if (value['Status_Code'] == 200) {
            Provider.of<ApiCalls>(context, listen: false)
                .fetchCustomerProfile(value['Id'], token);
          }
        });
      });
    }
  }

  void fetchCustomerProfile() {
    Provider.of<Authenticate>(context, listen: false)
        .tryAutoLogin()
        .then((value) {
      token = Provider.of<Authenticate>(context, listen: false).token;

      Provider.of<ApiCalls>(context, listen: false)
          .fetchUser(token)
          .then((value) {
        if (value['Status_Code'] == 200) {
          Provider.of<ApiCalls>(context, listen: false)
              .fetchCustomerProfile(value['Id'], token);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    consumerProfile = Provider.of<ApiCalls>(context).consumerProfile;
    if (consumerProfile.isNotEmpty) {
      consumerId = consumerProfile['Consumer'];
      firstName = consumerProfile['First_Name'];
      lastName = consumerProfile['Last_Name'];

      mobile = consumerProfile['Mobile'];

      street = consumerProfile['Street'];

      city = consumerProfile['City'];

      state = consumerProfile['State'];

      zipCode = consumerProfile['Zip_Code'];
    }
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        firstName ?? 'N/A',
                        style: GoogleFonts.roboto(
                          textStyle: const TextStyle(
                              fontSize: 28, fontWeight: FontWeight.w700),
                        ),
                      ),
                      Text(
                        mobile ?? 'N/A',
                        style: GoogleFonts.roboto(
                          textStyle: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () async {
                      var result =
                          await Get.toNamed(EditProfileSetUp.routeName);

                      if (result == 'Success') {
                        Provider.of<Authenticate>(context, listen: false)
                            .tryAutoLogin()
                            .then((value) {
                          var token =
                              Provider.of<Authenticate>(context, listen: false)
                                  .token;
                          Provider.of<ApiCalls>(context, listen: false)
                              .fetchUser(token)
                              .then((value) {
                            if (value['Status_Code'] == 200 ||
                                value['Status_Code'] == 201) {
                              Provider.of<ApiCalls>(context, listen: false)
                                  .fetchCustomerProfile(value['Id'], token)
                                  .then((value) {
                                if (value['StatusCode'] == 200) {
                                  if (value['Body'] == null) {
                                    return;
                                    // refresh();
                                  } else {
                                    fetchCustomerProfile();
                                    // getProfileDetails()
                                    //     .then(
                                    //         (value) {
                                    //   reRun();
                                    //   setState(
                                    //       () {});
                                    // });
                                  }
                                }
                              });
                            }
                          });
                        });
                      }
                    },
                    child: Container(
                      width: 80,
                      height: 35,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.orange),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Edit Profile',
                        style: GoogleFonts.roboto(
                            textStyle: const TextStyle(fontSize: 12)),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Text(
                'Food Orders',
                style: GoogleFonts.roboto(
                    textStyle: const TextStyle(color: Colors.grey)),
              ),
            ),
            GestureDetector(
              onTap: () {
                Get.toNamed(OrderHistory.routeName);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Image.asset('assets/images/shopping-bag.png'),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Text('Your Orders'),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      child: Image.asset('assets/images/heart.png'),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Text('Favorites'),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      child: Image.asset('assets/images/map-book.png'),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Text('Address Book'),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: GestureDetector(
                onTap: () {
                  Get.toNamed(ChatHistoryPage.routeName);
                },
                child: Row(
                  children: [
                    Container(
                        width: 20,
                        height: 20,
                        child: Icon(Icons.chat_bubble_outline)),
                    const SizedBox(
                      width: 10,
                    ),
                    const Text('Chats'),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    child: Image.asset('assets/images/info.png'),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  const Text('About'),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        width: width,
        height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                Get.offAll(() => LogIn());
                Provider.of<Authenticate>(context, listen: false).logout();
              },
              child: Container(
                  height: 40,
                  width: width - 28,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red)),
                  child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Log Out',
                        style: GoogleFonts.roboto(
                          textStyle:
                              const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ))),
            ),
          ],
        ),
      ),
    );
  }
}

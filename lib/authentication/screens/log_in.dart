import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:oota/authentication/providers/api_calls.dart';
import 'package:oota/authentication/providers/authenticate.dart';
import 'package:oota/authentication/screens/profile_setup_page.dart';
import 'package:oota/authentication/screens/sign_up_screen.dart';
import 'package:oota/home/screens/home_page.dart';
import 'package:oota/home/screens/nav_bar_screen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../helper/helperfunctions.dart';
import '../../services/auth.dart';
import '../../services/database.dart';

class LogIn extends StatefulWidget {
  LogIn({Key? key}) : super(key: key);

  @override
  _LogInState createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  var baseUrl = 'https://projectoota.herokuapp.com/';
  final GlobalKey<FormState> _formKey = GlobalKey();
  String _url = '';

  bool _obscureText = true;

  bool _passwordTyped = false;

  TextEditingController emailEditingController = TextEditingController();
  TextEditingController passwordEditingController = TextEditingController();

  AuthService authService = AuthService();

  @override
  void initState() {
    _url = '${baseUrl}accounts/password/reset/';
    super.initState();
  }

  Map<String, dynamic> logIn = {
    'email': '',
    'password': '',
  };

  TextStyle normalStyle() {
    return GoogleFonts.roboto(
        textStyle: const TextStyle(
            fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white));
  }

  Future<void> save() async {
    EasyLoading.show();
    _formKey.currentState!.save();
    print(logIn);

    Provider.of<Authenticate>(context, listen: false)
        .logIn(logIn)
        .then((value) async {
      await authService
          .signInWithEmailAndPassword(
              emailEditingController.text, passwordEditingController.text)
          .then((result) async {
        if (result != null) {
          QuerySnapshot userInfoSnapshot =
              await DatabaseMethods().getUserInfo(emailEditingController.text);
          var userName = userInfoSnapshot.docs[0].get('userName');
          var userEmail = userInfoSnapshot.docs[0].get('userEmail');
          HelperFunctions.saveUserLoggedInSharedPreference(true);
          HelperFunctions.saveUserNameSharedPreference(userName);
          HelperFunctions.saveUserEmailSharedPreference(userEmail);

          print('Login Success');

          // Navigator.pushReplacement(
          //     context, MaterialPageRoute(builder: (context) => ChatRoom()));
        } else {
          // setState(() {
          //   isLoading = false;
          //   //show snackbar
          // });
        }
      });
      EasyLoading.dismiss();
      if (value['StatusCode'] == 200 || value['StatusCode'] == 201) {
        Get.toNamed(NavBarScreen.routeName);
        // Provider.of<Authenticate>(context, listen: false)
        //     .tryAutoLogin()
        //     .then((value) async {
        //   var token = Provider.of<Authenticate>(context, listen: false).token;
        //   await Provider.of<ApiCalls>(context, listen: false)
        //       .fetchUser(token)
        //       .then((value) async {
        //     if (value['Status_Code'] == 200 || value['Status_Code'] == 201) {
        //       // Get.toNamed(HomePageScreen.routeName);
        //       // Get.toNamed(ProfileSetUpPage.routeName)
        //       // ;

        //       // Provider.of<ApiCalls>(context, listen: false)
        //       //     .fetchCustomerProfile(value['Id'], token)
        //       //     .then((value) {
        //       //   if (value['StatusCode'] == 200) {
        //       //     if (value['Body'] == null) {
        //       //       // EasyLoading.dismiss();
        //       //       Get.toNamed(ProfileSetUpPage.routeName);
        //       //     } else {
        //       //       // EasyLoading.dismiss();
        //       //       // EasyLoading.dismiss();

        //       //     }
        //       //   } else {
        //       //     EasyLoading.showError(
        //       //         'Something Went Wrong Please Try Again');
        //       //   }
        //       // });
        //     } else {
        //       EasyLoading.showError('Something Went Wrong Please Try Again');
        //     }
        //   });
        // });

        // Provider.of<Authenticate>(context, listen: false)
        //     .tryAutoLogin()
        //     .then((value) {
        //   var token = Provider.of<Authenticate>(context, listen: false).token;

        //   Provider.of<ApiCalls>(context, listen: false)
        //       .fetchProfileDetails(token)
        //       .then((value) {
        //     if (value['Status_Code'] == 200 || value['Status_Code'] == 201) {

        //       // Get.showSnackbar(GetSnackBar(
        //       //   duration: const Duration(seconds: 2),
        //       //   backgroundColor: Theme.of(context).backgroundColor,
        //       //   message:
        //       //       'Successfully signed up an verification email is sent to your email id please verify',
        //       //   title: 'Success',
        //       // ));
        //     }
        //   });
        // });
      } else {
        EasyLoading.dismiss();
        // Get.defaultDialog(
        //     title: 'Alert',
        //     middleText:
        //         value['Body'][0] ?? 'Something Went Wrong Please try again',
        //     confirm: TextButton(
        //         onPressed: () {
        //           Get.back();
        //         },
        //         child: const Text('Ok')));
      }
    });
  }

  void _launchURL() async {
    if (!await launch(_url)) throw 'Could not launch $_url';
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    print(height);
    var width = MediaQuery.of(context).size.width;
    var headingConatinerHeight = MediaQuery.of(context).size.height / 2;
    return Scaffold(
      // backgroundColor: Theme.of(context).backgroundColor,
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
            setState(() {
              _obscureText = true;
              _passwordTyped = false;
            });
          }
        },
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Stack(
              children: [
                Container(
                  width: width,
                  height: height,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 2),
                    child: Image.asset(
                      'assets/images/logInPageImage.jpg',
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                Container(
                  width: width,
                  height: height,
                  decoration: const BoxDecoration(
                    backgroundBlendMode: BlendMode.darken,
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(88, 70, 66, 55),
                        Color.fromARGB(88, 70, 66, 55),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: height * 0.12,
                  left: width * 0.15,
                  child: Padding(
                    padding: EdgeInsets.only(top: 15.0),
                    child: Text(
                      'Welcome to OOta',
                      style: GoogleFonts.openSans(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 34,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: height * 0.18,
                  left: width * 0.15,
                  child: Padding(
                    padding: EdgeInsets.only(top: 20.0),
                    child: Text(
                      'Get the best food served!!',
                      style: GoogleFonts.openSans(
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: height * 0.28,
                  left: width * 0.13,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Container(
                        //   width: width / 1.2,
                        //   padding: const EdgeInsets.only(bottom: 12),
                        //   child: const Text(
                        //     'Email Id',
                        //     style: TextStyle(color: Colors.white),
                        //   ),
                        // ),
                        Container(
                          width: width * 0.75,
                          height: 40,
                          decoration: const BoxDecoration(
                            // borderRadius: BorderRadius.circular(8),
                            // color: Colors.white.withOpacity(0.8),
                            border:
                                Border(bottom: BorderSide(color: Colors.white)),
                          ),
                          // BoxDecoration(
                          //   borderRadius: BorderRadius.circular(8),
                          //   color: Colors.white.withOpacity(0.8),
                          //   border: Border.all(color: Colors.black26),
                          // ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                            ),
                            child: TextFormField(
                              style: GoogleFonts.openSans(
                                textStyle: const TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                              controller: emailEditingController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Email Id',
                                hintStyle: GoogleFonts.openSans(
                                  textStyle: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                      color: Colors.white),
                                ),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  // showError('FirmCode');
                                  return '';
                                }
                              },
                              onSaved: (value) {
                                logIn['email'] = value;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: height * 0.38,
                  left: width * 0.13,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Container(
                        //   width: width / 1.2,
                        //   padding: const EdgeInsets.only(bottom: 12),
                        //   child: const Text(
                        //     'Password',
                        //     style: TextStyle(color: Colors.white),
                        //   ),
                        // ),
                        Container(
                          width: width * 0.75,
                          height: 40,
                          decoration: const BoxDecoration(
                            // borderRadius: BorderRadius.circular(8),
                            // color: Colors.white.withOpacity(0.8),
                            border:
                                Border(bottom: BorderSide(color: Colors.white)),
                          ),
                          //  BoxDecoration(
                          //   borderRadius: BorderRadius.circular(8),
                          //   color: Colors.white.withOpacity(0.8),
                          //   border: Border.all(color: Colors.black26),
                          // ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: FocusScope(
                                    child: Focus(
                                      onFocusChange: (value) {
                                        if (value == true) {
                                          setState(() {
                                            _passwordTyped = true;
                                          });
                                        } else {
                                          setState(() {
                                            _passwordTyped = false;
                                          });
                                        }
                                      },
                                      child: TextFormField(
                                        obscureText: _obscureText,
                                        controller: passwordEditingController,
                                        style: GoogleFonts.openSans(
                                          textStyle: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.white),
                                        ),

                                        // autovalidateMode: AutovalidateMode.always,
                                        // ignore: prefer_const_constructors
                                        decoration: InputDecoration(
                                            // suffix: Container(
                                            //   alignment: Alignment.bottomCenter,
                                            //   width: 40,
                                            //   height: 25,
                                            //   child: Image.asset(
                                            //     'assets/images/view.png',
                                            //     fit: BoxFit.contain,
                                            //     color: Colors.black,
                                            //   ),
                                            // ),
                                            hintText: 'Password',
                                            hintStyle: GoogleFonts.openSans(
                                              textStyle: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 18,
                                                  color: Colors.white),
                                            ),
                                            border: InputBorder.none),

                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            // showError('FirmCode');
                                            return '';
                                          }
                                        },

                                        onSaved: (value) {
                                          logIn['password'] = value;
                                          // firmData['Firm_Code'] = value!;
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                _passwordTyped == true && _obscureText == false
                                    ? GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _obscureText = true;
                                          });
                                        },
                                        child: Container(
                                          alignment: Alignment.bottomCenter,
                                          width: 40,
                                          height: 25,
                                          child: Image.asset(
                                            'assets/images/invisible.png',
                                            fit: BoxFit.contain,
                                            color: Colors.white,
                                          ),
                                        ),
                                      )
                                    : _passwordTyped == true &&
                                            _obscureText == true
                                        ? GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _obscureText = false;
                                              });
                                            },
                                            child: Container(
                                              alignment: Alignment.bottomCenter,
                                              width: 40,
                                              height: 25,
                                              child: Image.asset(
                                                'assets/images/view.png',
                                                fit: BoxFit.contain,
                                                color: Colors.white,
                                              ),
                                            ),
                                          )
                                        : SizedBox(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: height * 0.50,
                  left: width * 0.13,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Container(
                        width: width * 0.75,
                        height: 60,
                        child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                // const Color.fromRGBO(255, 193, 7, 1),
                                // const Color.fromRGBO(255, 171, 76, 1),
                                Color.fromRGBO(245, 148, 2, 1),
                              ),
                            ),
                            onPressed: save,
                            child: Text(
                              'Log In',
                              style: GoogleFonts.roboto(
                                  textStyle: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w500,
                              )),
                            ))),
                  ),
                ),
                Positioned(
                  top: height * 0.62,
                  left: width * 0.32,
                  child: TextButton(
                    onPressed: _launchURL,
                    child: Text(
                      'Forgot Password?',
                      style: normalStyle(),
                    ),
                  ),
                ),
                Positioned(
                  top: height * 0.68,
                  left: width * 0.45,
                  child: const Padding(
                    padding: EdgeInsets.only(top: 15.0),
                    child: Text(
                      'Or',
                      style: TextStyle(
                          fontSize: 15,
                          decoration: TextDecoration.underline,
                          color: Colors.white),
                    ),
                  ),
                ),
                Positioned(
                  top: height * 0.75,
                  left: width * 0.23,
                  child: TextButton(
                    onPressed: () {
                      Get.toNamed(SignUpScreen.routeName);
                    },
                    child: Text(
                      'Create New Account',
                      style: GoogleFonts.roboto(
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

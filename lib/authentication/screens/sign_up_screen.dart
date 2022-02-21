import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oota/authentication/providers/authenticate.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:provider/provider.dart';

import '../../helper/helperfunctions.dart';
import '../../services/auth.dart';
import '../../services/database.dart';

class SignUpScreen extends StatefulWidget {
  SignUpScreen({Key? key}) : super(key: key);

  static const routeName = '/SignUpScreen';

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  TextEditingController _passwordController = TextEditingController();

  Map<String, dynamic> signUp = {
    'email': '',
    'password1': '',
    'password2': '',
  };

  var validate = true;
  double fieldHeight = 60;
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  var connectivityResult;

  @override
  void initState() {
    getStatus();
    super.initState();
  }

  Future<void> getStatus() async {
    // var connectionStatus = await DataConnectionChecker().connectionStatus;
  }

  AuthService authService = new AuthService();
  DatabaseMethods databaseMethods = new DatabaseMethods();

  Future<void> save() async {
    validate = _formKey.currentState!.validate();

    if (validate != true) {
      setState(() {
        validate = false;
      });
      return;
    }
    _formKey.currentState!.save();
    print(signUp);

    var isDeviceConnected = false;

    connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == _connectionStatus) {
      Get.showSnackbar(GetSnackBar(
        duration: const Duration(seconds: 2),
        backgroundColor: Theme.of(context).backgroundColor,
        message: 'Please Connect to the internet',
        title: 'Alert',
      ));
      return;
    }

    EasyLoading.show();

    try {
      Provider.of<Authenticate>(context, listen: false)
          .signUp(signUp)
          .then((value) async {
        if (value == 200 || value == 201) {
          await authService
              .signUpWithEmailAndPassword(signUp['email'], signUp['password1'])
              .then((result) {
            if (result != null) {
              Map<String, String> userDataMap = {
                "userName": signUp['email'],
                "userEmail": signUp['email'],
              };

              databaseMethods.addUserInfo(userDataMap);

              HelperFunctions.saveUserLoggedInSharedPreference(true);
              HelperFunctions.saveUserNameSharedPreference(
                signUp['email'],
              );
              HelperFunctions.saveUserEmailSharedPreference(
                signUp['email'],
              );

              // Navigator.pushReplacement(
              //     context, MaterialPageRoute(builder: (context) => ChatRoom()));
            }
          });

          EasyLoading.dismiss();
          Get.back();

          Get.defaultDialog(
            title: 'Alert',
            middleText:
                'Successfully signed up an verification email is sent to your email id please verify',
            confirm: TextButton(
              onPressed: () {
                Get.back();
                Navigator.of(context).pop();
              },
              child: const Text('Ok'),
            ),
          );
          // Get.showSnackbar(GetSnackBar(
          //   duration: const Duration(seconds: 2),
          //   backgroundColor: Theme.of(context).backgroundColor,
          //   message:
          //       'Successfully signed up an verification email is sent to your email id please verify',
          //   title: 'Success',
          // ));
        } else {
          EasyLoading.dismiss();
          // Get.showSnackbar(GetSnackBar(
          //   duration: const Duration(seconds: 2),
          //   backgroundColor: Theme.of(context).backgroundColor,
          //   message: 'Something Went Wrong',
          //   title: 'Failed',
          // ));
        }
      });
    } catch (e) {
      EasyLoading.dismiss();
      print('Printing Error');
    }
  }

  @override
  Widget build(BuildContext context) {
    var formWidth = MediaQuery.of(context).size.width / 1.2;
    var width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        body: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 30),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text('Sign Up',
                          style: GoogleFonts.roboto(
                              textStyle: const TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.w700))),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(top: 24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: width / 1.2,
                            padding: const EdgeInsets.only(bottom: 12),
                            child: const Text('Email'),
                          ),
                          Container(
                            width: width / 1.2,
                            height: validate == false ? fieldHeight : 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                              border: Border.all(color: Colors.black26),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              child: TextFormField(
                                decoration: const InputDecoration(
                                    hintText: 'email',
                                    border: InputBorder.none),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    // showError('FirmCode');
                                    return 'Email Cannot be Empty';
                                  }
                                  bool emailValid = RegExp(
                                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                      .hasMatch(value);

                                  if (emailValid != true) {
                                    return 'Provide a valid Email Address';
                                  }
                                },
                                onSaved: (value) {
                                  signUp['email'] = value;
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
                            child: Text('Password'),
                          ),
                          Container(
                            width: width / 1.2,
                            height: validate == false ? fieldHeight : 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                              border: Border.all(color: Colors.black26),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              child: TextFormField(
                                controller: _passwordController,
                                decoration: const InputDecoration(
                                    hintText: 'password',
                                    border: InputBorder.none),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    // showError('FirmCode');
                                    return 'Password Cannot be Empty';
                                  }
                                },
                                onSaved: (value) {
                                  signUp['password1'] = value;
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
                            child: const Text('Confirm Password'),
                          ),
                          Container(
                            width: width / 1.2,
                            height: validate == false ? fieldHeight : 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                              border: Border.all(color: Colors.black26),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              child: TextFormField(
                                decoration: const InputDecoration(
                                    hintText: 'Confirm password',
                                    border: InputBorder.none),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    // showError('FirmCode');
                                    return 'confirm Password Cannot be Empty';
                                  } else if (_passwordController.text !=
                                      value) {
                                    return 'Password and confirm password should be equal';
                                  }
                                },
                                onSaved: (value) {
                                  signUp['password2'] = value;
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // formDesign(context, 'Password', 'Enter Password',
                    //     signUp['password1']),
                    // formDesign(context, 'Confirm Password',
                    //     'Enter Confirm Password', signUp['password2']),
                    Padding(
                      padding: const EdgeInsets.only(top: 25.0),
                      child: Container(
                          width: formWidth,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                height: 45,
                                width: 100,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color:
                                          const Color.fromRGBO(255, 114, 76, 1),
                                    )),
                                child: TextButton(
                                    // style: ButtonStyle(
                                    //   shape: MaterialStateProperty.all(),
                                    //     backgroundColor: MaterialStateProperty.all(
                                    //   const Color.fromRGBO(124, 209, 184, 1),
                                    // )),
                                    onPressed: () {
                                      Get.back();
                                    },
                                    child: Text(
                                      'Cancel',
                                      style: GoogleFonts.roboto(
                                          textStyle: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black)),
                                    )),
                              ),
                              Container(
                                height: 45,
                                width: 100,
                                child: ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                      const Color.fromRGBO(255, 114, 76, 1),
                                    )),
                                    onPressed: save,
                                    child: Text(
                                      'Sign Up',
                                      style: GoogleFonts.roboto(
                                          textStyle: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black)),
                                    )),
                              ),
                            ],
                          )),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Padding formDesign(
      BuildContext context, String formName, String hintText, var data) {
    var width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: width / 1.2,
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(formName),
          ),
          Container(
            width: width / 1.2,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
              border: Border.all(color: Colors.black26),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: TextFormField(
                decoration: InputDecoration(
                    hintText: hintText, border: InputBorder.none),
                validator: (value) {
                  if (value!.isEmpty) {
                    // showError('FirmCode');
                    return '';
                  }
                },
                onSaved: (value) {
                  data = value;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oota/authentication/providers/api_calls.dart';
import 'package:oota/authentication/providers/authenticate.dart';
import 'package:oota/home/screens/consumer_profile_screen.dart';
import 'package:oota/home/screens/menu_page.dart';
import 'package:oota/home/screens/search_results_display_page.dart';
import 'package:oota/home/screens/search_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletons/skeletons.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../../chat.dart';
import '../../helper/helperfunctions.dart';
import '../../services/database.dart';

class HomePageScreen extends StatefulWidget {
  HomePageScreen({Key? key}) : super(key: key);

  static const routeName = '/HomePageScreen';

  @override
  _HomePageScreenState createState() => _HomePageScreenState();
}

enum sort { ratingHL, costHL, costLH }

enum filter {
  allergen,
  cusines,
}

class _HomePageScreenState extends State<HomePageScreen> {
  List profileList = [];

  sort _selected = sort.ratingHL;
  filter _selectedFilter = filter.allergen;

  List _searchResults = [];

  ScrollController selectedFilterController = ScrollController();

  Map<String, dynamic> fcmDeviceModel = {
    'registration_id': '',
    'name': '',
    'device_id': '',
    'type': '',
  };

  String query = '';

  String _searchText = '';

  bool _focus = false;

  Future<String?> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      fcmDeviceModel['type'] = 'android';
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.androidId; // unique ID on Android
      // import 'dart:io'
      // unique ID on iOS
    } else {
      fcmDeviceModel['type'] = 'ios';
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor;
    }
  }

  void search(String name) {
    _searchText = name;
    Provider.of<Authenticate>(context, listen: false)
        .tryAutoLogin()
        .then((value) {
      var token = Provider.of<Authenticate>(context, listen: false).token;

      Provider.of<ApiCalls>(context, listen: false)
          .searchMenuItems(token, name);
    });
  }

  void clearSearch(int data) {
    setState(() {
      _searchResults.clear();
      _finalSearchFoodResults.clear();
      _finalSearchRestaurantResults.clear();
      _focus = false;
    });
  }

  @override
  void initState() {
    // String? deviceId = await _getId();
    // final prefs = await SharedPreferences.getInstance();
    // if (!prefs.containsKey('FCM')) {
    //   return;
    // }
    // final extratedUserData =
    //     json.decode(prefs.getString('FCM')!) as Map<String, dynamic>;
    // fcmDeviceModel['registration_id'] = extratedUserData['token'];
    // fcmDeviceModel['name'] = '';
    // fcmDeviceModel['device_id'] = deviceId;

    Provider.of<Authenticate>(context, listen: false)
        .tryAutoLogin()
        .then((value) async {
      var token = Provider.of<Authenticate>(context, listen: false).token;
      // Provider.of<ApiCalls>(context, listen: false)
      //     .sendFCMDeviceModel(fcmDeviceModel, token)
      //     .then((value) {
      //   if (value == 200 || value == 201) {
      //     // Get.toNamed(HomePageScreen.routeName);
      //   }
      // });
      Provider.of<ApiCalls>(context, listen: false)
          .fetchBusinessProfileDetails(token)
          .then((value) async {
        if (value == 200 || value == 201) {}
      });
    });
    super.initState();
  }

  TextEditingController controller = TextEditingController();

  Widget buildSearch() => SearchWidget(
        text: query,
        hintText: 'Restaurant name or dish...',
        onChanged: (value) {},
        data: search,
        clear: clearSearch,
        controller: controller,
        change: change,
      );

  List _finalSearchRestaurantResults = [];

  List _finalSearchFoodResults = [];

  void change(int data) {
    print(data);
    setState(() {
      _focus = true;
    });
  }

  late Future _allergenFuture;
  late Future _cuisineFuture;
  List selectedCuisines = [];

  Future fetchAllergenesList() async {
    await Provider.of<Authenticate>(context, listen: false)
        .tryAutoLogin()
        .then((value) {
      var token = Provider.of<Authenticate>(context, listen: false).token;

      return Provider.of<ApiCalls>(context, listen: false)
          .fetchAllergenes(token);
    });
  }

  Future fetchCuisineList() async {
    await Provider.of<Authenticate>(context, listen: false)
        .tryAutoLogin()
        .then((value) {
      var token = Provider.of<Authenticate>(context, listen: false).token;
      return Provider.of<ApiCalls>(context, listen: false)
          .getCuisinesCategory(token);
    });
  }

  Future fetchBusinessProfileList() async {
    Provider.of<Authenticate>(context, listen: false)
        .tryAutoLogin()
        .then((value) async {
      var token = Provider.of<Authenticate>(context, listen: false).token;

      Provider.of<ApiCalls>(context, listen: false)
          .fetchBusinessProfileDetails(token)
          .then((value) async {
        if (value == 200 || value == 201) {}
      });
    });
  }

  List selectedAllergenes = [];

  void allergenSelected(Map<String, dynamic> data) {
    if (selectedAllergenes.isEmpty) {
      selectedAllergenes.add(data['Allergen']);
    } else {
      if (data['value'] == false) {
        selectedAllergenes.remove(data['Allergen']);
      } else {
        selectedAllergenes.add(data['Allergen']);
      }
    }

    print(selectedAllergenes);
  }

  List selectedCuisineId = [];
  void cuisineSelected(Map<String, dynamic> data) {
    if (selectedCuisines.isEmpty) {
      selectedCuisines.add(data['Cuisine']);
    } else {
      if (data['value'] == false) {
        selectedCuisines.remove(data['Cuisine']);
      } else {
        selectedCuisines.add(data['Cuisine']);
      }
    }

    if (selectedCuisineId.isEmpty) {
      selectedCuisineId.add(data['CuisineId']);
    } else {
      if (data['value'] == false) {
        selectedCuisineId.remove(data['CuisineId']);
      } else {
        selectedCuisineId.add(data['CuisineId']);
      }
    }

    print(selectedCuisines);
    print(selectedCuisineId);
  }

  @override
  Widget build(BuildContext context) {
    profileList = Provider.of<ApiCalls>(context).profileList;
    _searchResults = Provider.of<ApiCalls>(context).searchList;
    if (_searchResults.isNotEmpty) {
      final restaurantResult = _searchResults.where((element) {
        final businessName = element['Profile']['Business_Name'].toLowerCase();
        final searchText = _searchText.toLowerCase();
        return businessName.contains(searchText);
      }).toList();

      final foodResult = _searchResults.where((element) {
        final businessName = element['Food_Name'].toLowerCase();
        final searchText = _searchText.toLowerCase();
        return businessName.contains(searchText);
      }).toList();

      log('log ${restaurantResult.toString()}');

      if (restaurantResult.length != 1) {
        for (int i = 0; i < restaurantResult.length; i++) {
          for (int j = 0; j < restaurantResult.length; j++) {
            if (restaurantResult[j]['Profile']['Business_Name'] ==
                restaurantResult[i]['Profile']['Business_Name']) {
              restaurantResult.removeAt(i);
            }
          }
        }
      }

      _finalSearchFoodResults = foodResult;
      _finalSearchRestaurantResults = restaurantResult;
    }
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          controller.clear();
          clearSearch(100);
          return false;
        },
        child: Scaffold(
          // appBar: AppBar(
          //   backgroundColor: Colors.white,
          //   automaticallyImplyLeading: false,
          //   elevation: 0,
          //   title: Text(
          //     'Oota',
          //     style: GoogleFonts.roboto(
          //       textStyle: const TextStyle(color: Colors.black),
          //     ),
          //   ),
          //   actions: [
          //     IconButton(
          //       onPressed: () {
          //         Get.toNamed(OrdersScreen.routeName);
          //       },
          //       icon: const Icon(
          //         Icons.food_bank_rounded,
          //         color: Colors.black,
          //       ),
          //     ),
          //     IconButton(
          //       onPressed: () {
          //         Get.offAll(() => LogIn());
          //         Provider.of<Authenticate>(context, listen: false).logout();
          //       },
          //       icon: const Icon(
          //         Icons.logout_outlined,
          //         color: Colors.black,
          //       ),
          //     )
          //   ],
          // ),
          body: GestureDetector(
            onTap: () {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
                setState(() {
                  _focus = false;
                });
              }
            },
            child: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerboxscrolled) {
                return [
                  SliverAppBar(
                    automaticallyImplyLeading: false,
                    snap: true,
                    pinned: false,
                    floating: true,
                    stretch: true,
                    title: Text(
                      'Oota',
                      style: GoogleFonts.roboto(
                          textStyle: const TextStyle(
                              fontSize: 25, color: Colors.black)),
                    ),
                    backgroundColor: Colors.white,
                    iconTheme: const IconThemeData(color: Colors.black),
                    actions: [
                      // IconButton(
                      //     onPressed: () {
                      //       Get.toNamed(WebViewDisplayContent.routeName);
                      //     },
                      //     icon: const Icon(Icons.search)),
                      IconButton(
                          onPressed: () {
                            Get.toNamed(ConsumerProfileScreen.routeName);
                          },
                          icon: const Icon(Icons.person))
                    ],
                    onStretchTrigger: () async {
                      print('object');
                    },
                  ),
                ];
              },
              body: profileList.isEmpty
                  ? SkeletonListView(
                      item: SkeletonListTile(
                        hasLeading: false,
                        // trailing: Container(
                        //   width: 64,
                        //   height: 64,
                        //   decoration: BoxDecoration(
                        //       shape: BoxShape.circle, border: Border.all(color: Colors.grey)),
                        // ),
                        verticalSpacing: 12,
                        leadingStyle: SkeletonAvatarStyle(
                            width: 64, height: 64, shape: BoxShape.circle),
                        titleStyle: SkeletonLineStyle(
                            height: 200,
                            minLength: MediaQuery.of(context).size.width * 0.8,
                            randomLength: true,
                            borderRadius: BorderRadius.circular(12)),
                        subtitleStyle: SkeletonLineStyle(
                            height: 12,
                            minLength:
                                MediaQuery.of(context).size.width * 2 / 3,
                            randomLength: true,
                            borderRadius: BorderRadius.circular(12)),
                        hasSubtitle: true,
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                buildSearch(),
                                IconButton(
                                    onPressed: () {
                                      Get.dialog(AlertDialog(
                                        title: const Text('Sort'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text(
                                                    'Sort By Ratings(High to Low)'),
                                                Radio(
                                                    value: sort.ratingHL,
                                                    groupValue: _selected,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _selected =
                                                            value as sort;
                                                      });
                                                      Get.back();
                                                    })
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                    'Sort By cost(High to Low)'),
                                                Radio(
                                                    value: sort.costHL,
                                                    groupValue: _selected,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _selected =
                                                            value as sort;
                                                      });
                                                      Get.back();
                                                    })
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text(
                                                    'Sort By cost(Low to High)'),
                                                Radio(
                                                    value: sort.costLH,
                                                    groupValue: _selected,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _selected =
                                                            value as sort;
                                                      });
                                                      Get.back();
                                                    })
                                              ],
                                            ),
                                          ],
                                        ),
                                      ));

                                      // Get.dialog(Container(
                                      //   width: width * 0.8,
                                      //   height: height * 0.5,
                                      //   decoration: BoxDecoration(
                                      //       border: Border.all(), color: Colors.white),
                                      // ));
                                    },
                                    icon: const Icon(Icons.sort)),
                                IconButton(
                                    onPressed: () {
                                      if (selectedAllergenes.isEmpty) {
                                        _allergenFuture = fetchAllergenesList();
                                      }

                                      if (selectedCuisines.isEmpty) {
                                        _cuisineFuture = fetchCuisineList();
                                      }

                                      // selectedAllergenes.clear();

                                      Get.dialog(Dialog(
                                        child:
                                            allergenFilterDialog(width, height),
                                      )).then((value) {
                                        if (selectedAllergenes.isEmpty &&
                                            selectedCuisines.isEmpty) {
                                          fetchBusinessProfileList();
                                        } else {
                                          setState(() {});
                                        }
                                      });
                                    },
                                    icon: Icon(Icons.filter_alt))
                              ],
                            ),
                            selectedAllergenes.isEmpty &&
                                    selectedCuisines.isEmpty
                                ? SizedBox()
                                : Container(
                                    width: width,
                                    height: 50,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(left: 15.0),
                                      child: ListView(
                                          scrollDirection: Axis.horizontal,
                                          controller: selectedFilterController,
                                          children: [
                                            selectedAllergenes.isEmpty
                                                ? SizedBox()
                                                : selectedAllergenChips(),
                                            selectedAllergenes.isEmpty
                                                ? SizedBox()
                                                : selectedCuisineChips(),
                                          ]),
                                    ),
                                  ),
                            _searchResults.isEmpty && _focus == false
                                ? displayProfiles()
                                : SizedBox(),
                            _finalSearchFoodResults.isEmpty
                                ? SizedBox()
                                : displaySearchResults(),
                            _finalSearchRestaurantResults.isNotEmpty
                                ? displaySearchRestaurantResults()
                                : const SizedBox(),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  ListView selectedCuisineChips() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: selectedCuisines.length,
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        return Chip(
            key: UniqueKey(),
            onDeleted: () {
              selectedCuisineId.removeAt(index);
              selectedCuisines.removeAt(index);
              if (selectedAllergenes.isNotEmpty ||
                  selectedCuisineId.isNotEmpty) {
                var filter = {
                  'Allergenes': selectedAllergenes,
                  'Cuisines': selectedCuisineId
                };
                print(filter);

                Provider.of<Authenticate>(context, listen: false)
                    .tryAutoLogin()
                    .then((value) {
                  var token =
                      Provider.of<Authenticate>(context, listen: false).token;
                  Provider.of<ApiCalls>(context, listen: false)
                      .sendSelectedAllergen(filter, token);
                });
              } else {
                fetchBusinessProfileList();
              }
              setState(() {});
            },
            deleteIcon: Icon(Icons.cancel_outlined),
            label: Text(selectedCuisines[index].toString()));
      },
    );
  }

  ListView selectedAllergenChips() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: selectedAllergenes.length,
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        return Chip(
            key: UniqueKey(),
            onDeleted: () {
              selectedAllergenes.removeAt(index);
              if (selectedAllergenes.isNotEmpty ||
                  selectedCuisineId.isNotEmpty) {
                var filter = {
                  'Allergenes': selectedAllergenes,
                  'Cuisines': selectedCuisineId
                };
                print(filter);

                Provider.of<Authenticate>(context, listen: false)
                    .tryAutoLogin()
                    .then((value) {
                  var token =
                      Provider.of<Authenticate>(context, listen: false).token;
                  Provider.of<ApiCalls>(context, listen: false)
                      .sendSelectedAllergen(filter, token);
                });
              } else {
                fetchBusinessProfileList();
              }
              setState(() {});
            },
            deleteIcon: Icon(Icons.cancel_outlined),
            label: Text(selectedAllergenes[index].toString()));
      },
    );
  }

  TextStyle filterTextStyle() {
    return GoogleFonts.roboto(
        textStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w400,
    ));
  }

  Container allergenFilterDialog(double width, double height) {
    var dialogWidth = width * 0.9;
    var dialogHeight = height * 0.8;
    return Container(
      width: dialogWidth,
      height: dialogHeight,
      child: StatefulBuilder(
        builder: (BuildContext context, setState) {
          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 10),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        _selectedFilter == filter.allergen
                            ? Container(
                                width: 100,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: const LinearGradient(
                                      colors: [
                                        Color.fromARGB(230, 167, 179, 157),
                                        Color.fromARGB(220, 125, 129, 117)
                                      ],
                                      begin: FractionalOffset.topLeft,
                                      end: FractionalOffset.bottomRight),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Allergen',
                                  style: filterTextStyle()
                                      .copyWith(color: Colors.white),
                                ),
                              )
                            : GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedFilter = filter.allergen;
                                  });
                                },
                                child: Text(
                                  'Allergen',
                                  style: filterTextStyle(),
                                ),
                              ),
                        SizedBox(
                          height: 20,
                        ),
                        _selectedFilter == filter.cusines
                            ? Container(
                                width: 100,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: const LinearGradient(
                                      colors: [
                                        Color.fromARGB(230, 167, 179, 157),
                                        Color.fromARGB(220, 125, 129, 117)
                                      ],
                                      begin: FractionalOffset.topLeft,
                                      end: FractionalOffset.bottomRight),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Cuisines',
                                  style: filterTextStyle()
                                      .copyWith(color: Colors.white),
                                ),
                              )
                            : GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedFilter = filter.cusines;
                                  });
                                },
                                child: Text(
                                  'Cuisines',
                                  style: filterTextStyle(),
                                ),
                              ),
                      ],
                    ),
                  ),
                  _selectedFilter != filter.allergen
                      ? SizedBox()
                      : Padding(
                          padding: const EdgeInsets.only(left: 10.0, top: 25),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: width * 0.4,
                                height: dialogHeight * 0.8,
                                child: SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Allergens',
                                          style: GoogleFonts.roboto(
                                            textStyle: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                        FutureBuilder(
                                            future: _allergenFuture,
                                            builder: (ctx, dataSnapShot) {
                                              if (dataSnapShot
                                                      .connectionState ==
                                                  ConnectionState.waiting) {
                                                return const Center(
                                                    child:
                                                        CircularProgressIndicator());
                                              } else {
                                                return Consumer<ApiCalls>(
                                                  builder:
                                                      (context, value, child) =>
                                                          ListView.builder(
                                                    shrinkWrap: true,
                                                    physics:
                                                        NeverScrollableScrollPhysics(),
                                                    itemCount: value
                                                        .allergenList.length,
                                                    itemBuilder:
                                                        (BuildContext context,
                                                            int index) {
                                                      return AllergenItem(
                                                          selectedAllergenes:
                                                              selectedAllergenes,
                                                          name:
                                                              value.allergenList[
                                                                      index]
                                                                  ['Allergen'],
                                                          data:
                                                              allergenSelected);
                                                    },
                                                  ),
                                                );
                                              }
                                            }),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                  _selectedFilter != filter.cusines
                      ? SizedBox()
                      : Padding(
                          padding: const EdgeInsets.only(left: 10.0, top: 25),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: width * 0.4,
                                height: dialogHeight * 0.8,
                                child: SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Cuisines',
                                          style: GoogleFonts.roboto(
                                            textStyle: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                        FutureBuilder(
                                            future: _cuisineFuture,
                                            builder: (ctx, dataSnapShot) {
                                              if (dataSnapShot
                                                      .connectionState ==
                                                  ConnectionState.waiting) {
                                                return const Center(
                                                    child:
                                                        CircularProgressIndicator());
                                              } else {
                                                return Consumer<ApiCalls>(
                                                  builder:
                                                      (context, value, child) =>
                                                          ListView.builder(
                                                    shrinkWrap: true,
                                                    physics:
                                                        NeverScrollableScrollPhysics(),
                                                    itemCount: value
                                                        .cuisinesCategoryList
                                                        .length,
                                                    itemBuilder:
                                                        (BuildContext context,
                                                            int index) {
                                                      return CuisineItemData(
                                                          name: value
                                                                  .cuisinesCategoryList[
                                                              index]['Cuisine'],
                                                          data: cuisineSelected,
                                                          selectedCuisines:
                                                              selectedCuisines,
                                                          cusinesId: value
                                                              .cuisinesCategoryList[
                                                                  index]
                                                                  ['Cuisine_Id']
                                                              .toString());
                                                    },
                                                  ),
                                                );
                                              }
                                            }),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                ],
              ),
              allergenApplyMethod(width, context)
            ],
          );
        },
      ),
    );
  }

  ListView displayProfiles() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: profileList.length,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
          child: DisplayProfiles(
            profileCode: profileList[index]['Profile_Code'],
            profileId: profileList[index]['Profile_Id'],
            businessName: profileList[index]['Business_Name'],
            businessAddress: profileList[index]['Business_Address'],
            businessCategory: profileList[index]['Business_Category'],
            firstName: profileList[index]['First_Name'],
            lastName: profileList[index]['Last_Name'],
            imageList: profileList[index]['Images'],
            email: profileList[index]['User__email'] ?? '',
          ),
        );
      },
    );
  }

  ListView displaySearchRestaurantResults() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _finalSearchRestaurantResults.length,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
          child: DisplaySearchRestaurantResults(
            list: _finalSearchRestaurantResults,
            index: index,
            key: UniqueKey(),
          ),
        );
      },
    );
  }

  ListView displaySearchResults() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _finalSearchFoodResults.length,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () {
            List temp = _finalSearchFoodResults;
            if (temp.length != 1) {
              for (int i = 0; i < temp.length; i++) {
                for (int j = 0; j < temp.length; j++) {
                  if (temp[j]['Profile']['Business_Name'] ==
                      temp[i]['Profile']['Business_Name']) {
                    temp.removeAt(i);
                  }
                }
              }
            }
            Get.toNamed(SearchResultsDisplayPage.routeName, arguments: temp);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
            child: DisplaySearchResults(
              list: _finalSearchFoodResults,
              index: index,
              searchText: _searchText,
              key: UniqueKey(),
            ),
          ),
        );
      },
    );
  }

  Padding allergenApplyMethod(double width, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: width * 0.3,
            alignment: Alignment.center,
            child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.orange)),
                onPressed: () {
                  // selectedAllergenes

                  Get.back();
                },
                child: Text('cancel')),
          ),
          Container(
            width: width * 0.3,
            alignment: Alignment.center,
            child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.orange)),
                onPressed: () {
                  // selectedAllergenes

                  var filter = {
                    'Allergenes': selectedAllergenes,
                    'Cuisines': selectedCuisineId
                  };
                  print(filter);

                  Provider.of<Authenticate>(context, listen: false)
                      .tryAutoLogin()
                      .then((value) {
                    var token =
                        Provider.of<Authenticate>(context, listen: false).token;
                    Provider.of<ApiCalls>(context, listen: false)
                        .sendSelectedAllergen(filter, token);
                  });
                  Get.back();
                },
                child: Text('Apply')),
          ),
        ],
      ),
    );
  }
}

class DisplaySearchRestaurantResults extends StatefulWidget {
  DisplaySearchRestaurantResults(
      {Key? key, required this.list, required this.index})
      : super(key: key);

  final List list;
  final int index;

  @override
  State<DisplaySearchRestaurantResults> createState() =>
      _DisplaySearchRestaurantResultsState();
}

class _DisplaySearchRestaurantResultsState
    extends State<DisplaySearchRestaurantResults> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Get.toNamed(MenuPageScreen.routeName, arguments: {
          'Profile_Id': widget.list[widget.index]['Profile']['Profile_Id'],
          // 'UserName': widget.firstName + widget.lastName,
          'Profile_Code': widget.list[widget.index]['Profile']['Profile_Code'],
          'Business_Name': widget.list[widget.index]['Profile']
              ['Business_Name'],
        });
      },
      title: Text(widget.list[widget.index]['Profile']['Business_Name']),
    );
  }
}

class DisplayProfiles extends StatefulWidget {
  DisplayProfiles(
      {Key? key,
      required this.profileId,
      required this.businessName,
      required this.businessAddress,
      required this.businessCategory,
      required this.firstName,
      required this.lastName,
      required this.profileCode,
      required this.imageList,
      required this.email})
      : super(key: key);

  final int profileId;
  final String businessName;
  final String businessAddress;
  final String businessCategory;
  final String firstName;
  final String lastName;
  final String profileCode;
  final List imageList;
  final String email;

  @override
  _DisplayProfilesState createState() => _DisplayProfilesState();
}

class _DisplayProfilesState extends State<DisplayProfiles> {
  int currentPos = 0;

  double height = 280;

  int _initialPage = 0;

  Future<dynamic> alertDialogs(
    BuildContext context,
    var alertMessage,
  ) {
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
              Navigator.of(ctx).pop();
              Provider.of<Authenticate>(context, listen: false)
                  .tryAutoLogin()
                  .then((value) {
                var token =
                    Provider.of<Authenticate>(context, listen: false).token;

                // Provider.of<ApiCalls>(context, listen: false).bookFood({
                //   'Profile_Id': widget.profileId,
                //   'title': 'New Order',
                //   'body': '2 plate Gobi Manchurian'
                // }, token).then((value) async {
                //   if (value == 200 || value == 201) {}
                // });
              });
            },
            child: const Text('ok'),
          )
        ],
      ),
    );
  }

  // ScrollController controller = ScrollController();
  CarouselController controller = CarouselController();
  DatabaseMethods databaseMethods = new DatabaseMethods();

  sendMessage(String userName, String hotelName) async {
    var myName = await HelperFunctions.getUserNameSharedPreference();
    List<String> users = [myName!, userName];

    print(myName);
    print(userName);

    String chatRoomId = hotelName;
    // getChatRoomId(myName, hotelName);

    Map<String, dynamic> chatRoom = {
      "users": users,
      "chatRoomId": chatRoomId,
    };

    print(chatRoomId);
    print(users);

    // databaseMethods.getUserChatRoom(chatRoomId).then((value) {
    //   print('chatRoomId ${value.toString()}');

    //   print('value ${value.docs.toString()}');
    // });

    databaseMethods.addChatRoom(chatRoom, chatRoomId);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Chat(
          chatRoomId: chatRoomId,
          userName: userName,
        ),
      ),
    );
  }

  getChatRoomId(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        Get.toNamed(MenuPageScreen.routeName, arguments: {
          'Profile_Id': widget.profileId,
          'UserName': widget.firstName + widget.lastName,
          'Profile_Code': widget.profileCode,
          'Business_Name': widget.businessName,
        });

        print(widget.profileId);

        // alertDialogs(
        //   context,
        //   'Are You Sure Want to Order This Item',
        // );
      },
      child: Card(
        elevation: 5,
        child: Container(
          width: width,
          height: height,
          child: Stack(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              backgroundImagePosition(width),
              // favoriteIconPosition(context),
              widget.imageList.isEmpty ? SizedBox() : previousImagePosition(),
              widget.imageList.isEmpty ? SizedBox() : nextImagePosition(),
              // _buildSliderDots(height, width),
              businessNamePosition(width),
              businessMessagePosition(width),
              businessAddressPosition(width),
              businessCategoryPosition(width),
            ],
          ),
        ),
      ),
    );
  }

  Positioned businessCategoryPosition(double width) {
    return Positioned(
        left: width * 0.02,
        bottom: height * 0.05,
        child: Text(widget.businessCategory));
  }

  Positioned businessAddressPosition(double width) {
    return Positioned(
        left: width * 0.02,
        bottom: height * 0.1,
        child: Text(widget.businessAddress));
  }

  Positioned businessNamePosition(double width) {
    return Positioned(
      bottom: height * 0.15,
      left: width * 0.02,
      child: Text(
        widget.businessName,
        style: GoogleFonts.roboto(
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Positioned businessMessagePosition(double width) {
    return Positioned(
      bottom: height * 0.07,
      right: width * 0.02,
      child: IconButton(
        onPressed: () {
          sendMessage(
            widget.email,
            widget.businessName,
          );
        },
        icon: Icon(
          Icons.message,
          color: Colors.orange,
          size: 30,
        ),
      ),
    );
  }

  Positioned backgroundImagePosition(double width) {
    return Positioned(
      // top: height * 0.01,
      // right: width * 0.01,
      child: ClipRRect(
        clipBehavior: Clip.hardEdge,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        child: Container(
          width: width,
          height: 200,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              // borderRadius: BorderRadius.only(
              //   topLeft: Radius.circular(40.0),
              //   topRight: Radius.circular(40.0),
              //   bottomLeft: Radius.circular(20.0),
              //   bottomRight: Radius.circular(20.0),
              // ),
              ),
          child: widget.imageList.isEmpty
              ? Image.asset(
                  'assets/images/default image.jpeg',
                  fit: BoxFit.fill,
                )
              : CarouselSlider.builder(
                  itemCount: widget.imageList.length,
                  carouselController: controller,

                  options: CarouselOptions(
                    // enableInfiniteScroll: false,
                    autoPlayCurve: Curves.easeInOutQuart,
                    height: 200,
                    enlargeCenterPage: true,
                    viewportFraction: 10,
                    autoPlayAnimationDuration: const Duration(seconds: 1),
                    autoPlayInterval: const Duration(seconds: 3),
                    // autoPlayInterval: ,

                    // aspectRatio: 16 / 9,
                    initialPage: _initialPage,

                    scrollDirection: Axis.horizontal,
                    autoPlay: true,
                    onPageChanged: (index, reason) {
                      setState(() {
                        currentPos = index;
                      });
                    },
                  ),

                  itemBuilder:
                      (BuildContext context, int index, int realIndex) {
                    return Container(
                      // decoration: BoxDecoration(
                      //   borderRadius: BorderRadius.only(
                      //     topLeft: Radius.circular(40.0),
                      //     topRight: Radius.circular(40.0),
                      //     bottomLeft: Radius.circular(20.0),
                      //     bottomRight: Radius.circular(20.0),
                      //   ),
                      //   // border: Border.all(),
                      // ),
                      width: width,
                      child: CachedNetworkImage(
                        fit: BoxFit.fill,

                        // width: 400,
                        imageUrl: widget.imageList[index]['Food_Image'],
                      ),
                    );
                  },
                  // itemBuilder: (BuildContext context, int index) {
                  //   return
                  //   CachedNetworkImage(
                  //     fit: BoxFit.fill,
                  //     width: 500,
                  //     imageUrl: widget.imagePath[index],
                  //   );
                  // },
                ),
        ),
      ),
    );
  }

  Positioned previousImagePosition() {
    return Positioned(
      left: 1,
      top: height * 0.3,
      child: IconButton(
        onPressed: () {
          // setState(() {
          // if (currentPos == 0) {
          //   print('return');
          //   return;
          // } else {}
          // controller.jumpToPage(currentPos + 1);
          controller.previousPage(
              duration: Duration(milliseconds: 300), curve: Curves.linear);
          // });
        },
        icon: Container(
          width: 30,
          height: 30,
          child: Image.asset(
            'assets/images/previous.png',
            color: Colors.black.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  Positioned nextImagePosition() {
    return Positioned(
        right: 1,
        top: height * 0.3,
        child: IconButton(
          onPressed: () {
            controller.nextPage();
          },
          icon: Container(
            width: 30,
            height: 30,
            child: Image.asset(
              'assets/images/next.png',
              color: Colors.black.withOpacity(0.5),
            ),
          ),
        ));
  }

  Positioned favoriteIconPosition(BuildContext context) {
    return Positioned(
        top: 1,
        right: 1,
        child: IconButton(
            onPressed: () {
              Provider.of<Authenticate>(context, listen: false)
                  .tryAutoLogin()
                  .then((value) async {
                var token =
                    Provider.of<Authenticate>(context, listen: false).token;
                final prefs = await SharedPreferences.getInstance();
                if (!prefs.containsKey('CustomerProfile')) {
                  final extratedUserData =
                      //we should use dynamic as a another value not a Object
                      json.decode(prefs.getString('CustomerProfile')!)
                          as Map<String, dynamic>;
                  Provider.of<ApiCalls>(context, listen: false).addToFavorites(
                      extratedUserData['Consumer_Id'],
                      {'favorites': widget.profileId},
                      token);
                } else {
                  Provider.of<ApiCalls>(context, listen: false)
                      .fetchUser(token)
                      .then((value) {
                    if (value['Status_Code'] == 200) {
                      Provider.of<ApiCalls>(context, listen: false)
                          .fetchCustomerProfile(value['Id'], token)
                          .then((value) {
                        if (value['StatusCode'] == 200 ||
                            value['StatusCode'] == 201) {
                          if (value['Body'] == null) {
                            Get.defaultDialog(
                                title: 'Alert',
                                middleText:
                                    'You have not created your profile\n create it to add restaurants to favorites',
                                confirm: TextButton(
                                    onPressed: () {
                                      Get.back();
                                    },
                                    child: Text('ok')));
                          } else {
                            Provider.of<ApiCalls>(context, listen: false)
                                .addToFavorites(value['Body']['Consumer'],
                                    {'favorites': widget.profileId}, token);
                          }
                        }
                      });
                    }
                  });
                }
              });
            },
            icon: Icon(
              Icons.favorite_border,
              color: Colors.orange,
            )));
  }

  Widget _buildSliderDots(var height, var width) {
    return Positioned(
      left: width * 0.42,
      // left: 180,
      bottom: height * 0.35,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: widget.imageList.map((url) {
          int index = widget.imageList.indexOf(url);
          return Container(
            width: 8.0,
            height: 8.0,
            margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: currentPos == index
                  ? Color.fromRGBO(0, 0, 0, 0.9)
                  : Color.fromRGBO(0, 0, 0, 0.4),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class DisplaySearchResults extends StatefulWidget {
  const DisplaySearchResults(
      {Key? key,
      required this.list,
      required this.index,
      required this.searchText})
      : super(key: key);

  final List list;
  final int index;
  final String searchText;

  @override
  State<DisplaySearchResults> createState() => _DisplaySearchResultsState();
}

class _DisplaySearchResultsState extends State<DisplaySearchResults> {
  @override
  Widget build(BuildContext context) {
    print('some ${widget.searchText}');
    return ListTile(
      leading: widget.list[widget.index]['Food_Image'] == null
          ? SizedBox()
          : Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(widget.list[widget.index]['Food_Image']),
                ),
              ),
            ),
      title: Text(widget.list[widget.index]['Food_Name']),
    );
  }
}

class AllergenItem extends StatefulWidget {
  AllergenItem(
      {Key? key,
      required this.name,
      required this.data,
      required this.selectedAllergenes})
      : super(key: key);
  final String name;
  final ValueChanged<Map<String, dynamic>> data;
  final List selectedAllergenes;

  @override
  State<AllergenItem> createState() => _AllergenItemState();
}

class _AllergenItemState extends State<AllergenItem> {
  bool selected = false;
  @override
  void initState() {
    super.initState();
    if (widget.selectedAllergenes.isNotEmpty) {
      if (widget.selectedAllergenes.contains(widget.name)) {
        selected = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
            activeColor: Colors.orange,
            value: selected,
            onChanged: (value) {
              setState(() {
                selected = value!;
                widget.data({'value': value, 'Allergen': widget.name});
              });
            }),
        Expanded(child: Text(widget.name))
      ],
    );
  }
}

class CuisineItemData extends StatefulWidget {
  CuisineItemData(
      {Key? key,
      required this.name,
      required this.data,
      required this.selectedCuisines,
      required this.cusinesId})
      : super(key: key);
  final String name;
  final ValueChanged<Map<String, dynamic>> data;
  final List selectedCuisines;
  final String cusinesId;

  @override
  State<CuisineItemData> createState() => _CuisineItemDataState();
}

class _CuisineItemDataState extends State<CuisineItemData> {
  bool selected = false;
  @override
  void initState() {
    super.initState();
    if (widget.selectedCuisines.isNotEmpty) {
      if (widget.selectedCuisines.contains(widget.name)) {
        selected = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
            activeColor: Colors.orange,
            value: selected,
            onChanged: (value) {
              setState(() {
                selected = value!;
                widget.data({
                  'value': value,
                  'Cuisine': widget.name,
                  'CuisineId': widget.cusinesId,
                });
              });
            }),
        Expanded(child: Text(widget.name))
      ],
    );
  }
}

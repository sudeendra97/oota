import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiCalls with ChangeNotifier {
  List _menuList = [];

  List _profileList = [];

  var _orderList = [];

  Map<String, dynamic> _consumerProfile = {};

  List _searchList = [];

  Map<String, dynamic> _singleOrderList = {};

  List _allergenList = [];

  List _cuisinesCategoryList = [];

  List get cuisinesCategoryList {
    return _cuisinesCategoryList;
  }

  List get allergenList {
    return _allergenList;
  }

  List get searchList {
    return _searchList;
  }

  Map<String, dynamic> get consumerProfile {
    return _consumerProfile;
  }

  Map<String, dynamic> get singleOrderList {
    return _singleOrderList;
  }

  List get orderList {
    return _orderList;
  }

  List get profileList {
    return _profileList;
  }

  List get menuList {
    return _menuList;
  }

  var baseUrl = 'https://projectoota.herokuapp.com/';

  Future<Map<String, dynamic>> sendProfileSetUp(var data, var token) async {
    final url = Uri.parse('${baseUrl}business/profile-list/');
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8",
          "Authorization": 'Token $token'
        },
        body: json.encode(data),
      );

      // print(response.statusCode);
//       print(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseData = json.decode(response.body);
        return {
          'Status_Code': response.statusCode,
          'Id': responseData['Profile_Id'],
        };
      }
      return {'Status_Code': response.statusCode, 'Response_Body': ''};
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

  Future<Map<String, dynamic>> sendSelectedAllergen(var data, var token) async {
    final url = Uri.parse('${baseUrl}menu-data/allergen-list/');
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8",
          "Authorization": 'Token $token'
        },
        body: json.encode(data),
      );

      print(response.statusCode);
      log(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseData = json.decode(response.body);
        _profileList = responseData;
        notifyListeners();
        return {
          'Status_Code': response.statusCode,
          // 'Id': responseData['Profile_Id'],
        };
      }
      return {'Status_Code': response.statusCode, 'Response_Body': ''};
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

  Future<int> getCuisinesCategory(var token) async {
    final url = Uri.parse('${baseUrl}menu-data/cuisine-list/');
    try {
      final response = await http.get(
        url,
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8",
          "Authorization": 'Token $token'
        },
      );

      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);

        _cuisinesCategoryList = responseData;
        notifyListeners();
      }

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

  Future<Map<String, dynamic>> addToFavorites(
      var id, var data, var token) async {
    final url = Uri.parse('${baseUrl}consumer/consumer-favorite-list/$id/');
    try {
      final response = await http.patch(
        url,
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8",
          "Authorization": 'Token $token'
        },
        body: json.encode(data),
      );

      print(response.statusCode);
      log(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseData = json.decode(response.body);
        // _profileList = responseData;
        notifyListeners();
        return {
          'Status_Code': response.statusCode,
          // 'Id': responseData['Profile_Id'],
        };
      }
      return {'Status_Code': response.statusCode, 'Response_Body': ''};
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

  Future<int> sendBusinessHours(var data, var id, var token) async {
    final url = Uri.parse('${baseUrl}business/businesshours-list/$id/');
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8",
          "Authorization": 'Token $token'
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

  Future<int> sendBankPaymentOptions(var data, var id, var token) async {
    final url = Uri.parse('${baseUrl}business/bankpayment-list/$id/');
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8",
          "Authorization": 'Token $token'
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

  Future<int> sendBpayDetails(var data, var id, var token) async {
    final url = Uri.parse('${baseUrl}business/bpay-list/$id/');
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8",
          "Authorization": 'Token $token'
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

  Future<int> sendMessageNotification(var data, var token) async {
    final url = Uri.parse('${baseUrl}business/sendmessage/');

    print(data);
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8",
          "Authorization": 'Token $token'
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

  Future<int> fetchBusinessProfileDetails(var token) async {
    final url = Uri.parse('${baseUrl}business/get-profiles/');
    try {
      final response = await http.get(
        url,
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8",
          "Authorization": 'Token $token'
        },
      );

      print(response.statusCode);
      log('Profile List ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseData = json.decode(response.body);

        _profileList = responseData;
        notifyListeners();
        return response.statusCode;
      }
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

  Future<Map<String, dynamic>> fetchUser(var token) async {
    final url = Uri.parse('${baseUrl}business/user-details/');
    try {
      final response = await http.get(
        url,
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8",
          "Authorization": 'Token $token'
        },
      );

      // print(response.statusCode);
      // print(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseData = json.decode(response.body);
        return {
          'Status_Code': response.statusCode,
          'Id': responseData['id'],
        };
      }
      return {'Status_Code': response.statusCode, 'Response_Body': ''};
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

  Future<Map<String, dynamic>> addCustomerProfile(
    var data,
    var id,
    var token,
  ) async {
    final url = Uri.parse('${baseUrl}consumer/consumer-list/$id/');

    Map<String, String> headers = {
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": 'Token $token'
    };
    try {
      var request = http.MultipartRequest('POST', url);
      request.headers.addAll(headers);
      // if (image.isNotEmpty) {
      //   request.files.add(
      //     http.MultipartFile.fromBytes('Image', image,
      //         // File(image).readAsBytesSync(),
      //         // File(image.relativePath).lengthSync(),
      //         filename: name),
      //   );
      // }

      request.fields['First_Name'] = data['First_Name'].toString();
      request.fields['Last_Name'] = data['Last_Name'];
      request.fields['Mobile'] = data['Mobile'];
      request.fields['Street'] = data['Street'];
      // request.fields['City'] = data['City'].toString();
      // request.fields['State'] = data['State'];
      // request.fields['Zip_Code'] = data['Zip_Code'].toString();
      // request.fields['Description'] = data['Description'].toString();
      request.fields['User'] = data['User'].toString();
      request.fields['Latitude'] = data['Latitude'].toString();
      request.fields['Longitude'] = data['Longitude'].toString();
      request.fields['Profile_Code'] = data['Profile_Code'].toString();

      var res = await request.send();
      // print(res.statusCode);

      var responseString = await res.stream.bytesToString();
      // print(responseString);
      if (res.statusCode == 201) {
        return {'StatusCode': res.statusCode, 'Id': responseString};
      }

      return {
        'StatusCode': res.statusCode,
      };
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

  Future<Map<String, dynamic>> updateCustomerProfile(
    var data,
    var id,
    var token,
  ) async {
    final url = Uri.parse('${baseUrl}consumer/consumer-details/$id/');

    Map<String, String> headers = {
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": 'Token $token'
    };
    try {
      var request = http.MultipartRequest('PUT', url);
      request.headers.addAll(headers);
      // if (image.isNotEmpty) {
      //   request.files.add(
      //     http.MultipartFile.fromBytes('Image', image,
      //         // File(image).readAsBytesSync(),
      //         // File(image.relativePath).lengthSync(),
      //         filename: name),
      //   );
      // }

      request.fields['First_Name'] = data['First_Name'].toString();
      request.fields['Last_Name'] = data['Last_Name'];
      request.fields['Mobile'] = data['Mobile'];
      request.fields['Street'] = data['Street'];
      // request.fields['City'] = data['City'].toString();
      // request.fields['State'] = data['State'];
      // request.fields['Zip_Code'] = data['Zip_Code'].toString();
      // request.fields['Description'] = data['Description'].toString();
      request.fields['User'] = data['User'].toString();
      request.fields['Latitude'] = data['Latitude'].toString();
      request.fields['Longitude'] = data['Longitude'].toString();
      request.fields['Profile_Code'] = data['Profile_Code'].toString();

      var res = await request.send();
      print(res.statusCode);

      var responseString = await res.stream.bytesToString();
      print(responseString);
      if (res.statusCode == 201 || res.statusCode == 202) {
        return {'StatusCode': res.statusCode, 'Id': responseString};
      }

      return {
        'StatusCode': res.statusCode,
      };
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

  Future<Map<String, dynamic>> fetchCustomerProfile(var id, var token) async {
    final url = Uri.parse('${baseUrl}consumer/consumer-details/$id/');

    try {
      final response = await http.get(
        url,
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8",
          "Authorization": 'Token $token'
        },
      );

      // print(response.statusCode);
      // print(response.body);

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          return {'StatusCode': response.statusCode, 'Body': null};
        } else {
          var responseData = json.decode(response.body);
          _consumerProfile = responseData;
          notifyListeners();
          final prefs = await SharedPreferences.getInstance();
          final userData = json.encode(
            {
              'Consumer_Id': responseData['Consumer'],
              'First_Name': responseData['First_Name'],
              'Last_Name': responseData['Last_Name'],
              'Mobile': responseData['Mobile'],
              'Street': responseData['Street'],
              'City': responseData['City'],
              'State': responseData['State'],
              'Zip_Code': responseData['Zip_Code'],
              'Latitude': responseData['Latitude'],
              'Longitude': responseData['Longitude'],
              'Profile_Code': responseData['Profile_Code'],
            },
          );
          prefs.setString('CustomerProfile', userData);
          return {'StatusCode': response.statusCode, 'Body': responseData};
        }
      }

      return {
        'StatusCode': response.statusCode,
      };
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

  Future<int> replaceMenuItem(
      var data, var id, var token, var image, var name) async {
    // print(name);
    final url = Uri.parse('${baseUrl}menu-data/menu-details/$id/');

    Map<String, String> headers = {
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": 'Token $token'
    };
    try {
      var request = http.MultipartRequest('PUT', url);
      request.headers.addAll(headers);
      if (image.isNotEmpty) {
        request.files.add(
          http.MultipartFile.fromBytes('Food_Image', image,
              // File(image).readAsBytesSync(),
              // File(image.relativePath).lengthSync(),
              filename: name),
        );
      }

      request.fields['Profile'] = data['Profile'].toString();
      request.fields['Food_Name'] = data['Food_Name'];
      request.fields['Ingredients'] = data['Ingredients'];
      request.fields['Allergen'] = data['Allergen'];
      request.fields['Price'] = data['Price'].toString();
      request.fields['Description'] = data['Description'];
      request.fields['Preparation_Time'] = data['Preparation_Time'].toString();

      var res = await request.send();
      // print(res.statusCode);

      var responseString = await res.stream.bytesToString();
      // print(responseString);

      // if (res.statusCode == 204 || res.statusCode == 202) {
      //   fetchMenuItems(token, data['Profile']).then((value) {
      //     return res.statusCode;
      //   });
      // }

      return res.statusCode;
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

  Future<int> editMenuItems(var data, var id, var token) async {
    // print(id);
    final url = Uri.parse('${baseUrl}menu-data/menu-details/$id/');

    var headers = <String, String>{
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": 'Token $token'
    };
    try {
      // final response = await http.patch(
      //   url,
      //   headers: <String, String>{
      //     "Content-Type": "application/json; charset=UTF-8",
      //     "Authorization": 'Token $token'
      //   },
      //   body: json.encode(data),
      // );
      var request = http.MultipartRequest('PATCH', url);
      request.headers.addAll(headers);
      // if (image.isNotEmpty) {
      //   request.files.add(
      //     http.MultipartFile.fromBytes('Food_Image', image,
      //         // File(image).readAsBytesSync(),
      //         // File(image.relativePath).lengthSync(),
      //         filename: name),
      //   );
      // }

      request.fields['Profile'] = data['Profile'].toString();
      request.fields['Food_Name'] = data['Food_Name'];
      request.fields['Ingredients'] = data['Ingredients'];
      request.fields['Allergen'] = data['Allergen'];
      request.fields['Price'] = data['Price'].toString();
      request.fields['Description'] = data['Description'];
      request.fields['Preparation_Time'] = data['Preparation_Time'].toString();

      var res = await request.send();
      // print(res.statusCode);

      var responseString = await res.stream.bytesToString();
      // print(responseString);

      return res.statusCode;
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

  Future<int> editMenuImage(var id, var token, var image, var name) async {
    // print(name);
    final url = Uri.parse('${baseUrl}menu-data/menu-details/$id/');

    Map<String, String> headers = {
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": 'Token $token'
    };
    try {
      var request = http.MultipartRequest('PATCH', url);
      request.headers.addAll(headers);
      if (image.isNotEmpty) {
        request.files.add(
          http.MultipartFile.fromBytes('Food_Image', image,
              // File(image).readAsBytesSync(),
              // File(image.relativePath).lengthSync(),
              filename: name),
        );
      }

      // request.fields['Profile'] = data['Profile'].toString();
      // request.fields['Food_Name'] = data['Food_Name'];
      // request.fields['Ingredients'] = data['Ingredients'];
      // request.fields['Allergen'] = data['Allergen'];
      // request.fields['Price'] = data['Price'].toString();
      // request.fields['Description'] = data['Description'];
      // request.fields['Preparation_Time'] = data['Preparation_Time'].toString();

      var res = await request.send();
      // print(res.statusCode);

      var responseString = await res.stream.bytesToString();
      // print(responseString);

      return res.statusCode;
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

  Future<Map<String, dynamic>> fetchMenuItems(var token, var id) async {
    final url = Uri.parse('${baseUrl}menu-data/menu-list/$id/');
    try {
      final response = await http.get(
        url,
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8",
          "Authorization": 'Token $token'
        },
      );

      // print(response.statusCode);
      log(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseData = json.decode(response.body);
        _menuList = responseData;
        notifyListeners();

        return {
          'Status_Code': response.statusCode,
          'Response_Body': responseData
        };
      }
      return {'Status_Code': response.statusCode, 'Response_Body': []};
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

  Future<int> searchMenuItems(var token, var item) async {
    // print(item);

    final url = Uri.parse('${baseUrl}menu-data/menu-search/?search=$item');
    try {
      final response = await http.get(
        url,
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8",
          "Authorization": 'Token $token'
        },
      );

      // print(response.statusCode);
      log(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseData = json.decode(response.body);
        _searchList = responseData;
        notifyListeners();
        return response.statusCode;
      }
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

  Future<int> updateStockValue(var data, var id, var token) async {
    // print(id);
    final url = Uri.parse('${baseUrl}menu-data/menu-details/$id/');

    var headers = <String, String>{
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": 'Token $token'
    };
    try {
      // final response = await http.patch(
      //   url,
      //   headers: <String, String>{
      //     "Content-Type": "application/json; charset=UTF-8",
      //     "Authorization": 'Token $token'
      //   },
      //   body: json.encode(data),
      // );
      var request = http.MultipartRequest('PATCH', url);
      request.headers.addAll(headers);
      // if (image.isNotEmpty) {
      //   request.files.add(
      //     http.MultipartFile.fromBytes('Food_Image', image,
      //         // File(image).readAsBytesSync(),
      //         // File(image.relativePath).lengthSync(),
      //         filename: name),
      //   );
      // }

      request.fields['In_Stock'] = data.toString();

      var res = await request.send();
      // print(res.statusCode);

      var responseString = await res.stream.bytesToString();
      // print(responseString);

      return res.statusCode;
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

  Future<Map<String, dynamic>> bookFood(var id, var data, var token) async {
    final url = Uri.parse('${baseUrl}order/newOrder-list/$id/');
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8",
          "Authorization": 'Token $token'
        },
        body: json.encode(data),
      );

      // print(response.statusCode);
      // print(response.body);
      if (response.statusCode == 201) {
        var responseData = json.decode(response.body);
        return {'Status_Code': response.statusCode, 'Body': responseData};
      } else {
        return {'Status_Code': response.statusCode, 'Body': {}};
      }
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

  Future<int> updateRatings(var id, var data, var token) async {
    final url = Uri.parse('${baseUrl}order/order-details/$id/');
    try {
      final response = await http.patch(
        url,
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8",
          "Authorization": 'Token $token'
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

  Future<Map<String, dynamic>> fetchOrders(var id, var token) async {
    final url = Uri.parse('${baseUrl}order/order-list/');
    // final url1 = Uri.parse(
    //     'https://mobilenallimenu.herokuapp.com/restrant/menu-details/1/');

    print('object');

    try {
      final response = await http.get(
        url,
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8",
          "Authorization": 'Token $token'
        },
      );
      // print(response.statusCode);
      log(response.body);

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        _orderList = responseData;
        notifyListeners();
        return {'Status_Code': response.statusCode, 'Body': responseData};
      }

      return {'Status_Code': response.statusCode, 'Body': {}};
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

  Future<Map<String, dynamic>> fetchAllergenes(var token) async {
    final url = Uri.parse('${baseUrl}menu-data/allergen-list/');
    // final url1 = Uri.parse(
    //     'https://mobilenallimenu.herokuapp.com/restrant/menu-details/1/');

    print('object');

    try {
      final response = await http.get(
        url,
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8",
          "Authorization": 'Token $token'
        },
      );
      // print(response.statusCode);
      log(response.body);

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        _allergenList = responseData;
        notifyListeners();
        return {'Status_Code': response.statusCode, 'Body': responseData};
      }

      return {'Status_Code': response.statusCode, 'Body': {}};
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

  Future<Map<String, dynamic>> fetchSingleOrder(var id, var token) async {
    final url = Uri.parse('${baseUrl}order/order-details/$id');
    try {
      final response = await http.get(
        url,
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8",
          "Authorization": 'Token $token'
        },
      );
      // print(response.statusCode);
      log(response.body);

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        _singleOrderList = responseData;
        notifyListeners();
        return {'Status_Code': response.statusCode, 'Body': responseData};
      }

      return {'Status_Code': response.statusCode, 'Body': {}};
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

  Future<int> sendFCMDeviceModel(var data, var token) async {
    // print(data);
    final url = Uri.parse('${baseUrl}consumer/consumer-fcm-list/');
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8",
          "Authorization": 'Token $token'
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
}

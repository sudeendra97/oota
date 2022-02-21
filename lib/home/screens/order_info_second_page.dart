import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:oota/authentication/providers/api_calls.dart';
import 'package:oota/authentication/providers/authenticate.dart';
import 'package:provider/provider.dart';

import '../../chat.dart';
import '../../helper/helperfunctions.dart';
import '../../services/database.dart';

class OrderInfoSecondPage extends StatefulWidget {
  OrderInfoSecondPage({Key? key}) : super(key: key);
  static const routeName = '/OrderInfoSecondPage';

  @override
  State<OrderInfoSecondPage> createState() => _OrderInfoSecondPageState();
}

class _OrderInfoSecondPageState extends State<OrderInfoSecondPage> {
  var orderId;
  var data;
  var businessEmail;
  Map<String, dynamic> _orderDetails = {};

  @override
  void initState() {
    data = Get.arguments;
    if (data != null) {
      orderId = data['orderId'];
      businessEmail = data['businessEmail'];
      print(businessEmail);
    }

    Provider.of<Authenticate>(context, listen: false)
        .tryAutoLogin()
        .then((value) {
      var token = Provider.of<Authenticate>(context, listen: false).token;
      Provider.of<ApiCalls>(context, listen: false)
          .fetchSingleOrder(orderId, token)
          .then((value) => null);
    });

    super.initState();
  }

  var date;
  var status;

  TextStyle generalStyle() {
    return GoogleFonts.roboto(
        textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ));
  }

  TextStyle specialStyle() {
    return GoogleFonts.roboto(
        textStyle: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
    ));
  }

  DatabaseMethods databaseMethods = new DatabaseMethods();

  sendMessage(String userName, String chatId) async {
    var myName = await HelperFunctions.getUserNameSharedPreference();
    List<String> users = [myName!, userName];

    print(myName);
    print(userName);

    String chatRoomId = chatId;

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
    _orderDetails = Provider.of<ApiCalls>(context).singleOrderList;
    if (_orderDetails.isNotEmpty) {
      date = DateFormat.yMMMEd()
          .format(DateTime.parse(_orderDetails['Created_On']));
      if (_orderDetails['Status'] == '' || _orderDetails['Status'] == null) {
        status = 'Pending';
      } else if (_orderDetails['Status'] == 'Ready') {
        status = 'Ready';
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order Info',
          style: GoogleFonts.roboto(
              textStyle: const TextStyle(color: Colors.black)),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Status:',
                    style: specialStyle(),
                  ),
                  Text(
                    status ?? '',
                    style: generalStyle(),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order Code:',
                    style: specialStyle(),
                  ),
                  Text(
                    _orderDetails['Order_Code'] ?? '',
                    style: generalStyle(),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ordered On:',
                    style: specialStyle(),
                  ),
                  Text(
                    date ?? '',
                    style: generalStyle(),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Text(
                    'Item Details',
                    style: GoogleFonts.roboto(
                        textStyle: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              _orderDetails.isEmpty
                  ? const SizedBox()
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _orderDetails['Items'].length,
                      itemBuilder: (BuildContext context, int index) {
                        return Row(
                          children: [
                            Text(
                              _orderDetails['Items'][index]['Food_Quantity']
                                  .toString(),
                              style: generalStyle(),
                            ),
                            Text(
                              'X',
                              style: generalStyle(),
                            ),
                            Text(
                              _orderDetails['Items'][index]['Food_Name'],
                              style: generalStyle(),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '\$${_orderDetails['Items'][index]['Total_Food_Price'].toString()}',
                                  style: generalStyle(),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
              const Divider(
                color: Colors.black,
              ),
              Row(
                children: [
                  Text(
                    'Grand Total',
                    style: specialStyle(),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '\$${_orderDetails['Price'].toString()}',
                        style: generalStyle(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  Text(
                    'Paid Through',
                    style: specialStyle(),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Card',
                        style: generalStyle(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  Text(
                    'Payment process',
                    style: specialStyle(),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Success',
                        style: generalStyle(),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 25.0),
                child: IconButton(
                  onPressed: () {
                    sendMessage(businessEmail, _orderDetails['Order_Code']);
                  },
                  icon: Icon(
                    Icons.message,
                    size: 40,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

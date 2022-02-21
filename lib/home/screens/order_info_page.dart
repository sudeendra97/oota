import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:oota/authentication/providers/api_calls.dart';
import 'package:oota/authentication/providers/authenticate.dart';
import 'package:oota/home/screens/nav_bar_screen.dart';
import 'package:provider/provider.dart';

class OrderInfoFirstPage extends StatefulWidget {
  OrderInfoFirstPage({Key? key}) : super(key: key);

  static const routeName = '/OrderInfoPage';

  @override
  State<OrderInfoFirstPage> createState() => _OrderInfoFirstPageState();
}

class _OrderInfoFirstPageState extends State<OrderInfoFirstPage> {
  var orderDetails;

  Map<String, dynamic> _orderDetails = {};

  @override
  void initState() {
    orderDetails = Get.arguments;

    Provider.of<Authenticate>(context, listen: false)
        .tryAutoLogin()
        .then((value) {
      var token = Provider.of<Authenticate>(context, listen: false).token;
      Provider.of<ApiCalls>(context, listen: false)
          .fetchSingleOrder(orderDetails['Order_Id'], token)
          .then((value) => null);
    });

    super.initState();
  }

  var date;
  var status;

  TextStyle generalStyle() {
    return GoogleFonts.roboto(
        textStyle: const TextStyle(
      fontSize: 14,
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

  @override
  Widget build(BuildContext context) {
    _orderDetails = Provider.of<ApiCalls>(context).singleOrderList;
    if (_orderDetails.isNotEmpty) {
      date = DateFormat.yMMMEd()
          .format(DateTime.parse(_orderDetails['Created_On']));
      if (_orderDetails['Status'] == '' || _orderDetails['Status'] == null) {
        status = 'Pending';
      }
    }
    return WillPopScope(
      onWillPop: () async {
        Get.offNamed(NavBarScreen.routeName);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Order Info',
            style: GoogleFonts.roboto(
                textStyle: const TextStyle(color: Colors.black)),
          ),
          leading: IconButton(
              onPressed: () {
                Get.offNamed(NavBarScreen.routeName);
              },
              icon: const Icon(Icons.arrow_back)),
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          elevation: 0,
          automaticallyImplyLeading: true,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
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
              )
            ],
          ),
        ),
      ),
    );
  }
}

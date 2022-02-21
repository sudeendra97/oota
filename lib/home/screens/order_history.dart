import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oota/authentication/providers/api_calls.dart';
import 'package:oota/authentication/providers/authenticate.dart';
import 'package:provider/provider.dart';
import 'package:skeletons/skeletons.dart';

import 'orders_screen.dart';

class OrderHistory extends StatefulWidget {
  OrderHistory({Key? key}) : super(key: key);

  static const routeName = '/OrderHistory';

  @override
  State<OrderHistory> createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  List _ordersList = [];

  bool orderList = true;

  @override
  void initState() {
    Provider.of<Authenticate>(context, listen: false)
        .tryAutoLogin()
        .then((value) {
      var token = Provider.of<Authenticate>(context, listen: false).token;
      Provider.of<ApiCalls>(context, listen: false)
          .fetchOrders(1, token)
          .then((value) async {
        if (value['Status_Code'] == 200 || value['Status_Code'] == 201) {
          if (value['Body'].isEmpty) {
            setState(() {
              orderList = false;
            });
          }
        }
      });
    });
    super.initState();
  }

  Future<void> fetchOrders() async {
    Provider.of<Authenticate>(context, listen: false)
        .tryAutoLogin()
        .then((value) {
      var token = Provider.of<Authenticate>(context, listen: false).token;
      Provider.of<ApiCalls>(context, listen: false)
          .fetchOrders(1, token)
          .then((value) async {
        if (value['Status_Code'] == 200 || value['Status_Code'] == 201) {
          if (value['Body'].isEmpty) {
            setState(() {
              orderList = false;
            });
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var topPadding = MediaQuery.of(context).padding.top;
    _ordersList = Provider.of<ApiCalls>(context).orderList;
    // if (_ordersList.isEmpty) {
    //   EasyLoading.show();
    // } else {
    //   EasyLoading.dismiss();
    // }
    return Scaffold(
      body: _ordersList.isEmpty && orderList == true
          ? Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: skeletonDisplay(),
            )
          : orderList == false
              ? const Center(
                  child: Text('No Orders Found!'),
                )
              : RefreshIndicator(
                  onRefresh: () => fetchOrders(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 15, vertical: topPadding + 10),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                  onPressed: () {
                                    Get.back();
                                  },
                                  icon: Icon(Icons.arrow_back)),
                              Text(
                                'History',
                                style: GoogleFonts.roboto(
                                    textStyle: const TextStyle(fontSize: 24)),
                              ),
                            ],
                          ),
                          Flexible(
                            fit: FlexFit.loose,
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _ordersList.length,
                              itemBuilder: (BuildContext context, int index) {
                                return OrderItem(
                                  email: _ordersList[index]
                                      ['Profile__User__email'],
                                  orderId: _ordersList[index]['Order_Id'],
                                  rating: _ordersList[index]['Rating'],
                                  businessName: _ordersList[index]
                                      ['Profile__Business_Name'],
                                  orderCode: _ordersList[index]['Order_Code']
                                      .toString(),
                                  date: _ordersList[index]['Created_On'],
                                  totalPrice:
                                      _ordersList[index]['Price'].toString(),
                                  items: _ordersList[index]['Items'],
                                  status: _ordersList[index]['Status'] == '' ||
                                          _ordersList[index]['Status'] == null
                                      ? 'Pending'
                                      : _ordersList[index]['Status'],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  SkeletonListView skeletonDisplay() => SkeletonListView(
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
              height: 80,
              minLength: MediaQuery.of(context).size.width * 0.8,
              randomLength: true,
              borderRadius: BorderRadius.circular(12)),
          // subtitleStyle: SkeletonLineStyle(
          //     height: 12,
          //     minLength: MediaQuery.of(context).size.width * 2 / 3,
          //     randomLength: true,
          //     borderRadius: BorderRadius.circular(12)),
          hasSubtitle: false,
        ),
      );
}

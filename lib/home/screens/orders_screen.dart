import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oota/authentication/providers/api_calls.dart';
import 'package:oota/authentication/providers/authenticate.dart';
import 'package:oota/home/screens/order_info_second_page.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:skeletons/skeletons.dart';

class OrdersScreen extends StatefulWidget {
  OrdersScreen({Key? key}) : super(key: key);

  static const routeName = '/OrdersScreen';

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
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
                              // IconButton(
                              //     onPressed: () {
                              //       Get.back();
                              //     },
                              //     icon: Icon(Icons.arrow_back)),
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
                                  email: _ordersList[index]
                                      ['Profile__User__email'],
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

class OrderItem extends StatefulWidget {
  OrderItem(
      {Key? key,
      required this.orderCode,
      required this.date,
      required this.totalPrice,
      required this.items,
      required this.status,
      required this.businessName,
      required this.rating,
      required this.orderId,
      required this.email})
      : super(key: key);

  final String orderCode;
  final String date;
  final String totalPrice;
  final List items;
  final String status;
  final String businessName;
  final String rating;
  final int orderId;
  final String email;

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  var date;

  @override
  void initState() {
    date = DateFormat.yMMMEd().format(DateTime.parse(widget.date));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        Get.toNamed(OrderInfoSecondPage.routeName, arguments: {
          'orderId': widget.orderId.toString(),
          'businessEmail': widget.email
        });
      },
      child: Card(
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
          child: Container(
            width: width - 30,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.businessName,
                        style: GoogleFonts.roboto(
                            textStyle: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500)),
                      ),
                      widget.status == 'Accept'
                          ? Text(
                              widget.status,
                              style: GoogleFonts.roboto(
                                  textStyle:
                                      const TextStyle(color: Colors.green)),
                            )
                          : widget.status == 'Pending'
                              ? Text(
                                  widget.status,
                                  style: GoogleFonts.roboto(
                                      textStyle: const TextStyle(
                                          color: Colors.orange)),
                                )
                              : widget.status == 'Ready'
                                  ? Text(
                                      widget.status,
                                      style: GoogleFonts.roboto(
                                          textStyle: const TextStyle(
                                              color: Colors.green)),
                                    )
                                  : Text(
                                      widget.status,
                                      style: GoogleFonts.roboto(
                                          textStyle: const TextStyle(
                                              color: Colors.red)),
                                    ),
                    ],
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.items.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          SizedBox(
                              width: 15,
                              child: Text(widget.items[index]['Food_Quantity']
                                  .toString())),
                          const SizedBox(width: 15, child: Text('X')),
                          SizedBox(
                              width: 120,
                              child: Text(widget.items[index]['Food_Name']))
                        ],
                      ),
                    );
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(date.toString()),
                    Text(
                      '\$${widget.totalPrice}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: widget.status == 'Pending'
                      ? SizedBox()
                      : Row(
                          children: [
                            Text(
                              'Rate',
                              style: GoogleFonts.roboto(
                                  textStyle: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w500)),
                            ),
                            RatingBar.builder(
                              itemSize: 15,
                              initialRating: widget.rating == ''
                                  ? 0
                                  : double.parse(widget.rating),
                              minRating: 0,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemPadding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              itemBuilder: (context, _) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              onRatingUpdate: (rating) {
                                if (widget.status == 'Pending') {
                                  return;
                                } else {
                                  EasyLoading.show();
                                  Provider.of<Authenticate>(context,
                                          listen: false)
                                      .tryAutoLogin()
                                      .then((value) {
                                    var token = Provider.of<Authenticate>(
                                            context,
                                            listen: false)
                                        .token;
                                    Provider.of<ApiCalls>(context,
                                            listen: false)
                                        .updateRatings(
                                            widget.orderId.toString(),
                                            {'Rating': rating.toString()},
                                            token)
                                        .then((value) async {
                                      if (value == 202 || value == 201) {
                                        EasyLoading.showSuccess(
                                            'Successfully updated Rating');
                                      } else {
                                        EasyLoading.showError(
                                            'Failed to update Rating');
                                      }
                                    });
                                  });
                                }

                                print(rating);
                              },
                            ),
                          ],
                        ),
                ),
                // IconButton(
                //   onPressed: () {},
                //   icon: Icon(Icons.message, size: 30),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class WebViewDisplayContent extends StatefulWidget {
  WebViewDisplayContent({Key? key}) : super(key: key);

  static const routeName = '/WebViewDisplayContent';

  @override
  State<WebViewDisplayContent> createState() => _WebViewDisplayContentState();
}

class _WebViewDisplayContentState extends State<WebViewDisplayContent> {
  Map<String, dynamic>? paymentIntentData;
  @override
  void initState() {
    super.initState();
    // Enable virtual display.
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
  }

//   String html = """<!DOCTYPE html>
//           <html>
//             <head>
//             <style>
//             body {
//               overflow: hidden;
//             }
//         .embed-youtube {
//             position: relative;
//             padding-bottom: 56.25%;
//             padding-top: 0px;
//             height: 0;
//             overflow: hidden;
//         }

//         .embed-youtube iframe,
//         .embed-youtube object,
//         .embed-youtube embed {
//             border: 0;
//             position: absolute;
//             top: 0;
//             left: 0;
//             width: 100%;
//             height: 100%;
//         }
//         </style>

//         <meta charset="UTF-8">
//          <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
//           <meta http-equiv="X-UA-Compatible" content="ie=edge">
//            </head>
//           <body bgcolor="#121212">
//         <div class="embed-youtube">
//          <iframe
//           id="vjs_video_3_Youtube_api"
//           style="width:100%;height:100%;top:0;left:0;position:absolute;"
//           class="vjs-tech holds-the-iframe"
//           frameborder="0"
//           allowfullscreen="1"
//           allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture"
//           webkitallowfullscreen mozallowfullscreen allowfullscreen
//           title="Live Tv"
//           frameborder="0"
//           src="$iframeUrl"
//           ></iframe></div>
//           </body>
//         </html>
//   """;
// final Completer<WebViewController> _controller =
//     Completer<WebViewController>();
// final String contentBase64 =
//     base64Encode(const Utf8Encoder().convert(html));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Payment',
            style: GoogleFonts.roboto(
              textStyle: const TextStyle(color: Colors.black),
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () async {
                    await makePayment();
                  },
                  child: Container(
                    height: 50,
                    width: 200,
                    decoration: const BoxDecoration(color: Colors.green),
                    child: Center(
                      child: Text('Pav'),
                    ),
                  ),
                ),
              ],
            ),
            // CardField(
            //   onCardChanged: (card) {
            //     print(card);
            //   },
            // ),
            // TextButton(
            //     onPressed: () async {
            //       final paymentMethod = await Stripe.instance
            //           .createPaymentMethod(const PaymentMethodParams.card());
            //     },
            //     child: Text('pay'))
          ],
        )
        //  Container(
        //   child: const WebView(
        //     initialUrl:
        //         'https://stackoverflow.com/questions/54464853/flutter-loading-an-iframe-from-webview',
        //     javascriptMode: JavascriptMode.unrestricted,
        //   ),
        // ),
        );
  }

  Future<void> makePayment() async {
    try {
      paymentIntentData = await createPaymentIntent('20', 'INR');
      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: paymentIntentData!['client_secret'],
        applePay: true,
        googlePay: true,
        style: ThemeMode.system,
        merchantCountryCode: 'INR',
        merchantDisplayName: 'Sudeendra',
      ));

      displayPaymentSheet();
    } catch (e) {
      print(e.toString());
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card'
      };

      var response = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body,
          headers: {
            'Authorization':
                'Bearer sk_test_51KMUpeSAYfEkrbYeQ3eCEngsqbEttKwR70hXYZu8NqujZtztkgApac69MCvHQTxCbFMzN6Jjor23WA6QsFen80UJ00tOUGbTcu',
            'Content-Type': 'application/x-www-form-urlencoded',
          });

      return jsonDecode(response.body.toString());
    } catch (e) {
      print(e.toString());
    }
  }

  calculateAmount(String amount) {
    final price = int.parse(amount) * 100;
    return price.toString();
  }

  void displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet(
          parameters: PresentPaymentSheetParameters(
        clientSecret: paymentIntentData!['client_secret'],
        confirmPayment: true,
      ));
      setState(() {
        paymentIntentData = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Paid Successfully'),
        ),
      );
    } on StripeException catch (e) {
      print(e.toString());

      Get.defaultDialog(title: 'Alert', middleText: 'Cancelled');
    }
  }
}

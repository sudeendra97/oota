import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:oota/authentication/providers/api_calls.dart';
import 'package:oota/authentication/providers/authenticate.dart';
import 'package:oota/authentication/screens/log_in.dart';
import 'package:get/get.dart';
import 'package:oota/authentication/screens/profile_setup_page.dart';
import 'package:oota/authentication/screens/sign_up_screen.dart';
import 'package:oota/chat.dart';
import 'package:oota/home/screens/chat_history.dart';
import 'package:oota/home/screens/check_outpage.dart';
import 'package:oota/home/screens/consumer_profile_screen.dart';
import 'package:oota/home/screens/edit_profile_setup.dart';
import 'package:oota/home/screens/home_page.dart';
import 'package:oota/home/screens/map_screen.dart';
import 'package:oota/home/screens/menu_page.dart';
import 'package:oota/home/screens/nav_bar_screen.dart';
import 'package:oota/home/screens/order_history.dart';
import 'package:oota/home/screens/order_info_page.dart';
import 'package:oota/home/screens/order_info_second_page.dart';
import 'package:oota/home/screens/orders_screen.dart';
import 'package:oota/home/screens/search_results_display_page.dart';
import 'package:oota/home/screens/select_address.dart';
import 'package:oota/home/screens/select_address_page.dart';
import 'package:oota/home/screens/webview_display_content.dart';
import 'package:oota/services/database.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helper/helperfunctions.dart';
import 'home/screens/splash_screen.dart';

import 'package:http/http.dart' as http;

RemoteMessage? newMessage;
Map<String, dynamic>? messageData;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  newMessage = message;
  messageData = message.data;
  print('Message Data $messageData');
  flutterLocalNotificationsPlugin.show(
    int.parse('1'),
    message.data['Title'],
    message.data['body'],
    NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        color: Colors.blue,
        playSound: true,
        icon: '@mipmap/ic_launcher',
      ),
    ),
  );
}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  description:
      'This channel is used for important notifications.', // description
  importance: Importance.high,
  playSound: true,
);

/// Initialize the [FlutterLocalNotificationsPlugin] package.
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey =
      'pk_test_51KMUpeSAYfEkrbYeriyIf7kB1KdCmhKVZEtH5JVZWgWugxx8G0mDp4qEMwFuaom1gCZQJdNU0cJLfx9Plj02Sbq000oY5USOxt';
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  var initializationSettingsAndroid =
      const AndroidInitializationSettings('@mipmap/ic_launcher');

  var initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) {
    runApp(const MyApp());
  });
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var initializationSettingsAndroid =
      const AndroidInitializationSettings('@mipmap/ic_launcher');
  final navigatorKey = GlobalKey<NavigatorState>();
  DatabaseMethods databaseMethods = DatabaseMethods();

  @override
  void initState() {
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
    // checkForInitialMessage();
    FirebaseMessaging.instance.getToken().then((value) async {
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': value,
        },
      );
      prefs.setString('FCM', userData);
      log('Token $value');
    });

    // FirebaseMessaging.instance
    //     .getInitialMessage()
    //     .then((RemoteMessage? message) {
    //   if (message != null) {
    //     print(message.data);
    //   }
    // });

    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;
        print('new Message');
        print(message.data.toString());
        if (notification != null && android != null) {
          flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                color: Colors.blue,
                playSound: true,
                icon: '@mipmap/ic_launcher',
              ),
            ),
          );
        } else {
          newMessage = message;
          flutterLocalNotificationsPlugin.show(
            int.parse('1'),
            message.data['Title'],
            message.data['body'],
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                color: Colors.blue,
                playSound: true,
                icon: '@mipmap/ic_launcher',
              ),
            ),
          );
        }
      },
    );

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenApp Event Was Published');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        Get.defaultDialog(
            title: notification.title.toString(),
            middleText: notification.body.toString(),
            confirm: TextButton(
                onPressed: () {
                  Get.back();
                },
                child: Text('Ok')));
        print(notification.title.toString());
      } else {
        sendMessage(
          newMessage?.data['Sender_Email'],
          newMessage?.data['Title'],
        );
      }
    });

    super.initState();
  }

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

    databaseMethods.addChatRoom(chatRoom, chatRoomId);

    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => Chat(
    //       chatRoomId: chatRoomId,
    //       userName: userName,
    //     ),
    //   ),
    // );

    Get.to(() => Chat(chatRoomId: chatRoomId, userName: userName));
  }

  Future<dynamic> onSelectNotification(payload) async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage?.notification != null) {
      Get.toNamed(HomePageScreen.routeName);
      checkForInitialMessage();
    } else {
      print(initialMessage?.data.toString());
      print('New Message ${newMessage?.data.toString()}');
      print('message data opened inside class $messageData');
      sendMessage(
        newMessage?.data['Sender_Email'],
        newMessage?.data['Title'],
      );
    }
  }

  checkForInitialMessage() async {
    // await Firebase.initializeApp();
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      // PushNotification notification = PushNotification(
      //   title: initialMessage.notification?.title,
      //   body: initialMessage.notification?.body,
      // );
      // setState(() {
      Get.defaultDialog(
          title: initialMessage.notification!.title.toString(),
          middleText: initialMessage.notification!.body.toString());
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Authenticate(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => ApiCalls(),
        ),
      ],
      child: Consumer<Authenticate>(
        builder: (ctx, auth, _) => GetMaterialApp(
          debugShowCheckedModeBanner: false,
          getPages: [
            GetPage(
              name: '/',
              page: () => const MyApp(),
            ),
            GetPage(
                name: HomePageScreen.routeName, page: () => HomePageScreen()),
            GetPage(name: SignUpScreen.routeName, page: () => SignUpScreen()),
            GetPage(
                name: MenuPageScreen.routeName, page: () => MenuPageScreen()),
            GetPage(name: OrdersScreen.routeName, page: () => OrdersScreen()),
            GetPage(
                name: SelectAddressScreen.routeName,
                page: () => SelectAddressScreen()),
            GetPage(
                name: ProfileSetUpPage.routeName,
                page: () => ProfileSetUpPage()),
            GetPage(name: MapScreen.routeName, page: () => MapScreen()),
            GetPage(name: NavBarScreen.routeName, page: () => NavBarScreen()),
            GetPage(
                name: ConsumerProfileScreen.routeName,
                page: () => ConsumerProfileScreen()),
            GetPage(
                name: SearchResultsDisplayPage.routeName,
                page: () => SearchResultsDisplayPage()),
            GetPage(
                name: WebViewDisplayContent.routeName,
                page: () => WebViewDisplayContent()),
            GetPage(name: CheckOutPage.routeName, page: () => CheckOutPage()),
            GetPage(
                name: SelectAddressPage.routeName,
                page: () => SelectAddressPage()),
            GetPage(
                name: OrderInfoFirstPage.routeName,
                page: () => OrderInfoFirstPage()),
            GetPage(
                name: OrderInfoSecondPage.routeName,
                page: () => OrderInfoSecondPage()),
            GetPage(
                name: EditProfileSetUp.routeName,
                page: () => EditProfileSetUp()),
            GetPage(
              name: OrderHistory.routeName,
              page: () => OrderHistory(),
            ),
            GetPage(
              name: ChatHistoryPage.routeName,
              page: () => ChatHistoryPage(),
            ),
            GetPage(
              name: Chat.routeName,
              page: () => Chat(chatRoomId: '', userName: ''),
            ),
          ],
          title: 'Oota',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: auth.isAuth
              ? NavBarScreen()
              : FutureBuilder(
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : LogIn(),
                  future: auth.tryAutoLogin(),
                ),
          builder: EasyLoading.init(),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GlobalKey<FormState> _formKey = GlobalKey();
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 300,
                height: 30,
                child: TextFormField(
                  onSaved: (value) {},
                ),
              ),
              ElevatedButton(onPressed: () {}, child: const Text('Send')),
            ],
          ),
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

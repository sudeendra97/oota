import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oota/home/screens/home_page.dart';
import 'package:oota/home/screens/orders_screen.dart';

class NavBarScreen extends StatefulWidget {
  NavBarScreen({Key? key}) : super(key: key);

  static const routeName = '/NavBarScreen';

  @override
  _NavBarScreenState createState() => _NavBarScreenState();
}

class _NavBarScreenState extends State<NavBarScreen> {
  int _selectedIndex = 0;
  static final List<Widget> _widgetOptions = <Widget>[
    HomePageScreen(),
    OrdersScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   elevation: 0,
      //   iconTheme: const IconThemeData(color: Colors.black),
      //   actions: [IconButton(onPressed: () {}, icon: Icon(Icons.person))],
      //   title: Text(
      //     'Oota',
      //     style: GoogleFonts.roboto(
      //       textStyle: const TextStyle(fontSize: 25, color: Colors.black),
      //     ),
      //   ),
      //   backgroundColor: Colors.white,
      // ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: Container(
        height: 60,
        child: Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: BottomNavigationBar(
            selectedItemColor: Colors.orange,
            selectedIconTheme: const IconThemeData(color: Colors.orange),
            unselectedIconTheme: const IconThemeData(color: Colors.black),
            iconSize: 25,
            enableFeedback: true,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.home,
                  // color: Colors.black,
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                  icon: Icon(
                    Icons.history,
                  ),
                  label: 'History',
                  tooltip: 'History'),
            ],
            type: BottomNavigationBarType.shifting,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            elevation: 5,
          ),
        ),
      ),
    );
  }
}

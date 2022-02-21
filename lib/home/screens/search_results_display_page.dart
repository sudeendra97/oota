import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'menu_page.dart';

class SearchResultsDisplayPage extends StatefulWidget {
  SearchResultsDisplayPage({Key? key}) : super(key: key);

  static const routeName = '/SearchResultsDisplayPage';

  @override
  State<SearchResultsDisplayPage> createState() =>
      _SearchResultsDisplayPageState();
}

class _SearchResultsDisplayPageState extends State<SearchResultsDisplayPage> {
  List searchResults = [];

  @override
  void initState() {
    searchResults = Get.arguments;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0, top: 20),
                child: Text(
                  'Based on Your Search results',
                  style: GoogleFonts.roboto(
                      textStyle: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w500)),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: 1,
                  itemBuilder: (BuildContext context, int index) {
                    return DisplaySearchResult(
                      list: searchResults,
                      index: index,
                      key: UniqueKey(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DisplaySearchResult extends StatefulWidget {
  DisplaySearchResult({Key? key, required this.list, required this.index})
      : super(key: key);

  final List list;
  final int index;

  @override
  State<DisplaySearchResult> createState() => _DisplaySearchResultState();
}

class _DisplaySearchResultState extends State<DisplaySearchResult> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: ListTile(
        onTap: () {
          Get.toNamed(MenuPageScreen.routeName, arguments: {
            'Profile_Id': widget.list[widget.index]['Profile']['Profile_Id'],
            // 'UserName': widget.firstName + widget.lastName,
            'Profile_Code': widget.list[widget.index]['Profile']
                ['Profile_Code'],
            'Business_Name': widget.list[widget.index]['Profile']
                ['Business_Name'],
          });
        },
        title: Text(widget.list[widget.index]['Profile']['Business_Name']),
      ),
    );
  }
}

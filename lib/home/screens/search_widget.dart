import 'package:flutter/material.dart';

class SearchWidget extends StatefulWidget {
  final String text;
  final ValueChanged<String> onChanged;
  final String hintText;
  final ValueChanged<String> data;
  final ValueChanged<int> clear;
  final TextEditingController controller;
  final ValueChanged<int> change;

  const SearchWidget({
    Key? key,
    required this.text,
    required this.onChanged,
    required this.hintText,
    required this.data,
    required this.clear,
    required this.controller,
    required this.change,
  }) : super(key: key);

  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final controller = TextEditingController();

  bool valueEntered = false;

  @override
  Widget build(BuildContext context) {
    final styleActive = TextStyle(color: Colors.black);
    final styleHint = TextStyle(color: Colors.black54);
    final style = widget.text.isEmpty ? styleHint : styleActive;
    var width = MediaQuery.of(context).size.width;
    FocusScopeNode currentFocus = FocusScope.of(context);

    return Container(
      height: 42,
      width: width * 0.68,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: Colors.black26),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextField(
          onTap: () {
            print('object');
            widget.change(100);
            setState(() {
              valueEntered = true;
            });
          },
          controller: widget.controller,
          decoration: InputDecoration(
            icon: valueEntered == true
                ? IconButton(
                    onPressed: () {
                      valueEntered = false;
                      widget.controller.clear();
                      widget.clear(100);
                    },
                    icon: const Icon(Icons.arrow_back_ios_new))
                : Icon(Icons.search, color: style.color),
            suffixIcon: valueEntered == true
                ? IconButton(
                    onPressed: () {
                      widget.data(widget.controller.text);
                    },
                    icon: const Icon(
                      Icons.search,
                      color: Colors.black,
                    ))
                : null,
            hintText: widget.hintText,
            hintStyle: style,
            border: InputBorder.none,
          ),
          style: style,
          onChanged: (value) {
            if (value.isEmpty) {
              setState(() {
                valueEntered = false;
                widget.controller.clear();
                widget.clear(100);
              });
            } else {
              setState(() {
                valueEntered = true;
              });
              if (value.length > 2) {
                widget.data(widget.controller.text);
              }
            }

            widget.onChanged;
          }),
    );
  }
}

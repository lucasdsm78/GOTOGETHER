import 'dart:developer';
import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  const SearchBar({Key? key, this.placeholder, required this.searchbarController}) : super(key: key);
  final String? placeholder;
  final TextEditingController searchbarController;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(
        Icons.search,
        color: Colors.black,
        size: 28,
      ),
      title: TextField(
        autofocus: true,
        controller: searchbarController,
        decoration: InputDecoration(
          hintText: (placeholder ?? 'description, city, adresse...'),
          hintStyle: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontStyle: FontStyle.italic,
          ),
          border: InputBorder.none,
        ),
        style: const TextStyle(
          color: Colors.black,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_together/helper/extensions/string_extension.dart';

enum Privacy {
  private,
  public
}

extension PrivacyExtension on Privacy{
  Icon getIcon() {
    switch (this) {
      case Privacy.private:
        return Icon(Icons.lock_outline);
      case Privacy.public:
        return Icon(Icons.lock_open_outlined);
      default:
        return Icon(Icons.lock_outline);
    }
  }
  String toShortString() {
    return this.toString().enumValueToNormalCase();
  }

  String translate(){
    switch (this) {
      case Privacy.private:
        return "Entre amis";
      case Privacy.public:
        return "Publique";
      default:
        return "Entre amis";
    }
  }

  bool isPublic(){
    if(this == Privacy.public){
      return true;
    }
    else{
      return false;
    }
  }
}

/// Get Privacy from a string
Privacy getPrivacyByString(String privacy){
  return Privacy.values.firstWhere((element) => element.toShortString() == privacy || element.translate() == privacy);
}
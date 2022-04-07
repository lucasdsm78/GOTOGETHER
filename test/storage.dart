import 'dart:developer';

import 'package:flutter_test/flutter_test.dart';
import 'package:go_together/helper/storage.dart';
import 'package:go_together/mock/mock.dart';
import 'package:go_together/models/user.dart';


void main() {
  group('storage', (){

    test('store a user', () async {
      User user = Mock.userGwen;
      CustomStorage store = CustomStorage();
      await store.storeUser(user);
      String getted = await store.get("user");
      expect(getted, user.toJson());
      //expect(actual, matcher)
    });

  });
}



import 'dart:developer';

import 'package:flutter_test/flutter_test.dart';
import 'package:go_together/helper/session.dart';
import 'package:go_together/helper/storage.dart';
import 'package:go_together/mock/mock.dart';
import 'package:go_together/models/user.dart';


void main() {

  //Note : works, but annoying to get it in widget Screens because of the async
  group('local storage', (){
    CustomStorage store = CustomStorage();

    test('store a user and retrieve its data', () async {
      User user = Mock.userGwen;
      await store.storeUser(user);
      String getted = await store.get("user");
      expect(getted, user.toJson());
      //expect(actual, matcher)
    });
  });

  group('session', (){
    Session session = Session();

    test('store a user and retrieve its data', () {
      User user = Mock.userGwen;
      session.setData(SessionData.user, user);
      User userGet = session.getData(SessionData.user) as User;
      expect(userGet, user);
    });
  });
}



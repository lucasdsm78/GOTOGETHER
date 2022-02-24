import 'dart:developer';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';

import 'package:go_together/helper/date_extension.dart';
import 'package:go_together/usecase/message.dart';

// voir comment faire une premiere requete pour s'authentifier , avant que les test ne se lance
// pour recuperer un de nos JWT token
// pouvoir les reutiliser dans le MAIN_HEADER de helper/api (class Api)
// pouvoir set le main_header pour y ajouter le token avec l'indice 'x-access-token'

void main() {
  // Define a test. The TestWidgets function also provides a WidgetTester
  // to work with. The WidgetTester allows you to build and interact
  // with widgets in the test environment.

  group('API', (){
    test('get messages from api', () async {
      // Test code goes here.
      final MessageUseCase messageUseCase = MessageUseCase();
      final futureActivity = await messageUseCase.getById(1);
      log(futureActivity.toString());
      debugPrint(futureActivity.toString());
      expect(futureActivity.length, greaterThanOrEqualTo(8));
    });
    test('description', () async{
      
    });

  });
}



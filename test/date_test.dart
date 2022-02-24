import 'package:flutter_test/flutter_test.dart';

import 'package:go_together/helper/date_extension.dart';


void main() {
  // Define a test. The TestWidgets function also provides a WidgetTester
  // to work with. The WidgetTester allows you to build and interact
  // with widgets in the test environment.
group('date_extension', (){
    test('get week day of today', () async {
      // Test code goes here.
      final DateTime dateTime = DateTime.now();
      expect(dateTime.getWeekDayName(), "thursday");
    });
    test('get month  of today', () async {
      // Test code goes here.
      final DateTime dateTime = DateTime.now();
      expect(dateTime.getMonthName(), "February".toLowerCase());
    });

  });
}



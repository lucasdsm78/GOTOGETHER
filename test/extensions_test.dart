import 'package:flutter_test/flutter_test.dart';
import 'package:go_together/helper/extensions/int_extension.dart';
import 'package:go_together/helper/extensions/date_extension.dart';
import 'package:go_together/helper/extensions/string_extension.dart';
import 'package:go_together/helper/extensions/map_extension.dart';
import 'package:go_together/helper/extensions/list_extension.dart';

helperTestIntExt(int value, int length){
  String numWithLpad = value.left0(length: length);
  expect(numWithLpad.length, length);
}

enum TestEnum {
  firstValue,
  secondValue
}
void main() {
  group('int_extension', (){

    group('test left0', (){
      test('9 should be 09 by default (length=2) ', () async {
        const int number = 9;
        expect(number.left0(), "09");
      });

      test('9 should be 009 if length = 3 ', () async {
        const int number = 9;
        const length = 3;
        helperTestIntExt(number, length);
        expect(number.left0(length: length), "009");
      });

      test('10 should be 010 if length = 3 ', () async {
        const int number = 10;
        const length = 3;
        helperTestIntExt(number, length);
        expect(number.left0(length: length), "010");
      });

      test('1205920 should be 0001205920 if length = 10 ', () async {
        const int number = 1205920;
        const length = 10;
        helperTestIntExt(number, length);
        expect(number.left0(length: length), "0001205920");
      });

      test('1205920 should stay 1205920 if length = 3 ', () async {
        const int number = 1205920;
        const length = 3;
        expect(number.left0(length: length), number.toString());
      });
    });

    test('isEmpty', () async {
      expect(0.isEmpty(), true);
      expect(10.isEmpty(), false);
      expect((-10).isEmpty(), false);
    });
  });

  group('date_extension', () {
    final FIXED_DATE_STRING_SUNDAY = "2022-05-01 00:00:00";
    final FIXED_DATE_SUNDAY = DateTime.parse(FIXED_DATE_STRING_SUNDAY);
    final FIXED_DATE_MONDAY = DateTime.parse("2022-05-02 00:00:00");
    final FIXED_DATE_1_BEFORE_END_OF_MONTH = DateTime.parse("2022-05-30 00:00:00");

    test('parse date string to datetime object', () async {
      expect(parseStringToDateTime(FIXED_DATE_STRING_SUNDAY), FIXED_DATE_SUNDAY);
    });

    group("get datetime month / day name", (){
      test('get datetime day name - fixed date 2022-05-01 (sunday)', () async {
        expect(FIXED_DATE_SUNDAY.getWeekDayName(), "sunday");
      });
      test('get datetime day name - fixed date 2022-05-02', () async {
        expect(FIXED_DATE_MONDAY.getWeekDayName(), "monday");
      });
      test('get datetime month', () async {
        expect(FIXED_DATE_SUNDAY.getMonthName(), "May".toLowerCase());
        expect(FIXED_DATE_MONDAY.getMonthName(), "May".toLowerCase());
      });
    });

    group("add minutes to datetime", (){
      test('30 + 30', () async {
        DateTime currDate = FIXED_DATE_SUNDAY;
        expect(currDate.addMinutes(30), parseStringToDateTime("2022-05-01 00:30:00"));
        expect(currDate.addMinutesAndStringify(60), "01/05/2022 01:00");
      });
      test('1440 = 1 day', () async {
        DateTime currDate = FIXED_DATE_1_BEFORE_END_OF_MONTH;
        expect(currDate.addMinutes(1440), parseStringToDateTime("2022-05-31 00:00:00"));
        expect(currDate.addMinutesAndStringify(1440*2), "01/06/2022 00:00");
      });

      test('-1', () async {
        DateTime currDate = FIXED_DATE_SUNDAY;
        expect(currDate.addMinutes(-1), parseStringToDateTime("2022-04-30 23:59:00"));
      });
    });

    group("get formated date from datetime", (){
      test('get only date - remove hours', () async {
        expect(FIXED_DATE_SUNDAY.getOnlyDate(), parseStringToDateTime("2022-05-01"));
      });
      test('french format d/m/Y', () async {
        expect(FIXED_DATE_SUNDAY.getFrenchDate(), "01/05/2022");
      });
      test('french format d/m/Y H:i:s', () async {
        expect(FIXED_DATE_SUNDAY.getFrenchDateTime(), "01/05/2022 00:00");
      });
      test('format Y-m-d', () async {
        expect(FIXED_DATE_SUNDAY.getDbDate(), "2022-05-01");
      });
      test('format Y-m-d H:i:s', () async {
        expect(FIXED_DATE_SUNDAY.getDbDateTime(), "2022-05-01 00:00:00");
      });
    });
  });

  group('string_extension', () {
    final String SNAKE_CASED = "this_is_a_var";
    final String CAMEL_CASED = "thisIsAVar";

    test('capitalize', () async {
      expect("hello everybody. how ARE you today?".capitalize(), "Hello everybody. how are you today?");
    });
    test('camel case to normal case', () async {
      expect(CAMEL_CASED.camelCaseToNormalCase(), "this Is A Var");
      expect(SNAKE_CASED.camelCaseToNormalCase(), SNAKE_CASED);
    });
    test('snake case to normal case', () async {
      expect(CAMEL_CASED.snakeCaseToNormalCase(), CAMEL_CASED);
      expect("this_is_a_var".snakeCaseToNormalCase(), "this is a var");
    });
    test('enum get name as string - normal case', () async {
      expect(TestEnum.firstValue.toString().enumValueToNormalCase(), "first Value");
    });
  });

  group('map_extension', () {
    Map map = {"a":null ,"b":null, "c":2, "e":"", "f":5};
    test('get the first not null - keys with 2 not null', () async {
      expect(map.getFromMapFirstNotNull(["a", "c", "f"]).toString(), "2");
    });
    test('get the first not null - keys with 1 not null', () async {
      expect(map.getFromMapFirstNotNull(["a", "c"]).toString(), "2");
    });
    test('get the first not null - all keys are null', () async {
      expect(map.getFromMapFirstNotNull(["a", "b"]), null);
    });
    test('get the first not null - no keys', () async {
      expect(map.getFromMapFirstNotNull([]), null);
    });

  });

  group('list_extension', () {
    List<String> list = ["a", "b", "c", "d", "e", "f"];
    test('remove from array - existing keys', () async {
      expect(list.removeFromArray(["a", "c", "f"]), ["b", "d", "e"]);
    });
    test('remove from array - not existing keys', () async {
      expect(list.removeFromArray(["z"]), list);
    });
    test('remove from array - empty keys', () async {
      expect(list.removeFromArray([]), list);
    });
  });
}



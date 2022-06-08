import 'package:flutter_test/flutter_test.dart';
import 'package:go_together/helper/extensions/int_extension.dart';

helperTestIntExt(int value, int length){
  String numWithLpad = value.left0(length: length);
  expect(numWithLpad.length, length);
}
void main() {
  group('int_extension', (){

    test('test left0 : 9 should be 09 by default (length=2) ', () async {
      const int number = 9;
      expect(number.left0(), "09");
    });

    test('test left0 : 9 should be 009 if length = 3 ', () async {
      const int number = 9;
      const length = 3;
      helperTestIntExt(number, length);
      expect(number.left0(length: length), "009");
    });

    test('test left0 : 10 should be 010 if length = 3 ', () async {
      const int number = 10;
      const length = 3;
      helperTestIntExt(number, length);
      expect(number.left0(length: length), "010");
    });

    test('test left0 : 1205920 should be 010 if length = 3 ', () async {
      const int number = 1205920;
      const length = 10;
      helperTestIntExt(number, length);
      expect(number.left0(length: length), "0001205920");
    });
  });
}





import 'dart:io';

mixin EventSimulator {
  //adb shell input keyevent 66
  static Future<void> inputKeyEvent(int keyEvent) async {
    await Process.run('adb', ['shell', 'input', 'keyevent', '$keyEvent']);
    //sleep(const Duration(seconds: 1));
  }

  //adb shell input keyevent KEYCODE_HOME
  static Future<void> inputKeyEventWithName(String keyEvent) async {
    await Process.run('adb', ['shell', 'input', 'keyevent', '$keyEvent']);
//    sleep(const Duration(seconds: 1));
  }

  //adb shell input tap 1290 960
  static Future<void> inputText(String text) async => Process.run('adb', ['shell', 'input', 'text', '$text']);

  //adb shell input tap 1290 960
  static Future<void> tapScreen(int x, int y) async => Process.run('adb', ['shell', 'input', 'tab', '$x', '$y']);

  //adb shell input swipe 540 1600 540 100 1500
  static Future<void> swipe(int startX, int startY, int endX, int endY, int duration) async =>
      Process.run('adb', ['shell', 'input', 'swipe', '$startX', '$startY', '$endX', '$endY', '$duration']);

  //Number
  static Future<void> inputNumber(int number) async {
    if (number >= 0 && number <= 9) {
      await inputKeyEventWithName('KEYCODE_$number');
    }
  }

  //Alphabet
  static Future<void> inputAlphabet(String alphabet) async {
    if (alphabet != null && alphabet.length == 1) {
      await inputKeyEventWithName('KEYCODE_${alphabet.toUpperCase()}');
    }
  }

  //back button
  static Future<void> tapBackButton() async => Process.run('adb', ['shell', 'input', 'keyevent', '4']);

  //home button
  static Future<void> tapHomeButton() async => Process.run('adb', ['shell', 'input', 'keyevent', 'KEYCODE_HOME']);

  static Future<void> grantPermission(String permission) async =>
      Process.run('adb', ['shell', 'pm', 'grant', 'ai.nextbillion.navigation.nb_navigation_flutter_example', permission]);
}

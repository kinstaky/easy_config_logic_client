import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';


class SettingsModel extends ChangeNotifier {
  SettingsModel();

  // theme color
  late Color color;
  // color value
  late int colorValue;
  // theme brightness, light or dark
  late Brightness brightness;
  // locale, en or zh
  late Locale locale;


  Future<void> init() async {
    await Hive.initFlutter();
    var box = await Hive.openBox("settings");
    var version = box.get("version") ?? 0;
    if (version == 0) {
      colorValue = 0xFFF78A4B;
      color = Color(0xFFF79A4B);
      brightness = Brightness.light;
      locale = Locale("en");
    } else if (version == 1) {
      colorValue = box.get("color");
      color = Color(colorValue);
      brightness = box.get("brightness") == 0
        ? Brightness.light
        : Brightness.dark;
      locale = Locale(box.get("locale"));
    }
  }


  Future<void> save() async {
    await Hive.initFlutter();
    var box = await Hive.openBox("settings");
    box.put("version", 1);
    box.put("color", colorValue);
    box.put(
      "brightness",
      brightness == Brightness.light ? 0 : 1
    );
    box.put("locale", locale.languageCode);
  }


  void updateThemeColor(value) {
    colorValue = value;
    color = Color(colorValue);
    notifyListeners();
    save();
  }


  void updateBrightness(Brightness b) {
    brightness = b;
    notifyListeners();
    save();
  }


  void updateLocale(Locale l) {
    locale = l;
    notifyListeners();
    save();
  }

}
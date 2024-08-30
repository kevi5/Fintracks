import 'package:shared_preferences/shared_preferences.dart';

class fintrackerSharedPref {
  static const String DARKMODE = "DARKMODE";
  static const String ISFIRSTTIME = "ISFIRSTTIME";
  static const String ISCFALLOWED = "ISCFALLOWED";
  static const String CURRENCYSYMBOL = "CURRENCYSYMBOL";

  setDarkTheme(bool value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(DARKMODE, value);
  }

  getDarkTheme() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getBool(DARKMODE);
  }

  setFirstTime(bool value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(ISFIRSTTIME, value);
  }

  getFirstTime() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getBool(ISFIRSTTIME);
  }

  setCFAllowed(bool value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(ISCFALLOWED, value);
  }

  getCFAllowed() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getBool(ISCFALLOWED);
  }

  setCurrencySymbol(String value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(CURRENCYSYMBOL, value);
  }

  getCurrencySymbol() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(CURRENCYSYMBOL);
  }
}

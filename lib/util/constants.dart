import 'package:FinTrack/models/category_model.dart';
import 'package:FinTrack/util/color.dart';
import 'package:intl/intl.dart';

class Constants {
  static final List<String> recurTypes = [
    "Daily",
    "Weekly",
    "Monthly",
    "Yearly"
  ];

  static final List<String> choicesWeekly = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  static final List<String> choicesMonthly =
      List.generate(28, (index) => (index + 1).toString());

  static final List<String> choicesMonthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  static final DateFormat dateFormat = DateFormat('d');
  static final DateFormat showDateOnlyFormat = DateFormat('dd-MM-yyyy');
  static final DateFormat monthFormat = DateFormat('MMMM');
  static final DateFormat yearFormat = DateFormat('yyyy');
  static final DateFormat dayFormat = DateFormat('EEEE');

  static final List<CategoryModel> initialCategories = [
    CategoryModel(
        catName: 'Food',
        catType: 0,
        catColor: Colour.colorList.keys.elementAt(0),
        catIsFav: false),
    CategoryModel(
        catName: 'Travel',
        catType: 0,
        catColor: Colour.colorList.keys.elementAt(1),
        catIsFav: false),
    CategoryModel(
        catName: 'Shopping',
        catType: 0,
        catColor: Colour.colorList.keys.elementAt(2),
        catIsFav: false),
    CategoryModel(
        catName: 'Health',
        catType: 0,
        catColor: Colour.colorList.keys.elementAt(3),
        catIsFav: false),
    CategoryModel(
        catName: 'Entertainment',
        catType: 0,
        catColor: Colour.colorList.keys.elementAt(4),
        catIsFav: false),
    CategoryModel(
        catName: 'Education',
        catType: 0,
        catColor: Colour.colorList.keys.elementAt(5),
        catIsFav: false),
    CategoryModel(
        catName: 'Salary',
        catType: 1,
        catColor: Colour.colorList.keys.elementAt(6),
        catIsFav: false),
    CategoryModel(
        catName: 'Other',
        catType: 0,
        catColor: Colour.colorList.keys.elementAt(7),
        catIsFav: false),
  ];

  static final List<String> currenciesSymbol = [
    "₹",
    "\$",
    "€",
    "£",
    "¥",
    "₽",
    "₺",
    "₩",
    "₴",
    "₸",
    "₮",
  ];

  static final Map<String, String> currencySymbolMap = {
    "₹": "INR",
    "\$": "USD",
    "€": "EUR",
    "£": "GBP",
    "¥": "JPY",
    "₽": "RUB",
    "₺": "TRY",
    "₩": "KRW",
    "₴": "UAH",
    "₸": "KZT",
    "₮": "MNT",
  };
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:FinTrack/db_helper/category_db_controller.dart';
import 'package:FinTrack/db_helper/recurrence_db_controller.dart';
import 'package:FinTrack/db_helper/transaction_db_controller.dart';
import 'package:FinTrack/models/recurrence_model.dart';
import 'package:FinTrack/models/transaction_model.dart';
import 'package:FinTrack/pages/helper/drawer_navigation.dart';
import 'package:FinTrack/services/settings_provider.dart';
import 'package:FinTrack/services/shared_pref.dart';

import '../util/value_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CategoryController _categoryController = Get.put(CategoryController());
  final SettingsProvider _settingsProvider = Get.put(SettingsProvider());
  final RecurrenceController _recurrenceController =
      Get.put(RecurrenceController());
  final TransactionController _transactionController =
      Get.put(TransactionController());
  final List<RecurrenceModel> _recurrences = [];

  double _dailyExpense = 0.0;
  double _dailyExpensePrevious = 0.0;
  double _dailyIncome = 0.0;
  double _dailyIncomePrevious = 0.0;
  double _monthlyExpense = 0.0;
  double _monthlyExpensePrevious = 0.0;
  double _monthlyIncome = 0.0;
  double _monthlyIncomePrevious = 0.0;
  double _balance = 0.0;

  double? _income = 0;
  double? _expense = 0;
  double? _total = 0;
  dynamic _startDate = DateTime.now();
  String currencySymbol = '₹';
  String _selectedTimeframe = 'This Month';

  @override
  void initState() {
    super.initState();
    if (SharedPref().notificationAllowed) {
      TimeOfDay notificationTiming = SharedPref().notificationTime;
      SharedPref().turnOnNotifications(true, notificationTiming);
    }
    var lastDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
    var firstDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
    _getTransactionsListBydate(firstDate, lastDate);
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    currencySymbol = _settingsProvider.currencySymbol;
  }

  void _loadData() async {
    await getUpcomingRecurrences();
    await _calculateStatistics();
  }

  Future<void> _calculateStatistics() async {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime startOfMonth = DateTime(now.year, now.month, 1);
    DateTime startOfPreviousDay = startOfDay.subtract(Duration(days: 2));
    DateTime startOfPreviousMonth = DateTime(now.year, now.month - 1, 1);

    double dailyExpense =
        await _transactionController.getAmountByDate(0, startOfDay, now) ?? 0.0;
    double dailyExpensePrevious = await _transactionController.getAmountByDate(
            0, startOfPreviousDay, startOfDay) ??
        0.0;
    double dailyIncome =
        await _transactionController.getAmountByDate(1, startOfDay, now) ?? 0.0;
    double dailyIncomePrevious = await _transactionController.getAmountByDate(
            1, startOfPreviousDay, startOfDay) ??
        0.0;
    double monthlyExpense =
        await _transactionController.getAmountByDate(0, startOfMonth, now) ??
            0.0;
    double monthlyExpensePrevious = await _transactionController
            .getAmountByDate(0, startOfPreviousMonth, startOfMonth) ??
        0.0;
    double monthlyIncome =
        await _transactionController.getAmountByDate(1, startOfMonth, now) ??
            0.0;
    double monthlyIncomePrevious = await _transactionController.getAmountByDate(
            1, startOfPreviousMonth, startOfMonth) ??
        0.0;

    setState(() {
      _dailyExpense = dailyExpense;
      _dailyExpensePrevious = dailyExpensePrevious;
      _dailyIncome = dailyIncome;
      _dailyIncomePrevious = dailyIncomePrevious;
      _monthlyExpense = monthlyExpense;
      _monthlyExpensePrevious = monthlyExpensePrevious;
      _monthlyIncome = monthlyIncome;
      _monthlyIncomePrevious = monthlyIncomePrevious;
      _balance = monthlyIncome - monthlyExpense;
    });
  }

  void _updateTransactionsForTimeframe(String timeframe) {
    DateTime firstDate, lastDate;
    switch (timeframe) {
      case 'This Month':
        lastDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 1);
        firstDate = DateTime(DateTime.now().year, DateTime.now().month, 0);
        _getTransactionsListBydate(firstDate, lastDate);
        break;
      case 'Last Month':
        lastDate = DateTime(DateTime.now().year, DateTime.now().month, 0);
        firstDate = DateTime(DateTime.now().year, DateTime.now().month - 1, 1);
        _getTransactionsListBydate(firstDate, lastDate);
        break;
      case 'Last 3 Months':
        lastDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
        firstDate = DateTime(DateTime.now().year, DateTime.now().month - 3, 1);
        _getTransactionsListBydate(firstDate, lastDate);
        break;
      case 'Last 6 Months':
        lastDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
        firstDate = DateTime(DateTime.now().year, DateTime.now().month - 6, 1);
        _getTransactionsListBydate(firstDate, lastDate);
        break;
      default:
        // Default to 'This Month'
        lastDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
        firstDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
        _getTransactionsListBydate(firstDate, lastDate);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FinTrack'),
        centerTitle: true,
        elevation: 0.0,
      ),
      drawer: const DrawerNavigation(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: _buildDailyNetCard(),
                ),
                Expanded(
                  child: _buildMonthlyNetCard(),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            _buildBalanceCard(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(500.0),
        ),
        onPressed: () async {
          await Navigator.pushNamed(context, '/transactions');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDailyNetCard() {
    double dailyChange = (_dailyIncome - _dailyExpense) -
        (_dailyIncomePrevious - _dailyExpensePrevious);
    print('dailyChange: $dailyChange');
    print('Previous: ${_dailyIncomePrevious - _dailyExpensePrevious}');
    double dailyPercentageChange =
        (_dailyIncomePrevious - _dailyExpensePrevious) != 0
            ? (dailyChange / (_dailyIncomePrevious - _dailyExpensePrevious)) *
                100
            : 0.0;
    Color changeColor = dailyChange >= 0 ? Colors.green : Colors.red;

    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'SF Pro Display',
              ),
            ),
            const SizedBox(height: 20.0),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                '$currencySymbol${(_dailyIncome - _dailyExpense).toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                  color: changeColor,
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                '${dailyChange >= 0 ? "+" : "-"} $currencySymbol${dailyChange.abs().toStringAsFixed(2)} (${dailyPercentageChange.toStringAsFixed(2)}%)',
                style: TextStyle(
                  fontSize: 18.0,
                  color: changeColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyNetCard() {
    double monthlyChange = (_monthlyIncome - _monthlyExpense) -
        (_monthlyIncomePrevious - _monthlyExpensePrevious);
    double monthlyPercentageChange =
        (_monthlyIncomePrevious - _monthlyExpensePrevious) != 0
            ? (monthlyChange /
                    (_monthlyIncomePrevious - _monthlyExpensePrevious)) *
                100
            : 0.0;

    Color changeColor = monthlyChange >= 0 ? Colors.green : Colors.red;

    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'SF Pro Display',
              ),
            ),
            const SizedBox(height: 20.0),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                '$currencySymbol${(_monthlyIncome - _monthlyExpense).toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                  color: changeColor,
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                '${monthlyChange >= 0 ? "+" : "-"} $currencySymbol${monthlyChange.abs().toStringAsFixed(2)} (${monthlyPercentageChange.toStringAsFixed(2)}%)',
                style: TextStyle(
                  fontSize: 18.0,
                  color: changeColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: _selectedTimeframe,
                  items: [
                    DropdownMenuItem(
                      value: 'This Month',
                      child: Text(
                        'This Month',
                        style: TextStyle(
                          fontFamily: 'SF Pro Text',
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Last Month',
                      child: Text(
                        'Last Month',
                        style: TextStyle(
                          fontFamily: 'SF Pro Text',
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Last 3 Months',
                      child: Text(
                        'Last 3 Months',
                        style: TextStyle(
                          fontFamily: 'SF Pro Text',
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Last 6 Months',
                      child: Text(
                        'Last 6 Months',
                        style: TextStyle(
                          fontFamily: 'SF Pro Text',
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'All time',
                      child: Text(
                        'All time',
                        style: TextStyle(
                          fontFamily: 'SF Pro Text',
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ],
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedTimeframe = newValue!;
                      _updateTransactionsForTimeframe(_selectedTimeframe);
                    });
                  },
                  style: TextStyle(
                    fontFamily: 'SF Pro Text',
                    fontSize: 16.0,
                  ),
                  icon: Icon(Icons.arrow_drop_down),
                  underline: SizedBox(),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            Text(
              'Balance: $currencySymbol${_total?.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'SF Pro Display',
              ),
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Income: $currencySymbol${_income?.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 18.0,
                    fontFamily: 'SF Pro Text',
                  ),
                ),
                Text(
                  'Expenses: $currencySymbol${_expense?.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 18.0,
                    fontFamily: 'SF Pro Text',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingRecurrencesCard() {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upcoming Recurrences',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'SF Pro Display',
              ),
            ),
            const SizedBox(height: 20.0),
            _recurrences.isEmpty
                ? const Text('No upcoming recurrences.')
                : Column(
                    children: _recurrences.map((recurrence) {
                      return ListTile(
                        title: Text(recurrence.recurNote ?? ''),
                        subtitle: Text(
                          '$currencySymbol${recurrence.recurAmount} on ${DateFormat('yyyy-MM-dd').format(recurrence.recurOn as DateTime)}',
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }

  void _getTransactionsListBydate(fromDate, toDate) {
    _getTransactionsFromDBBydate(fromDate, toDate);
  }

  void _getTransactionsFromDBBydate(fromDate, toDate) async {
    _getStartDate();
    var income =
        await _transactionController.getAmountByDate(1, fromDate, toDate) ??
            0.0;
    var expense =
        await _transactionController.getAmountByDate(0, fromDate, toDate) ??
            0.0;

    setState(() {
      _income = income;
      _expense = expense;
      _total = income - expense;
    });
  }

  void _getStartDate() async {
    var date = await _transactionController.getStartDate();
    setState(() {
      _startDate = date;
    });
  }

  Future<void> getUpcomingRecurrences() async {}
}

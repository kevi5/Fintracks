import 'package:FinTrack/db_helper/category_db_controller.dart';
import 'package:FinTrack/db_helper/transaction_db_controller.dart';
import 'package:FinTrack/db_helper/trash_db_controller.dart';
import 'package:FinTrack/models/category_model.dart';
import 'package:FinTrack/models/transaction_model.dart';
import 'package:FinTrack/models/trash_model.dart';
import 'package:FinTrack/pages/helper/drawer_navigation.dart';
import 'package:FinTrack/pages/helper/select_category_dialog.dart';
import 'package:FinTrack/services/settings_provider.dart';
import 'package:FinTrack/util/color.dart';
import 'package:FinTrack/util/constants.dart';
import 'package:FinTrack/util/value_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  List<CategoryModel> _categories = [];
  List<TransactionModel> _transactions = [];

  final CategoryController _categoryController = Get.find();
  final TransactionController _transactionController = Get.find();
  final TrashController _trashController = Get.put(TrashController());
  final TextEditingController _selectedCategoryController =
      TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final SettingsProvider settingsProvider = Get.find();

  int selectedCategoryIndex = 0;
  bool isOpen = false;
  double? _income = 0;
  double? _expense = 0;
  double? _total = 0;
  dynamic _startDate = DateTime.now();
  String currencySymbol = '₹';
  String _selectedTimeframe = 'This Month';

  @override
  void initState() {
    _getAllCategories();
    _getStartDate();
    _getAllTransactions();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    currencySymbol = settingsProvider.currencySymbol;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FinTrack Transactions',
          style: TextStyle(
            fontFamily: 'SF Pro Text', // Apple's default font
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0.0,
      ),
      drawer: const DrawerNavigation(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Start of Card
            Card(
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
                              child: Text('This Month'),
                            ),
                            DropdownMenuItem(
                              value: 'Last Month',
                              child: Text('Last Month'),
                            ),
                            DropdownMenuItem(
                              value: 'Last 3 Months',
                              child: Text('Last 3 Months'),
                            ),
                            DropdownMenuItem(
                              value: 'Last 6 Months',
                              child: Text('Last 6 Months'),
                            ),
                            DropdownMenuItem(
                              value: 'All time',
                              child: Text('All time'),
                            ),
                          ],
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedTimeframe = newValue!;
                              _updateTransactionsForTimeframe(
                                  _selectedTimeframe);
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
                      'Balance: \$$_total',
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
                          'Income: \$$_income',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 18.0,
                            fontFamily: 'SF Pro Text',
                          ),
                        ),
                        Text(
                          'Expenses: \$$_expense',
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
            ),
            // End of Card
            SizedBox(height: 20.0),
            Expanded(
              child: _getTransactionsList(),
            ),
          ],
        ),
      ),
      floatingActionButton: _addTransactionFloatingButton(context, false),
    );
  }

  void _updateTransactionsForTimeframe(String timeframe) {
    DateTime firstDate, lastDate;
    switch (timeframe) {
      case 'This Month':
        lastDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
        firstDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
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
      case 'All time':
        _getAllTransactions();
        break;
      default:
        // Default to 'This Month'
        lastDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
        firstDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
        _getTransactionsListBydate(firstDate, lastDate);
        break;
    }
  }

  Widget _getTransactionsList() {
    if (_transactions.isEmpty) {
      return const Center(child: Text('No Transactions'));
    } else {
      return ListView.builder(
        itemCount: _transactions.length,
        itemBuilder: (context, index) {
          return Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    tileColor:
                        _getColorByTransactionId(_transactions[index].catId, 0),
                    leading: Icon(
                      _getIconByTransactionById(_transactions[index].catId),
                      color: _getTextOrIconColorBasedOnCategoryTypeColor(
                          _transactions[index].catId ?? -1),
                    ),
                    title: Text(
                        getCategoryNameFromCatId(
                            _transactions[index].catId ?? -1),
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: _getTextOrIconColorBasedOnCategoryTypeColor(
                                _transactions[index].catId ?? -1))),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_transactions[index].description ?? '',
                            style: TextStyle(
                                color:
                                    _getTextOrIconColorBasedOnCategoryTypeColor(
                                        _transactions[index].catId ?? -1))),
                        Text(
                            _getDateToShow(_transactions[index].date ??
                                DateTime.now().toIso8601String()),
                            style: TextStyle(
                                color:
                                    _getTextOrIconColorBasedOnCategoryTypeColor(
                                        _transactions[index].catId ?? -1)))
                      ],
                    ),
                    trailing: Text(
                      '$currencySymbol ${_transactions[index].amount}',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: _getTextOrIconColorBasedOnCategoryTypeColor(
                              _transactions[index].catId ?? -1)),
                    ),
                    onTap: () {
                      _createTransactionDialog(
                          context, true, _transactions[index]);
                    }),
                Visibility(
                  visible: _transactions[index].isAutoAdded == 1,
                  child: ListTile(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      leading: Icon(Icons.autorenew_rounded),
                      tileColor: _getColorByTransactionId(
                          _transactions[index].catId, 1),
                      title: Text(
                        'Auto added by recurring',
                        style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.black54),
                      ),
                      dense: true,
                      visualDensity: VisualDensity(vertical: -4),
                      onTap: () {
                        _createTransactionDialog(
                            context, true, _transactions[index]);
                      }),
                )
              ],
            ),
          );
        },
      );
    }
  }

  void _getTransactionsListBydate(fromDate, toDate) {
    _getTransactionsFromDBBydate(fromDate, toDate);
  }

  String _getDateToShow(String date) {
    DateTime parsedDate;
    try {
      parsedDate = DateFormat('yyyy-MM-dd').parse(date);
    } catch (e) {
      parsedDate = DateTime.parse(date);
    }
    return DateFormat('yyyy-MM-dd').format(parsedDate);
  }

  Widget _addTransactionFloatingButton(BuildContext context, bool isEdit) {
    return FloatingActionButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(200.0)),
      onPressed: () {
        _createTransactionDialog(context, false, TransactionModel());
      },
      child: const Icon(Icons.add),
    );
  }

  _getIconByTransactionById(int? catId) {
    var category = _categories.firstWhere((element) => element.catId == catId);
    return category.catType == 0 ? Icons.arrow_downward : Icons.arrow_upward;
  }

  Color _getColorByTransactionId(int? catId, int isAutoAdded) {
    var category = _categories.firstWhere((element) => element.catId == catId);
    return Color(int.parse('0xFF${category.catColor}'))
        .withOpacity(isAutoAdded == 1 ? 0.5 : 1.0);
  }

  void _createTransactionDialog(
      BuildContext context, bool isEdit, TransactionModel transactionModel) {
    initialiseVariables(isEdit, transactionModel);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.close),
                      ),
                      Visibility(
                        visible: isEdit,
                        child: IconButton(
                          onPressed: () {
                            _addTransactionToTrash(transactionModel.id ?? 0);
                            _deleteTransaction(transactionModel.id ?? 0);
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.delete),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0)),
                      contentPadding: const EdgeInsets.all(10.0),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  TextField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0)),
                      contentPadding: const EdgeInsets.all(10.0),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 10.0),
                  TextField(
                    readOnly: true,
                    controller: _dateController,
                    decoration: InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0)),
                      contentPadding: const EdgeInsets.all(10.0),
                    ),
                    onTap: () async {
                      await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      ).then((dateTime) {
                        if (dateTime != null) {
                          setState(() {
                            _dateController.text =
                                DateFormat('yyyy-MM-dd').format(dateTime);
                          });
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          readOnly: true,
                          controller: _selectedCategoryController,
                          onTap: () => _dialogBox(context, setState),
                          decoration: InputDecoration(
                            labelText: 'Select Category',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0)),
                            contentPadding: const EdgeInsets.all(10.0),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      _getIconWidget(),
                    ],
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                  child: (isEdit) ? const Text('Update') : const Text('Create'),
                  onPressed: () {
                    if (!isEdit) {
                      _dateController.text =
                          DateFormat('yyyy-MM-dd').format(DateTime.now());
                      _createTransaction();
                    } else {
                      transactionModel.description =
                          _descriptionController.text;
                      transactionModel.amount =
                          double.parse(_amountController.text);
                      transactionModel.date = _dateController.text;
                      transactionModel.catId =
                          _selectedCategoryController.text.isEmpty
                              ? 1
                              : _categories[selectedCategoryIndex].catId;
                      _updateTransaction(transactionModel);
                    }
                    resetVariables();
                    Navigator.of(context).pop();
                  })
            ],
          );
        });
      },
    );
  }

  void _deleteTransaction(int transactionId) async {
    await _transactionController.deleteTransaction(transactionId);
    _getAllTransactions();
  }

  void _updateTransaction(TransactionModel transactionModel) {
    _transactionController.updateTransaction(transaction: transactionModel);
    _getAllTransactions();
  }

  dynamic _getIconWidget() {
    if (_categories.isEmpty) {
      return const Icon(Icons.circle, color: Colors.grey);
    } else if (_categories.isNotEmpty &&
        selectedCategoryIndex < _categories.length) {
      return Icon(Icons.circle,
          color: Color(
              int.parse('0xFF${_categories[selectedCategoryIndex].catColor}')));
    }
  }

  void resetVariables() {
    _descriptionController.clear();
    _amountController.clear();
    _selectedCategoryController.clear();
  }

  void initialiseVariables(bool isEdit, TransactionModel transactionModel) {
    if (isEdit) {
      _descriptionController.text = transactionModel.description ?? '';
      _amountController.text = transactionModel.amount.toString();
      selectedCategoryIndex = _categories
          .indexWhere((category) => category.catId == transactionModel.catId);
      _selectedCategoryController.text =
          _categories[selectedCategoryIndex].catName ?? '';
      _dateController.text = _getDateToShow(
          transactionModel.date ?? DateTime.now().toIso8601String());
    } else {
      _descriptionController.text = '';
      _amountController.text = '';
      selectedCategoryIndex = 0;
      _selectedCategoryController.text = '';
      _dateController.text = _getDateToShow(DateTime.now().toIso8601String());
    }
  }

  void setSelectedCategoryIndex(int index) {
    setState(() {
      selectedCategoryIndex = index;
    });
  }

  dynamic _dialogBox(BuildContext context, StateSetter setState) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return SelectCategoryDialog(
            categories: _categories,
            setStateInCallingPage: setState,
            setSelectedCategoryIndex: setSelectedCategoryIndex,
            selectedCategoryIndex: selectedCategoryIndex,
            selectedCategoryController: _selectedCategoryController);
      },
    );
  }

  void _getAllCategories() async {
    var catagories = await _categoryController.getCategories();
    setState(() {
      _categories = catagories;
    });
  }

  void _getAllTransactions() async {
    _getStartDate();
    var transactions = await _transactionController.getTransactions();
    var income = await _transactionController.getAmountByDate(1, _startDate,
            DateTime(DateTime.now().year, DateTime.now().month + 1, 0)) ??
        0.0;
    var expense = await _transactionController.getAmountByDate(0, _startDate,
            DateTime(DateTime.now().year, DateTime.now().month + 1, 0)) ??
        0.0;
    setState(() {
      _transactions = transactions;
      _income = income;
      _expense = expense;
      _total = income - expense;
    });
  }

  void _createTransaction() {
    var dateTime = DateTime.parse(_dateController.text);
    dateTime = DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      DateTime.now().hour,
      DateTime.now().minute,
      DateTime.now().second,
    );
    _transactionController.addTransaction(
        transaction: TransactionModel(
      description: _descriptionController.text,
      amount: double.parse(_amountController.text),
      date: dateTime.toIso8601String(),
      catId: _selectedCategoryController.text.isEmpty
          ? 1
          : _categories[selectedCategoryIndex].catId,
      isAutoAdded: 0,
    ));
    _getAllTransactions();
  }

  void _getStartDate() async {
    var date = await _transactionController.getStartDate();
    setState(() {
      _startDate = date;
    });
  }

  void _getTransactionsFromDBBydate(fromDate, toDate) async {
    _getStartDate();
    var transactions =
        await _transactionController.getTransactionsByDate(fromDate, toDate);
    var income =
        await _transactionController.getAmountByDate(1, fromDate, toDate) ??
            0.0;
    var expense =
        await _transactionController.getAmountByDate(0, fromDate, toDate) ??
            0.0;

    setState(() {
      _transactions = transactions;
      _income = income;
      _expense = expense;
      _total = income - expense;
    });
  }

  String getCategoryNameFromCatId(int catId) {
    if (catId == -1) return 'Other Expenses';
    return _categories
            .firstWhere((element) => element.catId == catId)
            .catName ??
        'Other Expenses';
  }

  Color _getTextOrIconColorBasedOnCategoryTypeColor(int catId) {
    var index = _categories.indexWhere((element) => element.catId == catId);

    if (index >= _categories.length || catId == -1) {
      return Colors.black45;
    }
    return Colour.colorList.entries
                .firstWhere((entry) => entry.key == _categories[index].catColor,
                    orElse: () => MapEntry('', 0))
                .value ==
            1
        ? Colors.white
        : Colors.black;
  }

  Future<void> _addTransactionToTrash(int transactionId) async {
    var transaction =
        await _transactionController.getTransactionById(transactionId);
    _trashController.addTrash(
        trash: TrashModel(
            description: transaction.description,
            date: transaction.date,
            amount: transaction.amount,
            trashDate: DateTime.now().toIso8601String(),
            isAutoAdded: transaction.isAutoAdded,
            catId: transaction.catId));
  }
}

import 'package:FinTrack/db_helper/category_db_controller.dart';
import 'package:FinTrack/db_helper/transaction_db_controller.dart';
import 'package:FinTrack/db_helper/trash_db_controller.dart';
import 'package:FinTrack/models/category_model.dart';
import 'package:FinTrack/models/transaction_model.dart';
import 'package:FinTrack/models/trash_model.dart';
import 'package:FinTrack/pages/helper/drawer_navigation.dart';
import 'package:FinTrack/util/constants.dart';
import 'package:FinTrack/util/value_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TrashPage extends StatefulWidget {
  const TrashPage({super.key});

  @override
  State<TrashPage> createState() => _TrashPageState();
}

class _TrashPageState extends State<TrashPage> {
  List<TrashModel> _trash = [];
  List<CategoryModel> _categories = [];

  final CategoryController _categoryController = Get.find();
  final TrashController _trashController = Get.put(TrashController());
  final TransactionController _transactionController = Get.find();

  bool? deletePermanently = false;

  @override
  void initState() {
    _getAllCategories();
    _getAllTrash();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FinTrack Trash'),
        centerTitle: true,
        elevation: 0.0,
      ),
      drawer: const DrawerNavigation(),
      body: _getTrashList(),
    );
  }

  Widget _getTrashList() {
    if (_trash.isEmpty) {
      return const Center(child: Text('Trash Empty'));
    } else {
      return ListView.builder(
        itemCount: _trash.length,
        itemBuilder: (context, index) {
          return Card(
            child: Column(
              children: [
                ListTile(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    tileColor: Colors.grey,
                    leading: Icon(_getIconByTrashCatId(_trash[index].catId)),
                    title: Text(_trash[index].description ?? ''),
                    subtitle: Text(_trash[index].amount.toString()),
                    trailing: Text(_getDateToShow(
                        _trash[index].date ?? DateTime.now().toString())),
                    onTap: () {
                      _createDialog(context, _trash[index]);
                    }),
              ],
            ),
          );
        },
      );
    }
  }

  _getIconByTrashCatId(int? catId) {
    var category = _categories.firstWhere((element) => element.catId == catId);
    return category.catType == 0 ? Icons.arrow_downward : Icons.arrow_upward;
  }

  void _createDialog(BuildContext context, TrashModel trashModel) {
    deletePermanently = false;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              content: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child:
                      Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ignore: deprecated_member_use
                        Text("Choose Action", textScaleFactor: 1.5),
                        ListTile(
                          title: Text('Restore'),
                          leading: Radio<bool>(
                            value: false,
                            groupValue: deletePermanently,
                            onChanged: (bool? value) {
                              setState(() {
                                deletePermanently = value;
                              });
                            },
                          ),
                        ),
                        ListTile(
                          title: Text('Delete forever'),
                          leading: Radio<bool>(
                            value: true,
                            groupValue: deletePermanently,
                            onChanged: (bool? value) {
                              setState(() {
                                deletePermanently = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ])),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                    child: const Text('Okay'),
                    onPressed: () {
                      if (deletePermanently ?? false) {
                        _deleteTrashById(trashModel.id ?? 0);
                      } else {
                        _createTransaction(trashModel);
                        _deleteTrashById(trashModel.id ?? 0);
                      }
                      _getAllTrash();
                      Navigator.of(context).pop();
                    })
              ],
            );
          });
        });
  }

  void _getAllTrash() async {
    var trash = await _trashController.getTrash();
    setState(() {
      _trash = trash;
    });
  }

  void _getAllCategories() async {
    var catagories = await _categoryController.getCategories();
    setState(() {
      _categories = catagories;
    });
  }

  void _createTransaction(TrashModel trash) {
    _transactionController.addTransaction(
        transaction: TransactionModel(
      description: trash.description,
      amount: trash.amount,
      date: trash.date,
      catId: trash.catId,
      isAutoAdded: trash.isAutoAdded,
    ));
  }

  void _deleteTrashById(int trashId) {
    _trashController.deleteTrash(trashId);
  }

  String _getDateToShow(String date) {
    return Constants.showDateOnlyFormat
        .format(ValueHelper().getDateFromISOString(date));
  }
}

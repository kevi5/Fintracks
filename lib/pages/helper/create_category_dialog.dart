import 'package:FinTrack/db_helper/category_db_controller.dart';
import 'package:FinTrack/pages/components/selectable_button.dart';
import 'package:FinTrack/util/color.dart';
import 'package:flutter/material.dart';
import 'package:FinTrack/models/category_model.dart';
import 'package:get/get.dart';

class CreateCategoryDialog extends StatefulWidget {
  final bool isEditModeOn;
  final CategoryModel categoryModel;
  final Function setStateInCallingPage;
  List<CategoryModel> categories;
  CreateCategoryDialog(
      {super.key,
      required this.isEditModeOn,
      required this.categoryModel,
      required this.setStateInCallingPage,
      required this.categories});

  @override
  State<CreateCategoryDialog> createState() => _CreateCategoryDialogState();
}

class _CreateCategoryDialogState extends State<CreateCategoryDialog> {
  final TextEditingController _categoryNameController = TextEditingController();
  int _colorIndex = 0;
  bool _isFavorite = false;
  bool _isExpense = true;
  final CategoryController _categoryController = Get.find();
  bool expense = true;
  bool income = false;

  @override
  Widget build(BuildContext context) {
    initializeControllersAndVars();

    return StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  visible: widget.isEditModeOn,
                  child: IconButton(
                    onPressed: () {
                      _deleteCategory(id: widget.categoryModel.catId ?? -1);
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.delete),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            TextField(
              controller: _categoryNameController,
              decoration: InputDecoration(
                labelText: 'Category Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                contentPadding: const EdgeInsets.all(10.0),
              ),
            ),
            const SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SelectableButton(
                  selected: expense,
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.selected)) {
                          return Colors.white;
                        }
                        return null; // defer to the defaults
                      },
                    ),
                    backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                        print(states);
                        if (states.contains(MaterialState.selected)) {
                          return Colors.indigo;
                        }
                        return null; // defer to the defaults
                      },
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _isExpense = !_isExpense;
                      expense = !expense;
                      income = !income;
                    });
                  },
                  child: const Text('Expense'),
                ),
                SelectableButton(
                  selected: income,
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.selected)) {
                          return Colors.white;
                        }
                        return null; // defer to the defaults
                      },
                    ),
                    backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.selected)) {
                          return Colors.indigo;
                        }
                        return null; // defer to the defaults
                      },
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _isExpense = !_isExpense;
                      expense = !expense;
                      income = !income;
                    });
                  },
                  child: const Text('Income'),
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            Container(
              height: 40,
              width: MediaQuery.of(context).size.width * 0.6,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: Colour.colorList.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _colorIndex = index;
                          });
                        },
                        child: Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              color: Color(int.parse(
                                  '0xFF${Colour.colorList.keys.elementAt(index)}')),
                              shape: BoxShape.circle,
                            )),
                      ),
                    );
                  }),
            ),
            CheckboxListTile(
              title: const Text("Favorite Category"),
              value: _isFavorite,
              onChanged: (newValue) {
                setState(() {
                  _isFavorite = !_isFavorite;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            )
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (widget.isEditModeOn) {
                _updateCategory(widget.categoryModel);
              } else {
                _createCategory();
              }
              //set all attributes to default/empty
              _categoryNameController.clear();
              _colorIndex = 0;
              _isFavorite = false;
              _isExpense = true;
              Navigator.of(context).pop();
            },
            child: Text(widget.isEditModeOn ? 'Update' : 'Create'),
          ),
        ],
      );
    });
  }

  void initializeControllersAndVars() {
    if (widget.isEditModeOn) {
      _categoryNameController.text = widget.categoryModel.catName ?? '';
      _colorIndex = Colour.colorList.keys
          .toList()
          .indexOf(widget.categoryModel.catColor ?? '');
      _isFavorite = widget.categoryModel.catIsFav ?? false;
      _isExpense = widget.categoryModel.catType == 0 ? true : false;
      expense = _isExpense;
      income = !_isExpense;
    } else {
      _categoryNameController.clear();
      _colorIndex = 0;
      _isFavorite = false;
      _isExpense = true;
      expense = true;
      income = false;
    }
  }

  void _updateCategory(CategoryModel categoryModel) async {
    await _categoryController.updateCategory(
        category: CategoryModel(
      catId: widget.categoryModel.catId,
      catName: _categoryNameController.text,
      catCount: widget.categoryModel.catCount,
      catColor: Colour.colorList.keys.elementAt(_colorIndex),
      catIsFav: _isFavorite,
      catType: _isExpense ? 0 : 1,
    ));
    _getAllCategories();
  }

  void _deleteCategory({required int id}) async {
    if (id == -1) {
      return;
    }
    await _categoryController.deleteCategory(id);
    _getAllCategories();
  }

  void _createCategory() {
    // _categoryController.deleteAllCategories();

    _categoryController.addCategory(
        category: CategoryModel(
      catName: _categoryNameController.text,
      catCount: 0,
      catColor: Colour.colorList.keys.elementAt(_colorIndex),
      catIsFav: _isFavorite,
      catType: _isExpense ? 0 : 1,
    ));
    _getAllCategories();
  }

  void _getAllCategories() async {
    var catagory = await _categoryController.getCategories();
    widget.setStateInCallingPage(() {
      widget.categories = catagory;
    });
  }
}

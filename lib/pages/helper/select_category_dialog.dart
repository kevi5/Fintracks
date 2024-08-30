import 'package:FinTrack/db_helper/category_db_controller.dart';
import 'package:FinTrack/models/category_model.dart';
import 'package:FinTrack/pages/helper/create_category_dialog.dart';
import 'package:FinTrack/util/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectCategoryDialog extends StatefulWidget {
  List<CategoryModel> categories;
  final Function setStateInCallingPage;
  final Function setSelectedCategoryIndex;
  int selectedCategoryIndex;
  final TextEditingController selectedCategoryController;

  SelectCategoryDialog(
      {super.key,
      required this.categories,
      required this.setStateInCallingPage,
      required this.setSelectedCategoryIndex,
      required this.selectedCategoryIndex,
      required this.selectedCategoryController});

  @override
  State<SelectCategoryDialog> createState() => _SelectCategoryDialogState();
}

class _SelectCategoryDialogState extends State<SelectCategoryDialog> {
  final CategoryController _categoryController = Get.find();

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        title: const Text('Select Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(child: _buildView(context, setState)),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: SizedBox(
                    width: double.maxFinite,
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      leading: const Icon(Icons.add),
                      title: const Text('Add Category'),
                      onTap: () {
                        //add category dialog box open
                        showDialog(
                            context: context,
                            builder: (context) {
                              return CreateCategoryDialog(
                                  isEditModeOn: false,
                                  categoryModel: CategoryModel(),
                                  setStateInCallingPage:
                                      widget.setStateInCallingPage,
                                  categories: widget.categories);
                            });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildView(BuildContext context, StateSetter setState) {
    _getCategories();
    return SizedBox(
      width: double.maxFinite,
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: widget.categories.length,
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemBuilder: (BuildContext context, int index) {
          return Card(
            elevation: 5.0,
            color: Color(int.parse('0xFF${widget.categories[index].catColor}')),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              leading: Icon(
                  widget.categories[index].catType == 0
                      ? Icons.arrow_downward
                      : Icons.arrow_upward,
                  color: getColorBasedOnType(index)),
              title: Text(
                widget.categories[index].catName.toString(),
                style: TextStyle(
                  color: getColorBasedOnType(index),
                ),
              ),
              onTap: () {
                setState(() {
                  widget.selectedCategoryIndex = index;
                  widget.selectedCategoryController.text =
                      widget.categories[index].catName.toString();
                });
                widget.setSelectedCategoryIndex(index);
                print('selected : ${widget.selectedCategoryController.text}');
                Navigator.of(context).pop();
              },
            ),
          );
        },
      ),
    );
  }

  dynamic getColorBasedOnType(int index) {
    return Colour.colorList.entries
                .firstWhere(
                    (entry) => entry.key == widget.categories[index].catColor,
                    orElse: () => MapEntry('', 0))
                .value ==
            1
        ? Colors.white
        : Colors.black;
  }

  void _getCategories() async {
    var catagory = await _categoryController.getCategories();
    widget.setStateInCallingPage(() {
      widget.categories = catagory;
    });
  }
}

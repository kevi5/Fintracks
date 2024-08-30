import 'package:FinTrack/db_helper/db/db_helper.dart';
import 'package:FinTrack/models/category_model.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class CategoryController {
  var categoriesList = <CategoryModel>[].obs;
  var particularCategory = CategoryModel();

  Future<int> addCategory({CategoryModel? category}) async {
    var result = await DBHelper.insertCategory(category!);
    if (result > 0) {
      categoriesList.add(category);
    } else {
      if (kDebugMode) {
        print('Failed to add category');
      }
    }
    return result;
  }

  Future<List<CategoryModel>> getCategories() async {
    List<Map<String, dynamic>> categories = await DBHelper.getCategories();
    categoriesList.assignAll(
        categories.map((data) => CategoryModel.fromJson(data)).toList());
    if (kDebugMode) {
      print('Total fetched categories: ${categoriesList.length}');
    }
    return categoriesList;
  }

  Future<int> updateCategory({CategoryModel? category}) async {
    var result = await DBHelper.updateCategory(category!);
    return result;
  }

  Future<CategoryModel> getCategoryById(int? id) async {
    List<Map<String, dynamic>> category = await DBHelper.getCategoryById(id!);
    particularCategory = CategoryModel.fromJson(category[0]);
    return particularCategory;
  }

  //delete full table
  void deleteAllCategories() async {
    DBHelper.deleteAllCategories();
  }

  //delete particular category
  Future<int> deleteCategory(int? id) async {
    return await DBHelper.deleteCategory(id!);
  }
}

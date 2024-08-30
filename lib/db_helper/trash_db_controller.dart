import 'package:FinTrack/db_helper/db/db_helper.dart';
import 'package:FinTrack/models/trash_model.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class TrashController {
  var trashList = <TrashModel>[].obs;

  Future<int> addTrash({TrashModel? trash}) async {
    var result = await DBHelper.insertTrash(trash!);
    if (result > 0) {
      trashList.add(trash);
      print('Added successfully');
    } else {
      if (kDebugMode) {
        print('Failed to add trash');
      }
    }
    return result;
  }

  Future<List<TrashModel>> getTrash() async {
    List<Map<String, dynamic>> trash = await DBHelper.getTrash();
    trashList
        .assignAll(trash.map((data) => TrashModel.fromJson(data)).toList());
    if (kDebugMode) {
      print('Total fetched trash: ${trashList.length}');
    }
    return trashList;
  }

  void deleteAllTrash() async {
    DBHelper.deleteAllTrash();
  }

  //delete particular trash
  Future<int> deleteTrash(int? id) async {
    return await DBHelper.deleteTrash(id!);
  }
}

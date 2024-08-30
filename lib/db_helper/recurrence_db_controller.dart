import 'package:FinTrack/db_helper/db/db_helper.dart';
import 'package:FinTrack/models/recurrence_model.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class RecurrenceController {
  var recurrenceList = <RecurrenceModel>[].obs;
  var particularRecurrence = RecurrenceModel();

  Future<int> addRecurringTransaction({RecurrenceModel? recurrence}) async {
    var result = await DBHelper.insertRecurrence(recurrence!);
    if (result > 0) {
      recurrenceList.add(recurrence);
    } else {
      if (kDebugMode) {
        print('Failed to add recurring transaction');
      }
    }
    return result;
  }

  Future<List<RecurrenceModel>> getRecurringTransactions() async {
    List<Map<String, dynamic>> recurrences = await DBHelper.getRecurrences();
    recurrenceList.assignAll(
        recurrences.map((data) => RecurrenceModel.fromJson(data)).toList());
    if (kDebugMode) {
      print('Total fetched recurring transaction: ${recurrenceList.length}');
    }
    return recurrenceList;
  }

  Future<int> updateRecurringTransaction(
      {RecurrenceModel? recurringTransaction}) async {
    var result = await DBHelper.updateRecurrence(recurringTransaction!);
    if (result > 0) {
      var index = recurrenceList.indexWhere(
          (element) => element.recurId == recurringTransaction.recurId);
      recurrenceList[index] = recurringTransaction;
    }
    return result;
  }

  //delete full table
  void deleteAllRecurringTransactions() async {
    DBHelper.deleteAllRecurrences();
  }

  //delete particular category
  Future<int> deleteRecurringTransaction(int? id) async {
    return await DBHelper.deleteRecurrence(id!);
  }

  //get recurrent transactions
  Future<List<RecurrenceModel>> getUpcomingRecurrentTransactions(
      DateTime startDate, DateTime endDate) async {
    List<Map<String, dynamic>> recurrences =
        await DBHelper.getUpcomingRecurrentTransactions(startDate, endDate);
    recurrenceList.assignAll(
        recurrences.map((data) => RecurrenceModel.fromJson(data)).toList());
    if (kDebugMode) {
      print('Total fetched recurring transaction: ${recurrenceList.length}');
    }
    return recurrenceList;
  }
}

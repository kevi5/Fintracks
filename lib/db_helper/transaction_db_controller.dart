import 'package:FinTrack/models/transaction_model.dart';
import 'package:FinTrack/db_helper/db/db_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class TransactionController {
  var transactionsList = <TransactionModel>[].obs;

  Future<int> addTransaction({TransactionModel? transaction}) async {
    var result = await DBHelper.insertTransaction(transaction!);
    if (result > 0) {
      transactionsList.add(transaction);
      print('Added successfully');
    } else {
      if (kDebugMode) {
        print('Failed to add transaction');
      }
    }
    return result;
  }

  Future<List<TransactionModel>> getTransactions() async {
    List<Map<String, dynamic>> transactions = await DBHelper.getTransactions();
    transactionsList.assignAll(
        transactions.map((data) => TransactionModel.fromJson(data)).toList());
    if (kDebugMode) {
      print('Total fetched transactions: ${transactionsList.length}');
    }
    return transactionsList;
  }

  Future<List<TransactionModel>> getTransactionsByDate(
      DateTime fromDate, DateTime toDate) async {
    List<Map<String, dynamic>> transactions =
        await DBHelper.getTransactionsByDate(fromDate, toDate);
    transactionsList.assignAll(
        transactions.map((data) => TransactionModel.fromJson(data)).toList());
    return transactionsList;
  }

  Future<int> updateTransaction({TransactionModel? transaction}) async {
    var result = await DBHelper.updateTransaction(transaction!);
    return result;
  }

  Future<double?> getAmountByDate(
      int type, DateTime fromDate, DateTime toDate) async {
    var result = await DBHelper.getAmountByDate(type, fromDate, toDate);
    return result;
  }

  void deleteAllTransactions() async {
    DBHelper.deleteAllTransactions();
  }

  Future<dynamic> getStartDate() async {
    var date = await DBHelper.getStartDate();
    return date;
  }

  //delete particular transaction
  Future<int> deleteTransaction(int? id) async {
    return await DBHelper.deleteTransaction(id!);
  }

  Future<TransactionModel> getTransactionById(int? id) async {
    List<Map<String, dynamic>> transaction =
        await DBHelper.getTransactionById(id!);
    return TransactionModel.fromJson(transaction[0]);
  }
}

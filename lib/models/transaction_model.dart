class TransactionModel{
  int? id;
  String? description;
  double? amount;
  String? date;
  int? catId;
  int? isAutoAdded;

  TransactionModel({this.id, this.description, this.amount, this.date, this.catId, this.isAutoAdded});

  factory TransactionModel.fromJson(Map<String, dynamic> json){
    return TransactionModel(
      id: json['id'],
      description: json['description'],
      amount: json['amount'],
      date: json['date'],
      catId: json['cat_id'],
      isAutoAdded: json['is_auto_added'],
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'date': date,
      'cat_id': catId,
      'is_auto_added': isAutoAdded
    };
  }
}
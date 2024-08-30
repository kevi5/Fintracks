class TrashModel{
  int? id;
  String? description;
  double? amount;
  String? date;
  int? catId;
  int? isAutoAdded;
  String? trashDate;

  TrashModel({this.id, this.description, this.amount, this.date, this.catId, this.isAutoAdded, this.trashDate});

  factory TrashModel.fromJson(Map<String, dynamic> json){
    return TrashModel(
      id: json['id'],
      description: json['description'],
      amount: json['amount'],
      date: json['date'],
      catId: json['cat_id'],
      isAutoAdded: json['is_auto_added'],
      trashDate: json['trash_date']
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'date': date,
      'cat_id': catId,
      'is_auto_added': isAutoAdded,
      'trash_date': trashDate
    };
  }
}
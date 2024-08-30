class RecurrenceModel{
  int? recurId;
  String? recurAmount;
  String? recurNote;
  int? recurCatId;
  int? recurType; //0 - daily, 1 - weekly(take day), 2-monthly (take date), 3-yearly(take date and month)
  String? recurOnLabel; //if daily store 10 PM, if weekly then store day value, if monthly then store date, if yearly then store date and month
  String? recurOn;
  bool? recurShown;

  RecurrenceModel({this.recurId, this.recurAmount, this.recurNote, this.recurCatId, this.recurType, this.recurOnLabel, this.recurOn, this.recurShown});

  factory RecurrenceModel.fromJson(Map<String, dynamic> json){
    return RecurrenceModel(
      recurId: json['recur_id'],
      recurAmount: json['recur_amount'],
      recurNote: json['recur_note'],
      recurCatId: json['recur_cat_id'],
      recurType: json['recur_type'],
      recurOnLabel: json['recur_on_label'],
      recurOn: json['recur_on'],
      recurShown: json['recur_shown'] == 1 ? true : false,
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'recur_id': recurId,
      'recur_amount': recurAmount,
      'recur_note': recurNote,
      'recur_cat_id': recurCatId,
      'recur_type': recurType,
      'recur_on_label': recurOnLabel,
      'recur_on': recurOn,
      'recur_shown': recurShown == true ? 1 : 0
    };
  }
}
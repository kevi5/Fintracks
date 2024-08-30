class CategoryModel{
  int? catId;
  String? catName;
  int? catType;
  int? catCount;
  String? catColor;
  bool? catIsFav;

  CategoryModel({this.catId, this.catName, this.catType, this.catCount, this.catColor, this.catIsFav});

  factory CategoryModel.fromJson(Map<String, dynamic> json){
    return CategoryModel(
      catId: json['cat_id'],
      catName: json['cat_name'],
      catType: json['cat_type'],
      catCount: json['cat_count'],
      catColor: json['cat_color'],
      catIsFav: json['cat_is_fav'] == 1 ? true : false,
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'cat_id': catId,
      'cat_name': catName,
      'cat_type': catType,
      'cat_count': catCount,
      'cat_color': catColor,
      'cat_is_fav': catIsFav == true ? 1 : 0,
    };
  }
}
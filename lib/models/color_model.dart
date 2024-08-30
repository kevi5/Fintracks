class ColorModel{
  int? colorId;
  String? colorCode;
  String? colorTextType;

  ColorModel({this.colorId, this.colorCode, this.colorTextType});

  factory ColorModel.fromJson(Map<String, dynamic> json){
    return ColorModel(
      colorId: json['color_id'],
      colorCode: json['color_code'],
      colorTextType: json['color_text_type'],
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'color_id': colorId,
      'color_code': colorCode,
      'color_text_type': colorTextType,
    };
  }
}
class ReviewsClass {
  String? success;
  String? register;
  List<DRData>? data;

  ReviewsClass({this.success, this.register, this.data});

  ReviewsClass.fromJson(Map<String, dynamic> json) {
    success = json['success'].toString();
    register = json['register'];
    if (json['data'] != null) {
      data = <DRData>[];
      json['data'].forEach((v) {
        data!.add(DRData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['register'] = register;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DRData {
  String? name;
  String? rating;
  String? description;
  String? image;

  DRData({this.name, this.rating, this.description, this.image});

  DRData.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    rating = json['rating'].toString();
    description = json['description'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['rating'] = rating;
    data['description'] = description;
    data['image'] = image;
    return data;
  }
}

class ReportSpamData {
  int? success;
  String? register;
  RData? data;

  ReportSpamData({this.success, this.register, this.data});

  ReportSpamData.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    register = json['register'];
    data = json['data'] != null ? RData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['register'] = register;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class RData {
  int? userId;
  String? title;
  dynamic description;
  String? updatedAt;
  String? createdAt;
  int? id;

  RData(
      {this.userId,
      this.title,
      this.description,
      this.updatedAt,
      this.createdAt,
      this.id});

  RData.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    title = json['title'];
    description = json['description'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['title'] = title;
    data['description'] = description;
    data['updated_at'] = updatedAt;
    data['created_at'] = createdAt;
    data['id'] = id;
    return data;
  }
}

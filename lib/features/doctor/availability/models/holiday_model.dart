class HolidayModel {
  String? success;
  String? msg;
  List<HData>? data;

  HolidayModel({this.success, this.msg, this.data});

  HolidayModel.fromJson(Map<String, dynamic> json) {
    success = json['success'].toString();
    msg = json['msg'];
    if (json['data'] != null) {
      data = <HData>[];
      json['data'].forEach((v) {
        data!.add(HData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['msg'] = msg;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class HData {
  int? id;
  int? doctorId;
  String? startDate;
  String? endDate;
  String? description;
  String? createdAt;
  String? updatedAt;

  HData({
    this.id,
    this.doctorId,
    this.startDate,
    this.endDate,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  HData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    doctorId = json['doctor_id'];
    startDate = json['start_date'].toString();
    endDate = json['end_date'].toString();
    description = json['description'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['doctor_id'] = doctorId;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    data['description'] = description;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

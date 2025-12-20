class UploadImageModel {
  int? status;
  String? message;
  UploadImageData? data;

  UploadImageModel({this.status, this.message, this.data});

  UploadImageModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? UploadImageData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class UploadImageData {
  String? name;
  String? appointmentId;
  String? image;
  String? updatedAt;
  String? createdAt;
  int? id;

  UploadImageData(
      {this.name,
        this.appointmentId,
        this.image,
        this.updatedAt,
        this.createdAt,
        this.id});

  UploadImageData.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    appointmentId = json['appointment_id'];
    image = json['image'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['appointment_id'] = appointmentId;
    data['image'] = image;
    data['updated_at'] = updatedAt;
    data['created_at'] = createdAt;
    data['id'] = id;
    return data;
  }
}

class ReportDeleteRes {
  int? status;
  String? message;

  ReportDeleteRes({this.status, this.message});

  ReportDeleteRes.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    return data;
  }
}

class DoctorProfileDetails {
  dynamic success;
  String? register;
  MyData? data;

  DoctorProfileDetails({this.success, this.register, this.data});

  DoctorProfileDetails.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    register = json['register'];
    data = json['data'] != null ? MyData.fromJson(json['data']) : null;
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

class MyData {
  int? id;
  String? name;
  String? email;
  String? aboutus;
  String? workingTime;
  String? address;
  String? lat;
  String? lon;
  dynamic phoneno;
  String? services;
  String? healthcare;
  String? image;
  dynamic password;
  String? createdAt;
  String? updatedAt;
  int? isApprove;
  dynamic consultationFees;
  String? departmentName;
  int? avgratting;

  MyData({
    this.id,
    this.name,
    this.email,
    this.aboutus,
    this.workingTime,
    this.address,
    this.lat,
    this.lon,
    this.phoneno,
    this.services,
    this.healthcare,
    this.image,
    this.password,
    this.createdAt,
    this.updatedAt,
    this.isApprove,
    this.consultationFees,
    this.departmentName,
    this.avgratting,
  });

  MyData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    aboutus = json['aboutus'] ?? "";
    workingTime = json['working_time'].toString();
    address = json['address'] ?? "";
    lat = json['lat'] == null ? "" : json['lat'].toString();
    lon = json['lon'] == null ? "" : json['lon'].toString();
    phoneno = json['phoneno'].toString();
    services = json['services'] ?? "";
    healthcare = json['healthcare'] ?? "";
    image = json['image'].toString();
    password = json['password'].toString();
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    isApprove = json['is_approve'];
    consultationFees = json['consultation_fees'].toString();
    departmentName = json['department_name'] ?? "";
    avgratting = json['avgratting'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['aboutus'] = aboutus;
    data['working_time'] = workingTime;
    data['address'] = address;
    data['lat'] = lat;
    data['lon'] = lon;
    data['phoneno'] = phoneno;
    data['services'] = services;
    data['healthcare'] = healthcare;
    data['image'] = image;
    data['password'] = password;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['is_approve'] = isApprove;
    data['consultation_fees'] = consultationFees;
    data['department_name'] = departmentName;
    data['avgratting'] = avgratting;
    return data;
  }
}

class DoctorProfileWithRating {
  String? success;
  String? register;
  DPData? data;

  DoctorProfileWithRating({this.success, this.register, this.data});

  DoctorProfileWithRating.fromJson(Map<String, dynamic> json) {
    success = json['success'].toString();
    register = json['register'];
    data = json['data'] != null ? DPData.fromJson(json['data']) : null;
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

class DPData {
  int? id;
  String? name;
  String? image;
  String? address;
  String? departmentName;
  int? avgratting;
  dynamic isSubscription;

  DPData({
    this.id,
    this.name,
    this.image,
    this.address,
    this.departmentName,
    this.isSubscription,
    this.avgratting,
  });

  DPData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'].toString();
    address = json['address'];
    departmentName = json['department_name'];
    avgratting = json['avgratting'];
    isSubscription = json['is_subscription'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['image'] = image;
    data['address'] = address;
    data['department_name'] = departmentName;
    data['avgratting'] = avgratting;
    data['is_subscription'] = isSubscription;
    return data;
  }
}

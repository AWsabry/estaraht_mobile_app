class SpecialityClass {
  String? success;
  String? register;
  List<Speciality>? data;

  SpecialityClass({this.success, this.register, this.data});

  SpecialityClass.fromJson(Map<String, dynamic> json) {
    success = json['success'].toString();
    register = json['register'];
    if (json['data'] != null) {
      data = <Speciality>[];
      json['data'].forEach((v) {
        data!.add(Speciality.fromJson(v));
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

class Speciality {
  int? id;
  String? name;
  String? icon;
  int? totalDoctors;

  Speciality({this.id, this.name, this.icon, this.totalDoctors});

  Speciality.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    icon = json['icon'];
    totalDoctors = json['total_doctors'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['icon'] = icon;
    data['total_doctors'] = totalDoctors;
    return data;
  }
}
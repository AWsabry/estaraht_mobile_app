class HomeScreenData {
  int? status;
  String? msg;
  HomeData? data;

  HomeScreenData({this.status, this.msg, this.data});

  HomeScreenData.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    msg = json['msg'];
    data = json['data'] != null ? HomeData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['msg'] = msg;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class HomeData {
  List<BannerList>? banner;
  List<SpecialityData>? speciality;
  List<Appointment>? appointment;

  HomeData({this.banner, this.speciality, this.appointment});

  HomeData.fromJson(Map<String, dynamic> json) {
    if (json['banner'] != null) {
      banner = <BannerList>[];
      json['banner'].forEach((v) {
        banner!.add(BannerList.fromJson(v));
      });
    }
    if (json['speciality'] != null) {
      speciality = <SpecialityData>[];
      json['speciality'].forEach((v) {
        speciality!.add(SpecialityData.fromJson(v));
      });
    }
    if (json['appointment'] != null) {
      appointment = <Appointment>[];
      json['appointment'].forEach((v) {
        appointment!.add(Appointment.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (banner != null) {
      data['banner'] = banner!.map((v) => v.toJson()).toList();
    }
    if (speciality != null) {
      data['speciality'] = speciality!.map((v) => v.toJson()).toList();
    }
    if (appointment != null) {
      data['appointment'] = appointment!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BannerList {
  int? id;
  String? image;

  BannerList({this.id, this.image});

  BannerList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['image'] = image;
    return data;
  }
}

class SpecialityData {
  int? id;
  String? name;
  String? icon;

  SpecialityData({this.id, this.name, this.icon});

  SpecialityData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    icon = json['icon'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['icon'] = icon;
    return data;
  }
}

class Appointment {
  int? id;
  int? doctorId;
  String? date;
  String? slot;
  String? phone;
  String? departmentName;
  Doctorls? doctorls;

  Appointment(
      {this.id,
      this.doctorId,
      this.date,
      this.slot,
      this.phone,
      this.departmentName,
      this.doctorls});

  Appointment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    doctorId = json['doctor_id'];
    date = json['date'];
    slot = json['slot'];
    phone = json['phone'];
    departmentName = json['department_name'];
    doctorls = json['doctorls'] != null
        ? Doctorls.fromJson(json['doctorls'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['doctor_id'] = doctorId;
    data['date'] = date;
    data['slot'] = slot;
    data['phone'] = phone;
    data['department_name'] = departmentName;
    if (doctorls != null) {
      data['doctorls'] = doctorls!.toJson();
    }
    return data;
  }
}

class Doctorls {
  String? name;
  String? email;
  String? workingTime;
  String? address;
  String? lat;
  String? lon;
  String? phoneno;
  String? image;
  String? password;
  String? consultationFees;

  Doctorls(
      {this.name,
      this.email,
      this.workingTime,
      this.address,
      this.lat,
      this.lon,
      this.phoneno,
      this.image,
      this.password,
      this.consultationFees});

  Doctorls.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    workingTime = json['working_time'];
    address = json['address'];
    lat = json['lat'];
    lon = json['lon'];
    phoneno = json['phoneno'];
    image = json['image'];
    password = json['password'];
    consultationFees = json['consultation_fees'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['email'] = email;
    data['working_time'] = workingTime;
    data['address'] = address;
    data['lat'] = lat;
    data['lon'] = lon;
    data['phoneno'] = phoneno;
    data['image'] = image;
    data['password'] = password;
    data['consultation_fees'] = consultationFees;
    return data;
  }
}

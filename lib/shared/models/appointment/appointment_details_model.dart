class DoctorAppointmentDetailsClass {
  int? success;
  Prescription? prescription;
  String? register;
  String? prescription1;
  Data? data;
  List<PrescriptionImage>? image;

  DoctorAppointmentDetailsClass({
    this.success,
    this.prescription,
    this.register,
    this.data,
    this.image,
  });

  DoctorAppointmentDetailsClass.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    register = json['register'];
    if (json['prescription'].runtimeType == String) {
      prescription1 = json['prescription'];
    } else {
      prescription = Prescription.fromJson(json['prescription']);
    }
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    if (json['image'] != null) {
      image = <PrescriptionImage>[];
      json['image'].forEach((v) {
        image!.add(PrescriptionImage.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['register'] = register;
    if (prescription != null) {
      data['prescription'] = prescription!.toJson();
    }
    if (prescription1.toString() != "null") {
      data['prescription'] = prescription1;
    }
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    if (image != null) {
      data['image'] = image!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DoctorAppointmentDetailsClass1 {
  int? success;
  Prescription? prescription;
  String? register;
  String? prescription1;
  Data? data;
  List<PrescriptionImage>? image;
  Doctor? doctor;

  DoctorAppointmentDetailsClass1({
    this.success,
    this.prescription,
    this.register,
    this.data,
    this.image,
  });

  DoctorAppointmentDetailsClass1.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    register = json['register'];
    if (json['prescription'].runtimeType == String) {
      prescription1 = json['prescription'];
    } else {
      prescription = Prescription.fromJson(json['prescription']);
    }
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    if (json['image'] != null) {
      image = <PrescriptionImage>[];
      json['image'].forEach((v) {
        image!.add(PrescriptionImage.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['register'] = register;
    if (prescription != null) {
      data['prescription'] = prescription!.toJson();
    }
    if (prescription1.toString() != "null") {
      data['prescription'] = prescription1;
    }
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    if (image != null) {
      data['image'] = image!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Prescription {
  List<Medicine>? medicine;

  Prescription({this.medicine});

  Prescription.fromJson(Map<String, dynamic> json) {
    if (json['medicine'] != null) {
      medicine = <Medicine>[];
      json['medicine'].forEach((v) {
        medicine!.add(Medicine.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (medicine != null) {
      data['medicine'] = medicine!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Medicine {
  int? medicineId;
  int? repeatDays;
  List<Time>? time;
  dynamic dosage;
  dynamic type;
  String? medicine_name;

  Medicine({
    this.medicineId,
    this.repeatDays,
    this.time,
    this.dosage,
    this.type,
    this.medicine_name,
  });

  Medicine.fromJson(Map<String, dynamic> json) {
    medicineId = json['medicine_id'];
    repeatDays = json['repeat_days'];
    medicine_name = json['medicine_name'];
    if (json['time'] != null) {
      time = <Time>[];
      json['time'].forEach((v) {
        time!.add(Time.fromJson(v));
      });
    }
    dosage = json['dosage'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['medicine_id'] = medicineId;
    data['repeat_days'] = repeatDays;
    if (time != null) {
      data['time'] = time!.map((v) => v.toJson()).toList();
    }
    data['dosage'] = dosage;
    data['type'] = type;
    data['medicine_name'] = medicine_name;
    return data;
  }
}

class Time {
  String? tTime;

  Time({this.tTime});

  Time.fromJson(Map<String, dynamic> json) {
    tTime = json['t_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['t_time'] = tTime;
    return data;
  }
}

class Data {
  String? doctorImage;
  String? doctorName;
  String? doctorGender;
  String? userImage;
  String? userName;
  int? status;
  int? doctorId;
  int? userId;
  String? date;
  String? slot;
  dynamic phone;
  String? email;
  String? description;
  dynamic connectycubeUserId;
  dynamic id;
  String? prescription;
  List<DeviceToken>? deviceToken;
  String? remainTime;
  int? isAppointmentTime;

  Data({
    this.doctorImage,
    this.doctorName,
    this.doctorGender,
    this.userImage,
    this.userName,
    this.status,
    this.doctorId,
    this.userId,
    this.date,
    this.slot,
    this.phone,
    this.email,
    this.description,
    this.connectycubeUserId,
    this.id,
    this.prescription,
    this.deviceToken,
    this.remainTime,
    this.isAppointmentTime,
  });

  Data.fromJson(Map<String, dynamic> json) {
    doctorImage = json['doctor_image'];
    doctorName = json['doctor_name'];
    doctorGender = json['doctor_gender'];
    userImage = json['user_image'];
    userName = json['user_name'];
    status = json['status'];
    // Handle doctor_id - convert string to int if needed
    if (json['doctor_id'] is int) {
      doctorId = json['doctor_id'];
    } else if (json['doctor_id'] is String) {
      doctorId = int.tryParse(json['doctor_id']);
    }
    // Handle user_id - convert string to int if needed
    if (json['user_id'] is int) {
      userId = json['user_id'];
    } else if (json['user_id'] is String) {
      userId = int.tryParse(json['user_id']);
    }
    date = json['date'];
    slot = json['slot'];
    phone = json['phone'];
    email = json['email'];
    description = json['description'];
    connectycubeUserId = json['connectycube_user_id'];
    id = json['id'];
    prescription = json['prescription'];
    if (json['device_token'] != null) {
      deviceToken = <DeviceToken>[];
      json['device_token'].forEach((v) {
        deviceToken!.add(DeviceToken.fromJson(v));
      });
    }
    remainTime = json['remain_time'];
    isAppointmentTime = json['is_appointment_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['doctor_image'] = doctorImage;
    data['doctor_name'] = doctorName;
    data['doctor_gender'] = doctorGender;
    data['user_image'] = userImage;
    data['user_name'] = userName;
    data['status'] = status;
    data['doctor_id'] = doctorId;
    data['user_id'] = userId;
    data['date'] = date;
    data['slot'] = slot;
    data['phone'] = phone;
    data['email'] = email;
    data['description'] = description;
    data['connectycube_user_id'] = connectycubeUserId;
    data['id'] = id;
    data['prescription'] = prescription;
    if (deviceToken != null) {
      data['device_token'] = deviceToken!.map((v) => v.toJson()).toList();
    }
    data['remain_time'] = remainTime;
    data['is_appointment_time'] = isAppointmentTime;
    return data;
  }
}

class DeviceToken {
  String? token;
  int? type;

  DeviceToken({this.token, this.type});

  DeviceToken.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['token'] = token;
    data['type'] = type;
    return data;
  }
}

class PrescriptionImage {
  int? id;
  int? appointmentId;
  String? name;
  String? image;
  String? createdAt;
  String? updatedAt;

  PrescriptionImage({
    this.id,
    this.appointmentId,
    this.name,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  PrescriptionImage.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    appointmentId = json['appointment_id'];
    name = json['name'].toString();
    image = json['image'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['appointment_id'] = appointmentId;
    data['name'] = name;
    data['image'] = image;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class Doctor {
  int? id;
  String? name;
  String? email;
  String? aboutus;
  String? workingTime;
  String? address;
  double? lat;
  double? lon;
  int? phoneno;
  String? services;
  String? healthcare;
  String? image;
  int? departmentId;
  dynamic password;
  String? facebookUrl;
  String? twitterUrl;
  String? createdAt;
  String? updatedAt;
  int? isApprove;
  int? consultationFees;
  String? loginId;
  int? connectycubeUserId;
  dynamic connectycubePassword;
  int? avgratting;
  Departmentls? departmentls;

  Doctor({
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
    this.departmentId,
    this.password,
    this.facebookUrl,
    this.twitterUrl,
    this.createdAt,
    this.updatedAt,
    this.isApprove,
    this.consultationFees,
    this.loginId,
    this.connectycubeUserId,
    this.connectycubePassword,
    this.avgratting,
    this.departmentls,
  });

  Doctor.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    aboutus = json['aboutus'];
    workingTime = json['working_time'];
    address = json['address'];
    lat = json['lat'];
    lon = json['lon'];
    phoneno = json['phoneno'];
    services = json['services'];
    healthcare = json['healthcare'];
    image = json['image'];
    departmentId = json['department_id'];
    password = json['password'];
    facebookUrl = json['facebook_url'];
    twitterUrl = json['twitter_url'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    isApprove = json['is_approve'];
    consultationFees = json['consultation_fees'];
    loginId = json['login_id'];
    connectycubeUserId = json['connectycube_user_id'];
    connectycubePassword = json['connectycube_password'];
    avgratting = json['avgratting'];
    departmentls = json['departmentls'] != null
        ? Departmentls.fromJson(json['departmentls'])
        : null;
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
    data['department_id'] = departmentId;
    data['password'] = password;
    data['facebook_url'] = facebookUrl;
    data['twitter_url'] = twitterUrl;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['is_approve'] = isApprove;
    data['consultation_fees'] = consultationFees;
    data['login_id'] = loginId;
    data['connectycube_user_id'] = connectycubeUserId;
    data['connectycube_password'] = connectycubePassword;
    data['avgratting'] = avgratting;
    if (departmentls != null) {
      data['departmentls'] = departmentls!.toJson();
    }
    return data;
  }
}

class Departmentls {
  int? id;
  String? icon;
  String? name;
  String? createdAt;
  String? updatedAt;
  int? isActive;

  Departmentls({
    this.id,
    this.icon,
    this.name,
    this.createdAt,
    this.updatedAt,
    this.isActive,
  });

  Departmentls.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    icon = json['icon'];
    name = json['name'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    isActive = json['is_active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['icon'] = icon;
    data['name'] = name;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['is_active'] = isActive;
    return data;
  }
}

import 'package:videocalling/shared/models/speciality/speciality_model.dart';

class DoctorDetailsClass {
  String? success;
  String? register;
  DoctorDData? data;

  DoctorDetailsClass({this.success, this.register, this.data});

  DoctorDetailsClass.fromJson(Map<String, dynamic> json) {
    success = json['success']?.toString();
    register = json['register'];
    data = json['data'] != null ? DoctorDData.fromJson(json['data']) : null;
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

class DoctorDData {
  int? id;
  String? name;
  String? email;
  dynamic aboutus;
  String? address;
  String? lat;
  String? lon;
  String? phoneno;
  dynamic services;
  dynamic healthcare;
  String? image;
  int? departmentId;
  String? workingTime;
  String? password;
  dynamic facebookUrl;
  dynamic twitterUrl;
  String? createdAt;
  String? updatedAt;
  String? departmentName; // specialization
  double? avgratting;
  int? totalReview;
  String? consultationFee; // booking_price
  List<Speciality>? specializations;

  // New fields from Supabase doctors table
  String? age;
  String? gender;
  int? yearsOfExp;
  int? numbPatients;
  String? fcmToken;
  int? nbSessions;
  double? sessionFee;
  int? avgSessionTime; // in minutes

  DoctorDData({
    this.id,
    this.name,
    this.email,
    this.aboutus,
    this.address,
    this.lat,
    this.lon,
    this.phoneno,
    this.services,
    this.healthcare,
    this.image,
    this.departmentId,
    this.workingTime,
    this.password,
    this.facebookUrl,
    this.twitterUrl,
    this.createdAt,
    this.updatedAt,
    this.departmentName,
    this.specializations,
    this.avgratting,
    this.totalReview,
    this.consultationFee,
    this.age,
    this.gender,
    this.yearsOfExp,
    this.numbPatients,
    this.fcmToken,
    this.nbSessions,
    this.sessionFee,
    this.avgSessionTime,
  });

  DoctorDData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    aboutus = json['aboutus'];
    address = json['address'];
    lat = json['lat']?.toString();
    lon = json['lon']?.toString();
    phoneno = json['phoneno']?.toString();
    services = json['services'];
    healthcare = json['healthcare'];
    image = json['image'];
    departmentId = json['department_id'] is String ? 0 : json['department_id'];
    workingTime = json['working_time']?.toString();
    password = json['password']?.toString();
    facebookUrl = json['facebook_url'];
    twitterUrl = json['twitter_url'];
    nbSessions = json['numb_session'] is int
        ? json['numb_session']
        : int.tryParse(json['numb_session']?.toString() ?? '0');
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    departmentName = json['department_name'];
    if (json['specializations'] != null) {
      specializations = <Speciality>[];
      for (final v in (json['specializations'] as List)) {
        specializations!.add(Speciality.fromJson(v));
      }
    }
    avgratting = json['avgratting'] != null
        ? double.tryParse(json['avgratting'].toString()) ?? 0
        : 0;
    // Map total reviews from total_reviews (DB), total_review, or number_review
    if (json.containsKey('total_reviews')) {
      totalReview = json['total_reviews'] is int
          ? json['total_reviews']
          : int.tryParse(json['total_reviews']?.toString() ?? '0');
    } else if (json.containsKey('total_review')) {
      totalReview = json['total_review'] is int
          ? json['total_review']
          : int.tryParse(json['total_review']?.toString() ?? '0');
    } else if (json.containsKey('number_review')) {
      totalReview = json['number_review'] is int
          ? json['number_review']
          : int.tryParse(json['number_review']?.toString() ?? '0');
    } else {
      totalReview = 0;
    }
    consultationFee = json['consultation_fees']?.toString();

    // Map new fields if present
    age = json['age']?.toString();
    gender = json['gender'];
    yearsOfExp = json['years_of_exp'] is int
        ? json['years_of_exp']
        : int.tryParse(json['years_of_exp']?.toString() ?? '0');
    numbPatients = json['numb_patients'] is int
        ? json['numb_patients']
        : int.tryParse(json['numb_patients']?.toString() ?? '0');
    fcmToken = json['fcm_token'];
    sessionFee = json['session_fee'] != null
        ? double.tryParse(json['session_fee'].toString()) ?? 0
        : 0;
    avgSessionTime = json['avg_session_time'] is int
        ? json['avg_session_time']
        : int.tryParse(json['avg_session_time']?.toString() ?? '30');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['aboutus'] = aboutus;
    data['address'] = address;
    data['lat'] = lat;
    data['lon'] = lon;
    data['phoneno'] = phoneno;
    data['services'] = services;
    data['healthcare'] = healthcare;
    data['image'] = image;
    data['working_time'] = workingTime;
    data['password'] = password;
    data['facebook_url'] = facebookUrl;
    data['twitter_url'] = twitterUrl;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['department_name'] = departmentName;
    data['avgratting'] = avgratting;
    data['total_review'] = totalReview;
    data['consultation_fees'] = consultationFee;
    // New
    data['age'] = age;
    data['gender'] = gender;
    data['years_of_exp'] = yearsOfExp;
    data['numb_patients'] = numbPatients;
    data['numb_session'] = nbSessions;
    data['booking_price'] = sessionFee;
    data['fcm_token'] = fcmToken;
    data['avg_session_time'] = avgSessionTime;
    return data;
  }
}

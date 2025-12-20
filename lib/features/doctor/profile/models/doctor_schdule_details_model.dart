import 'package:videocalling/features/doctor/profile/models/doctor_slot_details_model.dart';

class DoctorScheduleDetails {
  String? success;
  String? register;
  List<DSData>? data;

  DoctorScheduleDetails({this.success, this.register, this.data});

  DoctorScheduleDetails.fromJson(Map<String, dynamic> json) {
    success = json['success'].toString();
    register = json['register'];
    if (json['data'] != null) {
      data = <DSData>[];
      json['data'].forEach((v) {
        data!.add(DSData.fromJson(v));
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

class DSData {
  int? id;
  int? doctorId;
  int? dayId;
  String? startTime;
  String? endTime;
  String? duration;
  String? createdAt;
  String? updatedAt;
  List<Getslotls>? getslotls;

  DSData({
    this.id,
    this.doctorId,
    this.dayId,
    this.startTime,
    this.endTime,
    this.duration,
    this.createdAt,
    this.updatedAt,
    this.getslotls,
  });

  DSData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    doctorId = json['doctor_id'];
    dayId = json['day_id'];
    startTime = json['start_time'].toString();
    endTime = json['end_time'].toString();
    duration = json['duration'].toString();
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    if (json['getslotls'] != null) {
      getslotls = <Getslotls>[];
      json['getslotls'].forEach((v) {
        getslotls!.add(Getslotls.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['doctor_id'] = doctorId;
    data['day_id'] = dayId;
    data['start_time'] = startTime;
    data['end_time'] = endTime;
    data['duration'] = duration;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (getslotls != null) {
      data['getslotls'] = getslotls!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

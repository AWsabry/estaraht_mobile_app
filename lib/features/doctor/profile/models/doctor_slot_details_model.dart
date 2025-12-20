class DoctorSlotsDetails {
  String? success;
  String? register;
  List<SlotsData>? data;

  DoctorSlotsDetails({this.success, this.register, this.data});

  DoctorSlotsDetails.fromJson(Map<String, dynamic> json) {
    success = json['success'].toString();
    register = json['register'];
    if (json['data'] != null) {
      data = <SlotsData>[];
      json['data'].forEach((v) {
        data!.add(SlotsData.fromJson(v));
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

class SlotsData {
  int? id;
  int? doctorId;
  int? dayId;
  String? startTime;
  String? endTime;
  String? duration;
  String? createdAt;
  String? updatedAt;
  List<Getslotls>? getslotls;

  SlotsData({
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

  SlotsData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    doctorId = int.parse(json['doctor_id'].toString());
    dayId = int.parse(json['day_id'].toString());
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

class Getslotls {
  int? id;
  int? scheduleId;
  String? slot;
  String? createdAt;
  String? updatedAt;

  Getslotls({
    this.id,
    this.scheduleId,
    this.slot,
    this.createdAt,
    this.updatedAt,
  });

  Getslotls.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    scheduleId = int.parse(json['schedule_id'].toString());
    slot = json['slot'].toString();
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['schedule_id'] = scheduleId;
    data['slot'] = slot;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

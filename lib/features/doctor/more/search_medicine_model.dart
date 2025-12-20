class SearchAddMedicineModel {
  int? status;
  String? msg;
  List<MedicineData>? data;

  SearchAddMedicineModel({this.status, this.msg, this.data});

  SearchAddMedicineModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    msg = json['msg'];
    if (json['data'] != null) {
      data = <MedicineData>[];
      json['data'].forEach((v) {
        data!.add(MedicineData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['msg'] = msg;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MedicineData {
  int? id;
  String? name;
  dynamic dosage;
  String? medicineType;
  String? description;

  MedicineData({
    this.id,
    this.name,
    this.dosage,
    this.medicineType,
    this.description,
  });

  MedicineData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    dosage = json['dosage'];
    medicineType = json['medicine_type'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['dosage'] = dosage;
    data['medicine_type'] = medicineType;
    data['description'] = description;
    return data;
  }
}

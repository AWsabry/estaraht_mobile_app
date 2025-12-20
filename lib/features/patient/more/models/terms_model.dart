class TermsData {
  int? status;
  String? msg;
  TData? data;

  TermsData({this.status, this.msg, this.data});

  TermsData.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    msg = json['msg'];
    data = json['data'] != null ? TData.fromJson(json['data']) : null;
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

class TData {
  int? id;
  String? about;
  String? trems;
  String? privacy;
  String? dataDeletion;
  String? createdAt;
  String? updatedAt;

  TData(
      {this.id,
      this.about,
      this.trems,
      this.privacy,
      this.dataDeletion,
      this.createdAt,
      this.updatedAt});

  TData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    about = json['about'];
    trems = json['trems'];
    privacy = json['privacy'];
    dataDeletion = json['data_deletion'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['about'] = about;
    data['trems'] = trems;
    data['privacy'] = privacy;
    data['data_deletion'] = dataDeletion;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

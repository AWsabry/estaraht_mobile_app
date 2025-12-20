class GetMedicineMOdel {
  dynamic status;
  String? msg;

  GetMedicineMOdel({this.status, this.msg});

  GetMedicineMOdel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['msg'] = msg;
    return data;
  }
}

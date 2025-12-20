class UserLoginResponse {
  int? success;
  URegister? register;
  Headers? headers;

  UserLoginResponse({this.success, this.register, this.headers});

  UserLoginResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    register = json['register'] != null
        ? URegister.fromJson(json['register'])
        : null;
    headers = json['headers'] != null
        ? Headers.fromJson(json['headers'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (register != null) {
      data['register'] = register!.toJson();
    }
    if (headers != null) {
      data['headers'] = headers!.toJson();
    }
    return data;
  }
}

class URegister {
  int? userId;
  String? name;
  int? phone;
  String? email;
  String? profilePic;
  String? loginId;

  URegister({
    this.userId,
    this.name,
    this.phone,
    this.email,
    this.profilePic,
    this.loginId,
  });

  URegister.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    name = json['name'];
    phone = json['phone'];
    email = json['email'];
    profilePic = json['profile_pic'];
    loginId = json['login_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['name'] = name;
    data['phone'] = phone;
    data['email'] = email;
    data['profile_pic'] = profilePic;
    data['login_id'] = loginId;
    return data;
  }
}

class Headers {
  String? accessControlAllowOrigin;

  Headers({this.accessControlAllowOrigin});

  Headers.fromJson(Map<String, dynamic> json) {
    accessControlAllowOrigin = json['Access-Control-Allow-Origin'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Access-Control-Allow-Origin'] = accessControlAllowOrigin;
    return data;
  }
}

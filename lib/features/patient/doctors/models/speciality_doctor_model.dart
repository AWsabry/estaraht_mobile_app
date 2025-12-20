class SpecialityDoctorsClass {
  String? success;
  String? register;
  DData? data;

  SpecialityDoctorsClass({this.success, this.register, this.data});

  SpecialityDoctorsClass.fromJson(Map<String, dynamic> json) {
    success = json['success'].toString();
    register = json['register'];
    data = json['data'] != null ? DData.fromJson(json['data']) : null;
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

class DData {
  int? currentPage;
  List<DoctorData>? doctorData;
  String? firstPageUrl;
  int? from;
  int? lastPage;
  String? lastPageUrl;
  List<Links>? links;
  String? nextPageUrl;
  String? path;
  int? perPage;
  String? prevPageUrl;
  int? to;
  int? total;

  DData(
      {this.currentPage,
      this.doctorData,
      this.firstPageUrl,
      this.from,
      this.lastPage,
      this.lastPageUrl,
      this.links,
      this.nextPageUrl,
      this.path,
      this.perPage,
      this.prevPageUrl,
      this.to,
      this.total});

  DData.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    if (json['data'] != null) {
      doctorData = <DoctorData>[];
      json['data'].forEach((v) {
        doctorData!.add(DoctorData.fromJson(v));
      });
    }
    firstPageUrl = json['first_page_url'];
    from = json['from'];
    lastPage = json['last_page'];
    lastPageUrl = json['last_page_url'];
    if (json['links'] != null) {
      links = <Links>[];
      json['links'].forEach((v) {
        links!.add(Links.fromJson(v));
      });
    }
    nextPageUrl = json['next_page_url'].toString();
    path = json['path'];
    perPage = json['per_page'];
    prevPageUrl = json['prev_page_url'].toString();
    to = json['to'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['current_page'] = currentPage;
    if (doctorData != null) {
      data['data'] = doctorData!.map((v) => v.toJson()).toList();
    }
    data['first_page_url'] = firstPageUrl;
    data['from'] = from;
    data['last_page'] = lastPage;
    data['last_page_url'] = lastPageUrl;
    if (links != null) {
      data['links'] = links!.map((v) => v.toJson()).toList();
    }
    data['next_page_url'] = nextPageUrl;
    data['path'] = path;
    data['per_page'] = perPage;
    data['prev_page_url'] = prevPageUrl;
    data['to'] = to;
    data['total'] = total;
    return data;
  }
}

class DoctorData {
  String? name;
  int? id;
  String? image;
  int? departmentId;
  String? email;
  String? phoneno;
  String? address;
  String? departmentName;
  String? gender;

  DoctorData(
      {this.name,
      this.id,
      this.image,
      this.departmentId,
      this.email,
      this.phoneno,
      this.address,
      this.departmentName,
      this.gender});

  DoctorData.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    id = json['id'];
    image = json['image'];
    departmentId = json['department_id'];
    email = json['email'];
    phoneno = json['phoneno'].toString();
    address = json['address'];
    departmentName = json['department_name'];
    gender = json['gender'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['id'] = id;
    data['image'] = image;
    data['department_id'] = departmentId;
    data['email'] = email;
    data['phoneno'] = phoneno;
    data['address'] = address;
    data['department_name'] = departmentName;
    data['gender'] = gender;
    return data;
  }
}

class Links {
  String? url;
  String? label;
  bool? active;

  Links({this.url, this.label, this.active});

  Links.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    label = json['label'].toString();
    active = json['active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    data['label'] = label;
    data['active'] = active;
    return data;
  }
}

class UserAppointmentsClass {
  String? success;
  String? register;
  AData? data;

  UserAppointmentsClass({this.success, this.register, this.data});

  UserAppointmentsClass.fromJson(Map<String, dynamic> json) {
    success = json['success'].toString();
    register = json['register'];
    data = json['data'] != null ? AData.fromJson(json['data']) : null;
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

class AData {
  int? currentPage;
  List<AppointmentData>? appointmentData;
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

  AData(
      {this.currentPage,
        this.appointmentData,
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

  AData.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    if (json['data'] != null) {
      appointmentData = <AppointmentData>[];
      json['data'].forEach((v) {
        appointmentData!.add(AppointmentData.fromJson(v));
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
    if (appointmentData != null) {
      data['data'] =
          appointmentData!.map((v) => v.toJson()).toList();
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

class AppointmentData {
  String? id;
  String? date;
  String? slot;
  String? phone;
  String? name;
  String? address;
  String? image;
  String? departmentName;
  String? status;

  AppointmentData(
      {this.id,
        this.date,
        this.slot,
        this.phone,
        this.name,
        this.address,
        this.image,
        this.departmentName,
        this.status});

  AppointmentData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    date = json['date'];
    slot = json['slot'];
    phone = json['phone'].toString();
    name = json['name'];
    address = json['address'];
    image = json['image'];
    departmentName = json['department_name'];
    status = json['status'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['date'] = date;
    data['slot'] = slot;
    data['phone'] = phone;
    data['name'] = name;
    data['address'] = address;
    data['image'] = image;
    data['department_name'] = departmentName;
    data['status'] = status;
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

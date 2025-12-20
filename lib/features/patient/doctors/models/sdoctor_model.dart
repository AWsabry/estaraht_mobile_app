class SearchDoctorClass {
  int? status;
  String? msg;
  SDData? data;

  SearchDoctorClass({this.status, this.msg, this.data});

  SearchDoctorClass.fromJson(Map<String, dynamic> json) {
    status = int.parse(json['status'].toString());
    msg = json['msg'];
    data = json['data'] != null ? SDData.fromJson(json['data']) : null;
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

class SDData {
  int? currentPage;
  List<SDoctorData>? doctorData;
  String? firstPageUrl;
  int? from;
  int? lastPage;
  String? lastPageUrl;
  List<SDLinks>? links;
  String? nextPageUrl;
  String? path;
  int? perPage;
  String? prevPageUrl;
  int? to;
  int? total;

  SDData({
    this.currentPage,
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
    this.total,
  });

  SDData.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    if (json['data'] != null) {
      doctorData = <SDoctorData>[];
      json['data'].forEach((v) {
        doctorData!.add(SDoctorData.fromJson(v));
      });
    }
    firstPageUrl = json['first_page_url'];
    from = json['from'];
    lastPage = json['last_page'];
    lastPageUrl = json['last_page_url'];
    if (json['links'] != null) {
      links = <SDLinks>[];
      json['links'].forEach((v) {
        links!.add(SDLinks.fromJson(v));
      });
    }
    nextPageUrl = json['next_page_url'] ?? "null";
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

class SDoctorData {
  String? id;
  String? doctorId;
  String? name;
  String? fullName;
  String? email;
  String? phoneNumber;
  int? age;
  String? gender;
  String? address;
  String? bio;
  String? image;
  String? profileImgUrl;
  int? departmentId;
  String? departmentName;
  String? specialization;
  int? yearsOfExp;
  int? numbPatients;
  double? bookingPrice;

  SDoctorData({
    this.id,
    this.doctorId,
    this.name,
    this.fullName,
    this.email,
    this.phoneNumber,
    this.age,
    this.gender,
    this.address,
    this.bio,
    this.image,
    this.profileImgUrl,
    this.departmentId,
    this.departmentName,
    this.specialization,
    this.yearsOfExp,
    this.numbPatients,
    this.bookingPrice,
  });

  SDoctorData.fromJson(Map<String, dynamic> json) {
    // Support both old API and new Supabase format
    // Use doctor_id as primary ID, fallback to id for old API
    doctorId = json['doctor_id']?.toString();
    id = json['id']?.toString() ?? doctorId;

    // Name can come from either 'name' or 'full_name'
    name = json['name'] ?? json['full_name'];
    fullName = json['full_name'] ?? json['name'];

    email = json['email'];
    phoneNumber = json['phone_number'];
    age = json['age'] is int
        ? json['age']
        : int.tryParse(json['age']?.toString() ?? '0');
    gender = json['gender'];

    // Address can come from either 'address' or 'bio'
    address = json['address'] ?? json['bio'];
    bio = json['bio'] ?? json['address'];

    // Image can come from either 'image' or 'profile_img_url'
    image = json['image'] ?? json['profile_img_url'];
    profileImgUrl = json['profile_img_url'] ?? json['image'];

    departmentId = json['department_id'] is String ? 0 : json['department_id'];
    departmentName = json['department_name'] ?? json['specialization'];
    specialization = json['specialization'] ?? json['department_name'];

    yearsOfExp = json['years_of_exp'] is int
        ? json['years_of_exp']
        : int.tryParse(json['years_of_exp']?.toString() ?? '0');
    numbPatients = json['numb_patients'] is int
        ? json['numb_patients']
        : int.tryParse(json['numb_patients']?.toString() ?? '0');
    bookingPrice = json['booking_price'] is double
        ? json['booking_price']
        : double.tryParse(json['booking_price']?.toString() ?? '0');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['doctor_id'] = doctorId;
    data['name'] = name;
    data['full_name'] = fullName;
    data['email'] = email;
    data['phone_number'] = phoneNumber;
    data['age'] = age;
    data['gender'] = gender;
    data['address'] = address;
    data['bio'] = bio;
    data['image'] = image;
    data['profile_img_url'] = profileImgUrl;
    data['department_id'] = departmentId;
    data['department_name'] = departmentName;
    data['specialization'] = specialization;
    data['years_of_exp'] = yearsOfExp;
    data['numb_patients'] = numbPatients;
    data['booking_price'] = bookingPrice;
    return data;
  }
}

class SDLinks {
  String? url;
  String? label;
  bool? active;

  SDLinks({this.url, this.label, this.active});

  SDLinks.fromJson(Map<String, dynamic> json) {
    url = json['url'] ?? "";
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

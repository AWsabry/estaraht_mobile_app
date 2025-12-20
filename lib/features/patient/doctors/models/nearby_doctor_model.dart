class NearbyDoctorsClass {
  int? status;
  String? msg;
  NDData? data;

  NearbyDoctorsClass({this.status, this.msg, this.data});

  NearbyDoctorsClass.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    msg = json['msg'];
    data = json['data'] != null ? NDData.fromJson(json['data']) : null;
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

class NDData {
  int? currentPage;
  List<NearbyData>? nearbyData;
  String? firstPageUrl;
  int? from;
  int? lastPage;
  String? lastPageUrl;
  List<NDLinks>? links;
  String? nextPageUrl;
  String? path;
  int? perPage;
  String? prevPageUrl;
  int? to;
  int? total;

  NDData({
    this.currentPage,
    this.nearbyData,
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

  NDData.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    if (json['data'] != null) {
      nearbyData = <NearbyData>[];
      json['data'].forEach((v) {
        nearbyData!.add(NearbyData.fromJson(v));
      });
    }
    firstPageUrl = json['first_page_url'];
    from = json['from'];
    lastPage = json['last_page'];
    lastPageUrl = json['last_page_url'];
    if (json['links'] != null) {
      links = <NDLinks>[];
      json['links'].forEach((v) {
        links!.add(NDLinks.fromJson(v));
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
    if (nearbyData != null) {
      data['data'] = nearbyData!.map((v) => v.toJson()).toList();
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

class NearbyData {
  int? id;
  String? name;
  String? address;
  String? image;
  double? distance;
  String? departmentName;
  String? gender;

  NearbyData({
    this.id,
    this.name,
    this.address,
    this.image,
    this.distance,
    this.departmentName,
    this.gender,
  });

  NearbyData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    address = json['address'];
    image = json['image'];
    //distance = double.parse(json['distance'].toString()) ?? 0.0;
    departmentName = json['department_name'];
    gender = json['gender'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['address'] = address;
    data['image'] = image;
    data['distance'] = distance;
    data['department_name'] = departmentName;
    data['gender'] = gender;
    return data;
  }
}

class NDLinks {
  String? url;
  String? label;
  bool? active;

  NDLinks({this.url, this.label, this.active});

  NDLinks.fromJson(Map<String, dynamic> json) {
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

class DoctorPastAppointmentsClass {
  String? success;
  String? register;
  DAData? data;

  DoctorPastAppointmentsClass({this.success, this.register, this.data});

  DoctorPastAppointmentsClass.fromJson(Map<String, dynamic> json) {
    success = json['success'].toString();
    register = json['register'];
    data = json['data'] != null ? DAData.fromJson(json['data']) : null;
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

class DAData {
  int? currentPage;
  List<DoctorAppointmentData>? doctorAppointmentData;
  String? firstPageUrl;
  int? from;
  int? lastPage;
  String? lastPageUrl;
  List<DALinks>? links;
  String? nextPageUrl;
  String? path;
  int? perPage;
  String? prevPageUrl;
  int? to;
  int? total;

  DAData({
    this.currentPage,
    this.doctorAppointmentData,
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

  DAData.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    if (json['data'] != null) {
      doctorAppointmentData = <DoctorAppointmentData>[];
      json['data'].forEach((v) {
        doctorAppointmentData!.add(DoctorAppointmentData.fromJson(v));
      });
    }
    firstPageUrl = json['first_page_url'];
    from = json['from'];
    lastPage = json['last_page'];
    lastPageUrl = json['last_page_url'];
    if (json['links'] != null) {
      links = <DALinks>[];
      json['links'].forEach((v) {
        links!.add(DALinks.fromJson(v));
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
    if (doctorAppointmentData != null) {
      data['data'] = doctorAppointmentData!.map((v) => v.toJson()).toList();
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

class DoctorAppointmentData {
  String? id;
  String? patientId;
  String? doctorId;
  String? availabilityId;
  String? status;
  double? price;
  String? paymentIntentId;
  String? videoSessionId;
  String? createdAt;
  String? bookingDate;
  String? bookingTime;
  String? name;
  String? image;

  DoctorAppointmentData({
    this.id,
    this.patientId,
    this.doctorId,
    this.availabilityId,
    this.status,
    this.price,
    this.paymentIntentId,
    this.videoSessionId,
    this.createdAt,
    this.bookingDate,
    this.bookingTime,
    this.name,
    this.image,
  });

  DoctorAppointmentData.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    patientId = json['patient_id']?.toString();
    doctorId = json['doctor_id']?.toString();
    availabilityId = json['availability_id']?.toString();
    status = json['status']?.toString();
    price = json['price'] != null
        ? double.tryParse(json['price'].toString())
        : null;
    paymentIntentId = json['payment_intent_id']?.toString();
    videoSessionId = json['video_session_id']?.toString();
    createdAt = json['created_at']?.toString();
    bookingDate = json['booking_date']?.toString();
    bookingTime = json['booking_time']?.toString();
    name = json['patients']?['name'];
    image = json['patients']?['profile_img_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['patient_id'] = patientId;
    data['doctor_id'] = doctorId;
    data['availability_id'] = availabilityId;
    data['status'] = status;
    data['price'] = price;
    data['payment_intent_id'] = paymentIntentId;
    data['video_session_id'] = videoSessionId;
    data['created_at'] = createdAt;
    data['booking_date'] = bookingDate;
    data['booking_time'] = bookingTime;
    data['name'] = name;
    data['image'] = image;
    return data;
  }

  @override
  String toString() {
    return 'AppointmentData(id: $id, patientId: $patientId, doctorId: $doctorId, availabilityId: $availabilityId, status: $status, price: $price, paymentIntentId: $paymentIntentId, videoSessionId: $videoSessionId, createdAt: $createdAt, bookingDate: $bookingDate, bookingTime: $bookingTime, name: $name, image: $image)';
  }
}

class DALinks {
  String? url;
  String? label;
  bool? active;

  DALinks({this.url, this.label, this.active});

  DALinks.fromJson(Map<String, dynamic> json) {
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

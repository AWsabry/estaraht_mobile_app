class DoctorModel {
  String? doctorId;
  String? fullName;
  String? email;
  String? phoneNumber;
  int? age;
  String? gender;
  String? specialization;
  String? bio;
  int? yearsOfExp;
  int? numbPatients;
  String? profileImgUrl;
  double? bookingPrice;
  String? fcmToken;
  double? avgRating;
  int? numbSession;
  int? numberReview;
  String? updatedAt;

  DoctorModel({
    this.doctorId,
    this.fullName,
    this.email,
    this.phoneNumber,
    this.age,
    this.gender,
    this.specialization,
    this.bio,
    this.yearsOfExp,
    this.numbPatients,
    this.profileImgUrl,
    this.bookingPrice,
    this.fcmToken,
    this.avgRating,
    this.numbSession,
    this.numberReview,
    this.updatedAt,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      doctorId: json['doctor_id']?.toString(),
      fullName: json['full_name']?.toString(),
      email: json['email']?.toString(),
      phoneNumber: json['phone_number']?.toString(),
      age: json['age'] is int
          ? json['age']
          : int.tryParse(json['age']?.toString() ?? '0'),
      gender: json['gender']?.toString(),
      specialization: json['specialization']?.toString(),
      bio: json['bio']?.toString(),
      yearsOfExp: json['years_of_exp'] is int
          ? json['years_of_exp']
          : int.tryParse(json['years_of_exp']?.toString() ?? '0'),
      numbPatients: json['numb_patients'] is int
          ? json['numb_patients']
          : int.tryParse(json['numb_patients']?.toString() ?? '0'),
      profileImgUrl: json['profile_img_url']?.toString(),
      bookingPrice: json['booking_price'] is double
          ? json['booking_price']
          : double.tryParse(json['booking_price']?.toString() ?? '0'),
      fcmToken: json['fcm_token']?.toString(),
      avgRating: (json['average_rating'] ?? json['avg_rating']) is double
          ? (json['average_rating'] ?? json['avg_rating'])
          : double.tryParse((json['average_rating'] ?? json['avg_rating'])?.toString() ?? '0'),
      numbSession: json['numb_session'] is int
          ? json['numb_session']
          : int.tryParse(json['numb_session']?.toString() ?? '0'),
      numberReview: (json['total_reviews'] ?? json['number_review']) is int
          ? (json['total_reviews'] ?? json['number_review'])
          : int.tryParse((json['total_reviews'] ?? json['number_review'])?.toString() ?? '0'),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'doctor_id': doctorId,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'age': age,
      'gender': gender,
      'specialization': specialization,
      'bio': bio,
      'years_of_exp': yearsOfExp,
      'numb_patients': numbPatients,
      'profile_img_url': profileImgUrl,
      'booking_price': bookingPrice,
      'fcm_token': fcmToken,
      'avg_rating': avgRating,
      'numb_session': numbSession,
      'number_review': numberReview,
      'updated_at': updatedAt,
    };
  }

  @override
  toString() {
    return 'DoctorModel(doctorId: $doctorId, fullName: $fullName, email: $email, phoneNumber: $phoneNumber, age: $age, gender: $gender, specialization: $specialization, bio: $bio, yearsOfExp: $yearsOfExp, numbPatients: $numbPatients, profileImgUrl: $profileImgUrl, bookingPrice: $bookingPrice, fcmToken: $fcmToken, avgRating: $avgRating, numbSession: $numbSession, numberReview: $numberReview, updatedAt: $updatedAt, )';
  }

  // Helper getters for backward compatibility with NearbyData
  int? get id => doctorId != null ? int.tryParse(doctorId!) : null;
  String? get name => fullName;
  String? get image => profileImgUrl;
  String? get departmentName => specialization;
}

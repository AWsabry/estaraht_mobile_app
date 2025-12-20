class ReviewModel {
  final String? id;
  final String? bookingId;
  final String? patientId;
  final String? doctorId;
  final String? rating;
  final String? comment;
  final String? createdAt;
  final String? patientName;
  final String? patientImage;

  ReviewModel({
    this.id,
    this.bookingId,
    this.patientId,
    this.doctorId,
    this.rating,
    this.comment,
    this.createdAt,
    this.patientName,
    this.patientImage,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id']?.toString(),
      bookingId: json['booking_id']?.toString(),
      patientId: json['patient_id']?.toString(),
      doctorId: json['doctor_id']?.toString(),
      rating: json['rating']?.toString(),
      comment: json['comment']?.toString(),
      createdAt: json['created_at']?.toString(),
      patientName: json['patient_name']?.toString(),
      patientImage: json['patient_image']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'patient_id': patientId,
      'doctor_id': doctorId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt,
      'patient_name': patientName,
      'patient_image': patientImage,
    };
  }

  double get ratingValue {
    return double.tryParse(rating ?? '0') ?? 0.0;
  }

  DateTime? get createdAtDate {
    if (createdAt == null) return null;
    try {
      return DateTime.parse(createdAt!);
    } catch (e) {
      return null;
    }
  }

  String get formattedDate {
    final date = createdAtDate;
    if (date == null) return '';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else {
      return '${(difference.inDays / 365).floor()} years ago';
    }
  }
}


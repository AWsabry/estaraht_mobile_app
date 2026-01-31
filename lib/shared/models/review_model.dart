import 'package:videocalling/shared/services/others/timezone_service.dart';

class ReviewModel {
  final String? id;
  final String bookingId;
  final String patientId;
  final String doctorId;
  final int rating;
  final String? comment;
  final DateTime? createdAt;
  final String? patientName;
  final String? patientImage;

  ReviewModel({
    this.id,
    required this.bookingId,
    required this.patientId,
    required this.doctorId,
    required this.rating,
    this.comment,
    this.createdAt,
    this.patientName,
    this.patientImage,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id']?.toString(),
      bookingId: json['booking_id']?.toString() ?? '',
      patientId: json['patient_id']?.toString() ?? '',
      doctorId: json['doctor_id']?.toString() ?? '',
      rating: int.tryParse(json['rating']?.toString() ?? '0') ?? 0,
      comment: json['comment']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
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
      'created_at': createdAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'booking_id': bookingId,
      'patient_id': patientId,
      'doctor_id': doctorId,
      'rating': rating,
      'comment': comment,
    };
  }

  String get formattedDate {
    if (createdAt == null) return '';
    return '${createdAt!.day}/${createdAt!.month}/${createdAt!.year}';
  }

  String get timeAgo {
    if (createdAt == null) return '';

    final now = TimezoneService.getCurrentMauritaniaTime();
    final difference = now.difference(createdAt!);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year(s) ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month(s) ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day(s) ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour(s) ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute(s) ago';
    } else {
      return 'Just now';
    }
  }
}

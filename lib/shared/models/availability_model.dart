class AvailabilityModel {
  final String id;
  final String doctorId;
  final int dayNumber;
  final List<String> timeSlots;
  final bool isAvailable;
  final DateTime? createdAt;

  AvailabilityModel({
    required this.id,
    required this.doctorId,
    required this.dayNumber,
    required this.timeSlots,
    required this.isAvailable,
    this.createdAt,
  });

  factory AvailabilityModel.fromJson(Map<String, dynamic> json) {
    return AvailabilityModel(
      id: json['id'] ?? '',
      doctorId: json['doctor_id'] ?? '',
      dayNumber: json['day_number'] ?? 0,
      timeSlots: json['time_slots'] != null
          ? List<String>.from(json['time_slots'])
          : [],
      isAvailable: json['is_available'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctor_id': doctorId,
      'day_number': dayNumber,
      'time_slots': timeSlots,
      'is_available': isAvailable,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  @override
  toString() {
    return 'AvailabilityModel(id: $id, doctorId: $doctorId, dayNumber: $dayNumber, timeSlots: $timeSlots, isAvailable: $isAvailable, createdAt: $createdAt)';
  }

  // Helper method to get day name
  String getDayName() {
    const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    if (dayNumber >= 0 && dayNumber < days.length) {
      return days[dayNumber];
    }
    return 'Unknown';
  }
}


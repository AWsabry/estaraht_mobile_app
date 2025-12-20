class AvailabilityModel {
  final String? id;
  final String doctorId;
  final int dayNumber;
  final List<String> timeSlots;
  final bool isAvailable;
  final String? createdAt;

  AvailabilityModel({
    this.id,
    required this.doctorId,
    required this.dayNumber,
    required this.timeSlots,
    this.isAvailable = true,
    this.createdAt,
  });

  factory AvailabilityModel.fromJson(Map<String, dynamic> json) {
    return AvailabilityModel(
      id: json['id']?.toString(),
      doctorId: json['doctor_id']?.toString() ?? '',
      dayNumber: json['day_number'] ?? 0,
      timeSlots: json['time_slots'] != null
          ? List<String>.from(json['time_slots'])
          : [],
      isAvailable: json['is_available'] ?? true,
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'doctor_id': doctorId,
      'day_number': dayNumber,
      'time_slots': timeSlots,
      'is_available': isAvailable,
      if (createdAt != null) 'created_at': createdAt,
    };
  }

  AvailabilityModel copyWith({
    String? id,
    String? doctorId,
    int? dayNumber,
    List<String>? timeSlots,
    bool? isAvailable,
    String? createdAt,
  }) {
    return AvailabilityModel(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      dayNumber: dayNumber ?? this.dayNumber,
      timeSlots: timeSlots ?? this.timeSlots,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}


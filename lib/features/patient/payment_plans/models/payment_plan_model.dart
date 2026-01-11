class PaymentPlansResponse {
  final bool success;
  final List<PaymentPlan> plans;
  final String? message;

  PaymentPlansResponse({
    required this.success,
    required this.plans,
    this.message,
  });

  factory PaymentPlansResponse.fromJson(Map<String, dynamic> json) {
    return PaymentPlansResponse(
      success: true,
      plans: (json as List)
          .map((planJson) => PaymentPlan.fromJson(planJson))
          .toList(),
      message: null,
    );
  }
}

class PaymentPlan {
  final String id;
  final String planName;
  final String? planNameAr;
  final String? planNameFr;
  final String? description;
  final String? descriptionAr;
  final String? descriptionFr;
  final double price;
  final int sessions;
  final bool isFirstTimeOnly;
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  PaymentPlan({
    required this.id,
    required this.planName,
    this.planNameAr,
    this.planNameFr,
    this.description,
    this.descriptionAr,
    this.descriptionFr,
    required this.price,
    required this.sessions,
    required this.isFirstTimeOnly,
    required this.isActive,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentPlan.fromJson(Map<String, dynamic> json) {
    return PaymentPlan(
      id: json['id'] as String,
      planName: json['plan_name'] as String,
      planNameAr: json['plan_name_ar'] as String?,
      planNameFr: json['plan_name_fr'] as String?,
      description: json['description'] as String?,
      descriptionAr: json['description_ar'] as String?,
      descriptionFr: json['description_fr'] as String?,
      price: (json['price'] as num).toDouble(),
      sessions: json['sessions'] as int,
      isFirstTimeOnly: json['is_first_time_only'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      sortOrder: json['sort_order'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plan_name': planName,
      'plan_name_ar': planNameAr,
      'plan_name_fr': planNameFr,
      'description': description,
      'description_ar': descriptionAr,
      'description_fr': descriptionFr,
      'price': price,
      'sessions': sessions,
      'is_first_time_only': isFirstTimeOnly,
      'is_active': isActive,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class PatientPlanSubscription {
  final String id;
  final String patientId;
  final String planId;
  final String? paymentId;
  final int sessionsPurchased;
  final int sessionsUsed;
  final double pricePaid;
  final String? paymentGateway;
  final String paymentCurrency;
  final String paymentStatus;
  final DateTime subscribedAt;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final String status; // 'active', 'expired'

  PatientPlanSubscription({
    required this.id,
    required this.patientId,
    required this.planId,
    this.paymentId,
    required this.sessionsPurchased,
    required this.sessionsUsed,
    required this.pricePaid,
    this.paymentGateway,
    required this.paymentCurrency,
    required this.paymentStatus,
    required this.subscribedAt,
    required this.createdAt,
    this.expiresAt,
    this.status = 'active',
  });

  factory PatientPlanSubscription.fromJson(Map<String, dynamic> json) {
    return PatientPlanSubscription(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      planId: json['plan_id'] as String,
      paymentId: json['payment_id'] as String?,
      sessionsPurchased: json['sessions_purchased'] as int,
      sessionsUsed: json['sessions_used'] as int? ?? 0,
      pricePaid: (json['price_paid'] as num).toDouble(),
      paymentGateway: json['payment_gateway'] as String?,
      paymentCurrency: json['payment_currency'] as String? ?? 'USD',
      paymentStatus: json['payment_status'] as String? ?? 'completed',
      subscribedAt: DateTime.parse(json['subscribed_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      status: json['status'] as String? ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'plan_id': planId,
      'payment_id': paymentId,
      'sessions_purchased': sessionsPurchased,
      'sessions_used': sessionsUsed,
      'price_paid': pricePaid,
      'payment_gateway': paymentGateway,
      'payment_currency': paymentCurrency,
      'payment_status': paymentStatus,
      'subscribed_at': subscribedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'status': status,
    };
  }
}

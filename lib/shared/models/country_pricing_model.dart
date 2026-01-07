class CountryPricing {
  final String? id;
  final String countryCode;
  final String countryName;
  final String currency;
  final double sessionPrice;
  final DateTime? createdAt;

  CountryPricing({
    this.id,
    required this.countryCode,
    required this.countryName,
    required this.currency,
    required this.sessionPrice,
    this.createdAt,
  });

  factory CountryPricing.fromJson(Map<String, dynamic> json) {
    return CountryPricing(
      id: json['id']?.toString(),
      countryCode: json['country_code']?.toString() ?? '',
      countryName: json['country_name']?.toString() ?? '',
      currency: json['currency']?.toString() ?? 'USD',
      sessionPrice:
          double.tryParse(json['session_price']?.toString() ?? '0') ?? 0.0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'country_code': countryCode,
      'country_name': countryName,
      'currency': currency,
      'session_price': sessionPrice,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  String get formattedPrice {
    if (currency == 'MRU') {
      return '${sessionPrice.toStringAsFixed(0)} MRU';
    }
    return '\$${sessionPrice.toStringAsFixed(2)}';
  }

  String get currencySymbol {
    switch (currency) {
      case 'MRU':
        return 'MRU';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      default:
        return currency;
    }
  }

  static CountryPricing defaultPricing() {
    return CountryPricing(
      countryCode: 'default',
      countryName: 'Other',
      currency: 'USD',
      sessionPrice: 17.0,
    );
  }
}

import 'package:videocalling/core/utils/logger.dart';
import 'package:videocalling/shared/models/country_pricing_model.dart';
import 'package:videocalling/shared/services/auth/supabase_helper.dart';

class PricingService {
  static final PricingService _instance = PricingService._internal();
  factory PricingService() => _instance;
  PricingService._internal();

  final SupabaseHelper _supabaseHelper = SupabaseHelper();

  List<CountryPricing> _cachedPricing = [];
  bool _isLoaded = false;

  Future<void> loadPricing() async {
    if (_isLoaded) return;

    try {
      final response = await _supabaseHelper.client
          .from('country_pricing')
          .select()
          .order('country_name', ascending: true);

      _cachedPricing = (response as List)
          .map((json) => CountryPricing.fromJson(json))
          .toList();

      _isLoaded = true;
      loggerNoStack.i(
        'Loaded ${_cachedPricing.length} country pricing records',
      );
    } catch (e) {
      loggerNoStack.e('Error loading country pricing: $e');
      _cachedPricing = [CountryPricing.defaultPricing()];
    }
  }

  Future<List<CountryPricing>> getAllPricing() async {
    await loadPricing();
    return _cachedPricing;
  }

  Future<CountryPricing> getPricingByCountryCode(String countryCode) async {
    await loadPricing();

    final pricing = _cachedPricing.firstWhere(
      (p) => p.countryCode == countryCode,
      orElse: () => _cachedPricing.firstWhere(
        (p) => p.countryCode == 'default',
        orElse: () => CountryPricing.defaultPricing(),
      ),
    );

    return pricing;
  }

  Future<double> getSessionPrice(String countryCode) async {
    final pricing = await getPricingByCountryCode(countryCode);
    return pricing.sessionPrice;
  }

  Future<String> getCurrency(String countryCode) async {
    final pricing = await getPricingByCountryCode(countryCode);
    return pricing.currency;
  }

  Future<String> getFormattedPrice(String countryCode) async {
    final pricing = await getPricingByCountryCode(countryCode);
    return pricing.formattedPrice;
  }

  Future<CountryPricing?> getPricingForDoctor(String doctorId) async {
    try {
      final doctorResponse = await _supabaseHelper.client
          .from('doctors')
          .select('phone_number')
          .eq('doctor_id', doctorId)
          .maybeSingle();

      if (doctorResponse == null || doctorResponse['phone_number'] == null) {
        return CountryPricing.defaultPricing();
      }

      // Extract country code from phone_number (format: "+22212345678")
      final phoneNumber = doctorResponse['phone_number'] as String;
      String? countryCode;

      // List of supported country codes (from longest to shortest to avoid partial matches)
      final supportedCodes = [
        '+222',
        '+966',
        '+971',
        '+965',
        '+974',
        '+973',
        '+968',
        '+962',
        '+964',
        '+963',
        '+961',
        '+249',
        '+218',
        '+216',
        '+213',
        '+212',
        '+20',
      ];

      // Try to match from longest to shortest codes
      for (final code in supportedCodes) {
        if (phoneNumber.startsWith(code)) {
          countryCode = code;
          break;
        }
      }

      if (countryCode == null) {
        return CountryPricing.defaultPricing();
      }

      return await getPricingByCountryCode(countryCode);
    } catch (e) {
      loggerNoStack.e('Error getting pricing for doctor: $e');
      return CountryPricing.defaultPricing();
    }
  }

  void clearCache() {
    _cachedPricing = [];
    _isLoaded = false;
  }
}

final pricingService = PricingService();

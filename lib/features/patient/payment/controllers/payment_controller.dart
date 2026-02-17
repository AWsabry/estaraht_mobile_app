import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:videocalling/core/config/app_variables.dart';
import 'package:videocalling/core/config/routes.dart';
import 'package:videocalling/core/utils/logger.dart';
import 'package:videocalling/core/widgets/text_style/custom_text_style.dart';
import 'package:videocalling/features/patient/appointments/controllers/make_appointment_controller.dart';
import 'package:videocalling/features/patient/payment_plans/controllers/payment_plans_controller.dart';
import 'package:videocalling/features/patient/payment_plans/models/payment_plan_model.dart';
import 'package:videocalling/shared/services/auth/firebase_helper.dart';
import 'package:videocalling/shared/services/others/timezone_service.dart';
import 'package:videocalling/shared/services/payment/bankily_service.dart';
import 'package:videocalling/shared/services/payment/digital_wallet_service.dart';

class PaymentController extends GetxController {
  // Payment method selection: 0=Digital wallet, 1=Card (Visa/Mastercard USD), 2=Bankily (MRU)
  final selectedPaymentMethod =
      1.obs; // Default to Card (Visa/Mastercard), not Bankily

  // Coupon controller
  final couponController = TextEditingController();

  // Bankily payment fields
  final phoneController = TextEditingController();
  final passcodeController = TextEditingController();
  final merchantId = "".obs;
  // Credit card fields
  final cardNumberController = TextEditingController();
  final cardHolderNameController = TextEditingController();
  final expirationDateController = TextEditingController();
  final cvvController = TextEditingController();
  final cardHolderName = ''.obs;
  final saveCardInfo = false.obs;

  // Arguments from navigation
  late String doctorName;
  String doctorId = '';
  late String userId;
  String appointmentDate = '';
  String appointmentTime = '';
  String slotId = '';
  late String amount;
  late String phone;
  late String description;
  String doctorSpecialization = '';
  String doctorImageUrl = '';
  String doctorGender = '';

  // Payment summary
  final subtotal = 0.0.obs;
  final discount = 0.0.obs;
  final total = 0.0.obs;

  // Loading state
  final isProcessingPayment = false.obs;

  // Tab management
  final selectedTab = 0.obs; // 0 = Payment Details, 1 = Payment Methods
  final showPaymentBreakdown = false.obs;

  // Stripe payment intent (for card payments)
  Map<String, dynamic>? stripePaymentIntent;

  // Store payment intent ID separately for digital wallet payments
  String? digitalWalletPaymentIntentId;

  // Stripe currency selection
  String stripeCurrencyCode = 'USD';
  final List<String> stripeSupportedCurrencies = const [
    'USD',
    // 'AED',
    // 'AFN',
    // 'ALL',
    // 'AMD',
    // 'ANG',
    // 'AOA',
    // 'ARS',
    // 'AUD',
    // 'AWG',
    // 'AZN',
    // 'BAM',
    // 'BBD',
    // 'BDT',
    // 'BGN',
    // 'BIF',
    // 'BMD',
    // 'BND',
    // 'BOB',
    // 'BRL',
    // 'BSD',
    // 'BWP',
    // 'BYN',
    // 'BZD',
    // 'CAD',
    // 'CDF',
    // 'CHF',
    // 'CLP',
    // 'CNY',
    // 'COP',
    // 'CRC',
    // 'CVE',
    // 'CZK',
    // 'DJF',
    // 'DKK',
    // 'DOP',
    // 'DZD',
    // 'EGP',
    // 'ETB',
    // 'EUR',
    // 'FJD',
    // 'FKP',
    // 'GBP',
    // 'GEL',
    // 'GIP',
    // 'GMD',
    // 'GNF',
    // 'GTQ',
    // 'GYD',
    // 'HKD',
    // 'HNL',
    // 'HTG',
    // 'HUF',
    // 'IDR',
    // 'ILS',
    // 'INR',
    // 'ISK',
    // 'JMD',
    // 'JPY',
    // 'KES',
    // 'KGS',
    // 'KHR',
    // 'KMF',
    // 'KRW',
    // 'KYD',
    // 'KZT',
    // 'LAK',
    // 'LBP',
    // 'LKR',
    // 'LRD',
    // 'LSL',
    // 'MAD',
    // 'MDL',
    // 'MGA',
    // 'MKD',
    // 'MMK',
    // 'MNT',
    // 'MOP',
    // 'MUR',
    // 'MVR',
    // 'MWK',
    // 'MXN',
    // 'MYR',
    // 'MZN',
    // 'NAD',
    // 'NGN',
    // 'NIO',
    // 'NOK',
    // 'NPR',
    // 'NZD',
    // 'PAB',
    // 'PEN',
    // 'PGK',
    // 'PHP',
    // 'PKR',
    // 'PLN',
    // 'PYG',
    // 'QAR',
    // 'RON',
    // 'RSD',
    // 'RUB',
    // 'RWF',
    // 'SAR',
    // 'SBD',
    // 'SCR',
    // 'SEK',
    // 'SGD',
    // 'SHP',
    // 'SLE',
    // 'SOS',
    // 'SRD',
    // 'STD',
    // 'SZL',
    // 'THB',
    // 'TJS',
    // 'TOP',
    // 'TRY',
    // 'TTD',
    // 'TWD',
    // 'TZS',
    // 'UAH',
    // 'UGX',
    // 'UYU',
    // 'UZS',
    // 'VND',
    // 'VUV',
    // 'WST',
    // 'XAF',
    // 'XCD',
    // 'XCG',
    // 'XOF',
    // 'XPF',
    // 'YER',
    // 'ZAR',
    // 'ZMW',
  ];

  // Bankily service
  final _bankilyService = BankilyService();

  // Transaction tracking
  final transactionId = ''.obs;
  final operationId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    try {
      loggerNoStack.i('PaymentController initialized');
      merchantIdRevoke();
      _extractArguments();
      _calculateTotal();
      _generateOperationId();
      loggerNoStack.i(
        'PaymentController initialization complete - Operation ID: ${operationId.value}',
      );
    } catch (e, stackTrace) {
      loggerNoStack.e('Error initializing PaymentController: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
    }
  }

  // Check if this is a plan payment
  bool isPlanPayment = false;
  PaymentPlan? selectedPlan;

  void _extractArguments() {
    try {
      final args = Get.arguments as Map<String, dynamic>?;

      loggerNoStack.d('Extracting payment arguments: $args');

      if (args != null) {
        // Check if this is a plan payment
        isPlanPayment = args['isPlanPayment'] == true;

        if (isPlanPayment) {
          // Extract plan payment data
          final planJson = args['plan'] as Map<String, dynamic>?;
          if (planJson != null) {
            selectedPlan = PaymentPlan.fromJson(planJson);
            doctorName = args['doctorName'] ?? 'Estarht Subscription';
            amount = args['amount'] ?? selectedPlan!.price.toString();
            description =
                args['description'] ??
                '${selectedPlan!.planName} - ${selectedPlan!.sessions} sessions';
            phone = args['phone'] ?? '';

            loggerNoStack.i(
              'Plan payment detected - Plan: ${selectedPlan!.planName}, '
              'Sessions: ${selectedPlan!.sessions}, Price: \$${selectedPlan!.price}',
            );
          }
        } else {
          // Extract appointment payment data
          doctorName = args['doctorName'] ?? '';
          doctorImageUrl = args['doctorImageUrl'] ?? '';
          doctorGender = args['doctorGender'] ?? '';
          doctorSpecialization = args['doctorSpecialization'] ?? '';
          doctorId = args['doctorId'] ?? '';
          appointmentDate = args['appointmentDate'] ?? '';
          appointmentTime = args['appointmentTime'] ?? '';
          slotId = args['slotId'] ?? '';
          amount = args['amount'] ?? '0';
          phone = args['phone'] ?? '';
          description = args['description'] ?? '';
        }

        userId = args['userId'] ?? firebaseHelper.currentUser?.uid ?? '';
        subtotal.value = double.tryParse(amount) ?? 0.0;
        phoneController.text = phone;

        loggerNoStack.i(
          'Arguments extracted - Type: ${isPlanPayment ? "Plan" : "Appointment"}, '
          'Amount: $amount${isPlanPayment ? "" : ", Doctor: $doctorName"}',
        );
      } else {
        loggerNoStack.w('No arguments provided to PaymentController');
      }
    } catch (e, stackTrace) {
      loggerNoStack.e('Error extracting arguments: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
    }
  }

  void _calculateTotal() {
    try {
      total.value = subtotal.value - discount.value;
    } catch (e, stackTrace) {
      loggerNoStack.e('Error calculating total: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
    }
  }

  void _generateOperationId() {
    try {
      // Generate unique operation ID with current date prefix for Bankily
      final now = TimezoneService.getCurrentMauritaniaTime();
      final datePrefix =
          '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';

      // Safely get user ID suffix (max 6 chars, or full length if shorter)
      String userIdSuffix = userId.isNotEmpty
          ? userId.substring(0, userId.length > 6 ? 6 : userId.length)
          : 'USER';

      // Format: YYYYMMDD_OPR_timestamp_userSuffix
      operationId.value =
          '${datePrefix}_OPR_${now.millisecondsSinceEpoch}_$userIdSuffix';
      loggerNoStack.i('Generated operation ID: ${operationId.value}');
    } catch (e, stackTrace) {
      loggerNoStack.e('Error generating operation ID: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
      // Fallback to basic operation ID with date
      final datePrefix = TimezoneService.getCurrentMauritaniaTime()
          .toIso8601String()
          .substring(0, 10)
          .replaceAll('-', '');
      operationId.value =
          '${datePrefix}_OPR_${TimezoneService.getCurrentMauritaniaTime().millisecondsSinceEpoch}_FALLBACK';
      loggerNoStack.w('Using fallback operation ID: ${operationId.value}');
    }
  }

  void setStripeCurrencyCode(String code) {
    try {
      if (stripeSupportedCurrencies.contains(code)) {
        stripeCurrencyCode = code;
        loggerNoStack.i('Stripe currency set to: $code');
      } else {
        loggerNoStack.w('Attempted to set unsupported Stripe currency: $code');
      }
    } catch (e, stackTrace) {
      loggerNoStack.e('Error setting Stripe currency code: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
    }
  }

  /// Get payment gateway and currency from selected payment method.
  /// Card (Visa/Mastercard) = stripe, USD. Bankily = bankily, MRU. Digital wallet = platform name, USD.
  ({String gateway, String currency}) getPaymentGatewayAndCurrency() {
    switch (selectedPaymentMethod.value) {
      case 0:
        return (
          gateway: DigitalWalletService.getPlatformPaymentName()
              .toLowerCase()
              .replaceAll(' ', '_'),
          currency: 'USD',
        );
      case 1:
        return (gateway: 'stripe', currency: 'USD');
      case 2:
        return (gateway: 'bankily', currency: 'MRU');
      default:
        return (gateway: 'stripe', currency: 'USD');
    }
  }

  void selectPaymentMethod(int index) {
    try {
      selectedPaymentMethod.value = index;
      loggerNoStack.i('Payment method selected: $index');
    } catch (e, stackTrace) {
      loggerNoStack.e('Error selecting payment method: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
    }
  }

  void switchTab(int index) {
    selectedTab.value = index;
    loggerNoStack.i('Switched to tab: $index');
  }

  void togglePaymentBreakdown() {
    showPaymentBreakdown.value = !showPaymentBreakdown.value;
    loggerNoStack.i(
      'Payment breakdown visibility: ${showPaymentBreakdown.value}',
    );
  }

  void applyCoupon() async {
    try {
      final couponCode = couponController.text.trim();

      loggerNoStack.i('Applying coupon: $couponCode');

      if (couponCode.isEmpty) {
        loggerNoStack.w('Coupon code is empty');
        Get.snackbar(
          'error'.tr,
          'please_enter_a_coupon_code'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Show loading indicator
      Get.snackbar(
        'validating'.tr,
        'checking_coupon_validity'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Validate coupon with database
      final validationResult = await _validateCoupon(couponCode);

      if (validationResult['isValid'] == true) {
        // Apply discount
        final discountValue = validationResult['discountValue'] ?? 10.0;

        discount.value = discountValue;

        // Ensure discount doesn't exceed subtotal
        if (discount.value > subtotal.value) {
          discount.value = subtotal.value;
        }

        _calculateTotal();

        loggerNoStack.i(
          'Coupon applied successfully - Discount: ${discount.value}',
        );

        Get.snackbar(
          'success'.tr,
          'coupon_applied_successfully'.tr.replaceAll(
            '{amount}',
            '\$${discount.value.toStringAsFixed(2)}',
          ),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        loggerNoStack.w('Invalid coupon: ${validationResult['message']}');
        Get.snackbar(
          'invalid_coupon'.tr,
          validationResult['message'] ?? 'this_coupon_is_not_valid'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e, stackTrace) {
      loggerNoStack.e('Error applying coupon: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
      Get.snackbar(
        'error'.tr,
        'failed_to_validate_coupon'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Validate coupon against database rules
  Future<Map<String, dynamic>> _validateCoupon(String couponCode) async {
    try {
      loggerNoStack.i('🎫 Validating coupon: $couponCode');

      final supabase = Supabase.instance.client;

      // Step 1: Find the coupon
      final couponResponse = await supabase
          .from('coupon')
          .select('*')
          .eq('coupon_code', couponCode.toUpperCase())
          .maybeSingle();

      if (couponResponse == null) {
        loggerNoStack.w('❌ Coupon not found: $couponCode');
        return {'isValid': false, 'message': 'Coupon code not found'};
      }

      loggerNoStack.d('Found coupon: $couponResponse');

      final couponId = couponResponse['id'];
      final validUntil = DateTime.parse(couponResponse['valid_until']);
      final oneUse = couponResponse['one_use'] ?? true;
      final numberOfUses = couponResponse['number_of_uses'] ?? 1;
      final forUser = couponResponse['for_user'];
      final isUsed = couponResponse['is_used'] ?? false;

      // Step 2: Check if coupon has expired
      final now = TimezoneService.getCurrentMauritaniaTime();
      if (now.isAfter(validUntil)) {
        loggerNoStack.w(
          '❌ Coupon expired: $couponCode (expired on $validUntil)',
        );
        return {'isValid': false, 'message': 'This coupon has expired'};
      }

      // Step 3: Check if coupon is for a specific user
      if (forUser != null && forUser.isNotEmpty && forUser != userId) {
        loggerNoStack.w(
          '❌ Coupon not for this user: $couponCode (for: $forUser, current: $userId)',
        );
        return {
          'isValid': false,
          'message': 'This coupon is not valid for your account',
        };
      }

      // Step 4: Check if it's a one-use coupon and already used
      if (oneUse && isUsed) {
        loggerNoStack.w('❌ One-use coupon already used: $couponCode');
        return {
          'isValid': false,
          'message': 'This coupon has already been used',
        };
      }

      // Step 5: For multi-use coupons, check usage count and user-specific usage
      if (!oneUse) {
        // Check total usage count
        final usageCountResponse = await supabase
            .from('coupon_usage')
            .select('id')
            .eq('coupon_id', couponId);

        final totalUsageCount = usageCountResponse.length;

        if (totalUsageCount >= numberOfUses) {
          loggerNoStack.w(
            '❌ Multi-use coupon reached max uses: $couponCode ($totalUsageCount/$numberOfUses)',
          );
          return {
            'isValid': false,
            'message': 'This coupon has reached its maximum number of uses',
          };
        }

        // Check if current user has already used this coupon
        final userUsageResponse = await supabase
            .from('coupon_usage')
            .select('id')
            .eq('coupon_id', couponId)
            .eq('user_id', userId)
            .maybeSingle();

        if (userUsageResponse != null) {
          loggerNoStack.w(
            '❌ User already used this coupon: $couponCode (user: $userId)',
          );
          return {
            'isValid': false,
            'message': 'You have already used this coupon',
          };
        }
      }

      // Step 6: If all checks pass, coupon is valid — use discount from DB
      loggerNoStack.i('✅ Coupon is valid: $couponCode');

    
      final rawDiscount = couponResponse['coupon_value'];
      final discountValue = rawDiscount != null
          ? (rawDiscount is num ? rawDiscount : num.tryParse(rawDiscount.toString()) ?? 10.0).toDouble()
          : 10.0;

      return {
        'isValid': true,
        'couponId': couponId,
        'discountValue': discountValue,
        'message': 'Coupon is valid',
      };
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ Error validating coupon: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
      return {
        'isValid': false,
        'message': 'Error validating coupon. Please try again.',
      };
    }
  }

  /// Mark coupon as used after successful payment
  Future<void> _markCouponAsUsed(String couponCode) async {
    try {
      if (couponCode.isEmpty || discount.value <= 0) {
        loggerNoStack.d('No coupon to mark as used');
        return;
      }

      loggerNoStack.i('🎫 Marking coupon as used: $couponCode');

      final supabase = Supabase.instance.client;

      // Get coupon details
      final couponResponse = await supabase
          .from('coupon')
          .select('id, one_use')
          .eq('coupon_code', couponCode.toUpperCase())
          .single();

      final couponId = couponResponse['id'];
      final oneUse = couponResponse['one_use'] ?? true;

      if (oneUse) {
        // Mark one-use coupon as used
        await supabase
            .from('coupon')
            .update({'is_used': true})
            .eq('id', couponId);

        loggerNoStack.i('✅ One-use coupon marked as used');
      } else {
        // Add usage record for multi-use coupon
        await supabase.from('coupon_usage').insert({
          'coupon_id': couponId,
          'user_id': userId,
          'used_at': TimezoneService.getCurrentMauritaniaTime()
              .toIso8601String(),
        });

        loggerNoStack.i('✅ Multi-use coupon usage recorded');
      }
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ Error marking coupon as used: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
      // Don't throw - this is auxiliary functionality
    }
  }

  /// get merchant id to get paid

  void merchantIdRevoke() async {
    try {
      await _bankilyService.initializeAndAuthenticate();

      loggerNoStack.i(
        'Merchant ID retrieved: ${_bankilyService.commercentCode}',
      );
      merchantId.value = _bankilyService.commercentCode.toString();
      update();
      // Use the merchantId as needed
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ Error retrieving merchant ID: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
    }
  }

  /// Process payment through Bankily
  Future<void> processBankilyPayment() async {
    loggerNoStack.i('=== Starting Bankily Payment Process ===');

    try {
      // Validate inputs
      loggerNoStack.d('Validating payment inputs...');

      if (phoneController.text.isEmpty) {
        loggerNoStack.w('Phone number is empty');
        Get.snackbar(
          'error'.tr,
          'please_enter_your_phone_number'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (passcodeController.text.isEmpty) {
        loggerNoStack.w('Passcode is empty');
        Get.snackbar(
          'error'.tr,
          'please_enter_your_bankily_passcode'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      isProcessingPayment.value = true;

      loggerNoStack.i('Payment inputs validated');
      loggerNoStack.i('Phone: ${phoneController.text}');
      loggerNoStack.i('Operation ID: ${operationId.value}');
      loggerNoStack.i('Amount (USD): ${total.value.toStringAsFixed(2)}');

      // Convert USD to MRU for Bankily payment
      final amountInMRU = _convertToMRU(total.value);
      loggerNoStack.i('Amount (MRU): ${amountInMRU.toStringAsFixed(2)}');

      // Save initial transaction record as 'waiting'
      // await _saveTransactionHistory(status: 'waiting');
      await _savePaymentHistory(
        status: 'waiting',
        gateway: 'bankily',
        currency: 'MRU',
      );

      // Step 1: Initialize and authenticate with Bankily service
      loggerNoStack.i('🔧 Step 1: Initializing Bankily service...');
      final authResult = await _bankilyService.initializeAndAuthenticate();

      if (authResult['success'] != true) {
        loggerNoStack.e(
          '❌ Bankily authentication failed: ${authResult['message']}',
        );

        // Update records to failed status
        // await _updateTransactionHistory(status: 'failed');
        await _updatePaymentHistory(
          status: 'failed',
          gateway: 'bankily',
          currency: 'MRU',
        );

        Get.snackbar(
          'authentication_error_title'.tr,
          'failed_to_connect_payment_service'.tr.replaceAll(
            '{message}',
            authResult['message']?.toString() ?? '',
          ),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      loggerNoStack.i('✅ Bankily service authenticated successfully');

      // Step 2: Process payment through Bankily
      loggerNoStack.i('💳 Step 2: Processing payment through Bankily...');

      final paymentResult = await _bankilyService.processPaymentWithAuth(
        clientPhone: phoneController.text.trim(),
        passcode: passcodeController.text.trim(),
        operationId: operationId.value,
        amount: amountInMRU.toStringAsFixed(2),
        language: 'FR',
      );

      final errorCode = paymentResult['errorCode'];
      final errorMessage = paymentResult['errorMessage'];
      final paymentTransactionId = paymentResult['transactionId'];

      loggerNoStack.i(
        'Payment result - ErrorCode: $errorCode, Message: $errorMessage, TxnId: $paymentTransactionId',
      );

      if (errorCode != '0') {
        loggerNoStack.e('❌ Payment failed - Error: $errorMessage');

        // Update records to failed status
        // await _updateTransactionHistory(status: 'failed');
        await _updatePaymentHistory(
          status: 'failed',
          gateway: 'bankily',
          currency: 'MRU',
        );

        Get.snackbar(
          'payment_failed_title'.tr,
          errorMessage ?? 'payment_processing_failed'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Step 3: Wait and verify payment completion
      loggerNoStack.i('⏳ Step 3: Waiting for payment confirmation...');

      bool paymentConfirmed = false;
      int maxAttempts = 10; // Check for up to 30 seconds (3 seconds * 10)
      int attempt = 0;

      while (attempt < maxAttempts && !paymentConfirmed) {
        attempt++;
        loggerNoStack.d(
          'Checking payment status - Attempt $attempt/$maxAttempts',
        );

        // Wait 3 seconds before checking
        await Future.delayed(const Duration(seconds: 3));

        final statusResult = await _bankilyService.checkTransactionWithAuth(
          operationId: operationId.value,
        );

        final status = statusResult['status'];
        final statusErrorCode = statusResult['errorCode'];

        loggerNoStack.d(
          'Status check result - Status: $status, ErrorCode: $statusErrorCode',
        );

        if (statusErrorCode == '0') {
          if (status == 'TS') {
            // Transaction Successful
            paymentConfirmed = true;
            transactionId.value =
                statusResult['transactionId'] ??
                paymentTransactionId ??
                'UNKNOWN';
            loggerNoStack.i(
              '✅ Payment confirmed successful! Transaction ID: ${transactionId.value}',
            );
            break;
          } else if (status == 'TF') {
            // Transaction Failed
            loggerNoStack.e('❌ Payment failed during processing');

            // Update records to failed status
            // await _updateTransactionHistory(status: 'failed');
            await _updatePaymentHistory(
              status: 'failed',
              gateway: 'bankily',
              currency: 'MRU',
            );

            Get.snackbar(
              'payment_failed_title'.tr,
              'transaction_declined'.tr,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
            return;
          } else if (status == 'TA') {
            // Transaction Pending - continue waiting
            loggerNoStack.d('⏳ Payment still pending, continuing to wait...');
            continue;
          }
        } else {
          loggerNoStack.w(
            '⚠️ Error checking transaction status: ${statusResult['errorMessage']}',
          );
        }
      }

      if (!paymentConfirmed) {
        loggerNoStack.e('❌ Payment confirmation timeout');

        // Update records to failed status (timeout)
        // await _updateTransactionHistory(status: 'failed');
        await _updatePaymentHistory(
          status: 'failed',
          gateway: 'bankily',
          currency: 'MRU',
        );

        Get.snackbar(
          'payment_timeout_title'.tr,
          'payment_timeout_message'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      // Step 4: Update records to success status BEFORE creating booking
      loggerNoStack.i('✅ Step 4: Updating payment records to success...');
      // await _updateTransactionHistory(status: 'success');
      await _updatePaymentHistory(
        status: 'success',
        gateway: 'bankily',
        currency: 'MRU',
      );

      // Step 5: Mark coupon as used if a coupon was applied
      if (couponController.text.trim().isNotEmpty && discount.value > 0) {
        loggerNoStack.i('🎫 Step 5: Marking coupon as used...');
        await _markCouponAsUsed(couponController.text.trim());
      }

      // Step 6: Process based on payment type
      if (isPlanPayment && selectedPlan != null) {
        // Handle plan subscription
        loggerNoStack.i('💳 Step 6: Processing plan subscription...');
        await _processPlansSubscription();

        loggerNoStack.i('✅ Plan subscription completed successfully!');
        Get.snackbar(
          'success_str'.tr,
          'subscription_success_message'.tr.replaceAll(
            '{sessions}',
            '${selectedPlan!.sessions}',
          ),
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Navigate to plans tab in user tab screen
        await Future.delayed(const Duration(seconds: 1));
        Get.offAllNamed(Routes.userTabScreen, arguments: {'initialTab': 3});
      } else {
        // Handle appointment booking
        loggerNoStack.i(
          '📝 Step 6: Creating booking after payment confirmation...',
        );
        await _createBookingInSupabase();

        loggerNoStack.i('✅ Payment and booking completed successfully!');
        Get.snackbar(
          'success_str'.tr,
          'payment_booking_success'.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Navigate to appointments tab in user tab screen
        await Future.delayed(const Duration(seconds: 1));
        Get.offAllNamed(Routes.userTabScreen, arguments: {'initialTab': 2});
      }
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ CRITICAL ERROR in processBankilyPayment: $e');
      loggerNoStack.e('Stack trace: $stackTrace');

      try {
        // Update records to failed status on critical error
        // await _updateTransactionHistory(status: 'failed');
        await _updatePaymentHistory(
          status: 'failed',
          gateway: 'bankily',
          currency: 'MRU',
        );
      } catch (updateError) {
        loggerNoStack.e(
          '❌ Error updating payment records after failure: $updateError',
        );
      }

      Get.snackbar(
        'error'.tr,
        'payment_processing_failed'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isProcessingPayment.value = false;
      loggerNoStack.i('=== Bankily Payment Process Complete ===');
    }
  }

  /// Save initial payment history record (disabled for now)
  Future<void> _savePaymentHistory({
    required String status,
    String? gateway,
    String? currency,
  }) async {
    // Payment history submit disabled
  }

  /// Update payment history status (disabled for now)
  Future<void> _updatePaymentHistory({
    required String status,
    String? gateway,
    String? currency,
  }) async {
    // Payment history submit disabled
  }

  /// Generate a unique booking ID with current date prefix
  String _generateBookingId() {
    try {
      final now = TimezoneService.getCurrentMauritaniaTime();
      final datePrefix =
          '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';

      // Safely get user ID suffix (max 4 chars)
      String userIdSuffix = userId.isNotEmpty
          ? userId.substring(0, userId.length > 4 ? 4 : userId.length)
          : 'USER';

      // Format: YYYYMMDD_BKG_timestamp_userSuffix
      final bookingId =
          '${datePrefix}_BKG_${now.millisecondsSinceEpoch}_$userIdSuffix';
      loggerNoStack.i('Generated booking ID: $bookingId');
      return bookingId;
    } catch (e, stackTrace) {
      loggerNoStack.e('Error generating booking ID: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
      // Fallback to basic booking ID with date
      final datePrefix = TimezoneService.getCurrentMauritaniaTime()
          .toIso8601String()
          .substring(0, 10)
          .replaceAll('-', '');
      return '${datePrefix}_BKG_${TimezoneService.getCurrentMauritaniaTime().millisecondsSinceEpoch}_FALLBACK';
    }
  }

  /// Process plan subscription after successful payment
  Future<void> _processPlansSubscription() async {
    try {
      if (selectedPlan == null) {
        throw Exception('No plan selected for subscription');
      }

      loggerNoStack.i(
        '💳 Processing subscription for plan: ${selectedPlan!.planName}',
      );

      // Get or create PaymentPlansController
      PaymentPlansController plansController;
      if (Get.isRegistered<PaymentPlansController>()) {
        plansController = Get.find<PaymentPlansController>();
      } else {
        plansController = Get.put(PaymentPlansController());
      }

      // Subscribe to the plan - use detected gateway/currency from payment screen
      final pay = getPaymentGatewayAndCurrency();
      await plansController.subscribeToPlan(
        plan: selectedPlan!,
        paymentGateway: pay.gateway,
        paymentId: transactionId.value,
        paymentCurrency: pay.currency,
      );

      loggerNoStack.i(
        '✅ Subscription processed - ${selectedPlan!.sessions} sessions added',
      );
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ Error processing plan subscription: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Deduct session from patient's available sessions and add to pending
  Future<void> _deductSessionFromPatient(String patientId) async {
    try {
      loggerNoStack.i('📉 Deducting session from patient...');

      // Get current session counts
      final patientData = await Supabase.instance.client
          .from('patients')
          .select('sessions_available, sessions_pending')
          .eq('id', patientId)
          .single();

      final currentAvailable = patientData['sessions_available'] ?? 0;
      final currentPending = patientData['sessions_pending'] ?? 0;

      if (currentAvailable <= 0) {
        loggerNoStack.w('⚠️ No sessions available to deduct');
        // Don't throw error - this might be a direct payment
        return;
      }

      // Deduct 1 from available, add 1 to pending
      await Supabase.instance.client
          .from('patients')
          .update({
            'sessions_available': currentAvailable - 1,
            'sessions_pending': currentPending + 1,
          })
          .eq('id', patientId);

      loggerNoStack.i(
        '✅ Session deducted: Available $currentAvailable -> ${currentAvailable - 1}, Pending $currentPending -> ${currentPending + 1}',
      );
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ Error deducting session: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
      // Don't throw - this is not critical for booking creation
    }
  }

  /// Create booking directly in Supabase
  Future<void> _createBookingInSupabase() async {
    try {
      loggerNoStack.i('📝 Creating booking in Supabase...');

      // Get current Firebase user
      final user = firebaseHelper.currentUser;

      if (user == null) {
        loggerNoStack.e('❌ User is not authenticated');
        throw Exception('User not authenticated. Please sign in again.');
      }

      final patientId = user.uid;
      loggerNoStack.i('✅ Patient ID: $patientId');
      loggerNoStack.i('✅ Patient Email: ${user.email}');

      // Deduct session from patient's available count
      await _deductSessionFromPatient(patientId);

      // appointmentDate and appointmentTime are in doctor's local time; convert to UTC for storage
      int doctorOffset = 0;
      try {
        final doctorRow = await Supabase.instance.client
            .from('doctors')
            .select('timezone_offset_hours')
            .eq('doctor_id', doctorId)
            .maybeSingle();
        if (doctorRow != null && doctorRow['timezone_offset_hours'] != null) {
          doctorOffset = (doctorRow['timezone_offset_hours'] as num).toInt();
        }
      } catch (_) {}

      final timeStr = appointmentTime.contains(':')
          ? appointmentTime.length >= 5
              ? appointmentTime.substring(0, 5)
              : appointmentTime
          : appointmentTime;
      final utcBooking = TimezoneService.localDateAndTimeToUtcStrings(
        appointmentDate,
        timeStr,
        doctorOffset,
      );

      loggerNoStack.d(
        'Booking Date (UTC): ${utcBooking.utcDateStr}',
      );
      loggerNoStack.d('Booking Time (UTC): ${utcBooking.utcTimeStr}');

      // Generate unique booking ID with date prefix
      final bookingId = _generateBookingId();

      // Create booking data (store UTC)
      final bookingData = {
        'patient_id': patientId,
        'doctor_id': doctorId,
        'availability_id': slotId.isNotEmpty ? slotId : null,
        'status': 'confirmed', // confirmed, pending, cancelled, completed
        'price': total.value.toStringAsFixed(2),
        'payment_intent_id': transactionId.value,
        'video_session_id': null, // Will be set when video call starts
        'created_at': TimezoneService.getCurrentMauritaniaTime()
            .toIso8601String(),
        'booking_date': utcBooking.utcDateStr,
        'booking_time': utcBooking.utcTimeStr,
      };

      loggerNoStack.d('Booking data to insert: $bookingData');

      // Insert booking into Supabase using the supabase client
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('bookings')
          .insert(bookingData)
          .select()
          .single();

      loggerNoStack.i('✅ Booking created successfully!');
      loggerNoStack.d('Booking response: $response');

      // Update payment and transaction history with booking ID
      await _updateRecordsWithBookingId(bookingId);

      // Show success details
      loggerNoStack.i('=== Booking Details ===');
      loggerNoStack.i('Booking ID: ${response['id']}');
      loggerNoStack.i('Status: ${response['status']}');
      loggerNoStack.i('Patient: $patientId');
      loggerNoStack.i('Doctor: ${response['doctor_id']}');
      loggerNoStack.i(
        'Date: ${response['booking_date']} at ${response['booking_time']}',
      );
      loggerNoStack.i('Price: \$${response['price']}');
      loggerNoStack.i('======================');
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ Error creating booking in Supabase: $e');
      loggerNoStack.e('Stack trace: $stackTrace');

      // More detailed error messages
      if (e.toString().contains('not authenticated')) {
        throw Exception('Authentication failed. Please sign in again.');
      } else if (e.toString().contains('violates')) {
        throw Exception('Database constraint error. Please check your data.');
      } else if (e.toString().contains('duplicate key')) {
        throw Exception('This booking already exists. Please try again.');
      } else {
        throw Exception('Failed to create booking: $e');
      }
    }
  }

  /// Update payment and transaction history with booking ID (disabled for now)
  Future<void> _updateRecordsWithBookingId(String bookingId) async {
    // Payment history submit disabled
  }

  /// Convert USD to MRU (approximate exchange rate)
  /// TODO: Replace with real-time exchange rate API in production
  double _convertToMRU(double amountInUSD) {
    // Approximate exchange rate: 1 USD = 50 MRU
    // This should be fetched from a real exchange rate API in production
    const exchangeRate = 50.0;
    final amountInMRU = amountInUSD * exchangeRate;

    loggerNoStack.i(
      '💱 Currency conversion: $amountInUSD USD = ${amountInMRU.toStringAsFixed(2)} MRU (rate: 1 USD = $exchangeRate MRU)',
    );

    return amountInMRU;
  }

  /// Create a Stripe PaymentIntent for the current total amount
  Future<Map<String, dynamic>> _createStripePaymentIntent() async {
    try {
      // Total is already in USD, convert to minor units
      final amountInMinorUnits = (total.value * 100).round();

      loggerNoStack.i(
        '💳 Creating Stripe PaymentIntent - Amount: $amountInMinorUnits cents USD',
      );

      final body = {
        'amount': amountInMinorUnits.toString(),
        'currency': stripeCurrencyCode,
        'payment_method_types[]': 'card',
      };

      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $stripeSecretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      if (response.statusCode != 200) {
        loggerNoStack.e(
          '❌ Failed to create Stripe PaymentIntent: ${response.body}',
        );
        throw Exception('Failed to create payment session. Please try again.');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      loggerNoStack.i('✅ Stripe PaymentIntent created: ${data['id']}');
      return data;
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ Error creating Stripe PaymentIntent: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Safely show a snackbar only when an overlay context is available to avoid
  /// crashes if the controller is used outside a widget tree.
  void _showSafeSnackbar({
    required String title,
    required String message,
    Color backgroundColor = Colors.black,
    SnackPosition position = SnackPosition.BOTTOM,
  }) {
    // Prefer any available context that has an Overlay ancestor.
    final overlayContext =
        Get.overlayContext ?? Get.key.currentContext ?? Get.context;

    // If still no usable context, skip to avoid crashing.
    if (overlayContext == null) {
      loggerNoStack.w(
        'Skipped showing snackbar "$title": no overlay context available.',
      );
      return;
    }

    try {
      // Validate that an Overlay exists above the chosen context.
      final overlay = Overlay.maybeOf(overlayContext, rootOverlay: true);
      if (overlay == null) {
        loggerNoStack.w(
          'Skipped showing snackbar "$title": overlay widget not found.',
        );
        return;
      }

      Get.showSnackbar(
        GetSnackBar(
          titleText: Text(
            title,
            style: const CustomTextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          messageText: Text(
            message,
            style: const CustomTextStyle(color: Colors.white),
          ),
          snackPosition: position,
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(12),
          borderRadius: 8,
        ),
      );
    } catch (err, stack) {
      loggerNoStack.e('Failed to show snackbar "$title": $err');
      loggerNoStack.e(stack);
    }
  }

  /// Process payment through Stripe (card payment)
  Future<void> _processStripePayment() async {
    loggerNoStack.i('=== Starting Stripe Payment Process ===');

    try {
      // Prevent double submission
      if (isProcessingPayment.value) {
        loggerNoStack.w(
          'Stripe payment already in progress, ignoring duplicate request',
        );
        return;
      }

      isProcessingPayment.value = true;

      // Save initial transaction record as 'waiting'
      // Card (Visa/Mastercard) is always USD
      await _savePaymentHistory(
        status: 'waiting',
        gateway: 'stripe',
        currency: 'USD',
      );

      // 1) Create PaymentIntent on Stripe
      stripePaymentIntent = await _createStripePaymentIntent();

      // 2) Initialize Stripe payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret:
              stripePaymentIntent!['client_secret'] as String,
          merchantDisplayName: 'Videocalling',
        ),
      );

      // 3) Present payment sheet
      await Stripe.instance.presentPaymentSheet();

      // If we reach here, payment succeeded
      transactionId.value =
          stripePaymentIntent?['id']?.toString() ?? 'STRIPE_UNKNOWN';

      loggerNoStack.i(
        '✅ Stripe payment successful, PaymentIntent ID: ${transactionId.value}',
      );

      // Update records to success (Card is always USD)
      await _updatePaymentHistory(
        status: 'success',
        gateway: 'stripe',
        currency: 'USD',
      );

      // Mark coupon as used if applicable
      if (couponController.text.trim().isNotEmpty && discount.value > 0) {
        await _markCouponAsUsed(couponController.text.trim());
      }

      // Process based on payment type
      if (isPlanPayment && selectedPlan != null) {
        // Handle plan subscription
        await _processPlansSubscription();

        loggerNoStack.i('✅ Stripe plan subscription completed successfully!');
        _showSafeSnackbar(
          title: 'success_str'.tr,
          message: 'subscription_success_message'.tr.replaceAll(
            '{sessions}',
            '${selectedPlan!.sessions}',
          ),
          position: SnackPosition.TOP,
          backgroundColor: Colors.green,
        );

        // Navigate to plans tab in user tab screen
        await Future.delayed(const Duration(seconds: 1));
        Get.offAllNamed(Routes.userTabScreen, arguments: {'initialTab': 3});
      } else {
        // Create booking
        await _createBookingInSupabase();

        loggerNoStack.i('✅ Stripe payment and booking completed successfully!');
        _showSafeSnackbar(
          title: 'success_str'.tr,
          message: 'payment_booking_success'.tr,
          position: SnackPosition.TOP,
          backgroundColor: Colors.green,
        );

        // Navigate to appointments tab in user tab screen
        await Future.delayed(const Duration(seconds: 1));
        Get.offAllNamed(Routes.userTabScreen, arguments: {'initialTab': 2});
      }
    } on StripeException catch (e, stackTrace) {
      loggerNoStack.e('❌ StripeException during payment: $e');
      loggerNoStack.e('Stack trace: $stackTrace');

      // Update records to failed (Card is always USD)
      await _updatePaymentHistory(
        status: 'failed',
        gateway: 'stripe',
        currency: 'USD',
      );

      _showSafeSnackbar(
        title: 'payment_failed_title'.tr,
        message: 'payment_cancelled_or_failed'.tr,
        position: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ CRITICAL ERROR in _processStripePayment: $e');
      loggerNoStack.e('Stack trace: $stackTrace');

      try {
        await _updatePaymentHistory(
          status: 'failed',
          gateway: 'stripe',
          currency: 'USD',
        );
      } catch (updateError) {
        loggerNoStack.e(
          '❌ Error updating payment records after Stripe failure: $updateError',
        );
      }

      _showSafeSnackbar(
        title: 'error'.tr,
        message: 'payment_failed'.tr,
        position: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
    } finally {
      isProcessingPayment.value = false;
      stripePaymentIntent = null;
      loggerNoStack.i('=== Stripe Payment Process Complete ===');
    }
  }

  /// Prepare Digital Wallet Payment - Create Payment Intent if not exists
  Future<void> prepareDigitalWalletPayment() async {
    // If payment intent already created, skip
    if (digitalWalletPaymentIntentId != null &&
        digitalWalletPaymentIntentId!.isNotEmpty) {
      loggerNoStack.i(
        '✅ Payment intent already exists: $digitalWalletPaymentIntentId',
      );
      return;
    }

    loggerNoStack.i('🔧 Preparing digital wallet payment...');

    try {
      // Save initial transaction record as 'waiting'
      await _savePaymentHistory(
        status: 'waiting',
        gateway: DigitalWalletService.getPlatformPaymentName()
            .toLowerCase()
            .replaceAll(' ', '_'),
        currency: 'USD', // Digital wallet uses card, always USD
      );

      // Create PaymentIntent on Stripe
      loggerNoStack.i('🔧 Creating Stripe PaymentIntent...');
      stripePaymentIntent = await _createStripePaymentIntent();

      // Store the payment intent ID separately for digital wallet
      digitalWalletPaymentIntentId = stripePaymentIntent!['id'] as String;

      loggerNoStack.i('✅ PaymentIntent created: $digitalWalletPaymentIntentId');
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ Error preparing digital wallet payment: $e');
      loggerNoStack.e('Stack trace: $stackTrace');

      await _updatePaymentHistory(
        status: 'failed',
        gateway: DigitalWalletService.getPlatformPaymentName()
            .toLowerCase()
            .replaceAll(' ', '_'),
        currency: 'USD',
      );

      rethrow;
    }
  }

  /// Process Digital Wallet Payment (Apple Pay / Google Pay)
  Future<void> _processDigitalWalletPayment() async {
    loggerNoStack.i('=== Starting Digital Wallet Payment Process ===');

    try {
      // Prevent double submission
      if (isProcessingPayment.value) {
        loggerNoStack.w(
          'Digital wallet payment already in progress, ignoring duplicate request',
        );
        return;
      }

      isProcessingPayment.value = true;

      final platformName = DigitalWalletService.getPlatformPaymentName();
      loggerNoStack.i('💳 Processing $platformName payment...');

      // Save initial transaction record as 'waiting' (digital wallet uses card, always USD)
      await _savePaymentHistory(
        status: 'waiting',
        gateway: platformName.toLowerCase().replaceAll(' ', '_'),
        currency: 'USD',
      );

      // 1) Create PaymentIntent on Stripe for the digital wallet
      loggerNoStack.i('🔧 Step 1: Creating Stripe PaymentIntent...');
      stripePaymentIntent = await _createStripePaymentIntent();

      // Store the payment intent ID separately for digital wallet
      digitalWalletPaymentIntentId = stripePaymentIntent!['id'] as String;

      final clientSecret = stripePaymentIntent!['client_secret'] as String;
      loggerNoStack.i('✅ PaymentIntent created: $digitalWalletPaymentIntentId');

      // 2) Create payment items for digital wallet
      loggerNoStack.i('📋 Step 2: Creating payment items...');
      final paymentItems = DigitalWalletService.createDetailedPaymentItems(
        subtotal: subtotal.value,
        discount: discount.value,
        total: total.value,
      );

      // 3) Process payment based on platform
      loggerNoStack.i('💰 Step 3: Processing $platformName payment...');

      // This will be handled by the Pay button widget in the UI
      // The token will be returned from onPaymentResult callback
      loggerNoStack.i(
        '⏳ Waiting for user to complete $platformName payment...',
      );

      // Note: The actual payment processing happens in the Pay widget callback
      // See _buildDigitalWalletBlackButton in payment_page.dart
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ CRITICAL ERROR in _processDigitalWalletPayment: $e');
      loggerNoStack.e('Stack trace: $stackTrace');

      try {
        await _updatePaymentHistory(
          status: 'failed',
          gateway: DigitalWalletService.getPlatformPaymentName()
              .toLowerCase()
              .replaceAll(' ', '_'),
          currency: 'USD',
        );
      } catch (updateError) {
        loggerNoStack.e(
          '❌ Error updating payment records after digital wallet failure: $updateError',
        );
      }

      _showSafeSnackbar(
        title: 'error'.tr,
        message: 'payment_failed'.tr,
        position: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
    } finally {
      isProcessingPayment.value = false;
      // Don't clean up digitalWalletPaymentIntentId here - it's needed for the callback
      loggerNoStack.i('=== Digital Wallet Payment Process Complete ===');
    }
  }

  /// Handle successful digital wallet payment result
  Future<void> onDigitalWalletPaymentSuccess(
    Map<String, dynamic> paymentResult,
  ) async {
    try {
      loggerNoStack.i('✅ Digital Wallet payment successful!');
      loggerNoStack.d('Payment result: $paymentResult');

      // Extract payment token from result
      final token =
          paymentResult['paymentMethodData']?['tokenizationData']?['token'];

      if (token == null) {
        throw Exception('No payment token received from digital wallet');
      }

      loggerNoStack.i('🔑 Payment token received, confirming payment...');

      // Confirm the payment with Stripe using the token
      final confirmed = await _confirmDigitalWalletPayment(token);

      if (!confirmed) {
        throw Exception('Failed to confirm digital wallet payment');
      }

      // Set transaction ID from saved payment intent ID
      transactionId.value =
          digitalWalletPaymentIntentId ?? 'DIGITAL_WALLET_UNKNOWN';

      loggerNoStack.i(
        '✅ Payment confirmed, transaction ID: ${transactionId.value}',
      );

      // Update records to success (digital wallet uses card, always USD)
      await _updatePaymentHistory(
        status: 'success',
        gateway: DigitalWalletService.getPlatformPaymentName()
            .toLowerCase()
            .replaceAll(' ', '_'),
        currency: 'USD',
      );

      // Mark coupon as used if applicable
      if (couponController.text.trim().isNotEmpty && discount.value > 0) {
        await _markCouponAsUsed(couponController.text.trim());
      }

      // Process based on payment type
      if (isPlanPayment && selectedPlan != null) {
        // Handle plan subscription
        await _processPlansSubscription();

        loggerNoStack.i('✅ Digital wallet plan subscription completed!');
        _showSafeSnackbar(
          title: 'success_str'.tr,
          message: 'subscription_success_message'.tr.replaceAll(
            '{sessions}',
            '${selectedPlan!.sessions}',
          ),
          position: SnackPosition.TOP,
          backgroundColor: Colors.green,
        );

        await Future.delayed(const Duration(seconds: 1));
        Get.offAllNamed(Routes.userTabScreen, arguments: {'initialTab': 3});
      } else {
        // Create booking
        await _createBookingInSupabase();

        loggerNoStack.i('✅ Digital wallet payment and booking completed!');
        _showSafeSnackbar(
          title: 'success_str'.tr,
          message: 'payment_booking_success'.tr,
          position: SnackPosition.TOP,
          backgroundColor: Colors.green,
        );

        await Future.delayed(const Duration(seconds: 1));
        Get.offAllNamed(Routes.userTabScreen, arguments: {'initialTab': 2});
      }
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ Error handling digital wallet success: $e');
      loggerNoStack.e('Stack trace: $stackTrace');

      await _updatePaymentHistory(
        status: 'failed',
        gateway: DigitalWalletService.getPlatformPaymentName()
            .toLowerCase()
            .replaceAll(' ', '_'),
        currency: 'USD',
      );

      _showSafeSnackbar(
        title: 'error'.tr,
        message: 'failed_to_process_payment_try_again'.tr,
        position: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
    } finally {
      // Clean up payment intent after processing is complete
      stripePaymentIntent = null;
      digitalWalletPaymentIntentId = null;
      loggerNoStack.i(
        '=== Digital Wallet Payment Success Handler Complete ===',
      );
    }
  }

  /// Confirm digital wallet payment with Stripe
  Future<bool> _confirmDigitalWalletPayment(String token) async {
    try {
      loggerNoStack.i('🔒 Confirming digital wallet payment with Stripe...');

      // Check if payment intent ID exists
      if (digitalWalletPaymentIntentId == null ||
          digitalWalletPaymentIntentId!.isEmpty) {
        loggerNoStack.e(
          '❌ Payment intent ID is null or empty, cannot confirm payment',
        );
        return false;
      }

      loggerNoStack.i(
        '💳 Using payment intent ID: $digitalWalletPaymentIntentId',
      );

      // Decode the token (it's usually a JSON string)
      final tokenData = jsonDecode(token);

      // Confirm the payment intent with the token
      final response = await http.post(
        Uri.parse(
          'https://api.stripe.com/v1/payment_intents/$digitalWalletPaymentIntentId/confirm',
        ),
        headers: {
          'Authorization': 'Bearer $stripeSecretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'payment_method_data[type]': 'card',
          'payment_method_data[card][token]': tokenData['id'] ?? token,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        loggerNoStack.i('✅ Payment confirmed successfully');
        loggerNoStack.d('Confirmation data: $data');
        return data['status'] == 'succeeded';
      } else {
        loggerNoStack.e('❌ Payment confirmation failed: ${response.body}');
        return false;
      }
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ Error confirming digital wallet payment: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
      return false;
    }
  }

  void processPayment() async {
    loggerNoStack.i('=== Processing Payment ===');
    loggerNoStack.i('Selected payment method: ${selectedPaymentMethod.value}');

    if (isProcessingPayment.value) {
      loggerNoStack.w(
        'Payment already in progress, ignoring duplicate request',
      );
      return;
    }

    try {
      if (selectedPaymentMethod.value == 0) {
        // Digital Wallet (Apple Pay/Google Pay)
        loggerNoStack.i('Digital Wallet selected - initiating payment...');
        await _processDigitalWalletPayment();
        return;
      } else if (selectedPaymentMethod.value == 1) {
        // Card (Visa/Mastercard) payment via Stripe (USD)
        loggerNoStack.i('Processing card payment via Stripe...');
        await _processStripePayment();
        return;
      } else if (selectedPaymentMethod.value == 2) {
        // Bankily payment (MRU)
        loggerNoStack.i('Processing payment via Bankily...');
        await processBankilyPayment();
        return; // Don't set isProcessingPayment to false here, it's handled in processBankilyPayment
      } else {
        // Fallback for unknown payment methods - use detected gateway/currency
        final pay = getPaymentGatewayAndCurrency();
        isProcessingPayment.value = true;
        await _savePaymentHistory(
          status: 'waiting',
          gateway: pay.gateway,
          currency: pay.currency,
        );

        try {
          // Get the make appointment controller
          final makeAppointmentController =
              Get.find<MakeAppointmentController>();

          // Process other payment methods
          loggerNoStack.i('Processing other payment method...');
          await makeAppointmentController.bookAppointment(type: "online");

          // If booking succeeds, update records to success
          final pay = getPaymentGatewayAndCurrency();
          await _updatePaymentHistory(
            status: 'success',
            gateway: pay.gateway,
            currency: pay.currency,
          );

          // Mark coupon as used if a coupon was applied
          if (couponController.text.trim().isNotEmpty && discount.value > 0) {
            loggerNoStack.i(
              '🎫 Marking coupon as used for other payment method...',
            );
            await _markCouponAsUsed(couponController.text.trim());
          }

          loggerNoStack.i('Payment and booking completed successfully');
        } catch (paymentError) {
          // If payment/booking fails, update records to failed
          final pay = getPaymentGatewayAndCurrency();
          await _updatePaymentHistory(
            status: 'failed',
            gateway: pay.gateway,
            currency: pay.currency,
          );

          loggerNoStack.e('Payment failed: $paymentError');
          rethrow; // Re-throw to be caught by outer catch
        }
      }
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ CRITICAL ERROR in processPayment: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
      Get.snackbar(
        'error'.tr,
        'payment_failed'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (selectedPaymentMethod.value != 1 &&
          selectedPaymentMethod.value != 2) {
        isProcessingPayment.value = false;
      }
      loggerNoStack.i('=== Payment Process Complete ===');
    }
  }

  @override
  void onClose() {
    try {
      loggerNoStack.i('Disposing PaymentController resources');
      couponController.dispose();
      phoneController.dispose();
      passcodeController.dispose();
      cardNumberController.dispose();
      cardHolderNameController.dispose();
      expirationDateController.dispose();
      cvvController.dispose();
      super.onClose();
      loggerNoStack.i('PaymentController disposed successfully');
    } catch (e, stackTrace) {
      loggerNoStack.e('Error disposing PaymentController: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
    }
  }
}

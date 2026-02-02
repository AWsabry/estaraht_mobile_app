import 'dart:io';

import 'package:flutter/services.dart';
import 'package:pay/pay.dart';
import 'package:videocalling/core/config/app_variables.dart';
import 'package:videocalling/core/utils/logger.dart';

/// Service for handling Apple Pay and Google Pay payments via Stripe
class DigitalWalletService {
  /// Get Apple Pay configuration
  /// Merchant ID configured in Apple Developer Console
  static PaymentConfiguration getApplePayConfig() {
    // Apple Merchant ID: merchant.com.estaraht.appname
    const merchantId = 'merchant.com.estaraht.appname';

    loggerNoStack.i('🍎 Configuring Apple Pay with Merchant ID: $merchantId');

    return PaymentConfiguration.fromJsonString('''
    {
      "provider": "apple_pay",
      "data": {
        "merchantIdentifier": "$merchantId",
        "displayName": "Estaraht",
        "merchantCapabilities": ["3DS", "debit", "credit"],
        "supportedNetworks": ["visa", "masterCard", "amex", "discover"],
        "countryCode": "US",
        "currencyCode": "USD"
      }
    }
    ''');
  }

  /// Get Google Pay configuration
  /// Uses Stripe as the payment gateway
  static PaymentConfiguration getGooglePayConfig() {
    loggerNoStack.i('📱 Configuring Google Pay with Stripe');

    return PaymentConfiguration.fromJsonString('''
    {
      "provider": "google_pay",
      "data": {
        "environment": "TEST",
        "apiVersion": 2,
        "apiVersionMinor": 0,
        "allowedPaymentMethods": [
          {
            "type": "CARD",
            "tokenizationSpecification": {
              "type": "PAYMENT_GATEWAY",
              "parameters": {
                "gateway": "stripe",
                "stripe:version": "2018-10-31",
                "stripe:publishableKey": "$stripePublisherKey"
              }
            },
            "parameters": {
              "allowedCardNetworks": ["VISA", "MASTERCARD", "AMEX", "DISCOVER"],
              "allowedAuthMethods": ["PAN_ONLY", "CRYPTOGRAM_3DS"],
              "billingAddressRequired": false,
              "billingAddressParameters": {
                "format": "MIN",
                "phoneNumberRequired": false
              }
            }
          }
        ],
        "merchantInfo": {
          "merchantName": "Estaraht"
        },
        "transactionInfo": {
          "countryCode": "US",
          "currencyCode": "USD"
        }
      }
    }
    ''');
  }

  /// Load payment configuration from JSON file in assets
  static Future<PaymentConfiguration> loadPaymentConfigFromAsset(
    String platform,
  ) async {
    try {
      final configString = platform == 'apple_pay'
          ? await rootBundle.loadString('assets/apple_pay_config.json')
          : await rootBundle.loadString('assets/google_pay_config.json');

      return PaymentConfiguration.fromJsonString(configString);
    } catch (e) {
      loggerNoStack.e('❌ Error loading payment config from asset: $e');
      // Fallback to hardcoded config
      return platform == 'apple_pay'
          ? getApplePayConfig()
          : getGooglePayConfig();
    }
  }

  /// Check if digital wallet payment is available
  static bool isPlatformSupported() {
    return Platform.isIOS || Platform.isAndroid;
  }

  /// Get platform name for display
  static String getPlatformPaymentName() {
    if (Platform.isIOS) {
      return 'Apple Pay';
    } else if (Platform.isAndroid) {
      return 'Google Pay';
    }
    return 'Digital Wallet';
  }

  /// Create payment items for Apple Pay/Google Pay
  static List<PaymentItem> createPaymentItems({
    required double amount,
    required String label,
    String? type,
  }) {
    loggerNoStack.d(
      '💰 Creating payment items - Amount: \$${amount.toStringAsFixed(2)}, Label: $label',
    );

    return [
      PaymentItem(
        label: label,
        amount: amount.toStringAsFixed(2),
        status: PaymentItemStatus.final_price,
        type: type != null
            ? PaymentItemType.values.firstWhere(
                (e) => e.toString().split('.').last == type,
                orElse: () => PaymentItemType.item,
              )
            : PaymentItemType.total,
      ),
    ];
  }

  /// Create detailed payment items with breakdown
  static List<PaymentItem> createDetailedPaymentItems({
    required double subtotal,
    required double discount,
    required double total,
  }) {
    loggerNoStack.d(
      '📋 Creating detailed payment items - '
      'Subtotal: \$${subtotal.toStringAsFixed(2)}, '
      'Discount: \$${discount.toStringAsFixed(2)}, '
      'Total: \$${total.toStringAsFixed(2)}',
    );

    final items = <PaymentItem>[
      PaymentItem(
        label: 'Consultation Fee',
        amount: subtotal.toStringAsFixed(2),
        status: PaymentItemStatus.final_price,
        type: PaymentItemType.item,
      ),
    ];

    if (discount > 0) {
      items.add(
        PaymentItem(
          label: 'Discount',
          amount: '-${discount.toStringAsFixed(2)}',
          status: PaymentItemStatus.final_price,
          type: PaymentItemType.item,
        ),
      );
    }

    // Add total as the last item
    items.add(
      PaymentItem(
        label: 'Estaraht',
        amount: total.toStringAsFixed(2),
        status: PaymentItemStatus.final_price,
        type: PaymentItemType.total,
      ),
    );

    return items;
  }
}

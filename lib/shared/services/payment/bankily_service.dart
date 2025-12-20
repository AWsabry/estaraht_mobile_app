import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/core/utils/logger.dart';

class BankilyService {
  // Supabase helper instance
  final SupabaseHelper supabaseHelper = SupabaseHelper();

  // Configuration parameters from database
  String? _paymentUrl;
  String? _authentificationUrl;
  String? _checkTransactionUrl;
  String? _username;
  String? _password;
  String? _clientId;
  String? commercentCode;

  // Store authentication tokens
  String? _accessToken;
  String? _refreshToken;
  DateTime? _tokenExpiry;
  DateTime? _refreshTokenExpiry;

  // Singleton pattern
  static final BankilyService _instance = BankilyService._internal();
  factory BankilyService() => _instance;
  BankilyService._internal();

  /// Initialize the service by loading configuration from database
  Future<bool> init() async {
    try {
      loggerNoStack.i('🔧 Initializing Bankily service...');

      final response = await supabaseHelper.client
          .from('bankily_params')
          .select('*')
          .limit(1)
          .maybeSingle();

      if (response == null) {
        loggerNoStack.e('❌ No Bankily configuration found in database');
        return false;
      }

      // Clean and trim URLs to remove any hidden characters
      _paymentUrl = response['payment_url']?.toString().trim();
      _authentificationUrl = response['authentification_url']
          ?.toString()
          .trim();
      _checkTransactionUrl = response['check_transaction_url']
          ?.toString()
          .trim();
      _username = response['username']?.toString().trim();
      _password = response['password']?.toString().trim();
      _clientId = response['client_id']?.toString().trim();
      commercentCode = response['commercant_code']?.toString().trim();

      // Additional cleaning for URLs - remove any BOM or invisible characters
      if (_paymentUrl != null) {
        _paymentUrl = _paymentUrl!.replaceAll(RegExp(r'[^\x20-\x7E]'), '');
      }
      if (_authentificationUrl != null) {
        _authentificationUrl = _authentificationUrl!.replaceAll(
          RegExp(r'[^\x20-\x7E]'),
          '',
        );
      }
      if (_checkTransactionUrl != null) {
        _checkTransactionUrl = _checkTransactionUrl!.replaceAll(
          RegExp(r'[^\x20-\x7E]'),
          '',
        );
      }

      loggerNoStack.i('✅ Bankily service initialized successfully');
      loggerNoStack.d('Authentication URL: [$_authentificationUrl]');
      loggerNoStack.d('Payment URL: [$_paymentUrl]');
      loggerNoStack.d('Check Transaction URL: [$_checkTransactionUrl]');
      loggerNoStack.d('Client ID: [$_clientId]');
      loggerNoStack.d('Username: [$_username]');

      return true;
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ Failed to initialize Bankily service: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Authenticate with Bankily using username and password
  Future<Map<String, dynamic>> authenticate({
    required String username,
    required String password,
  }) async {
    try {
      loggerNoStack.i('🔐 Authenticating with Bankily...');
      loggerNoStack.d('Username: $username');
      loggerNoStack.d('Client ID: $_clientId');
      loggerNoStack.d('Auth URL: [$_authentificationUrl]');

      // Validate URL before parsing
      if (_authentificationUrl == null || _authentificationUrl!.isEmpty) {
        loggerNoStack.e('❌ Authentication URL is null or empty');
        return {
          'success': false,
          'error': 'Configuration error',
          'message': 'Authentication URL not configured',
        };
      }

      // Clean URL and ensure it's properly formatted
      String cleanUrl = _authentificationUrl!.trim();
      if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
        cleanUrl = 'https://$cleanUrl';
      }

      loggerNoStack.d('Using cleaned URL: [$cleanUrl]');

      // Prepare request body
      final requestBody = {
        'grant_type': 'password',
        'username': username,
        'password': password,
        'client_id': _clientId ?? 'ebankily',
      };

      loggerNoStack.d('Request body: $requestBody');

      final response = await http
          .post(
            Uri.parse(cleanUrl),
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded',
              'Accept': 'application/json',
            },
            body: requestBody,
          )
          .timeout(const Duration(seconds: 30));

      loggerNoStack.i('Authentication response status: ${response.statusCode}');
      loggerNoStack.d('Authentication response headers: ${response.headers}');
      loggerNoStack.d('Authentication response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Store tokens
        _accessToken = data['access_token'];
        _refreshToken = data['refresh_token'];

        // Calculate expiry times
        if (data['expires_in'] != null) {
          int expiresIn = int.tryParse(data['expires_in'].toString()) ?? 3600;
          _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn));
          loggerNoStack.d('Access token expires in: $expiresIn seconds');
        }

        if (data['refresh_expires_in'] != null) {
          int refreshExpiresIn =
              int.tryParse(data['refresh_expires_in'].toString()) ?? 86400;
          _refreshTokenExpiry = DateTime.now().add(
            Duration(seconds: refreshExpiresIn),
          );
          loggerNoStack.d(
            'Refresh token expires in: $refreshExpiresIn seconds',
          );
        }

        loggerNoStack.i('✅ Authentication successful');

        return {
          'success': true,
          'access_token': _accessToken,
          'refresh_token': _refreshToken,
          'expires_in': data['expires_in'],
          'refresh_expires_in': data['refresh_expires_in'],
        };
      } else {
        loggerNoStack.e('❌ Authentication failed: ${response.statusCode}');
        loggerNoStack.e('Response body: ${response.body}');

        // Try to parse error response
        String errorMessage = 'Authentication failed: ${response.statusCode}';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['error'] != null) {
            errorMessage = errorData['error'];
          } else if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          }
        } catch (e) {
          // If response is not JSON, use the raw body
          if (response.body.isNotEmpty) {
            errorMessage = response.body;
          }
        }

        return {
          'success': false,
          'error': 'Authentication failed: ${response.statusCode}',
          'message': errorMessage,
        };
      }
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ CRITICAL ERROR during authentication: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
      return {
        'success': false,
        'error': 'Authentication error',
        'message': e.toString(),
      };
    }
  }

  /// Refresh the access token using refresh token
  Future<Map<String, dynamic>> refreshAccessToken() async {
    try {
      if (_refreshToken == null) {
        loggerNoStack.e('❌ No refresh token available');
        return {'success': false, 'error': 'No refresh token available'};
      }

      loggerNoStack.i('🔄 Refreshing access token...');

      // Clean URL same as in authenticate method
      String cleanUrl = _authentificationUrl!.trim();
      if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
        cleanUrl = 'https://$cleanUrl';
      }

      final response = await http
          .post(
            Uri.parse(cleanUrl),
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded',
              'Accept': 'application/json',
            },
            body: {
              'grant_type': 'refresh_token',
              'refresh_token': _refreshToken!,
              'client_id': _clientId ?? 'ebankily',
            },
          )
          .timeout(const Duration(seconds: 30));

      loggerNoStack.d('Refresh token response status: ${response.statusCode}');
      loggerNoStack.d('Refresh token response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Update tokens
        _accessToken = data['access_token'];
        _refreshToken = data['refresh_token'];

        // Update expiry times
        if (data['expires_in'] != null) {
          int expiresIn = int.tryParse(data['expires_in'].toString()) ?? 3600;
          _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn));
        }

        if (data['refresh_expires_in'] != null) {
          int refreshExpiresIn =
              int.tryParse(data['refresh_expires_in'].toString()) ?? 86400;
          _refreshTokenExpiry = DateTime.now().add(
            Duration(seconds: refreshExpiresIn),
          );
        }

        loggerNoStack.i('✅ Token refresh successful');

        return {
          'success': true,
          'access_token': _accessToken,
          'refresh_token': _refreshToken,
        };
      } else {
        loggerNoStack.e('❌ Token refresh failed: ${response.statusCode}');
        loggerNoStack.e('Response body: ${response.body}');
        return {
          'success': false,
          'error': 'Token refresh failed',
          'message': response.body,
        };
      }
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ Token refresh error: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
      return {
        'success': false,
        'error': 'Token refresh error',
        'message': e.toString(),
      };
    }
  }

  /// Check if token is expired and refresh if needed
  Future<bool> ensureValidToken() async {
    try {
      if (_accessToken == null) {
        loggerNoStack.w('⚠️ No access token available');
        return false;
      }

      // Check if token is about to expire (within 5 minutes)
      if (_tokenExpiry != null &&
          DateTime.now()
              .add(const Duration(minutes: 5))
              .isAfter(_tokenExpiry!)) {
        loggerNoStack.w('⏰ Access token expiring soon, refreshing...');
        final result = await refreshAccessToken();
        return result['success'] == true;
      }

      loggerNoStack.d('✅ Access token is valid');
      return true;
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ Error validating token: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Process a payment through Bankily
  /// Returns errorCode, errorMessage, and transactionId
  Future<Map<String, dynamic>> processPayment({
    required String clientPhone,
    required String passcode,
    required String operationId,
    required String amount,
    String language = 'FR',
  }) async {
    try {
      loggerNoStack.i('💳 Processing Bankily payment...');
      loggerNoStack.d('Client Phone: $clientPhone');
      loggerNoStack.d('Operation ID: $operationId');
      loggerNoStack.d('Amount: $amount');
      loggerNoStack.d('Language: $language');

      // Ensure we have a valid token
      if (!await ensureValidToken()) {
        loggerNoStack.e('❌ Invalid or expired token');
        return {
          'errorCode': '2',
          'errorMessage':
              'Invalid or expired token. Please authenticate first.',
          'transactionId': null,
        };
      }

      loggerNoStack.i('Sending payment request to Bankily API...');
      // Format amount: replace decimal dot with comma (e.g. "57.50" -> "57,50")
      // dart
      final String cleanAmount = amount.split(
        RegExp(r'[,.]'),
      )[0]; // keep only before comma/dot
      final String formattedAmount = cleanAmount; // no *100, no decimals
      loggerNoStack.d('Amount (integer only): $formattedAmount');

      final response = await http.post(
        Uri.parse('$_paymentUrl'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
        body: jsonEncode({
          'clientPhone': clientPhone,
          'passcode': passcode,
          'operationId': operationId,
          'amount': formattedAmount,
          'language': language,
        }),
      );
      loggerNoStack.d(
        'Payment request headers: ${jsonEncode({'clientPhone': clientPhone, 'passcode': passcode, 'operationId': operationId, 'amount': formattedAmount, 'language': language})}',
      );

      loggerNoStack.i('Payment response status: ${response.statusCode}');
      loggerNoStack.d('Payment response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final errorCode = data['errorCode']?.toString() ?? '1';
        final errorMessage =
            data['errorMessage']?.toString() ?? 'Unknown error';
        final transactionId = data['transactionId']?.toString();

        loggerNoStack.i(
          'Payment API response - errorCode: $errorCode, transactionId: $transactionId',
        );

        if (errorCode == '0') {
          loggerNoStack.i(
            '✅ Payment successful! Transaction ID: $transactionId',
          );
        } else {
          loggerNoStack.e('❌ Payment failed - Error: $errorMessage');
        }

        return {
          'errorCode': errorCode,
          'errorMessage': errorMessage,
          'transactionId': transactionId,
        };
      } else {
        loggerNoStack.e(
          '❌ Payment request failed with status: ${response.statusCode}',
        );
        loggerNoStack.e('Response body: ${response.body}');
        return {
          'errorCode': '1',
          'errorMessage': 'Payment request failed: ${response.statusCode}',
          'transactionId': null,
        };
      }
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ CRITICAL ERROR in processPayment: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
      return {
        'errorCode': '1',
        'errorMessage': 'Payment error: $e',
        'transactionId': null,
      };
    }
  }

  /// Check the status of a transaction
  /// Returns errorCode, errorMessage, transactionId, and status
  Future<Map<String, dynamic>> checkTransaction({
    required String operationId,
  }) async {
    try {
      loggerNoStack.i('🔍 Checking transaction status...');
      loggerNoStack.d('Operation ID: $operationId');

      // Ensure we have a valid token
      if (!await ensureValidToken()) {
        loggerNoStack.e('❌ Invalid or expired token');
        return {
          'errorCode': '1',
          'errorMessage':
              'Invalid or expired token. Please authenticate first.',
          'transactionId': null,
          'status': null,
        };
      }

      final response = await http.post(
        Uri.parse('$_checkTransactionUrl'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
        body: jsonEncode({'operationId': operationId}),
      );

      loggerNoStack.i(
        'Check transaction response status: ${response.statusCode}',
      );
      loggerNoStack.d('Check transaction response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final errorCode = data['errorCode']?.toString() ?? '1';
        final status = data['status']?.toString();

        loggerNoStack.i('Transaction status: $status (errorCode: $errorCode)');

        return {
          'errorCode': errorCode,
          'errorMessage': data['errorMessage']?.toString() ?? '',
          'transactionId': data['transactionId']?.toString(),
          'status': status, // TS, TF, TA
        };
      } else {
        loggerNoStack.e(
          '❌ Check transaction failed with status: ${response.statusCode}',
        );
        loggerNoStack.e('Response body: ${response.body}');
        return {
          'errorCode': '1',
          'errorMessage': 'Check transaction failed: ${response.statusCode}',
          'transactionId': null,
          'status': null,
        };
      }
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ CRITICAL ERROR in checkTransaction: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
      return {
        'errorCode': '1',
        'errorMessage': 'Check transaction error: $e',
        'transactionId': null,
        'status': null,
      };
    }
  }

  /// Authenticate using stored credentials from database
  Future<Map<String, dynamic>> authenticateWithStoredCredentials() async {
    try {
      if (_username == null || _password == null) {
        loggerNoStack.e(
          '❌ No stored credentials available. Please initialize service first.',
        );
        return {
          'success': false,
          'error': 'No stored credentials available',
          'message':
              'Service not initialized or credentials not found in database',
        };
      }

      loggerNoStack.i('🔐 Authenticating with stored credentials...');
      return await authenticate(username: _username!, password: _password!);
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ Error authenticating with stored credentials: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
      return {
        'success': false,
        'error': 'Authentication error',
        'message': e.toString(),
      };
    }
  }

  /// Initialize and authenticate in one call
  Future<Map<String, dynamic>> initializeAndAuthenticate() async {
    try {
      loggerNoStack.i('🚀 Initializing and authenticating Bankily service...');

      // First initialize the service
      final initResult = await init();

      if (!initResult) {
        return {
          'success': false,
          'error': 'Initialization failed',
          'message': 'Could not load Bankily configuration from database',
        };
      }

      // Then authenticate with stored credentials
      return await authenticateWithStoredCredentials();
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ Error in initializeAndAuthenticate: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
      return {
        'success': false,
        'error': 'Initialization and authentication error',
        'message': e.toString(),
      };
    }
  }

  /// Update configuration in database
  Future<bool> updateConfiguration({
    required String paymentUrl,
    required String authentificationUrl,
    required String checkTransactionUrl,
    required String username,
    required String password,
    required String clientId,
  }) async {
    try {
      loggerNoStack.i('💾 Updating Bankily configuration in database...');

      // Check if configuration exists
      final existing = await supabaseHelper.client
          .from('bankily_params')
          .select('id')
          .limit(1)
          .maybeSingle();

      final configData = {
        'payment_url': paymentUrl,
        'authentification_url': authentificationUrl,
        'check_transaction_url': checkTransactionUrl,
        'username': username,
        'password': password,
        'client_id': _clientId,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (existing != null) {
        // Update existing configuration
        await supabaseHelper.client
            .from('bankily_params')
            .update(configData)
            .eq('id', existing['id']);
        loggerNoStack.i('✅ Configuration updated successfully');
      } else {
        // Insert new configuration
        await supabaseHelper.client.from('bankily_params').insert(configData);
        loggerNoStack.i('✅ Configuration inserted successfully');
      }

      // Reload configuration
      await init();

      return true;
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ Error updating configuration: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Get current configuration from database
  Future<Map<String, dynamic>?> getConfiguration() async {
    try {
      final response = await supabaseHelper.client
          .from('bankily_params')
          .select('*')
          .limit(1)
          .maybeSingle();

      return response;
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ Error getting configuration: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Process payment with auto-authentication
  Future<Map<String, dynamic>> processPaymentWithAuth({
    required String clientPhone,
    required String passcode,
    required String operationId,
    required String amount,
    String language = 'FR',
  }) async {
    try {
      // Ensure service is initialized and authenticated
      if (!isAuthenticated) {
        loggerNoStack.i(
          '🔄 Not authenticated, initializing and authenticating...',
        );
        final authResult = await initializeAndAuthenticate();
        if (authResult['success'] != true) {
          return {
            'errorCode': '2',
            'errorMessage': 'Authentication failed: ${authResult['message']}',
            'transactionId': null,
          };
        }
      }

      // Process the payment
      return await processPayment(
        clientPhone: clientPhone,
        passcode: passcode,
        operationId: operationId,
        amount: amount,
        language: language,
      );
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ Error in processPaymentWithAuth: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
      return {
        'errorCode': '1',
        'errorMessage': 'Payment processing error: $e',
        'transactionId': null,
      };
    }
  }

  /// Check transaction with auto-authentication
  Future<Map<String, dynamic>> checkTransactionWithAuth({
    required String operationId,
  }) async {
    try {
      // Ensure service is initialized and authenticated
      if (!isAuthenticated) {
        loggerNoStack.i(
          '🔄 Not authenticated, initializing and authenticating...',
        );
        final authResult = await initializeAndAuthenticate();
        if (authResult['success'] != true) {
          return {
            'errorCode': '1',
            'errorMessage': 'Authentication failed: ${authResult['message']}',
            'transactionId': null,
            'status': null,
          };
        }
      }

      // Check the transaction
      return await checkTransaction(operationId: operationId);
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ Error in checkTransactionWithAuth: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
      return {
        'errorCode': '1',
        'errorMessage': 'Transaction check error: $e',
        'transactionId': null,
        'status': null,
      };
    }
  }

  /// Get readable status description
  String getStatusDescription(String? status) {
    switch (status?.toUpperCase()) {
      case 'TS':
        return 'Transaction Success - Payment completed successfully';
      case 'TF':
        return 'Transaction Failed - Payment failed';
      case 'TA':
        return 'Transaction Pending - Payment is being processed';
      default:
        return 'Unknown Status - ${status ?? 'No status available'}';
    }
  }

  /// Get readable error code description
  String getErrorCodeDescription(String? errorCode) {
    switch (errorCode) {
      case '0':
        return 'Success - Operation completed successfully';
      case '1':
        return 'Error - General error occurred';
      case '2':
        return 'Invalid Token - Authentication token is invalid or expired';
      case '4':
        return 'Operation ID Required - Operation ID parameter is missing';
      default:
        return 'Unknown Error Code - ${errorCode ?? 'No error code available'}';
    }
  }

  /// Get the current access token
  String? get accessToken => _accessToken;

  /// Check if authenticated
  bool get isAuthenticated =>
      _accessToken != null &&
      (_tokenExpiry == null || DateTime.now().isBefore(_tokenExpiry!));

  /// Clear all tokens (logout)
  void clearTokens() {
    _accessToken = null;
    _refreshToken = null;
    _tokenExpiry = null;
    _refreshTokenExpiry = null;
    loggerNoStack.i('🔓 Bankily tokens cleared');
  }

  /// Check if service is properly configured
  bool get isConfigured =>
      _paymentUrl != null &&
      _authentificationUrl != null &&
      _checkTransactionUrl != null &&
      _username != null &&
      _password != null &&
      _clientId != null;

  /// Get configuration status
  Map<String, dynamic> get configurationStatus => {
    'isConfigured': isConfigured,
    'isAuthenticated': isAuthenticated,
    'hasAccessToken': _accessToken != null,
    'hasRefreshToken': _refreshToken != null,
    'tokenExpiry': _tokenExpiry?.toIso8601String(),
    'refreshTokenExpiry': _refreshTokenExpiry?.toIso8601String(),
  };
}

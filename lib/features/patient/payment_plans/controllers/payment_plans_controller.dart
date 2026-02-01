import 'package:get/get.dart';
import 'package:videocalling/shared/services/others/timezone_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:videocalling/core/utils/logger.dart';
import 'package:videocalling/features/patient/payment_plans/models/payment_plan_model.dart';
import 'package:videocalling/shared/services/auth/firebase_helper.dart';
import 'package:videocalling/shared/services/invoice_service.dart';
import 'package:videocalling/shared/services/storage/storage_service.dart';
import 'package:videocalling/shared/services/subscription_expiry_service.dart';

class PaymentPlansController extends GetxController {
  final supabase = Supabase.instance.client;

  // Observable lists
  final RxList<PaymentPlan> allPlans = <PaymentPlan>[].obs;
  final RxList<PaymentPlan> availablePlans = <PaymentPlan>[].obs;
  final RxList<PatientPlanSubscription> subscriptionHistory =
      <PatientPlanSubscription>[].obs;

  // Loading states
  final RxBool isLoadingPlans = true.obs;
  final RxBool isLoadingHistory = true.obs;
  final RxBool isProcessingPayment = false.obs;

  // Patient subscription status
  final RxBool subscribedBefore = false.obs;
  final RxBool currentlySubscribed = false.obs;
  final RxInt sessionsAvailable = 0.obs;
  final RxInt sessionsPending = 0.obs;

  // Selected plan for purchase
  final Rxn<PaymentPlan> selectedPlan = Rxn<PaymentPlan>();

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  /// Initialize data sequentially to ensure patient status is loaded before filtering plans
  Future<void> _initializeData() async {
    final user = firebaseHelper.currentUser;
    if (user != null) {
      // Check if subscription has expired first
      if (Get.isRegistered<SubscriptionExpiryService>()) {
        await Get.find<SubscriptionExpiryService>().checkSubscriptionExpiry(
          user.uid,
        );
      }
    }
    await loadPatientStatus(); // Wait for status first
    await loadPaymentPlans(); // Then load and filter plans
    loadSubscriptionHistory(); // Can run independently
  }

  /// Load patient subscription status
  Future<void> loadPatientStatus() async {
    try {
      // Try Firebase Auth first, fallback to StorageService
      String? patientId = firebaseHelper.currentUser?.uid;

      if (patientId == null) {
        // Fallback to local storage
        final storedUserId = StorageService.readData(key: LocalStorageKeys.userId);
        if (storedUserId != null && storedUserId.toString().isNotEmpty) {
          patientId = storedUserId.toString();
          loggerNoStack.i('Using patient ID from local storage: $patientId');
        } else {
          loggerNoStack.w('! User not authenticated');
          return;
        }
      } else {
        loggerNoStack.i('Using patient ID from Firebase Auth: $patientId');
      }

      final patientData = await supabase
          .from('patients')
          .select(
            'subscribed, subscribed_before, sessions_available, sessions_pending',
          )
          .eq('id', patientId)
          .single();

      subscribedBefore.value = patientData['subscribed_before'] ?? false;
      currentlySubscribed.value = patientData['subscribed'] ?? false;
      sessionsAvailable.value = patientData['sessions_available'] ?? 0;
      sessionsPending.value = patientData['sessions_pending'] ?? 0;

      loggerNoStack.i(
        'Patient status loaded - Subscribed before: ${subscribedBefore.value}, '
        'Currently subscribed: ${currentlySubscribed.value}, '
        'Sessions available: ${sessionsAvailable.value}, '
        'Sessions pending: ${sessionsPending.value}',
      );
    } catch (e, stackTrace) {
      loggerNoStack.e('Error loading patient status: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
    }
  }

  /// Load all payment plans from database
  Future<void> loadPaymentPlans() async {
    try {
      isLoadingPlans.value = true;

      final response = await supabase
          .from('payment_plans')
          .select('*')
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      allPlans.value = (response as List)
          .map((json) => PaymentPlan.fromJson(json))
          .toList();

      // Filter plans based on subscription status
      _filterAvailablePlans();

      loggerNoStack.i('Loaded ${allPlans.length} payment plans');
    } catch (e, stackTrace) {
      loggerNoStack.e('Error loading payment plans: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
    } finally {
      isLoadingPlans.value = false;
    }
  }

  /// Filter plans based on whether patient has subscribed before
  void _filterAvailablePlans() {
    if (subscribedBefore.value) {
      // Hide first-time-only plans (40$ plan)
      availablePlans.value = allPlans
          .where((plan) => !plan.isFirstTimeOnly)
          .toList();
      loggerNoStack.i(
        'Filtered plans: Hiding first-time-only plan (subscribed before)',
      );
    } else {
      // Show all plans
      availablePlans.value = allPlans.toList();
      loggerNoStack.i('Showing all plans (new subscriber)');
    }
  }

  /// Load patient's subscription history
  Future<void> loadSubscriptionHistory() async {
    try {
      isLoadingHistory.value = true;

      final user = firebaseHelper.currentUser;
      if (user == null) {
        loggerNoStack.w('User not authenticated');
        return;
      }

      final response = await supabase
          .from('patient_plan_subscriptions')
          .select('*')
          .eq('patient_id', user.uid)
          .order('subscribed_at', ascending: false);

      subscriptionHistory.value = (response as List)
          .map((json) => PatientPlanSubscription.fromJson(json))
          .toList();

      loggerNoStack.i(
        'Loaded ${subscriptionHistory.length} subscription records',
      );
    } catch (e, stackTrace) {
      loggerNoStack.e('Error loading subscription history: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
    } finally {
      isLoadingHistory.value = false;
    }
  }

  /// Select a plan for purchase
  void selectPlan(PaymentPlan plan) {
    selectedPlan.value = plan;
    loggerNoStack.i(
      'Selected plan: ${plan.planName} (${plan.sessions} sessions, \$${plan.price})',
    );
  }

  /// Process subscription payment and add sessions to patient account
  Future<void> subscribeToPlan({
    required PaymentPlan plan,
    required String paymentGateway,
    required String paymentId,
    String? paymentCurrency,
  }) async {
    try {
      isProcessingPayment.value = true;
      loggerNoStack.i('Processing subscription to plan: ${plan.planName}');

      // Get userId from SharedPreferences (StorageService)
      final patientId = StorageService.readData(key: LocalStorageKeys.userId);
      if (patientId == null || patientId.toString().isEmpty) {
        throw Exception('User not authenticated');
      }
      final String oddddddd = patientId.toString();
      loggerNoStack.i('Patient ID from storage: $oddddddd');

      // Calculate expiry date (30 days from now)
      // For first-time-only plan, no expiry (one-time use)
      final expiresAt = TimezoneService.getCurrentMauritaniaTime().add(const Duration(days: 30));
      final subscriptionExpiresAt = plan.isFirstTimeOnly
          ? null
          : expiresAt.toIso8601String();

      // 1. Create subscription record
      final subscriptionResponse = await supabase
          .from('patient_plan_subscriptions')
          .insert({
            'patient_id': oddddddd,
            'plan_id': plan.id,
            'payment_id': paymentId,
            'sessions_purchased': plan.sessions,
            'sessions_used': 0,
            'price_paid': plan.price,
            'payment_gateway': paymentGateway,
            'payment_currency': paymentCurrency ?? 'USD',
            'payment_status': 'completed',
            'subscribed_at': TimezoneService.getCurrentMauritaniaTime().toIso8601String(),
            'expires_at': subscriptionExpiresAt,
            'status': 'active',
          })
          .select('id')
          .single();

      final subscriptionId = subscriptionResponse['id'];
      loggerNoStack.i('Subscription record created with ID: $subscriptionId');

      // 2. Update patient - RESET sessions to plan amount (not accumulate)
      await supabase
          .from('patients')
          .update({
            'sessions_available': plan.sessions, // RESET, not add
            'subscribed': true,
            'subscribed_before': true,
            'subscription_expires_at': subscriptionExpiresAt,
            'current_subscription_id': subscriptionId,
          })
          .eq('id', oddddddd);

      loggerNoStack.i(
        'Patient sessions reset to: ${plan.sessions} (expires: $subscriptionExpiresAt)',
      );

      // 3. Refresh patient status
      await loadPatientStatus();
      await loadSubscriptionHistory();

      // 4. Refresh available plans (to hide 40$ plan if applicable)
      _filterAvailablePlans();

      // 5. Send subscription invoice email
      try {
        loggerNoStack.i('📧 Attempting to send subscription invoice email...');

        final patientData = await supabase
            .from('patients')
            .select('email, name')
            .eq('id', oddddddd)
            .maybeSingle();

        loggerNoStack.i('📧 Patient data for email: $patientData');

        if (patientData != null && patientData['email'] != null) {
          loggerNoStack.i('📧 Sending invoice to: ${patientData['email']}');

          final emailSent = await invoiceService.sendSubscriptionInvoice(
            patientEmail: patientData['email'],
            patientName: patientData['name'] ?? 'Patient',
            planName: plan.planName,
            sessionsCount: plan.sessions,
            amount: plan.price.toString(),
            currency: paymentCurrency ?? 'USD',
            paymentMethod: paymentGateway,
          );

          if (emailSent) {
            loggerNoStack.i(
              '✅ Subscription invoice sent successfully to ${patientData['email']}',
            );
          } else {
            loggerNoStack.w(
              '⚠️ Failed to send subscription invoice - emailSent returned false',
            );
          }
        } else {
          loggerNoStack.w(
            '⚠️ Patient email not found in database, skipping invoice. Data: $patientData',
          );
        }
      } catch (emailError, emailStackTrace) {
        loggerNoStack.e('❌ Error sending invoice email: $emailError');
        loggerNoStack.e('❌ Stack trace: $emailStackTrace');
      }

      loggerNoStack.i('Subscription completed successfully');
    } catch (e, stackTrace) {
      loggerNoStack.e('Error processing subscription: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
      rethrow;
    } finally {
      isProcessingPayment.value = false;
    }
  }

  /// Process subscription payment with explicit patientId (for when Firebase auth may not be available)
  Future<void> subscribeToPlanWithUserId({
    required PaymentPlan plan,
    required String patientId,
    required String paymentGateway,
    required String paymentId,
    String? paymentCurrency,
  }) async {
    try {
      isProcessingPayment.value = true;
      loggerNoStack.i(
        'Processing subscription to plan: ${plan.planName} for patient: $patientId',
      );

      // Verify patient exists in database before proceeding
      final existingPatient = await supabase
          .from('patients')
          .select('id')
          .eq('id', patientId)
          .maybeSingle();

      if (existingPatient == null) {
        loggerNoStack.e('❌ Patient not found in database: $patientId');
        throw Exception(
          'Patient record not found. Please contact support or try logging out and back in.',
        );
      }

      // Calculate expiry date (30 days from now)
      // For first-time-only plan, no expiry (one-time use)
      final expiresAt = TimezoneService.getCurrentMauritaniaTime().add(const Duration(days: 30));
      final subscriptionExpiresAt = plan.isFirstTimeOnly
          ? null
          : expiresAt.toIso8601String();

      // 1. Create subscription record
      final subscriptionResponse = await supabase
          .from('patient_plan_subscriptions')
          .insert({
            'patient_id': patientId,
            'plan_id': plan.id,
            'payment_id': paymentId,
            'sessions_purchased': plan.sessions,
            'sessions_used': 0,
            'price_paid': plan.price,
            'payment_gateway': paymentGateway,
            'payment_currency': paymentCurrency ?? 'USD',
            'payment_status': 'completed',
            'subscribed_at': TimezoneService.getCurrentMauritaniaTime().toIso8601String(),
            'expires_at': subscriptionExpiresAt,
            'status': 'active',
          })
          .select('id')
          .single();

      final subscriptionId = subscriptionResponse['id'];
      loggerNoStack.i('Subscription record created with ID: $subscriptionId');

      // 2. Update patient - RESET sessions to plan amount (not accumulate)
      await supabase
          .from('patients')
          .update({
            'sessions_available': plan.sessions, // RESET, not add
            'subscribed': true,
            'subscribed_before': true,
            'subscription_expires_at': subscriptionExpiresAt,
            'current_subscription_id': subscriptionId,
          })
          .eq('id', patientId);

      loggerNoStack.i(
        'Patient sessions reset to: ${plan.sessions} (expires: $subscriptionExpiresAt)',
      );

      // 3. Refresh patient status
      await loadPatientStatus();
      await loadSubscriptionHistory();

      // 4. Refresh available plans (to hide 40$ plan if applicable)
      _filterAvailablePlans();

      // 5. Send subscription invoice email
      try {
        loggerNoStack.i('📧 Attempting to send subscription invoice email...');

        final patientData = await supabase
            .from('patients')
            .select('email, name')
            .eq('id', patientId)
            .maybeSingle();

        loggerNoStack.i('📧 Patient data for email: $patientData');

        if (patientData != null && patientData['email'] != null) {
          loggerNoStack.i('📧 Sending invoice to: ${patientData['email']}');

          final emailSent = await invoiceService.sendSubscriptionInvoice(
            patientEmail: patientData['email'],
            patientName: patientData['name'] ?? 'Patient',
            planName: plan.planName,
            sessionsCount: plan.sessions,
            amount: plan.price.toString(),
            currency: paymentCurrency ?? 'USD',
            paymentMethod: paymentGateway,
          );

          if (emailSent) {
            loggerNoStack.i(
              '✅ Subscription invoice sent successfully to ${patientData['email']}',
            );
          } else {
            loggerNoStack.w(
              '⚠️ Failed to send subscription invoice - emailSent returned false',
            );
          }
        } else {
          loggerNoStack.w(
            '⚠️ Patient email not found in database, skipping invoice. Data: $patientData',
          );
        }
      } catch (emailError, emailStackTrace) {
        loggerNoStack.e('❌ Error sending invoice email: $emailError');
        loggerNoStack.e('❌ Stack trace: $emailStackTrace');
      }

      loggerNoStack.i('Subscription completed successfully');
    } catch (e, stackTrace) {
      loggerNoStack.e('Error processing subscription: $e');
      loggerNoStack.e('Stack trace: $stackTrace');
      rethrow;
    } finally {
      isProcessingPayment.value = false;
    }
  }

  /// Check if patient has available sessions
  bool hasAvailableSessions() {
    return sessionsAvailable.value > 0;
  }

  /// Get display text for sessions status
  String getSessionsStatusText() {
    if (sessionsAvailable.value == 0) {
      return 'no_sessions_available'.tr;
    } else if (sessionsAvailable.value == 1) {
      return '1_session_available'.tr;
    } else {
      return 'x_sessions_available'.tr.replaceAll(
        '{count}',
        sessionsAvailable.value.toString(),
      );
    }
  }
}

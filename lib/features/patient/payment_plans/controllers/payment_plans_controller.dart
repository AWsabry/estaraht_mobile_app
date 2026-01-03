import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:videocalling/core/utils/logger.dart';
import 'package:videocalling/features/patient/payment_plans/models/payment_plan_model.dart';
import 'package:videocalling/shared/services/auth/firebase_helper.dart';

class PaymentPlansController extends GetxController {
  final supabase = Supabase.instance.client;

  // Observable lists
  final RxList<PaymentPlan> allPlans = <PaymentPlan>[].obs;
  final RxList<PaymentPlan> availablePlans = <PaymentPlan>[].obs;
  final RxList<PatientPlanSubscription> subscriptionHistory = <PatientPlanSubscription>[].obs;

  // Loading states
  final RxBool isLoadingPlans = false.obs;
  final RxBool isLoadingHistory = false.obs;
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
    loadPatientStatus();
    loadPaymentPlans();
    loadSubscriptionHistory();
  }

  /// Load patient subscription status
  Future<void> loadPatientStatus() async {
    try {
      final user = firebaseHelper.currentUser;
      if (user == null) {
        loggerNoStack.w('User not authenticated');
        return;
      }

      final patientData = await supabase
          .from('patients')
          .select('subscribed, subscribed_before, sessions_available, sessions_pending')
          .eq('id', user.uid)
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
      availablePlans.value = allPlans.where((plan) => !plan.isFirstTimeOnly).toList();
      loggerNoStack.i('Filtered plans: Hiding first-time-only plan (subscribed before)');
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

      loggerNoStack.i('Loaded ${subscriptionHistory.length} subscription records');
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
    loggerNoStack.i('Selected plan: ${plan.planName} (${plan.sessions} sessions, \$${plan.price})');
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

      final user = firebaseHelper.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // 1. Create subscription record
      final subscriptionData = {
        'patient_id': user.uid,
        'plan_id': plan.id,
        'payment_id': paymentId,
        'sessions_purchased': plan.sessions,
        'sessions_used': 0,
        'price_paid': plan.price,
        'payment_gateway': paymentGateway,
        'payment_currency': paymentCurrency ?? 'USD',
        'payment_status': 'completed',
        'subscribed_at': DateTime.now().toIso8601String(),
      };

      await supabase
          .from('patient_plan_subscriptions')
          .insert(subscriptionData);

      loggerNoStack.i('Subscription record created');

      // 2. Update patient's session count and subscription status
      final currentSessions = sessionsAvailable.value;
      final newSessionCount = currentSessions + plan.sessions;

      await supabase
          .from('patients')
          .update({
            'sessions_available': newSessionCount,
            'subscribed': true,
            'subscribed_before': true,
          })
          .eq('id', user.uid);

      loggerNoStack.i(
        'Patient sessions updated: $currentSessions -> $newSessionCount',
      );

      // 3. Refresh patient status
      await loadPatientStatus();
      await loadSubscriptionHistory();

      // 4. Refresh available plans (to hide 40$ plan if applicable)
      _filterAvailablePlans();

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

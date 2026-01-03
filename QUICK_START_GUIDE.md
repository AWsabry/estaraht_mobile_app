# Quick Start Guide - Payment Plans System

## 🚀 5-Minute Setup

### Step 1: Run Database Migrations (Required)

Open your Supabase SQL Editor and run these files in order:

1. `supabase_migrations/add_patient_session_fields.sql`
2. `supabase_migrations/create_payment_plans_table.sql`
3. `supabase_migrations/add_booking_confirmation_fields.sql`

**Copy and paste** each file's contents into the SQL editor and click "Run".

### Step 2: Add Navigation (Optional but Recommended)

Add a menu item to access payment plans. In `lib/features/patient/more/pages/more_page.dart`:

```dart
// Add this ListTile in the appropriate place
ListTile(
  leading: const Icon(Icons.card_membership),
  title: Text('subscription_plans'.tr),
  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
  onTap: () => Get.toNamed(Routes.paymentPlansScreen),
),
```

### Step 3: Add Translations (Required)

Add to your English translations:

```dart
'subscription_plans': 'Subscription Plans',
'your_sessions': 'Your Sessions',
'available': 'Available',
'pending': 'Pending',
'no_sessions_available': 'No Sessions Available',
'please_subscribe_to_continue': 'Please subscribe to a plan to book appointments',
```

Add Arabic translations similarly.

### Step 4: Test the Flow

1. **Register a new patient** → Should have 0 sessions
2. **Try to book appointment** → Should be redirected to plans
3. **Subscribe to a plan** (you'll need to integrate payment - see below)
4. **Book appointment** → Should deduct from sessions_available
5. **Cancel appointment** → Should return session to sessions_available

## 🔧 Integration Points

### Integrating Plan Payment with Bankily/Stripe

In `lib/features/patient/payment/controllers/payment_controller.dart`, add this after successful payment:

```dart
// After successful payment in processBankilyPayment() or _processStripePayment()
// Check if this is a plan subscription payment
final arguments = Get.arguments as Map<String, dynamic>?;
final isPlanPayment = arguments?['isPlanPayment'] == true;

if (isPlanPayment) {
  final planJson = arguments!['plan'] as Map<String, dynamic>;
  final plan = PaymentPlan.fromJson(planJson);

  // Import the controller at the top:
  // import 'package:videocalling/features/patient/payment_plans/controllers/payment_plans_controller.dart';

  try {
    final plansController = Get.find<PaymentPlansController>();

    await plansController.subscribeToPlan(
      plan: plan,
      paymentGateway: selectedPaymentMethod == 1 ? 'bankily' : 'stripe',
      paymentId: transactionId.value,
      paymentCurrency: selectedPaymentMethod == 1 ? 'MRU' : stripeCurrencyCode,
    );

    // Navigate to success screen or payment plans
    Get.offAllNamed(Routes.paymentPlansScreen);
  } catch (e) {
    loggerNoStack.e('Error subscribing to plan: $e');
  }
}
```

### Modifying Payment Plans Page Navigation

In `lib/features/patient/payment_plans/pages/payment_plans_page.dart`, the `_handleSubscribe()` method:

```dart
void _handleSubscribe(PaymentPlan plan) {
  controller.selectPlan(plan);

  // Navigate to payment screen with plan info
  Get.toNamed(
    Routes.userPaymentScreen, // Reuse existing payment screen
    arguments: {
      'isPlanPayment': true, // Flag to identify plan payment
      'plan': plan.toJson(),
      'doctorName': 'Estarht Subscription', // Or app name
      'amount': plan.price.toString(),
      'description': '${plan.planName} - ${plan.sessions} sessions',
      // Add other required fields...
    },
  );
}
```

### Adding Session Confirmation Buttons

In your appointment detail pages, add confirmation buttons:

**For Doctor:**
```dart
// Import the service
import 'package:videocalling/shared/services/session_management_service.dart';

final _sessionService = SessionManagementService();

// Add button
ElevatedButton(
  onPressed: () async {
    final result = await _sessionService.confirmSessionFromDoctor(
      bookingId: appointmentId,
      patientId: patientId,
    );

    Get.snackbar(
      result.success ? 'Success' : 'Error',
      result.message,
      backgroundColor: result.success ? Colors.green : Colors.red,
      colorText: Colors.white,
    );

    if (result.bothConfirmed) {
      // Refresh appointment details
      loadAppointmentDetails();
    }
  },
  child: Text('Confirm Session Complete'),
)
```

**For Patient:**
```dart
ElevatedButton(
  onPressed: () async {
    final result = await _sessionService.confirmSessionFromPatient(
      bookingId: appointmentId,
      patientId: currentUserId,
    );

    Get.snackbar(
      result.success ? 'Success' : 'Error',
      result.message,
      backgroundColor: result.success ? Colors.green : Colors.red,
      colorText: Colors.white,
    );

    if (result.bothConfirmed) {
      // Refresh appointment details
      loadAppointmentDetails();
    }
  },
  child: Text('Confirm Session Complete'),
)
```

## 📊 How It Works

```
┌─────────────────────────────────────────────────────────────┐
│                    PATIENT SESSION FLOW                     │
└─────────────────────────────────────────────────────────────┘

1. NEW PATIENT REGISTRATION
   ↓
   sessions_available = 0
   sessions_pending = 0
   subscribed = false
   subscribed_before = false

2. TRIES TO BOOK APPOINTMENT
   ↓
   Check: sessions_available > 0?
   ├─ NO → Redirect to Payment Plans 💳
   └─ YES → Continue to booking

3. SUBSCRIBES TO PLAN ($165 / 5 sessions)
   ↓
   sessions_available = 5
   subscribed = true
   subscribed_before = true
   (40$ plan now hidden)

4. BOOKS APPOINTMENT
   ↓
   sessions_available = 4 (5-1)
   sessions_pending = 1 (0+1)

5a. CANCELS APPOINTMENT
   ↓
   sessions_available = 5 (4+1)
   sessions_pending = 0 (1-1)

5b. COMPLETES SESSION (both confirm)
   ↓
   sessions_pending = 0 (1-1)
   (sessions_available stays at 4)
```

## 🎯 Key Features

✅ **Automatic Session Management**
- Sessions deducted when booking
- Sessions returned when canceling
- Sessions consumed when completing

✅ **Smart Plan Filtering**
- 40$ first-time plan hides after subscription
- Only active plans shown
- Sorted by price

✅ **Dual Confirmation**
- Requires both doctor AND patient to confirm
- Prevents disputes
- Tracks confirmation status

✅ **Session Status Display**
- Real-time available count
- Real-time pending count
- Visual status indicators

## ⚡ Common Tasks

### Check Patient Sessions
```dart
final service = SessionManagementService();
final counts = await service.getSessionCounts(patientId);

print('Available: ${counts?.available}');
print('Pending: ${counts?.pending}');
```

### Manual Session Grant (Admin)
```dart
await Supabase.instance.client
    .from('patients')
    .update({'sessions_available': increment(5)})
    .eq('id', patientId);
```

### View Subscription History
```dart
final controller = Get.find<PaymentPlansController>();
await controller.loadSubscriptionHistory();
print(controller.subscriptionHistory);
```

## 📚 Full Documentation

- **Complete Guide**: `PAYMENT_PLANS_IMPLEMENTATION.md`
- **Summary**: `IMPLEMENTATION_SUMMARY.md`
- **This Quick Start**: `QUICK_START_GUIDE.md`

## 🆘 Need Help?

1. Check the logs - all operations use `loggerNoStack`
2. Verify migrations ran successfully in Supabase
3. Ensure routes are properly configured
4. Review the detailed implementation guide

## ✨ You're Done!

The system is now ready. Just:
1. ✅ Run the migrations
2. ✅ Add navigation (optional)
3. ✅ Add translations
4. ✅ Integrate payment processing
5. ✅ Test thoroughly

Happy coding! 🚀

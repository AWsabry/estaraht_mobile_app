# Payment Plans & Session Management Implementation Guide

## Overview

This document describes the complete implementation of the payment plans and session management system for the Estarht mobile app.

## Key Changes

### 1. Database Schema Changes

#### Patients Table - New Columns
Run the SQL migration in `supabase_migrations/add_patient_session_fields.sql`:

```sql
ALTER TABLE patients
ADD COLUMN IF NOT EXISTS sessions_available INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS sessions_pending INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS subscribed BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS subscribed_before BOOLEAN DEFAULT FALSE;
```

**Column Descriptions:**
- `sessions_available`: Sessions the patient can book (decremented when booking, incremented when subscribing)
- `sessions_pending`: Sessions currently booked but not yet completed or canceled
- `subscribed`: Whether patient currently has an active subscription
- `subscribed_before`: Tracks if patient has ever subscribed (determines if 40$ first-time plan is shown)

#### New Tables
Run the SQL migration in `supabase_migrations/create_payment_plans_table.sql`:

1. **payment_plans**: Stores available subscription plans
   - Preloaded with 4 plans:
     - 40$ - 1 session (first-time only)
     - 165$ - 5 sessions
     - 220$ - 10 sessions
     - 275$ - 15 sessions

2. **patient_plan_subscriptions**: Tracks subscription history
   - Links patients to plans
   - Records sessions purchased and used
   - Stores payment information

### 2. Session Flow

#### When Patient Books an Appointment:
1. Check if `sessions_available > 0`
   - If NO: Redirect to payment plans page
   - If YES: Continue to booking

2. On successful booking:
   - `sessions_available -= 1`
   - `sessions_pending += 1`

#### When Appointment is Canceled:
1. Return session to available pool:
   - `sessions_available += 1`
   - `sessions_pending -= 1`

#### When Session is Completed (Both Parties Confirm):
1. Remove from pending (session is consumed):
   - `sessions_pending -= 1`
   - (sessions_available stays the same - already decremented)

### 3. File Structure

```
lib/features/patient/payment_plans/
├── models/
│   └── payment_plan_model.dart          # Data models
├── controllers/
│   └── payment_plans_controller.dart    # Business logic
├── pages/
│   └── payment_plans_page.dart          # UI
└── payment_plans_binding.dart            # Dependency injection
```

### 4. Key Files Modified

#### Registration
- `lib/features/auth/controllers/patient_register_controller.dart`
  - Initializes all session fields to 0 and subscription flags to false

#### Booking Flow
- `lib/features/patient/appointments/controllers/make_appointment_controller.dart`
  - Added session availability check before navigation to payment
  - Redirects to payment plans if no sessions available

#### Payment Processing
- `lib/features/patient/payment/controllers/payment_controller.dart`
  - Added `_deductSessionFromPatient()` method
  - Deducts session when booking is created

#### Routes
- `lib/core/config/app_routes.dart` & `lib/core/config/routes.dart`
  - Added `paymentPlansScreen` route
  - Added `planPaymentScreen` route

### 5. Payment Plans Controller Usage

```dart
// Get the controller
final controller = Get.find<PaymentPlansController>();

// Load patient status
await controller.loadPatientStatus();

// Check if patient has sessions
bool hasS sessions = controller.hasAvailableSessions();

// Get available plans (automatically filters out 40$ if subscribed before)
List<PaymentPlan> plans = controller.availablePlans;

// Subscribe to a plan
await controller.subscribeToPlan(
  plan: selectedPlan,
  paymentGateway: 'bankily',
  paymentId: 'txn_123456',
  paymentCurrency: 'MRU',
);
```

### 6. Session Confirmation Flow (To Be Implemented)

#### Option 1: Simple Confirmation in Appointment Details

Add these methods to both doctor and patient appointment detail controllers:

```dart
// In appointment_detail_controller.dart (both doctor & patient versions)

Future<void> markSessionAsComplete() async {
  try {
    final bookingId = appointmentId; // Your booking ID
    final userId = currentUserId; // Current user (doctor or patient)

    // Get current booking confirmation status
    final booking = await supabase
        .from('bookings')
        .select('doctor_confirmed, patient_confirmed, patient_id, status')
        .eq('id', bookingId)
        .single();

    bool doctorConfirmed = booking['doctor_confirmed'] ?? false;
    bool patientConfirmed = booking['patient_confirmed'] ?? false;
    final patientId = booking['patient_id'];
    final status = booking['status'];

    // Mark current user as confirmed
    if (isDoctor) {
      await supabase
          .from('bookings')
          .update({'doctor_confirmed': true})
          .eq('id', bookingId);
      doctorConfirmed = true;
    } else {
      await supabase
          .from('bookings')
          .update({'patient_confirmed': true})
          .eq('id', bookingId);
      patientConfirmed = true;
    }

    // If both confirmed, complete the session
    if (doctorConfirmed && patientConfirmed) {
      // Update booking status to completed
      await supabase
          .from('bookings')
          .update({'status': 'completed'})
          .eq('id', bookingId);

      // Deduct from sessions_pending
      final patientData = await supabase
          .from('patients')
          .select('sessions_pending')
          .eq('id', patientId)
          .single();

      final currentPending = patientData['sessions_pending'] ?? 0;

      if (currentPending > 0) {
        await supabase
            .from('patients')
            .update({'sessions_pending': currentPending - 1})
            .eq('id', patientId);
      }

      // Show success message
      Get.snackbar(
        'Session Completed',
        'This session has been marked as completed by both parties',
      );
    } else {
      // Show waiting message
      Get.snackbar(
        'Confirmation Recorded',
        'Waiting for the other party to confirm completion',
      );
    }
  } catch (e) {
    loggerNoStack.e('Error marking session as complete: $e');
    Get.snackbar('Error', 'Failed to mark session as complete');
  }
}
```

#### Option 2: Add Confirmation Columns to Bookings Table

```sql
-- Add these columns to bookings table
ALTER TABLE bookings
ADD COLUMN IF NOT EXISTS doctor_confirmed BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS patient_confirmed BOOLEAN DEFAULT FALSE;
```

### 7. Navigation & Access

#### Add to Patient More Menu

In `lib/features/patient/more/pages/more_page.dart`, add a menu item:

```dart
ListTile(
  leading: Icon(Icons.credit_card),
  title: Text('subscription_plans'.tr),
  onTap: () => Get.toNamed(Routes.paymentPlansScreen),
),
```

#### Or add to tab navigation

Modify patient tabs to include payment plans as a tab or bottom sheet.

### 8. Translation Keys to Add

Add these keys to your translation files:

```dart
// English
'subscription_plans': 'Subscription Plans',
'your_sessions': 'Your Sessions',
'available': 'Available',
'pending': 'Pending',
'available_plans': 'Available Plans',
'x_sessions': '{count} Sessions',
'duration_plan': '45 minutes per session',
'video_sessions_included': 'Video sessions included',
'subscribe_now': 'Subscribe Now',
'special_offer': 'Special Offer',
'no_sessions_available': 'No Sessions Available',
'please_subscribe_to_continue': 'Please subscribe to a plan to book appointments',
'no_plans_available': 'No plans available at this time',
'1_session_available': '1 session available',
'x_sessions_available': '{count} sessions available',

// Arabic
'subscription_plans': 'خطط الاشتراك',
'your_sessions': 'جلساتك',
'available': 'متاح',
'pending': 'قيد الانتظار',
// ... add more Arabic translations
```

### 9. Testing Checklist

- [ ] Run Supabase migrations
- [ ] Test patient registration (sessions should be 0)
- [ ] Test booking with 0 sessions (should redirect to plans)
- [ ] Test subscribing to a plan
- [ ] Verify sessions are added after subscription
- [ ] Test booking with available sessions
- [ ] Verify session deduction on booking
- [ ] Test appointment cancellation
- [ ] Verify session return on cancellation
- [ ] Test session completion flow
- [ ] Verify 40$ plan hides after first subscription

### 10. Plan Payment Integration

To integrate plan payment with Bankily/Stripe, modify the payment controller to detect plan purchases:

```dart
// In PaymentController, check if this is a plan payment
final isPlanPayment = Get.arguments['isPlanPayment'] ?? false;
final planData = Get.arguments['plan'];

// After successful payment for a plan
if (isPlanPayment && planData != null) {
  final plan = PaymentPlan.fromJson(planData);
  final controller = Get.find<PaymentPlansController>();

  await controller.subscribeToPlan(
    plan: plan,
    paymentGateway: selectedPaymentMethod == 1 ? 'bankily' : 'stripe',
    paymentId: transactionId.value,
    paymentCurrency: 'MRU',
  );
}
```

### 11. Future Enhancements

- Add expiration dates for sessions (e.g., 45 days from purchase)
- Implement session usage analytics
- Add push notifications for session confirmations
- Create admin panel for plan management
- Add promotional codes/discounts for plans
- Implement session transfer between patients
- Add recurring subscription options

## Support

For questions or issues, refer to the codebase or contact the development team.

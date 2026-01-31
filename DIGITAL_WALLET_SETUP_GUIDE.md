# 📱 دليل إعداد Apple Pay و Google Pay

## 📋 نظرة عامة

هذا الدليل يشرح بالتفصيل كيفية إعداد Apple Pay و Google Pay في تطبيق Estaraht.

---

## ✅ ما تم إنجازه

- ✅ تثبيت `pay: ^3.3.0` package
- ✅ إنشاء `DigitalWalletService`
- ✅ إضافة دالة `processDigitalWalletPayment` في `PaymentController`
- ✅ تحديث UI في `payment_page.dart` لاستخدام Apple/Google Pay buttons
- ✅ إنشاء ملفات configuration (`apple_pay_config.json` و `google_pay_config.json`)
- ✅ إضافة إعدادات AndroidManifest.xml و Info.plist

---

## 🍎 إعداد Apple Pay (iOS)

### الخطوة 1: إنشاء Merchant ID في Apple Developer

1. **سجل دخول على [Apple Developer](https://developer.apple.com/account)**

2. **اذهب إلى Certificates, Identifiers & Profiles**

3. **اختر Identifiers من القائمة الجانبية**

4. **اضغط زر (+) لإنشاء Identifier جديد**

5. **اختر Merchant IDs ثم Continue**

6. **أدخل المعلومات:**
   - **Description:** Estaraht Payments
   - **Identifier:** `merchant.com.estaraht.payments` (أو أي اسم تريده)

7. **اضغط Continue ثم Register**

8. **احفظ الـ Merchant ID** - ستحتاجه لاحقاً

---

### الخطوة 2: إنشاء Payment Processing Certificate

1. **في نفس صفحة الـ Merchant ID، اضغط على Edit**

2. **في قسم Payment Processing Certificate:**
   - اضغط **Create Certificate**

3. **ستحتاج إلى إنشاء Certificate Signing Request (CSR):**

   **على Mac:**
   - افتح Keychain Access
   - من القائمة: Keychain Access → Certificate Assistant → Request a Certificate From a Certificate Authority
   - أدخل بريدك الإلكتروني
   - Common Name: Apple Pay Payment Processing
   - اختر "Saved to disk" و "Let me specify key pair information"
   - احفظ الملف
   - Key Size: 2048 bits
   - Algorithm: RSA

4. **ارفع الـ CSR file على Apple Developer**

5. **حمل الـ Certificate وثبته في Keychain**

---

### الخطوة 3: تحديث Info.plist

افتح `ios/Runner/Info.plist` وتأكد من وجود هذا الكود (موجود بالفعل):

```xml
<!-- Apple Pay Configuration -->
<key>com.apple.developer.in-app-payments</key>
<array>
    <string>merchant.com.estaraht.payments</string>
</array>
```

**⚠️ مهم:** استبدل `merchant.com.estaraht.payments` بالـ Merchant ID الذي أنشأته في الخطوة 1.

---

### الخطوة 4: تفعيل Apple Pay في Xcode

1. **افتح المشروع في Xcode:**
   ```bash
   cd ios
   open Runner.xcworkspace
   ```

2. **اختر Target "Runner"**

3. **اذهب إلى تبويب "Signing & Capabilities"**

4. **اضغط "+ Capability"**

5. **ابحث عن "Apple Pay" واختره**

6. **في قسم Apple Pay:**
   - ستظهر قائمة Merchant IDs
   - اضغط (+)
   - أضف الـ Merchant ID الذي أنشأته
   - فعّل الـ checkbox بجانبه

7. **تأكد من Team وBundle Identifier صحيحين**

---

### الخطوة 5: تحديث ملف Configuration

افتح `assets/apple_pay_config.json` وحدث الـ merchantIdentifier:

```json
{
  "provider": "apple_pay",
  "data": {
    "merchantIdentifier": "merchant.com.estaraht.payments",  // ← هنا
    "displayName": "Estaraht",
    ...
  }
}
```

وأيضاً في `lib/shared/services/payment/digital_wallet_service.dart`:

```dart
// TODO: Replace with your actual Apple Merchant ID
const merchantId = 'merchant.com.estaraht.payments';  // ← هنا
```

---

## 📱 إعداد Google Pay (Android)

### الخطوة 1: تفعيل Google Pay API

1. **سجل دخول على [Google Cloud Console](https://console.cloud.google.com/)**

2. **اختر مشروعك أو أنشئ مشروع جديد**

3. **اذهب إلى APIs & Services → Library**

4. **ابحث عن "Google Pay API" وفعّله**

---

### الخطوة 2: إعداد Stripe لـ Google Pay

1. **سجل دخول على [Stripe Dashboard](https://dashboard.stripe.com/)**

2. **اذهب إلى Settings → Payment methods**

3. **فعّل Google Pay:**
   - ابحث عن Google Pay في القائمة
   - اضغط Enable

4. **احصل على Publishable Key:**
   - اذهب إلى Developers → API keys
   - انسخ الـ **Publishable key** (يبدأ بـ `pk_test_` أو `pk_live_`)

---

### الخطوة 3: تحديث ملف Configuration

افتح `assets/google_pay_config.json` وحدث الـ publishableKey:

```json
{
  "provider": "google_pay",
  "data": {
    ...
    "allowedPaymentMethods": [
      {
        "tokenizationSpecification": {
          "parameters": {
            "stripe:publishableKey": "pk_test_YOUR_KEY_HERE"  // ← هنا
          }
        },
        ...
      }
    ]
  }
}
```

وأيضاً في `lib/core/config/app_variables.dart`، تأكد من وجود:

```dart
const stripePublishableKey = 'pk_test_YOUR_STRIPE_PUBLISHABLE_KEY';
```

---

### الخطوة 4: تحديث Environment (للإنتاج)

عند النشر للـ Production، غير في `google_pay_config.json`:

```json
"environment": "PRODUCTION",  // كان TEST
```

وفي `digital_wallet_service.dart`:

```dart
"environment": "PRODUCTION",  // السطر 31
```

---

### الخطوة 5: التحقق من AndroidManifest.xml

تأكد من وجود هذا في `android/app/src/main/AndroidManifest.xml` (موجود بالفعل):

```xml
<!-- Google Pay Configuration -->
<meta-data
    android:name="com.google.android.gms.wallet.api.enabled"
    android:value="true" />
```

---

## 🔧 إعداد Stripe

### الخطوة 1: تفعيل Digital Wallets في Stripe

1. **سجل دخول على [Stripe Dashboard](https://dashboard.stripe.com/)**

2. **اذهب إلى Settings → Payment methods**

3. **فعّل Apple Pay:**
   - ابحث عن Apple Pay
   - اضغط Enable
   - أضف Domain verification (إن كان لديك موقع)

4. **فعّل Google Pay** (كما في الخطوة السابقة)

---

### الخطوة 2: Domain Verification لـ Apple Pay (اختياري)

إذا كان لديك موقع ويب:

1. في Stripe Dashboard → Settings → Apple Pay
2. اضغط Add Domain
3. أدخل domain name الخاص بك
4. حمل ملف الـ verification
5. ارفعه على سيرفر الويب في `/.well-known/apple-developer-merchantid-domain-association`
6. اضغط Verify

---

## 🧪 الاختبار

### اختبار Apple Pay على Simulator:

1. **افتح Wallet app على Simulator**
2. **أضف بطاقة اختبار:**
   - Card Number: `4242 4242 4242 4242`
   - Expiry: أي تاريخ مستقبلي
   - CVV: أي 3 أرقام
   - ZIP: أي رقم

3. **شغل التطبيق واختبر الدفع**

---

### اختبار Google Pay على Emulator/Device:

1. **تأكد من وجود Google account على الجهاز**

2. **افتح Google Pay app**

3. **أضف بطاقة اختبار:**
   - استخدم نفس بطاقة Stripe الاختبارية
   - Card Number: `4242 4242 4242 4242`

4. **شغل التطبيق واختبار الدفع**

---

## 📝 بطاقات اختبار Stripe

للاختبار في بيئة TEST:

| الحالة | رقم البطاقة | النتيجة |
|--------|-------------|---------|
| ✅ نجاح | 4242 4242 4242 4242 | الدفع ينجح |
| ❌ فشل | 4000 0000 0000 0002 | البطاقة مرفوضة |
| ⚠️ 3D Secure | 4000 0000 0000 3220 | يتطلب authentication |

**Expiry Date:** أي تاريخ مستقبلي (مثل: 12/25)
**CVV:** أي 3 أرقام (مثل: 123)
**ZIP:** أي رقم (مثل: 12345)

---

## 🐛 حل المشاكل الشائعة

### مشكلة: "Apple Pay is not available"

**الحل:**
- تأكد من إضافة Merchant ID في Xcode Capabilities
- تأكد من تطابق Merchant ID في Info.plist و Code
- تأكد من وجود بطاقة في Wallet

---

### مشكلة: "Google Pay is not available"

**الحل:**
- تأكد من تفعيل Google Pay API في Google Cloud Console
- تأكد من إضافة بطاقة في Google Pay app
- تأكد من صحة Stripe Publishable Key

---

### مشكلة: "Payment failed with no error message"

**الحل:**
- تحقق من Stripe Dashboard → Logs للاطلاع على الأخطاء
- تأكد من صحة Secret Key في app_variables.dart
- تحقق من الـ console logs في التطبيق

---

### مشكلة: "Certificate error on iOS"

**الحل:**
- تأكد من تثبيت Payment Processing Certificate في Keychain
- تحقق من صلاحية الـ Certificate (لم ينته)
- جرب إعادة إنشاء الـ Certificate

---

## 📄 الملفات المهمة

| الملف | الوصف |
|------|-------|
| `lib/shared/services/payment/digital_wallet_service.dart` | خدمة معالجة Digital Wallets |
| `lib/features/patient/payment/controllers/payment_controller.dart` | Controller الدفع (يحتوي على دوال المعالجة) |
| `lib/features/patient/payment/pages/payment_page.dart` | صفحة UI للدفع |
| `assets/apple_pay_config.json` | إعدادات Apple Pay |
| `assets/google_pay_config.json` | إعدادات Google Pay |
| `ios/Runner/Info.plist` | إعدادات iOS |
| `android/app/src/main/AndroidManifest.xml` | إعدادات Android |

---

## ⚠️ ملاحظات مهمة

1. **للإنتاج (Production):**
   - غير `environment` من `TEST` إلى `PRODUCTION` في Google Pay config
   - استخدم Live Keys من Stripe (تبدأ بـ `pk_live_` و `sk_live_`)
   - تأكد من Domain Verification لـ Apple Pay

2. **الأمان:**
   - **لا تضع** Secret Keys في الكود المصدري
   - استخدم `.env` file أو Environment Variables
   - الـ Secret Key يجب أن يكون على Backend فقط

3. **الرسوم:**
   - Apple Pay: لا توجد رسوم إضافية من Apple
   - Google Pay: لا توجد رسوم إضافية من Google
   - Stripe: الرسوم العادية للمعاملات (2.9% + $0.30)

---

## 🚀 الخطوات التالية

1. ✅ **أنشئ Apple Merchant ID** من Apple Developer Console
2. ✅ **حدّث المعرفات في الكود** (Merchant ID)
3. ✅ **احصل على Stripe Publishable Key** وحدثه في Config
4. ✅ **فعّل Apple Pay Capability في Xcode**
5. ✅ **اختبر على Simulator/Emulator** باستخدام بطاقات الاختبار
6. ✅ **اختبر على جهاز حقيقي** قبل النشر
7. ✅ **انشر للإنتاج** بعد التأكد من كل شيء

---

## 📞 الدعم

إذا واجهت أي مشاكل:

1. **Stripe Documentation:** https://stripe.com/docs/apple-pay
2. **Apple Pay Guide:** https://developer.apple.com/apple-pay/
3. **Google Pay Guide:** https://developers.google.com/pay/api/android/overview
4. **Flutter Pay Package:** https://pub.dev/packages/pay

---

## ✨ تم بنجاح!

الآن الكود جاهز تماماً! كل ما تحتاجه هو:
1. إنشاء Merchant ID من Apple
2. تحديث المعرفات في الملفات
3. الاختبار والنشر

حظاً موفقاً! 🎉

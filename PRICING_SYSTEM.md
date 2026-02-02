# نظام التسعير - Pricing System

## 📋 نظرة عامة

نظام التسعير يحدد سعر الجلسة تلقائياً بناءً على جنسية المعالج (من رقم الهاتف).

## 💰 الأسعار

### المعالج الموريتاني
- **السعر:** 663 أوقية موريتانية (MRU)
- **كود الدولة:** +222
- **العملة:** MRU (Mauritanian Ouguiya)

### المعالج العربي
- **السعر:** 17 دولار أمريكي (USD)
- **كود الدولة:** أي كود عربي آخر (+20, +966, +971, الخ)
- **العملة:** USD

### الدول المدعومة (17 دولار)
- 🇪🇬 مصر (+20)
- 🇸🇦 السعودية (+966)
- 🇦🇪 الإمارات (+971)
- 🇰🇼 الكويت (+965)
- 🇶🇦 قطر (+974)
- 🇧🇭 البحرين (+973)
- 🇴🇲 عمان (+968)
- 🇯🇴 الأردن (+962)
- 🇮🇶 العراق (+964)
- 🇸🇾 سوريا (+963)
- 🇱🇧 لبنان (+961)
- 🇸🇩 السودان (+249)
- 🇱🇾 ليبيا (+218)
- 🇹🇳 تونس (+216)
- 🇩🇿 الجزائر (+213)
- 🇲🇦 المغرب (+212)

## 🔧 كيف يعمل النظام؟

### 1. عند حجز موعد
```dart
// التطبيق يحصل على pricing من رقم هاتف الدكتور
final pricing = await pricingService.getPricingForDoctor(doctorId);

// يستخرج كود الدولة من رقم الهاتف
// مثال: "+222XXXXXXXX" -> "+222" (موريتانيا)
// مثال: "+20XXXXXXXXX" -> "+20" (مصر)

// يبحث عن السعر المناسب في جدول country_pricing
```

### 2. عرض السعر للمريض
```dart
// السعر يظهر بالعملة المناسبة
// موريتانيا: "663 MRU"
// مصر: "$17.00"
```

### 3. في قاعدة البيانات
جدول `country_pricing`:
| country_code | country_name | currency | session_price |
|--------------|--------------|----------|---------------|
| +222         | Mauritania   | MRU      | 663           |
| +20          | Egypt        | USD      | 17            |
| +966         | Saudi Arabia | USD      | 17            |
| default      | Other        | USD      | 17            |

## 📦 الملفات المتعلقة

1. **pricing_service.dart** - خدمة التسعير الرئيسية
2. **country_pricing_model.dart** - نموذج بيانات التسعير
3. **setup_country_pricing.sql** - سكريبت إعداد قاعدة البيانات
4. **make_appointment_controller.dart** - يستخدم التسعير عند الحجز

## 🚀 الإعداد الأولي

### 1. تشغيل السكريبت في Supabase
```sql
-- افتح Supabase SQL Editor
-- انسخ محتوى ملف setup_country_pricing.sql
-- شغل السكريبت
```

### 2. التحقق من البيانات
```sql
SELECT country_code, country_name, currency, session_price 
FROM country_pricing 
ORDER BY country_name;
```

## 🔍 مثال على الاستخدام

### مثال 1: معالج موريتاني
```
رقم الهاتف: +222XXXXXXXX
النظام يكتشف: كود الدولة = +222
يحدد السعر: 663 MRU
يعرض للمريض: "663 MRU"
```

### مثال 2: معالج مصري
```
رقم الهاتف: +20XXXXXXXXX
النظام يكتشف: كود الدولة = +20
يحدد السعر: 17 USD
يعرض للمريض: "$17.00"
```

### مثال 3: معالج من دولة غير مدرجة
```
رقم الهاتف: +1XXXXXXXXXX (أمريكا)
النظام يستخدم: default pricing
يحدد السعر: 17 USD
يعرض للمريض: "$17.00"
```

## ⚙️ تعديل الأسعار

### لتغيير سعر موريتانيا:
```sql
UPDATE country_pricing 
SET session_price = 700 
WHERE country_code = '+222';
```

### لتغيير سعر الدول العربية:
```sql
UPDATE country_pricing 
SET session_price = 20 
WHERE currency = 'USD';
```

### لإضافة دولة جديدة:
```sql
INSERT INTO country_pricing (country_code, country_name, currency, session_price)
VALUES ('+33', 'France', 'EUR', 15);
```

## 📝 ملاحظات مهمة

1. **الأولوية للكود الأطول:**
   - النظام يبحث من الكود الأطول للأقصر
   - مثال: +222 قبل +22
   - هذا يمنع الأخطاء في التطابق

2. **Default Pricing:**
   - أي دولة غير مدرجة تحصل على السعر الافتراضي (17 USD)
   - مُعرّف بـ `country_code = 'default'`

3. **Cache:**
   - النظام يحفظ البيانات في memory لسرعة الأداء
   - لمسح الـ cache: `pricingService.clearCache()`

4. **رقم الهاتف:**
   - يجب أن يكون بصيغة دولية: +[country_code][number]
   - مثال صحيح: +222XXXXXXXX
   - مثال خاطئ: 00222XXXXXXXX

## 🐛 استكشاف الأخطاء

### المشكلة: السعر دائماً 17 دولار
**الحل:** 
- تحقق من رقم هاتف الدكتور في جدول `doctors`
- تأكد أنه بصيغة دولية صحيحة
- تحقق من وجود السجل في `country_pricing`

### المشكلة: السعر لا يظهر
**الحل:**
- تحقق من logs: `Error getting pricing for doctor`
- تأكد من وجود اتصال بـ Supabase
- تحقق من صلاحيات الجدول

### المشكلة: العملة خاطئة
**الحل:**
- تحقق من حقل `currency` في جدول `country_pricing`
- تأكد من تطابقه مع الكود في `CountryPricing.formattedPrice`

## 📊 إحصائيات

يمكنك معرفة توزيع المعالجين حسب الدولة:

```sql
SELECT 
  cp.country_name,
  cp.currency,
  cp.session_price,
  COUNT(d.doctor_id) as therapist_count
FROM country_pricing cp
LEFT JOIN doctors d ON d.phone_number LIKE cp.country_code || '%'
GROUP BY cp.country_code, cp.country_name, cp.currency, cp.session_price
ORDER BY therapist_count DESC;
```

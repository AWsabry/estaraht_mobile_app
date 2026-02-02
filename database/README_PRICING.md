# إعداد نظام التسعير - Pricing Setup Guide

## ✅ ما تم إنجازه

1. ✅ الكود جاهز بالفعل في التطبيق
2. ✅ Default pricing = 17 USD (للمعالجين العرب)
3. ✅ سكريبت SQL جاهز لإضافة الأسعار

## 🚀 خطوات التفعيل

### الخطوة 1: تشغيل السكريبت في Supabase

1. افتح Supabase Dashboard
2. اذهب إلى **SQL Editor**
3. افتح ملف `setup_country_pricing.sql`
4. انسخ المحتوى كله
5. الصقه في SQL Editor
6. اضغط **Run** أو **F5**

### الخطوة 2: التحقق من البيانات

شغل هذا الـ Query للتأكد:

```sql
SELECT country_code, country_name, currency, session_price 
FROM country_pricing 
ORDER BY 
  CASE 
    WHEN country_code = '+222' THEN 0
    WHEN country_code = 'default' THEN 999
    ELSE 1 
  END;
```

**النتيجة المتوقعة:**
```
+222    | Mauritania          | MRU | 663
+20     | Egypt              | USD | 17
+966    | Saudi Arabia       | USD | 17
...
default | Other Countries    | USD | 17
```

### الخطوة 3: اختبار النظام

1. **أضف معالج موريتاني:**
   - رقم الهاتف: `+222XXXXXXXX`
   - عند حجز موعد، السعر سيكون: **663 MRU**

2. **أضف معالج مصري:**
   - رقم الهاتف: `+20XXXXXXXXX`
   - عند حجز موعد، السعر سيكون: **$17**

3. **أضف معالج سعودي:**
   - رقم الهاتف: `+966XXXXXXXX`
   - عند حجز موعد، السعر سيكون: **$17**

## 📊 الأسعار النهائية

| الجنسية | كود الدولة | السعر | العملة |
|---------|-----------|------|--------|
| 🇲🇷 موريتاني | +222 | 663 | MRU |
| 🇪🇬 مصري | +20 | 17 | USD |
| 🇸🇦 سعودي | +966 | 17 | USD |
| 🇦🇪 إماراتي | +971 | 17 | USD |
| 🇰🇼 كويتي | +965 | 17 | USD |
| ... باقي الدول العربية | ... | 17 | USD |
| 🌍 دول أخرى | default | 17 | USD |

## ⚠️ ملاحظات مهمة

1. **رقم الهاتف يجب أن يكون بصيغة دولية:**
   - ✅ صحيح: `+222XXXXXXXX`
   - ❌ خاطئ: `222XXXXXXXX`
   - ❌ خاطئ: `00222XXXXXXXX`

2. **النظام تلقائي:**
   - لا حاجة لإعداد يدوي لكل معالج
   - السعر يُحدد تلقائياً من رقم الهاتف

3. **التحديثات:**
   - إذا أردت تغيير سعر موريتانيا:
     ```sql
     UPDATE country_pricing 
     SET session_price = 700 
     WHERE country_code = '+222';
     ```

## 🔍 استكشاف المشاكل

### المشكلة: السعر لا يظهر صحيح

**الحل:**
```sql
-- تحقق من رقم هاتف الدكتور
SELECT doctor_id, name, phone_number 
FROM doctors 
WHERE doctor_id = 'xxx';

-- تحقق من pricing
SELECT * FROM country_pricing 
WHERE country_code = '+222';
```

### المشكلة: جدول country_pricing غير موجود

**الحل:**
```sql
-- أنشئ الجدول
CREATE TABLE IF NOT EXISTS country_pricing (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  country_code TEXT UNIQUE NOT NULL,
  country_name TEXT NOT NULL,
  currency TEXT NOT NULL,
  session_price NUMERIC NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ثم شغل setup_country_pricing.sql
```

## 📞 للدعم

إذا واجهت أي مشكلة:
1. تحقق من logs في التطبيق
2. تحقق من البيانات في Supabase
3. راجع ملف `PRICING_SYSTEM.md` للتوضيح الكامل

---

**تم إعداد النظام بواسطة:** Cursor AI
**التاريخ:** فبراير 2026

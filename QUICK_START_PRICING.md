# نظام التسعير - ملخص سريع 🚀

## ✅ النظام جاهز!

الكود جاهز بالفعل في التطبيق. فقط نفذ الخطوات التالية:

## 📝 خطوة واحدة للتفعيل

### افتح Supabase وشغل هذا السكريبت:

```sql
-- نسخ من ملف: database/setup_country_pricing.sql
-- فقط افتح SQL Editor في Supabase والصق هذا الكود

-- موريتانيا - 663 أوقية
INSERT INTO country_pricing (country_code, country_name, currency, session_price)
VALUES ('+222', 'Mauritania', 'MRU', 663)
ON CONFLICT (country_code) DO UPDATE SET session_price = 663;

-- باقي الدول العربية - 17 دولار
INSERT INTO country_pricing (country_code, country_name, currency, session_price)
VALUES 
  ('+20', 'Egypt', 'USD', 17),
  ('+966', 'Saudi Arabia', 'USD', 17),
  ('+971', 'UAE', 'USD', 17),
  ('default', 'Other', 'USD', 17)
ON CONFLICT (country_code) DO UPDATE SET session_price = 17;
```

## 🎯 كيف يعمل؟

1. **معالج موريتاني** (رقم +222XXXXXXXX):
   - السعر: **663 MRU**
   - العملة: أوقية موريتانية

2. **معالج عربي** (رقم +20, +966, +971...):
   - السعر: **$17**
   - العملة: دولار أمريكي

3. **النظام تلقائي:**
   - يحدد السعر من رقم هاتف المعالج
   - لا حاجة لإعداد يدوي

## ✨ انتهى!

بعد تشغيل السكريبت، النظام يعمل تلقائياً:
- عند حجز موعد مع معالج موريتاني → 663 أوقية
- عند حجز موعد مع معالج عربي → 17 دولار

---

للتفاصيل الكاملة: راجع `PRICING_SYSTEM.md`

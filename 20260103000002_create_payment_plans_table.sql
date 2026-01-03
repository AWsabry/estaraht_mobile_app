-- Migration to create payment_plans table for patient subscription plans
-- Run this in your Supabase SQL editor

-- Enable pgcrypto extension for gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Create payment_plans table
CREATE TABLE IF NOT EXISTS payment_plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  plan_name TEXT NOT NULL,
  plan_name_ar TEXT,
  description TEXT,
  description_ar TEXT,
  price DECIMAL(10, 2) NOT NULL,
  sessions INTEGER NOT NULL,
  is_first_time_only BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add comments
COMMENT ON TABLE payment_plans IS 'Subscription plans available for patients';
COMMENT ON COLUMN payment_plans.plan_name IS 'Plan name in English';
COMMENT ON COLUMN payment_plans.plan_name_ar IS 'Plan name in Arabic';
COMMENT ON COLUMN payment_plans.price IS 'Plan price in USD';
COMMENT ON COLUMN payment_plans.sessions IS 'Number of sessions included in the plan';
COMMENT ON COLUMN payment_plans.is_first_time_only IS 'Whether this plan is only available for first-time subscribers';
COMMENT ON COLUMN payment_plans.is_active IS 'Whether this plan is currently available for purchase';
COMMENT ON COLUMN payment_plans.sort_order IS 'Display order (lower numbers appear first)';

-- Insert default plans based on the screenshots
INSERT INTO payment_plans (plan_name, plan_name_ar, description, description_ar, price, sessions, is_first_time_only, is_active, sort_order)
VALUES
  ('First Session Only', 'فقط أول جلسة', 'Perfect for trying our service', 'مثالي لتجربة خدمتنا', 40.00, 1, TRUE, TRUE, 1),
  ('Who Searches for Clarity', 'من يبحث عن وضوح', 'Get clarity with 5 sessions', 'احصل على الوضوح مع 5 جلسات', 165.00, 5, FALSE, TRUE, 2),
  ('Who Listens to Everyone', 'من يسمــــــــع الجميع ولا يســـــــــمــــــــع', 'Listen and be heard with 10 sessions', 'استمع واسمع مع 10 جلسات', 220.00, 10, FALSE, TRUE, 3),
  ('Who Carries a Lot', 'مــــن تحمـــــل كثيــــرا بعضـــــــــــــه', 'Comprehensive support with 15 sessions', 'دعم شامل مع 15 جلسة', 275.00, 15, FALSE, TRUE, 4)
ON CONFLICT DO NOTHING;

-- Create patient_plan_subscriptions table to track subscription history
CREATE TABLE IF NOT EXISTS patient_plan_subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id TEXT NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
  plan_id UUID NOT NULL REFERENCES payment_plans(id) ON DELETE CASCADE,
  payment_id TEXT,
  sessions_purchased INTEGER NOT NULL,
  sessions_used INTEGER DEFAULT 0,
  price_paid DECIMAL(10, 2) NOT NULL,
  payment_gateway TEXT,
  payment_currency TEXT DEFAULT 'USD',
  payment_status TEXT DEFAULT 'completed',
  subscribed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add comments for subscription table
COMMENT ON TABLE patient_plan_subscriptions IS 'History of patient plan subscriptions';
COMMENT ON COLUMN patient_plan_subscriptions.patient_id IS 'Reference to the patient who subscribed';
COMMENT ON COLUMN patient_plan_subscriptions.plan_id IS 'Reference to the purchased plan';
COMMENT ON COLUMN patient_plan_subscriptions.sessions_purchased IS 'Number of sessions purchased in this subscription';
COMMENT ON COLUMN patient_plan_subscriptions.sessions_used IS 'Number of sessions used from this subscription';
COMMENT ON COLUMN patient_plan_subscriptions.price_paid IS 'Amount paid for the subscription';

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_patient_plan_subscriptions_patient_id ON patient_plan_subscriptions(patient_id);
CREATE INDEX IF NOT EXISTS idx_patient_plan_subscriptions_plan_id ON patient_plan_subscriptions(plan_id);
CREATE INDEX IF NOT EXISTS idx_payment_plans_is_active ON payment_plans(is_active);

-- Migration to add French language support to payment_plans table
-- Run this in your Supabase SQL editor

-- Add French columns
ALTER TABLE payment_plans
ADD COLUMN IF NOT EXISTS plan_name_fr TEXT,
ADD COLUMN IF NOT EXISTS description_fr TEXT;

-- Add comments
COMMENT ON COLUMN payment_plans.plan_name_fr IS 'Plan name in French';
COMMENT ON COLUMN payment_plans.description_fr IS 'Plan description in French';

-- Update existing plans with French translations
UPDATE payment_plans
SET
  plan_name_fr = 'Première Session Seulement',
  description_fr = 'Parfait pour essayer notre service'
WHERE plan_name = 'First Session Only';

UPDATE payment_plans
SET
  plan_name_fr = 'Qui Cherche la Clarté',
  description_fr = 'Obtenez la clarté avec 5 séances'
WHERE plan_name = 'Who Searches for Clarity';

UPDATE payment_plans
SET
  plan_name_fr = 'Qui Écoute Tout le Monde',
  description_fr = 'Écoutez et soyez entendu avec 10 séances'
WHERE plan_name = 'Who Listens to Everyone';

UPDATE payment_plans
SET
  plan_name_fr = 'Qui Porte Beaucoup',
  description_fr = 'Soutien complet avec 15 séances'
WHERE plan_name = 'Who Carries a Lot';

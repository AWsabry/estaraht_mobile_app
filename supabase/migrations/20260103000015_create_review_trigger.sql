-- Ensure reviews table exists
CREATE TABLE IF NOT EXISTS reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id TEXT NOT NULL,
  patient_id TEXT NOT NULL,
  doctor_id TEXT NOT NULL,
  rating INTEGER CHECK (rating >= 1 AND rating <= 5) NOT NULL,
  comment TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(booking_id)
);

-- Create indexes if not exist
CREATE INDEX IF NOT EXISTS idx_reviews_doctor_id ON reviews(doctor_id);
CREATE INDEX IF NOT EXISTS idx_reviews_patient_id ON reviews(patient_id);
CREATE INDEX IF NOT EXISTS idx_reviews_booking_id ON reviews(booking_id);

-- Create or replace function to update doctor's average rating
CREATE OR REPLACE FUNCTION update_doctor_rating()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'DELETE' THEN
    UPDATE doctors
    SET 
      average_rating = (
        SELECT COALESCE(ROUND(AVG(rating)::numeric, 2), 0)
        FROM reviews
        WHERE doctor_id = OLD.doctor_id
      ),
      total_reviews = (
        SELECT COUNT(*)
        FROM reviews
        WHERE doctor_id = OLD.doctor_id
      )
    WHERE doctor_id = OLD.doctor_id;
    RETURN OLD;
  ELSE
    UPDATE doctors
    SET 
      average_rating = (
        SELECT COALESCE(ROUND(AVG(rating)::numeric, 2), 0)
        FROM reviews
        WHERE doctor_id = NEW.doctor_id
      ),
      total_reviews = (
        SELECT COUNT(*)
        FROM reviews
        WHERE doctor_id = NEW.doctor_id
      )
    WHERE doctor_id = NEW.doctor_id;
    RETURN NEW;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- Drop existing trigger if exists and recreate
DROP TRIGGER IF EXISTS trigger_update_doctor_rating ON reviews;

CREATE TRIGGER trigger_update_doctor_rating
  AFTER INSERT OR UPDATE OR DELETE ON reviews
  FOR EACH ROW
  EXECUTE FUNCTION update_doctor_rating();

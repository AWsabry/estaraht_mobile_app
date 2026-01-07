-- Create reviews table for rating and review system
CREATE TABLE IF NOT EXISTS reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id UUID NOT NULL,
  patient_id TEXT NOT NULL,
  doctor_id TEXT NOT NULL,
  rating INTEGER CHECK (rating >= 1 AND rating <= 5) NOT NULL,
  review_text TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(booking_id)
);

-- Add average rating and total reviews to doctors table
ALTER TABLE doctors ADD COLUMN IF NOT EXISTS average_rating DECIMAL(2,1) DEFAULT 0;
ALTER TABLE doctors ADD COLUMN IF NOT EXISTS total_reviews INTEGER DEFAULT 0;

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_reviews_doctor_id ON reviews(doctor_id);
CREATE INDEX IF NOT EXISTS idx_reviews_patient_id ON reviews(patient_id);
CREATE INDEX IF NOT EXISTS idx_reviews_booking_id ON reviews(booking_id);

-- Create function to update doctor's average rating
CREATE OR REPLACE FUNCTION update_doctor_rating()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE doctors
  SET 
    average_rating = (
      SELECT COALESCE(ROUND(AVG(rating)::numeric, 1), 0)
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
END;
$$ LANGUAGE plpgsql;

-- Create trigger to auto-update rating on new review
DROP TRIGGER IF EXISTS trigger_update_doctor_rating ON reviews;
CREATE TRIGGER trigger_update_doctor_rating
  AFTER INSERT OR UPDATE ON reviews
  FOR EACH ROW
  EXECUTE FUNCTION update_doctor_rating();

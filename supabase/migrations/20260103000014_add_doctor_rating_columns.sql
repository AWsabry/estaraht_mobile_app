-- Add average rating and total reviews columns to doctors table
ALTER TABLE doctors ADD COLUMN IF NOT EXISTS average_rating DECIMAL(3,2) DEFAULT 0;
ALTER TABLE doctors ADD COLUMN IF NOT EXISTS total_reviews INTEGER DEFAULT 0;

-- Create or replace function to update doctor's average rating
CREATE OR REPLACE FUNCTION update_doctor_rating()
RETURNS TRIGGER AS $$
BEGIN
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
END;
$$ LANGUAGE plpgsql;

-- Create trigger to auto-update rating on new review
DROP TRIGGER IF EXISTS trigger_update_doctor_rating ON reviews;
CREATE TRIGGER trigger_update_doctor_rating
  AFTER INSERT OR UPDATE OR DELETE ON reviews
  FOR EACH ROW
  EXECUTE FUNCTION update_doctor_rating();

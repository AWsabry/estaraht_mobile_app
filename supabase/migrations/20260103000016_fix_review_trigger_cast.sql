-- Fix the trigger function to cast rating to numeric
CREATE OR REPLACE FUNCTION update_doctor_rating()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'DELETE' THEN
    UPDATE doctors
    SET 
      average_rating = (
        SELECT COALESCE(ROUND(AVG(rating::numeric), 2), 0)
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
        SELECT COALESCE(ROUND(AVG(rating::numeric), 2), 0)
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

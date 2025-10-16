-- Migration: 035_auto_hold_overdue_permits.sql
-- Description: Auto-hold construction permits when payment deadline is exceeded
-- Author: Admin App Implementation
-- Date: 2025-10-14

-- Function to check and update overdue permits
CREATE OR REPLACE FUNCTION check_overdue_permits()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Update permits to 'on_hold' status when payment deadline has passed
  -- and they have unpaid balances
  UPDATE construction_permits
  SET
    permit_status = 'on_hold',
    updated_at = NOW()
  WHERE
    permit_status IN ('pending', 'approved')
    AND payment_deadline < CURRENT_DATE
    AND road_fee_amount > COALESCE((
      SELECT SUM(payment_amount)
      FROM permit_payments
      WHERE permit_payments.permit_id = construction_permits.id
    ), 0);
END;
$$;

-- Create a scheduled job trigger (requires pg_cron extension)
-- Note: This requires pg_cron to be enabled in Supabase
-- Alternatively, this can be called from an Edge Function on a schedule

-- For manual execution, admins can call: SELECT check_overdue_permits();

-- Add a trigger to check on permit status changes
CREATE OR REPLACE FUNCTION trigger_check_permit_deadline()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  -- If permit is being approved or payment deadline is being set
  IF (TG_OP = 'UPDATE' AND
      (NEW.permit_status = 'approved' OR NEW.payment_deadline IS DISTINCT FROM OLD.payment_deadline)) THEN

    -- Check if deadline has already passed and payment is incomplete
    IF NEW.payment_deadline < CURRENT_DATE AND
       NEW.road_fee_amount > COALESCE((
         SELECT SUM(payment_amount)
         FROM permit_payments
         WHERE permit_payments.permit_id = NEW.id
       ), 0) THEN
      NEW.permit_status := 'on_hold';
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

-- Apply trigger to construction_permits
DROP TRIGGER IF EXISTS check_permit_deadline_trigger ON construction_permits;
CREATE TRIGGER check_permit_deadline_trigger
  BEFORE INSERT OR UPDATE ON construction_permits
  FOR EACH ROW
  EXECUTE FUNCTION trigger_check_permit_deadline();

-- Comments
COMMENT ON FUNCTION check_overdue_permits() IS 'Checks and updates permits to on_hold status when payment deadline is exceeded';
COMMENT ON FUNCTION trigger_check_permit_deadline() IS 'Automatically sets permit to on_hold if payment deadline has passed';
COMMENT ON TRIGGER check_permit_deadline_trigger ON construction_permits IS 'Enforces payment deadline compliance';

-- Create an Edge Function schedule hint for periodic checks
-- This would typically be implemented as a Supabase Edge Function called via cron
COMMENT ON FUNCTION check_overdue_permits() IS '
  Scheduled execution recommendation:
  - Run daily at midnight: SELECT check_overdue_permits();
  - Implement via Supabase Edge Function with pg_cron or external scheduler
  - Example: */apps/admin/lib/cron/check-overdue-permits.ts
';

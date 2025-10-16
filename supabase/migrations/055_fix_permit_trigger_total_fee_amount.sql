-- Migration: 055_fix_permit_trigger_total_fee_amount.sql
-- Description: Fix trigger function to use correct field name (road_fee_amount instead of total_fee_amount)
-- Author: Bug Fix
-- Date: 2025-10-16

-- The trigger functions in migration 035 were referencing a non-existent field 'total_fee_amount'
-- The correct field name in the construction_permits table is 'road_fee_amount'

-- Drop the existing trigger first
DROP TRIGGER IF EXISTS check_permit_deadline_trigger ON construction_permits;

-- Fix the trigger function to use correct field name
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
         SELECT SUM(amount_paid)
         FROM permit_payments
         WHERE permit_payments.permit_id = NEW.id
       ), 0) THEN
      NEW.permit_status := 'on_hold';
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

-- Recreate the trigger
CREATE TRIGGER check_permit_deadline_trigger
  BEFORE INSERT OR UPDATE ON construction_permits
  FOR EACH ROW
  EXECUTE FUNCTION trigger_check_permit_deadline();

-- Also fix the check_overdue_permits function
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
      SELECT SUM(amount_paid)
      FROM permit_payments
      WHERE permit_payments.permit_id = construction_permits.id
    ), 0);
END;
$$;

-- Comments
COMMENT ON FUNCTION trigger_check_permit_deadline() IS 'Fixed: Uses road_fee_amount instead of total_fee_amount';
COMMENT ON FUNCTION check_overdue_permits() IS 'Fixed: Uses road_fee_amount instead of total_fee_amount';
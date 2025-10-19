# SQL Commands to Fix Permit Trigger

## Issue
The trigger `check_permit_deadline_trigger` is referencing incorrect field names:
- `total_fee_amount` should be `road_fee_amount`
- `amount_paid` should be `payment_amount`

## Solution
Run these SQL commands in Supabase Studio (SQL Editor) to fix the trigger:

### 1. Drop the existing trigger
```sql
DROP TRIGGER IF EXISTS check_permit_deadline_trigger ON construction_permits;
```

### 2. Drop the existing function
```sql
DROP FUNCTION IF EXISTS trigger_check_permit_deadline();
```

### 3. Recreate the function with correct field names
```sql
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
```

### 4. Recreate the trigger
```sql
CREATE TRIGGER check_permit_deadline_trigger
  BEFORE INSERT OR UPDATE ON construction_permits
  FOR EACH ROW
  EXECUTE FUNCTION trigger_check_permit_deadline();
```

### 5. Also fix the check_overdue_permits function
```sql
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
```

## How to Apply
1. Open Supabase Studio: http://127.0.0.1:54323
2. Go to the SQL Editor tab
3. Copy and paste the SQL commands above
4. Run them sequentially

## Verification
After running the SQL, test the permit approval again. You should see:
```
📝 Permit update result: { updateError: null }
✅ Permit updated successfully
🎉 Permit approved successfully!
```
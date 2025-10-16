-- Migration: 027_create_payment_logs.sql
-- Description: Create payment logs and invoices tables for association fee management
-- Author: Admin App Implementation
-- Date: 2025-10-12

-- Invoices table for association dues
CREATE TABLE IF NOT EXISTS invoices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  household_id UUID NOT NULL REFERENCES households(id) ON DELETE CASCADE,
  invoice_number TEXT NOT NULL UNIQUE,
  invoice_type TEXT NOT NULL CHECK (invoice_type IN ('association_fee', 'special_assessment', 'penalty', 'other')),
  amount DECIMAL(10,2) NOT NULL,
  due_date DATE NOT NULL,
  billing_period_start DATE,
  billing_period_end DATE,
  invoice_status TEXT NOT NULL DEFAULT 'unpaid' CHECK (invoice_status IN ('unpaid', 'partial', 'paid', 'overdue', 'cancelled')),
  amount_paid DECIMAL(10,2) DEFAULT 0,
  amount_remaining DECIMAL(10,2) GENERATED ALWAYS AS (amount - COALESCE(amount_paid, 0)) STORED,
  notes TEXT,
  issued_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  paid_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Payment logs table
CREATE TABLE IF NOT EXISTS payment_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  household_id UUID NOT NULL REFERENCES households(id) ON DELETE CASCADE,
  invoice_id UUID REFERENCES invoices(id) ON DELETE SET NULL,
  receipt_number TEXT NOT NULL UNIQUE,
  payment_amount DECIMAL(10,2) NOT NULL,
  payment_method TEXT NOT NULL CHECK (payment_method IN ('cash', 'check', 'bank_transfer', 'online', 'card')),
  payment_reference TEXT,
  payment_date DATE NOT NULL DEFAULT CURRENT_DATE,
  received_by UUID REFERENCES auth.users(id),
  receipt_url TEXT,
  notes TEXT,
  voided_at TIMESTAMPTZ,
  voided_by UUID REFERENCES auth.users(id),
  void_reason TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for invoices
CREATE INDEX idx_invoices_tenant ON invoices(tenant_id);
CREATE INDEX idx_invoices_household ON invoices(household_id);
CREATE INDEX idx_invoices_status ON invoices(tenant_id, invoice_status);
CREATE INDEX idx_invoices_due_date ON invoices(due_date);
CREATE INDEX idx_invoices_number ON invoices(invoice_number);

-- Indexes for payment_logs
CREATE INDEX idx_payment_logs_tenant ON payment_logs(tenant_id);
CREATE INDEX idx_payment_logs_household ON payment_logs(household_id);
CREATE INDEX idx_payment_logs_invoice ON payment_logs(invoice_id);
CREATE INDEX idx_payment_logs_receipt ON payment_logs(receipt_number);
CREATE INDEX idx_payment_logs_date ON payment_logs(payment_date);

-- Trigger for updated_at
CREATE TRIGGER update_invoices_updated_at
  BEFORE UPDATE ON invoices
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_payment_logs_updated_at
  BEFORE UPDATE ON payment_logs
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Function to generate receipt number
CREATE OR REPLACE FUNCTION generate_receipt_number()
RETURNS TEXT AS $$
DECLARE
  receipt_num TEXT;
  year_part TEXT;
  sequence_num INTEGER;
BEGIN
  year_part := TO_CHAR(CURRENT_DATE, 'YYYY');

  SELECT COALESCE(MAX(CAST(SUBSTRING(receipt_number FROM 'RCP-' || year_part || '-([0-9]+)') AS INTEGER)), 0) + 1
  INTO sequence_num
  FROM payment_logs
  WHERE receipt_number LIKE 'RCP-' || year_part || '-%';

  receipt_num := 'RCP-' || year_part || '-' || LPAD(sequence_num::TEXT, 6, '0');
  RETURN receipt_num;
END;
$$ LANGUAGE plpgsql;

-- Function to generate invoice number
CREATE OR REPLACE FUNCTION generate_invoice_number()
RETURNS TEXT AS $$
DECLARE
  inv_num TEXT;
  year_part TEXT;
  sequence_num INTEGER;
BEGIN
  year_part := TO_CHAR(CURRENT_DATE, 'YYYY');

  SELECT COALESCE(MAX(CAST(SUBSTRING(invoice_number FROM 'INV-' || year_part || '-([0-9]+)') AS INTEGER)), 0) + 1
  INTO sequence_num
  FROM invoices
  WHERE invoice_number LIKE 'INV-' || year_part || '-%';

  inv_num := 'INV-' || year_part || '-' || LPAD(sequence_num::TEXT, 6, '0');
  RETURN inv_num;
END;
$$ LANGUAGE plpgsql;

-- Trigger function to update invoice status based on payments
CREATE OR REPLACE FUNCTION update_invoice_status()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE invoices
  SET
    invoice_status = CASE
      WHEN amount_paid >= amount THEN 'paid'
      WHEN amount_paid > 0 AND amount_paid < amount THEN 'partial'
      WHEN due_date < CURRENT_DATE AND amount_paid < amount THEN 'overdue'
      ELSE 'unpaid'
    END,
    paid_at = CASE WHEN amount_paid >= amount THEN NOW() ELSE NULL END
  WHERE id = NEW.invoice_id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-update invoice status when payment is recorded
CREATE TRIGGER trigger_update_invoice_status
  AFTER INSERT ON payment_logs
  FOR EACH ROW
  WHEN (NEW.invoice_id IS NOT NULL AND NEW.voided_at IS NULL)
  EXECUTE FUNCTION update_invoice_status();

-- Comments
COMMENT ON TABLE invoices IS 'Billing invoices for association fees and assessments';
COMMENT ON TABLE payment_logs IS 'Payment records with receipt generation';
COMMENT ON COLUMN invoices.amount_remaining IS 'Auto-calculated remaining balance';

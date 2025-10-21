-- Guest Management System Migration
-- Creates tables for guest registration, check-in/check-out, and verification

-- Guests table for storing guest information and visit details
CREATE TABLE IF NOT EXISTS guests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    household_id UUID NOT NULL REFERENCES households(id) ON DELETE CASCADE,

    -- Guest personal information
    guest_name TEXT NOT NULL,
    phone_number TEXT NOT NULL,
    purpose TEXT NOT NULL,
    scheduled_date TIMESTAMP WITH TIME ZONE NOT NULL,
    expected_arrival TEXT NOT NULL, -- Time stored as HH:MM string
    expected_departure TEXT NOT NULL, -- Time stored as HH:MM string

    -- Status and tracking
    status TEXT NOT NULL DEFAULT 'expected' CHECK (status IN ('expected', 'checked_in', 'checked_out', 'cancelled')),
    vehicle_info TEXT,
    notes TEXT,
    approved_by_guard_id UUID REFERENCES user_profiles(id),
    actual_arrival TIMESTAMP WITH TIME ZONE,
    actual_departure TIMESTAMP WITH TIME ZONE,

    -- Metadata
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Guest check-in logs for detailed audit trail
CREATE TABLE IF NOT EXISTS guest_checkin_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    guest_id UUID NOT NULL REFERENCES guests(id) ON DELETE CASCADE,
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,

    -- Check-in details
    check_in_timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    check_in_by UUID REFERENCES user_profiles(id),
    actual_arrival TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    temperature_celsius DECIMAL(3,1),

    -- Verification checklist
    id_verified BOOLEAN DEFAULT false,
    purpose_confirmed BOOLEAN DEFAULT false,
    temperature_checked BOOLEAN DEFAULT false,
    escort_assigned BOOLEAN DEFAULT false,

    -- Security notes
    guard_notes TEXT,
    security_flags TEXT[] DEFAULT '{}',

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Guest verification photos (for face recognition verification)
CREATE TABLE IF NOT EXISTS guest_verification_photos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    guest_id UUID NOT NULL REFERENCES guests(id) ON DELETE CASCADE,
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,

    -- Photo details
    photo_url TEXT NOT NULL,
    photo_type TEXT NOT NULL CHECK (photo_type IN ('check_in', 'check_out', 'verification')),
    storage_path TEXT NOT NULL,

    -- Metadata
    file_size_bytes INTEGER,
    uploaded_by UUID REFERENCES user_profiles(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Household contact logs for communication tracking
CREATE TABLE IF NOT EXISTS household_contact_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    guest_id UUID REFERENCES guests(id) ON DELETE SET NULL,
    household_id UUID NOT NULL REFERENCES households(id) ON DELETE CASCADE,
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,

    -- Contact details
    contact_type TEXT NOT NULL CHECK (contact_type IN ('phone_call', 'sms', 'email', 'in_person')),
    contact_direction TEXT NOT NULL CHECK (contact_direction IN ('outgoing', 'incoming')),
    contact_result TEXT,

    -- Communication content
    message_content TEXT,
    contact_person_name TEXT,
    contact_person_relation TEXT,

    -- Timestamps
    contact_timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES user_profiles(id),

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for performance optimization
CREATE INDEX IF NOT EXISTS idx_guests_tenant_id ON guests(tenant_id);
CREATE INDEX IF NOT EXISTS idx_guests_household_id ON guests(household_id);
CREATE INDEX IF NOT EXISTS idx_guests_status ON guests(status);
CREATE INDEX IF NOT EXISTS idx_guests_scheduled_date ON guests(scheduled_date);
CREATE INDEX IF NOT EXISTS idx_guests_actual_arrival ON guests(actual_arrival);
CREATE INDEX IF NOT EXISTS idx_guest_checkin_logs_guest_id ON guest_checkin_logs(guest_id);
CREATE INDEX IF NOT EXISTS idx_guest_checkin_logs_timestamp ON guest_checkin_logs(check_in_timestamp);
CREATE INDEX IF NOT EXISTS idx_household_contact_logs_household_id ON household_contact_logs(household_id);
CREATE INDEX IF NOT EXISTS idx_household_contact_logs_timestamp ON household_contact_logs(contact_timestamp);
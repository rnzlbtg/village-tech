-- Create messages table for household-admin communication
CREATE TABLE IF NOT EXISTS messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  household_id UUID NOT NULL REFERENCES households(id) ON DELETE CASCADE,
  admin_id UUID REFERENCES admin_users(id) ON DELETE SET NULL,
  message_type VARCHAR(50) NOT NULL CHECK (message_type IN ('household_to_admin', 'admin_to_household')),
  subject TEXT,
  content TEXT NOT NULL,
  is_read BOOLEAN DEFAULT false,
  read_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index for performance
CREATE INDEX idx_messages_household_id ON messages(household_id);
CREATE INDEX idx_messages_admin_id ON messages(admin_id);
CREATE INDEX idx_messages_type ON messages(message_type);
CREATE INDEX idx_messages_is_read ON messages(is_read);
CREATE INDEX idx_messages_created_at ON messages(created_at);
CREATE INDEX idx_messages_household_type ON messages(household_id, message_type);
CREATE INDEX idx_messages_household_unread ON messages(household_id, message_type, is_read);

-- Add updated_at trigger
CREATE TRIGGER update_messages_updated_at
  BEFORE UPDATE ON messages
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Add RLS (Row Level Security)
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- RLS Policies for messages table

-- 1. Household users can only see messages for their own household
CREATE POLICY "Households can view their own messages"
  ON messages FOR SELECT
  USING (
    household_id = (auth.jwt() ->> 'household_id')::UUID
  );

-- 2. Household users can only insert messages of type household_to_admin for their household
CREATE POLICY "Households can send messages to admin"
  ON messages FOR INSERT
  WITH CHECK (
    message_type = 'household_to_admin' AND
    household_id = (auth.jwt() ->> 'household_id')::UUID AND
    admin_id IS NULL
  );

-- 3. Household users can only update is_read and read_at fields for messages sent to them
CREATE POLICY "Households can mark received messages as read"
  ON messages FOR UPDATE
  USING (
    household_id = (auth.jwt() ->> 'household_id')::UUID AND
    message_type = 'admin_to_household'
  )
  WITH CHECK (
    household_id = (auth.jwt() ->> 'household_id')::UUID AND
    message_type = 'admin_to_household' AND
    is_read = true AND
    -- Only allow updating is_read and read_at fields
    id = id AND
    household_id = household_id AND
    admin_id = admin_id AND
    message_type = message_type AND
    subject = subject AND
    content = content AND
    created_at = created_at
  );

-- 4. Admin users can view all messages for their tenant
CREATE POLICY "Admins can view all messages for their tenant"
  ON messages FOR SELECT
  USING (
    (auth.jwt() ->> 'app_role')::TEXT IN ('admin_head', 'admin_officer') AND
    household_id IN (
      SELECT h.id FROM households h
      WHERE h.residence_unit_id IN (
        SELECT ru.id FROM residence_units ru
        WHERE ru.property_id IN (
          SELECT p.id FROM properties p
          WHERE p.tenant_id = (auth.jwt() ->> 'tenant_id')::UUID
        )
      )
    )
  );

-- 5. Admin users can insert messages of type admin_to_household for households in their tenant
CREATE POLICY "Admins can send messages to households"
  ON messages FOR INSERT
  WITH CHECK (
    (auth.jwt() ->> 'app_role')::TEXT IN ('admin_head', 'admin_officer') AND
    message_type = 'admin_to_household' AND
    household_id IN (
      SELECT h.id FROM households h
      WHERE h.residence_unit_id IN (
        SELECT ru.id FROM residence_units ru
        WHERE ru.property_id IN (
          SELECT p.id FROM properties p
          WHERE p.tenant_id = (auth.jwt() ->> 'tenant_id')::UUID
        )
      )
    )
  );

-- 6. Admin users can update messages for households in their tenant
CREATE POLICY "Admins can update messages for their tenant"
  ON messages FOR UPDATE
  USING (
    (auth.jwt() ->> 'app_role')::TEXT IN ('admin_head', 'admin_officer') AND
    household_id IN (
      SELECT h.id FROM households h
      WHERE h.residence_unit_id IN (
        SELECT ru.id FROM residence_units ru
        WHERE ru.property_id IN (
          SELECT p.id FROM properties p
          WHERE p.tenant_id = (auth.jwt() ->> 'tenant_id')::UUID
        )
      )
    )
  );

-- 7. Super Admin can access all messages
CREATE POLICY "Super Admin full access to messages"
  ON messages FOR ALL
  USING ((auth.jwt() ->> 'app_role')::TEXT = 'super_admin')
  WITH CHECK ((auth.jwt() ->> 'app_role')::TEXT = 'super_admin');

-- Add comments for documentation
COMMENT ON TABLE messages IS 'Messages for household-admin communication';
COMMENT ON COLUMN messages.id IS 'Unique identifier for the message';
COMMENT ON COLUMN messages.household_id IS 'Reference to the household';
COMMENT ON COLUMN messages.admin_id IS 'Reference to the admin user (if applicable)';
COMMENT ON COLUMN messages.message_type IS 'Type of message: household_to_admin or admin_to_household';
COMMENT ON COLUMN messages.subject IS 'Optional subject line for the message';
COMMENT ON COLUMN messages.content IS 'Content of the message';
COMMENT ON COLUMN messages.is_read IS 'Whether the message has been read';
COMMENT ON COLUMN messages.read_at IS 'Timestamp when the message was marked as read';
COMMENT ON COLUMN messages.created_at IS 'Timestamp when the message was created';
COMMENT ON COLUMN messages.updated_at IS 'Timestamp when the message was last updated';
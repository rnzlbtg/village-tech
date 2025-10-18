-- Migration: Create FCM tokens table for push notifications
-- Description: Stores Firebase Cloud Messaging tokens for mobile app push notifications
-- Author: System
-- Date: 2025-10-15

-- Create fcm_tokens table
CREATE TABLE fcm_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  household_id UUID REFERENCES households(id) ON DELETE CASCADE,
  token TEXT NOT NULL,
  platform TEXT NOT NULL DEFAULT 'android' CHECK (platform IN ('android', 'ios')),
  device_info JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  last_used_at TIMESTAMPTZ,
  UNIQUE(user_id, token)
);

-- Add comments for documentation
COMMENT ON TABLE fcm_tokens IS 'Stores Firebase Cloud Messaging tokens for push notifications';
COMMENT ON COLUMN fcm_tokens.user_id IS 'References auth.users - owner of the FCM token';
COMMENT ON COLUMN fcm_tokens.household_id IS 'References households - for household-level targeting';
COMMENT ON COLUMN fcm_tokens.token IS 'Firebase Cloud Messaging device token';
COMMENT ON COLUMN fcm_tokens.platform IS 'Device platform (android or ios)';
COMMENT ON COLUMN fcm_tokens.device_info IS 'Additional device information (model, OS version, etc)';
COMMENT ON COLUMN fcm_tokens.last_used_at IS 'Last time notification was sent to this token';

-- Create indexes for performance
CREATE INDEX idx_fcm_tokens_user_id ON fcm_tokens(user_id);
CREATE INDEX idx_fcm_tokens_household_id ON fcm_tokens(household_id);
CREATE INDEX idx_fcm_tokens_platform ON fcm_tokens(platform);
CREATE INDEX idx_fcm_tokens_created_at ON fcm_tokens(created_at DESC);

-- Enable Row Level Security
ALTER TABLE fcm_tokens ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can manage their own FCM tokens
CREATE POLICY "Users can insert their own FCM tokens"
ON fcm_tokens FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view their own FCM tokens"
ON fcm_tokens FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own FCM tokens"
ON fcm_tokens FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own FCM tokens"
ON fcm_tokens FOR DELETE
USING (auth.uid() = user_id);

-- RLS Policy: Service role has full access (for backend notification system)
CREATE POLICY "Service role full access to FCM tokens"
ON fcm_tokens FOR ALL
USING (auth.jwt() ->> 'role' = 'service_role');

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_fcm_tokens_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to auto-update updated_at
CREATE TRIGGER fcm_tokens_updated_at
BEFORE UPDATE ON fcm_tokens
FOR EACH ROW
EXECUTE FUNCTION update_fcm_tokens_updated_at();

-- Create function to clean up old/invalid tokens (optional utility)
CREATE OR REPLACE FUNCTION cleanup_old_fcm_tokens(days_old INTEGER DEFAULT 90)
RETURNS INTEGER AS $$
DECLARE
  deleted_count INTEGER;
BEGIN
  DELETE FROM fcm_tokens
  WHERE last_used_at < NOW() - (days_old || ' days')::INTERVAL
    OR (last_used_at IS NULL AND created_at < NOW() - (days_old || ' days')::INTERVAL);
  
  GET DIAGNOSTICS deleted_count = ROW_COUNT;
  RETURN deleted_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION cleanup_old_fcm_tokens IS 'Clean up FCM tokens that have not been used in specified days (default 90)';

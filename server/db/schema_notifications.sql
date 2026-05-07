-- Run once against your travel_companion database (psql or GUI).
-- user_id columns are TEXT so they match JWT `sub` whether users.id is UUID or integer.

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS notification_types (
  code TEXT PRIMARY KEY,
  label TEXT NOT NULL,
  default_enabled BOOLEAN NOT NULL DEFAULT TRUE
);

INSERT INTO notification_types (code, label, default_enabled) VALUES
  ('login', 'Sign-in alerts', TRUE),
  ('welcome', 'Welcome messages', TRUE)
ON CONFLICT (code) DO NOTHING;

CREATE TABLE IF NOT EXISTS user_notification_preferences (
  user_id TEXT NOT NULL,
  type_code TEXT NOT NULL REFERENCES notification_types (code) ON DELETE CASCADE,
  enabled BOOLEAN NOT NULL,
  PRIMARY KEY (user_id, type_code)
);

CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT NOT NULL,
  type_code TEXT NOT NULL REFERENCES notification_types (code),
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  read_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notifications_user_created
  ON notifications (user_id, created_at DESC);

CREATE TABLE IF NOT EXISTS business_profiles (
  user_id TEXT PRIMARY KEY,
  company_name TEXT,
  tagline TEXT,
  phone TEXT,
  website TEXT,
  address TEXT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Example row (replace YOUR_USER_ID with a real users.id as string):
-- INSERT INTO business_profiles (user_id, company_name, tagline, phone, website, address)
-- VALUES ('YOUR_USER_ID', 'My Travel Co.', 'We plan trips', '+92...', 'https://example.com', 'Lahore')
-- ON CONFLICT (user_id) DO UPDATE SET company_name = EXCLUDED.company_name, updated_at = NOW();

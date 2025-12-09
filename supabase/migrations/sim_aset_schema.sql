-- =====================================================
-- SIM-ASET DATABASE SCHEMA FOR SUPABASE
-- Run this in Supabase SQL Editor
-- =====================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ==================== LOCATIONS ====================
CREATE TABLE IF NOT EXISTS locations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  building TEXT,
  floor TEXT,
  room TEXT,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==================== ASSETS ====================
CREATE TABLE IF NOT EXISTS assets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  qr_code TEXT UNIQUE NOT NULL,
  category TEXT NOT NULL, -- 'elektronik', 'furniture', 'kendaraan', 'it_equipment', 'lainnya'
  location_id UUID REFERENCES locations(id) ON DELETE SET NULL,
  status TEXT DEFAULT 'active', -- 'active', 'inactive', 'disposed'
  condition TEXT DEFAULT 'good', -- 'good', 'fair', 'poor', 'broken'
  purchase_date DATE,
  purchase_price DECIMAL(15,2),
  warranty_until DATE,
  image_url TEXT,
  notes TEXT,
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_assets_category ON assets(category);
CREATE INDEX IF NOT EXISTS idx_assets_status ON assets(status);
CREATE INDEX IF NOT EXISTS idx_assets_location ON assets(location_id);
CREATE INDEX IF NOT EXISTS idx_assets_qr_code ON assets(qr_code);

-- ==================== MAINTENANCE LOGS ====================
CREATE TABLE IF NOT EXISTS maintenance_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  asset_id UUID REFERENCES assets(id) ON DELETE CASCADE,
  technician_id UUID REFERENCES auth.users(id),
  type TEXT NOT NULL, -- 'scheduled', 'repair', 'inspection', 'upgrade'
  title TEXT NOT NULL,
  description TEXT,
  status TEXT DEFAULT 'pending', -- 'pending', 'in_progress', 'completed', 'cancelled'
  priority TEXT DEFAULT 'normal', -- 'low', 'normal', 'high', 'urgent'
  scheduled_at TIMESTAMPTZ,
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  notes TEXT,
  cost DECIMAL(15,2),
  before_image_url TEXT,
  after_image_url TEXT,
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_maintenance_asset ON maintenance_logs(asset_id);
CREATE INDEX IF NOT EXISTS idx_maintenance_technician ON maintenance_logs(technician_id);
CREATE INDEX IF NOT EXISTS idx_maintenance_status ON maintenance_logs(status);
CREATE INDEX IF NOT EXISTS idx_maintenance_scheduled ON maintenance_logs(scheduled_at);

-- ==================== BOOKINGS ====================
CREATE TABLE IF NOT EXISTS bookings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  asset_id UUID REFERENCES assets(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id),
  title TEXT NOT NULL,
  purpose TEXT,
  start_time TIMESTAMPTZ NOT NULL,
  end_time TIMESTAMPTZ NOT NULL,
  status TEXT DEFAULT 'pending', -- 'pending', 'approved', 'rejected', 'cancelled', 'completed'
  approved_by UUID REFERENCES auth.users(id),
  approved_at TIMESTAMPTZ,
  rejection_reason TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Note: EXCLUDE constraint for overlap detection requires btree_gist extension
-- Run separately: CREATE EXTENSION IF NOT EXISTS btree_gist;
-- Then add: ALTER TABLE bookings ADD CONSTRAINT no_booking_overlap 
--   EXCLUDE USING gist (asset_id WITH =, tstzrange(start_time, end_time) WITH &&) 
--   WHERE (status = 'approved');

CREATE INDEX IF NOT EXISTS idx_bookings_asset ON bookings(asset_id);
CREATE INDEX IF NOT EXISTS idx_bookings_user ON bookings(user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_status ON bookings(status);
CREATE INDEX IF NOT EXISTS idx_bookings_time ON bookings(start_time, end_time);

-- ==================== INVENTORY MUTATIONS ====================
-- Extends existing inventory_items table
CREATE TABLE IF NOT EXISTS inventory_mutations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  item_id UUID REFERENCES inventory_items(id) ON DELETE CASCADE,
  type TEXT NOT NULL, -- 'in', 'out', 'adjustment', 'opname'
  quantity INTEGER NOT NULL,
  previous_stock INTEGER,
  new_stock INTEGER,
  reason TEXT,
  reference_no TEXT,
  performed_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_mutations_item ON inventory_mutations(item_id);
CREATE INDEX IF NOT EXISTS idx_mutations_type ON inventory_mutations(type);
CREATE INDEX IF NOT EXISTS idx_mutations_date ON inventory_mutations(created_at);

-- ==================== NOTIFICATIONS ====================
CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  body TEXT,
  type TEXT NOT NULL, -- 'task', 'booking', 'maintenance', 'inventory', 'system'
  reference_type TEXT, -- 'asset', 'booking', 'maintenance', etc
  reference_id UUID,
  is_read BOOLEAN DEFAULT false,
  read_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_unread ON notifications(user_id, is_read) WHERE is_read = false;

-- ==================== FCM TOKENS ====================
CREATE TABLE IF NOT EXISTS user_fcm_tokens (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  token TEXT NOT NULL,
  device_type TEXT, -- 'android', 'ios', 'web'
  device_name TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, token)
);

-- ==================== ROW LEVEL SECURITY ====================

ALTER TABLE locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE assets ENABLE ROW LEVEL SECURITY;
ALTER TABLE maintenance_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_fcm_tokens ENABLE ROW LEVEL SECURITY;

-- Locations: All authenticated users can read
CREATE POLICY "Locations viewable by authenticated users" ON locations
  FOR SELECT USING (auth.role() = 'authenticated');

-- Assets: All authenticated users can read
CREATE POLICY "Assets viewable by authenticated users" ON assets
  FOR SELECT USING (auth.role() = 'authenticated');

-- Maintenance: All authenticated users can read
CREATE POLICY "Maintenance viewable by authenticated users" ON maintenance_logs
  FOR SELECT USING (auth.role() = 'authenticated');

-- Bookings: All authenticated users can read
CREATE POLICY "Bookings viewable by authenticated users" ON bookings
  FOR SELECT USING (auth.role() = 'authenticated');

-- Notifications: Users can only see their own
CREATE POLICY "Users can view own notifications" ON notifications
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own notifications" ON notifications
  FOR UPDATE USING (auth.uid() = user_id);

-- FCM Tokens: Users can manage their own
CREATE POLICY "Users can manage own FCM tokens" ON user_fcm_tokens
  FOR ALL USING (auth.uid() = user_id);

-- ==================== AUTO UPDATE TRIGGERS ====================

CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply triggers
DROP TRIGGER IF EXISTS tr_locations_updated_at ON locations;
CREATE TRIGGER tr_locations_updated_at
  BEFORE UPDATE ON locations
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS tr_assets_updated_at ON assets;
CREATE TRIGGER tr_assets_updated_at
  BEFORE UPDATE ON assets
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS tr_maintenance_updated_at ON maintenance_logs;
CREATE TRIGGER tr_maintenance_updated_at
  BEFORE UPDATE ON maintenance_logs
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS tr_bookings_updated_at ON bookings;
CREATE TRIGGER tr_bookings_updated_at
  BEFORE UPDATE ON bookings
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ==================== SEED DATA (Optional) ====================

-- Sample locations
INSERT INTO locations (name, building, floor, room) VALUES
  ('Ruang Server', 'Gedung Utama', '1', 'R-101'),
  ('Ruang Meeting A', 'Gedung Utama', '2', 'R-201'),
  ('Lobby', 'Gedung Utama', '1', 'Lobby'),
  ('Kantin', 'Gedung Pendukung', '1', 'K-001')
ON CONFLICT DO NOTHING;

-- =====================================================
-- END OF MIGRATION
-- =====================================================

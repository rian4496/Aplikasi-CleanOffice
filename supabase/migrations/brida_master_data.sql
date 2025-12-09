-- =====================================================
-- BRIDA MASTER DATA - ASSET CATEGORIES
-- Run this in Supabase SQL Editor after sim_aset_schema.sql
-- =====================================================

-- CLEANUP: Drop existing master tables to recreate with correct schema
DROP TABLE IF EXISTS asset_categories CASCADE;
DROP TABLE IF EXISTS asset_types CASCADE;
DROP TABLE IF EXISTS departments CASCADE;
DROP TABLE IF EXISTS asset_conditions CASCADE;

-- ==================== ASSET TYPES ====================
-- Tipe Aset: Bergerak vs Tidak Bergerak
CREATE TABLE IF NOT EXISTS asset_types (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO asset_types (code, name, description) VALUES
  ('movable', 'Aset Bergerak', 'Barang yang dapat dipindahkan tanpa mengubah fungsinya'),
  ('immovable', 'Aset Tidak Bergerak', 'Kekayaan tetap yang tidak dapat dipindahkan')
ON CONFLICT (code) DO NOTHING;

-- ==================== ASSET CATEGORIES ====================
-- Kategori Aset berdasarkan tipe
CREATE TABLE IF NOT EXISTS asset_categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  type_id UUID REFERENCES asset_types(id) ON DELETE CASCADE,
  code TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  icon TEXT, -- Icon name untuk Flutter
  description TEXT,
  sort_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Get type IDs
DO $$
DECLARE
  movable_id UUID;
  immovable_id UUID;
BEGIN
  SELECT id INTO movable_id FROM asset_types WHERE code = 'movable';
  SELECT id INTO immovable_id FROM asset_types WHERE code = 'immovable';

  -- ASET BERGERAK
  INSERT INTO asset_categories (type_id, code, name, icon, description, sort_order) VALUES
    (movable_id, 'kendaraan', 'Kendaraan Dinas', 'directions_car', 'Mobil, Motor, Truk operasional', 1),
    (movable_id, 'komputer', 'Peralatan IT', 'computer', 'Komputer, Laptop, Printer, Server', 2),
    (movable_id, 'lab', 'Peralatan Laboratorium', 'biotech', 'Alat riset, Alat ukur, Instrumen lab', 3),
    (movable_id, 'elektronik', 'Elektronik Kantor', 'devices', 'AC, Proyektor, TV, Sound System', 4),
    (movable_id, 'furniture', 'Furniture', 'chair', 'Meja, Kursi, Lemari, Filing Cabinet', 5),
    (movable_id, 'alat_kantor', 'Alat Kantor', 'print', 'Mesin fotocopy, Mesin jilid, dll', 6)
  ON CONFLICT (code) DO NOTHING;

  -- ASET TIDAK BERGERAK
  INSERT INTO asset_categories (type_id, code, name, icon, description, sort_order) VALUES
    (immovable_id, 'gedung', 'Gedung & Bangunan', 'business', 'Gedung kantor, Gudang, Ruang kerja', 10),
    (immovable_id, 'tanah', 'Tanah', 'terrain', 'Tanah kantor, Lahan', 11),
    (immovable_id, 'infrastruktur', 'Infrastruktur', 'foundation', 'Pagar, Taman, Area parkir, Jalan', 12),
    (immovable_id, 'instalasi', 'Instalasi', 'electrical_services', 'Jaringan listrik, Air, Internet', 13)
  ON CONFLICT (code) DO NOTHING;
END $$;

-- ==================== DEPARTMENTS (BRIDA) ====================
CREATE TABLE IF NOT EXISTS departments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  parent_id UUID REFERENCES departments(id),
  description TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO departments (code, name, description) VALUES
  ('sekretariat', 'Sekretariat', 'Kesekretariatan BRIDA'),
  ('bid_riset', 'Bidang Riset', 'Bidang Riset dan Pengembangan'),
  ('bid_inovasi', 'Bidang Inovasi', 'Bidang Inovasi Daerah'),
  ('bid_ppi', 'Bidang PPI', 'Bidang Penguatan dan Pembinaan Inovasi'),
  ('upt', 'UPT', 'Unit Pelaksana Teknis')
ON CONFLICT (code) DO NOTHING;

-- ==================== ASSET CONDITIONS ====================
CREATE TABLE IF NOT EXISTS asset_conditions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  color TEXT, -- Hex color for UI
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO asset_conditions (code, name, color, sort_order) VALUES
  ('baik', 'Baik', '#4CAF50', 1),           -- Green
  ('cukup', 'Cukup Baik', '#2196F3', 2),    -- Blue
  ('kurang', 'Kurang Baik', '#FF9800', 3),  -- Orange
  ('rusak_ringan', 'Rusak Ringan', '#FF5722', 4),  -- Deep Orange
  ('rusak_berat', 'Rusak Berat', '#F44336', 5)     -- Red
ON CONFLICT (code) DO NOTHING;

-- ==================== LOCATIONS (BRIDA - Alphabetical Order) ====================
DELETE FROM locations;

INSERT INTO locations (name, building, floor, room, description) VALUES
  ('Gudang', 'Gedung G', '1', 'GG-003', 'Gudang penyimpanan (belakang lobi)'),
  ('Koridor Penghubung', 'Gedung G', '1', 'GG-002', 'Bridge penghubung antar gedung'),
  ('Mushola', 'Gedung G', '1', 'GG-005', 'Mushola BRIDA'),
  ('Parkir Indoor', 'Gedung A', '1', 'GA-001', 'Parkir kendaraan indoor'),
  ('Parkir Outdoor', NULL, NULL, 'Outdoor', 'Area parkir luar'),
  ('Ruang Aula', 'Gedung D', '1', 'GD-001', 'Aula untuk event dan seminar'),
  ('Ruang Baca', 'Gedung G', '1', 'GG-004', 'Ruang baca/perpustakaan'),
  ('Ruang Bidang Inovasi', 'Gedung B', '1', 'GB-001', 'Ruang Kepala Bidang Inovasi dan staf'),
  ('Ruang Bidang Riset', 'Gedung C', '1', 'GC-001', 'Ruang Kepala Bidang Riset dan staf'),
  ('Ruang Generator', 'Bangunan Generator', '1', 'GEN-001', 'Generator listrik'),
  ('Ruang Kantin', 'Gedung A', '1', 'GA-002', 'Kantin BRIDA'),
  ('Ruang Kasubbag Keuangan', 'Gedung E', '1', 'GE-001', 'Ruang Kepala Sub Bagian Keuangan'),
  ('Ruang Kasubbag Umpeg', 'Gedung E', '1', 'GE-003', 'Ruang Kepala Sub Bagian Umpeg'),
  ('Ruang Kepala BRIDA', 'Gedung G', '2', 'GG-201', 'Ruang Kepala Badan (Lt.2)'),
  ('Ruang Keuangan', 'Gedung E', '1', 'GE-002', 'Ruang staf Keuangan'),
  ('Ruang Lobi', 'Gedung G', '1', 'GG-001', 'Lobi utama'),
  ('Ruang Rapat Kecil', 'Gedung G', '2', 'GG-202', 'Ruang rapat kecil (Lt.2)'),
  ('Ruang Sekretariat', 'Gedung B', '1', 'GB-002', 'Ruang Sekretariat'),
  ('Ruang Sekretaris Badan', 'Gedung F', '1', 'GF-001', 'Ruang Sekretaris Badan BRIDA'),
  ('Ruang Umpeg', 'Gedung E', '1', 'GE-004', 'Ruang Umum dan Kepegawaian'),
  ('Taman Indoor', 'Gedung G', '1', 'GG-006', 'Taman kecil indoor'),
  ('WC Pria Gedung E', 'Gedung E', '1', 'WC-EP', 'Toilet pria Gedung E'),
  ('WC Pria Gedung F', 'Gedung F', '1', 'WC-FP', 'Toilet pria Gedung F'),
  ('WC Wanita Gedung E', 'Gedung E', '1', 'WC-EW', 'Toilet wanita Gedung E'),
  ('WC Wanita Gedung F', 'Gedung F', '1', 'WC-FW', 'Toilet wanita Gedung F')
ON CONFLICT DO NOTHING;

-- ==================== UPDATE ASSETS TABLE ====================
-- Add foreign keys to new master tables
ALTER TABLE assets 
ADD COLUMN IF NOT EXISTS type_id UUID REFERENCES asset_types(id),
ADD COLUMN IF NOT EXISTS category_id UUID REFERENCES asset_categories(id),
ADD COLUMN IF NOT EXISTS department_id UUID REFERENCES departments(id),
ADD COLUMN IF NOT EXISTS condition_id UUID REFERENCES asset_conditions(id);

-- ==================== RLS POLICIES ====================
ALTER TABLE asset_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE asset_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE departments ENABLE ROW LEVEL SECURITY;
ALTER TABLE asset_conditions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Master data viewable by authenticated users" ON asset_types
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Asset categories viewable by authenticated users" ON asset_categories
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Departments viewable by authenticated users" ON departments
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Asset conditions viewable by authenticated users" ON asset_conditions
  FOR SELECT USING (auth.role() = 'authenticated');

-- =====================================================
-- END OF BRIDA MASTER DATA
-- =====================================================

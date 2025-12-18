-- =====================================================
-- BRIDA ERP SEED DATA (DUMMY)
-- Run this AFTER brida_erp_foundation.sql
-- =====================================================

-- 1. DEPARTMENTS (ORGANISASI)
insert into departments (id, code, name, description) values 
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '01', 'Kepala Badan', 'Pimpinan Tertinggi'),
('b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', '01.01', 'Sekretariat', 'Administrasi Umum'),
('c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a33', '01.02', 'Bidang Riset & Inovasi', 'Penelitian Utama');

-- 2. PEGAWAI
insert into master_pegawai (nip, nama_lengkap, jabatan, status, unit_kerja_id, foto_url) values
('198001012005011001', 'Dr. H. Andi Syahputra, M.Si', 'Kepala Badan', 'aktif', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'https://placehold.co/200/1A4D8C/white?text=AS'),
('198502022010012002', 'Rina Wulandari, S.Kom', 'Sekretaris', 'aktif', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'https://placehold.co/200/FFC107/black?text=RW'),
('199003032015011003', 'Budi Santoso, ST', 'Kabid Riset', 'aktif', 'c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a33', 'https://placehold.co/200/1A4D8C/white?text=BS');

-- 3. ANGGARAN
insert into master_anggaran (kode_rekening, uraian, tahun_anggaran, pagu_awal, pagu_terpakai) values
('5.1.02.01.01.0001', 'Belanja Alat Tulis Kantor', 2025, 50000000, 12500000),
('5.1.02.01.01.0002', 'Belanja Bahan Komputer', 2025, 75000000, 45000000),
('5.2.02.05.01.0005', 'Belanja Modal PC/Laptop', 2025, 200000000, 0);

-- 4. ASET (INVENTARIS)
insert into master_assets (asset_code, name, condition_id, location_id, image_url) values
('AST-2024-001', 'MacBook Pro M3 Pro', 'baik', 'Ruang Kepala', 'https://placehold.co/400/1A4D8C/white?text=MacBook'),
('AST-2024-002', 'Kursi Kerja Ergonomis', 'rusak_ringan', 'Ruang Staff', 'https://placehold.co/400/FFC107/black?text=Chair'),
('AST-2023-055', 'Proyektor Epson EB-X500', 'baik', 'Aula', 'https://placehold.co/400/1A4D8C/white?text=Projector'),
('AST-2022-010', 'Toyota Avanza Veloz', 'rusak_berat', 'Parkiran', 'https://placehold.co/400/333333/white?text=Car');

-- 5. VENDOR
insert into master_vendor (nama_perusahaan, npwp, kontak_person, status_verifikasi, rating) values
('PT. Sarana Informatika', '01.234.567.8-111.000', 'Bpk. Wijaya', 'verified', 4.8),
('CV. Maju Jaya Furniture', '02.345.678.9-222.000', 'Ibu Siska', 'verified', 4.5),
('UD. Berkah Abadi', '03.456.789.0-333.000', 'Mas Tono', 'unverified', 0.0),
('PT. Nakal Sekali', '99.999.999.9-999.999', 'Mr. X', 'blacklist', 1.0);

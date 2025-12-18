-- =====================================================
-- BRIDA ERP TRANSACTION SEED
-- Run this AFTER brida_erp_transactions.sql
-- =====================================================

-- 1. PROCUREMENT REQUESTS
-- 1a. Pending Request
insert into transactions_procurement (id, code, request_date, status, description, total_estimated_budget) values 
('d1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'REQ-2025-001', CURRENT_DATE, 'pending', 'Pengadaan Laptop Baru untuk Tim Dev', 45000000);

insert into transaction_procurement_items (procurement_id, item_name, quantity, unit_price_estimate) values
('d1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'MacBook Air M2', 3, 15000000);

-- 1b. Completed PO
insert into transactions_procurement (id, code, request_date, status, description, total_estimated_budget, po_number, vendor_id) values 
('d2eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'REQ-2025-002', CURRENT_DATE - 5, 'completed', 'Pembelian ATK Bulanan', 5000000, 'PO/2025/005', (SELECT id FROM master_vendor LIMIT 1));

insert into transaction_procurement_items (procurement_id, item_name, quantity, unit_price_estimate) values
('d2eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'Kertas A4 Rim', 50, 60000),
('d2eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'Tinta Printer Epson', 10, 200000);


-- 2. MAINTENANCE TICKETS
-- 2a. Reported Issue
insert into transactions_maintenance (code, asset_id, issue_title, issue_description, priority, status) values
('MT-2025-001', (SELECT id FROM master_assets WHERE asset_code='AST-2022-010' LIMIT 1), 'AC Mobil Gak Dingin', 'Freon habis atau kompresor masalah', 'high', 'reported');

-- 2b. In Progress Issue
insert into transactions_maintenance (code, asset_id, issue_title, issue_description, priority, status, assigned_technician_id) values
('MT-2025-002', (SELECT id FROM master_assets WHERE asset_code='AST-2024-002' LIMIT 1), 'Roda Kursi Macet', 'Perlu diganti rodanya', 'normal', 'in_progress', (SELECT id FROM master_pegawai LIMIT 1));

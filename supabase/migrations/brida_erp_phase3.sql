-- ==============================================================================
-- PHASE 3: DISPOSAL & REPORTING
-- ==============================================================================

-- 1. Create DISPOSAL REQUESTS Table
-- Workflow: Draft -> Proposed -> Approved/Rejected -> Execution (Sold/Destroyed) -> Completed
CREATE TABLE transactions_disposal (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT NOT NULL UNIQUE, -- DSP-YYYY-XXX
    asset_id UUID NOT NULL REFERENCES master_assets(id),
    proposer_id UUID REFERENCES auth.users(id), -- User who proposed
    
    -- Request Details
    reason TEXT NOT NULL, -- Rusak Berat, Usang, Hilang, dll
    description TEXT,
    estimated_value NUMERIC(15, 2) DEFAULT 0, -- Taksiran Nilai Jual
    
    -- Status Workflow
    status TEXT NOT NULL DEFAULT 'draft', -- draft, submitted, approved, rejected, in_process, completed
    
    -- Approval / Execution Details
    approval_date TIMESTAMP WITH TIME ZONE,
    approved_by UUID REFERENCES auth.users(id),
    
    final_disposal_type TEXT, -- Sold (Lelang), Destroyed (Pemusnahan), Donated (Hibah)
    final_value NUMERIC(15, 2), -- Harga Jual Akhir
    execution_date TIMESTAMP WITH TIME ZONE,
    
    -- Metadata
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Create RLS Policies
ALTER TABLE transactions_disposal ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Enable read access for authenticated users" ON transactions_disposal
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Enable insert for authenticated users" ON transactions_disposal
    FOR INSERT TO authenticated WITH CHECK (true);

CREATE POLICY "Enable update for authenticated users" ON transactions_disposal
    FOR UPDATE TO authenticated USING (true);

-- 3. Triggers for Updated At
CREATE TRIGGER handle_updated_at BEFORE UPDATE ON transactions_disposal
    FOR EACH ROW EXECUTE PROCEDURE moddatetime (updated_at);

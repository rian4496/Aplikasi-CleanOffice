-- Migration: RBAC & Ticketing System
-- Description: Creates tables for user roles, tickets, and cleaner schedules.
-- Date: 2024-12-16

-- ==================== USER ROLES ====================
-- Links auth.users to application roles (Admin assigns based on Jabatan)
CREATE TABLE IF NOT EXISTS public.user_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    employee_id UUID REFERENCES public.master_employees(id) ON DELETE SET NULL,
    role TEXT NOT NULL CHECK (role IN ('admin', 'kasubbag', 'cleaner', 'teknisi', 'employee')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id)
);

CREATE INDEX IF NOT EXISTS idx_user_roles_user ON public.user_roles(user_id);
CREATE INDEX IF NOT EXISTS idx_user_roles_role ON public.user_roles(role);

-- ==================== TICKETS ====================
-- Universal inbox for all types of reports/requests
CREATE TABLE IF NOT EXISTS public.tickets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ticket_number TEXT UNIQUE NOT NULL, -- Auto-generated: TKT-YYYYMMDD-XXXX
    type TEXT NOT NULL CHECK (type IN ('kerusakan', 'kebersihan', 'stock_request')),
    title TEXT NOT NULL,
    description TEXT,
    status TEXT DEFAULT 'open' CHECK (status IN ('open', 'claimed', 'in_progress', 'pending_approval', 'approved', 'rejected', 'completed', 'cancelled')),
    priority TEXT DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'urgent')),
    
    -- Relationships
    created_by UUID NOT NULL REFERENCES auth.users(id),
    assigned_to UUID REFERENCES auth.users(id),
    approved_by UUID REFERENCES auth.users(id),
    location_id UUID REFERENCES public.locations(id) ON DELETE SET NULL,
    asset_id UUID REFERENCES public.assets(id) ON DELETE SET NULL,
    
    -- For Stock Request
    inventory_item_id UUID REFERENCES public.inventory_items(id) ON DELETE SET NULL,
    requested_quantity INTEGER,
    
    -- Attachments
    image_url TEXT,
    
    -- Timestamps
    claimed_at TIMESTAMPTZ,
    approved_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_tickets_type ON public.tickets(type);
CREATE INDEX IF NOT EXISTS idx_tickets_status ON public.tickets(status);
CREATE INDEX IF NOT EXISTS idx_tickets_created_by ON public.tickets(created_by);
CREATE INDEX IF NOT EXISTS idx_tickets_assigned_to ON public.tickets(assigned_to);
CREATE INDEX IF NOT EXISTS idx_tickets_created_at ON public.tickets(created_at DESC);

-- ==================== CLEANER SCHEDULES ====================
-- Auto-generated daily cleaning tasks
CREATE TABLE IF NOT EXISTS public.cleaner_schedules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    schedule_date DATE NOT NULL,
    location_id UUID NOT NULL REFERENCES public.locations(id) ON DELETE CASCADE,
    task_type TEXT NOT NULL, -- e.g., 'daily_clean', 'deep_clean', 'sanitation'
    task_description TEXT,
    claimed_by UUID REFERENCES auth.users(id),
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'claimed', 'in_progress', 'completed', 'skipped')),
    completed_at TIMESTAMPTZ,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_cleaner_schedules_date ON public.cleaner_schedules(schedule_date);
CREATE INDEX IF NOT EXISTS idx_cleaner_schedules_location ON public.cleaner_schedules(location_id);
CREATE INDEX IF NOT EXISTS idx_cleaner_schedules_claimed_by ON public.cleaner_schedules(claimed_by);
CREATE INDEX IF NOT EXISTS idx_cleaner_schedules_status ON public.cleaner_schedules(status);

-- ==================== ROW LEVEL SECURITY ====================

ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cleaner_schedules ENABLE ROW LEVEL SECURITY;

-- User Roles: Authenticated users can read their own, Admin can manage all
CREATE POLICY "Users can view own role" ON public.user_roles
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Admin can manage all roles" ON public.user_roles
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.user_roles ur 
            WHERE ur.user_id = auth.uid() AND ur.role = 'admin'
        )
    );

-- Tickets: All authenticated can create and view, assignee can update
CREATE POLICY "Authenticated users can create tickets" ON public.tickets
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can view all tickets" ON public.tickets
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Assigned users can update tickets" ON public.tickets
    FOR UPDATE USING (
        auth.uid() = created_by 
        OR auth.uid() = assigned_to 
        OR EXISTS (
            SELECT 1 FROM public.user_roles ur 
            WHERE ur.user_id = auth.uid() AND ur.role IN ('admin', 'kasubbag')
        )
    );

-- Cleaner Schedules: All cleaners can view, claim their own
CREATE POLICY "Cleaners can view schedules" ON public.cleaner_schedules
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Cleaners can claim and update schedules" ON public.cleaner_schedules
    FOR UPDATE USING (
        claimed_by IS NULL 
        OR auth.uid() = claimed_by
        OR EXISTS (
            SELECT 1 FROM public.user_roles ur 
            WHERE ur.user_id = auth.uid() AND ur.role IN ('admin', 'kasubbag')
        )
    );

-- ==================== TRIGGERS ====================

-- Auto-generate ticket number
CREATE OR REPLACE FUNCTION generate_ticket_number()
RETURNS TRIGGER AS $$
DECLARE
    seq_num INTEGER;
BEGIN
    SELECT COALESCE(MAX(CAST(SUBSTRING(ticket_number FROM 14) AS INTEGER)), 0) + 1 INTO seq_num
    FROM public.tickets
    WHERE ticket_number LIKE 'TKT-' || TO_CHAR(CURRENT_DATE, 'YYYYMMDD') || '-%';
    
    NEW.ticket_number := 'TKT-' || TO_CHAR(CURRENT_DATE, 'YYYYMMDD') || '-' || LPAD(seq_num::TEXT, 4, '0');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tr_tickets_generate_number ON public.tickets;
CREATE TRIGGER tr_tickets_generate_number
    BEFORE INSERT ON public.tickets
    FOR EACH ROW
    WHEN (NEW.ticket_number IS NULL)
    EXECUTE FUNCTION generate_ticket_number();

-- Auto-update updated_at
DROP TRIGGER IF EXISTS tr_user_roles_updated_at ON public.user_roles;
CREATE TRIGGER tr_user_roles_updated_at
    BEFORE UPDATE ON public.user_roles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS tr_tickets_updated_at ON public.tickets;
CREATE TRIGGER tr_tickets_updated_at
    BEFORE UPDATE ON public.tickets
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS tr_cleaner_schedules_updated_at ON public.cleaner_schedules;
CREATE TRIGGER tr_cleaner_schedules_updated_at
    BEFORE UPDATE ON public.cleaner_schedules
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- =====================================================
-- END OF MIGRATION
-- =====================================================

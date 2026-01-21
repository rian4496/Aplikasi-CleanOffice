-- Migration: Update Organization Types
-- Description: Updates the CHECK constraint on master_organizations.type to include 'sekretariat' and 'sub_bagian'

-- 1. Drop the existing CHECK constraint if it exists (name usually auto-generated, but we can replace it)
-- Note: Supabase/Postgres names constraints like `table_column_check`.
-- We will try to DROP CONSTRAINT by name master_organizations_type_check.

DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'master_organizations_type_check'
    ) THEN
        ALTER TABLE public.master_organizations
        DROP CONSTRAINT master_organizations_type_check;
    END IF;
END $$;

-- 2. Add the NEW updated constraint
ALTER TABLE public.master_organizations
ADD CONSTRAINT master_organizations_type_check
CHECK (type IN ('dinas', 'sekretariat', 'bidang', 'sub_bagian', 'seksi', 'upt'));

-- 3. Verify changes (optional comment)
-- New allowed values: 'dinas', 'sekretariat', 'bidang', 'sub_bagian', 'seksi', 'upt'

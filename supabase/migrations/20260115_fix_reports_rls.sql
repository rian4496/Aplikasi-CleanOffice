-- Migration: Fix Reports RLS for Cleaners
-- Date: 2026-01-15
-- Description: Allow cleaners to see all 'pending' reports to enable claiming them.

BEGIN;

-- Drop existing restrictive policy
DROP POLICY IF EXISTS "Users can view reports in their department" ON public.reports;

-- Create new inclusive policy
CREATE POLICY "Users can view reports"
  ON public.reports FOR SELECT
  TO authenticated
  USING (
    -- 1. Reporter can see their own reports
    reporter_id = auth.uid()
    
    -- 2. Assigned cleaner can see their tasks
    OR assigned_to = auth.uid()
    
    -- 3. Admins can see ALL reports
    OR EXISTS (
      SELECT 1 FROM public.users
      WHERE id = auth.uid() AND role = 'admin'
    )
    
    -- 4. Users can see reports in their own department
    OR department_id IN (
      SELECT department_id FROM public.users WHERE id = auth.uid()
    )
    
    -- 5. Cleaners can see ALL pending reports (Global Pool)
    OR (
       status = 'pending' AND 
       EXISTS (
         SELECT 1 FROM public.users 
         WHERE id = auth.uid() AND role = 'cleaner'
       )
    )
  );

COMMIT;

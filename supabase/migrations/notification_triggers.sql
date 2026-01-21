-- ============================================
-- NOTIFICATION TRIGGERS FOR SIM-ASET BRIDA
-- Run this in Supabase SQL Editor
-- ============================================

-- 1. Create notifications table if not exists
CREATE TABLE IF NOT EXISTS notifications (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  type VARCHAR(50) NOT NULL, -- 'ticket_created', 'ticket_claimed', 'ticket_completed', etc.
  title VARCHAR(255) NOT NULL,
  message TEXT,
  data JSONB, -- Additional data like ticket_id, etc.
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add columns if table exists but columns are missing
ALTER TABLE notifications ADD COLUMN IF NOT EXISTS is_read BOOLEAN DEFAULT false;
ALTER TABLE notifications ADD COLUMN IF NOT EXISTS data JSONB;

-- Enable RLS
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view own notifications" ON notifications;
DROP POLICY IF EXISTS "Service can insert notifications" ON notifications;
DROP POLICY IF EXISTS "Users can update own notifications" ON notifications;

-- Policy: Users can only see their own notifications
CREATE POLICY "Users can view own notifications" ON notifications
  FOR SELECT USING (auth.uid() = user_id);

-- Policy: System can insert notifications for any user
CREATE POLICY "Service can insert notifications" ON notifications
  FOR INSERT WITH CHECK (true);

-- Policy: Users can update their own notifications (mark as read)
CREATE POLICY "Users can update own notifications" ON notifications
  FOR UPDATE USING (auth.uid() = user_id);

-- ============================================
-- TRIGGER FUNCTION: Notify on Ticket Created
-- ============================================
CREATE OR REPLACE FUNCTION notify_on_ticket_created()
RETURNS TRIGGER AS $$
BEGIN
  -- Notify all admins about new ticket
  INSERT INTO notifications (user_id, type, title, message, data)
  SELECT 
    u.id,
    'ticket_created',
    'Tiket Baru: ' || COALESCE(NEW.title, 'Tanpa Judul'),
    'Tiket baru telah dibuat oleh ' || COALESCE((SELECT display_name FROM users WHERE id = NEW.created_by), 'Unknown'),
    jsonb_build_object('ticket_id', NEW.id, 'ticket_number', NEW.ticket_number)
  FROM users u
  WHERE u.role = 'admin';
  
  -- Notify cleaners for kebersihan tickets
  IF NEW.type = 'kebersihan' THEN
    INSERT INTO notifications (user_id, type, title, message, data)
    SELECT 
      u.id,
      'ticket_created',
      'Tugas Baru: ' || COALESCE(NEW.title, 'Kebersihan'),
      'Ada tiket kebersihan baru menunggu dikerjakan',
      jsonb_build_object('ticket_id', NEW.id, 'ticket_number', NEW.ticket_number, 'type', NEW.type)
    FROM users u
    WHERE u.role = 'cleaner';
  END IF;
  
  -- Notify teknisi for maintenance/AC/kelistrikan tickets
  IF NEW.type IN ('pemeliharaan', 'ac', 'kelistrikan', 'perbaikan') THEN
    INSERT INTO notifications (user_id, type, title, message, data)
    SELECT 
      u.id,
      'ticket_created',
      'Tugas Baru: ' || COALESCE(NEW.title, 'Perbaikan'),
      'Ada tiket ' || NEW.type || ' baru menunggu dikerjakan',
      jsonb_build_object('ticket_id', NEW.id, 'ticket_number', NEW.ticket_number, 'type', NEW.type)
    FROM users u
    WHERE u.role = 'teknisi';
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- TRIGGER FUNCTION: Notify on Ticket Claimed
-- ============================================
CREATE OR REPLACE FUNCTION notify_on_ticket_claimed()
RETURNS TRIGGER AS $$
BEGIN
  -- Only trigger when assigned_to changes from NULL to a value
  IF OLD.assigned_to IS NULL AND NEW.assigned_to IS NOT NULL THEN
    -- Notify the ticket creator that their ticket was claimed
    INSERT INTO notifications (user_id, type, title, message, data)
    VALUES (
      NEW.created_by,
      'ticket_claimed',
      'Tiket Anda Sedang Ditangani',
      'Tiket #' || NEW.ticket_number || ' sedang ditangani oleh petugas',
      jsonb_build_object('ticket_id', NEW.id, 'ticket_number', NEW.ticket_number, 'assigned_to', NEW.assigned_to)
    );
    
    -- Also notify admins
    INSERT INTO notifications (user_id, type, title, message, data)
    SELECT 
      u.id,
      'ticket_claimed',
      'Tiket Diklaim: #' || NEW.ticket_number,
      'Tiket telah diklaim oleh ' || COALESCE((SELECT display_name FROM users WHERE id = NEW.assigned_to), 'Petugas'),
      jsonb_build_object('ticket_id', NEW.id, 'ticket_number', NEW.ticket_number)
    FROM users u
    WHERE u.role = 'admin' AND u.id != NEW.assigned_to;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- TRIGGER FUNCTION: Notify on Ticket Completed
-- ============================================
CREATE OR REPLACE FUNCTION notify_on_ticket_completed()
RETURNS TRIGGER AS $$
BEGIN
  -- Only trigger when status changes to 'completed'
  IF OLD.status != 'completed' AND NEW.status = 'completed' THEN
    -- Notify the ticket creator
    INSERT INTO notifications (user_id, type, title, message, data)
    VALUES (
      NEW.created_by,
      'ticket_completed',
      'Tiket Anda Telah Selesai',
      'Tiket #' || NEW.ticket_number || ' telah diselesaikan',
      jsonb_build_object('ticket_id', NEW.id, 'ticket_number', NEW.ticket_number)
    );
    
    -- Notify admins
    INSERT INTO notifications (user_id, type, title, message, data)
    SELECT 
      u.id,
      'ticket_completed',
      'Tiket Selesai: #' || NEW.ticket_number,
      'Tiket telah diselesaikan oleh ' || COALESCE((SELECT display_name FROM users WHERE id = NEW.assigned_to), 'Petugas'),
      jsonb_build_object('ticket_id', NEW.id, 'ticket_number', NEW.ticket_number)
    FROM users u
    WHERE u.role = 'admin';
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- CREATE TRIGGERS
-- ============================================

-- Trigger: After ticket inserted
DROP TRIGGER IF EXISTS trigger_notify_ticket_created ON tickets;
CREATE TRIGGER trigger_notify_ticket_created
  AFTER INSERT ON tickets
  FOR EACH ROW
  EXECUTE FUNCTION notify_on_ticket_created();

-- Trigger: After ticket updated (for claim)
DROP TRIGGER IF EXISTS trigger_notify_ticket_claimed ON tickets;
CREATE TRIGGER trigger_notify_ticket_claimed
  AFTER UPDATE ON tickets
  FOR EACH ROW
  EXECUTE FUNCTION notify_on_ticket_claimed();

-- Trigger: After ticket updated (for completion)
DROP TRIGGER IF EXISTS trigger_notify_ticket_completed ON tickets;
CREATE TRIGGER trigger_notify_ticket_completed
  AFTER UPDATE ON tickets
  FOR EACH ROW
  EXECUTE FUNCTION notify_on_ticket_completed();

-- ============================================
-- INDEX for better performance
-- ============================================
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read);

-- ============================================
-- DONE! Test by creating or updating a ticket
-- ============================================

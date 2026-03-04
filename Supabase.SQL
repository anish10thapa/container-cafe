-- =====================================================
-- Supabase Schema for Cafe De' Container
-- Run this in your Supabase SQL editor
-- =====================================================

-- Enable required extensions (optional, but recommended for real-time)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Members table
CREATE TABLE IF NOT EXISTS members (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
ALTER TABLE members ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'members' AND policyname = 'Public members read'
  ) THEN
    CREATE POLICY "Public members read" ON members FOR SELECT USING (true);
  END IF;
END
$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'members' AND policyname = 'Authenticated insert members'
  ) THEN
    CREATE POLICY "Authenticated insert members" ON members FOR INSERT WITH CHECK (true);
  END IF;
END
$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'members' AND policyname = 'Admin delete members'
  ) THEN
    CREATE POLICY "Admin delete members" ON members FOR DELETE USING (auth.role() = 'authenticated');
  END IF;
END
$$;

-- 2. Posts table
CREATE TABLE IF NOT EXISTS posts (
  id TEXT PRIMARY KEY,
  author_id TEXT NOT NULL,
  author_name TEXT NOT NULL,
  text TEXT,
  media JSONB DEFAULT '[]'::jsonb,
  likes JSONB DEFAULT '[]'::jsonb,
  comments JSONB DEFAULT '[]'::jsonb,
  is_sample BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'posts' AND policyname = 'Public read posts'
  ) THEN
    CREATE POLICY "Public read posts" ON posts FOR SELECT USING (true);
  END IF;
END
$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'posts' AND policyname = 'Authenticated insert posts'
  ) THEN
    CREATE POLICY "Authenticated insert posts" ON posts FOR INSERT WITH CHECK (true);
  END IF;
END
$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'posts' AND policyname = 'Update own post'
  ) THEN
    CREATE POLICY "Update own post" ON posts FOR UPDATE USING (auth.uid()::text = author_id);
  END IF;
END
$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'posts' AND policyname = 'Delete own or admin post'
  ) THEN
    CREATE POLICY "Delete own or admin post" ON posts FOR DELETE USING (true);
  END IF;
END
$$;

-- 3. Events table
CREATE TABLE IF NOT EXISTS events (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  event_date DATE NOT NULL,
  event_time TEXT,
  tag TEXT DEFAULT 'upcoming',
  icon TEXT,
  capacity TEXT,
  description TEXT,
  img_url TEXT,
  attendees INTEGER DEFAULT 0,
  interested INTEGER DEFAULT 0,
  created_at_ms BIGINT
);
ALTER TABLE events ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'events' AND policyname = 'Public read events'
  ) THEN
    CREATE POLICY "Public read events" ON events FOR SELECT USING (true);
  END IF;
END
$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'events' AND policyname = 'Authenticated insert events'
  ) THEN
    CREATE POLICY "Authenticated insert events" ON events FOR INSERT WITH CHECK (true);
  END IF;
END
$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'events' AND policyname = 'Admin update events'
  ) THEN
    CREATE POLICY "Admin update events" ON events FOR UPDATE USING (auth.role() = 'authenticated');
  END IF;
END
$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'events' AND policyname = 'Admin delete events'
  ) THEN
    CREATE POLICY "Admin delete events" ON events FOR DELETE USING (auth.role() = 'authenticated');
  END IF;
END
$$;

-- 4. Deleted events (to hide presets)
CREATE TABLE IF NOT EXISTS deleted_events (
  event_id TEXT PRIMARY KEY,
  deleted_at BIGINT
);
ALTER TABLE deleted_events ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'deleted_events' AND policyname = 'Public read deleted'
  ) THEN
    CREATE POLICY "Public read deleted" ON deleted_events FOR SELECT USING (true);
  END IF;
END
$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'deleted_events' AND policyname = 'Authenticated insert deleted'
  ) THEN
    CREATE POLICY "Authenticated insert deleted" ON deleted_events FOR INSERT WITH CHECK (true);
  END IF;
END
$$;

-- 5. Reservations table
CREATE TABLE IF NOT EXISTS reservations (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  date DATE NOT NULL,
  time TEXT NOT NULL,
  guests TEXT,
  occasion TEXT,
  notes TEXT,
  status TEXT DEFAULT 'pending',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
ALTER TABLE reservations ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'reservations' AND policyname = 'Public read reservations'
  ) THEN
    CREATE POLICY "Public read reservations" ON reservations FOR SELECT USING (true);
  END IF;
END
$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'reservations' AND policyname = 'Authenticated insert reservations'
  ) THEN
    CREATE POLICY "Authenticated insert reservations" ON reservations FOR INSERT WITH CHECK (true);
  END IF;
END
$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'reservations' AND policyname = 'Admin update reservations'
  ) THEN
    CREATE POLICY "Admin update reservations" ON reservations FOR UPDATE USING (auth.role() = 'authenticated');
  END IF;
END
$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'reservations' AND policyname = 'Admin delete reservations'
  ) THEN
    CREATE POLICY "Admin delete reservations" ON reservations FOR DELETE USING (auth.role() = 'authenticated');
  END IF;
END
$$;

-- 6. Sales table
CREATE TABLE IF NOT EXISTS sales (
  id TEXT PRIMARY KEY,
  amount NUMERIC NOT NULL,
  category TEXT,
  description TEXT,
  sale_date DATE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
ALTER TABLE sales ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'sales' AND policyname = 'Public read sales'
  ) THEN
    CREATE POLICY "Public read sales" ON sales FOR SELECT USING (true);
  END IF;
END
$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'sales' AND policyname = 'Authenticated insert sales'
  ) THEN
    CREATE POLICY "Authenticated insert sales" ON sales FOR INSERT WITH CHECK (true);
  END IF;
END
$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'sales' AND policyname = 'Admin delete sales'
  ) THEN
    CREATE POLICY "Admin delete sales" ON sales FOR DELETE USING (auth.role() = 'authenticated');
  END IF;
END
$$;

-- 7. Custom menu table
CREATE TABLE IF NOT EXISTS custom_menu (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  price TEXT NOT NULL,
  description TEXT NOT NULL,
  category TEXT NOT NULL,
  tag TEXT,
  img_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
ALTER TABLE custom_menu ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'custom_menu' AND policyname = 'Public read custom_menu'
  ) THEN
    CREATE POLICY "Public read custom_menu" ON custom_menu FOR SELECT USING (true);
  END IF;
END
$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'custom_menu' AND policyname = 'Authenticated insert custom_menu'
  ) THEN
    CREATE POLICY "Authenticated insert custom_menu" ON custom_menu FOR INSERT WITH CHECK (true);
  END IF;
END
$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'custom_menu' AND policyname = 'Admin delete custom_menu'
  ) THEN
    CREATE POLICY "Admin delete custom_menu" ON custom_menu FOR DELETE USING (auth.role() = 'authenticated');
  END IF;
END
$$;

-- 8. Notifications table
CREATE TABLE IF NOT EXISTS notifications (
  id TEXT PRIMARY KEY,
  text TEXT NOT NULL,
  type TEXT DEFAULT 'amber',
  read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'notifications' AND policyname = 'Public read notifications'
  ) THEN
    CREATE POLICY "Public read notifications" ON notifications FOR SELECT USING (true);
  END IF;
END
$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'notifications' AND policyname = 'Authenticated insert notifications'
  ) THEN
    CREATE POLICY "Authenticated insert notifications" ON notifications FOR INSERT WITH CHECK (true);
  END IF;
END
$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'notifications' AND policyname = 'Admin update notifications'
  ) THEN
    CREATE POLICY "Admin update notifications" ON notifications FOR UPDATE USING (auth.role() = 'authenticated');
  END IF;
END
$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'notifications' AND policyname = 'Admin delete notifications'
  ) THEN
    CREATE POLICY "Admin delete notifications" ON notifications FOR DELETE USING (auth.role() = 'authenticated');
  END IF;
END
$$;

-- 9. Enable Realtime for all tables (if you want real-time changes reflected in the app)
-- Note: You need to be a superuser or have the appropriate permissions to alter publications
-- If you get an error here, you can skip or run separately.
DO $$
BEGIN
  BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE members;
  EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Could not add members to publication: %', SQLERRM;
  END;
  BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE posts;
  EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Could not add posts to publication: %', SQLERRM;
  END;
  BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE events;
  EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Could not add events to publication: %', SQLERRM;
  END;
  BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE deleted_events;
  EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Could not add deleted_events to publication: %', SQLERRM;
  END;
  BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE reservations;
  EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Could not add reservations to publication: %', SQLERRM;
  END;
  BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE sales;
  EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Could not add sales to publication: %', SQLERRM;
  END;
  BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE custom_menu;
  EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Could not add custom_menu to publication: %', SQLERRM;
  END;
  BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE notifications;
  EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Could not add notifications to publication: %', SQLERRM;
  END;
END
$$;

-- Note: You also need to create a public storage bucket named 'cafe-images'
-- in the Supabase Storage dashboard. Set it to public and allow all operations.
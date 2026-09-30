-- Run once in the Supabase SQL Editor. Safe to repeat.
ALTER TABLE public.rooms
ADD COLUMN IF NOT EXISTS rules jsonb NOT NULL DEFAULT '{}'::jsonb;

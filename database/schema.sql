-- Supabase/PostgreSQL schema for the Stolen Artworks Intelligence Dashboard.
-- Run this first in Supabase SQL Editor.

create table if not exists public.stolen_artworks (
  id text primary key,
  title text not null,
  artist text,
  category text,
  country_of_theft text,
  city_of_theft text,
  institution text,
  theft_year integer check (theft_year between 1400 and 2100),
  recovery_year integer,
  status text not null check (status in ('Missing', 'Recovered', 'Unknown')),
  estimated_value_usd_m numeric,
  latitude numeric,
  longitude numeric,
  source_name text,
  source_url text,
  notes text,
  risk_score numeric,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists set_stolen_artworks_updated_at on public.stolen_artworks;
create trigger set_stolen_artworks_updated_at
before update on public.stolen_artworks
for each row execute function public.set_updated_at();

alter table public.stolen_artworks enable row level security;

drop policy if exists "Allow public read of stolen artworks" on public.stolen_artworks;
create policy "Allow public read of stolen artworks" on public.stolen_artworks
for select using (true);

create index if not exists idx_stolen_artworks_status on public.stolen_artworks(status);
create index if not exists idx_stolen_artworks_category on public.stolen_artworks(category);
create index if not exists idx_stolen_artworks_theft_year on public.stolen_artworks(theft_year);
create index if not exists idx_stolen_artworks_country on public.stolen_artworks(country_of_theft);

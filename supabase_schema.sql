-- Infinity Global Chat 2 Database Schema

-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- Countries Table (195 countries)
create table public.countries (
    id uuid default uuid_generate_v4() primary key,
    name text not null unique,
    code text not null unique,
    flag_emoji text not null,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Users / Profiles Table
create table public.profiles (
    id uuid references auth.users on delete cascade primary key,
    username text unique,
    avatar_url text,
    theme_preference text default 'Royal Purple',
    is_premium boolean default false,
    premium_paid_at timestamp with time zone,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Chat Messages Table
create table public.messages (
    id uuid default uuid_generate_v4() primary key,
    country_id uuid references public.countries(id) on delete cascade not null,
    user_id uuid references public.profiles(id) on delete set null,
    username text not null,
    message text not null,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Payments Table (Razorpay tracking)
create table public.payments (
    id uuid default uuid_generate_v4() primary key,
    user_id uuid references public.profiles(id) on delete set null,
    razorpay_order_id text unique,
    razorpay_payment_id text unique,
    amount numeric not null,
    currency text default 'MYR',
    status text not null,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Row Level Security (RLS) Policies
alter table public.countries enable row level security;
alter table public.profiles enable row level security;
alter table public.messages enable row level security;
alter table public.payments enable row level security;

-- Public read policies
create policy "Allow public read countries" on public.countries for select using (true);
create policy "Allow public read profiles" on public.profiles for select using (true);
create policy "Allow public read messages" on public.messages for select using (true);

-- Authenticated write policies
create policy "Allow users to update own profile" on public.profiles for update using (auth.uid() = id);
create policy "Allow users to insert messages" on public.messages for insert with check (auth.uid() = user_id);

-- Insert sample/core 195 countries array summary block (Example stub for quick start)
insert into public.countries (name, code, flag_emoji) values
('United States', 'US', '🇺🇸'),
('Malaysia', 'MY', '🇲🇾'),
('United Kingdom', 'GB', '🇬🇧'),
('Singapore', 'SG', '🇸🇬'),
('Indonesia', 'ID', '🇮🇩'),
('Australia', 'AU', '🇦🇺'),
('Canada', 'CA', '🇨🇦'),
('Japan', 'JP', '🇯🇵'),
('Germany', 'DE', '🇩🇪'),
('France', 'FR', '🇫🇷'),
('India', 'IN', '🇮🇳'),
('Brazil', 'BR', '🇧🇷'),
('South Africa', 'ZA', '🇿🇦'),
('New Zealand', 'NZ', '🇳🇿'),
('Saudi Arabia', 'SA', '🇸🇦'),
('United Arab Emirates', 'AE', '🇦🇪'),
('South Korea', 'KR', '🇰🇷'),
('China', 'CN', '🇨🇳'),
('Thailand', 'TH', '🇹🇭')
on conflict (code) do nothing;

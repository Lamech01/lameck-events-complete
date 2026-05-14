-- ================================================
-- LAMECK & CO. EVENTS — SUPABASE SETUP SCRIPT
-- Run this in your Supabase SQL Editor
-- ================================================

-- 1. EVENT TYPES TABLE
create table if not exists public.event_types (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  icon text not null default 'fa-calendar',
  img text not null,
  description text not null,
  features text[] not null default '{}',
  display_order integer default 0,
  created_at timestamptz default now()
);

-- 2. GALLERY PHOTOS TABLE
create table if not exists public.gallery_photos (
  id uuid default gen_random_uuid() primary key,
  src text not null,
  label text not null,
  category text not null default 'Wedding',
  storage_path text,
  created_at timestamptz default now()
);

-- 3. CONTACT INQUIRIES TABLE
create table if not exists public.contact_inquiries (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  phone text not null,
  email text,
  event_type text,
  event_date date,
  message text,
  status text default 'new',
  created_at timestamptz default now()
);

-- 4. TESTIMONIALS TABLE
create table if not exists public.testimonials (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  event text not null,
  quote text not null,
  stars integer default 5,
  initials text not null,
  approved boolean default true,
  created_at timestamptz default now()
);

-- 5. SITE SETTINGS TABLE
create table if not exists public.site_settings (
  key text primary key,
  value text not null,
  updated_at timestamptz default now()
);

-- ── ROW LEVEL SECURITY ──
alter table public.event_types enable row level security;
alter table public.gallery_photos enable row level security;
alter table public.contact_inquiries enable row level security;
alter table public.testimonials enable row level security;
alter table public.site_settings enable row level security;

-- Public can read event_types, gallery_photos, testimonials
create policy "Public read event_types" on public.event_types for select using (true);
create policy "Public read gallery_photos" on public.gallery_photos for select using (true);
create policy "Public read testimonials" on public.testimonials for select using (approved = true);
create policy "Public read site_settings" on public.site_settings for select using (true);

-- Public can insert contact inquiries
create policy "Public insert contact" on public.contact_inquiries for insert with check (true);

-- Authenticated (admin) can do everything
create policy "Admin all event_types" on public.event_types for all using (auth.role() = 'authenticated');
create policy "Admin all gallery_photos" on public.gallery_photos for all using (auth.role() = 'authenticated');
create policy "Admin all contact_inquiries" on public.contact_inquiries for all using (auth.role() = 'authenticated');
create policy "Admin all testimonials" on public.testimonials for all using (auth.role() = 'authenticated');
create policy "Admin all site_settings" on public.site_settings for all using (auth.role() = 'authenticated');

-- ── STORAGE BUCKET ──
insert into storage.buckets (id, name, public) values ('gallery', 'gallery', true)
on conflict (id) do nothing;

create policy "Public read gallery" on storage.objects for select using (bucket_id = 'gallery');
create policy "Admin upload gallery" on storage.objects for insert with check (bucket_id = 'gallery' and auth.role() = 'authenticated');
create policy "Admin delete gallery" on storage.objects for delete using (bucket_id = 'gallery' and auth.role() = 'authenticated');

-- ── SEED DATA ──
insert into public.event_types (name, icon, img, description, features, display_order) values
('Weddings','fa-rings-wedding','https://images.unsplash.com/photo-1519741497674-611481863552?w=1400&q=80','Your love story deserves a perfect setting. From intimate garden ceremonies to grand ballroom receptions, we curate every detail of your wedding day across Kenya.',ARRAY['Venue sourcing & decoration','Bridal & groom coordination','Catering & cake arrangement','Photography & videography coordination','MC & entertainment','Honeymoon planning support'],1),
('Birthdays','fa-birthday-cake','https://images.unsplash.com/photo-1530103862676-de8c9debad1d?w=1400&q=80','Whether it''s a Sweet 16, a milestone 50th, or a toddler''s first birthday — we create vibrant, joyful celebrations that your guests will talk about for years.',ARRAY['Themed décor & setup','Birthday cake coordination','Entertainment & games','Catering & beverages','Photography sessions','Gift table & setup'],2),
('Corporate Events','fa-briefcase','https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=1400&q=80','Professional, polished, and perfectly executed. From AGMs to product launches, team retreats to gala dinners — we handle every corporate event with precision.',ARRAY['Conference & seminar setup','AV & tech coordination','Corporate branding & banners','Gala dinner planning','Team building activities','VIP guest management'],3),
('Ruracio / Traditional','fa-drumstick-bite','https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=1400&q=80','We celebrate Kenyan culture with pride. Our team understands the depth and beauty of traditional ceremonies across all communities.',ARRAY['Cultural ceremony coordination','Traditional décor & setup','Food & drinks (traditional menu)','Community coordination','Clan elder facilitation','Photography & documentation'],4),
('Graduations','fa-graduation-cap','https://images.unsplash.com/photo-1541339907198-e08756dedf3f?w=1400&q=80','Celebrate academic achievements in style. Whether it''s a university ceremony or a class 8 graduation, we create milestone celebrations that honour every accomplishment.',ARRAY['Graduation venue setup','Academic themed décor','Photo booth & photography','Reception catering','Certificate & awards display','Entertainment coordination'],5),
('Baby Showers','fa-baby','https://images.unsplash.com/photo-1544078751-58fee2d8a03b?w=1400&q=80','Welcome the newest member of the family with a warm, beautiful celebration full of love, colour, and joy.',ARRAY['Soft themed decoration','Gender reveal coordination','Games & activities','Catering & dessert tables','Gift registry assistance','Photography sessions'],6),
('Concerts & Shows','fa-music','https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?w=1400&q=80','From intimate acoustic shows to large outdoor festivals, we manage live event logistics so artists and audiences can focus on the magic of the moment.',ARRAY['Stage & sound setup coordination','Artist liaisons & hospitality','Ticketing & entry management','Security coordination','Lighting & effects','Crowd management planning'],7),
('Fundraisers','fa-hand-holding-heart','https://images.unsplash.com/photo-1559027615-cd4628902d4a?w=1400&q=80','Meaningful causes deserve powerful events. We help charities, schools, churches, and families raise funds through well-organised, impactful fundraising events.',ARRAY['Event concept & promotion','Guest invitation coordination','Auction & raffle management','Keynote speaker support','Catering & venue','Donation collection & accounting'],8),
('Church Events','fa-church','https://images.unsplash.com/photo-1438032005730-c779502df39b?w=1400&q=80','Sunday services, revival meetings, thanksgiving ceremonies — we support your ministry with respectful, faith-centred event planning.',ARRAY['Church setup & decoration','Sound & AV coordination','Ushering & guest management','Catering for congregations','Fellowship event planning','Anniversary celebrations'],9),
('Funeral Services','fa-dove','https://images.unsplash.com/photo-1578301978693-85fa9c0320b9?w=1400&q=80','In times of grief, we take the burden of logistics off your family''s shoulders. We organise dignified, respectful farewell ceremonies that honour your loved one''s memory.',ARRAY['Venue & tent arrangement','Floral tributes & casket décor','Order of service printing','Catering for mourners','Transport coordination','Memorial photography'],10),
('Product Launches','fa-rocket','https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=1400&q=80','Make your product''s debut unforgettable. We create high-impact launch events that generate buzz, media attention, and lasting brand impressions.',ARRAY['Brand-themed setup & décor','Press & media coordination','Live demo stage management','Influencer event hosting','Product display & exhibition','Post-event media coverage'],11)
on conflict do nothing;

insert into public.gallery_photos (src, label, category) values
('https://images.unsplash.com/photo-1519741497674-611481863552?w=800&q=80','Dream Wedding — Nairobi','Wedding'),
('https://images.unsplash.com/photo-1530103862676-de8c9debad1d?w=800&q=80','Lavish Birthday Bash','Birthday'),
('https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=800&q=80','Corporate Gala Dinner','Corporate'),
('https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=800&q=80','Elegant Wedding Reception','Wedding'),
('https://images.unsplash.com/photo-1541339907198-e08756dedf3f?w=800&q=80','Graduation Celebration','Graduation'),
('https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?w=800&q=80','Live Concert Night','Concert'),
('https://images.unsplash.com/photo-1544078751-58fee2d8a03b?w=800&q=80','Sweet Baby Shower','Baby Shower'),
('https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800&q=80','Brand Product Launch','Corporate'),
('https://images.unsplash.com/photo-1559027615-cd4628902d4a?w=800&q=80','Charity Fundraiser Gala','Fundraiser')
on conflict do nothing;

insert into public.testimonials (name, event, quote, stars, initials) values
('Wanjiku M.','Wedding — Karen, Nairobi','Lameck & Co. made our wedding day absolutely magical. Every single detail was perfect — from the floral arrangements to the timing of the reception. We couldn''t have asked for more.',5,'WM'),
('David Ochieng','Corporate Event — Mombasa','Our annual company gala was a huge success. Professional, timely, and incredibly creative. Our 300+ guests were blown away. We''ll definitely use them again.',5,'DO'),
('Grace Njeri','Birthday Party — Westlands','My mum''s 60th birthday was beyond what we imagined. The décor, food coordination, and entertainment were all world-class. Thank you Lameck & Co.!',5,'GN'),
('Peter Mutua','Ruracio — Machakos','They understood our culture perfectly. Our ruracio was organised with so much respect and beauty. The family was really impressed and everything ran smoothly.',5,'PM'),
('Amina Hassan','Baby Shower — Kilimani','The most beautiful baby shower! The soft pink and gold theme was dreamy. Everyone kept asking who planned it — and I was so proud to say Lameck & Co. Events.',5,'AH'),
('James Kariuki','Fundraiser — Kikuyu','They helped us raise over KES 2.5 million for our school project through a perfectly organised harambee. Highly professional and genuinely caring team.',5,'JK')
on conflict do nothing;

select 'Setup complete! All tables, policies, storage and seed data are ready.' as result;

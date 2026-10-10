create table public.listings (
 id uuid primary key default gen_random_uuid(),
 seller_id uuid not null references auth.users(id) on delete cascade,
 listing_type text not null default 'direct_sell' check (listing_type in ('direct_sell','rent')),
 rental_period text not null default 'day' check (rental_period in ('day','week','month')),
 title text not null check (char_length(title) between 3 and 120),
 description text not null default 'No description provided.' check (char_length(description) between 10 and 3000),
 price numeric(10,2) not null check (price >= 0 and price <= 99999999),
 category text not null check (category in ('Books','Electronics','Furniture','Cycles','Fashion','Other')),
 condition text not null default 'Good' check (condition in ('Like new','Good','Fair')),
 college text not null default 'Campus' check (char_length(college) between 2 and 150),
 seller_name text not null check (char_length(seller_name) between 2 and 100),
 email text not null check (email ~ '^[^@\s]+@[^@\s]+\.[^@\s]+$'),
 phone text not null check (phone ~ '^\+?[0-9 ()-]{7,20}$'),
 year text not null check (year in ('1st year','2nd year','3rd year','4th year','5th year','Postgraduate')),
 department text not null check (char_length(department) between 2 and 100),
 image_path text,
 status text not null default 'available' check (status in ('available','sold')),
 created_at timestamptz not null default now()
);
create index listings_seller_idx on public.listings(seller_id);
create index listings_created_idx on public.listings(created_at desc);
alter table public.listings enable row level security;
grant select on public.listings to anon, authenticated;
grant insert, update, delete on public.listings to authenticated;
create policy "Anyone can browse listings" on public.listings for select to anon, authenticated using (true);
create policy "Sellers create own listings" on public.listings for insert to authenticated with check ((select auth.uid()) = seller_id);
create policy "Sellers update own listings" on public.listings for update to authenticated using ((select auth.uid()) = seller_id) with check ((select auth.uid()) = seller_id);
create policy "Sellers delete own listings" on public.listings for delete to authenticated using ((select auth.uid()) = seller_id);
insert into storage.buckets (id,name,public,file_size_limit,allowed_mime_types) values ('products','products',true,5242880,array['image/jpeg','image/png','image/webp']);
create policy "Sellers upload own photos" on storage.objects for insert to authenticated with check (bucket_id='products' and (storage.foldername(name))[1]=(select auth.uid())::text);
create policy "Sellers delete own photos" on storage.objects for delete to authenticated using (bucket_id='products' and (storage.foldername(name))[1]=(select auth.uid())::text);
create policy "Sellers read own photo records" on storage.objects for select to authenticated using (bucket_id='products' and (storage.foldername(name))[1]=(select auth.uid())::text);

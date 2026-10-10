create schema if not exists private;
revoke all on schema private from public,anon,authenticated;
alter table public.listings alter column seller_id drop not null;
drop policy if exists "Sellers create own listings" on public.listings;
drop policy if exists "Sellers update own listings" on public.listings;
drop policy if exists "Sellers delete own listings" on public.listings;
revoke insert,update,delete on public.listings from anon,authenticated;
create table private.listing_management(listing_id uuid primary key references public.listings(id) on delete cascade, token_hash text not null);
alter table private.listing_management enable row level security;
create or replace function public.manage_listing(action text, payload jsonb, listing_id uuid, management_token text) returns uuid language plpgsql security definer set search_path='' as $$
declare target uuid; hashed text;
begin
 if management_token is null or length(management_token)<40 then raise exception 'Invalid management key'; end if;
 hashed:=encode(sha256(convert_to(management_token,'UTF8')),'hex');
 if action='create' then
  insert into public.listings(title,price,category,seller_name,email,phone,year,department,listing_type,rental_period,image_path)
  values(payload->>'title',(payload->>'price')::numeric,'Other',payload->>'seller_name',payload->>'email',payload->>'phone',payload->>'year',payload->>'department',payload->>'listing_type',payload->>'rental_period',payload->>'image_path') returning id into target;
  insert into private.listing_management values(target,hashed);
  return target;
 end if;
 if not exists(select 1 from private.listing_management m where m.listing_id=manage_listing.listing_id and m.token_hash=hashed) then raise exception 'This browser cannot manage this listing'; end if;
 if action='update' then
  update public.listings l set title=payload->>'title',price=(payload->>'price')::numeric,seller_name=payload->>'seller_name',email=payload->>'email',phone=payload->>'phone',year=payload->>'year',department=payload->>'department',listing_type=payload->>'listing_type',rental_period=payload->>'rental_period',image_path=payload->>'image_path' where l.id=manage_listing.listing_id;
 elsif action='status' then
  update public.listings l set status=payload->>'status' where l.id=manage_listing.listing_id;
 elsif action='delete' then
  delete from public.listings l where l.id=manage_listing.listing_id;
 else raise exception 'Unknown action'; end if;
 return listing_id;
end $$;
revoke all on function public.manage_listing(text,jsonb,uuid,text) from public;
grant execute on function public.manage_listing(text,jsonb,uuid,text) to anon,authenticated;
create table public.feedback(id uuid primary key default gen_random_uuid(),name text not null check(char_length(name) between 2 and 100),email text check(email is null or email ~ '^[^@\s]+@[^@\s]+\.[^@\s]+$'),rating integer not null check(rating between 1 and 5),message text not null check(char_length(message) between 10 and 3000),created_at timestamptz not null default now());
alter table public.feedback enable row level security;
grant insert on public.feedback to anon,authenticated;
revoke select,update,delete on public.feedback from anon,authenticated;
create policy "Visitors submit private feedback" on public.feedback for insert to anon,authenticated with check(true);
create policy "Visitors upload product photos" on storage.objects for insert to anon with check(bucket_id='products');

alter table public.listings drop column seller_id;
drop policy if exists "Sellers upload own photos" on storage.objects;
drop policy if exists "Sellers delete own photos" on storage.objects;
drop policy if exists "Sellers read own photo records" on storage.objects;

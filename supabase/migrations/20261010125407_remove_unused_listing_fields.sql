begin;
create or replace function public.manage_listing(action text, payload jsonb, listing_id uuid, management_token text) returns uuid language plpgsql security definer set search_path='' as $$
declare target uuid; hashed text;
begin
 if management_token is null or length(management_token)<40 then raise exception 'Invalid management key'; end if;
 hashed:=encode(sha256(convert_to(management_token,'UTF8')),'hex');
 if action='create' then
  insert into public.listings(title,price,seller_name,email,phone,year,department,listing_type,rental_period,image_path)
  values(payload->>'title',(payload->>'price')::numeric,payload->>'seller_name',payload->>'email',payload->>'phone',payload->>'year',payload->>'department',payload->>'listing_type',payload->>'rental_period',payload->>'image_path') returning id into target;
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

alter table public.listings drop column category, drop column college, drop column condition;
commit;
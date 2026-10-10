begin;
alter table public.listings drop constraint listings_listing_type_check;
alter table public.listings add constraint listings_listing_type_check check(listing_type in ('direct_sell','rent','lost','found'));
alter table public.listings add constraint listings_lost_photo_check check(listing_type not in ('lost','found') or (image_path is not null and length(trim(image_path))>0));
alter table public.listings add constraint listings_lost_price_check check(listing_type not in ('lost','found') or price=0);
commit;

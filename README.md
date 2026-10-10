# buyNsell

A campus marketplace for selling, renting or giving away products. Visitors publish directly with product and contact details. No accounts, passwords, verification or payments.

## Development

Run npm install, npm run dev, or npm run build with Node.js 22 or newer.

## Backend and listing management

Supabase project pentvxbgrqithicezozf, Mumbai. Apply supabase/schema.sql then supabase/account-free.sql for the current structure. Listings have no user-account relationship. Previous Auth records are retained; the app does not use them or create new accounts. SMTP is unused.

The manage_listing RPC checks a random management key for edits, status changes and deletion. The hashed key is stored in private.listing_management, inaccessible to visitors. The original key stays in the seller browser under buynsell-listing-keys. Clearing browser data loses management access. Older listings without browser keys can be managed by the owner in Supabase.

JPEG, PNG and WebP photos up to 5 MB can be uploaded. Public photos are immutable to visitors; obsolete photos require owner cleanup in Storage.

## Feedback inbox

Feedback stores name, optional email, rating and message in public.feedback. Visitors can submit but cannot read feedback. Read submissions in Supabase Table Editor > feedback. Email notifications are not configured.

## Deployment

https://buynsell-six.vercel.app — Vite deployed through Vercel from harshan-spec/buyNsell. Theme and listing management keys are saved in the browser.

Lost & found: use the button beside Sell an item to post a lost or found item. A photo and student contact details are required. Posts are browsed in the Lost & found tab and managed through My listings with Mark resolved. Database constraints require a photo path and zero price for these posts.

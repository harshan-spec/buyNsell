# buyNsell

An inter-college marketplace for selling or giving away used products. Buyers browse and contact sellers without an account. Sellers use Supabase email authentication to publish, edit, mark sold, relist and delete their products. No payment integration.

## Development

Node.js 22 or newer. Run `npm install`, then `npm run dev`. Run `npm run build` for production.

## Backend

Supabase project: `pentvxbgrqithicezozf` (buyNsell, Mumbai). Schema and row ownership policies are documented in `supabase/schema.sql`, which has already been applied to the new project. The client uses a public publishable key; all mutations are protected by RLS and require the seller's authenticated user ID. Product photos are stored in the `products` bucket with a 5 MB limit and JPEG/PNG/WebP validation.

Product contact fields are public so guest buyers can contact sellers. Seller name, college, year and department are self-declared, not independently verified. Email confirmation verifies mailbox ownership. Account details are stored by Supabase Auth. Listing details and seller contact information are in Postgres.

Production: https://buynsell-six.vercel.app . Supabase Authentication URL Configuration uses this as the Site URL and allowed redirect for confirmation and password recovery. Email confirmation remains enabled. A custom SMTP provider is required for student signup: Supabase's built-in email sender only delivers to organization team members, with a 2 emails/hour limit. Configure SMTP in Authentication > Emails > SMTP Settings before inviting students.

## Deployment

Vite frontend deployed to Vercel with the GitHub `harshan-spec/buyNsell` repository. `vercel.json` configures fallback routing for authentication links.

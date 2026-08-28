# Menu — Premium Digital Menu SaaS MVP

A mobile-first Arabic/English digital-menu product designed for Riyadh cafes and restaurants. The UX was redesigned after reviewing the public Oaza Coffee menu experience on Yalla QR Codes.

## What is included
- Premium mobile-first customer menu
- Arabic / English switching with RTL/LTR
- Sticky search and category navigation
- Featured recommendations
- Item detail modal
- Availability states
- WhatsApp, Instagram and Google Maps CTAs
- Responsive cards and accessible controls
- Oaza-inspired demonstration dataset with representative menu categories/products
- Lightweight admin panel for local MVP editing
- Production-ready Supabase SQL schema for tenants, branches, categories and products
- Multi-tenant architecture prepared for one platform serving many cafes

## Architecture

`Customer -> Vercel -> Menu frontend -> Supabase PostgreSQL/Storage`

One platform can serve multiple tenants:

- `oaza.yourdomain.com`
- `cafe2.yourdomain.com`
- `cafe3.yourdomain.com`

A customer can later use their own branded subdomain such as `menu.customer.com` without creating a separate application.

## Supabase setup
1. Open the user's existing Supabase project (Midosd2 Project).
2. Run `supabase-schema.sql` in SQL Editor.
3. Copy `supabase-config.example.js` to `supabase-config.js` and enter the Project URL plus public Publishable/anon key.
4. Never place a service-role/secret key in frontend code.
5. Add the same public values as Vercel environment variables when the app is moved to a build-based frontend.

## Commercial roadmap
1. Connect the customer menu to Supabase.
2. Add authenticated admin access and tenant isolation.
3. Add image storage and drag/drop uploads.
4. Add branch management and QR generation.
5. Add custom-domain/subdomain routing.
6. Add analytics and conversion tracking.
7. Add optional ordering, table ordering, payments and POS integrations as paid modules.

## Portfolio rule
The Oaza data is a demonstration dataset based on publicly visible menu information. Oaza is **not** represented as a client unless the business explicitly approves the work.

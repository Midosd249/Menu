# Menu — Premium Digital Menu SaaS MVP

Menu is a mobile-first Arabic-first digital menu platform for Saudi cafes and restaurants. This iteration continues the existing `Midosd249/Menu` project rather than creating a separate application. The public menu is designed for QR scans, while `admin.html` provides a browser-based demo workspace for managing three independent tenant fixtures.

## Implemented in this repository

The public experience now supports generic tenant routing through `?tenant=oaza`, `?tenant=juniper`, or `?tenant=mirage`, plus branch selection through `&branch=main`. It first renders the premium local fixture for fast perceived load, then fetches the selected tenant, active branch, active categories, and available products from Supabase using the browser-safe publishable key. Arabic/English switching, RTL/LTR layout, branch status, contact/location actions, search across bilingual names and descriptions, sticky horizontal categories, featured items, availability states, VAT messaging, item detail sheets, keyboard escape handling, responsive mobile cards, and a graceful fallback remain available.

The admin experience supports tenant selection, branch selection and editing, tenant-aware public URLs, Supabase email/password login and logout, membership-aware live tenant loading, profile updates, colors and logo URL, local fallback persistence, product creation/editing/deletion, Arabic and English fields, price validation, availability and featured flags, preview links, product image validation/upload to the `menu-assets` bucket, and menu visit event insertion. QR preview, copy, and PNG download are implemented with a browser QR library.

The included `supabase-schema.sql` is the production data model. The repository also includes `almas-seed.sql` and `ALMAS_research.md` for the verified portfolio case study. It contains tenants, branches, categories, products, tenant memberships, branch hours, and menu analytics events. Row-level security is enabled, public menu reads are limited to active/available content, and dashboard writes are membership-scoped. The schema seeds the original three demo tenants; `almas-seed.sql` adds the clearly labeled AL MAS portfolio tenant without representing AL MAS as a client or partner.

## AL MAS portfolio tenant

`AL MAS Family Restaurant` is included as a separate portfolio case study at `index.html?tenant=almas&branch=malaz`. Public sources verify the restaurant identity, Indian/North and South Indian plus Arabic and Chinese positioning, the Al Malaz location, Instagram presence, and selected phone/address references. Because no stable current official menu or opening hours could be verified, the case study uses a small **prototype reference dataset**, displays prices as **السعر حسب التوفر / Price on request**, and shows hours as unpublished. The public-source research and attribution boundaries are recorded in [`ALMAS_research.md`](ALMAS_research.md), and the reproducible database seed is [`almas-seed.sql`](almas-seed.sql).

Sources used for the portfolio case study are [AL MAS Family Restaurant on Facebook][1], [AL MAS Restaurant on Instagram][2], and [AL MAS Restaurant on Tripadvisor][3].

## Local run

The project is intentionally lightweight and can be previewed as static files:

```bash
python3 -m http.server 4173
# open http://localhost:4173/index.html?tenant=oaza
# admin: http://localhost:4173/admin.html
```

The admin page renders a read-only local preview until a Supabase Auth session is established. Management buttons are disabled for unauthenticated visitors; authenticated users must also have a matching `tenant_members` row. Any localStorage fallback is useful only for portfolio demonstrations and is not an authentication boundary.

## Supabase setup

The current repository is configured against the existing Supabase project through `supabase-config.js`, using only the public publishable key. The production schema and seed migrations have been applied to that project. Never replace the client key with a service-role key or commit any secret. Supabase Auth credentials are entered only in the admin form; tenant membership is checked through RLS and `tenant_members`.

Before first production launch, create an authenticated owner account in Supabase Auth, insert its UUID into `tenant_members` for the intended tenant with `owner` or `admin` role, configure storage policies for the `menu-assets` bucket, and verify the public domain. The localStorage path remains only as a fallback when no live session or live tenant data is available; it is not an authorization boundary.

## Tenant and domain model

Public routing is tenant-ready and uses a generic slug. The intended production mapping is:

| Public address | Meaning |
| --- | --- |
| `menu.example.com/index.html?tenant=oaza` | Current demo-compatible route |
| `oaza.example.com/branch/riyadh` | Recommended branded subdomain route |
| `menu.customer.com/branch/main` | Future custom-domain route |

At deployment time, rewrite the branded host or path to the same application and resolve the tenant from the validated hostname/path on the server. Do not rely on a hidden client-side selector for authorization. The current query-string routes are demo-compatible; a commercial deployment should move tenant resolution to the verified host/path layer.

## Design and competitive research

The visual direction is intentionally original: warm editorial neutrals, dark coffee tones, restrained serif display type, Arabic-first hierarchy, and large touch-friendly controls. The public Oaza Coffee menu at [Yalla QR Codes](https://oaza-coffee.yallaqrcodes.com/branch/1/) was reviewed only as competitive research. Its observed conventions included a branch header, contact/location links, horizontal category navigation, bilingual item naming, prices, calories, and explicit unavailable states. No Oaza logo, proprietary asset, or endorsement claim is used here. Any Oaza-like content is demo/portfolio content only.

## Deployment

The repository can be deployed as a static site to Vercel, Netlify, GitHub Pages, or any CDN that serves HTML/CSS/JavaScript. For Vercel, import the repository, keep the static root, and deploy; `404.html`, `favicon.svg`, and `robots.txt` are included. Configure a custom domain or rewrite branded hosts to the same app, then resolve tenant and branch from validated host/path parameters. Add production response headers, cache policy, stricter Storage policies, and image transformation/CDN handling before broad commercial rollout.

## QA performed and remaining limitations

Static JavaScript syntax was checked with Node. Public and admin HTML were served successfully by a local HTTP server, and Chromium headless DOM checks passed for live tenant routing plus admin rendering. The Supabase schema, seed data, branding/storage migration, and public project configuration were applied through the connected project.

Remaining owner actions are limited to creating/authorizing real admin users, adding `tenant_members` rows, confirming Storage RLS policies, testing the live admin session in the owner’s browser, and configuring the final domain/DNS. Branch-hour rendering, branch create/delete flows, category drag ordering, logo file upload, and full analytics reporting are schema-ready but still require the next product iteration. AL MAS prices, current menu, official opening hours, canonical phone, and final branding still require restaurant confirmation before client-facing publication.

[1]: https://www.facebook.com/almasfamilyrestaurantksa/ "AL MAS Family Restaurant — Facebook"
[2]: https://www.instagram.com/almas_family_restaurant/?hl=en "AL MAS Restaurant — Instagram"
[3]: https://www.tripadvisor.com/Restaurant_Review-g293995-d9883951-Reviews-Al_Mas_Restaurant-Riyadh_Riyadh_Province.html "Al Mas Restaurant — Tripadvisor"

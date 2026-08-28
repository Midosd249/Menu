# Menu — Premium Digital Menu SaaS MVP

Menu is a mobile-first Arabic-first digital menu platform for Saudi cafes and restaurants. This iteration continues the existing `Midosd249/Menu` project rather than creating a separate application. The public menu is designed for QR scans, while `admin.html` provides a browser-based demo workspace for managing three independent tenant fixtures.

## Implemented in this repository

The public experience now supports generic tenant routing through `?tenant=oaza`, `?tenant=juniper`, or `?tenant=mirage`, Arabic/English switching with persisted preference, RTL/LTR layout, branch status, contact/location actions, search across bilingual names and descriptions, sticky horizontal categories, featured items, availability states, VAT messaging, item detail sheets, keyboard escape handling, responsive mobile cards, and polished loading-free local demo rendering. The footer includes an explicit route to the demo admin workspace.

The admin experience supports tenant selection, tenant-aware public URLs, profile editing, local persistence, product creation/editing/deletion, Arabic and English fields, price validation, availability and featured flags, preview links, basic visit/item metrics placeholders, and QR presentation/copy actions. The QR view is deliberately labeled as a placeholder until a production QR generator or server-side image endpoint is connected.

The included `supabase-schema.sql` is the production data model. It contains tenants, branches, categories, products, tenant memberships, branch hours, and menu analytics events. Row-level security is enabled, public menu reads are limited to active/available content, and dashboard writes are membership-scoped. The schema also seeds three clearly labeled demo tenants; it does not represent Oaza Coffee as a customer or partner.

## Local run

The project is intentionally lightweight and can be previewed as static files:

```bash
python3 -m http.server 4173
# open http://localhost:4173/index.html?tenant=oaza
# admin: http://localhost:4173/admin.html
```

The admin demo stores its edits in `localStorage` under `menuDemoDb`. This is useful for portfolio demonstrations but is not an authentication boundary. Do not use the local admin as a production control plane.

## Supabase setup

Create or select a Supabase project, run `supabase-schema.sql` in the SQL editor, and configure the public project URL plus publishable/anon key using the existing `supabase-config.example.js` pattern. Never commit a service-role key or any secret into this repository. A production build should move Supabase calls to a server-mediated or authenticated frontend integration and should keep tenant membership checks enforced by RLS rather than trusting a client-provided tenant ID.

Before first production launch, create an authenticated owner account, insert its UUID into `tenant_members` for the intended tenant with `owner` or `admin` role, create branch records, populate categories/products, and configure storage policies for product images. The current static demo intentionally avoids pretending that unauthenticated localStorage is secure.

## Tenant and domain model

Public routing is tenant-ready and uses a generic slug. The intended production mapping is:

| Public address | Meaning |
| --- | --- |
| `menu.example.com/index.html?tenant=oaza` | Current demo-compatible route |
| `oaza.example.com/branch/riyadh` | Recommended branded subdomain route |
| `menu.customer.com/branch/main` | Future custom-domain route |

At deployment time, rewrite the branded host or path to the same application and resolve the tenant from the validated hostname/path on the server. Do not rely on a hidden client-side selector for authorization.

## Design and competitive research

The visual direction is intentionally original: warm editorial neutrals, dark coffee tones, restrained serif display type, Arabic-first hierarchy, and large touch-friendly controls. The public Oaza Coffee menu at [Yalla QR Codes](https://oaza-coffee.yallaqrcodes.com/branch/1/) was reviewed only as competitive research. Its observed conventions included a branch header, contact/location links, horizontal category navigation, bilingual item naming, prices, calories, and explicit unavailable states. No Oaza logo, proprietary asset, or endorsement claim is used here. Any Oaza-like content is demo/portfolio content only.

## Deployment

The repository can be deployed as a static site to Vercel, Netlify, GitHub Pages, or any CDN that serves HTML/CSS/JavaScript. For a real SaaS, use a build/server layer that integrates Supabase Auth, database queries, storage uploads, tenant hostname resolution, server-side analytics inserts, and authenticated admin routes. Add custom response headers, HTTPS, cache policy, a real QR image generator, image optimization, and an error/404 route at that stage.

## QA performed and remaining limitations

Static JavaScript syntax was checked with Node, and both `index.html` and `admin.html` were served successfully by a local HTTP server during smoke testing. The project retains `*.before-production` snapshots of the original files for rollback/reference.

The remaining production work is intentional rather than hidden: Supabase is not connected in the static demo, admin authentication is not active locally, image upload/storage is not wired, the QR view is a labeled placeholder, analytics counters are demo values, and branch hours are represented in the schema but not yet rendered from live data. These steps require the owner’s Supabase project URL/key, Auth configuration, storage bucket/policies, domain/DNS settings, and a decision on the hosting/build pipeline.

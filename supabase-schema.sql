-- Menu SaaS production schema
create extension if not exists pgcrypto;

create table if not exists public.tenants (
  id uuid primary key default gen_random_uuid(),
  slug text unique not null,
  name text not null,
  tagline text,
  logo_url text,
  instagram_url text,
  whatsapp text,
  created_at timestamptz not null default now()
);

create table if not exists public.branches (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  slug text not null,
  name text not null,
  address text,
  maps_url text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  unique(tenant_id, slug)
);

create table if not exists public.categories (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  sort_order int not null default 0,
  name_ar text not null,
  name_en text not null,
  is_active boolean not null default true
);

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  category_id uuid references public.categories(id) on delete set null,
  sort_order int not null default 0,
  name_ar text not null,
  name_en text not null,
  description_ar text,
  description_en text,
  price numeric(10,2) not null default 0,
  currency text not null default 'SAR',
  image_url text,
  calories int,
  is_available boolean not null default true,
  is_featured boolean not null default false,
  allergens text[] not null default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists products_tenant_idx on public.products(tenant_id);
create index if not exists categories_tenant_idx on public.categories(tenant_id);
create index if not exists branches_tenant_idx on public.branches(tenant_id);

alter table public.tenants enable row level security;
alter table public.branches enable row level security;
alter table public.categories enable row level security;
alter table public.products enable row level security;

-- Public menus: read-only access. Admin writes should use authenticated policies added after auth is configured.
create policy "public can read active tenants" on public.tenants for select using (true);
create policy "public can read active branches" on public.branches for select using (is_active = true);
create policy "public can read active categories" on public.categories for select using (is_active = true);
create policy "public can read products" on public.products for select using (true);

insert into public.tenants (slug, name, tagline, instagram_url, whatsapp)
values ('oaza', 'Oaza Coffee', 'قهوة مختصة • الرياض', 'https://instagram.com/oaza.ksa', '+966566332329')
on conflict (slug) do nothing;

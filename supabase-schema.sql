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

create table if not exists public.tenant_members (
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null default 'editor' check (role in ('owner','admin','editor')),
  created_at timestamptz not null default now(),
  primary key (tenant_id, user_id)
);
create table if not exists public.branch_hours (
  branch_id uuid not null references public.branches(id) on delete cascade,
  weekday smallint not null check (weekday between 0 and 6),
  opens_at time,
  closes_at time,
  is_closed boolean not null default false,
  primary key (branch_id, weekday)
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
create table if not exists public.menu_events (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  branch_id uuid references public.branches(id) on delete set null,
  product_id uuid references public.products(id) on delete set null,
  event_type text not null check (event_type in ('visit','product_view')),
  created_at timestamptz not null default now()
);

create index if not exists products_tenant_idx on public.products(tenant_id);
create index if not exists categories_tenant_idx on public.categories(tenant_id);
create index if not exists branches_tenant_idx on public.branches(tenant_id);
create index if not exists tenant_members_user_idx on public.tenant_members(user_id);
create index if not exists menu_events_tenant_idx on public.menu_events(tenant_id, created_at desc);

alter table public.tenants enable row level security;
alter table public.branches enable row level security;
alter table public.categories enable row level security;
alter table public.products enable row level security;
alter table public.tenant_members enable row level security;
alter table public.branch_hours enable row level security;
alter table public.menu_events enable row level security;

-- Public menu reads are scoped to active/published content. Dashboard writes are membership-scoped.
create or replace function public.is_tenant_member(target_tenant uuid) returns boolean language sql stable security definer set search_path = public as $$ select exists(select 1 from public.tenant_members tm where tm.tenant_id = target_tenant and tm.user_id = auth.uid()); $$;
drop policy if exists "public can read active tenants" on public.tenants;
drop policy if exists "public can read active branches" on public.branches;
drop policy if exists "public can read active categories" on public.categories;
drop policy if exists "public can read available products" on public.products;
drop policy if exists "members can manage own tenants" on public.tenants;
drop policy if exists "members can manage own branches" on public.branches;
drop policy if exists "members can manage own categories" on public.categories;
drop policy if exists "members can manage own products" on public.products;
drop policy if exists "members can read memberships" on public.tenant_members;
drop policy if exists "members can read branch hours" on public.branch_hours;
drop policy if exists "members can manage branch hours" on public.branch_hours;
drop policy if exists "public can record menu events" on public.menu_events;
drop policy if exists "members can read own analytics" on public.menu_events;
create policy "public can read active tenants" on public.tenants for select using (true);
create policy "public can read active branches" on public.branches for select using (is_active = true);
create policy "public can read active categories" on public.categories for select using (is_active = true);
create policy "public can read available products" on public.products for select using (is_available = true);
create policy "members can manage own tenants" on public.tenants for all using (public.is_tenant_member(id)) with check (public.is_tenant_member(id));
create policy "members can manage own branches" on public.branches for all using (public.is_tenant_member(tenant_id)) with check (public.is_tenant_member(tenant_id));
create policy "members can manage own categories" on public.categories for all using (public.is_tenant_member(tenant_id)) with check (public.is_tenant_member(tenant_id));
create policy "members can manage own products" on public.products for all using (public.is_tenant_member(tenant_id)) with check (public.is_tenant_member(tenant_id));
create policy "members can read memberships" on public.tenant_members for select using (user_id = auth.uid() or public.is_tenant_member(tenant_id));
create policy "members can read branch hours" on public.branch_hours for select using (exists(select 1 from public.branches b where b.id = branch_id and public.is_tenant_member(b.tenant_id)));
create policy "members can manage branch hours" on public.branch_hours for all using (exists(select 1 from public.branches b where b.id = branch_id and public.is_tenant_member(b.tenant_id))) with check (exists(select 1 from public.branches b where b.id = branch_id and public.is_tenant_member(b.tenant_id)));
create policy "public can record menu events" on public.menu_events for insert with check (event_type in ('visit','product_view'));
create policy "members can read own analytics" on public.menu_events for select using (public.is_tenant_member(tenant_id));
insert into public.tenants (slug, name, tagline, instagram_url, whatsapp) values
('oaza', 'Oaza Coffee', 'Demo portfolio tenant — قهوة مختصة • الرياض', 'https://instagram.com/oaza.ksa', '+966566332329'),
('juniper', 'Juniper Roasters', 'Demo portfolio tenant — تحميص محلي', null, null),
('mirage', 'Mirage Kitchen', 'Demo portfolio tenant — نكهات سعودية', null, null)
on conflict (slug) do nothing;

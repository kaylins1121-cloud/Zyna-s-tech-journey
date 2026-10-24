-- Chỉ chạy file này nếu bạn ĐÃ chạy setup.sql trước đó (thêm bảng cho Lab)
create table if not exists experiments (
  id text primary key, slug text unique not null, title text not null,
  cat text default 'Thí nghiệm', date text, tags text[] default '{}', summary text,
  sim text, body jsonb default '[]', media jsonb default '[]', links jsonb default '{}',
  sort int default 0, published boolean default true, created_at timestamptz default now());
alter table experiments enable row level security;
create policy "public read experiments" on experiments for select using (published or is_admin());
create policy "admin write experiments" on experiments for all using (is_admin()) with check (is_admin());

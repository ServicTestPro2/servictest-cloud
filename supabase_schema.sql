-- ============================================================================
-- ServicTest — Schema Supabase (Postgres)
-- Cole este arquivo inteiro no SQL Editor do seu projeto Supabase e rode.
--
-- O sistema guarda todo o estado (clientes, laudos, usuários, configurações
-- de ensaio) num único objeto, salvo como um blob JSON numa linha desta
-- tabela — mesmo padrão usado no GestãoCampo Pro.
--
-- Segurança: Row Level Security exige usuário autenticado (Supabase Auth).
-- Sem login, a anon key pública (visível no HTML hospedado) não lê nem
-- escreve nada.
-- ============================================================================

create table if not exists public.app_state (
  id text primary key,
  dados jsonb not null,
  updated_at timestamptz not null default now()
);

alter table public.app_state enable row level security;

create policy "auth_full_access" on public.app_state
  for all to authenticated using (true) with check (true);

-- =====================================================================
--  Schéma applicatif : blagues multilingues + agrégation d'actualité
--  PostgreSQL / Supabase
-- =====================================================================

create extension if not exists "pgcrypto";
create extension if not exists "unaccent";


-- =====================================================================
--  PARTIE 1 — BLAGUES
-- =====================================================================

create type joke_rating as enum ('tout_public', 'adulte');
create type joke_status as enum ('brouillon', 'publie', 'retire');

-- Ouvrage d'origine (votre PDF de départ, puis les suivants)
create table books (
  id            uuid primary key default gen_random_uuid(),
  title         text not null,
  author        text,
  is_free       boolean not null default true,
  created_at    timestamptz not null default now()
);

-- L'identité de la blague : pas de texte ici, uniquement les métadonnées
create table jokes (
  id            uuid primary key default gen_random_uuid(),
  book_id       uuid references books(id) on delete set null,
  rating        joke_rating not null default 'tout_public',
  status        joke_status not null default 'brouillon',
  -- compteurs dénormalisés : lecture instantanée, mis à jour par trigger
  view_count    integer not null default 0,
  like_count    integer not null default 0,
  share_count   integer not null default 0,
  created_at    timestamptz not null default now()
);

create index on jokes (status, rating);
-- tri par popularité, uniquement sur ce qui est visible
create index on jokes (share_count desc) where status = 'publie';

-- Le texte, une ligne par langue. 'ary' = darija marocaine
create table joke_translations (
  joke_id       uuid not null references jokes(id) on delete cascade,
  lang          text not null check (lang ~ '^[a-z]{2,3}$'),
  setup         text not null,
  punchline     text not null,
  is_machine    boolean not null default false,  -- traduction auto non relue
  search_vector tsvector generated always as (
                  to_tsvector('simple', setup || ' ' || punchline)
                ) stored,
  primary key (joke_id, lang)
);

create index on joke_translations using gin (search_vector);
create index on joke_translations (lang);

-- Catégories, elles aussi traduites
create table categories (
  id            uuid primary key default gen_random_uuid(),
  slug          text not null unique,
  sort_order    integer not null default 0
);

create table category_translations (
  category_id   uuid not null references categories(id) on delete cascade,
  lang          text not null,
  name          text not null,
  primary key (category_id, lang)
);

create table joke_categories (
  joke_id       uuid not null references jokes(id) on delete cascade,
  category_id   uuid not null references categories(id) on delete cascade,
  primary key (joke_id, category_id)
);

create index on joke_categories (category_id);


-- ---------------------------------------------------------------------
--  Interactions utilisateur
-- ---------------------------------------------------------------------

create type joke_event as enum ('vue', 'favori', 'partage', 'signalement');

create table user_joke_events (
  user_id       uuid not null references auth.users(id) on delete cascade,
  joke_id       uuid not null references jokes(id) on delete cascade,
  event         joke_event not null,
  created_at    timestamptz not null default now(),
  primary key (user_id, joke_id, event)
);

-- index déterminant : c'est lui qui rend rapide l'exclusion du "déjà vu"
create index on user_joke_events (user_id, event, joke_id);

-- La blague du jour, programmée à l'avance par vos soins
create table daily_picks (
  pick_date     date primary key,
  joke_id       uuid not null references jokes(id),
  created_at    timestamptz not null default now()
);


-- ---------------------------------------------------------------------
--  Tirage sans répétition
--  Renvoie des blagues jamais vues ; si l'utilisateur a tout épuisé,
--  repart sur les plus anciennement vues plutôt que de ne rien renvoyer.
-- ---------------------------------------------------------------------

create or replace function next_jokes(
  p_user     uuid,
  p_lang     text default 'fr',
  p_rating   joke_rating default 'tout_public',
  p_category uuid default null,
  p_limit    integer default 20
)
returns table (joke_id uuid, setup text, punchline text)
language sql stable as $$
  with vues as (
    select e.joke_id from user_joke_events e
    where e.user_id = p_user and e.event = 'vue'
  ),
  eligibles as (
    select j.id, t.setup, t.punchline
    from jokes j
    join joke_translations t on t.joke_id = j.id and t.lang = p_lang
    left join joke_categories jc on jc.joke_id = j.id
    where j.status = 'publie'
      and j.rating <= p_rating
      and (p_category is null or jc.category_id = p_category)
  )
  select e.id, e.setup, e.punchline
  from eligibles e
  where e.id not in (select joke_id from vues)
  order by random()
  limit p_limit;
$$;


-- =====================================================================
--  PARTIE 2 — ACTUALITÉ
-- =====================================================================

create type news_category as enum ('maroc', 'monde', 'sport', 'economie', 'insolite');

create table news_sources (
  id            uuid primary key default gen_random_uuid(),
  name          text not null,
  site_url      text not null,
  feed_url      text not null unique,
  lang          text not null default 'fr',
  category      news_category not null,
  is_active     boolean not null default true,
  last_fetch_at timestamptz,
  last_error    text
);

create table articles (
  id            uuid primary key default gen_random_uuid(),
  source_id     uuid not null references news_sources(id) on delete cascade,
  title         text not null,
  -- empreinte du titre normalisé : c'est elle qui bloque les doublons
  title_hash    text not null,
  excerpt       text check (char_length(excerpt) <= 200),
  url           text not null,
  image_url     text,
  category      news_category not null,
  lang          text not null default 'fr',
  published_at  timestamptz not null,
  fetched_at    timestamptz not null default now(),
  click_count   integer not null default 0
);

-- Contrainte anti-doublon : un même titre ne peut réapparaître
-- qu'une fois par source. Le filtre 48h est appliqué à l'insertion.
create unique index on articles (title_hash, source_id);
create index on articles (published_at desc);
create index on articles (category, published_at desc);

-- Fil classé : fraîcheur + popularité, avec diversité des sources
create or replace view feed_articles as
select a.*, s.name as source_name, s.site_url,
       (extract(epoch from (now() - a.published_at)) / 3600.0) as age_heures,
       (a.click_count + 1)
         / power(extract(epoch from (now() - a.published_at)) / 3600.0 + 2, 1.5)
         as score
from articles a
join news_sources s on s.id = a.source_id
where a.published_at > now() - interval '7 days'
order by score desc;

-- Purge : à programmer quotidiennement via pg_cron
create or replace function purge_old_articles()
returns void language sql as $$
  delete from articles where published_at < now() - interval '30 days';
$$;


-- =====================================================================
--  SÉCURITÉ (Supabase RLS)
--  Lecture publique du contenu, écriture réservée à chaque utilisateur
--  sur ses propres interactions.
-- =====================================================================

alter table jokes              enable row level security;
alter table joke_translations  enable row level security;
alter table articles           enable row level security;
alter table user_joke_events   enable row level security;

create policy "blagues publiées visibles" on jokes
  for select using (status = 'publie');

create policy "traductions visibles" on joke_translations
  for select using (true);

create policy "articles visibles" on articles
  for select using (true);

create policy "chacun ses interactions" on user_joke_events
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

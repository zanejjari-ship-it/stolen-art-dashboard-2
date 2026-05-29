-- Supabase/PostgreSQL schema for the Stolen Artworks Intelligence Dashboard.
-- Run this first in Supabase SQL Editor.

create table if not exists public.stolen_artworks (
  id text primary key,
  title text not null,
  artist text,
  category text,
  country_of_theft text,
  city_of_theft text,
  institution text,
  theft_year integer check (theft_year between 1400 and 2100),
  recovery_year integer,
  status text not null check (status in ('Missing', 'Recovered', 'Unknown')),
  estimated_value_usd_m numeric,
  latitude numeric,
  longitude numeric,
  source_name text,
  source_url text,
  notes text,
  risk_score numeric,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists set_stolen_artworks_updated_at on public.stolen_artworks;
create trigger set_stolen_artworks_updated_at
before update on public.stolen_artworks
for each row execute function public.set_updated_at();

alter table public.stolen_artworks enable row level security;

drop policy if exists "Allow public read of stolen artworks" on public.stolen_artworks;
create policy "Allow public read of stolen artworks" on public.stolen_artworks
for select using (true);

create index if not exists idx_stolen_artworks_status on public.stolen_artworks(status);
create index if not exists idx_stolen_artworks_category on public.stolen_artworks(category);
create index if not exists idx_stolen_artworks_theft_year on public.stolen_artworks(theft_year);
create index if not exists idx_stolen_artworks_country on public.stolen_artworks(country_of_theft);


-- Seed data for the Stolen Artworks Intelligence Dashboard.
-- Run this after database/schema.sql.

insert into public.stolen_artworks (
  id, title, artist, category, country_of_theft, city_of_theft, institution,
  theft_year, recovery_year, status, estimated_value_usd_m, latitude, longitude,
  source_name, source_url, notes, risk_score
) values
('gardner-1990-vermeer-concert', 'The Concert', 'Johannes Vermeer', 'Painting', 'United States', 'Boston', 'Isabella Stewart Gardner Museum', 1990, null, 'Missing', 200.0, 42.3386, -71.0995, 'Isabella Stewart Gardner Museum', 'https://www.gardnermuseum.org/about/theft', 'One of the works stolen during the 1990 Gardner Museum theft.', 75.4),
('gardner-1990-rembrandt-storm', 'Christ in the Storm on the Sea of Galilee', 'Rembrandt van Rijn', 'Painting', 'United States', 'Boston', 'Isabella Stewart Gardner Museum', 1990, null, 'Missing', 100.0, 42.3386, -71.0995, 'Isabella Stewart Gardner Museum', 'https://www.gardnermuseum.org/about/theft', 'Only known seascape by Rembrandt, stolen in the Gardner theft.', 66.4),
('gardner-1990-flinck-obelisk', 'Landscape with an Obelisk', 'Govaert Flinck', 'Painting', 'United States', 'Boston', 'Isabella Stewart Gardner Museum', 1990, null, 'Missing', 10.0, 42.3386, -71.0995, 'Isabella Stewart Gardner Museum', 'https://www.gardnermuseum.org/about/theft', 'Stolen in the 1990 Gardner Museum theft.', 58.3),
('gardner-1990-rembrandt-lady-gentleman', 'A Lady and Gentleman in Black', 'Rembrandt van Rijn', 'Painting', 'United States', 'Boston', 'Isabella Stewart Gardner Museum', 1990, null, 'Missing', 40.0, 42.3386, -71.0995, 'Isabella Stewart Gardner Museum', 'https://www.gardnermuseum.org/about/theft', 'Large Rembrandt painting stolen from the Dutch Room.', 61.0),
('gardner-1990-manet-tortoni', 'Chez Tortoni', 'Edouard Manet', 'Painting', 'United States', 'Boston', 'Isabella Stewart Gardner Museum', 1990, null, 'Missing', 20.0, 42.3386, -71.0995, 'Isabella Stewart Gardner Museum', 'https://www.gardnermuseum.org/about/theft', 'Manet work missing after the Gardner theft.', 59.2),
('gardner-1990-degas-cortege', 'Cortege aux Environs de Florence', 'Edgar Degas', 'Drawing', 'United States', 'Boston', 'Isabella Stewart Gardner Museum', 1990, null, 'Missing', 5.0, 42.3386, -71.0995, 'Isabella Stewart Gardner Museum', 'https://www.gardnermuseum.org/about/theft', 'Degas drawing stolen during the Gardner theft.', 53.9),
('gardner-1990-bronze-eagle', 'Napoleonic Eagle Finial', 'Unknown', 'Decorative Object', 'United States', 'Boston', 'Isabella Stewart Gardner Museum', 1990, null, 'Missing', 0.1, 42.3386, -71.0995, 'Isabella Stewart Gardner Museum', 'https://www.gardnermuseum.org/about/theft', 'Bronze finial from a Napoleonic flag staff.', 53.4),
('louvre-1911-mona-lisa', 'Mona Lisa', 'Leonardo da Vinci', 'Painting', 'France', 'Paris', 'Louvre Museum', 1911, 1913, 'Recovered', 860.0, 48.8606, 2.3376, 'Louvre Museum', 'https://www.louvre.fr/en/explore/the-palace/from-the-mona-lisa-to-the-wedding-feast-at-cana', 'Stolen from the Louvre in 1911 and recovered in Florence in 1913.', 69),
('oslo-1994-munch-scream', 'The Scream', 'Edvard Munch', 'Painting', 'Norway', 'Oslo', 'National Gallery of Norway', 1994, 1994, 'Recovered', 120.0, 59.9139, 10.7522, 'National Museum Norway', 'https://www.nasjonalmuseet.no/en/collection/object/NG.M.00939', 'Recovered in 1994 after a high-profile theft.', 37.6),
('amsterdam-2002-van-gogh-scheveningen', 'View of the Sea at Scheveningen', 'Vincent van Gogh', 'Painting', 'Netherlands', 'Amsterdam', 'Van Gogh Museum', 2002, 2016, 'Recovered', 30.0, 52.3584, 4.8811, 'Van Gogh Museum', 'https://www.vangoghmuseum.nl/en/about/knowledge-and-research/restorations/conservation-treatment-of-view-of-the-sea-at-scheveningen', 'Recovered in Italy in 2016 after being stolen from Amsterdam.', 26.3),
('amsterdam-2002-van-gogh-nuenen', 'Congregation Leaving the Reformed Church in Nuenen', 'Vincent van Gogh', 'Painting', 'Netherlands', 'Amsterdam', 'Van Gogh Museum', 2002, 2016, 'Recovered', 30.0, 52.3584, 4.8811, 'Van Gogh Museum', 'https://www.vangoghmuseum.nl/en/about/knowledge-and-research/restorations/conservation-treatment-church-in-nuenen', 'Recovered with the Scheveningen painting in 2016.', 26.3),
('cairo-2010-van-gogh-poppy', 'Poppy Flowers', 'Vincent van Gogh', 'Painting', 'Egypt', 'Cairo', 'Mohamed Mahmoud Khalil Museum', 2010, null, 'Missing', 50.0, 30.0444, 31.2357, 'FBI National Stolen Art File', 'https://artcrimes.fbi.gov/', 'Famous Van Gogh work reported stolen from Cairo in 2010.', 53.9),
('palermo-1969-caravaggio-nativity', 'Nativity with St. Francis and St. Lawrence', 'Caravaggio', 'Painting', 'Italy', 'Palermo', 'Oratory of San Lorenzo', 1969, null, 'Missing', 20.0, 38.1157, 13.3615, 'FBI Art Theft Program', 'https://www.fbi.gov/investigate/violent-crime/art-crime/fbi-top-ten-art-crimes', 'Long-running missing masterpiece case.', 64.8),
('stockholm-2000-renoir-conversation', 'Conversation with a Gardener', 'Pierre-Auguste Renoir', 'Painting', 'Sweden', 'Stockholm', 'Nationalmuseum', 2000, 2005, 'Recovered', 7.5, 59.3293, 18.0686, 'FBI Art Theft Program', 'https://www.fbi.gov/investigate/violent-crime/art-crime/fbi-top-ten-art-crimes', 'One of several works stolen from the Nationalmuseum in 2000.', 25.1),
('stockholm-2000-rembrandt-selfportrait', 'Self-Portrait', 'Rembrandt van Rijn', 'Painting', 'Sweden', 'Stockholm', 'Nationalmuseum', 2000, 2005, 'Recovered', 36.0, 59.3293, 18.0686, 'FBI Art Theft Program', 'https://www.fbi.gov/investigate/violent-crime/art-crime/fbi-top-ten-art-crimes', 'Recovered after the armed robbery of Nationalmuseum.', 27.6),
('vienna-1997-saliera', 'Saliera', 'Benvenuto Cellini', 'Sculpture', 'Austria', 'Vienna', 'Kunsthistorisches Museum', 2003, 2006, 'Recovered', 60.0, 48.2038, 16.3618, 'Cellini Salt Cellar case summary', 'https://en.wikipedia.org/wiki/Cellini_Salt_Cellar', 'Renaissance gold sculpture recovered in Austria.', 28.6),
('paris-2010-picasso-pigeon', 'Le pigeon aux petits pois', 'Pablo Picasso', 'Painting', 'France', 'Paris', 'Musee d''Art Moderne de Paris', 2010, null, 'Missing', 28.0, 48.8647, 2.2979, 'INTERPOL Stolen Works of Art Database', 'https://www.interpol.int/Crimes/Cultural-heritage-crime/Stolen-Works-of-Art-Database', 'Reported stolen from the Paris museum in 2010; recovery status remains unresolved in this teaching dataset.', 51.9),
('paris-2010-matisse-pastoral', 'La Pastorale', 'Henri Matisse', 'Painting', 'France', 'Paris', 'Musee d''Art Moderne de Paris', 2010, null, 'Missing', 18.0, 48.8647, 2.2979, 'INTERPOL Stolen Works of Art Database', 'https://www.interpol.int/Crimes/Cultural-heritage-crime/Stolen-Works-of-Art-Database', 'One of five works stolen in the Paris museum theft.', 51.0),
('paris-2010-modigliani-fan', 'Woman with a Fan', 'Amedeo Modigliani', 'Painting', 'France', 'Paris', 'Musee d''Art Moderne de Paris', 2010, null, 'Missing', 24.0, 48.8647, 2.2979, 'INTERPOL Stolen Works of Art Database', 'https://www.interpol.int/Crimes/Cultural-heritage-crime/Stolen-Works-of-Art-Database', 'High-value painting stolen in Paris in 2010.', 51.6),
('rotterdam-2012-picasso-harlequin', 'Harlequin Head', 'Pablo Picasso', 'Painting', 'Netherlands', 'Rotterdam', 'Kunsthal Rotterdam', 2012, null, 'Unknown', 15.0, 51.9244, 4.4777, 'Kunsthal public case summary', 'https://en.wikipedia.org/wiki/Kunsthal', 'Included as unknown/unresolved status for dashboard comparison.', 33.0),
('rotterdam-2012-monet-waterloo', 'Waterloo Bridge, London', 'Claude Monet', 'Painting', 'Netherlands', 'Rotterdam', 'Kunsthal Rotterdam', 2012, null, 'Unknown', 20.0, 51.9244, 4.4777, 'Kunsthal public case summary', 'https://en.wikipedia.org/wiki/Kunsthal', 'Stolen in the Kunsthal Rotterdam theft.', 33.4),
('rotterdam-2012-gauguin-woman-window', 'Woman Before a Window', 'Paul Gauguin', 'Painting', 'Netherlands', 'Rotterdam', 'Kunsthal Rotterdam', 2012, null, 'Unknown', 17.0, 51.9244, 4.4777, 'Kunsthal public case summary', 'https://en.wikipedia.org/wiki/Kunsthal', 'Kunsthal Rotterdam theft case record.', 33.1),
('warsaw-2000-monet-beach', 'Beach in Pourville', 'Claude Monet', 'Painting', 'Poland', 'Poznan', 'National Museum in Poznan', 2000, 2010, 'Recovered', 7.0, 52.4064, 16.9252, 'National Museum in Poznan', 'https://www.mnp.art.pl/en/collections/', 'Recovered after being stolen in Poland.', 25.0),
('miami-2019-dali-elephants', 'Les Elephants', 'Salvador Dali', 'Print', 'United States', 'San Francisco', 'Dennis Rae Fine Art', 2019, 2019, 'Recovered', 0.02, 37.7749, -122.4194, 'Public art-theft case summary', 'https://en.wikipedia.org/wiki/Art_theft', 'Small-value case useful for contrast against museum thefts.', 12.8),
('milan-1997-klimt-lady', 'Portrait of a Lady', 'Gustav Klimt', 'Painting', 'Italy', 'Piacenza', 'Ricci Oddi Gallery', 1997, 2019, 'Recovered', 66.0, 45.0526, 9.6934, 'Kunsthal public case summary', 'https://www.smithsonianmag.com/smart-news/painting-found-inside-walls-italian-gallery-may-be-stolen-klimt-180973757/', 'Found in the walls of the gallery after decades missing.', 31.5),
('oxford-2020-van-dyck-soldier', 'A Soldier on Horseback', 'Anthony van Dyck', 'Painting', 'United Kingdom', 'Oxford', 'Christ Church Picture Gallery', 2020, null, 'Missing', 1.3, 51.752, -1.2577, 'Thames Valley Police', 'https://www.chch.ox.ac.uk/news/stolen-artwork-returned-christ-church-picture-gallery', 'Recent unresolved case used to show time filters.', 45.5),
('oxford-2020-carracci-boy-drinking', 'A Boy Drinking', 'Annibale Carracci', 'Painting', 'United Kingdom', 'Oxford', 'Christ Church Picture Gallery', 2020, null, 'Missing', 1.0, 51.752, -1.2577, 'Thames Valley Police', 'https://www.chch.ox.ac.uk/news/stolen-artwork-returned-christ-church-picture-gallery', 'Stolen alongside two other paintings from Oxford.', 45.5),
('zurich-2008-cezanne-boy-red-waistcoat', 'Boy in a Red Waistcoat', 'Paul Cezanne', 'Painting', 'Switzerland', 'Zurich', 'Foundation E.G. Buehrle', 2008, 2012, 'Recovered', 109.0, 47.3769, 8.5417, 'Foundation E.G. Buehrle Collection', 'https://buehrle.ch/en/artworks/the-boy-in-the-red-waistcoat/', 'Recovered after a major Zurich art theft.', 31.0),
('zurich-2008-monet-poppies', 'Poppies near Vetheuil', 'Claude Monet', 'Painting', 'Switzerland', 'Zurich', 'Foundation E.G. Buehrle', 2008, 2008, 'Recovered', 44.0, 47.3769, 8.5417, 'Foundation E.G. Buehrle Collection', 'https://buehrle.ch/en/collection/', 'Recovered shortly after the theft.', 25.2),
('athens-2012-picasso-woman-head', 'Woman''s Head', 'Pablo Picasso', 'Painting', 'Greece', 'Athens', 'National Gallery of Greece', 2012, 2021, 'Recovered', 20.0, 37.9838, 23.7275, 'National Gallery of Greece', 'https://www.nationalgallery.gr/en/', 'Recovered by Greek authorities in 2021.', 21.4),
('athens-2012-mondrian-windmill', 'Stammer Windmill with Summer House', 'Piet Mondrian', 'Painting', 'Greece', 'Athens', 'National Gallery of Greece', 2012, 2021, 'Recovered', 8.0, 37.9838, 23.7275, 'National Gallery of Greece', 'https://www.nationalgallery.gr/en/', 'Recovered with the Picasso painting in 2021.', 20.3)
on conflict (id) do update set
  title = excluded.title,
  artist = excluded.artist,
  category = excluded.category,
  country_of_theft = excluded.country_of_theft,
  city_of_theft = excluded.city_of_theft,
  institution = excluded.institution,
  theft_year = excluded.theft_year,
  recovery_year = excluded.recovery_year,
  status = excluded.status,
  estimated_value_usd_m = excluded.estimated_value_usd_m,
  latitude = excluded.latitude,
  longitude = excluded.longitude,
  source_name = excluded.source_name,
  source_url = excluded.source_url,
  notes = excluded.notes,
  risk_score = excluded.risk_score;

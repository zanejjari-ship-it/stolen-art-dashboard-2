import { createClient } from "@supabase/supabase-js";

const supabaseUrl = (import.meta.env.VITE_SUPABASE_URL || "").trim().replace(/\/+$/g, "");
const supabaseKey = (import.meta.env.VITE_SUPABASE_ANON_KEY || "").trim();

let supabase = null;
if (supabaseUrl && supabaseKey && /^https:\/\/[a-z0-9-]+\.supabase\.co$/i.test(supabaseUrl)) {
  supabase = createClient(supabaseUrl, supabaseKey, {
    auth: { persistSession: false }
  });
}

function normalizeArtwork(row) {
  return {
    id: row.id,
    title: row.title || "Untitled",
    artist: row.artist || "Unknown",
    category: row.category || "Unknown",
    country_of_theft: row.country_of_theft || "Unknown",
    city_of_theft: row.city_of_theft || "Unknown",
    institution: row.institution || "Unknown",
    theft_year: Number(row.theft_year || 0),
    recovery_year: row.recovery_year ? Number(row.recovery_year) : null,
    status: row.status || "Unknown",
    estimated_value_usd_m: Number(row.estimated_value_usd_m || 0),
    latitude: row.latitude ? Number(row.latitude) : null,
    longitude: row.longitude ? Number(row.longitude) : null,
    source_name: row.source_name || "Source",
    source_url: row.source_url || "",
    notes: row.notes || "",
    risk_score: Number(row.risk_score || 0)
  };
}

async function fallbackArtworks(reason = "Supabase is not configured") {
  const response = await fetch("/sample_data.json", { cache: "no-store" });
  if (!response.ok) throw new Error("Could not load local sample data.");
  const data = await response.json();
  return { data: data.map(normalizeArtwork), fromDatabase: false, warning: reason };
}

export async function fetchArtworks() {
  if (!supabase) {
    return fallbackArtworks("Supabase environment variables are missing or malformed. Showing local sample data.");
  }

  try {
    const { data, error } = await supabase
      .from("stolen_artworks")
      .select("*")
      .order("theft_year", { ascending: true });

    if (error) {
      return fallbackArtworks(`Supabase read failed: ${error.message}. Showing local sample data.`);
    }

    if (!data || data.length === 0) {
      return fallbackArtworks("Supabase table is empty. Showing local sample data.");
    }

    return { data: data.map(normalizeArtwork), fromDatabase: true, warning: "" };
  } catch (error) {
    return fallbackArtworks(`Network/database error: ${error.message}. Showing local sample data.`);
  }
}

export function filterArtworks(artworks, { q = "", status = "All", category = "All" } = {}) {
  const term = q.trim().toLowerCase();
  return artworks.filter((row) => {
    const matchesQ = !term || [
      row.title,
      row.artist,
      row.country_of_theft,
      row.city_of_theft,
      row.institution,
      row.notes,
      row.source_name
    ].join(" ").toLowerCase().includes(term);
    const matchesStatus = status === "All" || row.status === status;
    const matchesCategory = category === "All" || row.category === category;
    return matchesQ && matchesStatus && matchesCategory;
  });
}

export function buildSummary(artworks) {
  const total = artworks.length;
  const missing = artworks.filter((a) => a.status === "Missing").length;
  const recovered = artworks.filter((a) => a.status === "Recovered").length;
  const unknown = artworks.filter((a) => a.status === "Unknown").length;
  const totalValue = artworks.reduce((sum, a) => sum + Number(a.estimated_value_usd_m || 0), 0);

  const durations = artworks
    .filter((a) => a.recovery_year && a.theft_year)
    .map((a) => Number(a.recovery_year) - Number(a.theft_year));
  const avgRecoveryYears = durations.length ? durations.reduce((a, b) => a + b, 0) / durations.length : 0;

  const group = (key) => Object.values(
    artworks.reduce((acc, row) => {
      const label = row[key] || "Unknown";
      if (!acc[label]) acc[label] = { name: label, count: 0, value: 0 };
      acc[label].count += 1;
      acc[label].value += Number(row.estimated_value_usd_m || 0);
      return acc;
    }, {})
  ).sort((a, b) => b.count - a.count || b.value - a.value);

  const timeline = Object.values(
    artworks.reduce((acc, row) => {
      const year = row.theft_year || "Unknown";
      if (!acc[year]) acc[year] = { year, count: 0, missing: 0, recovered: 0, unknown: 0 };
      acc[year].count += 1;
      if (row.status === "Missing") acc[year].missing += 1;
      if (row.status === "Recovered") acc[year].recovered += 1;
      if (row.status === "Unknown") acc[year].unknown += 1;
      return acc;
    }, {})
  ).sort((a, b) => Number(a.year) - Number(b.year));

  const scatter = artworks
    .filter((a) => a.theft_year && a.estimated_value_usd_m > 0)
    .map((a) => ({
      year: Number(a.theft_year),
      value: Number(a.estimated_value_usd_m),
      title: a.title,
      status: a.status,
      category: a.category
    }));

  return {
    kpis: {
      total_cases: total,
      missing_cases: missing,
      recovered_cases: recovered,
      unknown_cases: unknown,
      recovery_rate: total ? Math.round((recovered / total) * 1000) / 10 : 0,
      estimated_total_value_usd_m: Math.round(totalValue * 10) / 10,
      average_recovery_years: Math.round(avgRecoveryYears * 10) / 10
    },
    charts: {
      byStatus: group("status"),
      byCategory: group("category"),
      byCountry: group("country_of_theft"),
      timeline,
      scatter
    }
  };
}

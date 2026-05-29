import React, { useEffect, useMemo, useState } from "react";
import {
  Area,
  AreaChart,
  Bar,
  BarChart,
  CartesianGrid,
  Cell,
  Legend,
  Pie,
  PieChart,
  ResponsiveContainer,
  Scatter,
  ScatterChart,
  Tooltip,
  XAxis,
  YAxis
} from "recharts";
import { RefreshCw, Search, Database, ExternalLink, ShieldAlert, CheckCircle2 } from "lucide-react";
import { buildSummary, fetchArtworks, filterArtworks } from "./api.js";

const chartColors = ["#7c3aed", "#db2777", "#2563eb", "#16a34a", "#ea580c", "#0f766e", "#9333ea"];

function money(value) {
  return `$${Number(value || 0).toLocaleString(undefined, { maximumFractionDigits: 1 })}m`;
}

function KpiCard({ label, value, note }) {
  return (
    <section className="kpi-card">
      <p>{label}</p>
      <strong>{value}</strong>
      <span>{note}</span>
    </section>
  );
}

function Badge({ status }) {
  return <span className={`badge ${String(status).toLowerCase()}`}>{status}</span>;
}

export default function App() {
  const [artworks, setArtworks] = useState([]);
  const [q, setQ] = useState("");
  const [status, setStatus] = useState("All");
  const [category, setCategory] = useState("All");
  const [loading, setLoading] = useState(true);
  const [warning, setWarning] = useState("");
  const [fromDatabase, setFromDatabase] = useState(false);
  const [lastRefresh, setLastRefresh] = useState(null);

  async function loadData() {
    setLoading(true);
    try {
      const result = await fetchArtworks();
      setArtworks(result.data);
      setFromDatabase(result.fromDatabase);
      setWarning(result.warning || "");
      setLastRefresh(new Date());
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadData();
  }, []);

  const summary = useMemo(() => buildSummary(artworks), [artworks]);
  const filtered = useMemo(() => filterArtworks(artworks, { q, status, category }), [artworks, q, status, category]);
  const categories = useMemo(() => ["All", ...Array.from(new Set(artworks.map((a) => a.category))).sort()], [artworks]);

  return (
    <main className="app-shell">
      <header className="hero">
        <div>
          <span className="eyebrow">Art crime analytics</span>
          <h1>Stolen Artworks Intelligence Dashboard</h1>
          <p>
            A database-backed web dashboard for exploring stolen artworks by recovery status, theft year,
            country, category, estimated value, and source documentation.
          </p>
          <div className="status-line">
            <span className={fromDatabase ? "pill success" : "pill warning"}>
              {fromDatabase ? <CheckCircle2 size={15} /> : <ShieldAlert size={15} />}
              {fromDatabase ? "Connected to Supabase database" : "Using local fallback data"}
            </span>
            {lastRefresh && <span className="pill neutral">Last view refresh: {lastRefresh.toLocaleTimeString()}</span>}
          </div>
        </div>
        <button className="refresh-button" onClick={loadData} disabled={loading}>
          <RefreshCw size={18} className={loading ? "spin" : ""} />
          {loading ? "Refreshing..." : "Refresh view"}
        </button>
      </header>

      {warning && <div className="warning-box">{warning}</div>}

      <section className="kpi-grid">
        <KpiCard label="Total cases" value={summary.kpis.total_cases} note="Records in current dataset" />
        <KpiCard label="Missing" value={summary.kpis.missing_cases} note="Still unresolved or not returned" />
        <KpiCard label="Recovered" value={summary.kpis.recovered_cases} note={`${summary.kpis.recovery_rate}% recovery rate`} />
        <KpiCard label="Estimated value" value={money(summary.kpis.estimated_total_value_usd_m)} note="Teaching/demo estimates" />
        <KpiCard label="Average recovery time" value={`${summary.kpis.average_recovery_years} yrs`} note="For recovered cases only" />
      </section>

      <section className="panel controls-panel">
        <div className="search-box">
          <Search size={17} />
          <input value={q} onChange={(e) => setQ(e.target.value)} placeholder="Search title, artist, country, institution..." />
        </div>
        <select value={status} onChange={(e) => setStatus(e.target.value)}>
          <option>All</option>
          <option>Missing</option>
          <option>Recovered</option>
          <option>Unknown</option>
        </select>
        <select value={category} onChange={(e) => setCategory(e.target.value)}>
          {categories.map((c) => <option key={c}>{c}</option>)}
        </select>
      </section>

      <section className="chart-grid">
        <div className="panel chart-panel wide">
          <h2>Theft timeline</h2>
          <ResponsiveContainer height={315}>
            <AreaChart data={summary.charts.timeline}>
              <defs>
                <linearGradient id="timelineGradient" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="#7c3aed" stopOpacity={0.55} />
                  <stop offset="95%" stopColor="#7c3aed" stopOpacity={0.04} />
                </linearGradient>
              </defs>
              <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
              <XAxis dataKey="year" />
              <YAxis allowDecimals={false} />
              <Tooltip />
              <Legend />
              <Area type="monotone" dataKey="count" name="All cases" stroke="#7c3aed" fill="url(#timelineGradient)" strokeWidth={3} />
            </AreaChart>
          </ResponsiveContainer>
        </div>

        <div className="panel chart-panel">
          <h2>Status</h2>
          <ResponsiveContainer height={315}>
            <PieChart>
              <Pie data={summary.charts.byStatus} dataKey="count" nameKey="name" outerRadius={104} label>
                {summary.charts.byStatus.map((_, index) => <Cell key={index} fill={chartColors[index % chartColors.length]} />)}
              </Pie>
              <Tooltip />
              <Legend />
            </PieChart>
          </ResponsiveContainer>
        </div>

        <div className="panel chart-panel">
          <h2>Categories</h2>
          <ResponsiveContainer height={315}>
            <BarChart data={summary.charts.byCategory.slice(0, 8)} layout="vertical" margin={{ left: 20 }}>
              <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
              <XAxis type="number" allowDecimals={false} />
              <YAxis type="category" dataKey="name" width={88} />
              <Tooltip />
              <Bar dataKey="count" name="Cases" radius={[0, 8, 8, 0]} fill="#2563eb" />
            </BarChart>
          </ResponsiveContainer>
        </div>

        <div className="panel chart-panel">
          <h2>Top countries</h2>
          <ResponsiveContainer height={315}>
            <BarChart data={summary.charts.byCountry.slice(0, 8)}>
              <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
              <XAxis dataKey="name" angle={-25} textAnchor="end" height={75} />
              <YAxis allowDecimals={false} />
              <Tooltip />
              <Bar dataKey="count" name="Cases" fill="#db2777" radius={[8, 8, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>

        <div className="panel chart-panel wide">
          <h2>Estimated value by theft year</h2>
          <ResponsiveContainer height={315}>
            <ScatterChart>
              <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
              <XAxis dataKey="year" type="number" name="Theft year" domain={[1900, "dataMax"]} />
              <YAxis dataKey="value" type="number" name="Estimated value" tickFormatter={money} />
              <Tooltip cursor={{ strokeDasharray: "3 3" }} formatter={(value, name) => name === "value" ? money(value) : value} />
              <Scatter name="Artworks" data={summary.charts.scatter} fill="#16a34a" />
            </ScatterChart>
          </ResponsiveContainer>
        </div>
      </section>

      <section className="panel table-panel">
        <div className="table-header">
          <div>
            <h2>Case database</h2>
            <p>{filtered.length} visible record(s) after filters.</p>
          </div>
          <div className="db-note"><Database size={16} /> Supabase table: stolen_artworks</div>
        </div>
        <div className="table-wrap">
          <table>
            <thead>
              <tr>
                <th>Artwork</th>
                <th>Artist</th>
                <th>Place</th>
                <th>Year</th>
                <th>Status</th>
                <th>Value</th>
                <th>Source</th>
              </tr>
            </thead>
            <tbody>
              {filtered.map((row) => (
                <tr key={row.id}>
                  <td><strong>{row.title}</strong><small>{row.category}</small></td>
                  <td>{row.artist}</td>
                  <td>{row.city_of_theft}, {row.country_of_theft}<small>{row.institution}</small></td>
                  <td>{row.theft_year}</td>
                  <td><Badge status={row.status} /></td>
                  <td>{money(row.estimated_value_usd_m)}</td>
                  <td>
                    <a href={row.source_url} target="_blank" rel="noreferrer" className="source-link">
                      {row.source_name || "Source"} <ExternalLink size={13} />
                    </a>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>
    </main>
  );
}

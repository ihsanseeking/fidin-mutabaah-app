# ERD — Mutabaah Fidin Jenggot Merah
**Entity Relationship Diagram & Database Schema**  
Versi: 1.2 | Terakhir diperbarui: 2026-06-09

---

## Changelog

| Versi | Tanggal | Perubahan |
|-------|---------|-----------|
| 1.0 | 2026-06-07 | Rilis awal: users, daily_checkin, tilawah_progress |
| 1.1 | 2026-06-07 | Tambah state storage table (dokumentasi saja) |
| 1.2 | 2026-06-09 | Rename semua tabel ke prefix `mtb_`, tambah mtb_counters, mtb_iqob, mtb_group_config, kolom external_user_id & peran di mtb_users |

---

## Catatan Arsitektur

Semua tabel menggunakan **prefix `mtb_`** agar mudah diintegrasikan ke dalam database web aplikasi utama kelak, tanpa konflik nama dengan tabel lain. Kolom `external_user_id` pada `mtb_users` disiapkan sebagai link ke tabel user utama saat integrasi dilakukan.

**Pendekatan sync:** _offline-first_ — localStorage selalu diperbarui duluan, Supabase sync dilakukan secara async di background. Data counter progressive (olahraga, dzikir, QL sub) dan iqob kini tersimpan di Supabase, sehingga multi-device sync berjalan penuh.

---

## Diagram ERD

```
┌──────────────────────────────────────┐
│              mtb_users               │
├──────────────────────────────────────┤
│ 🔑 id               UUID  PK         │
│    nama_lengkap     TEXT  UNIQUE     │
│    device_id        TEXT  UNIQUE     │
│    grup             TEXT             │
│    peran            TEXT  DEFAULT    │
│                           'anggota'  │
│    external_user_id UUID  nullable   │ ← link ke web app utama (nanti)
│    created_at       TIMESTAMPTZ      │
└──────────┬───────────────────────────┘
           │ 1 : ∞ ke semua tabel di bawah
           │
   ┌───────┼────────────────────────────────────────────┐
   │       │                  │                          │
   ▼       ▼                  ▼                          ▼
┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────┐
│ mtb_daily_checkin│  │   mtb_tilawah    │  │  mtb_counters    │  │  mtb_iqob    │
├──────────────────┤  ├──────────────────┤  ├──────────────────┤  ├──────────────┤
│ user_id  FK      │  │ user_id  FK      │  │ user_id  FK      │  │ user_id FK   │
│ tanggal  DATE    │  │ tanggal  DATE    │  │ tanggal  DATE    │  │ tanggal DATE │
│ amalan_id TEXT   │  │ halaman  INT     │  │ olahraga_menit   │  │ hutang INT   │
│ checked  BOOL    │  │ UNIQUE(uid,tgl)  │  │ istighfar INT    │  │ dilunasi INT │
│ checked_at       │  └──────────────────┘  │ sholawat  INT    │  │ kumulatif INT│
│ UNIQUE(uid,tgl,  │                        │ tasbih    INT    │  │ UNIQUE(u,t)  │
│        amalan_id)│                        │ tahajud_rokaat   │  └──────────────┘
└──────────────────┘                        │ witir_rokaat     │
                                            │ UNIQUE(uid,tgl)  │
                                            └──────────────────┘

┌──────────────────────────────────────────┐
│           mtb_group_config               │  (satu baris per grup)
├──────────────────────────────────────────┤
│ grup             TEXT  UNIQUE            │ ← 'Jenggot Merah'
│ target_amalan    TEXT[]                  │ ← array amalan_id
│ dzikir_targets   JSONB                   │ ← {istighfar:100, ...}
│ olahraga_target  INT                     │ ← default 30 menit
│ iqob_per_miss    INT                     │ ← default 10 pushup
│ updated_by       TEXT                    │
│ updated_at       TIMESTAMPTZ             │
└──────────────────────────────────────────┘
```

---

## DDL (SQL Schema)

```sql
-- TABLE: mtb_users
CREATE TABLE mtb_users (
  id                UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  nama_lengkap      TEXT        NOT NULL UNIQUE,
  device_id         TEXT        UNIQUE,
  grup              TEXT        NOT NULL DEFAULT 'Jenggot Merah',
  peran             TEXT        NOT NULL DEFAULT 'anggota', -- 'anggota'|'pj'|'pembina'
  external_user_id  UUID,       -- link ke web app utama (nullable sampai integrasi)
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- TABLE: mtb_daily_checkin
CREATE TABLE mtb_daily_checkin (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID        NOT NULL REFERENCES mtb_users(id) ON DELETE CASCADE,
  tanggal     DATE        NOT NULL,
  amalan_id   TEXT        NOT NULL,
  checked     BOOLEAN     NOT NULL DEFAULT false,
  checked_at  TIMESTAMPTZ,
  UNIQUE (user_id, tanggal, amalan_id)
);

-- TABLE: mtb_tilawah
CREATE TABLE mtb_tilawah (
  id        UUID  PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id   UUID  NOT NULL REFERENCES mtb_users(id) ON DELETE CASCADE,
  tanggal   DATE  NOT NULL,
  halaman   INT   NOT NULL DEFAULT 0,
  UNIQUE (user_id, tanggal)
);

-- TABLE: mtb_counters  (baru v1.2 — counter progressive)
CREATE TABLE mtb_counters (
  id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID        NOT NULL REFERENCES mtb_users(id) ON DELETE CASCADE,
  tanggal         DATE        NOT NULL,
  olahraga_menit  INT         NOT NULL DEFAULT 0,
  istighfar       INT         NOT NULL DEFAULT 0,
  sholawat        INT         NOT NULL DEFAULT 0,
  tasbih          INT         NOT NULL DEFAULT 0,
  tahajud_rokaat  INT         NOT NULL DEFAULT 0,
  witir_rokaat    INT         NOT NULL DEFAULT 0,
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id, tanggal)
);

-- TABLE: mtb_iqob  (baru v1.2 — hutang iqob)
CREATE TABLE mtb_iqob (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID        NOT NULL REFERENCES mtb_users(id) ON DELETE CASCADE,
  tanggal     DATE        NOT NULL,
  hutang      INT         NOT NULL DEFAULT 0,   -- baru hari ini
  dilunasi    INT         NOT NULL DEFAULT 0,   -- dibayar hari ini
  kumulatif   INT         NOT NULL DEFAULT 0,   -- total carry-over
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id, tanggal)
);

-- TABLE: mtb_group_config  (baru v1.2 — config PJ)
CREATE TABLE mtb_group_config (
  id                 UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  grup               TEXT        NOT NULL UNIQUE,
  target_amalan      TEXT[]      NOT NULL DEFAULT '{}',
  dzikir_targets     JSONB       NOT NULL DEFAULT '{"istighfar":100,"sholawat":100,"tasbih":33}',
  olahraga_target    INT         NOT NULL DEFAULT 30,
  iqob_per_miss      INT         NOT NULL DEFAULT 10,
  updated_by         TEXT,
  updated_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

---

## Row Level Security (RLS)

Semua tabel menggunakan **anon key** — open policy karena identitas dijaga di sisi app.

```sql
-- Pola sama untuk semua tabel mtb_*:
-- SELECT/INSERT/UPDATE diizinkan oleh anon
-- Saat integrasi Supabase Auth (v2): ganti ke USING (auth.uid() = external_user_id)
```

---

## Daftar amalan_id

| amalan_id | Nama Tampil | Kategori | Hari |
|-----------|-------------|----------|------|
| `1juz` | Tilawah | Tilawah | Semua |
| `olahraga` | Olahraga 30 mnt | Sehat | Semua |
| `istighfar` | Istighfar | Dzikir | Semua |
| `sholawat` | Sholawat | Dzikir | Semua |
| `tasbih` | Tasbih | Dzikir | Semua |
| `infaq` | Infaq | Amal | Semua |
| `puasa_senin_kamis` | Puasa Senin-Kamis | Puasa | Senin, Kamis |
| `ql` | Sholat Malam (QL) | Malam | Semua |
| `earlybird_subuh` | Early Bird Subuh | Subuh | Semua |
| `qobliyah_subuh` | Qobliyah Subuh | Subuh | Semua |
| `subuh` | Sholat Subuh | Subuh | Semua |
| `dzikir_pagi` | Dzikir Pagi | Pagi | Semua |
| `duha` | Sholat Duha | Pagi | Semua |
| `earlybird_dzuhur` | Early Bird Dzuhur | Dzuhur | Kecuali Jumat |
| `qobliyah_dzuhur` | Qobliyah Dzuhur | Dzuhur | Kecuali Jumat |
| `dzuhur` | Sholat Dzuhur | Dzuhur | Kecuali Jumat |
| `badiyah_dzuhur` | Ba'diyah Dzuhur | Dzuhur | Kecuali Jumat |
| `earlybird_ashar` | Early Bird Ashar | Ashar | Semua |
| `ashar` | Sholat Ashar | Ashar | Semua |
| `dzikir_sore` | Dzikir Sore | Sore | Semua |
| `kahfi` | Baca Al-Kahfi | Sore | Jumat |
| `earlybird_maghrib` | Early Bird Maghrib | Maghrib | Semua |
| `qobliyah_maghrib` | Qobliyah Maghrib | Maghrib | Semua |
| `maghrib` | Sholat Maghrib | Maghrib | Semua |
| `badiyah_maghrib` | Ba'diyah Maghrib | Maghrib | Semua |
| `earlybird_isya` | Early Bird Isya | Isya | Semua |
| `isya` | Sholat Isya | Isya | Semua |
| `badiyah_isya` | Ba'diyah Isya | Isya | Semua |
| `sholat_jumat` | Sholat Jumat | Jumat | Jumat |

---

## State Storage (localStorage → Supabase sync)

| Data | localStorage key | Tabel Supabase | Sync? |
|------|-----------------|----------------|-------|
| Centang amalan | `state.checked[tgl][id]` | `mtb_daily_checkin` | ✅ |
| Tilawah halaman | `state.tilawah[tgl]` | `mtb_tilawah` | ✅ |
| Olahraga menit | `state.olahraga[tgl]` | `mtb_counters.olahraga_menit` | ✅ v1.2 |
| Istighfar count | `state.dzikir[tgl].istighfar` | `mtb_counters.istighfar` | ✅ v1.2 |
| Sholawat count | `state.dzikir[tgl].sholawat` | `mtb_counters.sholawat` | ✅ v1.2 |
| Tasbih count | `state.dzikir[tgl].tasbih` | `mtb_counters.tasbih` | ✅ v1.2 |
| Tahajud rokaat | `state.ql_sub[tgl].tahajud` | `mtb_counters.tahajud_rokaat` | ✅ v1.2 |
| Witir rokaat | `state.ql_sub[tgl].witir` | `mtb_counters.witir_rokaat` | ✅ v1.2 |
| Hutang iqob | `state.iqob.hutang` | `mtb_iqob.kumulatif` | ✅ v1.2 |
| Config target grup | hardcoded JS → load dari DB | `mtb_group_config` | ✅ v1.2 |

---

## Contoh Query Laporan

```sql
-- Progress anggota hari ini (target grup saja)
SELECT u.nama_lengkap,
       COUNT(dc.id) FILTER (WHERE dc.checked AND dc.amalan_id = ANY(gc.target_amalan)) AS done,
       array_length(gc.target_amalan, 1) AS total_target
FROM mtb_users u
LEFT JOIN mtb_daily_checkin dc ON dc.user_id = u.id AND dc.tanggal = CURRENT_DATE
CROSS JOIN mtb_group_config gc WHERE gc.grup = 'Jenggot Merah'
GROUP BY u.nama_lengkap, gc.target_amalan
ORDER BY done DESC;

-- Olahraga + dzikir minggu ini
SELECT u.nama_lengkap,
       SUM(c.olahraga_menit) AS menit_olahraga,
       SUM(c.istighfar)      AS total_istighfar,
       SUM(c.sholawat)       AS total_sholawat
FROM mtb_users u
JOIN mtb_counters c ON c.user_id = u.id
WHERE c.tanggal >= date_trunc('week', CURRENT_DATE)
GROUP BY u.nama_lengkap;

-- Hutang iqob per anggota
SELECT u.nama_lengkap,
       MAX(i.kumulatif)  AS hutang_pushup,
       SUM(i.dilunasi)   AS sudah_dilunasi
FROM mtb_users u
LEFT JOIN mtb_iqob i ON i.user_id = u.id
GROUP BY u.nama_lengkap ORDER BY hutang_pushup DESC;
```

---

## Integrasi Google Sheets (Rencana v1.3)

Data Supabase bisa di-pull otomatis ke Google Sheets menggunakan **Google Apps Script** (gratis):

```javascript
// Di Google Apps Script — jalankan tiap malam (trigger time-based)
function syncMutabaahToSheets() {
  const BASE = 'https://rnrtoevvinjbnldfeitg.supabase.co/rest/v1';
  const KEY  = 'YOUR_ANON_KEY';
  const opts = { headers: { apikey: KEY, Authorization: 'Bearer ' + KEY } };

  const today = Utilities.formatDate(new Date(), 'Asia/Jakarta', 'yyyy-MM-dd');

  // Pull checkin hari ini
  const checkins = JSON.parse(
    UrlFetchApp.fetch(`${BASE}/mtb_daily_checkin?tanggal=eq.${today}&checked=eq.true`, opts)
    .getContentText()
  );

  // Pull counters hari ini
  const counters = JSON.parse(
    UrlFetchApp.fetch(`${BASE}/mtb_counters?tanggal=eq.${today}`, opts)
    .getContentText()
  );

  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('Daily') ||
                SpreadsheetApp.getActiveSpreadsheet().insertSheet('Daily');
  // ... tulis ke sheet
}
```

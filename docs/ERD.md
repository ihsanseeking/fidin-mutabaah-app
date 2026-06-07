# ERD — Mutabaah Fidin Jenggot Merah
**Entity Relationship Diagram & Database Schema**  
Versi: 1.1 | Terakhir diperbarui: 2026-06-07

---

## Diagram ERD

```
┌─────────────────────────────────┐
│             users               │
├─────────────────────────────────┤
│ 🔑 id          UUID  PK         │
│    nama_lengkap TEXT  NOT NULL  │
│    device_id   TEXT  UNIQUE     │
│    grup        TEXT  DEFAULT    │
│                      'Jenggot   │
│                       Merah'    │
│    created_at  TIMESTAMPTZ      │
└──────────────┬──────────────────┘
               │ 1
               │
               │ ∞
┌──────────────▼──────────────────┐
│         daily_checkin           │
├─────────────────────────────────┤
│ 🔑 id          UUID  PK         │
│ 🔗 user_id     UUID  FK→users   │
│    tanggal     DATE  NOT NULL   │
│    amalan_id   TEXT  NOT NULL   │
│    checked     BOOLEAN          │
│    checked_at  TIMESTAMPTZ      │
│                                 │
│ UNIQUE(user_id, tanggal,        │
│        amalan_id)               │
└─────────────────────────────────┘

               │ 1
               │ (users)
               │ ∞
┌──────────────▼──────────────────┐
│       tilawah_progress          │
├─────────────────────────────────┤
│ 🔑 id          UUID  PK         │
│ 🔗 user_id     UUID  FK→users   │
│    tanggal     DATE  NOT NULL   │
│    halaman     INT   NOT NULL   │
│                                 │
│ UNIQUE(user_id, tanggal)        │
└─────────────────────────────────┘
```

---

## DDL (SQL Schema)

```sql
-- ─────────────────────────────────────────
-- TABLE: users
-- Satu baris per anggota (atau per device tamu)
-- device_id unik per device (dari localStorage)
-- ─────────────────────────────────────────
CREATE TABLE users (
  id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  nama_lengkap  TEXT        NOT NULL,
  device_id     TEXT        UNIQUE,
  grup          TEXT        NOT NULL DEFAULT 'Jenggot Merah',
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ─────────────────────────────────────────
-- TABLE: daily_checkin
-- Satu baris per amalan per hari per user
-- amalan_id: slug dari DEFAULT_AMALAN di app
-- ─────────────────────────────────────────
CREATE TABLE daily_checkin (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  tanggal     DATE        NOT NULL,
  amalan_id   TEXT        NOT NULL,
  checked     BOOLEAN     NOT NULL DEFAULT false,
  checked_at  TIMESTAMPTZ,
  UNIQUE (user_id, tanggal, amalan_id)
);

-- ─────────────────────────────────────────
-- TABLE: tilawah_progress
-- Satu baris per hari per user
-- halaman: total halaman tilawah hari itu (bisa > 20)
-- ─────────────────────────────────────────
CREATE TABLE tilawah_progress (
  id        UUID  PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id   UUID  NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  tanggal   DATE  NOT NULL,
  halaman   INT   NOT NULL DEFAULT 0,
  UNIQUE (user_id, tanggal)
);
```

---

## Row Level Security (RLS)

Semua tabel menggunakan **anon key** (tidak ada autentikasi user). Kebijakan:

```sql
-- users: anon bisa baca semua, insert baru, update milik sendiri
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
CREATE POLICY "anon_read_users"   ON users FOR SELECT USING (true);
CREATE POLICY "anon_insert_users" ON users FOR INSERT WITH CHECK (true);
CREATE POLICY "anon_update_users" ON users FOR UPDATE USING (true);

-- daily_checkin: anon bisa baca semua, insert & update bebas
ALTER TABLE daily_checkin ENABLE ROW LEVEL SECURITY;
CREATE POLICY "anon_read_checkin"   ON daily_checkin FOR SELECT USING (true);
CREATE POLICY "anon_insert_checkin" ON daily_checkin FOR INSERT WITH CHECK (true);
CREATE POLICY "anon_update_checkin" ON daily_checkin FOR UPDATE USING (true);

-- tilawah_progress: anon bisa baca semua, insert & update bebas
ALTER TABLE tilawah_progress ENABLE ROW LEVEL SECURITY;
CREATE POLICY "anon_read_tilawah"   ON tilawah_progress FOR SELECT USING (true);
CREATE POLICY "anon_insert_tilawah" ON tilawah_progress FOR INSERT WITH CHECK (true);
CREATE POLICY "anon_update_tilawah" ON tilawah_progress FOR UPDATE USING (true);
```

> **Catatan**: RLS di sini bersifat open karena identitas dijaga di sisi app (device_id di localStorage), bukan di Supabase auth. Untuk v2 yang multi-grup, pertimbangkan Supabase Auth + RLS by user_id.

---

## Daftar amalan_id

| amalan_id | Nama Tampil | Kategori |
|-----------|-------------|----------|
| `ql` | QL / Sholat Malam | Malam |
| `earlybird_subuh` | Early Bird Subuh | Subuh |
| `qobliyah_subuh` | Qobliyah Subuh | Subuh |
| `subuh` | Sholat Subuh | Subuh |
| `dzikir_pagi` | Dzikir Pagi | Pagi |
| `duha` | Sholat Duha | Pagi |
| `earlybird_dzuhur` | Early Bird Dzuhur | Dzuhur |
| `qobliyah_dzuhur` | Qobliyah Dzuhur | Dzuhur |
| `dzuhur` | Sholat Dzuhur | Dzuhur |
| `badiyah_dzuhur` | Ba'diyah Dzuhur | Dzuhur |
| `earlybird_ashar` | Early Bird Ashar | Ashar |
| `ashar` | Sholat Ashar | Ashar |
| `dzikir_sore` | Dzikir Sore | Sore |
| `kahfi` | Baca Al-Kahfi | Jumat |
| `earlybird_maghrib` | Early Bird Maghrib | Maghrib |
| `maghrib` | Sholat Maghrib | Maghrib |
| `qobliyah_maghrib` | Sunnah Qobliyah Maghrib | Maghrib |
| `badiyah_maghrib` | Ba'diyah Maghrib | Maghrib |
| `earlybird_isya` | Early Bird Isya | Isya |
| `isya` | Sholat Isya | Isya |
| `badiyah_isya` | Ba'diyah Isya | Isya |
| `sholat_jumat` | Sholat Jumat (Jumat only) | Jumat |
| `infaq` | Infaq | Amal |
| `1juz` | Tilawah 1 Juz | Tilawah |
| `puasa_senin_kamis` | Puasa Senin-Kamis | Puasa |
| `olahraga` | Olahraga 30 mnt | Sehat |
| `istighfar` | Istighfar | Dzikir |
| `sholawat` | Sholawat | Dzikir |
| `tasbih` | Tasbih/Dzikir | Dzikir |

---

## State Storage (localStorage)

State yang disimpan di localStorage pada sisi client:

| Key | Format | Keterangan |
|-----|--------|------------|
| `mutabaah_user_id` | UUID string | ID user aktif — digunakan untuk multi-device sync |
| `state.olahraga[tanggal]` | `int` (menit) | Durasi olahraga harian (progressive, bukan boolean) |
| `state.dzikir[tanggal][id]` | `int` (count) | Counter per jenis dzikir per hari |
| `state.iqob` | `{ hutang: int, lastCalc: date }` | Akumulasi hutang iqob dan tanggal kalkulasi terakhir |

> **Catatan**: `mutabaah_user_id` menggantikan peran `device_id` untuk identifikasi user lintas device. `state.olahraga` menyimpan menit (integer) bukan boolean karena target olahraga bersifat progressive. `state.dzikir` menggunakan nested object `[tanggal][id]` agar bisa menyimpan banyak jenis dzikir sekaligus.

---

## Contoh Query Admin

```sql
-- Progress anggota hari ini
SELECT u.nama_lengkap,
       COUNT(dc.id) FILTER (WHERE dc.checked) as done,
       COUNT(dc.id) as total
FROM users u
LEFT JOIN daily_checkin dc ON dc.user_id = u.id AND dc.tanggal = CURRENT_DATE
GROUP BY u.nama_lengkap
ORDER BY done DESC;

-- Tilawah minggu ini
SELECT u.nama_lengkap, SUM(tp.halaman) as total_hal
FROM users u
JOIN tilawah_progress tp ON tp.user_id = u.id
WHERE tp.tanggal >= date_trunc('week', CURRENT_DATE)
GROUP BY u.nama_lengkap
ORDER BY total_hal DESC;
```

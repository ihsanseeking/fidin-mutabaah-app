# 📋 Briefing: Mutabaah Fidin Jenggot Merah
> Dokumen ini untuk melanjutkan proyek di Claude Code. Baca semua sebelum mulai.

---

## 🎯 Gambaran Proyek

Aplikasi mutabaah (checklist amalan harian) untuk komunitas **FIDIN Jenggot Merah** — sebuah kelompok kajian Islam di Sukabumi, Jawa Barat. App ini berbasis **single-file HTML** yang di-host di Netlify, mobile-first, dan bisa disimpan di HP sebagai PWA (Add to Home Screen).

**URL Live:** https://mutabaah-ihsan.netlify.app/  
**File utama:** `mutabaah.html` (satu file, semua CSS + JS di dalamnya)  
**Stack:** Vanilla HTML/CSS/JS + Supabase (akan diintegrasikan)

---

## ✅ Fitur yang Sudah Ada

- Checklist amalan harian (14 amalan)
- Waktu sholat akurat dari data Kemenag Sukabumi (hardcode Juni 2026)
- Countdown ke sholat berikutnya + reminder notifikasi browser
- Reminder Duha bertahap (interval bisa diatur di Setelan)
- Reminder infaq muncul bersamaan dengan notif sholat
- Progress tilawah per halaman (target 20 halaman = 1 juz)
- Puasa Senin Kamis: muncul otomatis di hari Senin/Kamis, reminder malam sebelumnya
- Laporan mingguan: bar chart 7 hari, detail per amalan, ekspor teks ke WA
- Multi-user: pilih nama dari list anggota, data tersimpan di localStorage per user
- Logo FIDIN di header, branding "Mutabaah Fidin Jenggot Merah"
- Dark green theme, font Amiri + Plus Jakarta Sans + DM Mono

---

## 👥 Anggota Fidin Jenggot Merah (11 orang)

```
1. Auliya Bil Allafa
2. Hendri Ibnu Halim
3. Heri Hermawan
4. Ihsan Faturohman  ← ini ownernya (Kepala Sekolah Al-Khansa Edu Kids, Sukabumi)
5. Miftah Subarkah
6. Moh Agung Gunawan
7. Muhamad Ilham
8. Muhammad Giat A Shiddiiq
9. Ryan Al Fatih
10. Sigit Senjaya
11. Yadi Abdullah
```

---

## 📋 Daftar Amalan (DEFAULT_AMALAN)

| ID | Nama | Kategori | Catatan |
|---|---|---|---|
| `ql` | QL minimal 5 Rokaat | Malam | Qiyamul Lail |
| `subuh` | Sholat Subuh | Sholat | |
| `dzikir_pagi` | Dzikir Pagi | Pagi | Setelah Subuh |
| `duha` | Sholat Duha | Pagi | Reminder bertahap |
| `puasa_senin_kamis` | Puasa Senin Kamis | Puasa | Muncul Senin & Kamis saja |
| `dzuhur` | Sholat Dzuhur | Sholat | |
| `ashar` | Sholat Ashar | Sholat | |
| `dzikir_sore` | Dzikir Sore | Sore | Setelah Ashar |
| `kahfi` | Baca Al Kahfi | Tilawah | Muncul Jumat saja |
| `maghrib` | Sholat Maghrib | Sholat | |
| `isya` | Sholat Isya | Sholat | |
| `infaq` | Infaq | Amal | Reminder ikut sholat |
| `1juz` | Tilawah 1 Juz | Tilawah | Ada progress bar halaman |
| `earlybird` | Early Bird | Pagi | Bangun sebelum Subuh |
| `olahraga` | Olah Raga 30 menit | Sehat | |

---

## 🗄️ Yang Perlu Dikerjakan (Prioritas)

### 1. Integrasi Supabase (UTAMA)

Tujuan: data checklist tersimpan ke cloud, bukan hanya localStorage.

**Schema database yang dibutuhkan:**

```sql
-- Tabel users (anggota)
CREATE TABLE users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nama_lengkap TEXT NOT NULL,           -- dari list resmi
  nama_panggilan TEXT,                   -- isi sendiri
  grup TEXT DEFAULT 'Jenggot Merah',
  device_id TEXT,                        -- fingerprint device
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Tabel daily_checkin (data mutabaah harian)
CREATE TABLE daily_checkin (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  tanggal DATE NOT NULL,
  amalan_id TEXT NOT NULL,               -- e.g. 'subuh', 'duha', dll
  checked BOOLEAN DEFAULT false,
  checked_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, tanggal, amalan_id)
);

-- Tabel tilawah_progress
CREATE TABLE tilawah_progress (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  tanggal DATE NOT NULL,
  halaman INT DEFAULT 0,
  UNIQUE(user_id, tanggal)
);
```

**Flow yang diinginkan:**
1. User buka app → pilih nama dari list → isi nama panggilan → terkunci di device
2. Setiap centang amalan → simpan ke Supabase + localStorage (offline fallback)
3. Saat online → sync data localStorage ke Supabase

### 2. Fitur Komunitas Anonim

Tampilkan di app (tab baru atau section di checklist):
```
🕌 Subuh      ████████░░  9/11 anggota
🌤️ Duha       ██████░░░░  6/11 anggota
📖 Tilawah    ███░░░░░░░  3/11 anggota
```
- Tanpa nama, hanya angka
- Real-time dari Supabase
- Update tiap 5 menit atau saat app dibuka

### 3. Admin Dashboard

- Login dengan password khusus (simpan di Supabase atau env)
- Bisa lihat:
  - Rekap semua anggota per hari
  - Grafik pencapaian per amalan (bar/line chart)
  - Streak terpanjang per anggota
  - Export laporan (CSV/teks)
- Akses via URL khusus atau tombol tersembunyi di app

### 4. Fix Sistem Pilih Nama

- Nama hanya bisa dipilih SEKALI, setelah itu terkunci di device
- Tidak ada tombol "ganti nama" yang mudah diakses
- Kalau mau ganti harus clear localStorage manual

---

## 🔧 Detail Teknis Penting

### Struktur State (localStorage)
```javascript
// Key: mutabaah_v2_{nama_lowercase}
{
  checked: { "2026-06-05": { "subuh": 1717545600000, "duha": 1717548000000 } },
  history: { "2026-06-04": { "subuh": true, "duha": false } },
  tilawah: { "2026-06-05": 8 },  // halaman sudah dibaca
  settings: {
    lat: -6.92, lon: 106.93,
    city: "Sukabumi",
    reminderMin: 15,
    duhaInterval: 30,
    togPagi: true, togSore: true, togAdzan: false,
    amalanEnabled: { "subuh": true, "duha": true, ... }
  },
  streak: 3
}
```

### Multi-user (localStorage)
```javascript
localStorage.getItem('mutabaah_users')      // array nama ["Ihsan", "Yadi"]
localStorage.getItem('mutabaah_active_user') // nama aktif "Ihsan"
localStorage.getItem('mutabaah_v2_ihsan_faturohman') // data user Ihsan
```

### Waktu Sholat
Data hardcode Kemenag Sukabumi Juni 2026 ada di variabel `PRAYER_DB` di dalam HTML.
Format: `"2026-06-05": ["04:37","11:53","15:15","17:45","18:59"]`
Urutan: Subuh, Dzuhur, Ashar, Maghrib, Isya

### Netlify Deploy
- Drag & drop `mutabaah.html` ke dashboard Netlify
- Link tetap sama setelah update
- Tidak ada build process, pure static

---

## 📦 Supabase Setup yang Dibutuhkan

1. Buat project baru di supabase.com
2. Jalankan SQL schema di atas di SQL Editor
3. Enable Row Level Security (RLS):
   - `daily_checkin`: user hanya bisa baca/tulis data miliknya
   - `users`: semua bisa baca (untuk fitur komunitas anonim), hanya bisa update miliknya
4. Ambil `Project URL` dan `anon key` dari Settings → API
5. Masukkan ke app

---

## 🗒️ Catatan Owner

- **Ihsan Faturohman** = owner & developer (dibantu Claude)
- Lokasi: Sukabumi, Jawa Barat
- Jabatan: Kepala Sekolah Al-Khansa Edu Kids + aktif di FIDIN
- Preferensi: modular, scalable, tidak ribet untuk user awam
- HP anggota: mayoritas Android, Chrome browser
- Koneksi: tidak selalu stabil → offline-first penting
- Bahasa UI: Indonesia (non-formal, friendly)

---

## 🚀 Langkah Selanjutnya di Claude Code

1. **Minta Ihsan paste Supabase URL + anon key**
2. **Buat file terpisah** atau tetap single-file? → Rekomendasinya tetap single-file untuk kemudahan deploy Netlify
3. **Mulai dari integrasi Supabase** → schema → koneksi → sync checkin
4. **Lanjut komunitas anonim** → query aggregat per amalan per hari
5. **Admin dashboard** → bisa halaman terpisah `admin.html`

---

*Briefing dibuat: 5 Juni 2026 | Versi app: mutabaah-fidin-v2*

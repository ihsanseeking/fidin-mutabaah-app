# PRD — Mutabaah Fidin Jenggot Merah
**Product Requirements Document**  
Versi: 1.0 | Terakhir diperbarui: 2026-06-07  
Dibuat oleh: Ihsan Faturohman (PJ Mutabaah)

---

## 1. Latar Belakang

Kelompok kajian **FIDIN Jenggot Merah** di Sukabumi terdiri dari 11 anggota yang berkomitmen menjalankan amalan harian secara istiqomah. Selama ini pencatatan dilakukan manual (grup WhatsApp / kertas), sehingga sulit memantau konsistensi dan membuat laporan untuk Pembina.

**Mutabaah Fidin** hadir sebagai aplikasi web progresif (PWA) yang memudahkan setiap anggota mencatat amalan hariannya, dan memudahkan PJ serta Pembina memantau progres kelompok.

---

## 2. Tujuan Produk

| # | Tujuan | Indikator Keberhasilan |
|---|--------|------------------------|
| 1 | Anggota rutin mencatat amalan harian | ≥80% anggota aktif mengisi tiap hari |
| 2 | PJ dapat memantau progres tanpa repot | Laporan TXT tersedia 1-klik |
| 3 | Pembina dapat melihat detail & grafik | Grafik riwayat 30 hari per anggota |
| 4 | Data tersinkron antar device via cloud | Supabase sync real-time |
| 5 | Bisa dipakai offline | localStorage sebagai fallback |

---

## 3. Pengguna (User Personas)

### 3.1 Anggota FIDIN (Primary User)
- **Siapa**: 11 anggota tetap kelompok kajian
- **Kebutuhan**: Catat amalan harian dengan cepat dari HP
- **Pain point**: Lupa isi, tidak ada reminder visual, tidak bisa lihat progress sendiri

### 3.2 PJ Mutabaah
- **Siapa**: Penanggung jawab mutabaah, 1 orang
- **Kebutuhan**: Pantau siapa yang aktif/tidak, set target grup, download laporan mingguan untuk Pembina
- **Pain point**: Harus tanya satu-satu, rekap manual tiap pekan

### 3.3 Pembina
- **Siapa**: Ustadz / pembina kelompok, 1 orang
- **Kebutuhan**: Lihat detail amalan per anggota, grafik perkembangan, laporan CSV
- **Pain point**: Tidak bisa lihat data mentah, hanya dapat ringkasan dari PJ

### 3.4 Tamu / Non-anggota
- **Siapa**: Orang yang ingin mencoba aplikasi
- **Kebutuhan**: Coba fitur tanpa daftar
- **Batasan**: Data hanya di localStorage, tidak sync ke cloud

---

## 4. Fitur Utama

### 4.1 Modul Checkin Harian (Anggota)

#### F-01: Login & Identitas
- Pilih nama dari 11 anggota FIDIN (tidak bisa ketik bebas)
- Nama dikunci ke device setelah dipilih pertama kali
- Mode Tamu: input nama bebas, data hanya localStorage
- Logo diklik 5× untuk buka halaman admin

#### F-02: Daftar Amalan (24 amalan)
| Kategori | Amalan |
|----------|--------|
| Sholat Malam | QL / Sholat Malam (Tahajud + Witir sub-counter) |
| Subuh | Early Bird Subuh, Qobliyah Subuh, Sholat Subuh |
| Pagi | Dzikir Pagi, Sholat Duha |
| Dzuhur | Early Bird, Qobliyah, Sholat, Ba'diyah Dzuhur |
| Ashar | Early Bird Ashar, Sholat Ashar |
| Sore | Dzikir Sore, Baca Al-Kahfi |
| Maghrib | Early Bird, Sholat, Ba'diyah Maghrib |
| Isya | Early Bird, Sholat, Ba'diyah Isya |
| Amal | Infaq |
| Tilawah | Tilawah (target 1 Juz/hari, boleh lebih) |
| Puasa | Puasa Senin-Kamis |
| Sehat | Olahraga 30 menit |

#### F-03: QL Sub-counter
- Tahajud: +2 atau +4 rokaat
- Witir: +1 atau +3 rokaat
- QL otomatis ter-centang jika total rokaat ≥5 AND witir sudah dilakukan

#### F-04: Tilawah Counter
- Satuan: halaman (1 Juz = 20 hal default, bisa dikonfigurasi)
- Display: `X Juz + Y hal` jika melebihi 1 Juz
- Tidak ada batas atas (boleh > 1 Juz)

#### F-05: Target Grup (★ Badge)
- PJ bisa set amalan mana yang jadi target prioritas grup
- Target ditandai ★ di checklist anggota
- Disimpan di localStorage admin

#### F-06: Tab Komunitas
- Progress anonim seluruh anggota (tidak ada nama, hanya %)
- Challenger: amalan yang paling banyak diselesaikan bersama
- Pencapaian Top 3 anggota terbaik (anonim)

#### F-07: Sync Cloud
- Setiap centang/uncentang langsung sync ke Supabase
- Saat offline, data tersimpan di localStorage
- Saat online kembali, auto bulk-sync semua pending

### 4.2 Modul Admin

#### F-08: Akses Admin
- URL: `/admin.html`
- Akses tersembunyi: klik logo 5× di app utama
- Dua role dengan password berbeda

#### F-09: Role PJ Mutabaah (`fidin2026`)
- Lihat daftar anggota dengan progress % (Harian / Pekanan / Bulanan / Custom)
- Statistik ringkasan: total aktif, rata-rata %, anggota terbaik
- Download laporan TXT (format ringkasan untuk Pembina)
- Kelola target grup (centang amalan prioritas)

#### F-10: Role Pembina (`pembina2026`)
- Semua fitur PJ +
- Tabel detail amalan per anggota per tanggal
- Grafik riwayat 30 hari (bar chart % harian)
- Riwayat per-amalan per anggota (tabel detail)
- Download laporan CSV (raw data)

#### F-11: Date Range
- Harian (default: hari ini)
- Pekanan (pekan berjalan, 7 hari)
- Bulanan (bulan berjalan)
- Custom (pilih tanggal mulai-selesai)

---

## 5. Arsitektur Teknis

### 5.1 Tech Stack

| Layer | Teknologi |
|-------|-----------|
| Frontend | HTML5 + CSS3 + Vanilla JS (single file PWA) |
| Hosting | Netlify (static) |
| Database | Supabase (PostgreSQL) |
| Auth | Tidak ada akun — identitas by device_id + nama |
| Offline | localStorage sebagai primary store + fallback |
| Sync | Supabase JS SDK v2 (CDN) |

### 5.2 Prinsip Desain
- **Offline-first**: localStorage selalu diperbarui duluan, Supabase sync async
- **Single-file**: semua CSS dan JS inline di `mutabaah.html`
- **Device-locked identity**: `device_id` tersimpan di localStorage, dikaitkan ke 1 user di DB
- **No duplicate user**: saat login, cek by device → cek by nama → baru buat baru

### 5.3 Deployment
- `mutabaah.html` → deploy sebagai `/index.html` di Netlify
- `admin.html` → deploy sebagai `/admin.html`
- Deploy via Netlify Files API (PowerShell script, SHA1-based)

---

## 6. Non-Functional Requirements

| # | Requirement |
|---|-------------|
| NFR-01 | Load time < 3 detik pada koneksi 4G |
| NFR-02 | Bekerja offline (localStorage fallback) |
| NFR-03 | Responsive: mobile-first, support layar 360px+ |
| NFR-04 | Password admin tidak disimpan di Supabase |
| NFR-05 | Data anggota tidak bisa dilihat anggota lain (kecuali komunitas anonim) |

---

## 7. Out of Scope (v1.0)

- Push notification / reminder harian
- Login dengan akun Google / email
- Multi-grup (satu app untuk banyak kelompok kajian)
- Edit data retroaktif oleh PJ
- Sync target grup ke Supabase (saat ini hanya localStorage admin)

---

## 8. Roadmap

| Versi | Fitur |
|-------|-------|
| v1.0 (sekarang) | Checkin, sync cloud, admin PJ+Pembina, grafik |
| v1.1 | Notifikasi/reminder harian via browser |
| v1.2 | Target grup tersinkron ke semua anggota via Supabase |
| v2.0 | Multi-grup, admin manajemen anggota |

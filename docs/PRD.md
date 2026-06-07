# PRD — Mutabaah Fidin Jenggot Merah
**Product Requirements Document**  
Versi: 1.1 | Terakhir diperbarui: 2026-06-07  
Dibuat oleh: Ihsan Faturohman (PJ Mutabaah)

---

## Changelog

| Versi | Tanggal | Perubahan |
|-------|---------|-----------|
| 1.0 | 2026-06-07 | Rilis awal |
| 1.1 | 2026-06-07 | Tambah olahraga progressive, dzikir customizable, sistem iqob, social motivation inline, QL sub-split, qobliyah maghrib, Sholat Jumat, multi-device sync by name, admin remember role, perbaikan tampilan PJ/Pembina/Settings/Laporan |

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
| 4 | Data tersinkron antar device via cloud | Supabase sync real-time, identitas by nama |
| 5 | Bisa dipakai offline | localStorage sebagai fallback |
| 6 | Motivasi sosial mendorong konsistensi | Jumlah anonim peserta per amalan tampil inline |

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
- **Multi-device sync**: `user_id` disimpan dan diidentifikasi berdasarkan nama anggota, bukan `device_id` — sehingga satu anggota bisa login di beberapa device dan datanya tetap tersinkron
- Mode Tamu: input nama bebas, data hanya localStorage
- Logo diklik 5× untuk buka halaman admin

#### F-02: Daftar Amalan
| Kategori | Amalan | Keterangan |
|----------|--------|------------|
| Sholat Malam | QL Auto | Tercentang otomatis jika Tahajud + Witir memenuhi syarat |
| Sholat Malam | — Tahajud (sub-row) | +2 atau +4 rokaat |
| Sholat Malam | — Witir (sub-row) | +1 atau +3 rokaat |
| Subuh | Early Bird Subuh | |
| Subuh | Qobliyah Subuh | |
| Subuh | Sholat Subuh | |
| Pagi | Dzikir Pagi | |
| Pagi | Sholat Duha | |
| Dzuhur | Early Bird Dzuhur | |
| Dzuhur | Qobliyah Dzuhur | |
| Dzuhur | Sholat Dzuhur | |
| Dzuhur | Ba'diyah Dzuhur | |
| Ashar | Early Bird Ashar | |
| Ashar | Sholat Ashar | |
| Sore | Dzikir Sore | |
| Sore | Baca Al-Kahfi | |
| Maghrib | Early Bird Maghrib | |
| Maghrib | Qobliyah Maghrib | *(baru di v1.1)* |
| Maghrib | Sholat Maghrib | |
| Maghrib | Ba'diyah Maghrib | |
| Isya | Early Bird Isya | |
| Isya | Sholat Isya | |
| Isya | Ba'diyah Isya | |
| Jumat | Sholat Jumat | Hanya muncul pada hari Jumat |
| Amal | Infaq | |
| Tilawah | Tilawah | Target 1 Juz/hari, boleh lebih |
| Puasa | Puasa Senin-Kamis | |
| Sehat | Olahraga | Progressive minutes counter, target 30 menit |
| Dzikir | Istighfar | Counter, target set oleh PJ |
| Dzikir | Sholawat | Counter, target set oleh PJ |
| Dzikir | Tasbih | Counter, target set oleh PJ |

#### F-03: QL Sub-split
- **QL Auto**: row utama, tercentang otomatis — tidak bisa dicentang manual
- **Tahajud** (sub-row, indented): tombol +2 / +4 rokaat, menampilkan total rokaat
- **Witir** (sub-row, indented): tombol +1 / +3 rokaat, menampilkan total rokaat
- Kondisi QL otomatis tercentang: total Tahajud ≥ 2 rokaat AND Witir sudah dilakukan (≥ 1 rokaat)

#### F-04: Tilawah Counter
- Satuan: halaman (1 Juz = 20 hal default, bisa dikonfigurasi)
- Display: `X Juz + Y hal` jika melebihi 1 Juz
- Tidak ada batas atas (boleh > 1 Juz)

#### F-05: Olahraga Progressive (v1.1)
- Input berupa **minutes counter** (tambah/kurang menit), bukan checkbox
- Target default: **30 menit**
- Amalan dianggap selesai jika menit ≥ target
- Progress bar atau indikator visual menunjukkan menit saat ini vs target
- Target dapat diubah oleh PJ melalui panel admin

#### F-06: Dzikir Customizable (v1.1)
- Tiga jenis dzikir: **Istighfar**, **Sholawat**, **Tasbih**
- Masing-masing memiliki **counter** (tombol + / -)
- **Target per dzikir** di-set oleh PJ di panel admin (misal: istighfar 100x, sholawat 100x, tasbih 33x)
- Amalan dianggap selesai jika count ≥ target
- Target grup dzikir bisa berbeda-beda per jenis

#### F-07: Sistem Iqob (v1.1)
- Jika anggota **tidak mencapai target** amalan tertentu di hari itu, timbul **hutang iqob** (misal: pushup)
- Jumlah iqob dihitung berdasarkan amalan target grup yang tidak terpenuhi
- **Carry-over**: iqob yang belum dibayar di hari sebelumnya terakumulasi ke hari berikutnya
- Anggota dapat menandai iqob sebagai sudah dilunasi
- PJ dapat mengkonfigurasi: amalan mana yang memicu iqob dan berapa unit per miss

#### F-08: Social Motivation per Amalan (v1.1)
- Di bawah setiap amalan dalam checklist, tampil **jumlah anonim** anggota yang sudah menyelesaikan amalan tersebut hari ini
- Format: `👥 X orang sudah` (tanpa nama)
- Data diambil dari Supabase secara real-time
- Tidak ada nama yang ditampilkan — hanya jumlah

#### F-09: Target Grup (★ Badge)
- PJ bisa set amalan mana yang jadi target prioritas grup
- Target ditandai ★ di checklist anggota
- Konfigurasi target tersimpan di Supabase (sync ke semua device)

#### F-10: Tab Komunitas
- Progress anonim seluruh anggota (tidak ada nama, hanya %)
- Challenger: amalan yang paling banyak diselesaikan bersama
- Pencapaian Top 3 anggota terbaik (anonim)

#### F-11: Sync Cloud
- Setiap centang/uncentang / counter update langsung sync ke Supabase
- Saat offline, data tersimpan di localStorage
- Saat online kembali, auto bulk-sync semua pending

#### F-12: Sholat Jumat (v1.1)
- Amalan **Sholat Jumat** hanya muncul dalam daftar checklist pada **hari Jumat**
- Pada hari lain, amalan ini tidak ditampilkan dan tidak dihitung dalam target

### 4.2 Modul Admin

#### F-13: Akses Admin
- URL: `/admin.html`
- Akses tersembunyi: klik logo 5× di app utama
- Dua role dengan password berbeda
- **Remember role**: setelah login, role tersimpan di localStorage sehingga tidak perlu login ulang saat membuka admin kembali di device yang sama

#### F-14: Role PJ Mutabaah (`fidin2026`)
- Lihat daftar anggota dengan progress % (Harian / Pekanan / Bulanan / Custom)
- **Progress view hanya menampilkan amalan yang merupakan target grup** — amalan non-target tidak ditampilkan di view PJ
- Statistik ringkasan: total aktif, rata-rata %, anggota terbaik
- Download laporan TXT (format ringkasan untuk Pembina)
- Kelola target grup: centang amalan prioritas, set target hitungan dzikir, set target menit olahraga
- Konfigurasi sistem iqob (amalan pemicu + unit iqob)

#### F-15: Role Pembina (`pembina2026`)
- Semua fitur PJ +
- Tabel detail amalan per anggota per tanggal
- Grafik riwayat 30 hari (bar chart % harian)
- Riwayat per-amalan per anggota (tabel detail)
- Download laporan CSV (raw data)
- **Target grup default**: tampilan default menggunakan filter target grup; tersedia **toggle "Tampilkan Semua"** untuk melihat semua amalan

#### F-16: Date Range
- Harian (default: hari ini)
- Pekanan (pekan berjalan, 7 hari)
- Bulanan (bulan berjalan)
- Custom (pilih tanggal mulai-selesai)

### 4.3 Modul Settings (Anggota)

#### F-17: Halaman Pengaturan
- Konfigurasi pribadi anggota: ukuran Juz tilawah (halaman per Juz)
- **Amalan target grup bersifat locked (non-toggleable)**: anggota tidak dapat menyembunyikan atau menonaktifkan amalan yang sudah ditetapkan sebagai target grup oleh PJ
- Amalan non-target dapat di-toggle tampil/sembunyi sesuai preferensi pribadi

### 4.4 Modul Laporan (Anggota)

#### F-18: Laporan Mandiri Anggota
- Anggota dapat melihat ringkasan progres diri sendiri
- **Laporan hanya menampilkan amalan target grup** — konsisten dengan fokus kelompok
- Grafik sederhana atau persentase pencapaian per periode

---

## 5. Arsitektur Teknis

### 5.1 Tech Stack

| Layer | Teknologi |
|-------|-----------|
| Frontend | HTML5 + CSS3 + Vanilla JS (single file PWA) |
| Hosting | Netlify (static) |
| Database | Supabase (PostgreSQL) |
| Auth | Tidak ada akun — identitas by nama anggota (user_id linked to nama) |
| Offline | localStorage sebagai primary store + fallback |
| Sync | Supabase JS SDK v2 (CDN) |

### 5.2 Prinsip Desain
- **Offline-first**: localStorage selalu diperbarui duluan, Supabase sync async
- **Single-file**: semua CSS dan JS inline di `mutabaah.html`
- **Name-based identity**: `user_id` dikaitkan ke nama anggota, bukan device — memungkinkan multi-device sync per orang
- **No duplicate user**: saat login, cek by nama → gunakan `user_id` yang ada → tidak buat baru jika nama sudah terdaftar

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
| NFR-05 | Data anggota tidak bisa dilihat anggota lain (kecuali komunitas anonim & social count) |
| NFR-06 | Social count anonim tidak mengekspos nama anggota |
| NFR-07 | Iqob carry-over tidak hilang saat refresh/offline |

---

## 7. Out of Scope (v1.1)

- Push notification / reminder harian
- Login dengan akun Google / email
- Multi-grup (satu app untuk banyak kelompok kajian)
- Edit data retroaktif oleh PJ
- Pelunasan iqob diverifikasi oleh PJ (saat ini self-reported)

---

## 8. Roadmap

| Versi | Fitur |
|-------|-------|
| v1.0 | Checkin, sync cloud, admin PJ+Pembina, grafik |
| v1.1 (sekarang) | Olahraga progressive, dzikir customizable, sistem iqob, social motivation inline, QL sub-split, qobliyah maghrib, Sholat Jumat, multi-device sync by name, admin remember role, filter target grup per role, settings locked target, laporan target grup |
| v1.2 | Notifikasi/reminder harian via browser |
| v2.0 | Multi-grup, admin manajemen anggota |

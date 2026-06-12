# Mutabaah Fidin Jenggot Merah

Aplikasi web progresif (PWA) untuk pencatatan amalan harian kelompok kajian FIDIN Jenggot Merah, Sukabumi.

🔗 **Live App**: https://fidin-mutabaah-app.pages.dev  
🔐 **Admin PJ**: https://fidin-mutabaah-app.pages.dev/admin.html  

## Fitur
- ✅ Checklist 24 amalan harian
- 🌙 QL sub-counter (Tahajud + Witir)
- 📖 Tilawah tracker (> 1 Juz)
- ☁️ Sync cloud via Supabase (offline-first)
- 👥 Tab komunitas (progress anonim)
- 📊 Admin dashboard: PJ (progres) + Pembina (detail + grafik)
- 📥 Download laporan TXT / CSV

## Dokumen
- [`docs/PRD.md`](docs/PRD.md) — Product Requirements Document
- [`docs/ERD.md`](docs/ERD.md) — ERD & Database Schema

## Tech Stack
- **Frontend**: Vanilla HTML/CSS/JS (single-file PWA)
- **Database**: Supabase (PostgreSQL)
- **Hosting**: Cloudflare Pages

## Struktur File
```
mutabaah.html   → App utama (deploy sebagai index.html)
admin.html      → Dashboard admin (PJ + Pembina)
docs/
  PRD.md        → Product Requirements Document
  ERD.md        → Entity Relationship Diagram
```

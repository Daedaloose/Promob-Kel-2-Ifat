# Project Context — Peaceful Mind

Dokumen ini mendokumentasikan keadaan proyek saat ini, arsitektur, repositori yang digunakan, dan rencana pekerjaan berikutnya.

---

## 📋 Detail Proyek & Repositori

1.  **Frontend (Aplikasi Flutter)**:
    *   **Nama Proyek**: Peaceful Mind (`com.example.testpromobkel`)
    *   **Repositori**: [Daedaloose/Promob-Kel-2-Ifat](https://github.com/Daedaloose/Promob-Kel-2-Ifat.git)
    *   **Status Git**: Terpaut ke `main` branch, semua perubahan terunggah (clean).
2.  **Backend (FastAPI Server)**:
    *   **Repositori**: [schrodingercato/promob-backend](https://github.com/schrodingercato/promob-backend.git)
    *   **Deployment**: Dihosting di **Vercel** secara online.
    *   **URL Online**: `https://promob-backend.vercel.app`
    *   **Database**: SQLite (menyimpan di `/tmp/users.db` ketika dideploy di Vercel).
    *   **Status Git**: Terpaut ke `main` branch, semua perubahan terunggah (clean).
3.  **Firebase Project**:
    *   **Project ID**: `peaceful-mind-b5b66`
    *   **Metode Login**: Google & Apple Sign-In diaktifkan.

---

## 🛠️ Ringkasan Pekerjaan yang Baru Saja Dilakukan

1.  **Menyelesaikan Masalah Python & Pip Lokal**:
    *   Mengidentifikasi bahwa pemanggilan `python` merujuk ke MSYS2 yang tidak memiliki `pip`.
    *   Mengalihkan ke Python Launcher resmi Windows (`py`) untuk menginstal library backend.
    *   Sukses menginstal: `fastapi`, `uvicorn`, `sqlalchemy`, `firebase-admin`.
2.  **Menyiapkan Backend untuk Deployment Cloud**:
    *   Membuat file `vercel.json` untuk konfigurasi serverless routing Vercel.
    *   Membuat file `api/index.py` sebagai pintu masuk utama (entrypoint) Vercel.
    *   Memperbarui `database.py` agar menggunakan `/tmp/` ketika mendeteksi lingkungan Vercel guna menghindari error *Read-only file system*.
    *   Menambahkan file `.gitignore` untuk mengabaikan `__pycache__`, file database lokal (`.db`), dan kredensial rahasia (`serviceAccountKey.json`).
3.  **Deploy Online**:
    *   Menginisialisasi Git di folder `promob-backend/` lokal dan menghubungkannya ke repositori GitHub baru.
    *   Melakukan commit dan force-push seluruh kode backend ke GitHub.
    *   Aplikasi backend otomatis terdeploy di Vercel dan dapat diakses publik di `https://promob-backend.vercel.app`.
4.  **Menghubungkan Aplikasi Flutter**:
    *   Mengubah variabel `backendUrl` di [auth_service.dart](file:///c:/Users/Aisyah R. Nadjib/Downloads/Semester 4/Program Bergerak/Promob-Kel-2-Ifat/lib/services/auth_service.dart) dari `http://10.0.2.2:8000` (lokal) menjadi `https://promob-backend.vercel.app` (online Vercel).
    *   Melakukan commit dan push semua perubahan di folder Flutter ke repositori utama `Daedaloose/Promob-Kel-2-Ifat`.

---

## 🔮 Rencana Pekerjaan Selanjutnya (Next TODOs)

Berdasarkan struktur UI/UX aplikasi Flutter saat ini, fitur-fitur berikut masih berjalan secara lokal/mocking dan **belum terintegrasi** dengan database atau API luar:

1.  **Integrasi Fitur Jurnal (Journal)**:
    *   **Kondisi Saat Ini**: Jurnal pada `journal_screen.dart` masih berupa data statis (hardcoded) di memori aplikasi. Menekan tombol tambah jurnal belum menyimpan data secara permanen.
    *   **Rencana**:
        *   Buat tabel `journals` di database backend (FastAPI).
        *   Buat API endpoint di backend: `GET /api/journals` (mengambil riwayat jurnal milik user bersangkutan) dan `POST /api/journals` (membuat jurnal baru).
        *   Integrasikan UI Flutter `journal_screen.dart` dengan API tersebut.
2.  **Integrasi AI Chat & Asisten Psikologi**:
    *   **Kondisi Saat Ini**: Chatbot di `ai_chat_screen.dart` masih menggunakan deteksi kata kunci lokal sederhana (seperti mendeteksi kata "capek" atau "takut") dan membalas secara kaku.
    *   **Rencana**:
        *   Hubungkan aplikasi dengan API AI seperti **Google Gemini API** atau **Circadify AI**.
        *   Buat endpoint di backend `POST /api/chat` yang meneruskan pesan user ke AI, lalu mengembalikan respon cerdas.
        *   Gunakan SDK API Key yang disimpan aman di environment variable Vercel backend (bukan di dalam Flutter APK demi keamanan).
3.  **Integrasi Mood & Stats (Statistik Mood)**:
    *   **Kondisi Saat Ini**: Statistik di `stats_screen.dart` dan deteksi di `mood_detection_screen.dart` masih berjalan dengan data demo/statis.
    *   **Rencana**:
        *   Buat endpoint di backend untuk menyimpan data deteksi mood harian.
        *   Tarik data tersebut untuk ditampilkan dalam grafik mingguan/bulanan di `stats_screen.dart`.
4.  **Pembuatan File APK Rilis**:
    *   Membuat file penandatanganan aplikasi `key.jks`.
    *   Mendaftarkan SHA-1 rilis ke Firebase Console agar Google Sign-In tetap bekerja di HP orang lain.
    *   Menghasilkan `.apk` rilis final menggunakan `flutter build apk --release`.

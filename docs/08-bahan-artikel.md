# Bahan Artikel Website

Kerangka dan draf siap sunting, diambil dari dokumen [01](01-instalasi-ollama.md)–[06](06-laporan-validasi.md).
Silakan pangkas atau ubah gaya bahasanya sesuai website.

---

## Pilihan judul

1. **Punya Agen AI Pribadi di Telegram Tanpa GPU: Hermes Agent + Model Cloud Ollama**
2. Laptop Biasa Jalankan Agen AI: Panduan Hermes Agent dengan Ollama Cloud
3. "Model Not Found" Padahal Bot Jalan: Pelajaran dari Merapikan Konfigurasi Agen AI

**Kata kunci SEO:** hermes agent, ollama cloud, gemma 4, agen ai telegram, ai agent tanpa gpu,
ollama openai compatible, tool calling ollama, hermes agent ollama, self-hosted ai agent.

**Ringkasan (meta description, ±155 karakter):**
Cara memasang Hermes Agent dengan model cloud Ollama (Gemma 4) di laptop biasa, terhubung ke Telegram,
plus cara mendeteksi dan memperbaiki error model 404.

---

## Draf artikel

### Pembuka

Agen AI tidak sekadar chatbot. Ia bisa menjalankan perintah di komputer, membaca dan menulis file,
mencari di web, dan bekerja terjadwal. Masalahnya, model AI yang cukup pintar untuk itu biasanya butuh
GPU mahal dan unduhan puluhan gigabyte, atau API berbayar per token.

Kami memasang **Hermes Agent** (open source dari Nous Research) di sebuah laptop Fedora dengan RAM 15 GB,
tanpa GPU khusus. Modelnya **Gemma 4 31B** yang dijalankan di **cloud Ollama**, dan agennya bisa
diperintah lewat **Telegram**. Pemeriksaan dan perbaikannya dikerjakan bersama **Claude Code**, agen AI
yang bekerja di terminal.

### Cara kerjanya

```
Telegram / terminal → Hermes Agent → Ollama (di laptop) → model di cloud
```

- **Hermes Agent** adalah "otak" yang memutuskan langkah dan memakai tool.
- **Ollama** di laptop hanya perantara. API-nya tetap `localhost:11434`, sehingga Hermes tidak perlu
  tahu bahwa modelnya di cloud dan tidak perlu API key.
- **Model `gemma4:31b-cloud`** berjalan di server Ollama, jadi tidak memakai RAM atau GPU laptop.

### Langkah 1: Pasang Ollama dan daftarkan model cloud

```bash
curl -fsSL https://ollama.com/install.sh | sh
ollama signin
ollama pull gemma4:31b-cloud
```

Perintah `pull` di sini tidak mengunduh model. Di `ollama list`, kolom ukurannya hanya berisi tanda "–".

Sebelum lanjut, pastikan dua hal: model bisa menjawab, dan model bisa **memanggil tool**. Yang kedua
syarat wajib sebuah agen. Dalam uji kami, Gemma 4 menjawab dalam ±0,7 detik dan memanggil tool
`get_weather` dengan argumen kota yang benar.

### Langkah 2: Pasang Hermes Agent

```bash
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
```

Installer menyiapkan semuanya di folder `~/.hermes`: Python terisolasi, Node.js, dan perintah `hermes`.

### Langkah 3: Arahkan Hermes ke Ollama

Di `~/.hermes/config.yaml`, cukup tiga baris:

```yaml
model:
  default: "gemma4:31b-cloud"
  provider: "custom"
  base_url: "http://localhost:11434/v1"
```

Lalu jalankan gateway Telegram dan agen siap diperintah dari HP.

### Masalah: error 404, padahal Telegram jalan

Saat diperiksa, perintah `hermes` di terminal selalu gagal:

```
HTTP 404: model '<model-agregator>' not found
```

Anehnya, bot Telegram tetap menjawab. Penyebabnya ada dua:

1. **Ada dua nama model di blok yang sama.** Hermes menerima kunci `default:` maupun `model:`. Di config
   tersisa `default:` berisi model dari provider lain yang tidak ada di Ollama, dan `model:` berisi Gemma 4.
   Yang menang `default:`, jadi yang dipakai justru yang salah.
2. **Telegram selamat karena kebetulan.** Sesi Telegram pernah diganti modelnya dengan `/model`, dan
   pengaturan itu tersimpan per sesi. Begitu sesi baru dibuat dengan `/new`, bot akan ikut error.

> **Tips:** Selalu uji agen dengan sesi baru, misalnya `hermes -z "pertanyaan"` **tanpa** opsi `-m`.
> Sesi lama bisa menyembunyikan config yang rusak.

### Langkah 4: Bersihkan config

Config dicadangkan dulu ke `~/.hermes/backups/`, lalu:

- `default:` diganti `gemma4:31b-cloud`, dan kunci `model:` ganda dihapus;
- `api_key:` di blok model dihapus. Ollama lokal tidak memerlukannya, dan key milik provider lain tidak
  seharusnya ikut terkirim ke mana-mana;
- provider lama dikosongkan dari config, `.env`, dan daftar kredensial;
- gateway direstart dengan `hermes gateway restart`.

### Langkah 5: Satu skrip untuk memeriksa semuanya

Kami menulis `cek-kesehatan.sh` yang memeriksa seluruh rantai: Ollama hidup, model terdaftar, model
menjawab, tool calling jalan, config benar, Hermes menjawab tanpa `-m`, Hermes bisa membaca file lewat
tool, dan gateway aktif.

```
Hasil: 9 lulus, 0 gagal
```

Skrip ini bisa dijalankan ulang setiap kali Hermes atau Ollama diperbarui.

### Bonus: sesi panjang itu boros

Setiap pesan mengirim ulang seluruh riwayat percakapan. Sesi Telegram kami sudah 142 pesan, sehingga
pertanyaan sesederhana "uptime laptop berapa jam" mengirim sekitar **108 ribu token**. Biasakan `/new`
untuk topik baru dan `/compress` untuk meringkas sesi panjang. Kuota cloud jadi jauh lebih awet.

### Penutup

**Hasil akhir:** agen AI pribadi yang bisa diperintah dari Telegram, memakai model 31 miliar parameter,
berjalan di laptop biasa tanpa GPU, dengan config yang bersih dan bisa diperiksa dalam satu perintah.

### Kotak info (sidebar)

| | |
|---|---|
| Perangkat | Laptop Fedora Linux 44, RAM 15 GB, tanpa GPU khusus |
| Perangkat lunak | Hermes Agent 0.21.6 (MIT), Ollama 0.40.8, Claude Code |
| Model | Gemma 4 31B (`gemma4:31b-cloud`): teks, thinking, tools, vision; konteks 262.144 token |
| Antarmuka | Telegram dan terminal |
| Biaya | Akun Ollama; pemakaian model cloud dibatasi kuota paket akun |
| Hasil cek kesehatan | 9 lulus, 0 gagal |

---

## Daftar gambar yang disarankan

Repo ini belum punya folder screenshot. Ambil gambar berikut, lalu **periksa dan blur** sebelum
dipublikasi: token, isi `.env`, ID atau nama akun Telegram, alamat IP, dan path home lengkap.

| Untuk bagian | Gambar | Cara mengambil |
|---|---|---|
| Pembuka | Chat Telegram dengan bot | Screenshot HP saat bot menjawab |
| Cara kerjanya | Diagram alur | Buat ulang diagram dari [README](../README.md) sebagai gambar |
| Langkah 1 | `ollama list` dengan SIZE "–" | Screenshot terminal |
| Langkah 1 | Uji tool calling | Output perintah di [02 § Uji](02-model-cloud-ollama.md#uji) |
| Langkah 3 | `hermes status` | Screenshot terminal (aman, tidak menampilkan key) |
| Masalah | Pesan error 404 | Buat ulang dari teks di [05](05-troubleshooting.md); jangan ubah config asli untuk memancing error |
| Langkah 4 | Blok `model:` sebelum/sesudah | Dua potongan kode berdampingan, bukan screenshot config utuh |
| Langkah 5 | Output `cek-kesehatan.sh` | Jalankan skrip lalu screenshot |

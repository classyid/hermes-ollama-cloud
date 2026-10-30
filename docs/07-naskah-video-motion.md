# Naskah & Storyboard Video Motion

Durasi target **±90 detik**, format **9:16** (Reels/TikTok/Shorts). Versi 16:9 untuk YouTube bisa memakai
adegan yang sama dengan tata letak melebar: terminal di kiri, diagram/hasil di kanan.

**Gaya visual:** motion graphic datar (flat), latar gelap seperti terminal. Aksen **hijau** untuk yang
berhasil (`[OK]`, centang), **merah** untuk error, putih untuk teks utama. Font tebal sans-serif untuk judul,
monospace untuk semua perintah, config, dan output terminal. Gelembung chat bergaya aplikasi pesan generik.

**Musik:** elektronik ringan, tempo sedang. Beat turun di adegan 7 (error 404), naik lagi di adegan 10
(9 lulus, 0 gagal).

Sumber data: [01](01-instalasi-ollama.md)–[06](06-laporan-validasi.md) dan
[`scripts/cek-kesehatan.sh`](../scripts/cek-kesehatan.sh).

---

## Adegan

| # | Waktu | Visual | Teks di layar | Narasi (VO) |
|---|---|---|---|---|
| 1 | 0–5 dtk | Layar HP: chat dengan bot. Pesan masuk "Uptime laptop berapa jam", bot langsung membalas | **Agen AI pribadi… di Telegram** | "Bayangkan punya agen AI sendiri yang bisa disuruh lewat Telegram." |
| 2 | 5–12 | Laptop dengan meter RAM merah; ikon kartu GPU dicoret; label unduhan "20 GB" dicoret | **Tanpa GPU. Tanpa unduh model raksasa.** | "Tapi laptop biasa tidak kuat menjalankan model AI besar. Jadi modelnya kami jalankan di cloud." |
| 3 | 12–20 | Diagram tersusun dari kiri ke kanan: ikon chat/terminal → kotak "Hermes Agent" → kotak "Ollama `localhost:11434`" → awan "gemma4:31b". Garis data mengalir | **Hermes → Ollama → Cloud** | "Rangkaiannya: Hermes Agent sebagai otak, Ollama di laptop sebagai perantara, dan modelnya di cloud." |
| 4 | 20–28 | Terminal mengetik tiga baris: `curl … ollama.com/install.sh \| sh`, `ollama signin`, `ollama pull gemma4:31b-cloud`. Lalu `ollama list`; kolom SIZE berisi `-` disorot | **Model cloud: ukurannya "–"** | "Pasang Ollama, login akun, lalu daftarkan model cloud. Tidak ada yang diunduh: ukurannya kosong." |
| 5 | 28–34 | Satu baris `curl … hermes-agent.nousresearch.com/install.sh \| bash`; folder `~/.hermes` terisi ikon `config.yaml`, `.env`, `logs` | **Hermes Agent: satu perintah** | "Hermes Agent juga cukup satu perintah instalasi." |
| 6 | 34–44 | Dua kartu bergantian. Kiri: pertanyaan "Ibukota Jawa Timur?" → jawaban "Surabaya" dengan stopwatch 0,7 dtk. Kanan: ikon kunci-pas "tool", muncul `get_weather(city: "Kediri")` dan label `finish_reason: tool_calls` | **Cepat. Dan bisa pakai tool.** | "Modelnya menjawab dalam kurang dari satu detik, dan bisa memanggil tool, syarat wajib sebuah agen." |
| 7 | 44–52 | Terminal `hermes -z "…"` → baris merah `HTTP 404: model '<model-agregator>' not found`. Di sampingnya HP Telegram masih centang hijau, lalu muncul tanda tanya | **Error 404… tapi Telegram jalan?** | "Tapi saat dicek, Hermes error: modelnya tidak ditemukan. Anehnya, Telegram tetap jalan." |
| 8 | 52–60 | Zoom ke blok `model:` di `config.yaml`: baris `default: "<model-agregator>"` dan `model: gemma4:31b:cloud` berdampingan; `default` menyala, `model` meredup. Lalu label kecil di HP: "override /model sesi ini" | **Dua nama model. Satu yang menang.** | "Ternyata ada dua nama model di config, dan yang dipakai justru yang salah. Telegram selamat karena sesinya punya pengaturan sendiri." |
| 9 | 60–68 | Ikon folder "backups" terisi dulu. Lalu baris-baris tersapu: `default` diganti `gemma4:31b-cloud`, `api_key:` dihapus, `custom_providers` menyusut jadi `[]`, kunci di `.env` hilang | **Backup dulu, lalu bersihkan** | "Config dicadangkan dulu, lalu dibersihkan: satu model, tanpa key yang tidak perlu, tanpa provider lama." |
| 10 | 68–78 | `hermes gateway restart`, lalu `cek-kesehatan.sh` berjalan: sembilan baris `[OK]` muncul satu per satu (Ollama, service, model, chat, tool calling, config, Hermes, tool lewat Hermes, gateway). Penutup: `Hasil: 9 lulus, 0 gagal` | **9 lulus, 0 gagal** | "Gateway direstart, lalu satu skrip memeriksa seluruh rantai. Sembilan pemeriksaan, semuanya lulus." |
| 11 | 78–84 | Penghitung token di gelembung chat: 142 pesan, angka 108.000 berdenyut; perintah `/new` diketik; angka turun drastis | **Sesi panjang = boros kuota. Ketik /new** | "Satu tips: sesi yang terlalu panjang mengirim ratusan ribu token. Mulai sesi baru supaya hemat." |
| 12 | 84–90 | Rekaman layar asli: chat Telegram dengan bot menjawab, lalu halaman repo dokumentasi bergulir (README → docs 01–07) | **Agen AI sendiri. Model cloud. Tanpa GPU.** · link repo | "Agen AI pribadi, model cloud, laptop biasa. Panduan lengkapnya ada di repo ini." |

---

## Aset yang dibutuhkan

| Aset | Sumber |
|---|---|
| Perintah instalasi Ollama & model cloud | [01-instalasi-ollama.md](01-instalasi-ollama.md), [02-model-cloud-ollama.md](02-model-cloud-ollama.md) |
| Output `ollama list` (SIZE `-`) | [02-model-cloud-ollama.md § Daftarkan model cloud](02-model-cloud-ollama.md#daftarkan-model-cloud) |
| Perintah instalasi Hermes, struktur `~/.hermes` | [03-instalasi-hermes.md](03-instalasi-hermes.md) |
| Contoh uji chat & tool calling (`get_weather`, Kediri) | [02-model-cloud-ollama.md § Uji](02-model-cloud-ollama.md#uji) |
| Pesan error 404, blok config sebelum/sesudah | [05-troubleshooting.md](05-troubleshooting.md), [06-laporan-validasi.md](06-laporan-validasi.md) |
| Output 9 baris `[OK]` | [06-laporan-validasi.md § Hasil setelah perbaikan](06-laporan-validasi.md#hasil-setelah-perbaikan) atau jalankan `scripts/cek-kesehatan.sh` lalu rekam layar |
| Angka sesi panjang (142 pesan, ±108 ribu token) | [06-laporan-validasi.md](06-laporan-validasi.md) masalah no. 5 |
| Rekaman chat Telegram | Rekam layar HP saat bertanya ke bot (blur nama akun & foto profil) |
| Rekaman repo | Rekam layar halaman README repo ini di browser |
| Logo | Logo Ollama/Nous Research/Telegram sebaiknya tidak dipakai sebagai logo; cukup sebut nama atau ikon generik (llama digantikan ikon awan, Telegram digantikan gelembung chat) |

## Catatan produksi

- **Jangan tampilkan** token, API key, isi `.env`/`auth.json`, ID chat Telegram, alamat IP, atau path
  home lengkap di layar mana pun. Pakai `~/.hermes` dan `<model-agregator>` seperti di dokumentasi.
- Saat merekam terminal asli, jalankan `hermes status` dan `cek-kesehatan.sh` saja; keduanya tidak
  menampilkan rahasia. Jangan membuka `config.yaml` utuh: tampilkan hanya blok `model:` yang sudah bersih.
- Angka di layar mengikuti hasil uji 30 Okt 2026: jawaban ±0,7 detik, context 262.144 token,
  9 lulus 0 gagal. Kalau merekam ulang dan angkanya berbeda, pakai angka hasil rekaman.
- Kredit di akhir video: "Hermes Agent (github.com/NousResearch/hermes-agent, lisensi MIT) · Ollama
  (ollama.com) · Model Gemma 4 · Dibantu Claude Code".
- Untuk versi 16:9, adegan 8 paling jelas jika dua sisi ditampilkan bersamaan: config yang salah di kiri
  (`default` menyala merah) dan config bersih di kanan (satu baris hijau).

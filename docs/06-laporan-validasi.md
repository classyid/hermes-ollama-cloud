# 6. Laporan validasi — 30 Oktober 2026

Pemeriksaan menyeluruh Hermes Agent + Ollama cloud di komputer kerja
(Fedora 44), termasuk perbaikan yang dilakukan.

## Kondisi awal

| Komponen | Hasil |
|---|---|
| Ollama 0.40.8 | Service aktif di `127.0.0.1:11434` |
| Model `gemma4:31b-cloud` | Menjawab benar dalam ±0,7 detik (login cloud valid) |
| Tool calling di Ollama | Lulus (`finish_reason: tool_calls`, argumen benar) |
| Hermes Agent 0.21.6 | Terpasang, `hermes doctor` lulus untuk Python, paket, database |
| Gateway Telegram | Berjalan, `connected` |
| **Hermes tanpa `-m`** | **GAGAL: `HTTP 404: model '<model-agregator>' not found`** |

## Masalah yang ditemukan

1. **Model default salah.** Blok `model:` berisi `default: "<model-agregator>"`
   (nama model milik provider agregator lain) sementara `base_url` mengarah
   ke Ollama lokal yang tidak punya model itu. Di blok yang sama juga ada
   `model: gemma4:31b:cloud` yang diabaikan karena `default:` menang.
   Akibat: sesi CLI baru, cron, dan chat Telegram baru error 404.
2. **Telegram jalan karena kebetulan.** Sesi Telegram yang aktif menyimpan
   override `/model gemma4:31b:cloud`, sehingga tidak memakai default yang
   rusak. `/new` akan membuat bot ikut error.
3. **API key provider lain ikut terkirim ke Ollama** (`api_key:` di blok
   model). Tidak berbahaya untuk Ollama lokal, tapi tidak perlu.
4. **Provider lama masih terdaftar** di `custom_providers` (format lama yang
   juga ditandai `hermes doctor`), beserta key-nya di `.env` dan entri
   credential pool di `auth.json`.
5. **Sesi Telegram sangat panjang:** 142 pesan, ±108 ribu token input per
   pertanyaan. Masih lancar karena cache, tapi boros kuota cloud.

## Perbaikan

Dengan backup di `~/.hermes/backups/` (config & .env) sebelum perubahan:

| Lokasi | Perubahan |
|---|---|
| `config.yaml` → `model.default` | `<model-agregator>` → `gemma4:31b-cloud` |
| `config.yaml` → blok model | Hapus `api_key:` dan `model:` ganda |
| `config.yaml` → `aliases` | `gemma4:31b:cloud` → `gemma4:31b-cloud` (seragam dengan `ollama list`) |
| `config.yaml` → `custom_providers` | Seluruh provider lama dihapus → `custom_providers: []` |
| `.env` | Hapus key provider lama |
| `auth.json` | Hapus entri credential pool provider lama |
| Gateway | `hermes gateway restart` |

## Hasil setelah perbaikan

`scripts/cek-kesehatan.sh`:

```
== 1. Ollama
  [OK]    API hidup {"version":"0.40.8"}
  [OK]    service ollama aktif
== 2. Model gemma4:31b-cloud
  [OK]    terdaftar di Ollama
  [OK]    chat cloud: Surabaya
  [OK]    tool calling berfungsi
== 3. Konfigurasi Hermes
  [OK]    blok model benar
== 4. Hermes end-to-end (tanpa -m)
  [OK]    hermes menjawab: Surabaya
  [OK]    tool calling lewat hermes
== 5. Gateway
  [OK]    hermes-gateway aktif
  [info]  telegram: connected

Hasil: 9 lulus, 0 gagal
```

`hermes status`: `Model: gemma4:31b-cloud`, `Provider: custom`,
`Gateway: running`, `Platforms: Telegram`.

## Rekomendasi lanjutan

- Kirim `/new` di Telegram untuk memulai sesi bersih (hemat kuota, jawaban
  lebih fokus). Sesi baru otomatis memakai `gemma4:31b-cloud`.
- Jalankan `scripts/cek-kesehatan.sh` setelah update Hermes/Ollama atau
  mengubah config.
- Pertimbangkan `hermes fallback add` agar ada cadangan saat Ollama cloud
  gangguan.
- `hermes update` untuk menutup peringatan kerentanan npm dari `hermes doctor`.

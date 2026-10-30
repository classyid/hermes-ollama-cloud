# Hermes Agent + Ollama Cloud

Dokumentasi instalasi dan konfigurasi **Hermes Agent** (Nous Research) yang
memakai **model cloud Ollama** (`gemma4:31b-cloud`) sebagai satu-satunya
penyedia model, di Fedora Linux.

```
 Telegram / CLI
       │
       ▼
 ┌──────────────┐   OpenAI-compatible API    ┌──────────────────┐   ┌──────────────┐
 │ Hermes Agent │ ─────────────────────────▶ │ Ollama (lokal)   │──▶│ Ollama Cloud │
 │  + gateway   │  http://localhost:11434/v1 │ 127.0.0.1:11434  │   │ gemma4:31b   │
 └──────────────┘                            └──────────────────┘   └──────────────┘
```

Hermes tidak perlu API key apa pun: ia bicara ke Ollama lokal, dan Ollama
lokal yang meneruskan ke cloud memakai akun ollama.com yang sudah `signin`.
Model tidak diunduh ke disk dan tidak memakai GPU/RAM lokal.

## Daftar isi

| No | Dokumen | Isi |
|---|---|---|
| 1 | [Instalasi Ollama](docs/01-instalasi-ollama.md) | Install, service systemd, cek API |
| 2 | [Model cloud Ollama](docs/02-model-cloud-ollama.md) | `ollama signin`, pull model cloud, uji chat & tool calling |
| 3 | [Instalasi Hermes Agent](docs/03-instalasi-hermes.md) | Installer resmi, struktur `~/.hermes`, `hermes doctor` |
| 4 | [Hermes memakai Ollama cloud](docs/04-hermes-ollama-cloud.md) | Konfigurasi `config.yaml`, gateway Telegram, ganti model |
| 5 | [Troubleshooting](docs/05-troubleshooting.md) | Error yang pernah terjadi dan solusinya |
| 6 | [Laporan validasi](docs/06-laporan-validasi.md) | Hasil pemeriksaan & perbaikan 30 Okt 2026 |
| 7 | [Naskah video motion](docs/07-naskah-video-motion.md) | Storyboard 12 adegan (±90 detik, 9:16), narasi, aset |

Skrip: [`scripts/cek-kesehatan.sh`](scripts/cek-kesehatan.sh) memeriksa seluruh
rantai (Ollama → model cloud → tool calling → konfigurasi Hermes → jawaban
Hermes → gateway) dalam satu perintah.

## Ringkasan cepat

```bash
# 1. Ollama
curl -fsSL https://ollama.com/install.sh | sh
ollama signin                       # login akun ollama.com
ollama pull gemma4:31b-cloud        # hanya mendaftarkan model cloud (tanpa unduh bobot)

# 2. Hermes Agent
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash

# 3. Arahkan Hermes ke Ollama (~/.hermes/config.yaml)
#    model:
#      default: "gemma4:31b-cloud"
#      provider: "custom"
#      base_url: "http://localhost:11434/v1"

# 4. Cek
./scripts/cek-kesehatan.sh
```

## Lingkungan yang didokumentasikan

| Komponen | Versi |
|---|---|
| OS | Fedora Linux 44 Workstation, kernel 6.19 |
| Ollama | 0.40.8 (service systemd `ollama`) |
| Model | `gemma4:31b-cloud` — completion, thinking, tools, vision; context 262.144 token |
| Hermes Agent | 0.21.6 (instalasi git di `~/.hermes/hermes-agent`) |
| Python (runtime Hermes) | 3.14 |
| Platform gateway | Telegram |

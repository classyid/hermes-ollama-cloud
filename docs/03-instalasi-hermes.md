# 3. Instalasi Hermes Agent

[Hermes Agent](https://github.com/NousResearch/hermes-agent) adalah agent AI
dari Nous Research dengan tool calling (terminal, file, browser, web search,
memori, cron, delegasi) dan gateway ke platform chat (Telegram, Discord,
Slack, WhatsApp, dll.).

## Install

```bash
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
```

Installer (metode git):

1. meng-clone `NousResearch/hermes-agent` ke `~/.hermes/hermes-agent`;
2. menyiapkan runtime Python terisolasi beserta dependensi (terverifikasi
   lewat `uv.lock`), Node.js, npm, ripgrep, dan FFmpeg di `~/.hermes/tools`;
3. memasang perintah `hermes` di `~/.local/bin/hermes`.

Cek:

```bash
hermes --version
# Hermes Agent v0.21.6 ...
# Install directory: ~/.hermes/hermes-agent
# Install method: git
```

## Struktur `~/.hermes`

| Path | Isi |
|---|---|
| `config.yaml` | Konfigurasi utama (model, provider, tools, gateway, dll.) |
| `.env` | API key & token (izin 600, jangan di-commit) |
| `auth.json` | Kredensial OAuth / credential pool |
| `logs/agent.log`, `logs/errors.log`, `logs/gateway.log` | Log |
| `backups/` | Tempat menyimpan salinan config sebelum diubah |
| `hermes-agent/` | Source code (instalasi git) |

## Pemeriksaan

```bash
hermes status            # ringkas: model, provider, gateway, platform
hermes status --full     # semua bagian
hermes doctor            # cek dependensi, config, tools
hermes doctor --fix      # perbaiki otomatis yang bisa diperbaiki
```

## Setup awal

```bash
hermes setup             # wizard interaktif
hermes model             # pilih provider & model default
```

Untuk memakai Ollama cloud, lihat [dokumen 4](04-hermes-ollama-cloud.md).

## Update

```bash
hermes update
```

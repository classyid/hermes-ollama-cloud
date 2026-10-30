# 1. Instalasi Ollama

## Install

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

Installer resmi ini:

- memasang binary di `/usr/local/bin/ollama`;
- membuat user & group sistem `ollama`;
- membuat service systemd `ollama.service` yang menjalankan `ollama serve`.

Cek versi:

```bash
ollama --version          # contoh: ollama version is 0.40.8
```

## Service systemd

```bash
systemctl status ollama           # harus "active (running)"
sudo systemctl enable --now ollama
sudo systemctl restart ollama
journalctl -u ollama -f           # log
```

Isi unit (ringkas):

```ini
[Service]
ExecStart=/usr/local/bin/ollama serve
User=ollama
Group=ollama
Restart=always
RestartSec=3
```

> Karena service berjalan sebagai user `ollama`, data & kunci login-nya
> berada di home user tersebut (`/usr/share/ollama/.ollama`), bukan di
> `~/.ollama` milik user biasa.

## Cek API

Ollama hanya mendengarkan di loopback secara default:

```bash
ss -ltnp | grep 11434             # 127.0.0.1:11434
curl -s localhost:11434/api/version
curl -s localhost:11434/v1/models # endpoint OpenAI-compatible (dipakai Hermes)
```

Jangan membuka port 11434 ke jaringan (`OLLAMA_HOST=0.0.0.0`) tanpa firewall
atau reverse proxy berautentikasi: siapa pun di jaringan bisa memakai kuota
cloud akun Anda.

## Update / uninstall

```bash
curl -fsSL https://ollama.com/install.sh | sh   # update = jalankan ulang installer
sudo systemctl disable --now ollama             # matikan
```

# 5. Troubleshooting

## `HTTP 404: model '<nama>' not found`

```
custom didn't answer after 3 attempts ...
Provider said: HTTP 404: model 'xxx' not found
```

**Penyebab:** `model.default` berisi nama model yang tidak ada di Ollama,
misalnya nama model milik provider lain, sementara `base_url` mengarah ke
Ollama lokal.

**Cek:**

```bash
hermes status | grep Model
curl -s localhost:11434/v1/models        # daftar model yang benar-benar ada
grep -n -A3 '^model:' ~/.hermes/config.yaml
```

**Solusi:** samakan `model.default` dengan nama di `ollama list`, hapus kunci
`model:` ganda di blok yang sama, lalu `hermes gateway restart`.

**Jebakan:** chat Telegram bisa tetap jalan walau default salah, karena sesi
itu punya override `/model` sendiri. Begitu `/new`, sesi baru ikut error. Uji
selalu dengan `hermes -z "..."` **tanpa** `-m`.

## Ollama tidak merespons

```bash
systemctl status ollama
curl -s localhost:11434/api/version
sudo systemctl restart ollama
journalctl -u ollama --since "10 min ago"
```

## Model cloud: `unauthorized` / minta login

Akun ollama.com belum login atau sesi kedaluwarsa:

```bash
ollama signin
```

## Model cloud lambat atau ditolak (limit)

Kuota paket ollama.com habis atau server sibuk. Kurangi ukuran konteks
(`/new`, `/compress`), tunggu, atau pasang fallback (`hermes fallback add`).

## Tool tampil sebagai teks JSON, tidak dieksekusi

Model/servernya tidak mengembalikan `tool_calls`. Uji langsung ke Ollama
(lihat [dokumen 2](02-model-cloud-ollama.md#uji)); `finish_reason` harus
`tool_calls`. `gemma4:31b-cloud` sudah lulus uji ini.

## Peringatan `hermes doctor` yang aman diabaikan

- `platform 'teams' / 'google_chat' has no valid toolsets` — hanya relevan
  bila platform itu dipakai.
- `Nous Portal / Codex / MiniMax / xAI auth (not logged in)` — provider lain
  yang memang tidak dipakai.
- `npm vulnerabilities` di browser tools / web / ui-tui — perbarui dengan
  `hermes update`; tidak memengaruhi koneksi model.

## Komputer kehabisan RAM

Model cloud tidak memakai RAM lokal, tapi browser, gateway, dan tool agent
tetap memakai memori. Di Fedora (btrfs) swapfile dibuat dengan:

```bash
sudo btrfs subvolume create /swap
sudo btrfs filesystem mkswapfile --size 16G /swap/swapfile
sudo swapon -p 10 /swap/swapfile
echo "/swap/swapfile none swap defaults,pri=10 0 0" | sudo tee -a /etc/fstab
```

Prioritas 10 < zram (100), jadi zram tetap dipakai lebih dulu.

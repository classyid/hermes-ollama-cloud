# 4. Hermes memakai model cloud Ollama

Prasyarat: [Ollama terpasang](01-instalasi-ollama.md) dan
[model cloud sudah aktif](02-model-cloud-ollama.md).

## Konfigurasi

Selalu backup dulu:

```bash
cp -p ~/.hermes/config.yaml ~/.hermes/backups/config.yaml.$(date +%Y%m%d-%H%M%S)
```

Blok `model:` di `~/.hermes/config.yaml`:

```yaml
model:
  default: "gemma4:31b-cloud"          # nama persis seperti di `ollama list`
  provider: "custom"                   # endpoint OpenAI-compatible
  base_url: "http://localhost:11434/v1"
```

Catatan penting:

- **Hanya satu nama model.** Hermes menerima kunci `default:` maupun
  `model:` di blok ini. Kalau keduanya ada dengan nilai berbeda, yang dipakai
  `default:`. Jangan menaruh keduanya.
- **Tidak perlu `api_key`.** Ollama lokal tidak memeriksa key. Jangan
  memasukkan key milik provider lain ke blok ini: key itu akan ikut terkirim
  ke endpoint yang dituju.
- `provider: "ollama"` adalah alias dari `"custom"`; keduanya butuh `base_url`.
- Kalau tidak memakai provider lain, kosongkan daftar lama:
  `custom_providers: []`.

Cara interaktif sebagai alternatif: `hermes model` → pilih **Custom Endpoint**
→ isi `http://localhost:11434/v1` → pilih `gemma4:31b-cloud`.

### Alias (opsional)

Alias memudahkan pindah model dengan `/model <alias>`:

```yaml
  aliases:
    gemma-lokal:
      base_url: http://localhost:11434/v1
      model: gemma4:31b-cloud
      provider: custom
```

## Terapkan & uji

```bash
python3 -c "import yaml;yaml.safe_load(open('$HOME/.hermes/config.yaml'));print('YAML valid')"
hermes gateway restart                 # gateway membaca ulang config
hermes status                          # Model: gemma4:31b-cloud, Provider: custom

# jawaban biasa, TANPA -m (membuktikan model default benar)
hermes -z "Jawab satu kata: ibukota Jawa Timur?"         # → Surabaya

# tool calling lewat Hermes
echo "uji-ok-123" > /tmp/uji.txt
hermes -z "Gunakan tool file untuk membaca /tmp/uji.txt lalu tuliskan isinya persis."  # → uji-ok-123
```

Atau jalankan semua sekaligus: `scripts/cek-kesehatan.sh`.

## Gateway (Telegram)

Gateway berjalan sebagai **user service** systemd:

```bash
systemctl --user status hermes-gateway
hermes gateway status | restart | stop | start
journalctl --user -u hermes-gateway -f
```

Status platform tersimpan di `~/.hermes/gateway_state.json`
(`"telegram": {"state": "connected"}`).

Perintah di dalam chat Telegram / CLI:

| Perintah | Fungsi |
|---|---|
| `/model gemma4:31b-cloud` | Ganti model untuk sesi itu saja (tersimpan per sesi) |
| `/new` | Mulai sesi baru (riwayat lama tidak ikut dikirim lagi) |
| `/compress` | Ringkas riwayat sesi yang panjang |
| `/retry` | Ulangi permintaan terakhir |

> `/model` di sebuah sesi **menimpa** model default untuk sesi itu dan tetap
> diingat setelah gateway restart. Sesi baru selalu memakai `model.default`.

## Menghemat kuota cloud

Setiap pesan mengirim ulang seluruh riwayat sesi. Sesi Telegram yang sudah
ratusan pesan bisa mengirim >100 ribu token untuk pertanyaan sederhana.
Biasakan `/new` untuk topik baru dan `/compress` untuk sesi panjang.

## Fallback (opsional)

Jika ingin cadangan saat Ollama cloud gangguan:

```bash
hermes fallback add
```

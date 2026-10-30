#!/usr/bin/env bash
# Cek kesehatan rantai Hermes Agent -> Ollama lokal -> model cloud.
# Pemakaian: ./cek-kesehatan.sh [nama-model]   (default: gemma4:31b-cloud)
set -u

MODEL="${1:-gemma4:31b-cloud}"
OLLAMA="${OLLAMA_URL:-http://localhost:11434}"
CONFIG="${HERMES_HOME:-$HOME/.hermes}/config.yaml"
LULUS=0; GAGAL=0

ok()   { echo "  [OK]    $*"; LULUS=$((LULUS+1)); }
gagal(){ echo "  [GAGAL] $*"; GAGAL=$((GAGAL+1)); }

echo "== 1. Ollama"
if v=$(curl -s -m 5 "$OLLAMA/api/version"); then ok "API hidup $v"; else gagal "Ollama tidak merespons di $OLLAMA"; fi
systemctl is-active --quiet ollama && ok "service ollama aktif" || gagal "service ollama tidak aktif"

echo "== 2. Model $MODEL"
if curl -s -m 10 "$OLLAMA/v1/models" | grep -q "\"$MODEL\""; then ok "terdaftar di Ollama"; else gagal "tidak ada di 'ollama list'"; fi
jawab=$(curl -s -m 120 "$OLLAMA/api/chat" -d "{\"model\":\"$MODEL\",\"stream\":false,\"messages\":[{\"role\":\"user\",\"content\":\"Jawab satu kata: ibukota Jawa Timur?\"}]}" \
  | python3 -c 'import sys,json;print(json.load(sys.stdin).get("message",{}).get("content","").strip())' 2>/dev/null)
[[ "$jawab" == *Surabaya* ]] && ok "chat cloud: $jawab" || gagal "chat cloud gagal (jawaban: '${jawab}')"

tc=$(curl -s -m 120 "$OLLAMA/v1/chat/completions" -H 'Content-Type: application/json' -d "{\"model\":\"$MODEL\",\"messages\":[{\"role\":\"user\",\"content\":\"Cuaca di Kediri sekarang?\"}],\"tools\":[{\"type\":\"function\",\"function\":{\"name\":\"get_weather\",\"description\":\"Ambil cuaca kota\",\"parameters\":{\"type\":\"object\",\"properties\":{\"city\":{\"type\":\"string\"}},\"required\":[\"city\"]}}}]}" \
  | python3 -c 'import sys,json;c=json.load(sys.stdin)["choices"][0];print(c["finish_reason"], (c["message"].get("tool_calls") or [{}])[0].get("function",{}).get("name",""))' 2>/dev/null)
[[ "$tc" == "tool_calls get_weather" ]] && ok "tool calling berfungsi" || gagal "tool calling gagal ($tc)"

echo "== 3. Konfigurasi Hermes ($CONFIG)"
python3 - "$CONFIG" "$MODEL" <<'EOF' && ok "blok model benar" || gagal "blok model perlu diperbaiki (lihat pesan di atas)"
import sys, yaml
cfg = yaml.safe_load(open(sys.argv[1])); m = cfg.get("model") or {}; want = sys.argv[2]; err = []
if m.get("default", m.get("model")) != want: err.append(f"model.default = {m.get('default')!r}, seharusnya {want!r}")
if "default" in m and "model" in m and m["default"] != m["model"]: err.append("ada 'default' dan 'model' dengan nilai berbeda")
if m.get("provider") not in ("custom", "ollama"): err.append(f"provider = {m.get('provider')!r}")
if "11434" not in str(m.get("base_url", "")): err.append(f"base_url = {m.get('base_url')!r}")
if m.get("api_key"): err.append("ada api_key di blok model (tidak perlu untuk Ollama)")
for e in err: print("          -", e)
sys.exit(1 if err else 0)
EOF

echo "== 4. Hermes end-to-end (tanpa -m)"
if command -v hermes >/dev/null; then
  h=$(timeout 180 hermes -z "Jawab satu kata: ibukota Jawa Timur?" 2>&1 | tail -1)
  [[ "$h" == *Surabaya* ]] && ok "hermes menjawab: $h" || gagal "hermes: $h"
  f=$(mktemp); echo "uji-hermes-$$" > "$f"
  h=$(timeout 300 hermes -z "Gunakan tool file untuk membaca $f lalu tuliskan isinya persis, tanpa penjelasan." 2>&1 | tail -1)
  rm -f "$f"
  [[ "$h" == *"uji-hermes-$$"* ]] && ok "tool calling lewat hermes" || gagal "tool calling lewat hermes: $h"
else
  gagal "perintah hermes tidak ditemukan"
fi

echo "== 5. Gateway"
systemctl --user is-active --quiet hermes-gateway && ok "hermes-gateway aktif" || gagal "hermes-gateway tidak aktif"
python3 - <<'EOF' 2>/dev/null || true
import json, os
d = json.load(open(os.path.expanduser("~/.hermes/gateway_state.json")))
for name, p in (d.get("platforms") or {}).items():
    print(f"  [info]  {name}: {p.get('state')}" + (f" ({p.get('error_message')})" if p.get("error_message") else ""))
EOF

echo
echo "Hasil: $LULUS lulus, $GAGAL gagal"
exit $(( GAGAL > 0 ))

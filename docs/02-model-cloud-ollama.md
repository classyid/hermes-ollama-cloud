# 2. Model cloud Ollama

Model berakhiran `-cloud` (misalnya `gemma4:31b-cloud`) dijalankan di server
Ollama, bukan di komputer Anda. Ollama lokal hanya menjadi perantara, jadi
API-nya tetap `localhost:11434` dan aplikasi lain (seperti Hermes) tidak perlu
tahu bahwa modelnya di cloud.

Keuntungan: tidak butuh GPU/RAM besar, tidak ada unduhan bobot puluhan GB.
Konsekuensi: butuh internet, butuh akun ollama.com, dan pemakaian dibatasi
kuota paket akun.

## Login akun

```bash
ollama signin
```

Perintah ini menampilkan link; buka di browser, login ke ollama.com, dan
setujui perangkat. Untuk keluar: `ollama signout`.

## Daftarkan model cloud

```bash
ollama pull gemma4:31b-cloud
ollama list
# NAME                ID              SIZE    MODIFIED
# gemma4:31b-cloud    ef09f235533c    -       ...
```

Kolom `SIZE` berisi `-` karena tidak ada bobot yang diunduh.

## Uji

Chat (API native):

```bash
curl -s localhost:11434/api/chat -d '{
  "model": "gemma4:31b-cloud", "stream": false,
  "messages": [{"role":"user","content":"Jawab singkat: ibukota Jawa Timur?"}]
}'
# ... "content":"Surabaya" ...
```

Endpoint OpenAI-compatible + **tool calling** (wajib untuk agent):

```bash
curl -s localhost:11434/v1/chat/completions -H 'Content-Type: application/json' -d '{
  "model": "gemma4:31b-cloud",
  "messages": [{"role":"user","content":"Bagaimana cuaca di Kediri sekarang?"}],
  "tools": [{"type":"function","function":{"name":"get_weather",
    "description":"Ambil cuaca kota",
    "parameters":{"type":"object","properties":{"city":{"type":"string"}},"required":["city"]}}}]
}'
# harus berisi "tool_calls":[{"function":{"name":"get_weather","arguments":"{\"city\":\"Kediri\"}"}}]
# dan "finish_reason":"tool_calls"
```

Detail kemampuan model:

```bash
curl -s localhost:11434/api/show -d '{"model":"gemma4:31b-cloud"}' \
  | python3 -c 'import sys,json;d=json.load(sys.stdin);print(d["capabilities"]);print(d["model_info"])'
# ['completion', 'thinking', 'tools', 'vision']
# {'gemma4.context_length': 262144}
```

## Penamaan model

Ollama menerima `gemma4:31b-cloud` maupun `gemma4:31b:cloud`, dan di respons
API menyebut dirinya `gemma4:31b`. Supaya konsisten, pakai nama persis seperti
di `ollama list`: **`gemma4:31b-cloud`**.

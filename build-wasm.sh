#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PATH="/tmp/suicune-wasm-bin:${PATH}"
mkdir -p /tmp/suicune-wasm-bin

cat > /tmp/suicune-wasm-bin/sdl2-config <<'SH'
#!/usr/bin/env sh
case "$1" in
  --cflags) printf '%s\n' '-sUSE_SDL=2' ;;
  --libs|--static-libs) printf '%s\n' '-sUSE_SDL=2' ;;
  --version) printf '%s\n' '2.0.0-emscripten' ;;
  *) exit 0 ;;
esac
SH
chmod +x /tmp/suicune-wasm-bin/sdl2-config

cd "$ROOT"
if [[ "${CLEAN:-0}" == "1" ]]; then
  make clean || true
fi

COMPILE_FLAGS=(
  -sUSE_SDL=2
  -Wno-unused-command-line-argument
  -Wno-pragma-pack
)

LINK_FLAGS=(
  -sUSE_SDL=2
  -sALLOW_MEMORY_GROWTH=1
  -sASYNCIFY=1
  -sASYNCIFY_IMPORTS='["emscripten_sleep"]'
  -sEXIT_RUNTIME=0
  -sFORCE_FILESYSTEM=1
  -sEXPORTED_FUNCTIONS='["_main","_wasm_set_joypad_key","_wasm_get_joypad","_wasm_flush_save"]'
  -sEXPORTED_RUNTIME_METHODS='["FS"]'
  --shell-file wasm-shell.html
  --preload-file gfx
  --preload-file data
  --preload-file audio
  --preload-file maps
  --preload-file server.json
  --preload-file input_system/default_config.ini
  --preload-file icon.png
  -lidbfs.js
)

emmake make -j"$(nproc)" \
  NAME=index.html \
  CC=emcc \
  AR=emar \
  RELEASE=1 \
  CFLAGS="${COMPILE_FLAGS[*]}" \
  LDFLAGS="${LINK_FLAGS[*]}"

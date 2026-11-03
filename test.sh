#!/usr/bin/env bash
# Levanta el Postgres de docker-compose, ejecuta los tests y lo apaga.
set -euo pipefail
cd "$(dirname "$0")"
sal=${SAL_BIN:-"$PWD/../sal/target/release/sal"}
[[ -x "$sal" ]] || sal=sal
trap 'docker compose down -v >/dev/null 2>&1' EXIT
docker compose down -v >/dev/null 2>&1 || true
docker compose up -d --wait
"$sal" install
"$sal" test

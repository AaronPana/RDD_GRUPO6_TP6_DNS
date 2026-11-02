#!/usr/bin/env bash
# Vuelve el laboratorio al estado inicial: zonas originales y contenedores nuevos
# Uso: bash scripts/reset.sh   (desde Git Bash o WSL)

set -e
export MSYS_NO_PATHCONV=1
cd "$(dirname "$0")/.."

read -p ">> Se van a restaurar las zonas originales y recrear los contenedores. ¿Continuar? (s/n) " resp
[ "$resp" = "s" ] || { echo ">> Cancelado."; exit 0; }

echo ">> Restaurando archivos de zona desde bind/original/..."
cp bind/original/db.lab bind/db.lab
cp bind/original/db.172.30.6 bind/db.172.30.6

echo ">> Eliminando contenedores, red y volúmenes..."
docker compose down -v

echo ">> Levantando desde cero..."
docker compose up -d --build

sleep 5
docker compose logs dns2 | grep -E "transferred serial|Transfer status" \
  || echo ">> No se ven transferencias. Revisar con: docker compose logs dns2"

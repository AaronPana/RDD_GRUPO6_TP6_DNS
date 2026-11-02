#!/usr/bin/env bash
# Instala y levanta el laboratorio DNS - Grupo 6
# Uso: bash scripts/setup.sh   (desde Git Bash o WSL)

set -e # Corta el script ante cualquier error
export MSYS_NO_PATHCONV=1 # Git Bash: evita que convierta rutas tipo /etc/... a rutas de Windows
cd "$(dirname "$0")/.."       # Se ubica en la carpeta del proyecto

KEY=bind/tsig.key
IMAGE=internetsystemsconsortium/bind9:9.20

# Si Docker creó una carpeta en lugar de la clave (por levantar sin generarla), se elimina
if [ -d "$KEY" ]; then
  echo ">> $KEY es una carpeta, no la clave. Se elimina."
  docker compose down
  rm -r "$KEY"
fi

# Genera la clave TSIG solo si no existe
if [ ! -f "$KEY" ]; then
  echo ">> Generando clave TSIG..."
  docker run --rm --entrypoint tsig-keygen "$IMAGE" -a hmac-sha256 transfer-grupo6 > "$KEY"
else
  echo ">> La clave TSIG ya existe, se usa la actual."
fi

echo ">> Levantando el laboratorio..."
docker compose up -d --build

echo ">> Esperando a que ns2 copie las zonas..."
sleep 5
docker compose ps
docker compose logs dns2 | grep -E "transferred serial|Transfer status" \
  || echo ">> No se ven transferencias. Revisar con: docker compose logs dns2"

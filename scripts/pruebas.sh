#!/usr/bin/env bash
# Ejecuta las pruebas principales del laboratorio DNS - Grupo 6
# Uso: bash scripts/pruebas.sh   (desde Git Bash o WSL, con el laboratorio levantado)

export MSYS_NO_PATHCONV=1 # Git Bash: evita que convierta rutas a rutas de Windows
cd "$(dirname "$0")/.."

NS1=172.30.6.10
NS2=172.30.6.11
CORTO="+noall +comments +answer"   # Muestra solo encabezado (status y flags) y respuesta
SECRET=$(grep secret bind/tsig.key | cut -d'"' -f2)

# Ejecuta un comando dentro del cliente, con un título
prueba() {
  echo
  echo "=================== $1 ==================="
  shift
  echo "\$ $*"
  docker compose exec -T cliente "$@"
}

echo "##### PRUEBAS DESDE EL CLIENTE LINUX #####"
prueba "Registro A (ns1)"            dig @$NS1 www.grupo6.lab $CORTO
prueba "Alias CNAME"                 dig @$NS1 web.grupo6.lab $CORTO
prueba "Correo MX"                   dig @$NS1 grupo6.lab MX $CORTO
prueba "Servidores NS"               dig @$NS1 grupo6.lab NS $CORTO
prueba "Resolución inversa PTR"      dig @$NS1 -x 172.30.6.20 $CORTO
prueba "Nombre inexistente"          dig @$NS1 noexiste.grupo6.lab $CORTO
prueba "Nombre externo (sin aa)"     dig @$NS1 google.com $CORTO
prueba "Registro A (ns2, con aa)"    dig @$NS2 www.grupo6.lab $CORTO
prueba "Serial en ns1"               dig @$NS1 grupo6.lab SOA +short
prueba "Serial en ns2"               dig @$NS2 grupo6.lab SOA +short
prueba "Transferencia SIN clave"     dig @$NS1 grupo6.lab AXFR
prueba "Transferencia CON clave"     dig @$NS1 grupo6.lab AXFR -y "hmac-sha256:transfer-grupo6:$SECRET"
prueba "Uso del DNS por el sistema"  ping -c 2 www.grupo6.lab

echo
echo "##### PRUEBAS DESDE EL HOST #####"
if command -v nslookup > /dev/null; then
  for cmd in "www.grupo6.lab 127.0.0.1" \
    "-port=5300 www.grupo6.lab 127.0.0.1" \
    "-type=MX grupo6.lab 127.0.0.1" \
    "172.30.6.20 127.0.0.1" \
    "google.com 127.0.0.1"; do
    echo
    echo "\$ nslookup $cmd"
    nslookup $cmd
  done
else
  echo ">> nslookup no está instalado. En WSL: sudo apt install dnsutils"
fi

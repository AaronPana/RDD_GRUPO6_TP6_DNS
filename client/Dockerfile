# Cliente DNS: Linux liviano (Alpine) con herramientas de consulta
FROM alpine:3.20
# bind-tools incluye dig y nslookup
RUN apk add --no-cache bind-tools
# Mantiene el contenedor encendido para ejecutar comandos con "docker compose exec"
CMD ["sleep", "infinity"]

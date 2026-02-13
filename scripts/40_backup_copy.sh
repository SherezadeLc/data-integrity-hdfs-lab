#!/usr/bin/env bash
set -euo pipefail

DT=${DT:-$(date +%F)}
NN_CONTAINER="namenode"

echo "[backup] Creando copia de seguridad de /data en /backup"
echo "[backup] Fecha: $DT"

# Crear carpeta /backup si no existe
docker exec -it $NN_CONTAINER bash -c "
  hdfs dfs -mkdir -p /backup
"

# Copiar datos preservando permisos (-p)
docker exec -it $NN_CONTAINER bash -c "
  hdfs dfs -cp -p /data/* /backup/
"

echo "[backup] Copia completada. Validando contenido..."

# Listar contenido para verificar
docker exec -it $NN_CONTAINER bash -c "
  hdfs dfs -ls -R /backup
"

echo "[backup] Backup finalizado correctamente."

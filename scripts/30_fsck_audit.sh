#!/usr/bin/env bash
set -euo pipefail

DT=${DT:-$(date +%F)}
NN_CONTAINER="namenode"

echo "[fsck] Ejecutando auditoría de integridad para /data"
echo "[fsck] Fecha: $DT"

# Ejecutar fsck dentro del contenedor y guardar salida temporal
docker exec -it $NN_CONTAINER bash -c "
  hdfs fsck /data -files -blocks -locations > /tmp/fsck_${DT}.txt
"

echo "[fsck] Copiando auditoría a HDFS en /audit"

# Crear carpeta audit si no existe
docker exec -it $NN_CONTAINER bash -c "
  hdfs dfs -mkdir -p /audit;
  hdfs dfs -put -f /tmp/fsck_${DT}.txt /audit/fsck_${DT}.txt
"

echo "[fsck] Auditoría completada. Archivo guardado en /audit/fsck_${DT}.txt"

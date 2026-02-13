#!/usr/bin/env bash
set -euo pipefail

DT=${DT:-$(date +%F)}
NN_CONTAINER="namenode"

echo "[inventory] Comparando /data y /backup"
echo "[inventory] Fecha: $DT"

# Ejecutar du en HDFS y guardar resultados
docker exec -it $NN_CONTAINER bash -c "
  hdfs dfs -du -s /data > /tmp/inventory_data_${DT}.txt
  hdfs dfs -du -s /backup > /tmp/inventory_backup_${DT}.txt
"

echo "[inventory] Copiando informe a HDFS en /audit"

docker exec -it $NN_CONTAINER bash -c "
  hdfs dfs -mkdir -p /audit
  hdfs dfs -put -f /tmp/inventory_data_${DT}.txt /audit/inventory_data_${DT}.txt
  hdfs dfs -put -f /tmp/inventory_backup_${DT}.txt /audit/inventory_backup_${DT}.txt
"

echo "[inventory] Comparación completada. Archivos guardados en /audit/"

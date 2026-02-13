#!/usr/bin/env bash
set -euo pipefail

NN_CONTAINER="namenode"
DN_CONTAINER="clustera-dnnm-1"

echo "[recovery] Restaurando DataNode: $DN_CONTAINER"

# 1) Arrancar de nuevo el DataNode
docker start "$DN_CONTAINER"

echo "[recovery] DataNode arrancado. Esperando 20 segundos para que el clúster se estabilice..."
sleep 20

echo "[recovery] Ejecutando fsck final sobre /data..."

# 2) Ejecutar fsck y guardar informe final
docker exec -it "$NN_CONTAINER" bash -c "
  hdfs fsck /data -files -blocks -locations > /tmp/fsck_recovery.txt
"

echo "[recovery] Copiando informe de recuperación a HDFS en /audit..."

docker exec -it "$NN_CONTAINER" bash -c "
  hdfs dfs -mkdir -p /audit;
  hdfs dfs -put -f /tmp/fsck_recovery.txt /audit/fsck_recovery.txt
"

echo "[recovery] Proceso de recuperación completado."
echo "[recovery] Informe disponible en: /audit/fsck_recovery.txt"

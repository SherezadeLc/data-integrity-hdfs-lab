#!/usr/bin/env bash
set -euo pipefail

NN_CONTAINER=${NN_CONTAINER:-namenode}
DT=${DT:-$(date +%F)}

echo "[bootstrap] DT=$DT"
echo "[bootstrap] Creando estructura base en HDFS..."

docker exec -it $NN_CONTAINER bash -lc "
  hdfs dfs -mkdir -p /data/logs/raw/dt=$DT
  hdfs dfs -mkdir -p /data/iot/raw/dt=$DT
  hdfs dfs -mkdir -p /backup/logs/raw/dt=$DT
  hdfs dfs -mkdir -p /backup/iot/raw/dt=$DT
  hdfs dfs -mkdir -p /audit/fsck/$DT
  hdfs dfs -mkdir -p /audit/inventory/$DT
"

echo "[bootstrap] Estructura creada correctamente."

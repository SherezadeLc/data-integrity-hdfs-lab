#!/usr/bin/env bash
set -euo pipefail

DT=${DT:-$(date +%F)}
LOCAL_DIR="./local_data/$DT"

echo "[ingest] DT=$DT"
echo "[ingest] Local dir=$LOCAL_DIR"

if [ ! -d "$LOCAL_DIR" ]; then
  echo "[ingest] ERROR: No existe $LOCAL_DIR. Ejecuta antes 10_generate_data.sh"
  exit 1
fi

# Nombre del contenedor del NameNode
NN_CONTAINER="namenode"

echo "[ingest] Copiando datos al contenedor..."
docker cp "$LOCAL_DIR" "$NN_CONTAINER:/tmp/"

echo "[ingest] Creando rutas en HDFS..."
docker exec -it $NN_CONTAINER bash -c "
  hdfs dfs -mkdir -p /data/logs/raw/dt=$DT;
  hdfs dfs -mkdir -p /data/iot/raw/dt=$DT;
"

echo "[ingest] Subiendo datos a HDFS..."
docker exec -it $NN_CONTAINER bash -c "
  hdfs dfs -put /tmp/$DT/logs/* /data/logs/raw/dt=$DT/;
  hdfs dfs -put /tmp/$DT/iot/*  /data/iot/raw/dt=$DT/;
"

echo "[ingest] Ingesta completada correctamente."

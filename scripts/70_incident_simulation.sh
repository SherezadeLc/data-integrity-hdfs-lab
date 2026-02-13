#!/usr/bin/env bash
set -euo pipefail

# Nombre del NameNode y del DataNode que vamos a "romper"
NN_CONTAINER="namenode"
DN_CONTAINER="clustera-dnnm-1"

echo "[incident] Simulando caída del DataNode: $DN_CONTAINER"

# 1) Parar el DataNode
docker stop "$DN_CONTAINER"

echo "[incident] DataNode detenido. Esperando 10 segundos para que el NameNode detecte el fallo..."
sleep 10

echo "[incident] Ejecutando fsck sobre /data para ver el impacto del fallo..."

# 2) Ejecutar fsck dentro del NameNode y guardar el resultado en un fichero temporal
docker exec -it "$NN_CONTAINER" bash -c "
  hdfs fsck /data -files -blocks -locations > /tmp/fsck_incident.txt
"

echo "[incident] Copiando informe de fsck a HDFS en /audit..."

# 3) Subir el informe a HDFS en /audit
docker exec -it "$NN_CONTAINER" bash -c "
  hdfs dfs -mkdir -p /audit;
  hdfs dfs -put -f /tmp/fsck_incident.txt /audit/fsck_incident.txt
"

echo "[incident] Incidente simulado correctamente."
echo "[incident] Informe disponible en: /audit/fsck_incident.txt"

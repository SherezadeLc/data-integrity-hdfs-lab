#!/usr/bin/env bash
set -euo pipefail

DT=${DT:-$(date +%F)}

OUT_DIR="./local_data/$DT"
LOG_DIR="$OUT_DIR/logs"
IOT_DIR="$OUT_DIR/iot"

echo "[generate] Generando dataset para fecha: $DT"
echo "[generate] Carpeta destino: $OUT_DIR"

mkdir -p "$LOG_DIR"
mkdir -p "$IOT_DIR"

########################################
# 1) LOGS
########################################

LOG_FILE="$LOG_DIR/logs_${DT//-/}.log"
echo "[generate] Creando logs en: $LOG_FILE"

for i in {1..2000}; do
  echo "INFO $(date +%s) user=user$i action=login status=OK" >> "$LOG_FILE"
  echo "WARN $(date +%s) user=user$i action=query status=SLOW" >> "$LOG_FILE"
  echo "ERROR $(date +%s) user=user$i action=update status=FAIL" >> "$LOG_FILE"
done

########################################
# 2) IoT JSONL
########################################

IOT_FILE="$IOT_DIR/iot_${DT//-/}.jsonl"
echo "[generate] Creando IoT en: $IOT_FILE"

for i in {1..3000}; do
  TS=$(date +%s)
  TEMP=$(awk -v min=20 -v max=30 'BEGIN{srand(); print min+rand()*(max-min)}')
  echo "{\"device\":\"sensor-$i\",\"timestamp\":$TS,\"metric\":\"temperature\",\"value\":$TEMP}" >> "$IOT_FILE"
done

echo "[generate] Dataset generado correctamente:"
echo "  - $LOG_FILE"
echo "  - $IOT_FILE"

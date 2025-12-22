#!/bin/bash
set -e

APP_DIR="/home/ec2-user/app"
LOG_FILE="$APP_DIR/app.log"
PID_FILE="$APP_DIR/app.pid"

mkdir -p "$APP_DIR"
touch "$LOG_FILE"
chmod 664 "$LOG_FILE" || true

echo "[stop] $(date)" >> "$LOG_FILE"

# PID 파일 기반 종료(가장 안정적)
if [ -f "$PID_FILE" ]; then
  PID=$(cat "$PID_FILE" || true)
  if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
    kill "$PID"
    echo "[stop] killed pid=$PID" >> "$LOG_FILE"
    sleep 3
  fi
  rm -f "$PID_FILE"
fi

# 혹시 PID 파일이 없거나 남아있을 때를 대비한 fallback
PIDS=$(pgrep -f 'java.*\.jar' || true)
if [ -n "$PIDS" ]; then
  echo "[stop] fallback pgrep pids=$PIDS" >> "$LOG_FILE"
  kill $PIDS || true
fi

echo "[stop] done" >> "$LOG_FILE"
exit 0

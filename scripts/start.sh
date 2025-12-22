#!/bin/bash
set -e

APP_DIR="/home/ec2-user/app"
LOG_FILE="$APP_DIR/app.log"
PID_FILE="$APP_DIR/app.pid"

cd "$APP_DIR"

JAR=$(ls -1 *.jar | head -n 1)
if [ -z "$JAR" ]; then
  echo "[start] no jar found in $APP_DIR" >> "$LOG_FILE"
  exit 1
fi

echo "[start] $(date) starting $JAR" >> "$LOG_FILE"

nohup java -jar "$JAR" >> "$LOG_FILE" 2>&1 &
echo $! > "$PID_FILE"

echo "[start] pid=$(cat $PID_FILE)" >> "$LOG_FILE"

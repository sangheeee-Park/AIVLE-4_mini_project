#!/bin/bash
set -e

APP_DIR="/home/ec2-user/app"
LOG_FILE="$APP_DIR/app.log"
PID_FILE="$APP_DIR/app.pid"

mkdir -p "$APP_DIR"
touch "$LOG_FILE"
chmod 664 "$LOG_FILE" || true

cd "$APP_DIR"

JAR=$(ls -1 *.jar 2>/dev/null | head -n 1)
if [ -z "$JAR" ]; then
  echo "[start] $(date) no jar found in $APP_DIR" >> "$LOG_FILE"
  ls -al "$APP_DIR" >> "$LOG_FILE" 2>&1
  exit 1
fi

echo "[start] $(date) starting $JAR" >> "$LOG_FILE"

nohup java -jar "$JAR" >> "$LOG_FILE" 2>&1 &
echo $! > "$PID_FILE"

sleep 1
PID=$(cat "$PID_FILE" 2>/dev/null || true)
if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
  echo "[start] pid=$PID running" >> "$LOG_FILE"
else
  echo "[start] pid not running. check log above" >> "$LOG_FILE"
  exit 1
fi

exit 0

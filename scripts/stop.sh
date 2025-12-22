#!/bin/bash
set +e  # stop 단계는 실패하면 안 됨

APP_DIR="/home/ec2-user/app"
LOG_FILE="$APP_DIR/app.log"
PID_FILE="$APP_DIR/app.pid"

mkdir -p "$APP_DIR"
touch "$LOG_FILE"
chmod 664 "$LOG_FILE" 2>/dev/null

echo "[stop] $(date)" >> "$LOG_FILE"

# PID 파일 기반 종료
if [ -f "$PID_FILE" ]; then
  PID=$(cat "$PID_FILE" 2>/dev/null)
  if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
    kill "$PID" 2>/dev/null
    echo "[stop] killed pid=$PID" >> "$LOG_FILE"
    sleep 3
  fi
  rm -f "$PID_FILE"
fi

# fallback: jar 프로세스 종료
PIDS=$(pgrep -f 'java.*\.jar' 2>/dev/null)
if [ -n "$PIDS" ]; then
  echo "[stop] fallback pgrep pids=$PIDS" >> "$LOG_FILE"
  kill $PIDS 2>/dev/null
  sleep 2
  # 안 죽으면 강제 종료(옵션)
  PIDS2=$(pgrep -f 'java.*\.jar' 2>/dev/null)
  if [ -n "$PIDS2" ]; then
    echo "[stop] force kill pids=$PIDS2" >> "$LOG_FILE"
    kill -9 $PIDS2 2>/dev/null
  fi
fi

echo "[stop] done" >> "$LOG_FILE"
exit 0

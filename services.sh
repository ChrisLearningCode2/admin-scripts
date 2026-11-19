#!/usr/bin/env bash
# PURPOSE: check that important services are running and write a report

# --- 1. SETTINGS ---
SERVICES="cron NetworkManager systemd-journald"
REPORT=~/scripts/services.txt

# --- 2. START ---
mkdir -p ~/scripts
echo "Service check $(date)" > "$REPORT"

# --- 3. WORK ---
for svc in $SERVICES; do
  if systemctl is-active --quiet "$svc"; then
    echo "OK: $svc is running" >> "$REPORT"
  else
    echo "WARNING: $svc is NOT running" >> "$REPORT"
  fi
done

# --- 4. FINISH ---
cat "$REPORT"

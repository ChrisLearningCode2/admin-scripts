#!/usr/bin/env bash
# PURPOSE: read-only system health report (uptime, disk usage, memory)

# --- 1. SETTINGS ---
THRESHOLD=80                                   # warn if a disk is fuller than this %
REPORT=~/scripts/health-$(date +%F).txt        # report file named with today's date

# --- 2. START ---
mkdir -p ~/scripts
echo "Health check for $(hostname) - $(date)" > "$REPORT"
echo "Uptime: $(uptime -p)" >> "$REPORT"

# --- 3. WORK ---
# Loop over every real disk and warn if it is too full
df -h --output=target,pcent -x tmpfs -x devtmpfs | tail -n +2 | while read -r mount use; do
  pct=${use%\%}                                # strip the % sign so we can compare numbers
  if [ "$pct" -ge "$THRESHOLD" ]; then
    echo "WARNING: $mount is ${use} full" >> "$REPORT"
  else
    echo "OK: $mount is ${use} full" >> "$REPORT"
  fi
done

# Memory: how much is available
echo "Memory available: $(free -h | awk '/Mem:/ {print $7}')" >> "$REPORT"

# --- 4. FINISH ---
cat "$REPORT"

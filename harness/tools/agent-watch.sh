#!/usr/bin/env bash
# agent-watch.sh — beobachtet den Speicher, waehrend Subagenten laufen, und schlaegt
# an, BEVOR der Kernel entscheidet.
#
# WARUM ES DIESES WERKZEUG GIBT. Am 2026-07-29 gab es zwei Abstuerze durch
# Speichermangel. Der OOM-Dump des Kernels benennt den Verursacher eindeutig: der
# getoetete Prozess war Claude Code SELBST mit 25,37 GB RSS — 85 % der 29,7 GB, die
# 226 Prozesse zusammen hielten. Die Maschine hat 20 Kerne, die Last lag bei ~24 %;
# CPU war nie das Problem, obwohl der Vorfall sich so anfuehlte. Ausgeloest hat die
# scheiternde Allokation ein `docker build` (containerd), verursacht hat sie die
# Werkzeugschicht: zwei gleichzeitig laufende Subagenten tragen jeder einen grossen
# Kontext, und ihre Transkripte liegen im SELBEN Prozess wie die Hauptsitzung.
#
# WAS ES KANN UND WAS NICHT — die Grenze ist wichtig, sonst verlaesst sich jemand auf
# das Falsche:
#   - Es BEOBACHTET von aussen und meldet. Mehr nicht.
#   - Es kann einen Agenten NICHT abbrechen. Subagenten sind keine eigenen Prozesse;
#     sie leben im Claude-Code-Prozess. Ein `kill` traefe die ganze Sitzung. Der
#     Abbruch laeuft ueber das Werkzeug, das den Agenten gestartet hat — ausgeloest
#     von der Meldung, die dieses Skript schreibt.
#   - Es ist damit ein Melder mit menschlicher (bzw. agentischer) Reaktionszeit, kein
#     Automatismus. Wer eine harte Grenze will, setzt sie an der cgroup (memory.max);
#     dann toetet der Kernel innerhalb der cgroup statt global — das ist eine
#     Entscheidung ueber die Sitzung, nicht ueber einen Agenten.
#
# AUSGABE: eine Zeile je UEBERSCHREITUNG auf stdout (als Ereignis gedacht), und jede
# Messung in den Verlauf unter .harness/state/. Ruhe heisst: alles unter der Schwelle.
#
# Aufruf: agent-watch.sh [warn-GB] [abbruch-GB] [intervall-s]
set -uo pipefail

WARN="${1:-10}"
ABORT="${2:-16}"
INTERVAL="${3:-5}"

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
LOG="$ROOT/.harness/state/agent-watch.log"
mkdir -p "$(dirname "$LOG")"

# Die cgroup der Werkzeugschicht. Sie umfasst Editor UND Claude Code — genau die
# Menge, die im OOM-Dump zusammen 25 GB hielt. Fehlt sie (anderer Start-Weg, andere
# Umgebung), faellt das Skript auf den groessten Einzelprozess zurueck, statt still
# nichts zu messen.
CG=""
for d in /sys/fs/cgroup/user.slice/user-*.slice/user@*.service/app.slice/snap.code.*; do
  [ -d "$d" ] || continue
  CG="$d"
  break
done

belegt_gb() {
  if [ -n "$CG" ] && [ -r "$CG/memory.current" ]; then
    awk '{printf "%.2f", $1/1073741824}' "$CG/memory.current"
    return
  fi
  # Rueckfall: groesster RSS im System, aus /proc gelesen (kein ps noetig).
  local max=0 rss
  for s in /proc/[0-9]*/status; do
    rss="$(awk '/^VmRSS/{print $2; exit}' "$s" 2>/dev/null)" || continue
    [ -n "$rss" ] && [ "$rss" -gt "$max" ] && max="$rss"
  done
  awk -v k="$max" 'BEGIN{printf "%.2f", k/1048576}'
}

frei_gb() { awk '/MemAvailable/{printf "%.2f", $2/1048576}' /proc/meminfo; }

echo "agent-watch: Schwellen warn=${WARN}GB abbruch=${ABORT}GB, Intervall ${INTERVAL}s, Verlauf $LOG" >&2

gewarnt=0
while :; do
  b="$(belegt_gb)"
  f="$(frei_gb)"
  l="$(cut -d' ' -f1 /proc/loadavg)"
  printf '%s\tbelegt=%s\tfrei=%s\tlast=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$b" "$f" "$l" >> "$LOG"

  # Abbruch-Schwelle zuerst: sie beendet die Beobachtung, damit die Meldung nicht in
  # einer Flut von Warnungen untergeht.
  if awk -v b="$b" -v s="$ABORT" 'BEGIN{exit !(b>=s)}'; then
    echo "ABBRUCH-SCHWELLE: Werkzeugschicht haelt ${b} GB (>= ${ABORT}), frei nur noch ${f} GB — laufende Agenten JETZT stoppen"
    exit 1
  fi
  if [ "$gewarnt" = 0 ] && awk -v b="$b" -v s="$WARN" 'BEGIN{exit !(b>=s)}'; then
    echo "WARNUNG: Werkzeugschicht haelt ${b} GB (>= ${WARN}), frei ${f} GB — keine weiteren Agenten starten"
    gewarnt=1
  fi
  sleep "$INTERVAL"
done

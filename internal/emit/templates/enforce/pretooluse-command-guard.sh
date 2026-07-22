#!/usr/bin/env bash
# pretooluse-command-guard — blockt Host-Paketmanager und Host-Toolchains
# (go/pip/npm/cargo/...); dieses Repo baut make/Docker-only (AGENTS.md Hard
# Rule 3.1). Reines bash + awk, KEIN node/jq/OCI.
#
# Der awk-Extraktor (tools/harness/extract-command.awk) zieht nur das eine Feld
# tool_input.command aus der Hook-stdin-JSON; bei Parse-Zweifel (malformed,
# abgeschnitten, \u-Escape im Befehl) -> fail-closed (block).
#
# Geprueft wird die Befehlsposition jedes Kommando-Segments (Trennung an
# ; & && || | $( ` ( und Zeilenenden) — `git commit -m "... pip ..."` bleibt
# erlaubt, `/usr/bin/pip` und `sudo pip` werden erkannt. Zuweisungs- und
# Wrapper-Praefixe (VAR=…, sudo/env/command/…) sowie fuehrende Brace-Group-
# Delimiter ({ … }) werden uebersprungen.
# ACHTUNG quote-BLIND: ein Trenner (; & | …) IN einem Argument (z. B. einer
# Commit-Message `… & gofmt …`) startet ein neues Segment — steht dort ein
# blockiertes Wort am Kopf, blockt der Guard (False-Positive). Abhilfe:
# Commit-Messages via `git commit -F <datei>`.
# Sub-Shell-Strings (`bash -c "…"`, auch in Flag-Buendeln wie -lc/-ec/-cx)
# werden rekursiv geprueft (Tiefe <= 3, darueber fail-closed).
# Bewusst NICHT geprueft: andere Interpreter (`python -c`, `find -exec`, …)
# — der Guard ist ein Stolperdraht gegen versehentliche Host-Toolchain-
# Nutzung, KEINE Sandbox; Vollstaendigkeit ist nicht das Ziel.
#
# Im Pass-Fall: KEINE Ausgabe — "approve" wuerde das Permission-System
# ueberspringen; ohne Ausgabe laeuft die normale Permission-Entscheidung.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
extractor="$here/../../tools/harness/extract-command.awk"

emit_block() {
  cat <<'JSON'
{
  "decision": "block",
  "reason": "This repository is make/Docker-only (AGENTS.md Hard Rule 3.1). Use make targets; do not install or run host package managers or host toolchains (apt/brew/pip/npm/cargo/go/...). On parse doubt the guard fails closed."
}
JSON
}

# BLOCKED = universelle Paketmanager + die Toolchain der Ziel-Sprache (je --lang
# von ai-harness-init eingesetzt; @@BLOCKED_SET@@ wird beim Emit ersetzt).
BLOCKED="@@BLOCKED_SET@@"
PREFIXES="sudo env command exec nice time xargs eval"
SHELLS="bash sh zsh dash ksh"

in_set() {  # in_set <space-getrennte-menge> <wort>
  local w
  for w in $1; do [ "$w" = "$2" ] && return 0; done
  return 1
}

# Ergebnis in der globalen STRIPPED (kein Subshell-Fork je Token; der Guard
# laeuft vor JEDEM Bash-Call, Latenz zaehlt).
strip_quotes() {  # fuehrende/abschliessende " und ' entfernen (wie ^["']+|["']+$)
  local s=$1
  while [ -n "$s" ]; do case $s in \"*|\'*) s=${s#?};; *) break;; esac; done
  while [ -n "$s" ]; do case $s in *\"|*\') s=${s%?};; *) break;; esac; done
  STRIPPED=$s
}

scan() {  # scan <cmd> <tiefe>; return 0 = BLOCK, 1 = ok
  local cmd=$1 depth=$2
  [ "$depth" -gt 3 ] && return 0          # zu tief verschachtelt -> fail-closed
  local s=$cmd
  s=${s//'&&'/$'\n'}; s=${s//'&'/$'\n'}; s=${s//'||'/$'\n'}; s=${s//'|'/$'\n'}
  s=${s//';'/$'\n'};  s=${s//\$\(/$'\n'};  s=${s//'`'/$'\n'}
  s=${s//'('/$'\n'};  s=${s//$'\r'/$'\n'}
  local seg head i j rest x
  local -a toks stoks
  while IFS= read -r seg; do
    read -ra toks <<< "$seg"
    [ "${#toks[@]}" -eq 0 ] && continue
    stoks=()
    for x in "${toks[@]}"; do strip_quotes "$x"; stoks+=("$STRIPPED"); done
    i=0
    while [ "$i" -lt "${#stoks[@]}" ]; do
      if [[ "${stoks[$i]}" =~ ^[A-Za-z_][A-Za-z0-9_]*= ]]; then i=$((i+1)); continue; fi
      in_set "$PREFIXES" "${stoks[$i]}" && { i=$((i+1)); continue; }
      # fuehrende Brace-Group-Delimiter ueberspringen: `{ go build; }` ->
      # Kopf waere sonst `{` und das Tool an Position 2 entkaeme der Pruefung.
      case "${stoks[$i]}" in "{"|"}") i=$((i+1)); continue;; esac
      break
    done
    [ "$i" -ge "${#stoks[@]}" ] && continue
    head=${stoks[$i]}; head=${head##*/}    # /usr/bin/pip -> pip
    in_set "$BLOCKED" "$head" && return 0
    if in_set "$SHELLS" "$head"; then
      # -c auch in Flag-Buendeln (-lc, -ec, -cx, …): bei sh/bash ist c das
      # einzige Single-Letter-Flag mit Kommando-String-Semantik.
      j=$((i+1))
      while [ "$j" -lt "${#stoks[@]}" ]; do
        if [[ "${stoks[$j]}" =~ ^-[a-z]*c[a-z]*$ ]]; then
          rest="${stoks[*]:$((j+1))}"
          scan "$rest" "$((depth+1))" && return 0
          break
        fi
        j=$((j+1))
      done
    fi
  done <<< "$s"
  return 1
}

input="$(cat)"

# Ohne awk keine Pruefung -> fail-closed. (awk ist POSIX-Basis.)
command -v awk >/dev/null 2>&1 || { emit_block; exit 0; }

set +e
cmd="$(printf '%s' "$input" | awk -f "$extractor")"
rc=$?
set -e
[ "$rc" -ne 0 ] && { emit_block; exit 0; }   # Parse-Zweifel -> fail-closed

scan "$cmd" 0 && emit_block
# Pass-Fall: keine Ausgabe — normale Permission-Pruefung uebernimmt.
exit 0

#!/usr/bin/env bash
# pretooluse-commit-msg-guard — blockt einen `git commit -F <datei>`-Aufruf
# (Repo-Konvention "Commit via Message-Datei"), dessen Message-Datei keine
# Traceability-Kennung (ADR-/LH-/MR-/slice-) traegt (AGENTS.md §5,
# harness/README.md §Traceability, AGENTS.md 3.6). Sensor: `make
# commit-msg-check MSG=<datei>` (harness/README.md; commits:-Block in
# .d-check.yml).
#
# Reines bash + awk, wie der Nachbar-Guard (LH-QA-03) — der awk-Extraktor
# (harness/tools/extract-command.awk) liefert denselben dekodierten Befehl,
# den auch pretooluse-command-guard.sh sieht; bei Parse-Zweifel gibt DIESER
# Zusatz-Hook nichts aus (der Command-Guard entscheidet fail-closed bereits
# selbst, ein zweiter Block waere doppelte Meldung fuer denselben Befund).
#
# Erkannt wird NUR die dokumentierte Aufrufform `git commit ... -F <datei>
# ...` (kein Trenner-Zeichen zwischen `commit` und `-F`, kein Anspruch auf
# Vollstaendigkeit). `git commit -m "…"` oder `-F -` (stdin) entkommen dieser
# Pruefung — derselbe Stolperdraht-Charakter wie beim Command-Guard: kein
# Sandbox-Anspruch, ADR-0004.
#
# Reagiert dieser Hook (Muster erkannt, Datei existiert), gilt SEIN Urteil:
# `make commit-msg-check` selbst prueft nur die ANWESENHEIT einer Kennung,
# nicht ihre Wahrheit (harness/README.md) — derselbe Befund wie bei
# `doc-commits`.
#
# Die Pruef-Instanz (docker/d-check) ist ueber PRETOOLUSE_COMMIT_MSG_CHECKER
# austauschbar (Default: `make -C <repo> commit-msg-check MSG=<datei>`) —
# der einzige Grund ist Testbarkeit: das gepinnte bats-Image faehrt ohne
# Docker und ohne `git` (test/guard.bats-Nachbarschaft), ein Vor-Ort-Stub
# kann die reale Pruef-Instanz darum nicht laden. Die Ersetzungs-Stelle liegt
# HINTER der Match-/Existenz-Pruefung — derselbe Code-Pfad, den auch der
# Default-Aufruf durchlaeuft.
#
# --match <befehl>: nur die Extraktion pruefen (ohne stdin/JSON, ohne
# Pruef-Instanz) — druckt den erkannten Dateipfad auf stdout und exit 0, oder
# nichts und exit 1, wenn kein `git commit … -F <datei>` erkannt wird.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
extractor="$here/../../harness/tools/extract-command.awk"
repo_root="$(cd "$here/../.." && pwd)"

# git commit … -F <datei> -> Datei auf stdout, exit 0; sonst exit 1 (kein Output).
match_msgfile() {
  local cmd=$1 re
  re='git[[:space:]]+commit[^;&|]*[[:space:]]-F[[:space:]]+([^[:space:]"'"'"']+)'
  [[ "$cmd" =~ $re ]] || return 1
  printf '%s' "${BASH_REMATCH[1]}"
}

if [ "${1:-}" = "--match" ]; then
  match_msgfile "${2:-}"
  exit $?
fi

emit_block() {  # $1 = Begruendungstext (bereits JSON-sicher)
  printf '{\n  "decision": "block",\n  "reason": "%s"\n}\n' "$1"
}

input="$(cat)"

command -v awk >/dev/null 2>&1 || exit 0   # kein awk: dieser Zusatz-Hook greift nicht, der Command-Guard bleibt aktiv

set +e
cmd="$(printf '%s' "$input" | awk -f "$extractor")"
rc=$?
set -e
[ "$rc" -ne 0 ] && exit 0   # Parse-Zweifel: der Command-Guard blockt bereits fail-closed

msgfile="$(match_msgfile "$cmd")" || exit 0   # keine `git commit … -F`-Form: dieser Hook greift nicht
[ "$msgfile" = "-" ] && exit 0                # stdin-Form ausserhalb der Repo-Konvention: keine Datei zu pruefen

case "$msgfile" in
  /*) abspath="$msgfile" ;;
  *) abspath="$repo_root/$msgfile" ;;
esac
[ -f "$abspath" ] || exit 0   # (noch) keine Datei an der Stelle -> kein Befund, kein Block

check_rc=0
if [ -n "${PRETOOLUSE_COMMIT_MSG_CHECKER:-}" ]; then
  "$PRETOOLUSE_COMMIT_MSG_CHECKER" "$abspath" >/dev/null 2>&1 || check_rc=$?
else
  make -C "$repo_root" commit-msg-check MSG="$abspath" >/dev/null 2>&1 || check_rc=$?
fi

if [ "$check_rc" -ne 0 ]; then
  reason="Commit-Message-Datei ${msgfile} traegt keine Traceability-Kennung (ADR-/LH-/MR-/slice-) -- siehe: make commit-msg-check MSG=${msgfile}"
  reason="${reason//\\/\\\\}"; reason="${reason//\"/\\\"}"
  emit_block "$reason"
fi
exit 0

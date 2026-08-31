#!/usr/bin/env bash
# slice-mv.sh — Lifecycle-Wechsel eines Slice UND der Verweise, die er bricht
# (AGENTS.md §3.3: Move und Inhalt sind zwei Commits — dieses Skript setzt
# beide selbst, in dieser Reihenfolge, s. ZUSAGE).
#
# ABGRENZUNG (Ausgangspunkt, keine Antwort). Das Schwesterwerkzeug
# a-check/tools/slice-mv.sh ersetzt zwei Präfix-Formen ("../<dir>/<datei>" und
# "docs/plan/planning/<dir>/<datei>"). Dieses Repo führt mehr Formen (die
# beiden Mess-Kommandos in docs/plan/planning/in-progress/
# slice-144-lifecycle-move-zieht-seine-verweise-nach.md §1) — eine bloße
# Übernahme der zwei Muster wäre schlechter als kein Werkzeug: sie meldete
# Erfolg und ließe den Rest unentdeckt stehen. Die EINGEHEND-Ersetzung unten
# ersetzt darum keine feste Musterliste, sondern jedes Vorkommen von
# "<von>/<datei>" an einer Wortgrenze — das deckt jede Präfix-Form (vom
# nackten Verzeichnisnamen bis zum doppelten Aufstieg über
# "docs/plan/planning/") mit einer Regel statt einer Liste, die driftet.
#
# ZUSAGE. `make slice-mv SLICE=<slice-NNN> TO=<open|next|in-progress|done>`
# bewegt den Slice per `git mv` und committet den reinen Move SOFORT als
# eigenen Commit (Hard Rule 3.3: kein Byte Inhalt veraendert, die
# Rename-Erkennung greift). Danach zieht es reale Verweise nach — EINGEHEND
# (jede Praefix-Form auf die bewegte Datei, repo-weit) UND AUSGEHEND
# (praefixlose Ziele INNERHALB der bewegten Datei, die nach dem Wechsel ins
# falsche Verzeichnis zeigen) — und committet diese Inhaltsaenderung, falls
# welche anfielen, als ZWEITEN, vom Move getrennten Commit; fiel keine an,
# bleibt es beim einen Move-Commit. test/slice-mv.bats deckt beide
# Ersetzungsrichtungen und die Teilstring-Falle (slice-13 steckt in
# slice-130), ohne ein Repo zu bewegen — es ruft die Ersetzungs-Funktionen
# direkt auf (Quelle: dieses Skript, per BASH_SOURCE-Waechter ohne
# Nebenwirkung ladbar). Die Zwei-Commit-Sequenz selbst ist NICHT per bats
# gedeckt — main() braucht ein echtes `git`-Repo, das gepinnte bats-Image
# fuehrt kein `git`-Binaer (wie test/slice-mv.bats am Dateiende selbst
# festhaelt); Beleg ist ein manueller `git show --stat`-Lauf auf den
# Move-Commit.
#
# VORAUSSETZUNG. Weil das Skript selbst committet, verlangt es einen sauberen
# Arbeitsbaum (keine gestagten oder ungestagten Aenderungen an getrackten
# Dateien), BEVOR es startet — sonst landet ein fremder, zufaellig
# anwesender Diff im automatischen Move- oder Inhalts-Commit. Ein Verstoss
# bricht den Aufruf vor dem ersten `git mv` (main(), erste Pruefung).
#
# GRENZEN (gemessen, nicht vermutet — drei Stück):
# (1) Das Werkzeug zieht PFADE nach, keine ZUSTANDSSÄTZE. Eine Zeile "In
#     Arbeit: <slice>" bleibt nach dem Wechsel stehen; ihr Verweis wird
#     richtig, ihre Aussage falsch. Welcher Satz einen Zustand behauptet, ist
#     Urteil, kein Match.
# (2) WELLE-Plan-Dateien wechseln beim Closure-Move die Verzeichnis-TIEFE
#     (flach -> done/), nicht nur das Verzeichnis — eine andere Ersetzung als
#     der Tausch auf gleicher Ebene. Dieses Werkzeug bewegt nur SLICE-Dateien
#     (SLICE=<slice-NNN>) und ersetzt in der Ausgehend-Richtung darum auch nur
#     "slice-"-Ziele; ein präfixloses "welle-"-Ziel bleibt unberührt.
# (3) Präfixlose EINGEHENDE Verweise — eine andere, im $from-Verzeichnis
#     bleibende Datei referenziert die bewegte Datei ohne jedes
#     Verzeichnis-Segment ("[x](slice-N….md)") — erkennt die
#     Eingehend-Ersetzung NICHT: ihr fehlt das Verzeichnis-Literal, an dem die
#     Wortgrenzen-Regel ankert. Gemessen (BEO-003 im Beobachtungs-Register),
#     nicht geschlossen.
#
# KOPPLUNG. Wer $LIFECYCLE erweitert (ein fünftes Verzeichnis), muss auch
# harness/README.md §Sensors und diesen Kopf nachziehen — beide zählen die
# vier Namen aus, nicht aus einer gemeinsamen Quelle.
set -euo pipefail

PLANNING="docs/plan/planning"
LIFECYCLE="open next in-progress done"

usage() {
  cat >&2 <<'USAGE'
Aufruf: make slice-mv SLICE=<slice-NNN[-kurztitel[.md]]> TO=<open|next|in-progress|done>

  Bewegt den Slice per `git mv`, committet den reinen Move sofort, und zieht
  danach die Verweise nach — repo-weit eingehend (jede gemessene Präfix-Form)
  und innerhalb der Datei selbst ausgehend (präfixlose Ziele, die nach dem
  Wechsel ins falsche Verzeichnis zeigen); fielen Verweise an, committet es
  sie getrennt vom Move. Verlangt einen sauberen Arbeitsbaum. Grenzen: siehe
  Skriptkopf.
USAGE
}

# Erweiterte Regex-Metazeichen im Dateinamen entschärfen — ein Slice-Titel
# trägt mindestens einen Punkt (die Endung ".md"), der in ERE sonst "ein
# beliebiges Zeichen" bedeutet statt sich selbst.
re_escape() {
  printf '%s' "$1" | sed -e 's/[][\.^$*+?(){}|\\]/\\&/g'
}

# EINGEHEND: jedes Vorkommen von "$from/$base" in $file wird zu "$to/$base" —
# an einer Wortgrenze (Zeilenanfang oder ein Zeichen davor, das kein
# Bestandteil eines Wortes/Verzeichnisnamens ist — Buchstabe, Ziffer,
# Unterstrich UND Bindestrich zählen als Wortzeichen, weil "in-progress"
# selbst einen Bindestrich trägt und ein glued Präfix wie "sibling-open/"
# sonst faelschlich träfe), nicht an einer festen Präfix-Liste. Der Selbsttest
# prüft das an einer Stichprobe über Tiefe (0/1/2 Aufstiege) und Kontext
# (Klammer, Backtick, Zwischensegment) — die Zahl der im Bestand tatsächlich
# auftretenden Formen wandert mit dem Baum (Slice-Plan §1, erstes Kommando)
# und ist keine feste Liste, gegen die dieser Test zählt; Vollständigkeit
# gegen den lebenden Bestand misst `make docs-check` vor/nach einem realen
# Move (Slice-Plan §2 DoD (2)), nicht dieser Selbsttest.
rewrite_incoming_in_file() {  # $1=datei $2=base $3=from $4=to
  local file="$1" base="$2" from="$3" to="$4" esc_base
  esc_base="$(re_escape "$base")"
  sed -i -E "s#(^|[^A-Za-z0-9_-])$from/$esc_base#\\1$to/$base#g" "$file"
}

# AUSGEHEND: präfixlose "](slice-…)"-Ziele INNERHALB von $file, deren Datei im
# $from-Verzeichnis liegen geblieben ist, bekommen "../$from/" vorangestellt —
# sonst zeigt der Verweis nach dem Wechsel ins neue (falsche) Verzeichnis.
# Nur "slice-"-Ziele (Grenze 2 im Skriptkopf); ein Ziel, das nicht (mehr) unter
# $from liegt, bleibt unberührt (kein Rateversuch, welches Verzeichnis stimmt).
# Gibt die Anzahl umgehängter Ziele auf stdout aus — main() liest sie per
# Kommando-Substitution, statt Vorher/Nachher getrennt zu zählen.
rewrite_outgoing_bare_in_file() {  # $1=datei $2=from
  local file="$1" from="$2" t esc_t count=0
  while IFS= read -r t; do
    [ -n "$t" ] || continue
    [ -f "$PLANNING/$from/$t" ] || continue
    esc_t="$(re_escape "$t")"
    sed -i -E "s#\\]\\($esc_t\\)#](../$from/$t)#g" "$file"
    count=$((count + 1))
  done < <(grep -ohE '\]\(slice-[0-9][^)/]*\)' "$file" 2>/dev/null \
             | sed -E 's/^\]\(//; s/\)$//' | sort -u)
  printf '%d\n' "$count"
}

main() {
  local SLICE="${1:-}" TO="${2:-}"
  [ -n "$SLICE" ] && [ -n "$TO" ] || { usage; exit 2; }

  cd "$(dirname "$0")/../.."

  # Sauberer Arbeitsbaum (VORAUSSETZUNG im Skriptkopf) — sonst landet ein
  # fremder Diff in einem der beiden automatischen Commits weiter unten.
  if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "slice-mv: Arbeitsbaum nicht sauber — erst committen oder stashen (das Skript committet selbst, siehe Skriptkopf VORAUSSETZUNG)" >&2
    exit 2
  fi

  case " $LIFECYCLE " in
    *" $TO "*) ;;
    *) echo "slice-mv: '$TO' ist kein Lifecycle-Verzeichnis ($LIFECYCLE)" >&2; exit 2 ;;
  esac

  # Quelle finden: Präfix oder voller Dateiname, in genau EINEM Verzeichnis —
  # zwei Treffer (auch über Verzeichnisse hinweg) sind mehrdeutig und brechen
  # ab, statt zu raten.
  local found="" d f
  for d in $LIFECYCLE; do
    for f in "$PLANNING/$d/${SLICE%.md}"*.md; do
      [ -e "$f" ] || continue
      if [ -n "$found" ]; then
        echo "slice-mv: '$SLICE' ist mehrdeutig — $found und $f" >&2
        exit 2
      fi
      found="$f"
    done
  done
  [ -n "$found" ] || { echo "slice-mv: kein Slice '$SLICE' unter $PLANNING/" >&2; exit 2; }

  local base from
  base="$(basename "$found")"
  from="$(basename "$(dirname "$found")")"
  if [ "$from" = "$TO" ]; then
    echo "slice-mv: '$base' liegt bereits in $TO/" >&2
    exit 2
  fi

  mkdir -p "$PLANNING/$TO"
  git mv "$found" "$PLANNING/$TO/$base"

  # Commit 1 — reiner Move, kein Byte Inhalt veraendert (Hard Rule 3.3): der
  # Arbeitsbaum war laut Vorpruefung sauber, `git mv` ist die einzige gestagte
  # Aenderung, also committet dieser Aufruf genau sie.
  git commit -q -m "slice-mv: $base  $from/ -> $TO/ (reiner Move)"

  # EINGEHEND, repo-weit — außer zwei eingefrorenen Bereichen: die vendored
  # Baseline (unveränderter Fremdtext, .harness/baseline/**) und
  # docs/reviews/** (Zeitdokumente, .d-check.yml codepaths.exempt-paths: ihre
  # Lifecycle-Pfade veralten per Definition und werden nicht nachgezogen).
  # docs/plan/planning/done/** ist ANDERS als diese zwei — NICHT ausgenommen
  # und wird MIT nachgezogen: `codepaths.exempt-paths` nennt nur
  # docs/reviews/**, ein Closure-Verweis in einer done/-Datei ist ein realer,
  # von docs-check geprüfter Link und bricht wie jeder andere.
  local in_count=0 rf
  local -a touched=()
  while IFS= read -r rf; do
    [ -n "$rf" ] || continue
    rewrite_incoming_in_file "$rf" "$base" "$from" "$TO"
    touched+=("$rf")
    in_count=$((in_count + 1))
  done < <(git grep -l -F -e "$from/$base" -- \
             ':!.harness/baseline' ':!docs/reviews' \
             2>/dev/null || true)

  # AUSGEHEND — nur in der bewegten Datei selbst, an ihrem NEUEN Ort.
  local out_count
  out_count="$(rewrite_outgoing_bare_in_file "$PLANNING/$TO/$base" "$from")"
  [ "$out_count" -gt 0 ] && touched+=("$PLANNING/$TO/$base")

  # Commit 2 — Inhaltsänderung, GETRENNT vom Move (Hard Rule 3.3), nur wenn
  # ueberhaupt ein Verweis anfiel; explizite Pfade statt `git add -A`, damit
  # kein anderer (eigentlich schon per VORAUSSETZUNG ausgeschlossener) Diff
  # mitgenommen wird.
  if [ "${#touched[@]}" -gt 0 ]; then
    git add -- "${touched[@]}"
    git commit -q -m "slice-mv: Verweise auf $base nach $TO/ nachgezogen ($in_count eingehend, $out_count ausgehend)"
  fi

  echo "slice-mv ok: $base  $from/ -> $TO/"
  echo "  Commit 1 (reiner Move): $from/$base -> $TO/$base"
  echo "  eingehend: $in_count Datei(en) mit Verweisen nachgezogen"
  echo "  ausgehend: $out_count präfixloses Ziel(e) in der bewegten Datei auf ../$from/ umgehängt"
  if [ "${#touched[@]}" -gt 0 ]; then
    echo "  Commit 2 (Inhalt, getrennt vom Move — AGENTS.md §3.3): $in_count eingehend, $out_count ausgehend"
  else
    echo "  Kein Verweis zu ziehen — kein zweiter Commit nötig."
  fi
}

# BASH_SOURCE-Wächter: test/slice-mv.bats sourced dieses Skript, um
# rewrite_incoming_in_file/rewrite_outgoing_bare_in_file direkt zu prüfen,
# ohne main() (und damit git mv) auszulösen — sonst misst der Selbsttest sich
# selbst statt der Ersetzung.
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
  main "$@"
fi

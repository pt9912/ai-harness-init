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
# ZUSAGE. `make slice-mv SLICE=slice-<Kennung> TO=<open|next|in-progress|done>`
# bewegt den Slice per `git mv` und committet den reinen Move SOFORT als
# eigenen Commit (Hard Rule 3.3: kein Byte Inhalt veraendert, die
# Rename-Erkennung greift). Danach zieht es reale Verweise nach — EINGEHEND
# (jede Praefix-Form auf die bewegte Datei, repo-weit, dazu die praefixlose
# Link-Form aus den Geschwistern im Ausgangsverzeichnis) UND AUSGEHEND
# (praefixlose Ziele INNERHALB der bewegten Datei, die nach dem Wechsel ins
# falsche Verzeichnis zeigen; getroffen wird eine nummerierte wie eine
# benannte Slice-Kennung gleichermassen) — und committet diese
# Inhaltsaenderung, falls welche anfielen, als ZWEITEN, vom Move getrennten
# Commit; fiel keine an, bleibt es beim einen Move-Commit. test/slice-mv.bats
# deckt beide Ersetzungsrichtungen und die Teilstring-Falle (slice-13 steckt
# in slice-130 bzw. slice-abc in slice-abc-erweitert), ohne ein Repo zu
# bewegen — es ruft die Ersetzungs-Funktionen direkt auf (Quelle: dieses
# Skript, per BASH_SOURCE-Waechter ohne Nebenwirkung ladbar). Die
# Zwei-Commit-Sequenz selbst ist NICHT per bats gedeckt — main() braucht ein
# echtes `git`-Repo, das gepinnte bats-Image fuehrt kein `git`-Binaer (wie
# test/slice-mv.bats am Dateiende selbst festhaelt); Beleg ist ein manueller
# `git show --stat`-Lauf auf den Move-Commit.
#
# VORAUSSETZUNG. Weil das Skript selbst committet, verlangt es einen sauberen
# Arbeitsbaum (keine gestagten oder ungestagten Aenderungen an getrackten
# Dateien), BEVOR es startet — sonst landet ein fremder, zufaellig
# anwesender Diff im automatischen Move- oder Inhalts-Commit. Ein Verstoss
# bricht den Aufruf vor dem ersten `git mv` (main(), erste Pruefung).
#
# BELEG (DoD (2) im Slice-Plan slice-144, fuer den heutigen Zwei-Commit-Stand
# nach 8737ca7 — "es lief" reicht der DoD nicht). Eigener Scratch-Clone,
# sauberer Checkout, echter Move mit beiden Richtungen zugleich (slice-069,
# open/ -> next/ — traegt acht eingehende Referenzen INKLUSIVE einer aus
# docs/reviews/2026-07-31-adr-0012-proposed-review.md, dazu ein praefixloses
# ausgehendes Ziel auf slice-070):
#   vorher:  make docs-check  ->  d-check: 480 Datei(en) geprueft, 0 Befund(e)
#   danach:  make docs-check  ->  d-check: 480 Datei(en) geprueft, 8 Befund(e)
#            alle acht target-missing, alle acht praefixlose Geschwister
#            UNTER open/ ohne Verzeichnis-Segment (Grenze 3 unten) — keiner in
#            docs/reviews/** oder docs/plan/planning/done/**. `git show --stat`
#            auf Commit 1 zeigt einen reinen Rename (0 insertions/0 deletions);
#            Commit 2 traegt ausschliesslich Inhalt, darunter den
#            docs/reviews-Treffer.
#   Grenze dieser Messung: sie belegt die Zwei-Commit-Sequenz, nicht die Menge
#   der Verweis-Formen, die main() nachzieht. Welche Formen das sind, sagen die
#   GRENZEN unten; die Messung dazu steht in harness/sensors/slice-mv.md
#   §Kanten. Stand der Messung: 8737ca7. Die konkreten Zahlen wandern mit dem
#   Baum und sind kein Erwartungswert (MR-025 Setzung 2).
#
# ZWEITE MESSUNG (ADR-0042 Festlegung 2: `docs/plan/adr` zusätzlich zu
# `.harness/baseline` in eingehend_ausgenommene_pfade — die erste Messung oben
# deckt nur die Baseline-Ausnahme, diese hier den Nachtrag). Der Nachtrag ist
# in main() SELBST gedeckt, nicht nur in eingehend_ausgenommene_pfade() als
# reiner Funktion (die bats-Faelle in test/slice-mv.bats pruefen nur die
# Liste, nie main()s Gebrauch davon):
# TestSliceMvEchtUebergehtAcceptedADRBeimNachzug
# (cmd/ai-harness-init/slice_mv_echt_test.go, Teil von `make test-go`) kopiert
# dieses Skript in ein echtes Scratch-Repo mit einer ADR und einem
# Review-Report, die beide per Praefix-Form dieselbe Slice-Datei verlinken,
# und fuehrt main() als echten Prozess aus: der Report wird nachgezogen, die
# ADR bleibt unveraendert.
# test/mutations/315-slice-mv-main-verliert-ausnahmeliste.sh nimmt main() die
# Verbindung zur Liste weg (Pathspec-Uebergabe im `git grep`-Aufruf unten
# entfernt) und faerbt genau diesen Test rot.
#
# GRENZEN (gemessen, nicht vermutet — vier Stück):
# (1) Das Werkzeug zieht PFADE nach, keine ZUSTANDSSÄTZE. Eine Zeile "In
#     Arbeit: <slice>" bleibt nach dem Wechsel stehen; ihr Verweis wird
#     richtig, ihre Aussage falsch. Welcher Satz einen Zustand behauptet, ist
#     Urteil, kein Match.
# (2) WELLE-Plan-Dateien wechseln beim Closure-Move die Verzeichnis-TIEFE
#     (flach -> done/), nicht nur das Verzeichnis — eine andere Ersetzung als
#     der Tausch auf gleicher Ebene. Dieses Werkzeug bewegt nur SLICE-Dateien
#     (SLICE=slice-<Kennung>) und ersetzt in der Ausgehend-Richtung darum
#     auch nur "slice-"-Ziele; ein präfixloses "welle-"-Ziel bleibt unberührt.
# (3) Die praefixlose EINGEHEND-Ersetzung (rewrite_incoming_bare_in_file)
#     erkennt einen Verweis ohne Verzeichnis-Segment nur als Markdown-Link
#     "](<datei>)" oder "](<datei>#…)" und nur in den getrackten Dateien, die
#     flach im $from-Verzeichnis liegen — dort loest der blanke Name gegen das
#     Verzeichnis auf, das die Datei verlassen hat. Eine andere Schreibweise
#     desselben Verweises ("](./<datei>)", "](<<datei>>)", eine
#     Referenz-Definition "[x]: <datei>") bleibt stehen; im Bestand der drei
#     Ausgangsverzeichnisse zaehlt sie (kein Erwartungswert)
#       git grep -hE '\]\(\./slice-|\]\(<slice-|^\[[^]]*\]: *slice-' -- \
#         docs/plan/planning/open docs/plan/planning/next \
#         docs/plan/planning/in-progress | wc -l
#     Markdown liest die Ersetzung nicht: steht die Link-Syntax selbst mit
#     genau diesem Namen in einem Code-Span oder Code-Block, wird sie
#     mitersetzt. Welche Dateien main() ihr uebergibt, faehrt keine bats-Stufe;
#     die Messung dazu steht in harness/sensors/slice-mv.md §Kanten.
# (4) Die AUSGEHEND-Ersetzung trifft nur die lowercase-Kebab-Form einer
#     benannten Kennung (Zeichenklasse "[0-9a-z]"). Die zweite Namensform aus
#     MR-057 Setzung 1 — das Präfix eines vorhandenen Ankers (LH-*, ADR-*,
#     CO-*) — ist in diesem Repo großgeschrieben und trifft die Zeichenklasse
#     nicht: ein Ziel "](slice-ADR-0042-nachzug.md)" bleibt unerkannt und
#     zeigt nach dem Wechsel ins falsche Verzeichnis. Dieselbe Grenze steht in
#     internal/archive/stub.go bei sliceRE.
#
# KOPPLUNG. Wer $LIFECYCLE erweitert (ein fünftes Verzeichnis), muss auch
# harness/README.md §Sensors und diesen Kopf nachziehen — beide zählen die
# vier Namen aus, nicht aus einer gemeinsamen Quelle.
set -euo pipefail

PLANNING="docs/plan/planning"
LIFECYCLE="open next in-progress done"

# psed_i — portables `sed -i`: BSD-sed (macOS) verlangt nach `-i` zwingend eine eigene
# Backup-Extension als naechstes Token (auch leer) und verschluckt sonst das naechste
# Argument dafuer — ein blosses `sed -i -E SCRIPT FILE` (Extension = "-E", -E greift
# nicht) scheitert dort mit "\1 not defined in the RE", auf GNU-sed nicht. Kein -i:
# Ausgabe in eine temporaere Datei, dann in die Zieldatei GESCHRIEBEN statt ueber sie
# verschoben — `mktemp` legt die temporaere Datei mit 0600 an, und `mv` traegt diesen
# Modus auf das Ziel; ein `d-check`-Container liest als Nicht-Root, und ein derart auf
# 0600 gefallenes Ziel wird dort unlesbar. `cat >` in die bestehende Zieldatei behaelt
# deren Inode und damit ihren Modus. Aufruf wie `sed -i`: optionale Flags, dann SCRIPT,
# dann FILE als letztes Argument.
psed_i() {
  local tmp ziel
  tmp="$(mktemp -p "${TMPDIR:-/tmp}")"
  ziel="${!#}"
  sed "$@" >"$tmp"
  cat "$tmp" >"$ziel"
  rm -f "$tmp"
}

usage() {
  cat >&2 <<'USAGE'
Aufruf: make slice-mv SLICE=slice-<Kennung>[-kurztitel[.md]] TO=<open|next|in-progress|done>

  Bewegt den Slice per `git mv`, committet den reinen Move sofort, und zieht
  danach die Verweise nach — repo-weit eingehend (jede gemessene Präfix-Form,
  dazu präfixlose Links aus den Geschwistern im Ausgangsverzeichnis)
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

# EINGEHEND-Ausnahmeliste: `git grep`-Pathspecs, die der eingehende
# Verweis-Nachzug NICHT durchsucht — eine Zeile je Eintrag. `main()` liest sie
# hier aus, test/slice-mv.bats ebenso (Mitgliedschaft UND Nicht-Mitgliedschaft),
# damit beide dieselbe Liste pruefen statt zwei Fassungen zu pflegen.
#
# `.harness/baseline` ist unveraenderter Fremdtext. `docs/plan/adr` ist
# ADR-0042 Festlegung 2: eine Accepted-ADR bekommt keinen Byte-Nachzug — der
# Go-Traeger zieht dieselbe Grenze in internal/archive/scan.go
# (AusgenommenePfadeNachzug). `docs/reviews` steht ABSICHTLICH NICHT darin
# (ADR-0033 Abnahme-Kriterium 1): Review-Reports sind reale, von `docs-check`
# gepruefte Verweisziele.
eingehend_ausgenommene_pfade() {
  printf '%s\n' ':!.harness/baseline' ':!docs/plan/adr'
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
  psed_i -E "s#(^|[^A-Za-z0-9_-])$from/$esc_base#\\1$to/$base#g" "$file"
}

# EINGEHEND, PRAEFIXLOS: jeder Markdown-Link "](<base>)" oder "](<base>#…)" in
# $file wird zu "](../<to>/<base>…)". main() ruft das fuer die Geschwister im
# Ausgangsverzeichnis der bewegten Datei auf — dort loest der blanke Name gegen
# das Verzeichnis auf, das die Datei gerade verlassen hat. Die Regel ankert an
# der Link-Klammer "](" und am Ende des Namens (")" oder "#"): ein Code-Span mit
# dem blossen Namen, ein Tree-Operand "<sha>:<base>", ein Verweis mit
# Verzeichnis-Segment und ein laengerer Name mit demselben Anfang bleiben
# stehen. Die Regel liest kein Markdown: steht die Link-Syntax selbst mit
# genau diesem Namen in einem Code-Span oder Code-Block, wird sie mitersetzt
# (Grenze 3 im Skriptkopf). Gibt die Anzahl ersetzter Links auf stdout aus.
rewrite_incoming_bare_in_file() {  # $1=datei $2=base $3=to
  local file="$1" base="$2" to="$3" esc_base count
  esc_base="$(re_escape "$base")"
  count="$( { grep -oE "[]]\\(${esc_base}[)#]" "$file" 2>/dev/null || true; } | wc -l)"
  psed_i -E "s|[]]\\($esc_base([)#])|](../$to/$base\\1|g" "$file"
  printf '%d\n' "$((count))"
}

# AUSGEHEND: präfixlose "](slice-…)"-Ziele INNERHALB von $file, deren Datei im
# $from-Verzeichnis liegen geblieben ist, bekommen "../$from/" vorangestellt —
# sonst zeigt der Verweis nach dem Wechsel ins neue (falsche) Verzeichnis.
# Nur "slice-"-Ziele (Grenze 2 im Skriptkopf); ein Ziel, das nicht (mehr) unter
# $from liegt, bleibt unberührt (kein Rateversuch, welches Verzeichnis stimmt).
# Das Fundmuster trifft eine nummerierte Kennung (slice-NNN…) ebenso wie eine
# benannte (slice-<slug>, lowercase Kebab-Case ohne Ziffern-Praefix).
# Gibt die Anzahl umgehängter Ziele auf stdout aus — main() liest sie per
# Kommando-Substitution, statt Vorher/Nachher getrennt zu zählen.
rewrite_outgoing_bare_in_file() {  # $1=datei $2=from
  local file="$1" from="$2" t esc_t count=0
  while IFS= read -r t; do
    [ -n "$t" ] || continue
    [ -f "$PLANNING/$from/$t" ] || continue
    esc_t="$(re_escape "$t")"
    psed_i -E "s#\\]\\($esc_t\\)#](../$from/$t)#g" "$file"
    count=$((count + 1))
  done < <(grep -ohE '\]\(slice-[0-9a-z][^)/]*\)' "$file" 2>/dev/null \
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

  # EINGEHEND, repo-weit — außer der Liste aus eingehend_ausgenommene_pfade()
  # (vendored Baseline, Accepted-ADRs). docs/reviews/** ist NICHT ausgenommen:
  # dort steht zwar in .d-check.yml codepaths.exempt-paths und
  # ids.*.exempt-paths (die Zeitdokumente sind von der Inline-Code-Pfadpflicht
  # und der ID-Linkpflicht befreit) — aber links/anchors tragen keine solche
  # Ausnahme und prüfen jeden echten Markdown-Link dort wie überall sonst.
  # Ein Verweis auf die bewegte Datei bricht dort also genauso wie in
  # docs/plan/planning/done/**, und beide werden darum mitgezogen; nur der
  # Pfad ändert sich, die umgebende Aussage bleibt Zeitdokument (Grenze 1).
  local -a in_pathspec=()
  while IFS= read -r p; do in_pathspec+=("$p"); done < <(eingehend_ausgenommene_pfade)

  local in_count=0 rf
  local -a touched=()
  while IFS= read -r rf; do
    [ -n "$rf" ] || continue
    rewrite_incoming_in_file "$rf" "$base" "$from" "$TO"
    touched+=("$rf")
    in_count=$((in_count + 1))
  done < <(git grep -l -F -e "$from/$base" -- "${in_pathspec[@]}" 2>/dev/null || true)

  # EINGEHEND, praefixlos — in den getrackten Geschwistern, die flach im
  # Ausgangsverzeichnis liegen (":(glob)" haelt "*" innerhalb eines Segments),
  # unter derselben Ausnahmeliste. Eine Datei, die die Praefix-Ersetzung schon
  # getroffen hat, zaehlt in $in_count nicht doppelt.
  local bare_count=0 n sf
  while IFS= read -r sf; do
    [ -n "$sf" ] || continue
    n="$(rewrite_incoming_bare_in_file "$sf" "$base" "$TO")"
    [ "$n" -gt 0 ] || continue
    bare_count=$((bare_count + n))
    case " ${touched[*]-} " in
      *" $sf "*) ;;
      *) touched+=("$sf"); in_count=$((in_count + 1)) ;;
    esac
  done < <(git grep -l -F -e "]($base" -- ":(glob)$PLANNING/$from/*.md" "${in_pathspec[@]}" 2>/dev/null || true)

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
    git commit -q -m "slice-mv: Verweise auf $base nach $TO/ nachgezogen ($in_count eingehend, $out_count ausgehend, $bare_count praefixlos aus $from/)"
  fi

  echo "slice-mv ok: $base  $from/ -> $TO/"
  echo "  Commit 1 (reiner Move): $from/$base -> $TO/$base"
  echo "  eingehend: $in_count Datei(en) mit Verweisen nachgezogen, darin $bare_count praefixlose(r) Link(s) aus Geschwistern unter $from/"
  echo "  ausgehend: $out_count präfixloses Ziel(e) in der bewegten Datei auf ../$from/ umgehängt"
  if [ "${#touched[@]}" -gt 0 ]; then
    echo "  Commit 2 (Inhalt, getrennt vom Move — AGENTS.md §3.3): $in_count eingehend, $out_count ausgehend, $bare_count praefixlos aus $from/"
  else
    echo "  Kein Verweis zu ziehen — kein zweiter Commit nötig."
  fi
}

# BASH_SOURCE-Wächter: test/slice-mv.bats sourced dieses Skript, um
# die Ersetzungs-Funktionen direkt zu prüfen,
# ohne main() (und damit git mv) auszulösen — sonst misst der Selbsttest sich
# selbst statt der Ersetzung.
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
  main "$@"
fi

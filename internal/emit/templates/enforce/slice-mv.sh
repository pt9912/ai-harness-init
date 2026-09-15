#!/usr/bin/env bash
# slice-mv.sh — Lifecycle-Wechsel eines Slice UND der Verweise, die er bricht,
# emittiert von ai-harness-init.
#
# ZUSAGE. `make slice-mv SLICE=slice-<Kennung> TO=<open|next|in-progress|done>`
# bewegt den Slice per `git mv` und committet den reinen Move SOFORT als eigenen
# Commit (ein Move und eine Inhaltsaenderung in einem Commit verlieren die
# Rename-Erkennung). Danach zieht es reale Verweise nach — EINGEHEND (jede
# Praefix-Form auf die bewegte Datei, repo-weit) UND AUSGEHEND (praefixlose
# Ziele INNERHALB der bewegten Datei, die nach dem Wechsel ins falsche
# Verzeichnis zeigen; getroffen wird eine nummerierte wie eine benannte
# Slice-Kennung gleichermassen) — und committet diese Inhaltsaenderung, falls
# welche anfiel, als ZWEITEN, vom Move getrennten Commit; fiel keine an, bleibt
# es beim einen Move-Commit.
#
# WAS DIESE COMMITS ALS KENNUNG TRAGEN. Die zwei Messages nennen den bewegten
# Slice mit seinem DATEINAMEN — die Kennung eines Slice ist ihr Dateiname, und
# beide Messages tragen sie damit verbatim. Ob eine Kennungs-Menge dieses Repos
# den Namen trifft und ob ein Waechter sie am Commit prueft, entscheidet dieses
# Repo: diese Datei fuehrt keine Kennungs-Menge und setzt keine voraus. Ein Repo
# ohne Commits-Waechter committet hier also kennungsfrei im Sinne seiner eigenen
# Konfiguration.
#
# VORAUSSETZUNG. Weil dieses Skript selbst committet, verlangt es einen sauberen
# Arbeitsbaum (keine gestagten oder ungestagten Aenderungen an getrackten
# Dateien), BEVOR es startet — sonst landet ein fremder, zufaellig anwesender
# Diff in einem der beiden Commits. Ein Verstoss bricht den Aufruf vor dem
# ersten `git mv` ab (main(), erste Pruefung).
#
# REPO-POLITIK statt Mechanik: die Pfade, die der EINGEHEND-Nachzug ausnimmt
# (Variable SLICE_MV_AUSGENOMMENE_PFADE unten). Die zwei Vorgaben sind
# Ableitungen aus dem mitemittierten Regelwerk, keine Vorliebe des Werkzeugs:
# `.harness/baseline` ist unveraenderter Fremdtext, und eine `Accepted`-ADR
# wird nach der Hard Rule fuer Accepted-ADRs nicht inhaltlich ueberschrieben.
# Ein Repo mit einer anderen Politik — weitere Baeume, oder ein anderer Umgang
# mit seinen Zeitdokumenten — setzt die Variable; sie zu aendern ist der
# markierte Ort dafuer. Diese Datei selbst wird bei jedem Bootstrap kanonisch
# neu geschrieben, eine Aenderung an ihr ueberlebt den naechsten Lauf nicht.
#
# GRENZEN (vier, jede mit ihrer Ursache):
# (1) Das Werkzeug zieht PFADE nach, keine ZUSTANDSSAETZE. Eine Zeile
#     "In Arbeit: <slice>" bleibt nach dem Wechsel stehen; ihr Verweis wird
#     richtig, ihre Aussage falsch. Welcher Satz einen Zustand behauptet, ist
#     Urteil, kein Match.
# (2) Ein WELLE-Plan wechselt beim Closure-Move die Verzeichnis-TIEFE (flach ->
#     done/), nicht nur das Verzeichnis — eine andere Ersetzung als der Tausch
#     auf gleicher Ebene. Dieses Werkzeug bewegt nur SLICE-Dateien
#     (SLICE=slice-<Kennung>) und ersetzt in der Ausgehend-Richtung darum auch
#     nur "slice-"-Ziele; ein praefixloses "welle-"-Ziel bleibt unberuehrt.
# (3) Praefixlose EINGEHENDE Verweise — eine andere, im $from-Verzeichnis
#     bleibende Datei referenziert die bewegte Datei ohne jedes
#     Verzeichnis-Segment ("[x](slice-N….md)") — erkennt die
#     Eingehend-Ersetzung NICHT: ihr fehlt das Verzeichnis-Literal, an dem die
#     Wortgrenzen-Regel ankert. Was danach tot bleibt, meldet das Doku-Gate des
#     Repos als toten Link; von Hand nachzuziehen ist der vorgesehene Weg.
# (4) Die AUSGEHEND-Ersetzung trifft die lowercase-Kebab-Form einer benannten
#     Kennung (Zeichenklasse "[0-9a-z]"). Eine Slice-Kennung, die das Praefix
#     eines vorhandenen Ankers traegt (LH-*, ADR-*, CO-*) und darum
#     Grossbuchstaben fuehrt, bleibt unerkannt.
set -euo pipefail

PLANNING="docs/plan/planning"
LIFECYCLE="open next in-progress done"

# REPO-POLITIK (s. Kopf): die `git grep`-Pathspecs, die der EINGEHEND-Nachzug
# NICHT durchsucht — whitespace-getrennt, eine Angabe je Eintrag. Die Vorgabe
# ist aus dem mitemittierten Regelwerk abgeleitet (Fremdtext und die Hard Rule
# fuer Accepted-ADRs). Ein Repo, das weitere Baeume ausnimmt oder Zeitdokumente
# anders behandelt, setzt diese Variable — im Aufruf oder in seinem eigenen
# Make-Fragment; die Datei selbst ist tool-eigen und wird kanonisch neu
# geschrieben.
SLICE_MV_AUSGENOMMENE_PFADE="${SLICE_MV_AUSGENOMMENE_PFADE:-:!.harness/baseline :!docs/plan/adr}"

usage() {
  cat >&2 <<'USAGE'
Aufruf: make slice-mv SLICE=slice-<Kennung>[-kurztitel[.md]] TO=<open|next|in-progress|done>

  Bewegt den Slice per `git mv`, committet den reinen Move sofort, und zieht
  danach die Verweise nach — repo-weit eingehend und innerhalb der Datei selbst
  ausgehend; fielen Verweise an, committet es sie getrennt vom Move. Verlangt
  einen sauberen Arbeitsbaum. Grenzen: siehe Skriptkopf.
USAGE
}

# Erweiterte Regex-Metazeichen im Dateinamen entschaerfen — ein Slice-Titel
# traegt mindestens einen Punkt (die Endung ".md"), der in ERE sonst "ein
# beliebiges Zeichen" bedeutet statt sich selbst.
re_escape() {
  printf '%s' "$1" | sed -e 's/[][\.^$*+?(){}|\\]/\\&/g'
}

# Die Ausnahmeliste als reine Funktion — main() liest sie hier aus, und ein
# Test kann sie rufen, ohne ein Repo zu bewegen. Zerlegt wird an Leerraum, weil
# die Variable als eine Zeile mit mehreren Eintraegen gesetzt wird.
eingehend_ausgenommene_pfade() {
  local p
  for p in $SLICE_MV_AUSGENOMMENE_PFADE; do printf '%s\n' "$p"; done
}

# EINGEHEND: jedes Vorkommen von "$from/$base" in $file wird zu "$to/$base" —
# an einer Wortgrenze (Zeilenanfang oder ein Zeichen davor, das kein Bestandteil
# eines Wortes/Verzeichnisnamens ist — Buchstabe, Ziffer, Unterstrich UND
# Bindestrich zaehlen als Wortzeichen, weil "in-progress" selbst einen
# Bindestrich traegt und ein glued Praefix wie "sibling-open/" sonst faelschlich
# traefe), nicht an einer festen Praefix-Liste. Das deckt jede Praefix-Tiefe
# (vom nackten Verzeichnisnamen bis zum doppelten Aufstieg ueber
# "docs/plan/planning/") mit einer Regel statt einer Liste, die driftet.
rewrite_incoming_in_file() {  # $1=datei $2=base $3=from $4=to
  local file="$1" base="$2" from="$3" to="$4" esc_base
  esc_base="$(re_escape "$base")"
  sed -i -E "s#(^|[^A-Za-z0-9_-])$from/$esc_base#\\1$to/$base#g" "$file"
}

# AUSGEHEND: praefixlose "](slice-…)"-Ziele INNERHALB von $file, deren Datei im
# $from-Verzeichnis liegen geblieben ist, bekommen "../$from/" vorangestellt —
# sonst zeigt der Verweis nach dem Wechsel ins neue (falsche) Verzeichnis.
# Nur "slice-"-Ziele (Grenze 2 im Skriptkopf); ein Ziel, das nicht (mehr) unter
# $from liegt, bleibt unberuehrt (kein Rateversuch, welches Verzeichnis stimmt).
# Das Fundmuster trifft eine nummerierte Kennung (slice-NNN…) ebenso wie eine
# benannte (slice-<slug>, lowercase Kebab-Case ohne Ziffern-Praefix).
# Gibt die Anzahl umgehaengter Ziele auf stdout aus — main() liest sie per
# Kommando-Substitution, statt Vorher/Nachher getrennt zu zaehlen.
rewrite_outgoing_bare_in_file() {  # $1=datei $2=from
  local file="$1" from="$2" t esc_t count=0
  while IFS= read -r t; do
    [ -n "$t" ] || continue
    [ -f "$PLANNING/$from/$t" ] || continue
    esc_t="$(re_escape "$t")"
    sed -i -E "s#\\]\\($esc_t\\)#](../$from/$t)#g" "$file"
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

  # Quelle finden: Praefix oder voller Dateiname, in genau EINEM Verzeichnis —
  # zwei Treffer (auch ueber Verzeichnisse hinweg) sind mehrdeutig und brechen
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

  # Commit 1 — reiner Move, kein Byte Inhalt veraendert: der Arbeitsbaum war
  # laut Vorpruefung sauber, `git mv` ist die einzige gestagte Aenderung, also
  # committet dieser Aufruf genau sie.
  git commit -q -m "slice-mv: $base  $from/ -> $TO/ (reiner Move)"

  # EINGEHEND, repo-weit — ausser der Liste aus eingehend_ausgenommene_pfade().
  # Zeitdokumente sind NICHT ausgenommen: `done/`, `docs/reviews/` und die
  # Belege des Registers sind reale Verweisziele, auf die das Doku-Gate sieht;
  # ein Verweis auf die bewegte Datei bricht dort genauso wie ueberall sonst.
  # Nur der Pfad aendert sich, die umgebende Aussage bleibt stehen (Grenze 1).
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

  # AUSGEHEND — nur in der bewegten Datei selbst, an ihrem NEUEN Ort.
  local out_count
  out_count="$(rewrite_outgoing_bare_in_file "$PLANNING/$TO/$base" "$from")"
  [ "$out_count" -gt 0 ] && touched+=("$PLANNING/$TO/$base")

  # Commit 2 — Inhaltsaenderung, GETRENNT vom Move, nur wenn ueberhaupt ein
  # Verweis anfiel; explizite Pfade statt `git add -A`, damit kein anderer
  # (eigentlich schon per VORAUSSETZUNG ausgeschlossener) Diff mitgenommen wird.
  if [ "${#touched[@]}" -gt 0 ]; then
    git add -- "${touched[@]}"
    git commit -q -m "slice-mv: Verweise auf $base nach $TO/ nachgezogen ($in_count eingehend, $out_count ausgehend)"
  fi

  echo "slice-mv ok: $base  $from/ -> $TO/"
  echo "  Commit 1 (reiner Move): $from/$base -> $TO/$base"
  echo "  eingehend: $in_count Datei(en) mit Verweisen nachgezogen"
  echo "  ausgehend: $out_count praefixloses Ziel(e) in der bewegten Datei auf ../$from/ umgehaengt"
  if [ "${#touched[@]}" -gt 0 ]; then
    echo "  Commit 2 (Inhalt, getrennt vom Move): $in_count eingehend, $out_count ausgehend"
  else
    echo "  Kein Verweis zu ziehen — kein zweiter Commit noetig."
  fi
}

# BASH_SOURCE-Waechter: ein Test sourced dieses Skript, um
# rewrite_incoming_in_file/rewrite_outgoing_bare_in_file direkt zu pruefen,
# ohne main() (und damit git mv) auszuloesen — sonst misst der Test sich selbst
# statt der Ersetzung.
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
  main "$@"
fi

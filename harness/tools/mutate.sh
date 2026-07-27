#!/usr/bin/env bash
# mutate.sh — Mutations-Sensor fuer AGENTS.md Hard Rule 3.6 ("keine Zusage ohne
# rot gesehenes Gegenbeispiel"). Faehrt ein kuratiertes Set aus
# (Mutation -> erwartet rot faerbender Test) und meldet jeden Waechter, der
# seine Zaehne verloren hat.
#
# WARUM ES DIESES SKRIPT GIBT: 3.6 ist die einzige Hard Rule, die am RUHENDEN
# Baum nicht pruefbar ist — ein Test mit Zaehnen und einer ohne sehen identisch
# aus. Der Unterschied ist eine Eigenschaft der Entstehungsgeschichte. Die
# einzige Messung, die ihn sichtbar macht, ist Mutation. Ohne dieses Skript
# laege 3.6 nur im Feedforward-Quadranten, und Modul 9 nennt das "halb
# durchgesetzt".
#
# WAS ES NICHT LEISTET:
#   - HALTBARKEIT statt ENTSTEHUNG: ein neu geschriebener Waechter ohne Mutation
#     im Set bleibt unbewacht — kuratiert heisst unvollstaendig. Die
#     Entstehungs-Seite haengt an Schritt 19 der Pre-completion-Checkliste.
#   - KEINE Aussage ueber Waechter, die kein Fall adressiert. Der Treiber selbst
#     ist teilweise bewacht (test/mutate-driver.bats + Fall 09 decken failure_form,
#     nicht die uebrigen run_case-Zweige — Review-Befund NR-2, dieselbe
#     kuratiert-ist-unvollstaendig-Grenze).
#
# STALE LOCK (Review-Befund NR-1): der mkdir-Mutex traegt keine PID. Ein hart
# abgebrochener Lauf (SIGKILL, Stromausfall — nicht INT/TERM, die raeumt der trap)
# hinterlaesst .harness/state/mutate.lock, und jeder weitere Lauf bricht ab, bis
# es von Hand entfernt wird. Bewusst fail-closed: ein liegengebliebener Lock
# blockiert laut, statt einen zweiten Lauf auf denselben Baum zu lassen. Die
# Abbruch-Meldung nennt den Pfad; der Lock ist gitignored (.harness/state/).
# Nicht mehr auf `make test` beschraenkt: `# verify: smoke` faehrt einen Fall
# gegen den Tier-2-Sensor. Die frueher hier stehende Zusage "Waechter in
# make smoke sind bauartbedingt nicht abdeckbar" war eine Scope-Aussage, die als
# Architektur-Aussage auftrat (Review-Befund slice-026 F-5).
# Kein node/jq/python — bash, coreutils, GNU sed. `sed` statt `perl` (Befund F-4:
# die frueheren Faelle brauchten Host-perl, waehrend der Kopf "bash + coreutils"
# zusagte). Die Faelle nutzen `sed -i` und GNU-BRE-Escapes, sind also NICHT strikt
# POSIX — die zwischenzeitliche POSIX-Zusage griff weiter als der Code (N-3).
#
# FAIL-CLOSED, fuenf Bedingungen. Der Sensor misst die ABWESENHEIT von Rot und
# koennte darum selbst still gruen werden; jede dieser Bedingungen schliesst
# einen Weg dorthin:
#   1. Das Mutations-Skript scheitert            -> Befund (nicht uebersprungen).
#   2. Die Mutation aendert die Datei NICHT      -> Befund. Das faengt den
#      veralteten Patch: waere er nur wirkungslos, saehe "kein Rot" wie
#      "Zaehne intakt" aus.
#   3. Der Sensor (`make test` bzw. `make smoke`, s. `# verify:`) bleibt GRUEN
#      -> Befund. Der eigentliche Zweck.
#   4. Der Sensor wird rot, aber der ERWARTETE Waechter steht nicht in seiner
#      FEHLSCHLAG-Ausgabe -> Befund. Rot aus dem falschen Grund ist kein Beleg.
#   5. Die Zieldatei(en) im HOST-Baum aendern sich waehrend eines Falls -> Befund und
#      ABBRUCH. Die Isolation ist dann gebrochen (oder es wurde parallel editiert);
#      beides macht jede weitere Messung wertlos.
#
# NICHT in `make gates` — der Grund ist die LAUFZEIT (ein voller `make test`-Zyklus
# je Fall, gemessen rund 7 s bei warmem Cache; bei 70+ Faellen eine Viertelstunde).
# Der frueher hier stehende Grund („dieser Sensor veraendert den Arbeitsbaum") ist
# mit slice-047 entfallen und wurde ERSETZT, nicht ergaenzt — eine gewanderte Grenze
# umzuschreiben statt zu kommentieren haelt den Kopf ehrlich. Nicht-Gate-Verify neben
# `make smoke`, gebunden an DoD-Verify/Closure (LH-QA-01).
#
# ISOLATION: der Baum wird EINMAL pro Lauf nach ausserhalb des Repos kopiert; Seds
# und Sensor-Laeufe treffen nur diese Kopie. Ausserhalb, weil ein Verzeichnis UNTER
# dem Repo ungetrackt im Working Tree laege und den MR-003-Stop-Hook-Hash verschoebe.
# Der Treiber BELEGT die Unversehrtheit selbst — je Fall zwischen Mutation und Restore,
# und einmal ueber alle Ziele am Ende —, statt sie zuzusagen.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CASES_DIR="$REPO/test/mutations"
BACKUP=""
# WORK ist der Baum, gegen den mutiert und gemessen wird — die isolierte Kopie.
# Bis prepare_isolation() sie anlegt, ist er leer; run_case laeuft NIE gegen $REPO.
WORK=""
ISO_ROOT=""
# HOST_BEFORE: Fingerabdruck der Mutations-Ziele im HOST-Baum vor dem Lauf (run_case
# vergleicht mitten im Lauf dagegen).
HOST_BEFORE=""

LOCK="$REPO/.harness/state/mutate.lock"
HAVE_LOCK=""

restore() {
  [ -n "$BACKUP" ] || return 0
  # Alles zurueckspielen, was gesichert wurde. tar bewahrt die relativen Pfade.
  # Ziel ist die KOPIE ($WORK), nie der Host-Baum (slice-047).
  if [ -f "$BACKUP/files.tar" ] && [ -n "$WORK" ]; then
    tar -xf "$BACKUP/files.tar" -C "$WORK"
  fi
  rm -rf "$BACKUP"
  BACKUP=""
}

# fingerprint_of_list hasht die INHALTE einer NUL-separierten Dateiliste (relativ zu
# dir), die auf stdin kommt. Getrennt von der Listen-BESCHAFFUNG, damit die Rechen-
# Eigenschaft ohne git pruefbar ist — der bats-Container traegt kein git.
fingerprint_of_list() {
  local dir="$1"
  ( cd "$dir" && LC_ALL=C sort -z | xargs -0 -r sha256sum ) | sha256sum | cut -d' ' -f1
}

# mutation_targets liefert die Vereinigung aller `# files:`-Ziele, zeilenweise und
# sortiert. Genau diese Dateien koennte ein Isolations-Bruch im Host-Baum beschaedigen.
mutation_targets() {
  sed -n 's/^# files: //p' "$1"/*.sh | tr ' ' '\n' | sed '/^$/d' | LC_ALL=C sort -u
}

# target_fingerprint hasht diese Dateien im Baum root. Er ist der Beleg der Kern-Zusage
# des Sensors: „ein Lauf veraendert den Host-Baum nicht."
#
# BEWUSST NUR die Mutations-Ziele, nicht der ganze Baum: sonst roetet jede parallele
# Arbeit am Repo (Doku, Slice-Dateien, Reviews) den Lauf — und die Isolation verloere
# genau den Nutzen, fuer den sie gebaut ist. Der Preis: schreibt ein kuenftiger Defekt
# in eine Host-Datei AUSSERHALB dieser Menge, faellt es hier nicht auf. Die Menge deckt
# ab, was die Faelle anfassen; mehr behauptet dieser Waechter nicht.
#
# FAIL-CLOSED: leere Ziel-Liste oder fehlende Datei -> Exit != 0, kein Hash ueber die
# leere Menge (zwei leere Hashes waeren gleich und meldeten „unveraendert", ohne je
# gemessen zu haben).
target_fingerprint() {
  local root="$1" cases="$2" targets
  targets="$(mutation_targets "$cases")"
  [ -n "$targets" ] || return 1
  printf '%s\n' "$targets" | tr '\n' '\0' | fingerprint_of_list "$root"
}

# isolation_path liefert den Zielpfad der Kopie und VERWEIGERT fail-closed ein Ziel
# unter dem Repo (die slice-044-Falle: ein ungetracktes Verzeichnis im Working Tree
# verschoebe den MR-003-Stop-Hook-Hash und traege die Mutationen zurueck in genau den
# Baum, den die lesenden Rollen messen). Rein — kein Kopieren: so ist die Ortsregel
# pruefbar, ohne dass jeder Test 8 MB schiebt (Review F-5/F-7).
isolation_path() {
  local root="$1" dest="$1/repo"
  case "$dest" in
    "$REPO" | "$REPO"/*)
      echo "mutate: ABBRUCH — die Isolation laege unter dem Repo ($dest)." >&2
      return 1
      ;;
  esac
  [ -n "$root" ] || { echo "mutate: ABBRUCH — leere Isolations-Wurzel." >&2; return 1; }
  printf '%s' "$dest"
}

# prepare_isolation kopiert den Host-Baum EINMAL pro Lauf an diesen Ort. Die Kopie IST
# das Repo — inklusive `.git`: `make ci-lint` faehrt actionlint, und das bricht ohne
# git-Projektwurzel ab („no project was found in any parent directories"). Der erste
# Entwurf sparte `.git` aus; der Gruen-Vorlauf fing es. Ausgeschlossen bleibt nur
# `.harness/state/` (Laufzustand, gitignored, enthaelt den Lock DIESES Laufs). tar statt
# rsync/cp -a: tar ist im Repo ohnehin die Sicherungs-Mechanik (LH-QA-03). 8,0 MB.
prepare_isolation() {
  local dest
  dest="$(isolation_path "$1")" || return 1
  mkdir -p "$dest"
  ( cd "$REPO" && tar -cf - --exclude=./.harness/state . ) | tar -xf - -C "$dest"
  printf '%s' "$dest"
}

# require_isolated ist die fail-closed Schranke VOR jedem Zugriff auf $WORK. Ohne sie
# haengt „run_case laeuft nie gegen $REPO" allein an der Aufruf-Reihenfolge: `cd ""` ist
# in bash Exit 0 OHNE Wirkung, ein leeres $WORK liesse also alle `cd "$WORK"`-Stellen
# lautlos im cwd des Treibers laufen — und das ist unter `make mutate` das Repo
# (Review F-1). Eine Zusage, die nur durch Reihenfolge gilt, ist keine.
require_isolated() {
  case "${WORK:-}" in
    "") echo "mutate: ABBRUCH — WORK ist leer; ohne Isolation wird nicht mutiert." >&2; return 1 ;;
    "$REPO" | "$REPO"/*) echo "mutate: ABBRUCH — WORK liegt im Repo ($WORK)." >&2; return 1 ;;
  esac
  [ -d "$WORK" ] || { echo "mutate: ABBRUCH — WORK ist kein Verzeichnis ($WORK)." >&2; return 1; }
}

cleanup() {
  restore
  # Die Isolation liegt ausserhalb des Repos: sie wegzuwerfen kann den Host-Baum
  # nicht beruehren — auch nicht bei einem Abbruch mitten in einer Mutation.
  [ -n "$ISO_ROOT" ] && rm -rf "$ISO_ROOT"
  [ -n "$HAVE_LOCK" ] && rmdir "$LOCK" 2>/dev/null
  return 0
}
# Bei Abbruch (Ctrl-C, Kill) die Isolation wegraeumen. Der Host-Baum braucht keine
# Wiederherstellung mehr — er wurde nie veraendert (slice-047). Ein SIGKILL laesst
# hoechstens ein Temp-Verzeichnis ausserhalb des Repos liegen, kein Residuum im Baum.
trap 'cleanup' EXIT INT TERM


fail_count=0
pass_count=0

report_fail() {
  printf 'mutate: BEFUND  %-42s %s\n' "$1" "$2" >&2
  fail_count=$((fail_count + 1))
}

# failure_form liefert das Muster, an dem ein FEHLGESCHLAGENER Waechter des
# jeweiligen Sensors erkennbar ist. Es muss ausschliesslich bei Fehlschlag
# auftreten — sonst ist Bedingung 4 wirkungslos (F-1).
#
# EINZIGE Quelle der erlaubten Modi: ein unbekannter Modus liefert Exit 1, kein
# leeres Muster. Zuvor stand die Zulassungsliste getrennt in run_case; ein Modus
# ohne Arm hier ergab einen LEEREN Regex, und `grep -E ''` matcht jede Zeile —
# Bedingung 4 fiel damit exakt in den F-1-Zustand zurueck (Review-Befund
# slice-026 N-2, gemessen). Zwei Listen, die getrennt gepflegt werden, sind
# genau die Drift-Konstruktion, die dieses Repo mehrfach beseitigt hat.
failure_form() {
  case "$1" in
    test)    printf '%s' '--- FAIL:|not ok [0-9]+' ;;  # go test | bats
    smoke)   printf '%s' 'smoke: FEHLER' ;;            # harness/tools/smoke.sh
    ci-lint) printf '%s' ':[0-9]+:[0-9]+:' ;;          # actionlint file:line:col: (nur bei Fehler)
    *)       return 1 ;;
  esac
}

run_case() {
  local case_file="$1"
  local name files expect verify form
  name="$(basename "$case_file" .sh)"

  # Doppelte Koepfe sind ein Befund, kein "letzter gewinnt": `sed -n …p` sammelt
  # ALLE Treffer, `read -r -a … <<<` liest aber nur die erste Zeile — ein zweiter
  # `# files:`-Kopf verschwaende sonst lautlos, die Datei waere weder gesichert
  # noch zurueckgesetzt (Review-Befund slice-026 F-7).
  local k
  for k in files expect verify; do
    if [ "$(grep -c "^# $k: " "$case_file")" -gt 1 ]; then
      report_fail "$name" "mehrfacher '# $k:'-Kopf — nur der erste wuerde wirken"
      return
    fi
  done

  files="$(sed -n 's/^# files: //p' "$case_file")"
  expect="$(sed -n 's/^# expect: //p' "$case_file")"
  # `# verify:` waehlt den Sensor, den die Mutation rot faerben soll. Ohne die
  # Angabe faehrt run_case nur `make test` — und Waechter in `make smoke` waeren
  # damit bauartbedingt unbewacht (Review-Befund slice-026 F-5). Genau die sind
  # aber gerade als inert aufgeflogen (F-2), also brauchen sie die Abdeckung am
  # dringendsten.
  verify="$(sed -n 's/^# verify: //p' "$case_file")"
  [ -n "$verify" ] || verify="test"
  if [ -z "$files" ] || [ -z "$expect" ]; then
    report_fail "$name" "Kopf unvollstaendig: '# files:' und '# expect:' sind Pflicht"
    return
  fi
  # Zulassung kommt aus failure_form — eine Quelle, keine zweite Liste (N-2).
  if ! form="$(failure_form "$verify")"; then
    report_fail "$name" "unbekanntes '# verify: $verify' — kein Fehlschlag-Muster definiert"
    return
  fi
  # Als Array, damit mehrere Pfade sauber getrennt bleiben (statt ungequotetem
  # Word-Splitting — Hard Rule 3.2 laesst keine Inline-Suppression zu).
  local -a file_list
  read -r -a file_list <<<"$files"

  # Sichern (Bedingung 1-4 duerfen den Baum nie veraendert zuruecklassen).
  BACKUP="$(mktemp -d)"
  ( cd "$WORK" && tar -cf "$BACKUP/files.tar" "${file_list[@]}" )
  # Fuer Bedingung 2 zaehlt der INHALT, nicht die Metadaten: `sed -i` (wie zuvor
  # `perl -pi`) schreibt die Datei auch dann neu, wenn keine Substitution greift —
  # die mtime aendert sich, der Inhalt nicht. Ein tar-Vergleich meldete dann
  # faelschlich "veraendert" und liesse den veralteten Patch als Bedingung 3
  # durchgehen (eigener Sonden-Befund beim Bau dieses Sensors).
  ( cd "$WORK" && sha256sum "${file_list[@]}" >"$BACKUP/before.sums" )

  # Referenzwert der HOST-Fassung DIESES Falls, unmittelbar vor der Mutation.
  local case_before
  case_before="$(printf '%s\n' "${file_list[@]}" | tr '\n' '\0' | fingerprint_of_list "$REPO")" || case_before=""
  if [ -z "$case_before" ]; then
    report_fail "$name" "Host-Fingerabdruck der Zieldatei(en) nicht berechenbar"
    restore
    return
  fi

  # (1) Mutation anwenden. Die Ausgabe wandert in die Meldung, nicht in eine
  # Datei — restore() raeumt das Temp-Verzeichnis sofort weg, ein Pfad-Zeiger
  # darin ginge ins Leere (Review-Befund slice-026, LOW).
  local mut_out
  if ! mut_out="$( cd "$WORK" && bash "$case_file" 2>&1 )"; then
    report_fail "$name" "Mutations-Skript scheiterte: ${mut_out//$'\n'/ }"
    restore
    return
  fi

  # ISOLATIONS-PRUEFUNG MITTEN IM LAUF: genau JETZT ist die Mutation angewandt und
  # noch nicht zurueckgenommen. Ein Vergleich erst NACH dem Lauf kann den symmetrischen
  # Rueckfall nicht sehen — laufen Sed und Restore beide gegen $REPO (das Verhalten vor
  # der Isolation), ist vorher==nachher und der Waechter bliebe gruen. Hier faellt er.
  #
  # Gemessen werden DIE DATEIEN DIESES FALLS, nicht alle Ziele: eine parallel bearbeitete
  # fremde Zieldatei liesse sonst JEDEN Folgefall abbrechen — bis zu 70 falsche Befunde,
  # kein einziger Waechter gemessen, und die Briefings sagen fuer genau diesen Fall das
  # Gegenteil zu (Review-Runde 2, F-3).
  #
  # Steht VOR Bedingung 2: im Rueckfall bleibt die KOPIE unveraendert, also feuerte sonst
  # zuerst „Mutation hat nicht gegriffen" — ein gebrochener Sensor waere als veralteter
  # Patch fehldiagnostiziert. Real so gemessen, als der Rot-Beleg gebaut wurde.
  local case_now
  case_now="$(printf '%s\n' "${file_list[@]}" | tr '\n' '\0' | fingerprint_of_list "$REPO")" || case_now=""
  if [ -z "$case_now" ] || [ "$case_now" != "$case_before" ]; then
    report_fail "$name" "die Zieldatei(en) im HOST-Baum haben sich waehrend des Falls geaendert — Isolation gebrochen, oder parallel editiert"
    # ABBRUCH statt Weiterlaufen (F-4): ist die Isolation gebrochen, mutieren die
    # Folgefaelle weiter gegen den Host — und ein Host-Restore gibt es nicht, das
    # Backup liegt in der Kopie. Lieber laut stehenbleiben.
    echo "mutate: ABBRUCH — der Host-Baum ist betroffen; Folgefaelle wuerden ihn weiter mutieren." >&2
    echo "  Betroffen: ${file_list[*]}" >&2
    restore
    exit 1
  fi

  # (2) Hat sie ueberhaupt gegriffen? Ein wirkungsloser Patch wuerde sonst als
  # "Waechter intakt" durchgehen — der Sensor waere still gruen.
  #
  # JEDE gelistete Datei muss sich geaendert haben, nicht irgendeine: `# files:`
  # benennt die Mutations-ZIELE. Ein blosses `sha256sum -c` ueber alle schlaegt
  # schon fehl, wenn EINE abweicht — bei mehreren Pfaden waere der veraltete
  # Patch fuer die uebrigen unsichtbar (Review-Befund slice-026 F-7). Heute traegt
  # jeder Fall genau einen Pfad; die Schranke gilt, bevor der erste zwei traegt.
  local f unchanged=""
  for f in "${file_list[@]}"; do
    if ( cd "$WORK" && grep -F -- " $f" "$BACKUP/before.sums" | sha256sum -c - ) >/dev/null 2>&1; then
      unchanged="$unchanged $f"
    fi
  done
  if [ -n "$unchanged" ]; then
    report_fail "$name" "Mutation hat nicht gegriffen bei:$unchanged — Patch veraltet?"
    restore
    return
  fi

  # (3)+(4) Sensor-Lauf: rot erwartet, und zwar am benannten Waechter.
  local out rc=0
  out="$BACKUP/verify.log"
  ( cd "$WORK" && make "$verify" ) >"$out" 2>&1 || rc=$?

  if [ "$rc" -eq 0 ]; then
    report_fail "$name" "make $verify blieb GRUEN — '$expect' hat keine Zaehne mehr"
    restore
    return
  fi
  # Bei einem Befund die letzten Zeilen des Sensor-Laufs zeigen: restore() loescht
  # das Log gleich danach, und eine Ein-Zeilen-Meldung ohne Kontext ist schwer zu
  # diagnostizieren (Review-Befund slice-026 N-5, zweite Haelfte von F-8).
  show_tail() { sed -e 's/^/    | /' <(tail -n 12 "$out") >&2; }
  # Nur FEHLSCHLAG-Zeilen zaehlen. bats druckt jeden Testnamen AUCH beim Bestehen
  # ("ok 21 emittiert: eingelegter SYMLINK"), ein blosses grep auf den Namen war
  # damit fuer jeden bats-Fall unter allen Bedingungen erfuellt — Bedingung 4 war
  # dort wirkungslos (Review-Befund slice-026 F-1, per Sonde nachgestellt). Erst die
  # Fehlschlag-Form ist eine Aussage — und sie ist je Sensor eine andere.
  if ! grep -E -- "$form" "$out" | grep -qF -- "$expect"; then
    report_fail "$name" "rot, aber '$expect' faellt nicht — falscher Grund"
    show_tail
    restore
    return
  fi

  printf 'mutate: ok      %-42s %s\n' "$name" "-> $expect rot"
  pass_count=$((pass_count + 1))
  restore
}

# Hauptteil gekapselt, damit test/mutate-driver.bats die Funktionen SOURCEN
# kann, ohne den ganzen Lauf auszuloesen. Ohne die Kapselung fuehrt jedes
# `source` den Gruen-Vorlauf und die Mutations-Schleife aus — mein erster
# Test-Entwurf tat genau das (Konstruktionsfehler im Test, nicht im Treiber).
main() {
  # LOCK gegen parallele Laeufe. Seine URSPRUENGLICHE Begruendung ist mit slice-047
  # entfallen: zwei Laeufe mutieren nicht mehr denselben Arbeitsbaum (jeder hat seine
  # eigene Kopie). Was bleibt, ist die geteilte RESSOURCE: beide Laeufe bauen dieselben
  # Docker-Image-Tags (`ai-harness-init:test` …) und wuerden einander die Tags und den
  # Build-Cache unter den Fuessen wegziehen — die Ergebnisse blieben zwar korrekt (jeder
  # Build hat seinen eigenen Kontext), aber die Laufzeit vervielfachte sich und ein
  # `make smoke`-Fall kollidierte in seinen tmp-Ressourcen. Der Lock bleibt also, mit
  # geaenderter Begruendung — nicht mehr Baum-Schutz, sondern Ressourcen-Serialisierung.
  # `mkdir` ist atomar, also ein portabler Mutex ohne flock. Er steht IN main(), nicht
  # im Top-Level: test/mutate-driver.bats sourct die Datei fuer ihre Funktionen, und ein
  # Lock beim Sourcen wuerde die Tests verschmutzen (von genau diesen Tests gefangen).
  mkdir -p "$(dirname "$LOCK")"
  if ! mkdir "$LOCK" 2>/dev/null; then
    echo "mutate: ABBRUCH — ein Lauf ist bereits aktiv ($LOCK)." >&2
    echo "  Zwei gleichzeitige Laeufe teilen sich Docker-Tags und Build-Cache." >&2
    echo "  Stale? Dann '$LOCK' entfernen." >&2
    exit 1
  fi
  HAVE_LOCK=1

  [ -d "$CASES_DIR" ] || { echo "mutate: $CASES_DIR fehlt" >&2; exit 1; }

  # ISOLATION: den Baum EINMAL nach ausserhalb des Repos kopieren. Ab hier trifft
  # keine Mutation mehr den Host-Baum — parallele Gate-/Test-Laeufe in diesem Repo
  # sind unbedenklich, und ein Abbruch laesst nichts zurueck (slice-047).
  shopt -s nullglob
  cases=("$CASES_DIR"/*.sh)
  shopt -u nullglob
  if [ "${#cases[@]}" -eq 0 ]; then
    # Ein leeres Set waere ein gruener Lauf ohne jede Aussage — genau das stille
    # Gruen, gegen das der Sensor gerichtet ist. Steht VOR dem Fingerabdruck: der
    # scheitert ueber einem leeren Fall-Verzeichnis ohnehin, und dann meldete der Lauf
    # einen Rechen-Fehler statt der wahren Ursache.
    echo "mutate: keine Faelle in $CASES_DIR — ein leeres Set ist kein gruener Lauf" >&2
    exit 1
  fi

  local host_after
  if ! HOST_BEFORE="$(target_fingerprint "$REPO" "$CASES_DIR")"; then
    echo "mutate: ABBRUCH — Fingerabdruck der Mutations-Ziele nicht berechenbar." >&2
    echo "  Ohne ihn liefe der Lauf ohne den Beleg, dass der Host-Baum unberuehrt bleibt." >&2
    exit 1
  fi
  ISO_ROOT="$(mktemp -d)"
  WORK="$(prepare_isolation "$ISO_ROOT")"
  require_isolated || exit 1
  echo "mutate: isolierte Kopie unter $WORK — der Host-Baum wird NICHT veraendert."

  # GRUEN-VORLAUF vor der ersten Mutation (Review-Befund slice-026 F-6). Ohne ihn
  # wuerde jeder Fall auf einem bereits roten Baum "bestehen" — aus dem falschen
  # Grund. Der Fall ist nicht theoretisch: waehrend des Reviews faerbte ein
  # paralleler mutate-Lauf im selben Arbeitsbaum die Tests rot.
  # Je Sensor, den irgendein Fall benutzt — sonst liefe ein smoke-Fall auf einem
  # bereits roten smoke los und "bestuende".
  modes="$(sed -n 's/^# verify: //p' "$CASES_DIR"/*.sh | LC_ALL=C sort -u)"
  [ -n "$modes" ] || modes=""
  for m in test $modes; do
    # Erst die Zulassung, dann der Lauf: ein vertippter Modus liefe sonst als
    # `make <tippfehler>` und wuerde als "Baum ist rot" gemeldet — eine
    # irrefuehrende Diagnose fuer einen Kopf-Fehler (Review-Befund slice-026 N-4).
    if ! failure_form "$m" >/dev/null; then
      echo "mutate: ABBRUCH — unbekannter '# verify: $m' in test/mutations/." >&2
      echo "  Erlaubt ist, wofuer failure_form ein Fehlschlag-Muster kennt." >&2
      exit 1
    fi
    echo "mutate: Gruen-Vorlauf make $m (muss VOR der ersten Mutation gruen sein)"
    if ! ( cd "$WORK" && make "$m" ) >/dev/null 2>&1; then
      echo "mutate: ABBRUCH — make $m ist schon ohne Mutation rot." >&2
      echo "  Auf rotem Baum ist jeder Fall bedeutungslos: er waere rot, aber nicht" >&2
      echo "  wegen SEINER Mutation. Erst den Baum gruen bekommen." >&2
      exit 1
    fi
  done

  echo "mutate: ${#cases[@]} Faelle (je ein voller make-test-Zyklus, das dauert)"
  for c in "${cases[@]}"; do
    run_case "$c"
  done

  # FUENFTE Bedingung, fail-closed: die Mutations-Ziele im Host-Baum sind nach dem Lauf
  # byte-gleich. Sie faengt ein LIEGENGEBLIEBENES Residuum. Den symmetrischen Rueckfall
  # (Sed und Restore beide gegen $REPO) faengt NICHT sie, sondern die Pruefung mitten im
  # Lauf in run_case — dort ist der Host im Moment der Messung mutiert (Review F-2).
  if ! host_after="$(target_fingerprint "$REPO" "$CASES_DIR")"; then
    report_fail "host-baum" "Fingerabdruck nach dem Lauf nicht berechenbar — Ziel-Datei entfernt?"
    host_after=""
  fi
  if [ "$HOST_BEFORE" != "$host_after" ]; then
    report_fail "host-baum" "eine Mutations-Zieldatei im HOST-Baum hat sich geaendert — entweder greift die Isolation nicht, oder es wurde parallel editiert"
  fi

  echo "mutate: $pass_count ok, $fail_count Befund(e)"
  [ "$fail_count" -eq 0 ]
}

# Nur bei DIREKTEM Aufruf laufen, nicht beim Sourcen.
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  main "$@"
fi

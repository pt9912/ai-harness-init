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
# NICHT in `make gates` — der Grund ist die LAUFZEIT: je Fall ein voller Sensor-Lauf,
# und die Fall-Menge waechst mit jedem bewachten Waechter. Was der Lauf HEUTE kostet,
# sagt er selbst am Ende (`report_times`), statt es hier als Zahl zu behaupten, die mit
# dem Bestand wandert.
# Der frueher hier stehende Grund („dieser Sensor veraendert den Arbeitsbaum") ist
# mit slice-047 entfallen und wurde ERSETZT, nicht ergaenzt — eine gewanderte Grenze
# umzuschreiben statt zu kommentieren haelt den Kopf ehrlich. Nicht-Gate-Verify neben
# `make smoke`, gebunden an DoD-Verify/Closure (LH-QA-01).
#
# PREIS EINES `# verify: full-smoke`-FALLS, damit die naechste Zusage ihn kennt, bevor
# sie ihn ausloest: der Modus bootstrappt in tmp-Repos und faehrt dort echte
# Docker-Gates. Der Gruen-Vorlauf faehrt jeden benutzten Modus EINMAL, danach faehrt
# jeder Fall seinen eigenen Lauf — der erste solche Fall kostet also zwei Laeufe, jeder
# weitere einen. Gemessen am 2026-08-23 auf dieser Maschine mit
# `/usr/bin/time -f 'FULLSMOKE_SECONDS=%e' make full-smoke`: unmutiert 90.00 s und
# 136.16 s, beide Exit 0 — zwei Laeufe ueber denselben Baum, dazwischen hat ein
# `make mutate` den Docker-Cache umgewaelzt. Der Cache-Zustand ist damit der groessere
# Posten als der Baum, und eine einzelne Zahl waere hier eine Genauigkeit, die es nicht
# gibt. Mit der Mutation von test/mutations/152 53.32 s, Exit 2 (dasselbe Kommando ueber
# dem mutierten Baum): ein Fall-Lauf bricht am getroffenen Waechter ab und ist darum
# kuerzer als der vollstaendige Vorlauf. Wer den Aufschlag gegen die Gesamtlaufzeit
# halten will, rechnet ihn aus diesen Werten.
#
# ISOLATION: der Baum wird JE WORKER nach ausserhalb des Repos kopiert; Seds und
# Sensor-Laeufe treffen nur diese Kopien. Ausserhalb, weil ein Verzeichnis UNTER
# dem Repo ungetrackt im Working Tree laege und den MR-003-Stop-Hook-Hash verschoebe.
# Der Treiber BELEGT die Unversehrtheit selbst — je Fall zwischen Mutation und Restore,
# und einmal ueber alle Ziele am Ende —, statt sie zuzusagen.
#
# PARALLEL, DYNAMISCH ZUGETEILT: MUTATE_JOBS Worker ziehen ihre Faelle aus einer
# gemeinsamen Warteschlange, statt einen fest zugeteilten Block abzuarbeiten. Ein
# statischer Schnitt taugt hier nicht — die Fall-Kosten streuen um mehr als eine
# Groessenordnung (eine bats-Stufe gegen einen full-smoke-Lauf), und der Worker mit dem
# teuren Block bestimmte allein die Wanduhr-Zeit, waehrend die uebrigen leerliefen.
#
# DAS VERDIKT HAENGT NICHT AN DER WORKER-ZAHL, und das ist die Bedingung, unter der
# MUTATE_JOBS ueberhaupt eine Stellschraube sein darf (LH-QA-02): dieselbe Fall-Menge,
# dasselbe Ergebnis, egal ueber wie viele Worker sie lief. Getragen wird das von drei
# Eigenschaften, nicht von Zuversicht — jeder Worker faehrt den Gruen-Vorlauf jedes Modus
# in SEINER Kopie (green_prerun, faul); der zusammengefuehrte Bericht BELEGT, dass jede
# Fall-ID genau einmal gelaufen ist (merge_report), statt es aus „alle Worker sind
# zurueck" zu folgern; und die Modi, deren Urteil an einem geteilten Docker-Tag haengt,
# laufen in EINER Spur (is_heavy_mode). Ein Worker, der stirbt, und ein Fall, den die
# Warteschlange nie ausgibt, sind beide ein Befund.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CASES_DIR="$REPO/test/mutations"
BACKUP=""
# WORK ist der Baum, gegen den mutiert und gemessen wird — die isolierte Kopie.
# Bis prepare_isolation() sie anlegt, ist er leer; run_case laeuft NIE gegen $REPO.
WORK=""
ISO_ROOT=""
# PRERUN_LOG_DIR: das mktemp-Verzeichnis, in dem der Gruen-Vorlauf sein Protokoll
# fuehrt. Leer, bis green_prerun es anlegt; cleanup() raeumt es weg.
PRERUN_LOG_DIR=""
# HOST_BEFORE: Fingerabdruck der Mutations-Ziele im HOST-Baum vor dem Lauf (run_case
# vergleicht mitten im Lauf dagegen).
HOST_BEFORE=""

LOCK="$REPO/.harness/state/mutate.lock"
HAVE_LOCK=""

# JOBS ist die Zahl der Worker; jeder traegt eine eigene isolierte Kopie. Der Default ist
# eine ZEIT-Stellschraube, keine Verdikt-Stellschraube (s. Kopf): 4, weil die Reihe ueber
# N=1/4/6/8 bei N=4 den Sprung bringt und N=6/8 nur noch 6-7 % daraufsetzen. Ein FESTER
# Default statt einer Ableitung aus `nproc`: leitete er sich aus der Maschine ab, waeren
# zwei Laeufe auf zwei Maschinen in ihrer Wanduhr nicht mehr vergleichbar — und
# Vergleichbarkeit ist genau das, wofuer die Zeiten erhoben werden.
JOBS="${MUTATE_JOBS:-4}"
# RUN_DIR sammelt Warteschlangen, Cursor, Fall-Protokolle und Statuszeilen EINES Laufs.
# Es liegt unter ISO_ROOT, also ausserhalb des Repos — dieselbe Ortsregel wie fuer die
# Kopien und aus demselben Grund (MR-003-Stempel ueber getrackte UND untrackte Dateien).
RUN_DIR=""
# WORKER_ID steht in den Meldungen, die ein Worker ausserhalb eines Falls schreibt.
# Leer im Elternprozess.
WORKER_ID=""
# CASE_NAMES bildet die Fall-NUMMER auf den Fall-NAMEN ab (1-basiert). merge_report
# braucht den Namen fuer Faelle, die kein Ergebnis geliefert haben — deren Statuszeile
# fehlt ja gerade, und eine Meldung mit blosser Nummer waere keine Adresse.
declare -a CASE_NAMES=()
# CASE_MODES bildet die Fall-NUMMER auf ihren Sensor-Modus ab (1-basiert). Die Modi
# werden in einem ERSTEN Durchgang erhoben: erst die vollstaendige Modus-Menge sagt,
# welche Spur ein Fall bekommt.
declare -a CASE_MODES=()
# HEAVY_MODES ist die serielle Spur, einmal je Lauf erhoben (is_heavy_mode). Leer
# heisst: kein Modus teilt sich einen Tag ueber den Bau hinaus.
HEAVY_MODES=" "

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

# prepare_prerun_log legt das Verzeichnis fuer das Protokoll des Gruen-Vorlaufs an und
# liefert den Pfad der Log-Datei darin — dasselbe mktemp-Muster, das run_case fuer sein
# Sensor-Log benutzt, und dieselbe Ortsregel wie isolation_path: ein Ziel UNTER dem Repo
# faellt fail-closed. Wohin `mktemp -d` zeigt, entscheidet $TMPDIR; im Repo laege das
# Protokoll ungetrackt im Working Tree und verschoebe mitten im Lauf den
# MR-003-Nachweis-Stempel, den harness/tools/working-tree-hash.sh ueber getrackte UND
# untrackte Dateien rechnet.
#
# Ohne Zugriff auf die Globalen: das Verzeichnis traegt der Aufrufer in PRERUN_LOG_DIR
# ein, damit cleanup() es findet. So faehrt test/mutate-driver.bats die Ortsregel, ohne
# dass der EXIT-trap des gesourcten Treibers das Messobjekt vorher wegraeumt.
prepare_prerun_log() {
  local dir
  dir="$(mktemp -d)" || return 1
  case "$dir" in
    "$REPO" | "$REPO"/*)
      echo "mutate: ABBRUCH — das Vorlauf-Protokoll laege im Repo ($dir)." >&2
      rm -rf "$dir"; return 1 ;;
  esac
  printf '%s' "$dir/prerun.log"
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
  # Auch das Vorlauf-Protokoll liegt ausserhalb des Repos (prepare_prerun_log).
  [ -n "$PRERUN_LOG_DIR" ] && rm -rf "$PRERUN_LOG_DIR"
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
# narrow_sensor waehlt den Sensor eines Falls OHNE eigenen `# verify:`-Modus aus seiner
# `# expect:`-Zeile: nennt sie einen Go-Test, genuegt die Go-Stufe; sonst die bats-Stufe.
# Bis slice-056 fuhr jeder dieser Faelle BEIDE Stufen — 92 Faelle x (bats + voller
# go-test-Build).
#
# FAIL-CLOSED ist der Kern: alles, was nicht eindeutig zuzuordnen ist (leere Erwartung,
# mehrere Zeilen, ein Name der weder Go-Test-Form noch bats-Titel ist), faellt auf den
# VOLLEN Satz zurueck. Ein schnellerer Lauf, der weniger prueft, waere genau das stille
# Gruen, gegen das make mutate antritt (LH-QA-01). test/mutate-driver.bats faehrt die
# drei Faelle; test/mutations/97 nimmt die Auswahl weg und muss den Driver-Test roeten.
narrow_sensor() {
  local expect="$1"
  # Mehrzeilig oder leer -> nicht eindeutig -> voller Satz.
  case "$expect" in
    "") printf '%s' 'test'; return ;;
    *"
"*) printf '%s' 'test'; return ;;
  esac
  # Go-Testfunktionen tragen das Praefix `Test` plus Grossbuchstabe (Konvention des
  # Test-Werkzeugs, nicht unsere) — deshalb dieses Muster und keine Namensliste.
  case "$expect" in
    Test[A-Z]*) printf '%s' 'test-go' ;;
    *)          printf '%s' 'test-bats' ;;
  esac
}

failure_form() {
  case "$1" in
    test)     printf '%s' '--- FAIL:|not ok [0-9]+' ;;  # go test | bats
    test-go)  printf '%s' '--- FAIL:' ;;                # nur die Go-Stufe
    test-bats) printf '%s' 'not ok [0-9]+' ;;           # nur die bats-Stufe
    smoke)   printf '%s' 'smoke: FEHLER' ;;            # harness/tools/smoke.sh
    # Gross-/Kleinschreibung und der Praefix sind hier tragend, nicht kosmetisch: ein
    # GRUENER full-smoke-Lauf faerbt Teil-Gates absichtlich rot und druckt deren Ausgabe,
    # darunter die Zeile `full-smoke: absichtlicher Schicht-Fehler`. Ueber einem gruenen
    # Lauf gemessen (2026-08-23, `make full-smoke >fs.log 2>&1`, Exit 0):
    # `grep -cE 'full-smoke: FEHLER' fs.log` -> 0, `grep -cEi 'full-smoke.*fehler' fs.log`
    # -> 3. Ein weiter gefasstes Muster waere damit schon im Bestehen erfuellt und
    # Bedingung 4 wirkungslos.
    full-smoke) printf '%s' 'full-smoke: FEHLER' ;;    # harness/tools/full-smoke.sh
    ci-lint) printf '%s' ':[0-9]+:[0-9]+:' ;;          # actionlint file:line:col: (nur bei Fehler)
    *)       return 1 ;;
  esac
}

# show_tail zeigt die letzten Zeilen des Sensor-Logs $1 eingerueckt auf stderr. Das Log
# wird gleich danach weggeraeumt, ein Pfad-Zeiger in der Meldung ginge also ins Leere —
# die Zeilen selbst nicht (Review-Befund slice-026 N-5, zweite Haelfte von F-8).
# Zwei Aufrufer: der Fall-Pfad in run_case und der Abbruch des Gruen-Vorlaufs. In beiden
# ist die Meldung sonst die vollstaendige Evidenz des Laufs, und ein Exit-Code allein
# sagt nicht, was der Sensor gesehen hat.
show_tail() { sed -e 's/^/    | /' <(tail -n 12 "$1") >&2; }

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
  # `# verify:` waehlt den Sensor, den die Mutation rot faerben soll — Waechter in
  # `make smoke` waeren sonst bauartbedingt unbewacht (Review-Befund slice-026 F-5).
  # OHNE die Angabe waehlt seit slice-056 narrow_sensor die passende Stufe aus der
  # `# expect:`-Zeile (fail-closed: im Zweifel beide); bis dahin lief immer der volle
  # `make test`.
  verify="$(sed -n 's/^# verify: //p' "$case_file")"
  [ -n "$verify" ] || verify="$(narrow_sensor "$expect")"
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
    #
    # Die Flagge ZUERST, dann der eigene Abbruch: `exit 1` beendet nur DIESEN Worker;
    # die uebrigen zoegen ohne sie weiter Faelle und mutierten weiter gegen den Host.
    abort_run
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
  # Nur FEHLSCHLAG-Zeilen zaehlen. bats druckt jeden Testnamen AUCH beim Bestehen
  # ("ok 21 emittiert: eingelegter SYMLINK"), ein blosses grep auf den Namen war
  # damit fuer jeden bats-Fall unter allen Bedingungen erfuellt — Bedingung 4 war
  # dort wirkungslos (Review-Befund slice-026 F-1, per Sonde nachgestellt). Erst die
  # Fehlschlag-Form ist eine Aussage — und sie ist je Sensor eine andere.
  if ! grep -E -- "$form" "$out" | grep -qF -- "$expect"; then
    report_fail "$name" "rot, aber '$expect' faellt nicht — falscher Grund"
    show_tail "$out"
    restore
    return
  fi

  printf 'mutate: ok      %-42s %s\n' "$name" "-> $expect rot"
  pass_count=$((pass_count + 1))
  restore
}

# green_prerun faehrt jeden uebergebenen Modus EINMAL, bevor die erste Mutation laeuft
# (Review-Befund slice-026 F-6). Ohne ihn wuerde jeder Fall auf einem bereits roten
# Baum "bestehen" — aus dem falschen Grund. Der Fall ist nicht theoretisch: waehrend des
# Reviews faerbte ein paralleler mutate-Lauf im selben Arbeitsbaum die Tests rot.
# Je Sensor, den irgendein Fall benutzt — sonst liefe ein smoke-Fall auf einem bereits
# roten smoke los und "bestuende".
#
# Der Lauf jedes Modus geht in ein Protokoll, und der Abbruch zeigt dessen letzte
# Zeilen. Ein Vorlauf, der beide Stroeme des Sensors verwirft, laesst als Evidenz einen
# Exit-Code und einen Satz zurueck; welcher Zustand den Sensor rot gemacht hat, steht
# dann in keinem Protokoll (test/mutate-driver.bats haelt beide Stroeme).
#
# Ausser $WORK und dieser Liste braucht die Funktion keinen Zustand aus main — so faehrt
# test/mutate-driver.bats sie mit einem make-Stub auf $PATH, ohne echten Sensor-Lauf.
green_prerun() {
  local m log
  # Ein Worker ruft diese Funktion je Modus ERNEUT (fauler Vorlauf, s. worker_main).
  # Das Protokoll des vorigen Aufrufs faellt dabei weg, statt bis zum Lauf-Ende
  # liegenzubleiben — sonst haelt ein Worker so viele Verzeichnisse offen, wie er Modi
  # beruehrt hat, und cleanup() kennt nur das letzte.
  [ -n "$PRERUN_LOG_DIR" ] && rm -rf "$PRERUN_LOG_DIR"
  log="$(prepare_prerun_log)" || return 1
  PRERUN_LOG_DIR="$(dirname "$log")"
  for m in "$@"; do
    # Erst die Zulassung, dann der Lauf: ein vertippter Modus liefe sonst als
    # `make <tippfehler>` und wuerde als "Baum ist rot" gemeldet — eine
    # irrefuehrende Diagnose fuer einen Kopf-Fehler (Review-Befund slice-026 N-4).
    if ! failure_form "$m" >/dev/null; then
      echo "mutate: ABBRUCH — unbekannter '# verify: $m' in test/mutations/." >&2
      echo "  Erlaubt ist, wofuer failure_form ein Fehlschlag-Muster kennt." >&2
      return 1
    fi
    echo "mutate: Gruen-Vorlauf make $m (muss VOR der ersten Mutation gruen sein)"
    if ! ( cd "$WORK" && make "$m" ) >"$log" 2>&1; then
      # Gemessen ist dieser eine Lauf: dieser Modus, diese Kopie, keine Mutation,
      # Exit != 0. Woran er lag, steht in den Zeilen darunter — die Meldung nennt es
      # nicht, weil der Treiber es nicht misst.
      echo "mutate: ABBRUCH — make $m ist in der isolierten Kopie ohne Mutation rot." >&2
      echo "  Ein Fall gegen diesen Sensor waere danach ebenfalls rot, aber nicht" >&2
      echo "  wegen SEINER Mutation." >&2
      echo "  Die letzten Zeilen von make $m:" >&2
      show_tail "$log"
      return 1
    fi
  done
}

# --- Warteschlange ----------------------------------------------------------
# Die Zuteilung ist DYNAMISCH: ein Worker zieht seinen naechsten Fall, wenn er frei ist.
# Traeger ist ein Cursor (eine Datei mit der naechsten Zeilennummer) unter einem
# mkdir-Mutex — dieselbe atomare, portable Mechanik wie der Lauf-Lock in main(), und
# ohne flock/jq/node/python (LH-QA-03). Ein FIFO waere kuerzer, aber zeilenweises Lesen
# durch MEHRERE Leser ist nicht garantiert atomar; der Cursor braucht diese Zusage nicht.
# Sensor: test/mutate-driver.bats „driver: die Warteschlange gibt jeden Eintrag genau
# einmal und meldet dann leer" — und, falls die Zuteilung doch danebengeht, die zweite
# Achse der Zusammenfuehrung (merge_report, „mehr als einmal gezogen").

# elapsed rechnet die Differenz zweier `date +%s.%N`-Marken in Sekunden. awk, weil bash
# keine Gleitkomma-Arithmetik kennt.
elapsed() { awk -v a="$1" -v b="$2" 'BEGIN { printf "%.2f", b - a }'; }

# abort_run legt die Flagge, an der JEDER Worker vor seinem naechsten Zug haengenbleibt.
# Ohne sie stoppte ein Isolations-Bruch nur den Worker, der ihn entdeckt.
abort_run() {
  [ -n "$RUN_DIR" ] && : >"$RUN_DIR/abort"
  return 0
}

# queue_new legt die Warteschlange <name> aus den Zeilen auf stdin an und setzt ihren
# Cursor auf den ersten Eintrag.
queue_new() {
  local name="$1"
  cat >"$RUN_DIR/$name.queue"
  printf '1\n' >"$RUN_DIR/$name.cursor"
}

# QUEUE_LOCK_TRIES x 0,05 s ist die Geduld eines Wartenden am Mutex. Sie ist eine
# FAIL-CLOSED-Schranke, kein Komfort: stirbt ein Worker, waehrend er den Mutex haelt,
# wartete ohne sie jeder andere ewig — der Lauf saehe aus wie ein langsamer Lauf und
# lieferte nie ein Ergebnis. Mit ihr bricht der Wartende ab und der Lauf wird rot.
# Bemessen am teuersten Fall (ein full-smoke-Lauf), damit ein LANGSAMER Halter nicht
# faelschlich fuer einen toten gehalten wird — der Halter gibt den Mutex frei, BEVOR er
# seinen Fall faehrt, dieser Wert ist also um Groessenordnungen zu grosszuegig.
QUEUE_LOCK_TRIES=6000

# queue_take zieht den naechsten Eintrag der Warteschlange <name> und druckt ihn.
# Status: 0 = Eintrag geliefert, 1 = Schlange leer, 2 = Mutex-Zeitueberschreitung,
# 3 = ein anderer Worker hat den Lauf abgebrochen.
queue_take() {
  local name="$1"
  local lock="$RUN_DIR/$name.lock" tries=0 pos line
  if [ -e "$RUN_DIR/abort" ]; then
    echo "mutate: Worker $WORKER_ID zieht nicht weiter — ein anderer Worker hat den Lauf abgebrochen." >&2
    return 3
  fi
  until mkdir "$lock" 2>/dev/null; do
    tries=$((tries + 1))
    if [ "$tries" -gt "$QUEUE_LOCK_TRIES" ]; then
      echo "mutate: ABBRUCH — Worker $WORKER_ID wartet seit $((tries / 20)) s auf den Warteschlangen-Mutex ($lock)." >&2
      echo "  Gemessen ist die Wartezeit, nicht ihr Grund; sicher ist nur, dass dieser Lauf" >&2
      echo "  kein vollstaendiges Ergebnis mehr liefern kann." >&2
      return 2
    fi
    sleep 0.05
  done
  pos="$(cat "$RUN_DIR/$name.cursor")"
  line="$(sed -n "${pos}p" "$RUN_DIR/$name.queue")"
  printf '%s\n' "$((pos + 1))" >"$RUN_DIR/$name.cursor"
  rmdir "$lock"
  [ -n "$line" ] || return 1
  printf '%s' "$line"
}

# case_mode liefert den Sensor-Modus eines Falls nach derselben Regel, die run_case
# anwendet: ein ausdruecklicher `# verify:`-Kopf schlaegt die Ableitung aus `# expect:`.
# Ein MEHRFACHER Kopf ergibt hier '-' statt eines Modus: run_case meldet ihn als Befund,
# bevor ein Sensor laeuft, ein Gruen-Vorlauf dafuer haette also keinen Gegenstand.
case_mode() {
  local v
  v="$(sed -n 's/^# verify: //p' "$1")"
  case "$v" in
    "") narrow_sensor "$(sed -n 's/^# expect: //p' "$1")" ;;
    *"
"*) printf '%s' '-' ;;
    *) printf '%s' "$v" ;;
  esac
}

# mode_rank ist der Sortierschluessel der Warteschlange: TEUERSTE MODI ZUERST
# (longest-processing-time-first). Zwei Wirkungen, beide tragend. (a) Ein Fall ist nicht
# teilbar; laeuft der teuerste zufaellig spaet an, haengt ein Worker allein nach, waehrend
# die uebrigen leerlaufen — die Wanduhr richtet sich dann nach dem Nachzuegler statt nach
# dem Durchschnitt. (b) Gleiche Modi liegen dabei von selbst beieinander, weil die Kosten
# je SENSOR konstant sind: absteigend nach Kosten sortieren IST nach Sensor gruppieren.
# Ein Worker beruehrt darum typisch ein bis zwei Modi, und jeder Wechsel kostet ihn einen
# Gruen-Vorlauf in seiner Kopie.
#
# Die REIHENFOLGE ist die Zusage, nicht die Zahl dahinter: welcher Modus wirklich wie
# teuer ist, misst der Lauf selbst und schreibt es in report_times. Weicht die dortige
# Reihenfolge von dieser ab, gehoert diese Funktion nachgezogen — der Rang ist eine
# Annahme ueber die Kosten, und report_times ist ihre Messung.
mode_rank() {
  case "$1" in
    full-smoke) printf '%s' '1' ;;
    test) printf '%s' '2' ;;
    smoke) printf '%s' '3' ;;
    test-bats) printf '%s' '4' ;;
    test-go) printf '%s' '5' ;;
    ci-lint) printf '%s' '6' ;;
    *) printf '%s' '9' ;;
  esac
}

# plan_self_contained entscheidet, ob das Urteil des Modus <1> vollstaendig in dem
# steckt, was `make -n` zeigt. Nur dann duerfen zwei Worker den Modus GLEICHZEITIG
# fahren; sonst gehoert er in die serielle Spur (is_heavy_mode).
#
# WORUM ES GEHT: `docker build` und `docker run` tragen ihr Urteil in ihrem eigenen
# Exit-Code. Zwei Worker duerfen denselben Image-Tag ueberschreiben, weil danach niemand
# ihn liest — jeder Build hat seinen eigenen Kontext, und der ist die Kopie des Workers.
# `harness/tools/artifact-copy.sh` bricht das: es holt das Binary mit
# `docker create`/`docker cp` AUS dem Tag, also NACH dem Bau. Liefen zwei Worker
# gleichzeitig durch ein solches Ziel, koennte der eine das Binary des anderen
# extrahieren — verschiedene Mutationen, falsches Urteil, und zwar eines, das still
# GRUEN meldet.
#
# DAS KRITERIUM IST DIE DELEGATION, NICHT DIE ZEILENFORM. Ein Plan, der ausschliesslich
# `docker build`/`docker run` ausfuehrt, ist vollstaendig gelesen. Ein Plan, der in ein
# Skript oder ein anderes Werkzeug abbiegt, ist es NICHT — was dort geschieht, steht
# nicht im Plan, und ein Treiber, der es dort nachschlaegt, bindet sich an die Gestalt
# fremder Zeilen. Genau daran ist der erste Entwurf zerbrochen: er suchte
# `artifact-copy.sh` eine Ebene tiefer ueber `^[[:space:]]*make ` in den Treiberskripten
# und verfehlte `full-smoke` in dem Moment, in dem eine fremde Aenderung
# `make artifact …` in eine Kommando-Substitution setzte (`x="$( make artifact … )"`) —
# der gefaehrlichste Modus galt danach als sicher, und kein Sensor sagte es.
#
# FAIL-CLOSED in beide Richtungen: ein Trockenlauf, der nicht auswertbar ist, und jede
# Zeile, die kein `docker build`/`docker run` ist, machen den Modus seriell.
# Falsch-seriell kostet Zeit, falsch-parallel kostet ein Urteil.
#
# GRENZE, benannt statt zugedeckt: gemessen wird EINMAL je Lauf, ueber dem HOST-Baum und
# vor der ersten Mutation. Ein Fall, der das Makefile so mutiert, dass sein Modus danach
# ein Bild ueber den Tag zurueckliest, liefe in der Spur, die vor seiner Mutation galt.
# Kein Fall in test/mutations/ tut das; wer den ersten schreibt, faellt hierunter.
# DER TROCKENLAUF LAEUFT OHNE DIE MAKE-UMGEBUNG SEINES AUFRUFERS, und das ist nicht
# Kosmetik. `make mutate` ruft diesen Treiber aus einer Rezeptur; ein `make` darin ist ein
# SUB-make und schaltet `--print-directory` von selbst ein. Gemessen, aus einer Rezeptur
# heraus (`sonde: <TAB> @make -n test-go`):
#   make[1]: Verzeichnis „…" wird betreten
#   docker build --no-cache-filter test … --target test -t ai-harness-init:test .
#   make[1]: Verzeichnis „…" wird verlassen
# Die zwei Rahmenzeilen sind kein docker-Aufruf — JEDER Modus fiel damit in die serielle
# Spur, und der ganze Lauf lief auf einem Worker. Dieselbe Funktion, aus einer normalen
# Shell gerufen, sagte das Gegenteil: die Zuordnung haing an der Umgebung des Aufrufers
# statt am Ziel. `env -u …` plus `--no-print-directory` macht den Trockenlauf davon
# unabhaengig — er sieht aus wie ein Aufruf von der Kommandozeile.
plan_self_contained() {
  local mode="$1" plan line
  plan="$( cd "$REPO" && env -u MAKEFLAGS -u MAKELEVEL -u MFLAGS \
    make --no-print-directory -n "$mode" 2>/dev/null )" || return 1
  [ -n "$plan" ] || return 1
  while IFS= read -r line; do
    # Leere Zeilen und Kommentar-Echos des Trockenlaufs tragen kein Kommando.
    case "$line" in
      "" | "#"*) continue ;;
    esac
    # Fuehrende Variablen-Zuweisungen (`GO_VERSION='…' bash …`) gehoeren zum Kommando
    # und werden uebersprungen, bis das erste Wort ohne '=' kommt.
    local -a words
    read -r -a words <<<"$line"
    local w=0
    while [ "$w" -lt "${#words[@]}" ]; do
      case "${words[$w]}" in
        *=*) w=$((w + 1)) ;;
        *) break ;;
      esac
    done
    [ "${words[$w]:-}" = "docker" ] || return 1
    case "${words[$((w + 1))]:-}" in
      build | run) ;;
      *) return 1 ;;
    esac
  done <<<"$plan"
  return 0
}

# is_heavy_mode fragt die einmal je Lauf erhobene Spur ab (main fuellt HEAVY_MODES).
is_heavy_mode() {
  grep -qF " $1 " <<<"$HEAVY_MODES"
}

# --- Worker -----------------------------------------------------------------
worker_cleanup() {
  restore
  [ -n "$PRERUN_LOG_DIR" ] && rm -rf "$PRERUN_LOG_DIR"
  return 0
}

# worker_main ist EIN Worker: eigene Kopie, eigener Vorlauf-Zustand, eigene Protokolle.
# Aufruf: worker_main <id> <schon-gruene-modi> <schlange>...
#
# GRUEN-VORLAUF FAUL, je Worker UND Modus: der Worker faehrt den Vorlauf eines Modus
# erst, wenn er den ersten Fall dieses Modus zieht — und dann in SEINER Kopie. Das ist
# gegenueber dem sequentiellen Treiber strikt MEHR Deckung, nicht weniger: der fuhr
# green_prerun EINMAL vor allen Faellen und vertraute danach durchgehend auf restore().
# Hier belegt jeder Worker seine eigene Kopie fuer jeden Modus, den er faehrt.
# Sensor: test/mutate-driver.bats „driver: ein Worker BRICHT AB, wenn sein Gruen-Vorlauf
# in SEINER Kopie rot ist"; der Zahn dazu ist test/mutations/192.
worker_main() {
  local id="$1" seen="$2"
  shift 2
  WORKER_ID="$id"
  WORK="$ISO_ROOT/w$id/repo"
  # Die fail-closed-Schranke gilt JE WORKER, nicht einmal fuer den Lauf: jeder Worker
  # setzt sein eigenes $WORK, und ein leeres oder repo-internes liesse SEINE Seds im
  # cwd des Treibers laufen (Review F-1).
  require_isolated || return 1
  # Alle Temp-Dateien dieses Workers (Fall-Backups, Vorlauf-Protokolle, die tmp-Repos
  # der Smokes) liegen unter seiner Kopie. Ein hart abgebrochener Worker laesst damit
  # nichts liegen, was das cleanup() des Elternteils nicht ohnehin mit ISO_ROOT wegraeumt.
  TMPDIR="$ISO_ROOT/w$id/tmp"
  export TMPDIR
  mkdir -p "$TMPDIR"
  trap 'worker_cleanup' EXIT INT TERM

  local queue rc line idx mode case_file log t0 t1 pt0 pt1 fc0 st
  for queue in "$@"; do
    while :; do
      rc=0
      line="$(queue_take "$queue")" || rc=$?
      case "$rc" in
        0) ;;
        1) break ;;
        *) return "$rc" ;;
      esac
      IFS=$'\t' read -r idx mode case_file <<<"$line"
      # Der Zug wird protokolliert, BEVOR der Fall laeuft: stirbt der Worker mitten im
      # Fall, ist der Zug belegt und die fehlende Statuszeile faellt als Befund auf.
      # Sensor: test/mutate-driver.bats „driver: merge_report FAELLT, wenn ein Fall ohne
      # Ergebnis geblieben ist"; der Zahn dazu ist test/mutations/193.
      printf '%s\n' "$idx" >>"$RUN_DIR/draws.$id"

      # Marker-Grep als Here-String, nicht `printf | grep -q`: unter pipefail bricht
      # ein grep, das frueh aussteigt, die Pipe mit EPIPE — und der Treffer saehe wie
      # ein Fehlschlag aus.
      if [ "$mode" != "-" ] && ! grep -qF " $mode " <<<" $seen "; then
        pt0="$(date +%s.%N)"
        if ! green_prerun "$mode" >>"$RUN_DIR/prerun.$id.log" 2>&1; then
          echo "mutate: ABBRUCH — Worker $id: der Gruen-Vorlauf 'make $mode' ist in SEINER Kopie ohne Mutation rot." >&2
          echo "  Jeder Fall dieses Modus waere danach ebenfalls rot, aber nicht wegen SEINER Mutation." >&2
          cat "$RUN_DIR/prerun.$id.log" >&2
          abort_run
          return 1
        fi
        pt1="$(date +%s.%N)"
        printf '%s\t%s\t%s\n' "$id" "$mode" "$(elapsed "$pt0" "$pt1")" >>"$RUN_DIR/prerun.times.$id"
        seen="$seen $mode"
      fi

      # Die Ausgabe des Falls geht in SEINE eigene Datei — merge_report setzt sie in
      # Fall-Reihenfolge zusammen, unabhaengig davon, wie die Laeufe verschraenkt waren.
      log="$RUN_DIR/case.$idx.log"
      fc0="$fail_count"
      t0="$(date +%s.%N)"
      { run_case "$case_file"; } >"$log" 2>&1
      t1="$(date +%s.%N)"
      # Das Urteil kommt aus dem Zaehler, den run_case selbst fuehrt — nicht aus einem
      # zweiten Kriterium daneben, das mit ihm auseinanderlaufen koennte.
      if [ "$fail_count" -gt "$fc0" ]; then st="BEFUND"; else st="OK"; fi
      printf '%s\t%s\t%s\t%s\t%s\n' \
        "$idx" "$(basename "$case_file" .sh)" "$st" "$mode" "$(elapsed "$t0" "$t1")" \
        >"$RUN_DIR/status.$idx"
      # FORTSCHRITT auf Deskriptor 3, in der Reihenfolge des Laufs — nicht der Bericht.
      # Der entsteht erst am Ende (merge_report), und ohne diese Zeile schwiege ein Lauf
      # ueber Minuten vollstaendig: an einem stummen Sensor ist nicht unterscheidbar, ob
      # er arbeitet oder haengt. Bewusst getrennt vom Bericht, dessen Reihenfolge gerade
      # NICHT vom Scheduler abhaengen darf.
      printf 'mutate: [w%s] %-42s %s (%s s)\n' "$id" "$(basename "$case_file" .sh)" "$st" "$(elapsed "$t0" "$t1")" >&3
    done
  done
  return 0
}

# --- Zusammenfuehrung -------------------------------------------------------
# merge_report setzt die Fall-Protokolle in FALL-Reihenfolge zusammen und BELEGT die
# Vollstaendigkeit. Die Zeilenfolge des Berichts haengt damit nicht daran, wie die Laeufe
# verschraenkt waren; ein Bericht, den der Scheduler umsortiert, waere als Sensor-Ausgabe
# nicht vergleichbar (LH-QA-02).
#
# Drei Wege in ein stilles Gruen sind hier zugehalten, jeder mit eigener Meldung:
#   1. ein Fall OHNE Statuszeile (Worker gestorben, Fall nie gezogen)   -> Befund,
#   2. eine Fall-ID MEHR ALS EINMAL gezogen (Cursor-Defekt)             -> Befund,
#   3. die Zahl der gelaufenen Faelle weicht von der Zahl der FALL-DATEIEN ab -> Befund.
# Der dritte ist nicht redundant: 1 und 2 messen gegen die Warteschlange, 3 gegen das
# Verzeichnis. Waere die Warteschlange selbst unvollstaendig gebaut worden, waeren 1 und 2
# still gruen — genau die Konstruktion, gegen die dieser Sensor antritt.
merge_report() {
  local total="$1" i st_line st
  for ((i = 1; i <= total; i++)); do
    if [ -f "$RUN_DIR/case.$i.log" ]; then cat "$RUN_DIR/case.$i.log"; fi
  done

  # (1) Statuszeilen, in Fall-Reihenfolge, und die Faelle ohne eine solche. Die Liste
  # wird GEKUERZT, aber ihre Laenge genannt: ein Abbruch laesst leicht dreistellig viele
  # Faelle ohne Ergebnis, und eine Meldung, die man nicht mehr liest, ist keine.
  local missing="" missing_n=0 gelaufen=0
  for ((i = 1; i <= total; i++)); do
    if [ ! -f "$RUN_DIR/status.$i" ]; then
      missing_n=$((missing_n + 1))
      if [ "$missing_n" -le 12 ]; then missing="$missing ${CASE_NAMES[$i]}"; fi
      continue
    fi
    st_line="$(cat "$RUN_DIR/status.$i")"
    # Nur das Urteil wird hier gebraucht; Name, Modus und Zeit stehen im Bericht
    # (report_times) und in der Statuszeile selbst.
    IFS=$'\t' read -r _ _ st _ _ <<<"$st_line"
    gelaufen=$((gelaufen + 1))
    if [ "$st" = "BEFUND" ]; then
      fail_count=$((fail_count + 1))
    else
      pass_count=$((pass_count + 1))
    fi
  done
  if [ "$missing_n" -gt 0 ]; then
    if [ "$missing_n" -gt 12 ]; then missing="$missing … (${missing_n} insgesamt)"; fi
    report_fail "vollstaendigkeit" "ohne Ergebnis geblieben:$missing — ein Worker ist gestorben oder die Warteschlange hat den Fall nie ausgegeben"
  fi

  # (2) Jede gezogene ID GENAU EINMAL. Gemessen an den Zug-Protokollen der Worker, nicht
  # an den Statusdateien: die tragen die ID im NAMEN, ein Doppelzug ueberschriebe die
  # Datei und bliebe damit unsichtbar.
  #
  # nullglob, weil ein Glob OHNE Treffer sonst als Literal an `cat` geht: das scheitert,
  # unter `pipefail` faellt die ganze Pipe, und die Zuweisung reisst unter `set -e` den
  # Bericht ab — ausgerechnet in dem Fall, in dem KEIN Worker je gezogen hat und die
  # Meldung am noetigsten waere.
  local doppelt
  local -a draw_files
  shopt -s nullglob
  draw_files=("$RUN_DIR"/draws.*)
  shopt -u nullglob
  if [ "${#draw_files[@]}" -gt 0 ]; then
    doppelt="$(cat "${draw_files[@]}" | LC_ALL=C sort -n | uniq -d | tr '\n' ' ')"
  else
    doppelt=""
    report_fail "vollstaendigkeit" "kein einziger Worker hat ein Zug-Protokoll hinterlassen — der Lauf hat nichts gemessen"
  fi
  if [ -n "${doppelt// /}" ]; then
    # Die Meldung nennt, was GEMESSEN ist — dieselbe Nummer mehrfach ausgegeben —, nicht
    # den Mechanismus dahinter. Der kann ein nicht fortgeschriebener Cursor sein oder ein
    # ausgefallener Mutex (dann lesen mehrere Worker denselben Stand, und der Cursor
    # stimmt trotzdem); der Treiber unterscheidet das nicht und behauptet es darum nicht.
    report_fail "vollstaendigkeit" "mehr als einmal gezogen (Fall-Nummern): $doppelt — die Warteschlange hat dieselbe Nummer mehrfach ausgegeben und teilt damit nicht mehr zu"
  fi

  # (3) Zahl der gelaufenen Faelle gegen die Zahl der Fall-DATEIEN.
  local unvollstaendig=""
  if [ "$gelaufen" -ne "$total" ]; then
    report_fail "vollstaendigkeit" "$gelaufen von $total Fall-Dateien haben ein Ergebnis — der Lauf ist unvollstaendig"
    unvollstaendig=1
  fi
  # Die BESTAETIGUNG faellt weg, sobald eine der drei Pruefungen angeschlagen hat. Ein
  # Lauf, der „jede Fall-ID genau einmal gezogen" meldet und daneben einen fehlenden Fall
  # als Befund fuehrt, sagt in derselben Ausgabe beides — und die Bestaetigung ist die
  # Zeile, die man zuerst glaubt.
  if [ -z "$unvollstaendig" ] && [ "$missing_n" -eq 0 ] && [ -z "${doppelt// /}" ]; then
    echo "mutate: Vollstaendigkeit — $gelaufen von $total Fall-Dateien mit Ergebnis, jede Fall-ID genau einmal gezogen."
  fi
}

# report_times ist die Zeit-Aufschluesselung: je Fall eine Dauer, je Sensor Summe und
# ANTEIL an der Fall-Arbeit. Sie ist MESSUNG, kein Urteil ueber einen Waechter — die
# Zahlen haengen an der Maschine und an dem, was sonst auf ihr laeuft; ein Schwellenwert
# darueber waere rot ohne Befund und gruen ohne Deckung (LH-QA-01).
#
# UEBER IHRE EIGENE VOLLSTAENDIGKEIT urteilt sie aber sehr wohl, und darum nennt sie
# ihren Nenner: Anteile ueber einer Teilmenge sind Anteile an etwas anderem als dem, was
# die Ueberschrift sagt. Weicht die Zahl der Faelle mit Dauer von der Zahl der
# Fall-Dateien ab, gibt es KEINE Bilanz, sondern einen Befund.
report_times() {
  local total="$1"
  local -a status_files prerun_files
  # Dieselbe nullglob-Vorsicht wie in merge_report: ein leerer Glob ginge als Literal an
  # `cat` und risse unter `pipefail`/`set -e` den Bericht ab.
  shopt -s nullglob
  status_files=("$RUN_DIR"/status.*)
  prerun_files=("$RUN_DIR"/prerun.times.*)
  shopt -u nullglob
  local n=0
  if [ "${#status_files[@]}" -gt 0 ]; then n="${#status_files[@]}"; fi
  if [ "$n" -ne "$total" ]; then
    report_fail "zeit-bilanz" "$n von $total Fall-Dateien tragen eine Dauer — eine Bilanz ueber einer Teilmenge nennt Anteile, die nicht gelten"
    return 0
  fi

  echo "mutate: Zeit je Sensor ueber $n von $total Fall-Dateien (Summe / Anteil / Mittel / laengster Fall, Sekunden):"
  cat "${status_files[@]}" | awk -F'\t' '
    { n[$4]++; s[$4] += $5; g += $5; if ($5 + 0 > m[$4] + 0) { m[$4] = $5; mn[$4] = $2 } }
    END {
      for (k in n)
        printf "  %-12s n=%-4d summe=%9.1f anteil=%5.1f%% mittel=%6.2f max=%7.2f (%s)\n",
               k, n[k], s[k], (g > 0 ? 100 * s[k] / g : 0), s[k] / n[k], m[k], mn[k]
    }
  ' | LC_ALL=C sort
  if [ "${#prerun_files[@]}" -gt 0 ]; then
    echo "mutate: Gruen-Vorlaeufe (Worker, Modus, Sekunden) — der Preis der Aufteilung:"
    cat "${prerun_files[@]}" | LC_ALL=C sort | sed -e 's/^/  /'
  fi
  echo "mutate: Zeit je Fall, absteigend (alle $n):"
  cat "${status_files[@]}" | LC_ALL=C sort -t"$(printf '\t')" -k5,5gr \
    | awk -F'\t' '{ printf "  %8.2f s  %-42s %s\n", $5, $2, $4 }'
  cat "${status_files[@]}" | awk -F'\t' '
    { s += $5; if ($5 + 0 > m + 0) { m = $5; mn = $2 } }
    END { printf "mutate: untere Schranke jeder Parallelisierung = laengster Einzelfall: %.2f s (%s); Fall-Arbeit gesamt %.1f s\n", m, mn, s }
  '
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

  # Fail-closed auf die Worker-Zahl. Ohne diese Schranke liefe eine unsinnige Vorgabe
  # (leer, 0, Text) auf null Worker hinaus: die Warteschlange bliebe voll, kein Fall
  # liefe, und der Lauf faende seinen Befund erst in der Zusammenfuehrung — als
  # Vollstaendigkeits-Meldung statt als das, was er ist, ein Aufruf-Fehler.
  case "$JOBS" in
    "" | *[!0-9]*) JOBS=0 ;;
  esac
  if [ "$JOBS" -lt 1 ]; then
    echo "mutate: ABBRUCH — MUTATE_JOBS ist keine Worker-Zahl >= 1 (gelesen: '${MUTATE_JOBS:-}')." >&2
    exit 1
  fi

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
  RUN_DIR="$ISO_ROOT/run"
  mkdir -p "$RUN_DIR"
  # Deskriptor 3 ist die Fortschritts-Ausgabe des Laufs. Die Worker leiten stdout und
  # stderr je in eine eigene Datei um — der Bericht muss deterministisch bleiben —, ihre
  # Fortschrittszeile soll aber den Aufrufer erreichen und nicht die Datei. Er wird HIER
  # geoeffnet und nicht im Kopf der Datei: test/mutate-driver.bats sourct den Treiber,
  # und bats fuehrt auf Deskriptor 3 seine eigene Ausgabe.
  exec 3>&2

  # Die Fall-Nummer ist die Stelle des Falls in der SORTIERTEN Datei-Liste. Sie ist der
  # Schluessel, an dem der Bericht wieder in Fall-Reihenfolge kommt — und die Groesse,
  # gegen die die Vollstaendigkeit gemessen wird. 1-basiert, damit sie mit den
  # Zeilennummern der Warteschlange zusammenfaellt.
  local total="${#cases[@]}" i mode rank
  CASE_NAMES=()
  CASE_MODES=()
  for ((i = 1; i <= total; i++)); do
    CASE_NAMES[i]="$(basename "${cases[$((i - 1))]}" .sh)"
  done

  # Modus je Fall, und die Zulassung EINMAL vorab statt erst beim Ziehen: ein vertippter
  # `# verify:`-Kopf soll den Lauf sofort anhalten, nicht nach zwanzig Minuten Arbeit.
  # Quelle der erlaubten Modi bleibt failure_form — keine zweite Liste (N-2).
  local used_modes=" "
  for ((i = 1; i <= total; i++)); do
    mode="$(case_mode "${cases[$((i - 1))]}")"
    if [ "$mode" != "-" ] && ! failure_form "$mode" >/dev/null; then
      echo "mutate: ABBRUCH — unbekannter '# verify: $mode' in test/mutations/." >&2
      echo "  Erlaubt ist, wofuer failure_form ein Fehlschlag-Muster kennt." >&2
      exit 1
    fi
    if ! grep -qF " $mode " <<<"$used_modes"; then used_modes="$used_modes$mode "; fi
    CASE_MODES[i]="$mode"
  done

  # Welche Modi duerfen NICHT nebeneinander laufen? Einmal je Lauf gemessen, bevor die
  # erste Kopie steht — die Antwort entscheidet, welche Faelle sich einen Docker-Tag
  # teilen duerfen, und eine falsche Antwort hier ist ein falsches Urteil dort.
  # Der Pseudo-Modus '-' hat keinen Sensor-Lauf und darum keine Spur.
  for mode in $used_modes; do
    [ "$mode" = "-" ] && continue
    if ! plan_self_contained "$mode"; then HEAVY_MODES="$HEAVY_MODES$mode "; fi
  done
  if [ -n "${HEAVY_MODES// /}" ]; then
    echo "mutate: serielle Spur fuer:${HEAVY_MODES% } — ihr Plan besteht nicht nur aus docker-Aufrufen, ihr Urteil ist damit nicht vollstaendig gelesen."
  fi

  # Zwei Warteschlangen: die schwere laeuft in EINER Spur, die leichte leeren alle
  # Worker dynamisch. Der Rang steht beim Sortieren vorn und faellt danach weg; die
  # Schlange traegt Nummer, Modus und Fall-Datei.
  local heavy_lines="" light_lines="" line
  for ((i = 1; i <= total; i++)); do
    mode="${CASE_MODES[$i]}"
    rank="$(mode_rank "$mode")"
    line="$(printf '%s\t%s\t%s\t%s' "$rank" "$i" "$mode" "${cases[$((i - 1))]}")"
    if [ "$mode" != "-" ] && is_heavy_mode "$mode"; then
      heavy_lines="$heavy_lines$line"$'\n'
    else
      light_lines="$light_lines$line"$'\n'
    fi
  done
  printf '%s' "$heavy_lines" | LC_ALL=C sort | cut -f2- | queue_new heavy
  printf '%s' "$light_lines" | LC_ALL=C sort | cut -f2- | queue_new light

  # Je Worker eine eigene Kopie. prepare_isolation ist dieselbe Mechanik wie zuvor, nur
  # JOBS-mal gerufen; require_isolated haelt fuer jede einzelne.
  local j
  for ((j = 1; j <= JOBS; j++)); do
    mkdir -p "$ISO_ROOT/w$j"
    WORK="$(prepare_isolation "$ISO_ROOT/w$j")"
    require_isolated || exit 1
  done
  echo "mutate: $JOBS isolierte Kopie(n) unter $ISO_ROOT — der Host-Baum wird NICHT veraendert."

  # DAS BILD EINMAL VOR DEM FORK. `make test-go` uebersetzt die deps- und warm-Stufen
  # des Dockerfile; ohne diesen Lauf konkurrierten JOBS gleichzeitige Builds um denselben
  # BuildKit-Cache und uebersetzten die Standardbibliothek mehrfach. Es ist zugleich ein
  # vollwertiger Gruen-Vorlauf fuer Kopie 1 — derselbe Modus, dieselbe Kopie, keine
  # Mutation —, deshalb startet Worker 1 mit test-go als bereits gruen gesehen.
  # Uebersprungen, wenn kein Fall eine Go-Stufe faehrt: dann gaebe es nichts vorzuwaermen.
  local warm_seen=""
  if grep -qF " test-go " <<<"$used_modes" || grep -qF " test " <<<"$used_modes"; then
    WORK="$ISO_ROOT/w1/repo"
    require_isolated || exit 1
    echo "mutate: Bild einmal vor dem Fork (Kopie 1) — sonst baeuten $JOBS Worker dieselben Stufen gleichzeitig."
    green_prerun test-go || exit 1
    warm_seen="test-go"
  fi

  echo "mutate: $total Faelle auf $JOBS Worker, dynamisch aus einer gemeinsamen Warteschlange."
  local -a pids=()
  for ((j = 1; j <= JOBS; j++)); do
    # Worker 1 leert ERST die schwere Spur (sie ist die untere Schranke des Laufs) und
    # geht dann in die leichte. Alle uebrigen fahren nur die leichte.
    if [ "$j" -eq 1 ]; then
      ( rc=0; worker_main "$j" "$warm_seen" heavy light || rc=$?
        printf '%s\n' "$rc" >"$RUN_DIR/worker.$j.done"; exit "$rc" ) \
        >"$RUN_DIR/worker.$j.log" 2>&1 &
    else
      ( rc=0; worker_main "$j" "" light || rc=$?
        printf '%s\n' "$rc" >"$RUN_DIR/worker.$j.done"; exit "$rc" ) \
        >"$RUN_DIR/worker.$j.log" 2>&1 &
    fi
    pids+=("$!")
  done

  # EIN WORKER, DER STIRBT, MACHT DEN LAUF ROT — hier faellt es auf. Die Marker-Datei
  # unterscheidet dabei, WAS gemessen ist: liegt sie, hat der Worker seinen eigenen Rumpf
  # zu Ende gefuehrt und seinen Status selbst gemeldet (sein Protokoll sagt, warum);
  # fehlt sie, ist er unterwegs ausgestiegen. Warum, misst der Treiber nicht — und
  # behauptet es darum auch nicht.
  local k pid wrc
  for ((k = 0; k < ${#pids[@]}; k++)); do
    pid="${pids[$k]}"
    wrc=0
    wait "$pid" || wrc=$?
    if [ "$wrc" -ne 0 ]; then
      if [ -f "$RUN_DIR/worker.$((k + 1)).done" ]; then
        report_fail "worker-$((k + 1))" "Worker kehrte mit Status $wrc zurueck — sein Anteil an der Fall-Menge ist unvollstaendig"
      else
        report_fail "worker-$((k + 1))" "Worker endete mit Status $wrc OHNE Abschluss-Marke, ist also nicht bis zum Ende seines Rumpfes gekommen — sein Anteil an der Fall-Menge ist unvollstaendig"
      fi
    fi
  done

  # Die Ausgabe, die ein Worker AUSSERHALB eines Falls geschrieben hat (Vorlauf-Abbruch,
  # Mutex-Zeitueberschreitung), in Worker-Reihenfolge — sie erklaert die Befunde oben.
  for ((j = 1; j <= JOBS; j++)); do
    if [ -s "$RUN_DIR/worker.$j.log" ]; then
      echo "mutate: --- Worker $j ---" >&2
      sed -e 's/^/    | /' "$RUN_DIR/worker.$j.log" >&2
    fi
  done

  merge_report "$total"

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

  report_times "$total"
  echo "mutate: $pass_count ok, $fail_count Befund(e)"
  [ "$fail_count" -eq 0 ]
}

# Nur bei DIREKTEM Aufruf laufen, nicht beim Sourcen.
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  main "$@"
fi

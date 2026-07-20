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
#   - KEINE Aussage ueber Waechter, die kein Fall adressiert.
# Nicht mehr auf `make test` beschraenkt: `# verify: smoke` faehrt einen Fall
# gegen den Tier-2-Sensor. Die frueher hier stehende Zusage "Waechter in
# make smoke sind bauartbedingt nicht abdeckbar" war eine Scope-Aussage, die als
# Architektur-Aussage auftrat (Review-Befund slice-026 F-5).
# Kein node/jq/python — bash, coreutils, GNU sed. `sed` statt `perl` (Befund F-4:
# die frueheren Faelle brauchten Host-perl, waehrend der Kopf "bash + coreutils"
# zusagte). Die Faelle nutzen `sed -i` und GNU-BRE-Escapes, sind also NICHT strikt
# POSIX — die zwischenzeitliche POSIX-Zusage griff weiter als der Code (N-3).
#
# FAIL-CLOSED, vier Bedingungen. Der Sensor misst die ABWESENHEIT von Rot und
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
#
# NICHT in `make gates`: jede Mutation kostet einen vollen Docker-test-Zyklus
# (--no-cache-filter, also kein Cache-Grun). Nicht-Gate-Verify neben `make smoke`
# — gebunden an DoD-Verify/Closure, nicht an jeden Commit (LH-QA-01).
#
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CASES_DIR="$REPO/test/mutations"
BACKUP=""

restore() {
  [ -n "$BACKUP" ] || return 0
  # Alles zurueckspielen, was gesichert wurde. tar bewahrt die relativen Pfade.
  if [ -f "$BACKUP/files.tar" ]; then
    tar -xf "$BACKUP/files.tar" -C "$REPO"
  fi
  rm -rf "$BACKUP"
  BACKUP=""
}
# Auch bei Abbruch (Ctrl-C, Kill) den Baum zuruecklassen, wie er war.
trap 'restore' EXIT INT TERM

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
    test)  printf '%s' '--- FAIL:|not ok [0-9]+' ;;  # go test | bats
    smoke) printf '%s' 'smoke: FEHLER' ;;            # harness/tools/smoke.sh
    *)     return 1 ;;
  esac
}

run_case() {
  local case_file="$1"
  local name files expect verify form
  name="$(basename "$case_file" .sh)"

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
  ( cd "$REPO" && tar -cf "$BACKUP/files.tar" "${file_list[@]}" )
  # Fuer Bedingung 2 zaehlt der INHALT, nicht die Metadaten: `sed -i` (wie zuvor
  # `perl -pi`) schreibt die Datei auch dann neu, wenn keine Substitution greift —
  # die mtime aendert sich, der Inhalt nicht. Ein tar-Vergleich meldete dann
  # faelschlich "veraendert" und liesse den veralteten Patch als Bedingung 3
  # durchgehen (eigener Sonden-Befund beim Bau dieses Sensors).
  ( cd "$REPO" && sha256sum "${file_list[@]}" >"$BACKUP/before.sums" )

  # (1) Mutation anwenden. Die Ausgabe wandert in die Meldung, nicht in eine
  # Datei — restore() raeumt das Temp-Verzeichnis sofort weg, ein Pfad-Zeiger
  # darin ginge ins Leere (Review-Befund slice-026, LOW).
  local mut_out
  if ! mut_out="$( cd "$REPO" && bash "$case_file" 2>&1 )"; then
    report_fail "$name" "Mutations-Skript scheiterte: ${mut_out//$'\n'/ }"
    restore
    return
  fi

  # (2) Hat sie ueberhaupt gegriffen? Ein wirkungsloser Patch wuerde sonst als
  # "Waechter intakt" durchgehen — der Sensor waere still gruen.
  if ( cd "$REPO" && sha256sum -c "$BACKUP/before.sums" ) >/dev/null 2>&1; then
    report_fail "$name" "Mutation hat nichts veraendert — Patch veraltet?"
    restore
    return
  fi

  # (3)+(4) Sensor-Lauf: rot erwartet, und zwar am benannten Waechter.
  local out rc=0
  out="$BACKUP/verify.log"
  ( cd "$REPO" && make "$verify" ) >"$out" 2>&1 || rc=$?

  if [ "$rc" -eq 0 ]; then
    report_fail "$name" "make $verify blieb GRUEN — '$expect' hat keine Zaehne mehr"
    restore
    return
  fi
  # Nur FEHLSCHLAG-Zeilen zaehlen. bats druckt jeden Testnamen AUCH beim Bestehen
  # ("ok 21 emittiert: eingelegter SYMLINK"), ein blosses grep auf den Namen war
  # damit fuer jeden bats-Fall unter allen Bedingungen erfuellt — Bedingung 4 war
  # dort wirkungslos (Review-Befund slice-026 F-1, per Sonde belegt). Erst die
  # Fehlschlag-Form ist eine Aussage — und sie ist je Sensor eine andere.
  if ! grep -E -- "$form" "$out" | grep -qF -- "$expect"; then
    report_fail "$name" "rot, aber '$expect' faellt nicht — falscher Grund"
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
  [ -d "$CASES_DIR" ] || { echo "mutate: $CASES_DIR fehlt" >&2; exit 1; }

  shopt -s nullglob
  cases=("$CASES_DIR"/*.sh)
  shopt -u nullglob
  if [ "${#cases[@]}" -eq 0 ]; then
    # Ein leeres Set waere ein gruener Lauf ohne jede Aussage — genau das stille
    # Gruen, gegen das der Sensor gerichtet ist.
    echo "mutate: keine Faelle in $CASES_DIR — ein leeres Set ist kein gruener Lauf" >&2
    exit 1
  fi

  # GRUEN-VORLAUF vor der ersten Mutation (Review-Befund slice-026 F-6). Ohne ihn
  # wuerde jeder Fall auf einem bereits roten Baum "bestehen" — aus dem falschen
  # Grund. Der Fall ist nicht theoretisch: waehrend des Reviews faerbte ein
  # paralleler mutate-Lauf im selben Arbeitsbaum die Tests rot.
  # Je Sensor, den irgendein Fall benutzt — sonst liefe ein smoke-Fall auf einem
  # bereits roten smoke los und "bestuende".
  modes="$(sed -n 's/^# verify: //p' "$CASES_DIR"/*.sh | LC_ALL=C sort -u)"
  [ -n "$modes" ] || modes=""
  for m in test $modes; do
    echo "mutate: Gruen-Vorlauf make $m (muss VOR der ersten Mutation gruen sein)"
    if ! ( cd "$REPO" && make "$m" ) >/dev/null 2>&1; then
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

  echo "mutate: $pass_count ok, $fail_count Befund(e)"
  [ "$fail_count" -eq 0 ]
}

# Nur bei DIREKTEM Aufruf laufen, nicht beim Sourcen.
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  main "$@"
fi

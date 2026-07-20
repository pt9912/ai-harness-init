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
# WAS ES NICHT LEISTET, dreifach:
#   - HALTBARKEIT statt ENTSTEHUNG: ein neu geschriebener Waechter ohne Mutation
#     im Set bleibt unbewacht — kuratiert heisst unvollstaendig. Die
#     Entstehungs-Seite haengt an Schritt 19 der Pre-completion-Checkliste.
#   - NUR was `make test` faehrt. Waechter in `make smoke` (Tier 2) sind
#     bauartbedingt nicht abdeckbar, weil run_case nur `make test` aufruft.
#   - KEINE Aussage ueber Waechter, die in DIESEM Lauf gar nicht adressiert sind.
# Kein node/jq/python — bash, coreutils, sed. `sed` statt `perl`, weil POSIX es
# garantiert und das Repo sonst kein perl braucht (Review-Befund slice-026 F-4:
# die frueheren Faelle brauchten Host-perl, waehrend der Kopf "bash + coreutils"
# zusagte — die Zusage war weiter als die Abdeckung, ausgerechnet hier).
#
# FAIL-CLOSED, vier Bedingungen. Der Sensor misst die ABWESENHEIT von Rot und
# koennte darum selbst still gruen werden; jede dieser Bedingungen schliesst
# einen Weg dorthin:
#   1. Das Mutations-Skript scheitert            -> Befund (nicht uebersprungen).
#   2. Die Mutation aendert die Datei NICHT      -> Befund. Das faengt den
#      veralteten Patch: waere er nur wirkungslos, saehe "kein Rot" wie
#      "Zaehne intakt" aus.
#   3. `make test` bleibt GRUEN                  -> Befund. Der eigentliche Zweck.
#   4. `make test` wird rot, aber der ERWARTETE  -> Befund. Rot aus dem falschen
#      Test steht nicht in der Ausgabe              Grund ist kein Beleg.
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

run_case() {
  local case_file="$1"
  local name files expect
  name="$(basename "$case_file" .sh)"

  files="$(sed -n 's/^# files: //p' "$case_file")"
  expect="$(sed -n 's/^# expect: //p' "$case_file")"
  if [ -z "$files" ] || [ -z "$expect" ]; then
    report_fail "$name" "Kopf unvollstaendig: '# files:' und '# expect:' sind Pflicht"
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

  # (3)+(4) Testlauf: rot erwartet, und zwar am benannten Test.
  local out rc=0
  out="$BACKUP/test.log"
  ( cd "$REPO" && make test ) >"$out" 2>&1 || rc=$?

  if [ "$rc" -eq 0 ]; then
    report_fail "$name" "make test blieb GRUEN — '$expect' hat keine Zaehne mehr"
    restore
    return
  fi
  # Nur FEHLSCHLAG-Zeilen zaehlen. bats druckt jeden Testnamen AUCH beim Bestehen
  # ("ok 21 emittiert: eingelegter SYMLINK"), ein blosses grep auf den Namen war
  # damit fuer jeden bats-Fall unter allen Bedingungen erfuellt — Bedingung 4 war
  # dort wirkungslos (Review-Befund slice-026 F-1, per Sonde belegt). Erst die
  # Fehlschlag-Form ist eine Aussage: `--- FAIL:` (go test) bzw. `not ok N` (bats).
  if ! grep -E -- '--- FAIL:|not ok [0-9]+' "$out" | grep -qF -- "$expect"; then
    report_fail "$name" "rot, aber '$expect' faellt nicht — falscher Grund"
    restore
    return
  fi

  printf 'mutate: ok      %-42s %s\n' "$name" "-> $expect rot"
  pass_count=$((pass_count + 1))
  restore
}

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
echo "mutate: Gruen-Vorlauf (make test muss VOR der ersten Mutation gruen sein)"
if ! ( cd "$REPO" && make test ) >/dev/null 2>&1; then
  echo "mutate: ABBRUCH — make test ist schon ohne Mutation rot." >&2
  echo "  Auf rotem Baum ist jeder Fall bedeutungslos: er waere rot, aber nicht" >&2
  echo "  wegen SEINER Mutation. Erst den Baum gruen bekommen." >&2
  exit 1
fi

echo "mutate: ${#cases[@]} Faelle (je ein voller make-test-Zyklus, das dauert)"
for c in "${cases[@]}"; do
  run_case "$c"
done

echo "mutate: $pass_count ok, $fail_count Befund(e)"
[ "$fail_count" -eq 0 ]

#!/usr/bin/env bats
# stamp-records-mechanik.bats — Waechter ueber dem Mutations-Result-Konsum in Fall-Form
# (harness/tools/mutate.sh --stamp-records, ADR-0107 Festlegung 1-3).
#
# Der Waechter fuehrt das REALE Werkzeug ueber einer Isolationskopie aus (der Treiber
# leitet REPO/CASES_DIR aus seinem eigenen Ort ab — der Kopf von harness/tools/mutate.sh
# traegt die Kopier-Begruendung): je Test ein frisches Fixture mit Stub-Faellen unter
# test/mutations/ und Result-Files in der Fassung des `ergebnis`-Schritts
# (harness/tools/mutate-auswahl.sh, ergebnis_schreiben). Je fail-closed-Grenze wird
# behauptet: Exit 1, die Meldung nennt die Grenze, und der Fall-File-Bestand bleibt
# byte-gleich (ADR-0107 Festlegung 3: "ohne den Fall-File-Bestand anzutasten"). Der
# "nicht lesbar"-Zweig bleibt hier unbedeckt — eine als root laufende Test-Stufe liest
# jede chmod-000-Datei; er ist Code, nicht ein Bats-Fall (Grenze auch im
# Sensor-Doku-Update dieses Slices).

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  ISO="$(mktemp -d)"
  mkdir -p "$ISO/harness/tools" "$ISO/test/mutations" "$ISO/.harness/stamp/mutate"
  cp "$REPO/harness/tools/mutate.sh" "$ISO/harness/tools/mutate.sh"
  printf '# stub\n' >"$ISO/test/mutations/910-stub-fall-a.sh"
  printf '# stub\n' >"$ISO/test/mutations/911-stub-fall-b.sh"
  STAMP="$ISO/.harness/stamp/mutate"
}

teardown() {
  rm -rf "$ISO"
}

# ergebnis schreibt ein Result-File in der Fassung des `ergebnis`-Schritts:
# je Fall <name> mit Verdikt <form> (ok|BEFUND) eine per-Fall-Zeile, <form> leer =
# Zeile entfaellt; sonstige Zeilen (Shard-Belege, Fallmenge, Urteil) traegt es der
# Form halber mit, gelesen wird von --stamp-records allein die per-Fall-Ebene.
ergebnis() {
  {
    echo "mutate-ergebnis: slice-stamp-records-konsum-v1"
    echo "gepruefter Commit: 625cdef096cfeec27cda3f3fcfd9cbb0960b2212"
    if [ -n "${2:-}" ]; then printf '%-8s %-56s Shard 0\n' "$2" "$1"; fi
    if [ -n "${4:-}" ]; then printf '%-8s %-56s Shard 1\n' "$4" "$3"; fi
    echo "Fallmenge: 2 (Slice: 2)"
    echo "Urteil: BEFUND"
  } >"$ISO/ergebnis.txt"
}

# snap_bestand haelt die Fassung des Fall-File-Bestands vor und nach einem Abbruch
# dagegen — Pfadliste plus md5 je Datei, darueber ein md5; der Vergleich zeigt
# byte-gleich, dass "ohne den Fall-File-Bestand anzutasten" gehalten wurde.
snap_bestand() {
  if [ -n "$(ls "$STAMP" 2>/dev/null)" ]; then
    { ls "$STAMP"; md5sum "$STAMP"/*.txt; } | md5sum
  else
    echo leer
  fi
}

@test "stamp: ein Happy-Konsum haengt je Verdikt-Fall genau eine Festlegung-1-Zeile an und setzt je neuem Fall-File den Kopf" {
  ergebnis "910-stub-fall-a" "ok" "911-stub-fall-b" "BEFUND"
  run bash "$ISO/harness/tools/mutate.sh" --stamp-records "$ISO/ergebnis.txt" 45625795106 3
  [ "$status" -eq 0 ]

  a="$STAMP/910-stub-fall-a.txt"
  b="$STAMP/911-stub-fall-b.txt"
  [ -f "$a" ] && [ -f "$b" ]

  # Kopf je MR-051-Form: Run, Attempt, geprüfter Commit des Erstanhangs — EINMAL je File.
  [ "$(grep -c '^# Mutations-Fall-File' "$a")" -eq 1 ]
  grep -qF -- '# Run 45625795106, Attempt 3; geprüfter Commit des Erstanhangs: 625cdef0' "$a"
  grep -qF -- 'bash harness/tools/mutate.sh --stamp-records' "$a"

  # Je Fall genau eine Festlegung-1-Zeile: <datum> · commit <sha8> · form … · run <id> attempt <n>.
  [ "$(grep -c '· commit 625cdef0 · form ok · run 45625795106 attempt 3$' "$a")" -eq 1 ]
  grep -Eq '· form befund( · qualifikator [a-z]+)? · run 45625795106 attempt 3$' "$b"
  ! grep -q '· form BEFUND' "$b"   # das Result-File schreibt das Verdikt gross, die Zeile klein
}

@test "stamp: ein erneuter Konsum haengt am bestehenden Fall-File eine weitere Zeile an, der Kopf bleibt einmalig" {
  ergebnis "910-stub-fall-a" "ok" "" ""
  bash "$ISO/harness/tools/mutate.sh" --stamp-records "$ISO/ergebnis.txt" 111 1
  bash "$ISO/harness/tools/mutate.sh" --stamp-records "$ISO/ergebnis.txt" 222 7
  a="$STAMP/910-stub-fall-a.txt"
  [ "$(grep -c '^# Mutations-Fall-File' "$a")" -eq 1 ]
  [ "$(grep -cE '· run 111 attempt 1$' "$a")" -eq 1 ]
  [ "$(grep -cE '· run 222 attempt 7$' "$a")" -eq 1 ]
  grep -qF -- '# Run 111, Attempt 1' "$a"
  ! grep -q -- '# Run 222' "$a"
}

@test "stamp: FEHLT ist kein Urteil und wird nicht angehaengt" {
  ergebnis "910-stub-fall-a" "ok" "" ""
  printf 'FEHLT    %-56s\n' "911-stub-fall-b" >>"$ISO/ergebnis.txt"
  run bash "$ISO/harness/tools/mutate.sh" --stamp-records "$ISO/ergebnis.txt" 111 1
  [ "$status" -eq 0 ]
  [ -f "$STAMP/910-stub-fall-a.txt" ]
  [ ! -e "$STAMP/911-stub-fall-b.txt" ]
}

@test "stamp: der Qualifikator qualifiziert die befund-Zeile mit infra und last, nie die ok-Zeile" {
  ergebnis "910-stub-fall-a" "ok" "911-stub-fall-b" "BEFUND"
  i=0
  for q in infra last; do
    i=$((i + 1))
    MUTATE_STAMP_QUALIFIKATOR="$q" run bash "$ISO/harness/tools/mutate.sh" --stamp-records "$ISO/ergebnis.txt" 77 "$i"
    [ "$status" -eq 0 ]
    grep -qF -- "· form ok · run 77 attempt $i" "$STAMP/910-stub-fall-a.txt"
    grep -qF -- "· form befund · qualifikator $q · run 77 attempt $i" "$STAMP/911-stub-fall-b.txt"
  done
  vor="$(snap_bestand)"
  MUTATE_STAMP_QUALIFIKATOR=boing run bash "$ISO/harness/tools/mutate.sh" --stamp-records "$ISO/ergebnis.txt" 77 3
  [ "$status" -eq 1 ]
  grep -qF -- "mutate-stamp: ABBRUCH — MUTATE_STAMP_QUALIFIKATOR 'boing' ist weder leer noch infra oder last" <<<"$output"
  [ "$vor" = "$(snap_bestand)" ]
}

@test "stamp: fehlendes und leeres Result-File brechen fail-closed; eine Fassung ohne Kopf-Zeilen ist unlesbar" {
  vor="$(snap_bestand)"
  run bash "$ISO/harness/tools/mutate.sh" --stamp-records "$ISO/fehlt.txt" 5 2
  [ "$status" -eq 1 ]
  grep -qF -- "mutate-stamp: ABBRUCH — Result-File '$ISO/fehlt.txt' fehlt" <<<"$output"
  : >"$ISO/leer.txt"
  run bash "$ISO/harness/tools/mutate.sh" --stamp-records "$ISO/leer.txt" 5 2
  [ "$status" -eq 1 ]
  grep -qF -- "mutate-stamp: ABBRUCH — Result-File '$ISO/leer.txt' ist leer" <<<"$output"
  printf 'irgendein Text ohne Kopf-Zeilen\n' >"$ISO/kein-kopf.txt"
  run bash "$ISO/harness/tools/mutate.sh" --stamp-records "$ISO/kein-kopf.txt" 5 2
  [ "$status" -eq 1 ]
  grep -qF -- "trägt nicht genau eine 'mutate-ergebnis:'-Zeile und eine 'gepruefter Commit:'-Zeile — unlesbare Fassung" <<<"$output"
  [ "$vor" = "$(snap_bestand)" ]
}

@test "stamp: die doppelte (fall, run, attempt)-Bestimmung gegen den Bestand bricht fail-closed mit Meldung und der Bestand bleibt unveraendert" {
  ergebnis "910-stub-fall-a" "ok" "" ""
  bash "$ISO/harness/tools/mutate.sh" --stamp-records "$ISO/ergebnis.txt" 111 1
  vor="$(snap_bestand)"
  run bash "$ISO/harness/tools/mutate.sh" --stamp-records "$ISO/ergebnis.txt" 111 1
  [ "$status" -eq 1 ]
  grep -qF -- "mutate-stamp: ABBRUCH — doppelte Bestimmung: Paar (fall, run, attempt) steht bereits in" <<<"$output"
  [ "$vor" = "$(snap_bestand)" ]
}

@test "stamp: derselbe Fall zweimal im Result-File bricht fail-closed (doppelte Bestimmung)" {
  ergebnis "910-stub-fall-a" "ok" "" ""
  printf '%-8s %-56s Shard 1\n' "ok" "910-stub-fall-a" >>"$ISO/ergebnis.txt"
  vor="$(snap_bestand)"
  run bash "$ISO/harness/tools/mutate.sh" --stamp-records "$ISO/ergebnis.txt" 111 1
  [ "$status" -eq 1 ]
  grep -qF -- "mutate-stamp: ABBRUCH — doppelte Bestimmung: Fall '910-stub-fall-a' steht mehrfach im Result-File" <<<"$output"
  [ "$vor" = "$(snap_bestand)" ]
}

@test "stamp: eine unbekannte Fall-Kennung bricht mit Meldung, eine mehrdeutige nennt die Fundliste" {
  vor="$(snap_bestand)"
  ergebnis "920-fehlt-ganz" "ok" "" ""
  run bash "$ISO/harness/tools/mutate.sh" --stamp-records "$ISO/ergebnis.txt" 111 1
  [ "$status" -eq 1 ]
  grep -qF -- "mutate-stamp: ABBRUCH — unbekannte Fall-Kennung '920-fehlt-ganz'" <<<"$output"
  ergebnis "91" "ok" "" ""
  run bash "$ISO/harness/tools/mutate.sh" --stamp-records "$ISO/ergebnis.txt" 111 1
  [ "$status" -eq 1 ]
  grep -qF -- "mutate-stamp: ABBRUCH — mehrdeutige Fall-Kennung '91'" <<<"$output"
  grep -qF -- "911-stub-fall-b" <<<"$output"
  [ "$vor" = "$(snap_bestand)" ]
}

@test "stamp: ohne Run-Id oder Attempt bricht der Aufruf ab — eine Zeile traege nicht die Festlegung-1-Form" {
  ergebnis "910-stub-fall-a" "ok" "" ""
  vor="$(snap_bestand)"
  run bash "$ISO/harness/tools/mutate.sh" --stamp-records "$ISO/ergebnis.txt"
  [ "$status" -eq 1 ]
  grep -qF -- "mutate-stamp: ABBRUCH — Result-File, Run-Id und Attempt sind Pflicht" <<<"$output"
  run bash "$ISO/harness/tools/mutate.sh" --stamp-records "$ISO/ergebnis.txt" abc 2
  [ "$status" -eq 1 ]
  grep -qF -- "mutate-stamp: ABBRUCH — Run-Id 'abc' ist keine Zahl" <<<"$output"
  run bash "$ISO/harness/tools/mutate.sh" --stamp-records "$ISO/ergebnis.txt" 5 0
  [ "$status" -eq 1 ]
  grep -qF -- "mutate-stamp: ABBRUCH — Attempt '0' ist keine ganze Zahl >= 1" <<<"$output"
  [ "$vor" = "$(snap_bestand)" ]
}

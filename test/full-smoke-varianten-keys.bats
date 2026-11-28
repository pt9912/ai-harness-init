#!/usr/bin/env bats
# full-smoke-varianten-keys.bats — Waechter der je-Variante-E2E-Stempel-Klasse
# (ADR-0113, Festlegung 6; Form test/gates-fastpfad.bats und
# test/ci-stempel-committed.bats). Die Satzerzeuger-Rechnung laeuft hermetisch
# ueber --wurzel-Fixtures, der Konsum --entscheide ueber demselben Fixture samt
# sieben Stempel-Dateien, und die Schreiber-Form am Treiber wird am realen
# Skript gelesen.
#
# ROT FARBENDE MUTATIONEN (AGENTS.md §3.6, ADR-0113 Festlegung 6):
#   - der Konsum liest ein fremdes Feld oder einen falschen Varianten-Namen ->
#     der Stempel-Fall rot (a-1, Anlage je MR-071/MR-090);
#   - die gitignore-/Hash-Ausnahme der Stempel-Klasse faellt still weg ->
#     der check-ignore-Fall in test/ci-stempel-committed.bats rot (a-2);
#   - der Schreiber schreibt den Baum-Hash statt der Mengen-Rechnung ->
#     der Schreiber-Form-Fall rot (b-1).
#
# WAS HIER NICHT GEMESSEN WIRD: der reale Stempel-Lauf am Schreiber — er belegt
# die sieben Dateien, nicht dieser Wächter (die Grenze der hermetischen Form);
# die CI-Verdrahtung des push-main-Konsults haelt test/ci-stempel-committed.bats.

REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
SATZ="$REPO/harness/tools/full-smoke-varianten.sh"
SKIP="$REPO/harness/tools/full-smoke-skip.sh"
FIXTUR=""

B1="1111111111111111111111111111111111111111111111111111111111111111"

setup() {
  FIXTUR="$(mktemp -d)"
  mkdir -p "$FIXTUR/cmd" "$FIXTUR/internal/gen" "$FIXTUR/internal/emit/testdata" \
    "$FIXTUR/.harness/baseline/v7" "$FIXTUR/harness/tools" "$FIXTUR/.harness/state"
  printf 'package main\n' >"$FIXTUR/cmd/main.go"
  local f
  for f in golang cpp kotlin jvm java java_hexslice python python_hexslice csharp csharp_hexslice gen arch; do
    printf 'package gen\n' >"$FIXTUR/internal/gen/$f.go"
  done
  printf 'package emit\n' >"$FIXTUR/internal/emit/common.go"
  printf 'x\n' >"$FIXTUR/internal/emit/testdata/t.txt"
  printf 'package gen\n' >"$FIXTUR/internal/gen/cpp_test.go"
  printf 'x\n' >"$FIXTUR/.harness/baseline/v7/x.md"
  printf 'driver\n' >"$FIXTUR/harness/tools/full-smoke.sh"
  printf 'skip\n' >"$FIXTUR/harness/tools/full-smoke-skip.sh"
  printf 'hb\n' >"$FIXTUR/harness/tools/handbuch-baum.sh"
}

teardown() {
  [ -n "${FIXTUR:-}" ] && rm -rf "$FIXTUR"
  return 0
}

# stuempeln schreibt die sieben Stempel-Dateien ins Fixture — die Form, die der
# Schreiber am Treiber schreibt (ADR-0113 Festlegung 4).
stuempeln() {
  local v h
  while read -r v h; do
    printf 'variante %s\nmengen-hash %s\n' "$v" "$h" >"$FIXTUR/.harness/state/full-smoke-passed-$v.key"
  done < <(bash "$SATZ" --wurzel "$FIXTUR" alle)
}

@test "satzerzeuger: hash liefert 64 hex und ist deterministisch ueber zwei Laeufe (ADR-0113 Festlegung 1)" {
  local a b
  a="$(bash "$SATZ" --wurzel "$FIXTUR" hash kotlin)"
  [[ "$a" =~ ^[0-9a-f]{64}$ ]]
  b="$(bash "$SATZ" --wurzel "$FIXTUR" hash kotlin)"
  [ "$a" = "$b" ]
}

@test "satzerzeuger: ein Inhalt-Edit innerhalb der Menge dreht den Key, der je-Teil-Drift dreht nur die getragenen Varianten (ADR-0113 Festlegung 2)" {
  local v h
  declare -A alt=()
  while read -r v h; do alt["$v"]="$h"; done < <(bash "$SATZ" --wurzel "$FIXTUR" alle)
  # je-Teil-Drift: jvm.go traegt kotlin und java (der Gemeinsam-Knoten der zwei
  # JVM-Sprachen), cpp.go nur cpp
  printf 'package gen // drift\n' >>"$FIXTUR/internal/gen/jvm.go"
  declare -A neu=()
  while read -r v h; do neu["$v"]="$h"; done < <(bash "$SATZ" --wurzel "$FIXTUR" alle)
  [ "${alt[kotlin]}" != "${neu[kotlin]}" ]
  [ "${alt[java]}" != "${neu[java]}" ]
  [ "${alt[cpp]}" = "${neu[cpp]}" ]
  [ "${alt[sprachlos]}" = "${neu[sprachlos]}" ]
  [ "${alt[python]}" = "${neu[python]}" ]
  [ "${alt[csharp]}" = "${neu[csharp]}" ]
  # der Gemeinsam-Drift dreht alle sieben — das Binary ist eines (Festlegung 2)
  printf 'package main // drift\n' >>"$FIXTUR/cmd/main.go"
  declare -A gemeinsam=()
  while read -r v h; do gemeinsam["$v"]="$h"; done < <(bash "$SATZ" --wurzel "$FIXTUR" alle)
  [ "${neu[kotlin]}" != "${gemeinsam[kotlin]}" ]
  [ "${neu[sprachlos]}" != "${gemeinsam[sprachlos]}" ]
  [ "${neu[csharp]}" != "${gemeinsam[csharp]}" ]
}

@test "satzerzeuger: ein Inhalt-Edit ausserhalb der Menge dreht keinen Key (ADR-0113 Festlegung 2, nicht groesser)" {
  local v h alt neu
  declare -A alt=()
  while read -r v h; do alt["$v"]="$h"; done < <(bash "$SATZ" --wurzel "$FIXTUR" alle)
  printf 'x\n' >>"$FIXTUR/internal/gen/cpp_test.go"
  printf 'x\n' >>"$FIXTUR/internal/emit/testdata/t.txt"
  printf 'x\n' >"$FIXTUR/docs-drift.md"
  while read -r v h; do
    [ "${alt[$v]}" = "$h" ] || { echo "der Key $v drehte ausserhalb der Menge" >&2; return 1; }
  done < <(bash "$SATZ" --wurzel "$FIXTUR" alle)
}

@test "satzerzeuger: die Menge je Variante enthaelt die Profil-Datei der Tafel und nicht der uebrigen Sprachen (ADR-0113 Festlegung 2)" {
  local m
  m="$(bash "$SATZ" --wurzel "$FIXTUR" menge java)"
  grep -qF 'internal/gen/java.go' <<<"$m"
  grep -qF 'internal/gen/jvm.go' <<<"$m"
  grep -qF 'internal/gen/gen.go' <<<"$m"
  ! grep -qF 'internal/gen/kotlin.go' <<<"$m"
  ! grep -qF 'internal/gen/golang.go' <<<"$m"
  m="$(bash "$SATZ" --wurzel "$FIXTUR" menge sprachlos)"
  grep -qF 'internal/gen/golang.go' <<<"$m"
  ! grep -qF 'internal/gen/java.go' <<<"$m"
  m="$(bash "$SATZ" --wurzel "$FIXTUR" menge go)"
  [ "$m" = "$(bash "$SATZ" --wurzel "$FIXTUR" menge sprachlos)" ]
}

@test "satzerzeuger: unbekannte Variante faellt mit Meldung auf stderr (fail-closed, MR-017)" {
  run bash "$SATZ" --wurzel "$FIXTUR" hash fremd
  [ "$status" -eq 1 ]
  [[ "$output" == *"unbekannte Variante"* ]]
}

@test "mengen-waechter: eine nicht zugeordnete nicht-Test-Quelle unter internal/gen faellt rot (ADR-0113 Festlegung 2, fail-closed)" {
  printf 'package gen\n' >"$FIXTUR/internal/gen/ungefahren.go"
  run bash "$SATZ" --wurzel "$FIXTUR" pruefe
  [ "$status" -eq 1 ]
  [[ "$output" == *"internal/gen/ungefahren.go"* ]]
  rm "$FIXTUR/internal/gen/ungefahren.go"
  run bash "$SATZ" --wurzel "$FIXTUR" pruefe
  [ "$status" -eq 0 ]
}

@test "e2e-skip: alle sieben decken -> SKIP, Meldung nennt Varianten-Menge und Rest (ADR-0113 Festlegung 3)" {
  stuempeln
  run bash "$SKIP" --entscheide "$FIXTUR"
  [ "$status" -eq 0 ]
  [[ "$output" == *"SKIP"* ]]
  [[ "$output" == *"sprachlos go cpp kotlin java python csharp"* ]]
  [[ "$output" == *"Traeger-Releases"* ]]
  [[ "$output" == *"Runner-Fassung"* ]]
  [[ "$output" == *"Runner-Verdikt"* ]]
}

@test "e2e-skip: ein Stempel fehlt -> voller Lauf (fail-closed)" {
  stuempeln
  rm "$FIXTUR/.harness/state/full-smoke-passed-python.key"
  run bash "$SKIP" --entscheide "$FIXTUR"
  [ "$status" -eq 1 ]
}

@test "e2e-skip: fremder mengen-hash -> voller Lauf (fail-closed)" {
  stuempeln
  local frisch
  frisch="$(bash "$SATZ" --wurzel "$FIXTUR" hash kotlin)"
  printf 'variante kotlin\nmengen-hash %s\n' "$B1" >"$FIXTUR/.harness/state/full-smoke-passed-kotlin.key"
  run bash "$SKIP" --entscheide "$FIXTUR"
  [ "$status" -eq 1 ]
}

@test "e2e-skip: die variante-Zeile passt nicht zum Datei-Namen -> voller Lauf (ADR-0113 Festlegung 1, Selbst-Bindung)" {
  stuempeln
  local frisch
  frisch="$(bash "$SATZ" --wurzel "$FIXTUR" hash go)"
  printf 'variante cpp\nmengen-hash %s\n' "$frisch" >"$FIXTUR/.harness/state/full-smoke-passed-go.key"
  run bash "$SKIP" --entscheide "$FIXTUR"
  [ "$status" -eq 1 ]
}

@test "e2e-skip: ein fremdes Feld (baum-hash) statt mengen-hash -> voller Lauf (ADR-0113 Festlegung 1, a-1)" {
  stuempeln
  local frisch
  frisch="$(bash "$SATZ" --wurzel "$FIXTUR" hash go)"
  printf 'baum-hash %s\n' "$frisch" >"$FIXTUR/.harness/state/full-smoke-passed-go.key"
  run bash "$SKIP" --entscheide "$FIXTUR"
  [ "$status" -eq 1 ]
}

@test "e2e-skip: unformaler mengen-hash und eine dritte Zeile -> voller Lauf (fail-closed, MR-017)" {
  stuempeln
  local frisch
  frisch="$(bash "$SATZ" --wurzel "$FIXTUR" hash go)"
  printf 'variante go\nmengen-hash %s\nvarianten 24\n' "${frisch:0:40}" >"$FIXTUR/.harness/state/full-smoke-passed-go.key"
  run bash "$SKIP" --entscheide "$FIXTUR"
  [ "$status" -eq 1 ]
  printf 'variante go\nmengen-hash %s\n' "$frisch" >"$FIXTUR/.harness/state/full-smoke-passed-go.key"
  run bash "$SKIP" --entscheide "$FIXTUR"
  [ "$status" -eq 0 ]
}

@test "e2e-skip: die Satzerzeuger-Rechnung zweifelt und eine fremde Aufruf-Form sind Exit 1 bzw. 2" {
  run bash "$SKIP" --entscheide "$FIXTUR/noch-nicht"
  [ "$status" -eq 1 ]
  run bash "$SKIP"
  [ "$status" -eq 2 ]
  run bash "$SKIP" --entscheide "$FIXTUR" zuviel
  [ "$status" -eq 2 ]
}

@test "e2e-skip: die no-Root-Form liest die Wurzel aus dem Arbeitsverzeichnis — die Konsult-Form der ci (full-smoke.sh, ohne Wurzel-Argument)" {
  stuempeln
  run bash -c "cd '$FIXTUR' && bash '$SKIP' --entscheide"
  [ "$status" -eq 0 ]
  [[ "$output" == *"SKIP"* ]]
}

# --- die Schreiber-Form am Treiber (b-1, ADR-0113 Festlegung 4) --------------

@test "schreiber-form: der Treiber liest den Satzerzeuger-Modus alle und schreibt je Variante die Zwei-Zeilen-Form, ohne Baum-Hash (ADR-0113 Festlegung 4)" {
  local skript="$REPO/harness/tools/full-smoke.sh"
  # der Schreiber stempelt aus der Satzerzeuger-Ernte, nicht aus einer
  # Baum-Hash-Rechnung — der Wert ist die Vorlagen-Menge, nicht der Baum
  grep -qF 'stempel_ernte="$(bash "$HIER/full-smoke-varianten.sh" alle)"' "$skript"
  ! grep -qF 'E2E_BAUM_HASH_START' "$skript"
  grep -qF "full-smoke-passed-\${stempelzeile%% *}.key" "$skript"
  # die Klassen-Groesse ist fail-closed gehalten
  grep -qF -- '-ne 7' "$skript"
}

@test "konsum-verdrahtung: der Treiber faehrt den Griff unforced nur bei gesetzter Konsult-Umgebung (ADR-0111 Festlegung 2, ADR-0113 Festlegung 3)" {
  local skript="$REPO/harness/tools/full-smoke.sh"
  [ "$(grep -vE '^[[:space:]]*#' "$skript" | grep -cF 'FULL_SMOKE_SKIP_KONSULT')" -eq 1 ]
  grep -qF '[ "${FULL_SMOKE_SKIP_KONSULT:-}" = "1" ]' "$skript"
  grep -qF 'if bash "$HIER/full-smoke-skip.sh" --entscheide; then' "$skript"
}

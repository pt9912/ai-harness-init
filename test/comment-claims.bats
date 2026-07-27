#!/usr/bin/env bats
# comment-claims.bats — Zaehne fuer harness/tools/comment-claims.sh (slice-055).
#
# Der Gate prueft eine FORM: eine Abdeckungs-Behauptung im Kommentar muss ihren Sensor
# nennen, und ein genannter Testname muss existieren. Beide Eigenschaften brauchen ein
# rot faerbendes Gegenbeispiel (AGENTS.md 3.6), und die Roh-String-Ausnahme braucht
# eines in BEIDE Richtungen: sie ist die Stelle, an der ein zu eifriger Gate den
# emittierten Inhalt anfassen wuerde.

setup() {
  SCANNER="$BATS_TEST_DIRNAME/../harness/tools/comment-claims.sh"
  TMP="$(mktemp -d)"
}

teardown() {
  rm -rf "$TMP"
}

@test "Behauptung MIT Sensor-Nennung: gruen" {
  cat > "$TMP/ok.go" <<'EOF'
package x

// Foo tut etwas; TestGenerate_Deterministic bewacht die Eigenschaft.
func Foo() {}
EOF
  run bash "$SCANNER" "$TMP/ok.go"
  [ "$status" -eq 0 ]
}

@test "Behauptung OHNE Sensor-Nennung: rot" {
  cat > "$TMP/bad.go" <<'EOF'
package x

// Foo ist gegen doppelte Eintraege bewacht.
func Foo() {}
EOF
  run bash "$SCANNER" "$TMP/bad.go"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Behauptung ohne Sensor-Nennung"* ]]
}

@test "erfundener Testname: rot (der Fall, der den Autor selbst erwischt hat)" {
  cat > "$TMP/fake.go" <<'EOF'
package x

// Foo ist bewacht; TestDiesenTestGibtEsNicht faehrt genau das.
func Foo() {}
EOF
  run bash "$SCANNER" "$TMP/fake.go"
  [ "$status" -eq 1 ]
  [[ "$output" == *"erfundener Sensor"* ]]
}

@test "Roh-String-Literal ist ausgenommen: emittierter Inhalt roetet nicht" {
  # Die Behauptung steht INNERHALB eines Go-Roh-Strings — das ist emittierter
  # Adopter-Inhalt, keine Zusage dieses Repos.
  # Die Behauptung MUSS auf einer eigenen Zeile INNERHALB des Literals stehen: steht sie
  # auf der const-Zeile, sieht der Scanner dort nie einen Kommentar und die Ausnahme wird
  # gar nicht ausgeuebt — der Fall waere zahnlos (von make mutate als BEFUND gemeldet).
  printf 'package x\n\nconst tmpl = `\n# Dieser Test belegt den Build.\nkram\n`\n' > "$TMP/emit.go"
  run bash "$SCANNER" "$TMP/emit.go"
  [ "$status" -eq 0 ]
}

@test "Roh-String-Ausnahme ist eng: NACH dem Literal wird wieder geprueft" {
  # Gegenprobe zur Ausnahme: kippte der Zustand nicht zurueck, waere alles hinter dem
  # ersten Roh-String blind — der Gate waere still gruen.
  printf 'package x\n\nconst tmpl = `emittiert`\n\n// Foo ist bewacht.\nfunc Foo() {}\n' > "$TMP/after.go"
  run bash "$SCANNER" "$TMP/after.go"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Behauptung ohne Sensor-Nennung"* ]]
}

@test "Verneinung ist keine Behauptung" {
  cat > "$TMP/neg.go" <<'EOF'
package x

// Ein gruener Lauf belegt nicht, dass der Gate greift.
func Foo() {}
EOF
  run bash "$SCANNER" "$TMP/neg.go"
  [ "$status" -eq 0 ]
}

@test "Testname in einem Bezeichner ist kein Sensor-Name" {
  # cppTestCMakeLists darf nicht als Testname "TestCMakeLists" gelesen werden.
  cat > "$TMP/ident.go" <<'EOF'
package x

// cppTestCMakeLists rendert die Test-Verdrahtung; make comment-claims deckt die Form.
var cppTestCMakeLists = ""
EOF
  run bash "$SCANNER" "$TMP/ident.go"
  [ "$status" -eq 0 ]
}

#!/usr/bin/env bats
# baum-inventur.bats — haelt die Traeger-Inventur (internal/emit/baumaussage.go) gegen
# den NENNER: die `*.md` des `regelwerk/`-Verzeichnisses des gepinnten Baseline-Baums.
#
# Warum bats und nicht go-test: `.harness/` liegt nicht im Docker-Build-Kontext
# (.dockerignore), die go-test-Stage sieht den vendored Baum also gar nicht. Dieselbe
# Lage — und derselbe Ausweg — wie bei courseset-fixture.bats. Die hermetische Haelfte
# (Form der Eintraege, Abwesenheits-Adressen, Verdrahtung in den Emit) liegt in
# internal/emit/baumaussage_test.go; hier liegt die Haelfte, die den realen Baum braucht.
#
# Zwei Richtungen, beide noetig: ein Regelblock ohne Eintrag ist eine leere Zelle, ein
# Eintrag ohne Regelblock zeigt auf etwas, das der Baum nicht fuehrt. Der Nenner wird
# GELESEN, nicht notiert — eine notierte Zahl braeche beim naechsten Baseline-Sprung,
# ohne dass am Gegenstand etwas bricht.
#
# Dritte Achse: der Anker, vor den der Emit den Block setzt, steht im realen
# Vorlagen-Satz. Ohne ihn braeche jeder Bootstrap laut; die Fixture in
# internal/emit/templates_test.go fuehrt ihn, und dieser Test haelt sie daran fest.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  QUELLE="$REPO/internal/emit/baumaussage.go"
  REGELWERK="$(ls -d "$REPO"/.harness/baseline/*/regelwerk 2>/dev/null | head -1)"
}

# Die Modul-Namen der Inventur: jede Zeile `{Modul: "<name>", …}` in der Quelle.
inventur_module() {
  grep -oE '\{Modul: "[^"]+"' "$QUELLE" | sed 's/.*"\(.*\)"/\1/' | sort -u
}

@test "der gepinnte Baum fuehrt ein regelwerk/-Verzeichnis" {
  [ -n "$REGELWERK" ]
  [ -d "$REGELWERK" ]
  run bash -c "ls '$REGELWERK'/*.md | wc -l"
  [ "$status" -eq 0 ]
  [ "$output" -gt 0 ]
}

@test "jeder Regelblock des gepinnten Baums traegt einen Inventur-Eintrag" {
  fehlend=""
  while read -r datei; do
    name="$(basename "$datei")"
    if ! inventur_module | grep -qxF "$name"; then
      fehlend="$fehlend [$name]"
    fi
  done < <(ls "$REGELWERK"/*.md)
  [ -z "$fehlend" ] || {
    echo "Regelbloecke ohne Inventur-Eintrag:$fehlend" >&2
    false
  }
}

@test "jeder Inventur-Eintrag nennt einen Regelblock, den der gepinnte Baum fuehrt" {
  fremd=""
  while read -r name; do
    [ -n "$name" ] || continue
    if [ ! -f "$REGELWERK/$name" ]; then
      fremd="$fremd [$name]"
    fi
  done < <(inventur_module)
  [ -z "$fremd" ] || {
    echo "Inventur-Eintraege ohne Regelblock im gepinnten Baum:$fremd" >&2
    false
  }
}

@test "der Anker des Blocks steht im realen Vorlagen-Satz" {
  vorlage="$(ls -d "$REPO"/.harness/baseline/*/templates/harness/conventions.template.md | head -1)"
  [ -f "$vorlage" ]
  run grep -qxF '## Adaptions-Block' "$vorlage"
  [ "$status" -eq 0 ]
}

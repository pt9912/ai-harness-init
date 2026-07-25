#!/usr/bin/env bats
# mutate-driver.bats — Waechter fuer den Mutations-Treiber selbst.
#
# Warum: `make mutate` bewacht jeden gelisteten Waechter, aber bis slice-026
# NICHT sich selbst — harness/tools/mutate.sh stand in keinem `# files:`-Kopf
# (Review-Befund N-2). Ein Treiber ohne Waechter kann still seine Zaehne
# verlieren, und dann meldet der zweite Quadrant zu AGENTS 3.6 nur noch gruen.
#
# Selbst-Mutation waere der falsche Weg (das Skript liefe waehrend seiner eigenen
# Aenderung). Stattdessen: seine Einheiten hermetisch pruefen — und diese Datei
# ist dann per test/mutations/09 mutierbar wie jeder andere Waechter.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  DRIVER="$REPO/harness/tools/mutate.sh"
}

# failure_form ist die EINZIGE Quelle der erlaubten `# verify:`-Modi. Ein leeres
# Muster waere fatal: `grep -E ''` matcht jede Zeile, Bedingung 4 faellt damit in
# den F-1-Zustand zurueck (rot aus falschem Grund wird als Beleg akzeptiert).
@test "driver: failure_form liefert fuer jeden erlaubten Modus ein NICHT-leeres Muster" {
  local m
  for m in test smoke; do
    run bash -c "source '$DRIVER' 2>/dev/null || true; failure_form $m"
    [ -n "$output" ]
  done
}

@test "driver: failure_form lehnt einen unbekannten Modus AB (statt leer zu liefern)" {
  run bash -c "source '$DRIVER' 2>/dev/null || true; failure_form voellig-unbekannt"
  [ "$status" -ne 0 ]
  [ -z "$output" ]
}

# Die Muster duerfen ausschliesslich bei FEHLSCHLAG greifen — sonst ist
# Bedingung 4 wirkungslos. Genau das war F-1: bats druckt Testnamen auch beim
# Bestehen, und das damalige Muster war der blosse Name.
@test "driver: das test-Muster trifft Fehlschlag-Zeilen, NICHT Erfolgs-Zeilen" {
  local form
  form="$(bash -c "source '$DRIVER' 2>/dev/null || true; failure_form test")"
  printf 'ok 21 emittiert: eingelegter SYMLINK\n'      | grep -Eq -- "$form" && return 1
  printf 'not ok 21 emittiert: eingelegter SYMLINK\n'  | grep -Eq -- "$form"
  printf -- '--- FAIL: TestIrgendwas (0.00s)\n'        | grep -Eq -- "$form"
}

# --- Isolation (slice-047) ----------------------------------------------------
# Die Kern-Zusage des Treibers ist seit slice-047: "ein Lauf veraendert den
# Host-Baum nicht". Sie haengt an zwei Eigenschaften, die hier hermetisch (ohne
# Docker, ohne echten Mutations-Lauf) geprueft werden.

# Die Isolation MUSS ausserhalb des Repos liegen. Ein Verzeichnis UNTER dem Repo
# laege ungetrackt im Working Tree und verschoebe den MR-003-Stop-Hook-Hash — der
# Hook feuerte dann bei jedem Lauf (die slice-044-Worktree-Falle, real erlebt).
@test "driver: die isolierte Kopie liegt AUSSERHALB des Repos" {
  # Gegen die REINE Pfad-Funktion: sie traegt die Ortsregel, und der Test kostet so
  # kein 8-MB-Kopieren (Review F-7 — die Tests laufen in JEDEM make test, also ~70x
  # je mutate-Lauf).
  local root dest
  root="$(mktemp -d)"
  dest="$(bash -c "source '$DRIVER' 2>/dev/null || true; isolation_path '$root'")"
  rm -rf "$root"
  [ -n "$dest" ]
  case "$dest" in
    "$REPO" | "$REPO"/*) return 1 ;;   # unter dem Repo -> Befund
  esac
}

# Die Verweigerung selbst: ein Ziel UNTER dem Repo muss fallen, nicht nur „nicht
# gewaehlt werden". Das ist der Zweig, den Mutation 72 rot faerbt (Review F-5: vorher
# traf sie nur die Nicht-Leer-Assertion, nicht die Ortsregel).
@test "driver: isolation_path VERWEIGERT ein Ziel unter dem Repo" {
  run bash -c "source '$DRIVER' 2>/dev/null || true; isolation_path '$REPO/.mutate-iso'"
  [ "$status" -ne 0 ]
}

# require_isolated ist die Schranke vor jedem $WORK-Zugriff. `cd ""` ist in bash Exit 0
# OHNE Wirkung — ein leeres WORK liesse die Seds im cwd des Treibers laufen, und das ist
# unter `make mutate` das Repo (Review F-1).
@test "driver: require_isolated FAELLT bei leerem oder repo-internem WORK" {
  run bash -c "source '$DRIVER' 2>/dev/null || true; WORK=''; require_isolated"
  [ "$status" -ne 0 ]
  run bash -c "source '$DRIVER' 2>/dev/null || true; WORK='$REPO'; require_isolated"
  [ "$status" -ne 0 ]
  run bash -c "source '$DRIVER' 2>/dev/null || true; WORK='$REPO/test'; require_isolated"
  [ "$status" -ne 0 ]
}

# Die Kopie muss tragen, was ein Sensor-Lauf braucht — einschliesslich `.git`: der
# `# verify: ci-lint`-Modus faehrt actionlint, und das verlangt eine git-Projektwurzel
# („no project was found in any parent directories"). Ein zu sparsamer Ausschnitt
# laesst den Gruen-Vorlauf scheitern, und zwar aus einem Grund, der nichts mit einer
# Mutation zu tun hat. Nur der Laufzustand (.harness/state, gitignored) bleibt drausen.
@test "driver: die Kopie traegt den Sensor-Bedarf inklusive .git" {
  # Der EINZIGE Test, der wirklich kopiert (Review F-7).
  local root dest
  root="$(mktemp -d)"
  dest="$(bash -c "source '$DRIVER' 2>/dev/null || true; prepare_isolation '$root'")"
  [ -f "$dest/Makefile" ]
  [ -f "$dest/Dockerfile" ]
  [ -d "$dest/test" ]
  [ -d "$dest/harness/tools" ]
  [ -d "$dest/.harness/baseline" ]
  [ -e "$dest/.git" ]
  [ ! -e "$dest/.harness/state" ]
  rm -rf "$root"
}

# Der Fingerabdruck ist der Messwert, mit dem der Treiber seine Host-Unversehrtheit
# BELEGT statt sie zuzusagen. Taugt er nichts (z. B. konstant), waere die fuenfte
# Bedingung ein stilles Gruen — also: gleiche Inhalte gleicher Wert, geaenderter
# Inhalt anderer Wert. Geprueft wird die RECHNUNG (fingerprint_of_list), weil die
# Listen-Beschaffung git braucht und der bats-Container keines traegt.
@test "driver: der Fingerabdruck ist stabil und reagiert auf eine Aenderung" {
  local dir a b c
  dir="$(mktemp -d)"
  printf 'eins\n' >"$dir/datei.txt"
  a="$(printf 'datei.txt\0' | bash -c "source '$DRIVER' 2>/dev/null || true; fingerprint_of_list '$dir'")"
  b="$(printf 'datei.txt\0' | bash -c "source '$DRIVER' 2>/dev/null || true; fingerprint_of_list '$dir'")"
  [ -n "$a" ]
  [ "$a" = "$b" ]
  printf 'zwei\n' >"$dir/datei.txt"
  c="$(printf 'datei.txt\0' | bash -c "source '$DRIVER' 2>/dev/null || true; fingerprint_of_list '$dir'")"
  [ "$a" != "$c" ]
  rm -rf "$dir"
}

# FAIL-CLOSED: ohne Mutations-Ziele darf target_fingerprint NICHT einen Hash ueber die
# leere Menge liefern — zwei leere Hashes waeren gleich, und die fuenfte Bedingung
# meldete „Host unveraendert", ohne je gemessen zu haben. Genau dieser stille Weg war
# beim Bau des Waechters offen; der Test haelt ihn zu.
@test "driver: target_fingerprint FAELLT bei leerer Ziel-Liste (kein leeres Gruen)" {
  local leer
  leer="$(mktemp -d)"
  # Ein Fall-Verzeichnis mit einer Datei OHNE `# files:`-Kopf: mutation_targets
  # LAEUFT erfolgreich durch und liefert eine LEERE Liste — nur so wird die Schranke
  # `[ -n "$targets" ]` ueberhaupt erreicht. Ein leeres Verzeichnis taugt nicht: dort
  # scheitert schon das Glob, die Funktion faellt aus einem anderen Grund, und die
  # Zusage im Testnamen waere ungeprueft (von make mutate zweimal so gemeldet).
  printf '#!/usr/bin/env bash\n# expect: irgendwas\n' >"$leer/00-ohne-files-kopf.sh"
  run bash -c "source '$DRIVER' 2>/dev/null || true; target_fingerprint '$REPO' '$leer'"
  rm -rf "$leer"
  [ "$status" -ne 0 ]
}

# Der Fingerabdruck deckt GENAU die `# files:`-Ziele ab — nicht mehr (sonst roetet
# parallele Arbeit am Repo den Lauf) und nicht weniger (sonst bliebe ein
# Isolations-Bruch an einer Zieldatei unsichtbar).
@test "driver: der Fingerabdruck deckt die Mutations-Ziele, nicht den ganzen Baum" {
  local ziele
  ziele="$(bash -c "source '$DRIVER' 2>/dev/null || true; mutation_targets '$REPO/test/mutations'")"
  [ -n "$ziele" ]
  grep -q '^harness/tools/mutate.sh$' <<<"$ziele"
  # NICHT `grep -qv` fuer die ABWESENHEIT: `-q` und `-v` kombinieren sich je nach
  # grep-Implementierung verschieden (auf dem Entwickler-Host liefert ugrep 7.5.0
  # Status 1, wo dieselbe Zeile ohne `-q` Status 0 gibt; der bats-Container bringt
  # wieder ein anderes grep mit). Negiertes `grep -q` ist in beiden eindeutig.
  ! grep -q '^AGENTS.md$' <<<"$ziele"
}

# Die Mitten-im-Lauf-Pruefung ist der Sensor der Kern-Zusage dieses Slice — und war
# als einziger unbewacht (Review-Runde 2 F-1, Verifier R2-1). Die Begruendung „als
# Mutations-Fall nicht darstellbar" trug nicht: beide Zweige kehren VOR jedem
# make-Aufruf zurueck, also ist derselbe hermetische Weg moeglich wie fuer die uebrigen
# Funktionen. Fixture: ein Mini-Baum mit einer Zieldatei und einem Fall darauf; der
# Referenzwert wird absichtlich verfaelscht, indem die Zieldatei nach der Aufnahme
# veraendert wird — run_case muss das melden, bevor er einen Sensor faehrt.
@test "driver: run_case meldet einen HOST-Treffer, bevor er den Sensor faehrt" {
  local iso cases
  iso="$(mktemp -d)"; cases="$iso/cases"
  mkdir -p "$iso/repo" "$cases"
  printf 'alt\n' >"$iso/repo/ziel.txt"
  # Der Fall mutiert die Kopie UND (das ist der simulierte Bruch) den Host-Baum:
  # hier sind beide dasselbe Verzeichnis, also faellt der Referenzwert auseinander.
  printf '#!/usr/bin/env bash\n# files: ziel.txt\n# expect: egal\nsed -i s/alt/neu/ ziel.txt\n' >"$cases/01-fall.sh"
  run bash -c "source '$DRIVER' 2>/dev/null || true
    WORK='$iso/repo'; REPO='$iso/repo'; CASES_DIR='$cases'
    run_case '$cases/01-fall.sh'"
  rm -rf "$iso"
  [[ "$output" == *"Isolation gebrochen"* ]]
}

@test "driver: das smoke-Muster trifft Fehlschlag-Zeilen, NICHT Fortschritts-Zeilen" {
  local form
  form="$(bash -c "source '$DRIVER' 2>/dev/null || true; failure_form smoke")"
  printf 'smoke: 3/4 Skelett gestaged? ...\n'          | grep -Eq -- "$form" && return 1
  printf 'smoke: OK — Bootstrap laeuft\n'              | grep -Eq -- "$form" && return 1
  printf 'smoke: FEHLER — out-of-scope-Artefakt\n'     | grep -Eq -- "$form"
}

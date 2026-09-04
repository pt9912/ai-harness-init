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

# Die Mitten-im-Lauf-Pruefung ist der Sensor der Kern-Zusage dieses Slice, und der
# ABBRUCH ist ihre Wirkung. Beides braucht Deckung (Runde 2 F-1, Runde 3 F-1).
#
# Die Fixture trennt Kopie ($WORK) und Baum ($REPO) und laesst den Fall den BAUM per
# absolutem Pfad treffen — die Kopie bleibt unveraendert. Das ist der reale Bruch, und
# es deckt zugleich die REIHENFOLGE: waere die Pruefung hinter Bedingung 2, meldete der
# Treiber „Mutation hat nicht gegriffen" statt des Isolations-Bruchs (Runde 3 F-2, die
# vorherige Fixture liess beide zusammenfallen und konnte das nicht unterscheiden).
#
# Geprueft wird BEIDES: die Meldung UND der Exit-Status. Ohne die Status-Assertion
# bliebe ein `exit 1` -> `return` unsichtbar, und die Schleife liefe nach erkanntem
# Bruch weiter gegen den Host — der Zustand, den der Abbruch gerade beseitigt hat.
@test "driver: run_case meldet einen HOST-Treffer und BRICHT AB" {
  local iso cases
  iso="$(mktemp -d)"; cases="$iso/cases"
  mkdir -p "$iso/kopie" "$iso/baum" "$cases"
  printf 'alt\n' >"$iso/kopie/ziel.txt"
  printf 'alt\n' >"$iso/baum/ziel.txt"
  # Der Fall trifft den BAUM (absoluter Pfad), nicht die Kopie: genau der Bruch.
  printf '#!/usr/bin/env bash\n# files: ziel.txt\n# expect: egal\nsed -i s/alt/neu/ %s/ziel.txt\n' \
    "$iso/baum" >"$cases/01-fall.sh"
  run bash -c "source '$DRIVER' 2>/dev/null || true
    WORK='$iso/kopie'; REPO='$iso/baum'; CASES_DIR='$cases'
    run_case '$cases/01-fall.sh'"
  rm -rf "$iso"
  [[ "$output" == *"Isolation gebrochen"* ]]
  [ "$status" -ne 0 ]
}

# --- Gruen-Vorlauf (slice-100) ------------------------------------------------
# Bricht der Vorlauf ab, ist seine Meldung die vollstaendige Evidenz des Laufs: das Log
# des Sensors ist danach weg, und ein zweiter Lauf stellt den Zustand nicht her, der ihn
# rot gemacht hat. Sie traegt darum die letzten Zeilen des roten Modus.
#
# Geprueft werden BEIDE Stroeme, weil `>/dev/null 2>&1` zwei Umleitungen sind: ein
# Gegenbeispiel fuer eine von beiden liesse offen, ob der andere Strom weiter
# verschwindet. Bei `make full-smoke` steht die tragende Zeile auf stderr, der Kontext
# davor auf stdout — wer nur einen faengt, faengt die halbe Diagnose.
@test "driver: der abgebrochene Gruen-Vorlauf zeigt stdout UND stderr des roten Modus" {
  local iso stub
  iso="$(mktemp -d)"; stub="$iso/bin"
  mkdir -p "$iso/kopie" "$stub"
  # Ein make-Stub statt eines echten Sensor-Laufs: er druckt je eine unterscheidbare
  # Marke in jeden Strom und faellt. So kostet der Fall keinen Docker-Lauf und trennt
  # die zwei Stroeme sauber.
  cat >"$stub/make" <<'STUB'
#!/usr/bin/env bash
printf '%s\n' 'VORLAUF-MARKE-STDOUT'
printf '%s\n' 'VORLAUF-MARKE-STDERR' >&2
exit 1
STUB
  chmod +x "$stub/make"
  run env "PATH=$stub:$PATH" bash -c "source '$DRIVER' 2>/dev/null || true
    WORK='$iso/kopie'
    green_prerun test"
  rm -rf "$iso"
  [ "$status" -ne 0 ]
  grep -qF 'VORLAUF-MARKE-STDOUT' <<<"$output"
  grep -qF 'VORLAUF-MARKE-STDERR' <<<"$output"
}

# Das Protokoll des Vorlaufs liegt AUSSERHALB des Repos — dieselbe Ortsregel wie fuer
# die isolierte Kopie und aus demselben Grund: harness/tools/working-tree-hash.sh rechnet
# den MR-003-Stempel ueber getrackte UND untrackte Dateien, und der Vorlauf schreibt sein
# Log mitten im Lauf. Der Fingerabdruck aus Bedingung 5 faengt das nicht — er deckt die
# Mutations-Zieldateien, nicht neue Dateien im Arbeitsbaum.
@test "driver: das Protokoll des Gruen-Vorlaufs liegt AUSSERHALB des Repos" {
  local log dir
  log="$(bash -c "source '$DRIVER' 2>/dev/null || true; prepare_prerun_log")"
  [ -n "$log" ]
  case "$log" in
    "$REPO" | "$REPO"/*) return 1 ;;   # im Repo -> Befund
  esac
  dir="$(dirname "$log")"
  [ -d "$dir" ]
  rm -rf "$dir"
}

# Die Verweigerung selbst: ein Log-Ziel UNTER dem Repo muss FALLEN. Der Fall darueber
# misst die Lage, die `mktemp -d` liefert, und erreicht den case-Zweig nie — unter dem
# hier geltenden $TMPDIR zeigt `mktemp -d` nach /tmp, und im bats-Container ist das Repo
# als /code zusaetzlich :ro gemountet, ein Verzeichnis darunter entstuende dort gar
# nicht. Ein mktemp-Stub auf $PATH stellt die Bedingung her, unter der die Schranke
# greift: dieselbe Technik wie der make-Stub im Vorlauf-Fall oben, und dieselbe Paarung
# aus Lage und Verweigerung wie bei isolation_path.
@test "driver: prepare_prerun_log VERWEIGERT ein Protokoll unter dem Repo" {
  local iso stub
  iso="$(mktemp -d)"; stub="$iso/bin"
  mkdir -p "$stub" "$iso/baum/tmp.vorlauf"
  # Der Stub liefert ein Verzeichnis unter dem $REPO, das der Aufruf unten setzt. Beide
  # liegen im mktemp-Sandkasten, nicht im echten Baum — die Schranke raeumt ihr Argument
  # weg, und das darf nur den Sandkasten treffen.
  cat >"$stub/mktemp" <<STUB
#!/usr/bin/env bash
printf '%s\n' '$iso/baum/tmp.vorlauf'
STUB
  chmod +x "$stub/mktemp"
  run env "PATH=$stub:$PATH" bash -c "source '$DRIVER' 2>/dev/null || true
    REPO='$iso/baum'
    prepare_prerun_log"
  rm -rf "$iso"
  [ "$status" -ne 0 ]
  # Der Status allein traegt die Aussage nicht: ein gescheitertes `mktemp -d` faellt an
  # derselben Stelle mit demselben Status. Erst die Meldung trennt die Schranke davon.
  grep -qF 'das Vorlauf-Protokoll laege im Repo' <<<"$output"
}

@test "driver: das smoke-Muster trifft Fehlschlag-Zeilen, NICHT Fortschritts-Zeilen" {
  local form
  form="$(bash -c "source '$DRIVER' 2>/dev/null || true; failure_form smoke")"
  printf 'smoke: 3/4 Skelett gestaged? ...\n'          | grep -Eq -- "$form" && return 1
  printf 'smoke: OK — Bootstrap laeuft\n'              | grep -Eq -- "$form" && return 1
  printf 'smoke: FEHLER — out-of-scope-Artefakt\n'     | grep -Eq -- "$form"
}

# --- narrow_sensor (slice-056) ------------------------------------------------
# Die Zuordnung `# expect:` -> Sensor ist ab slice-056 STEUERGROESSE, nicht nur
# Dokumentation. Vier Faelle; die letzten beiden sind der eigentliche Schutz: was nicht
# eindeutig zuzuordnen ist, muss den VOLLEN Satz fahren. Ein schnellerer Lauf, der
# weniger prueft, waere das stille Gruen, gegen das make mutate antritt.

@test "driver: narrow_sensor waehlt fuer einen Go-Testnamen nur die Go-Stufe" {
  run bash -c "source '$DRIVER' 2>/dev/null || true; narrow_sensor TestGenerate_Deterministic"
  [ "$output" = "test-go" ]
}

@test "driver: narrow_sensor waehlt fuer einen bats-Titel nur die bats-Stufe" {
  run bash -c "source '$DRIVER' 2>/dev/null || true; narrow_sensor 'emittiert: eingelegter SYMLINK'"
  [ "$output" = "test-bats" ]
}

@test "driver: narrow_sensor faellt bei LEERER Erwartung auf den vollen Satz zurueck" {
  run bash -c "source '$DRIVER' 2>/dev/null || true; narrow_sensor ''"
  [ "$output" = "test" ]
}

@test "driver: narrow_sensor faellt bei MEHRZEILIGER Erwartung auf den vollen Satz zurueck" {
  run bash -c "source '$DRIVER' 2>/dev/null || true; narrow_sensor 'TestEins
TestZwei'"
  [ "$output" = "test" ]
}

# Die neuen Modi brauchen ein Fehlschlag-Muster — sonst faellt Bedingung 4 in den
# F-1-Zustand (rot aus falschem Grund wird als Beleg akzeptiert).
@test "driver: failure_form kennt die zwei neuen Stufen" {
  local m
  for m in test-go test-bats; do
    run bash -c "source '$DRIVER' 2>/dev/null || true; failure_form $m"
    [ -n "$output" ]
  done
}

# Der WERTEBEREICH, nicht die heutige Verzweigung: narrow_sensor waehlt den Sensor
# JEDES Falls ohne eigenen `# verify:`-Kopf, und wer diese Wahl trifft, verteilt
# Laufzeit auf Faelle, die sie nirgends geschrieben stehen haben. Ein teurer Modus
# gehoert deshalb in einen ausdruecklichen Kopf, nie in diese Auswahl. Gemessen wird
# ueber die echte Eingabe-Menge — alle `# expect:`-Zeilen des Fall-Verzeichnisses —
# plus die Rand-Eingaben, die auf den vollen Satz zurueckfallen muessen.
@test "driver: narrow_sensor liefert NUR Werte aus {test, test-go, test-bats}" {
  run bash -c '
    source "$1" 2>/dev/null || true
    ausserhalb() {
      case "$2" in
        test | test-go | test-bats) ;;
        *) printf "ausserhalb des Wertebereichs: [%s] -> [%s]\n" "$1" "$2" ;;
      esac
    }
    while IFS= read -r expect; do
      ausserhalb "$expect" "$(narrow_sensor "$expect")"
    done < <(
      sed -n "s/^# expect: //p" "$2"/test/mutations/*.sh
      printf "%s\n" "" "Test" "TestX" "testklein" "full-smoke" "smoke: FEHLER"
    )
    mehrzeilig="$(printf "TestEins\nTestZwei\n")"
    ausserhalb "mehrzeilig" "$(narrow_sensor "$mehrzeilig")"
  ' _ "$DRIVER" "$REPO"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

# --- Warteschlange, Spur und Zusammenfuehrung (slice-105) ----------------------
# Der Treiber teilt seine Faelle auf mehrere Worker auf. Damit entsteht eine neue Klasse
# von stillem Gruen, die es sequentiell nicht gab: ein Lauf, der weniger geprueft hat als
# er meldet — weil ein Worker starb, weil die Warteschlange einen Fall nie ausgab, oder
# weil zwei Worker einander ein gebautes Bild unterschoben. Die Faelle hier sind die
# Zaehne dagegen, und sie sind hermetisch: kein Docker, kein echter Sensor-Lauf.

# --- Die serielle Spur --------------------------------------------------------
# plan_self_contained entscheidet, ob zwei Worker einen Modus GLEICHZEITIG fahren
# duerfen. Ein falsches "ja" ist ein falsches Urteil, und zwar ein still gruenes: der
# eine Worker extrahierte das Binary des anderen aus demselben Tag. Der Vorgaenger
# dieses Kriteriums las die Treiberskripte nach `make <ziel>`-Zeilen ab und verfehlte
# `make full-smoke`, sobald eine fremde Aenderung den Aufruf in eine
# Kommando-Substitution setzte. Geprueft wird darum die EIGENSCHAFT (ist der Plan
# vollstaendig gelesen?), nicht die Gestalt einer Zeile.
#
# Der make-Stub liefert den Plan: dieselbe Technik wie beim Vorlauf-Fall oben.
plan_stub() {
  PS_ISO="$(mktemp -d)"
  mkdir -p "$PS_ISO/bin" "$PS_ISO/repo"
  cat >"$PS_ISO/bin/make" <<STUB
#!/usr/bin/env bash
# Bildet nach, was GNU make in einem SUB-make wirklich tut: liegt MAKELEVEL in der
# Umgebung, rahmt make seinen Plan mit Verzeichnis-Zeilen ein — es sei denn,
# --no-print-directory steht dabei. Genau diese zwei Zeilen sind kein docker-Aufruf.
rahmen=0
[ -n "\${MAKELEVEL:-}" ] && rahmen=1
for a in "\$@"; do [ "\$a" = "--no-print-directory" ] && rahmen=0; done
[ "\$rahmen" = 1 ] && printf 'make[1]: Verzeichnis wird betreten\n'
printf '%s' "\$PLAN_TEXT"
[ "\$rahmen" = 1 ] && printf '\nmake[1]: Verzeichnis wird verlassen\n'
exit \${PLAN_RC:-0}
STUB
  chmod +x "$PS_ISO/bin/make"
}

# Ruft plan_self_contained mit gestubtem Plan. \$1 = Plantext, \$2 = Exit des Trockenlaufs.
plan_urteil() {
  PLAN_TEXT="$1" PLAN_RC="${2:-0}" env "PATH=$PS_ISO/bin:$PATH" bash -c "
    source '$DRIVER' 2>/dev/null || true
    REPO='$PS_ISO/repo'
    if plan_self_contained irgendein-modus; then echo LEICHT; else echo SCHWER; fi"
}

# Dasselbe, aber MIT der make-Umgebung eines Aufrufers, der selbst aus einer Rezeptur
# kommt — der reale Fall, denn `make mutate` ruft den Treiber aus einem Rezept.
plan_urteil_im_submake() {
  PLAN_TEXT="$1" PLAN_RC="${2:-0}" MAKELEVEL=1 MAKEFLAGS=w \
    env "PATH=$PS_ISO/bin:$PATH" bash -c "
    source '$DRIVER' 2>/dev/null || true
    REPO='$PS_ISO/repo'
    if plan_self_contained irgendein-modus; then echo LEICHT; else echo SCHWER; fi"
}
@test "driver: ein Plan aus lauter docker-Aufrufen darf parallel laufen" {
  plan_stub
  run plan_urteil 'docker build --no-cache-filter test --target test -t ai-harness-init:test .'
  [ "$output" = "LEICHT" ]
  run plan_urteil 'docker run --rm --network none -v "/x":/code:ro -w /code bats/bats test/
docker build --target test -t ai-harness-init:test .'
  [ "$output" = "LEICHT" ]
  rm -rf "$PS_ISO"
}

# DER KERN: ein Plan, der in ein Skript abbiegt, ist NICHT vollstaendig gelesen — egal
# wie der Aufruf dort drin aussieht. Genau diese Gestalt-Unabhaengigkeit fehlte dem
# Vorgaenger.
@test "driver: ein Plan, der in ein Skript abbiegt, ist SCHWER — unabhaengig von der Zeilenform darin" {
  plan_stub
  run plan_urteil "GO_VERSION='1.27.0' bash harness/tools/full-smoke.sh"
  [ "$output" = "SCHWER" ]
  run plan_urteil 'bash harness/tools/smoke.sh'
  [ "$output" = "SCHWER" ]
  rm -rf "$PS_ISO"
}

# Fail-closed: was der Treiber nicht lesen kann, faehrt er seriell. Falsch-seriell
# kostet Zeit, falsch-parallel kostet ein Urteil.
@test "driver: ein unlesbarer oder leerer Trockenlauf ist SCHWER (fail-closed)" {
  plan_stub
  run plan_urteil 'docker build --target test .' 2
  [ "$output" = "SCHWER" ]
  run plan_urteil ''
  [ "$output" = "SCHWER" ]
  rm -rf "$PS_ISO"
}

# Ein docker-Unterkommando, das ein gebautes Bild ZURUECKLIEST, ist genau der Fall, um
# den es geht — `build` und `run` sind die einzigen, deren Urteil im eigenen Exit-Code
# steckt.
@test "driver: ein docker-Aufruf, der kein build/run ist, ist SCHWER" {
  plan_stub
  run plan_urteil 'docker create --name x ai-harness-init:build'
  [ "$output" = "SCHWER" ]
  rm -rf "$PS_ISO"
}

# --- Die Warteschlange --------------------------------------------------------
# Sie ist die dynamische Zuteilung. Gibt sie einen Eintrag ZWEIMAL aus, laeuft ein Fall
# doppelt und ein anderer nie; gibt sie einen nie aus, ist der Lauf unvollstaendig. Beide
# Wege enden im stillen Gruen, wenn niemand nachzaehlt.
@test "driver: die Warteschlange gibt jeden Eintrag genau einmal und meldet dann leer" {
  local dir
  dir="$(mktemp -d)"
  run bash -c "source '$DRIVER' 2>/dev/null || true
    RUN_DIR='$dir'
    printf 'a\nb\n' | queue_new light
    queue_take light; echo
    queue_take light; echo
    rc=0; queue_take light || rc=\$?; echo \"leer-status=\$rc\""
  rm -rf "$dir"
  [ "${lines[0]}" = "a" ]
  [ "${lines[1]}" = "b" ]
  [ "${lines[2]}" = "leer-status=1" ]
}

# Die Abbruch-Flagge ist der Weg, auf dem EIN sterbender Worker den GANZEN Lauf anhaelt.
# Ohne sie zoegen die uebrigen weiter — bei einem Isolations-Bruch mutierten sie dabei
# weiter gegen den Host.
@test "driver: nach abort_run zieht kein Worker mehr einen Fall" {
  local dir
  dir="$(mktemp -d)"
  run bash -c "source '$DRIVER' 2>/dev/null || true
    RUN_DIR='$dir'
    printf 'a\nb\n' | queue_new light
    abort_run
    rc=0; queue_take light || rc=\$?; echo \"status=\$rc\""
  rm -rf "$dir"
  grep -qF 'status=3' <<<"$output"
  grep -qF 'hat den Lauf abgebrochen' <<<"$output"
}

# --- Die Zusammenfuehrung -----------------------------------------------------
# merge_report ist die Stelle, an der „alle Worker sind zurueck" NICHT als Beleg gilt.
# Er zaehlt gegen zwei verschiedene Groessen: die Zug-Protokolle (hat jemand doppelt
# gezogen?) und das Fall-Verzeichnis (hat jeder Fall ein Ergebnis?).
mr_fixture() {
  MR_DIR="$(mktemp -d)"
  local i
  for i in 1 2 3; do
    printf 'mutate: ok      fall-%s\n' "$i" >"$MR_DIR/case.$i.log"
    printf '%s\tfall-%s\tOK\ttest-go\t1.00\n' "$i" "$i" >"$MR_DIR/status.$i"
  done
  printf '1\n2\n3\n' >"$MR_DIR/draws.1"
}

mr_lauf() {
  bash -c "source '$DRIVER' 2>/dev/null || true
    RUN_DIR='$MR_DIR'
    CASE_NAMES=('' fall-1 fall-2 fall-3)
    merge_report 3
    echo \"befunde=\$fail_count ok=\$pass_count\""
}

@test "driver: merge_report bestaetigt Vollstaendigkeit nur, wenn jeder Fall ein Ergebnis hat" {
  mr_fixture
  run mr_lauf
  rm -rf "$MR_DIR"
  grep -qF 'Vollstaendigkeit — 3 von 3 Fall-Dateien mit Ergebnis' <<<"$output"
  grep -qF 'befunde=0 ok=3' <<<"$output"
}

# DoD (3): ein Shard, der abstuerzt, haengt oder nichts meldet, faerbt den Gesamtlauf rot
# — er verkuerzt ihn nicht. Der Fall stellt genau das her: die Statuszeile eines Falls
# fehlt.
@test "driver: merge_report FAELLT, wenn ein Fall ohne Ergebnis geblieben ist" {
  mr_fixture
  rm "$MR_DIR/status.2"
  run mr_lauf
  rm -rf "$MR_DIR"
  grep -qF 'ohne Ergebnis geblieben: fall-2' <<<"$output"
  grep -qF '2 von 3 Fall-Dateien haben ein Ergebnis' <<<"$output"
  ! grep -qF 'Vollstaendigkeit — ' <<<"$output"
  grep -qF 'ok=2' <<<"$output"
}

# Der zweite Weg: ein Cursor, der nicht fortschreibt, gibt denselben Fall zweimal aus.
# Die Statusdatei traegt die Nummer im NAMEN und wuerde ueberschrieben — sichtbar ist der
# Doppelzug nur im Zug-Protokoll.
@test "driver: merge_report FAELLT bei einer mehr als einmal gezogenen Fall-Nummer" {
  mr_fixture
  printf '2\n' >>"$MR_DIR/draws.2"
  run mr_lauf
  rm -rf "$MR_DIR"
  grep -qF 'mehr als einmal gezogen (Fall-Nummern): 2' <<<"$output"
  ! grep -qF 'Vollstaendigkeit — ' <<<"$output"
}

@test "driver: merge_report FAELLT, wenn kein Worker je gezogen hat" {
  mr_fixture
  rm "$MR_DIR"/draws.*
  run mr_lauf
  rm -rf "$MR_DIR"
  grep -qF 'kein einziger Worker hat ein Zug-Protokoll hinterlassen' <<<"$output"
}

# --- Die Zeit-Aufschluesselung ------------------------------------------------
# DoD (1): die Bilanz nennt ihren Nenner. Anteile ueber einer Teilmenge sind Anteile an
# etwas anderem als dem, was die Ueberschrift sagt — darum gibt es sie unvollstaendig
# gar nicht, sondern nur als Befund.
@test "driver: report_times nennt Anteil je Sensor und seinen Nenner" {
  mr_fixture
  printf '2\tfall-2\tOK\tfull-smoke\t9.00\n' >"$MR_DIR/status.2"
  run bash -c "source '$DRIVER' 2>/dev/null || true
    RUN_DIR='$MR_DIR'
    report_times 3"
  rm -rf "$MR_DIR"
  grep -qF 'Zeit je Sensor ueber 3 von 3 Fall-Dateien' <<<"$output"
  grep -qE 'full-smoke +n=1 +summe= +9\.0 anteil= 81\.8%' <<<"$output"
  grep -qE 'test-go +n=2 +summe= +2\.0 anteil= 18\.2%' <<<"$output"
  grep -qF 'laengster Einzelfall: 9.00 s (fall-2)' <<<"$output"
}

@test "driver: report_times FAELLT statt eine Bilanz ueber einer Teilmenge auszugeben" {
  mr_fixture
  rm "$MR_DIR/status.3"
  run bash -c "source '$DRIVER' 2>/dev/null || true
    RUN_DIR='$MR_DIR'
    report_times 3
    echo \"befunde=\$fail_count\""
  rm -rf "$MR_DIR"
  grep -qF '2 von 3 Fall-Dateien tragen eine Dauer' <<<"$output"
  ! grep -qF 'Zeit je Sensor ueber' <<<"$output"
  ! grep -qF 'anteil=' <<<"$output"
  grep -qF 'befunde=1' <<<"$output"
}

# --- Der Gruen-Vorlauf je Worker ----------------------------------------------
# DoD (2): jeder Worker belegt den Sensor in SEINER Kopie, bevor er dessen ersten Fall
# faehrt. Ist er dort ohne Mutation rot, waere jeder Fall danach rot — und zwar nicht
# wegen seiner Mutation. Der Worker bricht dann ab UND legt die Abbruch-Flagge, damit
# kein anderer weiterzieht.
@test "driver: ein Worker BRICHT AB, wenn sein Gruen-Vorlauf in SEINER Kopie rot ist" {
  local iso stub
  iso="$(mktemp -d)"; stub="$iso/bin"
  mkdir -p "$stub" "$iso/w7/repo" "$iso/run"
  cat >"$stub/make" <<'STUB'
#!/usr/bin/env bash
printf '%s\n' 'VORLAUF-KOPIE-ROT'
exit 1
STUB
  chmod +x "$stub/make"
  run env "PATH=$stub:$PATH" bash -c "source '$DRIVER' 2>/dev/null || true
    ISO_ROOT='$iso'; RUN_DIR='$iso/run'
    printf '1\ttest-go\t/kein/fall.sh\n' | queue_new light
    rc=0; worker_main 7 '' light || rc=\$?
    echo \"status=\$rc\"
    [ -e '$iso/run/abort' ] && echo 'ABBRUCH-FLAGGE LIEGT'" 3>&2
  rm -rf "$iso"
  grep -qF 'Worker 7: der Gruen-Vorlauf' <<<"$output"
  grep -qF 'in SEINER Kopie ohne Mutation rot' <<<"$output"
  grep -qF 'VORLAUF-KOPIE-ROT' <<<"$output"
  grep -qF 'status=1' <<<"$output"
  grep -qF 'ABBRUCH-FLAGGE LIEGT' <<<"$output"
}

# DIE ZUORDNUNG DARF NICHT AN DER UMGEBUNG DES AUFRUFERS HAENGEN, und dieser Fall ist
# nicht theoretisch: `make mutate` ruft den Treiber aus einer Rezeptur, ein `make` darin
# ist ein SUB-make und schaltet `--print-directory` von selbst ein. Beim ersten Lauf ueber
# der echten Fall-Menge fiel damit JEDER Modus in die serielle Spur — dieselbe Funktion
# hatte aus einer normalen Shell gerufen das Gegenteil gesagt. Der make-Stub bildet genau
# diesen Unterschied nach; der Zahn dazu ist test/mutations/195.
@test "driver: die Spur-Zuordnung ist dieselbe, ob aus einer Shell oder aus einem Sub-make gerufen" {
  local plan ohne mit
  plan='docker build --no-cache-filter test --target test -t ai-harness-init:test .'
  plan_stub
  ohne="$(plan_urteil "$plan")"
  mit="$(plan_urteil_im_submake "$plan")"
  rm -rf "$PS_ISO"
  [ "$ohne" = "LEICHT" ]
  [ "$mit" = "LEICHT" ]
}

# --- Die Statuszeile ----------------------------------------------------------
# `>"$f"` legt die Datei an, BEVOR es schreibt. Ein Worker, der dazwischen stirbt —
# Signal, volle Platte —, hinterlaesst eine LEERE Statusdatei. Solange die
# Vollstaendigkeit ueber `[ -f ]` ging, zaehlte sie als Ergebnis, und das leere Urteil
# fiel in den else-Zweig: der verlorene Fall galt als BESTANDEN, waehrend der Lauf
# daneben seine Vollstaendigkeit bestaetigte. Beide Achsen werden hier gefahren, weil
# beide es behaupteten — die Vollstaendigkeit und die Bilanz.
@test "driver: eine LEERE Statusdatei zaehlt NICHT als Ergebnis" {
  mr_fixture
  : >"$MR_DIR/status.2"
  run mr_lauf
  rm -rf "$MR_DIR"
  grep -qF 'ohne lesbares Urteil: fall-2' <<<"$output"
  ! grep -qF 'Vollstaendigkeit — ' <<<"$output"
  grep -qF 'ok=2' <<<"$output"
}

# Eine Statuszeile, die auf den falschen Fall zeigt, ist ebenso wenig sein Ergebnis wie
# gar keine: die Nummer im Dateinamen und die im Inhalt muessen dieselbe sein.
@test "driver: eine Statuszeile mit fremder Fall-Nummer zaehlt NICHT als Ergebnis" {
  mr_fixture
  printf '9\tfall-2\tOK\ttest-go\t1.00\n' >"$MR_DIR/status.2"
  run mr_lauf
  rm -rf "$MR_DIR"
  grep -qF 'ohne lesbares Urteil: fall-2' <<<"$output"
  ! grep -qF 'Vollstaendigkeit — ' <<<"$output"
}

# Die Bilanz nennt als Nenner die ZEILEN, ueber die sie rechnet — nicht die Zahl der
# Statusdateien. Liefen beide auseinander, ueberschrieb `n von total` eine Summe ueber
# weniger, und die Anteile waeren Anteile an etwas anderem.
@test "driver: report_times rechnet ueber gueltige ZEILEN, nicht ueber Dateien" {
  mr_fixture
  : >"$MR_DIR/status.2"
  run bash -c "source '$DRIVER' 2>/dev/null || true
    RUN_DIR='$MR_DIR'
    report_times 3
    echo \"befunde=\$fail_count\""
  rm -rf "$MR_DIR"
  grep -qF '2 von 3 Fall-Dateien tragen eine Dauer' <<<"$output"
  ! grep -qF 'Zeit je Sensor' <<<"$output"
  grep -qF 'befunde=1' <<<"$output"
}

# --- Der Worker unter `set -e` ------------------------------------------------
# Die AUFRUFFORM traegt hier eine Eigenschaft: `worker_main … || rc=$?` setzt errexit
# fuer den ganzen Rumpf aus, bis in run_case hinein — bash tut das in jedem Kommando
# eines `||`-Kontextes. Ein gescheitertes Schreiben brach den Worker dann nicht ab; er
# lief weiter und hinterliess genau die leere Statusdatei aus dem Test darueber.
# Gefahren wird darum spawn_worker SELBST und keine im Test nachgebaute Subshell: sonst
# pruefte der Test seine eigene Form. Der Zug wird unschreibbar gemacht, indem an seiner
# Stelle ein VERZEICHNIS liegt — das braucht keinen Sensor-Lauf und keine volle Platte.
@test "driver: ein Worker BRICHT AB, wenn er seinen Zug nicht protokollieren kann" {
  local root
  root="$(mktemp -d)"
  mkdir -p "$root/run" "$root/w1/repo" "$root/run/draws.1"
  printf '1\ttest-go\t/nicht/vorhanden.sh\n' >"$root/run/light.queue"
  printf '1\n' >"$root/run/light.cursor"
  run bash -c "source '$DRIVER' 2>/dev/null || true
    trap - EXIT INT TERM
    ISO_ROOT='$root'; RUN_DIR='$root/run'
    exec 3>/dev/null
    spawn_worker 1 'test-go' light
    wait \$! || echo \"worker-status=\$?\"
    [ -f '$root/run/worker.1.done' ] && echo 'MARKE-DA' || echo 'MARKE-FEHLT'"
  rm -rf "$root"
  grep -qE 'worker-status=[1-9]' <<<"$output"
  grep -qF 'MARKE-FEHLT' <<<"$output"
}

# --- Die Zeitschranke ---------------------------------------------------------
# DoD (1) aus slice-117: ein Worker, der nicht zurueckkommt, faerbt den Lauf VON SELBST
# rot. `wait` allein kennt keine Schranke — ein haengender Lauf ist von einem langsamen
# nicht zu unterscheiden, und lokal beendet ihn niemand. Gemessen wird STILLE, nicht
# Dauer: hier zieht und beendet niemand einen Fall, waehrend ein Prozess weiterlaeuft.
@test "driver: ein Lauf ohne Fortschritt endet an der Zeitschranke" {
  local root
  root="$(mktemp -d)"
  mkdir -p "$root/run"
  printf '1\n' >"$root/run/draws.1"
  run bash -c "source '$DRIVER' 2>/dev/null || true
    trap - EXIT INT TERM
    RUN_DIR='$root/run'
    STALL_SECONDS=1
    sleep 20 </dev/null >/dev/null 2>&1 3>&- 4>&- & p=\$!
    WORKER_PIDS=(\$p)
    await_workers \$p || echo \"schranke=\$?\"
    kill \$p 2>/dev/null || :
    echo \"befunde=\$fail_count\""
  rm -rf "$root"
  grep -qF 'schranke=1' <<<"$output"
  grep -qF 'Noch laufend: Worker 1' <<<"$output"
  grep -qF 'befunde=1' <<<"$output"
}

# Ein Fortschritts-Ereignis setzt die Uhr zurueck — sonst roetete die Schranke jeden Lauf,
# der laenger als sie dauert, und das waere ein Sensor, der ohne Befund rot wird.
@test "driver: Fortschritt setzt die Zeitschranke zurueck" {
  local root
  root="$(mktemp -d)"
  mkdir -p "$root/run"
  printf '1\n' >"$root/run/draws.1"
  run bash -c "source '$DRIVER' 2>/dev/null || true
    trap - EXIT INT TERM
    RUN_DIR='$root/run'
    STALL_SECONDS=3
    ( sleep 2; printf '2\n' >>'$root/run/draws.1'; sleep 2 ) </dev/null >/dev/null 2>&1 3>&- 4>&- & p=\$!
    WORKER_PIDS=(\$p)
    await_workers \$p && echo 'ohne-schranke'
    echo \"befunde=\$fail_count\""
  rm -rf "$root"
  grep -qF 'ohne-schranke' <<<"$output"
  grep -qF 'befunde=0' <<<"$output"
}

# DoD (3): JEDE Zeitschranke des Treibers traegt einen Zahn. Diese hier stand seit
# slice-105 allein auf ihrem Kommentar — `grep -rln 'QUEUE_LOCK_TRIES' test/` war leer.
@test "driver: queue_take gibt an QUEUE_LOCK_TRIES auf, statt ewig zu warten" {
  local root
  root="$(mktemp -d)"
  mkdir -p "$root/run/light.lock"
  printf '1\ttest-go\tegal\n' >"$root/run/light.queue"
  printf '1\n' >"$root/run/light.cursor"
  run bash -c "source '$DRIVER' 2>/dev/null || true
    trap - EXIT INT TERM
    RUN_DIR='$root/run'
    QUEUE_LOCK_TRIES=2
    WORKER_ID=7
    queue_take light || echo \"status=\$?\""
  rm -rf "$root"
  grep -qF 'status=2' <<<"$output"
  grep -qF 'wartet seit' <<<"$output"
  grep -qF 'Worker 7' <<<"$output"
}

# --- Der Signal-Zweig ---------------------------------------------------------
# DoD (2): der Bericht eines abgebrochenen Laufs sagt nichts, was seine eigene Ausgabe
# widerlegt. Frueher loeschte der gemeinsame Handler ISO_ROOT — RUN_DIR liegt darin —,
# kehrte zurueck, und merge_report rechnete ueber ein geloeschtes Verzeichnis: „kein
# einziger Worker hat ein Zug-Protokoll hinterlassen" stand dann unter Faellen mit Urteil.
# Gefahren wird das ECHTE Signal gegen die trap-Verdrahtung des Treibers, nicht ein
# direkter Aufruf von on_signal: sonst bliebe die Verdrahtung ungeprueft.
@test "driver: ein Signal berichtet, BEVOR aufgeraeumt wird" {
  local root
  root="$(mktemp -d)"
  mkdir -p "$root/run"
  printf 'mutate: ok      fall-1\n' >"$root/run/case.1.log"
  printf '1\tfall-1\tOK\ttest-go\t1.00\n' >"$root/run/status.1"
  printf '1\n' >"$root/run/draws.1"
  run bash -c "source '$DRIVER' 2>/dev/null || true
    ISO_ROOT='$root'
    RUN_DIR='$root/run'
    TOTAL=2
    CASE_NAMES=('' fall-1 fall-2)
    kill -INT \$\$
    echo 'NACH-DEM-SIGNAL-WEITERGELAUFEN'"
  rm -rf "$root"
  [ "$status" -eq 130 ]
  grep -qF 'ohne Ergebnis geblieben: fall-2' <<<"$output"
  ! grep -qF 'kein einziger Worker hat ein Zug-Protokoll hinterlassen' <<<"$output"
  ! grep -qF 'NACH-DEM-SIGNAL-WEITERGELAUFEN' <<<"$output"
}

# --- Das Enden als Eigenschaft -------------------------------------------------
# DoD (1) sagt zu, dass ein Worker, der nicht zurueckkommt, den Lauf VON SELBST rot faerbt.
# Weder await_workers' Rueckgabewert noch stop_workers' kill-Zeilen belegen das einzeln:
# ohne die Schranke blockiert `wait` unbegrenzt, ohne die kill kehrt es auch nach
# abgelaufener Schranke nicht zurueck — getrennt gepruefte Teile sind gruen, waehrend das
# Ganze haengt. Der frueheste Entwurf dieses Tests raeumte den Testprozess selbst weg und
# maskierte damit genau die Wirkung, die er belegen sollte.
# `timeout` ist hier DETEKTOR, nicht Hilfsmittel: die Zusage ist, dass es NICHT gebraucht
# wird. Status 124 heisst, der Lauf haette ohne Hilfe von aussen nicht geendet.
@test "driver: das Einsammeln endet OHNE Hilfe von aussen" {
  local root
  root="$(mktemp -d)"
  mkdir -p "$root/run"
  printf '1\n' >"$root/run/draws.1"
  run timeout 30 bash -c "source '$DRIVER' 2>/dev/null || true
    trap - EXIT INT TERM
    RUN_DIR='$root/run'
    STALL_SECONDS=2
    sleep 45 </dev/null >/dev/null 2>&1 3>&- 4>&- & p=\$!
    WORKER_PIDS=(\$p)
    collect_workers \$p
    kill -0 \$p 2>/dev/null && echo 'WORKER-LEBT-NOCH' || echo 'worker-beendet'
    echo \"befunde=\$fail_count\""
  rm -rf "$root"
  # Beide Fassungen von `timeout`: GNU liefert 124, BusyBox 143 — im gepinnten Image ist
  # es BusyBox. Der Test fuehrt beide, damit er nicht auf einer Fassung stumm wird.
  [ "$status" -ne 124 ]
  [ "$status" -ne 143 ]
  grep -qF 'worker-beendet' <<<"$output"
  ! grep -qF 'WORKER-LEBT-NOCH' <<<"$output"
  grep -qE 'befunde=[1-9]' <<<"$output"
}

# Der Worker-Trap hatte denselben Defekt, den dieser Slice im Elternprozess behebt: EXIT,
# INT und TERM lagen auf worker_cleanup, das ZURUECKKEHRT. Ein TERM — von stop_workers
# selbst geschickt, sobald die Schranke greift — raeumte damit mitten in run_case das
# Fall-Backup weg und liess run_case danach in eine geloeschte Datei greifen: ein FALSCHES
# Fall-Urteil ohne jedes Signal von aussen.

# DoD (1) haengt an einer Zahl, die von aussen gesetzt werden kann. Ohne fail-closed-Pruefung
# schaltet eine unsinnige Vorgabe die Zusage LAUTLOS ab — gemessen: `abc` ergab 15
# Arithmetik-Fehler und null Zeitschranken-Befunde.
@test "driver: eine unsinnige MUTATE_STALL_SECONDS-Vorgabe BRICHT AB, statt die Schranke abzuschalten" {
  # Gegen eine echte Treiber-KOPIE ausserhalb des Repos: der Treiber leitet $REPO aus seinem
  # eigenen Ort ab, legt seinen Lock also im Temp-Baum an und beruehrt das Repo nicht.
  # Gefahren wird der ganze Weg — Vorgabe, Pruefung, Abbruch —, nicht nur die Pruefung:
  # eine Pruefung, die niemand ruft, ist gruen.
  local root
  root="$(mktemp -d)"
  mkdir -p "$root/harness/tools"
  cp "$DRIVER" "$root/harness/tools/mutate.sh"
  local bad
  for bad in abc 0 -5 1.5 "3 4"; do
    run env MUTATE_STALL_SECONDS="$bad" bash "$root/harness/tools/mutate.sh"
    [ "$status" -ne 0 ]
    grep -qF 'keine Sekundenzahl' <<<"$output"
  done
  # Eine LEERE Vorgabe ist keine unsinnige: `${MUTATE_STALL_SECONDS:-900}` behandelt sie wie
  # ungesetzt und faellt auf die Vorgabe des Treibers zurueck — dasselbe Verhalten wie bei
  # MUTATE_JOBS. Der Test haelt das fest, statt es zu bestrafen.
  run env MUTATE_STALL_SECONDS="" bash "$root/harness/tools/mutate.sh"
  ! grep -qF "keine Sekundenzahl" <<<"$output"
  # Eine gueltige Vorgabe kommt an dieser Schranke VORBEI (sonst prueft der Test nur, dass
  # der Treiber immer abbricht) und faellt erst am fehlenden Fall-Verzeichnis.
  run env MUTATE_STALL_SECONDS=42 bash "$root/harness/tools/mutate.sh"
  [ "$status" -ne 0 ]
  ! grep -qF 'keine Sekundenzahl' <<<"$output"
  rm -rf "$root"
}
# Der Worker-Trap hatte denselben Defekt, den dieser Slice im Elternprozess behebt: EXIT, INT
# und TERM lagen auf worker_cleanup, das ZURUECKKEHRT. Das TERM schickt stop_workers selbst,
# sobald die Zeitschranke greift — der Abbruch-Pfad erzeugte damit ein FALSCHES Fall-Urteil
# ohne jedes Signal von aussen: worker_cleanup raeumt das Fall-Backup weg, verify.log liegt
# darin, und run_case las danach eine geloeschte Datei.
# Gefahren wird worker_main SELBST, damit SEINE trap-Zeilen unter Messung stehen. Ein Test,
# der die Traps eigenhaendig setzt, misst worker_on_signal und laesst die Verdrahtung frei —
# so ist der erste Entwurf dieses Zahns durch `make mutate` gefallen.
@test "driver: ein Worker unter TERM meldet KEIN Fall-Urteil" {
  local iso stub
  iso="$(mktemp -d)"; stub="$iso/bin"
  mkdir -p "$stub" "$iso/w7/repo" "$iso/run"
  # Der Sensor-Lauf des Falls dauert kurz an; das TERM trifft waehrenddessen ein und wird
  # von bash danach zugestellt — genau die Lage, in der der Handler frueher zurueckkehrte.
  printf '#!/usr/bin/env bash\nsleep 3\n' >"$stub/make"
  chmod +x "$stub/make"
  # `# files:` nennt eine Datei, die es im ECHTEN Repo gibt: run_case rechnet den
  # Host-Fingerabdruck ueber sie, bevor es den Sensor faehrt.
  cp "$REPO/Makefile" "$iso/w7/repo/Makefile"
  cat >"$iso/fall.sh" <<'FALL'
#!/usr/bin/env bash
# files: Makefile
# verify: test-go
# expect: TestNieErreicht
sed -i '1i # mutiert' Makefile
FALL
  run timeout 25 env "PATH=$stub:$PATH" bash -c "source '$DRIVER' 2>/dev/null || true
    ISO_ROOT='$iso'; RUN_DIR='$iso/run'
    printf '1\ttest-go\t$iso/fall.sh\n' | queue_new light
    ( sleep 1; kill -TERM \$\$ ) </dev/null >/dev/null 2>&1 3>&- 4>&- &
    rc=0; worker_main 7 'test-go' light || rc=\$?
    echo \"NACH-DEM-WORKER-WEITERGELAUFEN status=\$rc\"" 3>&2
  local status_da="nein"
  [ -f "$iso/run/status.1" ] && status_da="ja"
  rm -rf "$iso"
  [ "$status" -eq 143 ]
  ! grep -qF 'NACH-DEM-WORKER-WEITERGELAUFEN' <<<"$output"
  [ "$status_da" = "nein" ]
}

# DoD (2): der Bericht eines abgebrochenen Laufs sagt nichts, was seine eigene Ausgabe
# widerlegt. Ein Signal, das WAEHREND des Berichts eintrifft, loeste frueher einen zweiten
# aus — gemessen `800 ok` ueber 400 Faellen mit doppelter Vollstaendigkeitszeile.
@test "driver: ein Signal wiederholt einen begonnenen Bericht NICHT" {
  local root
  root="$(mktemp -d)"
  mkdir -p "$root/run"
  printf 'mutate: ok      fall-1\n' >"$root/run/case.1.log"
  printf '1\tfall-1\tOK\ttest-go\t1.00\n' >"$root/run/status.1"
  printf '1\n' >"$root/run/draws.1"
  run bash -c "source '$DRIVER' 2>/dev/null || true
    ISO_ROOT='$root'; RUN_DIR='$root/run'
    TOTAL=1; CASE_NAMES=('' fall-1)
    BERICHT_BEGONNEN=1
    kill -INT \$\$
    echo 'NACH-DEM-SIGNAL-WEITERGELAUFEN'"
  rm -rf "$root"
  [ "$status" -eq 130 ]
  grep -qF 'wird nicht wiederholt' <<<"$output"
  ! grep -qF 'Vollstaendigkeit — ' <<<"$output"
  ! grep -qF 'NACH-DEM-SIGNAL-WEITERGELAUFEN' <<<"$output"
}

# Ein ZWEITES Signal waehrend des Berichts bricht ohne Bericht ab — und sagt das. Die Zeile
# davor hat zugesagt, dass berichtet wird; sie stillschweigend zu brechen waere eine Ausgabe,
# die ihrer eigenen widerspricht.
@test "driver: ein zweites Signal sagt, dass es OHNE Bericht abbricht" {
  local root
  root="$(mktemp -d)"
  mkdir -p "$root/run"
  run bash -c "source '$DRIVER' 2>/dev/null || true
    ISO_ROOT='$root'; RUN_DIR='$root/run'
    TOTAL=1; CASE_NAMES=('' fall-1)
    SIGNAL_SEEN=1
    kill -TERM \$\$
    echo 'NACH-DEM-SIGNAL-WEITERGELAUFEN'"
  rm -rf "$root"
  [ "$status" -eq 130 ]
  grep -qF 'zweites TERM' <<<"$output"
  grep -qF 'OHNE Bericht' <<<"$output"
  ! grep -qF 'NACH-DEM-SIGNAL-WEITERGELAUFEN' <<<"$output"
}

# --- Beleg statt Lauf (ADR-0035) ---------------------------------------------
# isolation_key_files/isolation_key sind die Bezugsmenge des Beleg-Schluessels: dieselbe
# ISOLATION_EXCLUDES-Definition wie prepare_isolation, plus die deklarierte Ausnahme
# ISOLATION_KEY_EXEMPT (`.git`). Die drei Tests unten sind die drei Zeilen der Fitness
# Function aus ADR-0035.

# Fitness-Function-Zeile 1 (bats, `make test`): jeder von prepare_isolation kopierte Pfad
# geht entweder in den Schluessel ein oder steht in der deklarierten Ausnahmeliste — ein
# dritter Fall ist rot. Beide Mengen kommen aus den ECHTEN Funktionen, nicht aus einer im
# Test nachgebauten Fassung (BEO-028): die Kopie-Seite aus einem echten
# prepare_isolation-Lauf, die Schluessel-Seite aus isolation_key_files selbst.
@test "driver: jeder von prepare_isolation kopierte Pfad geht in den Schluessel ein oder steht in der Ausnahmeliste" {
  local root dest copy key exempt diff p e matched
  root="$(mktemp -d)"
  dest="$(bash -c "source '$DRIVER' 2>/dev/null || true; prepare_isolation '$root'")"
  copy="$(cd "$dest" && find . -mindepth 1 \( -type f -o -type l \) | sed 's|^\./||' | LC_ALL=C sort -u)"
  # FAIL-CLOSED wie target_fingerprint/isolation_key im selben Skript: eine LEERE Kopie
  # macht "diff" trivial leer und die Schleife unten liefe nie — vakuaer gruen ueber der
  # leeren Menge, ohne je einen Pfad geprueft zu haben.
  [ -n "$copy" ]
  key="$(bash -c "source '$DRIVER' 2>/dev/null || true; isolation_key_files")"
  exempt="$(bash -c "source '$DRIVER' 2>/dev/null || true; printf '%s\n' \"\${ISOLATION_KEY_EXEMPT[@]}\"")"
  rm -rf "$root"
  diff="$(LC_ALL=C comm -23 <(printf '%s\n' "$copy") <(printf '%s\n' "$key" | LC_ALL=C sort -u))"
  while IFS= read -r p; do
    [ -z "$p" ] && continue
    matched=""
    while IFS= read -r e; do
      e="${e#./}"
      [ -z "$e" ] && continue
      case "$p" in
        "$e" | "$e"/*) matched=1 ;;
      esac
    done <<<"$exempt"
    if [ -z "$matched" ]; then
      echo "unerklaerter Pfad ausserhalb Schluessel UND Ausnahmeliste: $p" >&2
      return 1
    fi
  done <<<"$diff"
}

# Fitness-Function-Zeile 2 (test/mutations/262, `make mutate`): eine Mutation, die einen
# Pfad aus dem Schluessel nimmt, ohne ihn in ISOLATION_KEY_EXEMPT zu setzen, faerbt genau
# den Test oben rot — geprueft ueber `make mutate` selbst, nicht hier; dieser Kommentar ist
# der Zeiger auf den Fall, kein zweiter Wortlaut.

# Fitness-Function-Zeile 3 (bats, `make test`): der Schluessel reagiert auf den Inhalt, den
# er hasht — sonst waere ein "unveraendert" ein Rechen-Artefakt statt einer Messung.
@test "driver: isolation_key bewegt sich mit dem Inhalt, den er hasht" {
  local tmp a b
  tmp="$(mktemp -d)"
  printf 'eins\n' >"$tmp/datei.txt"
  a="$(bash -c "source '$DRIVER' 2>/dev/null || true; REPO='$tmp'; isolation_key")"
  printf 'zwei\n' >"$tmp/datei.txt"
  b="$(bash -c "source '$DRIVER' 2>/dev/null || true; REPO='$tmp'; isolation_key")"
  rm -rf "$tmp"
  [ -n "$a" ]
  [ "$a" != "$b" ]
}

# Fitness-Function-Zeile 3, zweiter Teil (bats, `make test`): ein Lauf mit mindestens
# einem Befund hinterlaesst KEINEN Beleg — auch nicht, wenn schon einer zum SELBEN
# Schluessel dastand (moeglich unter MUTATE_FORCE ueber unveraendertem Baum). Gegenprobe:
# fail_count=0 schreibt den Beleg. GEMESSEN IST NUR finalize_belief ISOLIERT — dass main()
# an ihrem einzigen Aufrufort, als dessen letzte Anweisung, tatsaechlich genauso aufruft,
# UND dass kein Ausgang DAVOR einen bestehenden Beleg unbehandelt laesst, prueft dieser
# Test-Block nicht; dafuer stehen die main()-Tests darunter.
@test "driver: finalize_belief schreibt den Beleg NUR bei fail_count=0" {
  local tmp
  tmp="$(mktemp -d)"
  run bash -c "source '$DRIVER' 2>/dev/null || true
    BELIEF='$tmp/mutate-passed.key'
    fail_count=0
    finalize_belief schluessel-abc"
  [ "$status" -eq 0 ]
  [ "$(cat "$tmp/mutate-passed.key")" = "schluessel-abc" ]
  rm -rf "$tmp"
}

@test "driver: ein Lauf mit Befund hinterlaesst keinen Beleg (auch keinen stehengebliebenen)" {
  local tmp
  tmp="$(mktemp -d)"
  printf 'alter-schluessel\n' >"$tmp/mutate-passed.key"
  run bash -c "source '$DRIVER' 2>/dev/null || true
    BELIEF='$tmp/mutate-passed.key'
    fail_count=1
    finalize_belief schluessel-abc"
  [ "$status" -eq 0 ]
  [ ! -f "$tmp/mutate-passed.key" ]
  rm -rf "$tmp"
}

# Der Beleg-Slot ist EIN Slot, keiner je Schluessel: finalize_belief steht als LETZTE
# Anweisung von main(), und jeder `exit`-Pfad DAVOR (leeres Fall-Set, Fingerabdruck,
# unbekannter Modus, require_isolated, der GRUEN-VORLAUF — der Docker-Cache-Fall aus
# ADR-0035 Festlegung 4 — und `on_signal`) muss einen bestehenden Beleg sofort entwerten,
# bevor er `main()` verlaesst — sonst ueberlebt ein Beleg genau den Lauf, der ihn
# widerlegt: ein erzwungener Lauf, der nach der Beleg-Pruefung rot abbricht, liesse den
# ALTEN Beleg stehen, und der naechste UNERZWUNGENE Aufruf meldete faelschlich
# "unveraendert", Exit 0. Dieser Test trifft NICHT die isolierte Funktion, sondern die
# ECHTE main()-Verdrahtung: er startet `mutate.sh` zweimal als eigenen Prozess, braucht
# kein Docker — der gewaehlte Abbruch (unbekannter `# verify:`-Modus) liegt vor jeder
# Isolations-Kopie und jedem Sensor-Lauf.
@test "driver: main() loescht einen bestehenden Beleg SOFORT, wenn der Lauf danach abbricht (kein Ueberleben)" {
  local fake
  fake="$(mktemp -d)"
  mkdir -p "$fake"/{harness/tools,test/mutations,.harness/state}
  cp "$DRIVER" "$fake/harness/tools/mutate.sh"
  printf '%s\n' '#!/usr/bin/env bash' '# files: datei.txt' '# expect: irgendwas' \
    '# verify: unbekannter-modus' 'set -euo pipefail' 'true' >"$fake/test/mutations/01-demo.sh"
  printf 'inhalt\n' >"$fake/datei.txt"
  bash -c "source '$fake/harness/tools/mutate.sh' 2>/dev/null || true; isolation_key" \
    >"$fake/.harness/state/mutate-passed.key"
  [ -s "$fake/.harness/state/mutate-passed.key" ]

  run env MUTATE_FORCE=1 bash "$fake/harness/tools/mutate.sh"
  [ "$status" -eq 1 ]
  [ ! -f "$fake/.harness/state/mutate-passed.key" ]

  run bash "$fake/harness/tools/mutate.sh"
  [ "$status" -eq 1 ]
  ! grep -qF 'Kein Fall-Lauf' <<<"$output"
  grep -qF "unbekannter '# verify:" <<<"$output"
  rm -rf "$fake"
}

# Der Uebersprung ist DREITEILIG (Bedingung 6 im Kopf: "NUR bei exaktem Schluessel-Treffer"):
# kein MUTATE_FORCE, eine Beleg-Datei liegt vor, UND ihr Inhalt entspricht dem aktuellen
# belief_key. Die ersten zwei Teile deckt der Test oben (keine Datei -> kein Uebersprung) und
# der volle main()-Lauf ohnehin (kein belief_key ohne Isolationskopie); der DRITTE, der
# Gleichheits-Vergleich selbst, ist ohne diesen Test unbewacht — eine Beleg-Datei mit
# beliebigem Inhalt genuegte dann fuer den Uebersprung. Dieser Test legt eine Beleg-Datei mit
# einem Inhalt an, der zu KEINEM berechenbaren Schluessel passt, und verlangt, dass der
# unerzwungene Lauf trotzdem voll faehrt statt "unveraendert" zu melden.
@test "driver: main() ueberspringt NUR bei einem Beleg, der dem aktuellen Schluessel entspricht" {
  local fake
  fake="$(mktemp -d)"
  mkdir -p "$fake"/{harness/tools,test/mutations,.harness/state}
  cp "$DRIVER" "$fake/harness/tools/mutate.sh"
  printf '%s\n' '#!/usr/bin/env bash' '# files: datei.txt' '# expect: irgendwas' \
    '# verify: unbekannter-modus' 'set -euo pipefail' 'true' >"$fake/test/mutations/01-demo.sh"
  printf 'inhalt\n' >"$fake/datei.txt"
  printf 'VOELLIG-FALSCHER-SCHLUESSEL\n' >"$fake/.harness/state/mutate-passed.key"

  run bash "$fake/harness/tools/mutate.sh"
  [ "$status" -eq 1 ]
  ! grep -qF 'Kein Fall-Lauf' <<<"$output"
  grep -qF "unbekannter '# verify:" <<<"$output"
  rm -rf "$fake"
}

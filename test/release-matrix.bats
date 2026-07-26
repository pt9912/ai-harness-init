#!/usr/bin/env bats
# release-matrix.bats — Waechter fuer die Release-Artefakte (slice-048, LH-QA-04).
#
# Warum hier und nicht als Lauf: die Matrix real zu bauen kostet sechs
# Docker-Builds; der bats-Container traegt weder Docker noch make. Geprueft wird
# darum die KOPPLUNG — dieselbe Linie wie test/sources-pin.bats, das die zwei
# Baseline-Pins fail-closed aneinander bindet. Der reale Bau ist Sache des
# Release-Laufs und der Pre-completion-Messung, nicht dieses Gates.
#
# Die vier Zusagen, die hier haengen:
#   1. Die Plattform-Liste im Makefile deckt GENAU die Matrix des Lastenhefts.
#   2. Windows-Artefakte tragen .exe (sonst laesst sich das Binary dort nicht
#      ohne Umbenennen starten).
#   3. Die build-Stage nimmt eine Zielplattform ENTGEGEN ...
#   4. ... und der Default-Pfad (`make build`) reicht KEINE durch — nur so bleibt
#      das bestehende Artefakt byte-identisch, woran artifact/smoke/full-smoke
#      haengen.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  MK="$REPO/Makefile"
  DF="$REPO/Dockerfile"
  LH="$REPO/spec/lastenheft.md"
}

# Die Anforderung ist die Quelle, nicht eine zweite Liste im Test: Betriebssysteme
# und Architekturen werden aus der LH-QA-04-Anforderungszeile gelesen. Faellt dort
# eine Plattform weg oder kommt eine hinzu, ohne dass das Makefile mitzieht, ist
# das ein Befund — in beide Richtungen.
lh_platforms() {
  local zeile os_teil arch_teil os arch
  # Der Anforderungssatz laeuft ueber ZWEI Zeilen (Betriebssysteme, dann
  # Architekturen) — beide einsammeln und verbinden, sonst sucht die Arch-Pruefung
  # im halben Satz.
  zeile="$(grep -A4 'LH-QA-04 — Plattform-Matrix' "$LH" | tr '\n' ' ')"
  # Die beiden fett gesetzten Segmente TRAGEN die Mengen — sie werden gelesen, nicht
  # gegen eine feste Liste geprueft. Nur so greift die Kopplung in BEIDE Richtungen:
  # eine im Lastenheft ERGAENZTE Plattform faellt hier ebenso auf wie eine entfernte.
  # (Vorher stand hier eine feste Ausgabe-Liste; ein zusaetzliches „· freebsd" in der
  # Anforderung liess den Waechter gruen — Review F-4.)
  os_teil="$(printf '%s' "$zeile" | sed -n 's/.*Native Binaries für \*\*\([^*]*\)\*\*.*/\1/p')"
  # Zwischen den Segmenten stehen `×` und MEHRERE Leerzeichen (der Satz ist im
  # Lastenheft umbrochen) — das Muster muss variable Abstaende zulassen.
  arch_teil="$(printf '%s' "$zeile" | sed -n 's/.*Native Binaries für \*\*[^*]*\*\* *× *\*\*\([^*]*\)\*\*.*/\1/p')"
  [ -n "$os_teil" ] || return 1
  [ -n "$arch_teil" ] || return 1
  for os in $(printf '%s' "$os_teil" | sed 's/·/ /g'); do
    # macos heisst in der Toolchain darwin — die einzige Stelle, an der Anforderung
    # und Bau-Vokabular auseinandergehen.
    [ "$os" = "macos" ] && os=darwin
    for arch in $(printf '%s' "$arch_teil" | sed 's/·/ /g'); do
      printf '%s/%s\n' "$os" "$arch"
    done
  done
}

mk_platforms() {
  sed -n 's/^RELEASE_PLATFORMS ?= //p' "$MK" | tr ' ' '\n' | sed '/^$/d'
}

@test "release: die Plattform-Liste deckt GENAU die Matrix des Lastenhefts" {
  local erwartet ist
  erwartet="$(lh_platforms | sort)"
  [ -n "$erwartet" ]
  ist="$(mk_platforms | sort)"
  [ "$ist" = "$erwartet" ]
}

@test "release: die Matrix traegt sechs Kombinationen" {
  [ "$(mk_platforms | wc -l)" -eq 6 ]
}

# Ohne .exe waere das Windows-Artefakt dort nicht startbar, ohne dass es beim Bau
# auffiele — ein Fehler, der erst beim Anwender sichtbar wuerde.
@test "release: Windows-Artefakte tragen .exe" {
  grep -q 'ext=".exe"' "$MK"
  grep -q '\[ "\$\$os" = "windows" \]' "$MK"
  # Entscheidend ist, dass die Endung im ZIELNAMEN landet — die beiden Zeilen oben
  # setzen sie nur. Faellt `$$ext` aus der Kopier-Zeile, hiesse das Windows-Artefakt
  # wie die uebrigen und waere dort nicht ohne Umbenennen startbar, ohne dass ein
  # Waechter es merkte (Review F-2).
  grep -q 'ai-harness-init-\$\$os-\$\$arch\$\$ext' "$MK"
}

@test "release: die build-Stage nimmt eine Zielplattform entgegen" {
  grep -q '^ARG TARGET_OS' "$DF"
  grep -q '^ARG TARGET_ARCH' "$DF"
  grep -q 'GOOS=\${TARGET_OS} GOARCH=\${TARGET_ARCH}' "$DF"
}

# Der Kern der Byte-Identitaet: `make build` (und damit artifact, smoke,
# full-smoke) darf KEINE Zielplattform durchreichen. Leer gelassen baut die
# Toolchain fuer die Plattform des Build-Images — genau wie vor slice-048.
@test "release: der Default-Pfad reicht KEINE Zielplattform durch" {
  local rezept
  rezept="$(sed -n '/^build:/,/^$/p' "$MK")"
  [ -n "$rezept" ]
  # NICHT `! cmd` fuer eine Assertion, die nicht die letzte ist: `set -e` greift bei
  # einem mit `!` negierten Kommando NICHT, der Fehlschlag wird also verschluckt und
  # das Ergebnis haengt allein an der letzten Zeile. Real gemessen — Mutation 80 setzt
  # nur TARGET_OS ein und lief dadurch gruen durch. Explizites return statt Negation.
  if printf '%s' "$rezept" | grep -q 'TARGET_OS'; then
    echo "build-Recipe reicht TARGET_OS durch: $rezept" >&2
    return 1
  fi
  if printf '%s' "$rezept" | grep -q 'TARGET_ARCH'; then
    echo "build-Recipe reicht TARGET_ARCH durch: $rezept" >&2
    return 1
  fi
}

# DEST ist Pflicht: ohne Zielverzeichnis liefe das Recipe ins Leere bzw. schriebe
# an einen unbeabsichtigten Ort. Exit 2 = Aufruf-Fehler, wie beim bestehenden
# artifact-Target.
@test "release: DEST ist Pflicht (Exit 2 ohne)" {
  local rezept
  rezept="$(sed -n '/^release-artifacts:/,/^$/p' "$MK")"
  [ -n "$rezept" ]
  printf '%s' "$rezept" | grep -q 'test -n "\$(DEST)"'
  printf '%s' "$rezept" | grep -q 'exit 2'
}

# --- Start-Smoke (slice-048) -------------------------------------------------
# Der Plattform-Nachweis selbst braucht einen Waechter: er ist die einzige Zusage
# des Slice, die auf fremden Runnern laeuft und dort niemand liest.

@test "release: start-smoke akzeptiert eine echte Usage" {
  local dir
  dir="$(mktemp -d)"
  printf '#!/usr/bin/env bash\necho "ai-harness-init — bootstrappt"\necho "  add-lang <sprache>"\n' >"$dir/fake"
  chmod +x "$dir/fake"
  run bash "$REPO/harness/tools/start-smoke.sh" "$dir/fake"
  rm -rf "$dir"
  [ "$status" -eq 0 ]
}

# Der Kern: ein Binary, das irgendetwas ausgibt und mit 0 endet, darf NICHT als
# Nachweis durchgehen — sonst waere der Plattform-Smoke ein Gate ueber leerem
# Bereich (LH-QA-01). Rot-Gegenbeispiel: test/mutations 83.
@test "release: start-smoke FAELLT bei Exit 0 ohne Usage" {
  local dir
  dir="$(mktemp -d)"
  printf '#!/usr/bin/env bash\necho "nichts zur Sache"\n' >"$dir/fake"
  chmod +x "$dir/fake"
  run bash "$REPO/harness/tools/start-smoke.sh" "$dir/fake"
  rm -rf "$dir"
  [ "$status" -ne 0 ]
}

# F-3 (Runde 3): ohne erzwungene Pfad-Form macht der Aufruf einen PATH-Lookup — ein
# gleichnamiges Kommando im PATH wuerde geprueft, waehrend die uebergebene Datei nie
# laeuft. Der Test stellt genau das nach: eine LOKALE Datei ohne Slash, die faellt,
# und ein gleichnamiges, gruenes Kommando im PATH. Der Sensor muss die lokale Datei
# nehmen und rot werden. Rot-Gegenbeispiel: test/mutations 84.
@test "release: start-smoke nimmt die uebergebene Datei, nicht ein PATH-Kommando" {
  local dir pathdir
  dir="$(mktemp -d)"; pathdir="$(mktemp -d)"
  # Der Hochstapler im PATH: meldet eine tadellose Usage.
  printf '#!/usr/bin/env bash\necho "ai-harness-init"\necho "add-lang"\n' >"$pathdir/kandidat"
  # Die echte Datei am uebergebenen Ort: faellt.
  printf '#!/usr/bin/env bash\nexit 3\n' >"$dir/kandidat"
  chmod +x "$pathdir/kandidat" "$dir/kandidat"
  cd "$dir"
  PATH="$pathdir:$PATH" run bash "$REPO/harness/tools/start-smoke.sh" kandidat
  cd /
  rm -rf "$dir" "$pathdir"
  [ "$status" -ne 0 ]
  # NICHT 127: der Fehlschlag muss vom lokalen Kandidaten kommen (der mit 3 endet),
  # nicht von einer kaputten Test-Umgebung. Beim ersten Entwurf war genau das der
  # Fall — der Test war gruen aus dem falschen Grund.
  [ "$status" -ne 127 ]
}

# F-4 (Runde 3): die Zusage lautet ZWEI Marker. Eine Usage mit nur einem davon darf
# nicht durchgehen — sonst traegt die zweite Haelfte der Zusage keine Abdeckung.
@test "release: start-smoke FAELLT bei nur EINEM Marker" {
  local dir
  dir="$(mktemp -d)"
  printf '#!/usr/bin/env bash\necho "ai-harness-init — aber ohne das Kommando"\n' >"$dir/fake"
  chmod +x "$dir/fake"
  run bash "$REPO/harness/tools/start-smoke.sh" "$dir/fake"
  rm -rf "$dir"
  [ "$status" -ne 0 ]
}

# --- slice-051: artifact-copy legt DEST an --------------------------------------
#
# Anlass war ein NUTZER-BERICHT, kein Sensor: `make artifact DEST=./bin` schlug fehl,
# wenn `bin` fehlte. Kein Test konnte das fangen, weil die Logik inline im Recipe lag
# und das bats-Image weder `make` noch eine docker-CLI hat (gemessen). Als Skript ist
# sie pruefbar — der Stub unten braucht keinen Daemon.
#
# WICHTIG, damit der Test nicht sich selbst prueft: der Stub bildet den REALEN
# Fehlermodus ab. Sein `cp` schreibt mit `>` in den Zielpfad und faellt daher — wie
# `docker cp` — wenn das Verzeichnis fehlt. Der Test haengt also an der beobachtbaren
# WIRKUNG (Verzeichnis da, Datei da), nicht daran, dass der Stub aufgerufen wurde.
# Der Stub PROTOKOLLIERT seine Aufrufe (DOCKER_STUB_LOG). Das ist noetig, weil zwei
# Zusagen des Skripts sonst unbewacht blieben (Review F-1/INFO-1): dass der Container
# aufgeraeumt wird, und dass aus dem ERWARTETEN Quellpfad kopiert wird. Beides
# hinterlaesst im Zielverzeichnis keine Spur — ohne Protokoll waere es nicht messbar.
docker_stub() {
  printf '%s\n' \
    '#!/usr/bin/env bash' \
    'printf "%s\n" "$*" >> "${DOCKER_STUB_LOG:-/dev/null}"' \
    'case "$1" in' \
    '  create) echo "cid-fake" ;;' \
    '  cp)     printf "binaerinhalt\n" > "$3" ;;' \
    '  rm)     : ;;' \
    '  *)      exit 99 ;;' \
    'esac' >"$1/docker"
  chmod +x "$1/docker"
}

@test "release: artifact-copy legt ein FEHLENDES Zielverzeichnis an" {
  local dir pathdir
  dir="$(mktemp -d)"; pathdir="$(mktemp -d)"
  docker_stub "$pathdir"
  # Der Kern des Nutzer-Befunds: DEST existiert NICHT.
  [ ! -d "$dir/bin" ]
  PATH="$pathdir:$PATH" run bash "$REPO/harness/tools/artifact-copy.sh" bild "$dir/bin" ai-harness-init
  local ok_dir=1 ok_file=1
  [ -d "$dir/bin" ] || ok_dir=0
  [ -s "$dir/bin/ai-harness-init" ] || ok_file=0
  rm -rf "$dir" "$pathdir"
  [ "$status" -eq 0 ]
  [ "$ok_dir" -eq 1 ]
  [ "$ok_file" -eq 1 ]
}

@test "release: artifact-copy schreibt auch in ein BESTEHENDES Zielverzeichnis" {
  local dir pathdir
  dir="$(mktemp -d)"; pathdir="$(mktemp -d)"
  docker_stub "$pathdir"
  mkdir -p "$dir/bin"
  PATH="$pathdir:$PATH" run bash "$REPO/harness/tools/artifact-copy.sh" bild "$dir/bin" ai-harness-init-linux-amd64
  local ok_file=1
  [ -s "$dir/bin/ai-harness-init-linux-amd64" ] || ok_file=0
  rm -rf "$dir" "$pathdir"
  [ "$status" -eq 0 ]
  [ "$ok_file" -eq 1 ]
}

# Review F-2: der Name sagt "alle drei", die erste Fassung mass nur das FEHLENDE
# dritte. Ein auf `$name` reduzierter Guard waere gruen geblieben, waehrend ein
# leeres Image oder Ziel mit Exit 0 durchgelaufen waere. Jetzt wird jede der drei
# Positionen einzeln leer gesetzt.
@test "release: artifact-copy verlangt alle drei Argumente (Exit 2)" {
  run bash "$REPO/harness/tools/artifact-copy.sh" "" /tmp/egal datei
  [ "$status" -eq 2 ]
  run bash "$REPO/harness/tools/artifact-copy.sh" bild "" datei
  [ "$status" -eq 2 ]
  run bash "$REPO/harness/tools/artifact-copy.sh" bild /tmp/egal ""
  [ "$status" -eq 2 ]
  # und der weggelassene dritte Parameter (nicht nur der leere)
  run bash "$REPO/harness/tools/artifact-copy.sh" bild /tmp/egal
  [ "$status" -eq 2 ]
}

# Review F-1: die Zusage "der Container wird immer aufgeraeumt" stand nur als
# Kommentar im Skript — kein Test mass sie. Ohne den `trap` blieben alle uebrigen
# Waechter gruen, waehrend jeder Aufruf einen Container zurueckliesse.
@test "release: artifact-copy raeumt den Container auf" {
  local dir pathdir
  dir="$(mktemp -d)"; pathdir="$(mktemp -d)"
  docker_stub "$pathdir"
  DOCKER_STUB_LOG="$dir/aufrufe" PATH="$pathdir:$PATH" \
    run bash "$REPO/harness/tools/artifact-copy.sh" bild "$dir/bin" ai-harness-init
  local aufgeraeumt=0
  grep -q '^rm ' "$dir/aufrufe" && aufgeraeumt=1
  rm -rf "$dir" "$pathdir"
  [ "$status" -eq 0 ]
  [ "$aufgeraeumt" -eq 1 ]
}

# Review INFO-1: Image-Tag und Container-Quellpfad waren unbewacht — ein Tippfehler
# in `/out/ai-harness-init` haette alle Waechter gruen gelassen, weil die Zieldatei
# vom Stub trotzdem entsteht.
@test "release: artifact-copy nimmt das uebergebene Image und den erwarteten Quellpfad" {
  local dir pathdir
  dir="$(mktemp -d)"; pathdir="$(mktemp -d)"
  docker_stub "$pathdir"
  DOCKER_STUB_LOG="$dir/aufrufe" PATH="$pathdir:$PATH" \
    run bash "$REPO/harness/tools/artifact-copy.sh" mein-bild "$dir/bin" ziel
  local ok_img=0 ok_src=0
  grep -q '^create mein-bild ' "$dir/aufrufe" && ok_img=1
  grep -qF "cp cid-fake:/out/ai-harness-init $dir/bin/ziel" "$dir/aufrufe" && ok_src=1
  rm -rf "$dir" "$pathdir"
  [ "$status" -eq 0 ]
  [ "$ok_img" -eq 1 ]
  [ "$ok_src" -eq 1 ]
}

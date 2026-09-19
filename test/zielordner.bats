#!/usr/bin/env bats
# zielordner.bats — Deckung des Zielordner-Dispatch (LH-FA-01, Slice
# zielordner-richtet-das-werkzeug-auf-ein-ziel-repo).
#
# WAS DIESER SENSOR HAELT. Der Init-Dispatch loest sein Ziel aus dem Argument,
# nicht aus dem Arbeitsverzeichnis; ohne Argument bricht er laut (fail-closed),
# und die vier Unterkommandos bleiben, wo sie waren. Der Verhaltens-Teil dieser
# Zusage laeuft am PROCESS und steht in der Go-Stufe (test-go) —
# TestRun_OhneZielordnerBrichtLaut, TestRun_KeinGitRepoZielBrichtLaut,
# TestZielordner_AusDemArgument und TestUnfallVektor_OhneArgumentImRepoWurzel
# (der Unfall-Vektor am Prozess, mit gebautem Traeger gegen ein stehendes Git-Repo).
# DAS HIER ist die Deckungs-Haelfte: die Struktur, die das Verhalten traegt.
# Ein Verhalten, dessen Struktur still umgebaut wird (ein Getwd zurueck auf den
# Init-Fall-through, eine Sperre hinter dem Bootstrap), waere im bats-Image
# unpruefbar — dieser Sensor haelt die Struktur, damit sie nicht still wandert.
#
# WARUM DIE STRUKTUR HIER UND NICHT NUR IM GO-TEST. test/unterkommando-kopplung.bats
# haelt die NAMEN der Aufrufer an denselben switch; dieser Sensor haelt die
# AUFLOESUNG: der Init-Fall-through reicht dem Traeger kein Arbeitsverzeichnis
# mehr hin, und die drei Sperren (Leer-Argument, Mehrfach-Argument, Git-Repo)
# stehen VOR dem Bootstrap-Aufruf in run(). Beide Sensoren lesen dieselbe Datei
# und decken verschiedene Haelften.
#
# NETZLOS, laeuft in `make gates`. Docker-only (bats-Image).

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  MAIN="$REPO/cmd/ai-harness-init/main.go"
  TEST="$REPO/cmd/ai-harness-init/main_test.go"
  MUT="test/mutations/377-init-argumentlos-stiller-init.sh"
}

@test "Deckung: der Dispatch fuehrt genau die vier Unterkommandos und add-lang, keiner faellt aufs Zielordner-Verhalten" {
  # Die Marken am Zeilenanfang sind die Menge, die main() dispatcht
  # (test/unterkommando-kopplung.bats liest sie gegen die Aufrufer; dieser Fall
  # haelt sie gegen ERWARTUNG). add-lang steht im switch, weil nur sein Zweig das
  # Arbeitsverzeichnis aufloest — der Init-Fall-through darunter nimmt kein Ziel
  # mehr aus dem Arbeitsverzeichnis.
  run grep -cE '^[[:space:]]*case "[^"]*":' "$MAIN"
  [ "$status" -eq 0 ]
  [ "$output" = "5" ]
  for name in span-emit span-report archive-welle vendor-baseline add-lang; do
    run grep -cE "^$name\$" <<<"$(grep -oE '^[[:space:]]*case "[^"]*":' "$MAIN" | sed -E 's/^[[:space:]]*case "//; s/":$//')"
    [ "$output" = "1" ]
  done
}

@test "Deckung: der Init-Fall-through reicht dem Traeger kein Arbeitsverzeichnis — die Aufloesung steht nur im add-lang-Zweig" {
  # Genau EINE Getwd-AUFRUF-Zeile in main(), und sie sitzt hinter der
  # add-lang-Marke: der CWD-Zweig steht nur im add-lang-Fall. Der Fall-through
  # uebergibt "" als Ziel-Kanal — der Zielordner kommt aus dem Argument. Gezaehlt
  # werden AUFRUF-Zeilen, nicht Kommentare: der Kommentarblock ueber dem switch
  # nennt die Stelle ebenfalls.
  anzahl="$(sed -n '/^func main/,$p' "$MAIN" | grep -cE '^[[:space:]]+wd, err := os.Getwd\(\)$')"
  [ "$anzahl" = "1" ] || {
    echo "main() traegt $anzahl Getwd-Aufrufe, want genau 1 (add-lang-Zweig) —" >&2
    echo "eine zweite auf dem Init-Fall-through waere die abgeloeste CWD-Zentralitaet." >&2
    return 1
  }
  add_zeile="$(grep -n 'case "add-lang":' "$MAIN" | head -1 | cut -d: -f1)"
  getwd_zeile="$(grep -nE '^[[:space:]]+wd, err := os.Getwd\(\)$' "$MAIN" | head -1 | cut -d: -f1)"
  durchfall_zeile="$(grep -nE '^[[:space:]]os.Exit\(run\(os.Args\[1:\], "",' "$MAIN" | head -1 | cut -d: -f1)"
  [ -n "$add_zeile" ] && [ -n "$getwd_zeile" ] && [ -n "$durchfall_zeile" ] || {
    echo "Anker nicht gefunden: add-lang=$add_zeile Getwd=$getwd_zeile Fall-through=$durchfall_zeile" >&2
    return 1
  }
  [ "$add_zeile" -lt "$getwd_zeile" ] || {
    echo "der Getwd-Aufruf (Zeile $getwd_zeile) liegt nicht im add-lang-Zweig (Marke: $add_zeile)" >&2
    return 1
  }
  [ "$durchfall_zeile" -gt "$getwd_zeile" ] || {
    echo "der Init-Fall-through (Zeile $durchfall_zeile) liegt vor dem Getwd-Aufruf ($getwd_zeile)" >&2
    return 1
  }
}

@test "Deckung: die drei Sperren stehen VOR dem Bootstrap-Aufruf in run()" {
  # Reihenfolge ist die Zusage: Leer-Argument, Mehrfach-Argument und Git-Repo
  # brechen, BEVOR bootstrap() etwas schreibt. Das Verhalten darueber haelt die
  # Go-Stufe; dieser Fall haelt die ORDNUNG der Zweige gegen das Ziel.
  leer="$(grep -nE '^[[:space:]]if fs.NArg\(\) == 0 \{$' "$MAIN" | cut -d: -f1)"
  mehr="$(grep -nE '^[[:space:]]if fs.NArg\(\) > 1 \{$' "$MAIN" | cut -d: -f1)"
  repo="$(grep -nE '^[[:space:]]if !istGitRepo\(ziel\) \{$' "$MAIN" | cut -d: -f1)"
  boot="$(grep -nE '^[[:space:]]return bootstrap\(ziel,' "$MAIN" | cut -d: -f1)"
  for v in "$leer" "$mehr" "$repo" "$boot"; do
    [ -n "$v" ] || { echo "Sperren-Anker fehlt in run() (Leer-Match) — der Fall waere ein leeres Gruen" >&2; return 1; }
  done
  [ "$leer" -lt "$boot" ] && [ "$mehr" -lt "$boot" ] && [ "$repo" -lt "$boot" ] || {
    echo "Sperren ($leer/$mehr/$repo) stehen nicht vor dem Bootstrap ($boot) — der Lauf startet, bevor er prueft" >&2
    return 1
  }
}

@test "Deckung: die Usage traegt die Zielordner-Form und den fail-closed-Satz" {
  # Die oeffentliche Oberflaeche: die Verwendungs-Zeile nennt <zielordner> am
  # Ende (die Standard-flag-Paket-Form — Flags vor dem Positionsargument), und
  # die Usage erklaert den laut-Bruch ohne Argument. Dokumentations- und
  # Vertragsfaesser kopieren diese Zeile; ihr Wegfall faerbt hier rot.
  run grep -c '\[--lang <sprache>\] \[--arch <arch>\] \[--name <name>\] <zielordner>' "$MAIN"
  [ "$status" -eq 0 ] && [ "$output" = "1" ] || {
    echo "die Verwendungs-Zeile mit <zielordner> fehlt oder steht mehrfach in $MAIN" >&2
    return 1
  }
  run grep -c 'Ohne Argument bricht der Lauf LAUT mit dieser Usage ab' "$MAIN"
  [ "$status" -eq 0 ] && [ "$output" = "1" ] || {
    echo "der fail-closed-Satz der Usage fehlt in $MAIN" >&2
    return 1
  }
}

@test "Deckung: der Unfall-Vektor traegt seinen Prozess-Fall und seine rote Gegenprobe" {
  # Der Verhaltens-Zahn des Unfall-Vektors liegt am Prozess (Go-Stufe) und seine
  # geschwaechte Zusicherung (bricht, aber schreibt) deckt dieselbe
  # Verzeichnis-Pruefung von Hand. Diese Kopplung haelt beide Dateien aneinander:
  # faellt der Prozess-Fall weg oder die Mutation verliert ihren expect-Namen,
  # ist der Vektor ungemessen und der Lauf rot.
  run grep -c 'func TestUnfallVektor_OhneArgumentImRepoWurzel' "$TEST"
  [ "$status" -eq 0 ] && [ "$output" = "1" ] || {
    echo "der Prozess-Fall des Unfall-Vektors fehlt in main_test.go" >&2
    return 1
  }
  run grep -c '# expect: TestUnfallVektor_OhneArgumentImRepoWurzel' "$REPO/$MUT"
  [ "$status" -eq 0 ] && [ "$output" = "1" ] || {
    echo "die Mutation $MUT nennt den Prozess-Fall nicht mehr — der Vektor haette seinen Zahn verloren" >&2
    return 1
  }
}
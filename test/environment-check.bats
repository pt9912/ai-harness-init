#!/usr/bin/env bats
# environment-check.bats — Wächter am Tool-/Versions-Check der Umgebungs-Zusage
# (harness/tools/environment-check.sh, erster Check der Gates-Kante).
#
# HERMETISCH: das gepinnte bats-Image führt weder git noch go — die Probe-Werkzeuge
# stehen als Stubs in einem temporären Pfad und die Inventare als Fixtures unter
# $TMPDIR; `--inventar` und `--form-only` sind die Aufruf-Formen des Skripts.
# Am GELEBTEN Inventar misst der Form-Test (Test 1) — er liest Datei-Text, keine
# Probe. WAS HIER NICHT GEMESSEN WIRD (Grenze): dass die Fähigkeits-Proben am
# REAL inventar-gelebten Werkzeug greifen — `sed`-Join, `mktemp -p` und der
# sha256-Digest über den gepinnten Image-Bauch tragen die Probe-Form nicht; das
# reale Rot-vor/Gruen-nach an den 13 Inventar-Zeilen trägt `make gates` selbst
# (environment-check als erster Check; Belege: Skriptkopf "Protokoll der
# Break-Tests"). Der bash-Guard ist strukturell gemessen (Test 7): seine
# Unter-Version-Auslösung braucht ein älteres bash, das kein Test-Image trägt.
#
# NETZLOS, in `make gates` über `make test` -> `test-bats`.

setup() {
    REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
    SCRIPT="$REPO/harness/tools/environment-check.sh"
    INV="$REPO/harness/tools/environment-inventory.txt"
    [ -f "$SCRIPT" ]
}

fixture() {
    # fixture <zeilen...> — Inventar nach $TMPDIR schreiben, Pfad ausgeben.
    F="$(mktemp "${TMPDIR:-/tmp}/envchk-inv.XXXXXX")"
    : > "$F"
    local line
    for line in "$@"; do
        printf '%s\n' "$line" >> "$F"
    done
    printf '%s' "$F"
}

@test "environment-check: Inventar formt am gelebten Bestand" {
    zeilen="$(grep -cvE '^[[:blank:]]*(#|$)' "$INV")"
    echo "gelebte Inventar-Zeilen: [$zeilen] (Zusage: Form-Test zählt eben sie)"
    [ "$zeilen" -ge 10 ]
    run bash "$SCRIPT" --form-only
    [ "$status" -eq 0 ]
    [[ "$output" == *"— $zeilen Zeilen, "* ]]
}

@test "environment-check: exakte Abweichung färbt Umgebungs-Befund mit Werkzeug, Soll und Ist" {
    F="$(fixture 'go|exakt|pflicht|abgeleitet:1.27.3|k|g')"
    S="$(mktemp -d)"
    printf '#!/usr/bin/env bash\necho "go version go1.99.0 linux/amd64"\n' > "$S/go"
    chmod +x "$S/go"
    run env PATH="$S:$PATH" bash "$SCRIPT" --inventar "$F"
    echo "Ausgabe: [$output] (Zusage: exit 1, Zeile mit Werkzeug · Soll · Ist)"
    [ "$status" -eq 1 ]
    [[ "$output" == *"umgebung: go · Soll: 1.27.3 · Ist: 1.99.0"* ]]
    rm -rf "$F" "$S"
}

@test "environment-check: fehlendes Pflicht-Werkzeug färbt Ist fehlt" {
    F="$(fixture 'go|exakt|pflicht|abgeleitet:1.27.3|k|g')"
    S="$(mktemp -d)"
    run env PATH="$S:/usr/bin:/bin" bash "$SCRIPT" --inventar "$F"
    echo "Ausgabe: [$output] (Zusage: Ist fehlt)"
    [ "$status" -eq 1 ]
    [[ "$output" == *"umgebung: go · Soll: 1.27.3 · Ist: fehlt"* ]]
    rm -rf "$F" "$S"
}

@test "environment-check: Fähigkeits-Probe färbt bei abweichendem Digest" {
    F="$(fixture 'sha256sum|Faehigkeit|pflicht|manifest:probe:sha256-abc|k|g')"
    S="$(mktemp -d)"
    printf '#!/usr/bin/env bash\necho deadbeef\n' > "$S/sha256sum"
    chmod +x "$S/sha256sum"
    run env PATH="$S:$PATH" bash "$SCRIPT" --inventar "$F"
    echo "Ausgabe: [$output] (Zusage: Probe fehlgeschlagen nennt die Probe-ID)"
    [ "$status" -eq 1 ]
    [[ "$output" == *"umgebung: sha256sum · Soll: sha256-abc · Ist: probe fehlgeschlagen: sha256-abc"* ]]
    rm -rf "$F" "$S"
}

@test "environment-check: fehlendes optionales Werkzeug warnt, kein Rot" {
    F="$(fixture 'tar|Anwesenheit|optional|manifest:anwesend|k|g')"
    S="$(mktemp -d)"
    run env PATH="$S:/nonexistent" bash "$SCRIPT" --inventar "$F"
    echo "Ausgabe: [$output] (Zusage: Warnzeile, exit 0)"
    [ "$status" -eq 0 ]
    [[ "$output" == *"umgebung-warn: tar · Soll: anwesend · Ist: fehlt"* ]]
    [[ "$output" == *"grün"* ]]
    rm -rf "$F" "$S"
}

@test "environment-check: Inventar-Aufform färbt fail-closed" {
    run bash "$SCRIPT" --inventar /nonexistent-envchk-inventar
    echo "unlesbarer Pfad: [$output] (Zusage: exit 2)"
    [ "$status" -eq 2 ]
    [[ "$output" == *"AUFFORM"* ]]
    F="$(fixture 'go|Falsch|pflicht|abgeleitet:1.27.3|k|g')"
    run bash "$SCRIPT" --inventar "$F"
    echo "unbekannte Pruefform: [$output] (Zusage: exit 2)"
    [ "$status" -eq 2 ]
    [[ "$output" == *"AUFFORM"* ]]
    rm -f "$F"
}

@test "environment-check: der bash-Guard steht als erster Top-Level-Befehl" {
    guard="$(awk 'NR>1 && $0 !~ /^#/ && $0 !~ /^[[:blank:]]*$/ {print; exit}' "$SCRIPT")"
    echo "erster Top-Level-Befehl: [$guard]"
    [[ "$guard" == 'if ((BASH_VERSINFO[0] < 4)); then' ]]
}

@test "environment-check: glücklich — jedes Pflicht-Werkzeug trägt sein Soll (Fixtures mit Stubs)" {
    F="$(fixture 'go|exakt|pflicht|abgeleitet:1.27.3|k|g' 'bats|Anwesenheit|pflicht|manifest:anwesend|k|g')"
    S="$(mktemp -d)"
    printf '#!/usr/bin/env bash\necho "go version go1.27.3 linux/amd64"\n' > "$S/go"
    printf '#!/usr/bin/env bash\nexit 0\n' > "$S/bats"
    chmod +x "$S/go" "$S/bats"
    run env PATH="$S:$PATH" bash "$SCRIPT" --inventar "$F"
    echo "Ausgabe: [$output] (Zusage: grün 2/2)"
    [ "$status" -eq 0 ]
    [[ "$output" == *"grün — 2/2 Pflicht-Werkzeuge tragen ihr Soll."* ]]
    rm -rf "$F" "$S"
}

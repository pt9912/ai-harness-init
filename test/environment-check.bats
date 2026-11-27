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
    # Der END-PUNKT des Falls ist das Stub-Verzeichnis: die Erwartung ist
    # Abwesenheit und haengt nicht mehr am System-Tail (/usr/bin, /bin) — dort
    # trägt der Runner installiertes Werkzeug (apt-Zug, brew-Zug, GITHUB_PATH),
    # das der Fall sonst als Ist liest (gemessen am Runner: Ist: 1.27.0 statt
    # fehlt). Die Maschinerie des Skripts (Basis-Werkzeuge) liegt als Verweise
    # im Stub-Verzeichnis, und der PATH des Falls endet dort.
    for m in bash sed cut sha256sum grep head; do
        [ "$(command -v "$m" 2>/dev/null)" ] && ln -s "$(command -v "$m")" "$S/$m" || true
    done
    run env PATH="$S" bash "$SCRIPT" --inventar "$F"
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
    F="$(fixture 'nichtvorhanden-werkzeug|Anwesenheit|optional|manifest:anwesend|k|g')"
    S="$(mktemp -d)"
    # Ein Werkzeug, das kein Host und kein Image im PATH trägt — der
    # Warn-Fall "optional fehlt" hängt an der Abwesenheit, nicht am Namen;
    # das gelebte `tar` trägt der PATH des Hosts, der Warn-Fall bliebe dort
    # konstruiert. (Warn-Stellung am Namen ungeändert.)
    run env PATH="$S:/usr/bin:/bin" bash "$SCRIPT" --inventar "$F"
    echo "Ausgabe: [$output] (Zusage: Warnzeile, exit 0)"
    [ "$status" -eq 0 ]
    [[ "$output" == *"umgebung-warn: nichtvorhanden-werkzeug · Soll: anwesend · Ist: fehlt"* ]]
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

# Die d-check-Anwesenheit ist AUSDRÜCKLICH erweitert (slice-binraire-ziehen-ohne-
# docker): außer dem PATH trägt sie die fetched Ablage (probe_dcheck_ablage,
# make dcheck-fetch) — Inventar-Zeile d-check, Grund-Spalte. Die zwei Seiten der
# Erweiterung — Grün an der Ablage, Rot ohne PATH und ohne Ablage:
@test "environment-check: d-check trägt Anwesenheit auch an der fetched Ablage (PATH sieht es nicht)" {
    F="$(fixture 'd-check|Anwesenheit|pflicht|manifest:anwesend|k|g')"
    S="$(mktemp -d)"
    mkdir -p "$S/ablage"
    ABLAGE="$S/ablage/d-check"
    printf '#!/usr/bin/env sh\necho ok\n' > "$ABLAGE"
    chmod +x "$ABLAGE"
    run env PATH="$S:/usr/bin:/bin" DCHECK_CARRIER="$ABLAGE" bash "$SCRIPT" --inventar "$F"
    echo "Ausgabe: [$output] (Zusage: grün 1/1, kein Befund)"
    [ "$status" -eq 0 ]
    [[ "$output" == *"grün — 1/1 Pflicht-Werkzeuge tragen ihr Soll."* ]]
    rm -rf "$F" "$S"
}

@test "environment-check: ohne PATH und ohne Ablage bleibt d-check ein Befund (Ist fehlt)" {
    F="$(fixture 'd-check|Anwesenheit|pflicht|manifest:anwesend|k|g')"
    S="$(mktemp -d)"
    run env PATH="$S:/usr/bin:/bin" \
        DCHECK_CARRIER="$S/nirgends/d-check" bash "$SCRIPT" --inventar "$F"
    echo "Ausgabe: [$output] (Zusage: umgebung: d-check · Ist: fehlt, exit 1)"
    [ "$status" -eq 1 ]
    [[ "$output" == *"umgebung: d-check · Soll: anwesend · Ist: fehlt"* ]]
    rm -rf "$F" "$S"
}

# Die golangci-lint-Zeile (seit slice-labor-gates-host-rezepte) traegt exakt
# mit abgeleitetem Soll und die reine PATH-Probe wie bats/shellcheck/actionlint
# (die Besorgung des Werkzeugs traegt die Umgebung, der Check belegt sie).
@test "environment-check: golangci-lint trägt exakt-Soll an der PATH-Fassung" {
    F="$(fixture 'golangci-lint|exakt|pflicht|abgeleitet:2.15.0|k|g')"
    S="$(mktemp -d)"
    printf '#!/usr/bin/env sh\necho "golangci-lint has version 2.15.0 compiled with go1.27.4"\n' > "$S/golangci-lint"
    chmod +x "$S/golangci-lint"
    run env PATH="$S:/usr/bin:/bin" bash "$SCRIPT" --inventar "$F"
    echo "Ausgabe: [$output] (Zusage: grün 1/1, kein Befund)"
    [ "$status" -eq 0 ]
    [[ "$output" == *"grün — 1/1 Pflicht-Werkzeuge tragen ihr Soll."* ]]
    rm -rf "$F" "$S"
}

@test "environment-check: abweichende golangci-lint-Fassung am PATH färbt exakt-Befund" {
    F="$(fixture 'golangci-lint|exakt|pflicht|abgeleitet:2.15.0|k|g')"
    S="$(mktemp -d)"
    printf '#!/usr/bin/env sh\necho "golangci-lint has version 9.99.0 compiled with go1.27.4"\n' > "$S/golangci-lint"
    chmod +x "$S/golangci-lint"
    run env PATH="$S:/usr/bin:/bin" bash "$SCRIPT" --inventar "$F"
    echo "Ausgabe: [$output] (Zusage: umgebung: golangci-lint · Soll · Ist)"
    [ "$status" -eq 1 ]
    [[ "$output" == *"umgebung: golangci-lint · Soll: 2.15.0 · Ist: 9.99.0"* ]]
    rm -rf "$F" "$S"
}

@test "environment-check: ohne PATH-Fassung bleibt golangci-lint ein Befund (Ist fehlt)" {
    F="$(fixture 'golangci-lint|exakt|pflicht|abgeleitet:2.15.0|k|g')"
    S="$(mktemp -d)"
    run env PATH="$S:/usr/bin:/bin" bash "$SCRIPT" --inventar "$F"
    echo "Ausgabe: [$output] (Zusage: umgebung: golangci-lint · Ist: fehlt, exit 1)"
    [ "$status" -eq 1 ]
    [[ "$output" == *"umgebung: golangci-lint · Soll: 2.15.0 · Ist: fehlt"* ]]
    rm -rf "$F" "$S"
}

#!/usr/bin/env bats
# rezept-host.bats — Wächter an den Rezept-Formen der docker-losen Gates-Kante
# (slice-labor-gates-host-rezepte, ADR-0109): die sechs Gate-Rezepte fahren am
# Host, die gepinnten Image-Fassungen bleiben opt-in (*-image) und ungestrichen.
#
# HERMETISCH: die Formen werden über `make -n` gelesen (Trockenlauf — zeigt die
# aufgelösten Rezept-Zeilen, Variablen expandiert) und gegen die Text-Form der
# Makefile-Datei gehalten; kein Docker, kein Netz, kein voller Gate-Lauf im Test.
#
# WAS HIER NICHT GEMESSEN WIRD — die Grenze des Form-Wächters:
#   1. Das URTEIL des Laufs trägt der Gate-Lauf selbst (`make gates`); ein
#      `make -n` zeigt die Zeile, sie läuft nicht.
#   2. Die tool-generierte Fassung `docs-check` (d-check.mk, MR-010) bleibt
#      byte-genau — hier gilt: kein zweiter Flags-Text im Makefile und keine
#      zweite Pin-Definition; das Erzeugungs-Urteil misst das Werkzeug.
#   3. Ein fehlendes/abweichendes Werkzeug bricht NICHT hier, sondern am
#      Umgebungs-Befund: test/environment-check.bats hält die Negative
#      (Ist fehlt, exakte Abweichung je Weg — go und golangci-lint); die
#      Rezepte unten messen darum auch die Abwesenheit der Pin-Nutzung.
#
# NETZLOS, in `make gates` über `make test` -> `test-bats`.

setup() {
    REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
}

@test "rezept: test-bats ruft bats am Host mit BATS_TARGET" {
    # BATS_TARGET EXPLIZIT setzen: der Lauf dieser Tests geschieht selbst unter
    # `make test-bats`, das die Variable als Kommandozeilen-Variable exportiert —
    # ein Aufruf ohne Setzung erbe das enge Ziel des Wächter-Laufs.
    run make -C "$REPO" -n test-bats BATS_TARGET=test/
    [ "$status" -eq 0 ]
    [[ "$output" == *"bats \"test/\""* ]]
    run make -C "$REPO" -n test-bats BATS_TARGET=test/xyz.bats
    [[ "$output" == *"bats \"test/xyz.bats\""* ]]
}

@test "rezept: test-bats-image ruft dasselbe Ziel im gepinnten Image" {
    run make -C "$REPO" -n test-bats-image BATS_TARGET=test/
    [ "$status" -eq 0 ]
    [[ "$output" == *"docker run --rm --network none"* ]]
    [[ "$output" == *"bats/bats@sha256:"* ]]
    [[ "$output" == *"\"test/\""* ]]
    run make -C "$REPO" -n test-bats-image BATS_TARGET=test/xyz.bats
    [[ "$output" == *"\"test/xyz.bats\""* ]]
}

@test "rezept: test-go läuft am Host und schreibt keine zweite Pin-Stelle" {
    run make -C "$REPO" -n test-go
    [ "$status" -eq 0 ]
    [[ "$output" == *"go test -count=1 ./..."* ]]
    [[ "$output" != *"GO_VERSION"* ]]  # Pin trägt der Inventar-Check (abgeleitet), nicht das Rezept
}

@test "rezept: test-go-image baut die gepinnte test-Stufe und fährt denselben -count=1-Lauf" {
    go_pin="$(grep -E '^GO_VERSION \?= ' "$REPO/Makefile" | sed 's/GO_VERSION ?= //')"
    run make -C "$REPO" -n test-go-image
    [ "$status" -eq 0 ]
    [[ "$output" == *"--build-arg GO_VERSION=$go_pin"* ]]
    [[ "$output" == *"go test -count=1 ./..."* ]]
}

@test "rezept: shell-lint hält dieselbe Pfadliste wie der Image-Weg und schaltet bats-lint auf Host" {
    hostliste="$(sed -n '/^shell-lint:/,/^[[:space:]]*BATS_HOST/p' "$REPO/Makefile")"
    bildliste="$(sed -n '/^shell-lint-image:/,/^[[:space:]]*BATS_IMAGE/p' "$REPO/Makefile")"
    [ -n "$hostliste" ] && [ -n "$bildliste" ]
    for pfad in '.claude/hooks/*.sh' 'harness/tools/*.sh' 'internal/emit/templates/*.sh' 'internal/emit/templates/enforce/*.sh' 'test/mutations/*.sh' '.githooks/commit-msg' '.githooks/pre-commit'; do
        [[ "$hostliste" == *"$pfad"* ]]
        [[ "$bildliste" == *"$pfad"* ]]
    done
    [[ "$hostliste" == *"BATS_HOST=1 bash harness/tools/bats-lint.sh"* ]]
    [[ "$bildliste" == *"BATS_IMAGE="*"bash harness/tools/bats-lint.sh"* ]]
}

@test "shell-lint Host-Weg: bats-preprocess erhaelt das BATS_ROOT/BATS_LIBDIR-Paar" {
    # bats-preprocess sourced common.bash relativ zu $BATS_ROOT/$BATS_LIBDIR; ohne
    # das Paar bricht der Aufruf an //bats-core/common.bash (rot gesehen am Host,
    # Fix slice-labor-gates-host-rezepte). Der Stub lebt im bats-Layout
    # libexec/bats-core/ und scheitert laut mit den erhaltenen Werten — der
    # abgeleitete Root (preprocess-Lage /../../) und lib muessen ankommen.
    # GRENZE: die Env-Ueberschreibung von BATS_ROOT/BATS_LIBDIR misst der Test
    # nicht; er faehrt den abgeleiteten Weg (BATS_ROOT/BATS_LIBDIR geleert).
    stamm="$(mktemp -d)"
    mkdir -p "$stamm/libexec/bats-core"
    printf '#!/usr/bin/env bash\necho "bats-lint: FEHLER — Paar <$BATS_ROOT> | <$BATS_LIBDIR>" >&2\nexit 1\n' > "$stamm/libexec/bats-core/bats-preprocess"
    chmod +x "$stamm/libexec/bats-core/bats-preprocess"
    run env -u BATS_ROOT -u BATS_LIBDIR BATS_HOST=1 BATS_HOST_PREPROCESS="$stamm/libexec/bats-core/bats-preprocess" bash "$REPO/harness/tools/bats-lint.sh"
    rm -rf "$stamm"
    [ "$status" -eq 2 ]
    [[ "$output" == *"Paar <$stamm> | <lib>"* ]]
}

@test "rezept: ci-lint ruft actionlint am Host, ci-lint-image im gepinnten Image" {
    run make -C "$REPO" -n ci-lint
    [ "$status" -eq 0 ]
    [[ "$output" == *"actionlint"* ]]
    [[ "$output" != *"docker"* ]]
    run make -C "$REPO" -n ci-lint-image
    [[ "$output" == *"docker run --rm"* ]]
    [[ "$output" == *"actionlint@sha256:"* ]]
}

@test "rezept: lint ruft das PATH-Binary ohne Ablage-Fallback" {
    run make -C "$REPO" -n lint
    [ "$status" -eq 0 ]
    [[ "$output" == *"golangci-lint run ./..."* ]]
    # Die Besorgung trägt die Umgebung, der Check belegt sie — das Rezept
    # schreibt keinen Ablage-Fallback und keine zweite Pin-Stelle.
    [[ "$output" != *".harness/state/bin/golangci-lint"* ]]
    [[ "$output" != *"GOLANGCI_LINT_CARRIER"* ]]
}

@test "rezept: lint-image baut die gepinnte lint-Stage ohne Cache-Filter" {
    pin="$(grep -E '^GOLANGCI_LINT_VERSION \?= ' "$REPO/Makefile" | sed 's/GOLANGCI_LINT_VERSION ?= //')"
    run make -C "$REPO" -n lint-image
    [ "$status" -eq 0 ]
    [[ "$output" == *"docker build --no-cache-filter lint"* ]]
    [[ "$output" == *"--build-arg GOLANGCI_LINT_VERSION=$pin"* ]]
}

@test "rezept: build kompiliert am Host in den gitignorierten Zustands-Bereich" {
    run make -C "$REPO" -n build
    [ "$status" -eq 0 ]
    [[ "$output" == *"CGO_ENABLED=0 go build -trimpath"* ]]
    [[ "$output" == *"-o .harness/state/bin/ai-harness-init.build"* ]]
    # TRAEGER_VERSION-Injektion: der Operand fehlt im leeren Default (byte-identisch)
    [[ "$output" == *'-ldflags="-s -w"'* ]]
    ldflags_zeile="$(sed -n '/^build:/,/^$/p' "$REPO/Makefile" | grep 'ldflags=')"
    [[ "$ldflags_zeile" == *'$(if $(TRAEGER_VERSION), -X main.fassung=$(TRAEGER_VERSION))'* ]]
    git -C "$REPO" check-ignore -q .harness/state/bin/x || { echo ".harness/state/bin ist nicht gitignored (MR-003)." >&2; return 1; }
}

@test "rezept: build-image baut die gepinnte build-Stage" {
    run make -C "$REPO" -n build-image
    [ "$status" -eq 0 ]
    [[ "$output" == *"docker build --build-arg GO_VERSION"* ]]
    [[ "$output" == *"--target build -t ai-harness-init:build ."* ]]
}

@test "rezept: docs-check-host ruft das fetched Binary ohne zweite Flags-Definition" {
    rezept_zeile="$(sed -n '/^docs-check-host:/,/^\$/p' "$REPO/Makefile" | sed -n 2p)"
    [[ "$rezept_zeile" == *'"$(DCHECK_CARRIER)"'* ]]
    [[ "$rezept_zeile" != *"--enable"* ]]
    [[ "$rezept_zeile" != *"--disable"* ]]
}

@test "rezept: docs-check bleibt die Fragment-Fassung (Image-Weg, d-check.mk unberührt)" {
    rezept="$(sed -n '/^docs-check:/,/^$/p' "$REPO/d-check.mk")"
    [[ "$rezept" == *"docker run --rm --network none"* ]]
    [[ "$rezept" == *'$(DCHECK_REF)'* ]]
}

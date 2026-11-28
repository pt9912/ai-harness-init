#!/usr/bin/env bats
# rezept-host.bats — Wächter an den Rezept-Formen der docker-losen Gates-Kante
# (slice-labor-gates-host-rezepte, ADR-0109): die sechs Gate-Rezepte fahren am
# Host, die gepinnten Image-Fassungen bleiben opt-in (*-image) und ungestrichen.
#
# HERMETISCH: die Formen werden gegen die Text-Form der Makefile-Datei gehalten
# (Rezept-Zeilen per sed, Pin-Zeilen per grep); kein Docker, kein Netz, kein
# voller Gate-Lauf, und kein `make`/`git` zur Laufzeit — der gepinnte
# bats-Image-Weg (`test-bats-image`, opt-in) trägt keines von beiden, und die
# Form-Lektüre ist der gemeinsame Träger beider Wege · seit
# slice-labor-gates-host-rezepte.
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
#   4. Die Make-Syntax (Zieltabelle parsen, Variablen expandieren) liest
#      dieser Form-Wächter nicht — er hält den Text der Datei; das
#      Expandierungs-Urteil trägt der Gate-Lauf selbst (`make gates`). Die
#      git-eigene Lesung der .gitignore (check-ignore, Präfix-/Ordner-Muster)
#      trägt `make span-check` (Ablageort); hier steht die Text-Form des
#      Eintrags.
#
# NETZLOS, in `make gates` über `make test` -> `test-bats`.

setup() {
    REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
}

# rezept_zeilen <ziel> — die Rezept-Zeilen des Ziels in der Text-Form, ohne
# die Target-Zeile mit Hilfetext; gelesen aus der Makefile-Datei (kein make).
rezept_zeilen() {
    sed -n "/^$1:/,/^\$/p" "$REPO/Makefile" | sed -n '2,$p'
}

@test "rezept: test-bats ruft bats am Host mit BATS_TARGET" {
    rezept="$(rezept_zeilen test-bats)"
    [[ "$rezept" == *'bats "$(BATS_TARGET)"'* ]]
}

@test "rezept: test-bats-image ruft dasselbe Ziel im gepinnten Image" {
    rezept="$(rezept_zeilen test-bats-image)"
    [[ "$rezept" == *"docker run --rm --network none"* ]]
    [[ "$rezept" == *'$(BATS_IMAGE)'* ]]
    [[ "$rezept" == *'"$(BATS_TARGET)"'* ]]
    grep -qE '^BATS_IMAGE \?= bats/bats@sha256:' "$REPO/Makefile"
}

@test "rezept: test-go läuft am Host und schreibt keine zweite Pin-Stelle" {
    rezept="$(rezept_zeilen test-go)"
    [[ "$rezept" == *"go test -count=1 ./..."* ]]
    [[ "$rezept" != *"GO_VERSION"* ]]  # Pin trägt der Inventar-Check (abgeleitet), nicht das Rezept
}

@test "rezept: test-go-image baut die gepinnte test-Stufe und fährt denselben -count=1-Lauf" {
    rezept="$(rezept_zeilen test-go-image)"
    [[ "$rezept" == *'--build-arg GO_VERSION=$(GO_VERSION)'* ]]
    [[ "$rezept" == *"go test -count=1 ./..."* ]]
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
    rezept_host="$(rezept_zeilen ci-lint)"
    [[ "$rezept_host" == *"actionlint"* ]]
    [[ "$rezept_host" != *"docker"* ]]
    rezept_image="$(rezept_zeilen ci-lint-image)"
    [[ "$rezept_image" == *"docker run --rm"* ]]
    [[ "$rezept_image" == *'$(ACTIONLINT_IMAGE)'* ]]
    grep -qE '^ACTIONLINT_IMAGE \?= .*actionlint@sha256:' "$REPO/Makefile"
}

@test "rezept: lint ruft das PATH-Binary ohne Ablage-Fallback" {
    rezept="$(rezept_zeilen lint)"
    [[ "$rezept" == *"golangci-lint run ./..."* ]]
    # Die Besorgung trägt die Umgebung, der Check belegt sie — das Rezept
    # schreibt keinen Ablage-Fallback und keine zweite Pin-Stelle.
    [[ "$rezept" != *".harness/state/bin/golangci-lint"* ]]
    [[ "$rezept" != *"GOLANGCI_LINT_CARRIER"* ]]
}

@test "rezept: lint-image baut die gepinnte lint-Stage ohne Cache-Filter" {
    rezept="$(rezept_zeilen lint-image)"
    [[ "$rezept" == *"docker build --no-cache-filter lint"* ]]
    [[ "$rezept" == *'--build-arg GOLANGCI_LINT_VERSION=$(GOLANGCI_LINT_VERSION)'* ]]
}

@test "rezept: build kompiliert am Host in den gitignorierten Zustands-Bereich" {
    rezept="$(rezept_zeilen build)"
    [[ "$rezept" == *"CGO_ENABLED=0 go build -trimpath"* ]]
    [[ "$rezept" == *"-o .harness/state/bin/ai-harness-init.build"* ]]
    # TRAEGER_VERSION-Injektion: der Operand fehlt im leeren Default (byte-identisch)
    ldflags_zeile="$(sed -n '/^build:/,/^$/p' "$REPO/Makefile" | grep 'ldflags=')"
    [[ "$ldflags_zeile" == *'$(if $(TRAEGER_VERSION), -X main.fassung=$(TRAEGER_VERSION))'* ]]
    # Der Zustands-Bereich bleibt git-gemessen ignoriert (MR-003; gitignore je
    # ADR-0111 Festlegung 1 in der Pflicht-Form): der Bau-Ablageort ist ignored,
    # die committete Stempel-Klasse dagegen nicht — die check-ignore-Lesung des
    # realen Ablageorts und die zwei Ausnahme-Zeilen tragen dieselbe Datei.
    git -C "$REPO" check-ignore -q .harness/state/bin/ai-harness-init || { echo "der Bau-Ablageort .harness/state/bin ist nicht ignored (MR-003); die git-eigene Lesung traegt make span-check." >&2; return 1; }
    grep -q '^!\.harness/state/gates-passed-\*\.key$' "$REPO/.gitignore" || { echo "die Ausnahme-Zeile der committeten je-Check-Keys fehlt (ADR-0111 Festlegung 1)." >&2; return 1; }
    grep -q '^!\.harness/state/full-smoke-passed\.key$' "$REPO/.gitignore" || { echo "die Ausnahme-Zeile des E2E-Stempels fehlt (ADR-0111 Festlegung 4)." >&2; return 1; }
}

@test "rezept: build-image baut die gepinnte build-Stage" {
    rezept="$(rezept_zeilen build-image)"
    [[ "$rezept" == *"docker build --build-arg GO_VERSION"* ]]
    [[ "$rezept" == *"--target build -t ai-harness-init:build ."* ]]
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

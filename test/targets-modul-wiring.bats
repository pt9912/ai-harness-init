#!/usr/bin/env bats
# targets-modul-wiring.bats — haelt das d-check-Modul `targets` (DC-FA-TGT-001) aktiv und seine
# `exempt-targets`-Liste exakt gegen die `.PHONY`-Deklarationen aus Makefile/d-check.mk: jeder
# dort genannte Name steht entweder als `make X`-Tabellenzeile in der `authority`-Datei
# (harness/README.md §Sensors) oder in `exempt-targets` — nie in beiden, nie in keinem. `docs-check` selbst
# haelt eine ANDERE Menge gegen dieselbe Autoritaets-Tabelle — jede Makefile-**Regel**
# (Target-Zeile), nicht nur die per `.PHONY` deklarierten; die zwei Mengen koennen in beide
# Richtungen auseinanderlaufen (ein `.PHONY`-Name ohne Regel vs. eine Regel ohne `.PHONY`-Eintrag).
# Heute sind sie gleich, beide 47:
#   grep -h '^\.PHONY:' Makefile d-check.mk | sed -E 's/^\.PHONY:[[:space:]]*//' | tr ' ' '\n' | grep -v '^$' | sort -u | wc -l
#   grep -hE '^[a-zA-Z][a-zA-Z0-9._-]*:' Makefile d-check.mk | sed -E 's/:.*//' | sort -u | wc -l
# aber eine Regel ohne `.PHONY`-Eintrag saehe dieser Waechter nicht, faerbte `docs-check` aber
# rot (Grund-Code gate-undocumented). Dieser Waechter prueft seine engere, `.PHONY`-gebundene
# Menge hermetisch, ohne Docker, und faellt darum auch dann, wenn ein neues `.PHONY`-Target
# committet wird, bevor der naechste `make docs-check`-Lauf es sieht.
#
# NETZLOS (nur Datei-Lesen), laeuft in `make gates` ueber `make test` -> `test-bats`.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  YML="$REPO/.d-check.yml"
  MAKEFILE="$REPO/Makefile"
  DCHECK_MK="$REPO/d-check.mk"
  AGENTS="$REPO/AGENTS.md"
  README="$REPO/harness/README.md"
}

# block gibt die Zeilen des TOP-LEVEL-targets:-Blocks aus (Schluessel in Spalte 0) — dieselbe
# Extraktions-Form wie in test/planning-modul-wiring.bats.
block() {
  awk '
    /^targets:[[:space:]]*$/ { inblk = 1; next }
    inblk && /^[^[:space:]]/   { inblk = 0 }
    inblk                      { print }
  ' "$YML"
}

field() {
  block | grep -E "^  $1:" | head -1 \
    | sed -E "s/^  $1:[[:space:]]*//"
}

phony_targets() {
  grep -h '^\.PHONY:' "$MAKEFILE" "$DCHECK_MK" | sed -E 's/^\.PHONY:[[:space:]]*//' \
    | tr ' ' '\n' | grep -v '^$' | sort -u
}

# Scope: nur der Abschnitt "## Sensors (Feedback-Gates)" bis zur naechsten "## "-Ueberschrift.
# Die eigentliche d-check-Autoritaetspruefung (gate-undocumented) scannt die GANZE Datei — sie
# kennt kein Heading-Scoping fuer das Modul `targets` (`d-check --print-config`). Diese engere,
# repo-lokale Pruefung haelt dagegen ein staerkeres Invariant: Sensors-Tabellenzeile und
# `exempt-targets` sind disjunkt. Ohne den Scope liefe sie gegen die eigene "Werkzeuge (kein
# Gate)"-Tabelle in derselben Datei, die dieselben Namen ABSICHTLICH mit Beschreibung fuehrt.
authority_table_targets() {
  awk '/^## Sensors \(Feedback-Gates\)/{p=1;next} p&&/^#/{exit} p' "$README" \
    | grep -E '^\|.*`make [a-z][a-z0-9-]*`.*\|$' | grep -oE '`make [a-z][a-z0-9-]*`' \
    | tr -d '`' | sed 's/^make //' | sort -u
}

exempt_targets() {
  block | grep -E '^  exempt-targets:[[:space:]]*$' >/dev/null
  block | awk '
    /^  exempt-targets:[[:space:]]*$/ { inlist = 1; next }
    inlist && /^    - /                { print; next }
    inlist                             { inlist = 0 }
  ' | sed -E 's/^[[:space:]]*-[[:space:]]*//' | sort -u
}

@test "targets ist in modules: aktiviert" {
  grep -E '^modules:.*\btargets\b' "$YML"
}

@test "targets: makefiles fuehrt Makefile UND d-check.mk" {
  [ "$(field makefiles)" = "[Makefile, d-check.mk]" ]
}

@test "targets: doc-tables fuehrt AGENTS.md UND harness/README.md" {
  [ "$(field doc-tables)" = "[AGENTS.md, harness/README.md]" ]
}

@test "targets: authority ist harness/README.md (Vollstaendigkeits-Quelle ist eine einzige Datei)" {
  [ "$(field authority)" = "harness/README.md" ]
}

@test "exempt-targets ist exakt — kein Glob-Zeichen in irgendeinem Namen" {
  ! exempt_targets | grep -qE '[*?\[]'
}

@test "jedes .PHONY-Target ohne Tabellenzeile im Sensors-Abschnitt steht genau einmal in exempt-targets" {
  local phony authdoc undocumented exempt
  phony="$(phony_targets)"
  authdoc="$(authority_table_targets)"
  undocumented="$(comm -23 <(echo "$phony") <(echo "$authdoc"))"
  exempt="$(exempt_targets)"
  diff <(echo "$undocumented") <(echo "$exempt")
}

@test "kein exempt-targets-Eintrag ist zugleich eine Sensors-Tabellenzeile" {
  local exempt authdoc
  exempt="$(exempt_targets)"
  authdoc="$(authority_table_targets)"
  local overlap
  overlap="$(comm -12 <(echo "$exempt") <(echo "$authdoc"))"
  [ -z "$overlap" ]
}

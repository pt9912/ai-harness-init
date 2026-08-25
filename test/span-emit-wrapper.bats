#!/usr/bin/env bats
# span-emit-wrapper.bats — Verhaltens-Tests des EMITTIERTEN Hook-Wrappers
# (internal/emit/templates/enforce/span-emit.sh, LH-FA-10 / ADR-0022 Festlegung 5).
# Laeuft Docker-only im gepinnten bats-Image (`make test`; ADR-0003, LH-QA-03).
#
# WARUM HIER UND NICHT IM GO-TEST: der Wrapper ist ein Shell-Skript, und seine tragende
# Eigenschaft ist sein LAUFVERHALTEN — fehlender Traeger, vorhandener Traeger, ein
# Traeger ohne Ausfuehrungsrecht. Ein Go-Test koennte davon nur den Text pruefen; das
# laufende Bild eines Go-Testlaufs ist das Test-Binary selbst und taugt nicht als
# Traeger-Attrappe.
#
# WAS DIESE DATEI NICHT LEISTET: sie sagt nichts darueber, ob der Traeger im Ziel einen
# Span mit voller Pflicht-Spalte schreibt — dafuer braucht es das echte Produkt-Binaer im
# gebootstrappten Repo, und das misst harness/tools/full-smoke.sh.
#
# Rot-Gegenbeispiel: test/mutations/161 nimmt dem Wrapper die Ausfuehrbarkeits-Pruefung.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  QUELLE="$REPO/internal/emit/templates/enforce/span-emit.sh"
  # Ein Ziel-Repo nachbauen, wie der Bootstrap es hinterlaesst: der Wrapper unter
  # .claude/hooks/, der Traeger-Ablageort unter .harness/state/bin/. Ausserhalb des
  # Repos, das der bats-Lauf read-only mountet.
  ZIEL="$(mktemp -d)"
  mkdir -p "$ZIEL/.claude/hooks" "$ZIEL/.harness/state/bin"
  cp "$QUELLE" "$ZIEL/.claude/hooks/span-emit.sh"
  WRAPPER="$ZIEL/.claude/hooks/span-emit.sh"
  BIN="$ZIEL/.harness/state/bin/ai-harness-init"
  PAYLOAD='{"hook_event_name":"PostToolUse","tool_name":"Bash","tool_use_id":"tu_bats","session_id":"s_bats","tool_input":{"command":"make gates"}}'
}

teardown() {
  rm -rf "$ZIEL"
}

# attrappe legt einen Traeger ab, der seine Argumente und sein stdin protokolliert —
# so wird sichtbar, WOMIT der Wrapper ihn ruft, nicht nur DASS er ihn ruft.
attrappe() {
  cat >"$BIN" <<'STUB'
#!/usr/bin/env bash
printf '%s\n' "$@" >"$(dirname "$0")/argv"
cat >"$(dirname "$0")/stdin"
STUB
  chmod 0755 "$BIN"
}

lauf() { printf '%s' "$PAYLOAD" | CLAUDE_PROJECT_DIR="$ZIEL" bash "$WRAPPER"; }

# ---------- fehlender Traeger: schweigen und mit 0 enden ----------

# Der Fall, fuer den es den Wrapper ueberhaupt gibt (ADR-0022 Festlegung 5b): ein
# frischer Klon des Adopter-Repos hat den gitignorierten Traeger nicht. Ein Hook, der
# hier meckert oder mit != 0 endet, blockiert den Tool-Call, den er beobachten soll.
@test "wrapper: fehlender Traeger -> Exit 0 und keine Ausgabe" {
  run lauf
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "wrapper: nicht ausfuehrbarer Traeger wird nicht gestartet -> Exit 0, keine Ausgabe" {
  attrappe
  chmod 0644 "$BIN"
  run lauf
  [ "$status" -eq 0 ]
  [ -z "$output" ]
  [ ! -e "$ZIEL/.harness/state/bin/argv" ]
}

# ---------- vorhandener Traeger: mit span-emit rufen, stdin durchreichen ----------

@test "wrapper: vorhandener Traeger wird mit dem Unterkommando span-emit gerufen" {
  attrappe
  run lauf
  [ "$status" -eq 0 ]
  [ "$(cat "$ZIEL/.harness/state/bin/argv")" = "span-emit" ]
}

@test "wrapper: die Hook-Payload erreicht den Traeger unveraendert auf stdin" {
  attrappe
  run lauf
  [ "$status" -eq 0 ]
  [ "$(cat "$ZIEL/.harness/state/bin/stdin")" = "$PAYLOAD" ]
}

# Fail-open am Traeger selbst: dessen Exit-Code darf den Wrapper nicht mitreissen. Die
# Klemme im Traeger bleibt davon unberuehrt — hier steht die zweite.
@test "wrapper: ein scheiternder Traeger endet trotzdem mit 0" {
  printf '%s\n' '#!/usr/bin/env bash' 'exit 3' >"$BIN"
  chmod 0755 "$BIN"
  run lauf
  [ "$status" -eq 0 ]
}

# ---------- Wurzel ohne CLAUDE_PROJECT_DIR ----------

# Die emittierte settings.json setzt die Variable; ein Werkzeug, das sie nicht setzt,
# soll den Traeger trotzdem finden. Die Wurzel liegt zwei Ebenen ueber dem Wrapper.
@test "wrapper: ohne CLAUDE_PROJECT_DIR wird die Wurzel aus dem eigenen Ort abgeleitet" {
  attrappe
  run env -u CLAUDE_PROJECT_DIR bash -c "printf '%s' '$PAYLOAD' | bash '$WRAPPER'"
  [ "$status" -eq 0 ]
  [ "$(cat "$ZIEL/.harness/state/bin/argv")" = "span-emit" ]
}

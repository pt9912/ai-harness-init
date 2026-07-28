#!/usr/bin/env bash
# span-emit — schreibt EINEN Span je Tool-Call in den gitignorierten Zustands-
# Bereich. Setzt ADR-0011 um; die Policy steht dort, hier steht nur die Mechanik.
#
# ZWEI EIGENSCHAFTEN SIND NICHT VERHANDELBAR (ADR-0011 Festlegung 6), und beide
# sind hier konstruktiv, nicht durch Sorgfalt, hergestellt:
#   1. stdout bleibt LEER — der gesamte Rumpf laeuft in einer Subshell, deren
#      stdout nach /dev/null geht. Auf stdout liegt bei Hooks der
#      ENTSCHEIDUNGS-Kanal; wer dort schreibt, entscheidet ueber Berechtigungen
#      mit, statt zu beobachten.
#   2. Der Exit-Code ist auf 0 geklemmt. Das ist kein Formalismus: `awk` endet
#      bei einem fatalen Fehler mit Exit 2 — genau dem Wert, mit dem ein Hook
#      blockiert. Ohne Klemme legte ein Skript-Fehler den Lauf stille, den die
#      Telemetrie nur beobachten soll.
# Beides ist bewacht: test/span-emit.bats (Klemme, stumme Ausgabe) und
# test/mutations/107 (Klemme entfernt -> Waechter rot).
#
# Fail-open heisst NICHT "niemand erfaehrt davon": jeder Span traegt eine je
# Strom monoton steigende Folgenummer, sodass der LESER eine Luecke sieht, ohne
# Zutun des Schreibers (ADR-0011 Folgepflicht 4). Nicht gedeckt bleibt der Fall,
# dass dieser Prozess VOR der Nummernvergabe stirbt — dann fehlt kein Eintrag,
# weil nie einer beansprucht wurde. Das steht so in der ADR und wird hier nicht
# schoener behauptet.
set -uo pipefail

emit_span() {
  cd "$(git rev-parse --show-toplevel 2>/dev/null)" || return 0

  payload="$(cat)"
  [ -n "$payload" ] || return 0

  fields="$(printf '%s' "$payload" | awk -f harness/tools/span-fields.awk)" || return 0
  [ -n "$fields" ] || return 0

  event=""; tool=""; useid=""; session=""; agent=""; agenttype=""
  transcript=""; permission=""; path=""; program=""; argc=""; err=""
  while IFS="$(printf '\t')" read -r key val; do
    case "$key" in
      hook_event_name) event="$val" ;;
      tool_name)       tool="$val" ;;
      tool_use_id)     useid="$val" ;;
      session_id)      session="$val" ;;
      agent_id)        agent="$val" ;;
      agent_type)      agenttype="$val" ;;
      transcript_path) transcript="$val" ;;
      permission_mode) permission="$val" ;;
      path)            path="$val" ;;
      program)         program="$val" ;;
      argc)            argc="$val" ;;
      error)           err="$val" ;;
    esac
  done <<EOF
$fields
EOF

  # --- Korrelations-IDs, abgeleitet statt geraten (ADR-0011 Festlegung 1.4) ---
  # slice.id IST das Lifecycle-Verzeichnis (Modul 5). Kein Slice -> leeres Feld,
  # als leer erkennbar; mehrere -> alle, denn "der eine Slice" waere geraten.
  slices=""; reqs=""
  slice_files=()
  for f in docs/plan/planning/in-progress/slice-*.md; do
    [ -e "$f" ] || continue
    b="${f##*/}"; b="${b%.md}"
    slices="${slices:+$slices,}\"$b\""
    slice_files+=("$f")
  done
  # requirement.id aus der Bezug-Zeile derselben Slices — bis zu vier je Slice,
  # also eine Liste, kein Wert.
  if [ ${#slice_files[@]} -gt 0 ]; then
    while IFS= read -r r; do
      [ -n "$r" ] || continue
      reqs="${reqs:+$reqs,}\"$r\""
    done < <(grep -hoE 'LH-[A-Z]{2}-[0-9]{2}' "${slice_files[@]}" 2>/dev/null | sort -u)
  fi

  # --- Strom = (Sitzung, Agent), Ablage gitignored (ADR-0011 Festlegung 3) ----
  stream="${session:-nosession}"
  [ -n "$agent" ] && stream="$stream-$agent"
  stream="$(printf '%s' "$stream" | tr -c 'A-Za-z0-9._-' '_')"
  # Der Ablageort ist der gitignorierte Zustands-Bereich (ADR-0011 Festlegung 3).
  # SPAN_DIR ueberschreibt ihn — ausschliesslich, damit die Waechter hermetisch
  # laufen koennen: `make test-bats` mountet das Repo READ-ONLY, ein Test gegen
  # den Produktionspfad koennte also gar nicht schreiben. Im Betrieb setzt ihn
  # niemand; die Kopplung an .gitignore bewacht test/span-emit.bats.
  dir="${SPAN_DIR:-.harness/state/spans}"
  mkdir -p "$dir" || return 0
  file="$dir/$stream.jsonl"

  # Aufraeumen beim ANLEGEN, und ausschliesslich der EIGENE Strom: "laeuft die
  # andere Sitzung noch?" ist nicht entscheidbar (ADR-0011 Festlegung 3), also
  # wird fremder Bestand nie angefasst.
  if [ ! -e "$file" ]; then
    : > "$file" || return 0
    chmod 600 "$file" 2>/dev/null || true
  fi

  # Folgenummer ZUERST vergeben: stirbt der Prozess danach, fehlt der Eintrag
  # und die Luecke ist sichtbar.
  seq=$(( $(wc -l < "$file" 2>/dev/null || echo 0) + 1 ))

  # --- Abgeleitete Argument-Werte (ADR-0011 Festlegung 2) --------------------
  # Der Fingerabdruck kommt aus dem DATEISYSTEM, nicht aus der Payload: so
  # passiert kein Byte fremden Inhalts diesen Emitter. Er beantwortet "hat sich
  # etwas geaendert", ohne den Inhalt zu tragen.
  size=""; hash=""
  if [ -n "$path" ] && [ -f "$path" ]; then
    size="$(wc -c < "$path" 2>/dev/null | tr -d ' ')"
    hash="$(sha256sum "$path" 2>/dev/null | cut -c1-16)"
  fi

  # --- Die Span-Zeile. Werte aus der Payload sind bereits JSON-escapt. -------
  {
    printf '{"seq":%d,"ts":"%s","event":"%s","tool":"%s","tool_use_id":"%s"' \
      "$seq" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$event" "$tool" "$useid"
    printf ',"session":"%s","agent":"%s","agent_type":"%s"' "$session" "$agent" "$agenttype"
    printf ',"slice":[%s],"requirement":[%s]' "$slices" "$reqs"
    printf ',"status":"%s"' "$([ -n "$err" ] && printf 'error' || printf 'ok')"
    [ -n "$permission" ] && printf ',"permission_mode":"%s"' "$permission"
    [ -n "$transcript" ] && printf ',"transcript":"%s"' "$transcript"
    [ -n "$path" ]       && printf ',"path":"%s"' "$path"
    [ -n "$size" ]       && printf ',"bytes":%s' "$size"
    [ -n "$hash" ]       && printf ',"sha256_16":"%s"' "$hash"
    [ -n "$program" ]    && printf ',"program":"%s"' "$program"
    [ -n "$argc" ]       && printf ',"argc":%s' "$argc"
    printf '}\n'
  } >> "$file" 2>/dev/null || return 0
}

# Die Klemme. Rumpf in einer Subshell, stdout verworfen, Exit-Code verworfen —
# was hier drinnen passiert, erreicht den Entscheidungs-Kanal nicht.
( emit_span ) >/dev/null 2>&1 || true
exit 0

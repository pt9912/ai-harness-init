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
  # requirement.id NUR aus dem Bezug-Block — nicht aus der ganzen Datei: ein
  # Slice erwaehnt im Fliesstext fremde Anforderungen (Praezedenzfaelle,
  # Abgrenzungen), und die sind nicht sein Bezug. Der Block reicht von der
  # `**Bezug:**`-Zeile bis zur naechsten Leerzeile.
  if [ ${#slice_files[@]} -gt 0 ]; then
    while IFS= read -r r; do
      [ -n "$r" ] || continue
      reqs="${reqs:+$reqs,}\"$r\""
    done < <(sed -n '/^\*\*Bezug:\*\*/,/^$/p' "${slice_files[@]}" |
             grep -oE 'LH-[A-Z]{2}-[0-9]{2}' | sort -u)
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
  # Modus VOR dem ersten Byte: `install -m` legt die Datei mit dem richtigen
  # Modus an, statt sie erst offen zu schaffen und dann nachzuziehen (das liesse
  # ein Fenster mit umask-Rechten offen).
  [ -e "$file" ] || install -m 600 /dev/null "$file"

  # --- Sperre: Nummernvergabe UND Anhaengen sind eine Einheit ----------------
  # `mkdir` ist die portable atomare Operation. Ohne sie vergaeben parallele
  # Emitter dieselbe Nummer und ihre Zeilen verschraenkten sich (gemessen im
  # Review: 6 doppelte seq, 8 kaputte Zeilen bei 25 Parallelen).
  lock="$dir/.$stream.lock"
  tries=0
  until mkdir "$lock" 2>/dev/null; do
    tries=$((tries + 1))
    # Fail-open: wer die Sperre nicht bekommt, verliert seinen Span — nicht der
    # Lauf seinen Fortgang. Diese Aufgabe ist unsichtbar (es wurde nie eine
    # Nummer beansprucht) — dieselbe benannte Grenze wie der Tod vor der Vergabe.
    [ "$tries" -lt 200 ] || return 0
  done

  # Die Nummer wird VERGEBEN, nicht aus dem Bestand abgeleitet. Der Unterschied
  # ist die ganze Zusage: `wc -l + 1` waere immer dicht 1..N, eine Luecke also
  # konstruktiv unmoeglich — der Leser saehe Vollstaendigkeit, wo Spans fehlen
  # (Review-Befund HIGH-3). Der Zaehler steht in einer eigenen Datei und wird
  # VOR dem Schreiben erhoeht: stirbt der Prozess danach, fehlt die Zeile und
  # die Luecke ist sichtbar.
  seqfile="$dir/$stream.seq"
  seq=$(( $(cat "$seqfile" 2>/dev/null || printf 0) + 1 ))
  printf '%s\n' "$seq" > "$seqfile"

  # --- Abgeleitete Argument-Werte (ADR-0011 Festlegung 2) --------------------
  # Der Fingerabdruck kommt aus dem DATEISYSTEM, nicht aus der Payload: so
  # passiert kein Byte fremden Inhalts diesen Emitter. Er beantwortet "hat sich
  # etwas geaendert", ohne den Inhalt zu tragen.
  # NUR fuer Schreib-Werkzeuge: die Tabelle in MR-018 gibt Lese-Werkzeugen den
  # Pfad und sonst nichts. Ein Fingerabdruck auf einem gelesenen Pfad waere ein
  # Bestaetigungs-Orakel ohne Incident-Frage (Review-Befund).
  size=""; hash=""
  case "$tool" in
    Write|Edit|MultiEdit|NotebookEdit)
      if [ -n "$path" ] && [ -f "$path" ]; then
        size="$(wc -c < "$path" | tr -d ' ')"
        hash="$(sha256sum "$path" | cut -c1-16)"
      fi
      ;;
  esac

  # --- Die Span-Zeile: EIN Puffer, EIN Schreibvorgang ------------------------
  # Elf einzelne printf in eine Datei zu schieben hiess, dass sich parallele
  # Emitter mitten in der Zeile verschraenken konnten (Review-Befund). Die Zeile
  # entsteht deshalb vollstaendig im Speicher und geht in einem Stueck raus —
  # innerhalb der Sperre, die auch die Nummer haelt.
  line='{"seq":'"$seq"',"ts":"'"$(date -u +%Y-%m-%dT%H:%M:%SZ)"'"'
  line="$line"',"event":"'"$event"'","tool":"'"$tool"'","tool_use_id":"'"$useid"'"'
  line="$line"',"session":"'"$session"'","agent":"'"$agent"'","agent_type":"'"$agenttype"'"'
  line="$line"',"slice":['"$slices"'],"requirement":['"$reqs"']'
  if [ -n "$err" ]; then line="$line"',"status":"error"'; else line="$line"',"status":"ok"'; fi
  [ -n "$permission" ] && line="$line"',"permission_mode":"'"$permission"'"'
  [ -n "$transcript" ] && line="$line"',"transcript":"'"$transcript"'"'
  [ -n "$path" ]       && line="$line"',"path":"'"$path"'"'
  [ -n "$size" ]       && line="$line"',"bytes":'"$size"
  [ -n "$hash" ]       && line="$line"',"sha256_16":"'"$hash"'"'
  [ -n "$program" ]    && line="$line"',"program":"'"$program"'"'
  [ -n "$argc" ]       && line="$line"',"argc":'"$argc"
  printf '%s}\n' "$line" >> "$file"

  rmdir "$lock"
}

# Die Klemme, und sie ist TRAGEND: `set -e` laesst jeden inneren Fehlschlag die
# Subshell verlassen, statt ihn an Ort und Stelle zu schlucken. Erst dadurch hat
# die Klemme ueberhaupt etwas zu fangen — und erst dadurch ist sie mutierbar
# (test/mutations/107). Ohne `set -e` waere `exit 0` unerreichbare Deko: der
# Rumpf kaeme immer mit 0 zurueck, und der Waechter koennte nie rot werden.
( set -e; emit_span ) >/dev/null 2>&1 || true
exit 0

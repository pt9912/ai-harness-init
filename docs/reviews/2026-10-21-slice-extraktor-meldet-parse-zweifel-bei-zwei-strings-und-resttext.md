# Review — slice-extraktor-meldet-parse-zweifel-bei-zwei-strings-und-resttext

Reviewer-Lauf, Diff `0181e351..7123b413`, Plan: `slice-extraktor-meldet-parse-zweifel-bei-zwei-strings-und-resttext` (wellenlos, in-progress). Quelle: Change Request d-check `2026-10-21-cr-ai-harness-init-guard-extraktor-parse-zweifel` (gelesen). Bezug: LH-FA-06, ADR-0004 Festlegung 2, AGENTS.md §3.6/§3.7/§3.9, MR-071.

Messort: BATS_IMAGE (busybox 1.36.1, `--network none`, Baum read-only); `make mutate`, `make mutate-greift`, `make test` liefen lokal auf macOS gegen Docker-Images. Nicht gemessen: gawk, mawk (Plan §6, benannt).

## Summary

Kein HIGH, kein MEDIUM. 1 LOW, 3 INFO.

## Findings

### F1 — LOW — Lauf-Zahn im Ziel für die Zusage „emittierter Guard blockt Parse-Zweifel" fehlt, Lücke steht nicht am Ort
- quelle: AGENTS.md §3.6 (Wirkung im Ziel), LH-FA-06
- pfad: test/guard.bats:78-123; harness/tools/full-smoke.sh:4701
- befund: Der Guard-Fall „zwei Strings -> block" fährt nur die lokale Fassung; der emittierte Guard löst seinen Extraktor über `tools/harness/…` auf. Die emittierte Fassung ist nur über den Vorlagen-Extraktor (Schleife + Mutation 781) gedeckt. `full-smoke` fährt zwar einen realen emittierten Guard-Lauf (Zeile 4701), aber keine Parse-Zweifel-Eingabe. Die Test-Kommentare in `guard.bats` nennen diese Grenze nicht.
- verifizierbar: ja (Fundstellen oben)
- klasse: Emittierte Zusage ohne Lauf-Zahn im Ziel, Lücke nur im Bericht benannt
- Einordnung: Der Guard-Code ist unverändert (nur Kommentar), die Code-Zeilen des Extraktors sind byte-gleich und der Guard ruft ihn unverändert per `awk -f`; das Risiko ist klein.

### F2 — INFO — Resttext hinter dem Wurzelobjekt und hinter Nicht-String-Werten bleibt Exit 0
- quelle: Plan §1 (bewusst ausgeschlossen)
- pfad: harness/tools/extract-command.awk (Ende von END)
- befund: `{"tool_input":{"command":"a"}}x` liefert `a`, Exit 0; `"k":1x` bleibt ungeprüft. Entspricht dem Plan-Ausschluss; `command` wird vor dem Rest gelesen. Keine Neubeobachtung nötig, sofern der Planner sie nicht ohnehin führt.
- verifizierbar: ja
- klasse: Scanner prüft Syntax nur nach String-Ende

### F3 — INFO — Falsch-Positiv-Wacht ohne eigene Mutation
- quelle: AGENTS.md §3.6
- pfad: test/guard.bats (Fall „wohlgeformtes JSON bleibt Exit 0"); test/mutations/780, 781
- befund: Beide Mutationen fahren nur die Richtung „Prüfung weg". Die Gegenrichtung (zu strenger Extraktor, etwa `afterstr = 0` entfernt, blockt jeden Befehl mit Folgefeld) hat keinen gelisteten Mutations-Fall; die Regressionsprobe und die Guard-Bestandsfälle färben sie nach Konstruktion, `make mutate` hält das aber nicht.
- verifizierbar: nein
- klasse: Wacht der Falsch-Positiv-Richtung ohne gelisteten Fall

### F4 — INFO — Mutationen 780/781: zweiter Test färbt mit (strukturell)
- quelle: Skill, „Mutations-Fall nennt einen Test, die Mutation färbt mehrere"
- pfad: test/mutations/780-extract-nach-stringende-lokal.sh, 781-extract-nach-stringende-emittiert.sh
- befund: Die gelöschte Zeile ist die einzige Prüfung; der Test „Zeichen außerhalb eines Strings" färbt unter beiden mit, unter 780 zusätzlich der Guard-Fall. Die Köpfe behaupten keine Exklusivität („Rot werden … die Fälle"), also kein Befund; gemeinsame Quell-Stelle. Die `t.Skip`-Gegenprobe entfällt (Bats).

## Eigenprobe (Schwerpunkte 1 und 5)

20 Eingaben x 3 Fassungen (lokal, Vorlage, Vorher `0181e351`) im BATS_IMAGE, Aufruf `awk -f <fassung>`:

| Eingabe | lokal / Vorlage | Vorher |
|---|---|---|
| `{"tool_input":{"command":"x"}}`, mit/ohne Zeilenende, Leerraum am Ende | `x`, Exit 0 | gleich |
| Escapes `a\"b\\`, `a\"` (Escape direkt vor dem schließenden `"`), `a\\` | korrekt dekodiert, Exit 0 | gleich |
| Folgefelder, Literale (`1`, `true`, `null`, `false`), verschachtelt Objekt/Array, Leerraum um `,` `:` `]` | `x`, Exit 0 | gleich |
| BOM vor `{`, CRLF an allen Tokens, Zeilenumbruch um Schlüssel-String und `:` | `x`, Exit 0 | gleich |
| String vor `}` und `]` | Exit 0 | gleich |
| zwei Strings ohne Trenner im Feldwert (CR 1) | Exit 3 | Exit 0, zweiter String |
| `"a" garbage }` (CR 2) | Exit 3 | Exit 0, `a` |
| `"a" 1`, `"a" "b":"c"` | Exit 3 | Exit 0 |
| `"a"` abgeschnitten | Exit 3 | Exit 3 |
| `b` im Befehl | Exit 3 | Exit 3 (Bestand, Absicht) |
| `{…}x` (Rest hinter dem Objekt) | Exit 0 | Exit 0 (Plan-Ausschluss, F2) |

Kein Falsch-Positiv gefunden. `afterstr` wird nur beim echten schließenden `"` gesetzt (der Escape-Zweig läuft vorher mit `continue`). Beide CR-Eingaben: vorher Exit 0, nachher Exit 3 (Rot-Beleg real).

## Weitere Prüfungen

- Code-Gleichheit: `diff <(grep -v '^[[:space:]]*#' …)` beider Fassungen leer. Kommentar-Unterschiede: nur Umlaut/ASCII und ADR-/LH-Verweis in der lokalen Fassung. `ß`/`ä` in der lokalen Fassung ist Bestand (Zeilen vor dem Diff trugen `ä`), die Vorlage ist ASCII — keine Abweichung.
- Kommentare (§3.7): Extraktor-Kopf nennt die Klassen im Indikativ, ohne Chronik oder Kennung. Beide Guard-Kopfkommentare nennen die zwei Klassen, deckungsgleich mit dem Extraktor; die Guard-Fassungen unterscheiden sich nur im Extraktor-Pfad (Bestand).
- `EMIT_EXTRACT`: `internal/emit/enforce.go:130` schreibt `tools/harness/extract-command.awk` aus `templates/enforce/extract-command.awk` (`Konvergent`); die Probe misst die reale Quelle, keine Kopie.
- docs/user: `git grep 'extract-command' docs/user` nennt nur die Baum-Zeile im Benutzerhandbuch, keine Aufzählung der Klassen; kein Nachzug nötig.
- Mutationen: `MUTATE_CASES='780-… 781-…' MUTATE_JOBS=1 make mutate` → `2 ok, 0 Befund(e)` (Teillauf, Beleg-Slot unberührt); `make mutate-greift` → `767 Fall/Faelle, 767 greifen, 0 Befund(e)`. `# files:` nennt je die gehebelte Datei, 781 mutiert die Vorlage; `# expect:` pinnt den Namen des ersten Bats-Falls; der sed-Anker trifft genau eine Zeile je Datei.
- `make test`: bats und alle Go-Pakete grün (auch `internal/emit`).
- Beleg-Ort: `make mutate-auswahl` meldet 5 Fälle unter Schwelle 8; der lokale Lauf ist zulässig und lief über das gepinnte Image (macOS-Host, kein Normbeleg nach §3.9). Ein CI-Branch ist nicht nötig; der CI-Lauf des Pushes (`make gates`) bleibt das Netz.

## Geprüft, ohne Befund

- Korrektheit der Regel gegen wohlgeformte JSON-Formen (Schwerpunkt 1): Probenmatrix oben.
- Code-Gleichheit und Kommentare beider Fassungen (2, 7).
- Bats-Fälle messen die Eigenschaft (Exit 3 über beide Fassungen, die gebrochene Fassung wird mit Pfad gemeldet), Regressionsprobe hält Falsch-Positive (3): außer F1/F3 kein Befund.
- Mutations-Fälle 780/781 und MR-071-Anker (4): außer F4 kein Befund.
- Rot-Beleg real (5), `make test` (6).
- AGENTS.md §3.2 und §3.9: kein Verstoß.

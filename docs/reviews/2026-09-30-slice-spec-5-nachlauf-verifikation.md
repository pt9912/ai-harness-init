# Verifikation — slice-spec-5-entscheidungen-nach-dem-umbau (A) und slice-spec-5-tabellen-sensor-und-zeiger-nach-dem-umbau (B)

Rolle Verifier. Stand `0a2d4b1e`, Vorstand `7bc65747`. Stichproben, wo der Review vollständig gelesen hat (Diff-Zeilen, Kommentar-Inhalte, Zeilen-Zuordnung je `SPEC`): gemessen sind Sensor-Rot, Bilanz, Kommandos der ADR, Anker. Nichts geschlossen, keine Häkchen.

## A — Entscheidungen (ADR-0076)
- **LP 1 Folge-ADR — bestätigt.** Fitness 1–3, 6, 7, 9 gemessen: `2`; Spec `0`/Datei `1`; `1`; `0`; `1`; `1` — alle im Soll. Zeile 10: `e84f1298`, `85e5ab5b`, `aef2dfc3`-Umfeld tragen „Rolle Architect"/Annahme. `make adr-immutable` (Range `3a5ccf54^..HEAD`, deckt 0074/0075/0076): `2180 Datei(en) geprüft, 0 Befund(e)`.
- **LP 2 Quellen — bestätigt.** Festlegung 6 (Architect schreibt `rollen-laeufe.md`); Festlegung 7 samt Regel in `plan-welle.md` mit Anker `· seit slice-spec-5-entscheidungen-nach-dem-umbau` (Z. 67 im Arbeitsbaum, Z. 77 in HEAD — Datei ist uncommittet in Arbeit des Planner-Laufs, Regel steht in beiden Ständen). `BEO-ALL/geplanter-slice-wird-nie-gearbeitet/state.md`: `Stand: verkörpert`, Zielort und Anker, Grenze benannt; der Anker steht im Ziel.
- **U14-Satz — bestätigt:** `docs/user/rollen-laeufe.md` Z. 37 („trägt keinen Wächter"), Z. 50 für die zweite Konvention; `START-KONVENTION` dort 1, in der Spec 0.
- **LP 3 Liste — bestätigt.** Ebenen-Tabelle Festlegung 3; Nachzug stimmt: elf Zellen mit Anker `LH-FA-10` (014/037/045/046/047/054/056/060/063/065/082 gemessen), 051–053 auf *Erfassungs-Umfang*, fünf Kennungen verlassen die Spec.
- **Fitness ohne Rot (5, 8, 11)** sind als `keiner` mit Lücke geführt; Rot nicht herstellbar, nicht nachgetragen.

## B — Sensor, Zeiger, Nachzug
- **LP 1 Sensor — bestätigt (Rot selbst gesehen).** Gefahren: `make mutate MUTATE_CASES="501-… 502-… 503-…"` → `3 ok, 0 Befund(e)`. Zusätzlich Ursache gelesen (bats im gepinnten Image, Scratchpad-Kopie): 501 → `not ok 1 … Tabellen mit SPEC-Zeilen: 5; mit Praezisiert …: 4; beides: 4`; 502 → `not ok 2 … mit leerer letzter Zelle: | \`SPEC-057\``; 503 → `not ok 3 … Zitat(e) ohne Fundstelle … unterscheidbar bleibt es am Pflichtfeld tool`; jeweils nur der gemeinte Test rot, Ausgangslage 4/4 ok. Der Baum blieb rein (`git status`: nur die `.claude`-Dateien der Parallel-Läufe).
- **LP 2 Zeiger — bestätigt.** Fixture-Probe von Hand (Kopie): Dateinamen-Fenster aus → Fixture-Test rot; Folgezeilen nicht verbinden → Fixture-Test rot, Bestandstest grün; Fundstellen-Prüfung ausgeschaltet → Fixture rot, Bestandstest grün. Der Bestand trägt kein echtes Zitat (Fall 503 selbst ist die einzige Fundstelle, wie im Kopf benannt); die Fixture trägt den Sensor unabhängig vom Bestand. Fall 131 zeigt auf `SPEC-022`/`SPEC-082`; Nicht-Kommentar-Diff über `internal test cmd harness/tools .claude/hooks` (ohne die neuen Sensoren): leer.
- **LP 3 Zeilen — bestätigt.** `SPEC-040` verlässt die Spec (Betriebsart: `rollen-laeufe.md` Z. 30); `SPEC-059/060/062–065` nennen Testnamen, die als `func` in `internal/span/span_test.go` stehen und den `# expect:` der Fälle 108/109/113/114/115/154 entsprechen.
- **LP 4 Nachzug — bestätigt.** `grep -E '\| Lücke \|$' spec/spezifikation.md | grep -oE '^\| \`SPEC-[0-9]+\`'` → leer; mit `SPEC-082` auf `Lücke` zurückgesetzt (Kopie) → `| \`SPEC-082\``. Kennungen 040/041/084/085/086 je 0 Vorkommen als Zeile (086 nur im Verlaufs-Text der §7-Zeile), keine neue `SPEC`-Kennung seit `7bc65747` (Neu-Menge 0). Kommentare: Guard-Kopf und `agent-guard.bats` tragen Grenzen und Fall 139/150; `mustContain` trägt die Grenze mit „Fälle 123 und 127" (`internal/span/response_test.go` Z. 61).
- **Wächter-Bilanz (`comm -3`, Namen `Test…`, `*.bats`, `test/mutations/N-*.sh`, „Fall(e) N", `make …`) — bestätigt.** Nur vorher: `agent-guard.bats`, Fall 139/150/32, „Fälle 123 und 127", `make test`, `make test-go`, `TestEnforce_EmitsAllMechanicFiles`, `TestEnforce_SettingsWiresBothHooks`; alle als Text im Repo auffindbar (Guard-Kopf, `enforce_test.go`, Fall 32, `response_test.go`). Nur nachher: die vier neuen Testnamen der Sensor-Zellen. Keine unbenannte Differenz.
- **Doku-Update:** `grep -rn 'spezifikation' docs/user | wc -l` → 3 (unverändert zum Vorstand-Stand).

## Gates
- `make gates` einmal am Ende: Exit 0, `docs-check` `2180 Datei(en) geprüft, 0 Befund(e)`, `comment-claims: 79 Datei(en) geprueft, 0 Befund(e)`; Wiederholung bestätigt Exit 0 (kein Rot durch die uncommitteten `.claude`-Dateien).

## Offene Punkte
- **Planner/Architect:** ADR-0076 Fitness-Zeile 4 nennt nach dem Nachzug `SPEC-051 SPEC-052 SPEC-053`; Ist und Plan-B sind leer (Lastenheft 0.23.0 trägt den Anker). Die Zeile der immutablen ADR ist damit überholt; Träger der Wahrheit ist der Plan B, nicht die ADR — Folge-ADR oder Nachtrag ist Entscheidung des Architects. Der erste Change Request entfällt, wenn 0.23.0 ihn deckt (Planner: Auftrag aus Liefer-Punkt 3 der Architect-Liste prüfen).
- **Grenze, benannt:** `make mutate` bindet für `test-bats` nur `not ok [0-9]+`, nicht den Testnamen; die Ursache der drei Fälle habe ich von Hand gelesen, der Treiber hält es nicht.
- **Zeiger-Sensor:** fasst nur Zitate hinter `„…“`/`"`, höchstens 250 Byte nach `spezifikation.md`; Bestand hat kein reales Zitat — Wächter ist bisher nur durch Fixture und Fall 503 belegt.
- `plan-welle.md` bleibt, bis der Planner-Lauf committet, ein beweglicher Beleg für LP 2b; nach dessen Commit Anker und die vier Auslöser erneut greppen.
- Closure, Lerneintrag, Register-Fortschreibung, Risiko-Ausgänge und Paarungen beider Slices: Planner.

# Review slice-071 — Umsetzungsplan §3a (Plan, kein Code)

**Rolle:** Reviewer · **Datum:** 2026-09-11 · **Gegenstand:** `git show 59f683d3`
(58 Zeilen, `docs/plan/planning/next/slice-071-bilanz-nennt-ihren-bestand.md` §3a).
**Baum:** clean, HEAD `59f683d3`. **Gemessen an:** `internal/report/report.go`,
`cmd/ai-harness-init/span_report.go`, `internal/report/report_test.go`,
`harness/tools/full-smoke.sh`, `internal/emit/templates/enforce/erfassung.mk`.
**Quellen:** DoD (1)(2)(3) §2, `AGENTS.md` §3.6, `LH-QA-01`, `MR-025`.

## Findings

### HIGH-1 — DoD (2) steht unter „keine Wahl", entzieht aber einem bestehenden Mutations-Fall seinen Verify-Pfad
`harness/tools/full-smoke.sh:658` sendet `"tool_name":"Bash"`; `report.go:147` lässt alles ≠ `Agent` fallen, also ist der Ziel-Bestand genau `Zeilen>0 ∧ AgentLaeufe==0` — die Lage, die DoD (2) neu abtrennt. Schritt (b) ab `full-smoke.sh:503` verlangt über ihr den Mechanik-Satz; `test/mutations/176-leser-grund-satz-weg.sh:4` führt `verify: full-smoke` als **einzigen** Pfad. `grep -c 'full-smoke' docs/plan/planning/next/slice-071-bilanz-nennt-ihren-bestand.md` → **0**.
Einschätzung: **bauen** — als dritte offene Wahl führen (wo der Mechanik-Satz künftig gemessen wird) und `harness/tools/full-smoke.sh` in die §3-Tabelle aufnehmen.
**klasse:** „Umsetzungsplan erklärt eine Angabe für alternativlos, deren Umsetzung einen fremden Wächter entzahnt"

### HIGH-2 — DoD (3) ist als „keine Wahl" geführt; die DoD schließt nur Orte aus, nicht Formulierungen
Der zitierte DoD-Satz („neben der Zahl, nicht in einer Fußnote und nicht im Kopf-Kommentar") entscheidet den **Ort**. Offen bleibt der **Wortlaut**, und dort liegt die Zusage: `report.go:124` füllt `sitzungen` nur aus geparsten Spans mit nicht-leerem `session`, unlesbare Zeilen springen bei `report.go:107` davor ab, und `report.go:328` druckt die Zeile bei `Sitzungen == 0` gar nicht. „Die Sitzungs-Ströme des Ablageorts" wäre damit selbst eine Angabe, die mehr behauptet als sie trägt — die Klasse, die dieser Slice behebt.
Einschätzung: **bauen** — als eigene Wahl mit zwei benannten Formulierungen und ihren Wahrheitsbedingungen.
**klasse:** „Ort einer Angabe entschieden, Bezugsmenge als mitentschieden ausgegeben"

### MEDIUM-1 — Wahl 1 stützt sich auf eine Aufrufer-Menge, die nicht gemessen ist
„jeder weitere Aufrufer von `report.Aggregiere`/`report.Schreibe` müsste dieselbe Existenzprüfung eigenständig nachbauen": `grep -rn 'report\.Aggregiere\|report\.Schreibe' --include='*.go' . | grep -v '_test.go' | cut -d: -f1 | sort -u | wc -l` → **1**. Das emittierte Ziel erreicht denselben Code über dasselbe Binär (`erfassung.mk:21`), nicht über einen zweiten Go-Aufrufer. Das Argument ist zudem symmetrisch: ein künftiger Aufrufer, der `Aggregiere` ohne `Schreibe` nutzt, schreibt seinen Text ohnehin selbst.
Einschätzung: **umformulieren** — die Menge nennen (`MR-025`) und das Argument auf den heutigen Bestand stellen.
**klasse:** „Aussage über eine Menge ohne Messung der Menge"

### MEDIUM-2 — Der Entscheidungssatz zu Wahl 1 nimmt den eigenen „Sieht nicht"-Punkt zurück
„`Zeilen` trägt exakt diese Art Unterscheidung schon": `Zeilen` entsteht als Nebenprodukt des ohnehin laufenden Lesens (`b.Zeilen++`, `report.go:105`) und berührt das Dateisystem nicht; die neue Lage braucht einen eigenen `os.Stat`. Gemeinsam ist der **Mechanismus** (Feld auf `Bilanz`, Zweig in `Schreibe`), nicht die **Art** — der eigene Aufzählungspunkt sagt das („eine Dateisystem-Prüfung zusätzlich zum Lesen der Spans"), der Entscheidungssatz überschreibt es.
Einschätzung: **umformulieren** — auf die Mechanismus-Gleichheit einschränken.
**klasse:** „Entscheidungssatz behauptet mehr als die Alternativen-Liste darüber"

### MEDIUM-3 — Wahl 1 trennt zwei von vier Kombinationen
§3 desselben Plans führt *feststellen* und *aussprechen* als zwei Achsen („Welche der beiden die Lage feststellt und welche sie ausspricht"); §3a legt sie zu einer binären Frage zusammen. Nicht genannt: Paket stellt fest (Feld oder Sentinel-Fehler), Aufrufer spricht aus. Der Sentinel-Zweig fällt bei `span_report.go:26-30` in den `return 1`-Pfad und berührt damit genau die Exit-Code-Setzung, die §3a drei Zeilen weiter als „kein Gegenstand" abräumt — er gehört benannt und verworfen, nicht übergangen.
Einschätzung: **umformulieren** — die vierte Kombination nennen und mit dem Exit-Code-Argument ausschließen.
**klasse:** „zwei Achsen als eine binäre Frage gestellt"

### MEDIUM-4 — Wahl 2 deckt nur die neue Meldung, nicht die Hälfte von DoD (1), die den Bestand betrifft
`report.go:304-308` trägt beide beanstandeten Sätze wörtlich — die Prämisse von Wahl 2 stimmt (s. u.). Offen und in keiner der beiden Listen: was an ihre Stelle tritt (ersatzlos · nur die Abgrenzung „KEINE Aussage ueber die Verbrauchs-Zaehler" behalten · engere Ursache). Daran hängt ein Literal: `full-smoke.sh:532-551` räumt mit `rm -rf` (`erfassung.mk:37`) das **Verzeichnis** weg und prüft über diesem Zustand `grep -qF "Kein Bestand:"` — dieselbe Zeichenkette nagelt `report_test.go:238`.
Einschätzung: **bauen** — als Wahl mit dem Literal als Nebenbedingung führen.
**klasse:** „Teil-Anforderung einer DoD ohne Eintrag in beiden Listen"

## REFUTED (Prüfpunkt 3 des Auftrags)

Wahl 2 trägt. `report.go:304-308` führt „ein frischer Klon hat es nicht" und „ein Aufraeum-Lauf nimmt es weg" beide über *das Programm*; und die Gegen-Ursache „unter diesem Pfad wurde nie geschrieben" ist nachweislich falsch, weil `erfassung.mk:37` (`rm -rf $(SPAN_DIR)`) den Ablageort regelmäßig entfernt. Die Entscheidung *ursachenlos* ist damit gemessen begründet, nicht nur plausibel.

## Verdikt

**Tragfähig mit Nachbesserung.** Zwei HIGH blockieren: die „keine Wahl"-Liste ist an zwei Stellen zu kurz, und beide fehlenden Wahlen berühren Wächter außerhalb von `make gates`. Die zwei entschiedenen Wahlen sind ohne Code prüfbar und eine davon (Wahl 2) gemessen richtig.

**Kategorie-Summary:** HIGH 2 · MEDIUM 4 · LOW 0 · INFO 0.

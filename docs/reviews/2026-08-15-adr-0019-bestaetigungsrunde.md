# ADR-0019 (Proposed) — Bestätigungsrunde

**Rolle:** Reviewer (Modul 10). **Datum:** 2026-08-15. **Lauf:** frischer Kontext, Subagent
`reviewer`.

**Gegenstand:** die vier Commits `60e4370` (Messung) · `83cf01d` (Senkung am Guard samt
Sensoren) · `f68cebd` (`ADR-0019` Proposed + `CO-002` Aktiv) · `6c3c9ff` (Nachzug
`spec/spezifikation.md` §5) — geprüft, **bevor** `AGENTS.md` §3.4 die ADR mit *Accepted*
einfriert.

**Eingangs-Kontext (die fünf Pflicht-Punkte plus Plan, Modul 10 §Eingangs-Kontext):**
Commit-Range oben · `LH-QA-01`, `LH-QA-03` (aus dem `Bezug:` der ADR) · aktive ADRs `0004`,
`0011`, `0012`, `0015`, `0016` · Hard Rules `AGENTS.md` §3.1–§3.8 · vorherige Findings am
gleichen Modul (`docs/reviews/2026-08-03-adr-0012-bestaetigungsrunde.md` und
`-runde-2.md`, `docs/reviews/2026-07-30-slice-060-v1-review.md`) · Plan-Bezug: kein Slice —
die Senkung lief außerhalb der Slice-Mechanik, die Plan-Seite ist `slice-074` und
`slice-071` als **betroffene** Artefakte.

**Selbst gefahren (Kommando und Ergebnis, nichts davon übernommen):**

| Kommando | Ergebnis |
|---|---|
| `cp -a` des Repos in eine isolierte Kopie außerhalb des Baums, dann `make test-bats` | 143 `ok`, 0 `not ok` |
| `bash test/mutations/150-agentguard-rolle-abgewiesen.sh` in isolierter Kopie, dann `make test-bats` | genau **ein** Fehlschlag: `not ok 16 guard: JEDER Typ in .claude/agents/ laeuft durch` |
| `bash test/mutations/139-agentguard-typ-failopen.sh` in isolierter Kopie, dann `make test-bats` | genau **ein** Fehlschlag: `not ok 15 guard: Agent-Aufruf ohne Subagent-Typ -> DENY (fail-closed)` |
| `make comment-claims` | `40 Datei(en) geprueft, 0 Befund(e)` |
| `grep` über `.harness/state/spans/*.jsonl` nach `"tool":"Agent"` + `2026-08-15` | vier Spans; die drei vor dem ADR-Lauf tragen von den neun Werten genau `model_version` |
| dieselben Dateien nach `SubagentStart` + `2026-08-15` | vier Ereignisse, Zeitstempel-gleich mit den vier `Agent`-Spans; `agent_type` = `architect`, `architect`, `general-purpose`, `reviewer` |
| `grep -in 'input_tokens\|totalTokens'` über `docs/user/claude-hooks-referenz.md` | genau zwei Treffer, beide in der `Agent`-`tool_response`-Tabelle (Z. 1571, 1574); **kein** Hook-Eingabeschema führt Zähler |

`make mutate` über alle 143 Fälle habe ich **nicht** gefahren — die zwei Fälle, die die
Fitness Function der ADR nennt, sind einzeln rot gesehen, das trägt die Frage.

**Nicht nachmessbar in diesem Lauf, und das gehört an den Anfang:** ein Subagent führt das
`Agent`-Werkzeug nicht (meine Werkzeugliste ist `Read`/`Write`/`Bash`). Das Eingabe-Schema von
`Agent` kann ich damit so wenig prüfen wie der Architect-Lauf. Alles unten zum Tool-Vertrag
prüft die **Beleg-Kette**, nicht den Vertrag.

---

## Findings

### HIGH-1 — `CO-002` hat keinen Folge-Slice, und genau daran hängt Festlegung 3

- **kategorie:** HIGH
- **quelle:** Regelwerk `v3.5.2`, `modul-07-carveouts.md` §Ziel-Form: Carveout (*„Sechs
  Pflicht-Header-Felder: … **Folge-Slice**. Fehlt der Folge-Slice, ist der Carveout de facto
  permanent — dann gehört er nicht in `carveouts/`, sondern über den Trichter unten in eine
  ADR"*) und §Regeln gegen typische Fehlannahmen (*„Deshalb braucht jeder temporäre Carveout
  einen Folge-Slice mit ID, der das Auflösen plant. Slice schlägt Memo"*); `ADR-0019`
  Festlegung 3
- **pfad:** `docs/plan/carveouts/CO-002-token-achse-je-rolle.md:25`
  (*„**Folge-Slice:** noch nicht geschnitten"*) · `docs/plan/adr/0019-agent-guard-prueft-die-aufrufform.md:160-173`
  (Modul-7-Frage 2) · `:287-292` (Folgepflicht 3)
- **befund:** Der Trichter-Ausgang *Carveout statt permanente Abweichung* wird in der ADR
  ausschließlich damit begründet, dass der dritte Trigger *„eine Messung [ist], die dieses
  Repo selbst fahren kann"* und dass *„hier der Folge-Slice einen Gegenstand und einen
  entscheidbaren Ausgang"* habe — im Kontrast zu `ADR-0012`, deren Carveout-Pfad genau daran
  scheiterte (*„Ein Slice mit dem Inhalt ‚abwarten' ist das Memo unter anderem Namen"*).
  Dieser Folge-Slice existiert nicht: `git grep -ln "updatedInput" -- docs/plan/planning/`
  liefert **null** Treffer, und `docs/plan/planning/open/` führt keinen Slice zu dieser
  Messung. Das tragende Element der Frage-2-Antwort ist damit im Moment der Annahme ein Memo,
  und `CO-002` steht in genau dem Zustand, den Modul 7 aus `carveouts/` ausschließt.
- **gegenbeispiel:** welle-10 schließt; `close-welle.md` Schritt 2 (Carveout-Audit) prüft
  *„aufgelöst · verlängert (mit Folge-Slice) · permanent akzeptiert"*. `CO-002` trägt keinen
  Folge-Slice, ist also nach Modul 7 in eine ADR zu überführen — während `ADR-0019`
  Festlegung 3 ab *Accepted* immutabel (§3.4) das Gegenteil festschreibt. Zwei aktive Normen
  widersprechen sich, und die Auflösung kostet eine Folge-ADR statt heute einen Slice-Schnitt.
- **verifizierbar:** ja, ohne Gate-Lauf —
  `git grep -ln "updatedInput" -- docs/plan/planning/` und `ls docs/plan/planning/{open,next,in-progress}/`.
  **Maschinell bewacht ist es nicht:** `.d-check.yml` führt `links, anchors, ids, matrix,
  codepaths, spans`, kein Modul liest die sechs Pflicht-Header-Felder eines Carveouts.
- **Muster, nicht Einzelfall:** `CO-001-bats-shell-lint.md:17` trägt seit 2026-07-21
  *„**Folge-Slice:** noch keiner angelegt — Trigger-gebunden"* und hat damit **sieben**
  Wellen-Audits überstanden (`welle-02`…`welle-08-results.md`). Zwei von zwei Carveouts dieses
  Repos haben keinen Folge-Slice. Modul 10 §Kontext-Eskalation: das ist ein
  Steering-Loop-Signal, kein Einzelbefund.

### MEDIUM-1 — „Zwei Enden, beide am Werkzeug gemessen": das zweite Ende ist keine Payload-Messung

- **kategorie:** MEDIUM
- **quelle:** `AGENTS.md` §3.6 (Zusage nur mit rot gesehenem Gegenbeispiel), `LH-QA-02`
  (Reproduzierbarkeit)
- **pfad:** `docs/plan/adr/0019-agent-guard-prueft-die-aufrufform.md:79` und `:86-88` ·
  `docs/reviews/2026-08-15-agent-guard-tool-vertrag.md:25-28`
- **befund:** Die ADR führt den tragenden Grund von Festlegung 1 als *„Zwei Enden, beide am
  Werkzeug gemessen"* und schließt mit *„Der Beleg für die Änderung selbst sind die zwei
  Payload-Messungen, nicht die Doku"*. Das erste Ende (2026-07-29) ist eine echte
  Payload-Messung — vier Aufrufe, Schlüsselnamen erfasst, dazu ein Rollen-Typ mit `true`
  abgelehnt und derselbe mit `false` durchgelaufen
  (`docs/reviews/2026-08-02-span-schema-messreihen.md` §1, §3). Das zweite Ende ist es nicht:
  die Probe vom 2026-08-15 fiel in den letzten Zweig der damaligen Guard-Fassung, und dieser
  Zweig feuerte für **jedes** `rib != "false"` — für `true` **wie** für `ABSENT`
  (`git show 60e4370:.claude/hooks/pretooluse-agent-guard.sh`, letzte drei Zeilen:
  `[ "$rib" = "false" ] && exit 0` / `emit_deny …`). Der Deny-Text kann Abwesenheit nicht von
  `true` unterscheiden; die Aussage *„Gefehlt hat allein der Schalter"* folgt nicht aus der
  Beobachtung, sondern aus der Schema-Selbstauskunft desselben Laufs. Die Rohpayload wurde an
  dem Tag nicht ausgeworfen.
- **gegenbeispiel:** eine Sonde, die `run_in_background` trotzdem in die Argumente setzt (per
  `updatedInput` oder aus einem Kontext, dessen Schema es führt), und die das Werkzeug
  **annimmt**. Dann war das Feld sendbar, die Bedingung war nicht unerfüllbar, sondern nur
  vom Modell nicht bedient — und der als *Vertragsänderung, nicht Abwägung* deklarierte
  tragende Grund von Festlegung 1 hätte eine andere Gestalt.
- **Was das nicht kippt:** die Entscheidung selbst. Auch unter der schwächeren Lesart kann
  kein realer Aufruf `false` tragen, die Bedingung wies also weiter alle sechs Rollen ab. Zu
  korrigieren ist die **Beleg-Etikettierung**, nicht der Ausgang. Die ADR benennt in
  §*„Die Grenze dieser Beleglage"* (`:103-107`) bereits die fehlende Sonde — sie zieht die
  Konsequenz nur nicht bis in den Satz *„beide am Werkzeug gemessen"* durch.
- **verifizierbar:** ja — `git show 60e4370:.claude/hooks/pretooluse-agent-guard.sh` gegen den
  zitierten Deny-Text in `docs/reviews/2026-08-15-agent-guard-tool-vertrag.md:21-23`.

### MEDIUM-2 — Der Auflösungs-Trigger von `CO-002` und sein Ableseort sind nicht dieselbe Bedingung

- **kategorie:** MEDIUM
- **quelle:** Regelwerk `v3.5.2`, `modul-07-carveouts.md` §Ziel-Form (*„Auflösungs-Trigger als
  beobachtbare, messbare Bedingung … eine Schwelle, die ein anderer Mensch ohne Rückfrage als
  erreicht beurteilen kann"*)
- **pfad:** `docs/plan/carveouts/CO-002-token-achse-je-rolle.md:63-65` ·
  `internal/report/report.go:136-140`
- **befund:** Der Trigger lautet *„ein `Agent`-Span trägt wieder `spawned_role` **und** die
  vier `usage`-Zähler — ablesbar an `make span-report`, dessen Abdeckungszeile dann eine Zahl
  größer 0 führt"*. Der genannte Ableseort misst das nicht: `report.go` zählt
  `b.MitZaehlern++` bereits, wenn **eines** von `InputTokens`/`OutputTokens` gesetzt ist
  (`if s.InputTokens == nil && s.OutputTokens == nil { return }`), und **ohne** jede Prüfung
  auf `SpawnedRole`. Ein Span ohne `spawned_role` wandert danach in den `Sammelposten` und
  wird anteilig nach Tool-Calls **geschätzt** verteilt (`report.go:150-157`).
- **gegenbeispiel:** ein `Agent`-Span kommt mit `usage`, aber leerem `agentType` zurück. Die
  Abdeckungszeile liest `1 von N`, der Trigger gilt als erreicht, der Carveout wird nach
  `done/` verschoben — und die **Token-Achse je Rolle**, also der Titel dieses Carveouts, hat
  weiterhin keinen direkten Eingang: die Zahlen stehen im Sammelposten und werden verteilt,
  nicht gemessen.
- **verifizierbar:** ja — `make span-report` gegen einen konstruierten Span-Bestand mit
  `usage` ohne `agentType`; die Abdeckungszeile steht dann > 0 bei leerer Rollen-Zuordnung.

### MEDIUM-3 — Die umgekehrte Reihenfolge ruht auf einer Prämisse, die nicht geprüft wurde, und auf einer Auftraggeber-Entscheidung ohne Fußabdruck

- **kategorie:** MEDIUM
- **quelle:** `AGENTS.md` §3.5; `MR-015` Setzung 2 (*„die Trennung ist am Commit ablesbar,
  nicht an der Prosa"*)
- **pfad:** `docs/plan/adr/0019-agent-guard-prueft-die-aufrufform.md:42-57` ·
  `harness/conventions.md:658-700`
- **befund:** Zwei Teile. **(a)** Die ADR stellt im Indikativ fest: *„Die Schleife war von
  innen nicht aufzuschneiden"*. Ein Weg, der die von §3.5 verlangte Reihenfolge erhalten
  hätte, ist weder benannt noch ausgeschlossen: eine **uncommittete, danach zurückgenommene**
  Änderung an `.claude/settings.json` (die Datei ist committet, der Arbeitsbaum aber frei),
  die den `"matcher": "Agent"`-Eintrag für genau einen Architect-Lauf abhängt — der Architect
  schreibt `ADR-0019`, danach landet die Senkung als Commit. Das ist keine Senkung der
  committeten Durchsetzung und damit kein §3.5-Fall. Die vendored Doku führt zudem
  `.claude/settings.local.json` als eigene Einstellungs-Ebene
  (`docs/user/claude-hooks-referenz.md:181, 605, 1778`); ob sie einen Projekt-Hook
  **abschalten** kann, habe ich **nicht** gemessen und behaupte es nicht — der
  `settings.json`-Weg braucht sie nicht. **(b)** Der Eintritt wird als *„Auftraggeber-Entscheidung
  der Klasse, die `MR-015` regelt"* geführt. `MR-015` regelt nach eigenem Geltungsbereich
  `spec/lastenheft.md` §7 und die Commit-Disziplin um diese Datei; seine Setzung 2 macht
  gerade die **Ablesbarkeit am Commit** zum Punkt. Hier gibt es keinen Fußabdruck: kein
  Lastenheft-Commit, kein CR-Vermerk, keine Zeile außerhalb der ADR selbst. Der einzige Beleg
  für die Legitimität der Reihenfolge steht in dem Dokument, dessen Legitimität zur Debatte
  steht.
- **gegenbeispiel:** ein späterer Lauf fragt *„wurde der Guard mit Zustimmung des
  Auftraggebers gesenkt oder von einem Agenten aus eigener Kraft?"*. `git log` und
  `git show --stat` über `83cf01d` beantworten es nicht; die Antwort ist zirkulär.
- **Was trägt:** der Präzedenz-**Test**, den die ADR aufstellt (*„Wer sich später auf diesen
  Fall beruft, hat zu zeigen, dass die Senkung die Rolle blockierte, die sie hätte entscheiden
  müssen"*), ist prüfbar und eng genug — er ist an `git show 60e4370` und dem Deny-Text
  belegbar. Die Präzedenz öffnet **nicht** „erst senken, dann begründen". Die Schwäche liegt
  in der Prämisse und im fehlenden Fußabdruck, nicht im Test.
- **verifizierbar:** teilweise — (a) durch einen Lauf, der den Hook uncommittet abhängt und
  einen Rollen-Agenten startet; (b) nicht, das ist der Befund.

### MEDIUM-4 — Der Nachzug ist halb: drei lebende Plan-Artefakte tragen weiter die alte Mechanik

- **kategorie:** MEDIUM
- **quelle:** `ADR-0019` Folgepflicht 1 (Nachzug nach **Eigenschaft**, nicht nach Zeile);
  `AGENTS.md` §3.7 (*„Ein Kommentar beschreibt, was da ist"* — hier auf Plan-Text übertragen
  als Klasse, nicht als Buchstabe)
- **pfad und Einordnung** (gemessen mit dem Kommando aus dem Auftrag,
  `git grep -ln "VORDERGRUND\|Vordergrund\|run_in_background" -- ':!docs/reviews' ':!docs/plan/planning/done' ':!.harness/baseline' ':!docs/user/claude-hooks-referenz.md'`
  → 14 Dateien):

  | Datei | Zeile | lebend oder Zeitdokument | Grund |
  |---|---|---|---|
  | `docs/plan/planning/open/slice-071-cache-zaehler-getrennt.md` | 67-68 | **lebend** | DoD (2) weist den Implementer an, in §5 zu schreiben, *„die Zähler sind für Vordergrund-Läufe erfasst und dürfen **nicht** als unerreichbar geführt werden"* — `6c3c9ff` hat Abweichung 1 gerade auf das Gegenteil gezogen |
  | `docs/plan/planning/welle-09-modul-15-konformitaet.md` | 176 | **lebend** (Welle liegt in `planning/`, nicht in `done/`) | begründet die Existenzberechtigung von slice-066/071 mit *„die Quelle ist **gemessen** statt vermutet — ein `Agent`-Aufruf im **Vordergrund** trägt … `usage`"* und schließt daraus *„Das bequeme Argument ‚kein Gegenstand' ist damit ausgeschlossen; offen ist die Zuordnung zur **Rolle**, nicht die Datenlage"*. Genau die Datenlage ist weg |
  | `docs/plan/planning/open/slice-074-agent-vor-aufruf-protokoll.md` | 152, 156, 173 | **lebend, und die schärfste Stelle** | `ADR-0019` Festlegung 2 (`:209-213`) übergibt die offene Rollen-Frage ausdrücklich *„dem Slice, der das Vor-Aufruf-Protokoll baut"*. Dessen Beleg-Tabelle führt Zeile 1 (*„`tool_input` trägt `subagent_type` und `run_in_background` schon **vor** dem Lauf — **gemessen**"*), Zeile 5 (*„gelesen + gemessen, und sie widersprechen sich"*) und der Feld-Entwurf `run_in_background` mit *„genau drei Werte: `true`, `false`, `ABSENT`"* |
  | `docs/plan/planning/open/slice-078-verdrahtung-hat-waechter.md` | 58 | Grenzfall, s. LOW-2 | dort mit Messdatum versehen |
  | `spec/spezifikation.md`, `.claude/hooks/…`, `harness/tools/extract-agent-call.awk`, `test/…`, `internal/span/…`, `docs/plan/adr/*`, `docs/plan/carveouts/*` | — | gezogen bzw. Gegenstand | — |

- **befund:** Der Nachzug erfasst das Spec-Stratum vollständig, die Plan-Ebene gar nicht. Zwei
  der drei Stellen sind nicht Prosa, sondern **Anweisungen**: slice-071 DoD (2) trüge, wenn
  ausgeführt, den gerade gezogenen Satz in §5 zurück; slice-074 ist das Artefakt, dem die ADR
  selbst Arbeit übergibt, und seine Beleg-Tabelle behauptet als *gemessen*, was seit dem
  2026-08-15 nicht mehr ankommt.
- **gegenbeispiel:** ein Implementer nimmt slice-071 auf und setzt DoD (2) wörtlich um. §5
  Abweichung 1 sagt danach *„die Zähler sind erfasst"*, `CO-002` sagt *„die Zähler stehen in
  keiner Payload mehr"*, und **nichts** wird rot: kein `.d-check.yml`-Modul liest Plan gegen
  Spec, `make gates` kennt keine Konsistenz-Prüfung dieser Achse.
- **verifizierbar:** nein, maschinell nicht — der Befund ist per Lesen belegt und per
  `git grep` reproduzierbar.

### MEDIUM-5 — Die Rollen-Achse ist als Positiv-Konsequenz breiter zugesagt, als der Sensor trägt

- **kategorie:** MEDIUM
- **quelle:** `AGENTS.md` §3.6 (*„Ein Test, dessen Name eine Eigenschaft behauptet, muss die
  Eigenschaft messen"*), `LH-QA-01`
- **pfad:** `docs/plan/adr/0019-agent-guard-prueft-die-aufrufform.md:302` (Fitness-Function-Zeile
  1: *„eine neue Rolle ist damit automatisch gedeckt"*) · `:206-208` (Festlegung 2) · `:257-258`
  (Positiv-Konsequenz) · `internal/span/emit.go:182-188`
- **befund:** Festlegung 2 entfernt die **einzige** Stelle im Repo, die Rollen-Zugehörigkeit
  aus `.claude/agents/` **ableitete**. Die Begründung — *„sie hatte genau diesen einen
  Abnehmer"* — trifft für die Betriebsart-Forderung zu, übergeht aber die zweite Funktion, die
  der gelöschte Kopf-Kommentar selbst nannte (*„keine vierte Kopie neben dem Verzeichnis,
  `spec/spezifikation.md` §5 und `roleFromAgentType` — und der Guard kann nicht gegen das
  Verzeichnis veralten, das er bewacht"*). Nach der Änderung ist `roleFromAgentType` eine
  **hart notierte** Sechser-Liste (`switch agentType { case "planner", "architect",
  "implementer", "reviewer", "verifier", "validator": … }`), und `grep -rn "claude/agents"
  --include=*.go .` liefert **null** Treffer: kein Go-Code, kein Test koppelt die Liste an das
  Verzeichnis. Die zitierte Fitness-Function-Zeile deckt, dass eine neue Rolle **durchläuft** —
  nicht, dass sie in die Rollen-Achse gelangt. Der Satz sagt nicht, welche der beiden
  Eigenschaften er meint.
- **gegenbeispiel:** `.claude/agents/auditor.md` wird angelegt und ein Subagent vom Typ
  `auditor` gestartet. bats-Fall 16 bleibt grün (er prüft PASS), `make gates` bleibt grün,
  `make mutate` bleibt grün — und **jeder** Span dieses Laufs trägt `agent_role: ""`. Die
  Positiv-Konsequenz *„die Rollen-Achse der Telemetrie trägt weiter"* ist für diese Rolle
  falsch, ohne dass irgendetwas rot wird.
- **verifizierbar:** ja — eine siebte Datei in `.claude/agents/` anlegen und `make test`
  fahren; er bleibt grün.

### MEDIUM-6 — `CO-002` §Geltungs-Konfiguration ist am Tag seiner Anlage schon falsch

- **kategorie:** MEDIUM
- **quelle:** `ADR-0019` Festlegung 3 (*„Geltungsbereich, Trigger und die zwei Ausgänge stehen
  dort, nicht hier — ein zweiter Ort driftet"*); Modul 7 §Ziel-Form (Zeiger-Pflicht)
- **pfad:** `docs/plan/carveouts/CO-002-token-achse-je-rolle.md:85-92`
- **befund:** Die Tabelle führt beide Stellen mit *„ein `CO-002`-Zeiger fehlt"* bzw.
  *„Nachzug samt `CO-002`-Zeiger steht aus"*. `6c3c9ff` hat beide Zeiger fünf Minuten später
  gesetzt: `.claude/hooks/pretooluse-agent-guard.sh:13-15` (*„Gefuehrt wird dieser Ausfall als
  docs/plan/carveouts/CO-002-token-achse-je-rolle.md"*) und `spec/spezifikation.md` an sechs
  Stellen (§5 Punkt 5, START-KONVENTION Bedingung 2, Wächter-Absatz, Abweichung 1,
  Abweichung 5 Prüfschritt 2). Der Carveout ist ein **aktives** Artefakt, das die ADR
  ausdrücklich zum einzigen Ort für Geltungsbereich und Trigger erklärt — und er ist die
  erste Stelle, die driftet.
- **gegenbeispiel:** das Welle-Audit liest `CO-002` §Geltungs-Konfiguration und legt die zwei
  offenen Folgepflichten als Arbeit an, die längst erledigt ist — oder umgekehrt: jemand
  entfernt den Zeiger im Guard, weil der Carveout sagt, er stehe dort ohnehin nicht.
- **verifizierbar:** ja — `grep -n "CO-002" .claude/hooks/pretooluse-agent-guard.sh spec/spezifikation.md`
  gegen die Tabelle.

### LOW-1 — Der Extraktor begründet eine lebende Verweigerung mit einem Pfad, den niemand mehr baut

- **kategorie:** LOW
- **quelle:** `AGENTS.md` §3.7
- **pfad:** `harness/tools/extract-agent-call.awk:20-30` und `:111`
- **befund:** Der Kopf sagt *„`subagent_type` wird auf `[A-Za-z0-9_:-]` geprüft, weil der
  Guard daraus einen PFAD baut (`.claude/agents/<name>.md`)"*, Zeile 111 wiederholt *„Der
  Typname wird zum Pfadbestandteil"*, und der Absatz *„Grenze, ausgesprochen: ein Typ, der
  sich nur ÄHNLICH schreibt wie eine Rolle (Unicode-Doppelgänger), fällt hier nicht auf"*
  setzt die Rolle/Nicht-Rolle-Unterscheidung des Guards voraus. Beides gibt es seit `83cf01d`
  nicht mehr — der Guard baut keinen Pfad und unterscheidet keine Rollen. Die Prüfung selbst
  bleibt richtig (sie hält `exit 3` gegen `../../etc/passwd`), nur ihr Grund ist tot.
- **gegenbeispiel:** jemand liest den Kopf, stellt fest, dass kein Pfad mehr gebaut wird, und
  lockert den Zeichensatz. `test/mutations/120` fängt es — der Schaden ist also gebunden, der
  Kommentar aber führt in die Irre. §3.7 §Cutoff nimmt den **Bestand** ausdrücklich aus; die
  Zeilen wurden in `83cf01d` nicht angefasst, brechen also formal nichts.
- **verifizierbar:** nein (kein Sensor liest Kommentar-Inhalt; `make comment-claims` prüft nur,
  ob genannte Sensoren existieren — er lief grün).

### LOW-2 — `slice-078` nennt drei Mutations-Fälle, die es nicht mehr gibt

- **kategorie:** LOW
- **quelle:** `LH-QA-01` (Sinngemäß: ein Plan, der nicht existierende Prüfstellen zählt)
- **pfad:** `docs/plan/planning/open/slice-078-verdrahtung-hat-waechter.md:58`
- **befund:** *„vier Fälle (`117`, `118`, `119`, `139`) mutieren
  `.claude/hooks/pretooluse-agent-guard.sh`"*. `117`, `118` und `119` sind in `83cf01d`
  gelöscht; heute sind es zwei (`139`, `150`). Der Block trägt die Überschrift *„Der
  Ist-Zustand, gemessen am 2026-08-08"* — die Datierung mildert den Befund, macht die Zahl im
  Argument (*„Ein Skript, das niemand aufruft, besteht jeden dieser Fälle"*) aber nicht wieder
  richtig.
- **gegenbeispiel:** der Implementer von slice-078 sucht die vier genannten Dateien und findet
  zwei; der Ist-Stand, gegen den er baut, stimmt an der einzigen Stelle nicht, die den
  Sensor-Mangel beziffert.
- **verifizierbar:** ja — `ls test/mutations/11[789]-*` (leer).

### LOW-3 — Spec §5 nennt Fall 150 als Wächter der Gegenrichtung

- **kategorie:** LOW
- **quelle:** `AGENTS.md` §3.6
- **pfad:** `spec/spezifikation.md:493`
- **befund:** Prüfschritt 2 von Abweichung 5 sagt über den fail-closed-Zweig *„ein fehlender
  Typ gilt als unlesbarer Aufruf"*: *„Bewacht von `test/agent-guard.bats` (in `make test`) und
  den Fällen 139 und 150."* Fall 150 bewacht diese Aussage nicht — er baut einen
  **verweigernden** Zweig für Rollen-Typen ein und färbt den PASS-Fall rot (selbst gefahren:
  `not ok 16`, Fall 15 blieb grün). Für den zitierten Satz trägt allein 139 (selbst gefahren:
  `not ok 15`).
- **gegenbeispiel:** jemand entfernt Fall 139 und beruft sich darauf, 150 decke die Stelle mit
  ab. `make mutate` bliebe grün, und der einzige Dauer-Sensor des fail-closed-Zweigs wäre weg.
- **verifizierbar:** ja — die zwei Läufe oben.

### LOW-4 — `agent_role` steht im `SubagentStart` eines Nicht-Rollen-Typs nicht

- **kategorie:** LOW
- **quelle:** eigene Messung (s. Kopf)
- **pfad:** `docs/plan/adr/0019-agent-guard-prueft-die-aufrufform.md:124-127`
- **befund:** *„`agent_type` und `agent_role` stehen schon im `SubagentStart` (zweimal
  `architect`, einmal `general-purpose`)"*. Gemessen trägt das `general-purpose`-Ereignis
  `"agent_type":"general-purpose"` und `"agent_role":""` — die Klammer gilt für `agent_type`,
  nicht für beide Felder. Das ist konstruktionsgemäß (`roleFromAgentType` normalisiert
  Nicht-Rollen auf leer), aber der Satz behauptet mehr, als der Bestand zeigt.
- **gegenbeispiel:** jemand liest den Satz als Zusage, dass `agent_role` für jeden Spawn
  gefüllt ist, und baut eine Auswertung darauf; für `general-purpose`-Läufe ist die Achse leer
  und die Zeile wandert in den Sammelposten.
- **verifizierbar:** ja — `grep -h 'SubagentStart' .harness/state/spans/*.jsonl | grep '2026-08-15'`.

### INFO-1 — Festlegung 2 nennt einen Constraint für den späteren Protokoll-Zweig, aber nicht den engsten

- **kategorie:** INFO
- **pfad:** `docs/plan/adr/0019-agent-guard-prueft-die-aufrufform.md:209-213` ·
  `test/agent-guard.bats:46-48`
- **befund:** Der spätere, nicht entscheidende Rollen-Zweig bekommt zwei Constraints (er darf
  die Aufrufform nicht entscheiden; er unterliegt `ADR-0011` Festlegung 2). Der engere fehlt:
  `assert_passed()` prüft `[ -z "$output" ]` — **jede** Ausgabe des Hooks im Pass-Fall färbt
  den Fall aus Festlegung 1 rot, auch eine rein protokollierende. Das ist kein Fehler der ADR,
  aber die Stelle, an der ein Umsetzer stolpert; der Guard-Kopf sagt es (*„Im Pass-Fall: KEINE
  Ausgabe"*), die ADR nicht.

### INFO-2 — Der Ersatz-Beobachter für Festlegung 3 existiert, hat aber am Nachbarfall nicht gebunden

- **kategorie:** INFO
- **pfad:** `docs/plan/adr/0019-agent-guard-prueft-die-aufrufform.md:311-316` ·
  `.claude/commands/close-welle.md:41-44`
- **befund:** Die ADR setzt an die Stelle des fehlenden Sensors *„das `Letzte Prüfung`-Datum
  von `CO-002` und das Carveout-Audit je Welle"*. Der Träger existiert wirklich — Schritt 2
  von `close-welle.md` und die Audit-Blöcke in `welle-02`…`welle-08-results.md` belegen sieben
  gefahrene Audits. Er hat an `CO-001` sieben Mal nicht gebunden, was den fehlenden
  Folge-Slice angeht (s. HIGH-1). `welle-10-re-baseline.md` enthält das Wort *Carveout*
  überhaupt nicht; der Audit hängt dort allein am Command, nicht am Wellen-Plan.

---

## Negativbefunde — geprüft, ohne Befund

- **Modul-7-Trichter, Frage 1 (Granularität).** Geprüft am Modul, nicht an der Plausibilität:
  `docs/plan/carveouts/` führte vor `f68cebd` genau **einen** Carveout (`CO-001`, Geltungsbereich
  `shell-lint` über `.bats`-Dateien) — kein gemeinsamer Geltungsbereich mit `CO-002`, also kein
  Cluster. Das zweite BF-Symptom (*„Code existiert vor Doku"*) liegt nicht vor: die Doku ist
  vollständig, es fehlt eine Quelle. Die Ableitung *einzelne Diskrepanz → Frage 2* trägt.
  **Ohne Befund.**
- **Modul-7-Trichter, Frage 2 (Temporalität), soweit sie nicht HIGH-1 betrifft.** Die
  Unterscheidung zu `ADR-0012` ist am Modul sauber gezogen — dort liegt kein Trigger in
  eigener Hand, hier einer (`updatedInput`). Die Kehrseite (negative Messung → *Nein* → ADR)
  steht in der ADR (`:175-178`) **und** in `CO-002` (`:76-81`), inhaltlich deckungsgleich.
  **Ohne Befund**, außer dass der Träger fehlt (HIGH-1).
- **`CO-002` Geltungsbereich (acht der neun Werte).** Gegen `spec/spezifikation.md:122`
  (Agent-Zeile: *„neun Werte aus sechs Schlüsseln"*) und gegen den Span-Bestand gehalten: die
  vier `Agent`-Spans vom 2026-08-15 tragen `model_version` und keinen der acht übrigen. Die
  Aufzählung in `CO-002:16-19` deckt sich Feld für Feld mit der Spec-Zeile. **Ohne Befund.**
- **`CO-002` Trigger „beobachtbar am Bestand statt an einer Absicht".** Die Formulierung
  erfüllt Modul 7 (ein Dritter kann ohne Rückfrage urteilen); der Ableseort ist der Mangel
  (MEDIUM-2), nicht die Absicht. **Ohne weiteren Befund.**
- **`CO-002` gegen die vendored Vorlage.** `.harness/baseline/v3.5.2/templates/docs/plan/carveouts/carveout.template.md`
  Zeile für Zeile gegen `CO-002` gehalten: alle sechs Pflicht-Header-Felder vorhanden, alle
  fünf Body-Abschnitte in der Vorlagen-Reihenfolge, der `d-check:ignore`-Kommentar der
  Verifikations-Checkliste verbatim übernommen, Template-Hinweis-Block gelöscht. Die
  Abweichung in der Checkliste (Gate-Zeile durch `span-report`- und Spec-Zeile ersetzt) ist am
  Fall begründet. **cp-from-template-Disziplin gewahrt, ohne Befund.**
- **ADR-Form nach Modul 4 §Ziel-Form.** Kopf (Status · Datum · Bezug) vorhanden, `Supersedes`
  zu Recht leer; **fünf** verglichene Alternativen mit je einem Contra (Modul 4 verlangt
  mindestens drei); Fitness Function vorhanden und nicht leer; der Kontext referenziert
  `LH-QA-01`/`LH-QA-03`, statt sie zu wiederholen. **Ohne Befund.**
- **`AGENTS.md` §3.8 und der Commit-Zuschnitt von `f68cebd`.** §3.8 bindet die Commit-Form für
  Änderungen an den Hard Rules (§3) und am Adaptions-Block; `f68cebd` berührt **keines von
  beiden** (`git show --stat`: ADR, ADR-README, `CO-002`, Carveout-README), die Regel greift
  hier also gar nicht. Der Zuschnitt entspricht ihr trotzdem: nur Architect-Artefakte, Rolle
  in der ersten Zeile der Message. Für Carveouts benennt **keine** Quelle eine schreibende
  Rolle — Modul 7 §Carveout-Audit verteilt nur die Audit-Rollen —, und §3.8 sagt über andere
  Norm-Artefakte ausdrücklich nichts. **Ohne Befund.**
- **`AGENTS.md` §3.4.** `ADR-0019` steht auf *Proposed*, überschreibt keine Accepted-ADR und
  trägt kein `Supersedes`. `ADR-0012` wird als **Kontrastfall** zitiert, nicht geändert.
  **Ohne Befund.**
- **`AGENTS.md` §3.3 (git mv + Inhalt = zwei Commits).** Kein `git mv` in den vier Commits
  (`git show --stat` zeigt nur Adds/Modifies/Deletes ohne Rename). **Ohne Befund.**
- **`AGENTS.md` §3.2 (Lint-Suppression).** Kein `# shellcheck disable` in Guard, bats-Datei
  oder den zwei Mutations-Skripten. **Ohne Befund.**
- **Die vier verbliebenen fail-closed-Zweige, gezählt am Code.** `pretooluse-agent-guard.sh:58`
  (awk), `:60` (Extraktor), `:67` (rc≠0), `:79` (`stype = ABSENT`) — exakt vier, wie Festlegung 1
  und der Kopf behaupten. Der Kopf deklariert zwei davon **selbst** als `UNBEWACHT` und den
  Parse-Zweifel als „nur bats" — keine überdehnte Sensor-Zusage. **Ohne Befund.**
- **Ist etwas still durchlässig geworden?** Die einzige neu durchlässige Klasse ist
  „Rollen-Typ, dessen Aufruf nicht `run_in_background: false` trägt" — also die beabsichtigte.
  Nicht-Rollen-Typen liefen vorher wie nachher durch; der Zeichensatz-Riegel
  (`extract-agent-call.awk:112`, `exit 3`) hält weiter und ist von `test/mutations/120`
  gebunden; die Fixture-Naht `AGENT_GUARD_AGENTS_DIR` ist mit dem Zweig **entfallen**, also
  eine Angriffsfläche weniger. Die Zwei-Zeilen-Vertragsbindung zwischen Extraktor und Guard
  (`sed -n '2p'`) ist von den `extract:`-Fällen 1–4 gebunden. **Ohne Befund.**
- **Binden die zwei genannten Wächter, was die Fitness Function behauptet?** Ja, für
  Festlegung 1: Fall 150 tötet exakt den benannten bats-Fall und **nur** ihn (1 von 143),
  Fall 139 ebenso. Der bats-Fall fährt real über jede Datei in `.claude/agents/` und bricht
  bei `< 6` Dateien ab. Die ADR sagt selbst, dass die zwei Zeilen für **Festlegung 3** nichts
  binden. **Ohne Befund** — die Einschränkung in MEDIUM-5 betrifft die Formulierung *„eine
  neue Rolle ist damit automatisch gedeckt"*, nicht die Rot-Fähigkeit.
- **`ADR-0011`-Bezüge.** Festlegung 1 Punkt 5 lautet dort wörtlich *„Was auch nach der
  Ableitung nicht erreichbar ist, wird begründet dokumentiert, nicht weggelassen"*
  (`0011-…:93-95`) — korrekt zitiert und einschlägig. Festlegung 2 (kein Byte fremden Inhalts)
  trägt Alternative B korrekt. **Ohne Befund.**
- **`ADR-0016`-Form der Regelwerks-Belege.** Alle vier Regelwerks-Zitate in `ADR-0019` tragen
  Tag (`v3.5.2`), Dateiname, Abschnitt und wörtliches Zitat; gegen
  `.harness/baseline/v3.5.2/regelwerk/modul-07-carveouts.md` und `modul-08-agentenrollen.md`
  geprüft — Wortlaut stimmt. **Ohne Befund.**
- **Die Korrektur an der vendored Hooks-Referenz (der bereits behobene Fall).** Nachgeprüft:
  `docs/user/claude-hooks-referenz.md:1556-1561` führt für `Agent` vier Eingabefelder
  (`prompt`, `description`, `subagent_type`, `model`), kein `run_in_background`. Die
  ADR-Aussage, die Tabelle könne die Vertragsänderung weder belegen noch widerlegen, trägt.
  Der `status`-Beleg (*„Ab v2.1.198 … erzeugt ein weggelassenes `run_in_background` auch
  `async_launched`"*) steht Zeile 1568 wörtlich so. **Ohne Befund.**
- **Annahme (b) — „kein Hook-Ereignis trägt die Zähler".** Die ADR belegt sie nur mit
  `SubagentStop`; selbst nachgemessen über das **ganze** vendored Dokument: `input_tokens` und
  `totalTokens` kommen an genau zwei Stellen vor, beide in der `Agent`-`tool_response`-Tabelle.
  Das SubagentStop-Eingabeschema (`:2155`, `:2159-2173`) führt sie nicht. Die universelle
  Aussage trägt gegen die Doku — die ADR hätte sie schmaler belegt, als sie belegbar ist.
  **Ohne Befund.**
- **Die Ausfall-Rechnung gegen `internal/report/report.go`.** `AgentLaeufe++` ohne Bedingung,
  Rückkehr bei beiden fehlenden Zählern, Ausgabezeile wörtlich
  `Abdeckung: %d von %d Agent-Laeufen trugen Zaehler` (`:287`). `make span-report` steht im
  Makefile mit *„NICHT in gates (Bericht, kein Sensor)"* und ist in `gates:` nicht enthalten.
  **Ohne Befund.**
- **Die emittierte Ebene.** `ls internal/emit/templates/enforce/` → `enforce.mk`,
  `extract-command.awk`, `gitignore`, `pretooluse-command-guard.sh`, `record-gates.sh`,
  `settings.json`, `stop-require-gates.sh`, `working-tree-hash.sh` — **kein** Agent-Guard.
  Folgepflicht 4 der ADR ist am Bestand richtig. **Ohne Befund.**
- **`harness/conventions.md`.** `MR-018` (Span-Schema samt Start-Konvention) ist durch `MR-021`
  **aufgehoben**; der Adaptions-Block trägt heute keine Zusage über den Guard oder die
  Betriebsart. Kein Nachzug fällig. **Ohne Befund.**
- **`README.md`, `harness/README.md`, `docs/user/benutzerhandbuch*.md`, `.claude/agents/*.md`,
  `.harness/skills/*`.** Kein Treffer auf `Vordergrund` · `run_in_background` · `Hintergrund` ·
  `Betriebsart` · `Rollen-Agent` · `@-Erwähnung`. Keine dieser Dateien trägt eine Zusage, die
  der Guard nicht mehr gibt. **Ohne Befund.**
- **`docs/plan/adr/README.md` (Index-Zeile zu ADR-0019).** Inhaltlich deckungsgleich mit der
  ADR, Status `Proposed`, Bezug-Spalte vollständig, *„Zwei Wächter, beide vorhanden"* stimmt
  (selbst gefahren). **Ohne Befund.**
- **`make comment-claims`** (hermetisch, in `gates`): `40 Datei(en) geprueft, 0 Befund(e)` —
  die im Guard-Kopf genannten Sensoren (`test/agent-guard.bats`,
  `test/mutations/150-agentguard-rolle-abgewiesen.sh`, `…/139-…`) existieren alle.
  **Ohne Befund.**

---

## Kategorie-Summary

| Kategorie | Anzahl | IDs |
|---|---|---|
| HIGH | 1 | HIGH-1 |
| MEDIUM | 6 | MEDIUM-1 … MEDIUM-6 |
| LOW | 4 | LOW-1 … LOW-4 |
| INFO | 2 | INFO-1, INFO-2 |

---

## Verdikt

**Blockiert.** Blockierend ist **HIGH-1**: `CO-002` trägt keinen Folge-Slice, und die
Modul-7-Frage 2, mit der `ADR-0019` Festlegung 3 den Ausgang *Carveout* statt *permanente
Abweichung* begründet, hat genau diesen Slice als ihr einziges tragendes Element. Solange er
nicht in `docs/plan/planning/` liegt, schreibt die ADR mit *Accepted* (`AGENTS.md` §3.4,
immutabel) eine Werkzeug-Wahl fest, deren Voraussetzung das Regelwerk im selben Atemzug
ausschließt — und die Korrektur kostet danach eine Folge-ADR statt heute einen Slice-Schnitt.

**Ebenfalls vor der Annahme zu klären, aus demselben Grund (§3.4 friert den Text ein, nicht
nur die Entscheidung):**

- **MEDIUM-1** — die Beleg-Etikettierung *„Zwei Enden, beide am Werkzeug gemessen"*. Der
  Ausgang ändert sich nicht; der Satz aber steht ab *Accepted* unveränderlich da und trägt
  eine Messung, die niemand gefahren hat.
- **MEDIUM-3 (a)** — *„Die Schleife war von innen nicht aufzuschneiden"* im Indikativ, ohne
  den offenen Weg zu benennen oder auszuschließen. Er trägt die Präzedenz.
- **MEDIUM-5** — *„eine neue Rolle ist damit automatisch gedeckt"* in der Fitness Function:
  gedeckt ist der Durchlass, nicht die Rollen-Achse.

**Nicht blockierend, aber vor dem Wellen-Abschluss fällig:** MEDIUM-2, MEDIUM-4, MEDIUM-6 und
die vier LOW-Befunde. MEDIUM-4 und MEDIUM-6 liegen außerhalb der ADR (Plan-Artefakte und der
Carveout selbst) und sind ohne §3.4-Kosten reparierbar.

**Ausdrücklich nicht beanstandet:** die Entscheidung. Option A ist gegenüber B, C, D und E
sauber abgewogen, die zwei genannten Wächter binden das, was Festlegung 1 zusagt (selbst rot
gesehen), der Trichter ist am Modul und nicht an der Plausibilität gefahren, die
Nicht-Zusage für Festlegung 3 ist ehrlich benannt, und die emittierte Ebene ist gemessen
unberührt. Blockiert ist die **Trägerschaft** einer Voraussetzung, nicht der Ausgang.

**Übergabe:** Befunde gehen an den Architect (`ADR-0019`, `CO-002`), MEDIUM-4 zusätzlich an
den Planner (`slice-071`, `slice-074`, `welle-09`), MEDIUM-6 und LOW-1/LOW-3 an den
Implementer bzw. den Eigentümer des Spec-Stratums. Weder ADR noch Carveout, Guard, Tests oder
Spec sind in diesem Lauf geändert worden; committet wurde nichts.

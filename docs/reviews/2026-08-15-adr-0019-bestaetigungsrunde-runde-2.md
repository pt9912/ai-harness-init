# ADR-0019 (Proposed) — Bestätigungsrunde, Runde 2

**Rolle:** Reviewer (Modul 10). **Datum:** 2026-08-15. **Lauf:** frischer Kontext, Subagent
`reviewer`, zweiter Durchgang.

**Gegenstand:** die drei Commits, mit denen die Befunde aus
[`docs/reviews/2026-08-15-adr-0019-bestaetigungsrunde.md`](2026-08-15-adr-0019-bestaetigungsrunde.md)
abgearbeitet wurden — `770e0d9` (zwei LOW an `spec/spezifikation.md` und
`harness/tools/extract-agent-call.awk`) · `d408814` (Planner: `slice-086` neu, `slice-071`,
`slice-074`, `slice-078`, `welle-09` nachgezogen) · `e48dabd` (Architect: `ADR-0019`, `CO-002`,
ADR-Index). Geprüft wird **was der Fix eingeführt hat**, nicht erneut, was Runde 1 schon geprüft
hat. Der Status der ADR ist unverändert *Proposed*.

**Eingangs-Kontext (die fünf Pflicht-Punkte plus Plan, Modul 10 §Eingangs-Kontext):** Commit-Range
oben · `LH-QA-01`, `LH-QA-02`, `LH-QA-03` · aktive ADRs `0004`, `0011`, `0012`, `0016` · Hard Rules
`AGENTS.md` §3.1–§3.8 · **vorherige Findings am gleichen Modul:** Runde 1 (oben) sowie
`docs/reviews/2026-08-03-adr-0012-bestaetigungsrunde{,-runde-2}.md` · Plan-Bezug: `slice-086`
(neu), `slice-071`, `slice-074`, `slice-078`, `welle-09`, `CO-002`.

**Nicht nachmessbar in diesem Lauf, und das gehört wieder an den Anfang:** ein Subagent führt das
`Agent`-Werkzeug nicht (Werkzeugliste `Read`/`Write`/`Bash`). Alles zum Tool-Vertrag prüft die
**Beleg-Kette**, nicht den Vertrag.

**Selbst gefahren (Kommando und Ergebnis, nichts davon übernommen):**

| Kommando | Ergebnis |
|---|---|
| `make docs-check` | `d-check: 317 Datei(en) geprueft, 0 Befund(e)` — die sechs Module inkl. `links`, `anchors`, `matrix` über den neuen Bestand |
| `make comment-claims` | `40 Datei(en) geprueft, 0 Befund(e)` |
| `ls -1 .claude/agents/` | sechs Dateien: architect, implementer, planner, reviewer, validator, verifier |
| `grep -rn "claude/agents" --include=*.go .` | Exit 1, **null** Treffer (die Aussage der neuen ADR-Konsequenz §Grenze trägt) |
| `grep -l pretooluse-agent-guard test/mutations/*.sh` | genau zwei: `139-agentguard-typ-failopen.sh`, `150-agentguard-rolle-abgewiesen.sh` |
| `head` über die `expect:`-Zeilen von 139 und 150 | `139 → "guard: Agent-Aufruf ohne Subagent-Typ -> DENY (fail-closed)"`, `150 → "guard: JEDER Typ in .claude/agents/ laeuft durch"` — die korrigierte Spec-Zeile stimmt |
| `grep -n "CO-002" .claude/hooks/pretooluse-agent-guard.sh spec/spezifikation.md` | Guard: 1 Treffer (Z. 14) · Spec: 5 Treffer (Z. 166, 206, 237, 365, 487) — die Tabelle in `CO-002` §Geltungs-Konfiguration stimmt Stelle für Stelle |
| `grep -ho '"agent_role":"[^"]*"' .harness/state/spans/*.jsonl \| sort \| uniq -c` | `""` 1920 · architect 928 · implementer 1428 · planner 1976 · reviewer 1546 · verifier 431 — **`validator` kommt im gesamten Bestand nicht vor (0)** |
| dieselbe Auswertung, auf `2026-08-15` eingegrenzt | `""` 157 · architect 100 · planner 59 · reviewer 109 — **drei** Rollen, nicht sechs |
| `grep -h SubagentStart … \| grep 2026-08-15` | architect 3 · general-purpose 1 · planner 1 · reviewer 2 |
| `sed` über `internal/report/report.go:133-140` | `b.AgentLaeufe++` unbedingt, danach `if s.InputTokens == nil && s.OutputTokens == nil { return }` — die neue Formulierung in `CO-002` ist wörtlich richtig |
| `sed` über `internal/span/emit.go:182-188` | `switch agentType { case "planner","architect","implementer","reviewer","verifier","validator": … }` — harte Sechser-Liste, keine Verzeichnis-Kopplung |
| `grep -n "updatedInput"` / Vorrangregel in `docs/user/claude-hooks-referenz.md` | Z. 1617 (`"allow"` oder `"ask"`, für `"defer"` ignoriert) und Z. 1620 (`deny > defer > ask > allow`) — die Mechanik-Aussagen von `slice-086` sind doku-deckungsgleich |

`make gates` habe ich **nicht** vollständig gefahren (Gate-Lauf-Bestätigung ist Verifier-Arbeit,
Modul 10 §Anti-Pattern); die zwei Doku-/Kommentar-Gates oben laufen, weil `770e0d9` und `e48dabd`
genau dort eingreifen. Die zwei Mutations-Fälle sind in Runde 1 rot gesehen worden und seither
unverändert (`git show 770e0d9 --stat`: kein Guard, keine bats-Datei, keine Mutation berührt).

---

## Findings

### HIGH-1 — Die ADR erklärt eine Aussage für ungemessen und benutzt sie 130 Zeilen später als Prämisse; drei weitere lebende Artefakte führen sie als *gemessen*

- **kategorie:** HIGH
- **quelle:** `AGENTS.md` §3.6 (*„Richtig: die Zusage auf das einschränken, was der Code hält"*),
  `LH-QA-02` (Reproduzierbarkeit); Modul 10 §Kontext-Eskalation (zweite Runde derselben Klasse)
- **pfad:** `docs/plan/adr/0019-agent-guard-prueft-die-aufrufform.md:136-146` gegen `:277` ·
  `spec/spezifikation.md:173-174` und `:196-201` ·
  `docs/plan/planning/open/slice-074-agent-vor-aufruf-protokoll.md:170` und `:187` ·
  `docs/plan/adr/README.md:27`
- **befund:** Der Fix trennt die Beleglage korrekt (`:134-146`): *„Ungemessen bleiben **zwei**
  Aussagen"* — (i) *das Modell sendet den Schalter nicht mehr*, (ii) *der Schalter ist überhaupt
  nicht mehr sendbar*. Festlegung 4 setzt (ii) **im Indikativ** als Prämisse ein: *„Seit das Modell
  das Feld nicht mehr senden kann, ist das der einzige denkbare Weg zurück in den Vordergrund"*
  (`:277`). Damit trägt der Satz, der `updatedInput` zum einzigen Weg erklärt, genau die Aussage,
  die dieselbe ADR 130 Zeilen früher als ungemessen ausweist. Außerhalb der ADR ist derselbe Satz
  unverändert stehengeblieben: `spec/spezifikation.md:173-174` wortgleich; `:196-201` führt für
  denselben Sachverhalt die **Belegklasse: gemessen (2026-08-15)**, obwohl die ADR ihn auf
  *Schema-Selbstauskunft* zurückführt; `slice-074:170` schreibt in die Belegklassen-Spalte
  *„gelesen + gemessen, und sie stimmen inzwischen überein"* — während `ADR-0019:121-127` gerade
  feststellt, dass die vendored Tabelle die Frage *weder belegen noch widerlegen* kann (sie führte
  das Feld für `Agent` **nie**, auch nicht am 2026-07-29, als der Schalter nachweislich wirkte);
  `slice-074:187` notiert *„Der Wert ist heute konstant `ABSENT`"*.
- **gegenbeispiel:** Sonde 1 aus derselben ADR wird gefahren und die Schlüsselmenge von
  `tool_input` enthält `run_in_background` mit Wert `true`. Dann war das Feld sendbar, die
  Bedingung des Guards war erfüllbar (`false` hätte durchgelassen), Festlegung 1 ruhte auf einer
  falschen Prämisse — und Festlegung 4 hätte `updatedInput` nicht mehr als *einzigen denkbaren
  Weg*. `spec/spezifikation.md:200` behauptet für diesen Fall bis dahin, das Gegenteil sei
  **gemessen** worden; wer die Belegklassen des Spec-Stratums für belastbar hält, hat keinen
  Anlass, nachzusehen.
- **Muster, nicht Einzelfall:** dieselbe Klasse hat Runde 1 als MEDIUM-1 benannt; der Fix hat den
  Satz *„Der Beleg … sind die zwei Payload-Messungen"* korrigiert (`:131-132`) und vier weitere
  Fundorte derselben Aussage stehen gelassen, einer davon in derselben Datei. Nach Modul 10
  §Kontext-Eskalation ist die Wiederholung einer benannten Klasse eine Stufe höher zu führen —
  und der Befund ist ein Steering-Loop-Signal: die Klasse *„Belegklasse sagt gemessen, wo eine
  Selbstauskunft steht"* hat keinen Sensor (`.d-check.yml` führt `links, anchors, ids, matrix,
  codepaths, spans`; kein Modul liest Belegklassen).
- **verifizierbar:** ja, ohne Gate-Lauf — `sed -n '136,146p;277p' docs/plan/adr/0019-*.md` gegen
  `sed -n '196,206p' spec/spezifikation.md`. Maschinell **nicht** bewacht (s. o.).

### MEDIUM-1 — Die neue Positiv-Konsequenz sagt „für die sechs notierten Rollen gemessen"; gemessen sind drei, und eine Rolle hat im ganzen Bestand keinen einzigen Span

- **kategorie:** MEDIUM
- **quelle:** `AGENTS.md` §3.6; `LH-QA-01`
- **pfad:** `docs/plan/adr/0019-agent-guard-prueft-die-aufrufform.md:305-307`
- **befund:** Der Fix ersetzt die von Runde 1 (MEDIUM-5) beanstandete Zeile durch *„die
  Rollen-Achse der Telemetrie trägt weiter — für die sechs **notierten** Rollen gemessen, nicht
  gehofft (oben)"*. Der Rückverweis *(oben)* zeigt auf `:158-170`, und dort stehen drei
  `SubagentStart`-Ereignisse mit `agent_type` **architect, architect, general-purpose**. Selbst
  nachgemessen über den ganzen Bestand: `agent_role` trägt architect, implementer, planner,
  reviewer, verifier — **`validator` kommt in keinem Span vor (0 von 6.229 belegten Zeilen)**; am
  2026-08-15 selbst sind es drei Rollen (architect, planner, reviewer). Was für alle sechs trägt,
  ist die **Ableitung** in `roleFromAgentType` (Code, selbst gelesen), nicht eine Messung. Die
  Korrektur einer zu breiten Zusage hat eine neue, engere eingeführt.
- **gegenbeispiel:** ein Verifier prüft nach der Annahme die Konsequenz-Zeile am Bestand und sucht
  den `validator`-Beleg. Er findet keinen und muss entweder die als *immutabel* (§3.4) gesetzte
  Aussage als falsch melden oder sie als „gemeint war die Ableitung" umdeuten — genau die
  Umdeutung, die `AGENTS.md` §3.6 ausschließt.
- **verifizierbar:** ja —
  `grep -ho '"agent_role":"[^"]*"' .harness/state/spans/*.jsonl | sort | uniq -c` (Bestand ist
  gitignored und maschinenlokal; die **Gestalt** — eine Rolle ohne jeden Span — ist die Aussage,
  nicht die Zahl).

### MEDIUM-2 — `CO-002` nennt zwei verschiedene Schwellen für dasselbe Ereignis, und die Sonde aus `slice-086` erfüllt die eine, ohne die andere zu berühren

- **kategorie:** MEDIUM
- **quelle:** Regelwerk `v3.5.2`, `modul-07-carveouts.md` §Ziel-Form: Carveout
  (*„Auflösungs-Trigger als beobachtbare, messbare Bedingung … eine Schwelle, die ein anderer
  Mensch ohne Rückfrage als erreicht beurteilen kann"*)
- **pfad:** `docs/plan/carveouts/CO-002-token-achse-je-rolle.md:66-79` (Trigger) gegen `:25-32`
  (§Folge-Slice, neu) und `:118-120` (Verifikations-Punkt 1, neu) ·
  `docs/plan/planning/open/slice-086-vordergrund-per-updatedinput.md:56-63`
- **befund:** Der Trigger lautet nach dem Fix: *„ein `Agent`-Span trägt wieder `spawned_role`
  **und** alle vier `usage`-Zähler"*, abzulesen *„an der `Agent`-Zeile des Span-Bestands selbst"*.
  Der im selben Commit ergänzte §Folge-Slice sagt für den positiven Ausgang etwas anderes: *„folgt
  die Entscheidung über seine Verstetigung samt Permission-Folge in einer Folge-ADR, und **erst
  danach** löst sich dieser Carveout auf"*. `slice-086` DoD (1) verlangt ausdrücklich, die Sonde
  **zurückzunehmen** (*„`git status` ist leer … die Permission-Lage des Repos ist dieselbe wie
  vorher"*). Der bei der Messung entstandene Span bleibt im (gitignorierten, maschinenlokalen)
  Bestand liegen und erfüllt die Trigger-Bedingung ab da dauerhaft — ohne dass irgendein
  committeter Mechanismus je wieder Zähler herstellte. Der Fix hat die Verwechslungsgefahr eine
  Ebene tiefer richtig benannt (Abdeckungszeile vs. Span) und eine Ebene höher eine neue erzeugt.
- **gegenbeispiel:** `slice-086` läuft positiv, die Verdrahtung wird wie geplant zurückgenommen,
  die Folge-ADR steht noch aus. Das nächste Wellen-Audit (`close-welle.md` Schritt 2: *„aufgelöst ·
  verlängert · permanent akzeptiert"*) liest den Trigger, findet im Bestand einen `Agent`-Span mit
  `spawned_role` und vier Zählern, hakt *aufgelöst* ab und verschiebt `CO-002` nach `done/` — die
  Token-Achse je Rolle hat weiterhin keinen Eingang, und die Folge-ADR aus §Folge-Slice hat keinen
  Auftraggeber mehr. Auf jedem anderen Checkout ist die Beurteilung ohnehin nicht reproduzierbar.
- **verifizierbar:** ja, ohne Gate-Lauf — die drei Absätze gegeneinander lesen; kein
  `.d-check.yml`-Modul liest Carveout-Trigger.

### MEDIUM-3 — `slice-086` legt eine Fixture unter `test/` an, während sein Prüfgegenstand nach dem Lauf verschwindet — und behauptet zugleich, nichts aus ihm gehe in `make gates`

- **kategorie:** MEDIUM
- **quelle:** `LH-QA-01` (keine halluzinierten Gates), `AGENTS.md` §3.6
- **pfad:** `docs/plan/planning/open/slice-086-vordergrund-per-updatedinput.md:16-18` · `:56-70`
  (DoD (1)) · `:183-184` (§Berührte Dateien) · `Makefile:55` (`docker run … bats test/`)
- **befund:** Der Bezug-Block sagt *„nichts aus ihm geht in `make gates`, und die Sonde bleibt
  nicht stehen"*; DoD (1) verlangt, Hook-Datei und Verdrahtung zurückzunehmen. §Berührte Dateien
  führt dagegen `test/` als **neu** — *„die Fixture aus DoD (1) … Prüfung auf Wohlgeformtheit der
  Ausgabe und darauf, dass die Sonde in keine Datei schreibt"*. `make test-bats` fährt
  `bats test/` über das **ganze** Verzeichnis (selbst im Makefile gelesen; `test/` enthält heute
  ausschließlich `*.bats` und `mutations/`), also läuft jede dort abgelegte Datei in `make test`
  und damit in `make gates`. Ein Prüffall, dessen Gegenstand planmäßig gelöscht wird, ist entweder
  rot oder vakuös grün; beides widerspricht dem Bezug-Satz.
- **gegenbeispiel:** der Implementer setzt beide Punkte wörtlich um: Sonde weg, Fixture bleibt.
  Fährt der bats-Fall die Sonde, ist `make gates` rot und der Slice kann seine eigene DoD-Zeile
  *„`make gates` grün"* nicht erfüllen; fängt er das Fehlen ab, steht ein Fall im Gate, der eine
  Eigenschaft im Namen führt und nichts mehr misst — `AGENTS.md` §3.6 §*Falsch*, und
  `make mutate` hätte für ihn keinen Fall.
- **verifizierbar:** ja — `sed -n '55p' Makefile` und `ls test/` gegen `:183`.

### MEDIUM-4 — Der Nachzug an `welle-09` behauptet Folgenlosigkeit für das Closure-Kriterium, prüft aber nur eine der zwei betroffenen Zellen — und `slice-071` ist seit dem Fix nicht mehr startbar

- **kategorie:** MEDIUM
- **quelle:** `welle-09` §3 (*„Alle Slices dieser Welle in `done/`"*, *„Je Regelblock UND je Ebene
  ein belegter Zustand"*), `.claude/commands/close-welle.md` Schritt 1
- **pfad:** `docs/plan/planning/welle-09-modul-15-konformitaet.md:185-189` und `:88-89`, `:118`,
  `:124`, `:158` · `docs/plan/planning/open/slice-071-cache-zaehler-getrennt.md:111-116`
- **befund:** Der Fix schreibt in `welle-09`: *„**Für das Closure-Kriterium dieser Welle ändert der
  Ausfall nichts:** die Zelle *Token-Attribution × Repo* trägt für den Hintergrund-Teil den Wert
  *deklariert*"*. Das trägt für Block 2. Unberührt bleiben zwei andere Closure-Bedingungen
  derselben Welle: (a) *„Alle Slices dieser Welle in `done/`"* — `slice-071` ist Mitglied (`:124`,
  `:158`), und derselbe Commit hängt seinen Eintritt neu an *„**`CO-002` ist entschieden**"*
  (`slice-071:111-114`), also an `slice-086`, das seinerseits erst nach *Accepted* der ADR
  startet; (b) die Zelle **Cache-Counter × Repo** (Block 3), deren Wert ausweislich `:158` aus
  ebendieser Rechnung kommen sollte — wird `slice-071` wie geplant auf DoD (2) zurückgeschnitten,
  nennt kein Artefakt mehr, welchen der fünf zulässigen Werte diese Zelle dann trägt. Der Satz
  sagt *„ändert nichts"* und zeigt nur für eine von drei betroffenen Stellen, dass nichts sich
  ändert.
- **gegenbeispiel:** die Welle soll schließen. Schritt 1 von `close-welle.md` verlangt alle Slices
  in `done/`; `slice-071` steht in `open/` mit einem Eintritts-Trigger, der auf eine noch nicht
  angenommene ADR und eine noch nicht gefahrene Messung zeigt. Entweder die Welle steht — obwohl
  ihr eigener Plan sagt, der Ausfall ändere für ihr Closure-Kriterium nichts —, oder jemand füllt
  die Block-3-Zelle mit einem Wert, für den es weder Sensor noch Deklaration gibt.
- **verifizierbar:** nein, maschinell nicht — per Lesen belegt, mit `git show d408814` und den
  zitierten Zeilen reproduzierbar.

### MEDIUM-5 — Die zwei neuen Sonden sind ungleich getragen: die zweite ist ein Slice, die erste gehört niemandem — obwohl ein Artefakt derselben Runde sie bauen würde

- **kategorie:** MEDIUM
- **quelle:** Regelwerk `v3.5.2`, `modul-07-carveouts.md` §Regeln gegen typische Fehlannahmen
  (*„Slice schlägt Memo"* — hier auf die Messschuld einer ADR übertragen); `AGENTS.md` §3.6
- **pfad:** `docs/plan/adr/0019-agent-guard-prueft-die-aufrufform.md:139-146` · `:382-399`
  (Re-Evaluierungs-Trigger) · `docs/plan/planning/open/slice-074-agent-vor-aufruf-protokoll.md:187`
- **befund:** Sonde 2 ist an Festlegung 4 gebunden, von dort an `CO-002` §Folge-Slice und an
  `slice-086` — Träger vorhanden, entscheidbarer Ausgang benannt. Sonde 1 (*Schlüsselmenge von
  `tool_input` auswerfen und gegen die vier vom 2026-07-29 halten*) hat keinen: sie steht in keiner
  Folgepflicht, in keinem Slice und in keinem der vier Re-Evaluierungs-Trigger. Sie ist zugleich
  die **billigere** und die einzige, die den tragenden Grund von Festlegung 1 widerlegen könnte
  (ein `true` in der Schlüsselmenge hieße: sendbar). Bemerkenswert ist die Nähe: `slice-074`
  protokolliert nach dem Fix genau dieses Feld (*„genau drei Werte: `true`, `false`, `ABSENT`"*,
  `:187`) und begründet es mit dem ersten Re-Evaluierungs-Trigger der ADR — die Verbindung zur
  Messschuld nennt weder die ADR noch der Slice.
- **gegenbeispiel:** die ADR wird *Accepted* und damit immutabel. Ein Jahr später fragt jemand,
  woher die Aussage *„das Modell sendet den Schalter nicht mehr"* stammt. Die ADR nennt eine Sonde,
  die niemand schuldet; `slice-074` liegt in `open/` und hat einen anderen Zweck in seiner
  Begründung; die Spec sagt *„gemessen"* (HIGH-1). Die Messschuld ist damit ein Memo unter
  anderem Namen — dieselbe Diagnose, mit der Runde 1 den fehlenden Folge-Slice blockiert hat.
- **verifizierbar:** ja, ohne Gate-Lauf — `grep -n "Sonde" docs/plan/adr/0019-*.md` gegen
  `git grep -ln "Schlüsselmenge" -- docs/plan/planning/`.

### LOW-1 — Der Grund, den `770e0d9` aus dem Extraktor-Kopf entfernt hat, steht unverändert im Mutations-Fall, der ihn bewacht

- **kategorie:** LOW
- **quelle:** `AGENTS.md` §3.7; Runde 1 LOW-1 (nur an einem von zwei Fundorten aufgelöst)
- **pfad:** `test/mutations/120-extract-typname-zeichensatz.sh:6-11` gegen
  `harness/tools/extract-agent-call.awk:111-115`
- **befund:** Der awk-Kopf sagt seit `770e0d9` richtig, die Schranke gehöre *„zum Wert, nicht zu
  einem Abnehmer"*, und *„Der heutige Abnehmer tut es nicht mehr"*. Der Fall, der genau diese
  Schranke bewacht, begründet sie weiter im Präsens mit dem gelöschten Pfad-Bau: *„Der Guard baut
  aus `subagent_type` einen PFAD (`.claude/agents/<name>.md`) — das ist der Grund fuer die Strenge
  … die Existenzfrage zeigte dann auf einen Ort ausserhalb des Verzeichnisses, und ob der Aufruf
  als Rolle gilt, entschiede eine fremde Datei"*. Seit `83cf01d` baut der Guard keinen Pfad und
  stellt keine Existenzfrage.
- **gegenbeispiel:** jemand pflegt die Mutations-Fälle, liest den Kopf von 120, prüft die
  Behauptung am Guard, findet sie widerlegt und hält den Fall für verwaist — der einzige
  Dauer-Sensor des Zeichensatz-Riegels verschwindet, weil seine Begründung nicht mehr stimmt.
  `make comment-claims` fängt das nicht: er prüft die Existenz genannter Sensoren (grün gefahren),
  nicht den Inhalt einer Begründung.
- **verifizierbar:** nein (kein Sensor liest Kommentar-Inhalt).

### LOW-2 — Die Sonden-Begründung beruft sich auf `ADR-0011` Festlegung 2, deren Zeile für das Agenten-Werkzeug strenger ist als das, was sie tragen soll

- **kategorie:** LOW
- **quelle:** `ADR-0011` (**Accepted**) Festlegung 2, Zeile *„jedes andere, auch künftige"*:
  *„**nur** Name und Status — **keine** Argumente … Betrifft heute u. a. das Agenten-Werkzeug mit
  seinem **Freitext-Prompt**"*
- **pfad:** `docs/plan/adr/0019-agent-guard-prueft-die-aufrufform.md:139-143`
- **befund:** Sonde 1 soll *„die **Schlüsselmenge** von `tool_input` auswerfen — nur die Namen,
  keine Werte (`ADR-0011` Festlegung 2 — im Original als Link)"*. Die zitierte Festlegung erlaubt für das
  Agenten-Werkzeug nicht *Namen statt Werte*, sondern **nur Name und Status des Werkzeugs**; die
  Präzedenz für eine Namens-Messung ist die Messreihe vom 2026-07-29 (*„nur Feldnamen und
  Wertlängen, nie Werte"*), nicht `ADR-0011`. Der Verweis stützt die Sache, sagt aber etwas
  anderes als die Stelle, auf die er zeigt.
- **gegenbeispiel:** jemand baut Sonde 1 **dauerhaft** in die Erfassung ein und beruft sich auf
  diese Zeile als Erlaubnis. Damit wüchse die Positiv-Liste für `Agent` um Argument-Schlüssel — ein
  Schritt, den `ADR-0011` Festlegung 2 gerade ausschließt, und `test/mutations/127`
  (`span-positivliste-negiert`) bewacht die Liste, nicht ihre Erweiterung per ADR-Zitat.
- **verifizierbar:** ja, ohne Gate-Lauf — die zwei Stellen nebeneinander lesen.

### LOW-3 — Die Index-Zeile behauptet zuerst flach, was sie zwei Sätze später einschränkt

- **kategorie:** LOW
- **quelle:** `AGENTS.md` §3.6; `MR-001`-Muster (der Index ist ein lebendes Artefakt)
- **pfad:** `docs/plan/adr/README.md:27`
- **befund:** Die neu gefasste Zelle beginnt *„die Schalter-Forderung fällt, weil sie
  **unerfüllbar** geworden ist: `run_in_background` steht nicht mehr im Eingabe-Schema von
  `Agent`"* und schränkt erst danach ein: *„gemessen ist dort, dass **kein Aufruf `false` trug**,
  nicht, dass das Feld fehlte"*. Der Index ist die Zeile, die zitiert und weitergetragen wird; ihr
  erster Halbsatz sagt genau das, was der zweite zurücknimmt.
- **gegenbeispiel:** ein späterer Plan zitiert die Index-Zeile als Kurzfassung (so entstand
  `slice-074:170`) und trägt die flache Behauptung in ein weiteres lebendes Artefakt — der fünfte
  Fundort derselben Aussage, ohne dass jemand die ADR öffnet.
- **verifizierbar:** ja — `sed -n '27p' docs/plan/adr/README.md`.

### LOW-4 — Das Carveout-Audit von `welle-09` nennt weiter nur `CO-001`, obwohl `CO-002` die Datenlage eines ihrer Slices bestimmt

- **kategorie:** LOW
- **quelle:** Regelwerk `v3.5.2`, `modul-07-carveouts.md` §Carveout-Audit;
  `.claude/commands/close-welle.md` Schritt 2
- **pfad:** `docs/plan/planning/welle-09-modul-15-konformitaet.md:118`
- **befund:** Der Fix hat `welle-09` §5 um `CO-002` und `slice-086` ergänzt, die Closure-Zeile
  *„Carveout-Audit (Modul 7): `CO-001` (im Original als Link) geprüft, neue Carveouts dokumentiert oder begründet
  keine"* aber nicht. `CO-002` ist seit dem 2026-08-15 aktiv und entscheidet über den Eintritt von
  `slice-071`, einem Mitglied dieser Welle.
- **gegenbeispiel:** das Audit arbeitet die Zeile ab, prüft `CO-001` und schließt aus *„neue
  Carveouts dokumentiert"*, dass nichts weiter zu tun sei — während der Zustand von `CO-002` gerade
  die Bedingung ist, an der ein Slice dieser Welle hängt (MEDIUM-4).
- **verifizierbar:** ja — `grep -n "Carveout-Audit" docs/plan/planning/welle-09-*.md`.

### INFO-1 — Runde 1 INFO-1 ist aufgelöst, aber im Plan statt in der ADR

- **kategorie:** INFO
- **pfad:** `docs/plan/planning/open/slice-074-agent-vor-aufruf-protokoll.md:201-215`
- **befund:** Der engste Constraint für den späteren Protokoll-Zweig — der Pass-Fall des Guards ist
  an **keine Ausgabe** gebunden, jede protokollierende Zeile dort färbt den bats-Fall aus
  Festlegung 1 rot — steht jetzt ausgeschrieben, samt der daraus folgenden Entscheidung *„sie
  entsteht in diesem Hook, nicht als Zweig im Guard"*. Die ADR nennt ihn weiterhin nicht; das ist
  konsistent, weil Festlegung 2 die Frage ausdrücklich an diesen Slice übergibt.

### INFO-2 — Das Zeitdokument trägt weiter die breite Prämisse, und das ist richtig so

- **kategorie:** INFO
- **pfad:** `docs/reviews/2026-08-15-agent-guard-tool-vertrag.md:33`, `:49-51`, `:126-129`
- **befund:** Die Messung, auf die die ADR als *Grundlage* zeigt, führt die Überschrift *„Der
  Schalter ist nicht sendbar"*, den Satz *„Damit ist der Guard nicht verletzt, sondern
  **unerfüllbar**"* und *„Die Schleife lässt sich nicht von innen aufschneiden — der Eintritt ist
  eine Auftraggeber-Entscheidung, die Klasse, die `MR-015` regelt"*. Beides hat die ADR inzwischen
  enger gefasst bzw. als **Analogie** gekennzeichnet. Zeitdokumente werden nicht nachgezogen
  (Repo-Konvention, in Runde 1 bestätigt) — wer dem Verweis folgt, landet aber zuerst bei der
  überholten Fassung. Won't-fix-Notiz, kein Auftrag.

---

## Der Stand der Runde-1-Befunde (ausdrücklich, auch für das nicht Aufgelöste)

| Runde 1 | Stand nach `770e0d9` · `d408814` · `e48dabd` | Beleg |
|---|---|---|
| **HIGH-1** (kein Folge-Slice) | **aufgelöst** — `slice-086` liegt in `open/`, bindet beide Ausgänge (DoD (3)), `CO-002` §Folge-Slice zeigt darauf, die ADR bleibt bei der **Eigenschaft** statt der Adresse (Folgepflicht 3) | Datei gelesen; Template-Struktur (8 Abschnitte) deckungsgleich mit `.harness/baseline/v3.5.2/templates/…/slice.template.md` |
| HIGH-1 §Muster (`CO-001` ohne Folge-Slice) | **nicht aufgelöst** — `CO-001-bats-shell-lint.md:14` trägt weiter *„noch keiner angelegt"*; war Beiwerk des Befunds, nicht sein Kern | `grep -n "Folge-Slice" docs/plan/carveouts/CO-001-*.md` |
| **MEDIUM-1** (Beleg-Etikettierung) | **halb aufgelöst** — an der Kernstelle repariert, an vier weiteren Fundorten nicht; einer davon in derselben ADR → **HIGH-1 dieser Runde** | s. o. |
| **MEDIUM-2** (Trigger ≠ Ableseort) | **aufgelöst**, mit neuer Naht → MEDIUM-2 dieser Runde | `report.go:133-140` selbst gelesen; die neue Formulierung ist wörtlich richtig |
| **MEDIUM-3 (a)+(b)** (Reihenfolge-Prämisse, `MR-015`) | **aufgelöst** — Prämisse auf *„von innen, durch einen Agenten"* verengt, der uncommittete Weg steht als offen und ungeprüft da, `MR-015` ist als **Analogie** gekennzeichnet, der Fußabdruck (`60e4370` → `83cf01d`) wird samt seiner Grenze genannt (*„belegt die Reihenfolge, nicht die Zustimmung"*). Die zweite Beweislast der Präzedenz ist eine echte **Verengung**: sie verlangt von künftigen Berufungen mehr, als dieser Fall selbst geleistet hat, und sagt das ausdrücklich | ADR `:47-81`, gegen Runde 1 MEDIUM-3 gelesen |
| **MEDIUM-4** (halber Nachzug) | **aufgelöst** — die Anweisung in `slice-071` DoD (2) ist ersetzt (keine zweite Aussage über die Erreichbarkeit mehr), `slice-074` Zeilen 1 und 5 und die Feld-Tabelle sind gezogen, `welle-09` §5 ist neu gefasst. Neue Befunde an den nachgezogenen Stellen: HIGH-1, MEDIUM-4 | `git show d408814` |
| **MEDIUM-5** (Rollen-Achse zu breit) | **aufgelöst** — Fitness Function sagt *Durchlass*, die Grenze steht als eigener Konsequenz-Punkt und ist am Code korrekt (selbst gemessen: null Go-Treffer, harte Sechser-Liste). Der neue Positiv-Satz überzieht dafür → MEDIUM-1 dieser Runde | ADR `:317-326`, `:365` |
| **MEDIUM-6** (`CO-002` §Geltungs-Konfiguration falsch) | **aufgelöst** — beide Zeiger stehen, die Tabelle beschreibt sie richtig, und sie trägt jetzt ihr Prüf-Kommando; ich habe es gefahren (1 + 5 Treffer) | `grep -n "CO-002" …` |
| **LOW-1** (toter Grund im Extraktor) | **halb aufgelöst** → LOW-1 dieser Runde | `test/mutations/120-*.sh:6-11` |
| **LOW-2** (drei gelöschte Fälle) | **aufgelöst** — `slice-078:57-61` nennt zwei Fälle und sein Kommando; selbst nachgefahren, Ergebnis identisch | `grep -l pretooluse-agent-guard test/mutations/*.sh` |
| **LOW-3** (Fall 150 als falscher Wächter) | **aufgelöst** — die Spec trennt die zwei Richtungen; gegen die `expect:`-Zeilen beider Fälle geprüft | `spec/spezifikation.md:487-497` |
| **LOW-4** (`agent_role` im `SubagentStart`) | **aufgelöst** — ADR `:166-170` trennt `agent_type` und `agent_role` und nennt die Normalisierung | ADR gelesen |
| **INFO-1 / INFO-2** | INFO-1 im Plan aufgelöst (INFO-1 dieser Runde); INFO-2 unverändert — `welle-10-re-baseline.md` nennt *Carveout* weiter nur als Dateinamen-Bestandteil | `grep -n -i carveout docs/plan/planning/welle-10-*.md` |

---

## Negativbefunde — geprüft, ohne Befund

- **Der Doku-Gate über den geänderten Bestand.** `make docs-check` → `317 Datei(en) geprueft, 0
  Befund(e)`; die neuen Links (`CO-002` → `slice-086`, ADR → `ADR-0016`, `slice-071`/`welle-09` →
  `slice-086`) und alle Anker halten. **Ohne Befund.**
- **`make comment-claims`.** `40 Datei(en) geprueft, 0 Befund(e)` — die im neuen awk-Kopf genannten
  Sensoren (`test/agent-guard.bats` „extract: Pfad-Ausbruch im Typnamen -> exit 3",
  `test/mutations/120`) existieren; den bats-Fall habe ich zusätzlich namentlich in
  `test/agent-guard.bats:115` gefunden. **Ohne Befund.**
- **Die zwei LOW-Fixes aus `770e0d9` inhaltlich.** Der Spec-Satz trennt die Richtungen korrekt
  (139 = fail-open des fehlenden Typs → DENY-Fall rot; 150 = verweigernder Rollen-Zweig →
  Durchlass-Fall rot), beide gegen die `expect:`-Zeilen der Fälle geprüft. Der awk-Riegel selbst
  ist **unverändert** (`git show 770e0d9` zeigt nur Kommentarzeilen), die Regel also nicht
  angefasst. **Ohne Befund.**
- **`CO-002` §Geltungs-Konfiguration gegen den Bestand.** Das Guard-Zitat ist **verbatim**
  (`pretooluse-agent-guard.sh:13-15`), die fünf Spec-Stellen liegen genau dort, wo die Tabelle sie
  nennt (Erfassungs-Liste Punkt 5, START-KONVENTION, Wächter-Absatz, Abweichung 1, Abweichung 5).
  **Ohne Befund.**
- **Die Aussage über `report.go` in `CO-002` und in Festlegung 4.** *„kehrt erst zurück, wenn
  Eingabe- **und** Ausgabe-Zähler fehlen"* — im Code steht
  `if s.InputTokens == nil && s.OutputTokens == nil { return }`, davor `b.AgentLaeufe++`
  unbedingt, danach der Sammelposten-Zweig bei leerem `SpawnedRole`. Wörtlich richtig.
  **Ohne Befund.**
- **Die neue Konsequenz §Grenze am Code.** `grep -rn "claude/agents" --include=*.go .` → null
  Treffer (Exit 1), `roleFromAgentType` ist die zitierte harte Sechser-Liste, `.claude/agents/`
  führt sechs Dateien. Die Behauptung *„eine siebte Datei liefe durch, ihr Span trüge
  `agent_role: \"\"`, und nichts würde rot"* trägt. **Ohne Befund.**
- **`slice-086` gegen die vendored Vorlage (cp-from-template-Disziplin).** Alle acht
  Abschnitts-Überschriften in der Reihenfolge der Vorlage, Lifecycle-Block und Welle-/Bezug-/
  Autor-Kopf vorhanden, `§8 Sub-Area-Modus-Begründung` gefüllt. **Ohne Befund.**
- **`slice-086` §3 gegen `MR-016` Setzung 1.** Alle drei Fragen beantwortet, jede mit einem
  Argument statt einer Behauptung; die Aussage über die `welle-09`-Zelle (*„trägt für den
  Hintergrund-Teil bereits den Wert *deklariert*"*) deckt sich mit `welle-09:159` (slice-068
  DoD (3)); die Aussage über `welle-10` (Closure = drei Durchgänge + Pin, kein Bezug zum getauschten
  Baum) deckt sich mit dem dortigen Plan. Setzung 2/3 (kein Roadmap-Eintrag) korrekt angewandt.
  **Ohne Befund.**
- **Die Mechanik-Aussagen von `slice-086` gegen die vendored Doku.** `updatedInput` wirkt mit
  `"allow"` oder `"ask"`, für `"defer"` ignoriert (`claude-hooks-referenz.md:1617`); die
  Vorrangregel `deny > defer > ask > allow` steht wörtlich (`:1620`), die Aussage *„die
  `ask`-Entscheidung der Sonde lässt einen Guard-Deny stehen"* folgt daraus. **Ohne Befund** — dass
  `"ask"` die Durchsetzung **nicht** senkt (mehr Rückfragen, nicht weniger), trägt; die
  Verstetigungs-Frage bleibt korrekt bei der Folge-ADR.
- **Der `updatedInput`-Bauweg (Splice statt Serialisierung).** Die Begründung über `LH-QA-03`
  trägt: `harness/tools/extract-agent-call.awk` liest zwei **Werte** und gibt kein **Objekt**
  zurück — der Slice benennt genau diese Grenze als seine offene technische Frage und hat für ihr
  Scheitern zwei Rückführungen (§4), die nicht auf `jq` zeigen. **Ohne Befund.**
- **`slice-074`s neuer Abschnitt zur protokollierenden Rollen-Frage.** Beide Constraints aus
  `ADR-0019` Festlegung 2 sind übernommen und um den engeren ergänzt (leere Ausgabe im Pass-Fall);
  die Ableitung bleibt **neben** dem rohen Typnamen stehen, `ADR-0011` Festlegung 2 ist korrekt als
  weiter geltend benannt. **Ohne Befund.**
- **`slice-078`s neu gemessener Ist-Zustand.** *„zwei Fälle (`139`, `150`)"* samt Kommando — selbst
  gefahren, identisches Ergebnis; die ergänzte Einordnung (*„die Zahl ist das schwächere Argument
  von beiden"*) schwächt die Aussage korrekt ab, statt sie zu heilen. **Ohne Befund.**
- **`AGENTS.md` §3.8 und der Commit-Zuschnitt.** `e48dabd` berührt ausschließlich
  Architect-Artefakte (ADR, ADR-Index, Carveout), `d408814` ausschließlich Plan-Artefakte, beide
  mit der Rolle in der ersten Zeile. Hard Rules und Adaptions-Block sind in keinem der drei
  Commits angefasst (`git show --stat`), §3.8 greift also nicht einmal. `770e0d9` trägt keine
  Rolle im Betreff und ändert Spec und Extraktor-Kommentar — für diese Klasse benennt §3.8 keine
  schreibende Rolle. **Ohne Befund.**
- **`AGENTS.md` §3.3 und §3.2.** Kein `git mv` in den drei Commits (nur Add/Modify), keine
  `# shellcheck disable`-Zeile hinzugefügt. **Ohne Befund.**
- **`AGENTS.md` §3.4.** `ADR-0019` steht weiter auf *Proposed*, die Überarbeitung ist als eigene
  Geschichte-Zeile geführt (*„Überarbeitet, weiter Proposed"*) statt die erste zu überschreiben —
  das ist die Form, die §3.4 für die Zeit **vor** der Annahme verlangt. Keine Accepted-ADR
  angefasst. **Ohne Befund.**
- **Die Spec-START-KONVENTION nach dem Nachzug.** Die Überschrift führt weiter *„zwei Bedingungen,
  zwei BELEGKLASSEN"*, während der Text Bedingung 2 in-place entwertet (*„eine Beschreibung, wo
  eine Regel stünde"*) und mit *„Die Konvention hat damit nur noch Bedingung 1"* schließt. Die
  Aussage von `CO-002` §Geltungs-Konfiguration dazu ist wörtlich die des Spec-Texts. Gelesen,
  **ohne Befund** — die Auflösung steht im selben Absatz (die Belegklasse selbst ist Gegenstand
  von HIGH-1, nicht die Struktur).
- **Ist durch die drei Commits etwas still durchlässig geworden?** Kein Commit berührt Guard,
  Extraktor-Code, bats-Datei, Mutations-Fälle, `Makefile`, `.d-check.yml` oder `settings.json`
  (`git show --stat` über alle drei). Die einzige Code-Datei im Diff ist
  `extract-agent-call.awk`, und dort ausschließlich Kommentarzeilen. **Ohne Befund.**
- **Die emittierte Ebene.** Unberührt in allen drei Commits; Folgepflicht 4 der ADR bleibt am
  Bestand richtig. **Ohne Befund.**

---

## Kategorie-Summary

| Kategorie | Anzahl | IDs |
|---|---|---|
| HIGH | 1 | HIGH-1 |
| MEDIUM | 5 | MEDIUM-1 … MEDIUM-5 |
| LOW | 4 | LOW-1 … LOW-4 |
| INFO | 2 | INFO-1, INFO-2 |

---

## Verdikt

**Blockiert.** Blockierend ist **HIGH-1**: die ADR erklärt in `:136-146` zwei Aussagen für
ungemessen und benutzt eine davon in `:277` als Prämisse der Festlegung 4 — *„Seit das Modell das
Feld nicht mehr senden kann, ist das der einzige denkbare Weg zurück"*. `AGENTS.md` §3.4 friert mit
*Accepted* den **Text** ein, nicht nur die Entscheidung; eine Selbstwidersprüchlichkeit an einem
tragenden Satz kostet danach eine Folge-ADR. Dieselbe Aussage steht unkorrigiert in drei weiteren
lebenden Artefakten, eines davon (`spec/spezifikation.md:200`) mit der ausdrücklichen Belegklasse
**gemessen** — das ist die Etikettierung, die Runde 1 als MEDIUM-1 benannt hat, in zweiter Runde
und an mehr Orten.

**Ebenfalls vor der Annahme zu klären, weil in der ADR selbst und damit ab *Accepted* unveränderlich:**

- **MEDIUM-1** — *„für die sechs notierten Rollen gemessen"*. Gemessen sind drei; `validator` hat
  im gesamten Span-Bestand keinen Span (selbst gefahren). Die Reparatur einer zu breiten Zusage hat
  eine neue eingeführt.
- **MEDIUM-5** — Sonde 1 ohne Träger. Sie ist die billigere der zwei und die einzige, die den
  tragenden Grund von Festlegung 1 widerlegen könnte; ein Artefakt derselben Runde (`slice-074`)
  würde sie bauen, ohne dass eines der beiden das sagt.
- **LOW-2** und **LOW-3** liegen ebenfalls in Architect-Artefakten und sind mit je einem Satz
  erledigt.

**Nicht blockierend, aber vor dem Wellen-Abschluss fällig, und ohne §3.4-Kosten reparierbar:**
MEDIUM-2 (`CO-002` — zwei Schwellen für dasselbe Ereignis; die Sonde erfüllt die eine dauerhaft),
MEDIUM-3 (`slice-086` — Fixture im Gate gegen zurückgenommene Sonde), MEDIUM-4 (`welle-09` —
Folgenlosigkeit behauptet, eine von drei Stellen geprüft; `slice-071` ist nicht mehr startbar)
sowie LOW-1 und LOW-4.

**Ausdrücklich nicht beanstandet — und das ist mehr als in Runde 1:** der Kern der Überarbeitung
trägt. Die **Verengung der Präzedenz** ist echt und nicht kosmetisch: sie benennt den offenen
uncommitteten Weg, nimmt die Behauptung der Alternativlosigkeit zurück, kennzeichnet `MR-015` als
Analogie statt als Anwendung, nennt den Fußabdruck samt seiner Grenze — und legt künftigen
Berufungen eine zweite Beweislast auf, die dieser Fall selbst nicht erfüllt hat, was sie
ausspricht statt zu verdecken. Die `CO-002`-Korrekturen zu Ableseort und Zeigern sind am Code und
am Bestand nachgeprüft und richtig. `slice-086` ist ein echter Träger: Template-konform, mit
beiden Ausgängen gebunden, mit der Kontroll-Beobachtung als Bedingung der Deutbarkeit und mit
`"ask"` statt `"allow"` — und diese Wahl trägt, sie verschiebt die Senkung nicht, weil `"ask"` mehr
Rückfragen erzeugt und nicht weniger und die Verdrahtung uncommittet bleibt. Blockiert ist die
**Beleg-Etikettierung**, nicht die Entscheidung.

**Übergabe:** HIGH-1, MEDIUM-1, MEDIUM-5, LOW-2, LOW-3 an den **Architect** (`ADR-0019`,
`docs/plan/adr/README.md`); HIGH-1 zusätzlich an den Eigentümer des **Spec-Stratums**
(`spec/spezifikation.md:173-174`, `:196-201`); MEDIUM-2 an den Architect (`CO-002`); MEDIUM-3,
MEDIUM-4, LOW-4 und der `slice-074`-Anteil von HIGH-1 an den **Planner**; LOW-1 an den
**Implementer** (`test/mutations/120`). In diesem Lauf ist **nichts geändert und nichts
committet** worden; `git status` war vor und nach der Prüfung leer, die einzige geschriebene Datei
ist dieser Report.

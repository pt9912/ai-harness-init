# Review-Report: slice-066 (Plan, vor Code) — 2026-08-08

**Review-Art:** **Plan** — geprüft wird der Plan gegen Spec und Accepted-ADRs, *bevor*
implementiert wird (Modul 10 §Drei Review-Arten). Es existiert kein Diff am Auswerter, und
dieser Report verlangt keinen.

**Gegenstand:** `e561878^..HEAD` (`95952b1`), vier Commits:
`e561878` · `654956a` · `faa3631` · `95952b1`. Berührte Dateien:
`docs/plan/planning/in-progress/slice-066-telemetrie-auswertung.md`,
`.claude/settings.json`, `docs/plan/planning/open/slice-071-cache-zaehler-getrennt.md`.

**Skill:** `.harness/skills/reviewer.md` @ 1.4.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5[1m] · **Datum:** 2026-08-08

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde):

- Slice-Plan `docs/plan/planning/in-progress/slice-066-telemetrie-auswertung.md`
- aktive ADRs: [`ADR-0012`](../plan/adr/0012-haupt-kontext-ohne-token-bilanz.md) (Accepted),
  [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md) (Accepted),
  [`ADR-0003`](../plan/adr/0003-go-native-binaries.md) (Accepted)
- `LH-*`: [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten),
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
- [`AGENTS.md`](../../AGENTS.md) §3 Hard Rules (§3.1 · §3.3 · §3.4 · §3.5 · §3.6), §2 Source
  Precedence · [`harness/conventions.md`](../../harness/conventions.md)
  [`MR-000`](../../harness/conventions.md#mr-000--baseline-aussage),
  [`MR-002`](../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks),
  [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler),
  [`MR-019`](../../harness/conventions.md#mr-019--technik-stratum-als-rang-2-der-source-precedence)
- Regelwerk `v3.5.2`: `modul-05-planning-harness.md`, `modul-08-agentenrollen.md`,
  `modul-10-review-harness.md`
- **vorherige Findings am gleichen Modul:**
  `docs/reviews/2026-07-29-slice-060-066-plan-review.md` und die Runden 2, 3, 4 —
  wiederkehrende Klasse dort: *Plan-Aussage nach neuer Messung nicht nachgezogen*
  (Runde 3 F-3, Runde 4 F-1); Kategorisierungs-Präzedenz für eine Plan-Zusage ohne Zahn:
  Runde 2 F-6 = **MEDIUM**.

**Mess-Grundlage.** Alle Zahlen dieses Reports sind selbst erhoben, gegen einen Schnappschuss
des Span-Bestands (`.harness/state/spans/`) vom **2026-08-08T14:10:45Z**: 87 `*.jsonl`,
5.772 Spans, drei Sitzungs-Ströme. Der laufende Strom wächst während der Messung — die
Rekonstruktion des Stands vom 2026-08-03 erfolgt per `ts <= 2026-08-03T19:12:00Z`
(= 21:12 CEST, Zeitstempel von `e561878`).

---

## Findings

### F-1 — Die Definition of Done wurde in der Implementer-Rolle geändert; `ADR-0012` spricht den Slice-Plan ausdrücklich dem Planner zu

- `kategorie`: **HIGH**
- `quelle`: [`ADR-0012`](../plan/adr/0012-haupt-kontext-ohne-token-bilanz.md) (Accepted)
  §Folgepflicht 4, `:214-215` — *„Der Slice-Plan gehört dem Planner; diese ADR benennt die
  Bedingung, sie schreibt ihn nicht."* · Regelwerk `modul-08-agentenrollen.md`
  §Rollen-Sequenz (*„keine Rolle springt rückwärts in eine vorhergehende, ohne
  Übergabe-Artefakt"*) und §Rollen-Regeln (*„Rollen-Trennung ist Kontext-Trennung … aber
  nicht im selben Kontextfenster"*) · `modul-05-planning-harness.md` §Ziel-Form: Slice ·
  [`MR-000`](../../harness/conventions.md#mr-000--baseline-aussage) (Baseline unadaptiert
  übernommen, das Regelwerk gilt also unverändert)
- `pfad`: `docs/plan/planning/in-progress/slice-066-telemetrie-auswertung.md:87-94`
  (eingefügt durch `95952b1`) · dazu `:74-85` (`faa3631`/`95952b1`), `:147` (`e561878`),
  `:148` (`654956a`)
- `befund`: Alle vier Commits sind in der Implementer-Rolle entstanden und ändern
  Planner-Artefakte; `95952b1` erweitert DoD (1) um eine zusätzliche Ausgabe-Pflicht (die
  Ausgabe nennt das **Fenster**, über das die Abdeckungszahl rechnet), und `faa3631` streicht
  aus derselben DoD den Satz, der die Rückführung `in-progress → next` für genau diesen
  DoD-Punkt vorsah. Die Erweiterung entstand im selben Kontextfenster, das die auslösende
  Messung durchgeführt hat; ein Übergabe-Artefakt an den Planner existiert nicht, und die in
  §4 des Slice bereits verdrahteten Rückführungskanten wurden nicht benutzt.
- `failure-szenario`: Der Verifier prüft nach Modul 11 die Implementierung gegen die DoD und
  meldet dem Planner „DoD-konform". Die geprüfte DoD-Pflicht wurde jedoch vom implementierenden
  Kontext selbst formuliert — die Antwort *„die Ausgabe nennt ihr Fenster"* ist damit nie von
  einer anderen Rolle gegen die Alternative *„die Abdeckungszahl ist über diesem Bestand noch
  nicht baubar → Rückführung"* geprüft worden. Die Rollentrennung fällt genau an der Stelle
  aus, an der sie tragen soll, und der Ausfall ist im Ergebnis nicht sichtbar.
- `verifizierbar`: ja, ohne Gate —
  `git log --format='%h %s' e561878^..HEAD` gegen
  `git diff e561878^..HEAD -- docs/plan/planning/in-progress/slice-066-telemetrie-auswertung.md`
  zeigt die DoD-Änderung; kein Sensor deckt sie ab (`make gates` lief laut Commit-Message grün).

### F-2 — `SubagentStart` ist verdrahtet, aber der von `ADR-0012` dafür verlangte Nachtrag in `spec/spezifikation.md` §5 fehlt; der Rang-2-Text sagt weiter „zwei Ereignisse"

- `kategorie`: **HIGH**
- `quelle`: [`ADR-0012`](../plan/adr/0012-haupt-kontext-ohne-token-bilanz.md) (Accepted)
  §Re-Evaluierungs-Trigger, `:279-287` — *„Wer eines dieser Ereignisse verdrahtet, misst
  seine Schlüsselmenge mit und trägt sie in `spec/spezifikation.md` §5 nach"* ·
  [`AGENTS.md`](../../AGENTS.md) §2 Rang 2 /
  [`MR-019`](../../harness/conventions.md#mr-019--technik-stratum-als-rang-2-der-source-precedence)
- `pfad`: `.claude/settings.json:47-58` (neu in `faa3631`) gegen
  `spec/spezifikation.md:294-300` und `:506-515` · `docs/plan/adr/0012-…:111-113`
- `befund`: `spec/spezifikation.md` §5 sagt unter der Überschrift *„Die erfasste MENGE,
  ausgesprochen statt suggeriert"*: *„Verdrahtet sind **zwei** Ereignisse — `PostToolUse` und
  `PostToolUseFailure` … Erfasst wird damit der **abgeschlossene** Aufruf."* Seit `faa3631`
  sind es drei, und das dritte erfasst keinen abgeschlossenen Aufruf, sondern einen Start;
  §5 `:506-515` sagt zudem weiter, die Payloads der übrigen Ereignisse habe *„hier niemand
  angesehen"*, während `95952b1` genau eine solche Messung vorträgt. Der Commit-Bereich ändert
  `spec/spezifikation.md` nicht (`git diff --stat`: drei Dateien, keine davon die Spec), und
  die Plan-Tabelle führt die Datei ausschließlich für die Splitting-Regel (`:139`). Die
  Schlüsselmenge der `SubagentStart`-Payload ist nirgends festgehalten — der Plan nennt allein
  `agent_type`, obwohl der Emitter auch `agent_id` liest (`internal/span/span.go:86-87`).
- `failure-szenario`: Ein Leser (oder der Auswerter dieses Slice) nimmt §5 beim Wort, rechnet
  die Abdeckung gegen zwei Ereignisse und übersieht den dritten Strom-Eintrag mit `seq 1`;
  ADR-0012s Annahme (a) — *„die Hook-Oberfläche trägt für den Haupt-Kontext keine Zähler"* —
  bleibt für ein real verdrahtetes Ereignis unbelegt, obwohl die ADR das Nachmessen an genau
  diesen Vorgang gebunden hat.
- `verifizierbar`: ja — `sed -n '294,300p' spec/spezifikation.md` gegen
  `jq -r '.hooks | keys[]' .claude/settings.json`; kein Gate prüft es
  (`make comment-claims` lässt Markdown außen vor, `docs-check` prüft Links/Struktur, nicht
  Tatsachen).

### F-3 — Die zweite Quelle ist ausgerechnet für den Fall unvermessen, für den sie existiert; „baubar" reicht weiter als die Messung

- `kategorie`: **HIGH**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 (*„Keine Zusage ohne rot gesehenes
  Gegenbeispiel"* — DoD-Punkt und Commit-Message sind dort namentlich Zusage-Formen) ·
  `spec/spezifikation.md` §5 Regel *„die Payload ist die Quelle, die Doku ist Herkunft"*
- `pfad`: `docs/plan/planning/in-progress/slice-066-telemetrie-auswertung.md:69-82`
  (`:71-73` *„feuert je Spawn … unabhängig davon, ob der `Agent`-Span Telemetrie trug"*;
  `:82` *„Damit ist die zweite Quelle real, und dieser DoD-Punkt ist baubar"*)
- `befund`: Die Abdeckungszahl steht und fällt damit, dass `SubagentStart` **auch dann**
  feuert, wenn der `Agent`-Span keine Zähler trägt — also für den Hintergrund-Start. Gemessen
  wurden zwei Spawns (2026-08-08T14:02:29Z `general-purpose`, 14:09:24Z `reviewer`); **beide
  liefen im Vordergrund** — der erste hinterließ einen `Agent`-Span mit Zählern
  (`total_tokens: 21953`, `duration_ms 25127 > total_duration_ms 23496`, nach der Regel aus
  `spec/spezifikation.md:110` also Vordergrund), der zweite ist ein Rollen-Agent, den der
  Guard aus slice-060 im Hintergrund gar nicht zuließe. Für den zählerlosen Fall ist die
  Aussage damit **gelesen** (`docs/user/claude-hooks-referenz.md:2109`), nicht gemessen —
  und derselbe Plan hatte diese Unterscheidung für `agent_type` bis `95952b1` noch selbst
  eingefordert, samt Rückführung bei negativem Ausgang; der Satz ist mit demselben Commit
  entfallen.
- `failure-szenario`: Der Auswerter ist gebaut, der Agent-Guard fällt aus, ein Rollen-Lauf
  startet im Hintergrund. Feuert `SubagentStart` dort nicht, fehlt der Lauf in Zähler **und**
  Nenner: die Abdeckungszahl meldet 100 %, während genau der lautlose Ausfall eingetreten ist,
  gegen den DoD (1) sie eingeführt hat. Der Sensor gegen stilles Grün ist dann selbst still.
- `verifizierbar`: ja, ohne Gate — ein Spawn mit `run_in_background` (Typ ohne Rollen-Datei,
  damit der Guard ihn durchlässt), danach
  `jq -c 'select(.event=="SubagentStart")' .harness/state/spans/*.jsonl`. Der Bestand enthält
  heute **null** solcher Belege: alle 82 Subagenten-Ströme vor dem 2026-08-08 beginnen mit
  `PostToolUse`, nur zwei mit `SubagentStart`.

### F-4 — Die Fenster-Pflicht ist eine vierte Größe in derselben Ausgabe; die Plan-Tabelle führt weiter drei Zähne

- `kategorie`: **MEDIUM**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 ·
  [`ADR-0012`](../plan/adr/0012-haupt-kontext-ohne-token-bilanz.md) `:251-255`
  (*„Drei Größen, drei Angaben — wer zwei davon zusammenlegt, verliert eine"*) ·
  Kategorisierungs-Präzedenz: `docs/reviews/2026-07-29-slice-060-066-plan-review-runde-2.md`
  F-6 (MEDIUM)
- `pfad`: `docs/plan/planning/in-progress/slice-066-telemetrie-auswertung.md:91-94` gegen
  `:141` (Plan-Tabellen-Zeile `test/` + `test/mutations/`) und `:105-111` (DoD (2)
  *„Zwei Größen, zwei Angaben, zwei Zähne — zusammengelegt geht eine verloren"*)
- `befund`: Die Fenster-Angabe ist **neu**, nicht klarstellend: der Plan trennt sie im
  Folgesatz selbst vom Nenner aus DoD (2) (*„Diese Bezugsgröße ist **nicht** der Nenner aus
  DoD (2)"*, `:95-96`) und kann deshalb nicht dessen Zahn mitbenutzen — anders als die
  Zeitraum-Angabe aus Frage B, die ausdrücklich als *„keine zusätzliche Zusage"* unter DoD (2)
  gebucht wurde (`:148`). Damit führt die Ausgabe vier Größen (Sammelposten-Anteil ·
  Abdeckungszahl · Nenner · Fenster), während die Plan-Tabellen-Zeile für `test/mutations/`
  unverändert nur drei benennt und kein Satz sagt, was passieren müsste, damit die
  Fenster-Angabe bricht.
- `failure-szenario`: Der Implementer baut die Fenster-Angabe, ein späteres Refactoring
  entfernt sie, `make mutate` bleibt grün (kein gelisteter Fall), `make gates` bleibt grün.
  Die Abdeckungszahl steht dann ohne Geltungsbereich in der Ausgabe — genau die Zahl, die
  laut Plan *„mehr behauptet als sie trägt"*.
- `verifizierbar`: ja — `sed -n '87,96p;141p' docs/plan/…/slice-066-telemetrie-auswertung.md`;
  nach der Implementierung `make mutate` (der fehlende Fall ist ein nicht gelisteter Wächter).

### F-5 — Das Fenster hat nur eine linke Kante; ein laufender Subagent senkt die Abdeckungszahl ohne Defekt (heute gemessen: 50 %)

- `kategorie`: **MEDIUM**
- `quelle`: [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) ·
  Reproduzierbarkeits-Argument des Plans selbst (`:148` Punkt (3), *„der laufende Strom wächst
  während der Auswertung"*)
- `pfad`: `docs/plan/planning/in-progress/slice-066-telemetrie-auswertung.md:91-92`
  (*„ab dem ersten `SubagentStart`-Span im Bestand"*)
- `befund`: Definiert ist allein der Fenster-Anfang. `SubagentStart` entsteht beim **Start**,
  der `Agent`-Span des Aufrufers erst beim **Ende** — ein noch laufender Subagent liegt damit
  im Nenner, nicht im Zähler. Im Schnappschuss von 14:10:45Z: **2** `SubagentStart`-Spans
  gegen **1** `Agent`-Span im Fenster ab 14:02:29Z, also 50 % Abdeckung bei fehlerfreier
  Erfassung — die fehlende Hälfte ist der Review-Lauf, der diese Messung gerade ausführt.
- `failure-szenario`: Der Auswerter wird aus einem Subagenten heraus oder parallel zu einem
  laufenden Spawn aufgerufen und meldet eine Abdeckung unter 100 %. Der Leser sucht einen
  ausgefallenen Guard, der nicht existiert; zwei Aufrufe kurz nacheinander liefern zudem
  verschiedene Werte.
- `verifizierbar`: ja, ohne Gate —
  `jq -r 'select(.event=="SubagentStart")|.ts' .harness/state/spans/*.jsonl` gegen
  `jq -r 'select(.tool=="Agent" and .ts>="<erster ts>")|.ts' .harness/state/spans/*.jsonl`.

### F-6 — Frage B („der Bestand") und die Fenster-Auflösung lassen den Bericht über zwei verschieden großen Mengen rechnen; für 92 von 93 `Agent`-Spans sagt die Abdeckungszahl nichts

- `kategorie`: **MEDIUM**
- `quelle`: [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
  (Bericht über leerem Prüfbereich — dieselbe Klasse eine Ebene weiter, wie in Runde 2 F-6
  angewandt) · DoD (1) `:67-68` (*„Ohne diese Zahl liest sich eine unvollständige Erhebung wie
  eine vollständige"*)
- `pfad`: `docs/plan/planning/in-progress/slice-066-telemetrie-auswertung.md:87-94` gegen
  `:148` (Frage B: *der Bestand*)
- `befund`: Die Bilanz rechnet nach Frage B über den Bestand (ab 2026-07-29), die
  Abdeckungszahl nach der neuen Auflösung über das Fenster (ab 2026-08-08). Selbst gemessen:
  93 `Agent`-Spans im Bestand, davon **1** im Fenster; 71 tragen Zähler, 22 nicht. Der Plan
  benennt das Fenster, entscheidet aber nicht, was der Bericht über den **außerhalb**
  liegenden, weit größeren Teil der Bilanz aussagt — und für diesen Teil bleibt exakt die
  Lücke offen, gegen die DoD (1) die Abdeckungszahl eingeführt hat.
- `failure-szenario`: Der Bericht zeigt „Abdeckung 100 % (Fenster ab 2026-08-08)" über einer
  Bilanz, deren 22 zählerlose `Agent`-Spans allesamt vor dem Fenster liegen. Beide Angaben
  sind wahr, zusammen lesen sie sich als vollständige Erhebung.
- `verifizierbar`: ja, ohne Gate —
  `jq -r 'select(.tool=="Agent")|(if has("total_tokens") then "z" else "-" end)' .harness/state/spans/*.jsonl | sort | uniq -c`
  (heute: 71 mit, 22 ohne Zähler) gegen die Zahl der `SubagentStart`-Spans (2).

### F-7 — Frage A (4) ist durch die Arbeit desselben Tages widerlegt und im Plan nicht nachgezogen

- `kategorie`: **MEDIUM**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 · wiederkehrende Klasse dieses Slice:
  `docs/reviews/2026-07-29-slice-060-066-plan-review-runde-3.md` F-3 und
  `…-runde-4.md` F-1 (*Plan-Aussage nach neuer Messung nicht nachgezogen*) — mit diesem Befund
  die **dritte** Wiederholung, also ein Steering-Loop-Signal nach Reviewer-Skill
  §Kontext-Eskalation
- `pfad`: `docs/plan/planning/in-progress/slice-066-telemetrie-auswertung.md:147`, Punkt (4)
- `befund`: Der Plan sagt: *„der Sammelposten misst **0 Spans** (jeder zähler-tragende
  `Agent`-Span trägt eine Rolle), der aufgeteilte Anteil aus DoD (1) ist damit **0,0 %**"*.
  Selbst gemessen: am Stand des 2026-08-03 stimmte das (0 Spans); **heute** trägt der Bestand
  einen Sammelposten-Span (`ts 2026-08-08T14:02:54Z`, `total_tokens 21953`, `spawned_role`
  fehlt) — Anteil **0,1616 %** von 13.586.309 Token. Erzeugt hat ihn der Mess-Aufruf aus
  `95952b1`; dessen Commit-Message hält den Wechsel *„0 → 1"* fest, der Plan trägt ihn nicht
  nach. Ebenfalls widerlegt ist die Begründung im selben Punkt, rollenlose Typen liefen als
  Hintergrund-Läufe *„und tragen gar keine Zähler"*: genau dieser Span stammt aus einem
  `general-purpose`-Lauf **im Vordergrund**.
- `failure-szenario`: Der Implementer liest *„der heutige Effekt ist null"* und legt für den
  Sammelposten-Anteil einen Test mit Erwartungswert `0,0 %` oder gar keinen Testfall an; die
  Splitting-Regel bekommt keinen Zahn, obwohl sie seit heute einen realen Gegenstand hat.
- `verifizierbar`: ja, ohne Gate —
  `jq -c 'select(.tool=="Agent" and has("total_tokens") and ((.spawned_role//"")==""))' .harness/state/spans/*.jsonl`.

### F-8 — „76/92 der zähler-tragenden `Agent`-Spans" nennt die falsche Bezugsmenge und widerspricht Frage B in derselben Datei

- `kategorie`: **MEDIUM**
- `quelle`: [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) ·
  Reviewer-Skill §MEDIUM (*Spec-Treue-Lücke einer Messmethode*)
- `pfad`: `docs/plan/planning/in-progress/slice-066-telemetrie-auswertung.md:147`, Punkt (2)
  gegen `:148`, Punkt (1)
- `befund`: Frage A beziffert die Signal-Stärke des `slice`-Feldes mit *„76/92 der
  **zähler-tragenden** `Agent`-Spans"*; Frage B beziffert im selben Dokument und am selben Tag
  *„**70** zähler-tragende Läufe"* — 76 von 70 ist unmöglich. Rekonstruktion des Stands
  `ts <= 2026-08-03T19:12:00Z` löst den Widerspruch: es gab **92 `Agent`-Spans insgesamt**
  (davon 70 mit Zählern), und **76 von diesen 92** tragen `slice`. Unter den zähler-tragenden
  sind es **62 von 70**. Die Zahl stimmt, ihre Bezugsmenge ist falsch benannt.
- `failure-szenario`: Ein Verifier prüft Frage A gegen den Bestand, findet 62/70 statt 76/92
  und meldet die Begründung als unbelegt — oder der Implementer übernimmt die falsche
  Bezugsmenge in die Ausgabe-Beschriftung des Auswerters.
- `verifizierbar`: ja, ohne Gate —
  `jq -r 'select(.tool=="Agent" and .ts<="2026-08-03T19:12:00Z" and has("total_tokens"))|(if (.slice|length)>0 then "has" else "no" end)' .harness/state/spans/*.jsonl | sort | uniq -c`
  → `62 has / 8 no`.

### F-9 — Die Begründung der Verdrahtung stützt sich auf eine Aussage über die vendored Referenz, die die Referenz widerlegt — und auf ihr beruht die Streichung eines korrekten Verweises

- `kategorie`: **MEDIUM**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 (Commit-Message als Zusage-Form) ·
  `spec/spezifikation.md` §5 *„die Payload ist die Quelle, die Doku ist Herkunft"* (die Doku
  bleibt Herkunft, sie wird dadurch nicht falsch zitierbar)
- `pfad`: `faa3631` Commit-Message (*„Die vendored Referenz führt das Ereignis nur in Tabellen,
  einen Abschnitt dazu gibt es nicht, und der Agent-Typ steht dort als MATCHER-Wert"*) und die
  damit begründete Streichung in
  `docs/plan/planning/in-progress/slice-066-telemetrie-auswertung.md:71`
  (vorher: *„feuert je Spawn und trägt `agent_type` (Referenz, §SubagentStart)"*) gegen
  `docs/user/claude-hooks-referenz.md:2105-2143`
- `befund`: Die Referenz führt einen eigenen Abschnitt `<h3 id="subagentstart">` (`:2105-2107`)
  mit dem Unterabschnitt `SubagentStart-Eingabe` (`<h4 id="subagentstart-input">`, `:2113-2115`).
  Dort steht wörtlich, `SubagentStart`-Hooks erhielten *„`agent_id` … und `agent_type`"* als
  **Eingabefelder**, samt Beispiel-Payload mit `"agent_type": "Explore"` (`:2117-2128`) und der
  Aussage, das Ereignis könne die Erstellung nicht blockieren (`:2130`). Die drei Behauptungen
  der Commit-Message treffen sämtlich nicht zu; auf ihrer Grundlage wurde der zutreffende
  Quellen-Verweis aus der DoD entfernt, und `agent_id` — das der Emitter real liest
  (`internal/span/span.go:86`) — kommt im Plan nirgends vor.
- `failure-szenario`: Der nächste Leser sucht die Herkunft der `agent_type`-Aussage, findet im
  Plan keinen Verweis mehr und hält sie für eine reine Einzelbeobachtung; dieselbe Fläche wird
  ein zweites Mal vermessen, oder die Schlüsselmenge aus F-2 wird weiter unvollständig
  nachgetragen.
- `verifizierbar`: ja, ohne Gate —
  `sed -n '2105,2130p' docs/user/claude-hooks-referenz.md`.

### F-10 — Die Dogfood-Verdrahtung des Emitters hat keinen Mutations-Fall; der vorhandene bewacht die **emittierte** `settings.json`

- `kategorie`: **MEDIUM**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 ·
  [`MR-002`](../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks)
  (Geltungsbereich `.claude/`)
- `pfad`: `.claude/settings.json:47-58` gegen
  `test/mutations/32-enforce-settings-wires-guard.sh` (`files: internal/emit/templates/enforce/settings.json`)
- `befund`: Der einzige Mutations-Fall zur Hook-Verdrahtung greift auf die **Template**-Datei
  des emittierten Ziels, nicht auf die Verdrahtung dieses Repos; gemessen über alle 135 Fälle
  in `test/mutations/` gibt es keinen, der `.claude/settings.json` anfasst — weder für
  `PostToolUse` noch für den neuen `SubagentStart`-Block. Die Plan-Tabelle nennt Zähne für die
  Ausgabe-Größen (`:141`), keinen für die Quelle, an der die Abdeckungszahl hängt.
- `failure-szenario`: Der `SubagentStart`-Block fällt bei einer späteren Änderung an
  `.claude/settings.json` heraus. `make gates` und `make mutate` bleiben grün, das Fenster des
  Auswerters endet still am letzten Spawn, und die Abdeckungszahl meldet für alles danach
  entweder nichts oder 100 % über einem leeren Fenster.
- `verifizierbar`: ja — `grep -rl "settings.json" test/mutations/` (ein Treffer, und der zeigt
  auf `internal/emit/templates/`), danach `make mutate` nach Entfernen des Blocks: keine
  Rotfärbung erwartbar.

### F-11 — Die Ereignis-Menge ist an drei weiteren Fundstellen in zwei lebenden Artefakten unvollständig geblieben

- `kategorie`: **LOW**
- `quelle`: Maintainability · Repo-Regel *Korrektur an allen Vorkommen* (Befund nennt Fundort,
  nicht Fundmenge)
- `pfad`: `docs/plan/planning/welle-09-modul-15-konformitaet.md:54` und `:169` ·
  `docs/plan/planning/open/slice-067-pretooluse-ausgabeform.md:70-72`
- `befund`: **Prüfbereich: alle getrackten Dateien außer `docs/reviews/**`,
  `docs/plan/planning/done/**`, `.harness/state/**`, `.harness/baseline/**` und der vendored
  Referenz** — acht Dateien nennen `PostToolUseFailure`, davon treffen fünf eine Aussage über
  die verdrahtete Ereignis-Menge. Zwei sind in F-2 erfasst (`spec/spezifikation.md`,
  `ADR-0012` — letztere ist Accepted und nach §3.4 nicht zu ändern). Offen bleiben:
  welle-09 (*„Seit slice-059 … entstehen sie, und zwar an `PostToolUse`/`PostToolUseFailure`"*
  bzw. *„Der Emitter läuft an `PostToolUse`/`PostToolUseFailure`"*) und slice-067
  (*„die anderen Hook-Ereignisse dieses Repos (`PostToolUse`, `PostToolUseFailure`, `Stop`)"*).
  Die fünfte ist der slice-066-Plan selbst (`:75-76`); seine Aussage ist als **datierte
  Ist-Messung vor** der Verdrahtung korrekt und bleibt stehen. Die beiden Go-Testdateien führen
  nur Fixtures, keine Mengen-Aussage; die Go-Quellen enthalten keine Ereignis-Liste (der Emitter
  ist tatsächlich ereignis-generisch).
- `failure-szenario`: slice-067 wird nach seiner Zeile *„Was NICHT dazugehört"* umgesetzt und
  lässt den `SubagentStart`-Block bei der Ausgabeform-Umstellung unbetrachtet.
- `verifizierbar`: ja, ohne Gate — der oben genannte `git ls-files | xargs grep -l`-Lauf.

### F-12 — „1.101 = 864 + 236" geht nicht auf

- `kategorie`: **LOW**
- `quelle`: [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
- `pfad`: `docs/plan/planning/in-progress/slice-066-telemetrie-auswertung.md:147`, Punkt (3)
- `befund`: Der Plan schreibt *„Rollenlose Calls (1.101 = 864 Haupt-Strom + 236 in
  `general-purpose`-Subagenten)"*; die Summanden ergeben 1.100. Die Größenordnung ist belegt
  (eigene Rekonstruktion zum Stand 2026-08-03: 879 Haupt-Strom-Spans + 236
  `general-purpose`-Spans = 1.115 Spans mit leerem `agent_role`), die angegebene Identität
  aber nicht.
- `failure-szenario`: Ein Verifier rechnet die Zeile nach, findet die Differenz und kann nicht
  entscheiden, welcher der drei Werte der gemessene ist.
- `verifizierbar`: ja, ohne Gate — Nachrechnen der Zeile.

### F-13 — Das im Plan genannte Dateinamens-Muster trifft den Ist-Bestand nicht

- `kategorie`: **LOW**
- `quelle`: Maintainability · `spec/spezifikation.md:302-309` (*„eine Auswertung gruppiert nach
  den **Feldern**, nie nach dem Dateinamen"*)
- `pfad`: `docs/plan/planning/in-progress/slice-066-telemetrie-auswertung.md:83-85`
- `befund`: Der Plan nennt als Ablageform `<session>-<agentid>.jsonl`. Real heißt die Datei
  `87e98370_313e_4a2a_a686_0cebf298b8b8-a11add93f4fd7ab37.jsonl` — der Sitzungs-Anteil ist
  unterstrich-normalisiert, die Session-ID im Feld trägt Bindestriche. Die Schlussfolgerung des
  Absatzes (*„über **alle** Ströme zu zählen"*) bleibt richtig.
- `failure-szenario`: Der Auswerter leitet aus dem Muster einen Glob oder eine Session-Zuordnung
  über den Dateinamen ab und verletzt damit die bindende Regel aus §5, dass nach Feldern
  gruppiert wird.
- `verifizierbar`: ja, ohne Gate — `ls .harness/state/spans/ | head`.

### F-14 — Die übernommene Antwort in slice-071 beschreibt die Entstehung ihrer eigenen Zeile und lässt einen Satzbruch stehen

- `kategorie`: **LOW**
- `quelle`: Maintainability
- `pfad`: `docs/plan/planning/open/slice-071-cache-zaehler-getrennt.md:96`
- `befund`: Die Zeile schließt mit *„Die ursprüngliche Regel dieser Zeile — wer zuerst läuft,
  entscheidet sie, der zweite übernimmt die Antwort — zwei Ausgaben über verschieden großen
  Beständen wären nicht vergleichbar"*. Der Nachsatz hängt ohne Bezug, und die Zeile spricht
  über ihre eigene frühere Fassung statt über die Sache.
- `failure-szenario`: Der Implementer von slice-071 liest die Zeile und kann nicht entscheiden,
  ob die „ursprüngliche Regel" noch gilt oder ersetzt wurde.
- `verifizierbar`: ja, ohne Gate — `sed -n '96p' docs/plan/planning/open/slice-071-cache-zaehler-getrennt.md`.

### F-15 — Der beauftragte Commit-Bereich schließt einen der vier benannten Commits aus, und er berührt eine vierte Datei

- `kategorie`: **INFO**
- `quelle`: Reviewer-Skill §Eingangs-Kontext (Diff/Commit-Range als Pflicht-Punkt)
- `pfad`: Auftrag *„Commit-Range `e561878..HEAD`"* gegen die dort genannte Commit-Liste
- `befund`: `e561878..HEAD` enthält drei Commits; `e561878` selbst — der Commit, der Frage A
  entscheidet — liegt außerhalb. Geprüft wurde deshalb `e561878^..HEAD`. Der Bereich berührt
  zudem `docs/plan/planning/open/slice-071-cache-zaehler-getrennt.md`, das die Scope-Liste des
  Auftrags nicht führt; die Datei ist mitgeprüft (F-14).
- `verifizierbar`: ja, ohne Gate — `git log --oneline e561878..HEAD` (drei Zeilen) gegen
  `git diff --stat e561878..HEAD` (drei Dateien).

### F-16 — Der Lifecycle-Move nach `in-progress/` nennt eine Bedingung, deren Beleg zwei Minuten später entsteht

- `kategorie`: **INFO**
- `quelle`: `modul-05-planning-harness.md` §Trigger je Lifecycle-Übergang
  (`next→in-progress` — *„Abhängigkeiten gelöst"*) · Repo-Grundsatz *Doc führt, Code folgt*
- `pfad`: `a747617` (2026-08-03 21:09:45, *„next -> in-progress (WIP-Limit frei, Frage A
  entschieden)"*) gegen `e561878` (21:12:04, *„Frage A entschieden"*)
- `befund`: Der Move begründet sich mit einer Entscheidung, deren Artefakt zum Zeitpunkt des
  Moves noch nicht im Repo lag. Der Abstand beträgt zwei Minuten und dieselbe Sitzung; der
  Befund steht als Muster, nicht als Substanzvorwurf, und der Commit liegt außerhalb des
  beauftragten Bereichs.
- `verifizierbar`: ja, ohne Gate — `git log --format='%h %ad %s' --date=iso a747617 e561878`.

### F-17 — Plan-Eintrag und Änderung liegen in demselben Commit; die zwei gemessenen Präzedenzfälle trennen sie

- `kategorie`: **LOW**
- `quelle`: [`CLAUDE.md`](../../CLAUDE.md) / Greenfield-Grundsatz *Doc führt, Code folgt* ·
  `modul-05-planning-harness.md` §Ziel-Form: Slice (die Plan-Tabelle ist ein Vor-Code-Artefakt)
- `pfad`: `faa3631` (ändert `.claude/settings.json` **und** die Plan-Tabellen-Zeile
  `docs/plan/planning/in-progress/slice-066-telemetrie-auswertung.md:140` in einem Zug)
- `befund`: Bei den beiden vergleichbaren Vorgängen ging der Plan-Eintrag der Änderung in einem
  eigenen, früheren Commit voraus — slice-059: Plan-Zeile `022b2c1` (2026-07-28 09:44) vor der
  Verdrahtung `e07624a` (16:22); slice-060: Plan-Zeile `b093502` (2026-07-29 19:14) vor dem
  Guard-Commit `dd15b02` (2026-07-30 06:20). Hier entstehen Plan-Zeile und Verdrahtung
  gemeinsam; die Tabelle dokumentiert die Änderung, statt ihr vorauszugehen.
- `failure-szenario`: `git log` lässt nicht mehr unterscheiden, ob die Berührung der
  Durchsetzungsschicht geplant war oder als Seiteneffekt der Messung entstand — genau die
  Unterscheidung, die die Plan-Tabellen-Zeile laut ihrer eigenen Begründung herstellen soll
  (*„gehört deshalb in diese Tabelle, nicht in einen stillen Seiteneffekt"*).
- `verifizierbar`: ja, ohne Gate —
  `git show --stat faa3631` gegen
  `git log --follow -S'Event(s) und **Matcher** verdrahten' -- docs/plan/planning/done/slice-059-telemetrie-erfassung-hook.md`.

## Negativbefunde

- geprüft, ohne Befund: **`AGENTS.md` §3.1 (halluzinierte Gates)** — der Plan nennt
  `make gates`, `make mutate`, `make test`, `make span-clean`; alle vier existieren im
  `Makefile` (`test:` `:47`, `mutate:` `:121`, `span-clean:` `:261`, `gates:` `:270`). Die Plan-Tabelle lehnt für den Bericht
  ausdrücklich ein Gate ab und begründet es mit `LH-QA-01`. Der `settings.json`-Diff fügt kein
  Gate hinzu.
- geprüft, ohne Befund: **`AGENTS.md` §3.4 (ADRs immutabel)** — `git diff --stat e561878^..HEAD`
  zeigt drei Dateien, keine unter `docs/plan/adr/`. `ADR-0011`/`ADR-0012` sind unangetastet.
- geprüft, ohne Befund: **`AGENTS.md` §3.5 (keine Gate-Lockerung ohne ADR)** — die vollständige
  `.claude/settings.json` (70 Zeilen) gelesen: beide `PreToolUse`-Guards, der `Stop`-Hook und
  die zwei bestehenden Emitter-Blöcke sind unverändert; hinzugekommen ist ausschließlich ein
  additiver Ereignis-Block. Keine Schwellen-Senkung, keine Matcher-Verengung, kein entfernter
  Guard.
- geprüft, ohne Befund: **`AGENTS.md` §3.3 (Move und Rewrite getrennt)** — im Bereich liegt kein
  `git mv`.
- geprüft, ohne Befund: **Repo-Regel „bindender Spec-Text trägt keine Slice-Kennung"** —
  `grep -n "slice-[0-9]" spec/spezifikation.md` liefert **null** Treffer; die Treffer in
  `spec/lastenheft.md` liegen ausnahmslos in der `## Historie`-Tabelle und entsprechen der
  Fußabdruck-Form aus `MR-015`. DoD (3) formuliert die Regel korrekt und schließt die nackte
  `slice-`-Kennung ausdrücklich mit ein.
- geprüft, ohne Befund: **`MR-015` (Change Request)** — der Geltungsbereich ist
  `spec/lastenheft.md` §7 Historie und die Commit-Disziplin um diese Datei. Der Bereich ändert
  `spec/lastenheft.md` nicht; für die Durchsetzungsschicht greift `MR-015` nicht. Ein CR ist
  für die `settings.json`-Änderung **nicht** erforderlich.
- geprüft, ohne Befund: **Präzedenz früherer `.claude/settings.json`-Änderungen** —
  `git log -- .claude/settings.json` führt acht Commits (`f7576ca`, `38deae8`, `667e920`,
  `c27e549`, `e07624a`, `01fe699`, `dd15b02`, `faa3631`). Drei Slices stehen dahinter, und jeder
  führt die Datei in seiner Plan-Tabelle: slice-007 (`:62`), slice-059 (`:166`), slice-060
  (`:215`); die übrigen vier sind Bootstrap- bzw. `MR-004`/`MR-005`-Commits ohne Slice-Tabelle.
  **Keiner** der acht trug einen eigenen ADR oder CR. *(slice-031/032 fassen `.claude/settings.json`
  nicht an — sie ändern die **emittierte** Vorlage `internal/emit/templates/enforce/settings.json`;
  das ist die andere Ebene.)* Ein Plan-Tabellen-Eintrag ist damit die etablierte und
  ausreichende Form; offen bleiben allein die Reihenfolge (F-17) und die ADR-Pflicht aus F-2.
- geprüft, ohne Befund: **`MR-002`** — der Eintrag beschreibt die adoptierte Mechanik
  (`PreToolUse`-Guard, `Stop`-Gate), nicht eine abschließende Ereignis-Liste; er wird durch die
  Erweiterung nicht falsch. Der Nachzug der Ausgabeform je Ereignis ist bereits slice-067
  zugeordnet.
- geprüft, ohne Befund: **`ADR-0011` §Festlegung 6 (Telemetrie fail-open)** — die vendored
  Referenz belegt für `SubagentStart` „nicht blockierbar" (`:731`, `:2130`) und stderr-Anzeige
  ohne Abbruch (`:746`); der neue Block nutzt dasselbe Binary mit demselben `timeout: 5` wie
  `PostToolUse`. Die fail-open-Eigenschaft bleibt gewahrt.
- geprüft, ohne Befund: **`ADR-0003` (Docker-only)** — der Plan hält den Auswerter als
  Go-Binary in derselben Linie fest und schließt ein Subkommando des Produkt-Binaries aus;
  dieser Review hat keine Host-Toolchain benutzt (nur `git`, `jq`, `awk`, `sed`, `grep`).
- geprüft, ohne Befund: **„kein Code" für die Verdrahtung** — `grep` über `internal/` und
  `cmd/` findet keine Ereignis-Liste; `internal/span/span.go:86-87` liest `agent_id` und
  `agent_type` generisch aus der Payload, `emit.go:101-102` normalisiert über
  `roleFromAgentType`. Die Behauptung der Plan-Tabelle trifft zu.
- geprüft, ohne Befund: **`seq`-Nummernkreis** — der `SubagentStart`-Span belegt `seq 1` im
  eigenen Strom des Subagenten, die folgenden `PostToolUse`-Spans zählen ab 2 weiter (beide
  gemessenen Ströme). Keine Doppelvergabe, keine Lücke; die bindende Regel aus
  `spec/spezifikation.md:302-309` (Eindeutigkeit je Datei) bleibt erfüllt.
- geprüft, ohne Befund: **Frage A, Punkte (1)–(3)** — der Tool-Call-Schlüssel reproduziert zum
  Stand 2026-08-03 **exakt**: implementer 1368 · planner 1323 · reviewer 1004 · architect 449 ·
  verifier 364 (Summe 4.508). Ebenso bestätigt: kein `Agent`-Span trägt `path` (0 von 93);
  das Schreibziel liegt bei 157/879 Haupt-Strom-Spans (Plan: 156/864, frühere Messung);
  `slice` ist eindeutig belegt (alle Träger genau ein Wert, vier verschiedene Werte zum
  Stichtag). Die Ableitung *„anteilig nach Tool-Calls"* liefert Rollen, *„dem auslösenden Slice
  zugeschlagen"* nicht — das Argument trägt.
- geprüft, ohne Befund: **Frage B, Punkte (1)–(3) und der Preis** — zum Stand 2026-08-03
  reproduzieren alle Zahlen: 3 `Agent`-Läufe im laufenden Strom, 2 mit null Token im
  gemessenen Strom, **70** zähler-tragende Läufe über den Bestand, **95,1 %** der Token aus
  einer Sitzung, der größte Strom über fünf Kalendertage (2026-07-29…08-02). Der Bestand reicht
  bis 2026-07-29T08:01:32Z zurück. Die Entscheidung *„der Bestand"* ist gegen den Bestand
  haltbar.
- geprüft, ohne Befund: **Übernahme der Antwort durch slice-071** — die Zeile trägt die Antwort
  als übernommen aus, nicht als eigenständig entschieden, und verweist auf die Messung in
  slice-066. Inhaltlich korrekt (der Formmangel steht als F-14).
- geprüft, ohne Befund: **Modul 5 §Größen-Regeln** — der Slice führt weiterhin drei
  Sach-DoD-Punkte plus die drei Standard-Punkte und berührt `cmd/`/`internal/`, `Makefile`,
  `spec/`, `test/`, `.claude/` — die Grenze „≤ 3 DoD-Punkte, höchstens zwei Schichten" ist nicht
  überschritten; §8 (Sub-Area-Modus) ist vorhanden und unverändert.
- geprüft, ohne Befund: **`test/mutations/`-Nummernkreis** — 135 Fälle, höchste vergebene
  Nummer 139; keine Kollision mit den in `95952b1` angekündigten 140+.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 3 |
| MEDIUM | 7 |
| LOW | 5 |
| INFO | 2 |

## Verdikt

**NICHT KONFORM.**

**Merge-blockierend:** ja — F-1, F-2 und F-3 sind HIGH; F-4 bis F-10 sind vor der Freigabe zu
klären. Es gibt keinen Code zu mergen; blockiert ist der **Beginn** der Implementierung.

**Der Kern ist F-1, und er ist ein Rollen-Konflikt.** Die Fenster-Pflicht ist keine
Klarstellung, sondern eine vierte Zusage in derselben Ausgabe — der Plan trennt sie selbst vom
Nenner aus DoD (2) und kann deshalb dessen Zahn nicht mitbenutzen (F-4). Sie ist in der
Implementer-Rolle entstanden, in demselben Kontext, der das auslösende Problem gefunden hat,
und `ADR-0012` §Folgepflicht 4 spricht den Slice-Plan ausdrücklich dem Planner zu. Nach Modul 8
§Konflikt-Pfad ist das ab HIGH mit Rollen-Widerspruch als **Sequenz mit Übergabe-Artefakten**
zu behandeln; die Verdikt-Zeile *„Reviewer-Finding herabstufen, weil der Implementer
widerspricht"* ist dort ausdrücklich der falsche Pfad. Übergabe-Artefakt dieses Reports ist
dieser Report.

**Zur zweiten Prüffrage:** die Kollision zwischen Frage B (*der Bestand*) und einer
Bezugsgröße, die es erst seit dem 2026-08-08 gibt, ist mit *„die Ausgabe nennt ihr Fenster"*
**ehrlich, aber nicht aufgelöst**. Die Abdeckungszahl deckt nach dieser Auflösung 1 von 93
`Agent`-Spans (F-6), sie hat keine rechte Kante (F-5), und ihre zweite Quelle ist für den
zählerlosen Fall — den einzigen, für den sie existiert — unvermessen (F-3). Der Widerspruch
verlangt eine Entscheidung, die der Plan nicht trifft, und sie gehört dem Planner.

**Zur dritten Prüffrage:** ein Plan-Tabellen-Eintrag ist für `.claude/settings.json` die
etablierte und ausreichende Form — die drei früheren Slices an dieser Datei (007, 059, 060)
liefen genau so, ohne CR und ohne eigenen ADR; `MR-015` greift nicht (er gilt
`spec/lastenheft.md`). Ein eigener Slice ist ebenfalls nicht verlangt: die Änderung ist
additiv und kostet keinen Code. Was fehlt, ist nicht die
Form, sondern die von `ADR-0012` an genau diesen Vorgang gebundene Pflicht: Schlüsselmenge
messen und in `spec/spezifikation.md` §5 nachtragen (F-2). Bis dahin sagt der Rang-2-Text
„zwei Ereignisse", während drei verdrahtet sind.

**Zur vierten Prüffrage:** Frage A und Frage B sind gegen den Bestand **im Kern haltbar** —
der Tool-Call-Schlüssel und sämtliche Frage-B-Zahlen reproduzieren zum Stichtag exakt.
Überholt ist Punkt (4) von Frage A: der Sammelposten ist seit dem Mess-Aufruf dieses Slice
nicht mehr leer (F-7). Falsch etikettiert ist die Bezugsmenge in Punkt (2) (F-8), und die
Summanden-Identität in Punkt (3) geht nicht auf (F-12).

**Kann der Code jetzt beginnen? Nein.** Zu klären sind vorher, in dieser Reihenfolge: der
Rollen-Weg für die Fenster-Pflicht (F-1), der ADR-0012-Nachtrag (F-2) und die Messung der
zweiten Quelle im Hintergrund-Fall (F-3) — Letztere entscheidet, ob DoD (1) überhaupt baubar
ist oder ob die im Plan bis `95952b1` vorgesehene Rückführung `in-progress → next` greift.

**Übergabe:** Findings gehen an die Implementation, die HIGH-Befunde F-1 und die daraus
folgende Plan-Frage über die Rückkante an den Planner. Der Report ersetzt keine Verifikation —
DoD-/Spec-Konformität prüft der Verifier separat (Modul 11, anderes Prüf-Artefakt, anderer
Eingabe-Kontext). Eine Bestätigungsrunde bekommt eine **neue** Datei, dieser Report wird nicht
überschrieben.

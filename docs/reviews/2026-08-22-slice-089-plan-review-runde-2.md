# Review-Report: slice-089 (Plan, Runde 2) — 2026-08-22

**Review-Art:** **Plan** — geprüft wird der Plan gegen Spec und Accepted-ADRs, *bevor*
implementiert wird (Modul 10 §Drei Review-Arten). Zweite Runde: geprüft wird der **Nachzug** des
Planners gegen die Findings der ersten Runde, nicht gegen seine Commit-Message.

**Gegenstand:** `ee9ed1e` (`0b9013e..HEAD`), **zwei** Dateien, beide Planner-Artefakte:
`docs/plan/planning/open/slice-089-carveout-co-002-ueberfuehren.md` (+137/−…) und
`docs/plan/planning/welle-09-modul-15-konformitaet.md` (+88/−…). Der Wellen-Plan ist in dieser
Runde **zum ersten Mal Gegenstand**. Baum sauber beim Start.

**Skill:** `.harness/skills/reviewer.md` @ 1.4.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5[1m] · **Datum:** 2026-08-22

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde):

- die zwei geänderten Planner-Artefakte im Stand `ee9ed1e`, dazu `git show ee9ed1e`
- **Runde 1:** [`2026-08-22-slice-089-plan-review.md`](2026-08-22-slice-089-plan-review.md)
  (`0b9013e`) — 0 HIGH · 2 MEDIUM · 4 LOW · 3 INFO
- **aktive ADRs:** [`ADR-0021`](../plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md)
  (**Accepted**, Festlegung 5 + sieben Folgepflichten),
  [`ADR-0015`](../plan/adr/0015-rollen-eigentum-an-norm-artefakten.md) (**Accepted** — in dieser
  Runde neu zitiert, deshalb am Wortlaut geprüft),
  [`ADR-0012`](../plan/adr/0012-haupt-kontext-ohne-token-bilanz.md),
  [`ADR-0019`](../plan/adr/0019-agent-guard-prueft-die-aufrufform.md),
  [`ADR-0020`](../plan/adr/0020-emittierte-modul-15-regeln.md)
- **`LH-*`:** [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
- **weitere Verträge:** [`CO-002`](../plan/carveouts/CO-002-token-achse-je-rolle.md),
  [`docs/plan/carveouts/README.md`](../plan/carveouts/README.md),
  [`spec/spezifikation.md`](../../spec/spezifikation.md) §5,
  `.claude/hooks/pretooluse-agent-guard.sh`,
  [`docs/plan/planning/in-progress/roadmap.md`](../plan/planning/in-progress/roadmap.md),
  [slice-071](../plan/planning/open/slice-071-bilanz-nennt-ihren-bestand.md),
  [`harness/conventions.md`](../../harness/conventions.md)
  [`MR-016`](../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird),
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
- **Hard Rules:** [`AGENTS.md`](../../AGENTS.md) §2, §3.3 · §3.4 · §3.6 · §3.7 · §3.8, §4
- Regelwerk `v3.5.2`: `modul-05-planning-harness.md`, `modul-06-*`, `modul-07-carveouts.md`,
  `modul-10-review-harness.md`

## Selbst gefahren (nichts aus der Commit-Message übernommen)

| Kommando | Ergebnis | Behauptung | Urteil |
|---|---|---|---|
| `git ls-files \| xargs grep -ln 'CO-002' \| grep -vc -e '^docs/reviews/' -e '^docs/plan/planning/done/' -e '^\.harness/baseline/'` | **13** | §1: „**13** lebende Dateien" | **stimmt** (exakt das Kommando aus dem Plan) |
| `grep -c 'CO-002' docs/plan/planning/open/slice-071-cache-zaehler-getrennt.md` | **10** | §6 und welle-09 §3: „auf **10** Zeilen" | **stimmt** |
| `grep -n '^## ' docs/plan/carveouts/CO-002-token-achse-je-rolle.md` | u. a. `133:## Verifikation (nach Auflösung)`, `145:## Geschichte` | DoD (1): „beginnt bei **133** … `## Geschichte` bei **145**" | **stimmt** |
| `grep -n 'd-check:ignore' <dieselbe Datei>` | **142** | DoD (1): „steht heute auf Zeile **142**" | **stimmt** |
| `grep -c 'path: \[\]string' internal/span/response.go` | **9** | DoD (3): „→ **9**" | **stimmt**; zusätzlich geprüft, dass der **Gegenstand** derselbe ist — die neun Listen-Einträge stehen 1:1 zu den neun Werten des `mustContain`-Blocks (`response_test.go:105-110`), also kein „ungefähr passendes Kommando" |
| Lesung der Gegenprobe `response_test.go:181` | `SpawnedRole`, `TotalTokens`, `InputTokens`, `ModelVersion` | DoD (3): „**vier** … (`SpawnedRole`, `TotalTokens`, `InputTokens`, `ModelVersion`) … an der Gegenprobe gelesen, nicht gezählt" | **stimmt**, und die Lücken-Kennzeichnung ist die von `MR-025` verlangte |
| `ls .claude/agents/` | **6** (architect, implementer, planner, reviewer, validator, verifier) | Datei-Tabelle: „führt **sechs** Rollen und keine dieses Namens" | **stimmt** |
| `ADR-0015` §Entscheidung Festlegung 1 verbatim | *„Wo eine Quelle die schreibende Rolle benennt, gilt sie unverändert; wo keine sie benennt, bleibt das eine offene Frage, die diese Verengung ausdrücklich stehen lässt."* | Plan zitiert sie für „schreibende Rolle offen" | **Zitat trifft** — keine erfundene Quelle, keine erfundene Festlegungs-Nummer |
| `grep -rn ']([^)]*open/slice-089-…\.md)' --include='*.md' docs` | **6** Zeilen in **3** Dateien (4 + 1 unter `done/`, 1 in welle-09) | §5: „**6** Zeilen in **3** Dateien — zwei Zeitdokumente … und der Wellen-Plan" | **stimmt** |
| `grep -rn 'CO-002-token-achse-je-rolle\.md#' --include='*.md' .` | leer, Exit 1 | §6: „**leer (Exit 1)**, kein Verweis zielt auf einen Abschnitt des Stubs" | **stimmt** |
| `ls docs/plan/carveouts/CO-*.md \| wc -l` | **2** | welle-09 §3: „zählt deshalb weiter **2** — diese Zahl bewegt sich mit der Überführung **nicht**" | **stimmt**; die Zahl ist nicht als Erwartungswert gesetzt, sondern durch das Status-Kommando **ersetzt** (`MR-025` Setzung 2, zweite Variante) |
| `grep -n '^\*\*Status:' docs/plan/carveouts/CO-*.md` | zwei Treffer, beide `**Status:** Aktiv.` | welle-09 §3: „Wer *aktiv* von *entschieden* trennen will, liest den Kopf" | **stimmt** — das Kommando trennt, die Datei-Zählung nicht |
| `grep -n 'beiden Ausgängen' docs/plan/planning/welle-09-modul-15-konformitaet.md` | Exit 1 | „der falsche Satz ist **ersatzlos weg**" | **stimmt** |
| `grep -q '0021' docs/plan/planning/welle-09-modul-15-konformitaet.md` | Exit 0 | §3: „Prüfbar statt zugesagt … **Exit 0**" | **stimmt** |
| `grep -n 'slice-089' docs/plan/planning/in-progress/roadmap.md` | Exit 1 | `MR-016` Setzung 2/3: kein Roadmap-Eintrag | **stimmt**, unverändert korrekt geführt |
| `git show --stat ee9ed1e` | genau **2** Dateien, beide unter `docs/plan/planning/` | §3.4: die ADR darf nicht angefasst sein | **stimmt** — `docs/plan/adr/` ist im Commit nicht enthalten |
| `make docs-check` | `342 Datei(en) geprüft, 0 Befund(e)`, Exit 0 | — | grün am geprüften Stand |

---

## Findings

### Status der Runde-1-Findings

| Runde 1 | Kategorie | Status | Beleg |
|---|---|---|---|
| **F-1** — §1-Ziel breiter als die DoD | MEDIUM | **behoben** | §1 ist auf Stub, Index und **die sechs Stellen** verengt; der neue Absatz *„Was das Ziel NICHT umfasst"* nennt die 13 mit Kommando und `MR-025`-Kennzeichnung, sagt ausdrücklich *„die übrigen deckt dieser Slice nicht"* und benennt die zwei mit offener Schwelle. Beide stehen in §6 **mit Träger**: Roadmap und slice-071 als Planner-Arbeit am lebenden Plan (getragen von welle-09 §3), die ausgelöste Rückführung von slice-071 als **Architect**-Frage, und die Gegenrichtung (der Prosa-Verweis auf die gestrichene Liste). Die Datei-Tabelle führt beide als **unverändert** mit Grund. Die Lücken-Nennung *„wie viele davon die Schwelle als offen führen, trennt kein Kommando — das ist von Hand zu lesen"* steht in §6, nicht in §1; sie ist damit vorhanden, aber an einer anderen Stelle als die Commit-Message angibt. **Es wird nicht umbenannt, was vorher versprochen war** — der Geltungsbereich ist wirklich verkleinert, und was herausfällt, ist beziffert und adressiert. |
| **F-2** — vertagte Folgepflichten ohne Träger | MEDIUM | **behoben, mit einem Rest (G-1)** | Alle sechs Stellen im Wellen-Plan geprüft: (1) §3 Carveout-Audit liest den **Status** mit Kommando, und die Datei-Zählung ist als untauglich benannt; (2) der Satz *„in beiden Ausgängen in `done/`"* ist weg (Exit 1); (3) neuer §3-Punkt zu den zwei Zellen mit **ADR-Verdikt**, der Reihenfolge (Kopf-Status **vor** den Zellen), dem Prüfkommando und der Nicht-Mitgliedschaft von slice-089; (4) neuer §3-Punkt zu den zwei lebenden Artefakten samt Architect-Frage; (5) §4-Zeile zu slice-071 sagt *„diesen Trigger gibt es nach `ADR-0021` nicht mehr"*; (6) §4-Prosa an drei weiteren Stellen nachgezogen (Block-3-Absatz, Vordergrund-Absatz, die zwei Closure-Kriterien-Bullets). Der Träger existiert und ist mit `grep -q '0021' …` → Exit 0 belegt. **Rest:** eine siebte Stelle im selben Abschnitt ist stehengeblieben — G-1. |
| **F-3** — falsche Zeilen-Begründung | LOW | **behoben, mit einem Rest (G-3)** | Der dritte Sensor ist jetzt als *„Gegenprobe auf einen der fünf Haken"* geführt und sagt ausdrücklich *„Sie deckt die Streichung des Abschnitts nicht"*; 133 / 142 / 145 sind gemessen korrekt, die Kommandos stehen daneben. **Rest:** der Einleitungssatz desselben Blocks — G-3. |
| **F-4** — Zahlen ohne Kommando in DoD (3) | LOW | **behoben** | „neun" trägt `grep -c 'path: \[\]string' internal/span/response.go` → 9 (und misst den Gegenstand, nicht sein Umfeld — Korrespondenz zu den neun `mustContain`-Werten in diesem Lauf geprüft); „vier" ist mit den Feldnamen benannt **und** ausdrücklich als *„an der Gegenprobe gelesen, nicht gezählt: kein Kommando trennt sie"* markiert — genau die von `MR-025` Setzung 1 verlangte Lücken-Nennung. |
| **F-5** — erfundene Rolle *Spec-Eigentümer* | LOW | **behoben** | Die Spalte führt *„Implementer — schreibende Rolle offen"*; die Zelle nennt die Herkunft des Begriffs (die Folgepflicht), misst die sechs vorhandenen Rollen und zitiert `ADR-0015` Festlegung 1 wörtlich zutreffend. Die Rückführung in §4 adressiert nicht mehr einen Namen ohne Träger, sondern *„die Rolle, die dieses Stratum schreibt"* mit dem Zusatz, dass die Frage **vor** dem Eintritt zu klären ist. |
| **F-6** — Grund (a) trug für Folgepflicht 4 nicht | LOW | **behoben** | Der Grund ist auf Folgepflicht 3 eingeschränkt, und der Plan sagt es ausdrücklich: *„Für Folgepflicht 4 trägt der Grund nicht: die Audit-Regel hat einen Gegenstand, sie steht im §3 des Wellen-Plans."* Die Einleitung ist mitgezogen (*„der erste Grund unten gilt allein Folgepflicht 3, die zwei folgenden tragen für beide"*). |
| **F-7** — Folgepflicht 6 ungenannt | INFO | **behoben** | Der Bezug führt die verbleibenden zwei jetzt *„benannt statt weggelassen"*, und die Datei-Tabelle hat eine `internal/emit/`-Zeile als **unverändert** mit Grund. |
| **F-8** — Verlust einer Ziel-Form-Sektion | INFO | **behoben** | Eigener §6-Punkt; die Streichung ist als ADR-gebunden benannt, die Folge (kein Struktur-Modul, Begründung des fehlenden Adaptions-Eintrags gilt der Ablage-Frage) ausgesprochen, und die Entscheidung ausdrücklich **nicht** in diesem Slice getroffen. |
| **F-9** — DoD (2) grün ohne Handgriff | INFO | **behoben** | Wörtlich: *„es ist heute grün, nach einem korrekten Nachzug grün — und nach **null** Handgriffen ebenfalls grün"*, dazu die Trennung Verbots-/Gebots-Seite. |

### G-1 — Der Wellen-Plan widerspricht sich über den Wert der Zelle *Token-Attribution × Repo*: §3 und die Closure-Kriterien sagen *ADR-Verdikt*, die §4-Tabelle sagt weiter *„deklariert" mit Auflösungs-Trigger*

- `kategorie`: **MEDIUM**
- `quelle`: [`ADR-0021`](../plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) Festlegung 1
  (*„kein Auflösungs-Trigger"*) und Folgepflicht 3 · [`AGENTS.md`](../../AGENTS.md) §3.6
- `pfad`: `docs/plan/planning/welle-09-modul-15-konformitaet.md:210` (slice-068-Zeile der
  §4-Tabelle) gegen `:136-137` (§3) und `:245-246` (§4-Closure-Kriterien); Vokabular `:104`
- `befund`: §3 führt seit diesem Commit *„Die zwei Zellen der Repo-Spalte … tragen *ADR-Verdikt*:
  *Token-Attribution × Repo* (Hintergrund-Teil) und *Cache-Counter × Repo*"*, und der
  Closure-Kriterien-Absatz in §4 wiederholt *„beide tragen **ADR-Verdikt**"*. Die **definierende**
  Zeile derselben Zelle in der §4-Tabelle ist nicht mitgezogen: sie sagt weiter, slice-068
  *„legt … fest, dass ihre Belegart zweigeteilt ist: der Hintergrund-Teil trägt ‚deklariert' mit
  Auflösungs-Trigger"*. Die Nachbarzeile (slice-071) **ist** gezogen — die Korrektur ist an einem
  von zwei Vorkommen stehengeblieben. Der Wert ist zudem nach der Wert-Tabelle desselben Plans
  (`:104`) an einen **Auflösungs-Trigger** gebunden, den `ADR-0021` Festlegung 1 aufgehoben hat:
  *deklariert mit Auflösungs-Trigger* ist für diese Zelle kein zulässiger Wert mehr.
- `verifizierbar`: **ja** — kein Gate deckt es (`make docs-check` ist grün, es bricht kein Link):
  `sed -n '104p;136,137p;210p;245,246p' docs/plan/planning/welle-09-modul-15-konformitaet.md`
  stellt die drei Aussagen nebeneinander. Das Versagen tritt bei der Closure ein: wer die
  §4-Tabelle als Quelle des Zellwerts liest — und sie sagt von sich, dass slice-068 den Wert
  *festlegt* — schreibt *deklariert* in `welle-09-results.md`, gegen eine angenommene ADR. Das ist
  genau der Ausgang, den der neue §3-Punkt verhindern soll.

### G-2 — §5 des Wellen-Plans sagt „Wird blockiert von: nichts", während §3 zwei Bedingungen nennt, an denen die Closure hängt

- `kategorie`: **LOW**
- `quelle`: Regelwerk `v3.5.2` `modul-06-*` (Wellen-Ziel-Form: Abhängigkeiten) ·
  [`AGENTS.md`](../../AGENTS.md) §3.6
- `pfad`: `docs/plan/planning/welle-09-modul-15-konformitaet.md:368-369` gegen `:141-144` und
  `:156-158`
- `befund`: §5 führt unverändert *„**Wird blockiert von:** nichts"* mit einer Begründung, die
  allein die Werkzeug-Lage betrifft (gepinntes d-check-Image, `targets`-Modul). §3 hat in diesem
  Commit zwei Bedingungen bekommen, an denen die Closure hängt: die **Reihenfolge** gegenüber
  slice-089 (*„der Kopf des Stubs trägt den Verdikt-Status, bevor die Ergebnis-Notiz die Zellen
  setzt"*) und eine fällige **Architect**-Frage, von der §3 selbst sagt, das Kriterium *„alle
  Slices dieser Welle in `done/`"* hänge an ihrer Beantwortung. Beides sind Abhängigkeiten von
  fremden Vorgängen; §5 nennt sie nicht.
- `verifizierbar`: **ja** — kein Gate; `sed -n '141,144p;156,158p;364,372p' …` stellt es
  nebeneinander. Versagen: ein Closure-Lauf, der §5 als „was hält uns auf" liest, findet dort
  keine Vorbedingung und beginnt die Ergebnis-Notiz, bevor slice-089 gelandet ist.

### G-3 — Der Einleitungssatz von DoD (1) sagt weiter, jedes der drei Kommandos decke „genau die Änderung, neben der es steht"; drei Zeilen darunter steht, dass das dritte sie nicht deckt

- `kategorie`: **LOW**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 (Zusage und ihr Sensor) ·
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
- `pfad`: `docs/plan/planning/open/slice-089-carveout-co-002-ueberfuehren.md:86-87` gegen `:89-93`
- `befund`: Der Block beginnt mit *„drei Kommandos …, **jedes deckt genau die Änderung, neben der
  es steht**"*. Die Korrektur aus F-3 hat den dritten Satz ersetzt — er sagt jetzt *„Sie deckt die
  Streichung des Abschnitts **nicht**"* —, den Einleitungssatz aber stehen lassen. Für das dritte
  Kommando gilt die Verallgemeinerung damit nicht mehr; die Datei trägt beide Aussagen
  nebeneinander. Dieselbe Klasse wie G-1: die Korrektur ist an einem Fundort angekommen, an dem
  zweiten nicht.
- `verifizierbar`: **ja** — kein Gate; `sed -n '85,94p' …` zeigt beide Sätze in einem Bildschirm.
  Versagen: ein Verifikations-Lauf liest den Einleitungssatz, behandelt alle drei als deckende
  Kommandos und nimmt einen Stand ab, in dem nur die Haken-Zeile entfernt wurde.

### G-4 — Die Commit-Message schreibt vier Änderungen dem §5 des Wellen-Plans zu; §5 ist unberührt, die vier Stellen liegen in §4

- `kategorie`: **LOW**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 (*„Eine Zusage — Doc-Kommentar, Test-Name,
  DoD-Punkt, **Commit-Message**"*)
- `pfad`: `git show ee9ed1e` (Message, letzter Absatz zu F-2) gegen
  `docs/plan/planning/welle-09-modul-15-konformitaet.md:364` (`## 5. Abhängigkeiten`)
- `befund`: Die Message sagt *„und Paragraph 5 ist an vier Stellen nachgezogen"* und zählt sie zu
  den sechs Trage-Stellen des Wellen-Plans. Gemessen liegt die letzte Diff-Hunk-Grenze des
  Commits bei neuer Zeile **259**, während `## 5. Abhängigkeiten` bei **364** beginnt: **keine**
  Zeile des §5 ist berührt. Die vier gemeinten Stellen liegen sämtlich in §4 (Block-3-Absatz,
  Tabellenzeile slice-071, Vordergrund-Absatz, die zwei Closure-Kriterien-Bullets) — die Arbeit
  ist getan, die Adresse in der Message ist falsch.
- `verifizierbar`: **ja** — `git show ee9ed1e -- docs/plan/planning/welle-09-modul-15-konformitaet.md | grep '^@@'`
  gegen `grep -n '^## ' …`. Versagen: wer die Message als Inhaltsverzeichnis des Nachzugs nimmt,
  prüft §5, findet dort nichts und hält den Nachzug für unvollständig — oder, schlimmer, für
  geleistet, wo er nicht stattgefunden hat (G-2 liegt genau dort).

### G-5 — Der dangling gewordene Prosa-Verweis in slice-071 §6 hat nur in einem künftigen Zeitdokument einen Träger

- `kategorie`: **INFO**
- `quelle`: [`ADR-0021`](../plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md)
  Folgepflicht 1 · Runde 1 F-2 (Trägerschafts-Klasse)
- `pfad`: `docs/plan/planning/open/slice-089-carveout-co-002-ueberfuehren.md:367-371` gegen
  `docs/plan/planning/welle-09-modul-15-konformitaet.md:148-158`
- `befund`: §6 benennt korrekt, dass slice-071 §6 auf die von DoD (1) gestrichene
  Verifikations-Liste zeigt, dass **kein Link bricht** (in diesem Lauf bestätigt: Exit 1) und dass
  der Posten *„in denselben Architect-Lauf"* gehört. Der Wellen-Plan trägt von diesem Bündel die
  **Architect-Frage** und die *„10 Zeilen, von Hand zu lesen"*, nicht aber den dangling
  Prosa-Verweis als eigenen Posten. Nach dem Abschluss steht er allein in dieser Plan-Datei unter
  `done/`. Die Kette trägt trotzdem: derselbe Architect-Lauf öffnet slice-071 ohnehin, und
  welle-09 macht dessen Antwort zur Closure-Bedingung. Genannt, damit die Lücke nicht als
  geschlossen gilt.
- `verifizierbar`: **nein** — kein Gate; Text-Abgleich.

### G-6 — Der Wellen-Plan trägt jetzt einen lifecycle-abhängigen Pfad auf einen Nicht-Mitglieds-Slice; das koppelt ihn an jeden der drei Moves

- `kategorie`: **INFO**
- `quelle`: [`MR-016`](../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
  (Begründung: *„Ihr Zustand **ist** das Verzeichnis"*) · Runde 1 §5-Beobachtung
- `pfad`: `docs/plan/planning/welle-09-modul-15-konformitaet.md:143-144`
- `befund`: §3 verlinkt `[slice-089](open/slice-089-carveout-co-002-ueberfuehren.md)` — mit dem
  **Quellverzeichnis** im Pfad. Die eingehende Menge des Slice ist damit von 5 Zeilen in 2 auf
  **6 Zeilen in 3** Dateien gewachsen (gemessen), und die dritte ist ein **lebendes** Artefakt:
  jeder der drei Lifecycle-Moves macht diesen Link `target-missing`, bis der
  Reconciliation-Commit läuft. Das ist keine Regelverletzung — `MR-016` bindet die Roadmap, nicht
  Wellen-Pläne, der Plan führt slice-089 ausdrücklich als **kein Mitglied**, §5 des Slice hat die
  Zahl nachgezogen, und `make docs-check` erzwingt den Zug. Es ist eine neue Kopplung, die beim
  ersten Move sichtbar wird und hier benannt statt später entdeckt wird.
- `verifizierbar`: **ja** — `make docs-check` nach dem ersten `git mv` von slice-089 wird rot,
  bis der Link gezogen ist.

## Negativbefunde

- **geprüft, ohne Befund — die zwei MEDIUM aus Runde 1 sind an ihrem Gegenstand erledigt.** F-1 ist
  nicht umbenannt, sondern verengt: das Ziel verspricht jetzt genau, was die drei DoD-Punkte
  liefern, die herausfallende Menge ist beziffert (13, mit Kommando und `MR-025`-Kennzeichnung),
  und die zwei Artefakte mit offener Schwelle stehen mit Ort, Eigentümer und Grund in §6 **und**
  im Wellen-Plan. F-2 hat einen Träger bekommen, der außerhalb dieses Slice weiterlebt.
- **geprüft, ohne Befund — die Kernfrage aus Runde 1 bleibt positiv.** An DoD (1), (2) und (3) hat
  dieser Commit nichts am **Gegenstand** geändert — nur Begründungen geschärft. Die Deckung von
  Folgepflicht 1, 2 und 5 aus `ADR-0021` ist unverändert vollständig und wörtlich; die Zahl der
  slice-eigenen DoD-Punkte ist unverändert **drei** (Modul-5-Schranke gehalten); §7 ist leer; die
  §1–§8-Gliederung folgt weiter dem vendored Template.
- **geprüft, ohne Befund — §3.4.** `git show --stat ee9ed1e` führt genau zwei Dateien, beide unter
  `docs/plan/planning/`. Keine ADR ist berührt, auch nicht ihr Status. Die Datei-Tabelle des Plans
  führt `docs/plan/adr/` unverändert weiter als **unverändert** mit Immutabilitäts-Begründung.
- **geprüft, ohne Befund — Rollen-Eigentum des Commits.** Beide geänderten Artefakte sind
  Planner-Artefakte; `AGENTS.md` §3 und der Adaptions-Block sind nicht berührt, die
  Commit-Konstruktion aus [`ADR-0015`](../plan/adr/0015-rollen-eigentum-an-norm-artefakten.md)
  Festlegung 2 ist also nicht ausgelöst. Der Wellen-Plan **weist** dem Architect und dem Planner
  Arbeit zu, ohne sie zu tun — das ist Ansagen, nicht Entscheiden.
- **geprüft, ohne Befund — die neu zitierte Quelle.** `ADR-0015` existiert, ist **Accepted**, und
  Festlegung 1 sagt wörtlich, was der Plan ihr zuschreibt. Präzisierung ohne Finding-Rang: die
  Festlegung lässt die Rolle dort offen, wo **keine** Quelle sie benennt — `ADR-0021`
  Folgepflicht 2 benennt eine (*Spec-Eigentümer*), sie ist nur nicht instanziiert. Die Zelle des
  Plans stellt beide Tatsachen nebeneinander, der Leser wird also nicht in die Irre geführt.
- **geprüft, ohne Befund — `MR-025` über beide Dateien.** Jede Zahl, die in diesem Commit neu
  entstanden ist, trägt ihr Kommando: 13 · 10 · 9 · 6 · 133/142/145 · 6 (Rollen) · 2 (Carveouts).
  Alle sieben Kommandos sind in diesem Lauf gefahren und liefern genau diese Werte. Die zwei
  wandernden Größen sind behandelt: die 13 ausdrücklich als **kein** Erwartungswert, die
  Datei-Zählung der Carveouts durch ein Kriterium **ersetzt**, das den Gegenstand misst
  (`grep -n '^\*\*Status:'`). Die beiden nicht-mechanisierbaren Größen — *„vier der neun"* und
  *„wie viele der 10 Zeilen die Schwelle als offen führen"* — sind als Lesung ohne Kommando
  gekennzeichnet. Das ist die vollständige Form der Setzung, an beiden Dateien.
- **geprüft, ohne Befund — `MR-016`.** slice-089 ist weiter wellenlos geführt, die drei Fragen aus
  Setzung 1 stehen unverändert beantwortet in §3, und die Roadmap trägt keinen Eintrag (Exit 1).
  Der Wellen-Plan führt ihn ausdrücklich als **kein Mitglied** und zitiert Setzung 2 dafür
  korrekt.
- **geprüft, ohne Befund — der Wellen-Plan im Übrigen.** Der Satz, der für beide Carveout-Ausgänge
  `done/` voraussetzte, ist ersatzlos entfernt (Exit 1); kein weiterer Rest im Plan setzt einen
  `done/`-Ausgang für einen übergeführten Carveout voraus (`grep -n 'Auflösungs-Trigger'` über die
  Datei durchgesehen: die verbleibenden Treffer sind die Wert-Definitionen in §3, die
  ADR-0020-Passage in §6 und die jetzt korrekt als aufgehoben beschriebenen Stellen). §3 und die
  Closure-Kriterien in §4 stimmen für *Cache-Counter × Repo* zueinander; die Tool-Spalte ist
  unberührt und trägt weiter die ausdrückliche Nicht-Kopplung an den Carveout. Der einzige
  Widerspruch zwischen §3 und der §4-Tabelle ist G-1.
- **geprüft, ohne Befund — Gates und Sensoren.** `make docs-check` ist am geprüften Stand grün
  (342 / 0). Der Commit legt keinen Gate-Namen an, senkt keine Schwelle und berührt weder
  `Makefile` noch `.d-check.yml` — `LH-QA-01` und §3.5 sind nicht im Spiel; `LH-QA-02` ebenfalls
  nicht (keine Pin-Bewegung).
- **geprüft, ohne Befund — die drei INFO aus Runde 1** sind sämtlich gezogen und in diesem Lauf am
  Text nachgelesen; keine der drei Formulierungen reicht jetzt weiter als ihr Gegenstand.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 1 |
| LOW | 3 |
| INFO | 2 |

Runde 1 → Runde 2: **2 MEDIUM behoben, 4 LOW behoben, 3 INFO behoben**; **1 neues MEDIUM,
3 neue LOW, 2 neue INFO**. Alle neuen Befunde außer G-3 liegen im **Wellen-Plan** bzw. in der
Commit-Message, nicht im Slice-Plan.

## Verdikt

**Merge-blockierend: nein für slice-089 — ja für die Closure von
[welle-09](../plan/planning/welle-09-modul-15-konformitaet.md).**

Die Abweichung von *„MEDIUM blockiert typischerweise"* wird hier begründet, nicht still
entschieden. Das eine MEDIUM (G-1) liegt vollständig in `welle-09-modul-15-konformitaet.md` und
wirkt an **einem** Ort: beim Schreiben der Ergebnis-Notiz jener Welle. Es macht keinen DoD-Punkt
von slice-089 unprüfbar, ändert keine seiner drei Zusagen und berührt seinen Gegenstand nicht.
Umgekehrt gilt: solange die §4-Tabelle den Gegenwert der Zelle führt, ist welle-09 **noch kein
verlässlicher Träger** für Folgepflicht 3 — genau in der Achse, für die Runde 1 den Träger
verlangt hat. Deshalb blockiert es dort und nur dort.

Der Slice-Plan selbst trägt nach dieser Runde **null HIGH, null MEDIUM und ein LOW** (G-3). Die
zwei MEDIUM aus Runde 1 sind an ihrem Gegenstand erledigt, nicht umetikettiert: §1 verspricht
weniger, und was herausfällt, ist gezählt, adressiert und mit Eigentümer versehen.

Wiederkehrende Klasse dieser Runde, als Steering-Signal: **eine Korrektur landet an einem Fundort
und nicht am zweiten** — G-1 (Nachbarzeile derselben Tabelle) und G-3 (Einleitungssatz desselben
Blocks). Dieselbe Klasse hat der Nachzug an anderer Stelle richtig behandelt (die
Einleitung der Ausschlussgründe wurde mit F-6 mitgezogen); sie ist damit keine Unfähigkeit,
sondern ein fehlender Suchlauf über alle Vorkommen vor dem Commit.

**Übergabe:** G-1, G-2 und G-4 gehen an den **Planner** (Wellen-Plan und Commit-Message), G-3 an
den **Planner** (Slice-Plan). G-5 und G-6 sind Hinweise ohne erwartete Aktion. Der Report ersetzt
keine Verifikation — DoD-/Spec-Konformität prüft der Verifier separat (Modul 11).

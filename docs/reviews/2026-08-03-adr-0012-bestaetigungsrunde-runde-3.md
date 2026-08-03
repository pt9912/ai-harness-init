# Review — `ADR-0012` (Proposed), Bestätigungsrunde 3 nach dem Fix der zweiten Runde

## Kopf-Metadaten

| Feld | Wert |
|---|---|
| **Review-Art** | Design-Review (Modul 10 §Drei Review-Arten) — geprüft wird eine Entscheidung gegen Spec, aktive ADRs und Hard Rules, nicht ein Code-Diff |
| **Rolle** | Reviewer (Modul 10), `.harness/skills/reviewer.md` v1.4.0 — Lauf unter dem Rollen-Typ `reviewer`, frischer Kontext |
| **Modell** | claude-opus-5[1m] |
| **Datum** | 2026-08-03 |
| **Diff/Commit-Range** | genau **ein** Commit: `bed3f2f` — `git show --numstat` gefahren: +26/−22 an der ADR, +1/−1 am ADR-Index, +375 der Report der Vorrunde. Gegengelesen: `d021716` (der Fix der ersten Bestätigungsrunde) und `0d4d49b` (der Verweis-Nachzug) |
| **Prüfgegenstand** | `docs/plan/adr/0012-haupt-kontext-ohne-token-bilanz.md` (**304** Zeilen, `wc -l`, Status **Proposed**) + `docs/plan/adr/README.md:20` |
| **Modul-8-Auftrag** | `modul-08-agentenrollen.md` §Rollen-Regeln — *„ADR-Änderung: Architect schreibt; Reviewer prüft auf Konsistenz"*. Der Reviewer entscheidet **nicht** über die Annahme und setzt den Status nicht |
| **`LH-*`** | `LH-QA-01` (in der ADR zweimal zitiert, beide Male als *nicht berührt*), `LH-QA-03` (Alternative E) |
| **Aktive ADRs** | `ADR-0003`, `ADR-0011`, `ADR-0013`, `ADR-0014` — alle **Accepted** (`docs/plan/adr/README.md:11,19,21,22`); keine superseded Referenz |
| **Hard Rules** | `AGENTS.md` §3.1, §3.2, §3.3, §3.4, §3.5, §3.6 (Wortlaut selbst gelesen, `AGENTS.md:51-113`) |
| **Vorherige Findings am gleichen Modul** | `docs/reviews/2026-08-03-adr-0012-bestaetigungsrunde-runde-2.md` (0/3/3/3 — NICHT KONFORM) · `docs/reviews/2026-08-03-adr-0012-bestaetigungsrunde.md` (0/3/4/4 — NICHT KONFORM) · `docs/reviews/2026-07-31-adr-0012-proposed-review.md` (1/4/3/2) |
| **Regelwerk on-demand** | `regelwerk/README.md` (Index), `modul-07-carveouts.md` (**vollständig**, 132 Zeilen), `modul-10-review-harness.md`, `modul-08-agentenrollen.md` |
| **Gate-Lage** | `make docs-check` **selbst gefahren**: `d-check: 289 Datei(en) geprüft, 0 Befund(e)` — deckt sich mit der Gate-Ausgabe des Commits. Der Gate prüft `[links, anchors, ids, matrix, codepaths, spans]`, also **keine Sätze**; `make comment-claims` (`Makefile:135`) lässt jede Markdown-Datei außen vor |

**Prüfmethode.** Jeder der fünf Hunks von `bed3f2f` einzeln gegen die Frage *„schließt er den
Befund, oder verschiebt er ihn?"*; danach die Umgebung der umgeschriebenen Sätze; danach die
Suche nach neuen Fehlern in Sätzen, die vorher niemand beanstandet hat. Jede Zahl selbst
nachgezählt, jedes Zitat am Original verglichen, jede Fundstelle selbst nachgelesen. Wo eine
Vollständigkeitsaussage steht, steht der Prüfbereich dabei.

---

## Status der Vorrunden-Befunde

| ID | Vorrunden-Befund | Status heute | Beleg |
|---|---|---|---|
| **M-1** | Der Frage-1-Absatz trennte die zwei Abweichungen auf dem Frage-2-Kriterium und behauptete drei Zeilen später ihre Gleichheit auf demselben — begründet mit dem *Bemerken* | **geschlossen** | `:96-99` lautet jetzt *„nach deren eigenem Maßstab, dem **Erreichen**: auch die Bedingung von Abweichung 5 liegt in der Payload des Werkzeugs, und die bringt kein Aufwand dieses Repos herbei"*. Das ist gegen `spec/spezifikation.md:486-487` verifiziert (*„Sie entfällt ersatzlos, sobald die `tool_response` eines Hintergrund-Laufs Zähler trägt"*) und steht **nicht** mehr im Widerspruch zu `:113` (*„Frage 2 fragt nach dem Erreichen, nicht nach dem Bemerken"*). Der ausschließende Satz *„das ist Frage 2"* ist entfallen; die Trennung ruht jetzt auf der **Auflösung** (`:91-95`), die Gleichsetzung auf dem **Erreichen** (`:96-99`) — zwei verschiedene Prädikate, kein Widerspruch |
| **M-2** | *„Folgepflicht 2 — eingelöst"* über einem Präsens-Satz über eine Zelle, die es nicht gibt | **geschlossen** | `:190-194`: Überschrift jetzt *„die Vokabular-Ergänzung steht, die Zelle selbst entsteht erst bei der Closure"*, Satz im Futur (*„wird … führen"*), Entstehung benannt (*„entsteht mit der Ergebnis-Notiz der Welle"*). Gegen `slice-068` DoD (3) (`docs/plan/planning/done/slice-068-…:86-91`) geprüft: *„die Zelle trägt den Wert erst mit der Annahme"* und *„entsteht bei der Wellen-Closure in `welle-09-results.md`"* — beides jetzt korrekt wiedergegeben. `find docs -name 'welle-09*'` erneut gefahren: **ein** Treffer, der Welle-**Plan**; ein `results`-Artefakt gibt es nicht |
| **M-3** | Der ADR-Index trug *„vom Modul-15-Pflicht-Minimum"* weiter | **geschlossen** | `docs/plan/adr/README.md:20` lautet jetzt *„die Abweichung von den Modul-15-Token-Attributions-Regeln"* — deckungsgleich mit dem Rumpf `:43-44` und mit `spec/spezifikation.md:323-326`. Ganze Zeile geprüft (Titel · Status **Proposed** · Bezug-Spalte `LH-QA-01`, `ADR-0011`) — der Rest trägt; eine Restunschärfe steht als **L-5** |
| **L-1** | *„eingetragen von dem Slice, der die Rollen-Konvention schreibt"* — falsche Provenienz | **geschlossen** | Die Zuschreibung ist ersatzlos entfallen (`:197-199`). Selbst nachgemessen: `git log -S "ADR-Verdikt" -- docs/plan/planning/welle-09-modul-15-konformitaet.md` → genau **ein** Commit, `29ff58c` („slice-066 re-geschnitten") — die Vorrunden-Messung hält |
| **L-2** | *„sie kommen aus drei Regelblöcken"* ohne die auflösende Hälfte — an **zwei** Stellen (`:41-43` und die Geschichte-Zeile) | **halb geschlossen** | `:41-43` spiegelt jetzt `spec/spezifikation.md:311-312` nahezu verbatim (*„und eine weicht von keinem ab"*). Die Geschichte-Zeile `:299` trägt die Verkürzung unverändert weiter → **L-1 dieser Runde** |
| **L-3** | Die Frage-1-Antwort stand auf einem Kriterium, das Modul 7 nicht setzt | **umgeformt, nicht ganz geschlossen** | Der verengende Konjunkt (*„mit gemeinsamer Auflösung"*) ist weg; die Faustregel ist jetzt korrekt benannt (`:85-87`). Neu ist das Eingeständnis *„betrifft **dieselbe Achse**"* ohne einen Satz, der einen gemeinsamen **Geltungsbereich** von Abweichung 5 und 6 verneint → **L-4 dieser Runde** (die Antwort trägt trotzdem, Begründung dort) |
| **I-1** | Der Fix hängte sich an die bestehende Geschichte-Zeile | **geschlossen** | `bed3f2f` legt eine **eigene** Zeile an (`:298`); die Tabelle führt jetzt zwei Zeilen vom 2026-08-03 |
| **I-2 / I-3** | Nebenbefunde außerhalb der ADR bzw. undokumentierte Annahme | **unverändert offen, ausdrücklich** | Siehe **I-1**, **I-2** und **I-3** dieser Runde |

**Alle vier LOW und beide INFO der ersten Bestätigungsrunde** (Fallzahl 102/106, Zitat-Wortstellung,
Frageliste, Berichtsgröße, vier erhaltene Bestandteile, eindeutige Zeilen-Bezeichnung) sind
**geschlossen geblieben** — stichprobenartig am Original nachgemessen, Belege in **N-9** bis
**N-12**.

**Die fünf blockierenden Befunde der Runde vom 2026-07-31** (H-1, M-1…M-4) bleiben aufgelöst.
`bed3f2f` fasst keinen ihrer Träger an: die Konsequenz-Zeile (`:174-180`), Alternative G
(`:159`), die Fitness Function (`:216-266`) und der `LH-QA-01`-Kopf (`:10-15`) stehen unverändert;
der Träger der zwei Wächter-Zeilen ist nachgeprüft (**N-13**).

---

## Findings

### L-1 — Die Geschichte-Zeile trägt die Verkürzung weiter, die derselbe Commit im Kontext behebt — und die neue Zeile darüber nennt genau diese Klasse „eine Korrektur an einer von zwei Stellen ist keine"

- **kategorie:** LOW
- **quelle:** Repo-Regel „autoritative Quellen verbatim spiegeln oder darauf zeigen";
  `AGENTS.md` §3.6; Skill-Anker „Doku-Drift"
- **pfad:** `docs/plan/adr/0012-haupt-kontext-ohne-token-bilanz.md:299` gegen
  `spec/spezifikation.md:311-313` und `:327-329`
- **befund:** Die Geschichte-Zeile von `d021716` sagt unverändert *„die sechs Abweichungen wurden
  pauschal **einem** Pflicht-Minimum zugeschrieben, obwohl der Zielort sie ausdrücklich auf drei
  Regelblöcke verteilt"*. Der Zielort setzt in derselben Überschrift eine Einschränkung dahinter
  (`spec/spezifikation.md:311-312`): *„sie kommen aus drei Regelblöcken des
  Observability-Moduls, **und eine weicht von keinem ab**"*, ausgeschrieben in `:327-329`
  (*„**4** (Altbestände) weicht von **keiner** Modul-Regel ab"*). Über die vier
  Aufzählungspunkte `:315-329` selbst ausgezählt: 1 und 3 → Pflicht-Minimum des
  Audit-Span-Schemas, 2 → Mindestfelder eines Tool-Call-Spans, 5 und 6 →
  Token-Attributions-Regeln, 4 → keiner; **fünf** von sechs kommen aus drei Blöcken. Die
  Vorrunde hatte beide Stellen benannt; `bed3f2f` hat `:41-44` korrigiert und diese nicht.
- **verifizierbar:** nein — kein Gate liest Markdown-Sätze (`make docs-check` selbst gefahren:
  289/0, keine Zeile über Sätze). Die Zuordnung ist am Zielort ausgezählt.
- **Failure-Szenario:** Wer die 4 × 2-Matrix aus der Zusammenfassung dieser Zeile füllt, zieht
  Abweichung 4 (eine Aufbewahrungs-Entscheidung ohne Modul-Regel) in eine Modul-15-Zelle. Ab
  *Accepted* wäre die Zeile nach `AGENTS.md` §3.4 nur noch per Supersedes zu korrigieren.
- **Kategorisierung, offengelegt:** MEDIUM erwogen und verworfen. Die Aussage ist **unvollständig,
  nicht falsch** — der Zielort sagt wörtlich „drei Regelblöcke" —, und sie steht in der
  Verweis-Spalte einer historischen Zeile, nicht im normativen Teil. Anders als bei M-3 der
  Vorrunde widerspricht sie dem Rumpf nicht.

### L-2 — Die neue Geschichte-Zeile beziffert die vom Vorgänger-Fix erzeugten Fehler mit zwei; gemessen sind es drei, und die Zeile selbst führt den dritten auf

- **kategorie:** LOW
- **quelle:** `AGENTS.md` §3.6 (die Zahl steht als Tatsachenbehauptung); Repo-Präzedenz
  „Fallzahl nachzählen" (dieselbe Klasse war L-1 der ersten Bestätigungsrunde: 102 statt 106)
- **pfad:** `docs/plan/adr/0012-haupt-kontext-ohne-token-bilanz.md:298`
- **befund:** Die Zeile beginnt *„Zweite Bestätigungsrunde — und sie fing **zwei** Fehler, die der
  Fix der ersten selbst erzeugt hatte"*. Selbst am Diff gemessen (`git show d021716 -- <ADR>`):
  `d021716` hat **drei** der Befunde der zweiten Runde erst eingeführt — (1) den
  *Nachsehen*-Satz, (2) die Überschrift *„eingelöst"*, und (3) den Satz *„eingetragen von dem
  Slice, der die Rollen-Konvention schreibt"*, den die Vorrunde als **L-1** an
  `git log -S "ADR-Verdikt"` widerlegt hat (selbst nachgefahren: genau ein Commit, `29ff58c`).
  Vor `d021716` stand keiner der drei Sätze in der Datei. Dieselbe Zeile führt den dritten drei
  Sätze später selbst auf: *„Dazu die falsch zugeschriebene Herkunft dieser Ergänzung
  (entfallen)"*. Die Commit-Message trägt die präzise Fassung (*„Zwei der drei **MEDIUM**"*); in
  der Zeile ist die Einschränkung auf die Kategorie weggefallen.
- **verifizierbar:** ja, für die Tatsache — `git show d021716 -- docs/plan/adr/0012-*.md`
  (gefahren). Für die Aussage selbst nein.
- **Failure-Szenario:** Beim Annahme-Entscheid zählt der Architect die Runden und die
  Regressionen aus dieser Tabelle (so geschehen bei `ADR-0011`: *„**sechs** Proposed-Runden"*)
  und bekommt für die Fix-Regressionen eine zu wenig — in einem Dokument, das ab *Accepted* nur
  noch per Supersedes zu korrigieren ist. Die Zahl ist zugleich das Argument der Zeile („der Fix
  erzeugt Fehler"), also nicht beiläufig.

### L-3 — Der Zeilen-Verweis `:60-61` deckt das Zitat nicht, das er belegt

- **kategorie:** LOW
- **quelle:** Repo-Regel „autoritative Quellen verbatim spiegeln oder darauf zeigen"
- **pfad:** `docs/plan/adr/0012-haupt-kontext-ohne-token-bilanz.md:86-87` gegen
  `.harness/baseline/v3.5.2/regelwerk/modul-07-carveouts.md:60-62`
- **befund:** `:86-87` schreibt *„seine Faustregel für *Cluster* ist der **gemeinsame
  Geltungsbereich**, keine Carveout-Zahl (`:60-61`)"*. Am vollständig gelesenen Modul mit
  Zeilennummern nachgezählt: `:60-61` trägt *„Kein harter Schwellwert für „Cluster" — Faustregel
  (gemeinsamer Geltungsbereich),"*; das mitzitierte *„keine Carveout-Zahl"* steht auf **`:62`**.
  Der Verweis ist um eine Zeile zu kurz. Die Vorrunde hatte dieselbe Stelle mit `:60-62` zitiert.
- **verifizierbar:** nein — `d-check` prüft `codepaths` als Pfade, nicht Zeilenspannen gegen
  Zitate (`make docs-check` selbst gefahren: 289/0, die Datei ist grün).
- **Failure-Szenario:** Wer den Beleg nachschlägt, findet die zitierte Wendung nicht in der
  genannten Spanne und muss raten, ob die ADR ein anderes Modul meint oder falsch zitiert. In
  einer ADR, deren tragende Argumentation aus rund einem Dutzend solcher Zeilenverweise besteht,
  kostet ein nicht deckender Verweis das Vertrauen in die übrigen. Ab *Accepted* nur per
  Supersedes korrigierbar.

### L-4 — Der Frage-1-Absatz räumt „dieselbe Achse" ein und benennt den gemeinsamen Geltungsbereich als Faustregel, prüft ihn aber nur gegen den einen Carveout — nicht gegen die Nachbar-Abweichung

- **kategorie:** LOW
- **quelle:** `.harness/baseline/v3.5.2/regelwerk/modul-07-carveouts.md:54-62`, `:130-131`
- **pfad:** `docs/plan/adr/0012-haupt-kontext-ohne-token-bilanz.md:83-91`
- **befund:** Der Absatz sagt jetzt *„betrifft **dieselbe Achse** — der Zielort führt beide als
  denselben Ausfall an zwei getrennten Orten"* und nennt unmittelbar danach die Modul-7-Faustregel
  für *Cluster*: den **gemeinsamen Geltungsbereich**. Getestet wird danach ausschließlich das
  Symptom aus `:130` in seiner Carveout-Fassung: *„dieses Repo führt genau **einen** Carveout,
  und mit dem teilt diese Abweichung keinen Geltungsbereich"*. `modul-07-carveouts.md:54-56`
  formuliert dasselbe Kriterium aber als *„mehrere **Ausnahmen** auf denselben Pfad/dieselbe
  Sub-Area"* — und zwei erklärte Ausnahmen auf derselben Achse sind genau das, was der Absatz
  zwei Zeilen vorher einräumt. Kein Satz der ADR verneint einen gemeinsamen Geltungsbereich
  **zwischen Abweichung 5 und 6**; verneint wird nur der Überschnitt mit dem einen Carveout.
- **verifizierbar:** nein.
- **Failure-Szenario:** Ein späteres Abweichungs-Paar teilt eine Achse; wer diese dann immutable
  ADR als Präzedenz zitiert, liest, dass *„wir führen nur einen Carveout"* die Cluster-Frage
  beantwortet — und überspringt die BF-Sub-Area-Markierung in einem Fall, in dem Modul 7 sie
  vorsieht.
- **Warum die Antwort trotzdem trägt** (die Auftragsfrage, eigenständig geprüft): Selbst
  gemessen führt `docs/plan/carveouts/` genau eine Carveout-Datei (`CO-001-bats-shell-lint.md`,
  neben `README.md`; kein `done/`), ihr Geltungsbereich sind die dreizehn `.bats`-Dateien unter
  `test/` am Gate `shell-lint` — kein Überschnitt. Das zweite Symptom (*„Code existiert vor
  Doku"*) liegt nicht vor. `modul-07-carveouts.md:131` leitet *„eine einzelne, gut abgrenzbare
  Diskrepanz"* ausdrücklich auf den Carveout-/ADR-Pfad und **nicht** auf die BF-Markierung. Und
  die **Folge** einer Cluster-Antwort greift hier nicht: `:77-79` sagt, die BF-Markierung *„kippt
  den Sub-Area-Kontext, in dem die Diskrepanz erst entsteht"* — die berührten Sub-Areas (`spec/`,
  `docs/plan/`) sind GF-deklariert, und die Diskrepanz entsteht nicht aus einem Sub-Area-Kontext,
  sondern aus einer fremden Payload. Die Antwort *„einzelne Diskrepanz"* hält; sie steht nur auf
  einem Bein weniger, als der Absatz nahelegt.

### L-5 — Die neue Index-Zeile spricht von *der* Abweichung von den Token-Attributions-Regeln; der Rumpf sagt drei Zeilen lang, dass es zwei sind

- **kategorie:** LOW
- **quelle:** Skill-Anker „Doku-Drift"; `spec/spezifikation.md:323-326` (Technik-Stratum, Rang 2)
- **pfad:** `docs/plan/adr/README.md:20` gegen
  `docs/plan/adr/0012-haupt-kontext-ohne-token-bilanz.md:43-44`
- **befund:** Die korrigierte Index-Zeile lautet *„die Abweichung **von den
  Modul-15-Token-Attributions-Regeln** ist **permanent**"*. Der Regelblock ist damit richtig
  (M-3 der Vorrunde ist geschlossen), der bestimmte Singular aber nicht: derselbe Rumpf sagt
  *„Von den Token-Attributions-Regeln weichen **zwei** ab, die fünfte und die sechste"*
  (`:43-44`), und `spec/spezifikation.md:323-326` führt beide unter derselben Regelgruppe.
  Angebunden ist der Singular durch den Halbsatz davor (*„Der Haupt-Kontext bleibt ohne
  Token-Bilanz —"*); wer ihn mitliest, kommt richtig heraus.
- **verifizierbar:** nein.
- **Failure-Szenario:** Die Matrix-Zelle *Token-Attribution × Repo* ist nach
  `welle-09…:93-94` **je Abweichung** zu belegen und nach `slice-068` DoD (3) zweigeteilt
  (Hintergrund → *deklariert*, Haupt-Kontext → *ADR-Verdikt*). Wer den Einzeiler als kanonische
  Zusammenfassung nimmt — und das ist sein Zweck —, bucht *die* Token-Attributions-Abweichung als
  permanent und legt genau die Teilung wieder zu, die der Slice gerade festgelegt hat.
- **Kategorisierung, offengelegt:** LOW statt MEDIUM, weil der Index nicht von `AGENTS.md` §3.4
  gedeckt und jederzeit korrigierbar ist und weil der anbindende Halbsatz die richtige Lesart
  trägt. MEDIUM wäre es, wenn der Index dem Rumpf widerspräche — das tut er nach der Korrektur
  nicht mehr.

### I-1 — Der ADR-Satz über Abweichung 5 steht jetzt auf dem tragenden Kriterium; damit ist die Kollision mit der Buchung im Wellen-Closure scharf statt selbstwidersprüchlich

- **kategorie:** INFO
- **quelle:** `.harness/baseline/v3.5.2/regelwerk/modul-07-carveouts.md:63-67`;
  `docs/plan/planning/welle-09-modul-15-konformitaet.md:103`, `:106`;
  `docs/plan/planning/done/slice-068-rollen-arbeit-laeuft-als-rolle.md:83-88`
- **pfad:** `docs/plan/adr/0012-haupt-kontext-ohne-token-bilanz.md:96-99` (außerhalb: die zwei
  Plandateien)
- **befund:** Die ADR sagt jetzt zutreffend, die Bedingung von Abweichung 5 liege in der Payload
  des Werkzeugs und werde von keinem Aufwand dieses Repos herbeigeführt — also die Frage-2-Antwort
  *Nein*, die `modul-07-carveouts.md:63-67` auf den ADR-Pfad führt. `slice-068` DoD (3) bucht
  Abweichung 5 weiterhin als *„**deklariert** samt Auflösungs-Trigger"*, und
  `welle-09…:106` sagt für genau diesen Fall *„Ist sie wirklich permanent, gehört sie in eine ADR
  und die Zelle trägt „ADR-Verdikt""*. Vor `bed3f2f` untergrub die ADR ihre eigene Behauptung mit
  dem falschen Kriterium; jetzt steht sie.
- **verifizierbar:** nein.
- **Failure-Szenario:** Die Wellen-Closure bucht in einer Zelle dieselbe Trigger-Klasse einmal als
  *deklariert* und einmal als *ADR-Verdikt*, während eine immutable ADR im selben Repo sagt, dass
  beide Bedingungen denselben Charakter haben.
- **Warum kein Befund an der ADR** (die Auftragsfrage, ausdrücklich beantwortet): Modul 7 kennt
  **eine** Klammer für gemeinsame Behandlung, und das ist Frage 1 (`:50-52`: *„zwei sequenzielle
  Wenn-Dann-Fragen — Granularität *vor* Temporalität"*). Eine geteilte Frage-**2**-Antwort erzeugt
  **keine** Bündelungspflicht; die Folge einer Cluster-Antwort wäre die BF-Sub-Area-Markierung, und
  deren Voraussetzungen liegen nicht vor (siehe **L-4**). Die Behandlung nur der sechsten
  Abweichung ist damit nach Modul 7 **zulässig**, und die Abgrenzung `:99-100` (*„Ob sie deshalb
  denselben Pfad nehmen müsste, ist hier **nicht** mitentschieden"*) ist formal korrekt: ohne eine
  Frage-1-Aussage über Abweichung 5 ist der Modul-7-Ausgang für sie nicht determiniert. Der
  Klärungsbedarf liegt bei der Wellen-Closure, nicht in dieser ADR.

### I-2 — „sie läuft bereits" in Alternative G bleibt eine qualitative Behauptung ohne Sensor und ohne Annahme-Markierung

- **kategorie:** INFO
- **quelle:** Skill-Anker „dokumentationswürdige, aber undokumentierte Annahme"
- **pfad:** `docs/plan/adr/0012-haupt-kontext-ohne-token-bilanz.md:159`
- **befund:** Unverändert seit `d021716`. Qualitativ gedeckt (`.claude/agents/` führt sechs
  rollen-benannte Typen, die DASS-Regel steht im Technik-Stratum), quantitativ nach derselben
  Tabellenzelle unmessbar (*„wie viel weniger, misst niemand"*). Die Aussage ist konsistent, aber
  nirgends als Annahme markiert. Die Vorrunde hat dasselbe als I-3 geführt; `bed3f2f` fasst die
  Zelle nicht an.
- **verifizierbar:** nein.
- **Failure-Szenario:** Schwach — ein Leser liest *„läuft bereits"* als gemessen und sucht eine
  Zahl, die es nach derselben Zelle nicht geben kann.

### I-3 — Nebenbefund außerhalb des Prüfgegenstands: das Welle-Ziel nennt drei Belegarten, die Wert-Tabelle führt fünf

- **kategorie:** INFO
- **quelle:** Maintainability
- **pfad:** `docs/plan/planning/welle-09-modul-15-konformitaet.md:16-18` gegen `:100-106`
- **befund:** Selbst nachgelesen und unverändert: `:16-18` verlangt *„einen laufenden Sensor, eine
  deklarierte Entscheidung mit Auflösungs-Trigger oder das Verdikt einer ADR"* — drei Werte, *„auf
  BEIDEN Ebenen"*. Die Wert-Tabelle `:100-106` führt **fünf** (Sensor · deklariert · ADR-Verdikt ·
  emittiert · nicht emittiert), von denen `:91-92` zwei ausdrücklich der Tool-Spalte zuordnet. Der
  Commit benennt den Punkt ausdrücklich als unangetastet.
- **verifizierbar:** nein.
- **Failure-Szenario:** Wer das Welle-Ziel als Definition liest, hält *emittiert* / *nicht
  emittiert* für unzulässige Zellwerte und lässt die Tool-Spalte offen — eine offene Zelle ist
  nach `:108` ein offener Closure-Trigger.

### I-4 — „wieder das, was sie wirklich trägt" beschreibt eine Rückkehr zu einem Stand, den der Absatz nie hatte

- **kategorie:** INFO
- **quelle:** Repo-Regel „das Artefakt beschreibt die Sache, nicht die Entstehung ihres Textes"
- **pfad:** `docs/plan/adr/0012-haupt-kontext-ohne-token-bilanz.md:298`
- **befund:** Die neue Geschichte-Zeile sagt, die Antwort *„einzelne Diskrepanz"* trage **wieder**
  die zwei BF-Symptome. Am Diff gemessen: die BF-Symptom-Prüfung stand sowohl vor `d021716`
  (*„Auch keines der beiden Symptome … liegt vor"*) als auch danach unverändert im Absatz; sie war
  nie entfernt. Verschoben hat sich nur, welcher Satz die **Schlussfolgerung** trägt. Der zweite
  Halbsatz (*„statt einer auf *gemeinsame Auflösung* verengten Fassung"*) beschreibt die Änderung
  richtig.
- **verifizierbar:** ja, für die Tatsache — `git show d021716 -- <ADR>` und
  `git show bed3f2f -- <ADR>` (beide gefahren).
- **Failure-Szenario:** Schwach — der schwächste Befund dieses Laufs. Gemeldet, weil eine
  Zustandsbeschreibung in einem gleich immutablen Dokument steht und am Diff widerlegbar ist.

---

## Negativbefunde

Je Bereich eine „geprüft, ohne Befund"-Zeile. Wo eine Vollständigkeit behauptet wird, steht der
Prüfbereich dabei, aus dem sie stammt.

| # | Bereich | Ergebnis |
|---|---|---|
| **N-1** | **Hunk 1 — die Kontext-Herkunft der sechs Abweichungen** | `:41-43` lautet jetzt *„sechs erklärte Abweichungen; sie kommen aus **drei** Regelblöcken des Moduls, und eine weicht von keinem ab"* — gegen `spec/spezifikation.md:311-312` (*„Sechs erklärte Abweichungen — sie kommen aus drei Regelblöcken des Observability-Moduls, und eine weicht von keinem ab"*) praktisch verbatim gespiegelt. Der tragende Satz *„Von den Token-Attributions-Regeln weichen **zwei** ab, die fünfte und die sechste"* deckt sich mit `:323-326`. **Ohne Befund** (die unkorrigierte Zwillingsstelle ist **L-1**). |
| **N-2** | **Hunk 2 — die Sachzitate des neuen Frage-1-Absatzes**, jedes am Zielort nachgelesen | *„die Bedingung von Abweichung 5 ist erfüllt, sobald die `tool_response` eines Hintergrund-Laufs Zähler trägt"* → `spec/spezifikation.md:486-487` (*„Sie entfällt ersatzlos, sobald …"*) ✓ · *„ihn umschließt überhaupt kein solcher Aufruf"* → `spec:496-497` (*„Den Haupt-Kontext umschließt **kein** `Agent`-Aufruf"*) ✓ · *„durch einen `PreToolUse`-Guard **verkleinert** (er schließt die Lücke nicht …)"* → `spec:414-415` (*„der Guard verkleinert die Lücke, er schließt sie nicht"*) ✓ · *„der Zielort führt beide als denselben Ausfall an zwei getrennten Orten"* → `spec:323-326` (gemeinsamer Regelblock) und `spec:490` (*„die härtere Hälfte"*) ✓. **Ohne Befund.** |
| **N-3** | **Hunk 2 — der innere Widerspruch der Vorrunde** | `:91-95` (keine gemeinsame **Auflösung**) und `:96-99` (geteilte Antwort auf Frage 2 wegen des **Erreichens**) prädizieren Verschiedenes und widersprechen sich nicht. Gegen `:107-115` (*„Die Grenze dieser Antwort"*) Zeile für Zeile gelesen: der dort ausgeschlossene Maßstab (*Bemerken*) kommt im neuen Absatz **nicht** mehr vor. Gegen `modul-07-carveouts.md:63-67` geprüft: der Absatz verwendet Frage 2 in der Modul-Bedeutung (*„nichts davon werden wir in absehbarer Zeit tun"*). **Ohne Befund — M-1 der Vorrunde geschlossen.** |
| **N-4** | **Hunk 2 — Modul-7-Zitate und Zeilenverweise am vollständig gelesenen Modul** (`:26-29`, `:46-93`, `:48`, `:48-67`, `:63-67`, `:105-110`, `:129`, `:130`, `:21`) | Alle 132 Zeilen gelesen; die drei Blockzitate (`:28-29`, `:65-67`, `:129`) sind verbatim, `:48-67` deckt beide Fragen in der Reihenfolge *Granularität vor Temporalität* (`:50-52` sagt es wörtlich), `:130` nennt beide BF-Symptome, `:105-110` ist die Audit-DoD, `:21` die Dateikonvention. **Ohne Befund** — mit **einer** Ausnahme: der neu eingefügte Verweis `:60-61` (**L-3**). |
| **N-5** | **Hunk 3 — die zwei substanziellen Hälften der Folgepflicht 2** | (a) *„Der Welle-Plan führt die Belegart **ADR-Verdikt** … als eigenen Wert mit dieser ADR als erstem Fall"* → `welle-09…:104`, eigene Tabellenzeile, *„Erster Fall: `ADR-0012`"* ✓; die Zuordnung zu beiden Spalten steht in `:91-92` ✓. (b) *„der Slice, der die Rollen-Konvention schreibt, führt den Welle-Plan in seiner Plan-Tabelle"* → `slice-068…:102`, Zeile `welle-09 | update` ✓. Der Konjunktiv (*„ließe dafür nur die Wahl …"*) trifft zu: `welle-09…:103` definiert *deklariert* weiterhin **mit** Auflösungs-Trigger. **Ohne Befund.** |
| **N-6** | **Hunk 3 — die Zeitform-Korrektur und ihre Reihenfolge-Aussage** | *„die Zelle entsteht mit der Ergebnis-Notiz der Welle, und sie bindet erst mit der Annahme hier"* gegen `slice-068…:86-91` (*„die Zelle trägt den Wert erst mit der Annahme"*, *„entsteht bei der Wellen-Closure in `welle-09-results.md`"*) und `:253` (*„Vorbedingung der welle-09-Closure"*). Die zwei Klauseln sind einzeln wahr; die Nennung der Annahme **nach** der Entstehung liest sich als Reihenfolge, ist aber keine Behauptung über eine solche. Erwogen und **nicht** als Befund gemeldet — kein Failure-Szenario, das über eine Lesart hinausreicht. **Ohne Befund.** |
| **N-7** | **Hunk 4 — die neue Geschichte-Zeile, alle übrigen Zuschreibungen** | Der Verweis `docs/reviews/2026-08-03-adr-0012-bestaetigungsrunde-runde-2.md` existiert ✓ · das Zitat *„Frage 2 fragt nach dem Erreichen, nicht nach dem Bemerken"* deckt sich verbatim mit `:113` ✓ · *„(2) … Eingelöst ist die **Vokabular-Ergänzung**, nicht die Zelle"* deckt sich mit dem umgesetzten Hunk 3 ✓ · *„die zu kurze Fassung der Abweichungs-Herkunft (eine der sechs weicht von **keiner** Modul-Regel ab)"* deckt sich mit `spec:327-329` ✓ · das Zitat *„vom Modul-15-Pflicht-Minimum"* deckt sich verbatim mit dem Vor-Zustand von `README.md:20` (`git show bed3f2f`) ✓. Ausnahmen: die Fehler-Zahl (**L-2**) und *„wieder"* (**I-4**). **Sonst ohne Befund.** |
| **N-8** | **Hunk 5 — der ADR-Index, ganze Zeile** | `README.md:20` vollständig gelesen: Regelblock-Zuordnung jetzt deckungsgleich mit Rumpf und Zielort ✓ · *„Werkzeug-Wahl nach Modul 7: Trigger nicht durch Aufwand erreichbar ⇒ ADR statt Carveout mit Folge-Slice"* deckt sich mit `:101-105` ✓ · *„jede Bilanz aus diesen Spans nennt ihren Nenner — mit Wächter, fällig beim Auswertungs-Slice"* deckt sich mit Festlegung 2 (`:138-144`) und der Fitness Function (*„fällig mit der Bilanz … existiert heute nicht"*) ✓ · Status **Proposed** deckt sich mit `:3` ✓ · Bezug-Spalte (`LH-QA-01`, `ADR-0011`) deckt sich mit dem `Bezug`-Kopf ✓. **Ohne Befund** (die Restunschärfe ist **L-5**). |
| **N-9** | **Fortbestand der Vorrunden-Korrektur „102 statt 106"**, selbst nachgezählt | `git ls-tree --name-only 0fb1db8 test/mutations/` → **102** Einträge, davon **102** mit `.sh`; höchste Nummer **106**. `ADR-0011` trägt **fünf** `test/mutations/`-Zeilen (`grep -c` → 5, Zeilen `:328-331`, `:335`). `:257-259` gibt beides unverändert richtig wieder. **Ohne Befund.** |
| **N-10** | **Fortbestand der Vorrunden-Korrektur am Zitat der Sensor-Spalte** | `:247-248` lautet unverändert *„kein Gate prüft, ob ein … genannter Wächter noch existiert oder noch so heißt"* — `spec/spezifikation.md:76` verbatim. **Ohne Befund.** |
| **N-11** | **Fortbestand der Vorrunden-Korrekturen an Frageliste und Alternative G** | `:65-68` führt vier Fragen mit vorangestelltem *„unter ihnen"* und der tragenden Verneinung *„**keine** von ihnen führt diese Bedingung"* ✓ · `:159` führt die Berichtsgröße als *geliefert* im Technik-Stratum, die erzeugende Auswertung als *geplant* ✓ (`slice-066` liegt in `open/` — `ls` gefahren). **Ohne Befund.** |
| **N-12** | **Fortbestand der zwei INFO-Korrekturen der ersten Runde** | `:299` nennt *„Nummer, Überschrift **wörtlich**, das `Datum` und eine Zeiger-Zeile"* (vier Bestandteile) und *„Die **unterste** Zeile dieser Tabelle — die, die diese ADR eröffnet"* ✓. **Ohne Befund.** |
| **N-13** | **Der Träger der zwei Fitness-Function-Zeilen (Folgepflicht 4)** | `slice-066` liegt unverändert in `open/`; DoD (2) ist ein eigener Punkt (`:70-84`) und nennt *„**Zwei Zähne, rot gesehen**"* — Go-Test (`make test`) und `test/mutations/`-Fall (`make mutate`) —, die Plan-Tabelle nennt sie ein zweites Mal (`:113`). Die Bedingung, die Folgepflicht 4 stellt, ist am heutigen Bestand erfüllt. **Ohne Befund.** |
| **N-14** | **Die härteste Vollständigkeitsaussage der ADR** (`:156`, Alternative C) | Über alle **3.383** Zeilen von `docs/user/claude-hooks-referenz.md` selbst gemessen: `usage` erscheint **dreimal** — als Feldname genau einmal (`:1574`), zweimal in der URL `/docs/de/monitoring-usage` (`:641`, `:655`); `totalTokens` genau einmal (`:1571`). Beide Feld-Vorkommen liegen in der `tool_response`-Tabelle des `Agent`-Werkzeugs; `:1576` sagt ausdrücklich, dass Hintergrund-Subagenten keine Nutzungsfelder tragen. Die Spanne `:1571-1574` trifft. **Ohne Befund — die Aussage hält auch in dieser Runde.** |
| **N-15** | **Hard Rules** | §3.1: kein Gate in `make gates` (`Makefile:270` — `mutate` ist **nicht** enthalten), `AGENTS.md` §4 oder `harness/README.md` behauptet; die genannten Targets existieren (`Makefile:47` `test`, `:121` `mutate`). §3.2: keine Lint-Suppression — reiner Markdown-Commit. §3.3: kein Move, drei Dateien, reine Inhaltsänderung (`git show --numstat`). §3.4: Status bleibt **Proposed** (`:3`) und im Index; keine Accepted-ADR überschrieben, keine Supersedes-Kette angefasst. §3.5: keine Gate-Lockerung. §3.6: die Fitness Function benennt für Festlegung 1 ausdrücklich, warum es kein rot färbbares Gegenbeispiel gibt, und für Festlegung 2 zwei Zeilen mit Träger. **Ohne Befund.** |
| **N-16** | **Template-Konformität** | Gegen `.harness/baseline/v3.5.2/templates/docs/plan/adr/NNNN-titel.template.md` Abschnitt für Abschnitt: Status · Datum · Autor · Bezug · Schärft · Kontext · Entscheidung · Verglichene Alternativen · Konsequenzen · Fitness Function · Re-Evaluierungs-Trigger · Geschichte — alle vorhanden und in Template-Reihenfolge; ≥ 3 Alternativen (sieben, A–G, die gewählte fett); `Schärft` gefüllt samt Aufwärts-Deklaration; Geschichte-Tabelle mit `Datum | Ereignis | Verweis`; Template-Hinweis-Block entfernt. **Ohne Befund.** |
| **N-17** | **Repo-Regel „eine ADR nennt keine Slice-Kennungen"** | Über die **ganze** Datei gemessen: `grep -cE 'slice-[0-9]\|welle-[0-9]\|SL-\|CO-[0-9]'` → **0** Treffer, auch in der Verweis-Spalte, die die Regel ausnehmen würde. Die Pflichten hängen an der **Funktion** (*„der Slice, der die Bilanz baut"*, *„der Slice, der die Rollen-Konvention schreibt"*), die Zelle an *„der Ergebnis-Notiz der Welle"*. `bed3f2f` hat keine Kennung eingeführt — die neue Geschichte-Zeile nennt den Review-Report als Pfad. **Ohne Befund; die Regel ist übererfüllt.** |
| **N-18** | **Gate-Aussagen der Fitness Function** | `make comment-claims` (`Makefile:135`) fährt `internal/*.go`, `internal/**/*.go`, `cmd/**/*.go`, `harness/tools/*.sh`, `.claude/hooks/*.sh` — **kein** Markdown-Muster ✓; die ADR nennt vier Pfad-**Familien**, die fünf Globs treffen dieselben, und `AGENTS.md` §4 nennt exakt dieselben vier. `make docs-check` fährt `[links, anchors, ids, matrix, codepaths, spans]` — *„keine Behauptungen"* trifft zu. **Ohne Befund.** |
| **N-19** | **Gate-Lauf** | `make docs-check` selbst gefahren: `d-check: 289 Datei(en) geprüft, 0 Befund(e)` — deckt sich mit der Gate-Ausgabe des Commits. Links, Anker, Kennungs-Linkpflicht und die `matrix`-Regel sind grün. **Ohne Befund.** |
| **N-20** | **Status der referenzierten ADRs** | `ADR-0003` (`README.md:11`), `ADR-0011` (`:19`), `ADR-0013` (`:21`), `ADR-0014` (`:22`) sind **Accepted**; keine superseded oder deprecated Referenz. Der `Schärft`-Kopf `:24-25` (*„die erklärten Abweichungen vom Pflicht-Minimum"*) spiegelt den Wortlaut der Accepted `ADR-0013:96` (*„die je Abweichung vom Pflicht-Minimum geschuldete Begründung"*) und trägt kein bindendes *„diesem"* — wie in beiden Vorrunden **nicht** mitgemeldet. **Ohne Befund.** |
| **N-21** | **Die Entscheidung selbst** | Option F, ihre drei Festlegungen, die sieben Alternativen, die vier Folgepflichten, die Annahmen (a)–(c) und die vier Re-Evaluierungs-Trigger sind unverändert und in dieser Runde an keinem Punkt strittig. `bed3f2f` fasst keinen dieser Abschnitte an (`git show` — die vier ADR-Hunks liegen in Kontext, Trichter-Frage 1, Folgepflicht 2 und Geschichte). **Ohne Befund.** |

---

## Kategorie-Summary

| Kategorie | Anzahl | IDs |
|---|---|---|
| **HIGH** | **0** | — |
| **MEDIUM** | **0** | — |
| **LOW** | **5** | L-1, L-2, L-3, L-4, L-5 |
| **INFO** | **4** | I-1, I-2, I-3, I-4 |
| **Negativbefunde** | **21** | N-1 … N-21 |

**Was diese Runde von den beiden vorigen unterscheidet.** Beide Vorrunden fanden drei MEDIUM,
und beide Male waren die meisten davon vom jeweils vorigen Fix erzeugt. `bed3f2f` bricht dieses
Muster: die drei MEDIUM der zweiten Runde sind **geschlossen**, nicht verschoben, und der Fix hat
in den umgeschriebenen Sätzen **keinen** neuen MEDIUM erzeugt. Die fünf LOW dieser Runde sind
zweimal Reste unvollständig ausgeführter Korrekturen (L-1, L-4), zweimal Genauigkeitsmängel in
der neuen Geschichte-Zeile bzw. an einem neuen Zeilenverweis (L-2, L-3) und einmal eine
Restunschärfe im korrigierten Index (L-5). Keiner berührt die Entscheidung.

**Steering-Loop-Signal (Modul 10 §Pflege).** Dieselbe Klasse ist jetzt in **drei**
aufeinanderfolgenden Runden aufgetreten: *eine Zuschreibung wird an der Stelle korrigiert, die
der Review benannt hat, nicht an allen ihren Vorkommen.* Runde 1 → Kontext (M-2), Runde 2 → Index
(M-3), Runde 3 → Geschichte-Zeile (L-1); dazu L-2 und L-4 als weitere Halb-Korrekturen. Der
strukturelle Grund ist gemessen und unverändert: für Zuschreibungen in Markdown existiert in
diesem Repo **kein** Sensor — `make comment-claims` deckt kein Markdown (`Makefile:135`),
`make docs-check` prüft Links, Anker, Kennungen, Matrix, Codepfade und Spans, keine Sätze
(selbst gefahren: 289/0). Ab *Accepted* kommt `AGENTS.md` §3.4 hinzu. Für ADR-Text ist die
Prüfung nicht nur der einzige, sondern der letzte Sensor. Das ist als Signal festgehalten, nicht
als Auflage — die Werkzeug-Wahl dagegen gehört nicht in ein Finding.

---

## Verdikt

**KONFORM.**

**0 HIGH, 0 MEDIUM.** Nach `.harness/skills/reviewer.md` §Ablage blockieren typischerweise HIGH
und MEDIUM; beide sind leer. Die fünf LOW sind *nice-to-fix* und blockieren nicht, die vier INFO
erwarten keine Aktion.

**Zur Annahmereife.** Aus der Sicht der Rolle *Reviewer* steht der Annahme **nichts** im Weg:
die drei blockierenden Befunde der Vorrunde sind an ihren Trägern geschlossen, die Entscheidung
selbst war in keiner der drei Runden strittig, der Trichter ist in der Reihenfolge des Moduls
beantwortet und beide Antworten tragen, die Fitness Function ist zweigeteilt und hat für die
prüfbare Hälfte einen Träger mit zwei namentlich genannten Zähnen, die Template-Konformität ist
vollständig, der Index ist nachgezogen und `make docs-check` ist grün.

**Zwei Dinge gehören zur Vorlage dazu, ohne sie zu blockieren.** (1) Die fünf LOW liegen
sämtlich in Text, der ab *Accepted* nach `AGENTS.md` §3.4 nur noch per Supersedes zu korrigieren
ist — sie sind heute billig und danach teuer; zwei davon (L-1, L-2) stehen in der
Geschichte-Tabelle, drei (L-3, L-4, L-5) an Verweis, Begründung und Index. (2) **I-1** ist kein
ADR-Befund, aber ein offener Punkt der Wellen-Closure: die Buchung von Abweichung 5 als
*deklariert mit Auflösungs-Trigger* steht neben einer ADR, die deren Bedingung nach demselben
Modul-7-Maßstab als nicht erreichbar bezeichnet.

**Zur Sachfrage des Auftrags, ausdrücklich beantwortet:** die Behandlung nur der sechsten
Abweichung ist nach Modul 7 **zulässig**. Der Trichter kennt genau **eine** Klammer für
gemeinsame Behandlung — Frage 1 (Granularität), die Frage 2 bewusst vorangeht
(`modul-07-carveouts.md:50-52`) —, und eine geteilte Frage-**2**-Antwort erzeugt keine
Bündelungspflicht. Die Folge einer Cluster-Antwort wäre die BF-Sub-Area-Markierung; ihre beiden
Symptome (`:130`) liegen nicht vor (selbst gemessen: genau ein Carveout im Repo, Geltungsbereich
`shell-lint`/bats, kein Überschnitt; kein *„Code existiert vor Doku"*-Muster), und `:131` leitet
einzelne, gut abgrenzbare Diskrepanzen ausdrücklich auf den Carveout-/ADR-Pfad. Die Abgrenzung
`:99-100` ist damit eine zulässige Abgrenzung, kein offener Widerspruch.

Über die Annahme entscheide ich nicht (Modul 8: *„Architect schreibt; Reviewer prüft auf
Konsistenz"*); ich stelle den Zustand fest.

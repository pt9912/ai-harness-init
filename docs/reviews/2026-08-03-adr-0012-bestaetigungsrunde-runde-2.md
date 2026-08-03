# Review — `ADR-0012` (Proposed), Bestätigungsrunde 2 nach dem Befund-Fix

## Kopf-Metadaten

| Feld | Wert |
|---|---|
| **Review-Art** | Design-Review (Modul 10 §Drei Review-Arten) — geprüft wird eine Entscheidung gegen Spec, aktive ADRs und Hard Rules, nicht ein Code-Diff |
| **Rolle** | Reviewer (Modul 10), `.harness/skills/reviewer.md` v1.4.0 — Lauf unter dem Rollen-Typ `reviewer` |
| **Modell** | claude-opus-5[1m] |
| **Datum** | 2026-08-03 |
| **Diff/Commit-Range** | genau **ein** Commit: `d021716` (+31/−20 an der ADR, `git show --numstat` gefahren). Gegengelesen: `0d4d49b` (der Nachzug, den die Vorrunde prüfte) und `29ff58c` (der Commit, der die Belegart *ADR-Verdikt* in den Welle-Plan schrieb) |
| **Prüfgegenstand** | `docs/plan/adr/0012-haupt-kontext-ohne-token-bilanz.md` (300 Zeilen, Status **Proposed**) + `docs/plan/adr/README.md:20` |
| **Modul-8-Auftrag** | `modul-08-agentenrollen.md` §Rollen-Regeln — *„ADR-Änderung: Architect schreibt; Reviewer prüft auf Konsistenz"*. Der Reviewer entscheidet **nicht** über die Annahme und setzt den Status nicht |
| **`LH-*`** | `LH-QA-01` (in der ADR zweimal zitiert), `LH-QA-03` (Alternative E) |
| **Aktive ADRs** | `ADR-0011`, `ADR-0003`, `ADR-0013`, `ADR-0014` — alle **Accepted** (`docs/plan/adr/README.md:18,11,21,22`); keine superseded Referenz |
| **Hard Rules** | `AGENTS.md` §3.1, §3.4, §3.5, §3.6 (Wortlaut selbst gelesen, `AGENTS.md:50-113`) |
| **Vorherige Findings am gleichen Modul** | `docs/reviews/2026-08-03-adr-0012-bestaetigungsrunde.md` (0 HIGH, 3 MEDIUM, 4 LOW, 4 INFO — **NICHT KONFORM**) · `docs/reviews/2026-07-31-adr-0012-proposed-review.md` (1 HIGH, 4 MEDIUM) |
| **Regelwerk on-demand** | `regelwerk/README.md` (Index), `modul-07-carveouts.md` (**vollständig**, 132 Zeilen), `modul-10-review-harness.md`, `modul-08-agentenrollen.md` §Rollen-Regeln |
| **Gate-Lage** | `make docs-check` **selbst gefahren**: `288 Datei(en) geprüft, 0 Befund(e)` — deckt sich mit der Gate-Ausgabe des Commits. Der Gate prüft `[links, anchors, ids, matrix, codepaths, spans]` (`.d-check.yml:18`), also **keine Sätze**; `make comment-claims` lässt jede Markdown-Datei außen vor (`Makefile:135`) |

**Prüfmethode und Schwerpunkt.** Der Auftrag zielt auf das, was der Fix **selbst eingeführt**
hat (Präzedenzfall ADR-0007: die zweite Runde fing drei vom Fix erzeugte Probleme). Jeder der
acht Hunks von `d021716` wurde einzeln gegen die Frage geprüft *„schließt er den Befund, oder
verschiebt er ihn?"*, und danach die **Umgebung** der umgeschriebenen Sätze auf Widersprüche.
Jede Zahl selbst nachgezählt, jede Zuschreibung am Träger geprüft, jedes Zitat am Original
verglichen. Wo eine Vollständigkeitsaussage steht, steht der Prüfbereich dabei.

---

## Status der Vorrunden-Befunde

| ID | Vorrunden-Befund | Status heute | Beleg |
|---|---|---|---|
| **M-1** | Trichter-Frage 1 stützte sich auf einen *„ernst erreichbaren"* Trigger der Nachbar-Abweichung | **verschoben, nicht geschlossen** | Die unbelegte Stütze ist weg; an ihre Stelle tritt ein Absatz, der sich in vier Zeilen selbst widerspricht → **M-1 dieser Runde** |
| **M-2** | *„sechs erklärte Abweichungen von diesem Pflicht-Minimum"* | **überwiegend geschlossen** | `:41-43` sagt jetzt *„von den Token-Attributions-Regeln weichen **zwei** ab, die fünfte und die sechste"* — verbatim `spec/spezifikation.md:323-326`. Rest: die auflösende Hälfte des Zielorts fehlt (**L-2**), und der **ADR-Index** trägt die alte Fassung weiter (**M-3**) |
| **M-3** | Folgepflicht 2 im Präsens; eine Aussage am heutigen Welle-Plan falsch | **halb geschlossen** | Die falsche Aussage (*„hat für diesen Wert keinen Platz"*) ist durch einen zutreffenden Konjunktiv ersetzt; die Vokabular-Ergänzung ist am Träger belegt. Neu ist die Überschrift *„eingelöst"* über einem Satz, der eine nicht existierende Zelle im Präsens beschreibt → **M-2 dieser Runde**; dazu **L-1** |
| **L-1** | *„106 Fälle"* statt 102 | **geschlossen** | `git ls-tree --name-only 0fb1db8 test/mutations/` → **102** Dateien, alle `.sh`; höchste Nummer **106**; acht Lücken (12, 14, 21, 22, 23, 25, 33, 35), vier Doppelvergaben (47, 48, 49, 50) → 106 − 8 + 4 = 102. `107` liegt im Annahme-Commit noch nicht vor; `107-span-klemme-entfernt.sh` ist der erste Span-Fall (`spec/spezifikation.md:533`). Der Zusatz *„die Folge hat Lücken und Doppelvergaben"* ist gemessen richtig |
| **L-2** | Zitat der `spec`-Sensor-Spalte umgestellt | **geschlossen** | `:245` lautet jetzt *„kein Gate prüft, ob ein … genannter Wächter noch existiert oder noch so heißt"* — `spec/spezifikation.md:76` verbatim, die Auslassung deckt genau *„hier oder unter **Bewacht**"* |
| **L-3** | Frageliste des Plan-Bestands unvollständig | **geschlossen** | `:65-68` führt jetzt vier Fragen und setzt *„unter ihnen"* davor. Über `open/`, `next/`, `in-progress/`, `welle-09…md`, `planning/README.md` gemessen (`grep -ril token`): **sieben** Dateien — `slice-066` (Splitting-Regel), `welle-09` (Berichtsgröße), `slice-071` (Cache-Rechnung), `slice-069` (Wächter-Bindung), `roadmap`, dazu `slice-072`/`slice-073` mit dem Homonym `token:`. Alle vier genannten Fragen treffen zu; die Liste ist als offene gekennzeichnet |
| **L-4** | Berichtsgröße als *geplant* geführt | **geschlossen** | `:156` sagt *„steht geliefert als Festlegung im Technik-Stratum; erzeugt wird die Zahl erst von der Auswertung, und die ist geplant"* — `spec/spezifikation.md:269-286` führt sie samt beider Festlegungen; `slice-066` DoD (1) liegt in `open/` |
| **I-1** | Drei statt vier erhaltene Bestandteile | **geschlossen** | `:295` nennt jetzt *„Nummer, Überschrift **wörtlich**, das `Datum` und eine Zeiger-Zeile"* — `MR-020` (`harness/conventions.md:899-912`) legt genau diese vier fest, und `conventions.md:835-838` führt alle vier |
| **I-2** | *„Die Zeile von 2026-07-31 unten"* hatte vier Kandidaten | **geschlossen** | `:295` sagt *„Die **unterste** Zeile dieser Tabelle — die, die diese ADR eröffnet"*; das ist `:300` und eindeutig |
| **I-3 / I-4** | Nebenbefunde außerhalb der ADR | **unverändert offen, ausdrücklich** | Siehe **I-2** dieser Runde: I-3 hat durch den Fix ein Gegenstück *innerhalb* der ADR bekommen |

**Ergebnis der Abgleichung:** von zehn Positionen sind **sechs vollständig geschlossen**, zwei
teilweise, zwei liegen erklärt. Alle vier **kleineren** Befunde (L-1…L-4) und beide INFO an der
Geschichte-Zeile sind sauber und am Original belegt behoben.

---

## Findings

### M-1 — Der neue Frage-1-Absatz stellt die zwei Abweichungen auf dem Frage-2-Kriterium gegeneinander und behauptet drei Zeilen später ihre Gleichheit auf demselben Kriterium

- **kategorie:** MEDIUM
- **quelle:** `.harness/baseline/v3.5.2/regelwerk/modul-07-carveouts.md:63-67` (§Werkzeug-Wahl,
  Frage 2); Hard Rule `AGENTS.md` §3.6 (*„benennen, was wirklich deckt"*)
- **pfad:** `docs/plan/adr/0012-haupt-kontext-ohne-token-bilanz.md:87-92` gegen `:109-110`
- **befund:** `:87-89` trennt die beiden Abweichungen **auf dem Frage-2-Kriterium** und sagt das
  selbst dazu: *„Sie ist zudem durch einen `PreToolUse`-Guard **verkleinert** … an dieser hier
  bewegt kein Aufwand dieses Repos etwas — **das ist Frage 2**."* Drei Zeilen später steht das
  Gegenteil: *„**Wohl aber teilen die zwei die Antwort auf Frage 2**"*. Die einzige Begründung,
  die nach dem Doppelpunkt folgt, ist *„auch der Trigger von Abweichung 5 wirkt nur, wenn ihn
  jemand nachsieht"* — also die **Bemerken**-Eigenschaft, die derselbe Abschnitt bei `:109-110`
  ausdrücklich für Frage 2 ausschließt: *„eine Sonde **beobachtet** den Trigger, sie führt ihn
  nicht herbei … und Frage 2 fragt nach dem **Erreichen**, nicht nach dem **Bemerken**."* Der
  Satz, der die Antwort auf Frage 2 gleichsetzt, stützt sich damit auf ein Kriterium, das die
  ADR zwanzig Zeilen weiter für Frage 2 als unmaßgeblich erklärt; das Kriterium, das die
  Gleichsetzung tragen würde (auch die Bedingung von Abweichung 5 ist durch keinen Aufwand
  dieses Repos herbeizuführen), steht nirgends.
- **verifizierbar:** nein — kein Gate liest Markdown-Sätze gegeneinander (`.d-check.yml:18`;
  `make docs-check` selbst gefahren: 288/0, keine Zeile über Sätze). Belegt durch Lektüre von
  `:87-92` gegen `:109-110` und `modul-07-carveouts.md:63-67`.
- **Failure-Szenario, zwei Wege.** (1) **Regel-Import.** Ab *Accepted* ist der Satz nach
  `AGENTS.md` §3.4 nur per Supersedes zu korrigieren. Wer Modul 7 §Werkzeug-Wahl das nächste Mal
  anwendet, liest in der maßgeblichen Entscheidung, dass *„wirkt nur, wenn ihn jemand nachsieht"*
  eine Frage-2-Antwort begründet — dann wird jeder Trigger ohne Gate zu *permanent* und damit zu
  einer ADR. Genau diese Vermengung verbietet `:109-110`. (2) **Kollision mit der
  Wellen-Closure.** `:90` behauptet unbedingt, Abweichung 5 teile die Frage-2-Antwort; nach
  `modul-07-carveouts.md:63-67` führt diese Antwort auf den ADR-Pfad. Der Träger, den Folgepflicht
  2 derselben ADR als Einlösung anführt, bucht Abweichung 5 gegenteilig: `slice-068` DoD (3)
  (`docs/plan/planning/done/slice-068-rollen-arbeit-laeuft-als-rolle.md:83-86`) — *„der
  Hintergrund-Teil (Abweichung 5) trägt **deklariert** samt Auflösungs-Trigger"* —, und
  `welle-09:106` sagt für solche Fälle *„Ist sie wirklich permanent, gehört sie in eine ADR und
  die Zelle trägt „ADR-Verdikt""*. Der Zusatz `:91-93` (*„Ob sie deshalb denselben Pfad nehmen
  müsste, ist hier **nicht** mitentschieden"*) grenzt nur den **Pfad** ab, nicht die Behauptung
  über die Antwort; die Kollision bleibt stehen.
- **Kategorisierung, offengelegt:** HIGH erwogen und verworfen. Die **Entscheidung** für
  Abweichung 6 hängt nicht daran: `:98-102` begründet die Frage-2-Antwort *Nein* eigenständig
  (Hook-Oberfläche gehört dem Werkzeug, Transkript ausgeschlossen, Schätzen verboten), und die
  Frage-1-Antwort *Einzelne* überlebt über `:94-97`, wo **beide** von
  `modul-07-carveouts.md:130` genannten BF-Symptome eigenständig geprüft sind. Defekt ist die
  Begründung eines Eingeständnisses, nicht die Wahl.
- **Zur Auftragsfrage** *„ist `Ob sie deshalb denselben Pfad nehmen müsste, ist hier nicht
  mitentschieden` eine zulässige Abgrenzung oder ein offener Widerspruch?"*: als Abgrenzung
  **zulässig** — die ADR trifft für Abweichung 5 keine Frage-1-Aussage, und ohne beide Eingänge
  ist der Modul-7-Ausgang nicht determiniert. Der Widerspruch liegt nicht dort, sondern in dem
  Satz davor.

### M-2 — Folgepflicht 2 steht jetzt als „eingelöst" über einem Satz, der eine Zelle im Präsens beschreibt, die es nicht gibt

- **kategorie:** MEDIUM
- **quelle:** Hard Rule `AGENTS.md` §3.4 (Immutabilität ab *Accepted*) i. V. m. §3.6; Skill-Anker
  „Doku-Drift" mit Kontext-Eskalation (dieselbe Klasse hat `0d4d49b` an dieser ADR bereits
  einmal behoben)
- **pfad:** `docs/plan/adr/0012-haupt-kontext-ohne-token-bilanz.md:187-196` gegen
  `docs/plan/planning/done/slice-068-rollen-arbeit-laeuft-als-rolle.md:86-91`
- **befund:** Die Überschrift lautet jetzt *„Folgepflicht 2 — **eingelöst**, und sie verlangte
  eine Ergänzung des Vokabulars, **nicht nur eine ausgefüllte Zelle**"*. Der unmittelbar folgende
  Satz ist unverändert geblieben und steht im Präsens: *„Die Matrix-Zelle *Token-Attribution ×
  Repo* des Wellen-Closure **führt** für den Haupt-Kontext **nicht** „deklarierte Entscheidung
  mit Auflösungs-Trigger", sondern den Verweis auf diese ADR."* Diese Zelle existiert nicht:
  `slice-068` DoD (3) sagt *„Die Zelle selbst **entsteht bei der Wellen-Closure** in
  `welle-09-results.md`; sie hier abhaken zu wollen wäre eine Zusage über ein Artefakt, das es
  noch nicht gibt"* (`:89-91`) und *„(**Proposed** — die Zelle trägt den Wert **erst mit der
  Annahme**)"* (`:86-87`). Über `docs/` gemessen (`find docs -name 'welle-09*'`) liegt genau eine
  Datei: der Welle-**Plan**; ein `welle-09-results.md` gibt es nicht. Unter der alten Überschrift
  (*„und sie verlangt …"*) las sich der Satz vorschreibend; unter *„eingelöst"* liest er sich
  beschreibend — und ist dann falsch.
- **verifizierbar:** ja, für die Tatsache — `find docs -name 'welle-09*'` (gefahren, ein Treffer:
  der Plan). Für die Aussage selbst nein: kein Gate liest Sätze.
- **Failure-Szenario:** Die ADR wird angenommen und ist ab da immutabel. Sie behauptet dann eine
  gefüllte Zelle in einem Artefakt, das nicht existiert, und erklärt gleichzeitig die
  Folgepflicht für erledigt, deren einziger noch offener Teil genau das Füllen dieser Zelle ist —
  ein Schritt, der nach `slice-068` DoD (3) erst mit der Annahme dieser ADR möglich wird. Die
  Korrektur wäre nach `AGENTS.md` §3.4 eine Supersedes-ADR über eine Zeitform.
- **Abgrenzung:** Der praktische Schaden ist gemildert, weil `welle-09:108` unabhängig davon
  greift (*„Eine leere Zelle ist ein offener Closure-Trigger — kein „passt schon""*). Gemeldet
  wird die **Aussage**, nicht ein Prozessrisiko: sie ist genau die Klasse, die die
  Geschichte-Zeile derselben ADR eine Zeile weiter oben selbst diagnostiziert (*„jede Aussage
  darüber, was der Eintrag *führt*, *trägt* oder *ausspricht*, war seit dem Umzug im Präsens
  falsch"*).

### M-3 — Der ADR-Index trägt weiterhin die Zuschreibung, die der Fix im Rumpf als falsch korrigiert hat; beide stehen jetzt gegeneinander

- **kategorie:** MEDIUM
- **quelle:** Skill-Anker „Spec-Treue-Lücke"; `AGENTS.md` §3.6; `spec/spezifikation.md`
  (Technik-Stratum, Rang 2 der Source Precedence)
- **pfad:** `docs/plan/adr/README.md:20` gegen `docs/plan/adr/0012-haupt-kontext-ohne-token-bilanz.md:41-43`
  und `spec/spezifikation.md:311-329`
- **befund:** Die Index-Zeile lautet unverändert *„Der Haupt-Kontext bleibt ohne Token-Bilanz —
  die Abweichung **vom Modul-15-Pflicht-Minimum** ist **permanent**"*. Der Zielort reserviert
  *Pflicht-Minimum* für **einen** der drei Regelblöcke und ordnet ihm andere Abweichungen zu
  (`spec/spezifikation.md:315-318`): *„Vom **Pflicht-Minimum** eines Audit-Span-Schemas … weichen
  **1** (Cache-Status) und **3** (`agent_role`) ab"*; Abweichung 6 weicht von den
  **Token-Attributions-Regeln** ab (`:323-326`). Der ADR-Rumpf sagt seit `d021716` genau das
  (`:41-43`). Damit tragen ADR und Index desselben Gegenstands jetzt zwei verschiedene
  Regelblock-Zuordnungen.
- **verifizierbar:** nein für den Satz; die Zuordnung selbst ist am Zielort ausgezählt (vier
  Aufzählungspunkte über `spec/spezifikation.md:315-329`, je Abweichung ein Posten).
- **Failure-Szenario:** Das Closure-Kriterium von `welle-09:88-92` buchstabiert die Matrix als
  *„Je Regelblock UND je Ebene ein belegter Zustand"* — die Zuordnung Abweichung → Regelblock ist
  die Größe, an der die Zellen hängen. Wer den einzeiligen Index als Zusammenfassung der
  Entscheidung liest (und das ist sein Zweck), bucht den Haupt-Kontext unter Regelblock 1 statt
  unter Token-Attribution — also in genau die Zelle, deren Belegart `slice-068` DoD (3) gerade
  festgelegt hat. Nach der Annahme steht die falsche Zusammenfassung neben einer immutablen ADR,
  die ihr widerspricht.
- **Kategorisierung, offengelegt:** LOW erwogen — der Index ist nicht von `AGENTS.md` §3.4
  gedeckt und jederzeit korrigierbar. MEDIUM, weil es dieselbe Aussage ist, die dieser Commit
  ausdrücklich als falsch benennt und behebt, weil sie im Artefakt steht, das ein Leser **vor**
  der ADR sieht, und weil sie mit der Annahme zur kanonischen Einzeiler-Fassung einer
  Entscheidung wird, die gerade über Regelblock-Zugehörigkeit handelt.
- **Nicht mitgemeldet:** der `Schärft`-Kopf `:24-25` (*„die erklärten Abweichungen vom
  Pflicht-Minimum"*) — er spiegelt den Wortlaut der **Accepted** `ADR-0013:96` (*„die je
  Abweichung vom Pflicht-Minimum geschuldete Begründung"*) und trägt kein *„diesem"*, das ihn an
  einen bestimmten Regelblock bindet. Gleiche Einschätzung wie in der Vorrunde.

### L-1 — „eingetragen von dem Slice, der die Rollen-Konvention schreibt": die Belegart kam mit dem Re-Schnitt des Auswertungs-Slice

- **kategorie:** LOW
- **quelle:** `AGENTS.md` §3.6 (die Zuschreibung steht als Tatsachenbehauptung); Skill-Anker
  „Doku-Drift"
- **pfad:** `docs/plan/adr/0012-haupt-kontext-ohne-token-bilanz.md:193-196`
- **befund:** Der Satz schreibt die Vokabular-Ergänzung dem Slice zu, der die Rollen-Konvention
  schreibt. Gemessen über die Datei-Historie des Welle-Plans
  (`git log -S "ADR-Verdikt" -- docs/plan/planning/welle-09-modul-15-konformitaet.md`, genau ein
  Treffer): die Belegart **ADR-Verdikt** samt *„Erster Fall: ADR-0012"* und der mitgezogene Satz
  im Welle-Ziel entstanden in `29ff58c` — dem Commit, der den **Auswertungs**-Slice neu schnitt
  (*„slice-066 re-geschnitten: die Nenner-Pflicht bekommt ihren Traeger"*); derselbe Commit trug
  auch den Welle-Plan in die Plan-Tabelle des Rollen-Konventions-Slice ein. Dessen eigene drei
  Commits am Welle-Plan (`9eb07a4`, `13e9ac9`, `f19fd42`) haben die Zeile *deklariert* und die
  Berichtsgröße angefasst, nicht die Zeile *ADR-Verdikt*.
- **verifizierbar:** ja — `git log -S "ADR-Verdikt" -- docs/plan/planning/welle-09-modul-15-konformitaet.md`.
  Gefahren.
- **Failure-Szenario:** Schwach für die Sache — beide substanziellen Hälften halten:
  `welle-09:104` führt die Belegart als eigenen Wert mit dieser ADR als erstem Fall, und
  `slice-068:102` führt den Welle-Plan als `update` in seiner Plan-Tabelle. Gemeldet, weil eine
  Provenienz-Behauptung in einem immutablen Dokument steht und wer sie prüft, sie am genannten
  Träger nicht findet.

### L-2 — „sie kommen aus drei Regelblöcken des Moduls" lässt die auflösende Hälfte des Zielorts weg

- **kategorie:** LOW
- **quelle:** Repo-Regel „autoritative Quellen verbatim spiegeln"; `AGENTS.md` §3.6
- **pfad:** `docs/plan/adr/0012-haupt-kontext-ohne-token-bilanz.md:41-43` und `:295` gegen
  `spec/spezifikation.md:311-329`
- **befund:** Die neue Fassung lautet *„§5 führt sechs erklärte Abweichungen, und **sie** kommen
  aus **drei** Regelblöcken des Moduls"*. Der Zielort setzt in derselben Überschrift eine
  Einschränkung dahinter, die die ADR nicht mitnimmt (`:311-313`): *„Sechs erklärte Abweichungen
  — sie kommen aus drei Regelblöcken des Observability-Moduls, **und eine weicht von keinem
  ab**"*, ausgeschrieben in `:327-329`: *„**4** (Altbestände) weicht von **keiner** Modul-Regel
  ab."* Selbst ausgezählt über die vier Aufzählungspunkte `:315-329`: 1 und 3 → Pflicht-Minimum
  des Audit-Span-Schemas, 2 → Mindestfelder eines Tool-Call-Spans, 5 und 6 →
  Token-Attributions-Regeln, 4 → keiner. **Fünf** von sechs kommen aus drei Blöcken. Dieselbe
  Verkürzung wiederholt die Geschichte-Zeile `:295` (*„auf drei Regelblöcke verteilt"*).
- **verifizierbar:** nein.
- **Failure-Szenario:** Schwach, aber gleichgerichtet mit **M-3**: wer die 4 × 2-Matrix aus
  diesem Satz füllt, zieht Abweichung 4 (eine Aufbewahrungs-Entscheidung ohne Modul-Regel) in
  eine Modul-15-Zelle. Die für diese ADR tragende Angabe — *„von den Token-Attributions-Regeln
  weichen zwei ab, die fünfte und die sechste"* — ist gegen `:323-326` **verbatim richtig**.

### L-3 — Die Frage-1-Antwort steht auf einem Kriterium, das Modul 7 nicht setzt

- **kategorie:** LOW
- **quelle:** `.harness/baseline/v3.5.2/regelwerk/modul-07-carveouts.md:54-62`, `:130-131`
- **pfad:** `docs/plan/adr/0012-haupt-kontext-ohne-token-bilanz.md:83-90`
- **befund:** Der Absatz räumt jetzt ein *„betrifft dieselbe Achse"* und bestreitet danach nur
  noch die gemeinsame **Auflösung**; die Schlussfolgerung lautet *„Ein gemeinsamer
  Geltungsbereich **mit gemeinsamer Auflösung** besteht **damit** nicht."* Modul 7 setzt für
  *Cluster* die Faustregel **allein** auf den Geltungsbereich (`:60-62`: *„**Kein harter
  Schwellwert** für „Cluster" — Faustregel (**gemeinsamer Geltungsbereich**), keine
  Carveout-Zahl"*; `:54-56`: *„mehrere Ausnahmen auf denselben Pfad/dieselbe Sub-Area"*). Der
  zusätzliche Konjunkt verengt den Test; nach dem Eingeständnis trägt kein Satz mehr die
  Verneinung des Geltungsbereichs selbst.
- **verifizierbar:** nein.
- **Failure-Szenario:** Ein späteres Abweichungs-Paar teilt einen Geltungsbereich, hat aber
  getrennte Auflösungen; wer diese dann immutable ADR als Präzedenz zitiert, überspringt die
  BF-Sub-Area-Markierung, obwohl Modul 7 sie vorsieht.
- **Warum die Antwort trotzdem hält** (Auftragsfrage): `:94-97` prüft **beide** von
  `modul-07-carveouts.md:130` genannten BF-Symptome eigenständig — dieses Repo führt genau einen
  Carveout ohne Geltungsbereichs-Überschnitt (`docs/plan/carveouts/CO-001-bats-shell-lint.md`,
  Geltungsbereich `shell-lint`/bats), und das Muster *„Code existiert vor Doku"* liegt nicht vor
  —, und `:131` leitet einzelne, gut abgrenzbare Diskrepanzen ausdrücklich auf den
  Carveout-/ADR-Pfad statt auf die BF-Markierung. Die Antwort *„einzelne Diskrepanz, kein
  Cluster"* trägt; sie steht nur auf einem anderen Bein als der Satz behauptet.

### I-1 — Der Fix hängt sich an die bestehende Geschichte-Zeile, statt eine eigene anzulegen

- **kategorie:** INFO
- **quelle:** Maintainability; Repo-Präzedenz (`ADR-0010:262-265`, `ADR-0011:384-388`)
- **pfad:** `docs/plan/adr/0012-haupt-kontext-ohne-token-bilanz.md:295`
- **befund:** `d021716` erweitert die vorhandene Zeile *2026-08-03* um einen Block
  *„**Nachgetragen in derselben Runde** …"*, statt eine zweite Zeile anzulegen. Dieselbe Tabelle
  führt für 2026-07-31 **vier** eigene Zeilen (`:297`–`:300`), und die beiden anderen mehrrundigen
  ADRs dieses Repos nummerieren ihre Runden je Zeile (*„Überarbeitet (Runde 2/3/4)"*). Die zwei
  Commits `0d4d49b` und `d021716` sind zwei Überarbeitungen mit einer Review-Runde dazwischen;
  die Bezeichnung *„derselben Runde"* fasst sie als eine.
- **verifizierbar:** nein.
- **Failure-Szenario:** Keines im Bestand. Bei der Annahme zählt der Architect die Runden aus
  dieser Tabelle (so geschehen bei `ADR-0011`: *„**Sechs** Proposed-Runden"*) und bekommt hier
  eine zu wenig. Der Verweis auf den Review-Report in der Verweis-Spalte selbst ist repo-üblich
  und **kein** Befund (`ADR-0010:262-265`, `ADR-0011:386-388`).

### I-2 — I-3 und I-4 der Vorrunde bleiben offen; die erste hat durch den Fix ein Gegenstück in der ADR bekommen

- **kategorie:** INFO
- **quelle:** `modul-07-carveouts.md:63-67`; `docs/plan/planning/welle-09-modul-15-konformitaet.md:17`, `:102-106`
- **pfad:** `docs/plan/planning/welle-09-modul-15-konformitaet.md:17` gegen `:102-106`;
  `docs/plan/planning/done/slice-068-rollen-arbeit-laeuft-als-rolle.md:83-86`
- **befund:** Beide Nebenbefunde stehen unverändert und sind im Commit ausdrücklich als
  außerhalb der ADR liegend benannt — selbst nachgeprüft: (a) `slice-068` DoD (3) bucht
  Abweichung 5 weiterhin als *deklariert samt Auflösungs-Trigger*, während ihr einziger Trigger
  (`spec/spezifikation.md:486-489`) *„nur wirkt, wenn sie jemand nachsieht"*; (b) `welle-09:17`
  nennt drei Belegarten, die Wert-Tabelle `:102-106` führt fünf (Sensor · deklariert ·
  ADR-Verdikt · emittiert · nicht emittiert), von denen `:91-92` zwei der Tool-Spalte zuordnet.
  Neu ist nur, dass (a) jetzt eine Entsprechung **innerhalb** der ADR hat (`:90`, siehe **M-1**
  Failure-Szenario 2).
- **verifizierbar:** nein.
- **Failure-Szenario:** Die Wellen-Closure bucht dieselbe Trigger-Klasse in derselben Zelle
  einmal als *deklariert* und einmal als *ADR-Verdikt*, ohne dass ein Artefakt den Unterschied
  trägt.

### I-3 — „sie läuft bereits" in Alternative G ist qualitativ belegt und quantitativ nach derselben Zelle unmessbar

- **kategorie:** INFO
- **quelle:** Skill-Anker „dokumentationswürdige, aber undokumentierte Annahme"
- **pfad:** `docs/plan/adr/0012-haupt-kontext-ohne-token-bilanz.md:156`
- **befund:** Der Fix hat *„sie ist bereits geplant"* durch *„sie läuft bereits"* ersetzt.
  Qualitativ gedeckt: `.claude/agents/` führt sechs rollen-benannte Typen (`architect`,
  `implementer`, `planner`, `reviewer`, `validator`, `verifier`), und die DASS-Regel steht in
  `spec/spezifikation.md:257-267`. Eine Größe steht bewusst nicht daneben — dieselbe
  Tabellenzelle sagt *„wie viel weniger, misst niemand"*, und `spec:271-277` erklärt eine der
  beiden Formen für unsichtbar (*„klein heißt nicht ‚gelebt'"*). Die Aussage bleibt damit eine
  qualitative Behauptung ohne Sensor; das ist konsistent, aber nirgends als Annahme markiert.
- **verifizierbar:** nein.
- **Failure-Szenario:** Schwach — ein Leser liest *„läuft bereits"* als gemessen und sucht eine
  Zahl, die es nach derselben Zelle nicht geben kann.

---

## Negativbefunde

Je Bereich eine „geprüft, ohne Befund"-Zeile. Wo eine Vollständigkeit behauptet wird, steht der
Prüfbereich dabei, aus dem sie stammt.

| # | Bereich | Ergebnis |
|---|---|---|
| **N-1** | **Hunk 1 — die tragende Zahl der Regelblock-Zuordnung** | *„von den Token-Attributions-Regeln weichen **zwei** ab, die fünfte und die sechste"* gegen `spec/spezifikation.md:323-326` (*„**5** … und **6** … weichen von den **Token-Attributions-Regeln** ab"*) — verbatim. **Ohne Befund** (der Rest des Satzes ist **L-2**). |
| **N-2** | **Hunk 2 — der Plan-Bestand, über den selbst gesetzten Prüfbereich gemessen** | `grep -ril token` über `open/`, `next/`, `in-progress/`, `welle-09…md`, `planning/README.md` → **sieben** Dateien. Die vier genannten Fragen treffen zu (`slice-066`, `welle-09`, `slice-071`, `slice-069`); `slice-072`/`slice-073` tragen das Homonym `token:` (Doku-Gate-Modus), `roadmap` referenziert. Die tragende Verneinung — **keine** führt die Bedingung *„eine Quelle innerhalb des Repos, die Haupt-Kontext-Token trägt"* — hält. *„unter ihnen"* macht die Liste korrekt zu einer offenen. **Ohne Befund.** |
| **N-3** | **Hunk 3 — die Sachzitate des neuen Frage-1-Absatzes** | *„ihre Bedingung ist erfüllt, sobald die `tool_response` eines Hintergrund-Laufs Zähler trägt"* → `spec/spezifikation.md:486-487` ✓ · *„ihn umschließt überhaupt kein solcher Aufruf"* → `spec:496-498` (*„Den Haupt-Kontext umschließt **kein** `Agent`-Aufruf"*) ✓ · *„durch einen `PreToolUse`-Guard **verkleinert** (er schließt die Lücke nicht …)"* → `spec:414-415` wörtlich ✓. **Ohne Befund — die Zitate tragen; defekt ist die Schlussfolgerung (M-1).** |
| **N-4** | **Hunk 4 — Alternative G** | *„die Berichtsgröße … steht geliefert als Festlegung im Technik-Stratum"* → `spec/spezifikation.md:269-286`, Überschrift *„Die BERICHTSGRÖSSE dieser Regel"* samt beider Festlegungen ✓ · *„erzeugt wird die Zahl erst von der Auswertung, und die ist geplant"* → `slice-066` DoD (1) liegt in `open/` ✓. Die Contra-Spalte ist unverändert. **Ohne Befund** (die Zustandsaussage *„läuft bereits"* ist **I-3**). |
| **N-5** | **Hunk 5 — die zwei substanziellen Hälften der Folgepflicht 2** | (a) *„Der Welle-Plan führt die Belegart **ADR-Verdikt** … als eigenen Wert mit dieser ADR als erstem Fall"* → `welle-09:104`, eigene Tabellenzeile, *„Erster Fall: `ADR-0012`"* ✓; die Zuordnung zu beiden Spalten steht in `:91-92` ✓. (b) *„mit dem Welle-Plan in dessen Plan-Tabelle"* → `slice-068:102`, Zeile `welle-09 | update` ✓. Der ersetzte Konjunktiv (*„ließe dafür nur die Wahl …"*) trifft zu: `welle-09:103` definiert *deklariert* weiterhin **mit** Auflösungs-Trigger. **Ohne Befund** (M-2 betrifft die Überschrift, L-1 die Provenienz). |
| **N-6** | **Hunk 6 — Zitattreue** | `spec/spezifikation.md:76` gelesen: *„kein Gate prüft, ob ein hier oder unter **Bewacht** genannter Wächter noch existiert oder noch so heißt"*. Die ADR `:245` gibt Wortstellung und Wortlaut jetzt exakt wieder. **Ohne Befund — L-2 der Vorrunde geschlossen.** |
| **N-7** | **Hunk 7 — die Präzedenz-Rechnung, selbst nachgezählt** | `git ls-tree --name-only 0fb1db8 test/mutations/`: **102** Einträge, alle `.sh`, keine Nicht-`.sh`-Datei; höchste Nummer **106**; Lücken 12, 14, 21, 22, 23, 25, 33, 35 (acht); Doppelvergaben 47, 48, 49, 50 (vier). 106 − 8 + 4 = 102 ✓. `107` fehlt im Annahme-Commit; `107-span-klemme-entfernt.sh` ist der erste Span-Fall (`spec:533`) ✓. Die übrigen Zahlen desselben Absatzes stehen unverändert und wurden in der Vorrunde belegt (fünf `test/mutations/`-Zeilen in `ADR-0011`). **Ohne Befund.** |
| **N-8** | **Hunk 8 — die zwei INFO-Korrekturen der Geschichte-Zeile** | *„Nummer, Überschrift **wörtlich**, das `Datum` und eine Zeiger-Zeile"* → `MR-020` (`harness/conventions.md:906-911`) legt genau diese vier fest; `conventions.md:835-838` führt alle vier am realen Eintrag ✓. *„Die **unterste** Zeile dieser Tabelle — die, die diese ADR eröffnet"* → `:300`, eindeutig, und unverändert. **Ohne Befund — I-1 und I-2 der Vorrunde geschlossen.** |
| **N-9** | **Die neue Geschichte-Zeile, alle übrigen Zuschreibungen** | *„stützte sich auf einen ‚ernst erreichbaren' Trigger …, den der Zielort nicht mehr führt"* → am Vorgänger-Bestand geprüft: `git show 736b562:harness/conventions.md` führte für Abweichung 5 **zwei** Trigger, davon einen durch Arbeit erreichbaren (*„die **Abdeckungszahl** … **messbar, aber noch nicht gemessen**"*); der ist beim Umzug entfallen ✓ · *„Folgepflicht 2 verlangte im Präsens eine Vokabular-Ergänzung, die längst steht"* ✓ · die vier kleineren Punkte decken sich mit L-1…L-4 der Vorrunde ✓. Ausnahmen: **L-2** (drei Regelblöcke) und **I-1** (Zeilen-Anlage). **Sonst ohne Befund.** |
| **N-10** | **Modul-7-Zitate und Zeilenverweise** (`:26-29`, `:46-93`, `:48`, `:48-67`, `:63-67`, `:105-110`, `:129`, `:130`, `:21`) | Alle am **vollständig gelesenen** Modul (132 Zeilen) geprüft. Die drei Blockzitate sind verbatim (`:28-29`, `:65-67`, `:129`); `:48-67` deckt beide Fragen in der Reihenfolge *Granularität vor Temporalität* (`:50-52` sagt es wörtlich); `:130` nennt beide BF-Symptome; `:21` trägt die Dateikonvention. `d021716` hat an keinem Zitat etwas geändert. **Ohne Befund** (die *Anwendung* ist M-1/L-3). |
| **N-11** | **Hard Rules** | §3.1: kein Gate in `make gates`, `AGENTS.md` §4 oder `harness/README.md` behauptet; die genannten Targets `make test` und `make mutate` existieren (`Makefile:47`, `:121`). §3.2/§3.3: nicht berührt — `d021716` ist ein reiner Inhalts-Commit an zwei Dateien, kein Move, keine Lint-Suppression. §3.4: Status bleibt **Proposed** (`:3`), Index-Status ebenfalls; keine Accepted-ADR überschrieben, keine Supersedes-Kette angefasst. §3.5: keine Gate-Lockerung — die ADR fügt zwei Wächter-Zeilen hinzu und nimmt keine weg. **Ohne Befund.** |
| **N-12** | **Template-Konformität** | Gegen `.harness/baseline/v3.5.2/templates/docs/plan/adr/NNNN-titel.template.md`: alle Pflicht-Abschnitte vorhanden (Status · Datum · Autor · Bezug · Schärft · Kontext · Entscheidung · Verglichene Alternativen · Konsequenzen · Fitness Function · Re-Evaluierungs-Trigger · Geschichte); ≥ 3 Alternativen (sieben, A–G); `Schärft` gefüllt und mit Aufwärts-Deklaration; Geschichte-Tabelle mit `Datum | Ereignis | Verweis`; Template-Hinweis-Block entfernt. **Ohne Befund.** |
| **N-13** | **Repo-Regel „eine ADR nennt keine Slice-Kennungen"** | Über die ganze Datei gemessen: `grep -cniE 'slice-[0-9]{3}\|welle-[0-9]{2}'` → **0** Treffer, auch in der Verweis-Spalte der Geschichte-Tabelle, die die Regel ausnehmen würde. Die Pflichten hängen an der **Funktion** (*„der Slice, der die Bilanz baut"*, *„der Slice, der die Rollen-Konvention schreibt"*). `d021716` hat keine Kennung eingeführt. **Ohne Befund; die Regel ist übererfüllt.** |
| **N-14** | **Gate-Aussagen der Fitness Function** | `make comment-claims` (`Makefile:135`): `internal/*.go`, `internal/**/*.go`, `cmd/**/*.go`, `harness/tools/*.sh`, `.claude/hooks/*.sh` — kein Markdown-Muster ✓ (die ADR nennt vier Pfad-**Familien**; die fünf Globs treffen dieselben). `make docs-check`: `modules: [links, anchors, ids, matrix, codepaths, spans]` (`.d-check.yml:18`) — *„keine Behauptungen"* trifft zu. **Ohne Befund.** |
| **N-15** | **Gate-Lauf** | `make docs-check` selbst gefahren: `d-check: 288 Datei(en) geprüft, 0 Befund(e)`. Deckt sich mit der Gate-Ausgabe des Commits (*„d-check 288/0"*). Die Links, Anker, Kennungs-Linkpflicht und die `matrix`-Regel *spec-straten → adr: allow false* sind grün. **Ohne Befund.** |
| **N-16** | **Vollständigkeitsaussage über die vendored Werkzeug-Doku** (`:153`, Alternative C) | Über alle **3.383** Zeilen von `docs/user/claude-hooks-referenz.md` neu gemessen: `usage` als Feldname genau einmal (`:1574`), `totalTokens` genau einmal (`:1571`); die übrigen Treffer sind die `/docs/de/monitoring-usage`-URL (`:641`, `:655`) und der Fehlertyp `max_output_tokens`. Die Spanne `:1571-1574` trifft die vier Werte. **Ohne Befund — die härteste Vollständigkeitsaussage der ADR hält auch in dieser Runde.** |
| **N-17** | **`slice-066` als Träger der zwei Fitness-Function-Zeilen** | Unverändert: DoD (2) ist ein eigener Punkt (`:70-84`) und nennt *„Zwei Zähne, rot gesehen"* — Go-Test (`make test`) und `test/mutations/`-Fall (`make mutate`) —, die Plan-Tabelle nennt sie ein zweites Mal (`:113`). `d021716` hat daran nichts angefasst; die Auflösung des Vorrunden-Befunds trägt fort. **Ohne Befund.** |
| **N-18** | **Status der referenzierten ADRs** | `ADR-0003`, `ADR-0011`, `ADR-0013`, `ADR-0014` sind **Accepted** (`docs/plan/adr/README.md:11,18,21,22`); keine superseded oder deprecated Referenz. `ADR-0013` Festlegung 1 deckt den `Schärft`-Zielort. **Ohne Befund.** |

---

## Kategorie-Summary

| Kategorie | Anzahl | IDs |
|---|---|---|
| **HIGH** | **0** | — |
| **MEDIUM** | **3** | M-1, M-2, M-3 |
| **LOW** | **3** | L-1, L-2, L-3 |
| **INFO** | **3** | I-1, I-2, I-3 |
| **Negativbefunde** | **18** | N-1 … N-18 |

**Zur Eskalations-Regel des Skills.** Die drei MEDIUM sind **nicht** dieselbe Klasse wie die der
Vorrunde. Dort war es durchgängig *„eine Aussage über umgezogenen oder geschlossenen Bestand wurde
nicht am neuen Stand geprüft"*. Hier ist es zweimal *„der Fix hat den Satz geändert, ohne die
Umgebung mitzulesen"* (M-1: ein neuer Absatz widerspricht sich in vier Zeilen; M-2: eine neue
Überschrift kippt die Zeitform des unveränderten Satzes darunter) und einmal *„der Fix hat den
Befund an einer von zwei Stellen behoben"* (M-3: der ADR-Index). Der strukturelle Grund ist
unverändert und benannt: für Zuschreibungen in Markdown existiert in diesem Repo **kein** Sensor
— `comment-claims` deckt kein Markdown, `d-check` prüft Links, Anker, Kennungen und
Zeilenspannen, keine Sätze —, und ab *Accepted* kommt die Immutabilität hinzu. Für ADR-Text ist
die Prüfung nicht nur der einzige, sondern der letzte Sensor.

**Ausdrücklich festgehalten, was trägt.** Alle vier LOW und beide INFO der Vorrunde sind sauber
und am Original belegt geschlossen — die Präzedenz-Rechnung ist jetzt selbst nachgezählt richtig
(102 mit acht Lücken und vier Doppelvergaben), das Zitat ist wortgetreu, die Frageliste offen und
vollständig genug, die Berichtsgröße als geliefert geführt, die Bestandteile des aufgehobenen
Eintrags korrekt bei vier, die gemeinte Geschichte-Zeile eindeutig. Der Kern von M-2 der Vorrunde
ist im Rumpf behoben. Die **Entscheidung selbst** — Option F, permanent, mit der Nenner-Pflicht
als positiver Hälfte — ist in dieser Runde an keinem Punkt strittig: die Frage-2-Antwort steht
eigenständig, die Frage-1-Antwort steht über die beiden BF-Symptome, die Alternativen sind
vollständig, die Fitness Function ist zweigeteilt und hat für die prüfbare Hälfte einen Träger
mit zwei namentlich genannten Zähnen.

---

## Verdikt

**NICHT KONFORM.**

Drei MEDIUM blockieren nach Skill (*„HIGH und MEDIUM blockieren typischerweise"*). Kein HIGH —
und wie in der Vorrunde liegt kein Befund in der Entscheidung.

Was der Annahme im Weg steht, sind drei Sätze, nicht die Wahl:

1. **M-1** — der Absatz, der die Trichter-Frage 1 beantwortet, trennt die zwei Abweichungen auf
   dem Frage-2-Kriterium (`:87-89`, *„das ist Frage 2"*) und behauptet drei Zeilen später ihre
   Gleichheit auf demselben Kriterium (`:90`), begründet mit der *Bemerken*-Eigenschaft, die
   `:109-110` für Frage 2 ausdrücklich ausschließt.
2. **M-2** — Folgepflicht 2 trägt jetzt die Überschrift *„eingelöst"* über einem unveränderten
   Präsens-Satz, der eine Matrix-Zelle als gefüllt beschreibt; die Zelle entsteht nach
   `slice-068` DoD (3) erst bei der Wellen-Closure und trägt den Wert *„erst mit der Annahme"* —
   `welle-09-results.md` gibt es im Repo nicht (über `docs/` gemessen).
3. **M-3** — der ADR-Index (`docs/plan/adr/README.md:20`) führt weiterhin *„die Abweichung vom
   Modul-15-Pflicht-Minimum"*, also genau die Zuschreibung, die derselbe Commit im Rumpf als
   falsch benennt und behebt; ADR und Index widersprechen sich damit über die Regelblock-Zuordnung.

Alle drei sind vor der Annahme billig zu klären und danach nach `AGENTS.md` §3.4 nur noch per
Supersedes. Über die Annahme entscheide ich nicht; ich stelle den Zustand fest.

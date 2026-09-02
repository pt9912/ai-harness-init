# Review — ADR-0028 (Konsistenzprüfung vor dem Acceptance-Trigger)

| Feld | Wert |
|---|---|
| **Rolle** | Reviewer (Modul 8/10) — frischer Kontext, getrennt von Architektur, Planung und Implementation |
| **Review-Art** | **Plan-/Design-Review** gegen aktive ADRs, Hard Rules und die Ziel-Form der ADR-Vorlage. **Nicht** DoD-Abhakung (Verifier, Modul 11), **keine** inhaltliche Neubewertung der Entscheidung |
| **Gegenstand** | [`docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md`](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md), Status `Proposed`, angelegt in `2dc505a` (2026-08-31 09:46 +0200) |
| **Auftrag** | Baseline-Regelwerk `modul-08-agentenrollen.md` §Rollen-Regeln — *„ADR-Änderung: Architect schreibt; Reviewer prüft auf Konsistenz; Implementer liest als Constraint"*. Dieser Lauf **ist** die ADR-Review-Runde, die `grundlagen-bootstrap.md` §Vier Trigger-Klassen als Acceptance-Trigger führt (*„ADR-Review-Runde abgeschlossen → bindend"*) |
| **Plan** | [`docs/plan/planning/next/slice-145-adr-0028-acceptance-trigger-und-agents-zeiger.md`](../plan/planning/next/slice-145-adr-0028-acceptance-trigger-und-agents-zeiger.md), DoD (1) |
| **Bindende ADRs** | `ADR-0015` (Accepted), `ADR-0016` (Accepted), `ADR-0024` (Accepted) · zur Kohärenz mitgelesen, **nicht bindend**: `ADR-0025` (Proposed), `ADR-0029` (Proposed) |
| **Anforderungen / Normen** | `AGENTS.md` §3.1, §3.4, §3.6, §3.7, §3.8 · `MR-000`, `MR-015`, `MR-018`, `MR-021`, `MR-025`, `MR-030` · `LH-QA-01` |
| **Vorherige Findings am gleichen Modul** | `docs/reviews/2026-08-31-slice-144-review.md` HIGH-1 — der Befund, der diese ADR über den Konflikt-Pfad ausgelöst hat; `docs/reviews/2026-08-29-adr-0024-mr-031-032-review.md` — die Vorgänger-Runde derselben ADR-Familie, deren zwei Befunde (Status ohne Trigger · Festlegung schließt den eigenen Anwendungsfall aus) hier gezielt gegengeprüft wurden |
| **Skill-Version** | `.harness/skills/reviewer.md` 1.5.0 |
| **Modell** | Claude Opus 5 (1M context) |
| **Mess-Basis** | Arbeitsbaum-`HEAD` `7485be3` (2026-09-02 18:50 +0200). Alle Zahlen unten in dieser Sitzung selbst gefahren; jede steht neben dem Kommando, das genau sie ausgibt. Dieses Dokument ist ein **Zeitdokument** — es hält den Stand seines Laufs fest und wird nicht nachgezogen |
| **Kontext frisch** | ja — keine Einschätzung des Architect-Laufs ungeprüft übernommen; alle Zitate gegen die Quelle gehalten, nicht gegen die zitierende Stelle |

**Was in diesem Lauf gefahren wurde.** Kein Gate-Lauf (der Gegenstand ist ein Dokument, kein
Codepfad); stattdessen zehn Verbatim-Proben gegen den vendored Baum, fünf Zähl-Kommandos gegen
`HEAD` und dieselben fünf gegen `2dc505a` (den Commit, der die ADR anlegte), zwei Struktur-Proben
(ADR-Vorlage, `.d-check.yml`), sowie die Gegenprüfung der drei in Festlegung 3 genannten
Cross-Check-Orte. Der Arbeitsbaum wurde nicht verändert; das einzige Schreibprodukt dieses Laufs
ist diese Datei.

---

## Findings

### HIGH-1 — Die acht Baseline-Belege tragen den Tag nicht, und `ADR-0016` bindet genau den Übergang, der jetzt ansteht

- **kategorie:** HIGH
- **quelle:** `ADR-0016` (Accepted) Festlegung 2 und Festlegung 3 (a)
- **pfad:** `docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md:46,48,58,67-71,169-171,211,300`
- **befund:** Die ADR belegt acht Regelwerks-Stellen mit Dateiname, Abschnittsname und
  Verbatim-Zitat — alle zehn geprüften Zitate sind wörtlich korrekt (siehe Negativbefunde) —,
  nennt aber an **keiner** dieser Stellen den Tag. `ADR-0016` Festlegung 2 verlangt für ein
  Artefakt, das unveränderlich wird (namentlich: *„eine ADR ab Accepted"*), drei Teile je Beleg:
  **Tag** · **Regelwerks-Dateiname und Abschnittsname** · **Zitat verbatim**. Festlegung 3 (a)
  legt den Träger auf exakt diesen Zeitpunkt fest — *„Bevor der Status eines ADR auf Accepted
  wechselt, werden seine Baseline-Belege in die Form aus Festlegung 2 gebracht"* — und schließt
  den naheliegenden Einwand vorab aus: *„Ein Proposed-Artefakt ist kein Bestand, sondern wird
  geschrieben — der Cutoff aus Festlegung 1 deckt es nicht, Träger (a) bindet es."* Gemessen
  steht der Tag im ganzen Dokument **einmal**, und zwar nicht an einem Beleg, sondern in
  Re-Evaluierungs-Trigger 1 (Zeile 279):
  `grep -c 'v[0-9]\.[0-9]*\.[0-9]*' docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md`
  → **1**; dieselbe Zählung über die drei Geschwister derselben Familie:
  `for f in 0015 0024 0025; do grep -c 'v[0-9]\.[0-9]*\.[0-9]*' docs/plan/adr/$f-*.md; done`
  → **20**, **7**, **9**. Keine Erwartungswerte — sie wandern mit dem Text; tragend ist der
  Abstand zwischen **1** und den drei anderen. Eine der acht Stellen (Zeile 169–171) nennt
  darüber hinaus nicht einmal die Quelldatei: die Klammer wird mit *„nach `modul-06-roadmap.md`
  §Wellen-Closure-Prozedur"* eröffnet, das darin gesetzte Zitat *„Nur 1, 2 und 3b tragen einen
  Rollenwechsel; 3a, 3c, 4 und 5 laufen im Planner-Kontext"* steht jedoch in
  `modul-08-agentenrollen.md` §Rollen-Sequenz für eine Welle
  (`grep -rn 'Nur 1, 2 und 3b tragen einen Rollenwechsel' .harness/baseline/v5.12.0/regelwerk/`
  → genau eine Fundstelle, `modul-08-agentenrollen.md:68`). **Failure-Szenario:** Beim nächsten
  Baseline-Tausch verschwindet der Baum `v5.12.0` vollständig (`MR-007`, ein Tag zur Zeit).
  Wer dann die tragende Prämisse der ADR nachschlägt — *„die Baseline benennt für Command-
  Artefakte keine schreibende Rolle"* —, findet einen anderen Baum und kann nicht entscheiden,
  ob die Aussage je gegen den damals gepinnten Stand gemessen wurde. `AGENTS.md` §3.4 sperrt ab
  dann die Ein-Zeilen-Korrektur; `ADR-0016` beziffert diesen Preis selbst: *„nach der Annahme ist
  derselbe Satz durch §3.4 unerreichbar, und der Preis steigt von einer Zeile auf eine
  Folge-ADR."*
- **verifizierbar:** ja, aber **nicht durch ein Gate** — kein Modul der `.d-check.yml`
  (`grep -m1 '^modules:' .d-check.yml` → `[links, anchors, ids, matrix, codepaths, spans]`)
  prüft die Beleg-Form; `ADR-0016` Festlegung 3 nennt den Sensor ausdrücklich *mechanisierbar,
  aber nicht gebaut*. Bestätigt wird der Befund durch die zwei `grep -c`-Kommandos oben.
- **klasse:** „Baseline-Beleg ohne Tag in einem Artefakt, das mit dem nächsten Commit eingefroren
  wird"

### MEDIUM-1 — Fünf Messwerte ohne Mess-Basis; drei davon sind am heutigen Baum falsch, und der falscheste trägt die Aussage des Absatzes

- **kategorie:** MEDIUM
- **quelle:** `MR-025` Setzung 1 und Setzung 2 (von der ADR in ihrer eigenen `**Bezug:**`-Zeile
  angeführt: *„jede Zahl unten steht neben dem Kommando, das sie liefert"*); Präzedenz
  `ADR-0024` §Geschichte und `ADR-0025` §Kontext
- **pfad:** `docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md:113-124` (vier
  `git log`-Kommandos), `:36-39` und `:45` (der `BEO-007`-Zählerstand)
- **befund:** Die vier Kommandos im Kontext-Block laufen ohne Mess-Basis gegen `HEAD`. Am
  Anlege-Commit waren sie exakt — nachgefahren:
  `git log --format='%s' 2dc505a -- .claude/commands/ | wc -l` → **10**,
  `… | grep -c '^Rolle '` → **0**,
  `git log --format='%s' 2dc505a -- .claude/agents/ | wc -l` → **3**, `… | grep -c '^Rolle '`
  → **0**. Dieselben vier Kommandos, wie sie in der ADR stehen (ohne Ref, also gegen `HEAD`
  `7485be3`): **13**, **1**, **4**, **0**. Damit ist der Satz, den die vier Zahlen tragen, in
  **beiden** Hälften unwahr: *„Keine der beiden Dateimengen trägt ein einziges Rollen-präfigiertes
  Commit — nicht, weil eine zweite Rolle geschrieben hätte, sondern weil beide Verzeichnisse
  zuletzt vor Einführung der Präfix-Konvention berührt wurden."* Der eine Treffer ist `20a3e33`
  *„Rolle Architect: slice-083 Durchgang 2 …"*, und er berührt `.claude/commands/close-welle.md`
  (`git show 20a3e33 --stat --format=`). Der fünfte Wert ist der `BEO-007`-Zählerstand *„1×"*: er
  trägt **kein** Kommando (`MR-025` Setzung 1) und steht heute bei **4×** —
  `grep -c 'BEO-007 |' docs/plan/planning/observations.md` → **1** Zeile, deren Zähler-Spalte
  `4×` und deren Beleg-Spalte `slice-137, slice-144, slice-147, slice-148` führt. Keiner der fünf
  Werte ist als *kein Erwartungswert* gekennzeichnet, wie `MR-025` Setzung 2 es für mitwandernde
  Zahlen verlangt. **Failure-Szenario:** Der Absatz sagt selbst, die Zahlen *„tragen nichts zur
  Entscheidung bei"* — der Schaden liegt darum nicht in der Entscheidung, sondern in dem, was
  `MR-025` als den teureren Effekt benennt: ein Lauf zählt eine ausgewiesene Messung nach, findet
  drei von fünf Werten falsch, und gewöhnt sich ab, Messungen nachzuzählen. Die Präzedenz gegen
  genau diesen Fall steht in der Familie selbst: `ADR-0024` pinnt `3360c2e` in die Kommandos mit
  der Begründung, drei Werte bewegten sich *„mit jedem Commit an dieser Datei — auch mit dem, der
  diese ADR annimmt … statt im selben Zug zu veralten, in dem §3.4 sie einfriert"*; `ADR-0025`
  pinnt `b1b1ab7..722e272` aus demselben Grund.
- **verifizierbar:** ja — die neun Kommandos oben, wiederholbar gegen jeden Commit-Stand. Kein
  Gate: `MR-025` liegt nach eigener Aussage im Feedforward-Quadranten.
- **klasse:** „Mitwandernde Zahl ohne Mess-Basis in einem Artefakt, das eingefroren wird"

### MEDIUM-2 — Festlegung 2 beantwortet im selben Satz, was sie zu übergehen erklärt — und schreibt die Antwort einer ADR zu, die sie ausdrücklich nicht gibt

- **kategorie:** MEDIUM
- **quelle:** `ADR-0015` (Accepted) Festlegung 1 und §Was hier NICHT entschieden ist;
  `ADR-0024` (Accepted) §Was hier NICHT entschieden ist
- **pfad:** `docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md:180-187`
- **befund:** Festlegung 2 lautet: *„Über **diesen Teil** sagt diese ADR nichts; er bleibt bei der
  Rolle, die ADR-0015 für genau solche Aussagen bestimmt hat — dem Architect."* Beide Hälften
  stehen gegeneinander: der zweite Halbsatz nennt eine Rolle für den Rest und ist damit die
  Eigentums-Aussage, die der erste ausschließt. Die Zuschreibung an `ADR-0015` ist gegen die
  Quelle gehalten zu weit. `ADR-0015` Festlegung 1: *„Über die übrigen Norm-Artefakte trifft diese
  ADR **keine** Aussage — sie bestätigt keine fremde Zuordnung und setzt keine neue"*, und ihr
  Abschnitt §Was hier NICHT entschieden ist führt namentlich *„eine Eigentums-Aussage über
  irgendein drittes Artefakt"*. Sie weist den Architect **zwei benannten Artefakten** zu
  (`AGENTS.md` §3, Adaptions-Block), nicht einer Aussagen-**Klasse** an beliebigem Ort; eine
  Norm-Aussage ohne Original in einer Command-Datei ist genau das dritte Artefakt, das sie
  ausnimmt. Zum Vergleich die Schwester-Entscheidung für denselben Rest: `ADR-0024` führt in §Was
  hier NICHT entschieden ist *„die Rolle für eine bindende Aussage ohne Original, falls eine in
  ein Register gerät (Festlegung 1 grenzt sie ab und beantwortet sie nicht)"* — dort ist der Rest
  offen, hier ist er beantwortet, und der Abschnitt §Was hier NICHT entschieden ist dieser ADR
  führt ihn nicht mehr auf. **Kein Widerspruch im Ergebnis:** *Architect* ist unter beiden Lesarten
  die plausible Antwort, und `AGENTS.md` §3.8 begründet sie allgemein (*„ob eine Abweichung von der
  Baseline besteht, ist eine Architektur-Frage"*). **Und der Befund ist nicht datei-lokal:** die
  identische Verallgemeinerung steht in `ADR-0025` Festlegung 2 und in `ADR-0029` Festlegung 1,
  beide `Proposed` — die Klasse ist damit dreifach vorhanden, nicht ein Ausrutscher dieser Datei.
  **Failure-Szenario:** Ein künftiger Lauf zitiert die eingefrorene Festlegung 2 als Beleg dafür,
  dass `ADR-0015` die Klasse *„bindende Aussage ohne Original"* repo-weit dem Architect zugewiesen
  habe, und stützt darauf eine Zuständigkeit, die keine angenommene Quelle setzt — dieselbe
  Ableitung-ohne-Quelle, gegen die diese ADR-Familie angetreten ist.
- **verifizierbar:** ja — die drei Zitate oben gegen `docs/plan/adr/0015-…md` und
  `docs/plan/adr/0024-…md`. Kein Gate: `matrix` prüft Referenz-**Richtung** und Status, nicht
  Zuschreibungs-Weite.
- **klasse:** „Eine ADR schreibt einer Vorgänger-ADR eine Zuordnung zu, die deren eigene Verengung
  ausdrücklich ausschließt"

### MEDIUM-3 — Der Slice, der diese ADR annehmen soll, rechnet mit einem Register-Stand, den das Register seit zwei Slices nicht mehr hat

- **kategorie:** MEDIUM
- **quelle:** Slice-Plan §2 DoD-Punkt *Beobachtungs-Register* und §8 *Vorgelagert — offene
  Beobachtungen sichten*, gegen `docs/plan/planning/observations.md`; Baseline-Regelwerk
  `modul-06-roadmap.md` §Das Beobachtungs-Register
- **pfad:** `docs/plan/planning/next/slice-145-adr-0028-acceptance-trigger-und-agents-zeiger.md:110-115`
  und `:230-232`
- **befund:** Der Plan sagt zu, `BEO-007` bekomme seinen Ausgang *„**verkörpert** über ADR-0028 und
  den `AGENTS.md`-Zeiger aus DoD (2), nicht über die 3×-Schwelle (der Zähler bleibt bei 1×)"*, und
  sein §8-Sichtungsblock notiert *„`BEO-007` steht im Register (Sub-Area `*`, 1×, Beleg
  slice-137)"*. Gemessen am heutigen Register steht die Zeile bei **4×** mit den Belegen
  `slice-137, slice-144, slice-147, slice-148` und dem Stand *„**Schwelle erreicht**, weiter
  offen"*; sie führt dort ausdrücklich nicht mehr nur den Erstauftritts-Ort, sondern die
  **Klasse** — *„ein Norm-Artefakt ohne benannte schreibende Rolle"* —, und die zwei jüngsten
  Belege (`slice-147`, `slice-148`) liegen **außerhalb** von `.claude/commands/`, nämlich bei den
  Spec-Straten. Damit deckt der in DoD zugesagte Ausgang die Zeile nicht mehr: ADR-0028 beantwortet
  die Command-Hälfte, `ADR-0029` (`Proposed`) die Agenten-Hälfte, für die Spec-Straten-Hälfte
  benennt keine der beiden eine Rolle. Das Register weist den Lese-Schritt zudem einer anderen
  Stelle zu als der Plan: *„Der Lese-Schritt liegt bei der Closure von welle-10"*, Rollen-Zug
  Planner → Architect → Planner. **Failure-Szenario:** Die Closure dieses Slice trägt den Ausgang
  wie geplant ein und setzt eine Zeile auf *verkörpert*, deren zwei jüngste Belege von keiner
  Entscheidung berührt sind — der Zähler verliert genau die Beobachtung, für die er zählt, und
  zwar unter der Kennung, die sie zusammenhält.
- **verifizierbar:** ja — `awk -F'|' '$2 ~ /BEO-007/{print $5, $6}' docs/plan/planning/observations.md`
  → ` 4×   slice-137, slice-144, slice-147, slice-148` (Selektor auf Spalte 2, weil die Kennung auch in der `Stand`-Zelle einer anderen Zeile vorkommt), gegen den zitierten DoD-Text. Kein Gate: die maschinelle Hälfte der Register-Paarung prüft
  Deckung (Zeile existiert, Beleg vorhanden), nicht ob ein eingetragener Ausgang trägt — das ist
  nach `modul-06-roadmap.md` ausdrücklich das Urteil.
- **klasse:** „Plan-Zusage über den Stand eines lebenden Registers, gemessen zum Schnitt-Zeitpunkt
  statt zum Ausführungs-Zeitpunkt"

### LOW-1 — Die Verlagerung der sechs kanonischen Namen ist dem falschen `MR`-Eintrag zugeschrieben, und `MR-018` ist nicht teil-aufgehoben

- **kategorie:** LOW
- **quelle:** `MR-018` (Kopf), `MR-021` (Geltungsbereich), `MR-030` (Geltungsbereich)
- **pfad:** `docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md:133-138`
- **befund:** Der Satz lautet: *„die sechs kanonischen Namen stehen seit `MR-030` in
  `spec/spezifikation.md` §5; `MR-018` selbst trägt seit seiner Teil-Aufhebung nur noch den
  Kopf."* Gemessen: `MR-018`s Kopf sagt *„**Aufgehoben durch `MR-021`**"* — eine volle Aufhebung
  in der Kopf-statt-Rumpf-Form, keine Teil-Aufhebung; die Feldtabelle samt Namen wanderte mit
  `MR-021` (Datum 2026-08-02, Geltungsbereich: `MR-018` sowie die Abschnitte 3 und 5 der
  Spezifikation) nach `spec/spezifikation.md` §5. `MR-030` (Datum 2026-08-28) betrifft nach seinem
  eigenen Geltungsbereich nur *„den Absatz über die kanonischen Agenten-Typ-Namen"* in derselben
  §5 und löst dort eine Abweichung auf — er verlagert nichts. Die Aussage des Absatzes (der
  Cross-Check-Charakter bleibt, nur die dritte Stelle hat gewechselt) trägt unabhängig davon.
  **Failure-Szenario:** Wer die Verlagerung nachschlägt, landet auf dem Eintrag, der sie nicht
  vollzogen hat, und liest die Aufhebungs-Kette rückwärts falsch.
- **verifizierbar:** ja — `awk '/^### MR-018/,/^### MR-019/' harness/conventions.md` und dasselbe
  für `MR-021`/`MR-030`. Kein Gate.
- **klasse:** „Verlagerung dem nachfolgenden Eintrag zugeschrieben statt dem verlagernden"

### INFO-1 — Der Begriff *Anweisungssatz* deckt die Skill-Datei, die Anwendungs-Liste nennt sie nicht; und die Klasse wurde zwei Tage vor diesem Review erneut rollen-fremd geschrieben

- **kategorie:** INFO
- **quelle:** Maintainability; `docs/plan/adr/0028-…md` §Entscheidung gegen §Re-Evaluierungs-Trigger
- **pfad:** `docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md:158-173`
  gegen `:276-279`
- **befund:** Die Entscheidung definiert den Gegenstand allgemein (*„ein Artefakt, das die
  operative Ausführung genau einer Rolle für deren eigenen Ablauf distilliert"*), und
  Re-Evaluierungs-Trigger 1 spricht von *„Command- oder Skill-Artefakte"* — die
  **Angewandt**-Liste in Festlegung 1 führt jedoch nur die drei Commands.
  `.harness/skills/reviewer.md`, das `.claude/agents/reviewer.md` selbst als den Anweisungssatz
  des Reviewers benennt, erscheint allein als Baseline-*Präzedenzfall*. Die Antwort wäre auf
  beiden Wegen dieselbe (Reviewer); ausgesprochen ist der Geltungsbereich nicht. Dazu eine
  Beobachtung für den annehmenden Lauf, **kein** Vorwurf an die ADR: `20a3e33` (2026-08-31, nach
  dem Anlege-Commit) ändert in **einem** Architect-Commit `.claude/commands/close-welle.md` und
  `.harness/skills/reviewer.md` — nach Festlegung 1 Planner- bzw. Reviewer-Territorium
  (`git show 20a3e33 --stat --format=`). Der Cutoff der ADR (*„geprüft wird ab dem Commit, der
  diese ADR annimmt"*) deckt das; es datiert lediglich, ab wann Re-Evaluierungs-Trigger 4
  (*„wenn die Klasse ein weiteres Mal ohne Träger auftritt, obwohl der Träger jetzt steht"*) zu
  zählen beginnt.
- **verifizierbar:** ja — `git show 20a3e33 --stat --format=`; die Geltungsbereichs-Hälfte ist
  Textbefund, kein Kommando.
- **klasse:** „Geltungsbereich im Definitions-Satz weiter als in der Anwendungs-Liste"

## Negativbefunde

- **Prüfpunkt 1a — Widerspruch zu `ADR-0015` (Accepted):** geprüft, kein Befund über MEDIUM-2
  hinaus. Festlegung 1 der ADR-0028 besetzt ausschließlich Artefakte, für die `ADR-0015` die Frage
  offen gelassen hat (*„wo keine sie benennt, bleibt das eine offene Frage, die diese Verengung
  ausdrücklich stehen lässt"*); sie ändert an den zwei dort besetzten Artefakten nichts, ihr
  Cutoff und ihre Folgepflicht 2 (kein Adaptions-Eintrag, `MR-000`) sind wörtlich die von
  `ADR-0015`. Kein `Supersedes` nötig, keiner behauptet.
- **Prüfpunkt 1b — Widerspruch zu `ADR-0024` (Accepted):** geprüft, kein Befund. Die beiden
  Ableitungen laufen auf verschiedene Gegenstände (derivatives **Register** ↔
  **Anweisungssatz**) und verwenden verschiedene Vorfragen (*wessen Original projiziert die
  Aussage?* ↔ *wer führt den Ablauf aus?*). ADR-0028 §Kontext liest die Artefaktklassen-Tabelle
  aus Modul 8 ausdrücklich **nicht** als Eigentums-Aussage und benennt genau die Inversion, vor
  der `ADR-0015` warnt — die Falle der Vorgänger-Runde ist gesehen, nicht wiederholt.
- **Prüfpunkt 1c — Verhältnis zu `ADR-0029` und `ADR-0025` (beide `Proposed`, nicht bindend):**
  geprüft, kein Befund. Festlegung 3 nimmt `.claude/agents/*.md` aus und lässt die Frage offen;
  `ADR-0029` füllt sie mit einer anderen Ableitung und sagt selbst, sie ersetze Festlegung 3
  nicht. Das ist die Form, die `ADR-0024` → `ADR-0025` schon einmal gefahren hat (*„hier wird
  nichts abgelöst, sondern der von ihr benannte offene Punkt gefüllt. Kein `Supersedes`."*). Eine
  Annahme von ADR-0028 nimmt `ADR-0029` nichts vorweg — im Gegenteil: deren Festlegung 1, zweiter
  Spiegelstrich, stützt sich auf ADR-0028 Festlegung 1 und stünde danach auf einer angenommenen
  statt einer vorgeschlagenen Quelle.
- **Prüfpunkt 2 — innere Kette Kontext → Entscheidung → Konsequenzen:** geprüft, kein Befund über
  MEDIUM-2 hinaus. Jede der drei Festlegungen hat ihren tragenden Absatz in §Kontext (Festlegung 1
  → *Was die Baseline regelt* + *Was dieses Repo bereits sagt*; Festlegung 2 → dieselbe Grenze wie
  bei den Geschwistern; Festlegung 3 → *Warum `.claude/agents/*.md` eine andere Klasse sind*). Die
  sechs Optionen tragen je ein Contra, das auf ein Zitat oder eine Messung zeigt, und die gewählte
  Option C trägt ihren Preis (*„die Vorfrage … ist ein Urteil, kein Muster"*) auch in
  §Konsequenzen. Alle vier Folgepflichten nennen Adressat **und** Fälligkeitsmoment; Folgepflicht 1
  wartet ausdrücklich auf die Annahme, mit derselben Begründung wie `ADR-0025` Folgepflicht 2.
- **Prüfpunkt 2b — Prämisse von Folgepflicht 1:** geprüft, kein Befund. *„`AGENTS.md` §3.8 zeigt
  heute auf ADR-0024 und endet dort"* — `grep -c 'ADR-0024' AGENTS.md` → **1**,
  `grep -c 'ADR-0028' AGENTS.md` → **0**. Die Zusage, dieser Lauf schreibe `AGENTS.md` nicht, ist
  am Commit `2dc505a` eingehalten (`git show 2dc505a --stat --format=` nennt `AGENTS.md` nicht).
- **Prüfpunkt 3 — Zirkularität von Festlegung 3:** geprüft, kein Befund. Die Ausnahme ruht auf drei
  **gemessenen** Eigenschaften, nicht auf ihrem eigenen Ergebnis: der Gründungs-Commit sagt
  *„ABSICHTLICH DUENN"* und *„ZEIGEN darauf und wiederholen nichts"* (`git log -1 --format=%B
  e30e0fd`, verbatim geprüft), der Cross-Check über drei Stellen steht im selben Commit-Text, und
  der Cross-Role-Commit ist real (`git show b39d4ff --stat --format=` → `.claude/agents/reviewer.md`
  8 Zeilen, `.claude/agents/verifier.md` 8 Zeilen). Re-Evaluierungs-Trigger 3 benennt die
  Bedingung, unter der die Begründung fällt (*„die Begründung dafür ruht auf der heutigen,
  gemessenen Dünnheit"*) — das ist das Gegenteil eines Zirkels. Die Analogie zu `ADR-0025` ist
  ausdrücklich als **nicht entscheidend** markiert.
- **Prüfpunkt 3b — die drei in Festlegung 3 genannten Cross-Check-Orte:** geprüft, kein Befund. Die
  sechs kanonischen Namen stehen in `spec/spezifikation.md` §5 (`grep -n 'kanonischen Namen der
  Agenten-Typen' spec/spezifikation.md` → Zeile 429); `roleFromAgentType` existiert
  (`grep -rn 'roleFromAgentType' --include=*.go .` → `internal/span/emit.go:166` und
  `internal/span/response.go`). Der Cross-Check-Charakter der Menge ist damit belegt, nicht bloß
  behauptet.
- **Prüfpunkt 4 — Zitat-Treue, zehn Proben, alle verbatim:** geprüft, kein Befund. Gegen
  `.harness/baseline/v5.12.0/regelwerk/modul-08-agentenrollen.md` (whitespace-normalisiert, je
  genau 1 Treffer): *„Sie greift ab **HIGH mit Rollen-Widerspruch** oder ab dem **dritten**
  gleichen Konflikttyp"* · *„bei isolierten LOW/INFO-Findings ist die Sequenz Overkill"* ·
  *„**Briefing** (`AGENTS.md` + 8-Schritt-Workflow)"* · *„R aktualisiert Skill-Datei"* ·
  *„Lockerung legitim, aber undokumentiert"* · *„Folge-ADR + Erinnerungs-Slice in `next/`"* ·
  *„Nur 1, 2 und 3b tragen einen Rollenwechsel; 3a, 3c, 4 und 5 laufen im Planner-Kontext"* ·
  *„ADR-Änderung: Architect schreibt; Reviewer prüft auf Konsistenz"*. Gegen `AGENTS.md`:
  *„Über andere Norm-Artefakte sagt diese Regel nichts."* und *„wo keine sie benennt, bleibt die
  Frage offen"*. Gegen `grundlagen-bootstrap.md` §Vier Trigger-Klassen: der Acceptance-Trigger
  *„ADR-Review-Runde abgeschlossen"* steht dort in der Acceptance-Zeile (Zeile 196). Die
  Verortungs-Lücke einer dieser Stellen ist in HIGH-1 erfasst, die Wortlaute selbst sind sauber.
- **Prüfpunkt 4b — Zitate aus dem Repo-Bestand:** geprüft, kein Befund. Der Blockzitat-Auszug aus
  `e30e0fd`, die zwei `.claude/agents/`-Zitate (`implementer.md`, `planner.md`) und die drei
  Command-Eröffnungszeilen (*„Dieser Command führt die **Implementation**-Rolle (Modul 9) für
  *einen* Slice"* · *„… die **Planner**-Rolle für *eine* Welle"* · *„… die **Planner**-Rolle für
  die **Wellen-Closure**"*) stehen wörtlich so im Baum; die Aussage *„Jeder der drei Commands
  benennt seine ausführende Rolle selbst, an derselben Stelle, im selben Satzmuster"* ist am Text
  nachvollzogen und trifft zu.
- **Ziel-Form der ADR-Vorlage:** geprüft, kein Befund. Kopf (`Status`, `Datum`, `Autor`, `Bezug`,
  `Schärft`) und alle sieben Pflicht-Abschnitte der Vorlage
  `.harness/baseline/v5.12.0/templates/docs/plan/adr/NNNN-titel.template.md` sind in der
  Vorlagen-Reihenfolge vorhanden; der Schluss-Satz zur Immutabilität steht.
- **`LH-QA-01` (keine halluzinierten Gates):** geprüft, kein Befund. §Fitness Function behauptet
  ausdrücklich **kein** Gate und begründet die Lücke gegen die reale Konfiguration —
  `grep -m1 '^modules:' .d-check.yml` → `modules: [links, anchors, ids, matrix, codepaths, spans]`,
  deckungsgleich mit der Aufzählung in der ADR; die zwei genannten `mutate`-Fehlschlag-Formen sind
  dieselben, die `ADR-0015`, `ADR-0024` und `ADR-0025` führen.
- **`AGENTS.md` §3.7 (Zustandsfeld / Kommentar trägt keine Chronik):** geprüft, kein Befund **in
  der ADR**. Die Geschichte-Tabelle ist der von der Vorlage vorgesehene Ort für Provenienz, und
  `matrix.exclude-sections` nimmt sie ausdrücklich aus; §Kontext erzählt den Anlass, was für den
  Abschnitt *Kontext* die Aufgabe ist, nicht der Verstoß.
- **Nicht geprüft (bewusst außerhalb dieses Laufs):** der **Inhalt** der drei Commands und der
  sechs Typkarten; die DoD-Abhakung und der Gate-Lauf von `slice-145` (Verifier, Modul 11); die
  innere Konsistenz von `ADR-0029` (eigener Gegenstand, eigener Lauf); die Form der `Stand`-Zelle
  von `BEO-007` im Register (Planner-Artefakt, hier nur auf ihren **Wert** gelesen).

## Kategorie-Summary

- HIGH: 1
- MEDIUM: 3
- LOW: 1
- INFO: 1

**Finding-Klassen dieses Laufs (für die Slice-Closure §7 und den Zähler):**
„Baseline-Beleg ohne Tag in einem Artefakt, das eingefroren wird" ·
„Mitwandernde Zahl ohne Mess-Basis in einem Artefakt, das eingefroren wird" ·
„Eine ADR schreibt einer Vorgänger-ADR eine Zuordnung zu, die deren eigene Verengung ausschließt" ·
„Plan-Zusage über den Stand eines lebenden Registers, gemessen zum Schnitt- statt zum
Ausführungs-Zeitpunkt" · „Verlagerung dem nachfolgenden Eintrag zugeschrieben statt dem
verlagernden" · „Geltungsbereich im Definitions-Satz weiter als in der Anwendungs-Liste".

Die ersten beiden Klassen teilen einen Mechanismus und sind zusammen zu lesen: **eine Aussage, die
mit dem Baum wandert, wird durch `AGENTS.md` §3.4 in dem Moment eingefroren, in dem niemand sie
mehr korrigieren darf.** Beide Geschwister-ADRs dieser Familie haben genau dafür je einen eigenen
Mechanismus mitgeführt (Tag im Beleg, Mess-Basis im Kommando); diese ADR führt keinen von beiden.

## Verdikt

**Konsistenz: NICHT bestätigt — die Annahme ist blockiert, aber nicht die Entscheidung.**

Die Prüfung trennt zwei Dinge, weil der Slice sie trennt:

1. **Die Entscheidung selbst trägt.** Zu den vier Prüfpunkten des Auftrags: Ein Widerspruch zu
   einer angenommenen ADR besteht **nicht** (Prüfpunkt 1 — `ADR-0015` und `ADR-0024` sind
   gegengelesen, beide Ableitungen laufen aneinander vorbei statt gegeneinander). Die Kette
   Kontext → Entscheidung → Konsequenzen ist geschlossen, alle vier Folgepflichten tragen Adressat
   und Fälligkeit (Prüfpunkt 2). Festlegung 3 ist **nicht zirkulär**: sie ruht auf drei
   gemessenen Eigenschaften und benennt die Bedingung, unter der ihre Begründung fällt
   (Prüfpunkt 3). Die zehn geprüften Zitate sind **wörtlich korrekt** (Prüfpunkt 4).
   Ein **inhaltlicher** Einwand gegen Festlegung 1 oder 3 liegt damit nicht vor; die
   Rückführungen aus Slice-Plan §4 (`in-progress → next` bei inhaltlichem Einwand,
   `in-progress → open` bei einem Rollen-Widerspruch, der eine Folge-ADR verlangt) sind **nicht**
   ausgelöst.

2. **Der Statuswechsel darf trotzdem noch nicht stattfinden.** `ADR-0016` Festlegung 3 (a) macht
   die Beleg-Form aus Festlegung 2 zur **Vorbedingung genau dieses Übergangs**, und ADR-0028
   erfüllt sie an keiner ihrer acht Belegstellen (HIGH-1). Das ist kein Formalismus mit
   Aufschub-Option: nach `**Status:** Accepted` sperrt `AGENTS.md` §3.4 die Ein-Zeilen-Korrektur,
   und `ADR-0016` beziffert den dann fälligen Preis selbst als Folge-ADR. Dasselbe Zeitfenster
   gilt für MEDIUM-1 (fünf Messwerte ohne Mess-Basis, drei davon heute falsch) und MEDIUM-2
   (Zuschreibung an `ADR-0015`, die deren Verengung ausschließt) — alle drei sind **jetzt**
   Textänderungen an einem `Proposed`-Artefakt und **nach** der Annahme eine neue ADR.

**Übergabe.** Der Weg, den der Plan dafür schon vorsieht, ist §6 Risiko 1, Ausgang *eingetreten*:
*„die ADR wird vor der Annahme korrigiert (sie ist noch `Proposed`, keine Folge-ADR nötig) — Beleg
in der Geschichte-Tabelle."* Adressat ist der **Architect** als Rolleninhaber von DoD (1); dieser
Report ist das Übergabe-Artefakt. Nach der Korrektur ist die Konsistenz-Prüfung für HIGH-1,
MEDIUM-1 und MEDIUM-2 nachzuziehen (neuer Report, eigene Datei — dieser wird nicht
überschrieben); LOW-1 und INFO-1 sind nice-to-fix und blockieren nicht.

**MEDIUM-3 adressiert nicht den Architect, sondern den Planner:** die Register-Zusage in DoD und
§8 ist gegen den heutigen Stand von `BEO-007` zu stellen, **bevor** die Closure sie einträgt. Sie
hängt nicht am ADR-Text und blockiert den Statuswechsel nicht.

**Dieser Report ersetzt keine Verifikation** — DoD-Abhakung und Gate-Lauf prüft der Verifier
separat (Modul 11, anderes Prüf-Artefakt, anderer Eingabe-Kontext).

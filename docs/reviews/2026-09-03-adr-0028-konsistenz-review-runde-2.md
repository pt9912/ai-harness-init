# Review — ADR-0028, zweite Konsistenzrunde (Nachprüfung der Korrektur `88fb255`)

| Feld | Wert |
|---|---|
| **Rolle** | Reviewer (Modul 8/10) — frischer Kontext, getrennt von Architektur, Planung und Implementation |
| **Review-Art** | **Plan-/Design-Review** gegen aktive ADRs, Hard Rules, den Adaptions-Speicher und die adoptierte Baseline. **Nicht** DoD-Abhakung (Verifier, Modul 11), **keine** inhaltliche Neubewertung der Entscheidung |
| **Gegenstand** | [`docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md`](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md), Status `Proposed` |
| **Diff dieser Runde** | `88fb255` *„Rolle Architect: ADR-0028 vor der Annahme korrigiert — Belege tragen den Tag, Zahlen ihre Mess-Basis"* (2026-09-02 20:11 +0200), zwei Dateien: die ADR und der ADR-Index (`git show 88fb255 --stat --format=`) |
| **Auftrag** | Baseline-Regelwerk `modul-08-agentenrollen.md` §Rollen-Regeln — *„ADR-Änderung: Architect schreibt; Reviewer prüft auf Konsistenz; Implementer liest als Constraint"*. Dieser Lauf ist die zweite ADR-Review-Runde; wer die Korrektur geschrieben hat, prüft sie nicht |
| **Plan** | [`docs/plan/planning/next/slice-145-adr-0028-acceptance-trigger-und-agents-zeiger.md`](../plan/planning/next/slice-145-adr-0028-acceptance-trigger-und-agents-zeiger.md), DoD (1) |
| **Bindende ADRs** | `ADR-0015`, `ADR-0016`, `ADR-0024` (alle Accepted) · zur Kohärenz mitgelesen, **nicht bindend**: `ADR-0025`, `ADR-0029` (beide `Proposed`) |
| **Anforderungen / Normen** | `AGENTS.md` §3.1, §3.4, §3.6, §3.7, §3.8 · `MR-000`, `MR-007`, `MR-018`, `MR-021`, `MR-025`, `MR-030`, `MR-033`, `MR-040`, `MR-045` · `LH-QA-01`, `LH-QA-02` |
| **Vorherige Findings am gleichen Modul** | [`docs/reviews/2026-09-02-adr-0028-konsistenz-review.md`](2026-09-02-adr-0028-konsistenz-review.md) — 1 HIGH, 3 MEDIUM, 1 LOW, 1 INFO; jeder dieser sechs Befunde ist unten einzeln nachgemessen. Davor [`docs/reviews/2026-08-31-slice-144-review.md`](2026-08-31-slice-144-review.md) HIGH-1, der Auslöser der ADR |
| **Skill-Version** | `.harness/skills/reviewer.md` 1.5.0 |
| **Modell** | Claude Opus 5 (1M context) |
| **Mess-Basis** | Arbeitsbaum-`HEAD` `340cf2c` (2026-09-03), Baum sauber. Adoptierte Baseline: **`v5.18.0`** (`ls .harness/baseline/` → ein Eintrag). Alle Zahlen unten in dieser Sitzung selbst gefahren; keine Zahl der Korrektur ist übernommen worden. Dieses Dokument ist ein **Zeitdokument** und wird nicht nachgezogen |
| **Kontext frisch** | ja — jedes der neun Verbatim-Zitate, jede der vier `git log`-Zahlen und der `BEO-007`-Stand sind gegen die Quelle gefahren, nicht gegen die zitierende Stelle |

**Was in diesem Lauf gefahren wurde.** Kein Gate-Lauf (der Gegenstand ist ein Dokument). Stattdessen:
die neun Proben aus §Verbatim-Proben **zweimal** — einmal mit dem abgedruckten Pfad, einmal mit dem
Pfad auf den adoptierten Stand gezogen; die vier `git log`-Kommandos gegen die in der ADR gepinnte
Mess-Basis `7485be3` **und** gegen `HEAD`; der `BEO-007`-Zählerstand gegen beide Refs; ein
Voll-Diff der vier berührten Regelwerks-Dateien zwischen dem eingefrorenen `v5.12.0` und `v5.18.0`;
die drei Cross-Check-Orte aus Festlegung 3; die Zitat-Treue der zwei `ADR-0015`-Stellen, der
`ADR-0024`-Stelle und der zwei `AGENTS.md`-Stellen; die `MR-018`/`MR-021`/`MR-030`-Kette; der
Bestand von `.claude/commands`, `.harness/skills` und `.claude/agents`. Der Arbeitsbaum wurde nicht
verändert; das einzige Schreibprodukt dieses Laufs ist diese Datei.

---

## Nachprüfung der sechs Befunde aus der ersten Runde

| Befund (2026-09-02) | Status | Beleg dieses Laufs |
|---|---|---|
| **HIGH-1** — acht Baseline-Belege ohne Tag; eine Verortung falsch | **behoben** | `grep -c 'v5\.12\.0' <ADR>` → **17** (vorher 1). Jeder Beleg trägt jetzt Tag, Dateiname, Abschnittsname, Zitat. Die falsche Verortung ist korrigiert: das Zitat *„Nur 1, 2 und 3b …"* steht in der ADR jetzt unter `modul-08-agentenrollen.md` §Rollen-Sequenz für eine Welle (Zeile 226–228), und dort steht es auch |
| **MEDIUM-1** — fünf Messwerte ohne Mess-Basis, drei falsch | **behoben** | Die vier Kommandos tragen `7485be3` und sind als *keine Erwartungswerte* markiert. Selbst nachgefahren an `7485be3`: **13 · 1 · 4 · 0** — genau die abgedruckten Werte. Dieselben vier an `HEAD` `340cf2c`: **13 · 1 · 4 · 0** (unverändert, seit `7485be3` hat kein Commit die zwei Verzeichnisse berührt). Der eine Rollen-präfigierte Treffer ist `20a3e33` und berührt `close-welle.md` **und** `reviewer.md` (`git show 20a3e33 --stat --format=`) — der Satz im Absatz gibt das jetzt so wieder |
| **MEDIUM-2** — Festlegung 2 wies den ausgenommenen Teil dem Architect zu | **behoben** | Festlegung 2 lautet jetzt *„Über diesen Teil sagt diese ADR nichts, und sie weist ihn auch keiner Rolle zu."* Beide `ADR-0015`-Zitate sind verbatim (`tr '\n' ' ' < docs/plan/adr/0015-*.md \| tr -s ' ' \| grep -cF '<zitat>'` → je **1**), das `ADR-0024`-Zitat ebenso (`grep -n 'Rolle für eine bindende Aussage ohne Original' docs/plan/adr/0024-*.md` → Zeile 162). §Was hier NICHT entschieden ist führt den Teil jetzt auf |
| **MEDIUM-3** — `BEO-007` steht nicht bei 1×, sondern bei 4× | **ADR-Hälfte behoben · Plan-Hälfte offen** | Register-Wert selbst gemessen, an **beiden** Refs identisch: `git show 7485be3:docs/plan/planning/observations.md \| awk -F'\|' '$2 ~ /BEO-007/{print $5, $6}'` → ` 4×   slice-137, slice-144, slice-147, slice-148`, dasselbe `awk` gegen die Arbeitskopie → identisch. Die ADR druckt genau diesen Wert. `slice-147` und `slice-148` sind belegt die Spec-Straten (`# Slice slice-147: spec/spezifikation.md trägt ihr SPEC-<NNN>-Pflichtfeld`, `# Slice slice-148: spec/architecture.md trägt ihr ARC-<NNN>-Pflichtfeld`) — die Trennung *beantwortete/offene Hälfte* trifft zu. **Der Plan trägt die Korrektur nicht:** MEDIUM-2 dieses Laufs |
| **LOW-1** — Verlagerung dem falschen `MR`-Eintrag zugeschrieben | **behoben** | `MR-021` sagt *„wird **vollständig** [aufgehoben]"* (`grep -n 'vollständig' harness/conventions/MR-021-*.md` → Zeile 26); `MR-018`s Kopf sagt *„den Rumpf trägt `git`"*; `MR-030` §Geltungsbereich nennt *„den Absatz über die kanonischen Agenten-Typ-Namen"* und verlagert nichts. Die ADR gibt alle drei jetzt korrekt wieder |
| **INFO-1** — Geltungsbereich enger als der Definitions-Satz | **behoben** | Festlegung 1 sagt jetzt *„Gebunden ist die Artefaktklasse, nicht die Datei-Form"*, und die Anwendungs-Tabelle führt `.harness/skills/reviewer.md` als vierte Zeile |

**Keiner der sechs Befunde ist oberflächlich abgehakt** — die Zahlen sind an ihrer eigenen
Mess-Basis nachgefahren, die Zitate gegen die Quelldateien gehalten. Was den Statuswechsel
weiterhin blockiert, ist **nicht** einer dieser sechs, sondern ein Ereignis, das zwischen die
Korrektur und diesen Lauf gefallen ist.

---

## Findings

### HIGH-1 — Die Belege sind gegen einen Baseline-Stand gemessen, der seit `db83415` nicht mehr der adoptierte ist; drei Präsens-Aussagen darüber sind am heutigen Baum falsch

- **kategorie:** HIGH
- **quelle:** [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) Setzung 1 · [`MR-033`](../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist) §Begründung · `ADR-0016` (Accepted) Festlegung 3 (a) · `AGENTS.md` §3.8 §Begründung
- **pfad:** `docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md:31`, `:351`, `:368-390`
- **befund:** Die vendored Baseline trägt **einen Tag zur Zeit**
  ([`MR-007`](../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)),
  und der Tausch auf `v5.18.0` liegt **zwischen** der Korrektur und diesem Lauf:
  `git log --format='%h %ad %s' --date=iso -1 88fb255` → `2026-09-02 20:11:18`,
  `… -1 db83415` → `2026-09-03 06:23:44 slice-156: Baum auf v5.18.0 tauschen, Pins und Symlinks ziehen`;
  `ls .harness/baseline/` nennt heute genau `v5.18.0`. Drei Aussagen der ADR sind damit am
  heutigen Baum unwahr:
  **(1)** Zeile 31 — *„Alle Baseline-Zitate sind gegen den adoptierten Stand **`v5.12.0`**
  gehalten"* — Präsens über einen Stand, der nicht adoptiert ist.
  **(2)** Zeile 370–373 — *„Jede der sieben Baseline-Aussagen … steht am adoptierten Stand
  `v5.12.0` genau einmal … Die Ausgabe jedes Kommandos ist **1**"*. Die neun Kommandos **wie
  abgedruckt** gefahren: jedes gibt **0** aus, jedes mit
  `.harness/baseline/v5.12.0/regelwerk/…: Datei oder Verzeichnis nicht gefunden`.
  **(3)** Zeile 351 — *„`v5.12.0` benennt keine [schreibende Rolle] über den Skill-Datei-Fall
  hinaus"*: das ist die **tragende Negativ-Prämisse** der ganzen Entscheidung, und sie ist gegen
  einen Stand gemessen, der nicht mehr bindet.
  **Was die Nachmessung ergibt, und sie ist zweigeteilt.** Dieselben neun Proben mit dem Pfad auf
  `v5.18.0` gezogen: **acht** geben **1**, eine gibt **0** — *„Nur 1, 2 und 3b tragen einen
  Rollenwechsel; 3a, 3c, 4 und 5 laufen im Planner-Kontext"*. `v5.18.0` schreibt dort
  *„3a, 3c, 4, 5 und 6"*, weil die Closure-Prozedur einen sechsten Schritt bekommen hat
  (`diff <(git show b902b60:.harness/baseline/v5.12.0/regelwerk/modul-08-agentenrollen.md) .harness/baseline/v5.18.0/regelwerk/modul-08-agentenrollen.md`
  → genau dieser eine inhaltliche Block plus die Quell-URL). **Ein mechanischer Tag-Tausch
  erzeugte hier also ein falsches Zitat** — dieselbe Klasse, die `ADR-0016` §Kontext an ihrer
  Zeile-129-Messung misst. **Failure-Szenario:** Mit `**Status:** Accepted` friert `AGENTS.md`
  §3.4 die drei Sätze ein. Der nächste Lauf, der Re-Evaluierungs-Trigger 1 prüft (*„wenn ein
  künftiger Baseline-Stand eine schreibende Rolle … benennt"*), liest eine ADR, die den
  Vergleichsstand `v5.12.0` nennt, findet auf Platte `v5.18.0`, fährt die neun Proben und bekommt
  neunmal null — er kann nicht entscheiden, ob die Prämisse je gegen den bindenden Stand gehalten
  wurde, und der Preis der Korrektur steigt nach `ADR-0016` von einer Zeile auf eine Folge-ADR.
  **Abgrenzung, damit der Befund nicht überzogen wird:** Die **Form** aus `ADR-0016` Festlegung 2
  (Tag · Dateiname und Abschnittsname · Zitat verbatim) ist erfüllt, und ein *eingefrorener*
  Beleg mit altem Tag ist nach deren Festlegung 1 ausdrücklich in Ordnung. Was fehlt, ist die
  **Aktualität an genau dem Übergang**, den Festlegung 3 (a) bindet: *„Bevor der Status eines ADR
  auf Accepted wechselt, werden seine Baseline-Belege in die Form aus Festlegung 2 gebracht"*,
  und *„Ein Proposed-Artefakt ist kein Bestand, sondern wird geschrieben."* **Und keine andere
  Regel fängt den Fall:**
  [`MR-040`](../../harness/conventions.md#mr-040--drei-ausgänge-für-eine-präsens-aussage-über-den-vendored-baum)
  §Geltungsbereich nimmt `docs/plan/adr/` ausdrücklich aus, und
  [`slice-165`](../plan/planning/done/slice-165-praesens-aussagen-gegen-v5180.md) §1 schließt das
  Verzeichnis per Pathspec aus mit der Begründung *„die **eingefrorenen** ADRs bleiben
  unangetastet"* — ADR-0028 ist nicht eingefroren. Der Fall fällt damit genau in die Lücke, die
  Träger (a) schließen soll.
- **verifizierbar:** ja, aber **nicht durch ein Gate** — die drei Sätze stehen in keinem
  Markdown-Link, also sieht sie kein Modul aus `grep -m1 '^modules:' .d-check.yml`
  → `modules: [links, anchors, ids, matrix, codepaths, spans]`; genau diese Blindheit beziffert
  [`MR-040`](../../harness/conventions.md#mr-040--drei-ausgänge-für-eine-präsens-aussage-über-den-vendored-baum)
  §Begründung. Bestätigt wird der Befund durch die neun Proben in beiden Pfad-Fassungen und den
  `diff` der zwei Modul-Fassungen.
- **klasse:** „Baseline-Beleg gegen einen Stand gemessen, den der Re-Baseline vor dem Einfrieren
  überholt hat"

### MEDIUM-1 — Die ADR verlinkt zwei Review-Reports als Beleg, und die heute adoptierte Baseline archiviert Review-Reports ohne Stub

- **kategorie:** MEDIUM
- **quelle:** adoptierte Baseline `v5.18.0`, `modul-10-review-harness.md` §Ziel-Form: Review-Report (*„Ein Rang-Dokument, das einen einzelnen Report als Beleg verlinkt, hat damit ein Problem, das älter ist als das Archiv — es macht ein Zeitdokument zur Quelle. Die Aussage gehört an den zitierenden Ort, die Report-Kennung bleibt im Text."*) und `modul-06-roadmap.md` §Wellen-Closure-Prozedur Schritt 4 (*„die Review-Reports dieser Slices wandern in ein unveränderliches Archiv `done/<welle-id>/archiv.zip` … Review-Reports bekommen keinen Stub"*) · `AGENTS.md` §3.4
- **pfad:** `docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md:402`, `:403`
- **befund:** Die Geschichte-Tabelle führt zwei Markdown-Links in `docs/reviews/`
  (`grep -no '](\.\./\.\./reviews/[^)]*)' <ADR>` → Zeile 402 `2026-08-31-slice-144-review.md`,
  Zeile 403 `2026-09-02-adr-0028-konsistenz-review.md`). Der Absatz, der diese Konstruktion
  benennt, ist **im Re-Baseline von heute neu dazugekommen**
  (`diff <(git show b902b60:.harness/baseline/v5.12.0/regelwerk/modul-10-review-harness.md) .harness/baseline/v5.18.0/regelwerk/modul-10-review-harness.md`
  → ein einziger Einschub, Zeilen 109–116). Beide zitierten Reports gehören zu wellenlosen Slices
  (`grep -m1 '^\*\*Welle:\*\*' docs/plan/planning/done/slice-144-*.md` → *„ohne Welle"*, dasselbe
  für `slice-145`), und Schritt 4 sammelt ausdrücklich *„die wellenlosen, die seit der letzten
  Closure geschlossen wurden"* mit ein. **Failure-Szenario:** `slice-158` bringt den
  Archivierungs-Schritt (liegt in `open/`, Welle `welle-14`); schließt danach die erste Welle,
  wandern beide Reports ohne Stub in `done/<welle-id>/archiv.zip`, und die zwei Links in einer
  nach §3.4 unantastbaren ADR zeigen ins Leere — `links` färbt `make docs-check` rot, und die
  Reparatur ist entweder eine Gate-Ausnahme (nach `AGENTS.md` §3.5 eine eigene ADR, so wie
  `ADR-0017` sie für **einen** solchen Link schon einmal gekostet hat) oder eine Folge-ADR.
  **Abgrenzung:** Der Bestand trägt die Konstruktion bereits — acht **Accepted**-ADRs führen
  zusammen 16 solcher Links
  (`git grep -c '](\.\./\.\./reviews/' -- 'docs/plan/adr/*.md'`, Status je Datei
  `grep -m1 '^\*\*Status:\*\*'`); für die gilt der Cutoff, sie sind **kein** Arbeitsauftrag.
  Gebunden ist die ADR, die **jetzt** geschrieben wird, und ADR-0028 ist die einzige `Proposed`
  in der Liste.
- **verifizierbar:** ja — `make docs-check` nach dem ersten Archivierungslauf; heute lösen beide
  Links noch auf, der Befund ist der Zustand nach dem Archivieren, nicht davor.
- **klasse:** „Rang-Dokument verlinkt ein Zeitdokument als Beleg und wird eingefroren"

### MEDIUM-2 — Der Slice, der die Annahme trägt, rechnet unverändert mit `BEO-007` bei 1×

- **kategorie:** MEDIUM
- **quelle:** Slice-Plan §2 DoD und §8 *Vorgelagert — offene Beobachtungen sichten*, gegen
  [`docs/plan/planning/observations.md`](../plan/planning/observations.md); Baseline `v5.18.0`,
  `modul-06-roadmap.md` §Das Beobachtungs-Register
- **pfad:** `docs/plan/planning/next/slice-145-adr-0028-acceptance-trigger-und-agents-zeiger.md:110`, `:230`
- **befund:** Das ist MEDIUM-3 der ersten Runde, unverändert. Die Korrektur hat den Plan nicht
  berührt — `git show 88fb255 --stat --format=` nennt zwei Dateien, die ADR und
  `docs/plan/adr/README.md`. Der §8-Sichtungsblock sagt weiter *„`BEO-007` steht im Register
  (Sub-Area `*`, 1×, …)"*, während die Registerzeile bei **4×** steht (Kommando oben in der
  Nachprüfungs-Tabelle, an beiden Refs identisch) und ihr Stand-Feld den Ausgang bereits
  **dreigeteilt** führt: Command-Artefakte → `ADR-0028`, `.claude/agents/*.md` → `ADR-0029`,
  Spec-Straten → `slice-151`. **Failure-Szenario:** Die Closure trägt den Ausgang wie im Plan
  zugesagt ein und setzt eine Zeile auf *verkörpert*, deren zwei jüngste Belege von keiner
  angenommenen Quelle berührt sind — der Zähler verliert genau die Beobachtung, für die er zählt.
  **Adressat ist der Planner, nicht der Architect**; der Statuswechsel der ADR hängt nicht daran.
- **verifizierbar:** ja — die zwei zitierten Plan-Zeilen gegen das `awk`-Kommando auf das
  Register. Kein Gate: die maschinelle Hälfte der Register-Paarung prüft Deckung, nicht ob ein
  eingetragener Ausgang trägt.
- **klasse:** „Plan-Zusage über den Stand eines lebenden Registers, gemessen zum Schnitt- statt
  zum Ausführungs-Zeitpunkt" (zweites Auftreten)

### LOW-1 — §Verbatim-Proben zählt sieben Aussagen, druckt neun Kommandos, und die Geschichte-Tabelle nennt neun Wortlaute

- **kategorie:** LOW
- **quelle:** Maintainability; interne Widerspruchsfreiheit
- **pfad:** `docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md:370` gegen `:381-389` und `:403`
- **befund:** Der Kopf sagt *„Jede der **sieben** Baseline-Aussagen"*, der Block darunter enthält
  **neun** Kommandos
  (`awk '/^## Verbatim-Proben/,/^## Geschichte/' <ADR> | grep -c '^tr '` → **9**), und die
  Geschichte-Zeile vom 2026-09-02 sagt *„macht die **neun** Wortlaute nachfahrbar"*. Auch als
  Zählung *distinkter* Aussagen trägt „sieben" nicht: acht Stellen der ADR stützen sich auf je
  eine eigene Baseline-Aussage, zwei davon teilen sich eine (der Konflikt-Pfad, über zwei
  Fragmente belegt). **Failure-Szenario:** Wer die Vollständigkeit der Belege gegen die genannte
  Zahl prüft, hält den Block für vollständig abgezählt und übersieht, dass zwei Proben ohne
  Zuordnung dastehen.
- **verifizierbar:** ja — das `awk | grep -c` oben gegen die zwei Zahlwörter im Text.
- **klasse:** „Zwei Zählungen desselben Blocks in einem Dokument, die nicht übereinstimmen"

### LOW-2 — Die Anwendungs-Tabelle belegt ihr Kriterium mit der „ersten Zeile", und dort steht die Aussage nicht

- **kategorie:** LOW
- **quelle:** Maintainability; `AGENTS.md` §3.6 (eine Zusage sagt, was der Bestand hält)
- **pfad:** `docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md:218-220`, `:223`
- **befund:** Die Spalte *woran ablesbar* führt für alle drei Commands *„erste Zeile: …"*, und der
  Absatz darunter sagt, das mache die Anwendung *„trivial"*. Gemessen steht der zitierte Satz in
  allen drei Dateien in **Zeile 5**
  (`grep -n 'Dieser Command führt die' .claude/commands/*.md` → je `:5`); Zeile 1 ist die
  H1-Überschrift (`sed -n '1p' .claude/commands/implement-slice.md` →
  `# Slice implementieren (Harness)`), Zeile 3 die `Argument:`-Zeile. Die Zitate selbst sind
  verbatim korrekt (je 1 Treffer, whitespace-normalisiert). **Failure-Szenario:** Die ADR nennt
  die Ablesbarkeit ausdrücklich als das, was die Regel heute trivial anwendbar macht; wer daraus
  eine Prüfung baut, die Zeile 1 liest, findet in keiner der drei Dateien eine Rolle und hält das
  Kriterium für unerfüllt.
- **verifizierbar:** ja — das `grep -n` oben. Kein Gate.
- **klasse:** „Fundort-Angabe präziser formuliert, als der Bestand sie hält"

### INFO-1 — `ADR-0029` steht mit derselben Tag-Lage da, und `slice-152` soll sie annehmen

- **kategorie:** INFO
- **quelle:** Maintainability; `ADR-0016` Festlegung 3 (a)
- **pfad:** `docs/plan/adr/0029-agenten-typkarten-derivativ-gemischte-originale.md`
- **befund:** Kein Vorwurf an ADR-0028 — eine Beobachtung für die Runden danach. Die zweite
  `Proposed`-ADR derselben Familie trägt **einen** Tag im ganzen Dokument
  (`for f in 0015 0016 0024 0025 0028 0029; do grep -c 'v[0-9]\+\.[0-9]\+\.[0-9]\+' docs/plan/adr/$f-*.md; done`
  → **20 · 25 · 7 · 9 · 17 · 1**; keine Erwartungswerte, sie wandern mit dem Text). Sie stützt
  sich in Festlegung 1 auf ADR-0028 und wird von
  [`slice-152`](../plan/planning/open/slice-152-adr-0029-acceptance-trigger.md) zur Annahme
  geführt — derselbe Übergang, dieselbe Vorbedingung aus `ADR-0016` Festlegung 3 (a), und
  inzwischen derselbe Stand-Wechsel auf `v5.18.0`.
- **verifizierbar:** ja — das `for`-Kommando oben.
- **klasse:** „Baseline-Beleg ohne Tag in einem Artefakt, das eingefroren wird" (Wiederholung in
  einem Geschwister-Artefakt)

## Negativbefunde

- **Prüfpunkt 1a — Widerspruch zu `ADR-0015` (Accepted):** geprüft, **kein Befund**. Der Befund der
  ersten Runde ist weg: Festlegung 2 weist den ausgenommenen Teil keiner Rolle mehr zu, beide
  `ADR-0015`-Zitate sind verbatim, und §Was hier NICHT entschieden ist führt den Teil jetzt selbst.
  ADR-0028 besetzt ausschließlich Artefakte, für die `ADR-0015` die Frage offen gelassen hat; ihr
  Cutoff und ihre Folgepflicht 2 (kein Adaptions-Eintrag,
  [`MR-000`](../../harness/conventions.md#mr-000--baseline-aussage)) sind die von `ADR-0015`. Kein
  `Supersedes` nötig, keiner behauptet.
- **Prüfpunkt 1b — Widerspruch zu `ADR-0024` (Accepted):** geprüft, kein Befund. Verschiedene
  Gegenstände (derivatives **Register** ↔ **Anweisungssatz**), verschiedene Vorfragen (*wessen
  Original projiziert die Aussage?* ↔ *wer führt den Ablauf aus?*). Das übernommene
  `ADR-0024`-Zitat steht dort wörtlich (Zeile 162). Die Artefaktklassen-Tabelle aus Modul 8 wird
  in §Kontext ausdrücklich **nicht** als Eigentums-Aussage gelesen.
- **Prüfpunkt 1c — Verhältnis zu `ADR-0025` und `ADR-0029` (beide `Proposed`, nicht bindend):**
  geprüft, kein Befund über INFO-1 hinaus. Festlegung 3 nimmt `.claude/agents/*.md` aus und lässt
  die Frage offen; `ADR-0029` füllt sie mit einer anderen Ableitung. Eine Annahme von ADR-0028
  nimmt ihr nichts vorweg.
- **Prüfpunkt 2 — innere Kette Kontext → Entscheidung → Konsequenzen:** geprüft, kein Befund über
  LOW-1 hinaus. Jede der drei Festlegungen hat ihren tragenden Absatz in §Kontext; die sechs
  Optionen tragen je ein Contra mit Zitat oder Messung; Option C trägt ihren Preis auch in
  §Konsequenzen; alle vier Folgepflichten nennen Adressat **und** Fälligkeitsmoment, Folgepflicht 1
  wartet ausdrücklich auf die Annahme.
- **Prüfpunkt 2b — Prämisse von Folgepflicht 1:** geprüft, kein Befund. `grep -c 'ADR-0024' AGENTS.md`
  → **1**, `grep -c 'ADR-0028' AGENTS.md` → **0**; §3.8 zeigt weiterhin nur auf `ADR-0024`. Die
  Zusage *„Dieser Lauf schreibt `AGENTS.md` nicht"* ist am Korrektur-Commit eingehalten
  (`git show 88fb255 --stat --format=` nennt `AGENTS.md` nicht).
- **Prüfpunkt 3 — Festlegung 3 nicht zirkulär, Cross-Check-Orte real:** geprüft, kein Befund.
  `.claude/agents/` führt **6** Dateien (`git ls-tree -r --name-only HEAD -- .claude/agents | wc -l`);
  der Gründungs-Commit sagt *„DIE DATEIEN SIND ABSICHTLICH DUENN"* und *„Ihre Typ-Dateien ZEIGEN
  darauf und wiederholen nichts"* (`git log -1 --format=%B e30e0fd`, verbatim geprüft); der
  Cross-Role-Commit ist real und exakt so, wie die ADR ihn abdruckt (`git show b39d4ff --stat --format=`
  → `.claude/agents/reviewer.md | 8 ++++++++`, `.claude/agents/verifier.md | 8 +++++++-`); die sechs
  kanonischen Namen stehen in `spec/spezifikation.md` §5
  (`grep -c 'kanonischen Namen der Agenten-Typen' spec/spezifikation.md` → **1**) und
  `roleFromAgentType` existiert (`grep -rn 'roleFromAgentType' --include=*.go .` →
  `internal/span/emit.go:102` und `:166`).
- **Prüfpunkt 3b — die `MR`-Kette aus LOW-1 der ersten Runde:** geprüft, kein Befund. Alle fünf von
  der ADR adressierten Anker lösen in
  [`harness/conventions.md`](../../harness/conventions.md) auf, auch nach dem Umzug in die
  Verzeichnis-Form ([`MR-045`](../../harness/conventions.md#mr-045--der-adaptions-block-läuft-in-der-verzeichnis-form)):
  `MR-018` trägt in der Index-Zeile beide `id`-Anker und zeigt auf
  `conventions/done/MR-018-…md`.
- **Prüfpunkt 4 — Bestands-Messungen der Festlegung 1:** geprüft, kein Befund.
  `git ls-tree -r --name-only 7485be3 -- .claude/commands .harness/skills` → genau die **vier**
  Dateien der Anwendungs-Tabelle; dasselbe an `HEAD` → identisch. Alle fünf Repo-Zitate
  (drei Command-Eröffnungssätze, zwei Typkarten-Sätze) sind whitespace-normalisiert je **1**
  Treffer.
- **Prüfpunkt 5 — Substanz der tragenden Baseline-Prämisse gegen den heute bindenden Stand:**
  geprüft, **die Entscheidung trägt weiter**. `v5.18.0` benennt für Command- oder Skill-Artefakte
  **keine** schreibende Rolle über den Skill-Datei-Fall hinaus: die Artefaktklassen-Tabelle in
  `modul-08-agentenrollen.md` §Welche Rolle braucht welche Artefaktklasse ist gegenüber `v5.12.0`
  unverändert, *„R aktualisiert Skill-Datei"* steht unverändert in der Verdikt-Tabelle des
  Konflikt-Pfads (Zeile 212), und die einzige Nennung von `.claude/commands/*.md` im ganzen Baum
  (`grep -rn 'claude/commands' .harness/baseline/v5.18.0/` → **eine** Fundstelle,
  `grundlagen-durchsetzungsschicht.md:96`) führt sie als Glied des Artefakt-Sets ohne Rollen-Aussage
  und stand dort schon bei `v5.12.0`
  (`git show b902b60:.harness/baseline/v5.12.0/regelwerk/grundlagen-durchsetzungsschicht.md | grep -n 'claude/commands'`
  → Zeile 96). **Re-Evaluierungs-Trigger 1 hat also nicht gefeuert** — der Befund HIGH-1 betrifft
  die Mess-Basis der Aussage, nicht ihr Ergebnis.
- **Prüfpunkt 5b — die übrigen acht Zitate am neuen Stand:** geprüft, kein Befund.
  *„bei isolierten LOW/INFO-Findings ist die Sequenz Overkill"* · *„Sie greift ab HIGH mit
  Rollen-Widerspruch …"* · *„**Briefing** (`AGENTS.md` + 8-Schritt-Workflow)"* · *„R aktualisiert
  Skill-Datei"* · *„Die Eröffnung ist Planner-Arbeit"* · *„**Bei 3×** wandert der Eintrag …"* ·
  *„ADR-Review-Runde abgeschlossen → bindend"* · *„Eine ADR mit Status `Accepted` wird nicht
  inhaltlich überschrieben"* geben am `v5.18.0`-Baum je **1**. Die inhaltliche Zuordnung der
  Wellen-Closure zum Planner, die Festlegung 1 aus dem neunten Zitat zieht, gilt bei `v5.18.0`
  unverändert — nur mit sechs statt fünf Schritten.
- **`LH-QA-01` (keine halluzinierten Gates):** geprüft, kein Befund. §Fitness Function behauptet
  ausdrücklich **kein** Gate; die aufgezählten Module sind deckungsgleich mit
  `grep -m1 '^modules:' .d-check.yml` → `modules: [links, anchors, ids, matrix, codepaths, spans]`,
  und die zwei genannten `mutate`-Fehlschlag-Formen stehen so im Werkzeug
  (`grep -n -- '--- FAIL:' harness/tools/mutate.sh` → Zeile 425).
- **`AGENTS.md` §3.7 (Kommentar/Zustandsfeld trägt keine Chronik):** geprüft, kein Befund **in der
  ADR**. Die Geschichte-Tabelle ist der von der Vorlage vorgesehene Provenienz-Ort; §Kontext
  erzählt den Anlass, was die Aufgabe des Abschnitts ist.
- **Ziel-Form der ADR-Vorlage:** geprüft, kein Befund. Kopf (`Status`, `Datum`, `Autor`, `Bezug`,
  `Schärft`) und alle Pflicht-Abschnitte stehen in der Vorlagen-Reihenfolge; der
  Immutabilitäts-Schlusssatz steht. Der ADR-Index führt die Zeile mit Status `Proposed`
  (`grep -n '0028' docs/plan/adr/README.md`).
- **Beschreibung von `AGENTS.md` §3.8 als „Adaptions-Block in `harness/conventions.md`":** geprüft,
  **trägt weiter**. Seit [`MR-045`](../../harness/conventions.md#mr-045--der-adaptions-block-läuft-in-der-verzeichnis-form)
  (Datum 2026-09-03, also nach der Korrektur) nennt §3.8 die Index-Datei **und** das
  Eintrags-Verzeichnis daneben. Die Aussage der ADR — *„zwei benannte Artefakte"* — bleibt richtig,
  weil der Adaptions-Block ein Artefakt bleibt; nur seine Ablage hat zwei Pfade. Kein Finding, weil
  kein Versagen daraus folgt: `conventions.md` ist der Index und führt zu den Einträgen.
- **Nicht geprüft (bewusst außerhalb dieses Laufs):** der **Inhalt** der drei Commands, der
  Skill-Datei und der sechs Typkarten; die DoD-Abhakung und der Gate-Lauf von `slice-145`
  (Verifier, Modul 11); die innere Konsistenz von `ADR-0029` (eigener Gegenstand, eigener Lauf);
  der `v5.12.0`-Restbestand in den lebenden Artefakten außerhalb dieser ADR (Gegenstand von
  `slice-165`); die Form der `Stand`-Zelle von `BEO-007` (Planner-Artefakt, hier nur auf ihren
  **Wert** gelesen).

## Kategorie-Summary

- HIGH: 1
- MEDIUM: 2
- LOW: 2
- INFO: 1

**Finding-Klassen dieses Laufs (für die Slice-Closure §7 und den Zähler):**
„Baseline-Beleg gegen einen Stand gemessen, den der Re-Baseline vor dem Einfrieren überholt hat" ·
„Rang-Dokument verlinkt ein Zeitdokument als Beleg und wird eingefroren" ·
„Plan-Zusage über den Stand eines lebenden Registers, gemessen zum Schnitt- statt zum
Ausführungs-Zeitpunkt" (zweites Auftreten) ·
„Zwei Zählungen desselben Blocks in einem Dokument, die nicht übereinstimmen" ·
„Fundort-Angabe präziser formuliert, als der Bestand sie hält".

**HIGH-1 und der HIGH der ersten Runde teilen einen Mechanismus und sind zusammen zu lesen.** Beide
Male bricht dieselbe Klammer an derselben Stelle: Eine Aussage über die Baseline wird in dem Moment
eingefroren, in dem niemand sie mehr korrigieren darf — beim ersten Mal, weil der Tag fehlte, beim
zweiten Mal, weil der Tag inzwischen ein anderer ist. Der Unterschied zwischen den beiden Läufen
ist **zehn Stunden**: `88fb255` um 20:11, `db83415` um 06:23 des Folgetags. Das ist kein Versäumnis
der Korrektur, sondern die Eigenschaft eines `Proposed`-Artefakts, das über eine Re-Baseline hinweg
offen liegt — und genau der Grund, warum `ADR-0016` den Träger auf den **Übergang** legt und nicht
auf den Schreib-Zeitpunkt.

## Verdikt

**Inhaltlicher Einwand: nein. Konsistenz: NICHT bestätigt — der Statuswechsel bleibt blockiert.
ADR-0028 bleibt `Proposed`.**

Die Prüfung trennt dieselben zwei Dinge wie die erste Runde:

1. **Die Entscheidung trägt, und sie trägt jetzt auch gegen den neuen Stand.** Alle sechs Befunde
   der ersten Runde sind an der ADR behoben, einzeln nachgemessen statt abgehakt (Tabelle oben).
   Ein Widerspruch zu einer angenommenen ADR besteht nicht (`ADR-0015`, `ADR-0016`, `ADR-0024`
   gegengelesen). Die innere Kette ist geschlossen, Festlegung 3 ist nicht zirkulär, und die
   tragende Negativ-Prämisse habe ich gegen `v5.18.0` selbst nachgemessen: sie hält
   (Prüfpunkt 5). Re-Evaluierungs-Trigger 1 hat **nicht** gefeuert. Die Rückführungen aus
   Slice-Plan §4 sind damit **nicht** ausgelöst.

2. **Der Statuswechsel darf trotzdem noch nicht stattfinden.** Zwischen die Korrektur und diesen
   Lauf ist der Baseline-Tausch auf `v5.18.0` gefallen. Drei Präsens-Aussagen der ADR über den
   vendored Baum sind dadurch am heutigen Baum falsch, die neun abgedruckten Proben geben neunmal
   null, und eine von ihnen hält am neuen Stand auch inhaltlich nicht mehr (HIGH-1) — was einen
   mechanischen Tag-Tausch ausschließt. `ADR-0016` Festlegung 3 (a) bindet genau diesen Übergang;
   nach `**Status:** Accepted` sperrt `AGENTS.md` §3.4 die Ein-Zeilen-Korrektur, und der Preis
   steigt auf eine Folge-ADR. MEDIUM-1 liegt in demselben Zeitfenster: die zwei Report-Links sind
   **jetzt** eine Textänderung an einem `Proposed`-Artefakt und **nach** der Annahme eine
   Gate-Ausnahme oder eine neue ADR.

**Übergabe.** Der Weg steht im Plan: §6 Risiko 1, Ausgang *eingetreten* — *„die ADR wird vor der
Annahme korrigiert (sie ist noch `Proposed`, keine Folge-ADR nötig) — Beleg in der
Geschichte-Tabelle."* Adressat ist der **Architect** als Rolleninhaber von DoD (1); dieser Report
ist das Übergabe-Artefakt. Zu klären sind HIGH-1 und MEDIUM-1; LOW-1, LOW-2 und INFO-1 blockieren
nicht. Nach der Korrektur ist eine dritte Runde fällig (neue Datei, dieser Report wird nicht
überschrieben).

**MEDIUM-2 adressiert den Planner, nicht den Architect** — die Register-Zusage in `slice-145` §2
und §8 ist gegen den heutigen Stand von `BEO-007` zu stellen, **bevor** die Closure sie einträgt.
Sie hängt nicht am ADR-Text und blockiert den Statuswechsel nicht.

**Kein Rollen-Konflikt.** Kein Finding dieses Laufs widerspricht einer Position, die der
Architect-Lauf vertreten hätte; der Konflikt-Pfad aus Modul 8 §Konflikt-Pfad als Rollen-Sequenz ist
nicht auszulösen.

**Dieser Report ersetzt keine Verifikation** — DoD-Abhakung und Gate-Lauf prüft der Verifier
separat (Modul 11, anderes Prüf-Artefakt, anderer Eingabe-Kontext).

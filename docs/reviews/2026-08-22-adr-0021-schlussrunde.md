# ADR-0021 (Proposed) — Schlussrunde

**Rolle:** Reviewer (Modul 10). **Datum:** 2026-08-22. **Lauf:** frischer Kontext, Subagent
`reviewer`, **vierte** und letzte Runde zu dieser ADR.

**Review-Art:** Design-Review — die überarbeitete ADR gegen die ADR-Lage, gegen das Regelwerk und
gegen das eine offene Finding der Verdikt-Runde, vor dem Statuswechsel, den
[`AGENTS.md`](../../AGENTS.md) §3.4 unumkehrbar macht.

**Gegenstand:** `5e938bf` — ein Commit, zwei Dateien:
`docs/plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md` (+99/−29, jetzt 795 Zeilen) und die
Index-Zeile `docs/plan/adr/README.md:29`. Gegenlage: `ebb1632` (Verdikt-Runden-Report).
HEAD `5e938bf`, Arbeitsbaum vor und nach dem Lauf sauber.

**Skill:** `.harness/skills/reviewer.md` @ 1.4.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5[1m] · **Datum:** 2026-08-22

**Eingangs-Kontext (die fünf Pflicht-Punkte plus Plan-Bezug):**

- **Diff/Range:** `ebb1632..5e938bf`, beschränkt auf die zwei genannten Dateien (am `--name-only`
  geprüft).
- **Betroffene `LH-*`:** `LH-QA-01`, `LH-QA-02`, `LH-QA-03`.
- **Referenzierte aktive ADRs (Status je selbst geprüft):** `ADR-0011`, `ADR-0012`, `ADR-0016`,
  `ADR-0017`, `ADR-0019`, `ADR-0020` (alle **Accepted**); dazu `CO-002`, `CO-001`,
  `docs/plan/carveouts/README.md`, `spec/spezifikation.md` §5, `welle-09` §3, `.d-check.yml`,
  `harness/conventions.md` §MR-000/§MR-021/§MR-025,
  `.harness/baseline/v3.5.2/regelwerk/modul-07-carveouts.md`.
- **Hard Rules:** [`AGENTS.md`](../../AGENTS.md) §3.1–§3.8, besonders §3.4, §3.6 und §3.8.
- **Vorherige Findings am gleichen Modul:** die drei Vorrunden —
  [`…-bestaetigungsrunde.md`](2026-08-22-adr-0021-bestaetigungsrunde.md) (3 HIGH/3 MEDIUM/2 LOW/2 INFO),
  [`…-runde-2.md`](2026-08-22-adr-0021-bestaetigungsrunde-runde-2.md) (4 MEDIUM/1 LOW),
  [`…-verdikt-runde.md`](2026-08-22-adr-0021-verdikt-runde.md) (1 MEDIUM/2 LOW).
- **Plan-Bezug:** `docs/plan/planning/open/slice-089-carveout-co-002-ueberfuehren.md`.

**Nicht meine Rolle:** DoD-Abhakung, Gate-Lauf als Erfolgsmeldung, Lösungsvorschläge, Änderungen an
der ADR. **Nichts committet, außer diesem Report nichts geschrieben.** Sonden liefen in
Wegwerf-Kopien außerhalb des Repos und sind entfernt. Der Span-Bestand wurde nicht geöffnet.

**Selbst gefahren — Kommando und Ergebnis:**

| Kommando | Ergebnis |
|---|---|
| `make docs-check` (Ist-Stand `5e938bf`) | `340 Datei(en) geprüft, 0 Befund(e)`, Exit 0 |
| **Abzählung der §Ziel-Form-Bullets** — `awk '/^### Ziel-Form: Carveout/,/^<a id="werkzeug-wahl"/' <modul> \| grep -c '^- \*\*'` | **4** — die Behauptung *„§Ziel-Form führt genau vier Bullets"* trägt |
| dieselbe Extraktion, je Bullet nummeriert, gefiltert auf `carveouts/` bzw. `done/` | Treffer **nur** in Bullet **1** (*„gehört er nicht in `carveouts/`"*) und Bullet **4** (*„`git mv` nach `done/`"*); Bullet 2 (Form des Auflösungs-Triggers) und 3 (`# CO-<NNN>`-Kommentar) nennen **keinen** Ablageort — die Zuordnung der ADR ist exakt |
| **(a)** `sed -n '/^\*\*Folge-Slice:\*\*/,/^---/p' <CO-002>` | Feld **gefüllt**: der Folge-Slice ist benannt, mit beiden Ausgängen. Zusatzmessung am Anlage-Commit `f68cebd`: dort stand *„noch nicht geschnitten — fällig als Folgepflicht 3 von ADR-0019"*; das Feld wurde noch am selben Tag gefüllt (Geschichte-Zeile) und ist es seither |
| **(c)** `grep -n 'carveouts/done' <modul>` | **leer, Exit 1** — das Modul schreibt an allen **fünf** Fundstellen bares `` `done/` `` (`grep -n 'done/'`), und zwar durchgängig **artefakt-relativ** (auch `done/welle-NN-results.md` für die Wellen-Ergebnisse). Aus der Dateikonvention `docs/plan/carveouts/CO-<NNN>-<kurztitel>.md` derselben Sektion folgt `docs/plan/carveouts/done/`; `docs/plan/carveouts/README.md:6` und die Checkliste in `CO-002:142` lesen es genauso. **Die Prämisse von Grund (c) trägt** |
| **Zitat-Treue, drei neue Belege** — `grep -n` auf den Wortlaut | `MR-021` §Begründung *„Der Adaptions-Block registriert Abweichungen von der adoptierten Baseline."* ✓ · `AGENTS.md` §3.8 *„Die Regel füllt damit eine Lücke, statt von der Baseline abzuweichen — deshalb steht zu ihr kein Eintrag im Adaptions-Block"* ✓ · der erste §Ziel-Form-Bullet vollständig ✓ (Whitespace/Auszeichnung normalisiert, wie `ADR-0016` Festlegung 2 „verbatim" definiert) |
| **Präzedenz** — umbruch-tolerante Suche in `ADR-0012` | Der Satz steht dort verbatim zitiert, und die Disposition lautet Wort für Wort *„Der Satz greift hier nach seiner Logik, nicht nach seinem Buchstaben, und das gehört gesagt"* — **dieselbe Wendung**, **derselbe Satz** |
| **V-2 Gegenprobe, beide Richtungen** — Wegwerf-Kopie | Heute: `awk '/^## Verifikation/,/^## Geschichte/' <CO-002> \| grep -c '^- \[ \]'` → **5**. Nur die `git mv`-Zeile gelöscht: `carveouts/done` → **0**, `d-check:ignore` → **0**, `^## Verifikation` → **1**, verbleibende Haken → **4**. Abschnitt als Ganzes gelöscht: `^## Verifikation` → **0**. **Jede der sechs Zahlen der ADR exakt** |
| **V-3 Grund** — Zitat-Suche | `ADR-0021` zitiert `CO-002` §Auflösungs-Trigger **zweimal verbatim** (beide gegen die Quelle geprüft), und `ADR-0019:247` führt seine zwei Ausgänge — eine Löschung machte Zitate zweier ab dann immutabler ADRs quellenlos. Der Grund ist belegt |
| `grep -n 'nicht erfüllbar'` / `'Bedingung, unter der'` über ADR **und** Index | **beide leer, Exit 1** — die Rücknahme aus Runde 3 hält |
| `grep -nE '79\|81\|82\|84 Befund'` über ADR und Index | **leer, Exit 1** — keine wandernde Summe |
| `grep -c 'slice-[0-9]'` über die ADR | **0** |
| `grep -niE 'carveout' harness/conventions.md` | **kein** `MR-*`-Eintrag regelt die Carveout-Ablage — das Register ist an dieser Stelle leer |
| `git show --pretty=format: --name-only 5e938bf` | genau zwei Architect-Artefakte; Message beginnt mit *„Rolle Architect:"* (§3.8) |
| `grep -c '^## '` über die ADR | **7** — alle Pflicht-Abschnitte des vendored Templates |

**Nicht wiederholt, weil unverändert und je zweimal belegt:** die Move-Sonde (18/13/5), die drei
`resolve-from`/`ignore-refs`-Sonden, `--print-config`, der vollständige Vollzug (`0 Befund(e)`) und
die Mutations-Sonde zu Festlegung 2. Der Diff dieser Runde berührt keine dieser Stellen.

---

## Status der Findings aus der Verdikt-Runde

| Verdikt-Runde | Status | Beleg |
|---|---|---|
| **V-1** — das Ort-Inventar erklärte sich für vollständig und ließ den ersten §Ziel-Form-Bullet aus | **behoben, und zwar an der Wurzel** | Der Satz ist jetzt **verbatim zitiert und disponiert** statt übergangen, unter genau der Überschrift, die die Verdikt-Runde als Präzedenz benannt hatte. **Alle drei Gründe an der Quelle geprüft:** **(a)** trägt — `CO-002` führt das Pflichtfeld *Folge-Slice* gefüllt, mit benanntem Slice und beiden Ausgängen; die Permanenz folgt aus Messung und Trichter-Frage 2, nicht aus einem Form-Mangel des Kopfes. **(b)** trägt — der Nachsatz *„über den Trichter unten in eine ADR"* ist genau das, was diese ADR **ist**; wer den Satz anwendet, bekommt sie. **(c)** trägt und ist **kein Wortspiel:** das Modul schreibt `done/` an allen fünf Fundstellen artefakt-relativ, die Dateikonvention derselben Sektion setzt Carveouts nach `docs/plan/carveouts/`, also ist das vorgesehene Ziel ein **Unterverzeichnis** von `carveouts/` — unter der Ablage-Lesart erfüllte und verletzte derselbe Pfad-Präfix denselben Satz. Die Werkzeug-Lesart ist widerspruchsfrei und deckt sich mit dem Bullet, in dem der Satz steht (Pflicht-Header-Felder), und mit dem Ort, auf den er selbst zeigt (§Werkzeug-Wahl — der Abschnitt, der über Werkzeuge entscheidet). **Die Abzählung ist jetzt prüfbar und geprüft:** vier Bullets, davon zwei mit Ort-Aussage (1 und 4), plus §Werkzeug-Wahl und §Carveout-Audit-Slice = vier Regelwerks-Stellen, plus `CO-002` = fünf. Selbst nachgezählt, exakt |
| **die Folge — Folgepflicht 7** | **entschieden, und die Schlussfolgerung trägt** | Aus dem Negativbefund folgt **Lücke, nicht Abweichung**, und daraus **kein** Adaptions-Eintrag. Beide Belege verbatim geprüft (`MR-021` §Begründung, `AGENTS.md` §3.8 mit `MR-000`). **Die Prämisse ist nicht behauptet, sondern gemessen:** über alle vier §Ziel-Form-Bullets, §Werkzeug-Wahl, §Carveout-Audit-Slice — und zusätzlich über die Präambel derselben Sektion, deren Dateikonvention `docs/plan/carveouts/CO-<NNN>-…` ausdrücklich *„Ein **temporärer** Carveout"* adressiert und von dieser Entscheidung **eingehalten** statt verletzt wird. Es gibt keinen Satz, von dem abgewichen würde. **Gegenprobe im Register:** `grep -i carveout harness/conventions.md` findet keinen `MR-*`, der die Ablage regelt — es gibt auch nichts zu ändern. Die Nicht-Handlung steht als ausdrückliche Anweisung an den nächsten Architect-Lauf samt Vorbehalt für eine spätere Baseline; damit ist sie entschieden statt vergessen |
| **V-2** — das Prüfkommando zu Änderung (4) sah eine von fünf Zeilen | **behoben** | Das Kommando ist auf die Änderung gezogen: `grep -n '^## Verifikation'` → leer. Beide Richtungen selbst gefahren, **alle sechs Zahlen der ADR exakt** (5 Haken heute; nach der Ein-Zeilen-Löschung 0/0/1/4; nach der Abschnitts-Löschung 0). Der Satz *„jedes deckt genau die Änderung, neben der es steht"* trägt jetzt für (4); die `d-check:ignore`-Zeile bleibt als Gegenprobe daneben |
| **V-3** — die halbe Ausführung von *„Trigger fällt weg"* war weder vollzogen noch erklärt | **behoben** | Festlegung 5 sagt jetzt, was die erste Zitat-Hälfte heißt (*„es wartet nichts mehr auf diese Schwelle"*, an ihre Stelle treten die Re-Evaluierungs-Trigger) und was sie **nicht** heißt, mit dem handfesten Grund: eine Löschung machte Zitate zweier ab dann immutabler ADRs quellenlos. **Beide Zitate und die `ADR-0019`-Stelle selbst geprüft** — der Grund besteht. Änderung (3) trennt sauber: die **Handlungs**-Anweisung fällt, der Abschnitt bleibt, ein Vorspann-Satz zeigt auf den Status im Kopf |

**Keine Regression:** kein in den Runden 1–3 behobener Punkt ist wieder aufgetaucht. Kontext,
Festlegung 5, Folgepflicht 1, Folgepflicht 7, Geschichte- und Index-Zeile sind einzeln
gegengelesen und deckungsgleich; die Abzählungen passen zusammen (vier Ort-Stellen im Regelwerk +
`CO-002` = fünf; Bein 1 in Festlegung 5 nennt die gelesene Menge, nicht die Trefferzahl — zwei
Einheiten, beide ausgesprochen).

---

## Findings

*Kein HIGH, kein MEDIUM, kein LOW. Zwei INFO — beide dokumentationswürdig, keiner blockierend.*

### I-1 — Grund (c) schreibt dem Modul einen Pfad zu, den es nicht schreibt; die Prämisse trägt trotzdem, aber über einen Schluss, den der Text nicht zeigt

- **kategorie:** INFO
- **quelle:** [ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 2 (Beleg =
  Tag · Datei/Abschnitt · Zitat verbatim); Maintainability
- **pfad:** `docs/plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md:171-173`
- **befund:** Grund (c) lautet *„Das Ziel, das dasselbe Modul für einen abgeschlossenen Carveout
  vorsieht, ist `carveouts/done/`"*. Das Modul schreibt an allen fünf Fundstellen bares
  `` `done/` `` und **nie** `carveouts/done/` (`grep -n 'carveouts/done'` → leer, Exit 1). Der
  Schluss ist zwingend — `done/` steht im Modul durchgängig artefakt-relativ, und die
  Dateikonvention derselben Sektion setzt Carveouts nach `docs/plan/carveouts/` —, aber er ist
  ein Schluss und steht als Zuschreibung da. Die zwei anderen Gründe tragen unabhängig.
- **gegenbeispiel:** Jemand prüft die als *„am Wortlaut prüfbar"* angekündigten drei Gründe,
  greppt das Modul nach `carveouts/done/`, findet nichts und hält die Prämisse für erfunden —
  und verwirft damit einen von drei Gründen, obwohl er trägt.
- **verifizierbar:** ja, ohne Gate — `grep -n 'done/' .harness/baseline/v3.5.2/regelwerk/modul-07-carveouts.md`
  gegen die Dateikonvention derselben Sektion.

### I-2 — Änderung (3) hat zwei Hälften; das Prüfkommando deckt die Löschung, nicht die Ergänzung

- **kategorie:** INFO
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 (*„benennen, was wirklich deckt — oder dass
  nichts deckt"*)
- **pfad:** `docs/plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md:602-616` (Folgepflicht 1,
  Änderung (3) und der Satz *„jedes deckt genau die Änderung, neben der es steht"*)
- **befund:** Änderung (3) besteht aus einer **Löschung** (*„und nach `done/` zu verschieben"*)
  und einer **Ergänzung** (der Vorspann-Satz, der auf den Status im Kopf zeigt). Das zugeordnete
  Kommando `grep -n 'zu verschieben'` → leer sieht die Löschung; für die Ergänzung gibt es kein
  Kommando, und die ADR sagt an dieser Stelle nicht, dass keines existiert — anders als sonst,
  wo sie fehlende Wächter durchgängig ausspricht. Festlegung 5 führt den Vorspann-Satz als das
  Mittel, das den Leser trennt.
- **gegenbeispiel:** Der Implementer streicht die Handlungs-Anweisung, ergänzt keinen
  Vorspann-Satz; alle drei Kommandos sind leer, `make docs-check` grün, der Verifier hakt ab. Der
  Abschnitt `## Auflösungs-Trigger` steht dann ohne den Zeiger, den Festlegung 5 als Trennung
  benennt — die Wirkung ist gering (der Status steht im Kopf desselben Dokuments, und
  Folgepflicht 4 weist den Planner ohnehin darauf an), aber die Zusage reicht einen Halbsatz
  weiter als ihr Nachweis.
- **verifizierbar:** nein, nicht maschinell — kein Modul von `.d-check.yml` liest, ob ein Satz
  ergänzt wurde. Am Text belegbar durch Abgleich der drei Kommandos mit den vier Änderungen.

---

## Negativbefunde

- **geprüft, ohne Befund — die Abzählung des Ort-Inventars.** §Ziel-Form führt gemessen **vier**
  Bullets; Ort-Aussagen stehen **nur** im ersten und im vierten; die zwei dazwischen betreffen die
  Form des Auflösungs-Triggers und den `# CO-<NNN>`-Kommentar. Mit §Werkzeug-Wahl und
  §Carveout-Audit-Slice sind das vier Regelwerks-Stellen, mit `CO-002` fünf. **Die Abzählung ist
  vollständig** — und der einzige weitere Ort-Bezug der Sektion, die Dateikonvention in ihrer
  Präambel, ist auf *„Ein **temporärer** Carveout"* bezogen und wird von dieser Entscheidung
  eingehalten, nicht verletzt. Er stützt den Negativbefund, statt ihn zu stören.
- **geprüft, ohne Befund — (a) hält, auch gegen die Zeitachse.** Am Anlage-Commit `f68cebd` stand
  im Feld *„noch nicht geschnitten — fällig als Folgepflicht 3 von ADR-0019"*; es wurde am selben
  Tag gefüllt. Die ADR behauptet nichts über den Anlage-Zeitpunkt, sondern über den Zustand, den
  sie disponiert (*„hat das Feld gefüllt"*), und der gilt seither ununterbrochen. **Kein
  Widerspruch zum Folge-Slice-Test** weiter oben: dort wird derselbe Bullet nach seiner **Logik**
  herangezogen (der Slice ist verbraucht, ein zweiter wäre das Memo), hier sein **Buchstabe**
  disponiert — und genau diese Trennung sagt die Überschrift des Absatzes an, mit Rückverweis
  auf den Test.
- **geprüft, ohne Befund — (c) ist ein Argument, kein Wortspiel.** Die Reductio hat eine reale
  Prämisse (das vorgesehene Ziel liegt unter `carveouts/`) und eine reale Alternative, die drei
  unabhängige Stützen hat: den Bullet, in dem der Satz steht (Pflicht-Header-**Felder**), seinen
  eigenen Zeiger (*„über den Trichter unten"* = §Werkzeug-Wahl, der Abschnitt über **Werkzeuge**)
  und die Präzedenz. Zur Zuschreibung des Pfades s. I-1.
- **geprüft, ohne Befund — die Präzedenz ist exakt.** `ADR-0012` §Kontext zitiert **denselben
  Satz** verbatim und disponiert ihn mit **derselben Wendung** (*„Der Satz greift hier nach seiner
  Logik, nicht nach seinem Buchstaben, und das gehört gesagt"*). Die Behauptung *„mit derselben
  Wendung"* trägt wörtlich. Der Unterschied im **Ausgang** — dort lag der Gegenstand ohnehin nicht
  unter `docs/plan/carveouts/`, hier bleibt er dort — wird von ADR-0021 nicht verwischt: sie
  beruft sich auf dieselbe **Disposition**, nicht auf dasselbe Ergebnis, und stützt den härteren
  Fall auf drei eigene Gründe statt auf die Präzedenz.
- **geprüft, ohne Befund — Lücke statt Abweichung.** Die Schlussfolgerung von Folgepflicht 7 ruht
  auf zwei verbatim geprüften Sätzen und einer gemessenen Prämisse. Sie erklärt **keine**
  Abweichung zur Lücke: es gibt keinen Regelwerks-Satz, von dem abgewichen würde — der einzige
  Kandidat ist disponiert, die übrigen sind auf andere Fälle bezogen. Das Register bestätigt es
  von der anderen Seite: kein `MR-*` regelt die Carveout-Ablage. Der Vorbehalt für eine spätere
  Baseline steht, und er nennt mit `ADR-0016` Festlegung 2 den Maßstab, an dem er dann zu prüfen
  ist.
- **geprüft, ohne Befund — `MR-025` über jede in dieser Runde neu geschriebene Zahl.** Jede trägt
  entweder ihr Kommando oder ist eine Aufzählung, deren Glieder im selben Satz stehen: `4` Bullets
  (mit dem einleitenden Zitat und der Charakterisierung aller vier), `5` Haken (mit
  `awk … | grep -c`), die Gegenprobe `0/0/1/4` (mit drei `grep -c`), `3` legitime `done/`-Verweise
  (mit `grep -n`), `18` unverändert (mit Filter). **Alle selbst nachgefahren, alle exakt.** Die
  Zahlwörter *„fünf Stellen"*, *„vier stehen im Regelwerk"*, *„zwei Sätze"*, *„drei Gründe"*,
  *„vier Änderungen"*, *„drei Prüfkommandos"* sind Etiketten auf Listen, deren Glieder jeweils
  benannt sind — die Ausnahme, die `MR-025` Setzung 1 wörtlich vorsieht.
- **geprüft, ohne Befund — Status-Schnappschüsse.** Kein Satz nennt einen Status, den der eigene
  Accept falsch macht. Die fünfte Ort-Stelle ist ausdrücklich als Erwartung markiert, *„die der
  Carveout an seinen eigenen Ausgang schrieb, als der Ausgang noch offen war"*, mit benannter
  Aufhebung; die Zahl der geführten Carveouts trägt weiterhin den Zusatz, dass sie sich nicht
  bewegt; die vier `Accepted`-Angaben stimmen. Die **ADR-0020-Klasse trifft nicht.**
- **geprüft, ohne Befund — Zitat-Treue.** Die drei neuen verbatim-Stellen (`MR-021` §Begründung,
  `AGENTS.md` §3.8, der erste §Ziel-Form-Bullet) sind Wort für Wort geprüft; dazu die zwei
  `CO-002`-Zitate, auf denen V-3s Grund ruht, und die Präzedenz-Wendung aus `ADR-0012`. **Kein
  Zitat ist kondensiert oder umformuliert.** Der einzige Wortlaut-Vorbehalt betrifft eine
  Zuschreibung, kein Zitat (I-1).
- **geprüft, ohne Befund — Konsistenz und Form.** Kontext ↔ Festlegung 5 ↔ Folgepflicht 1 ↔
  Folgepflicht 7 ↔ Geschichte ↔ Index-Zeile: durchgehend deckungsgleich, einschließlich der
  Zahlwörter und der neuen Lücke-Aussage. Keine Slice-Adresse, keine wandernde Summe, beide
  N-2-Suchen leer, sieben Template-Abschnitte, §3.8 am Commit-Zuschnitt erfüllt,
  `make docs-check` `0 Befund(e)`.
- **geprüft, ohne Befund — die unveränderten Teile.** Fitness Function, Alternativen,
  Re-Evaluierungs-Trigger, Annahmen (a)–(d), Festlegungen 1–4 und die Folgepflichten 2–6 sind vom
  Diff nicht berührt; ihre Belege stehen aus den Runden 1–3 und sind dort je gefahren.
- **geprüft, nicht bewertet (fremde Rolle):** `slice-089` bleibt durch Festlegung 5 überholt
  (DoD (1) verlangt den Move samt `R100`, DoD (2) verlangt die Zeiger **leer**, während
  Folgepflicht 2 sie **stehend** verlangt; Datei-Tabelle und §5 planen einen Link-Zug für einen
  Move, den es nicht gibt). Das gehört in ein Plan-Review und steht unten in der Offen-Tabelle.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 0 |
| INFO | 2 |

Verlauf über vier Runden: **HIGH 3 → 0 → 0 → 0**, **MEDIUM 3 → 4 → 1 → 0**,
**LOW 2 → 1 → 2 → 0**, **INFO 2 → 0 → 0 → 2**. Die blockierende Menge ist **leer**.

## Was nach der Annahme offen bleibt — und wem es gehört

| Offener Posten | Eigentümer | Woran fertig |
|---|---|---|
| **Folgepflicht 1** — vier Inhaltsänderungen an `CO-002` (Status · `Letzte Prüfung`/Geschichte · Handlungs-Anweisung im Auflösungs-Trigger **plus Vorspann-Satz** · Abschnitt *Verifikation* als Ganzes) und eine an `docs/plan/carveouts/README.md`; **kein** `git mv`, **ein** Commit | Implementer | `grep -n 'zu verschieben'`, `grep -n '^## Verifikation'`, `grep -n 'd-check:ignore'` je leer + `make docs-check` `0 Befund(e)`; **I-2 beachten:** der Vorspann-Satz hat kein Kommando |
| **Folgepflicht 2** — die sechs Zeiger behalten ihre Adresse, ihre Aussage wird nachgezogen | Spec-Eigentümer + Implementer | `grep -n 'CO-002' spec/spezifikation.md .claude/hooks/pretooluse-agent-guard.sh` → weiter **sechs** Zeilen in zwei Dateien; `make docs-check` grün |
| **Folgepflicht 3** — Matrix-Zellen *Token-Attribution × Repo* (Hintergrund-Teil) und *Cache-Counter × Repo* auf **ADR-Verdikt** | Planner | die Zellen tragen den Wert; sie entstehen mit der Wellen-Closure |
| **Folgepflicht 4** — das Carveout-Audit liest den **Status**, nicht das Verzeichnis; der welle-09-Closure-Trigger nennt beide Carveouts | Planner | Audit trennt am Status; `ls docs/plan/carveouts/CO-*.md` zeigt weiter **2** |
| **Folgepflicht 5** — fälliger `test/mutations/`-Fall **als eigener DoD-Punkt** des umsetzenden Slice | Implementer (Fall) · Planner (DoD-Punkt) | `make mutate` ohne Befund, Fall rot gesehen |
| **Folgepflicht 6** — bekommt die emittierte Ebene je Erfassung, gilt die Grenze dort und gehört genannt | der Slice, der die Tool-Ebene entscheidet | — (feedforward, kein Termin) |
| **Folgepflicht 7** — **KEIN** Adaptions-Eintrag; die Nicht-Handlung ist die Anweisung | Architect | nichts zu tun; erst eine Baseline, die den Fall regelt, stellt die Frage neu |
| **`slice-089` ist überholt** — DoD (1)/(2), Datei-Tabelle und §5 planen den Move | Planner | Re-Schnitt oder Nachzug, danach Plan-Review |
| **`make gates` / `make mutate` nach dem Vollzug**, DoD-Abhakung, Plan-Konformität | Verifier (Modul 11, getrennter Kontext) | echte Gate-Ausgabe |
| **I-1 / I-2** — eine Zuschreibung und eine Halb-Deckung, beide benannt | Architect (falls je eine Folge-ADR denselben Gegenstand anfasst) | — (benannt, nicht geschlossen) |

## Verdikt

**Frei für die Annahme. ADR-0021 kann auf *Accepted* gesetzt werden.**

**Merge-blockierend: nein.** Null HIGH, null MEDIUM, null LOW. Was bleibt, sind zwei INFO — eine
Zuschreibung, deren Prämisse ich selbst nachgemessen habe und die trägt, und eine Halb-Deckung an
einem Prüfkommando, deren Wirkung sich auf einen fehlenden Zeiger in einem Dokument beschränkt,
dessen Kopf dieselbe Auskunft eine Zeile höher gibt. Keiner der beiden erzeugt einen Widerspruch,
keiner färbt einen Gate, keiner ändert eine Festlegung.

**Das offene MEDIUM der Verdikt-Runde ist an der Wurzel behoben, nicht umschrieben.** Der Satz,
den das Inventar ausgelassen hatte, steht jetzt verbatim im Text und ist mit drei Gründen
disponiert — und alle drei habe ich an der Quelle geprüft: der Vordersatz trifft nicht zu (das
Pflichtfeld ist gefüllt, gemessen bis in den Anlage-Commit hinein), der Nachsatz ist von dieser
ADR vollzogen, und die Ablage-Lesart widerspräche sich selbst, weil das vom Modul vorgesehene Ziel
unter demselben Pfad-Präfix liegt. Die Abzählung ist von *behauptet* auf *prüfbar* umgestellt und
stimmt: vier Bullets, zwei mit Ort-Aussage, plus zwei Sektionen, plus der Carveout. **Und die
Folge, an der V-1 praktisch wurde, ist mitentschieden:** die Ablage-Frage ist eine **Lücke**, keine
Abweichung — belegt mit zwei verbatim geprüften Sätzen, mit einer über die ganze Modul-Sektion
gemessenen Prämisse und, von der anderen Seite, mit einem Register, das an dieser Stelle leer ist.
Folgepflicht 7 ordnet deshalb **keinen** Eintrag an und sagt, warum. Das ist die Auflösung, die
gefehlt hat, und sie ist die inhaltlich richtige, nicht die bequeme.

**Zur Konvergenz, weil sie zum Verdikt gehört:** 3 HIGH → 4 MEDIUM → 1 MEDIUM → 0. Über vier
Runden ist kein Befund je zurückgekommen, und die Befunde sind nach außen gewandert — von der
Ausführbarkeit einer Folgepflicht über den Nachweis und die Vollständigkeit eines Belegs bis zu
zwei Randnotizen. **Die Sache selbst — der Ausfall der Verbrauchs-Achse je Rolle ist permanent,
und der übergeführte Carveout behält seine Adresse — ist in keiner der vier Runden angegriffen
worden.**

**Übergabe:** Der Statuswechsel gehört dem **Architect** (ADR und Index sind Architect-Artefakte,
§3.8 / [ADR-0015](../plan/adr/0015-rollen-eigentum-an-norm-artefakten.md)); mit ihm wird die ADR
nach §3.4 immutabel. Der **Planner** ist unabhängig gefordert: `slice-089` ist durch Festlegung 5
überholt und muss vor seinem Eintritts-Trigger nachgezogen werden. Der **Verifier** prüft in
getrenntem Kontext DoD und Gate-Lauf (Modul 11); dieser Report ersetzt das nicht. Der
Eintritts-Trigger von `slice-089` — *ADR-0021 ist Accepted* — ist mit dem Statuswechsel erfüllt.

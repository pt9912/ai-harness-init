# Review-Report: ADR-0070 (Proposed) — Konsistenz gegen ADR-0042, ADR-0033, ADR-0030 — 2026-09-26

**Rolle:** Reviewer (Modul 10, `.harness/skills/reviewer.md`), frischer Kontext.
**Gegenstand:** `docs/plan/adr/0070-der-verweis-nachzug-schreibt-in-docs-reviews-nur-die-link-form.md`, Commit `149c8aa5`, Baum bei Beginn sauber, HEAD `149c8aa5`.
**Eingang:** ADR-0070 komplett, das Architect-Verdikt `docs/reviews/2026-09-26-architect-verdikt-slice-mv-und-eingefrorene-adressen.md`, ADR-0042, ADR-0034 (Muster einer Teil-Ablösung), ADR-0030, ADR-0033 (Abnahme-Kriterium 1 wörtlich), ADR-0024/ADR-Index, `harness/tools/slice-mv.sh`, `harness/sensors/slice-mv.md`, `harness/sensors/archive-welle.md`, `internal/archive/{refs,scan}.go`, `.d-check.yml`, Baseline `modul-04/05/06/08`.
**Prüfgegenstand nach Acceptance-Trigger (ADR-0070 §Der Acceptance-Trigger, Z. 265-272):** Konsistenz gegen ADR-0042, ADR-0033, ADR-0030. Kein Code, keine ADR angefasst.

## Verdikt

**Accept-Empfehlung: ja nach Korrektur.** Kein HIGH. Die Entscheidung (Form-Regel für `docs/reviews/**`, Ausnahmeliste unverändert) trägt: die Zahlen des Architects sind nachgefahren und stimmen, die Wahl D ist gegen A/B/C fair gemessen, §3.5 ist nicht berührt, ADR-0033 Abnahme-Kriterium 1 ist richtig gelesen, §3.4 ist gewahrt. **Zwei MEDIUM betreffen den Wortlaut der Festlegungen** (eine Gate-Zusage, die über die Messung hinausgeht, und eine Grenzziehung *Link* gegen *Code-Span*, die für Link-Syntax **innerhalb** eines Code-Spans offen ist). Beides steht in Text, der mit dem Accept einfriert; beides ist im `Proposed`-Fenster mit zwei bis drei Sätzen zu beheben. Ob die MEDIUM „blockierend" im Sinne von ADR-0040 Festlegung 2 sind (dann ist der Beleg des Accepts eine erneute Runde), entscheidet der Architect beim Vollzug; ich melde sie als **vor dem Accept zu klären**.

Kategorien: HIGH 0 · MEDIUM 2 · LOW 6 · INFO 3.

## Findings

### MEDIUM-1 — „dort prüft `codepaths` die Code-Span-Form, und ein unterbliebener Nachzug färbte sie rot" ist für `done/` zu weit und ungefahren

- `kategorie`: MEDIUM · `quelle`: `AGENTS.md` §3.6 (Zusage ohne rot gesehenes Gegenbeispiel), ADR-0042 Festlegung 1 (Kriterium *Aussage*) und Verglichene Alternative A (Contra: *„die Sichtbarkeit für das Gate statt die Eigenschaft des Artefakts"*)
- `pfad`: `docs/plan/adr/0070-…link-form.md:153-155` (Festlegung 1, letzter Satz), `:186` („Dort ist der Nachzug gate-notwendig"), `:241` (Fitness-Zeile 4, „`codepaths` färbt rot"); Gegenstück `docs/plan/adr/0042-…md:315-333` (Festlegung 4, Gegenform 2)
- `befund`: Das Verdikt führt selbst als ungefahren Posten „Code-Span-Form in `done/**` unter `codepaths` … aus der Config gelesen, nicht gefahren" (Verdikt Z. 111); die ADR schreibt es als Tatsache. Gefahren (siehe §Sonden, E und Sondierung F): `codepaths` färbt in `done/` **nur** den reinen Pfad-Code-Span rot (`codepath-missing`); ein Pfad als **Operand in einem Kommando-Span** und ein Pfad in einem **Code-Block** bleiben grün, auch wenn der Nachzug unterbleibt. Die Regel auf `done/` auszudehnen (Politik E) ließ am realen Move **kein** `codepaths` rot werden; die eine nicht ersetzte Zeile liegt in einem Code-Block. Folge 1: Fitness-Zeile 4 hat ihr Rot nur für einen Fixture mit reinem Pfad-Span. Folge 2: die Begründung, warum `done/` anders behandelt wird als `docs/reviews/**` (*gate-notwendig*), trägt für die Operand-Form nicht — dort schreibt der Nachzug in `done/` weiter eine Mess-Aussage um (ADR-0042 Festlegung 4, Gegenform 2, z. B. der Operand `grep -rn ']([^)]*open/slice-089-carveout-co-002-ueberfuehren\.md)' …` in `done/slice-089-…md:312`), ohne dass ein Gate ihn braucht. Die Ungleichbehandlung beider Bäume hängt damit für diese Form an Gate-Sichtbarkeit — dem Maßstab, den ADR-0042 (Alternative A, Contra) verwirft — und die ADR sagt nicht, dass sie ihn hier bewusst anwendet.
- `verifizierbar`: ja (Gegenprobe unten)
- `klasse`: Gate-Wirkungs-Zusage über eine Form-Teilmenge zur Gesamtform verallgemeinert

### MEDIUM-2 — Link-Syntax **innerhalb** eines Code-Spans oder Code-Blocks ist von der Form-Regel weder eingeschlossen noch ausgeschlossen; die Byte-Gleich-Zusage ist so nicht bindbar

- `kategorie`: MEDIUM · `quelle`: `AGENTS.md` §3.6; ADR-0070 Fitness Function
- `pfad`: `docs/plan/adr/0070-…link-form.md:147-152` (Festlegung 1: *„Code-Span, Code-Block … wird nicht ersetzt"* neben *„Inline-Form `](ziel)`"*), `:236-241` (Fitness, kein Fall dafür); `harness/sensors/slice-mv.md:69-75` (die Grenze *„steht die Link-Syntax selbst … in einem Code-Span oder Code-Block, wird sie mitersetzt"*); `internal/archive/refs.go:24-35, 137-152` (die Ersetzung ist kontext-blind: Wortgrenze plus `done/<base>`)
- `befund`: Beide Träger sind kontext-blind. In `docs/reviews/**` steht Link-Syntax als Zitat innerhalb eines Code-Spans (Fundstellen der Sonde unten, u. a. `docs/reviews/2026-08-01-adr-0013-0014-bestaetigungsrunde.md:267`, `docs/reviews/2026-08-02-slice-068-verify.md:87`, `docs/reviews/2026-09-08-slice-127-adr-immutabilitaet-vcs-review.md:251`). Ob so ein Vorkommen „Ziel eines Markdown-Links" (ersetzen) oder „Code-Span" (byte-gleich) ist, sagt Festlegung 1 nicht. Ein Träger mit einer Link-Regex besteht jeden Fall der Fitness-Zeilen 1 und 2 (Link und *reiner* Pfad-Span nebeneinander) und schreibt die zitierte Link-Syntax trotzdem um; die Byte-Gleich-Zusage aus Festlegung 1 bricht dann an einer Form, die kein Test hält. (Gemessen ist die Klasse, nicht ein betroffener bewegter Slice: die drei genannten Zeilen nennen heute keinen Slice in `open/`, `next/` oder `in-progress/` mit echtem Namen — die Menge ist damit real, aber derzeit inert.)
- `verifizierbar`: ja (Fixture mit Link-Syntax im Code-Span; Regex-Träger fällt, Parser-Träger nicht)
- `klasse`: Grenzziehung Form-Regel ohne Aussage über die Überlappungs-Form

### LOW-1 — Referenz-Definition ist zugesagt, hat keinen Bestand und keinen Fall

- `pfad`: `docs/plan/adr/0070-…link-form.md:149-150` (*„… und die Referenz-Definition `[name]: ziel`"*); `harness/sensors/slice-mv.md:72-73` (dort: eine Referenz-Definition bleibt bei der präfixlosen Form stehen)
- `befund`: `git grep -nE '^\[[^]]+\]:[[:space:]]*\S*planning/' -- docs | wc -l` → **0**; `… (open|next|in-progress)/slice … -- docs/reviews docs/plan/planning/done | wc -l` → **0**. Die Form hat keinen Träger im Bestand und keine Fitness-Zeile; eine Mutation, die ihre Behandlung entfernt, färbt keinen Fall rot (§3.6). Die ADR benennt die Form als Regel-Inhalt, nicht als benannte Lücke.
- `verifizierbar`: ja · `klasse`: Zusage ohne Gegenbeispiel über einer Form ohne Bestand

### LOW-2 — Die Accept-Pflicht „Kopf-Marke an ADR-0042" steht nur im Verdikt, nicht in der ADR

- `pfad`: `docs/plan/adr/0070-…link-form.md:203-229` (§Konsequenzen: Folgepflichten 1 und 2, keine dritte); Verdikt Z. 107; `docs/plan/adr/README.md:37` (Muster: Zeile von ADR-0030)
- `befund`: Das Muster ist richtig gewählt und wird richtig geführt: ADR-0030 trägt die Teil-Ablösung **nicht** in der eigenen Datei (`Status: Accepted`, Z. 3), sondern in der Status-Zelle des ADR-Index (`Accepted (§Entscheidung Festlegung 3 … revidiert durch ADR-0034)`); `MR-032` gilt für Adaptions-Einträge, nicht für ADRs. Dass **der Index bei ADR-0042 beim Accept nachzuziehen ist** (und erst dann, sonst unwahre Zustandsaussage), steht aber nur im Verdikt (ein Zeitdokument), nicht in der ADR; der Vollzug liest im Normalfall die ADR. Ohne den Satz hängt die Marke an einem Verdikt, das kein Rang trägt.
- `verifizierbar`: nein · `klasse`: Accept-Folgepflicht steht im Zeitdokument statt in der Norm

### LOW-3 — Baseline-Bezug und `MR-000` bleiben ungesagt

- `pfad`: `docs/plan/adr/0070-…link-form.md:9-32` (Bezug ohne MR-000, ohne Modul-6-Stelle); Baseline `.harness/baseline/v6.9.0/regelwerk/modul-06-roadmap.md` (Schritt 4: *„Der Umzug ändert Pfade; die Operation zieht die Verweise nach — in **beiden** Formen, mit Verzeichnis-Präfix und geschwister-relativ"*)
- `befund`: Meine Einordnung: **keine Abweichung, kein MR nötig.** *„Beide Formen"* bezeichnet dort Präfix- und geschwister-relative Schreibweise des Pfades, nicht Link gegen Code-Span; die Link-Form bleibt in beiden Schreibweisen nachgezogen. Die ADR verengt zudem in die Richtung der Baseline-Aussage *„werden nicht nachgezogen"* (ADR-0042 Kontext, Zitat `v6.5.0`). ADR-0042 führt ebenfalls keinen MR. Die ADR beantwortet die Frage aber nicht, die ADR-0034 in ihrem Bezug beantwortet (`MR-000`: eine Abweichung schuldet einen Eintrag). Ein Satz genügt; sonst muss jeder spätere Leser die Einordnung neu messen.
- `verifizierbar`: nein · `klasse`: Baseline-Abgleich ungesagt

### LOW-4 — Verglichene Alternative B nennt „einzigen Ausweg", es gibt einen zweiten

- `pfad`: `docs/plan/adr/0070-…link-form.md:159-161` und `:198` (*„der einzige Ausweg wäre ein baum-weites `ignore-refs`"*)
- `befund`: ADR-0042 Festlegung 3 zeigt den engeren Weg selbst: namentlich geschnittene `ignore-refs`-Paare (`refs: [<ein Pfad>]`). Für B wäre je Move und Report ein Paar möglich — ebenfalls eine Senkung nach §3.5, teurer und ohne Ende, aber nicht baum-weit. Die Wahl von D bleibt davon unberührt; die Contra-Zelle ist zu absolut formuliert.
- `verifizierbar`: nein · `klasse`: absolute Formulierung über eine Menge mit drei Elementen

### LOW-5 — Von den drei akzeptierten Negativen trägt nur eines einen Trigger; die Kopplung ist baubar

- `pfad`: `docs/plan/adr/0070-…link-form.md:209-214` (Konsequenzen, Negativ 1 und 2), `:243-247` (Kopplung „hält kein Test"), `:249-261` (Trigger 1 bis 4), Verdikt Z. 108-110
- `befund`: (i) *Code-Span-Adressen sterben still*: Trigger 1 greift nur, wenn die **Config** kippt, nicht wenn ein Report-Leser auf einen toten Span läuft — teilgedeckt. (ii) *Schreiber-Verzicht hält nicht vollständig* (Zahl **67** in `done/`, **81** in Reports seit `05332d63`, beide nachgefahren): **kein** Trigger benannt, der die Empfehlung zur Pflicht macht. (iii) *Kopplung Form-Regel ⇄ `codepaths.exempt-paths`*: Trigger 1 und „der Lauf, der die Config ändert" tragen; die ADR sagt *nicht gebaut*, nicht *nicht baubar* — und ein Test, der `.d-check.yml` gegen die Zeile `exempt-paths: ["docs/reviews/**"]` unter `codepaths:` hält, ist von derselben Bauart wie `test/sources-pin.bats`. Die Formulierung darf bleiben; ein Trigger für (ii) fehlt.
- `verifizierbar`: ja (für iii) · `klasse`: akzeptiertes Negativ ohne Auflösungs-Bedingung

### LOW-6 — Form: Schlusssatz fehlt, Zahl steht ohne Kommando

- `pfad`: `docs/plan/adr/0070-…link-form.md:274-278` (Ende der Datei: die Fußzeile *„Nach `Accepted` wird diese Datei nicht mehr inhaltlich überschrieben …"* fehlt; vgl. `docs/plan/adr/0069-….md` und `docs/plan/adr/0042-….md` Ende); `:108-113` (Tabelle mit **1964** geprüften Dateien, dazu das Kommando nur über den Verweis aufs Verdikt)
- `befund`: Die Fußzeile trägt jede jüngere `Accepted`-ADR. Die 1964 stehen am Stand `f8d33b38`; am HEAD `149c8aa5` sind es **1966** (`git diff --name-only f8d33b38 HEAD | wc -l` → **3**, davon zwei neue Dateien: ADR-0070 und Verdikt). Tragend ist die Gleichheit der Zahl über die Politiken — sie ist nachgefahren und gleich; `MR-025` verlangt das Kommando am Ort der Zahl.
- `verifizierbar`: nein · `klasse`: Form / Zahl ohne Kommando am Ort

### INFO-1 — Die ADR (eingefroren ab Accept) verlinkt ein Verdikt in `docs/reviews/**` per Pfad

- `pfad`: `docs/plan/adr/0070-…link-form.md:103-104`
- `befund`: Der Hänger-Wächter aus ADR-0033 Abnahme-Kriterium 1 liest die ADR und den Report. Das Verdikt trägt keinen Slice-Namen und wird von keiner Welle eingesammelt (`AGENTS.md` §3.11: gebunden ist, was wandert). Kein Befund heute; ein Archivierungs-Schnitt, der Reports ohne Slice erfasst, würde ihn auslösen.

### INFO-2 — `Supersedes (Teil)` auf einen Wert: zulässig, mit einer Nebenwirkung auf Festlegung 4

- `pfad`: `docs/plan/adr/0070-…link-form.md:26-32`; `docs/plan/adr/0034-…md:36-45` (Muster)
- `befund`: Form und Wortlaut entsprechen ADR-0034 gegenüber ADR-0030 (*„genau einen Wert … alles andere bindet fort … Festlegungen … bleiben vollständig unberührt"*). ADR-0042 Festlegung 1 nennt **eine** Reichweite (*„ersetzt die Pfad-Adresse"*), keine Kriterien-Änderung; der Satz *„Beide Träger behalten ihre heutige Ausnahmeliste; keiner bekommt einen weiteren ausgenommenen Baum"* bleibt und wird von Festlegung 2 der ADR-0070 ausdrücklich bestätigt. Nebenwirkung: Die Gegenform 2 aus ADR-0042 Festlegung 4 (*Operand im Mess-Kommando*) entfällt für `docs/reviews/**` in der Code-Span-Form; für `done/` bleibt sie (siehe MEDIUM-1).

### INFO-3 — Restore-Commit `bd76d800`

- `pfad`: `docs/plan/adr/0070-…link-form.md:47-62`
- `befund`: Nachgefahren (`git show bd76d800 -U0`): die eine geänderte Zeile (`docs/reviews/2026-09-24-slice-program-feld-nennt-weder-operator-noch-wertfragment-verify.md:36`) tauscht `next/` gegen `open/` **innerhalb eines Code-Spans**; `.d-check.yml:384` nimmt `docs/reviews/**` aus `codepaths` aus. Die Commit-Message nennt §3.11 und ADR-0033 Abnahme-Kriterium 1 als Grund. Die Lesart der ADR stimmt: Ausgang richtig, Begründung falsch.

## Prüfpunkte des Auftrags

**(a) Die Entscheidung.** Trägt sie *„entschieden, nicht geduldet"* aus ADR-0042 Festlegung 1? Sie überschreibt **nur die Reichweite eines Werts** (Pfad-Adresse → Link-Ziel, nur `docs/reviews/`); Kriterium, drei übrige Bäume und Ausnahmeliste bleiben. Das ist ein Teil-Supersedes der Festlegung in dem Umfang, den ADR-0034 gegenüber ADR-0030 vormacht — nicht ein ausgenommener Baum (Festlegung 2 hält das ausdrücklich). Kopf-Marke: keine Änderung an ADR-0042 (§3.4 gewahrt — der Commit `149c8aa5` berührt genau drei Dateien: ADR-0070, `docs/plan/adr/README.md`, das Verdikt); die Marke gehört beim Accept in die Status-Zelle der ADR-0042-Zeile des Index, nach dem Muster der ADR-0030-Zeile (LOW-2). Nicht gesagt in der ADR: die Nebenwirkung auf `done/` (MEDIUM-1).

**(b) Sonden nachgefahren.** Alles stimmt.

| Sonde | ADR/Verdikt | eigene Messung |
|---|---|---|
| `done/`: Link · Code-Span | 527 · 59 | 527 · 59 |
| `docs/reviews/`: Link · Code-Span | 55 · 610 | 55 · 610 |
| Dateien mit Code-Span in `docs/reviews/` | 213 | 213 |
| Schreiber-Zählung seit `05332d63` | `done` 67 · `reviews` 81 | `done 67 · reviews 81` |
| `grep -c 'Der fail-closed-Wächter gegen einen lebenden Verweis' …0033…` | 1 | 1 |

Vier Politiken, je eine `git archive HEAD`-Kopie außerhalb des Repos, Move `slice-071-bilanz-nennt-ihren-bestand` von `next/` nach `in-progress/` (zwei Link-Zeilen und vier weitere Zeilen in Reports, 16 Zeilen in `done/`), je ein `make docs-check` im gepinnten Bild:

| Politik | Befunde gesamt | `target-missing` | Zeilen in Reports geändert (davon mit Backtick) | Zeilen in `done/` geändert | geprüfte Dateien |
|---|---|---|---|---|---|
| A — heute | 1 (`planning-drift`) | **0** | 6 (5) | 16 | 1966 |
| B — `docs/reviews` ausgenommen | 3 | **2** | 0 | 16 | 1966 |
| C — `done` ausgenommen | 16 | **15** | 6 (5) | 0 | 1966 |
| D — `docs/reviews` nur Link-Form | 1 | **0** | 2 (1, ein Link mit Code-Span als Linktext) | 16 | 1966 |
| E — Form-Regel auf `done/` und `docs/reviews` | 1 | **0** | 2 (1) | 15 | 1966 |

Die Differenz **0 / +2 / +15 / 0** stimmt, die Zahl der geprüften Dateien ist in allen fünf Läufen gleich. Fair? Die Wahl hält: B und C werden am selben Move gemessen und von D geschlagen. Grenzen der Nachbildung, ehrlich: A bis C stellen die Politik durch eine Zeile in der Ausnahmeliste von `slice-mv.sh` her (real gefahren: das Shell-Werkzeug); D und E sind **per `sed` am Ergebnis** nachgebildet, nicht von Werkzeug-Code erzeugt. Der Move geht nach `in-progress/` statt `done/` (bekannter `planning-drift`, in allen Läufen derselbe).

**(c) §3.5.** Keine Senkung. `.d-check.yml` ist im Commit unberührt (`git show --stat 149c8aa5`: drei Dateien, keine Config); `codepaths.exempt-paths: ["docs/reviews/**"]` steht unverändert (`.d-check.yml:384`); die geprüften Dateien sind über alle Politiken gleich (1966). Das Gate wird nicht enger, weil es die Code-Span-Form in `docs/reviews/**` heute schon nicht liest (Probe unten, Zeile *reviews*).

**(d) ADR-0033 Abnahme-Kriterium 1.** Richtig gelesen. Wortlaut (`docs/plan/adr/0033-…md:373-376`): *„Der fail-closed-Wächter gegen einen lebenden Verweis auf einen zu löschenden Review-Report schließt `docs/reviews/**` nicht aus. Bricht, wenn: ein Report, der bleibt, einen Report verlinkt, der ins Archiv geht"* — Suchraum des Hänger-Wächters. Die Fitness-Zeile (`:519`) bestätigt: *„`docs/reviews/**` aus dem Suchraum nehmen, dann muss der Wächter fallen"*. Über einen Nachzug spricht das Kriterium nicht. Die Zeile in `harness/tools/slice-mv.sh:169-171` (`docs/reviews steht ABSICHTLICH NICHT darin (ADR-0033 Abnahme-Kriterium 1)`) überträgt es tatsächlich auf den Nachzug-Zweig; ihre zweite Hälfte (*„reale, von `docs-check` geprüfte Verweisziele"*) bleibt für die Link-Form wahr. `internal/archive/scan.go:80-99` bestätigt die Trennung im Code: `Haenger` fragt `Suchraum()`, der schreibende Zweig `AusgenommenePfadeNachzug()`. Restore `bd76d800`: siehe INFO-3.

**(e) Rot-Belege (gefahren, nicht nur gelesen).**
1. *Regel entfernen → Politik A* — **gefahren** (Lauf A): 5 Zeilen mit Backtick in Reports geändert, Aussage umgeschrieben.
2. *Link-Nachzug entfernen → Politik B, +2 tote Links* — **gefahren** (Lauf B): die zwei Befunde stehen in `docs/reviews/2026-08-22-slice-089-plan-review-runde-2.md:34` und `docs/reviews/2026-08-25-slice-094-review.md:111`, beide `target-missing`.
3. *Regel auf `done/` ausdehnen → `codepaths` rot* — **nicht bestätigt am realen Move** (Lauf E: 0 `codepaths`-Befunde, die eine unersetzte Zeile ist ein Code-Block: `docs/plan/planning/done/slice-die-bilanz-sagt-worueber-sie-gerechnet-hat.md:68`). **Konstruiert** (Kopie von E, drei Zeilen in eine `done/`-Datei und eine in einen Report geschrieben): der reine Pfad-Span `` `docs/plan/planning/next/…` `` und `` `../next/…` `` in `done/` → `codepath-missing`; der Kommando-Span (`grep -c x <pfad>`) → **kein** Befund; derselbe reine Pfad-Span in einem Report → **kein** Befund. Ergebnis: das Rot existiert für die reine Pfad-Form, nicht für die Operand-Form — MEDIUM-1.
4. Fitness-Zeilen, die ohne Werkzeug-Änderung nicht prüfbar sind: Zeilen 1, 2 und 4 (bats, Go-Test, `make mutate`-Fall) hängen alle an Folgepflicht 1 — dort benannt. Zeile 3 (`make docs-check` nach dem Move) ist mit der Kopien-Probe vorab gefahren. Die Folgepflicht ist benannt, keine Zeile ist ohne Träger.

**(f) Akzeptierte Negative.** Siehe LOW-5: (i) Trigger 1 greift nur an der Config; (ii) **67 / 81** nachgefahren, ohne Trigger; (iii) benannt, Trigger 1 trägt, baubar.

**(g) Code-Folge.** Drei Liefer-Punkte (`slice-mv.sh` samt bats-Fall, `internal/archive` samt Go-Test und Mutations-Fall, die zwei Sensor-Docs) sind realistisch und stehen ohne Slice-Adresse (§3.11 gewahrt). Die Ersetzung ist in beiden Trägern kontext-blind (`refs.go:24-35`); *„nur Link-Form"* verlangt für `docs/reviews/` einen Kontext-Zweig **außerhalb** von `KERN` — die ADR lässt die Entscheidung dem Implementer und verlangt ihren Bericht (`:224-226`), das reicht. Lücke: Fall für Link-Syntax im Code-Span (MEDIUM-2) und für die Referenz-Definition (LOW-1).

**(h) Index-Zeile.** `docs/plan/adr/README.md:77` stimmt mit der Datei (Titel, Status `Proposed`, Bezug: 0042, 0033, 0030, 0040, `LH-QA-01`, `MR-025`). Dass die ADR-0042-Zeile erst beim Accept angepasst wird, ist **richtig** (vorher unwahre Zustandsaussage); die Pflicht gehört in die ADR (LOW-2).

**(i) §3.7 / §3.11 / `MR-000`.** Zustandsform: die Datei nennt Zustand und Kommando, keine Slice-Adresse als Pfad (`slice-mv.sh`/`test/slice-mv.bats` sind Werkzeug-Namen); die einzige Pfad-Adresse eines Zeitdokuments ist das Verdikt (INFO-1). Kennungs-Form: ohne Slice-Nummer. Trigger (4) und Acceptance-Trigger sind erfüllbar. `MR-000`: keine Abweichung (LOW-3). ADR-Form nach `modul-04`: Kontext, Entscheidung, fünf verglichene Optionen (mit „nichts tun"), Konsequenzen, Fitness Function, Trigger, Acceptance-Trigger vorhanden.

**(j) Negativbefund-Pflicht** — siehe unten.

## Vor dem Accept zu korrigieren (nach dem Accept nicht mehr änderbar)

1. **Festlegung 1, letzter Satz (`:153-155`), und Fitness-Zeile 4 (`:241`):** *„dort prüft `codepaths` die Code-Span-Form, und ein unterbliebener Nachzug färbte sie rot"* auf das Gemessene zurückziehen — der **reine Pfad-Code-Span** (nicht der Operand in einem Kommando-Span, nicht der Code-Block). Und den zweiten Punkt des Abschnitts *Was diese Entscheidung nicht tut* (`:186`, *„gate-notwendig"*) auf dieselbe Teilmenge einschränken; die Operand-Form in `done/` bleibt Gegenform 2 aus ADR-0042 Festlegung 4, und dass der Baum-Unterschied für sie an Gate-Sichtbarkeit hängt, gehört benannt. (MEDIUM-1)
2. **Festlegung 1 (`:147-152`):** sagen, ob Link-Syntax **innerhalb** eines Code-Spans oder Code-Blocks Link-Form (ersetzt) oder Code-Span-/Block-Form (byte-gleich) ist; und in der Fitness-Zeile 1 den Fall dafür aufnehmen. (MEDIUM-2)
3. **Nicht blockierend, aber im selben Fenster billig:** ein Satz zu `MR-000`/Modul 6 (LOW-3); die Accept-Folgepflicht *„ADR-0042-Zeile im Index bekommt die Teil-Revision nach dem Muster der ADR-0030-Zeile"* als Folgepflicht 3 (LOW-2); die Referenz-Definition entweder mit Fall belegen oder als benannte Lücke führen (LOW-1); die Fußzeile (LOW-6); *„einziger Ausweg"* (LOW-4); einen Trigger für Negativ (ii) (LOW-5).

## Sonden

- `git grep -noE '\]\([^)#]*/(open|next|in-progress)/[^)#]*\)' -- <baum> | wc -l` und `git grep -noE '`[^`]*(open|next|in-progress)/slice-[^`]*`' -- <baum> | wc -l` (Bäume `docs/plan/planning/done`, `docs/reviews`), dazu `git grep -lE … -- docs/reviews | wc -l` → Zahlen in der Tabelle (b).
- Link-Syntax im Code-Span in `docs/reviews/`: `git grep -nE '`[^`]*\]\([^)#]*/(open|next|in-progress)/[^)#]*\)[^`]*`' -- docs/reviews | wc -l` → **12** Zeilen; die Regex ist locker und zählt auch echte Links zwischen zwei Spans mit — **kein Erwartungswert**, tragend sind die drei oben genannten Zitat-Zeilen, die vollständig im Span stehen. Im Code-Block (Awk-Sonde über alle `docs/reviews/*`-Dateien): keine Fundstelle.
- Referenz-Definitionen: `git grep -nE '^\[[^]]+\]:[[:space:]]*\S*planning/' -- docs | wc -l` → **0**.
- Kopien-Probe: Skript im Scratchpad (`probe.sh`, Läufe A bis E), Kopien unter dem Scratchpad des Laufs, nicht im Repo; je `make docs-check` mit `--network none`.
- Konstruierte Sonde für MEDIUM-1: in der Post-Move-Kopie von E drei Zeilen an `done/slice-060-rollen-achse.md` und eine an `docs/reviews/2026-08-25-slice-094-review.md` angehängt (reiner Pfad-Span, `../`-Form, Kommando-Span; Pfad-Span im Report), `make docs-check` → zwei `codepath-missing`, beide in `done/`, beide reine Pfad-Spans.

## Geprüft, ohne Befund

- **Kontext-Zahlen und Kommandos** (Bäume-Tabelle, 67/81, `grep -c` zu ADR-0033): stimmen.
- **Politik-Tabelle** (A/B/C/D, `target-missing` 0/2/15/0, geprüfte Dateien gleich): stimmt.
- **§3.5 / `.d-check.yml` unberührt / Prüfbereich gleich:** kein Befund.
- **ADR-0033 Abnahme-Kriterium 1 und `bd76d800`:** richtig gelesen.
- **§3.4 (Accepted-ADR unberührt), Rollen-Eigentum (`AGENTS.md` §3.8, ADR-0024: Index gehört dem Architect):** kein Befund; der Commit trägt drei Architect-Artefakte.
- **Festlegungen 2 bis 5 von ADR-0042, ADR-0030 Festlegung 3/4:** durch Festlegung 2 und den Kopf-Absatz ausdrücklich unberührt; kein Widerspruch gefunden.
- **Skill-HIGH-Liste** (Verstoß gegen aktive ADR/Hard Rule, Gate-Lockerung ohne ADR, stilles Grün, halluziniertes Gate, superseded ADR referenziert, Norm nur im Template-Kommentar, Kommentar ohne Klasse, Zustandsfeld mit Chronik): keine Anwendung. Verweise auf ADR-0042/0033/0030/0040 gehen alle auf `Accepted`-ADRs.
- **Re-Evaluierungs-Trigger 1 bis 4 und Acceptance-Trigger:** vorhanden, erfüllbar, an ablesbaren Zuständen geführt.
- **§3.7-Zustandsform in der ADR:** kein Befund (Anlass-Absatz im Kontext ist Begründung einer Entscheidung, an der Stelle, die die Regel dafür vorsieht).

## Zusammenfassung für die Steering-Loop-Zählung (Klassen)

- Gate-Wirkungs-Zusage über eine Form-Teilmenge zur Gesamtform verallgemeinert (MEDIUM-1)
- Grenzziehung Form-Regel ohne Aussage über die Überlappungs-Form (MEDIUM-2)
- Zusage ohne Gegenbeispiel über einer Form ohne Bestand (LOW-1)
- Accept-Folgepflicht steht im Zeitdokument statt in der Norm (LOW-2)

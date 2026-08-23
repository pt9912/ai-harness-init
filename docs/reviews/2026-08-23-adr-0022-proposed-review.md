# ADR-0022 (Proposed) — Proposed-Review, erste Runde

**Rolle:** Reviewer (Modul 10). **Datum:** 2026-08-23. **Lauf:** frischer Kontext, Subagent
`reviewer`, erster Durchgang zu dieser ADR.

**Review-Art:** Design-Review — geprüft wird die Entscheidung **gegen ihre Quellen und die
Hard Rules**, nicht gegen einen Slice-Plan und nicht gegen eine Definition of Done (das ist die
Verifikation, und zu dieser ADR gibt es keinen Slice). Der Zeitpunkt ist der Punkt, an dem
[`AGENTS.md`](../../AGENTS.md) §3.4 die Aussagen unumkehrbar macht.

**Gegenstand:** `c4145a2` — `docs/plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md`
(*Proposed*, 587 Zeilen, acht Festlegungen) plus zwei Zeilen in `docs/plan/adr/README.md`
(neue Index-Zeile für ADR-0022, Teil-Revisions-Annotation an ADR-0020). Zwei Dateien, 589
Insertionen. Arbeitsbaum vor **und** nach dem Lauf sauber (`git status --porcelain` → leer, beide
Male selbst gefahren).

**Skill:** `.harness/skills/reviewer.md` @ 1.4.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5[1m]

## Eingangs-Kontext (die fünf Pflicht-Punkte, Modul 10 §Eingangs-Kontext)

- **Diff/Range:** `c4145a2` gegen `2059d62`. Beide Dateien vollständig gelesen, der Diff der
  Index-Zeilen einzeln.
- **Betroffene `LH-*`:** `LH-FA-10` (der Auslöser, Rang 1 — Lastenheft-Version selbst gelesen:
  `0.19.0`), dazu `LH-FA-01`, `LH-FA-06`, `LH-FA-08`, `LH-FA-09`, `LH-QA-01`, `LH-QA-02`,
  `LH-QA-03`, `LH-QA-04` — alle in `spec/lastenheft.md` an der Quelle gelesen.
- **Referenzierte aktive ADRs (Status je am Index geprüft):** `ADR-0003`, `ADR-0007`, `ADR-0011`,
  `ADR-0012`, `ADR-0013`, `ADR-0016`, `ADR-0020`, `ADR-0021` — alle *Accepted*. Kein Verweis auf
  eine *Superseded* ADR (Status-Spalte des Index vollständig gelesen).
- **Hard Rules:** [`AGENTS.md`](../../AGENTS.md) §2 (Source Precedence), §3.4, §3.5, §3.6, §3.7,
  §3.8 vollständig gelesen; Konventionen `MR-003`, `MR-010`, `MR-015`, `MR-017`, `MR-025` an der
  Quelle.
- **Vorherige Findings am gleichen Modul:** `docs/reviews/2026-08-22-adr-0021-bestaetigungsrunde.md`
  (3 HIGH / 3 MEDIUM / 2 LOW / 2 INFO) und `docs/reviews/2026-08-16-adr-0020-bestaetigungsrunde.md`.
  Die dort wiederkehrenden Klassen — *Zusage weiter als ihr Sensor*, *Regelwerks-Beleg ohne Tag und
  Dateinamen*, *Adresse statt Eigenschaft*, *Zahl ohne Kommando* — sind hier gezielt gesucht
  worden; drei treffen wieder, eine nicht (Negativbefunde unten).

**Nichts aus der Commit-Message übernommen.** Die zwei dort behaupteten Gate-Zahlen sind selbst
gefahren: `make docs-check` → `d-check: 351 Datei(en) geprüft, 0 Befund(e)`, Exit 0;
`make gates` → Exit 0 (letzte Zeile `span-check: Emitter vorhanden, ein Span geschrieben,
Ablageort git-ignoriert`). **Beide Behauptungen bestätigt.**

---

## Findings

### HIGH-1 — Festlegung 8 zieht aus ADR-0021 das Gegenteil dessen, was dort steht, und lässt dessen Folgepflicht 6 unerwähnt

- **kategorie:** HIGH
- **quelle:** ADR-0021 (*Accepted*) Folgepflicht 6 und §Kontext; [`AGENTS.md`](../../AGENTS.md)
  §3.4 (ADR-0021 ist damit unerreichbar); Reviewer-Skill §HIGH (*„Verstoß gegen eine aktive ADR"*)
- **pfad:** `docs/plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md:447-451`
  (Festlegung 8, dritter Punkt), `:54-56` (Bezug), `:555-559` (Re-Evaluierungs-Trigger);
  `docs/plan/adr/README.md` (ADR-0022-Zeile, derselbe Satz) gegen
  `docs/plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md:680-683` und `:108-111`
- **befund:** `:449` sagt über ADR-0021: *„ihre Permanenz ruht auf der committeten
  Berechtigungs-Lage **dieses** Repos. Was ein fremdes Repo an Zählern erhält, entscheidet dessen
  eigene Lage — wir wissen es nicht und dürfen es weder zusagen noch ausschließen."* ADR-0021 sagt
  an zwei Stellen das Gegenteil. **Erstens der Grund:** `:108-111` schließt die Permanenz aus den
  zwei verbliebenen Wegen, und beide liegen **im fremden Vertrag** — *„Es bleiben die zwei Wege im
  fremden Vertrag … Kein Aufwand dieses Repos bringt eines von beiden herbei."* Der Ausdruck
  *Berechtigungs-Lage* kommt in ADR-0021 nicht vor (`grep -n 'Berechtigungs-Lage'
  docs/plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md` → leer, Exit 1); die nächstliegende
  Stelle, Festlegung 4 (`:443`), führt die *„committete Permission-Lage"* als **Folge** des
  entfallenen Gegenstands, nicht als Grund. **Zweitens die Reichweite:** ADR-0021 Folgepflicht 6
  entscheidet genau den Fall, den ADR-0022 herbeiführt — *„die emittierte Ebene bleibt unberührt,
  und das ist eine Entscheidung. Sie führt heute weder Span-Emitter noch Agent-Guard … **Bekommt
  sie je einen, gilt diese Grenze dort unverändert — sie ist keine Eigenschaft unseres Aufbaus,
  sondern der Mechanik — und gehört dort genannt, nicht stillschweigend mitgeliefert.**"* ADR-0022
  nennt diese Folgepflicht nirgends (`grep -n 'ADR-0021'` über die neue ADR → vier Fundstellen,
  `:54`, `:82`, `:444`, `:448`; keine nennt eine Folgepflicht) und stellt statt der geforderten
  Nennung die Gegenaussage. Dieselbe Verkehrung trägt der Re-Evaluierungs-Trigger `:556`: *„dann
  trägt sie eine Bilanz, und das widerspricht nichts"* — nach ADR-0021 Festlegung 1 widerspräche es
  der dort **permanent** gesetzten Aussage und ist dort selbst der erste bzw. zweite
  Re-Evaluierungs-Trigger. Der Revidiert-Block von ADR-0022 führt aus ADR-0021 nichts auf; die
  Aussage wird also revidiert, ohne als Revision ausgewiesen zu sein.
- **gegenbeispiel:** Ein Adopter bootstrappt, ruft die emittierte Auswertung und liest *„keine
  Verbrauchs-Zähler im Bestand — Abdeckung unbekannt"*. Nach ADR-0021 ist das keine offene Frage,
  sondern eine entschiedene Eigenschaft der Werkzeug-**Mechanik**, die *„dort unverändert"* gilt
  und die er genannt bekommen soll. Er wartet auf Zahlen, die konstruktiv nicht kommen — genau der
  Zustand, den ADR-0021 Folgepflicht 6 mit *„nicht stillschweigend mitgeliefert"* ausschließt.
  Umgekehrt: nimmt jemand ADR-0022 beim Wort und schreibt in die emittierte Auswertung, die Lage
  des Adopters entscheide, steht in einem emittierten Artefakt eine Aussage, die einer *Accepted*
  ADR dieses Repos widerspricht.
- **verifizierbar:** nicht durch einen Gate-Lauf — kein Modul von `.d-check.yml` liest ADR-Semantik
  (`modules: [links, anchors, ids, matrix, codepaths, spans]`, selbst gelesen), und `make gates`
  ist mit dem Befund grün (selbst gefahren). Verifizierbar am Quellenabgleich: die drei
  `grep`/`sed`-Kommandos oben, alle gefahren.

### MEDIUM-1 — Der „Beweis" von Festlegung 1 belegt den Bootstrap-Host, nicht die Hook-Plattform; die Index-Zeile macht daraus eine Einzigkeits-Aussage, die die ADR selbst widerlegt

- **kategorie:** MEDIUM
- **quelle:** `LH-QA-04` §Grenze der Messmethode; [`AGENTS.md`](../../AGENTS.md) §3.6 (die
  Commit-Message führt denselben Satz als *Beweis*); die Belegpflicht für Mengenaussagen
- **pfad:** `docs/plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md:260-268`
  (Festlegung 1, *„nachweislich"*, `:267` *„hier ist sie bewiesen"*), `:236-238` (Annahme (a)),
  `:476` (Alternative F), `:553-554` (Trigger), gegen `docs/plan/adr/README.md` (ADR-0022-Zeile,
  *„das einzige ausführbare Bild, dessen Lauffähigkeit auf der Zielplattform feststeht"*)
- **befund:** Was der Lauf belegt, ist die Lauffähigkeit auf dem Host, der den Bootstrap
  **ausführt**. Was Festlegung 1 braucht, ist die Lauffähigkeit dort, wo die **Hooks** laufen.
  Beides fällt nur unter Annahme (a) zusammen, und die ADR führt genau diese Identität `:236-238`
  selbst als Annahme mit Re-Evaluierungs-Trigger. Damit steht dieselbe Aussage im selben Dokument
  einmal als Beweis (*„nachweislich"*, *„bewiesen"*) und einmal als umstoßbare Annahme; der
  tragende Grund ist um genau diese Differenz schwächer, als er auftritt. Die Index-Zeile
  verschärft ihn zur **Mengenaussage** — *„das **einzige** ausführbare Bild, dessen Lauffähigkeit
  auf der Zielplattform feststeht"* —, und diese Menge widerlegt die ADR selbst: `:476` sagt über
  Alternative F *„dieselben vier Konstruktions-Eigenschaften wie G"*, und die erste dieser vier ist
  `:265-268` *„Keine zweite Plattform-Matrix … hier ist sie bewiesen, weil das Bild gerade läuft"*;
  `:553-554` wiederholt es (*„Alternative F steht dafür bereit und trägt dieselben vier
  Konstruktions-Eigenschaften"*). Die Formulierung steht an **einem** Fundort, dem Index —
  `grep -n 'einzige'` über die ADR liefert zwei Treffer, beide anderen Inhalts (`:219`, `:563`),
  und die Commit-Message führt sie nicht. `LH-QA-04` deckt den Satz nicht: seine Messmethode sagt
  ausdrücklich, der Start-Smoke belege, *„dass das Binary auf der Plattform **läuft** — **nicht**,
  dass ein Bootstrap dort durchläuft"*.
- **gegenbeispiel:** Ein Leser der Annahme, die Wahl sei durch Einzigkeit erzwungen, vergleicht G
  gegen F und findet in derselben ADR, dass F die Eigenschaft teilt. Übrig bleibt als
  Unterscheidung nur der Preis — den die ADR als tragenden Grund ausdrücklich ausschließt
  (*„kein Aufwandsvergleich, sondern ein Beweis"*). Die Entscheidung ist dann ohne benannten
  tragenden Grund, und zwar in einem nach §3.4 eingefrorenen Artefakt.
- **verifizierbar:** ja am Quellenabgleich (`grep -n 'einzige'`, `sed -n '476p'`, `LH-QA-04`
  gelesen); nicht durch ein Gate.

### MEDIUM-2 — Die einzige ungemessene Größe der ADR hat weder Kommando noch Folgepflicht noch Fitness-Function-Zeile, und ihr Trigger ist als *feedback* eingeordnet, obwohl kein Sensor existiert

- **kategorie:** MEDIUM
- **quelle:** ADR-0011 §Re-Evaluierungs-Trigger (dieselbe Schwelle, dort *feedforward, bis ein
  Slice den Sensor baut*) und ADR-0011 §Fitness Function (*„jede Zeile dieser Tabelle nennt einen
  Sensor, der **existiert**"*); `MR-025` Setzung 1; [`AGENTS.md`](../../AGENTS.md) §3.6
- **pfad:** `docs/plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md:241-243`
  (Annahme (c)), `:488-492` (Konsequenz), `:550-554` (Trigger), gegen `:504-534` (die acht
  Folgepflichten) und `:536-546` (die sechs Fitness-Function-Zeilen)
- **befund:** Annahme (c) sagt *„**Hier nicht gemessen** — die Messung ist **unten** geschuldet,
  und ihr Ausgang ist der Trennungs-Trigger."* Unten steht sie nicht. Die acht Folgepflichten
  nennen sie nicht; die Fitness Function führt sechs Zeilen, keine davon die Latenz — **vier** der
  sechs tragen ausdrücklich *„Geschuldet, nicht geliefert"* samt Make-Target, die Latenz hat weder
  Zeile noch Target noch Adressaten. Was „unten" auflöst, sind zwei Wiederholungen derselben
  Schuld (`:490`, `:550`). Zugleich ist der Trigger als *(feedback — eine Messung mit festgelegter
  Schwelle, kein Gefühl)* geführt. ADR-0011 führt **dieselbe** Schwelle als *(feedforward, bis ein
  Slice den Sensor baut)*, und der Sensor existiert nicht:
  `grep -niE 'latenz|latency|median|bench' Makefile harness/mk/*.mk` → leer (selbst gefahren), und
  ADR-0011s Fitness Function hat keine Latenz-Zeile (vollständig gelesen). Ein *feedback*-Trigger
  ohne Sensor ist eine Beobachtung, die niemand macht. ADR-0011s Geschichte hält dieselbe
  Fehlerklasse als bereits einmal korrigiert fest (*„Quadranten-Korrektur (zwei Trigger waren
  fälschlich *feedback*)"*).
- **gegenbeispiel:** ADR-0022 wird angenommen und ist nach §3.4 eingefroren. Der Hook startet je
  Tool-Call das volle Produkt-Binär. Nichts im Repo macht die Messung fällig — kein Target, keine
  Folgepflicht, kein Fitness-Function-Zahn —, also feuert der Trennungs-Trigger nie, und die
  benannte Antwort (Alternative F) wird nie ausgelöst. `make gates` bleibt dabei durchgehend grün;
  genau das ist der Punkt.
- **verifizierbar:** ja — die drei Kommandos oben; `make gates` (selbst gefahren, Exit 0) belegt
  die Abwesenheit des Sensors, nicht seine Existenz.

### LOW-1 — „Festlegung 6 trägt jetzt die unbedingte statt der Nicht-Emission" schreibt einer Festlegung eine tragende Wirkung zu, die sie nicht hat

- **kategorie:** LOW
- **quelle:** ADR-0020 Festlegung 6; [`AGENTS.md`](../../AGENTS.md) §3.4
- **pfad:** `docs/plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md:93-96` und
  dieselbe Aussage in der ADR-0022-Zeile von `docs/plan/adr/README.md` — **zwei** Fundorte, beide
  lebend
- **befund:** **Die Umdeutung selbst hält, und das ist an der Quelle belegt.** ADR-0020
  Festlegung 6 (`:629-650`, vollständig gelesen) entscheidet eine Verbots-Aussage über die
  **konditionale** Form (*„Die Erfassung wird auch nicht KONDITIONAL emittiert"*), und ihr Befund
  ist *„Der Prüfbereich der Telemetrie existiert in jedem Ziel … Eine strukturelle Bedingung, die
  die Ziele trennte, gibt es nicht."* Beides überlebt den Fall von Festlegung 1 unverändert, und
  zusammen mit einer Emission ergibt es eine unbedingte. Nicht gedeckt ist die **Lastverteilung**:
  Festlegung 6 hat die Nicht-Emission nie getragen — das tat Festlegung 1 —, und sie trägt auch die
  Unbedingtheit nicht. Die trägt Festlegung 1 dieser ADR selbst (`:261` *„Geltungsbereich: die
  emittierte Ebene, **jede** Bootstrap-Variante"*). Wer später prüft, worauf die Unbedingtheit
  ruht, wird auf eine fremde, eingefrorene Festlegung verwiesen, die sie nicht ausspricht.
- **verifizierbar:** ja am Quellenabgleich; kein Gate.

### LOW-2 — Der einzige Regelwerks-Verweis der ADR trägt keinen der vier Formteile, und der Bezug-Block kündigt Belege an, die es nicht gibt

- **kategorie:** LOW
- **quelle:** ADR-0016 Festlegung 2 (*Tag · Regelwerks-Dateiname und Abschnittsname · Zitat
  verbatim*) und Festlegung 3(a) (*„Bevor der Status eines ADR auf Accepted wechselt, werden seine
  Baseline-Belege in die Form aus Festlegung 2 gebracht"*)
- **pfad:** `docs/plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md:50-51`
  (Ankündigung), `:311` (der Verweis)
- **befund:** Der Bezug-Block nennt ADR-0016 als *„die Form der Regelwerks-Belege **unten**: Tag,
  Dateiname, Abschnitt, Zitat"*. Unten steht genau **ein** Regelwerks-Verweis — `:311`, *„eine
  generische, aus Dogfood und **Kurs-Modul 8** abgeleitete Fassung"* — und er trägt keinen der vier
  Teile: keinen Tag, nicht `modul-08-agentenrollen.md`, keinen Abschnittsnamen, kein Zitat
  (`grep -n 'regelwerk\|modul-[0-9]\|v3\.5\|Kurs-Modul\|Modul [0-9]'` über die ADR → sechs Zeilen,
  fünf davon Lastenheft-/ADR-Bezüge, selbst gefahren). Träger (a) von ADR-0016 bindet genau den
  Accept-Übergang; danach kostet dieselbe Zeile eine Folge-ADR. **Wiederkehrende Klasse:**
  `docs/reviews/2026-08-22-adr-0021-bestaetigungsrunde.md` LOW-1 meldete sie an derselben Stelle
  der Vorgänger-ADR.
- **verifizierbar:** ja — das `grep` oben; kein Gate (`ids` nimmt nur `docs/reviews/**` und
  `CHANGELOG.md` aus und prüft ohnehin keine Regelwerks-Kennungen).

### LOW-3 — Folgepflicht 8 beschreibt nur einen der zwei Kommentare, die sie nachziehen soll

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7 (*„Ein Kommentar beschreibt, was da ist"*), von
  der Folgepflicht selbst als Grund genannt
- **pfad:** `docs/plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md:531-534` gegen
  `Dockerfile:84-93` (span-Stage) und `Dockerfile:101-109` (report-Stage)
- **befund:** Folgepflicht 8 sagt *„Sie nennen als Entscheidungs-Ort einen Plan-Schnitt"*. Der
  span-Stage-Kommentar tut das (*„entscheidet slice-062"*, selbst gelesen). Der
  report-Stage-Kommentar tut es **nicht** — er begründet die Trennung ohne Plan-Schnitt (*„kein
  Subkommando des Produkt-Binaries, sonst landete die Entscheidung ueber eine emittierte Auswertung
  beim Adopter, bevor sie getroffen ist"*) und trägt zusätzlich einen Satz, den Festlegung 2
  eigenständig falsch macht: *„Ein Host-Binary waere ein Artefakt ohne Leser"* — die Auswertung
  wechselt mit `:305-306` auf den Host und bekommt im Ziel genau einen Leser. Wer Folgepflicht 8
  über ihr Erkennungsmerkmal abarbeitet, findet die zweite Stelle nicht.
- **verifizierbar:** ja — beide Dockerfile-Abschnitte gelesen; `make comment-claims` prüft die
  Existenz eines genannten Sensors, nicht den Gegenstand eines Kommentars (§3.7 letzter Absatz).

### LOW-4 — Eine Fitness-Function-Zeile über einem Artefakt, das es noch nicht gibt, trägt als einzige neue keinen Schuld-Vermerk

- **kategorie:** LOW
- **quelle:** `LH-QA-01`; ADR-0011 §Fitness Function (*„jede Zeile dieser Tabelle nennt einen
  Sensor, der **existiert**"*)
- **pfad:** `docs/plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md:544`
- **befund:** Zeile 5 (*„Die Feldliste im Ziel ist der Ausdruck des Trägers"*, Target `make test`)
  trägt keinen Vermerk, während vier der sechs Zeilen ausdrücklich *„Geschuldet, nicht geliefert"*
  führen. Das emittierte Dokument entsteht erst mit Festlegung 7, und ein Sensor darüber existiert
  nicht: `grep -rln 'Feldliste' internal/emit/*.go` → leer (Exit 1, selbst gefahren). Die
  Nachbarzeile `:542` zeigt, dass die ADR die Unterscheidung führen kann — sie sagt für die
  fail-open-Zähne ausdrücklich *„Die Zähne existieren, sie hängen am alten Programm"*, und das ist
  am Bestand belegt (`ls test/mutations/` führt u. a. `107-span-klemme-entfernt.sh`,
  `112-span-stdout-geschwaetzig.sh`).
- **verifizierbar:** ja — die zwei Kommandos oben.

### LOW-5 — Eine Zahl tritt an drei Fundorten als Beleg auf und trägt an keinem ihr Kommando

- **kategorie:** LOW
- **quelle:** `MR-025` Setzung 1 (*„Eine Zahl, die als Messwert auftritt — Erwartungswert,
  Bruch-Kriterium, **Beleg** —, trägt im selben Absatz das Kommando, das genau sie ausgibt"*)
- **pfad:** `docs/plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md:303-304`,
  `:477` (Pro-Spalte G), `:504-505` (Folgepflicht 1)
- **befund:** *„zwei Bau-Stufen und ein Make-Ziel entfallen"* trägt die Aussage *„Der Umbau
  schrumpft die Konstruktion, statt sie zu vergrößern"* und tritt damit als Beleg auf; an allen
  drei Fundorten steht kein Kommando. Nachgefahren stimmt die Zahl —
  `grep -nE '^FROM .* AS ' Dockerfile` → acht Stufen, davon `span` (`:94`) und `report` (`:110`) —,
  aber ein Leser muss sie selbst rekonstruieren. Die ADR führt ihre übrigen Zahlen mustergültig
  (`:227` `ls -1 .claude/agents/ | wc -l` → 6, `:228` `grep -rn "claude/agents" --include=*.go . | wc -l`
  → 0, `:198` `grep -n 'artifact-copy' Makefile` → drei Aufrufstellen; alle drei selbst nachgefahren
  und bestätigt), was den Ausreißer sichtbar macht.
- **verifizierbar:** ja — `grep -nE '^FROM .* AS ' Dockerfile`; kein Gate (`MR-025` liegt
  ausdrücklich im Feedforward-Quadranten).

### INFO-1 — Kursivsatz trägt an drei Stellen eine Paraphrase in der Form, die er sonst für Verbatim-Zitate führt

- **kategorie:** INFO
- **quelle:** ADR-0016 Festlegung 2 (*Zitat verbatim*); die Gegenprobe wurde über alle Zitate
  gefahren
- **pfad:** `docs/plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md:45-46`
  (ADR-0012), `:85-87` (ADR-0020 Fitness-Function-Zeile), `:409-410` (`LH-FA-10`)
- **befund:** Die Verbatim-Gegenprobe über sämtliche wörtlichen Zitate der ADR gegen ihre
  Quellen (von Hand ausgezählt, jedes einzeln gefahren) ist bis auf drei Stellen sauber (Whitespace normalisiert, Kommentar-Präfixe gestrippt; `grep -qF` als Here-String,
  nie über eine Pipe). Die drei: `:45-46` gibt ADR-0012 als *jede Bilanz aus diesen Spans nennt
  ihren Nenner* wieder — die Quelle schreibt *„Jede Token-Bilanz aus diesen Spans ist eine Bilanz
  über SUBAGENTEN-Läufe und nennt ihren Nenner"*, der tragende Qualifier fehlt. `:85-87` gibt die
  zweite Fitness-Function-Zeile von ADR-0020 als *je ein Wächter über der Abwesenheit von
  `.claude/agents/`, Span-Emitter und Token-Bericht im Ziel* wieder; die Quelle (`:737`) formuliert
  anders. `:409-410` zitiert `LH-FA-10` wortgleich, verschiebt aber die Auszeichnung (Quelle: *„Eine
  **automatische Rotation ist nicht Teil der Zusage**"*). Alle drei stehen in derselben
  Kursiv-Form, die dieselbe ADR an über zwanzig Stellen für Verbatim führt und dort auch einlöst
  (`:275` `LH-QA-02`, `:299` ADR-0011 Festlegung 6, `:475` ADR-0003 — je verbatim geprüft).
- **verifizierbar:** ja — die Gegenprobe ist als Skript reproduzierbar (Normalisierung: Zeilenumbruch
  → Leerzeichen, Mehrfach-Whitespace kollabiert).

### INFO-2 — Die offene Frage, die Festlegung 7 beantwortet, steht in ADR-0013 nicht in der zugeschriebenen Folgepflicht

- **kategorie:** INFO
- **quelle:** ADR-0013 Folgepflicht 3 und §Re-Evaluierungs-Trigger
- **pfad:** `docs/plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md:47-49` und
  `:420-423` gegen `docs/plan/adr/0013-technik-stratum-als-zielort.md:153-158` und `:202-204`
- **befund:** ADR-0022 sagt, ADR-0013s *„Folgepflicht 3 fragt nach dem Zielort der Feldtabelle im
  Zielrepo"* und Festlegung 7 beantworte sie mit **Nein**. Folgepflicht 3 fragt nichts — sie stellt
  fest: *„die emittierte Ebene bleibt unberührt … An der Emission ändert sich **nichts**."* Die
  Frage steht im Re-Evaluierungs-Trigger derselben ADR (*„Wenn Spans emittiert werden … dann ist zu
  entscheiden, ob das Zielrepo die Feldtabelle in seinem Technik-Stratum mitbekommt. Folgepflicht 3
  hält die heutige Antwort fest, nicht die künftige."*). Die **Sache** ist damit richtig getroffen
  und der Trigger korrekt ausgelöst; nur die Adresse zeigt daneben.
- **verifizierbar:** ja — beide Stellen gelesen.

### INFO-3 — Die konvergente Klasse bekommt erstmals ein Artefakt, dessen kanonischer Inhalt von einem Laufzeit-Ausgang abhängt

- **kategorie:** INFO
- **quelle:** ADR-0007 Festlegung 3 (*„konvergent … Re-Lauf schreibt die emittierten Dateien
  kanonisch ([`LH-QA-02`](../../spec/lastenheft.md) byte-identisch)"*)
- **pfad:** `docs/plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md:344`
- **befund:** Die Idempotenz-Tabelle führt `.claude/settings.json` als *konvergent (unverändert)*
  und setzt hinzu: *„ein Re-Lauf, der ihn nicht setzen kann, **entfernt** ihn, damit die
  Konfiguration die Wirklichkeit beschreibt"*. Damit hängt der kanonische Inhalt einer konvergenten
  Datei erstmals davon ab, ob eine Kopie zur Laufzeit gelingt; zwei Läufe derselben Tool-Version
  können verschiedene Bytes erzeugen. Die Konstruktion ist gewollt (sie trägt die
  `LH-QA-01`-Zusage aus Festlegung 5) und die Klassenzuordnung deckt sich mit ADR-0007
  (`.claude/settings.json` steht dort in der konvergenten Zeile, selbst gelesen) — die neue
  Eigenschaft der Klasse wird nur nirgends ausgesprochen.
- **verifizierbar:** ja — ADR-0007 Festlegung 3 samt Tabelle gelesen.

### INFO-4 — Die von ADR-0020 Folgepflicht 1 genannte Reihenfolge wird umgekehrt, und das steht nicht dabei

- **kategorie:** INFO
- **quelle:** ADR-0020 Folgepflicht 1 (*„die Reihenfolge *Erprobung → Entscheidung → Emission*, die
  derselbe Wellen-Plan zieht"*)
- **pfad:** `docs/plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md:97-99`,
  `:290-301`, `:504-507`
- **befund:** ADR-0022 entscheidet einen Einstiegspunkt, den der Dogfood heute nicht fährt, und
  ordnet die Erprobung als eigene Folgepflicht 1 **nach** der Entscheidung an. Die Sache aus
  ADR-0020 Folgepflicht 1 ist damit eingelöst — *„der Beleg emittiert nichts, was der Dogfood nicht
  selbst fährt"* bindet die **Emission**, und die Emission kommt nach dem Nachzug (`:506-507`
  spricht es aus). Die daneben genannte Reihenfolge der ersten zwei Glieder ist aber invertiert,
  und die ADR sagt es nicht.
- **verifizierbar:** ja — ADR-0020 `:694-697` gelesen.

---

## Negativbefunde

Eine Zeile je betrachtetem Bereich — ohne diesen Block ist „keine Findings" nicht von „nicht
geprüft" zu unterscheiden.

- **geprüft, ohne Befund — ADR-0020 ist unangetastet (§3.4), gemessen statt angenommen:** die Blobs
  von `docs/plan/adr/0020-emittierte-modul-15-regeln.md` in `c4145a2` und `c4145a2^` sind identisch
  (`git rev-parse c4145a2^:… ` und `git rev-parse c4145a2:… ` → beide
  `1bf3152efdc3ae11ae7c89e92a6d5174a8f536f2`). Der Commit berührt zwei Dateien
  (`git show --name-only`), keine davon eine *Accepted* ADR-Datei.
- **geprüft, ohne Befund — §3.8:** der Commit trägt ausschließlich Architect-Artefakte (die neue
  ADR und `docs/plan/adr/README.md`, beide unter dem Pathspec, den §3.8 selbst als Architect-Fläche
  misst) und nennt die Rolle in der ersten Zeile der Message.
- **geprüft, ohne Befund — die Index-Annotation an ADR-0020 folgt der dort geübten Form:** die
  Status-Spalte des Index vollständig gelesen; das Muster *„Accepted (§… — … — revidiert durch
  [ADR-XXXX]; … gilt fort)"* steht an ADR-0004 (durch ADR-0006), ADR-0008 (durch ADR-0009) und
  ADR-0011 (durch ADR-0013). Die neue Annotation trägt Abschnitt, Umfang, revidierendes Artefakt
  und Fortgeltung in derselben Reihenfolge und **zusätzlich** die Kennzeichnung *„Teil-Revision
  **vorgeschlagen** … dort *Proposed*; bis zu deren Annahme gilt diese Entscheidung unverändert"* —
  strenger als die geübte Form, nicht schwächer. Einziger Nebenpunkt: Folgepflicht 7 (`:527-530`)
  sagt, der Index bekomme die Annotation an der abgelösten Entscheidung *„bei der Annahme"* und
  *„bis dahin"* nur die eigene Zeile; der Commit setzt bereits eine (interims-)Annotation. Weil sie
  ausdrücklich nichts als vollzogen ausweist, ist der Zweck der Folgepflicht gewahrt — der Zustand
  der Folgepflicht ist dadurch nur nicht mehr am Index ablesbar.
- **geprüft, ohne Befund — keine Slice-IDs in ADR oder Index-Zeile:**
  `grep -n 'slice-[0-9]\|welle-[0-9]'` über die ADR → leer; dieselbe Suche über die neue
  Index-Zeile → leer. Folgepflicht 5 spricht vom *„Wellen-Plan der Träger-Aussage"* über seine
  Eigenschaft statt über seine Adresse — genau die Form, die frühere Runden eingefordert haben.
- **geprüft, ohne Befund — kein Verweis auf eine superseded ADR:** die acht referenzierten ADRs
  tragen im Index alle *Accepted*; ADR-0001 und ADR-0002 (die beiden *Superseded*) kommen in der
  ADR nicht vor.
- **geprüft, ohne Befund — die Einlösung von ADR-0020 Folgepflicht 1, am Repo gemessen:** die zwei
  Behauptungen über den Dogfood halten. `grep -n '^gates:' Makefile` → `gates: baseline-verify
  docs-check lint build test shell-lint ci-lint comment-claims span-emit-build span-check
  record-gates`, also Erfassung und Prüfung in der Prerequisite-Kette.
  `grep -n 'artifact-copy' Makefile` → drei Aufrufstellen (`:73`, `:100`, `:234`), und die dritte
  liegt im Rezept von `span-emit-build` (Target `:230`). Der `Dockerfile`-Kommentar **stützt** die
  Entscheidung, statt ihr entgegenzustehen: er begründet die Trennung damit, dass *„ein Subkommando
  … diese Entscheidung vorweggenommen"* hätte — mit der Entscheidung entfällt sein Anlass, und
  Folgepflicht 8 ordnet den Nachzug an (Einschränkung siehe LOW-3). Das zitierte Fragment ist
  verbatim (`grep -qF` als Here-String nach Strip der `# `-Präfixe).
- **geprüft, ohne Befund — die Umdeutung von ADR-0020 Festlegung 6 ist vom Wortlaut gedeckt:** die
  Festlegung vollständig gelesen (`:629-650`). Ihr normativer Gehalt ist ein Verbot der
  konditionalen Form, ihr Befund *„Der Prüfbereich der Telemetrie existiert in jedem Ziel"* stützt
  die Unbedingtheit ebenso wie zuvor den Ausschluss von *„nur für manche"*, und ihr zweites
  Argument (*„Der Preis wäre zudem ein Vertrag, kein Handgriff … ein fremder Quellbaum samt
  Bauschritt und Aktualisierungsweg"*) wird von Alternative C der neuen ADR ausdrücklich
  fortgeführt. Es ist **keine** verkappte Revision; der Befund beschränkt sich auf die
  Lastverteilung (LOW-1).
- **geprüft, ohne Befund — die Supersedes-Grenze an Festlegung 3, soweit sie ADR-0020 betrifft:**
  ADR-0020 Festlegung 3 hängt ausdrücklich an einer Konjunktion aus Erfassungs- und Zähler-Glied
  (*„Die Bedingung für eine Emission ist damit **konjunktiv**"*), und nur das Erfassungs-Glied ruht
  auf Festlegung 1 (*„ein Ziel, das nicht erfasst, hat nichts zu verrechnen"*). Der Schnitt ist an
  der Quelle korrekt gezogen. Was aus dem Bruch der Konjunktion **für die emittierte Ebene** folgt,
  trägt HIGH-1.
- **geprüft, ohne Befund — die Abzählung der Wege:** die ADR führt sie über ein Kriterium statt über
  eine Zahl (*Herkunft des ausführbaren Bildes zur Bootstrap-Zeit*), und keine frühere Zählung ist
  importiert. Die Klassen *liegt vor · entsteht im Ziel · wird geholt · keines* sind als
  Existenz-mal-Ort-Partition erschöpfend; jede der sieben Zeilen der Tabelle fällt in genau eine.
  ADR-0020s Formulierung *„von den fünf abgezählten Ausgängen"* wird nirgends übernommen.
- **geprüft, ohne Befund — der ungemessene Punkt an Alternative E liegt neben der Beweisführung:**
  `:475` sagt *„ob `docker create` über ein Bild fremder Architektur trägt, ist hier
  **ungemessen**"* — als Kennzeichnung, nicht als Grund. E scheitert unabhängig und zweifach: am
  eigenen OCI-Image als Vertriebsmittel gegen ADR-0003 (dessen Begründung *„native Binaries sind
  bereits plattformübergreifend"* verbatim geprüft) und daran, dass das Bild eines Standes nicht
  von dem Stand erzeugt werden kann, der es verbraucht. Der ungemessene Punkt trägt die Ablehnung
  nicht und ist als ungemessen ausgewiesen — die Form, die `AGENTS.md` §3.6 verlangt.
- **geprüft, ohne Befund — die vier Mess-Kommandos der ADR sind selbst nachgefahren und stimmen:**
  `ls -1 .claude/agents/ | wc -l` → **6**; `grep -rn "claude/agents" --include=*.go . | wc -l` →
  **0**; `sed -n '42,44p' harness/tools/artifact-copy.sh` liefert exakt die drei zitierten Zeilen;
  `sed -n '182,189p' internal/span/emit.go` liefert `roleFromAgentType` mit genau den sechs
  zitierten Rollennamen.
- **geprüft, ohne Befund — die Aussagen über den Emissions-Pfad:** `.harness/.gitignore` mit
  `state/` wird emittiert (`internal/emit/enforce.go:47` und der Template-Inhalt, beide gelesen);
  die emittierte `.claude/settings.json` verdrahtet ihre Hooks über `$CLAUDE_PROJECT_DIR`
  (zwei Vorkommen); die emittierte `.d-check.yml` fährt `modules: [links, anchors]` über
  `roots: ["."]` mit `ignore: [… ".harness/**"]`, `.claude/agents/` liegt also im geprüften
  Bereich und `.harness/**` außerhalb — beide Aussagen der Festlegungen 3 und 7 halten. Der
  Abwesenheits-Wächter in `internal/emit/enforce_test.go` existiert in der beschriebenen Gestalt
  (`os.Stat` + `!os.IsNotExist` + `t.Errorf`, `:55-56`).
- **geprüft, ohne Befund — `MR-017` ist korrekt abgegrenzt:** sein Geltungsbereich (*„jeder
  Prüfbereich, dessen Schärfe wir für unbekannte Nutzer festlegen"*) deckt eine
  Träger-Aufhängung nicht, und ADR-0020 Festlegung 5(b) zieht dieselbe Grenze (*„Er entscheidet
  die **Schärfe eines emittierten Prüfbereichs** … nicht den **Lebenszyklus seines Trägers**"*).
- **geprüft, ohne Befund — `LH-FA-06` wächst nicht:** `LH-FA-10` §Abgrenzung stellt sich selbst
  additiv gegen `LH-FA-06`, `LH-FA-08` und `LH-FA-09` (*„Der **Beleg eines gelaufenen Prozesses**
  fällt in keine der drei"*), und die Historie-Zeile 0.19.0 sagt es noch einmal. Die Behauptung der
  ADR ist an der Quelle gedeckt.
- **geprüft, ohne Befund — ADR-0011 Festlegung 5 ist korrekt eingelöst:** *„**Wird emittiert,
  gelten die Festlegungen 1–4 und 6 unverändert**"* verbatim, und die vier eigenständigen Stücke
  von Festlegung 6 der neuen ADR treffen: die Feldlisten-Lesbarkeit, das Aufräum-Kommando
  (Quelle: *„ein `make`-Ziel, kein Automatismus"* in ADR-0011 Festlegung 3, `:169`), die
  Nicht-Zusage über den Bestand (ADR-0011 Festlegung 2 führt *„Die emittierte Ebene"* tatsächlich
  als **dritten** Grund) und die Rollen-Typen samt Auswertung.
- **geprüft, ohne Befund — die zwei zitierten Re-Evaluierungs-Trigger von ADR-0020 sind verbatim
  und richtig eingeordnet:** keiner der drei Ausgänge, die ADR-0020 *„in unserer Hand"* nennt
  (ADR-0011 Festlegungen 6, 2 und 4), wird von ADR-0022 umgestoßen. Nebenpunkt ohne Finding-Rang:
  der erste Trigger ist *feedforward — an einem frisch gebootstrappten Ziel ablesbar*, und diese
  Bedingung ist heute nicht erfüllt (`git grep -ln 'span-emit\|span-report\|spawned_role' --
  internal/emit/` → leer, Exit 1). Die Revision trägt ohnehin nicht der Trigger, sondern `LH-FA-10`
  auf Rang 1 — und genau das sagt die ADR selbst.
- **geprüft, ohne Befund — die beiden Gate-Zahlen der Commit-Message:** selbst gefahren,
  `make docs-check` → 351/0, Exit 0; `make gates` → Exit 0. Die ADR-Änderung erzeugt keinen
  Doku-Gate-Befund, und die Datei-Zahl ist in der Message korrekt als nicht-Erwartungswert nach
  `MR-025` Setzung 2 gekennzeichnet.
- **gesucht, nicht getroffen — *Adresse statt Eigenschaft*:** die aus früheren Runden bekannte
  Klasse liegt hier nicht vor (siehe Negativbefund zu den Slice-IDs); der Befund aus der
  Commit-Message über einen Inline-Pfad `harness/mk/` ist im Text nicht mehr auffindbar
  (`grep -n 'harness/mk' ` über die ADR → leer).

---

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 1 |
| MEDIUM | 2 |
| LOW | 5 |
| INFO | 4 |

## Verdikt

**Nicht frei für die Annahme — blockiert.**

Ein HIGH und zwei MEDIUM stehen offen; nach dem Reviewer-Skill blockieren beide Kategorien
typischerweise, und hier kommt der Grund hinzu, der diese Runde trägt: ab *Accepted* ist der Text
nach [`AGENTS.md`](../../AGENTS.md) §3.4 unerreichbar, und jede der drei Stellen kostet danach eine
Folge-ADR statt einer Zeile.

**Was zu ändern ist, damit die Sperre fällt:**

1. **HIGH-1.** Festlegung 8 muss sagen, was ADR-0021 sagt, oder ausweisen, dass sie es revidiert.
   Beide Wege sind offen und beide sind Architect-Arbeit: entweder die Aussage über die emittierte
   Ebene wird auf ADR-0021 Folgepflicht 6 ausgerichtet und die dort verlangte **Nennung** der
   Grenze im Ziel benannt — dann ist auch der Re-Evaluierungs-Trigger `:556` neu zu fassen, denn
   ein Adopter-Bestand mit Zählern widerspräche sehr wohl etwas —, oder die Abweichung wird als
   Teil-Revision von ADR-0021 in den Revidiert-Block aufgenommen und dort mit einem Grund versehen,
   der ADR-0021s Feststellung *„keine Eigenschaft unseres Aufbaus, sondern der Mechanik"*
   entgegentritt. Die Zuschreibung *„ihre Permanenz ruht auf der committeten Berechtigungs-Lage
   dieses Repos"* hält in keinem der beiden Fälle: sie steht so in ADR-0021 nicht.
2. **MEDIUM-1.** Der tragende Grund von Festlegung 1 ist auf das einzuschränken, was der Lauf
   belegt, und die Index-Zeile ist von der Einzigkeits-Aussage zu befreien — oder die Menge ist zu
   belegen, was die Alternative-F-Zeile derselben ADR heute verhindert.
3. **MEDIUM-2.** Die geschuldete Latenz-Messung braucht eine Adresse: eine Folgepflicht, eine
   Fitness-Function-Zeile mit Make-Target oder ein benanntes Mess-Kommando — und der Trigger
   gehört in den Quadranten, in dem ADR-0011 dieselbe Schwelle führt, solange kein Sensor existiert.

Die fünf LOW und vier INFO blockieren nicht; LOW-2 sollte trotzdem vor dem Accept fallen, weil
ADR-0016 Festlegung 3(a) genau diesen Übergang bindet und der Preis danach von einer Zeile auf
eine Folge-ADR steigt.

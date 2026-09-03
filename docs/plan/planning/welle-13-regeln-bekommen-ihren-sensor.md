# Welle welle-13: Fünf Regeln, die nur im Feedforward-Quadranten leben, bekommen ihren Sensor

**Lifecycle:** Die aktive Welle liegt flach unter `docs/plan/planning/`; bei
Closure wandert diese Datei per `git mv` nach `done/` (neben ihre
`welle-<NN>-results.md`). Der Zustand ist die Verzeichnis-Position — kein
Status-Feld. Ob eine flache Welle *aktuell* oder *geplant* ist, sagt die Roadmap.

**Zielmeilenstein:** kein Meilenstein-Bezug. Die sechs bestehenden Meilensteine sind erreicht, und
M1–M6 tragen durchweg **Fähigkeiten des Werkzeugs**; diese Welle schließt eine **Qualitätslücke des
Dogfoods**. Einen Meilenstein dafür zu erfinden hieße, die Meilenstein-Achse umzudeuten, damit eine
Welle einen Eintrag bekommt.

**Verantwortlich:** Planner. **Datum:** 2026-08-28.

---

## 1. Welle-Ziel

**Fünf Regeln dieses Repos, die heute nur als Text existieren, tragen am Ende einen verdrahteten
Sensor — und keiner dieser Sensoren meldet grün, weil er nichts prüft.**

Die Welle ist der Schnitt-Vorschlag zu den Achsen **(1)–(4)** und **(6)** des Roadmap-Kandidaten
*Regeln ohne Feedback-Quadrant schließen*. Sie nimmt **nicht** den ganzen Kandidaten: dessen Achsen
(5), (7) und (8) sind Eigenbauten, (7) liegt außerhalb von git, und (1) ist bereits am 2026-07-28
nach [welle-09](welle-09-modul-15-konformitaet.md) eingefaltet worden. Was hier landet, ist die
Hälfte, die der Kandidat selbst als *„bereits bezahlt"* führt — vier Regelmodule im gepinnten
d-check-Image, dazu eine zweite Fähigkeit eines davon, die der Kandidat für einen Eigenbau hielt
(§6).

### Der Hebel, und wo er kleiner ist als angenommen

Der Kandidat sagt: *„Adoption heißt Trockenlauf + Config-Block + Verdrahtung, nicht Neubau."* Das
stimmt — und ist teurer, als der Satz klingt. **Gemessen gegen eine Kopie außerhalb des Repos**
(Stand `1f5741f`, netzlos, Mount `:ro`, Image `v0.65.0` per Digest):

1. **Drei der vier Module sind ohne eigenen Config-Block nachweislich inert, und ihr `doc-*`-Ziel
   meldet dabei grün.** Nachweislich heißt: derselbe Baum trägt **mit** Config-Block Befunde und
   **ohne** ihn Exit 0. Der schärfste Beleg ist `targets`: mit einem angehängten Phantom-Gate in
   [`AGENTS.md`](../../../AGENTS.md) und **ohne** `targets:`-Block antwortet die Flag-Kombination aus
   [`d-check.mk`](../../../d-check.mk) `d-check: 425 Datei(en) geprüft, 0 Befund(e)`, Exit 0. Derselbe
   Baum **mit** Block: **21 Befunde**.
   **Für `vcs` brauchte der Nachweis eine zweite Runde, und sie liegt vor.** Der Lauf blieb in
   **vier** Formen grün, auch **mit** Config-Block und über einer Range mit einer Kern-Änderung an
   einer `Accepted`-ADR — weil die Probe den Satz **ans Dateiende** hängte und damit in
   `## Geschichte`, den der Default-Block über `exclude-sections` aus dem Kern nimmt. Derselbe Satz
   in `## Entscheidung` meldet `core-drift-vcs`, Exit 1
   ([slice-127](open/slice-127-adr-immutabilitaet-hat-einen-sensor.md) §1 führt beide Läufe).
   **Damit ist keines der vier Module ohne Rot**, und der Carveout-Pfad aus §3 wird für `vcs` nicht
   gebraucht.
2. **Die Adoptions-Schuld ist real und je Modul verschieden** — jede Zahl aus dem Lauf des jeweiligen
   `doc-*`-Ziels mit gesetztem Config-Block über den **unveränderten** Baum:
   `targets` → **21** (19 × `gate-undocumented`, 2 × `gate-phantom`);
   `planning` → **1** (`planning-drift` auf [`roadmap.md`](in-progress/roadmap.md) Zeile 13);
   `planning` mit der `waves`-Fähigkeit → **3** (zusätzlich `wave-drift` und `wave-preview-exists`
   auf `welle-09`); `commits` über `--range HEAD~20..HEAD` → **2** (`commit-untraceable`);
   `vcs` → **0** über den unveränderten Baum, und das ist hier die richtige Zahl: das Modul urteilt
   über Commits, nicht über einen Bestand;
   `planning` mit der `closure`-Fähigkeit → **0** über die 86 Slice-Notizen des Ruheorts, **16**
   über alle 104 seiner Dateien (§6).
   **Alle diese Zahlen hängen an ihrem Stand und sind keine Erwartungswerte** — der `planning`-Wert
   der Lifecycle-Invariante etwa ist über `fccc627` **0**, weil `in-progress/` seit dem Start von
   welle-10 einen Slice trägt
   ([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
   Setzung 2; der erste Schritt jeder Umsetzung ist, sie neu zu fahren).
3. **Der Trockenlauf ist nicht geteilt.** Jedes Modul brauchte seinen eigenen Lauf mit seiner eigenen
   Config; der Pin-Trockenlauf aus
   [slice-122](done/slice-122-d-check-pin-v0650.md) fährt die sechs **aktiven** Module und sagt über
   die vier Kandidaten nichts. Genau deshalb liegt der Pin **nicht** in dieser Welle.
4. **Zwei der vier sind in CI blind.** `grep -c 'fetch-depth' .github/workflows/ci.yml` → **0** bei
   vier `actions/checkout`-Zeilen (repo-weit sieben). Voreinstellung ist Tiefe **1**; ein
   history-lesendes Modul wäre dort **blind und grün** — die stille-Grün-Klasse aus
   [`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
   Setzung 3.

### Warum das eine Welle ist und keine Reihe von Wartungs-Slices

Gegen [`MR-016`](../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1 geprüft, alle drei Fragen beantwortet:

1. **Bündel?** **Ja.** Die Aussage *„die gemessenen Regeln ohne Feedback-Quadrant sind geschlossen"*
   wird von keinem einzelnen Slice wahr; jeder deckt genau eine Achse, und die Klasse ist die
   Einheit, in der sie gemessen wurde (sechsmal an einem Tag, Drift-Log 2026-07-26).
2. **Gemeinsames Closure-Kriterium?** **Ja**, und es unterscheidet sich von jeder Einzel-DoD: **kein
   `doc-*`-Ziel dieses Repos meldet mehr grün über einem Modul ohne Config-Block, ohne das zu
   sagen.** Das ist erst wahr, wenn alle vier Blöcke stehen **und** die verbleibenden sieben Ziele
   ihre Inertheit ausweisen — eine Aussage über die **Menge** der Ziele, die kein Slice allein
   trifft (§3).
3. **Auslöser reaktiv oder gewollt?** **Gewollt.** Kein Sensor hat gefeuert und kein Pin ist
   veraltet; hier wird eine Fähigkeit erworben, die das Repo bisher nicht hatte — Frage 3 nennt
   genau das als Wellen-Kriterium, *„auch wenn es zunächst nach einem Slice aussieht"*.

## 2. Trigger (Welle startet)

- **[slice-122](done/slice-122-d-check-pin-v0650.md) liegt in `done/`.** Beobachtbar ohne Rückfrage:
  `ls docs/plan/planning/done/slice-122-*.md`. Der Grund ist **tragend, nicht ordnend** — die
  Adoptions-Entscheidungen dieser Welle werden gegen das Verhalten eines Moduls getroffen, und das
  Verhalten hängt an der Version. Alle Messungen in §1 sind bereits gegen `v0.65.0` gefahren; sie
  gegen `v0.62.0` zu verdrahten hieße, eine Config gegen ein Image zu schneiden, das im selben Zug
  ausgetauscht wird.
- **[welle-14](welle-14-re-baseline.md) liegt in `done/`.** Der Grund ist **tragend**, nicht bloß
  ordnend: Zwei Slices dieser Welle bauen Sensoren auf Formen, die jener Sprung bewegt — der
  Roadmap-/Verzeichnis-Wächter ([slice-125](open/slice-125-roadmap-und-verzeichnis-stimmen-ueberein.md))
  und der Closure-Notiz-Sensor ([slice-129](open/slice-129-closure-notiz-hat-einen-sensor.md)). Die
  Ziel-Fassung schiebt der Wellen-Closure einen Schritt ein, der die Zeitdokumente einer Welle nach
  `done/<welle-id>/` archiviert und an ihrer Stelle Stubs lässt (`v5.18.0`, `modul-06-roadmap.md`,
  §Wellen-Closure-Prozedur, Schritt 4); damit ändert sich, was `done/` enthält und was eine
  Closure-Notiz ist. Es ist derselbe Grund wie beim Pin darüber: eine Config gegen ein Artefakt zu
  schneiden, das im selben Zug ausgetauscht wird.

## 3. Closure-Trigger (Welle schließt)

- Alle sechs Slices liegen in `done/`.
- `make gates` grün — **mit** den neu aufgenommenen Modulen in der Modul-Liste, nicht daneben.
- **Jedes neu verdrahtete Modul ist einmal rot gesehen worden**, mit dem Kommando, das es rot
  färbt, im jeweiligen Umsetzungs-Commit ([`AGENTS.md`](../../../AGENTS.md) §3.6). **Ein Modul, für
  das kein Rot herstellbar ist, wird nicht verdrahtet, sondern als Carveout geführt** (Modul 7) —
  die Welle darf mit einem dokumentierten Carveout schließen, nie mit einem still grünen Modul.
- **Das welle-eigene Kriterium, das keine Slice-DoD abschreibt:** für **jedes** der zwölf
  `docs?-*`-Ziele in [`d-check.mk`](../../../d-check.mk) ist entschieden und aufgeschrieben, ob es
  einen Prüfbereich hat — und die Ziele, die weiterhin ohne Config-Block laufen, **sagen das in
  ihrer eigenen Ausgabe oder ihrem Hilfetext**. Heute melden sie „0 Befund(e)" und meinen „nichts
  geprüft"; nach der Welle darf das nicht mehr vorkommen, ohne benannt zu sein
  ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- Closure-Notiz in `done/welle-13-results.md` mit Steering-Loop-Eintrag.

## 4. Slices in dieser Welle

<!-- Zustand jedes Slice = sein Lifecycle-Verzeichnis (open/next/in-progress/
done), hier NICHT gespiegelt — eine Status-Spalte driftete gegen die
Verzeichnisse (dieselbe zweite Wahrheit, die beim Slice retired wurde). -->

| Slice | Titel | Bezug |
|---|---|---|
| [slice-123](open/slice-123-ci-sieht-die-historie.md) | CI sieht die Historie — oder der Lauf fällt, statt grün zu melden | [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) |
| [slice-124](open/slice-124-gate-tabelle-hat-einen-waechter.md) | Die Gate-Tabellen werden gegen das Makefile gehalten (Modul `targets`, Achse 1) | [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |
| [slice-125](open/slice-125-roadmap-und-verzeichnis-stimmen-ueberein.md) | Roadmap und Lifecycle-Verzeichnis widersprechen sich nicht mehr still (Modul `planning`, Achse 4) | [`MR-016`](../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird) |
| [slice-126](open/slice-126-commit-message-traegt-eine-kennung.md) | Eine Commit-Message ohne Kennung wird rot, und zwar vor dem Commit (Modul `commits`, Achse 3) | [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |
| [slice-127](open/slice-127-adr-immutabilitaet-hat-einen-sensor.md) | Hard Rule 3.4 bekommt ihren Sensor (Modul `vcs`, Achse 2) | [`AGENTS.md`](../../../AGENTS.md) §3.4 |
| [slice-129](open/slice-129-closure-notiz-hat-einen-sensor.md) | Die Closure-Notiz-Pflicht bekommt ihren Sensor (Modul `planning`, zweite Fähigkeit, Achse 6) | [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |

**Die Reihenfolge ist nicht beliebig, eine Kante ist hart und eine ist ein Ausschluss.**
[slice-123](open/slice-123-ci-sieht-die-historie.md) geht **[slice-126](open/slice-126-commit-message-traegt-eine-kennung.md)
und [slice-127](open/slice-127-adr-immutabilitaet-hat-einen-sensor.md) voraus**: beide lesen
Historie, und ohne die Range-Entscheidung aus 123 wären sie in CI blind und grün — ein fail-open
Sensor ist schlechter als keiner, weil er eine Zusage trägt. Die drei hermetischen
([slice-124](open/slice-124-gate-tabelle-hat-einen-waechter.md),
[slice-125](open/slice-125-roadmap-und-verzeichnis-stimmen-ueberein.md),
[slice-129](open/slice-129-closure-notiz-hat-einen-sensor.md)) hängen an nichts und können zuerst
laufen. **Nicht gleichzeitig laufen dürfen 125 und 129:** beide konfigurieren dasselbe Modul in
demselben Schlüsselbaum — die Reihenfolge ist frei, die Parallelität nicht.

**Warum sechs und nicht drei.** Der Roadmap-Kandidat schätzt *„zwei bis drei Slices"*. Die
Schätzung ist von vor der Messung: sie unterstellt, Adoption sei je Modul eine Config-Zeile. §1
Messung 2 zeigt vier verschiedene Adoptions-Schulden mit vier verschiedenen Entscheidungen, dazu
kommt die zweite Fähigkeit von `planning` (§6, Achse 6), und Modul 5 §Ziel-Form deckelt einen Slice
bei **drei** eigenen DoD-Punkten. Zwei Module in einen Slice zu legen ergäbe sechs — *„der Schnitt
ist falsch"*, nicht *„die DoD ist länger"*.

## 5. Abhängigkeiten

- **Wird blockiert von:** [slice-122](done/slice-122-d-check-pin-v0650.md) (Pin, tragend) und
  [welle-10](done/welle-10-re-baseline.md) (WIP, ordnend) — beide mit ihrer Begründung in §2.
- **Blockiert:** nichts. [welle-11](welle-11-traeger-aussage.md) hängt an
  [welle-10](done/welle-10-re-baseline.md), nicht an dieser Welle; die Reihung ist damit
  welle-10 → welle-11 **und** welle-10 → welle-13, ohne Kante zwischen 11 und 13.
- **Berührt, aber bindet nicht:** [slice-121](open/slice-121-commit-message-nennt-was-es-gibt.md)
  liegt **außerhalb** dieser Welle und bekommt aus
  [slice-126](open/slice-126-commit-message-traegt-eine-kennung.md) seinen **Träger**, nicht seine
  Eigenschaft (Begründung dort in §1).

## 6. Out-of-Scope für diese Welle

- **Die Achsen (5), (7) und (8) des Roadmap-Kandidaten.** (5) Co-Change um
  [`spec/lastenheft.md`](../../../spec/lastenheft.md), (7) veröffentlichte Artefakte außerhalb von
  git, (8) der DoD-Punkte-Zähler — alle drei sind **Eigenbauten**, keine Adoption. Sie bleiben als
  Kandidaten-Zeile in der Roadmap stehen.
- **Achse (6) ist es nicht — sie ist hier drin.** Die Closure-Notiz-Pflicht galt als vierter
  Eigenbau; das gepinnte Image liefert sie als **zweite Fähigkeit** des Moduls `planning` (opt-in
  über `closure.dir`), mit fünf eigenen Grund-Codes: `closure-note-missing`, `-thin`,
  `-boilerplate`, `-placeholder`, `-ambiguous`. Damit ist sie dieselbe Klasse wie die vier
  gemessenen Achsen — Trockenlauf, Config-Block, Verdrahtung — und liegt als
  [slice-129](open/slice-129-closure-notiz-hat-einen-sensor.md) in dieser Welle. **Ihre
  Adoptions-Schuld ist die kleinste der Welle und die Messung dazu die kürzeste:** über den
  86 Slice-Notizen in [`done/`](done) (`ls docs/plan/planning/done/slice-*.md | wc -l`) meldet der
  Lauf `0 Befund(e)`, Exit 0, und dieselbe Kopie mit **einer** auf einen Satz gekürzten Notiz
  meldet **1** × `closure-note-thin` — die Null ist gemessen, nicht leer. Über der **Welle**-Ebene
  (`glob: '*.md'`, alle 104 Dateien) sind es **16** Befunde, und die sind eine Struktur-Aussage
  über unsere zweiteilige Wellen-Closure, kein Rückstand (Einzelheiten in slice-129 §1).
  **Draußen bleibt von Achse (6) die Skill-Datei** `.harness/skills/closure-note-reviewer.md`
  (`ls .harness/skills/ | wc -l` → **1**, während
  `grep -c 'closure-note-reviewer' internal/emit/templates.go` → **1** sie in jedes Ziel-Repo
  emittiert) — eine Dogfood-Lücke ohne Gate-Charakter; sie bleibt beim Kandidaten.
- **Die zehn nicht adoptierten Module des Images — vollständig aufgezählt, nicht beispielhaft.**
  Das gepinnte Image führt **20** verfügbare Module
  (`--print-config`, dann `grep -m1 '^# Verfügbar:' | tr ',' '\n' | wc -l`),
  [`.d-check.yml`](../../../.d-check.yml) aktiviert **sechs**
  (`grep -m1 '^modules:' .d-check.yml | tr ',' '\n' | wc -l`), diese Welle nimmt **vier** (§4) —
  **zehn** bleiben draußen. Eine Liste, die nur einen Teil davon nennt, gibt eine Auswahl als
  Vollzähligkeit aus; darum stehen hier alle zehn.

  **Fünf liegen neben den gemessenen sechs Regeln:** `tracked`, `structure`, `citations`,
  `sources`, `external`. `tracked` ist der interessanteste Grenzfall — es berührt
  [slice-116](open/slice-116-doku-gate-urteilt-ueber-den-getrackten-bestand.md); die Klärung gehört
  dorthin und nicht hierher (§1 dieses Slice misst die Frage, diese Welle nicht).

  **Die anderen fünf bleiben mit gemessenem Grund draußen** — Kopie außerhalb des Repos aus
  `git archive aa32e1f`, netzlos, Mount `:ro`, Image `v0.65.0` per Digest, je ein Lauf
  `--enable <modul>` über den unveränderten Baum:

  - **`hostpaths` — das einzige der fünf, das heute rot führe.** Ohne jeden Config-Block:
    `435 Datei(en) geprüft, 22 Befund(e)`, Exit 1; **alle 22** liegen in `docs/reviews/**`, über
    **14** Dateien. Ausnehmen lässt es sich nicht: das Modul kennt laut `--print-config` allein
    `prefixes`, kein `exempt-paths`, und der Zeilen-Marker greift nicht — Marker auf eine gemeldete
    Zeile gesetzt: unverändert **22**; denselben Hostpfad aus derselben Zeile entfernt: **21**.
    Bliebe `scan.ignore` auf `docs/reviews/**` — das blendete die sechs aktiven Module auf demselben
    Baum mit aus, also eine Senkung und damit eine ADR
    ([`AGENTS.md`](../../../AGENTS.md) §3.5, s. den nächsten Punkt). Ein Modul, das rot führt und
    dessen Adoption an einer Senkung hängt, ist ein **eigener Kandidat**, kein Mitglied einer Welle,
    deren Identität die gemessenen Achsen des Kandidaten sind.
  - **`versions` — gemessen und als Wächter verworfen, nicht aufgeschoben.** Ohne Block
    `0 Befund(e)`. Mit einem Block auf den d-check-Pin (`pin-pattern` auf
    `ghcr\.io/pt9912/d-check:(v…)`, `current-from` auf einen eigens angelegten Markdown-Span) und
    den vom Tool vorgeschlagenen Zeitdokument-Ausnahmen ebenfalls **0**; ohne die Ausnahmen **19**,
    davon **1** in `done/` und **18** in `docs/reviews/**` — keiner in einem lebenden Artefakt.
    Entscheidend ist die Sonde: den gelebten Pin in [`d-check.mk`](../../../d-check.mk) auf
    `v0.11.0` gedreht → **`0 Befund(e)`**; dieselbe Zahl zusätzlich in
    [`AGENTS.md`](../../../AGENTS.md) → **1 Befund**, `version-stale`. Das Modul liest Markdown und
    ist damit **blind für die Datei, die den Pin trägt**; es hält Zweitfassungen gegen eine
    Markdown-Autorität. Eine solche Autorität neu anzulegen verschöbe die unbewachte Kante, statt
    sie zu schließen.
    **Der zweite Gegenstand — der Baseline-Tag — ist entschieden, und zwar dagegen.**
    [ADR-0023](../adr/0023-verweis-beschluss-traegt-ueber-den-sprung.md) Festlegung 3 verwirft das
    Modul als Wächter der **stillen Hälfte** jenes Verweis-Bestands, den
    [slice-080](done/slice-080-verweis-ueberlebt-tagwechsel.md) misst: das Modul urteilt
    über **Zeichenketten-Frische, nicht über Verweis-Auflösung** — ein Link **ins Leere** unter
    dem aktuellen Tag lässt es schweigen, eine Nennung, die niemand auflösen soll, färbt es rot —,
    es trennt Adresse, datierte Aussage und Operand nicht, und der autoritative Pin steht in einer
    Zeile, die es nicht liest (`grep -c '^BASELINE_TAG' Makefile` → **1**, kein Markdown).
    **Es wird darum auch nicht als Kandidat geführt**
    ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)) — ein
    Modul, das die falsche Eigenschaft misst, ist kein Wächter im Wartestand. Was die Entscheidung
    hinterlässt, ist kein Slice, sondern ein **Kriterium**: ein Sensor über einem `<tag>`-gescopten
    Bestand wird nur adoptiert, wenn er die drei Klassen an je einem Ist-Beleg trennt. Bestand,
    Kommandos und Status der Entscheidung stehen in der ADR und im
    [ADR-Index](../adr/README.md), nicht zusätzlich hier.
  - **`pins` und `immutable` — der Gegenstand muss erst geschrieben werden.** Beide melden ohne
    Block `0 Befund(e)`, und das ist keine Config-Lücke, sondern eine leere Marker-Menge:
    `git grep -c 'dpin: sha256:' -- '*.md' ':!.harness/baseline' | wc -l` → **0**, dasselbe mit
    `'immutable: sha256:'` → **0**. Adoption hieße, Marker von Hand zu setzen — dieselbe
    Eigenbau-Klasse wie die Achsen (5), (7) und (8) oben, nur mit geliefertem Prüfer.
    **`immutable` bleibt als benannter Ausweichpfad geführt:** ein absichtlich falscher
    `immutable: sha256:0000…`-Marker auf einer Accepted-ADR meldet **`core-drift`** — das
    hermetische Geschwister derselben Zusage, die
    [slice-127](open/slice-127-adr-immutabilitaet-hat-einen-sensor.md) über `vcs` trägt. Gebraucht
    wird es dort nicht: das Rot über die Range ist hergestellt (Messung 1). Der Hinweis steht in
    slice-127 §6 und ändert dessen Zuschnitt nicht.
  - **`diagrams` — bewacht eine Kennung.** Ohne Block `0 Befund(e)`; mit `fences: [mermaid]` und
    einem Muster auf die vierstellige ADR-Kennung ebenfalls **0**, und die Kontrolle färbt rot: die
    eine Kennung im Fence von [`roadmap.md`](in-progress/roadmap.md) Zeile 162 auf eine nicht
    vergebene Nummer gedreht → **1 Befund**, `diagram-id-undefined`.
    Gegenstand ist **genau eine** Kennung in **einem** der **vier** mermaid-Fences dieses Repos
    (`git grep -c 'mermaid$' -- '*.md' ':!.harness/baseline'` → `roadmap.md:1`, `architecture.md:3`);
    `defined-in` muss zudem eine **Datei** sein — ein Verzeichnis quittiert das Tool mit
    `diagrams.patterns[0].defined-in ist keine Datei`, der Wächter liefe also gegen den ADR-Index
    statt gegen die ADR-Dateien. Kein Bündel-Bezug und kein Schuldenstand: S-Kandidat für die
    Doc-Gate-Härtungs-Zeile der Roadmap.
- **Jede Senkung einer bestehenden Schwelle.** Diese Welle **hebt** nur
  ([`MR-001`](../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids):
  Anheben → Steering-Loop). Stellt sich in einem Slice heraus, dass die Adoption nur durch eine
  Lockerung woanders grün wird, ist das ein ADR und damit ein Rückführungs-Grund, kein Zwischenschritt.
- **Der Pin selbst** ([slice-122](done/slice-122-d-check-pin-v0650.md)) — Trigger, nicht Mitglied.

## 7. Closure-Notiz

<!-- Erst nach Welle-Abschluss füllen. Verweis auf done/welle-13-results.md. -->

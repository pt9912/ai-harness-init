# Welle welle-13: Vier Regeln, die nur im Feedforward-Quadranten leben, bekommen ihren Sensor

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

**Vier Regeln dieses Repos, die heute nur als Text existieren, tragen am Ende einen verdrahteten
Sensor — und keiner dieser Sensoren meldet grün, weil er nichts prüft.**

Die Welle ist der Schnitt-Vorschlag zu den Achsen **(1)–(4)** des Roadmap-Kandidaten *Regeln ohne
Feedback-Quadrant schließen*. Sie nimmt **nicht** den ganzen Kandidaten: dessen Achsen (5)–(8) sind
Eigenbauten, (7) liegt außerhalb von git, und (1) ist bereits am 2026-07-28 nach
[welle-09](welle-09-modul-15-konformitaet.md) eingefaltet worden. Was hier landet, ist die Hälfte,
die der Kandidat selbst als *„bereits bezahlt"* führt — vier Regelmodule im gepinnten d-check-Image.

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
   **Für `vcs` gilt der Nachweis nicht** — dort blieb der Lauf in **vier** Formen grün, auch **mit**
   Config-Block und über einer Range, die eine Kern-Änderung an einer `Accepted`-ADR enthält. Ob
   das Modul inert ist oder die Config danebenzielt, ist **offen**;
   [slice-127](open/slice-127-adr-immutabilitaet-hat-einen-sensor.md) §1 führt die vier Läufe und
   macht die Herstellung dieses Rots zu seinem Ausgang.
2. **Die Adoptions-Schuld ist real und je Modul verschieden** — jede Zahl aus dem Lauf des jeweiligen
   `doc-*`-Ziels mit gesetztem Config-Block über den **unveränderten** Baum:
   `targets` → **21** (19 × `gate-undocumented`, 2 × `gate-phantom`);
   `planning` → **1** (`planning-drift` auf [`roadmap.md`](in-progress/roadmap.md) Zeile 13);
   `planning` mit der `waves`-Fähigkeit → **3** (zusätzlich `wave-drift` und `wave-preview-exists`
   auf `welle-09`); `commits` über `--range HEAD~20..HEAD` → **2** (`commit-untraceable`);
   `vcs` → **0**, und genau das ist der offene Punkt aus Messung 1.
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
- **[welle-10](welle-10-re-baseline.md) liegt in `done/`.** Der Grund ist **ordnend**: welle-10 ist
  die aktuelle Welle und tauscht den vendored Baum; zwei offene Wellen nebeneinander wären ein
  WIP-Bruch, keine Parallelität. Ist welle-10 vorher geschlossen, entfällt die Kante von selbst.

## 3. Closure-Trigger (Welle schließt)

- Alle fünf Slices liegen in `done/`.
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

**Die Reihenfolge ist nicht beliebig, und nur eine Kante ist hart.**
[slice-123](open/slice-123-ci-sieht-die-historie.md) geht **[slice-126](open/slice-126-commit-message-traegt-eine-kennung.md)
und [slice-127](open/slice-127-adr-immutabilitaet-hat-einen-sensor.md) voraus**: beide lesen
Historie, und ohne die Tiefen-Entscheidung aus 123 wären sie in CI blind und grün — ein fail-open
Sensor ist schlechter als keiner, weil er eine Zusage trägt. Die zwei hermetischen
([slice-124](open/slice-124-gate-tabelle-hat-einen-waechter.md),
[slice-125](open/slice-125-roadmap-und-verzeichnis-stimmen-ueberein.md)) hängen an nichts und
können zuerst oder parallel laufen.

**Warum fünf und nicht drei.** Der Roadmap-Kandidat schätzt *„zwei bis drei Slices"*. Die Schätzung
ist von vor der Messung: sie unterstellt, Adoption sei je Modul eine Config-Zeile. §1 Messung 2
zeigt vier verschiedene Adoptions-Schulden mit vier verschiedenen Entscheidungen, und Modul 5
§Ziel-Form deckelt einen Slice bei **drei** eigenen DoD-Punkten. Zwei Module in einen Slice zu
legen ergäbe sechs — *„der Schnitt ist falsch"*, nicht *„die DoD ist länger"*.

## 5. Abhängigkeiten

- **Wird blockiert von:** [slice-122](done/slice-122-d-check-pin-v0650.md) (Pin, tragend) und
  [welle-10](welle-10-re-baseline.md) (WIP, ordnend) — beide mit ihrer Begründung in §2.
- **Blockiert:** nichts. [welle-11](welle-11-traeger-aussage.md) hängt an
  [welle-10](welle-10-re-baseline.md), nicht an dieser Welle; die Reihung ist damit
  welle-10 → welle-11 **und** welle-10 → welle-13, ohne Kante zwischen 11 und 13.
- **Berührt, aber bindet nicht:** [slice-121](open/slice-121-commit-message-nennt-was-es-gibt.md)
  liegt **außerhalb** dieser Welle und bekommt aus
  [slice-126](open/slice-126-commit-message-traegt-eine-kennung.md) seinen **Träger**, nicht seine
  Eigenschaft (Begründung dort in §1).

## 6. Out-of-Scope für diese Welle

- **Die Achsen (5)–(8) des Roadmap-Kandidaten.** (5) Co-Change um
  [`spec/lastenheft.md`](../../../spec/lastenheft.md), (6) Closure-Notiz-Pflicht, (7) veröffentlichte
  Artefakte außerhalb von git, (8) der DoD-Punkte-Zähler — alle vier sind **Eigenbauten**, keine
  Adoption. Sie bleiben als Kandidaten-Zeile in der Roadmap stehen.
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
    deren Identität die vier gemessenen Achsen sind.
  - **`versions` — der Sensor existiert, sein Gegenstand liegt woanders.** Ohne Block
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
    **Wohin es gehört, ist gemessen:** sein großer lebender Gegenstand in diesem Repo ist der
    **Baseline-Tag**, nicht der d-check-Pin. `pin-pattern: 'baseline/(v…)'` gegen einen Span mit
    `v5.12.0` meldet **58 Befunde über 16 Dateien**, darunter **alle vier** Accepted-ADRs aus
    [slice-080](in-progress/slice-080-verweis-ueberlebt-tagwechsel.md) — also auch die **drei**, die dort
    als *stumm* gemessen sind. `versions` ist damit ein Kandidat für die **stille Hälfte** jenes
    Slice in [welle-10](welle-10-re-baseline.md); die Messung steht dort in §6, nicht nur hier.
  - **`pins` und `immutable` — der Gegenstand muss erst geschrieben werden.** Beide melden ohne
    Block `0 Befund(e)`, und das ist keine Config-Lücke, sondern eine leere Marker-Menge:
    `git grep -c 'dpin: sha256:' -- '*.md' ':!.harness/baseline' | wc -l` → **0**, dasselbe mit
    `'immutable: sha256:'` → **0**. Adoption hieße, Marker von Hand zu setzen — dieselbe
    Eigenbau-Klasse wie die Achsen (5)–(8) oben, nur mit geliefertem Prüfer.
    **`immutable` trägt trotzdem einen Befund für diese Welle:** ein absichtlich falscher
    `immutable: sha256:0000…`-Marker auf einer Accepted-ADR meldet **`core-drift`** — das
    hermetische Geschwister genau der Zusage, für die
    [slice-127](open/slice-127-adr-immutabilitaet-hat-einen-sensor.md) mit `vcs` in vier Formen kein
    Rot herstellen konnte. Das Rot ist also **herstellbar**, nur nicht über die Range; der Hinweis
    steht in slice-127 §6 und ändert dessen Zuschnitt nicht.
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

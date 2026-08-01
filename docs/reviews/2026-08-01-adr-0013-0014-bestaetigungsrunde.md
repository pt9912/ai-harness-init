# Bestätigungsrunde — ADR-0013 und ADR-0014 (Proposed), Behebung der blockierenden Befunde

- **gegenstand:** eng geschnittene Bestätigung, kein zweites Voll-Review. Geprüft:
  `docs/plan/adr/0013-technik-stratum-als-zielort.md`,
  `docs/plan/adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md`,
  `docs/plan/adr/0012-haupt-kontext-ohne-token-bilanz.md`, `docs/plan/adr/README.md`,
  `harness/conventions.md` (`MR-019`/`MR-020`), `spec/spezifikation.md`,
  `docs/plan/planning/open/slice-076-mr-018-umzug-technik-stratum.md`
- **diff:** `f9204b2..HEAD` (`cfd1b62` Architect · `b39d4ff` Rollentypen · `b2fb908` Planner)
- **ausgangs-report:** `docs/reviews/2026-08-01-adr-0013-0014-review.md` (3 HIGH · 6 MEDIUM ·
  8 LOW · 3 INFO, nicht konform)
- **in auftrag:** HIGH-1 · HIGH-2 · HIGH-3 · MEDIUM-1 · MEDIUM-2 · MEDIUM-5 · MEDIUM-6 ·
  alle Zahlen der geänderten Texte · Trag-Prüfung der MEDIUM-4-Aussage · neu entstandene Defekte.
  **Nicht in Auftrag:** MEDIUM-3, die Reparatur von MEDIUM-4, alle LOW und INFO des Vorreports.
- **verdikt:** **1 HIGH · 3 MEDIUM · 3 INFO.** `ADR-0014` ist annahmefähig; `ADR-0013` nicht —
  HIGH-2 ist auf der gemessenen Achse behoben, auf einer zweiten Achse desselben Satzes offen.
- **gates:** `make gates` Exit 0 (baseline-verify v3.5.2 / 42 Dateien · d-check 277/0 ·
  150 bats, 0 `not ok` · comment-claims 38/0 · span-check ok). Wie im Vorreport: die grünen
  Gates messen nichts von dem, was hier blockiert.

---

## Je Befund: erledigt / nicht erledigt

### HIGH-1 — Teil-Supersede deckungsgleich mit Festlegung 1 · **erledigt**

`ADR-0011` Folgepflicht 1 (`0011-…:293-295`) setzt den Zielort des Span-Schemas, Folgepflicht 2
(`:296-297`) den der Abweichungs-Begründungen **plus** ein Kommentar-Verbot. `ADR-0013`
Festlegung 1 verlegt genau diese beiden Gegenstände (Feldtabelle **und** *„die je Abweichung vom
Pflicht-Minimum geschuldete Begründung"*, `0013-…:95-100`).

Das Revidiert-Feld (`0013-…:20-35`) nennt jetzt die **Zielort-Setzungen der Folgepflichten 1 und
2** und grenzt ausdrücklich ab, was **nicht** revidiert ist: die Begründung von Folgepflicht 1,
das Verbot *„nicht in einem Kommentar"* aus Folgepflicht 2, die sechs Festlegungen, die Fitness
Function und die Folgepflichten **3–5**. Umfang und Verlegung sind damit deckungsgleich; 3–5 sind
draußen.

**Index nachgezogen:** `docs/plan/adr/README.md:19` führt jetzt *„Folgepflichten 1 und 2 — die
**Zielorte** von Span-Schema und Abweichungs-Begründung — revidiert durch ADR-0013; das
Kommentar-Verbot aus Folgepflicht 2, alle sechs Festlegungen, die Fitness Function und die
Folgepflichten 3–5 gelten fort"*. Auch `README.md:21` (`ADR-0013`-Zeile) ist auf *„Zielorte …
Folgepflichten 1 und 2"* gezogen.

**`ADR-0011` weiterhin null Byte.** Blob-Hash `39219fa4412174b47aeafcf58f951fa6fbd2ba65`
identisch bei `0fb1db8` (Accepted-Commit), `5200da6`, `f9204b2` und `HEAD` — selbst gemessen mit
`git rev-parse <rev>:docs/plan/adr/0011-telemetrie-erfassung-policy.md`.

### HIGH-2 — Zusage auf den Prüfbereich · **teilweise erledigt, siehe HIGH-2-R**

Auf der Achse, die der Vorreport gemessen hat (**nackt** gegen **verlinkt**), ist die Zusage an
allen drei Stellen zurückgenommen und die Lücke **benannt** statt verschwiegen:

- `harness/conventions.md:1690-1696` (`MR-019`) — der Bullet heißt jetzt *„Sensor, und seine
  Grenze"* und sagt: *„**Nicht** rot färbt eine **nackte** `slice-`-Kennung … eine solche Zeile im
  bindenden Text lässt den Gate bei Exit 0. Diese Hälfte der Regel trägt der Mensch."* Die
  Selbstauskunft *„Gegenprobe gefahren, nicht behauptet"* ist entfallen.
- `docs/plan/adr/0013-…:110` (Festlegung 3) — *„Der Doku-Gate hält die Regel **unvollständig** —
  wie weit, steht bei der Fitness Function."* Die Fitness-Function-Tabelle hat eine **dritte
  Zeile** mit Tooling **keines** (`:166`), und der Gegenproben-Absatz (`:168-175`) sagt, dass die
  dritte Zeile ebenso gemessen ist.
- `spec/spezifikation.md:29-32` (Rang 2) — *„für eine nackte Planungs-Kennung führt
  `ids.patterns` kein Muster — dort gilt die Regel ohne Wächter."*

Meine eigene Gegenprobe bestätigt alle drei Zeilen (Ausgabe unten). Was **nicht** zurückgenommen
ist, steht als HIGH-2-R.

### HIGH-3 — slice-076 gegen ADR-0014 Festlegung 2 · **erledigt**

DoD (2) (`slice-076-…:242-255`) heißt jetzt *„Der Eintrag wird vollständig aufgehoben, und die
Aufhebung wird vollzogen"* und bindet die drei Bedingungen **einzeln, je an ihrem Beleg**:

- **(a)** *„die Aufhebung ist vollständig — kein Satz des Rumpfs bindet nach dem Inventar noch von
  dort"*;
- **(b)** *„jede bindende Aussage steht andernorts bindend oder ist als *ersatzlos* mit Grund
  verzeichnet — das führt DoD (3) nach"*; das *ersatzlos*-Verzeichnis liegt zusätzlich im
  aufhebenden Eintrag selbst (`:246`), wie `ADR-0014` (b) es verlangt;
- **(c)** *„Aufhebung und Entfernung sind **zwei** Commits, und der Entfernungs-Commit löscht nur:
  `git show --numstat <sha> -- harness/conventions.md` zeigt **0** Insertions."*

**Zusammen fällig** ist in §3 Schritt 4 gebunden (`:287-290`): *„Fällig **mit** Schritt 3 …, weil
das Intervall dazwischen genau der Zustand ist, in dem die Feldtabelle an zwei Orten steht."*

Die Gegen-Aussagen des alten Schnitts sind vollständig weg: das DoD-Messkriterium *„`git diff`
zeigt an den Blockgrenzen 835 … 1658 null geänderte Bytes"*, §6 *„Der aufgehobene Rumpf bleibt
stehen"* und der §6-Posten *„Nicht in diesem Slice: die Entfernung des aufgehobenen Rumpfs"*.

**Korrektur von Entfernung unterscheidbar:** ja. §1 (a) sagt, die Wortlaut-Korrektur *„fährt
**nicht** im Umzugs-Diff mit"*; §3 Schritt 5 gibt ihr einen eigenen Commit mit eigener Message,
und Schritt 4 ist der reine Lösch-Commit mit der numstat-Zusicherung. Damit trägt jeder der drei
Vorgänge einen eigenen, an seiner Form erkennbaren Diff.

### MEDIUM-1 — `1673` als Nenner · **erledigt**

Beide Stellen führen den falschen Nenner nicht mehr und sind auf `5200da6` gepinnt:
`0013-…:52-57` (*„ein **einziger** Eintrag … trägt **824** Zeilen — mehr als **alle übrigen
zusammen** (801 in achtzehn Einträgen)"*) und `harness/conventions.md:1697-1707`.

Selbst nachgemessen an `5200da6` über die genannte Blockgrenze
`grep -nE '^### MR-[0-9]{3}|^## Modus-Deklaration'`: 19 Einträge, `MR-018` = **824 Z / 70.727 B**
(835…1658), übrige 18 = **801 Z / 64.490 B**, Block `34..1658` = 1625 = 824 + 801. Die Aussage
*„mehr als alle übrigen zusammen"* trifft an dem genannten Stand auf **beiden** Achsen zu
(824 > 801; 70.727 > 64.490).

### MEDIUM-2 — „je sieben Ränge" · **erledigt**

`0013-…:69-71` sagt jetzt zahlenfrei *„§Source precedence führen ihn beide nicht"*. Selbst
nachgezählt bei HEAD: `AGENTS.md` §2 = 8 Ränge, `harness/README.md` §Source precedence = 8 Ränge;
der Adaptions-Block steht in keiner der beiden Listen. Die tragende Hälfte bleibt richtig, die
einfrierende Zahl ist weg.

### MEDIUM-5 — `ADR-0012`s `Schärft:` · **erledigt**

`0012-…:23-28` sagt jetzt, dass §5 der von `ADR-0013` entschiedene **Zielort** ist und dass *„die
Deklaration … ab der ersten Zeile [greift], die dort steht"*. Damit behauptet der Zeiger keinen
Inhalt mehr, den das Ziel heute nicht trägt (§5 hat weiterhin null Datenzeilen,
`spec/spezifikation.md:56-57`).

### MEDIUM-6 — tragende Annahme gegen den eigenen CI · **erledigt**

`0014-…:57-62` ersetzt *„`git` ist auf jedem Checkout präsent"* durch *„wer den Rumpf braucht, hat
die Historie — das ist **nicht** dasselbe wie ‚jeder Checkout hat sie'"* und benennt den flachen
CI-Klon als **bestehenden** Zustand. Der Re-Evaluierungs-Trigger (`:152-154`) ist entsprechend
gedreht: *„Wenn der Rumpf **ohne** Historie gebraucht wird"*. `MR-020`s Auflösungs-Trigger
(`harness/conventions.md:1749-1751`) zieht nach.

Selbst gemessen: `.github/workflows/` führt **sieben** `- uses: actions/checkout@…`-Schritte
(ci.yml 4 · release.yml 2 · upstream-drift.yml 1; die achte Fundstelle `release.yml:82` ist ein
Kommentar), alle auf `fbc6f3992d24b796d5a048ff273f7fcc4a7b6c09` (v5.1.0) SHA-gepinnt;
`grep -rn 'fetch-depth\|fetch_depth' .github/` → **kein Treffer**. Die neue Formulierung nennt
**keine Zahl** und ist damit auch gegen den nächsten Workflow-Schritt haltbar.

### MEDIUM-4 — nur Trag-Prüfung der Planner-Aussage · **trägt, im Umfang der Aussage**

Die Aussage lautet, die §3.6-Belege würden **im Inventar** aufgefangen, nicht in der Regel. Sie
trägt für `slice-076`, und zwar an zwei Stellen belegbar: die §1-Zielort-Tabelle nennt die
Klasse ausdrücklich (`:123` — *„die rot-gesehen-Nachweise, Gegenproben und Messreihen, die
`ADR-0014` Bedingung (b) **nicht** deckt, weil sie keine bindende Aussage sind"*, Zielort
`docs/reviews/`), und DoD (3) (`:256-264`) bindet *„**jeder**, auch der, der keine bindende
Aussage ist"* samt Nachzählung gegen die Ist-Zahlen aus §1. Die Aussage generalisiert **nicht**
über diesen Slice hinaus — das behauptet sie aber auch nicht, und `ADR-0014` behauptet es
ebenfalls nicht. Kein Befund im Rahmen des Auftrags.

---

## Findings

### HIGH-2-R — Die Zusage über die **verlinkte** Kennung ist weiterhin breiter als ihr Prüfbereich

- **kategorie:** HIGH
- **quelle:** `AGENTS.md` §3.6, `ADR-0013` Festlegung 3, `MR-019`
- **pfad:** `docs/plan/adr/0013-technik-stratum-als-zielort.md:164`;
  `harness/conventions.md:1690-1693`; `spec/spezifikation.md:29-30`
- **befund:** Die Fitness Function sagt *„Eine **verlinkte** Entscheidungs- **oder**
  Planungs-Kennung im bindenden Text von `spec/spezifikation.md` (außerhalb der Historie) meldet
  `matrix-forbidden`"*; `MR-019` und `spec/spezifikation.md` tragen dieselbe Breite. Gemessen
  meldet die `matrix`-Regel nicht die **Kennung**, sondern die **Klasse des Link-Ziels**: eine
  Zeile `Diese Schranke stammt aus [slice-060](../AGENTS.md).` und ebenso
  `[ADR-0011](../AGENTS.md)` im bindenden Text lassen `make docs-check` bei
  `277 Datei(en) geprüft, 0 Befund(e)`, Exit 0. Das ist dieselbe Klasse wie HIGH-2 — eine Zusage
  ohne rot gesehenes Gegenbeispiel — eine Achse weiter, und die dritte Fitness-Function-Zeile
  nennt den Mechanismus (*„`matrix` greift nur über den Link"*), ohne die Folge für Zeile 1 zu
  ziehen. Die Fundstelle in `spec/spezifikation.md` steht auf **Rang 2** der Source Precedence.
- **verifizierbar:** ja — `make docs-check` mit einer der beiden obigen Zeilen; Ausgabe unten.

### MEDIUM-N1 — `AGENTS.md` §3.5 wird im Plan über seinen Wortlaut hinaus paraphrasiert

- **kategorie:** MEDIUM
- **quelle:** `AGENTS.md` §3.5 (Hard Rule)
- **pfad:** `docs/plan/planning/open/slice-076-mr-018-umzug-technik-stratum.md:52-53` und
  `:179-181`, gegen `AGENTS.md:76-79`
- **befund:** Die Bezug-Liste glossiert §3.5 neu als *„Regel-Lockerung nur mit ADR — die Grenze,
  an der die Entfernung des Rumpfs hängt"*; §1 sagt *„Die Lockerung der Disziplin-Regel ist ein
  ADR (`AGENTS.md` §3.5)"*. §3.5 heißt *„Gates nicht ohne ADR lockern"* und lautet im Text *„Jede
  Schwellen-Senkung (Modul-Aktivierung, Strenge) ist ein ADR"* — die Entfernung des Rumpfs senkt
  keine Gate-Schwelle und aktiviert kein Modul. Der Plan kennzeichnet die Analogie hier **nicht**,
  während er sie bei §3.3 zweimal ausdrücklich als *„in der Sache"* markiert; `ADR-0014` selbst
  zitiert §3.3, §3.4 und §3.6, aber §3.5 **nicht**. Vorher stand an der Bezug-Stelle die
  Überschrift wörtlich.
- **verifizierbar:** nein maschinell — nachlesbar an `AGENTS.md:76-79`.

### MEDIUM-N2 — `MR-020` nennt 42,8 % und schließt daraus auf „überwiegend"

- **kategorie:** MEDIUM
- **quelle:** `MR-020`
- **pfad:** `harness/conventions.md:1741-1744`
- **befund:** Derselbe Satz führt *„824 Zeilen / 70.727 Bytes und damit 42,8 % davon"* und
  *„macht den Pflicht-Lesepfad zu **überwiegend** nicht mehr bindendem Text"*. 42,8 % ist keine
  Mehrheit; der Rumpf ohne seinen Kopf ist noch etwas kleiner. `ADR-0014` selbst zieht diesen
  Schluss nicht — Option A wurde in `cfd1b62` gerade auf *„der oben gemessene Anteil"*
  zurückgenommen (`0014-…:97`), der Eintrag blieb stehen.
- **verifizierbar:** ja — Nachrechnung: `70727 / 165197 = 42,81 %` am gepinnten Stand `c145f2b`
  (selbst gemessen: `harness/README.md` 10.237 + `AGENTS.md` 12.798 + `harness/conventions.md`
  142.162 = 165.197 B).

### MEDIUM-N3 — `ADR-0014`s `119 anchor-missing` ist bei HEAD **121**, und als einzige Messung der ADR ungepinnt

- **kategorie:** MEDIUM
- **quelle:** `ADR-0014` Fitness Function, `AGENTS.md` §3.6
- **pfad:** `docs/plan/adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md:137-140` und `:100`
  (Option-D-Zeile)
- **befund:** *„die Überschrift des größten Eintrags umbenannt → `make docs-check` Exit 2 mit
  **119** `anchor-missing`"*. Selbst nachgefahren bei HEAD (gepinntes Image, `--network none`):
  `d-check: 277 Datei(en) geprüft, **121** Befund(e)`, Exit 2. Die Differenz stammt aus **diesem**
  Commit-Bündel: `b2fb908` hat zwei `MR-018`-Links in `slice-076` ergänzt (Anker-Referenzen im
  Baum 120 → 122, gemessen mit `git grep -c` bei `f9204b2` gegen HEAD). Dieselbe Überarbeitung
  hat die Byte-Messung derselben ADR auf `c145f2b` gepinnt (LOW-6 des Vorreports) und diese Zahl
  ungepinnt gelassen; sie friert mit *Accepted* ein. Die tragende Hälfte — Umbenennung färbt rot —
  ist unberührt.
- **verifizierbar:** ja — Zeile 835 von `harness/conventions.md` umbenennen, `make docs-check`,
  `anchor-missing` zählen.

### INFO-1 — Fälligkeits-Regel als „Festlegung 2c" zitiert

- **kategorie:** INFO
- **quelle:** `ADR-0014` Festlegung 2
- **pfad:** `docs/plan/planning/open/slice-076-…:288` gegen `0014-…:73-81`
- **befund:** Der Plan schreibt der Fälligkeit (*„Fällig **mit** Schritt 3"*) die Fundstelle
  *„Festlegung 2c"* zu. In der ADR steht *„Fällig ist die Entfernung **mit** der Aufhebung"* als
  eigener Satz **nach** der Aufzählung (a)–(c) und gilt damit der Festlegung 2 insgesamt, nicht
  ihrer Bedingung (c). Inhaltlich gebunden ist die Sache korrekt.
- **verifizierbar:** nein.

### INFO-2 — Die Index-Annotation nennt die fortgeltende **Begründung** von Folgepflicht 1 nicht

- **kategorie:** INFO
- **quelle:** `ADR-0013`, ADR-Index
- **pfad:** `docs/plan/adr/README.md:19`
- **befund:** Der Index nennt ausdrücklich, was von Folgepflicht **2** fortgilt (das
  Kommentar-Verbot), nicht aber, was von Folgepflicht **1** fortgilt (ihre Begründung *„der
  nächste Leser muss es ohne Code finden"*), obwohl die ADR beides gleichrangig abgrenzt
  (`0013-…:24-28`). Über *„die **Zielorte** … revidiert"* ist es implizit abgedeckt; asymmetrisch
  ist es trotzdem.
- **verifizierbar:** nein.

### INFO-3 — Beide ADRs überarbeiten ihre Geschichte-Zeile, statt eine zu ergänzen

- **kategorie:** INFO
- **quelle:** Maintainability
- **pfad:** `0013-…:208`, `0014-…:168`
- **befund:** `cfd1b62` hat die bestehende *Proposed*-Zeile von `ADR-0013` inhaltlich geändert
  (*„größer als die übrigen achtzehn zusammen"* → *„größer als alle übrigen zusammen"*) und keine
  Überarbeitungs-Zeile ergänzt; `ADR-0014`s Tabelle blieb unverändert. Bei *Proposed* ist das
  zulässig (`AGENTS.md` §3.4 greift ab *Accepted*), weicht aber von der Praxis ab, die `ADR-0011`
  mit einer Zeile je Runde etabliert hat. **Kein** Befund in der vom Auftrag befürchteten
  Richtung: Entstehungs-Erzählung wurde nirgends **eingezogen** (siehe Negativbefunde).
- **verifizierbar:** nein.

---

## Meine eigene Gegenprobe zu HIGH-2 (Ausgabe)

Alle Läufe: `make docs-check`, gepinntes Image
`ghcr.io/pt9912/d-check@sha256:fede3d027b2ebc1dd8534460853e57b67cc7a9a182cad2e2138c8eebf7a2d03c`,
`--network none`, eingefügte Zeile jeweils `spec/spezifikation.md:46` im bindenden Text von §3
(außerhalb der Historie). Datei danach byteweise aus der Sicherung zurückgeschrieben,
Arbeitsbaum sauber.

**(1) nackte Planungs-Kennung** — `Diese Schranke wurde in slice-060 gesetzt.`

```
d-check: 277 Datei(en) geprüft, 0 Befund(e)
```

Exit 0. **Die Lücke ist real** — und jetzt an allen drei Stellen benannt.

**(2) dieselbe Kennung als Link auf die Slice-Datei** —
`Diese Schranke wurde in [slice-060](../docs/plan/planning/in-progress/slice-060-rollen-achse.md) gesetzt.`

```
spec/spezifikation.md:46	../docs/plan/planning/in-progress/slice-060-rollen-achse.md	matrix-forbidden
d-check: 277 Datei(en) geprüft, 1 Befund(e)
```

Exit 2.

**(3) nackte Entscheidungs-Kennung** (Kontrolle der zweiten Zeile) —
`Diese Schranke wurde in ADR-0011 gesetzt.`

```
spec/spezifikation.md:46	ADR-0011	id-unlinked
d-check: 277 Datei(en) geprüft, 1 Befund(e)
```

Exit 2.

**(4) verlinkte Planungs-Kennung mit Nicht-Slice-Ziel** —
`Diese Schranke stammt aus [slice-060](../AGENTS.md).`

```
d-check: 277 Datei(en) geprüft, 0 Befund(e)
```

Exit 0 — **das ist HIGH-2-R.**

**(5) verlinkte Entscheidungs-Kennung mit Nicht-ADR-Ziel** —
`Diese Schranke stammt aus [ADR-0011](../AGENTS.md).`

```
d-check: 277 Datei(en) geprüft, 0 Befund(e)
```

Exit 0 — dieselbe Kante auf der ADR-Hälfte.

Mechanik dahinter, gelesen in `.d-check.yml`: `ids.patterns` führt `ADR-\d{4}`, `LH-[A-Z]{2}-\d{2}`
und `MR-\d{3}` — kein `slice-`-Muster; `matrix.classes` klassifiziert **Pfade**
(`slice: docs/plan/planning/**/slice-*.md`), und `matrix.rules` verbietet `spec-straten → adr`
sowie `spec-straten → slice`. Rot wird also das **Ziel** eines Links, nicht der Text der Kennung.

---

## Zahlen — selbst nachgerechnet

Alle Zahlen der geänderten Texte, je über die Blockgrenze
`grep -nE '^### MR-[0-9]{3}|^## Modus-Deklaration'`, wo die Texte sie nennen.

**`ADR-0013` / `MR-019`, gepinnt auf `5200da6`** — Pin selbst geprüft: `5200da6` ist Vorfahr von
HEAD, `harness/conventions.md` dort blob-identisch mit `dcee2f3`.

| Aussage | gemessen | Urteil |
|---|---|---|
| Datei 1.673 Z / 138.193 B, Block `34..1658` = 1.625 Z | ja | ✔ |
| `MR-018` 824 Z / 70.727 B (835…1658) | ja | ✔ |
| übrige **achtzehn** = 801 Z | ja (824 + 801 = 1.625) | ✔ |
| „mehr als alle übrigen zusammen" | 824 > 801, 70.727 > 64.490 — an **diesem** Stand auf beiden Achsen | ✔ |
| am 2026-07-28 47 Z, Datei 870 Z (`e07624a`) | ja | ✔ |
| Dateiwachstum 803, davon 777 auf den Eintrag | 1.673 − 870 = 803; 824 − 47 = 777 | ✔ |
| beide Precedence-Listen führen ihn nicht | `AGENTS.md` §2 und `harness/README.md` je 8 Ränge, keiner ist er | ✔ |

**`ADR-0014` / `MR-020`, gepinnt auf `c145f2b`**

| Aussage | gemessen | Urteil |
|---|---|---|
| Leseliste 165.197 B | 10.237 + 12.798 + 142.162 = 165.197 | ✔ |
| größter Eintrag 824 Z / 70.727 B | ja, auch bei `c145f2b` unverändert | ✔ |
| 42,8 % | 70.727 / 165.197 = 42,81 % | ✔ |
| Pin trifft den Stand | ja — bei `f9204b2` wären es 42,1 %, bei HEAD 41,95 % | ✔ |
| „überwiegend" | 42,8 % ist keine Mehrheit | **✘ MEDIUM-N2** |
| 119 `anchor-missing` | bei HEAD **121**, ungepinnt | **✘ MEDIUM-N3** |
| CI-Klon flach, kein `fetch-depth` | 7 Checkout-Schritte, alle SHA-gepinnt, `fetch-depth` nirgends | ✔ |

**`slice-076`, gepinnt auf `b39d4ff`** — Pin geprüft: `b39d4ff` ist HEAD~1, seine
`harness/conventions.md` ist mit der bei HEAD identisch.

| Aussage | gemessen | Urteil |
|---|---|---|
| Datei 1.767 Z / 145.563 B | ja | ✔ |
| `MR-018` 824 Z / 70.727 B (835…1658) | ja | ✔ |
| übrige **20** = 895 Z / 71.860 B | ja | ✔ |
| min 443 B · Median 3.369 B · max 7.991 B | `MR-000` 443, `MR-007` 7.991; Median (3.149+3.589)/2 = 3.369 | ✔ |
| 46,6 % der Zeilen / 48,6 % der Bytes | 824/1767 = 46,63 %; 70.727/145.563 = 48,59 % | ✔ |
| „auf **beiden** Achsen knapp kleiner" | 824 < 895 und 70.727 < 71.860 | ✔ |
| 28 Commits tragen den Eintrag, Kurve 47 … 824 | Kurve zeichengenau reproduziert (28 Werte) | ✔ |
| 21 aufwärts · 5 seitwärts · 1 abwärts, dieser 7 Z | 27 Übergänge, Auszählung stimmt; 206 → 199 = 7 | ✔ |
| 70 Stände, `^### MR-` je Stand 1 … 21, monoton | ja (`1 2 4 5 5 6 … 20 21 21`) | ✔ |
| Datei 823 → 1.767 Z, Einträge 18 → 21 | `9a4ad3b` (2026-07-28) 823 Z / 18 Einträge | ✔ |
| 1 Unterüberschrift; `grep -c '<!--'` → 0 | ja | ✔ |
| Modul-15 97 Z / 6.135 B | ja | ✔ |
| 19 von 28 Modul-Nennungen = 67,9 %; 9/3/5/1/1 | ja (19/28 = 67,86 %), Aufschlüsselung exakt | ✔ |
| 9 Slice-Nennungen, 4 verschiedene (059·060·066·068) | ja | ✔ |
| 49 Zeilen / 51 Vorkommen Datums-Stempel | ja | ✔ |
| 19 Zeilen / 20 Vorkommen `(Review\|Verifier)-Befund` | ja | ✔ |
| 14 Zeilen / 15 Vorkommen der „bis <Datum>"-Formel | ja | ✔ |
| 10 Test-Funktionen, 30 Mutations-Fälle, alle 30 existieren | ja, 0 fehlend | ✔ |
| slice-075: *839 Z, 50 %*; richtig 824 = 49,3 % dort, 46,6 % bei `b39d4ff` | Zitat verbatim; 824/1673 = 49,25 %, 824/1767 = 46,63 % | ✔ |
| `spec/*.md` Modul-Nennungen → 0 | ja | ✔ |
| Teil-Revisions-Weg **fünfmal** begangen | 3 Index-Annotationen (`ADR-0004`, `ADR-0008`, `ADR-0011`) + `MR-019` + `MR-020` | ✔ |
| `MR-019` zählt heute „zwei Abweichungen", eine vierte Spalte wäre die dritte | `harness/conventions.md:1681` sagt „Zwei Abweichungen" | ✔ |
| übrige **20** Einträge (§6) | 21 − 1 | ✔ |

Die Sub-Block-Zahlen des Eintrags (Feldtabelle 29 Z / 7.193 B, Werkzeug-Tabelle 17 Z / 1.851 B,
Abweichungs-Block 295 Z / 23.672 B, 274 Zeilen Sensor-Bindung, 62-Zeilen-Positiv-Liste) sind vom
Pin-Wechsel unberührt: der Block `835..1658` ist bei `7e496a9` und `b39d4ff` byteweise identisch
(`sha256` beider Auszüge `942b1db5…ff5f`), also gilt die Prüfung des Vorreports unverändert
weiter.

---

## Ist beim Beheben etwas Neues entstanden?

- **Umfang.** `ADR-0013` +3 Zeilen (44 hinzu / 41 weg), `ADR-0014` +2 (14/12),
  `harness/conventions.md` +7 (35/28), `spec/spezifikation.md` +2 (4/2), `slice-076` +37
  (132/95). Das Verhältnis von Ersetzung zu Zuwachs ist in den ADRs 41:3 bzw. 12:2 — es wurde
  ersetzt, nicht danebengeschrieben. Die 37 Zeilen des Plans verteilen sich auf die
  HIGH-3-Arbeit (DoD (2) +10, DoD (3) +4, §3 Schritt 4 +4), die zwei neuen Bezug-Einträge
  (`ADR-0014`, `MR-020`) und die Trigger-/§6-Umschreibung. **Kein** Absatz gefunden, wo ein
  ersetzter Satz gereicht hätte.
- **Entstehungs-Erzählung:** keine eingezogen. Über alle hinzugefügten Zeilen der ADRs, der
  `MR`-Einträge, der Spec und des Plans gesucht nach Befund-IDs, Runden-Verweisen, „hier stand
  bis…", „frühere Fassung", „Vorgänger" und Datums-Stempeln an Text-Änderungen: die Treffer sind
  ausnahmslos **Gegenstand** (die Zählungen über den `MR-018`-Rumpf, „Vorgängerin" als Rolle
  einer ADR, „Befund" als d-check-Fehlerform) oder **Messdaten mit Commit-Pin**. Der Vorreport
  liegt als eigene Datei unter `docs/reviews/` und wird von keiner ADR und keinem `MR`-Eintrag
  zitiert.
- **Neu entstanden sind:** MEDIUM-N1 (die §3.5-Paraphrase, vorher stand dort die Überschrift
  wörtlich) und MEDIUM-N3 (die `119` ist durch `b2fb908` stale geworden). MEDIUM-N2 stand schon
  bei `f9204b2`, liegt aber in einem in `cfd1b62` überarbeiteten Bullet und widerspricht der Zahl
  im selben Satz.

---

## Geprüft, ohne Befund

- **`ADR-0011` null Byte** — Blob `39219fa4412174b47aeafcf58f951fa6fbd2ba65` bei `0fb1db8`,
  `5200da6`, `f9204b2` und HEAD identisch.
- **`.d-check.yml` unverändert** im gesamten Bereich `f9204b2..HEAD` — die Gegenprobe misst also
  denselben Sensor wie der Vorreport.
- **Alle drei Zeilen der `ADR-0013`-Fitness-Function eigenständig reproduziert**, Fehlerform und
  Pfad zeichengenau (`matrix-forbidden`, `id-unlinked`, still).
- **Kommandos in den Texten selbst nachgefahren:** die Blockgrenzen-`grep`-Zeile,
  `awk 'NR>=835&&NR<=1658' | wc -l -c`, `git log --format=%h --reverse -- harness/conventions.md`,
  `grep -oE 'Modul[- ][0-9]{1,2}'`, `grep -oE 'Test[A-Z][A-Za-z0-9_]+' | sort -u`,
  `grep -oE 'test/mutations/[0-9]+' | sort -u`, `git ls-files 'spec/*.md' | …`. Alle liefern die
  im Text genannten Werte.
- **Slice-/Wellen-Kennungen in den ADRs und `MR`-Einträgen:** weiterhin keine — der einzige
  `slice-`-Treffer in `ADR-0013` steht in der Fitness-Function-Zeile als **Klassen**-Aussage
  („nackte Planungs-Kennung"), nicht als Adresse.
- **`spec/spezifikation.md` unverändert nach meiner Gegenprobe** — `git status` leer,
  `git diff --stat` leer; dasselbe für `harness/conventions.md` nach der Anker-Messung.
- **`ADR-0014` Festlegung 3** (Reichweite nur Adaptions-Block, ADRs unberührt) und **Folgepflicht
  3** (Emission unberührt) unverändert und vom Plan korrekt zitiert.
- **Plan-Zitate der `ADR-0013`-Folgepflichten** (1 = Inventar, 3 = Emission) und des
  Re-Evaluierungs-Triggers 1 gegen die ADR geprüft — treffen.
- **`make gates` Exit 0** bei sauberem Baum, nach Rückschreiben beider Prüf-Dateien.

---

## Kategorie-Summary

| Kategorie | Zahl |
|---|---|
| HIGH | 1 (HIGH-2-R) |
| MEDIUM | 3 (N1 · N2 · N3) |
| LOW | 0 |
| INFO | 3 |

Vom Auftrag umfasste Vorbefunde: **HIGH-1 erledigt · HIGH-2 teilweise · HIGH-3 erledigt ·
MEDIUM-1, -2, -5, -6 erledigt · MEDIUM-4-Aussage trägt.**

---

## Verdikt: annahmefähig?

- **`ADR-0014`: ja.** HIGH-3 ist im Plan aufgelöst, wie die Entscheidung es vorsieht; MEDIUM-6
  ist behoben, ohne eine neue Zahl einzuziehen. Die drei Bedingungen aus Festlegung 2 sind im
  einzigen Vollzugs-Plan einzeln, belegt und mit ihrer Fälligkeit gebunden. Die offenen MEDIUM
  hängen an ihrem `MR`-Eintrag (N2), an einer ungepinnten Zahl ihrer Fitness Function (N3) und am
  Plan (N1) — die **Entscheidung** trägt keinen davon. N3 gehört vor *Accepted* nachgezogen, weil
  die Zahl dann einfriert.
- **`ADR-0013`: nein.** HIGH-1, MEDIUM-1 und MEDIUM-2 sind sauber behoben. Offen bleibt
  **HIGH-2-R**: derselbe Satz, der auf der nackt/verlinkt-Achse gerade zurückgenommen wurde,
  ist auf der Ziel-Klassen-Achse weiterhin breiter als sein Prüfbereich — an denselben drei
  Stellen, eine davon auf Rang 2 der Source Precedence. Die dritte Fitness-Function-Zeile nennt
  den Mechanismus bereits; die Zusage in Zeile 1 zieht die Folge daraus nicht.

---

## Anmerkung zur Ablage (Fehler in der Vorlage, gemeldet statt still repariert)

`b39d4ff` hat die Repo-Hälfte des Konflikts geschlossen: `.claude/agents/reviewer.md` sagt jetzt
ausdrücklich, die Report-Datei sei das Werkstück der Rolle. Die **generische** Notiz im
Werkzeug-Rahmen dieses Laufs sagt weiterhin das Gegenteil (*„Do NOT Write report/summary/findings
.md files"*) und steht damit in direktem Widerspruch zur rollen-spezifischen Anweisung, zu
`.harness/skills/reviewer.md` §Ablage und zur Aufgabenstellung. Ich bin der spezifischeren
Anweisung gefolgt und habe diese Datei geschrieben; `Write` war verfügbar, der Lauf hat sie
selbst angelegt. Die Befunde stehen zusätzlich in der Text-Ausgabe an den aufrufenden Agenten.

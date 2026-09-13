# Review slice-225 — Gate-Index, Norm-Nachzug, Kennungs-Form

**Rolle:** Reviewer · **Datum:** 2026-09-13 ·
**Range:** `99bfd1c5^..fae7b7d1` (8 Dateien) — `99bfd1c5` (Implementer) · `3c2b4d82` (Architect) ·
`fae7b7d1` (Implementer) ·
**Plan:** [`slice-225`](../plan/planning/done/slice-225-gate-index-steht-einmal.md) ·
**Constraints:** [`AGENTS.md`](../../AGENTS.md) §3.4 · §3.5 · §3.6 · §3.7 · §3.8 · §3.11 ·
[`ADR-0044`](../plan/adr/0044-ziel-fassung-regiert-den-sprung-v672.md) ·
[`ADR-0024`](../plan/adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md) ·
[`ADR-0031`](../plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) ·
[`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) ·
[`MR-001`](../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids) ·
[`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) ·
[`MR-032`](../../harness/conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger) ·
[`MR-046`](../../harness/conventions.md#mr-046--die-verzeichnis-position-ist-binär-und-trägt-die-kopf-marke-nicht)

**Schnitt dieses Laufs.** Geprüft ist der Diff gegen Plan, ADRs und Hard Rules. **Nicht** geprüft:
die DoD-Abhakung (Verifier), `make gates` als Ganzes (fährt der Auftraggeber), die emittierte Ebene
(`internal/emit/**`, in §1 mit Adresse ausgeschlossen). Alle Zahlen stehen neben dem Kommando, das
sie liefert, gefahren über `fae7b7d1` — **keine Erwartungswerte**. Sonden liefen gegen Kopien
außerhalb des Repos, netzlos, Mount `:ro`, über den in [`d-check.mk`](../../d-check.mk) gepinnten
Digest. Nur lesende Kommandos im Arbeitsbaum, nichts geändert.

---

## Findings

### HIGH-1 — Der `authority`-Wechsel ist in einer Richtung eine gemessene Lockerung, und genau die misst die Senkungs-Prüfung nicht

- **kategorie:** HIGH
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.5; [`MR-001`](../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
- **pfad:** `.d-check.yml:88` (`targets.authority`), Plan §1 „Die Gate-Index-Frage ist eine Messung, keine Abwägung"
- **klasse:** Senkungs-Prüfung misst nur die Richtung, die nicht gesunken ist

**Was gemessen wurde, trägt — aber nur die halbe Frage.** Die Mengen-Differenz aus §1 ist
reproduziert und leer:

```sh
comm -23 <(git show 99bfd1c5^:AGENTS.md | grep -oE '^\| `make [a-z0-9-]+`' | sed 's/^| `make //;s/`$//' | sort -u) \
         <(grep -oE '`make [a-z0-9-]+`' harness/README.md | sed 's/`make //;s/`$//' | sort -u)
# leer — 11 gegen 29 eindeutige Token; kein bisher dokumentiertes Target verliert seine Zeile
```

Auch die Deckung des heutigen Bestands bleibt exakt: 28 Tabellenzeilen in der neuen
`authority`-Datei, 37 `exempt-targets`, 17 Namen in **beiden** — jede Makefile-Regel bleibt gedeckt,
das Modul meldet nichts.

```sh
grep -cE '^\|.*`make [a-z][a-z0-9-]*`.*\|$' harness/README.md                          # 28
sed -n '/^targets:/,/^ignore-refs:/p' .d-check.yml | grep -c '^    - '                 # 37
docker run --rm --network none -v "$PWD":/repo:ro "ghcr.io/pt9912/d-check@<digest>" \
  --config /repo/.d-check.yml --enable targets                                          # 0 Befund(e)
```

**Die Gegenrichtung ist nicht leer, und sie ist rot-gegen-grün gefahren.** Die neue
`authority`-Datei trägt **zwei** Tabellen — §Sensors und, als Unterabschnitt, §Werkzeuge (kein
Gate). Das Modul kennt kein Heading-Scoping (sagt der Wächter dieses Repos selbst,
`test/targets-modul-wiring.bats:49`), also deckt jetzt auch eine **Werkzeuge**-Zeile die
Vollständigkeits-Richtung. Sonde: ein neues Rezept mit Hilfetext, dokumentiert **nur** in der
Werkzeuge-Tabelle, **nicht** in `exempt-targets`:

```sh
# beide Kopien: git archive <ref> | tar -x; dann
printf '\nprobe-tool: ## Sonde\n\t@true\n' >> Makefile
# + eine Zeile `| `make probe-tool` | Sonde | kein Gate |` in die Werkzeuge-Tabelle
docker run --rm --network none -v "$PWD":/repo:ro "ghcr.io/pt9912/d-check@<digest>" \
  --config /repo/.d-check.yml --enable targets

# ueber 99bfd1c5^ (authority: AGENTS.md):
#   1 Befund(e) — Makefile:429  probe-tool  gate-undocumented
# ueber fae7b7d1 (authority: harness/README.md):
#   0 Befund(e)
```

Ein Repo-Zustand, den der Gate **vorher zurückwies**, geht **jetzt durch**. Damit ist die Strenge
des Moduls in dieser Richtung gesunken: Die kuratierte Ausnahmeliste war für ein Nicht-Gate-Rezept
bisher die einzige Route, jetzt ist sie eine von zweien. Für 17 der 37 Einträge ist sie bereits
heute ohne Wirkung.

**Die Begründung im Plan trägt diese Richtung nicht.** §1 stützt das Verdikt *Verschärfung* auf
„die neue Autorität trägt 17 Zeilen mehr, die in beide Richtungen zu belegen sind (`gate-phantom`
prüft jede behauptete Zeile gegen ein reales Rezept)". `gate-phantom` hängt aber an `doc-tables`,
nicht an `authority`, und `doc-tables` führte `harness/README.md` schon vorher — der Diff lässt die
Zeile unverändert (`git show 99bfd1c5 -- .d-check.yml`: nur `authority` wechselt). Die 17 Zeilen
waren in der Phantom-Richtung bereits gedeckt; der Wechsel fügt dort nichts hinzu.

**Failure-Szenario:** Das nächste Nicht-Gate-Rezept bekommt eine Werkzeuge-Zeile und keine
`exempt-targets`-Entscheidung. `make gates` bleibt grün, die Ausnahmeliste altert weiter, und die
kuratierte Einordnung „Gate oder kein Gate" fällt still aus — genau die Klasse, die der Plan selbst
als `ausnahmeliste-nur-auf-form-geprueft` (2×) als Risiko führt, nur ohne die Erkenntnis, dass der
Wechsel ihren Auslöser verbreitert.

**Was das nicht heißt.** Kein Vorwurf, den Wechsel gemacht zu haben: Die Ziel-Fassung streicht die
Tabelle in `AGENTS.md` §4, `authority` nimmt genau eine Datei, damit ist `harness/README.md` die
einzige verbleibende Wahl. Der Befund ist, dass die Folge **nicht entschieden**, sondern aus einer
Messung wegerklärt wurde, die sie nicht erfasst. §3.5 verlangt für eine Senkung eine ADR; der
Plan-Kopf verlangt für einen Gate-Befund beim Übernehmen eine **Meldung an den Auftraggeber**.
Beide Wege sind offen, der dritte — „die Differenz ist leer, also kein §3.5-Fall" — ist es nicht.

- **verifizierbar:** ja — das Sonden-Paar oben (rot über `99bfd1c5^`, grün über `fae7b7d1`);
  `make gates` allein bestätigt den Befund **nicht**, das ist sein Inhalt.

### MEDIUM-1 — `MR-057` nennt eine Zahl, die derselbe Commit falsch macht

- **kategorie:** MEDIUM
- **quelle:** [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) Setzung 2; [`AGENTS.md`](../../AGENTS.md) §3.6
- **pfad:** `harness/conventions/MR-057-kennungs-form-fuer-neue-slices-und-wellen-ist-der-name.md:43`
- **klasse:** `mess-zusage-trifft-das-eigene-zitat` (Register-Stand **3×** vor diesem Slice)

Der Eintrag belegt die Reichweite seiner Teil-Ablösung mit:

```sh
grep -c 'slice-NNN' harness/conventions/MR-000-baseline-aussage.md   # im Eintrag: 1
```

Gemessen über `fae7b7d1` liefert dasselbe Kommando **2**:

```sh
grep -n 'slice-NNN' harness/conventions/MR-000-baseline-aussage.md
# 7:  > **ÜBERHOLT: das Token `slice-NNN` in der ID-Schema-Zeile → MR-057 …
# 25:   ID-Schema: `LH-FA-NN` / `LH-QA-NN`, `ADR-NNNN`, `CO-NNN`, `slice-NNN`,
git show 3c2b4d82^:harness/conventions/MR-000-baseline-aussage.md | grep -c 'slice-NNN'   # 1
```

Die zweite Fundstelle ist die Kopf-Marke, die **derselbe Commit** (`3c2b4d82`) gesetzt hat. Die
Aussage, die die Zahl stützt („allein das Token in seiner `Adaption:`-Zeile"), bleibt sachlich
richtig — die Zahl daneben ist es nicht mehr.

**Failure-Szenario:** Ein späterer Lauf führt das Kommando aus, bekommt 2, und kann nicht
entscheiden, ob die Reichweite der Ablösung falsch beschrieben oder nur die Zahl veraltet ist.
`MR-057` ist mit dem aufnehmenden Commit wirksam (eigenes Feld `Wirksamkeits-Anlass`) und damit
append-only: Die Korrektur kostet ab Merge einen Nachfolge-Eintrag statt einer Zeile.

- **verifizierbar:** nein (kein Gate liest Zahl-gegen-Kommando; `make docs-check` bleibt grün) —
  nachprüfbar durch das Kommando oben.

### MEDIUM-2 — Die Grenze von `MR-057` hat eine Rolle und einen Zeitpunkt, aber keine Adresse

- **kategorie:** MEDIUM
- **quelle:** Baseline-Regelwerk `modul-05-planning-harness.md` §Ziel-Form: Slice, Ausschluss-Klasse 1 („Ein Folge-Slice übernimmt es — **mit Kennung**. … Die Adresse muss die Sendung annehmen")
- **pfad:** `harness/conventions/MR-057-…:88-105`
- **klasse:** fällige Arbeit ohne aufnehmende Kennung

Der Eintrag setzt die Namens-Form **ab sofort** in Kraft (Setzung 1, Cutoff „beginnt mit diesem
Eintrag") und benennt daneben, dass zwei Dogfood-Stellen die Kennung an Ziffern binden:

```sh
git grep -lE 'slice-(\[0-9\]|\\d)' -- harness/tools internal cmd Makefile d-check.mk ':!internal/emit'
# harness/tools/slice-mv.sh
# internal/archive/stub.go
```

Der Nachzug ist als „Implementer-Arbeit, fällig **bevor** die erste benannte Kennung vergeben wird"
adressiert. Diese Adresse existiert nicht: Kein Slice in `open/`, `next/` oder `in-progress/` trägt
sie (`git grep -ln 'slice-mv\.sh\|archive/stub\.go' -- 'docs/plan/planning/{open,next,in-progress}/*.md'`
→ `slice-188`, `slice-215` — beide mit anderem Gegenstand), kein Verzeichnis im
Beobachtungs-Register führt sie (`ls docs/plan/planning/observations/BEO-ALL/ | grep -i kennung` →
`abgeschaffte-kennung-in-unveraenderlichem-artefakt`, anderer Gegenstand), und `MR-057` stellt
selbst fest, dass kein Gate die Form prüft.

**Failure-Szenario, und es ist das teuerste im Register:** Die erste benannte Slice-Kennung wird
vergeben. `make slice-mv` findet beim Lifecycle-Wechsel die Verweise auf sie nicht mehr und zieht
sie nicht nach — das ist wörtlich
`BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch`, mit **13** Belegen der größte
Zähler des Registers
(`ls docs/plan/planning/observations/BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch/evidence/*.md | wc -l`).
Der Slice-Plan schließt die Stelle auch nicht aus: §1 grenzt „alles unter `internal/` und `cmd/`"
ab — `harness/tools/slice-mv.sh` liegt in keinem von beiden.

- **verifizierbar:** nein (keine Gate-Form für eine fällige Arbeit ohne Adresse) — nachprüfbar
  durch die Suchen oben.

### MEDIUM-3 — `harness/conventions.md` §Baseline meldet zweimal „ausstehend", was in `done/` liegt

- **kategorie:** MEDIUM
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7 (*Zustandsfelder ebenso* — Zustand und Beleg, nicht Chronik); [`ADR-0031`](../plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) Festlegung 2 (Form der Zeile)
- **pfad:** `harness/conventions.md:30-31`
- **klasse:** Zustandsfeld behauptet einen überholten Zustand

```sh
grep -n 'Delta-Nachweis in slice-224' harness/conventions.md
# 30:  **auf `v6.5.0`:** 2026-09-07, Delta-Nachweis in slice-224, ausstehend;
# 31:  **auf `v6.7.2`:** 2026-09-12, Delta-Nachweis in slice-224, ausstehend.
ls docs/plan/planning/done/slice-224-*.md
# docs/plan/planning/done/slice-224-delta-nachweis-und-planungs-nachzug.md
```

Dass `slice-224` in `done/` liegt, ist der **Start-Trigger dieses Slice** (Plan §4) — der Lauf hat
ihn geprüft, um überhaupt zu beginnen. Der Architect-Commit `3c2b4d82` hat dieselbe Datei
angefasst (Index-Zeile für `MR-057`) und das Feld stehen lassen.

**Failure-Szenario:** §Baseline ist die Stelle, an der ein Lauf nachsieht, ob der Adaptions-Durchgang
gegen den adoptierten Stand erbracht ist. „ausstehend" liest sich als offene Pflicht und löst eine
Runde aus, die bereits gelaufen ist — oder deckt umgekehrt, dass der Nachweis nie gebucht wurde.

- **verifizierbar:** nein (kein Modul hält Zustandsfeld gegen Verzeichnis-Position) — nachprüfbar
  durch die zwei Kommandos oben.

### LOW-1 — „keine `make X`-Zeile in **dieser Tabelle** nötig" steht über der Tabelle, die genau diese Zeilen führt

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7 (ein Kommentar/eine Aussage beschreibt, was da ist)
- **pfad:** `harness/README.md:62-63`
- **klasse:** Referent einer Deixis zeigt auf das Gegenteil des Gemeinten

`99bfd1c5` ersetzt „keine `make X`-Zeile in [`AGENTS.md`](../../AGENTS.md) §4 nötig" durch „keine
`make X`-Zeile in **dieser Tabelle** nötig". Der Satz steht unter `### Werkzeuge (kein Gate)`,
unmittelbar **vor** der Werkzeuge-Tabelle, deren 17 Zeilen sämtlich `make X`-Zeilen sind. Gemeint
ist die Sensors-Tabelle darüber; gelesen wird die darunter. Zusätzlich beschreibt der Satz seit dem
`authority`-Wechsel keine Notwendigkeit mehr, sondern nur noch den Ist-Zustand (HIGH-1).

- **verifizierbar:** nein.

### LOW-2 — Der Sensor-Vertrag nennt einen Abschnitts-Scope, den das Modul nicht kennt

- **kategorie:** LOW
- **quelle:** [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6); [`AGENTS.md`](../../AGENTS.md) §3.6
- **pfad:** `harness/sensors/docs-check.md:130`
- **klasse:** Vertrag beschreibt einen engeren Prüfbereich als das Werkzeug hat

`fae7b7d1` schreibt: *„**Vollständigkeit** (`gate-undocumented`) prüft gegen genau **eine**
`authority`-Datei — `harness/README.md` §Sensors"*. Das Modul liest die **Datei**, nicht den
Abschnitt — das stellt der Wächter dieses Repos ausdrücklich fest
(`test/targets-modul-wiring.bats:49-53`: *„scannt die GANZE Datei — sie kennt kein
Heading-Scoping"*). **Heute fällt beides zusammen**, weil jede `make X`-**Tabellenzeile** der Datei
innerhalb von §Sensors (inkl. Unterabschnitt §Werkzeuge) liegt:

```sh
grep -n '^#\{1,3\} ' harness/README.md | sed -n '5,7p'   # 40: ## Sensors … 60: ### Werkzeuge … 88: ## Traceability
grep -cE '^\|.*`make [a-z][a-z0-9-]*`.*\|$' harness/README.md                 # 28
awk 'NR>=40 && NR<=87' harness/README.md | grep -cE '^\|.*`make [a-z][a-z0-9-]*`.*\|$'   # 28
```

Latent, nicht gegenwärtig: Eine `make X`-Tabellenzeile außerhalb §Sensors — etwa in
§Safety and scope boundaries — wäre autoritäts-deckend, während der Vertrag das Gegenteil zusagt.

- **verifizierbar:** nein (kein Gate liest Sensor-Prosa).

### LOW-3 — Der Kopf des Wächters und sein Funktions-Kommentar sagen Verschiedenes über denselben Scope

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7
- **pfad:** `test/targets-modul-wiring.bats:5` gegen `:49-53`
- **klasse:** zwei Kommentare derselben Datei beschreiben dieselbe Mechanik unterschiedlich

Der Dateikopf sagt: *„jeder dort genannte Name steht entweder als `make X`-Tabellenzeile in der
`authority`-Datei (harness/README.md §Sensors) oder in `exempt-targets` — **nie in beiden**, nie in
keinem."* Für die `authority`-**Datei**, wie das Modul sie liest, ist das falsch:

```sh
comm -12 <(sed -n '/^targets:/,/^ignore-refs:/p' .d-check.yml | grep '^    - ' | sed 's/^    - //' | sort -u) \
         <(grep -E '^\|.*`make [a-z][a-z0-9-]*`.*\|$' harness/README.md | grep -oE '`make [a-z][a-z0-9-]*`' \
           | tr -d '`' | sed 's/^make //' | sort -u) | wc -l    # 17
```

Der Funktions-Kommentar 40 Zeilen darunter trennt sauber (Scope ist Absicht, das stärkere
Invariant gilt für §Sensors). Der Kopf zieht nicht nach und gleicht „authority-Datei" mit
„§Sensors" — derselbe Kurzschluss wie LOW-2, hier neben seiner eigenen Korrektur.

- **verifizierbar:** nein.

### INFO-1 — Liefer-Punkt 3 hinterlässt im Diff kein Artefakt; nachgeprüft ist er trotzdem

- **kategorie:** INFO
- **quelle:** Plan §2 Punkt 3 („Feuert keiner, ist das ebenfalls ein Ergebnis und wird mit der geprüften Kandidatenzahl notiert")
- **pfad:** —

Kein `git mv` nach `harness/conventions/done/`, kein Text im Diff. Das ist **kein** Defekt: Der
Ort für das Ergebnis ist die Closure-Notiz, und die schreibt der Planner
([`AGENTS.md`](../../AGENTS.md) §3.10). Nachprüfbar ist die Kandidatenmenge, und sie ist gewandert:

```sh
ls harness/conventions/MR-*.md | wc -l   # 54 aktive Eintraege (Plan: 52, vor MR-056/MR-057)
# Kandidaten-Schleife aus Plan §2 Punkt 3
… | wc -l                                 # 23 (Plan: 21)
```

**Die zwei Grenzfälle sind nachgeprüft und der Befund des Laufs trägt.** `MR-032` und `MR-039`
binden ihren Auflösungs-Trigger an die Migration dieses Blocks in die Verzeichnis-Form; die ist
erfolgt, aber durch eine **Repo**-Entscheidung, nicht durch `v6.7.2`. Beide tragen bereits eine
Kopf-Marke auf [`MR-046`](../../harness/conventions.md#mr-046--die-verzeichnis-position-ist-binär-und-trägt-die-kopf-marke-nicht),
die ihre Setzungen ausdrücklich fortschreibt (*„die Verzeichnis-Position ist binär und trägt die
Teil-Ablösung nicht"*). Nicht retirieren ist richtig. Die Aussage „0 von 21 feuern" selbst konnte
ich nicht gegen ein Repo-Artefakt halten — sie steht nur im Lauf-Bericht.

### INFO-2 — Zwei Zeilen des Nachweises mit Ziel `slice-225` haben im Diff keinen Beleg

- **kategorie:** INFO
- **quelle:** Plan §2 Punkt 2 („erfüllt, wenn **jede** Zeile des Nachweises mit Ziel `slice-225` einen Beleg im Diff hat"); `slice-224` §9
- **pfad:** `docs/plan/planning/done/slice-224-delta-nachweis-und-planungs-nachzug.md` §9

Sechs Zeilen tragen `slice-225`. Vier sind belegt (`grundlagen-harness-dateien.md`,
`grundlagen-source-precedence.md`, `AGENTS.template.md`, `harness/README.template.md`;
`harness/conventions.template.md` ist über `MR-000`/`MR-057` mitbelegt — `harness/conventions.md`
führt selbst keine ID-Schema-Zeile, `grep -n 'ID-Schema' harness/conventions.md` → eine Zeile über
ein **Zensus-Muster**). Ohne Beleg bleiben:

- `lab/regelwerk/modul-13-quality-gates.md` — „Deklarations-Sensor · `kein Gate`-Markierung in der
  Zeile selbst · Grenzen-Pflicht je Gate". Der Bestand erfüllt das sichtbar (Werkzeuge-Tabelle
  trägt `kein Gate` in der Bindungs-Spalte, `ls harness/sensors/*.md | wc -l` → 15), aber der Lauf
  sagt es nirgends.
- `lab/templates/.d-check.yml` — Doku-Kommentare zu `targets`/`reviews`. **Hier widersprechen sich
  zwei Pläne:** §9 adressiert `slice-225`, dessen §1 schließt die emittierte Vorlage aus und nennt
  `slice-210/211/212/213` als Adresse. Die Sendung hat damit zwei Empfänger und keinen eindeutigen.

Kein Befund am Diff — ein Posten für die Closure, die nach Plan §2 genau diese Deckung feststellt.

---

## Negativbefunde (geprüft, ohne Befund)

- **§3.8 Commit-Zuschnitt.** Drei Commits, jeder nennt die Rolle und `slice-225`. `3c2b4d82`
  berührt ausschließlich Architect-Artefakte (`AGENTS.md`, `harness/conventions.md`, zwei Einträge);
  `99bfd1c5`/`fae7b7d1` berühren keines. `git show --stat` je Commit geprüft.
- **§3.4 ADR-Immutabilität.** Keine Datei unter `docs/plan/adr/` im Diff
  (`git diff --name-only 99bfd1c5^..fae7b7d1`).
- **§3.11 / Adress-Form.** `MR-057` und die neue Kopf-Marke in `MR-000` zeigen auf die
  **Index-Zeile** (`../conventions.md#mr-…`), nicht auf die Eintrags-Datei — wie die Vorlage es
  verlangt, damit ein späterer `git mv` nach `done/` nichts bricht.
- **`MR-032`-Form der Kopf-Marke.** Die dritte Marke in `MR-000` folgt Setzung 1 wörtlich
  (`> **ÜBERHOLT: <Reichweite> → <Ziel>.** <Fortgeltung>`), wird vom **ablösenden** Eintrag in
  derselben Änderung gesetzt (Setzung 3), ersetzt kein Zeichen des Rumpfs
  (`git show 3c2b4d82 -- harness/conventions/MR-000-…`: 2 Zeilen additiv), und die beiden älteren
  Marken bleiben unangetastet.
- **`MR-046` / Verzeichnis-Position.** `MR-000` bleibt in `harness/conventions/`; die Position
  trägt die Teil-Ablösung nicht. Richtig.
- **`AGENTS.md` §4 gegen die Ziel-Fassung.** Der Ersatztext ist der Wortlaut aus
  `.harness/baseline/v6.7.2/templates/AGENTS.template.md` §4, plus ein additiver Absatz, der die
  maschinelle Deckung **und ihre Grenze** benennt („greifen nur an Tabellenzeilen; die
  Prosa-Hälfte trägt kein Gate") — die ehrliche Form nach `LH-QA-01`, keine neue Zusage.
  ``grep -cE '^\| `make ' AGENTS.md`` → **0**.
- **Was §4 verloren hat.** Vier Angaben standen nur dort. Drei sind Chronik (`(slice-057)`,
  `(slice-027)`) oder waren veraltet (`docs-check` als „links/anchors/ids/codepaths" — vier von
  acht Modulen). Die vierte, sachliche — Vorwärm-Stufe und `-count=1` für `make test` — steht
  weiter an zwei Orten: `Dockerfile:40` (Kommentar) und `MR-050`. Der `comment-claims`-Prüfbereich
  steht vollständiger in `harness/sensors/comment-claims.md`, `ADR-0022` ist an 81 Dateien
  referenziert. **Keine Aussage ist ersatzlos verschwunden.**
- **Die zwei §3.7-Notationsstellen.** Die Unterscheidung trägt. Gezogen ist die **vorschreibende**
  (Aufzählung der Herkunfts-Anker-Formen → `· seit welle-<Kennung>` / `· seit slice-<Kennung>`),
  stehen bleibt die **zitierende** (`grep -c 'seit slice-<NNN>' …` → 0 gegen
  `grep -c 'seit slice-<Kennung>' …` → 3; beide Zahlen reproduziert). `git grep -nE
  'slice-<NNN>|welle-<NN>' -- AGENTS.md` → genau **1** Treffer, und das ist das Suchmuster. Der
  umgebende Absatz ist mitgezogen: Er sagt nicht mehr „Divergenz, nicht entschieden", sondern
  benennt `MR-057` als die Deklaration — inhaltlich richtig, weil §Vergabe des adoptierten Stands
  die Namens-Form führt und die Deklaration ausdrücklich verlangt.
- **`MR-057` gegen die Vorgabe.** Setzung 1 ist wörtlich die Form aus
  `grundlagen-source-precedence.md` §Vergabe (Präfix eines vorhandenen Ankers oder freier Slug;
  `slice-<welle-name>-<aspekt-slug>` während einer Welle) — übernommen, nicht erfunden. Setzung 2
  ist die Auftraggeber-Entscheidung (Namen ab jetzt, kein Nachrüsten), wie `slice-224` §9 sie
  festhält. Setzung 3 (Platzhalter `<Kennung>` nur dort, wo eine **lebende** Regel die Form
  vorschreibt) geht über die Vorgabe nicht hinaus, sondern zieht ihre unmittelbare Folge. Die
  Einordnung „keine Abweichung, sondern die von der Baseline verlangte Deklaration" trägt: §Vergabe
  setzt die Form **und** schreibt *„Welche Form gilt, deklariert das Repo — in
  `harness/conventions.md`"* (beide `grep -c` → 1), und der Absatz, der bis `v6.0.0` dichte Nummern
  lizenzierte, ist gestrichen (`grep -c 'dichte Nummern'` → 0). Der Cutoff ist keine Abweichung,
  sondern die Nichtrückwirkung, die derselbe Abschnitt für das Bereichssegment ausdrücklich führt.
- **`gate-phantom` nach dem Wechsel.** Rot gesehen, eigene Sonde: eine Tabellenzeile
  `` | `make gibtesnicht` | Sonde | `` in `AGENTS.md` liefert `AGENTS.md:522 gibtesnicht
  gate-phantom`. `doc-tables` führt die Datei weiter, obwohl sie keinen Index mehr trägt — die
  Behauptung des Architect-Laufs ist reproduziert.
- **Der `targets`-Wächter in `make test`.** Die Umstellung von `AGENTS.md` auf den §Sensors-Scope
  von `harness/README.md` ist notwendig und begründet (ohne Scope liefe er gegen die
  Werkzeuge-Tabelle); das engere Invariant „Sensors-Zeile und `exempt-targets` sind disjunkt" gilt
  (`comm -12` → leer). Nur sein Dateikopf zieht nicht nach (LOW-3).
- **§3.9 Docker-only.** Keine Host-Toolchain im Diff; alle meine Sonden liefen über `make`-Pins
  bzw. den gepinnten Digest, `--network none`, Mount `:ro`.
- **Feldform von `MR-057`.** `Adaption:` und `Begründung:` fehlen (der Eintrag führt stattdessen
  `Setzung 1–3`). Das ist Bestandsform, nicht slice-eigen — `grep -ho '^- \*\*[^:*]*:\*\*'
  harness/conventions/*.md | sort | uniq -c` zeigt `Adaption:` in 26 von 54 Einträgen. Kein Finding.
- **Nicht geprüft, ausdrücklich:** die DoD-Abhakung · `make gates`, `make test`, `make mutate`,
  `make full-smoke` als Ganzes · die emittierte Ebene (`internal/emit/**`) · die Frage, ob die
  übrigen 21 Retirement-Kandidaten je einzeln richtig beurteilt sind (ich habe die Kandidatenmenge
  reproduziert und die zwei benannten Grenzfälle geprüft, nicht alle 23) · `slice-226`/`slice-227`
  als Adressen ihrer Sendungen.

---

## Kategorie-Summary

| Kategorie | Anzahl | Klassen |
|---|---|---|
| HIGH | 1 | Senkungs-Prüfung misst nur die Richtung, die nicht gesunken ist |
| MEDIUM | 3 | `mess-zusage-trifft-das-eigene-zitat` · fällige Arbeit ohne aufnehmende Kennung · Zustandsfeld behauptet einen überholten Zustand |
| LOW | 3 | Deixis zeigt auf das Gegenteil · Vertrag enger als das Werkzeug · zwei Kommentare, zwei Scopes |
| INFO | 2 | Ergebnis ohne Artefakt im Diff · Nachweis-Zeile mit zwei Empfängern |

## Verdikt

**Blockierend** — wegen HIGH-1 und MEDIUM-1/2/3.

Die Arbeit selbst ist sauber geschnitten und der Norm-Nachzug ist präzise: Die Ziel-Form ist
wörtlich übernommen, die Kopf-Marken-Mechanik stimmt, die Notations-Unterscheidung trägt, und der
Architect hat die Phantom-Richtung wirklich rot gesehen. Blockierend ist **nicht**, dass der
`authority`-Wechsel gemacht wurde — er ist alternativlos —, sondern dass seine gemessene
Lockerungs-Richtung durch eine Messung wegerklärt wird, die sie nicht erfasst. §3.5 kennt dafür
einen Weg (ADR), der Plan-Kopf einen zweiten (Meldung an den Auftraggeber); beide sind billiger als
die stille Variante. MEDIUM-1 ist eine Zeile, solange nicht gepusht ist, und ein Nachfolge-Eintrag
danach. MEDIUM-2 braucht eine Kennung, keine Arbeit. MEDIUM-3 sind zwei Wörter.

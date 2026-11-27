# Review — slice-environment-check-fuehrt-die-gates

**Datum:** 2026-11-27 · **Reviewer-Lauf:** frischer Kontext (Modul 10, `.harness/skills/reviewer.md` v2.3.0)
**Bezug:** Slice-Plan `docs/plan/planning/in-progress/slice-environment-check-fuehrt-die-gates.md` ·
[`ADR-0109`](../../docs/plan/adr/0109-gates-lauefer-docker-los-image-weg-opt-in.md) ·
[`MR-098`](../../harness/conventions/MR-098-die-umgebungs-zusage-traegt-mischform-die-dogfood-gates-und-lab-laeufer-fahren-am-host.md) ·
`AGENTS.md` §3.9 (Fassung nach dem Architect-Zug) · Baseline-Vorlage
`.harness/baseline/v7.0.0/templates/harness/sensors/environment-check.template.md`
**Diff:** `81fc3ddc` (Code+Tests), `9297bd70` (Doku), `7cb85890` (`.viper.sh`, Fremdcommit — nur
gewichtet, nicht gerügt als Slice-Artefakt), `44e0594b` (Pin-Nachzug 1.27.3 → 1.27.4, im Slice-Gegenstand — geprüft, s. u.)
**Umgebung:** Docker-Daemon aus (Auftraggeber). `make gates` / `make test` / `make docs-check`
nicht gefahren — Prüfung manuell (read/grep/`make -n`, Formen-Proben docker-los gegen Skript-Kopie).
**Negativbefund-Voraussetzung:** alle Formen-Proben lief docker-los im `/tmp`; kein Rest im Baum.

---

## Findings

### F-1 · MEDIUM — Mutations-Anlagen 795–798: `# expect:` nennt keinen Wächter, den die Mutation färbt

- **kategorie:** MEDIUM
- **quelle:** [`MR-071`](../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand), [`MR-090`](../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit), `AGENTS.md` §3.6
- **pfad:** `test/mutations/795-go-pin-paarung-verliert-inventar-quelle.sh:3`, `796-go-soll-driftet-gegen-makefile-pin.sh:3`, `797-exakt-paarung-zerzaegt.sh:3`, `798-aufform-faehrt-still-durch.sh:3`
- **befund:** Der Treiber prüft Bedingung 4, indem er die **Fehlschlag-Form-Zeilen** der Sensor-Ausgabe
  (`not ok [0-9]+` für `verify: test-bats`; `harness/tools/mutate.sh:619-622` und `905` im diff-Kontext,
  `failure_form` in `mutate.sh` Kopf) nach dem `expect`-Text durchsucht (`grep -qF`). Die vier
  `# expect:`-Zeilen tragen Erzählungen, keine Testnamen; der tatsächlich rot färbende Wächter trägt
  einen anderen Namen — bei 797 und 798 nennen die **Fallkörper** selbst den richtigen Namen
  („Rot faerbt test/environment-check.bats, Test "exakte Abweichung färbt Umgebungs-Befund mit
  Werkzeug, Soll und Ist"" bzw. „Test "Inventar-Aufform färbt fail-closed""), während der `# expect:`-Kopf
  daneben eine andere Zeile trägt. Für 795/796 ist der rot färbende Wächter
  `pinsync: das Pin go paart die Inventar-Soll-Zeile abgeleitet gegen die GO_VERSION-Stelle des Makefile`
  (`test/pinsync-modul-wiring.bats`, neu; `grep -qF` auf die Quellen-Zeile bzw. der Gleichheits-Vergleich).
- **verifizierbar:** ja — ein `make mutate`-Lauf über die vier Fälle meldet je
  „rot, aber '<expect>' faellt nicht — falscher Grund" (Bedingung 4), obwohl die Mutation greift
  (alle vier `sed`-Muster greifen am Ist-Bestand, 796 nach dem Pin-Nachzug auf 1.27.4 — Beleg unten).
  Docker-gebunden, hier nicht fahrbar; der nächtliche Mutations-Workflow hat das.
- **klasse:** „Mutations-Anker benennt den Wächter nicht, den die Mutation färbt"

Belege (gelesen, nicht gefahren — Sensor docker-gebunden):

```console
$ grep -h '# expect:' test/mutations/79[5-8]*.sh
# expect: pinsync: das Pin go verliert seine Inventar-Quelle — …        (nicht in einem Testnamen)
# expect: pinsync: das Inventar-Soll der Zeile go driftet byte-genau …  (nicht in einem Testnamen)
# expect: environment-check: die exakte Soll-Paarung wird zersaegt …    (nicht in einem Testnamen)
# expect: environment-check: die Aufform exit-Klasse (2) faehrt still … (nicht in einem Testnamen)
$ grep -A2 '@test "pinsync: das Pin go' test/pinsync-modul-wiring.bats   # Testname: „das Pin go paart …"
```

### F-2 · LOW — alter pinsync-Kommentar in `.d-check.yml` widerspricht dem zweiten Pin

- **kategorie:** LOW
- **quelle:** `AGENTS.md` §3.7 (Cutoff: wer eine solche Zeile ohnehin anfasst, zieht sie nach)
- **pfad:** `.d-check.yml:84-96`
- **befund:** Der Bestands-Kommentar trägt unverändert „Genau ein Pin, zwei Quellen" und „Positiver
  Beleg in der Ausgabe: die Zeile `pinsync: 1 Pin(s) geprueft` — fehlt sie, ist der Block nicht aktiv".
  Der Diff legt den ZWEITER-Pin-Block direkt darunter an („die Zeile `pinsync: 2 Pin(s) geprueft.
  4 Quelle(n) gelesen`") und zieht `harness/sensors/docs-check.md` auf „**zwei** Pins" — der alte
  Kommentar trägt jetzt eine falsche Positiv-Beleg-Zeile und eine falsche Pin-Zahl, der greifende
  Leser von Doku-Output gegen Konfig-Kommentar liest zwei Antworten.
- **verifizierbar:** ja — `make docs-check` färbt das nicht (Kommentar-Text, kein Link); nur gelesen.
- **klasse:** „Konfig-Kommentar trägt veraltete Positiv-Beleg-Zeile gegen denselben Block" (Doku-Drift)

### F-3 · INFO — „environment-check fährt stets voll" misst am Rückenstand und steht nur am Target

- **kategorie:** INFO
- **quelle:** Maintainability (Zusage über einer Konstellation, die erst mit `slice-gates-pruefgegenstand-stempel-v1` existiert)
- **pfad:** `Makefile` (Target-`environment-check`-Kommentar, `# je-Check-Key … fährt voll`)
- **befund:** Die Fast-Pfad-Kopplung wird am Target-Kommentar zugesagt, an keiner Sensor-Doku
  (`sensors/gates.md`, `sensors/environment-check.md`) und nicht in ADR-0108 nachgetragen. Verifiziert:
  auf `main` ist `harness/tools/gates-keys.sh` byte-identisch mit `harness/tools/gates-fast.sh`
  (`diff` leer; beide seit `413b6b50`) — die Subkommandos `liste`/`key`/`stamp` des Satzerzeugers
  existieren als solche nicht, `gates-fast.sh:123` ruft genau diese Datei (`gates-keys.sh liste`),
  das denselben Wrapper-Inhalt trägt; der Satzerzeuger-Weg des Tier-2-Fast-Pfads ist am Rückenstand
  nicht klassifizierbar. Die Aussage „die Tafel-Menge trägt ihn nicht → er fährt voll (ADR-0108
  Festlegung 1)" bezieht sich auf eine Semantik, die erst mit dem Schwesterslice (in-progress) liegt.
- **verifizierbar:** ja — nach Landung des Schwesterslice: SKIP-/Teildrift-Ausgabe von `make gates`
  (environment-check ist in keiner `liste`, fährt in SKIP/Teildrift keinen Lauf — der Satz „fährt
  voll" ist dann nur über den Vollsatz wahr).
- **klasse:** „Zusage über einem Rückenstand statt über dem Landungs-Stand" (dokumentationswürdige Annahme)

### F-4a · LOW — `.viper.sh` trägt apt-Form an brew; die einzig mögliche Nutzung scheitert

- **kategorie:** LOW
- **quelle:** Maintainability (latente Wartungsfalle)
- **pfad:** `.viper.sh:1`
- **befund:** `brew install -y bats-core shellcheck actionlint bats go` — `-y` ist die apt/npm-Form;
  brew fragt nicht nach Bestätigung und trägt dieses Flag nicht, zudem steht „bats" neben „bats-core"
  (dasselbe Formel-Paar). Die Installations-Hilfe fällt an genau dem Aufruf, für den sie abgelegt ist.
  Rot-Beleg steht aus: brew am Host in der Befehlsposition ist gebunden (§3.9), der Inhalt wird von
  keinem Sensor gelesen — die Fehlform ist nur gelesen, nicht gefahren.
- **verifizierbar:** nein (kein Träger liest die Datei; ein Lauf über brew am Host deckt sie höchstens beiläufig)
- **klasse:** „Installations-Hilfe trägt die Aufruf-Form eines anderen Paketmanagers"

### F-4b · INFO — `.viper.sh` ist eine Ablage ohne Träger und ohne Abdeckung

- **kategorie:** INFO
- **quelle:** Maintainability — bewusste Won't-Fix-Designnotiz des Fremdcommits
- **pfad:** `.viper.sh:1`
- **befund:** Die Datei ist kein Target, kein Gate, wird von keiner Doku referenziert (Repository-weite
  Textsuche: nur der Commit) und liegt außerhalb jeder Lint-Abdeckung (shell-lint: Hooks,
  `harness/tools/`, bats-Rümpfe). §3.9 bindet die **Befehlsposition** — der Inhalt eines abgelegten
  Skripts ist keine; der Guard bleibt in Kraft. Ihre einzige Vertragsquelle ist die Commit-Message
  („kein Make-Target"); eine Zusage, die kein Lauf deckt, trägt sie deshalb nicht — sie ist Deklaration,
  nicht Beleg. Message-Kennung (slice-* als Beleg-Anker, LH-QA-03) vorhanden.
- **verifizierbar:** nein (bewusst; kein Sensor liest sie)
- **klasse:** „Unreferenziertes Werkzeug-Hilfsskript im Baum ohne Abdeckungs-Anker"

---

## Formen-Probe (Fähigkeiten der Aufzählung, selbst gefahren — docker-los, Skript-Kopie in `/tmp`)

Die Grenzen-Aufzählung im Skriptkopf („AUFFORM … unlesbares oder leeres Inventar, Zeile mit anderer
Spaltenzahl, unbekannte Pruefform oder unbekannter Pflichtgrad, Soll-Feld ohne Quelle, Faehigkeits-Soll
mit unbekannter Probe-ID") wurde gegen eine Kopie mit je-einer Formprobe gefahren:

| Gefahrene Form | Ergebnis |
|---|---|
| 7 statt 6 Spalten | `AUFFORM — Zeile 1 trägt 7 statt 6 Spalten`, exit 2 |
| unbekannter Pflichtgrad (`andere`) | `AUFFORM — … unbekannter Pflichtgrad`, exit 2 |
| leeres Werkzeug-Feld | `AUFFORM — Zeile 1 ohne Werkzeug`, exit 2 |
| fremde Probe-ID (`manifest:probe:fremd-id`) | `AUFFORM — … trägt nicht die Probe-ID des Skripts`, exit 2 |
| Inventar ohne Zeile (nur Leerzeile) | `AUFFORM — Inventar … ohne Zeile`, exit 2 |
| führendes Leerzeichen im Werkzeug-Feld | exit 1, **lauter** Befund `umgebung:  go … Ist: fehlt` (nicht still) |
| `abgeleitet:` ohne Wert | `AUFFORM — … Soll ohne Wert`, exit 2 |
| CRLF-Zeilenende | exit 0 (Grün, keine Deklaration — harmlos, Spaltenzahl stimmt) |

Keine gefahrene Form fällt außerhalb der im Kopf genannten Aufzählung; die Aufzählung trägt
(negativbefund: Formen-Probe geführt und ohne Abweichung abgeschlossen).

---

## Negativbefunde — geprüft, ohne Befund

- **§3.9 am Skript** (`harness/tools/environment-check.sh`): kein Host-Toolchain-Aufruf außerhalb des
  Inventar-Zwecks; der `BASH_VERSINFO`-Guard steht als erster Top-Level-Befehl (Zeile 59, vor
  `set -euo pipefail`, nur Builtins) — strukturell gehalten durch
  `test/environment-check.bats` („der bash-Guard steht als erster Top-Level-Befehl"); unlesbares
  Inventar exit 2 (selbstprobe, oben). `make environment-check` existiert (`make -n`).
- **Inventar gegen MR-098, Setzung 1:** alle Werkzeuge der MR-Tafel (git, bash, make, GNU-Werkzeuge,
  bats, shellcheck, actionlint, d-check) tragen je eine Zeile mit Prüfform/Grund; `go` als einzige
  Pin-Stelle abgeleitet (Dockerfile-`ARG` exakt als dritte, ungepaarte Wertelage benannt —
  `.d-check.yml` Grenzen; nicht das `go.mod`-Paar); `docker` trägt keine Zeile —
  konsistent mit §3.9 („docker ist Werkzeug-Weg, nicht Gate-Pflicht"). Die Unterbestimmung
  *Anwesenheit* (bats/shellcheck/actionlint/d-check ohne Versions-Soll) ist an drei Stellen
  deklariert (Inventar-Grund, Skriptkopf Grenze 4, Sensor-Text Grenze 5) — [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)-Unterbestimmung
  bewusst benannt, nicht still; sie erzeugt keine unbelegte Zusage.
- **Prüfform-Menge als eine Quelle:** die normative Fassung trägt SPEC-099 (geschlossene Menge,
  Kombinations-Paarungen, drei Exits); Skriptkopf („VERTRAG: Spezifikation SPEC-099") und
  Sensor-Text verweisen darauf, statt eigenständig zu setzen. Keine zweite Definitions-Stelle mit
  abweichender Fassung gefunden (Terminologie „Auform/AIFFORM" variiert — ohne Inhalts-Drift).
- **Gates-Kante:** `make -n record-gates` → `environment-check` als erster Voraussetzung vor
  `baseline-verify`; das `make gates`-Rezept unverändert; die neue Harness-README-Zeile steht als
  erste Sensors-Zeile mit Bindung LH-QA-02/LH-QA-03; `sensors/gates.md`-Kanten-Zitat nennt die
  Ist-Reihenfolge (`environment-check baseline-verify … span-check`); `sensors/environment-check.md`
  füllt die Vorlage vollständig (Vertrag, Inventar-Ort, Soll-Quelle Mischform, Grenzen 1–6, Exits
  0/1/2, Sperren, Bindung) — kein Abschnitt geleert.
- **SPEC-099:** steht als erste Zeile der §7-Tabelle („Festlegungen der Harness-Werkzeuge" — die
  Tabelle trug zuvor keine Zeile; kein § durch den Historie-Zusatz geleert); Historie-Zeile ergänzt;
  Referenz-Richtung: die Festlegung nennt den Slice nicht (Werkzeug-Name statt Slice-Bezug, Historie
  außerhalb der Festlegung).
- **Mutations-`sed`-Anker am Bestand (MR-071):** alle vier Muster greifen am Ist-Bestand
  (795: Quellen-Zeile vorhanden; 796: nach `44e0594b` auf `1.27.4` nachgezogen; 797/798: Ziel-Zeilen
  im Skript vorhanden — Range-Anker statt Zeilennummer); `# files:` je Fall löst auf die tatsächliche
  Zieldatei.
- **Nur docker-gebundene Zähne:** der pinsync-Verhaltens-Zahn (`pinsync-mismatch` im `docs-check`-Lauf)
  hat keinen Treiber-Fall — deklariert in `sensors/docs-check.md` §Grenze („der Treiber kennt keinen
  docs-check-Modus"); sein rot gesehener Beleg steht bis zum Docker-los-Umzug übergabeweise aus;
  795/796 fahren über den docker-los-Config-Wächter (`test/pinsync-modul-wiring.bats`) — beide Wege
  sind benannt, keine unbenannte Lücke.
- **bats-Wächter (`test/environment-check.bats`):** der gelebte-Bestand-Form-Test trägt die
  Mengen-nicht-leer-Sonde (`zeilen -ge 10`, mit echo'd Soll) über dem neuen Vertrag; die
  Assertions sind Teilzeichenketten über stabilen Ausgabe-Formen; die docker-gebundene bats-Stufe
  selbst ist unverändert Rückstand — im Kopf der Datei als Grenze deklariert („was hier nicht
  gemessen wird"), im Plan §1 als Schicht-Abgrenzung ([`slice-labor-gates-host-rezepte`](../../docs/plan/planning/next/slice-labor-gates-host-rezepte.md)).
- **Pin-Nachzug `44e0594b`** (nach den Slice-Commits): Dockerfile, Makefile, Inventar-Soll,
  Go-Fallbacks der Smoke-Skripte und Fall-796-Anker im selben Zug — die pinsync-Paarung trägt
  byte-gleich; nichts vom Slice-Vertrag ist durch den Nachzug still geworden.
- **`.viper.sh` und der Guard:** die Datei ist Inhalt, keine Befehlsposition; der PreToolUse-Guard
  bleibt unangetastet (nicht einmal gelesen-Änderung an `.claude/`).
- **Link-/Kennungs-Anker:** `ADR-0109`, `ADR-0108`, MR-098, SPEC-099 (`#7-festlegungen-der-harness-werkzeuge`),
  LH-QA-02/03 lösen an ihren Zielen (Dateien existieren, §-Anker manuell gegen die Heading-Formen
  geprüft); Implementer-Aussage „gates-keys.sh trägt denselben Inhalt wie gates-fast.sh" verifiziert
  (diff → IDENTISCH, siehe F-3).
- **Make-Gates:** nicht gefahren (Daemon aus, Auftraggeber) — der Verifikations-Bericht trägt den
  Gates-Lauf; hier nur `make -n` (Trockenlauf) und docker-lose Formen-Proben.

## Restrisiken (übergeben, nicht gerügt)

- Die drei rot gesehene Belege am Skript sind im Kopf protokolliert (Vorlage-Form), der
  `make gates`-Echtlauf auf diesem Host (Closure-Trigger §5) und CI-Nachweis stehen aus — Verifier.
- `make test` → `test-bats` fährt im gepinnten bats-Image: bei ausgelassenem Daemon färbt die
  Kante am Docker vor dem ersten Wächter — Rückstand der Welle-ohne-docker, deklariert.

---

## Addendum — Abgleich-Runde (2026-11-27, Commit `4a61da9f`)

Die Implementer hat F-1 und F-2 im Commit `4a61da9f` gelöst (nur die vier Fall-Anlagen +
`.d-check.yml`). Belege dieses Addendums sind gelesen und byte-genau gegen den Bestand geprüft;
`make mutate-greift` (Implementer-Lauf) meldet 795–798 ohne Befund, die drei vorgefundenen Befunde
(784/785/794 — gates-*-Maschinerie des Schwesterslice `slice-gates-pruefgegenstand-stempel-v1`)
unverändert.

### F-1 · gelöst

Die vier `# expect:`-Köpfe tragen jetzt wortgenau den Titel des Wächters, den die Mutation färbt,
byte-genau gegen die `not ok`-Zeilen (`grep -qF`-Form des Treibers):

- 795/796: `pinsync: das Pin go paart die Inventar-Soll-Zeile abgeleitet gegen die GO_VERSION-Stelle
  des Makefile` — byte-identisch mit dem `@test`-Titel in `test/pinsync-modul-wiring.bats:53`
  (Probe: `grep -qF … test/pinsync-modul-wiring.bats` → Treffer).
- 797: `environment-check: exakte Abweichung färbt Umgebungs-Befund mit Werkzeug, Soll und Ist` —
  byte-identisch mit `test/environment-check.bats:46`.
- 798: `environment-check: Inventar-Aufform färbt fail-closed` — byte-identisch mit
  `test/environment-check.bats:91`.
- Fall 796 nennt im Körper zusätzlich den faerbenden Wächter und den Pin-Nachzug (1.27.4,
  `44e0594b`); die `sed`-Muster greifen unverändert am Bestand (MR-071-Anker unberührt).
- Der `make mutate-greift`-Lauf bestätigt die Zähne (781 griffen, 795–798 ohne Befund).

### F-2 · gelöst

Der pinsync-Kommentar in `.d-check.yml` trägt jetzt zwei Pins im Indikativ („Zwei Pins: der
d-check-Werkzeug-Pin paart … der go-Pin paart …"), die Positiv-Beleg-Zeile ist auf
`pinsync: 2 Pin(s) geprueft, 4 Quelle(n) gelesen` nachgezogen, die Mutations-Anker sind je Pin
benannt (790 d-check-Pin, 795/796 go-Pin) — die Kontradiktion zum ZWEITER-Pin-Block und zu
`sensors/docs-check.md` ist entfallen.

### Verbleibend offen

- **F-3 · INFO** — die Fast-Pfad-Kopplung des Target-Kommentars („Kanten-Check ohne zeigbare
  Tafel-Zeile fährt voll") misst am Rückenstand (`gates-keys.sh == gates-fast.sh`, kein
  Satzerzeuger) und steht weiterhin nur am Target, nicht in der Sensor-Doku; deklarierte Grenze,
  Träger ist das Schwesterslice `slice-gates-pruefgegenstand-stempel-v1`. Kein weiterer Zug in
  diesem Slice.
- **F-4a · LOW → widerlegt** — der Auftraggeber-Lauf hat die Zeile `.viper.sh` empirisch
  ausgeführt (Werkzeuge am Host installiert) und die Behauptung „scheitert an `-y`" damit
  außerhalb dieses Laufs widerlegt; die Beobachtung dieses Reviews war nur gelesen, nie gefahren.
  Refuted nur mit Beleg: der Beleg ist der Auftraggeber-Lauf, nicht ein Sensor dieses Repos.
- **F-4b · INFO** — bleibt Deklaration (unreferenziertes Hilfsskript ohne Träger und Abdeckung);
  bewusste Designnotiz des Fremdcommits, kein Zug angefordert.

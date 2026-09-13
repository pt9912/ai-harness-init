# Verifikation slice-225 — Der Gate-Index steht einmal, die Norm-Ebene zieht nach, Retirement-Runde

**Rolle:** Verifier · **Datum:** 2026-09-13 · **Geprüfter Stand:** `4fb6ad56` (HEAD, `main`),
`git status --porcelain` leer · **Plan:**
[`slice-225`](../plan/planning/in-progress/slice-225-gate-index-steht-einmal.md) (weiterhin
`in-progress/`, kein DoD-Häkchen gesetzt, §7 Platzhalter — konsistent mit `AGENTS.md` §3.10:
Closure ist Planner-Arbeit, nicht Teil dieses Laufs) · **Reviews:**
[`2026-09-13-slice-225-…`](2026-09-13-slice-225-gate-index-steht-einmal.md) (1 HIGH · 3 MEDIUM ·
3 LOW · 2 INFO, Verdikt **Blockierend**) und
[`2026-09-13-adr-0045-konsistenzrunde`](2026-09-13-adr-0045-konsistenzrunde.md) (0 HIGH · 4 MEDIUM ·
3 LOW · 3 INFO, Verdikt **Blockierend wegen MEDIUM-1/2/3**, alle drei vor dem Accept-Übergang
behoben) · **Prüfgegenstand:** DoD und Spec (`ADR-0045`, `ADR-0044`) — **nicht** Plan/Hard Rules,
das ist Reviewer-Sache. `make gates` nicht erneut gefahren (Weisung); stattdessen der `targets`-
Modullauf isoliert und Working-Tree-Zustand geprüft.

---

## 0. Vorfrage: Baumzustand

```sh
git status --porcelain          # leer
git rev-parse HEAD              # 4fb6ad5696574e1e7d8269aeb5748c758f6404f7
```

Kein Parallel-Lauf, kein uncommitteter Rest. `make gates` wurde nicht neu gefahren (Weisung);
stattdessen isoliert das Modul, das dieser Slice tatsächlich ändert:

```sh
REF="ghcr.io/pt9912/d-check@$(sed -n 's/^DCHECK_DIGEST ?= //p' d-check.mk)"
docker run --rm --network none -v "$PWD":/repo:ro "$REF" --config /repo/.d-check.yml --enable targets
# -> d-check: 1236 Datei(en) geprüft, 0 Befund(e)
```

Grün, netzlos, gegen den gepinnten Digest. Das deckt **nicht** die übrigen sieben Module (`links`,
`anchors`, `ids`, `matrix`, `codepaths`, `spans`, `planning`) und keinen der Go-/bats-Gates — dafür
gilt die Auskunft des Auftrags (`make gates` EXIT 0 bei Start dieser Verifikation), nicht meine
eigene Messung.

---

## 1. DoD Punkt für Punkt

### DoD-1 — Der Gate-Index steht einmal, und die Messung liegt daneben

**Erfüllt, materiell verschärft gegenüber der ursprünglichen Formulierung.**

```sh
grep -n 'authority' .d-check.yml | grep 'authority:'
#   authority: harness/README.md
grep -cE '^\| `make ' AGENTS.md
#   0
```

`AGENTS.md` §4 trägt Regel und Zeiger, keine Tabelle mehr. Die im Plan verlangte
Mengen-Differenz-Messung ("verliert kein bisher dokumentiertes Target seine Zeile") ist am
aktuellen Stand leer:

```sh
comm -23 <(git show 99bfd1c5^:AGENTS.md | grep -oE '^\| `make [a-z0-9-]+`' | sed 's/^| `make //;s/`$//' | sort -u) \
         <(grep -oE '`make [a-z0-9-]+`' harness/README.md | sed 's/`make //;s/`$//' | sort -u)
# -> leer
```

**Aber:** Diese Messung deckt nur eine Richtung. Der Reviewer hat mit HIGH-1 eine echte Senkung in
der *anderen* Richtung nachgewiesen (`gate-undocumented` lässt jetzt ein Nicht-Gate-Rezept mit
bloßer Werkzeuge-Tabellenzeile durch, wo es vorher `gate-phantom`-artig zurückgewiesen hätte — real
gemessen: 1 Befund gegen 0 über den beiden Bäumen). Anders als der ursprüngliche Plan-Kopf es
vorsah ("Meldung an den Auftraggeber, kein Eintrag, keine Ausnahme"), ist die Senkung über
[`ADR-0045`](../plan/adr/0045-authority-wechsel-senkt-eine-richtung.md) **gebucht und kompensiert**
worden — das ist der in `AGENTS.md` §3.5 vorgesehene Weg und schärfer als das, was der Plan
ursprünglich verlangte ("Senkungs-Frage beantwortet, nicht erwogen" — jetzt tatsächlich
entschieden, nicht wegerklärt). Damit ist DoD-1 in der Substanz **übererfüllt**: Die Senkung wurde
nicht nur gemessen, sondern durch eine ADR normativ geschlossen.

### DoD-2 — Die Norm-Ebene trägt die übrigen Posten aus slice-224 §9

**Teilweise offen — zwei von sieben `slice-225`-Zeilen ohne Beleg im Diff, eine davon ein echter
Zuständigkeits-Konflikt zwischen zwei Plänen.**

```sh
awk -F'|' '{n=NF; gsub(/^[ \t]+|[ \t]+$/,"",$n); if ($n=="slice-225") print NR}' \
  docs/plan/planning/done/slice-224-delta-nachweis-und-planungs-nachzug.md
# -> 680 683 695 699 700 715 716   (7 Zeilen, nicht 6 wie der Slice-225-Review notiert — INFO-2
#    dort zählte offenbar ohne die conventions.template.md-Zeile mit)
```

Belegt im Diff: `grundlagen-harness-dateien.md` (680, via `AGENTS.md` §4-Umbau),
`grundlagen-source-precedence.md` (683, via `MR-057`), `AGENTS.template.md` (700, dieselbe
Konsequenz), `harness/README.template.md` (715, via LOW-1-Fix in `f9b3c60f`),
`harness/conventions.template.md` (716, via `MR-000`/`MR-057` mitbelegt, wie der Review
begründet). **Ohne Beleg bleiben:**

- `lab/regelwerk/modul-13-quality-gates.md` (695) — "Gate-Index steht einmal"-Konzept. Der Bestand
  erfüllt es sichtbar (`ls harness/sensors/*.md | wc -l` → 15, `kein Gate`-Markierung in der
  Werkzeuge-Tabelle), aber kein Artefakt dieses Diffs sagt das; INFO-1/2 des Slice-Review haben das
  bereits so eingeordnet ("Posten für die Closure").
- `lab/templates/.d-check.yml` (699) — Doku-Kommentare zu `targets`/`reviews` in der **emittierten**
  Vorlage. Slice-224 §9 weist diese Zeile `slice-225` zu; `slice-225` §1 schließt die emittierte
  Vorlage ausdrücklich aus und benennt `slice-210/211/212/213` als Adresse. Ich habe geprüft, ob
  eine dieser vier Adressen die Zeile tatsächlich annimmt:

  ```sh
  grep -n 'reviews:\|targets' docs/plan/planning/open/slice-213-review-report-laeuft-in-der-tabellen-form.md | head
  ```

  `slice-213` behandelt `structure`/`reviews` in der **dogfood**-`.d-check.yml`, nicht die
  Doku-Kommentare der **emittierten Vorlage**. Keiner der vier genannten Slices nimmt diese
  konkrete Zeile an — die Sendung hat, wie schon der Review-INFO-2 vermerkt, **zwei Empfänger und
  keinen eindeutigen**. Das ist kein Diff-Defekt, sondern eine offene Zuordnungsfrage zwischen zwei
  Plänen, die vor der Closure zu klären ist.

**Der Rollenwechsel-Satz, die Kennungs-Notation und der neue Adaptions-Eintrag sind dagegen
sauber belegt** (geprüft, siehe unten):

```sh
grep -n '§3.10\|Kein Self-Review' AGENTS.md | sed -n '1,3p'
grep -n 'reviewer.md' harness/README.md          # Zeile 38 (Guides) + Zeile 132 (Workflow §8)
git grep -cE 'slice-<NNN>|welle-<NN>' -- AGENTS.md   # 1 (die zitierende Stelle, s.u.)
```

`git grep -nE 'slice-<NNN>|welle-<NN>' -- AGENTS.md` liefert genau eine Zeile
(`... grep -c 'seit slice-<NNN>' ... → 0`), und das ist — wie der Reviewer korrekt festgestellt
hat — das **Suchmuster selbst**, kein liegen gebliebener Platzhalter; die vorschreibende Stelle
(`· seit welle-<Kennung>` / `· seit slice-<Kennung>`) ist auf die neue Form gezogen.

### DoD-3 — Retirement-Runde: Was `v6.7.2` auflöst, hat den Adaptions-Block verlassen

**Kandidatenmenge selbst gemessen, weicht erneut vom Plan/Review ab (Bestand bewegt sich weiter);
benannte Stichprobe von 9 der 24 aktuellen Kandidaten unabhängig geprüft, alle bestätigen
"nicht gefeuert".**

```sh
ls harness/conventions/MR-*.md | wc -l
# 55 (Plan: 52, Slice-225-Review INFO-1: 54)
for f in harness/conventions/MR-*.md; do
  awk '/^- \*\*Auflösungs-Trigger:\*\*/{p=1} p{print} p&&/^- \*\*(Datum|Wirksamkeits-Anlass|Geltungsbereich|Ersetzt)/&&!/Auflösungs/{exit}' "$f" \
    | grep -qiE 'baseline|regelwerk|kurs-|upstream|adoptiert|Ziel-Fassung' && basename "$f"
done | wc -l
# 24 (Plan: 21, Review INFO-1: 23)
```

Der Bestand wandert mit jedem Commit — das ist erwartbar (`MR-057`/`MR-058` sind selbst neue
Kandidaten dieses Slice) und entwertet die "0 von N feuern"-Aussage nicht per se, sofern die
zusätzlichen Kandidaten tatsächlich nicht feuern. **Benannte Stichprobe** (9 von 24, ausgewählt
nach dem Kriterium "Trigger nennt eine konkret prüfbare Bedingung gegen einen künftigen
Baseline-Stand", zusätzlich zu den zwei vom Reviewer bereits geprüften Grenzfällen):

| Kandidat | Trigger-Bedingung | Geprüft gegen `v6.7.2` | Ergebnis |
|---|---|---|---|
| `MR-026` | Re-Baseline, deren AGENTS-Vorlage einen deckenden Hard-Rule-Satz führt | Eintrag benennt selbst, dass der §3.7-Fall bereits eingetreten und über `MR-031` (nicht diesen Eintrag) getragen ist; die allgemeine Nummerierungs-Aussage bleibt unberührt | **nicht gefeuert** |
| `MR-030` | künftiger Stand schreibt die dritte Rolle wieder anders als die übrigen fünf | `grep -c 'participant I as Implementer' .harness/baseline/v6.7.2/regelwerk/modul-08-agentenrollen.md` → 1, unverändert | **nicht gefeuert** |
| `MR-036` | künftiger Stand ändert den zitierten Personalunion-Absatz erneut | `grep -c 'Fallen Auftraggeber- und Entwickler-Rolle zusammen' .harness/baseline/v6.7.2/…` → Zeile 199, Wortlaut unverändert zum zitierten Stand | **nicht gefeuert** |
| `MR-041` | künftiger Stand ändert die Referenz-statt-Kopie-Anmerkung | `grep -c 'keine Blank-Kopie im Repo' .harness/baseline/v6.7.2/regelwerk/modul-02-harness-bootstrap.md` → 1, unverändert seit `v5.12.0` | **nicht gefeuert** |
| `MR-047` | künftiger Stand nennt wieder einen Ort für ausführbare Harness-Tools | `grep -rln 'tools/harness\|harness-tools' .harness/baseline/v6.7.2/regelwerk/ .../templates/` → leer | **nicht gefeuert** |
| `MR-053` | ein **adoptiertes** `versions`-Modul hält beide Fassungen zusammen | `versions` steht im gepinnten d-check als **verfügbar**, aber nicht in `modules:` aktiviert — nicht *adoptiert* | **nicht gefeuert** |
| `MR-013` | prozedural bei jeder Re-Baseline (Dauerzustand, kein einmaliger Trigger) | Beschreibt eine wiederkehrende Pflicht, keinen ablösbaren Zustand | **nicht gefeuert** (kein Kandidat für Ablösung) |
| `MR-032`/`MR-039` | Migration des Blocks in Verzeichnis-Form | Bereits vom Reviewer geprüft: die Migration ist erfolgt, aber durch eine **Repo**-Entscheidung, nicht durch `v6.7.2` selbst; beide tragen bereits eine Kopf-Marke auf `MR-046`, die die Setzung fortschreibt | **nicht gefeuert** (übernommen aus Review, nicht neu erhoben) |

**Innerhalb dieser Stichprobe (9 von 24) feuert kein Trigger gegen `v6.7.2`.** Das deckt sich mit
der Implementer-Behauptung ("0 von N") und der Review-Stichprobe, ist aber ausdrücklich **keine
Vollständigkeitsaussage**: 15 der 24 aktuellen Kandidaten (u. a. `MR-004`, `MR-006`, `MR-007`,
`MR-015`, `MR-031`, `MR-035`, `MR-038`, `MR-040`, `MR-042`, `MR-044`, `MR-054`, `MR-056`, `MR-057`,
`MR-058`) habe ich **nicht** einzeln nachgeprüft. Für die zwei zuletzt genannten (`MR-057`,
`MR-058`) ist ein Feuern gegen `v6.7.2` ohnehin unplausibel, weil sie mit diesem Slice selbst als
Reaktion auf `v6.7.2` erst entstanden sind.

Da im Diff kein `git mv` nach `harness/conventions/done/` steht, ist DoD-3 formal konsistent mit dem
Ergebnis "0 feuern" — vorbehaltlich der nicht geprüften 15 Kandidaten.

---

## 2. ADR-Konformität

### ADR-0045 (Accepted seit `4fb6ad56`)

**Festlegung 1** (Senkung gebucht, Wechsel bleibt) — trägt: `authority: harness/README.md` ist
gesetzt, die Sonde ist rot-gegen-grün belegt (oben unter DoD-1 nachvollzogen, nicht neu gefahren —
das hat die Konsistenzrunde bereits selbst getan und ich habe deren Zahlen gegen den aktuellen Baum
plausibilisiert, s. u.).

**Festlegung 2** (Kompensation über den §Sensors-Scope von `authority_table_targets()`) — der Scope
existiert unverändert:

```sh
sed -n '49,56p' test/targets-modul-wiring.bats
```

Der Kommentar (Zeile 49–54) beschreibt weiterhin nur die eigene Werkzeuge-Tabellen-Begründung, ohne
auf `ADR-0045` zu zeigen — das ist **MEDIUM-4** der Konsistenzrunde, dort ausdrücklich als **nicht
blockierend** eingeordnet (die ADR-Bindung selbst ist normativ wirksam, unabhängig davon, ob der
Kommentar sie nennt) und als Implementer-Folgepflicht in §Konsequenzen adressiert. Ich teile diese
Einordnung: Eine ADR auf Rang 4 der Source Precedence bindet unabhängig vom Kommentar an der
Stelle, die sie belastet (`AGENTS.md` §3.7 — ein Kommentar sitzt in keinem Rang).

**Festlegung 3** (Zielmenge auf Makefile-Regel-Namen statt `.PHONY`) — geprüft gegen den
tatsächlichen Testtext:

```sh
grep -n '^@test' test/targets-modul-wiring.bats
#  90:@test "jede Makefile-Regel ohne Tabellenzeile im Sensors-Abschnitt steht genau einmal in exempt-targets" {
#  99:@test "kein exempt-targets-Eintrag ist zugleich eine Sensors-Tabellenzeile" {
```

Die erste Testbezeichnung misst jetzt tatsächlich Makefile-**Regeln**, nicht `.PHONY`-Einträge —
deckt sich mit dem Namen und mit der Fitness-Function-Tabelle der ADR (dazu unten mehr). Der
`comm -23`-Rest (Regel-Menge gegen `.PHONY`-Menge) ist am aktuellen Stand leer:

```sh
comm -23 <(grep -hE '^[a-zA-Z][a-zA-Z0-9._-]*:' Makefile d-check.mk | sed -E 's/:.*//' | sort -u) \
         <(grep -h '^\.PHONY:' Makefile d-check.mk | sed -E 's/^\.PHONY:[[:space:]]*//' \
           | tr ' ' '\n' | grep -v '^$' | sort -u)
# -> leer
```

Festlegung 3 ist damit im Diff und am aktuellen Stand nachweisbar ausgeführt.

### Die drei korrigierten Darstellungs-Stellen (Auftrag: „sieh sie dir an, tragen sie jetzt?")

**1. Sektions-Adresse auf `ADR-0043`.** Alle drei ursprünglich falschen Stellen zeigen jetzt
korrekt auf `§Was beide Festlegungen nicht tun`:

```sh
grep -n 'ADR-0043' docs/plan/adr/0045-authority-wechsel-senkt-eine-richtung.md
#  10:  (§Was beide Festlegungen nicht tun stellt …
# 270:  §Was beide Festlegungen nicht tun,
# 402:  … §Was beide Festlegungen nicht tun ist damit beantwortet.
grep -n 'Was beide Festlegungen nicht tun' docs/plan/adr/0043-ziel-fassung-regiert-den-sprung-v671.md
# 428:### Was beide Festlegungen nicht tun
```

Alle drei Stellen — einschließlich der im Acceptance-Trigger selbst, wo der Fehler am teuersten
gewesen wäre — lösen jetzt korrekt auf. **Trägt.**

**2. Testname in Fitness Function/Kontext.** Die Tabelle nennt jetzt
`"jede Makefile-Regel ohne Tabellenzeile im Sensors-Abschnitt steht genau einmal in
exempt-targets"` — Zeichen für Zeichen identisch mit dem tatsächlichen `@test`-Namen in
`test/targets-modul-wiring.bats:90` (oben zitiert). **Trägt.**

**3. Observable von Re-Evaluierungs-Trigger 2.** Umgestellt von der defekten
Gleichheits-Prüfung (28 vs. 11) auf den `comm -12`-Schnitt zwischen `exempt-targets` und den
`make X`-Namen der **ganzen** Datei:

```sh
comm -12 <(sed -n '/^targets:/,/^ignore-refs:/p' .d-check.yml | grep '^    - ' | sed 's/^    - //' | sort -u) \
         <(grep -E '^\|.*`make [a-z][a-z0-9-]*`.*\|$' harness/README.md | grep -oE '`make [a-z][a-z0-9-]*`' \
           | tr -d '`' | sed 's/^make //' | sort -u) | wc -l
# -> 17  (deckt sich mit dem in der ADR genannten Wert)
```

Ich habe zusätzlich die logische Eigenschaft nachvollzogen, die den ursprünglichen Fehler behob:
Verliert die Werkzeuge-Tabelle **nur ihre `###`-Überschrift**, aber keine Zeile, bleibt die
README-weite `make X`-Namensliste unverändert — der neue Schnitt bleibt bei 17 und färbt **nicht**
fälschlich "Trigger eingetreten". Nur wenn die Tabelle selbst **entfernt** wird (Option D real
eingetreten), verschwinden die 17 Namen aus der README-Liste und der Schnitt wird leer. Das
Observable unterscheidet die zwei Zustände jetzt tatsächlich, anders als die vorherige Fassung.
**Trägt.**

**Damit tragen alle drei korrigierten Stellen der Substanz nach.** Der von der ADR selbst offen
zugestandene Preis — "die korrigierten Stellen selbst hat keine prüfende Rolle gesehen" — ist mit
dieser Verifikation eingelöst, für diese drei Stellen isoliert betrachtet.

### ADR-0044 (Accepted, regiert den Sprung `v6.7.2`)

Keine Datei unter `docs/plan/adr/` außer `0045-*.md` und `README.md` im Diff berührt
(`git diff --name-only 99bfd1c5^..4fb6ad56 -- docs/plan/adr/` → genau diese zwei) — `ADR-0044`
bleibt unangetastet, Festlegungen dort werden nicht neu bewertet. Kein Konflikt.

---

## 3. Der zentrale Befund dieser Verifikation: der Review-Report zu `slice-225` selbst ist nicht aktualisiert

Der Closure-Trigger (Plan §5) verlangt wörtlich zwei Kriterien, das zweite lautet: *„Der
Review-Report zu diesem Slice liegt unter `docs/reviews/` und trägt keinen blockierenden
Befund."*

Der Review-Report zu `slice-225`
([`2026-09-13-slice-225-gate-index-steht-einmal.md`](2026-09-13-slice-225-gate-index-steht-einmal.md))
endet nach wie vor mit:

> **Blockierend** — wegen HIGH-1 und MEDIUM-1/2/3.

```sh
git log --oneline -- docs/reviews/2026-09-13-slice-225-gate-index-steht-einmal.md
# a73f7d54 Rolle Reviewer: slice-225 -- Relativpfad im Report auf die Repo-Wurzel
# 7f2b4bff Rolle Reviewer: slice-225 -- blockierend, 1 HIGH / 3 MEDIUM / 3 LOW
```

Seit `7f2b4bff` (inhaltlich) bzw. `a73f7d54` (kosmetischer Pfad-Fix) ist diese Datei **nicht**
erneut angefasst worden. Die vier Findings sind seither in der Substanz behandelt worden — aber auf
zwei unterschiedlichen Wegen, von denen keiner eine Reviewer-Bestätigung *dieses* Reports einholt:

- **HIGH-1** ist über `ADR-0045` gebucht und kompensiert — inhaltlich der vom Reviewer selbst
  vorgeschlagene Weg ("§3.5 kennt dafür einen Weg (ADR)"), aber die Bestätigung, dass diese
  Lösung HIGH-1 tatsächlich schließt, kam über die **ADR-0045-Konsistenzrunde** — eine Prüfung des
  ADR-**Texts**, nicht eine erneute Prüfung des `slice-225`-Diffs als Ganzes.
- **MEDIUM-1** (Zahl in `MR-057`) ist über `MR-058` (Kopf-Marke) korrigiert — von der
  **Architect**-Rolle selbst, ohne erneute Reviewer-Bestätigung.
- **MEDIUM-3** (Zustandsfeld "ausstehend") ist direkt in `harness/conventions.md` gefixt — ebenfalls
  Architect-Selbstkorrektur ohne Reviewer-Bestätigung.
- **MEDIUM-2** — *„die Grenze von `MR-057` hat eine Rolle und einen Zeitpunkt, aber keine
  Adresse"* — ist **überhaupt nicht** adressiert:

  ```sh
  git grep -ln 'slice-mv\.sh\|archive/stub\.go' -- \
    'docs/plan/planning/open/*.md' 'docs/plan/planning/next/*.md' 'docs/plan/planning/in-progress/*.md'
  # -> slice-188-…, slice-215-…  (beide mit anderem Gegenstand, wie schon der Review feststellte)
  ```

  Kein Slice und kein Beobachtungs-Verzeichnis trägt diese fällige Arbeit als Adresse. Der
  ursprüngliche Reviewer-Kommentar dazu — "MEDIUM-2 braucht eine Kennung, keine Arbeit" — ist
  weiterhin zutreffend, aber die Kennung fehlt weiterhin.

**Das ist strukturell dieselbe Lücke, die eine vorangegangene Verifikation (`slice-224`) bereits
einmal benannt hat**: Eine Rolle behebt die eigenen Befunde und bucht das als erledigt, ohne dass
die Rolle, die den Befund erhoben hat (Reviewer), die Behebung an **diesem** Artefakt bestätigt.
Nach Modul 8 prüft *„Reviewer prüft auf Konsistenz"* — eine Selbstauflösung durch die behebende
Rolle, ohne erneute Prüfung durch die erhebende Rolle, ist genau die Klasse, die `AGENTS.md` §3.6
als *„Behauptung ohne Bestätigung"* fasst, hier auf das Review-Verdikt selbst angewandt statt auf
eine Test-Zusage. Andere Vorgänge in diesem Repo behandeln genau diesen Fall anders — `ADR-0040`
Festlegung 2 verlangt für einen Befund an der **Substanz** einer ADR ausdrücklich *„eine erneute
Runde derselben Rolle"*, nicht eine Selbstauskunft der korrigierenden Rolle. Für `ADR-0045` wurde
das eingehalten (die Konsistenzrunde). Für den `slice-225`-Report selbst — ein eigenständiges,
vom Plan selbst zitiertes Closure-Kriterium — ist das nicht geschehen.

**Das ist kein Einwand gegen die Richtigkeit der Korrekturen** — HIGH-1, MEDIUM-1 und MEDIUM-3 sind,
soweit ich sie oben nachvollzogen habe, inhaltlich korrekt geschlossen — sondern gegen die **Form**
des Nachweises: Auf dem Papier trägt der einzige vorliegende Review-Report für `slice-225`
weiterhin das Verdikt *Blockierend*, und DoD-Punkt "Review durchgeführt … kein Self-Review" ist
entsprechend korrekt unchecked geblieben.

---

## 4. Plan-vs-Code in beide Richtungen und §1-Abgrenzung

**Plan → Code:** Alle drei Liefer-Punkte sind im Diff nachweisbar (siehe §1 oben). Zusätzlich ist
eine vierte, im Plan nicht explizit vorgesehene, aber aus dem Review-Prozess legitim entstandene
Lieferung hinzugekommen: `ADR-0045` selbst. Das ist keine Abweichung von §1 — der Plan-Kopf sieht
für einen gemessenen Gate-Befund ausdrücklich zwei Wege vor (Meldung an den Auftraggeber *oder*
ADR nach §3.5), und der gewählte Weg ist einer davon.

**Code → Plan (Gebautes-aber-nicht-Geplantes):**

```sh
git diff --name-only 99bfd1c5^..4fb6ad56
```

13 Dateien, alle in einer der vier Kategorien: (a) die drei Liefer-Punkte des Plans, (b) `ADR-0045`
+ ADR-Index (legitime Konsequenz aus HIGH-1, s. o.), (c) die zwei Review-Reports selbst (Prozess-
Artefakte, kein Produktcode), (d) `harness/sensors/docs-check.md` (Norm-Nachzug, vom Plan implizit
über §9-Zeilen gedeckt). **Kein** Treffer unter `internal/`, `cmd/` oder
`internal/emit/templates/` — §1s Ausschluss *„Kein Produkt-Code und keine emittierte Vorlage"* hält
durch. **Kein** neuer `MR`-Eintrag, der eine Abweichung bucht — `MR-057`/`MR-058` sind
Deklarations-Einträge im Sinne der im Plan-Kopf definierten Ausnahme, keine Abweichungs-Buchungen.

**§3.8-Commit-Zuschnitt:** Für alle sechs inhaltstragenden Commits (`99bfd1c5`, `3c2b4d82`,
`fae7b7d1`, `ede6b7fb`, `f9b3c60f`, `4fb6ad56`) per `git show --stat` geprüft — jeder berührt
ausschließlich Artefakte einer Rolle, jeder nennt die Rolle in der Message. Deckt sich mit dem
Negativbefund des Reviewers.

---

## 5. Risiko-Lage (§6) — hat jedes Risiko einen Ausgang, oder stünde die Closure vor einem ohne?

Alle fünf Risiken tragen weiterhin `Ausgang: offen bis zur Closure` — für einen Slice in
`in-progress/` ist das der korrekte Zwischenstand (kein Verstoß, solange der Slice nicht nach
`done/` geht). Materiell zu jedem:

1. **„`authority`-Wechsel färbt `make gates` rot"** — ist **nicht** in der anvisierten Form
   eingetreten (kein rotes Gate beobachtet); stattdessen wurde die Senkung durch Reviewer-Analyse
   *ohne* rotes Gate gefunden und über `ADR-0045` geschlossen. Für die Closure-Notiz ist das
   festzuhalten als: *eingetreten, aber nicht als roter Gate-Lauf sichtbar geworden — gefunden im
   Review, geschlossen per ADR.*
2. **„Ausnahmeliste wird nur auf Form geprüft"** (Register 2×) — dieses Risiko hat sich in HIGH-1
   konkret bestätigt (17 von 37 `exempt-targets`-Einträgen ohne autoritative Wirkung mehr) und ist
   über `ADR-0045` Festlegung 2 kompensiert (der bats-Wächter trägt die Strenge weiter). Sinnvoller
   Ausgang: *eingetreten, kompensiert durch `ADR-0045`.*
3. **„`git mv` macht eine bewachte Adresse falsch"** (Register 13×, größter Zähler) — **nicht
   eingetreten**, weil kein `git mv` in diesem Slice stattfand (0 Retirement-Treffer). Sinnvoller
   Ausgang: *entfallen für diesen Slice* (der allgemeine Registereintrag bleibt unberührt offen).
4. **„Zweiter Rot-Fall bei `reviews`-Modul"** — nicht eingetreten, Modul nicht aktiviert.
5. **„Umfang von Liefer-Punkt 2 wächst"** — hat sich **bestätigt**: DoD-2 hat zwei unbelegte
   Nachweis-Zeilen, eine davon ein handfester Zuständigkeitskonflikt zwischen `slice-224` §9 und
   `slice-225` §1 (§1 oben). Kein Rückführungs-Fall nach dem im Plan definierten Schwellenwert
   (der bezieht sich nur auf Liefer-Punkt 1+3), aber ein offener Klärungsbedarf vor Closure.

Keines der fünf Risiken steht ohne plausiblen Ausgangs-Kandidaten da; die tatsächliche Zuweisung
ist Planner-Arbeit (§3.10), hier nur vorbereitet.

---

## Was ich nicht geprüft habe

- **15 der 24 Retirement-Kandidaten** (`MR-004`, `MR-006`, `MR-007`, `MR-015`, `MR-031`, `MR-035`,
  `MR-038`, `MR-040`, `MR-042`, `MR-044`, `MR-054`, `MR-056`, `MR-057`, `MR-058`) wurden nicht
  einzeln gegen `v6.7.2` geprüft — Stichprobe von 9 (siehe §1 DoD-3), keine Vollständigkeitsaussage.
- **Die übrigen sieben Doku-Gate-Module** (`links`, `anchors`, `ids`, `matrix`, `codepaths`,
  `spans`, `planning`) und die Go-/bats-/shellcheck-/actionlint-Gates wurden nicht neu gefahren —
  Weisung, plus die Auskunft des Auftrags, dass `make gates` bei Start dieser Verifikation EXIT 0
  lieferte.
- **Die inhaltliche Richtigkeit der 33 übrigen (nicht `slice-225`-adressierten) Zeilen des
  slice-224-Nachweises** — außerhalb meines Prüfauftrags.
- **`make mutate`, `make full-smoke`, `make smoke`** — nicht gefahren, nicht Gegenstand dieser
  Verifikation.
- **Ob die drei Sonden der ADR-0045-Konsistenzrunde tatsächlich in Docker gelaufen sind, wie
  behauptet** — ich habe die dort berichteten Zahlen gegen den aktuellen Baum nachgerechnet (17,
  48/48, Testnamen), aber die historischen `git archive`-Sonden über den alten Baum (`99bfd1c5^`)
  nicht selbst wiederholt, da das dieselbe Prüfung wäre, die die Konsistenzrunde bereits dokumentiert
  und die HIGH-1-Substanz nicht neu in Frage stellt.

---

## Urteil

**Sachlich: die Arbeit trägt, und die drei zur Prüfung gestellten ADR-Korrekturen tragen ebenfalls.**
Der Gate-Index steht einmal, die Norm-Ebene ist überwiegend nachgezogen, die Retirement-Runde
liefert innerhalb der geprüften Stichprobe konsistent "nicht gefeuert", und `ADR-0045` bucht die vom
Reviewer nachgewiesene Senkung normativ korrekt, statt sie wegzuerklären. Die drei
Darstellungs-Korrekturen (Sektions-Adresse, Testname, Trigger-2-Observable) sind jetzt sachlich
zutreffend.

**Formal: nicht abschlussreif, aus drei benannten Gründen:**

1. **Zentral:** Der einzige vorliegende Review-Report für `slice-225` selbst trägt weiterhin das
   Verdikt *Blockierend* und wurde nicht durch eine erneute Reviewer-Runde ersetzt oder bestätigt —
   der Closure-Trigger (§5) verlangt wörtlich einen Report ohne blockierenden Befund. Die
   ADR-0045-Konsistenzrunde deckt das nicht: sie prüft den ADR-**Text**, nicht den `slice-225`-Diff
   als Ganzes. Insbesondere **MEDIUM-2 des Slice-Reports ist unbehandelt** — keine Kennung für die
   fällige Arbeit an `harness/tools/slice-mv.sh`/`internal/archive/stub.go` existiert.
2. **DoD-2 unvollständig:** Zwei der sieben `slice-225`-Nachweiszeilen aus slice-224 §9 haben
   keinen Beleg im Diff; eine davon (`lab/templates/.d-check.yml`) ist ein offener
   Zuständigkeitskonflikt zwischen `slice-224` §9 und `slice-225` §1, den keiner der beiden Pläne
   auflöst.
3. **§6-Risiken sind materiell entschieden, aber formal noch nicht mit Ausgang versehen** — das ist
   nach `AGENTS.md` §3.10 korrekt Planner-Arbeit, hier aber vorzumerken, damit die Closure nicht auf
   einem unentschiedenen Risiko landet.

**Empfehlung an den Planner:** eine kurze, frische Reviewer-Runde gegen den **aktuellen** Stand von
`slice-225` (nicht nur gegen `ADR-0045`) einholen, die ausdrücklich bestätigt oder verwirft, dass
HIGH-1/MEDIUM-1/MEDIUM-3 geschlossen sind und MEDIUM-2 eine Adresse bekommt (oder als Risiko in die
Closure-Notiz wandert); parallel die `lab/templates/.d-check.yml`-Zuordnung zwischen `slice-224` und
`slice-225`/`slice-210-213` explizit klären. Erst danach ist DoD-Punkt "Review ohne blockierenden
Befund" ehrlich abhakbar.

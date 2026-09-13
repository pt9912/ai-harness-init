# Review slice-225 — Runde 2: sind die Befunde der ersten Runde aufgelöst?

**Rolle:** Reviewer · **Datum:** 2026-09-13 ·
**Range:** `fae7b7d1..86e00b97` — `ede6b7fb` (Architect) · `f9b3c60f` (Implementer) ·
`db455d62` (Reviewer, ADR-Konsistenzrunde) · `4fb6ad56` (Architect, Accept) ·
**Runde 1:** [`2026-09-13-slice-225-gate-index-steht-einmal.md`](2026-09-13-slice-225-gate-index-steht-einmal.md) (unangetastet) ·
**Plan:** [`slice-225`](../plan/planning/in-progress/slice-225-gate-index-steht-einmal.md) ·
**Constraints:** [`AGENTS.md`](../../AGENTS.md) §3.4 · §3.5 · §3.6 · §3.7 · §3.8 · §3.10 ·
[`ADR-0045`](../plan/adr/0045-authority-wechsel-senkt-eine-richtung.md) ·
[`ADR-0040`](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) ·
[`ADR-0031`](../plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) ·
[`MR-032`](../../harness/conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger) ·
[`MR-058`](../../harness/conventions.md#mr-058--eine-messung-die-ihr-eigener-vorgang-bewegt-wird-nach-dem-vorgang-genommen)

**Schnitt dieses Laufs — eine Frage.** Geprüft ist allein, ob die sieben Befunde aus Runde 1
aufgelöst sind, dazu die zwei Posten des Verifikations-Reports, die an ihnen hängen. **Kein**
Neuaufrollen des Diffs, **keine** DoD-Abhakung, **kein** Gate-Lauf als Ganzes. Alle Zahlen stehen
neben dem Kommando, gefahren über `86e00b97` — keine Erwartungswerte. Sonden liefen gegen Kopien
außerhalb des Repos, netzlos, Mount `:ro`, über den in [`d-check.mk`](../../d-check.mk) gepinnten
Digest. Nur lesende Kommandos im Arbeitsbaum, nichts geändert.

---

## Urteil je Befund

### HIGH-1 — **aufgelöst**

Die Senkung ist **entschieden statt wegerklärt**:
[`ADR-0045`](../plan/adr/0045-authority-wechsel-senkt-eine-richtung.md), `Accepted`, Festlegung 1
bucht sie und verwirft den dritten Weg wörtlich; Festlegung 2 weist die Last dem §Sensors-Scope von
`authority_table_targets()` zu und macht sein Entfernen zum eigenen §3.5-Fall; Festlegung 3 ist mit
`f9b3c60f` ausgeführt.

**Selbst gefahren, nicht übernommen** — der Kompensations-Träger beißt am heutigen Stand, und zwar
in genau meinem Failure-Szenario (Nicht-Gate-Rezept, **nur** Werkzeuge-Zeile, kein
`exempt-targets`, **kein** `.PHONY`):

```sh
# Kopie von HEAD: git archive HEAD | tar -x -C <kopie>; dort
printf '\nprobe-tool: ## Sonde\n\t@true\n' >> Makefile
# + eine Zeile `| `make probe-tool` | Sonde | kein Gate |` in die Werkzeuge-Tabelle
make -C <kopie> test-bats
#   not ok 262  jede Makefile-Regel ohne Tabellenzeile im Sensors-Abschnitt steht genau einmal in exempt-targets
docker run --rm --network none -v "$PWD":/repo:ro "$REF" --config /repo/.d-check.yml --enable targets
#   1237 Datei(en) geprüft, 0 Befund(e)   — das Modul lässt durch, der Wächter fängt
```

**Die Widerlegung meines impliziten Griffs ist reproduziert**, ebenfalls selbst gefahren: dieselbe
Zeile in der **Gate**-Tabelle `AGENTS.md` §4 über dem alten Baum —

```sh
# Kopie von 99bfd1c5^ (authority: AGENTS.md), probe-tool in die Gate-Tabelle
docker run --rm --network none -v "$PWD":/repo:ro "$REF" --config /repo/.d-check.yml --enable targets
#   1231 Datei(en) geprüft, 0 Befund(e)
```

Das Modul hat Gate und Nicht-Gate **nie** unterschieden; ein Wächter „Nicht-Gate steht nicht in
§Sensors" stellte nichts wieder her. Die Einordnung in
[`ADR-0045`](../plan/adr/0045-authority-wechsel-senkt-eine-richtung.md) §Was diese Entscheidung
nicht tut trägt.

**Zum Accept-Übergang, geprüft und ohne Befund:** Der Beleg ist eine **fremde** Runde
([`2026-09-13-adr-0045-konsistenzrunde.md`](2026-09-13-adr-0045-konsistenzrunde.md), `db455d62`),
die die drei Sonden selbst gefahren hat; die Verengung des Triggers auf *Substanz gegen
Darstellung* geschah, solange die Datei `Proposed` war, und ist damit der Weg, den
[`ADR-0040`](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 3
ausdrücklich öffnet (``grep -c 'solange die Datei `Proposed` ist' docs/plan/adr/0040-*.md`` → 1). Was
sie aufgibt, benennt die Datei selbst.

### MEDIUM-1 — **aufgelöst**

Append-only und formgerecht:
[`MR-058`](../../harness/conventions.md#mr-058--eine-messung-die-ihr-eigener-vorgang-bewegt-wird-nach-dem-vorgang-genommen)
streicht den Betrag (nicht das Kommando, nicht die Aussage), `MR-057` trägt die Kopf-Marke nach
[`MR-032`](../../harness/conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)
— gesetzt vom ablösenden Eintrag in derselben Änderung, rein additiv, auf die **Index**-Zeile
zeigend (§3.11), `MR-057` bleibt in `harness/conventions/` (`MR-046`). Alle drei Zahlen des neuen
Eintrags reproduzieren:

```sh
grep -c 'slice-NNN' harness/conventions/MR-000-baseline-aussage.md                                    # 2
git show 3c2b4d82^:harness/conventions/MR-000-baseline-aussage.md | grep -c 'slice-NNN'               # 1
ls docs/plan/planning/observations/BEO-ALL/mess-zusage-trifft-das-eigene-zitat/evidence/*.md | wc -l  # 3
git show ede6b7fb -- harness/conventions/MR-057-*.md | grep -c '^+'                                   # 3 (Marke + Leerzeile + Header)
```

Die Verallgemeinerung geht über meinen Befund hinaus, ohne ihn zu verfehlen: Setzung 2 trägt die
**Eigenschaft** statt des Einzelfalls, und sie regiert ab sofort auch die Kandidatenzahl unten.

### MEDIUM-2 — **nicht aufgelöst; blockiert nach meinem Urteil nicht**

Der Zustand ist unverändert — die Ziffern-Bindung steht, eine annehmende Adresse existiert nicht:

```sh
git grep -lE 'slice-(\[0-9\]|\\d)' -- harness/tools internal cmd Makefile d-check.mk ':!internal/emit'
# harness/tools/slice-mv.sh      (Zeile 171: grep -ohE '\]\(slice-[0-9][^)/]*\)')
# internal/archive/stub.go       (Zeile 203: regexp.MustCompile(`slice-[0-9]{3}`))
git grep -ln 'slice-mv\.sh\|archive/stub\.go' -- 'docs/plan/planning/{open,next,in-progress}/*.md'
# slice-188 (Gegenstand: BEO-Kennung im Stub, `grep -n 'BEO-\[0-9\]' docs/plan/planning/open/slice-188-*.md`), slice-215
```

**Warum das die Closure nicht blockiert.** Was fehlt, ist eine **Kennung**, und eine Kennung
schneidet der Planner — die ausführende Rolle darf ihr eigenes Abnahmekriterium nicht umschreiben
([`AGENTS.md`](../../AGENTS.md) §3.10). Für genau diesen Fall führt das Baseline-Regelwerk
`modul-05-planning-harness.md` §Offene Risiken werden bei Closure aufgelöst den geschlossenen
Ausgang *eingetreten → Folge-Slice mit ID*; die Closure ist der vorgesehene Ort, nicht der Diff.
**Zwei Bedingungen, sonst trägt der Ausgang nicht:** (1) Die Adresse muss die Sendung annehmen —
ein Folge-Slice, dessen Gegenstand die zwei Stellen wirklich nennt, keiner der beiden oben. (2) Sie
ist fällig **vor** der ersten benannten Kennung — und die erste benannte Kennung ist
voraussichtlich die des Folge-Slice selbst, weil
[`MR-057`](../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
Setzung 1 seit `3c2b4d82` für jede neu vergebene Kennung gilt.

- **verifizierbar:** nein (keine Gate-Form für eine fällige Arbeit ohne Adresse).
- **klasse:** fällige Arbeit ohne aufnehmende Kennung (unverändert aus Runde 1).

### MEDIUM-3 — **aufgelöst**

```sh
grep -n 'Delta-Nachweis in slice-224' harness/conventions.md
# 30:  **auf `v6.5.0`:** 2026-09-07, Delta-Nachweis in slice-224;
# 31:  **auf `v6.7.2`:** 2026-09-12, Delta-Nachweis in slice-224.
```

Beide Zeilen tragen jetzt genau die drei Teile, die
[`ADR-0031`](../plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) Festlegung 2 als
geschlossenen Mindestumfang setzt — Ziel-Tag und Datum, der Slice mit dem Delta-Nachweis, **sonst
nichts**; das Zustandswort ist weg, kein Ersatz-Urteil ist an seine Stelle getreten. Gleiche Form
wie die Zeilen zu `v5.18.0` und `v6.0.0` darüber.

### LOW-1 / LOW-2 / LOW-3 — **alle drei aufgelöst**

```sh
sed -n '62,63p' harness/README.md          # „… keine `make X`-Zeile in der Sensors-Tabelle oben nötig"
grep -n 'als \*\*Ganzes\*\*' harness/sensors/docs-check.md   # 1 — Vertrag auf das eingeschränkt, was das Modul hält
sed -n '2,10p' test/targets-modul-wiring.bats                # Kopf nennt Regel-Namen + „enger als das Modul selbst liest"
grep -hE '^[a-zA-Z][a-zA-Z0-9._-]*:' Makefile d-check.mk | sed -E 's/:.*//' | sort -u | wc -l   # 48
grep -h '^\.PHONY:' Makefile d-check.mk | sed -E 's/^\.PHONY:[[:space:]]*//' | tr ' ' '\n' | grep -v '^$' | sort -u | wc -l   # 48
```

LOW-1: die Deixis zeigt auf die gemeinte Tabelle. LOW-2: der Vertrag sagt jetzt „die Datei als
Ganzes" und nennt den Wächter als den, der den §Sensors-Scope hält, mit Zeiger auf
[`ADR-0045`](../plan/adr/0045-authority-wechsel-senkt-eine-richtung.md). LOW-3: der Dateikopf zieht
nach und die Zahl 47 → 48 ist mitgezogen, beide Mengen sind an ihren Kommandos belegt.

---

## Die zwei Posten des Verifiers

### DoD-2 / `lab/templates/.d-check.yml` — **Closure-Posten, kein Blocker; aber kein Häkchen ohne Ausgang**

Der Konflikt besteht und ist reproduziert: `slice-224` §9 Zeile 699 adressiert die Zeile an
`slice-225`; dessen §1 schließt die emittierte Vorlage aus und nennt `slice-210/211/212/213`, und
keiner von ihnen nimmt die Aktivierungsfrage des Moduls `reviews` an
(`git grep -n 'Modul .reviews.\|.reviews.-Modul' -- 'docs/plan/planning/{open,next}/*.md'` → leer).

Es ist dieselbe Klasse, die `slice-224` in seiner eigenen Closure schon einmal gebucht hat
(*„nicht der Zuschnitt war falsch, sondern die **Annahmebereitschaft** der Adresse"*,
`grep -n 'Annahmebereitschaft' docs/plan/planning/done/slice-224-*.md` → 1;
`ls docs/plan/planning/observations/BEO-ALL/uebergabe-an-andere-rolle-ohne-traeger-artefakt/evidence/*.md | wc -l`
→ 3). Genau deshalb ist die Auflösung Planner-Arbeit und nicht Diff-Arbeit: `slice-224` liegt in
`done/` und ist nicht mehr änderbar, und `slice-225` §1 ist das Abnahmekriterium des laufenden
Kontexts, das dieser nicht umschreiben darf ([`AGENTS.md`](../../AGENTS.md) §3.10).

**Blockierend wäre nur die stille Variante:** DoD-2 als erfüllt abhaken, während zwei der sieben
Zeilen ohne Beleg und eine ohne Empfänger dasteht. Ein Ausgang — Folge-Slice mit Kennung **oder**
ausdrückliche Ablehnung mit Begründung — trägt; ein Häkchen ohne ihn wäre ein grünes Feld über
einer Zusage, die niemand hält.

### Kandidatenmenge des Retirements — **24 bestätigt; 23 und 21 waren zu ihrem Zeitpunkt ebenfalls richtig**

```sh
ls harness/conventions/MR-*.md | wc -l                      # 55 (über fae7b7d1: 54)
# Kandidaten-Schleife des Verifiers, über HEAD und über fae7b7d1 gefahren, Ergebnis diff:
# 24 gegen 23 — einzige Differenz: MR-058-eine-messung-...-danach-genommen.md
```

Die drei Zahlen widersprechen sich nicht: Der Slice **erzeugt** zwei seiner eigenen Kandidaten
(`MR-057`, `MR-058`), also bewegt der schreibende Vorgang seine eigene Bezugsmenge — der Fall, den
[`MR-058`](../../harness/conventions.md#mr-058--eine-messung-die-ihr-eigener-vorgang-bewegt-wird-nach-dem-vorgang-genommen)
Setzung 2 seit `ede6b7fb` regelt: **die Messung wird nach dem Vorgang genommen.** Für die
Closure-Notiz heißt das: die Zahl, die dort steht, ist die am Abschluss gemessene, nicht 21 und
nicht 23.

**Tragend für das Ergebnis *0 feuern* ist die Zahl nur als Bezugsmenge**, und die zwei
Zuwächse sind trivial nicht gefeuert — beide sind gegen `v6.7.2` geschrieben und benennen ihren
Trigger als *permanent, neu fällig erst bei einem künftigen Stand*
(`grep -A 2 'Auflösungs-Trigger' harness/conventions/MR-05[78]-*.md`). Offen bleibt, was der
Verifier für sich selbst benennt: 15 der 24 hat er nicht einzeln geprüft, ich in Runde 1 zwei
Grenzfälle. Eine Vollständigkeitsaussage über die 24 führt dieser Report nicht.

---

## Negativbefunde (geprüft, ohne Befund)

- **§3.8 Commit-Zuschnitt der drei neuen Commits.** `ede6b7fb` und `4fb6ad56` berühren
  ausschließlich Architect-Artefakte (ADR, ADR-Index, `harness/conventions.md`, zwei Einträge),
  `f9b3c60f` ausschließlich Implementer-Artefakte; jede Message nennt ihre Rolle
  (`git show --pretty=format: --name-only <c>` je Commit).
- **§3.4 gegen `ADR-0045`.** Der Statuswechsel auf `Accepted` und die drei
  Darstellungs-Korrekturen liegen in **einem** Commit, solange die Datei `Proposed` war; danach ist
  nichts mehr angefasst (`git log --oneline -- docs/plan/adr/0045-*.md` → 2 Commits).
- **ADR-Index.** Zeile für `ADR-0045` existiert, Status `Accepted`, Bezüge vollständig
  (`grep -c '0045-authority-wechsel' docs/plan/adr/README.md` → 1).
- **Kein Rückschritt an den Stellen aus Runde 1.** `targets.authority` steht unverändert auf
  `harness/README.md`, `doc-tables` führt weiter beide Dateien
  (`sed -n '/^targets:/,/^ignore-refs:/p' .d-check.yml`).
- **Nicht geprüft, ausdrücklich:** der Diff jenseits meiner sieben Befunde · die DoD-Abhakung ·
  `make gates`/`make mutate`/`make full-smoke` als Ganzes · 15 der 24 Retirement-Kandidaten · die
  emittierte Ebene.

---

## Offen, nicht blockierend

- **Der Funktionskommentar über `authority_table_targets()` trägt die Last aus Festlegung 2
  nicht.** Er begründet den §Sensors-Scope weiter allein damit, dass der Test sonst gegen die
  eigene Werkzeuge-Tabelle liefe; der Rang-Zeiger auf
  [`ADR-0045`](../plan/adr/0045-authority-wechsel-senkt-eine-richtung.md) steht im **Dateikopf**
  (Festlegung 3), nicht über der Funktion (`grep -n 'ADR-0045' test/targets-modul-wiring.bats` → 1,
  Zeile 9). Die ADR benennt das in §Konsequenzen selbst als Folgepflicht mit Fälligkeit *beim
  nächsten Anfassen der Datei* — die Lücke ist benannt und adressiert, also kein Finding.

## Kategorie-Summary

| Kategorie | Runde 1 | Stand jetzt |
|---|---|---|
| HIGH | 1 | 0 — `ADR-0045` `Accepted`, Kompensation von mir rot gesehen |
| MEDIUM | 3 | 1 — MEDIUM-2 offen, mit Closure-Ausgang tragbar |
| LOW | 3 | 0 |
| INFO | 2 | 1 — INFO-2 als Closure-Posten (DoD-2) |

## Verdikt

**Nicht mehr blockierend.** Sechs der sieben Befunde sind aufgelöst und je an einem eigenen
Kommando nachgemessen; der siebte (MEDIUM-2) verlangt eine Kennung, die nur der Planner schneiden
kann, und die Closure ist der dafür vorgesehene Ort — zusammen mit dem Ausgang für den
`lab/templates/.d-check.yml`-Zuständigkeitskonflikt. Beide gehören in die Closure-Notiz als
Ausgang, nicht in einen weiteren Review-Durchgang.

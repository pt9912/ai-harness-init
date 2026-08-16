# Slice slice-087: Emittierte Doku-Tische behaupten nur Init-invariante Ziele

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-09](../welle-09-modul-15-konformitaet.md) — die **Tool**-Ebene, Vorarbeit. Er ist
Mitglied, weil die Zelle *Doku-Konsistenz-Drift × Tool* ohne ihn nicht belegbar ist: `slice-063`
darf den Träger erst konfigurieren, wenn kein emittiertes Dokument mehr ein Ziel behauptet, das
einer Bootstrap-Variante fehlt. Bliebe er außerhalb, deckte der Closure-Trigger *„alle Slices
dieser Welle in `done/`"* genau das nicht ab, woran die Welle hängt.

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (erste
Hälfte: *„Jeder emittierte Gate-Target läuft auf frischem Checkout"* — die Anforderung, gegen die
der emittierte Bestand heute selbst verstößt; ihre Messmethode `make gates`/Exit 0 sieht es nicht),
[`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) (*out-of-the-box grün* —
die Zusage, die ein verdrahteter Doku-Konsistenz-Träger heute bräche),
[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) (der
emittierte Stand ist gate-sicher — die Schranke, an der die Neutralisierung gemessen wird),
[`LH-FA-03`](../../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7) (die
emittierte Doc-Gate-Baseline — sie trägt den Abnehmer dieser Vorarbeit, wird hier aber **nicht**
berührt),
[`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
(die Default-Regel für emittierte Prüfbereiche — hier als Gegenkraft: *laut falsch* ist nur dann
besser als *leise falsch*, wenn der Adopter am Befund ablesen kann, dass er einer ist),
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
(der Schnitt-Test — er entscheidet die Welle, nicht die Größe; §4),
[`ADR-0007`](../../adr/0007-bootstrap-phasen.md) (**Accepted** — die Phasen-Trennung: `--lang` ist
optional, und genau daraus entsteht die Varianz, die dieser Slice schließt),
[`ADR-0020`](../../adr/0020-emittierte-modul-15-regeln.md) (**Proposed** — der Abnehmer:
Festlegung 4(e) macht diese Vorarbeit zur Vorbedingung der Emission, Festlegung 4(c) bindet jede
spätere Emissions-Phase an dieselbe Eigenschaft. **Der Befund hängt nicht an ihr:** die
behaupteten, nirgends existierenden Ziele verletzen
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) auch
ohne jede Doc-Gate-Konfiguration — die Entscheidung ist der Grund für die *Reihenfolge*, nicht für
die Arbeit).

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-08-16.

---

## 1. Ziel

**Ein frisch gebootstrapptes Ziel behauptet in seinen zwei Doku-Tischen nur noch `make`-Ziele, die
die Init-Phase selbst schreibt — in jeder Bootstrap-Variante, und ein Wächter hält die Eigenschaft
fest.**

**Der Bestand, gemessen (2026-08-16, `grep -noE 'make [a-z][a-z0-9-]+'` über
`.harness/baseline/v3.5.2/templates/AGENTS.template.md` und
`.harness/baseline/v3.5.2/templates/harness/README.template.md`):** **20 Nennungen** von **9
verschiedenen** Zielen. **Zwei** davon schreibt die Init-Phase selbst — `gates` und `help`
(6 Nennungen). **Sieben** nicht (14 Nennungen), und sie zerfallen in zwei ungleiche Hälften:

| Anspruch | existiert wo? | Beleg |
|---|---|---|
| `arch-check`, `ci`, `coverage-gate`, `coverage-gate-critical`, `fullbuild` | in **keiner** Variante — auch `arch-check` nicht, wenn ein Arch-Gate emittiert wird, denn das Target heißt dort `a-check` | `grep -rnoE '^(coverage-gate\|fullbuild\|ci\|arch-check):' internal/gen internal/emit` → **kein Treffer** |
| `lint`, `test` | **nur** mit `--lang`, im Code-Gate-Fragment `harness/mk/<lang>.mk` | [`internal/gen/golang.go`](../../../../internal/gen/golang.go) und [`internal/gen/cpp.go`](../../../../internal/gen/cpp.go) definieren je `test`, `lint`, `build` |

**Warum die zweite Hälfte mitmuss, obwohl sie „meistens" wahr ist.** Sie ist die teurere: eine
Behauptung, die in *einer* Variante zutrifft, macht jeden Befund über sie **unentscheidbar**. Die
sechs Sonden aus
[`ADR-0020`](../../adr/0020-emittierte-modul-15-regeln.md) §Kontext zeigen es an der Ausgabe des
Trägers — heutiger Tisch: **13 Befunde, davon 4 falsch**; die naheliegende Teil-Reparatur (nur die
fünf nirgends existierenden entfernen): **4 Befunde, alle vier falsch**; wahr und falsch sind
**byte-gleich**; nur der Init-invariante Tisch schweigt in **beiden** Varianten. Wer nur die erste
Hälfte repariert, erzeugt den Fehler also erst — und `exempt-targets: [lint, test]` hilft nicht
(dieselbe Sonde, unverändert 4 Befunde: die Ausnahmeliste greift auf der Vollständigkeits-Richtung,
nicht auf Richtung 1).

**Was der Slice damit herstellt, ist eine Eigenschaft, keine Liste:** die Menge der behaupteten
Ziele ist eine Teilmenge der Menge, die die Init-Phase definiert. Beide Mengen schreibt dasselbe
Werkzeug; die Invariante ist deshalb prüfbar, ohne dass jemand eine Datei-Liste pflegt.

## 2. Definition of Done

- [ ] **(1) Die zwei emittierten Doku-Tische behaupten nach der Emission nur noch Init-invariante
  Ziele — belegt an einem frisch gebootstrappten Ziel, in beiden Bootstrap-Varianten.** Die
  sieben Ansprüche fallen **emit-seitig**, nicht in der vendored Vorlage: die Kurs-Vorlagen
  gehören dem Kurs ([welle-09](../welle-09-modul-15-konformitaet.md) §6,
  [`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert)),
  und die Baseline ist nach [`AGENTS.md`](../../../../AGENTS.md) §3.4 unveränderlich. Die Form ist
  vorgemacht: [`internal/emit/templates.go`](../../../../internal/emit/templates.go) neutralisiert
  die eine gate-unsichere Zeile der Roadmap-Vorlage beim Schreiben. **Welche Form die
  Neutralisierung nimmt — Zeile streichen oder Anspruch auf ein existierendes Ziel umschreiben —
  entscheidet die Umsetzung am Fehlerbild, nicht dieser Plan**
  ([`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed));
  die Zusage ist die Eigenschaft, nicht der Handgriff.
- [ ] **(2) Ein netzloser Wächter hält die Eigenschaft, und er ist rot gesehen.** Ein Go-Test über
  dem emittierten Vorlagen-Inhalt hält **jede** `make`-Nennung der zwei Doku-Tische gegen die
  Ziel-Menge der Init-Phase und wird rot, sobald eine Nennung nicht darin liegt; dazu ein
  `test/mutations/`-Fall ([`AGENTS.md`](../../../../AGENTS.md) §3.6), der genau das einmal rot
  färbt. **Er prüft die Eigenschaft, nicht die sieben Namen** — sonst bindet er den heutigen
  Bestand statt der Regel, und die nächste Emissions-Phase, die ein Ziel mitbringt, liefe still an
  ihm vorbei.
- [ ] `make gates` grün.
- [ ] Doku-Update für den berührten öffentlichen Vertrag — **erwartet unberührt**:
  [`spec/lastenheft.md`](../../../../spec/lastenheft.md) wird von diesem Slice **erfüllt**, nicht
  geändert (§3); der Nachweis ist `git diff --stat` über den ganzen Slice.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

### Bewegt dieser Slice eine Anforderung? — Nein, er stellt eine her

[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) sagt
bereits, was hier hergestellt wird; der emittierte Bestand hält es nur nicht ein. Damit ist dies
kein Change Request nach
[`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
(er bewegt eine Anforderung — hier bewegt sich keine), sondern die Reparatur eines Bestands gegen
seinen eigenen Vertrag. Dieselbe Klasse wie
[slice-073](slice-073-emittierte-doc-gate-module.md): reaktiv, aus einer Messung am Bestand.

### Dateien

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`internal/emit/templates.go`](../../../../internal/emit/templates.go) | update | die emit-seitige Neutralisierung der sieben Ansprüche; die Roadmap-Vorlage macht die Form vor |
| `test/` (Go-Test + `test/mutations/`-Fall) | neu | der Wächter aus DoD (2) und sein rot gesehener Gegenfall |
| `.harness/baseline/v3.5.2/templates/**` | **unverändert** | die vendored Baseline ist nach [`AGENTS.md`](../../../../AGENTS.md) §3.4 unveränderlich; ein Befund dort ist ein Upstream-Befund ([welle-09](../welle-09-modul-15-konformitaet.md) §6) |
| [`spec/lastenheft.md`](../../../../spec/lastenheft.md), [`docs/plan/adr/`](../../adr/) | **unverändert** | keine Anforderung wird bewegt, keine Entscheidung getroffen — die trifft `slice-062` |
| `internal/emit/templates/d-check.yml`, [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh) | **unverändert** | die Doc-Gate-Konfiguration und die zwei Beleg-Richtungen sind `slice-063`; dieser Slice stellt nur dessen Eintritts-Bedingung her |

### Was die Umsetzung zuerst nachmisst

Die Zahlen oben sind aus dem **Vorlagen- und Emissions-Bestand** gerechnet, nicht an einem frisch
gebootstrappten Ziel gemessen. Vor dem ersten Handgriff sind sie dort neu zu fahren — sie hängen
am vendored Stand, und der wandert mit jeder Baseline ([welle-10](../welle-10-re-baseline.md)
zielt bereits auf einen anderen Tag). Ein Baseline-Sprung kann Ansprüche auflösen **oder**
hinzufügen; die Eigenschaft aus DoD (2) überlebt beides, eine abgeschriebene Sieben-Namen-Liste
nicht.

## 4. Trigger

**`open` → `next`:** keiner. Der Befund steht am Bestand und ist ohne fremde Entscheidung
lieferbar — insbesondere **nicht** hinter `slice-062`: die Ansprüche sind heute falsch, ob eine
ADR sie erwähnt oder nicht. Modul 5 §Ziel-Form (*„kein Slice wartet auf den nächsten"*) ist damit
gewahrt, und die Abhängigkeit läuft in die andere Richtung — `slice-063` wartet auf **diesen**.

**`next` → `in-progress`:** WIP-Limit — kein anderer Slice in `in-progress/`.

**Warum Mitglied von [welle-09](../welle-09-modul-15-konformitaet.md) und nicht wellenlos** (der
Schnitt-Test aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1 fragt, ob eine **neue Welle** nötig ist — hier steht die Welle schon, gefragt ist die
**Mitgliedschaft**): das Closure-Kriterium der Welle verlangt je Zelle einen belegten Zustand, und
die Zelle *Doku-Konsistenz-Drift × Tool* ist ohne diese Vorarbeit nicht belegbar. Eine Welle, deren
Closure an einem Nicht-Mitglied ohne Eintritts-Trigger hängt, hat ihr Kriterium nicht — sie
verschiebt es. Der Preis der Mitgliedschaft ist benannt: die Welle schließt später, dafür sagt
`alle Slices dieser Welle in done/` wieder die Wahrheit.

Rückführungen:

- `in-progress` → `next`: falls die Neutralisierung der zwei Hälften zwei verschiedene
  Mechanismen braucht (etwa: fünf Zeilen streichen, aber `lint`/`test` an die Sprach-Phase
  binden) und der Wächter aus DoD (2) damit einen dritten Liefergegenstand bekäme.
- `in-progress` → `open`: falls sich zeigt, dass ein Doku-Tisch ohne die sieben Ansprüche seine
  Aufgabe nicht mehr erfüllt — dann ist zu **entscheiden**, was ein emittierter Gate-Tisch dem
  Adopter zeigt, und das ist eine ADR-Frage, keine Emissions-Frage.

## 5. Closure-Trigger

DoD vollständig; Review konform (Modul 10); Verifikation bestätigt (Modul 11); `make gates`,
`make mutate` und `make full-smoke` grün — letzteres in **beiden** Bootstrap-Varianten und im
sprachlosen Ziel **vor** dessen `add-lang`-Schritt (§6); `git mv` nach `done/` (eigener
Move-Commit); Closure-Notiz mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Der sprachlose Zustand ist im Voll-Smoke nur ein Zwischenstand — gemessen.**
  [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh) bootstrappt zwei
  Repos (`--lang go` und sprachlos), fährt aber im sprachlosen anschließend `add-lang go` (zweimal,
  Mono-Repo-Schritt). Ein Beleg, der erst danach greift, misst die sprachlose Variante **nie**.
  Wer hier oder in `slice-063` einen Zahn setzt, setzt ihn deshalb **vor** dem `add-lang`-Schritt
  — sonst behauptet der Beleg eine Varianten-Klammer, die er nicht hat.
- **Die Eigenschaft bindet auch jede spätere Emissions-Phase, und der Träger dafür ist der
  Wächter, nicht dieser Text.**
  [`ADR-0020`](../../adr/0020-emittierte-modul-15-regeln.md) Festlegung 4(c) verlangt, dass eine
  Phase, die ein Ziel emittiert, **keinen** Doku-Anspruch darauf emittiert — die Konfiguration ist
  *skip-if-present* ([`ADR-0007`](../../adr/0007-bootstrap-phasen.md)) und kann nach der
  Init-Phase nicht mehr wachsen. Als Prosa wäre das eine Regel ohne Feedback-Quadrant; als
  Teilmengen-Test aus DoD (2) fällt sie beim nächsten Verstoß rot auf. **Das ist der Grund, warum
  DoD (2) die Eigenschaft prüft und nicht die Namen.**
- **Was dieser Slice ausdrücklich NICHT tut.** Die Doc-Gate-Konfiguration im Ziel (der
  `targets:`-Block) und die zwei Beleg-Richtungen gehören `slice-063`; die Entscheidung darüber
  `slice-062`; die zwei `codepath-missing`-Stellen der emittierten Vorlagen-Prosa gehören
  [slice-073](slice-073-emittierte-doc-gate-module.md) — **dieselbe Klasse Befund** (eine
  emittierte Vorlage behauptet, was im Ziel nicht existiert) und derselbe Ausweg
  (emit-seitige Neutralisierung), aber **andere Befund-Art** und nur **eine** gemeinsame Vorlage:
  jene Stellen liegen in der emittierten AGENTS- und der emittierten Konventions-Datei, die
  Gate-Ansprüche in der AGENTS-Vorlage und der Vorlage von
  [`harness/README.md`](../../../../harness/README.md). **Der Auflösungs-Trigger von
  [slice-073](slice-073-emittierte-doc-gate-module.md) DoD (3) fällt hier also NICHT** — wer das
  annimmt, hakt eine fremde Nicht-Emission an einer Messung ab, die sie nicht getroffen hat.
- **Die Migration bereits gebootstrappter Ziele bleibt offen.** Emittierte Dokumente sind
  *skip-if-present*/konvergent je nach Klasse ([`ADR-0007`](../../adr/0007-bootstrap-phasen.md));
  ein heute schon gebootstrapptes Repo bekommt die Korrektur nicht automatisch. Das ist die
  Idempotenz-Klasse, kein Versehen — aber es gehört benannt, weil die Zusage aus DoD (1) dort
  nicht gilt.

## 7. Closure-Notiz (nach `done/`)

<!--
Wird *nach* Abschluss ergänzt. Inhalt:
- Was hat funktioniert?
- Was ging anders als geplant?
- Steering-Loop-Eintrag: welcher Guide/Sensor sollte verbessert werden?
  (kanonische Definition: [`/kurs/de/grundlagen/klassifikation.md` §Steering Loop](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/grundlagen/klassifikation.md#steering-loop))
- Folge-Slices: welche neuen open/-Einträge?
-->

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `internal/emit/` und
`test/` gehören zum Greenfield-Bestand; der Modus steht in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md).

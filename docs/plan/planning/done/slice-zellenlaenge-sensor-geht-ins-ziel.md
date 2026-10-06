# Slice slice-zellenlaenge-sensor-geht-ins-ziel: Die emittierte Doku-Gate-Konfiguration begrenzt die Zellenlänge der README-Tabellen

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — keine Closure-Bedingung, die mehr beobachtet als die DoD ([`MR-037`](../../../../harness/conventions.md#mr-037)).

**Ebene: emittiert, nicht Dogfood.** Gegenstand ist `internal/emit/templates/d-check.yml`, die Startkonfiguration
eines gebootstrappten Ziels.

**Bezug:** [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) (Repo bootstrappen), [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein Gate im Ziel, das nichts prüft, ist behauptet),
[`LH-FA-12`](../../../../spec/lastenheft.md#lh-fa-12--e2e-abdeckungs-sicht-emittieren) (E2E-Abdeckungs-Sicht), [`MR-054`](../../../../harness/conventions.md#mr-054) (Modul im emittierten Doc-Gate: Erprobung, grüner Start, rotes
Gegenbeispiel), [`MR-055`](../../../../harness/conventions.md#mr-055) (eine Stellen-Messung trägt keine Folgerung über eine Eigenschaft).

**Berührte Spec-Stellen:** —

**Verantwortlich:** Implementer (pt9912)

**Autor:** Planner. **Datum:** 2026-10-05.

---

## 1. Ziel und Abgrenzung

**Ziel:** Ein frisch gebootstrapptes Ziel führt `structure` in seinem `modules:` mit einer Regel, die die
Zellen der Spalten `Tut was` und `Vertrag` seiner `harness/README.md` begrenzt; das Ziel startet grün, und
ein zu langer Zellsatz färbt `docs-check` im Ziel rot — als E2E-Stufe gemessen, nicht an einer Fixture.

**Start-Trigger:** `slice-werkzeug-zellenlaenge-hat-einen-sensor` liegt in `done/`
(`ls docs/plan/planning/done/slice-werkzeug-zellenlaenge-hat-einen-sensor.md`). Das ist Kriterium 1 aus
[`MR-054`](../../../../harness/conventions.md#mr-054) Setzung 1: der Dogfood fährt die Regel selbst. Dieser Plan wartet in `open/`, damit kein Slice
auf ihn in `in-progress/` wartet.

**Lage, am Ort benannt.** Der eingefrorene Plan `slice-werkzeug-zellen-tragen-ihre-prosa-unter-sensors`
schreibt, kein Sensor halte die Zellenlänge. Am gepinnten d-check `v0.79.0` tut es `structure`
(`table.column[].cell-max-chars`, Befund `section-cell-oversized`); der Plan bleibt unverändert
(`AGENTS.md` §3.11).

**Messung am Pin** (Wegwerf-Verzeichnis außerhalb des Repos mit der Vorlage
[`README.template.md`](../../../../.harness/baseline/v6.13.0/templates/harness/README.template.md) als
`harness/README.md` und einer Minimal-`.d-check.yml` mit `modules: [structure]`; gepinnter Digest aus
[`d-check.mk`](../../../../d-check.mk), `--network none`, Mount `:ro`):

- **Die Spaltenüberschriften der Vorlage gelten:** `| Target | Vertrag | Bindung |` (erste Tabelle) und
  `| Target | Tut was | Bindung |` (zweite). Beide stehen unter `## Sensors (Feedback-Gates)`.
- **Der Dogfood-Selektor gilt nicht.** Die Vorlage trägt keine `###`-Überschrift „Werkzeuge", sondern den
  Fettdruck-Absatz `**Werkzeuge — …**`; `section: "### Werkzeuge (kein Gate)"` träfe im Ziel keinen
  Abschnitt. Mit `section: "## Sensors (Feedback-Gates)"` findet die Regel die zweite Tabelle trotzdem
  (Grenze 60 → ein Befund auf der längsten Vorlagen-Zelle, 80 Zeichen; Grenze 200 → grün; eine 230-Zeichen-Zelle
  in der Vorlage → `section-cell-oversized` mit Zeile, Spalte und Zeichenzahl).
- **Grüner Start trägt:** die längsten Vorlagen-Zellen messen 62 (`Vertrag`) und 80 (`Tut was`) Zeichen.

```sh
awk '/^\| Target \| Vertrag/{f=1;next} /^\| Target \| Tut was/{f=2;next} f&&/^\|---/{next} f&&/^\| /{split($0,a,"|"); c=a[3]; gsub(/^ +| +$/,"",c); print f, length(c)} /^$/{f=0}' \
  .harness/baseline/v6.13.0/templates/harness/README.template.md | sort -k1,1 -k2,2n | awk '{m[$1]=$2}END{print m[1], m[2]}'   # 62 80
```

(`length` zählt hier Zeichen, solange die Locale UTF-8 ist; die Vorlagen-Zellen sind ASCII bis auf Umlaute —
die Zahl ist nicht Erwartungswert, [`MR-025`](../../../../harness/conventions.md#mr-025).)

**Schwelle: 200 für beide Spalten.** Die Vorlage trägt Platzhalter-Prosa bis 80 Zeichen; das Rot soll aus
Adopter-Inhalt kommen, nicht aus der emittierten Prosa ([`MR-054`](../../../../harness/conventions.md#mr-054) Setzung 2). 200 hat Luft über dem
Vorlagen-Bestand und bremst einen Zellsatz, der mehr als einen Satz trägt — die Vorlage selbst verlegt solche
Prosa nach `sensors/<target>.md`. Der Dogfood-Wert (260/150) misst den Bestand dieses Repos und überträgt sich
nicht. Der Implementer misst die gewählte Schwelle an der fertigen Konfiguration nach.

**Offen für den Architect (Übergabe, nicht Teil der DoD).** Die Baseline-Vorlage der Startkonfiguration führt
`structure` nur als Wort in der Modul-Liste (`grep -c structure .harness/baseline/v6.13.0/templates/.d-check.yml`
→ 1), also keine Position für eine Zellenregel; [`MR-054`](../../../../harness/conventions.md#mr-054) Setzung 1 deckt die Modul-Aktivierung, die Positionen
*innerhalb* eines Moduls lässt der Eintrag als eigene Entscheidung. Ob dafür ein Adaptions-Eintrag nötig ist,
entscheidet der Architect vor dem Start (`AGENTS.md` §3.8); ein ADR-Bedarf folgt aus einer Schärfung nicht
(`AGENTS.md` §3.5).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- Kein Nachzug in bestehende Ziele. Die emittierte `.d-check.yml` wird nur an einem freien Pfad geschrieben;
  ein Ziel mit eigener Fassung behält sie, der Nachzug ist Handarbeit nach der Liste im Kopfkommentar der
  Vorlage. *(Bestand bleibt stehen — Eigentum des Adopters.)*
- Keine Grenze auf `Bindung` und keine Untergrenze. Kennungs-Listen wachsen mit den Bindungen; die Zusage ist
  „Prosa unter `sensors/`". *(Bestand bleibt stehen; dieselbe Linie wie im Dogfood-Slice.)*
- Keine weiteren `structure`-Regeln im Ziel (etwa Stilllegungs-Form von Slice-Plänen). Jede Position braucht
  eigene Erprobung nach [`MR-054`](../../../../harness/conventions.md#mr-054). *(Anderer Vorgang.)*
- Keine Änderung der vendorten Vorlage `README.template.md` und keine der Dogfood-`.d-check.yml`. Die Vorlage
  ist Baseline-Bestand; der Dogfood ist der Vorgänger-Slice. *(Schicht-Abgrenzung.)*

## 2. Definition of Done

- [x] **(1) Die emittierte Vorlage trägt Modul und Regel, grün über dem frischen Ziel.**
      `internal/emit/templates/d-check.yml`: `structure` in `modules:`, ein Block mit
      `section: "## Sensors (Feedback-Gates)"` und den Spalten `Vertrag` und `Tut was`
      (`cell-max-chars: 200`), kein `exempt-paths`, der Kopfkommentar „Herkunft der Positionen" nennt die
      Position und ihre Grenze (nur freier Pfad, Nachzug Handarbeit). Ein Test in `internal/emit` hält Modul,
      Block und dass beide Spaltennamen in der vendorten Vorlage `README.template.md` als Kopfzeilen stehen.
      Die exakte Modul-Liste `[links, anchors, ids, matrix, spans]` ist an drei Stellen verdrahtet und wird in
      allen dreien nachgezogen: `internal/emit/emit_test.go` (`TestDCheckConfig_EntschiedeneModulListe`), das
      `sed` der Kennungs-Stufe in `harness/tools/full-smoke.sh` und der Zahn
      `test/mutations/295-emittierte-modulliste-verliert-matrix.sh`, dessen `sed`-Muster auf der neuen Liste
      nicht mehr trifft — Fall 295 wird nach [`MR-071`](../../../../harness/conventions.md#mr-071) gegen den
      neuen Bestand gemessen und rot gesehen (Verdikt: Architect-Bericht `2026-10-06-architect-zellenlaenge-ziel.md`).
      *Bricht die Zusage, wenn:* `structure` aus `modules:` fällt (das Ziel prüft keine Zelle mehr, bleibt aber
      grün) oder ein Baseline-Sprung eine Spalte umbenennt (jedes neue Ziel startet mit
      `section-column-missing` rot). Beides färbt den Test.
- [x] **(2) E2E-Stufe `zellenlaenge_im_ziel` in [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh).**
      Im frisch gebootstrappten Ziel: `make docs-check` ist grün (0 Befunde); je ein Satz über der Grenze in
      `Tut was` und in `Vertrag` der emittierten `harness/README.md` färbt `docs-check` rot, die Meldung
      `section-cell-oversized` wird gelesen; mit dem `structure`-Block aus der `.d-check.yml` des Ziels
      genommen bleibt dasselbe Gegenbeispiel grün (Gegenprobe, nach dem Muster der Kennungs-Stufe); danach
      zurückgenommen. Ein Fall in `test/mutations/` nimmt der Vorlage das Modul oder den Block (erwartet
      `full-smoke: FEHLER`); das `sed`-Muster ist gegen den Quell-Bestand gemessen
      ([`MR-071`](../../../../harness/conventions.md#mr-071)), der Fall fährt die Stelle, die der Aufrufer benutzt.
- [x] **(3) Deklaration und Sicht nach `AGENTS.md` §3.6.** Die Stufe ruft `e2e_abdeckung` mit
      den Kennungen [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) und [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6); die Kurzbeschreibung nennt, was der Lauf im Ziel misst — die zwei Spalten der
      Vorlagen-README an einem frisch emittierten Ziel — und die Teilabdeckung am selben Ort: nicht gemessen
      sind ein Ziel mit eigener `.d-check.yml` (skip-if-present), die Spalte `Bindung` und Tabellen außerhalb
      von `## Sensors`. `make e2e-abdeckung` erzeugt
      [`docs/user/e2e-abdeckung.md`](../../../../docs/user/e2e-abdeckung.md) neu; der Fall in
      [`test/e2e-abdeckung.bats`](../../../../test/e2e-abdeckung.bats) ist grün. *Grenze:* dieser Fall hält die
      Gleichheit der Datei mit der Deklaration, nicht deren Inhalt — wird die Teilabdeckung in der Deklaration
      gestrichen und die Datei neu erzeugt, bleibt er grün; ein Wächter dafür existiert nicht, Träger ist
      dieser Slice und sein Review.

Standard (zählen nicht): `make gates` grün · `make mutate` für den neuen Fall ohne Befund · `make full-smoke`
grün · Review-Report (kein Self-Review) · Closure-Notiz mit Lerneintrag · Register fortgeschrieben · Risiko-Ausgänge ·
drei Paarungen.

## 3. Plan (vor Code)

| Datei | Änderungs-Art | Begründung |
|---|---|---|
| `internal/emit/templates/d-check.yml` | update | DoD (1): Modul und Regel |
| Test in `internal/emit` | neu | DoD (1): Modul, Block, Spaltennamen gegen die Vorlage |
| `internal/emit/emit_test.go` | update | DoD (1): `TestDCheckConfig_EntschiedeneModulListe` bindet die neue Liste |
| `test/mutations/295-emittierte-modulliste-verliert-matrix.sh` | update | DoD (1): `sed`-Muster auf die neue Liste ([`MR-071`](../../../../harness/conventions.md#mr-071)) |
| [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh) | update | DoD (2) und (3): Stufe und Deklaration; das `sed` der Kennungs-Stufe (`modules:`-Liste) |
| `test/mutations/` | neu | DoD (2): Zahn am Modul |
| [`docs/user/e2e-abdeckung.md`](../../../../docs/user/e2e-abdeckung.md) | update (erzeugt) | DoD (3): `make e2e-abdeckung` |

Zwei Schichten: Emission und E2E-Skript.

## 4. Trigger

**Start** (`next` → `in-progress`): `slice-werkzeug-zellenlaenge-hat-einen-sensor` liegt in `done/`; der
Architect hat die Frage aus §1 beantwortet.

**Rückführungen:**

- `in-progress` → `next`: die Stufe braucht mehr als einen Fall je Spalte oder ein zweites Ziel-Layout — dann
  zu groß, nach Spalte schneiden.
- `in-progress` → `open`: das frisch emittierte Ziel startet mit der Regel rot, ohne dass Adopter-Inhalt schuld
  ist ([`MR-054`](../../../../harness/conventions.md#mr-054) Setzung 2) — Schwelle oder Selektor neu entscheiden.

## 5. Closure-Trigger

Zwei beobachtbare Kriterien: `make gates` und `make full-smoke` grün; die neue Stufe steht in
`docs/user/e2e-abdeckung.md` mit benannter Teilabdeckung. Dazu ein Lerneintrag in einer der drei Formen.

## 6. Risiken und offene Punkte

- Ein Adopter-Zellsatz über 200 färbt das Ziel rot, obwohl die Vorlage unschuldig ist. — **Ausgang:** entfallen:
  gewollt; das Rot kommt aus Adopter-Inhalt und kostet eine Verlagerung nach `sensors/` (Kostenmodell
  [`MR-017`](../../../../harness/conventions.md#mr-017)).
- Ein Baseline-Sprung benennt eine Spalte um. — **Ausgang:** entfallen: der Test aus DoD (1) und der grüne
  Start der Stufe färben beim Sprung rot, bevor ein Ziel es erbt.
- Bestehende Ziele bekommen die Regel nicht. — **Ausgang:** entfallen: gewollt (skip-if-present), der Nachzug
  steht als Handarbeit im Kopfkommentar der Vorlage.

## 7. Closure-Notiz

- **Was hat funktioniert:** Die emittierte Vorlage führt `structure` mit der Zellenregel (`Vertrag`, `Tut was`, je 200); die E2E-Stufe `zellenlaenge_im_ziel` misst grünen Start, je Spalte `section-cell-oversized` und die Gegenprobe im frischen Ziel; Deklaration und Sicht tragen die Teilabdeckung am selben Ort. Review: 1 LOW (behoben), 1 INFO; Verifikation bestätigt alle drei DoD-Punkte (`docs/reviews/2026-10-06-zellenlaenge-ziel-review.md`, `-verifikation.md`; Architect-Verdikt `2026-10-06-architect-zellenlaenge-ziel.md`).
- **Was ging anders als geplant:** DoD (1) nennt „ein Test in `internal/emit`" für Modul, Block und Spaltennamen; geliefert sind zwei Träger: Modul und Block hält der Go-Test `TestDCheckConfig_ZellenlaengeStructure`, die Spaltennamen gegen die vendorte Vorlage hält `test/emit-zellenlaenge-spalten.bats`, weil `.dockerignore` `.harness` aus dem Go-Test-Kontext ausschließt. Die DoD ist nicht umgeschrieben; die Abnahme liest beide Träger (Fall 516 färbt rot als bats-Meldung).
- **Steering-Loop-Eintrag:** benannte Lücke: die Zusage „Grenze der Spalte `Tut was` im Ziel" hängt allein an der Stufe `zellenlaenge_im_ziel`; kein `test/mutations`-Fall mit `verify: full-smoke` erwartet ihre Meldung (Fall 517 deckt sie nur über den Go-Test). Nicht gemessen: Ziel mit eigener `.d-check.yml`, Spalte `Bindung`, Tabellen außerhalb `## Sensors`, dritte Tabelle ohne die Spalten (`section-column-missing`).
- **Beobachtungs-Register (`../observations/`):** [`BEO-ALL/zusage-mit-bats-bindung-ohne-eigenen-mutations-fall`](../observations/BEO-ALL/zusage-mit-bats-bindung-ohne-eigenen-mutations-fall/observation.md): weiterer Beleg (`evidence/slice-zellenlaenge-sensor-geht-ins-ziel.md`); die Klasse ist in `AGENTS.md` §3.6 verkörpert, der Stand bleibt. `sensor-schranke-wird-durch-tabellenwachstum-unscharf` bleibt ohne Beleg: der Slice setzt die Schranke mit Luft über dem Vorlagen-Bestand.
- **Folge-Slices:** keiner; die Lücke trägt der Register-Beleg (Träger: Review gegen den Fall-Satz).
- **Risiken aus §6:** 1 entfallen (gewollt, im Plan begründet: das Rot kommt aus Adopter-Inhalt) · 2 entfallen (DoD-Test und grüner Start der Stufe färben beim Sprung rot, bevor ein Ziel es erbt) · 3 entfallen (gewollt, skip-if-present; der Nachzug steht als Handarbeit im Kopfkommentar der Vorlage).
- **Drei Paarungen:** Anker: kein `liegt in`-Feld, nichts zu paaren; Folge-Slice: keiner genannt; Register: der zitierte Pfad existiert und trägt Beleg.

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist `*` (gesamtes Repo, `ALL`) — Emissions-Vorlage und
`harness/tools/full-smoke.sh` (die Sub-Area `harness/tools/` ist mit `TOOLS` deklariert und GF). Beide erfüllen
das Inklusionskriterium.

**Vorgelagert — offene Beobachtungen sichten:** ein Treffer,
[`BEO-ALL/sensor-schranke-wird-durch-tabellenwachstum-unscharf`](../observations/BEO-ALL/sensor-schranke-wird-durch-tabellenwachstum-unscharf/observation.md),
Zähler-Stand 1 (`ls docs/plan/planning/observations/BEO-ALL/sensor-schranke-wird-durch-tabellenwachstum-unscharf/evidence | wc -l`
→ 1, gemergter Stand 2026-10-05); der Vorgänger-Slice führt ihn als Ausgang seines Risikos, sein Beleg kann den
Zähler auf 2 heben. Dieser Slice setzt eine Obergrenze mit Luft über dem Vorlagen-Bestand und berührt ihn
höchstens mit einem dritten Beleg — dann braucht er einen eigenen Folge-Slice.

### Sub-Area: `*` (gesamtes Repo) und `harness/tools/`

- **Modus:** GF (beide)
- **Konventionen-Dichte:** hoch — [`MR-054`](../../../../harness/conventions.md#mr-054) und [`MR-055`](../../../../harness/conventions.md#mr-055) binden die Emission, `full-smoke` trägt das Muster.
- **Phase-Reife:** Phase 5.
- **Evidenz-/Diskrepanz-Risiko:** niedrig; die Vorlage ist gemessen (§1).
- **Reconciliation-Aufwand:** keiner.


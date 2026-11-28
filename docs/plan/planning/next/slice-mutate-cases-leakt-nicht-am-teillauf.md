# Slice slice-mutate-cases-leakt-nicht-am-teillauf: der Teillauf des Mutations-Treibers bricht nicht mehr am Grün-Vorlauf

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — der Ausgang ist die DoD dieses Slice selbst (der
Verify-Befund B-1 ist der Auftrag; Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht). Wellenlose Arbeit erscheint nicht in der
Roadmap.

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(der dokumentierte Teillauf-Aufruf ist eine Zusage an den Aufruf — ein
dokumentierter Aufruf, der an seiner eigenen Doku-Form bricht, trägt seine
Zusage nicht),
[`ADR-0107`](../../adr/0107-die-mutations-record-granularitaet-ist-je-fall.md)
(die Fall-Granularität: der Fall-Ausgang trägt den Fall, nicht die
Umgebungs-Selektion),
[`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
(die Kennungs-Form dieser Slice-Kennung),
[`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)
/ [`MR-090`](../../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit)
(Anlage-Disziplin des Mutations-Falls, Anker am Commit).

**Berührte Spec-Stellen:** `—` — der Treiber-Teillauf liegt außerhalb jeder
Spec-Stelle; die Form der Werkzeug-Aussage trägt
[`harness/sensors/mutate.md`](../../../../harness/sensors/mutate.md).
Der Verweis zeigt **aufwärts**: Die Spec nennt diesen Slice nie.

**Verantwortlich:** —

**Autor:** pt9912 (Rolle Planner, Übergabe des Verify-Befunds B-1 aus
`slice-stamp-records-konsum-v1`). **Datum:** 2026-11-28.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — vier Klassen ausdrücklich ausgeschlossener Punkte sind ein
Suchraster, keine Ausfüll-Liste.

**Ziel:** Der dokumentierte Teillauf des Mutations-Treibers —
`make mutate MUTATE_CASES='<fälle>'` (genau die Form, die
[`harness/tools/mutate-auswahl.sh`](../../../../harness/tools/mutate-auswahl.sh)
druckt und der CI-Shard in
[`.github/workflows/mutate.yml`](../../../../.github/workflows/mutate.yml)
als `env: MUTATE_CASES:` setzt) — schließt den Grün-Vorlauf ab, statt an
`mutate: ABBRUCH — MUTATE_CASES nennt einen unbekannten Fall` zu brechen: die
Fall-Auswahl aus der Umgebung wirkt nur auf die Fall-Wahl des Teillaufs, nicht
auf die geschachtelten greift-Züge der bats-Wächter (`greift_main` liest
`MUTATE_CASES` aus der Umgebung,
[`harness/tools/mutate.sh`](../../../../harness/tools/mutate.sh); der
Wrapper-Fall `greift: ein Pfad, der Praefix …` liest dieselbe Variable,
`test/mutate-driver.bats`). Ein Entzug (`env -u`/`unset`) oder eine
Namespace-Trennung entlang des Vorlaufs trägt die Zusage.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- *(Bestand bleibt bewusst stehen.)* Die Rot-Züge der Bestands-Wächter laufen
  bis zur Behebung als Substitution je Fall-Kopf am realen Werkzeug (Form je
  Verify-Bericht `slice-stamp-records-konsum-v1`, B-1); bestehende
  Mutations-Fälle werden nicht nachgerüstet, der Übergang zum
  Teillauf-Rot-Zug geschieht je Fall bei Berührung.
- *(Es wäre ein anderer Vorgang.)* Der divergente gepushte Branch
  `mutate/slice-stamp-records-konsum-v1-b63291e6` (Verify-Befund B-2): seine
  Löschung (`git push origin :refs/heads/mutate/slice-stamp-records-konsum-v1-b63291e6`)
  und der reale Konsum-Stamp über der verifizierten Kette sind
  Auftraggeber-Entscheidung — als Lösch-Posten in der Closure von
  `slice-stamp-records-konsum-v1` übergeben, nicht hier entschieden; dieser
  Slice trägt die Löschung nicht.
- *(Schicht-Abgrenzung.)* Der Mutations-Vollsweep (`make mutate` ohne
  `MUTATE_CASES`, `MUTATE_FORCE`) und die Fall-Anlagen selbst bleiben
  unangetastet — berührt wird nur die Stelle, die die Umgebungs-Selektion in
  den geschachtelten greift-Zug liest.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; Gate-Läufe und die Closure-Pflichten
zählen nicht mit.

- [ ] **Liefer-Punkt 1:** der Teillauf
      `make mutate MUTATE_CASES='<fälle>'` (Fall-Kennungen je
      [`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)-Form)
      endet nicht mehr im `MUTATE_CASES nennt einen unbekannten Fall`-Abbruch
      des Grün-Vorlaufs — Rot-Beleg **je Richtung**
      ([`AGENTS.md`](../../../../AGENTS.md) §3.6): am Ist-Stand
      `MUTATE_CASES='810-…' bats -f 'greift: ein Pfad, der Praefix' test/mutate-driver.bats`
      → not ok, ohne die Variable → ok; nach der Behebung → ok je Richtung.
- [ ] **Liefer-Punkt 2:** der Wächter über dem realen Werkzeug plus ein
      Mutations-Fall, dessen Patch den Vorlauf-Entzug herausnimmt und dessen
      Wächter rot färbt — Anlage misst den `sed`-Anker gegen den Quell-Bestand
      ([`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)),
      Anker am Commit
      ([`MR-090`](../../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit)).
- [ ] **Liefer-Punkt 3:** die Doku-Form —
      [`harness/sensors/mutate.md`](../../../../harness/sensors/mutate.md) nennt,
      falls der öffentliche Vertrag berührt ist, dass die Teillauf-Auswahl den
      Grün-Vorlauf der Suite nicht mehr erreicht (Träger und Grenze).

- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — kein Self-Review (Modul 8).
- [ ] Doku-Update, falls ein öffentlicher Vertrag berührt ist.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben —
      `evidence/slice-mutate-cases-leakt-nicht-am-teillauf.md` in
      `BEO-ALL/mutate-cases-leakt-in-den-bats-gruen-vorlauf/` ergänzen; keine
      Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang.
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind hier geprüft —
      Repo ohne Wellen-Betrieb, nach dem `git mv`.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`harness/tools/mutate.sh`](../../../../harness/tools/mutate.sh) | update | der Vorlauf-Entzug: die geschachtelten greift-Züge der bats-Suite laufen ohne die Umgebungs-Auswahl (Entzug am gemeinsamen Eingang, nicht je Aufrufer) — LP 1 |
| `test/mutate-driver.bats` | update | der Wrapper-Fall liest die Auswahl nicht mehr still aus der Umgebung (oder sie tritt dort nur, wo der Fall sie ausdrücklich setzt) — LP 1 |
| `test/mutations/<nr>-…sh` | neu | Mutations-Fall über dem Entzug; der Wächter färbt rot ([`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)/[`MR-090`](../../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit)) — LP 2 |
| [`harness/sensors/mutate.md`](../../../../harness/sensors/mutate.md) | update | Träger-Form des Teillauf-Aufrufs, falls der Vertrag berührt ist — LP 3 |

## 4. Trigger

**Start** (`next` → `in-progress`): der Auftrag liegt vor — der
Verify-Befund B-1 des Berichts
`docs/reviews/2026-11-27-slice-stamp-records-konsum-v1-verify.md` (beobachtbar
an der Befund-Zeile); der Teillauf fällt am Bestand noch nachweisbar
(Rot-Beleg je Richtung in LP 1).

**Rückführungen — vorab benennen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): gerät der Entzug je
  Aufrufer-Klasse (make-Rezept, Workflow `mutate.yml`, direkter `bats`-Aufruf)
  als je eigener Liefer-Punkt in den Umfang — dann re-slicen je Aufrufer-Klasse.
- `in-progress` → `open` (blockiert — Carveout?): der Entzug bricht die
  Rot-Messung der Bestands-Wächter selbst (der Fall-Ausgang lässt sich von der
  Umgebung nicht mehr trennen) — Architektur-Frage an den Aufruf der
  Mutations-Fälle.

## 5. Closure-Trigger

DoD (§2) vollständig; der reale Teillauf über der verifizierten Kette grün und
die Rot-Belege je Richtung in der Übergabe; `make gates` grün; Review-Report
unter `docs/reviews/`; Closure-Notiz mit Lerneintrag.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- Der Entzug braucht eine Stelle entlang des Vorlaufs, die jede
  Aufrufer-Klasse trifft (make-Rezept, CI-Workflow, direkter `bats`-Aufruf);
  eine Stelle am Rezept allein entzahnt die anderen. — **Ausgang:** bei
  Closure entscheiden — Entzug am gemeinsamen Eingang (`greift_main` resp.
  der Vorlauf-Einstieg) oder die Lücke je Aufrufer-Klasse benannt.
- Bis der Teillauf trägt, messen die Bestands-Wächter ihre Rot-Züge als
  Substitution am Fall-Kopf; der Übergang je Fall zum Teillauf-Rot-Zug kann
  unbekannt bleiben. — **Ausgang:** weiter offen — steht nach der Closure ein
  Fall ohne Teillauf-Rot-Zug, trägt ihn `BEO-TOOLS/` im Register (Anlage-Form
  je [`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)).

## 7. Closure-Notiz

- *(wird bei dessen Closure gefüllt)*

## 8. Sub-Area-Prüfungen und Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** und die **vier Pflichtkriterien**, vier und nicht mehr.

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist `harness/tools/`
(Kürzel `TOOLS`, Modus-Deklaration
[`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area) — die Schwelle ≥ 2 von 3 Achsen ist erfüllt
(Strukturregeln über den Adaptions-Block, Phase-Reife Phase 5 — die Tools
laufen in `make gates`).

**Vorgelagert — offene Beobachtungen sichten:** Register gemergt gelesen.
Treffer: [`BEO-ALL/mutate-cases-leakt-in-den-bats-gruen-vorlauf`](../observations/BEO-ALL/mutate-cases-leakt-in-den-bats-gruen-vorlauf/state.md)
— Zähler 2× (`ls evidence | wc -l`) nach der Geber-Closure von
`slice-stamp-records-konsum-v1`, unter der Schwelle; dieser Slice ist die
Adresse des Befunds, bei Closure die `evidence/`-Datei ergänzen. Keine
weiteren Treffer an der berührten Ebene.

**Modus:** alle berührten Sub-Areas GF — der Modus-Begründungsblock entfällt.

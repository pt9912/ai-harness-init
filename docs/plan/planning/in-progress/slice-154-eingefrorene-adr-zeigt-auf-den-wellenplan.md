# Slice slice-154: Eine eingefrorene ADR zeigt auf den Wellenplan, den die Closure wegzieht

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Der Baseline-Test ist das *Mehr*
(`modul-06-roadmap.md` §Wann Arbeit eine Welle braucht): eine beobachtbare
Closure-Bedingung, die mehr beobachtet als die DoD dieses Slice. Es gibt keine —
der Slice **blockiert** die Closure von
[welle-10](../welle-10-re-baseline.md), gehört ihr aber nicht an: sein
Gegenstand ist eine Gate-Entscheidung, kein Durchgang der Re-Baseline-Prozedur.

**Bezug:** [ADR-0018](../../adr/0018-ziel-fassung-regiert-die-migration.md)
(`Accepted`; das Artefakt, das die tote Adresse trägt),
[ADR-0026](../../adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md)
und [ADR-0027](../../adr/0027-tote-adresse-in-eingefrorener-adr.md) (dieselbe
Klasse, zweimal entschieden; beide schließen ihre `ignore-refs`-Menge
**extensional** und verlangen für jedes weitere Paar eine eigene ADR),
[`AGENTS.md`](../../../../AGENTS.md) §3.4 (Immutabilität) und §3.5
(Gate-Senkung → ADR),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6).

**Berührte Spec-Stellen:** `—`.

**Verantwortlich:** Architect (pt9912). Der Liefergegenstand ist eine
Gate-Senkung mit ADR und damit **Architect**-Arbeit
([`AGENTS.md`](../../../../AGENTS.md) §3.5/§3.8); das Feld weicht damit von der
Default-Besetzung ab, die Baseline-Regelwerk `modul-05-planning-harness.md`
§Lifecycle als State Machine nennt.

**Autor:** Planner. **Datum:** 2026-09-02.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

Die Closure von [welle-10](../welle-10-re-baseline.md) verlangt den `git mv`
der Welle-Plan-Datei nach `done/` (Baseline-Regelwerk `modul-06-roadmap.md`
§Wellen-Closure-Prozedur, Schritt 3 — der Zustand ist die
Verzeichnis-Position). Der Move macht **eine** Adresse tot, und sie steht in
einem eingefrorenen Artefakt:

```
docs/plan/adr/0018-ziel-fassung-regiert-die-migration.md:202
        docs/plan/planning/welle-10-re-baseline.md    codepath-missing
```

Gemessen am 2026-09-02: der Move wurde vollzogen, **alle** übrigen Verweise
wurden in beide Richtungen nachgezogen, und `make docs-check` meldete danach
`491 Datei(en) geprüft, 1 Befund(e)` — genau diesen. Der Zustand ist
zurückgenommen; die Welle bleibt offen.

**Im Artefakt ist er unbehebbar.**
[ADR-0018](../../adr/0018-ziel-fassung-regiert-die-migration.md) steht auf
`Accepted`, und [`AGENTS.md`](../../../../AGENTS.md) §3.4 bindet nach
[ADR-0027](../../adr/0027-tote-adresse-in-eingefrorener-adr.md) Festlegung 1
*„das Artefakt, nicht nur seine Aussage"*. Zugleich sind die zwei bestehenden
Referenz-Ventile extensional geschlossen: *„jeder zusätzliche Eintrag … ist eine
neue Senkung und löst §3.5 erneut aus — auch dann, wenn er dieselbe Bedingung
erfüllt"*. Ein Planner-Lauf kann den Befund damit weder beheben noch ausnehmen.

**Die Klasse steht bei drei Instanzen, und das ist der eigentliche Gegenstand.**
[ADR-0026](../../adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md)
(Baseline-Pfad nach dem Tag-Tausch),
[ADR-0027](../../adr/0027-tote-adresse-in-eingefrorener-adr.md)
(Carveout-Pfad nach dem `done/`-Move) und dieser Befund (Wellenplan-Pfad nach
dem Closure-Move) sind dasselbe Muster: *ein vom Prozess **vorgeschriebener**
Ortswechsel macht eine Adresse in einem eingefrorenen Artefakt tot.* Die dritte
Instanz ist der Punkt, an dem eine Regel billiger wird als das nächste
Einzel-Ventil.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [ ] **(1) Eine ADR entscheidet den Fall und die Klasse** — per `cp` aus
      `.harness/baseline/v5.12.0/templates/docs/plan/adr/NNNN-titel.template.md`,
      mit Bezug auf
      [ADR-0026](../../adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md)/[ADR-0027](../../adr/0027-tote-adresse-in-eingefrorener-adr.md).
      Sie wägt mindestens die drei Wege gegeneinander, die die Vorgänger schon
      benannt haben: ein **drittes namentliches Ventil** (dieselbe Form, dritte
      Senkung) · eine **Form-Regel für den Accept-Übergang** in der Art von
      [ADR-0027](../../adr/0027-tote-adresse-in-eingefrorener-adr.md)
      Festlegung 3, auf Wellenplan- und Slice-Adressen ausgedehnt (feedforward —
      sie deckt den heutigen Bestand nicht) · eine **Bereichs-Ausnahme** für
      `docs/plan/adr/**` in `codepaths.exempt-paths` (breit; die Vorgänger haben
      Globs zweimal ausdrücklich verworfen). Der ADR-Index
      ([`docs/plan/adr/README.md`](../../adr/README.md)) trägt die Zeile.
- [ ] **(2) Der Befund ist weg, und die Entscheidung ist rot gesehen**
      ([`AGENTS.md`](../../../../AGENTS.md) §3.6): der `git mv` von
      [welle-10-re-baseline.md](../welle-10-re-baseline.md) nach `done/` wird
      probeweise vollzogen, `make docs-check` meldet ohne die Entscheidung
      `codepath-missing` auf Zeile **202** von
      [ADR-0018](../../adr/0018-ziel-fassung-regiert-die-migration.md) und mit
      ihr **0 Befunde**. Fällt die
      Wahl auf eine Config-Änderung, trägt die Zeile ihre Begründung und einen
      Zeiger auf die neue ADR — wie jede Ventil-Zeile der
      [`.d-check.yml`](../../../../.d-check.yml).
- [ ] `make gates` grün.
- [ ] Doku-Update: `harness/conventions.md`, falls die Entscheidung einen
      `MR`-Eintrag verlangt (Architect, eigener Commit).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations.md`) fortgeschrieben — **neue
      Kennung für die Klasse** *ein prozess-vorgeschriebener Ortswechsel macht
      eine Adresse in einem eingefrorenen Artefakt tot* (Sub-Area `*`, 1×, Beleg
      `slice-154`); die drei gemessenen Instanzen gehören in die Stand-Spalte.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) prüft die nächste
      Welle-Closure — die von [welle-10](../welle-10-re-baseline.md), die dieser
      Slice freigibt.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `docs/plan/adr/00NN-….md` | neu (per `cp` aus der vendored Vorlage), Architect | DoD (1) |
| [`docs/plan/adr/README.md`](../../adr/README.md) | update (Index-Zeile), Architect | DoD (1) |
| [`.d-check.yml`](../../../../.d-check.yml) | update **oder** unberührt, Architect | DoD (2) — hängt an der gewählten Option |
| [`docs/plan/adr/0018-ziel-fassung-regiert-die-migration.md`](../../adr/0018-ziel-fassung-regiert-die-migration.md) | **unberührt** | `Accepted` ([`AGENTS.md`](../../../../AGENTS.md) §3.4) — kein Byte, auch nicht an der Adresse |
| [`docs/plan/planning/observations.md`](../observations.md) | update (neue Kennung) | Register-Pflicht (nicht mitgezählt) |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): ein Architect-Lauf steht bereit. Keine
technische Vorbedingung — der Befund ist gemessen und reproduzierbar (§1).
**Dieser Slice ist die Vorbedingung der welle-10-Closure**, nicht umgekehrt.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die Entscheidung
  über den Einzelfall hinaus eine Form-Regel für den Accept-Übergang setzt und
  deren Anwendung auf den Bestand eigene Arbeit verlangt — dann trennt sich der
  Slice in *Entscheidung* und *Anwendung*.
- `in-progress` → `open` (blockiert — Carveout?): wenn keine der drei Optionen
  trägt. **Ein Carveout ist hier kein Ausweg** —
  [welle-10](../welle-10-re-baseline.md) §3 verlangt `make gates` grün *„ohne
  offenen Carveout auf einem Gate dieser Welle"*, und `docs-check` ist eines
  ([`CO-005`](../../carveouts/done/CO-005-adaptions-block-datierter-beleg.md)
  lag darauf).

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

**Erstens:** die neue ADR trägt `**Status:** Accepted` und steht im ADR-Index.
**Zweitens:** über einem Baum, in dem
[welle-10-re-baseline.md](../welle-10-re-baseline.md) in `done/` liegt, meldet
`make docs-check` **0 Befunde** — und ohne die Entscheidung meldet derselbe Lauf
`codepath-missing` (beide Ausgaben im Closure-Eintrag zitiert). Dazu die
Closure-Notiz mit Steering-Loop-Lerneintrag und je Risiko aus §6 genau ein
Ausgang.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Die Entscheidung fällt wieder auf ein Einzel-Ventil**, und die vierte
  Instanz kostet dieselbe Runde. — **Ausgang:** <entfallen: die ADR trifft die
  Klasse und nennt, was die nächste Instanz trägt | weiter offen → neue
  `BEO-<NNN>` im Register>
- **Eine Bereichs-Ausnahme für `docs/plan/adr/**` nimmt mehr aus als den Fall**
  — sie machte jede tote Adresse in jeder ADR unsichtbar, auch in noch
  änderbaren `Proposed`-Fassungen. — **Ausgang:** <entfallen: verworfen und in
  §Verglichene Alternativen begründet | eingetreten: die Senkung ist gemessen
  und ihre Restbreite benannt>
- **Der Befund wandert**, weil ein weiterer Wellenplan oder eine Slice-Datei
  aus einem eingefrorenen Artefakt adressiert wird, bevor die ADR steht. —
  **Ausgang:** <entfallen: die Menge ist vor der Entscheidung erhoben — ein
  `git grep` über `docs/plan/adr` nach Code-Span-Pfaden unter
  `docs/plan/planning/` | eingetreten: die ADR nimmt die zusätzlichen Fälle mit
  auf>

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien** (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und
nicht mehr.

**Umfang.** Der **Modus-Begründungsblock** unten ist Pflicht, sobald
mindestens eine berührte Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei
reinem GF genügt der Hinweis *"alle berührten Sub-Areas GF"*; bei reinem
Refactor ohne neue Sub-Area-Berührung entfällt er ganz. Die beiden
*Vorgelagert*-Blöcke entfallen nie.

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt sind `docs/plan/adr/` und das
Wurzelverzeichnis ([`.d-check.yml`](../../../../.d-check.yml)). Beide fallen
unter den Eintrag `*` (gesamtes Repo) der Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area)
— **alle berührten Sub-Areas GF**, der Modus-Begründungsblock entfällt damit
nach dem *Umfang*-Absatz oben.

**Vorgelagert — offene Beobachtungen sichten:** kein Eintrag des Registers
führt diese Klasse; das ist selbst der Befund, und DoD legt die Kennung an.
[`BEO-006`](../observations.md) (1×) grenzt an, trifft aber nicht: dort fehlt
dem Doku-Gate eine **Fähigkeit**, hier ist die Fähigkeit da und wird
absichtlich eingeschränkt. [`BEO-016`](../observations.md) (1×, Plan-Umfang) ist
auf diesen Plan angewandt statt notiert.

# Slice slice-werkzeug-festlegungen-ziehen-in-die-spezifikation: Was ein Harness-Werkzeug prüft und wie es an Randformen entscheidet, steht in der Spezifikation

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — die Closure-Bedingung ist die DoD dieses Slice; Baseline-Regelwerk
`modul-06-roadmap.md` §Wann Arbeit eine Welle braucht.

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`ADR-0078`](../../adr/0078-ziel-fassung-regiert-den-sprung-v6160.md) (Festlegung 3, Zeile Welle 158,
und ihr akzeptiertes Negativ zu Skriptkopf und `AGENTS.md` §3.7),
[`MR-075`](../../../../harness/conventions.md#mr-075),
[`MR-019`](../../../../harness/conventions.md#mr-019),
[`MR-025`](../../../../harness/conventions.md#mr-025);
Architect-Verdikt `docs/reviews/2026-10-07-spezifikation-nummern-verdikt.md` (Übergabe-Artefakt zur
Aufnahme-Regel).

**Berührte Spec-Stellen:** `spezifikation.md §Aufnahme-Regel` (Formregel zu den Abschnittsnummern),
`spezifikation.md §7` (neu, *Festlegungen der Harness-Werkzeuge*, ohne Zeilen),
`spezifikation.md §8` (Historie, bisher §7).

**Verantwortlich:** pt9912 (Implementer).

**Autor:** Planner. **Datum:** 2026-10-06.

---
## 1. Ziel und Abgrenzung

**Ziel:** Die Spezifikation trägt die Gliederung der Vorlage am Tag `v6.16.0` (Welle 158): §7
*Festlegungen der Harness-Werkzeuge* als Ort für die Festlegungen der Werkzeuge, die Historie als §8;
die Formregel der Aufnahme-Regel zu den Abschnittsnummern sagt, wann die Vorlage neu nummerieren darf;
die emittierten Kommentare beschreiben das Skelett des Ziels, wie es ist. **Der Slice ist vor dem
Release `v0.3.0` fällig:** die emittierte Gate-Vorlage beschreibt sonst im Ziel eine Überschrift, die
dessen Spezifikations-Skelett nicht trägt. Der Umzug der Festlegungen selbst liegt in den
Folge-Slices je Werkzeug-Gruppe (Abgrenzung unten).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Inventur und Umzug der Festlegungen aus `harness/sensors/` und den Skriptköpfen in
  `harness/tools/`.** *Folge-Slices*, je Werkzeug-Gruppe einer, geschnitten nach Review-Größe:
  [`slice-festlegungen-doku-gate-ziehen-in-die-spezifikation`](../open/slice-festlegungen-doku-gate-ziehen-in-die-spezifikation.md),
  [`slice-festlegungen-history-waechter-ziehen-in-die-spezifikation`](../open/slice-festlegungen-history-waechter-ziehen-in-die-spezifikation.md),
  [`slice-festlegungen-lifecycle-werkzeuge-ziehen-in-die-spezifikation`](../open/slice-festlegungen-lifecycle-werkzeuge-ziehen-in-die-spezifikation.md),
  [`slice-festlegungen-waechter-und-hooks-ziehen-in-die-spezifikation`](../open/slice-festlegungen-waechter-und-hooks-ziehen-in-die-spezifikation.md),
  [`slice-festlegungen-e2e-werkzeuge-ziehen-in-die-spezifikation`](../open/slice-festlegungen-e2e-werkzeuge-ziehen-in-die-spezifikation.md),
  [`slice-festlegungen-release-werkzeuge-ziehen-in-die-spezifikation`](../open/slice-festlegungen-release-werkzeuge-ziehen-in-die-spezifikation.md),
  [`slice-festlegungen-telemetrie-werkzeuge-ziehen-in-die-spezifikation`](../open/slice-festlegungen-telemetrie-werkzeuge-ziehen-in-die-spezifikation.md).
  Zusammen nennen ihre §3 jede Datei aus `ls harness/sensors/*.md harness/tools/*.sh` genau einmal.
- **Mutationsfall `test/mutations/298-emittierte-matrix-exclude-sections-faellt-zurueck.sh`.**
  *Bestand bleibt stehen:* sein `sed`-Anker `exclude-sections: [Geschichte]` steht unverändert in
  `internal/emit/templates/d-check.yml`, und der Rückfall auf die frühere Dogfood-Liste bleibt die
  Mutation, gegen die der Wächter bindet.

- **`Accepted`-Gate-ADRs mit `Schärft: —`.** *Bestand bleibt stehen:* [`AGENTS.md`](../../../../AGENTS.md)
  §3.4; neue Gate-ADRs schärfen ihre Stelle ([ADR-0078](../../adr/0078-ziel-fassung-regiert-den-sprung-v6160.md) Festlegung 3).
- **Keine Hard-Rule-Änderung an §3.7.** *Bestand bleibt stehen:* der Rang-Zeiger ist eine Klasse,
  die §3.7 führt ([ADR-0078](../../adr/0078-ziel-fassung-regiert-den-sprung-v6160.md), akzeptiertes Negativ).
- **Form der Sensor-Datei selbst.** *Folge-Slice:*
  [`slice-222`](../open/slice-222-sensor-datei-traegt-die-form-ihrer-vorlage.md).
- **Emittierte Spezifikations-Vorlage.** *Bestand bleibt stehen:* sie reist mit dem Pin ([ADR-0078](../../adr/0078-ziel-fassung-regiert-den-sprung-v6160.md)
  §Emittierte Ebene) und trägt am `v6.16.0` §7/§8 schon (Lage oben); hier werden nur die Kommentare
  wahr, die sie beschreiben.
- **Kein neuer Ausnahme-Gegenstand.** *Anderer Vorgang:* `exclude-sections` zieht nur den neuen Namen
  desselben Abschnitts nach — keine Senkung nach [`AGENTS.md`](../../../../AGENTS.md) §3.5.

## 2. Definition of Done

- [ ] **1 — Gliederung:** §7 *Festlegungen der Harness-Werkzeuge* steht mit der Spaltenform der
      Vorlage und ohne Zeilen (Bindungs-Spalte nach
      [`MR-075`](../../../../harness/conventions.md#mr-075)); die Historie ist §8;
      `exclude-sections` in `.d-check.yml` nennt den neuen Namen. **Rot gesehen**
      ([`AGENTS.md`](../../../../AGENTS.md) §3.6): `exclude-sections` behält einmal den alten Namen,
      und `make docs-check` meldet einen Befund aus dem Historie-Abschnitt.
- [ ] **2 — Aufnahme-Regel:** die Formregel zu den Abschnittsnummern sagt nach dem
      Architect-Verdikt (Bezug oben): Nummern werden nicht neu vergeben, außer die Gliederung der
      adoptierten Vorlage setzt sie neu; dann misst der Lauf vorher über Link und Code-Span, ob ein
      eingefrorenes Artefakt den Anker nennt, und findet er einen, fällt die Entscheidung vor der
      Umnummerierung. §8 trägt dazu eine Zeile.
- [ ] **3 — Emittierte Kommentare (vor `v0.3.0`):** die zwei Stellen in
      `internal/emit/templates/d-check.yml` (Überschrift des Skeletts ist *„8. Historie"*; die
      Dogfood-Liste trägt den neuen Namen) und der Kommentar in `internal/emit/emit_test.go`
      beschreiben, was da ist; `exclude-sections: [Geschichte]` der Vorlage bleibt; `make full-smoke`
      endet EXIT 0.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register: entfällt — kein Brownfield-Bootstrap.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben, oder „keine Beobachtung" in §7.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen prüft die nächste Welle-Closure (das Repo fährt Wellen).

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `spec/spezifikation.md` §7, §8 | update | Liefer-Punkt 1 |
| `spec/spezifikation.md` §Aufnahme-Regel, §8 | update | Liefer-Punkt 2 |
| `.d-check.yml` (`exclude-sections`) | update | Liefer-Punkt 1 |
| `internal/emit/templates/d-check.yml`, Kommentar in `internal/emit/emit_test.go` | update | Liefer-Punkt 3 |

## 4. Trigger

**Start** (`next` → `in-progress`): `slice-sprung-auf-v6160-wird-vollzogen` liegt in `done/` — die
Regel steht dann im vendored Baum (erfüllt). WIP-Limit frei.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next`: Die Gliederung oder die Regeländerung verlangt mehr als die drei
  Liefer-Punkte. Die frühere Bedingung — der Umzug übersteigt eine Review-Sitzung, gemessen an
  `wc -l harness/sensors/*.md` und den Skriptköpfen — ist eingetreten; sie ist ohne Rückführung
  aufgelöst, weil Inventur und Umzug an die Folge-Slices (§1) gingen und der verbleibende Umfang
  bereits geliefert bzw. ein Satz ist (Commits `7978f3ca`, `50a0dff0`; Liefer-Punkt 2 offen).
- `in-progress` → `open`: Die neue Formregel lässt sich nicht schreiben, ohne eine `Accepted`-ADR zu
  berühren — Übergabe an den Architect.

## 5. Closure-Trigger

1. `grep -n '^## ' spec/spezifikation.md | tail -1` nennt die Historie als §8, und `make docs-check`
   ist grün.
2. Die Formregel der Aufnahme-Regel nennt die Ausnahme der adoptierten Vorlage und die Messung vor
   der Umnummerierung, und §8 trägt die Zeile dazu.

**Lerneintrag** in einer der drei Formen, §7; die Closure schreibt der Planner
([`AGENTS.md`](../../../../AGENTS.md) §3.10).

## 6. Risiken und offene Punkte

- **Rang-Zeiger nennt eine Festlegung, deren Zweifelsregel anders entscheidet** — beim Umzug
  divergieren Quelle und Spezifikation; `rang-zeiger-nennt-eine-festlegung-deren-zweifelsregel-anders-entscheidet`
  im Register. — **Ausgang:** bei Closure *entfallen*, wenn der Umzug wie geplant nicht hier
  stattfindet — die Folge-Slices führen das Risiko in ihrem §6.
- **Festlegung und Rumpf nennen verschiedene Reichweiten** —
  `festlegung-und-ihr-rumpf-nennen-verschiedene-reichweiten` im Register. — **Ausgang:** wie oben.
- **[`MR-001`](../../../../harness/conventions.md#mr-001) nennt den Dogfood-Wert ohne den neuen
  Namen** — sein Feld *Ersetzt-Baseline-Regel* führt `matrix.exclude-sections: [Historie, "7. Historie",
  Geschichte]`, `.d-check.yml` trägt seit Liefer-Punkt 1 zusätzlich `"8. Historie"`. Ob das eine
  Kopf-Marke oder einen Folge-Eintrag braucht, entscheidet der Architect
  ([`AGENTS.md`](../../../../AGENTS.md) §3.8); dieser Punkt ist die Übergabe. — **Ausgang:** offen bis
  zum Architect-Verdikt, spätestens zur Closure.

## 7. Closure-Notiz

- **Was hat funktioniert:** —
- **Was ging anders als geplant:** —
- **Steering-Loop-Eintrag:** —
- **Beobachtungs-Register (`../observations/`):** —
- **Folge-Slices:** —
- **Risiken aus §6:** —

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist `*` (Spezifikation, `.d-check.yml`,
`internal/emit/`); `TOOLS` und `CODEX` nicht — die Skriptköpfe gingen an die Folge-Slices.

**Vorgelagert — offene Beobachtungen sichten:** Register am gemergten Stand gesichtet, nach
Gegenstand; Zähler `ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`: die zwei
Einträge aus §6. Für `TOOLS` kein Eintrag — alle Beobachtungen führen `*`.

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).


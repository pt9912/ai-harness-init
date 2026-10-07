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
[`MR-025`](../../../../harness/conventions.md#mr-025).

**Berührte Spec-Stellen:** `spezifikation.md §1`, `spezifikation.md §7` (neu, *Festlegungen der
Harness-Werkzeuge*), `spezifikation.md §8` (Historie, bisher §7).

**Verantwortlich:** pt9912 (Implementer).

**Autor:** Planner. **Datum:** 2026-10-06.

---
## 1. Ziel und Abgrenzung

**Ziel:** Nach `grundlagen-harness-dateien.md` am Tag `v6.16.0` (Welle 158) steht jede Festlegung
eines Harness-Werkzeugs — was ein Gate, Prüfer oder Hook prüft und wie er an Randformen entscheidet —
in der Spezifikation: als Verfeinerung in §1, wenn das Werkzeug genau eine Anforderung durchsetzt,
sonst in §7 *Festlegungen der Harness-Werkzeuge*; die Historie wird §8. Sensor-Datei und Skriptkopf
tragen die Festlegung nicht mehr, sondern einen Rang-Zeiger dorthin. **Liefer-Punkt 3 ist vor dem
Release `v0.2.9` fällig:** die emittierte Gate-Vorlage beschreibt sonst im Ziel eine Überschrift, die
dessen Spezifikations-Skelett nicht trägt.

**Lage** (Arbeitsbaum dieses Plans, keine Erwartungswerte):

```sh
ls harness/sensors/*.md | wc -l                                  # 21
ls harness/tools/*.sh | wc -l                                    # 28 Skriptköpfe
grep -n '^## ' spec/spezifikation.md                             # Aufnahme-Regel, 3, 5, 6, 7. Historie — kein §1
grep -c '"7. Historie"' .d-check.yml                             # 1 (exclude-sections)
grep -n '7\. Historie' internal/emit/templates/d-check.yml internal/emit/emit_test.go
                                                                 # d-check.yml:34, :44 (Kommentar), emit_test.go:111 (Kommentar)
grep -n '^## [78]' .harness/baseline/v6.16.0/templates/spec/spezifikation.template.md
                                                                 # 7. Festlegungen der Harness-Werkzeuge, 8. Historie
```

Das Spezifikations-Skelett eines Ziels kommt aus dem Template-Satz des gepinnten Tags (`DefaultTag`
in `internal/fetch/baseline.go` ist `v6.16.0`) und trägt §7/§8 bereits; falsch sind allein die
Kommentare, die es als *„7. Historie"* beschreiben.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **`Accepted`-Gate-ADRs mit `Schärft: —`.** *Bestand bleibt stehen:* [`AGENTS.md`](../../../../AGENTS.md)
  §3.4; neue Gate-ADRs schärfen ihre Stelle ([ADR-0078](../../adr/0078-ziel-fassung-regiert-den-sprung-v6160.md) Festlegung 3).
- **Keine Hard-Rule-Änderung an §3.7.** *Bestand bleibt stehen:* der Rang-Zeiger ist eine Klasse,
  die §3.7 führt ([ADR-0078](../../adr/0078-ziel-fassung-regiert-den-sprung-v6160.md), akzeptiertes Negativ).
- **Form der Sensor-Datei selbst.** *Folge-Slice:*
  [`slice-222`](slice-222-sensor-datei-traegt-die-form-ihrer-vorlage.md).
- **Emittierte Spezifikations-Vorlage.** *Bestand bleibt stehen:* sie reist mit dem Pin ([ADR-0078](../../adr/0078-ziel-fassung-regiert-den-sprung-v6160.md)
  §Emittierte Ebene) und trägt am `v6.16.0` §7/§8 schon (Lage oben); hier werden nur die Kommentare
  wahr, die sie beschreiben.
- **Kein neuer Ausnahme-Gegenstand.** *Anderer Vorgang:* `exclude-sections` zieht nur den neuen Namen
  desselben Abschnitts nach — keine Senkung nach [`AGENTS.md`](../../../../AGENTS.md) §3.5.

## 2. Definition of Done

- [ ] **1 — Inventur:** je Sensor-Datei unter `harness/sensors/` und je Skriptkopf unter
      `harness/tools/` ist jede Randform-Festlegung mit Ziel (§1-Verfeinerung oder §7) gelistet; die
      Liste liegt dem Review vor.
- [ ] **2 — Spezifikation:** §7 *Festlegungen der Harness-Werkzeuge* trägt die Festlegungen mit
      Bindungs-Spalte ([`MR-075`](../../../../harness/conventions.md#mr-075)), §1 die
      Verfeinerungen (der Abschnitt entsteht nur, wenn die Inventur eine liefert — heute führt die
      Datei keinen §1); die Historie ist §8; `exclude-sections` in `.d-check.yml` nennt den neuen
      Namen; jede Quelle trägt einen Rang-Zeiger. **Rot gesehen**
      ([`AGENTS.md`](../../../../AGENTS.md) §3.6): `exclude-sections` behält einmal den alten Namen,
      und `make docs-check` meldet einen Befund aus dem Historie-Abschnitt.
- [ ] **3 — Emittierte Kommentare (vor `v0.2.9`):** die zwei Stellen in
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
| `spec/spezifikation.md` §1, §7, §8 | update | Liefer-Punkt 2 |
| `harness/sensors/*.md`, Köpfe in `harness/tools/` | update | Festlegung raus, Rang-Zeiger rein |
| `.d-check.yml` (`exclude-sections`) | update | neuer Abschnittsname |
| `internal/emit/templates/d-check.yml`, Kommentar in `internal/emit/emit_test.go` | update | Liefer-Punkt 3 |

## 4. Trigger

**Start** (`next` → `in-progress`): `slice-sprung-auf-v6160-wird-vollzogen` liegt in `done/` — die
Regel steht dann im vendored Baum (erfüllt). WIP-Limit frei.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next`: Die Inventur aus Liefer-Punkt 1 ergibt mehr Umzüge, als eine
  Review-Sitzung prüft — dann wird je Werkzeug-Gruppe geschnitten; die Inventur bleibt hier.
- `in-progress` → `open`: Eine Festlegung lässt sich weder genau einer Anforderung noch §7 zuordnen,
  ohne eine `Accepted`-ADR zu berühren — Übergabe an den Architect.

## 5. Closure-Trigger

1. `grep -n '^## ' spec/spezifikation.md | tail -1` nennt die Historie als §8, und `make docs-check`
   ist grün.
2. Die Inventur liegt vor, und keine gelistete Festlegung steht mehr allein in einer Sensor-Datei oder
   einem Skriptkopf.

**Lerneintrag** in einer der drei Formen, §7; die Closure schreibt der Planner
([`AGENTS.md`](../../../../AGENTS.md) §3.10).

## 6. Risiken und offene Punkte

- **Rang-Zeiger nennt eine Festlegung, deren Zweifelsregel anders entscheidet** — beim Umzug
  divergieren Quelle und Spezifikation; `rang-zeiger-nennt-eine-festlegung-deren-zweifelsregel-anders-entscheidet`
  steht bei 2 Belegen.
  — **Ausgang:** offen bis zur Closure.
- **Festlegung und Rumpf nennen verschiedene Reichweiten** —
  `festlegung-und-ihr-rumpf-nennen-verschiedene-reichweiten` bei
  1 Belegen. — **Ausgang:** offen bis zur
  Closure.

## 7. Closure-Notiz

- **Was hat funktioniert:** —
- **Was ging anders als geplant:** —
- **Steering-Loop-Eintrag:** —
- **Beobachtungs-Register (`../observations/`):** —
- **Folge-Slices:** —
- **Risiken aus §6:** —

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt sind `*` (Spezifikation, Sensor-Dateien,
`.d-check.yml`, `internal/emit/`) und `TOOLS` (`harness/tools/`, Skriptköpfe); `CODEX` nicht.

**Vorgelagert — offene Beobachtungen sichten:** Register am gemergten Stand gesichtet, nach
Gegenstand; Zähler `ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`: die zwei
Einträge aus §6. Für `TOOLS` kein Eintrag — alle Beobachtungen führen `*`.

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).


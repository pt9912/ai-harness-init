# Slice slice-080: Ein Verweis in die vendored Baseline überlebt den Tag-Wechsel

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-10](../welle-10-re-baseline.md).

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (der Tag ist
die Reproduzierbarkeits-Klammer), [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
(ein Tag zur Zeit, `<tag>`-gescopter Pfad), [`AGENTS.md`](../../../../AGENTS.md) §3.4 und §3.5.

**Autor:** Planner. **Datum:** 2026-08-09.

---

## 1. Ziel

Es ist entschieden und in einer ADR festgehalten, **wie ein Verweis in den `<tag>`-gescopten
vendored Baum einen Tag-Wechsel übersteht, wenn er in einem unveränderlichen Artefakt steht** —
vor dem ersten Tausch, nicht danach.

**Der Konflikt, gemessen.** [`AGENTS.md`](../../../../AGENTS.md) §3.4 stellt ein ADR ab *Accepted*
unveränderlich; das Doku-Gate verlangt auflösbare Link-Ziele. Vier Accepted-ADRs zeigen in den
vendored Baum ([`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md),
[`ADR-0012`](../../adr/0012-haupt-kontext-ohne-token-bilanz.md),
[`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md),
[`ADR-0014`](../../adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md); die fünfte,
[`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md), steht auf *Proposed* und
fällt nicht unter §3.4). Verschwindet der Pfad, kollidieren zwei Regeln an einem Artefakt, das
keine von beiden ändern darf.

**Und die Kollision ist kleiner und zugleich schlimmer als sie aussieht — beides gemessen**
(Sonde im Arbeitsbaum, `make docs-check`, zurückgenommen):

| Verweis-Form | Beispiel | Gate |
|---|---|---|
| Markdown-Link | [`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) → `grundlagen-konventionen.md#spec-straten-…` | **`target-missing`** — rot |
| Inline-Code-Pfad | [`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md), [`ADR-0014`](../../adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md) | **stumm** |
| Zeilen-Referenz `datei:26-29` | [`ADR-0012`](../../adr/0012-haupt-kontext-ohne-token-bilanz.md) | **stumm** |

Rot wird also **genau ein** Accepted-ADR. Die anderen drei tragen nach dem Tausch eine falsche
Aussage über einen Baum, den es nicht mehr gibt, **und kein Sensor sagt es** — `codepaths.roots`
führt `spec`, `docs`, `harness`, nicht `.harness`. Die stille Hälfte ist die Frage dieses Slice,
nicht die laute.

## 2. Definition of Done

- [ ] Eine ADR ist *Accepted* und entscheidet den Konflikt: was mit einem `<tag>`-gepinnten
      Verweis in einem Accepted-Artefakt beim Tag-Wechsel geschieht — und welche Regel künftige
      Verweise bindet (**Eigenschaft statt Adresse**, oder ausdrücklich das Gegenteil).
- [ ] Die ADR trägt den **Ist-Bestand mit Kommando und Zahl**, getrennt nach gate-sichtbar und
      stumm; die stille Hälfte wird nicht als bewacht ausgegeben
      ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- [ ] Ist die Entscheidung eine **Gate-Lockerung** (Ausnahme für Ziele unter `.harness/baseline/`),
      steht das als solche in der ADR — [`AGENTS.md`](../../../../AGENTS.md) §3.5 verlangt für jede
      Senkung genau dieses Gefäß, nicht einen Nebensatz.
- [ ] `make gates` grün.
- [ ] Doku-Update: ADR-Index.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `docs/plan/adr/00NN-<titel>.md` | neu (per `cp` aus dem vendored ADR-Template) | trägt die Entscheidung |
| `docs/plan/adr/README.md` | update | Index wächst mit der ADR ([`AGENTS.md`](../../../../AGENTS.md) §5) |

Kein Code, keine Gate-Config: die Umsetzung liegt bei
[slice-081](slice-081-baum-tauschen-pin-ziehen.md).

## 4. Trigger

Beginnt, sobald [welle-10](../welle-10-re-baseline.md) startet — dieser Slice ist ihr
erster; kein Vorgänger innerhalb der Welle.

Rückführungen: `in-progress` → `next`, wenn die Entscheidung mehr als eine Frage trägt (etwa
zusätzlich den Sensor für die stille Hälfte — der ist dann ein eigener Slice). `in-progress` →
`open`, wenn sie eine Baseline-Aussage braucht, die erst **nach** dem Tausch messbar ist; dann ist
die Reihenfolge dieser Welle falsch geschnitten und das gehört gemeldet, nicht umgangen.

## 5. Closure-Trigger

DoD vollständig, ADR *Accepted*, Closure-Notiz geschrieben.

## 6. Risiken und offene Punkte

- **Die bequeme Antwort ist die Ausnahme.** Ziele unter `.harness/baseline/` vom Link-Check
  auszunehmen macht die vier ADRs auf einen Schlag grün — und nimmt zugleich die 16 heute
  gate-sichtbaren Verweise aus [`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder)
  und [`harness/conventions.md`](../../../../harness/conventions.md#mr-000--baseline-aussage) mit
  aus der Prüfung. Das ist eine Senkung mit weit größerem Geltungsbereich als der Anlass.
- **Die stille Hälfte hat keinen Wächter, und der Slice darf sie nicht so behandeln, als hätte
  sie einen.** Ob `codepaths.roots` um `.harness` erweiterbar ist, ohne den Prüfbereich
  aufzublähen, ist **ungemessen**.
- **Was hier entschieden wird, gilt über den Anlass hinaus:** dieselbe Frage stellt sich bei
  jedem künftigen Bump. Eine Entscheidung, die nur `v3.5.2` → `v5.3.1` regelt, ist keine.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `docs/plan/adr/` gehört
zum Greenfield-Bestand; der Modus steht in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md).

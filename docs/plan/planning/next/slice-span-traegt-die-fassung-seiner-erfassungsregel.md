# Slice slice-span-traegt-die-fassung-seiner-erfassungsregel: Der Span trägt die Fassung seiner Erfassungsregel

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese Datei liegt; er wechselt
nur durch `git mv` (Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine).

**Welle:** ohne Welle — reaktiv, ein Eintrag des Beobachtungs-Registers über der Schwelle; keine
Closure-Bedingung jenseits der DoD.

**Bezug:** [`LH-FA-13`](../../../../spec/lastenheft.md#lh-fa-13--erfassungs-schema-der-spans),
[`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md), [`ADR-0049`](../../adr/0049-ausgang-traegt-die-benannte-luecke.md).

**Berührte Spec-Stellen:** [`spezifikation.md` §5](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder).

**Verantwortlich:** — bis zur Priorisierung.

**Autor:** Planner. **Datum:** 2026-10-08.

---

## 1. Ziel und Abgrenzung

**Ziel:** Ein Leser des Span-Bestands kann einen Regelwechsel von einer Verhaltensänderung des
Beobachteten trennen, weil jede Zeile die Fassung der Erfassungsregel nennt, unter der sie entstand.

**Ausdrücklich NICHT in diesem Slice:**

- Eine Migration des Bestands — der Bestand ist gitignored, maschinenlokal und append-only; alte
  Zeilen bleiben ohne Fassung und gelten als *nicht bekannt*.
- Neue Span-Felder jenseits der Fassungs-Angabe — anderer Vorgang.

## 2. Definition of Done

- [ ] Entschieden und in `spec/spezifikation.md` §5 begründet: ein Fassungs-Feld je Span **oder** eine
      datierte Wechsel-Zeile je Bedeutungswechsel.
- [ ] Umgesetzt, und `make span-report` trennt die Fassungen; ein Span ohne bzw. mit falscher Fassung
      ist rot gesehen (bei der Feld-Variante).
- [ ] Die bisherigen Bedeutungswechsel (`program`-Feld) sind in der gewählten Form nachgetragen.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor (`.harness/skills/reviewer.md`).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben, oder in §7 notiert, dass keine Beobachtung anfiel.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `spec/spezifikation.md` §5 | update | Fassungs-Feld oder Wechsel-Zeile ([`LH-FA-13`](../../../../spec/lastenheft.md#lh-fa-13--erfassungs-schema-der-spans)) |
| `internal/` (span-emit, span-report) | update | nur bei der Feld-Variante |
| Go-Tests / `test/*.bats` | update | Fassung geschrieben und ausgewertet |

## 4. Trigger

**Start** (`next` → `in-progress`): priorisiert, `Verantwortlich:` gesetzt.

- `in-progress` → `next`: die Feld-Variante verlangt eine Änderung an [`LH-FA-13`](../../../../spec/lastenheft.md#lh-fa-13--erfassungs-schema-der-spans) selbst (Change
  Request) — dann trennt sich der Spec-Teil ab.
- `in-progress` → `open`: der offene CR zu [`LH-FA-13`](../../../../spec/lastenheft.md#lh-fa-13--erfassungs-schema-der-spans) blockiert die Festlegung.

## 5. Closure-Trigger

DoD vollständig, `make gates` grün, Closure-Notiz mit Lerneintrag.

## 6. Risiken und offene Punkte

- Die Fassungs-Angabe wird bei einem künftigen Regelwechsel nicht hochgezählt — **Ausgang:** offen
  bis Closure.

## 7. Closure-Notiz

— bei Closure.

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** `*` (gesamtes Repo), Kürzel `ALL`.

**Vorgelagert — offene Beobachtungen sichten:** `BEO-ALL/span-feld-bedeutung-wechselt-ohne-fassungs-angabe`
über der Schwelle, Stand `geplant` auf diesen Slice.

Alle berührten Sub-Areas GF.


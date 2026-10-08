# Welle welle-emittiertes-doc-gate: Das emittierte Doc-Gate ist entschieden

**Zielmeilenstein:** kein Meilenstein-Bezug.

**Verantwortlich:** pt9912. **Datum:** 2026-10-08.

---

## 1. Welle-Ziel

Die Startkonfiguration des Doc-Gates, die das Werkzeug ins Ziel schreibt
([`LH-FA-03`](../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7)), trägt für jedes offene Modul
eine Entscheidung nach den drei Kriterien aus
[`MR-054`](../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
(`planning`, `codepaths`, `targets`, `reviews`), und jede Ausnahme darin nennt ihren ganzen
Gegenstand — gemeinsam belegt an einem frisch gebootstrappten Ziel.

## 2. Trigger (Welle startet)

- [`MR-054`](../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
  steht im Adaptions-Block (die drei Kriterien, an denen jede Modul-Entscheidung misst) —
  eingetreten.

## 3. Closure-Trigger (Welle schließt)

- Alle Slices aus §4 in `done/`.
- `make gates` **und** `make full-smoke` grün auf demselben Commit — das *Mehr*: die vier
  Entscheidungen zusammen ergeben eine Startkonfiguration, die im frischen Ziel out-of-the-box
  grün ist; das belegt keine einzelne DoD.
- Closure-Notiz in `welle-emittiertes-doc-gate-results.md`.

## 4. Slices in dieser Welle

| Slice | Titel | Bezug |
|---|---|---|
| [slice-emittierte-gate-vorlage-traegt-targets-und-reviews](done/slice-emittierte-gate-vorlage-traegt-targets-und-reviews.md) | Die emittierte Vorlage trägt `targets` und `reviews` | [`LH-FA-03`](../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7) |
| [slice-210](in-progress/slice-210-planning-modul-im-emittierten-doc-gate.md) | Das Modul `planning` im emittierten Doc-Gate wird entschieden | [`LH-FA-03`](../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7) |
| [slice-211](next/slice-211-codepaths-im-emittierten-doc-gate.md) | Das Modul `codepaths` im emittierten Doc-Gate wird entschieden | [`LH-FA-03`](../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7) |
| [slice-ausnahme-grund-nennt-seinen-ganzen-gegenstand](next/slice-ausnahme-grund-nennt-seinen-ganzen-gegenstand.md) | Die Begründung neben einer Ausnahme nennt ihren ganzen Gegenstand | [`LH-FA-03`](../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7) |

## 5. Abhängigkeiten

- Blockiert: `welle-adopter-weg-im-ziel` (deren Läufe im Ziel fahren die Startkonfiguration dieser
  Welle; Reihenfolge, keine Vertragskante).
- Wird blockiert von: keiner Welle.

## 6. Out-of-Scope für diese Welle

- Das Doc-Gate **dieses** Repos (Dogfood) — außer der Hälfte von `slice-ausnahme-grund-…`, die
  beide Ebenen nennt; Dogfood-Härtung bleibt in der Vorschau-Zeile *Doc-Gate-Härtung*.
- Ein d-check-Pin-Sprung — anderer Vorgang mit eigenem Adaptions-Eintrag.
- Neue Module über die vier genannten hinaus.

## 7. Closure-Notiz

Ergebnis: `welle-emittiertes-doc-gate-results.md` (Geschwister im Ruheort `done/`)
Zähler: Beobachtungs-Register `docs/plan/planning/observations/`

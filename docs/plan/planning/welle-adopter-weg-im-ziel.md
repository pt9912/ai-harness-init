# Welle welle-adopter-weg-im-ziel: Die Werkzeuge des Adopters halten ihre Zusage im Ziel

**Lifecycle:** Diese Datei entsteht bei der **Eröffnung** der Welle und liegt
flach unter `docs/plan/planning/`; bei Closure wandert sie per `git mv` nach
`done/` (neben ihre `welle-<Kennung>-results.md`). Der Zustand ist die
Verzeichnis-Position — kein Status-Feld. **Geplante Wellen bekommen noch keine
Datei:** Sie stehen in der Roadmap unter *Nächste Wellen* und nirgends sonst —
zwei Positionen, nicht drei.

**Zielmeilenstein:** kein Meilenstein-Bezug.

**Verantwortlich:** pt9912. **Datum:** 2026-10-08.

---

## 1. Welle-Ziel

Die Werkzeuge, die ein Adopter im gebootstrappten Ziel fährt — Aktivierung des Commit-Trägers,
Archivierung, `make slice-mv` nach `done/`, die Zeilenenden-Meldung — halten dort ihre Zusage, und
die Eigentums-Grenze der emittierten Anweisungssätze ist für die Adopter-Seite entschieden
([`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen),
[`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren),
[`LH-FA-11`](../../../spec/lastenheft.md#lh-fa-11--selbstprüfung-der-durchsetzungsschicht-emittieren)).

## 2. Trigger (Welle startet)

- `welle-emittiertes-doc-gate` liegt in `done/` (`ls docs/plan/planning/done/welle-emittiertes-doc-gate.md`)
  — die Läufe im Ziel fahren deren Startkonfiguration des Doc-Gates.

## 3. Closure-Trigger (Welle schließt)

- Alle Slices aus §4 in `done/`.
- `make gates` **und** `make full-smoke` grün auf demselben Commit — das *Mehr*: die Stufen, die
  drei der Slices im Ziel anlegen, laufen zusammen mit allen übrigen Stufen durch; keine
  Slice-DoD belegt das Zusammenspiel.
- Closure-Notiz in `welle-adopter-weg-im-ziel-results.md`.

## 4. Slices in dieser Welle

Reihenfolge = Abarbeitung; die zwei `full-smoke.sh`-Slices laufen nacheinander (dieselbe Datei).

| Slice | Titel | Bezug |
|---|---|---|
| [slice-archivierung-erkennt-benannte-slices](done/slice-archivierung-erkennt-benannte-slices.md) | Archivierung liest benannte Kennungen; Start-Bedingung des Altbestand-Laufs | [`MR-059`](../../../harness/conventions.md#mr-059), [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |
| [slice-zeilenenden-meldungstest-bindet-das-verzeichnis](done/slice-zeilenenden-meldungstest-bindet-das-verzeichnis.md) | Meldungstest hält das genannte Verzeichnis | [`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) |
| [slice-aktivierung-reist-nicht-mit-dem-klon](done/slice-aktivierung-reist-nicht-mit-dem-klon.md) | Klon-Weg des Commit-Trägers gefahren | [`LH-FA-11`](../../../spec/lastenheft.md#lh-fa-11--selbstprüfung-der-durchsetzungsschicht-emittieren) |
| [slice-mv-kanten-nach-done-sind-bewacht](next/slice-mv-kanten-nach-done-sind-bewacht.md) | `open\|next → done` im Ziel gefahren | [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |
| [slice-adopter-seite-der-anweisungssatz-grenze](next/slice-adopter-seite-der-anweisungssatz-grenze.md) | Eigentums-Aussage für die Adopter-Seite (Architect) | [`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) |

## 5. Abhängigkeiten

- Blockiert: `welle-handbuch-zeigt-den-bestand` (das Handbuch nennt, was der Adopter-Weg im Ziel hält).
- Wird blockiert von: keiner Welle.

## 6. Out-of-Scope für diese Welle

- Der Altbestand-Lauf `archive-welle altbestand` selbst — eigener Vorgang (Auftraggeber-Entscheidung
  vom 2026-10-08); diese Welle liefert nur seine Start-Bedingung.
- Die emittierte Erfassungsschicht — `welle-erfassungsschicht-im-ziel`.
- Gleichlauf lokaler und emittierter Anweisungssätze — `welle-anweisungssatz-und-emittierter-satz`.
- Ein d-check- oder Baseline-Pin-Sprung — anderer Vorgang mit eigenem Adaptions-Eintrag.

## 7. Closure-Notiz

Erst nach Welle-Abschluss: Ergebnis `welle-adopter-weg-im-ziel-results.md` (Geschwister im Ruheort
`done/`), Zähler das Beobachtungs-Register eine Ebene über dem Ruheort.

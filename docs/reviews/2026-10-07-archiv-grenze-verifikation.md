# Verifikation: slice-archiv-grenze-aus-der-commit-abstammung

**Rolle:** Verifier (Modul 11) · **Datum:** 2026-10-07 · **an:** Planner
**Gegenstand:** Implementer-Commits `087f990d`, `3f068403`, `cb6dee52` gegen DoD und Plan des Slice,
[ADR-0081](../plan/adr/0081-altbestand-grenze-aus-der-commit-abstammung.md) §Fitness Function;
Review `2026-10-07-archiv-grenze-review.md` (0 HIGH/MEDIUM).

**Summary:** Liefer-Punkte 1 und 2 bestätigt, 3 bedingt; die zwei Rot-Belege von DoD 2 nachgetragen
(beide rot aus der behaupteten Ursache). Kein blockierender Befund.

## Verdikte je Liefer-Punkt

- **DoD 1 — Operation und Aufrufer: bestätigt.**
  - `internal/archive/grenze.go`: `gehoert` trägt Altbestand (S ≤ irgendein G) und Welle (früheste
    Closure, parallele G schließen einander nicht aus); `grenzeAnwenden` ändert ohne Ergebnisnotiz
    nichts; `grenzSperren` nur bei `GrenzeAktiv` mit `[flacher-klon]` und `[add-commit]`;
    `Schreibe` gibt *„bleibt liegen (nach der Grenze)"* aus.
  - `grep -rn 'exec\.\|"os/exec"' internal/archive/*.go | grep -v _test` → leer; git allein in
    `cmd/ai-harness-init/archive_welle.go` (`gitAbstammung`).
  - Rot-Beleg Mutation 542 (Vergleich umgekehrt) gebunden: im Review-Lauf gefahren
    (`make mutate MUTATE_CASES=…542…` → `3 ok, 0 Befund(e)`), hier nicht wiederholt.
- **DoD 2 — E2E im Ziel: bestätigt.** `make full-smoke` → EXIT 0, 172 s. Stufe
  `archivierung_im_ziel` (e), gelesen:
  - (e1) `flacher Klon (golang): make archive-welle WELLE=altbestand sperrt mit [flacher-klon], HEAD und done/ unveraendert.`
  - altbestand: `wellenlos … 1`, `bleibt liegen (nach der Grenze): 1`, `fremd … 1`,
    `archive-welle ok: altbestand` — nur slice-997 im Sammel-Archiv, slice-996 flach.
  - welle-1: `Mitglieder … 1`, `wellenlos … 0`, `bleibt liegen … 1`, `archive-welle ok: welle-1`
    — slice-995 archiviert, slice-996 bleibt flach.
  - **Rot-Belege nachgetragen** (fehlten im Implementer-Beleg; Baum danach per `git checkout` zurück):
    - Vergleich in `internal/archive` übersprungen (`case true || gehoert(…)`) → `make full-smoke`
      EXIT 2: `FEHLER — golang: der Altbestand-Lauf nimmt nicht genau den fruehen Slice …`, Ausgabe
      `wellenlos (seit der letzten Closure): 2`, `bleibt liegen …: 0` — der späte Slice wandert.
    - Shallow-Prüfung entfernt (`a.Flach = false && …`) → EXIT 2: `FEHLER — golang: im flachen Klon
      (git clone --depth 1) sperrt make archive-welle WELLE=altbestand nicht mit [flacher-klon] …`,
      Ausgabe `wellenlos … 2`, `archive-welle ok: altbestand` — stiller Lauf über beide Slices.
  - Stufen-Deklaration nennt die Teilmessung (lineare Historie, Arbeitsbaum-Träger, QA-02-Grenze).
- **DoD 3 — Texte: bedingt.** `close-welle.md` (Mutationen 543/544 gebunden, Review-Lauf) und
  Benutzerhandbuch nennen Grenze, *„bleibt liegen"* und Shallow-Sperre samt Bedingung. In
  `archivierung.mk` steht der Text im **Kopfkommentar** (Zeilen 18–23); die `##`-Hilfezeile von
  `archive-welle` (Zeile 37), die `make help` ausgibt, ist unverändert und nennt nichts davon.
  Ob „Hilfetext" den Kopfkommentar meint, entscheidet der Planner.

## Frage aus dem Auftrag: deckt der cmd-Echt-Test S < G?

- Nein, und keine DoD sagt es zu. `TestArchiveWelleEchtGrenzeLaesstDenSpaetenSliceLiegen` misst S = G
  und einen Slice ohne Abstammung zu G. DoD 1 beruft sich auf den Go-Test über eingespeiste Werte,
  DoD 2 auf `full-smoke`; ADR-0081 Fitness Zeile 3 legt die git-Quelle ausdrücklich auf die zwei
  `full-smoke`-Zeilen. S < G mit echtem git trägt `full-smoke` (e) — oben grün und rot gesehen.

## Plan vs. Code

- Plan §1 nennt `git merge-base --is-ancestor`, der Code liest `git rev-list G` als Vorfahren-Menge.
  Bei voller Historie gleichbedeutend; im flachen Klon sperrt der Lauf vorher. Abweichung im Mittel,
  nicht im Verhalten.
- Gebautes ohne Plan-Zeile: Usage-Text in `archive_welle.go`, Fehlerzweig-Einordnung in
  `full-smoke` (`3f068403`, `test/full-smoke-ausgang.bats`) — beide im Gegenstand des Plans.

## Offene Punkte für den Planner (Closure)

- Risiko §6 *CI-Klon flach*: `full-smoke` fährt über einem per `git init` angelegten tmp-Ziel mit
  voller Historie; die cmd-Echt-Tests bauen eigene Repos. Kein Lauf über dem Arbeits-Repo gefunden.
- Risiko §6 *Add-Commit eines Merge*: nicht gemessen — die Stufe deklariert „lineare Historie ohne
  Merge", kein Go-Test baut einen Merge.
- `make gates`: einmal am Ende über dem Baum mit diesem Bericht; Ergebnis in der Commit-Message.

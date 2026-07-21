# Slice slice-025: Bootstrap-Kette absichern (Pre-Flight statt Teil-Emit)

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-02-fetch-und-readme](../welle-02-fetch-und-readme.md).

**Bezug:** [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen), [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten), [`ADR-0005`](../../../../docs/plan/adr/0005-ziel-repo-distribution.md).

**Autor:** Claude (Pair-Session). **Datum:** 2026-07-20.

---

## 1. Ziel

> **Herkunft: ein Befund bei seiner vierten Wiederholung.** Der Bootstrap führt
> mehrere **schreibende** Schritte ohne gemeinsame Absicherung aus; scheitert
> Schritt *n*, bleiben die Ergebnisse von 1…*n-1* im Zielrepo liegen. Die Klasse
> wurde protokolliert in **slice-002** (I1), **slice-003** (I1), **slice-004a**
> (L3) und **slice-022a** (I1). slice-004a hielt als Steering-Loop-Eintrag fest,
> ein *gemeinsamer Pre-Flight über alle Bootstrap-Schritte* sei „die eigentliche
> Lösung", und wies ihn slice-004b/005 zu — **er ist nicht gelandet**, und
> slice-022a hat zwei weitere Schritte in dieselbe ungeschützte Kette gehängt.
> Dieser Slice existiert, weil die Zuweisung an einen ohnehin großen Folge-Slice
> dreimal nicht getragen hat. Ein viertes Weiterreichen wäre kein Plan, sondern
> ein Muster.

Die Bootstrap-Kette wird **als Ganzes** absichernd: entweder scheitert sie, bevor
sie etwas schreibt, oder sie hinterlässt ein vollständiges Ergebnis — kein
Zwischenzustand, den der Adopter von Hand aufräumen muss
([`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)). Nebenbei fallen zwei Robustheits-Befunde aus demselben
Codepfad mit (slice-022a L3/L4).

## 2. Definition of Done

- [ ] **Entwurfs-Entscheidung getroffen und begründet** (siehe §6): Pre-Flight-Check *oder* Staging→Commit. Der Unterschied ist nicht kosmetisch — Ersteres prüft Vorbedingungen, Letzteres macht die Kette atomar. Fällt die Wahl auf ein Modell mit Architektur-Wirkung, entsteht **vor dem Code** eine ADR (Modul 4).
- [ ] [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen): ein Bootstrap, der an **irgendeinem** Schritt scheitert, hinterlässt das Zielrepo in dem Zustand, in dem er es vorfand — belegt je Schritt der Kette, nicht nur für einen.
- [ ] Der Test, der das belegt, ist **rot gesehen** worden: ohne die Absicherung muss er fallen (die Klasse ist viermal durch Tests gerutscht, weil niemand den Kettenzustand *geprüft* hat — slice-022a M2 fing genau das).
- [ ] **slice-022a L3** aufgelöst: kein `.baseline-*`-Temp-Rest bei Abbruch zwischen `MkdirTemp` und Rename; das Stat→Rename-Fenster ist entweder geschlossen oder als bewusst akzeptiert begründet (Race, ggf. nicht verifizierbar — dann ehrlich benennen statt stillschweigend lassen).
- [ ] **slice-022a L4** aufgelöst: der Asset-Body wird nicht mehr unbegrenzt gepuffert, bevor der sha256-Pin greift (Größen-Schranke), [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten).
- [ ] [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6): `make gates` bleibt offline-grün; kein neues Gate behauptet.
- [ ] `make gates` grün.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag — hier zwingend zur **Klasse**: warum drei Zuweisungen nicht trugen und was den vierten Anlauf anders macht.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `docs/plan/adr/` | ggf. neu | nur falls die Entwurfs-Entscheidung Architektur-Wirkung hat (§6) — Doc führt, Code folgt |
| `cmd/ai-harness-init` | refactor | die Kette bekommt ihre Absicherung; die einzelnen Schritte bleiben, was sie sind |
| `internal/fetch` | update | L3 (Temp-Rest) + L4 (Größen-Schranke vor dem Pin) |
| `cmd`-Tests | neu | Abbruch je Schritt → Zielrepo unverändert; zuerst rot gesehen |

## 4. Trigger

slice-022b in `done/`. Damit steht die Kette **vor** slice-023 und slice-004b —
und das ist der Kern der Platzierung: jeder weitere Slice hängt sonst einen
weiteren ungeschützten Schritt an, und der Rückbau wächst mit. Genau so ist der
Befund viermal entstanden. Wer die Absicherung nach hinten schiebt, wiederholt
das Muster ein fünftes Mal.

Rückführungen: `in-progress → next`, wenn Entwurfs-Entscheidung und Umsetzung
nicht in eine Sitzung passen (dann die ADR als eigenen Schritt). `in-progress →
open`, wenn die Entscheidung eine ADR verlangt, die noch nicht geschrieben ist
(Doc führt, Code folgt — Modul 4).

## 5. Closure-Trigger

DoD vollständig + Review konform + Closure-Notiz → nach `done/`. Entsperrt
slice-023 mit einer abgesicherten Kette.

## 6. Risiken und offene Punkte

- **Die Entwurfs-Entscheidung ist der eigentliche Inhalt**, nicht das Refactoring.
  Zwei Modelle stehen zur Wahl, und sie sind nicht gleichwertig:
  **(a) Pre-Flight** — alle Vorbedingungen (Kollisionen ohne `--force`,
  Schreibrechte) prüfen, bevor der erste Schritt schreibt. Billig, deckt den
  häufigsten Fall, aber **nicht** den Abbruch *während* eines Netz-Fetchs.
  **(b) Staging→Commit** — alle Schritte schreiben in ein Staging-Verzeichnis,
  ein finaler Move macht es sichtbar. Vollständig, aber teurer und mit der Frage,
  wie sich das zu `--force` und zu bereits bestehenden Zieldateien verhält.
  slice-004a nannte beide; entschieden wurde nie. **Diese Slice-Fassung entscheidet
  bewusst nicht vor** — das gehört in den ersten Lauf, mit Begründung.
- **Die Kette ist ein bewegliches Ziel:** slice-023 entfernt den Skelett-Fetch,
  slice-004b fügt Gerüst und Verdrahtung hinzu. Die Absicherung muss die Kette
  als *Liste von Schritten* behandeln, nicht fünf Schritte hart verdrahten —
  sonst bricht sie beim nächsten Slice und der Befund kehrt zum fünften Mal wieder.
- **Teil-Erfolg ist nicht immer falsch:** ein gestagtes Skelett nach einem
  fehlgeschlagenen Doc-Gate ist Müll, ein bereits vendored Regelwerk vielleicht
  nicht. Das Modell muss sagen, was es zurückrollt und was nicht — pauschal
  „alles oder nichts" kann teuer sein (erneuter Netz-Fetch beim Retry).
- Abhängig von slice-022b; vorher konkurriert der Umbau mit der Embed-Entfernung
  im selben `emit`-Pfad.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example).

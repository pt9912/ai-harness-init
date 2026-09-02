# Slice slice-085: Die emittierte Ebene zieht nach

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-10](../welle-10-re-baseline.md).

**Bezug:** [`LH-FA-09`](../../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren),
[`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen),
[`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren),
[`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed).

**Autor:** Planner. **Datum:** 2026-08-09.

---

## 1. Ziel

Was ein **frisch gebootstrapptes Zielrepo** bekommt, steht auf `v5.12.0` — und die emittierten
Artefakte, die die Struktur des Regelwerks benennen, nennen keine Datei, die es dort nicht gibt.

**Die Ebene ist die Pointe.** Der Tag ist der Emissions-Kanal: `internal/fetch/baseline.go`
`DefaultTag` entscheidet, welchen Baum ein Zielrepo zieht. Der Dogfood-Tausch aus
[slice-081](../done/slice-081-baum-tauschen-pin-ziehen.md) verschiebt ihn mit — **was für dieses Repo gilt,
ist damit noch keine Aussage über das emittierte.** Emittiert werden unter anderem drei
Workflow-Commands (`plan-welle`, `close-welle`, `implement-slice`), die ihrerseits Module und
Ziel-Formen des Regelwerks benennen; `implement-slice` allein trägt 28 solcher Nennungen.

## 2. Definition of Done

- [ ] `make smoke` **und** `make full-smoke` sind mit dem neuen `DefaultTag` grün — ein frisch
      gebootstrapptes Zielrepo fährt mit `v5.12.0` out-of-the-box grün
      ([`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)).
- [ ] Die emittierten Artefakte nennen keine Regelwerks-Datei, die es in `v5.12.0` nicht gibt —
      geprüft als **Inventar gegen Abdeckung** (Nennungen gegen den Dateibestand des neuen Baums),
      nicht als Trefferliste.
- [ ] Wo ein emittierter Text eine Prozedur beschreibt, die die neue Fassung geändert hat
      (Freshness-Audit, Results-Template), ist entschieden: **nachziehen** oder als bewusste
      Abweichung **deklarieren** — nichts dazwischen.
- [ ] `make gates` grün.
- [ ] Doku-Update: `docs/user/benutzerhandbuch.md`, soweit es den emittierten Stand beschreibt.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/emit/templates/commands/` | update | drei Commands benennen Module und Ziel-Formen |
| `internal/emit/templates/` (übrige) | prüfen, ggf. update | `d-check.yml`, `baseline-verify.sh`, `enforce/` |
| `.harness/baseline/<tag>/templates/.harness/skills/*.template.md` als **Emissions-Quelle** | prüfen | was ein Zielrepo an Skills bekommt, entscheidet dieser Slice. **Die gefüllte Fassung dieses Repos** (`.harness/skills/reviewer.md`) gehört **nicht** hierher: sie ist ein ausgefülltes Artefakt der Dogfood-Ebene und liegt seit dem 2026-08-28 bei [slice-083](../done/slice-083-form-vergleich-pflichtfelder.md) §2 (1) — zwei Ebenen, zwei Verträge, dieselbe Trennung wie bei den Commands eine Zeile weiter |

## 4. Trigger

[slice-083](../done/slice-083-form-vergleich-pflichtfelder.md) liegt in `done/` — die Form-Entscheidungen
der Dogfood-Ebene stehen, bevor die emittierte Ebene sie spiegelt oder bewusst nicht spiegelt.

Rückführungen: `in-progress` → `next`, wenn die Command-Texte und der Skill zusammen eine Sitzung
sprengen. `in-progress` → `open`, wenn `make full-smoke` einen Fehler im Bootstrap-Pfad selbst
zeigt — der ist dann ein eigener Slice, nicht Fracht dieses.

## 5. Closure-Trigger

DoD vollständig, `make gates` grün, `make smoke` und `make full-smoke` grün, Closure-Notiz
geschrieben.

## 6. Risiken und offene Punkte

- **Zwei Ebenen, zwei Verträge.** Was in diesem Repo gilt, ist keine Aussage über das emittierte —
  und umgekehrt. Dieser Slice entscheidet die Ziel-Ebene und schreibt sie nicht aus dem Dogfood
  fort.
- **Der Lauf ist nicht offline.** `make smoke` und `make full-smoke` ziehen das Asset aus dem Netz;
  sie gehören darum nicht in `make gates`, sondern an DoD-Verify und Closure.
- **Die emittierte Starter-Config bleibt bewusst schmaler als der Dogfood.** Ihre Modul-Liste
  nachzuziehen ist eine eigene Frage und liegt bereits als
  [slice-073](../open/slice-073-emittierte-doc-gate-module.md) in `open/`; wer sie hier mitnimmt, vermischt
  Re-Baseline und Gate-Anhebung.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `internal/emit/` und
`.harness/skills/` gehören zum Greenfield-Bestand; der Modus steht in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md).

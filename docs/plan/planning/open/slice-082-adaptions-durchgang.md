# Slice slice-082: Adaptions-Durchgang — jeder Eintrag bekommt seinen Ausgang

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-10](../welle-10-re-baseline-v5-3-0.md).

**Bezug:** [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) (die Aussage,
die der Durchgang prüft), [`MR-020`](../../../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf),
[`MR-022`](../../../../harness/conventions.md#mr-022--kommentar-regel-als-vorgriff-auf-eine-neuere-baseline),
[`MR-023`](../../../../harness/conventions.md#mr-023--die-platzierung-der-kommentar-regel-ist-keine-abweichung),
[`ADR-0014`](../../adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md).

**Autor:** Planner. **Datum:** 2026-08-09.

---

## 1. Ziel

Jeder der **24** Einträge des Adaptions-Blocks trägt genau einen der **fünf Ausgänge** der
Ziel-Prozedur, mit Beleg. Die Frage je Eintrag stellt die Prozedur selbst: *Regelt die neue
Fassung das, wofür diese Adaption angelegt wurde?* — und sie ist ausdrücklich eine Frage an das
**Delta der neuen Fassung**, nicht an den Zustand der Baseline.

Die fünf Ausgänge, wie Modul 2 der Ziel-Fassung sie benennt (§*Freshness-Audit der vendored
Baseline*, vierte Eigenschaft): **gegenstandslos** → Rückbau · **bleibt gültig** → stehen lassen
(Normalfall) · **teilweise überholt** → durch eine engere Nachfolgerin ablösen · **Bezug
entfallen** (die Baseline regelt das Thema gar nicht mehr) · **widerspricht** der neuen Fassung —
dann gilt die Adaption weiter, aber der Widerspruch gehört benannt.

**Der Satz, der den Slice trägt:** *„Der Review geht durch die Adaptions-Liste, nicht nur durch den
Diff."* Ein Diff zeigt, was sich geändert hat; er zeigt nicht, welche unserer Setzungen dadurch
ihren Gegenstand verliert.

## 2. Definition of Done

- [ ] **Alle 24** Einträge tragen genau einen Ausgang mit Beleg — Vollständigkeit als **Inventar
      gegen Abdeckung** (`grep -c '^### MR-' harness/conventions.md` ist der Nenner), nicht als
      Trefferliste. `permanent`-Einträge sind mitgeprüft: *permanent* heißt „kein automatischer
      Auflösungs-Trigger", nicht „unauflösbar".
- [ ] **Jeder Rückbau ist ein neuer Eintrag, kein Edit**, und nennt den Baseline-Stand, der den
      Trigger gefeuert hat. Eingeschlossen:
      [`MR-022`](../../../../harness/conventions.md#mr-022--kommentar-regel-als-vorgriff-auf-eine-neuere-baseline)
      fällt vollständig und behält nach
      [`MR-020`](../../../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf)
      Kopf und Zeiger, [`AGENTS.md`](../../../../AGENTS.md) §3.7 ist auf den Baseline-Abschnitt
      zurückgeführt, und die von
      [`MR-023`](../../../../harness/conventions.md#mr-023--die-platzierung-der-kommentar-regel-ist-keine-abweichung)
      ausdrücklich offen gelassene **Textprüfung** ist entschieden: trägt der hiesige Wortlaut die
      Upstream-Semantik?
- [ ] [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) trägt den neuen Stand
      (Tag, Datum der Adoption, Umfang) und das, was der Durchgang an ihrer Aussage geändert hat.
- [ ] `make gates` grün.
- [ ] Doku-Update: `AGENTS.md` und `harness/README.md`, soweit ein Ausgang sie berührt.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`harness/conventions.md`](../../../../harness/conventions.md) | update (nur **neue** Einträge, Rümpfe unangetastet) | die Ausgänge; Append-only-Disziplin wie bei ADRs |
| [`AGENTS.md`](../../../../AGENTS.md) | update | §3.7 zurückführen, sobald der Vorgriff fällt |
| `docs/plan/planning/open/` | neu | ein Delta, das eigene Arbeit verlangt, wird Slice — nicht Fracht dieses Slice |

## 4. Trigger

[slice-081](slice-081-baum-tauschen-pin-ziehen.md) liegt in `done/` — der neue Baum ist im Repo,
sonst misst der Durchgang gegen eine Fassung, die hier nicht liegt.

Rückführungen: `in-progress` → `next`, wenn mehr als zwei Einträge eigene Umsetzung verlangen
(dann ist der Durchgang eine Welle für sich). `in-progress` → `open`, wenn ein Ausgang eine
Architektur-Entscheidung braucht, die noch nicht getroffen ist.

## 5. Closure-Trigger

DoD vollständig, Closure-Notiz geschrieben.

## 6. Risiken und offene Punkte

- **Der Durchgang entscheidet, er setzt nicht um.** Wo eine echte Umsetzung nötig wird, entsteht
  ein Slice in `open/`. Wer beides hineinzieht, hat eine Welle im Slice — und verliert das
  Closure-Kriterium der Welle mit.
- **Drei Einträge sind schon sichtbar, ihr Ausgang aber nicht entschieden** — hier steht, was zu
  messen ist, nicht, wie es ausgeht:
  [`MR-019`](../../../../harness/conventions.md#mr-019--technik-stratum-als-rang-2-der-source-precedence)
  (die Ziel-Fassung führt ein eigenes Spec-Modul und einen eigenen Grundlagen-Abschnitt zur Source
  Precedence — ob die Adaption damit **gegenstandslos** wird oder **bleibt gültig**, entscheidet
  der Text, nicht die Vermutung);
  [`MR-022`](../../../../harness/conventions.md#mr-022--kommentar-regel-als-vorgriff-auf-eine-neuere-baseline)
  (vorab gemessen, nur zu vollziehen); und
  [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage), deren
  **2-Strata**-Aussage sich mit dem Technik-Stratum aus
  [`AGENTS.md`](../../../../AGENTS.md) §2 reibt — der Durchgang ist der Ort, an dem das auffällt.
- **24 Einträge sind die Obergrenze einer Review-Sitzung.** Wird sie gerissen, ist der Schnitt
  falsch; dann wird geteilt, nicht die Sitzung gedehnt.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `harness/` und die
Briefing-Dateien im Wurzelverzeichnis gehören zum Greenfield-Bestand; der Modus steht in der
Modus-Deklaration von [`harness/conventions.md`](../../../../harness/conventions.md).

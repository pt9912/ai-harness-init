# Slice slice-083: Form-Vergleich — Pflichtfelder und umbenannte Sektionen

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-10](../welle-10-re-baseline-v5-3-0.md).

**Bezug:** [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage),
[`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert)
(die Templates werden referenziert, nicht kopiert — der Vergleich läuft gegen den vendored Baum).

**Autor:** Planner. **Datum:** 2026-08-09.

---

## 1. Ziel

Die Referenz-Form der Ziel-Fassung ist gegen die alte gehalten, und **was sie an Pflicht ändert,
steht in den ausgefüllten Artefakten**. Die fünfte Eigenschaft der Ziel-Prozedur begründet den
eigenen Durchgang: *„Der Review vergleicht auch die Form, nicht nur die Regeln"* — ein neuer Stand
kann die **Struktur** der Artefakte ändern, und dafür gibt es kein Trigger-Feld, das sich melden
könnte.

Der Umfang ist gemessen: die Templates wachsen **21 → 25** (neu: `observations`,
`reconciliation`, `welle-results`, ein Eintrags-Template für den Adaptions-Block), und die
Vorlagen der Singletons ändern sich substanziell — `conventions.template.md` um 122,
`AGENTS.template.md` um 95, die Spec-Vorlagen um 43 bis 76 Zeilen
(`git diff --stat v3.5.2 v5.3.0 -- lab/templates/` gegen einen lokalen Kurs-Klon).

**Der schwerste Einzelpunkt ist ein neues Pflichtfeld:** die Pflichtgliederung des
Adaptions-Blocks verlangt je Eintrag `Ersetzt-Baseline-Regel` — **genau eine** Regel der Baseline,
als Link mit Abschnitts-Anker; ein Datei-Link benennt keine Regel. Ein Eintrag, der keine benannte
Regel ersetzt, ist nach dieser Fassung ein **Fork**, keine Adaption. Das trifft jeden
überlebenden Eintrag dieses Repos.

## 2. Definition of Done

- [ ] Der Form-Diff ist gefahren und je **Singleton** ([`AGENTS.md`](../../../../AGENTS.md),
      [`harness/conventions.md`](../../../../harness/conventions.md),
      [`harness/README.md`](../../../../harness/README.md), die drei `spec/`-Dateien) mit Ausgang
      protokolliert: **neues Pflichtfeld · umbenannte Sektion · optional** (keine Nacharbeit). Ob
      ein Feld Pflicht ist, entscheidet die **Pflichtgliederung im Regelwerk**, nicht die Feldzahl
      im Template.
- [ ] `Ersetzt-Baseline-Regel` steht in jedem **überlebenden** Adaptions-Eintrag und nennt genau
      eine Baseline-Regel als Anker-Link; wo keine benannt werden kann, ist der Eintrag als
      **Fork** entschieden — nicht stillschweigend belassen.
- [ ] Die **wiederkehrenden** Templates sind append-only behandelt: neue Instanzen folgen der neuen
      Form, bestehende werden nicht rückwirkend umgeschrieben. Eingeschlossen:
      [`/close-welle`](../../../../.claude/commands/close-welle.md) zieht die Results-Notiz künftig
      per `cp` aus dem nun vorhandenen `welle-results`-Template — die Bedingung, die dort seit
      jeher steht („Existiert je ein `welle-results`-Template, dann per `cp` daraus"), ist
      eingetreten.
- [ ] `make gates` grün.
- [ ] Doku-Update: die Singleton-Artefakte, deren Form sich als Pflicht geändert hat.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`harness/conventions.md`](../../../../harness/conventions.md) | update | das neue Pflichtfeld je überlebendem Eintrag |
| [`AGENTS.md`](../../../../AGENTS.md), [`harness/README.md`](../../../../harness/README.md), `spec/` | update | Singleton-Nacharbeit, soweit Pflicht |
| [`.claude/commands/close-welle.md`](../../../../.claude/commands/close-welle.md) | update | die `cp`-Quelle der Results-Notiz existiert jetzt |

Die **emittierte** Fassung derselben Commands gehört zu
[slice-085](slice-085-emittierte-ebene-zieht-nach.md) — zwei Ebenen, zwei Verträge.

## 4. Trigger

[slice-082](slice-082-adaptions-durchgang.md) liegt in `done/` — ein Eintrag, der gegenstandslos
geworden ist, bekommt kein neues Pflichtfeld mehr.

Rückführungen: `in-progress` → `next`, wenn die Singleton-Nacharbeit und das Pflichtfeld zusammen
eine Sitzung sprengen (dann trennt der Schnitt beide). `in-progress` → `open`, wenn ein Pflichtfeld
eine Aussage verlangt, die erst der Bestands-Durchgang aus
[slice-084](slice-084-stichprobe-gegen-bestand.md) liefert.

## 5. Closure-Trigger

DoD vollständig, `make gates` grün, Closure-Notiz geschrieben.

## 6. Risiken und offene Punkte

- **Der Vergleich braucht beide Bäume, das Repo lässt nur einen zu.** Die Ziel-Prozedur rechnet mit
  `diff -r` über zwei `<tag>`-Verzeichnisse; `harness/tools/baseline-verify.sh` bricht bei mehr als
  einem ab ([`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)).
  Der Diff läuft darum **außerhalb des Arbeitsbaums**. Das ist eine Abweichung von der Prozedur in
  der Ausführung, nicht in der Sache — sie gehört in die Closure-Notiz.
- **`Ersetzt-Baseline-Regel` über rund zwanzig Einträge ist die größte Einzelposition der Welle.**
  Reißt sie die Sitzung, wird geteilt, nicht gedehnt.
- **Die Verzeichnis-Form des Adaptions-Blocks bleibt außen vor** (Welle §6). Wer sie hier
  mitnimmt, zieht jede `MR`-Kennung des Repos auf einen neuen Pfad — und die sind linkpflichtig.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `harness/`, `spec/`,
`.claude/commands/` und die Briefing-Dateien im Wurzelverzeichnis gehören zum
Greenfield-Bestand; der Modus steht in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md).

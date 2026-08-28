# Slice slice-083: Form-Vergleich — Pflichtfelder und umbenannte Sektionen

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-10](../welle-10-re-baseline.md).

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
`reconciliation`, `welle-results`, `MR-NNN-titel` als Eintrags-Template für den Adaptions-Block),
und die Vorlagen der Singletons ändern sich substanziell — `conventions.template.md` um 136,
`AGENTS.template.md` um 103, die Spec-Vorlagen um 64 bis 80 Zeilen; über alle Vorlagen **24
Dateien, +1073/−359**
(`git diff --stat v3.5.2 v5.12.0 -- lab/templates/` gegen einen lokalen Kurs-Klon).

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

- **Der Vergleich braucht Zugriff auf beide Formen, nicht zwei Verzeichnisse.** Die Ziel-Prozedur
  zeigt `diff -r` über zwei `<tag>`-Verzeichnisse — das ist ihr Mittel. Verlangt ist, dass die Form
  verglichen wird und die alte erreichbar bleibt, bis der Review durch ist. Genau diesen Zugriff
  sichert [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
  zu: *„ein Tag zur Zeit (Ersetzen), Historie liegt in git"*. Der Diff läuft deshalb über
  Tree-Operanden statt über zwei Verzeichnisse, ohne Entpacken — `git diff
  <Tausch-Commit>^:.harness/baseline/v3.5.2/templates <Tausch-Commit>:.harness/baseline/v5.12.0/templates`.
  **`v3.5.2` steht hier als Tree-Operand der Vor-Tausch-Seite, nicht als Zeiger auf einen Baum,
  der stehen bleiben müsste** — er wandert mit dem Zielstand nicht mit.
  Am letzten Re-Vendor dieses Repos vorgeführt (`ce4b611`, `v3.5.1` → `v3.5.2`): 15 Dateien,
  +47/−41, und weder vor noch nach dem Commit lag ein zweites `<tag>`-Verzeichnis im Baum.
  `harness/tools/baseline-verify.sh` ist damit kein Hindernis, sondern schützt die Eindeutigkeit,
  auf der dieser Zugriff beruht.
- **Handgriff: der Tausch-Commit muss benannt sein.** Ohne ihn hat der Vergleich keine alte Seite.
  Er entsteht in [slice-081](slice-081-baum-tauschen-pin-ziehen.md) und steht zum
  Ausführungszeitpunkt als jüngster Eintrag in `git log --oneline -- .harness/baseline/`.
- **`Ersetzt-Baseline-Regel` über rund zwanzig Einträge ist die größte Einzelposition der Welle.**
  Reißt sie die Sitzung, wird geteilt, nicht gedehnt.
- **Die Verzeichnis-Form des Adaptions-Blocks bleibt außen vor** (Welle §6). Wer sie hier
  mitnimmt, zieht jede `MR`-Kennung des Repos auf einen neuen Pfad — und die sind linkpflichtig.
- **Eine der vier neuen Vorlagen ist keine Form, sondern ein Ort mit zwei Lese-Schritten, und die
  drei DoD-Punkte oben fangen sie nicht.** `observations` ist das **Beobachtungs-Register**: die
  Ziel-Fassung führt es in `v5.12.0`, `modul-05-planning-harness.md`, §Lifecycle als State
  Machine — *„`done` ist kein Endzustand der Information: Die Beobachtungen aus §7 sind bei der
  Slice-Closure ins Beobachtungs-Register eingetragen und werden von dort weitergelesen"* — und
  hängt es in `v5.12.0`, `templates/docs/plan/planning/slice.template.md` an einen **DoD-Punkt je
  Slice**: *„Beobachtungs-Register (`../observations.md`) fortgeschrieben — neue `BEO-<NNN>` oder <!-- d-check:ignore (Pfad im Zitat der Ziel-Vorlage, existiert in diesem Repo nicht) -->
  Zähler +1 mit Beleg; keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7
  notiert."* Die gepinnte Fassung kennt den Begriff nicht
  (`git grep -l 'Beobachtungs-Register' v3.5.2 -- lab/regelwerk lab/templates | wc -l` → **0**,
  Exit 1; dasselbe für `v5.12.0` → **18** Dateien, lokaler Kurs-Klon; beide Beträge wandern mit
  dem Kurs-Stand, [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2). **Die drei DoD-Punkte oben decken Singleton-Form, das Pflichtfeld und die
  Append-only-Behandlung wiederkehrender Vorlagen — eine neue Artefakt-Klasse mit eigener
  Lese-Pflicht fällt zwischen sie.** Dieser Durchgang **entscheidet** darum nur, ob das Register
  adoptiert wird; verlangt es eigene Arbeit, wird es nach [welle-10](../welle-10-re-baseline.md)
  §6 ein Slice in `open/`, keine Fracht dieses Slice. **Der Anlass ist gemessen und liegt in
  diesem Repo:** [slice-080](../in-progress/slice-080-verweis-ueberlebt-tagwechsel.md) §7 hält zwei
  Fälle fest, in denen eine Beobachtung über ein **lebendes** Artefakt nur in einer
  Commit-Message stand und neunzehn Tage später neu gemacht werden musste.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `harness/`, `spec/`,
`.claude/commands/` und die Briefing-Dateien im Wurzelverzeichnis gehören zum
Greenfield-Bestand; der Modus steht in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md).

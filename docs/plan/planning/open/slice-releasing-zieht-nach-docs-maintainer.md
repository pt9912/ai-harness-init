# Slice slice-releasing-zieht-nach-docs-maintainer: Die Release-Prozedur liegt unter docs/maintainer/

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — die Closure-Bedingung ist die DoD dieses Slice.

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) ·
[ADR-0027](../../adr/0027-tote-adresse-in-eingefrorener-adr.md) ·
[ADR-0030](../../adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md).
Auslöser: Setzung des Auftraggebers vom 2026-10-09 („releasing.md wird unter docs/maintainer
abgelegt“), Freigabe für genau diesen einen Slice am selben Tag.

**Berührte Spec-Stellen:** —

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-10-09.

---

## 1. Ziel und Abgrenzung

**Ziel:** Die Release-Prozedur liegt unter `docs/maintainer/releasing.md`. Rang 6 der Source <!-- d-check:ignore (Ziel entsteht mit diesem Slice) -->
Precedence nennt diesen Ort, und kein Verweis bricht, auch nicht in einem eingefrorenen Artefakt.

**Gemessener Bestand** (2026-10-09, `git grep -l 'releasing\.md' -- ':!.harness/baseline' | wc -l`
→ 66 Dateien; davon in ADRs, `docs/reviews/`, `done/` und `observations/` 50, wobei `observations/`
lebende `state.md` neben eingefrorenen Belegen führt und die Zahl beide zählt):

- **Markdown-Links** (`git grep -ohE '\]\([^)]*releasing\.md[^)]*\)' -- <baum> | wc -l`): 4 in den
  `Accepted`-ADRs [ADR-0064](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md),
  [ADR-0066](../../adr/0066-exit-klassen-des-tap-werkzeugs-sind-die-des-skripts.md) und
  [ADR-0073](../../adr/0073-der-ort-des-tap-zugangsgeheimnisses-ist-das-repo-secret.md) · 27 in 12
  Dateien unter `done/` · 1 in `docs/reviews/` · 2 in `observations/` — zusammen 34.
- **Code-Spans** (`` git grep -ohE '`[^`]*releasing\.md[^`]*`' -- <baum> | wc -l ``): 103 unter
  `done/`, 128 in `docs/reviews/`, 15 in `observations/`, 4 in ADRs; lebend 3 in `open/` und 4 in
  `in-progress/`. Ob `codepaths` sie nach dem Umzug meldet, ist nicht gemessen.
- Die bestehenden `ignore-refs`-Einträge für `docs/reviews/**`, `done/**` und `observations/**`
  decken nur Verweise in `.harness/baseline/**`.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- Eingefrorene Artefakte umschreiben (ADRs, `done/`, `docs/reviews/`, `evidence/`) — Bestand bleibt:
  [`AGENTS.md`](../../../../AGENTS.md) §3.4/§3.11; sie behalten den alten Pfad, und die
  Entscheidung des Architect (§3) hält ihn gültig.
- Die übrigen Dateien unter `docs/user/` — Bestand bleibt: der Auftrag nennt allein `releasing.md`.
- Inhaltliche Änderungen an der Prozedur — anderer Vorgang: der Slice verlegt den Ort, nicht den
  Text; die Regel *Bestand im Release-Text* aus `slice-ziel-traegt-keine-kennung-dieses-repos`
  reist unverändert mit.
- Der Text von Rang 6 in [`AGENTS.md`](../../../../AGENTS.md) §2 und `harness/README.md` —
  Schicht-Abgrenzung: ihn schreibt der Architect (§3.8); dieser Plan führt die Übergabe.

## 2. Definition of Done

- [ ] **Architect-Entscheidung** (Übergabe vor dem Move, [`AGENTS.md`](../../../../AGENTS.md)
      §3.11): Rang 6 in `AGENTS.md` §2 und `harness/README.md` nennt `docs/maintainer/`, in einem <!-- d-check:ignore (Ziel entsteht mit diesem Slice) -->
      eigenen Architect-Commit (§3.8). Der Umgang mit den eingefrorenen Verweisen ist entschieden:
      ein Stub am alten Ort (Empfehlung des Auftraggebers) oder `ignore-refs` mit eigener ADR (§3.5).
- [ ] **Move** ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)):
      `git mv docs/user/releasing.md docs/maintainer/releasing.md` als reiner Move-Commit
      ([`AGENTS.md`](../../../../AGENTS.md) §3.3). Am alten Ort steht danach, was der Architect
      entschieden hat: der Stub mit Zeiger oder die deklarierten `ignore-refs`-Paare samt `# Deckung`.
- [ ] **Nachzug** ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)):
      Alle lebenden Verweise (relative Links in `releasing.md` selbst, `open/`, `next/`,
      `in-progress/`, `state.md` im Register) zeigen auf den neuen Ort, in einem eigenen Commit nach
      dem Move. `make docs-check` ist grün, ohne dass ein eingefrorenes Artefakt angefasst wurde
      (`git diff --stat` über ADRs, `done/`, `docs/reviews/` und `evidence/` ist leer). Der Anker
      `· seit slice-ziel-traegt-keine-kennung-dieses-repos` steht am neuen Ort.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

Reihenfolge, je Schritt ein Commit: **(1)** Architect, **(2)** Move, **(3)** Nachzug.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `AGENTS.md` §2, `harness/README.md` §Source precedence | update (Architect) | Rang 6 nennt `docs/maintainer/` neben `docs/user/`, DoD 1 | <!-- d-check:ignore (Ziel entsteht mit diesem Slice) -->
| `docs/user/releasing.md` → `docs/maintainer/releasing.md` | `git mv` | DoD 2; reiner Move, Rename-Detection bleibt erhalten | <!-- d-check:ignore (Ziel entsteht mit diesem Slice) -->
| `docs/user/releasing.md` (Stub) **oder** `.d-check.yml` (`ignore-refs`) + ADR | neu / update | je nach Architect-Entscheidung, DoD 1–2 |
| `docs/maintainer/releasing.md` | update | relative Links eine Ebene anders aufgelöst (Nachzug), DoD 3 | <!-- d-check:ignore (Ziel entsteht mit diesem Slice) -->
| lebende Verweise in `open/`, `next/`, `in-progress/` und `observations/*/state.md` | update | DoD 3 |

- **Mitgabe an den Architect:** die Messung in §1. Ein Stub hält die 34 Links ohne neue
  `ignore-refs`-Paare gültig; `ignore-refs` verlangt nach §3.5 eine eigene ADR und
  eine `# Deckung`-Zahl je Paar. Zu prüfen ist außerdem, ob der Stub den Anker
  `· seit slice-ziel-traegt-keine-kennung-dieses-repos` tragen muss (§6, Risiko 1).

## 4. Trigger

**Start** (`next` → `in-progress`): `slice-ziel-traegt-keine-kennung-dieses-repos` liegt in
`done/`. Damit steht die Regel *Bestand im Release-Text* in `releasing.md` und reist mit.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): der Architect entscheidet für
  `ignore-refs`, und die Paare samt ADR passen nicht mit Move und Nachzug in eine Review-Sitzung.
  Dann wird die ADR ein eigener Schnitt.
- `in-progress` → `open` (blockiert — Carveout?): `codepaths` meldet die Code-Spans in
  eingefrorenen Artefakten, und weder Stub noch `ignore-refs` deckt sie ohne weitere Entscheidung.

## 5. Closure-Trigger

DoD vollständig. `make docs-check` ist nach dem Nachzug-Commit grün, und
`git diff --stat <vor-move>..HEAD -- docs/plan/adr docs/plan/planning/done docs/reviews 'docs/plan/planning/observations/**/evidence'`
ist leer. Closure-Notiz mit Lerneintrag.

## 6. Risiken und offene Punkte

- Die Anker-Paarung von `slice-ziel-traegt-keine-kennung-dieses-repos` §7 (`liegt in`
  `docs/user/releasing.md`) prüft den Anker in der Datei am alten Pfad. Nach dem Move liegt dort
  ein Stub ohne Anker, oder es liegt nichts mehr — **Ausgang:** <…>
- `codepaths` meldet Code-Span-Pfade in eingefrorenen Artefakten, die keine Link-Form haben; die
  Zahl ist nicht gemessen. `codepaths` prüft Code-Spans; an diesem Plan wurde das als
  `codepath-missing` gesehen. Ob die eingefrorenen Bäume in seinem Prüfbereich liegen, ist offen
  — **Ausgang:** <…>
- Ein Werkzeug oder Workflow nennt den Pfad außerhalb von Markdown (`.github/`, `Makefile`,
  Skripte): `git grep` über alle Dateien fand am 2026-10-09 keinen solchen Treffer. Ein neuer
  Treffer bis zum Start bricht still — **Ausgang:** <…>

## 7. Closure-Notiz

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <Guide oder Sensor> <geschärft/ergänzt>: <was genau>
  — liegt in `<AGENTS.md §X | Makefile:<target> | .harness/skills/…>`.
  Auslöser: `BEO-<KUERZEL>/<slug>` (<slice-kennung-a>, <slice-kennung-b>, <slice-kennung-c> — 3×).
  *(Wurde mit diesem Slice nichts verkörpert — der Normalfall —, entfällt die
  Teil-Zeile `— liegt in …` ersatzlos. Der Eintrag ist dann gezählt, nicht
  verkörpert.)*
- **Beobachtungs-Register (`../observations/`):** <`BEO-<KUERZEL>/<slug>/` neu angelegt, Beleg `evidence/slice-<Kennung>.md` | `evidence/slice-<Kennung>.md` in `BEO-<KUERZEL>/<slug>/` ergaenzt — Zaehler steht damit bei <N>x | keine Beobachtung angefallen>
- **Folge-Slices:** <slice-<Kennung> (<Titel>) — ist eine Datei in `open/`>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** <nur im Repo ohne Wellen-Betrieb — Anker · Folge-Slice · Register, Ergebnis>

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist allein `*` (gesamtes Repo, `ALL`). Die
Modus-Deklaration in `harness/conventions.md` führt `docs/` nicht als eigene Sub-Area.

**Vorgelagert — offene Beobachtungen sichten** (`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence | wc -l`):

- `BEO-ALL/messung-nimmt-lebendes-register-in-den-eingefrorenen-ausschluss` — 2, offen. Die
  Messung in §1 zählt `observations/` als Ganzes; DoD 3 trennt lebende `state.md` von
  eingefrorenen Belegen. Trifft der Slice die Klasse trotzdem, ist es der dritte Beleg.
- `BEO-ALL/verweis-nachzug-bricht-tree-operand` — 2, offen; sachverwandt (Nachzug).
- `BEO-ALL/vorgeschriebener-ortswechsel-macht-adresse-tot`, `…/verweise-brechen-beim-ortswechsel`,
  `…/verweis-nachzug-schreibt-in-eingefrorenes-artefakt` — verkörpert. Ihre Regeln
  ([`AGENTS.md`](../../../../AGENTS.md) §3.11) tragen die Reihenfolge in §3.

**Modus-Begründungsblock:** alle berührten Sub-Areas GF.

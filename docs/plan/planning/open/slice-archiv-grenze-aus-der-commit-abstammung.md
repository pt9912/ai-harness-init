# Slice slice-archiv-grenze-aus-der-commit-abstammung: Die Archiv-Läufe ziehen ihre Grenze aus der Commit-Abstammung

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — die Closure-Bedingung ist die DoD dieses Slice; Baseline-Regelwerk
`modul-06-roadmap.md` §Wann Arbeit eine Welle braucht.

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
[ADR-0081](../../adr/0081-altbestand-grenze-aus-der-commit-abstammung.md) (Festlegungen 1–5,
§Fitness Function, Folgepflicht), [ADR-0033](../../adr/0033-wellen-archivierung-als-unterkommando.md),
[ADR-0041](../../adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md) (Festlegungen 1, 2, 4
bleiben). Anlass: Adopter-CR zu `v0.2.8` (Text in [ADR-0081](../../adr/0081-altbestand-grenze-aus-der-commit-abstammung.md) §Kontext).

**Berührte Spec-Stellen:** `—` — [ADR-0081](../../adr/0081-altbestand-grenze-aus-der-commit-abstammung.md) schärft kein Spec-Stratum.

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-10-07.

---

## 1. Ziel und Abgrenzung

**Ziel:** `archive-welle altbestand` und `archive-welle welle-N` nehmen keinen wellenlosen Slice mehr,
der nach der zugehörigen Welle-Closure geschlossen wurde: der Aufrufer
`cmd/ai-harness-init/archive_welle.go` liest Shallow-Status, Add-Commits
(`git log -1 --no-renames --diff-filter=A --format=%H -- <pfad>`) und Abstammung
(`git merge-base --is-ancestor`) und reicht sie als Werte an `internal/archive`, das die Klasse
entscheidet ([ADR-0081](../../adr/0081-altbestand-grenze-aus-der-commit-abstammung.md) Festlegungen 1–5).

**Lage** (keine Erwartungswerte): `grep -n 'func untergrenzeSperre\|func sperren' internal/archive/vorschau.go`
nennt die heutige Grenze (Existenz eines `done/*/archiv.zip`, für `altbestand` aufgehoben);
`grep -n 'func (b \*Bestand) einordnen' internal/archive/collect.go` die Klasse allein am Feld `Welle:`.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Index-Zeile von [ADR-0041](../../adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md) (Teil-Supersede).** *Anderer Vorgang, erledigt:* Architect-Artefakt,
  gesetzt mit der Annahme von [ADR-0081](../../adr/0081-altbestand-grenze-aus-der-commit-abstammung.md).
- **Erkennung benannter Slices** (`SliceNummer`, Stub-Kennung). *Folge-Slice:*
  `slice-archivierung-erkennt-benannte-slices` trägt sie; dieser Slice ändert die Auswahl, nicht die
  Kennungs-Lesung.
- **Der reale Altbestand-Lauf in diesem Repo.** *Anderer Vorgang:* Werkzeug-Nutzung; er wartet auf
  den Folge-Slice oben.
- **Ein Datums-Schnitt oder eine Namens-Ausnahme-Option.** *Bestand bleibt:* von [ADR-0081](../../adr/0081-altbestand-grenze-aus-der-commit-abstammung.md)
  (Alternativen B, C) verworfen.
- **Vertiefen eines flachen Klons durch das Werkzeug.** *Schicht-Abgrenzung:* die Sperre nennt den
  Zustand; `git fetch --unshallow` bleibt beim Aufrufer des Laufs.

## 2. Definition of Done

- [ ] **1 — Operation und Aufrufer:** `internal/archive` ordnet über eingespeiste Werte ein
      (Altbestand: S ≤ G für einen Grenz-Commit; Welle: früheste Closure in der Abstammung,
      parallele Grenz-Commits gehören beiden); ohne Ergebnisnotiz verhaltensgleich; zwei Sperren mit
      eigener Kennung (flacher Klon · fehlender Add-Commit), nur wo ein Grenz-Commit gebraucht wird;
      `--vorschau` zählt *„bleibt liegen (nach der Grenze)"*. `git` läuft allein in
      `archive_welle.go`. **Rot gesehen** ([`AGENTS.md`](../../../../AGENTS.md) §3.6): Go-Test unter
      umgekehrtem Vergleich; ein Fall in `test/mutations/` am Vergleich in `internal/archive`, den
      `make mutate MUTATE_CASES=…` als gebunden meldet.
- [ ] **2 — E2E im Ziel** (`make full-smoke`, Stufe der Archivierung): Ziel mit committeter,
      unarchivierter `welle-1`-Ergebnisnotiz, ein wellenloser Slice davor, einer danach —
      `archive-welle altbestand` nimmt nur den frühen, ein anschließendes `archive-welle welle-1`
      lässt den späten flach liegen; derselbe Stand per `git clone --depth 1 file://…` bricht mit der
      Shallow-Sperre ab, `done/` unverändert. **Rot gesehen:** Vergleich in `internal/archive`
      übersprungen ⇒ der späte Slice wandert; `--is-shallow-repository`-Prüfung entfernt ⇒ stiller
      Lauf. Die Stufen-Deklaration nennt, was sie misst (`make e2e-abdeckung`).
- [ ] **3 — Texte:** `internal/emit/templates/commands/close-welle.md`,
      `internal/emit/templates/enforce/archivierung.mk` (Hilfetext) und
      [`docs/user/benutzerhandbuch.md`](../../../user/benutzerhandbuch.md) (Zeile `make archive-welle`)
      nennen die Grenze, die Zeile *„bleibt liegen"* und die Shallow-Sperre — Ist-Zustand, keine Chronik.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register: entfällt — kein Brownfield-Bootstrap.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben, oder „keine Beobachtung" in §7.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen prüft die nächste Welle-Closure (das Repo fährt Wellen).

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/archive/collect.go`, `vorschau.go` | update | Einordnung über Abstammungs-Werte, zwei Sperren, Vorschau-Zeile (Liefer-Punkt 1) |
| `cmd/ai-harness-init/archive_welle.go` | update | git-Lesungen, Werte an die Operation ([ADR-0081](../../adr/0081-altbestand-grenze-aus-der-commit-abstammung.md) Festlegung 5) |
| `internal/archive/*_test.go`, `test/mutations/` | neu / update | früheste Closure, parallele Grenz-Commits, ohne Ergebnisnotiz; Mutation am Vergleich |
| `harness/tools/full-smoke.sh` (`archivierung_im_ziel`) | update | Liefer-Punkt 2 |
| `close-welle.md`, `archivierung.mk`, Benutzerhandbuch | update | Liefer-Punkt 3 |

## 4. Trigger

**Start** (`next` → `in-progress`): [ADR-0081](../../adr/0081-altbestand-grenze-aus-der-commit-abstammung.md) `Accepted` (erfüllt); WIP-Limit frei.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next`: Liefer-Punkt 1 und 2 passen nicht in eine Review-Sitzung — dann wird die
  E2E-Hälfte (Liefer-Punkt 2) als eigener Slice geschnitten.
- `in-progress` → `open`: eine Einordnung ist mit den Festlegungen von [ADR-0081](../../adr/0081-altbestand-grenze-aus-der-commit-abstammung.md) nicht entscheidbar
  (z. B. Merge-Commit als Add-Commit) — Übergabe an den Architect.

## 5. Closure-Trigger

1. `make full-smoke` endet EXIT 0 mit beiden neuen Fällen der Archivierungs-Stufe.
2. `make gates` grün und der Mutations-Fall am Vergleich als gebunden gemeldet.

**Lerneintrag** in einer der drei Formen, §7; die Closure schreibt der Planner
([`AGENTS.md`](../../../../AGENTS.md) §3.10).

## 6. Risiken und offene Punkte

- **CI-Klon ist flach** — `actions/checkout` klont per Default mit `fetch-depth: 1`; fährt
  `full-smoke` dort einen Lauf über dem Arbeits-Repo statt über dem tmp-Ziel, greift die Sperre.
  — **Ausgang:** offen bis zur Closure.
- **Add-Commit eines Merge** — ein über einen Merge eingebrachter Pfad liefert mit `--diff-filter=A`
  ggf. keinen oder einen anderen Commit; dann sperrt 4(b) statt einzuordnen. — **Ausgang:** offen bis
  zur Closure.

## 7. Closure-Notiz

- **Was hat funktioniert:** —
- **Was ging anders als geplant:** —
- **Steering-Loop-Eintrag:** —
- **Beobachtungs-Register (`../observations/`):** —
- **Folge-Slices:** —
- **Risiken aus §6:** —

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist `*` (`internal/archive`, `cmd/`,
`internal/emit/templates/`, `docs/user/`, `harness/tools/full-smoke.sh`); `TOOLS` nur über
`full-smoke.sh`, dessen Aussage dem Produkt gilt; `CODEX` nicht.

**Vorgelagert — offene Beobachtungen sichten:** Register am gemergten Stand gesichtet
(`grep -l 'archive-welle\|Archivierung\|shallow\|Abstammung\|Add-Commit' docs/plan/planning/observations/BEO-ALL/*/observation.md`):
kein Eintrag zu Archiv-Grenze, Abstammung oder flachem Klon — keine Treffer.

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).

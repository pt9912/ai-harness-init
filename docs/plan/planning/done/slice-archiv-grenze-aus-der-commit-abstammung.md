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

**Verantwortlich:** pt9912 (Implementer)

**Autor:** Planner. **Datum:** 2026-10-07.

---

## 1. Ziel und Abgrenzung

**Ziel:** `archive-welle altbestand` und `archive-welle welle-N` nehmen keinen wellenlosen Slice mehr,
der nach der zugehörigen Welle-Closure geschlossen wurde: der Aufrufer
`cmd/ai-harness-init/archive_welle.go` liest Shallow-Status, Add-Commits
(`git log -1 --no-renames --diff-filter=A --format=%H -- <pfad>`) und Abstammung
(`git rev-list <G>` als Vorfahren-Menge; bei voller Historie gleichbedeutend mit
`git merge-base --is-ancestor`, im flachen Klon sperrt der Lauf vorher) und reicht sie als Werte an `internal/archive`, das die Klasse
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

- [x] **1 — Operation und Aufrufer:** `internal/archive` ordnet über eingespeiste Werte ein
      (Altbestand: S ≤ G für einen Grenz-Commit; Welle: früheste Closure in der Abstammung,
      parallele Grenz-Commits gehören beiden); ohne Ergebnisnotiz verhaltensgleich; zwei Sperren mit
      eigener Kennung (flacher Klon · fehlender Add-Commit), nur wo ein Grenz-Commit gebraucht wird;
      `--vorschau` zählt *„bleibt liegen (nach der Grenze)"*. `git` läuft allein in
      `archive_welle.go`. **Rot gesehen** ([`AGENTS.md`](../../../../AGENTS.md) §3.6): Go-Test unter
      umgekehrtem Vergleich; ein Fall in `test/mutations/` (`verify: test-go`) kehrt den Vergleich
      in `internal/archive` um, `make mutate MUTATE_CASES=…` meldet ihn gebunden.
- [x] **2 — E2E im Ziel** (`make full-smoke`, Stufe der Archivierung): Ziel mit committeter,
      unarchivierter `welle-1`-Ergebnisnotiz, ein wellenloser Slice davor, einer danach —
      `archive-welle altbestand` nimmt nur den frühen, ein anschließendes `archive-welle welle-1`
      lässt den späten flach liegen; derselbe Stand per `git clone --depth 1 file://…` bricht mit der
      Shallow-Sperre ab, `done/` unverändert. **Rot gesehen:** Vergleich in `internal/archive`
      übersprungen ⇒ der späte Slice wandert (im Aufrufer übersprungen sperrt Festlegung 4(b) —
      eine andere Rot-Ursache, kein Beleg); `--is-shallow-repository`-Prüfung entfernt ⇒ stiller
      Lauf. Die Stufen-Deklaration nennt, was sie misst (`make e2e-abdeckung`).
- [x] **3 — Texte (abgehakt mit präzisiertem Wortlaut, §7 Planner-Entscheidung):**
      `internal/emit/templates/commands/close-welle.md`,
      `internal/emit/templates/enforce/archivierung.mk` (Kopfkommentar; die `##`-Hilfezeile bleibt
      einzeilig) und
      [`docs/user/benutzerhandbuch.md`](../../../user/benutzerhandbuch.md) (Zeile `make archive-welle`)
      nennen die Grenze, die Zeile *„bleibt liegen"* und die Shallow-Sperre — Ist-Zustand, keine Chronik.
- [x] `make gates` grün ([Verifikation](../../../reviews/2026-10-07-archiv-grenze-verifikation.md);
      `make full-smoke` EXIT 0).
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Reconciliation-Register: entfällt — kein Brownfield-Bootstrap.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben, oder „keine Beobachtung" in §7.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen prüft die nächste Welle-Closure (das Repo fährt Wellen); nach dem Move gefahren, §7.

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
  — **Ausgang:** entfallen — `full-smoke` archiviert über einem per `git init` angelegten tmp-Ziel
  mit voller Historie, die cmd-Echt-Tests bauen eigene Repos (Verifikation); kein Workflow fährt
  `archive-welle` über dem Arbeits-Repo (`grep -n archive .github/workflows/*.yml` → kein Treffer).
- **Add-Commit eines Merge** — ein über einen Merge eingebrachter Pfad liefert mit `--diff-filter=A`
  ggf. keinen oder einen anderen Commit; dann sperrt 4(b) statt einzuordnen. — **Ausgang:** weiter
  offen → [`BEO-ALL/archiv-grenze-ueber-merge-historie-ungemessen`](../observations/BEO-ALL/archiv-grenze-ueber-merge-historie-ungemessen/observation.md).

## 7. Closure-Notiz

Geschrieben vom Planner in eigenem Kontext ([`AGENTS.md`](../../../../AGENTS.md) §3.10).
**Rolle:** Planner · **Datum:** 2026-10-07

- **Was hat funktioniert:** Die Grenze aus der Commit-Abstammung trägt in Operation und Aufrufer
  (DoD 1, Mutation 542 gebunden) und im Ziel (`make full-smoke` EXIT 0, Stufe
  `archivierung_im_ziel` mit beiden Fällen und Shallow-Sperre); beide Rot-Belege von DoD 2 trug der
  Verifier nach, je aus der behaupteten Ursache
  ([Verifikation](../../../reviews/2026-10-07-archiv-grenze-verifikation.md)). Review: 0 HIGH/MEDIUM,
  F-1/F-2 behoben in `cb6dee52`, F-3 ohne Befund dieses Diffs stehen gelassen
  ([Review](../../../reviews/2026-10-07-archiv-grenze-review.md)).
- **Was ging anders als geplant:** Der Code liest die Abstammung über `git rev-list` statt
  `merge-base --is-ancestor` — gleiches Verhalten, §1 nachgezogen. Die Rot-Belege von DoD 2 fehlten
  im Implementer-Beleg.
- **Planner-Entscheidung — DoD 3 präzisiert:** „Hilfetext" meint den Kopfkommentar von
  `archivierung.mk` (Zeilen 18–23), den der Adopter am Fragment liest; die `##`-Zeile ist die
  einzeilige `make help`-Ausgabe und trägt keine Bedingungen. Der Wortlaut nennt jetzt den Ort.
- **Steering-Loop-Eintrag:** *Geschärfte Regel*: ein Text-DoD nennt den Ort im Artefakt (Kopfkommentar ·
  `##`-Hilfezeile · Abschnitt), nicht eine Gattung. Nicht verkörpert, gezählt im Register (unten).
- **Beobachtungs-Register (`../observations/`):**
  [`BEO-ALL/dod-ortsangabe-trennt-hilfezeile-und-kopfkommentar-nicht`](../observations/BEO-ALL/dod-ortsangabe-trennt-hilfezeile-und-kopfkommentar-nicht/observation.md)
  neu (1×, Verifikation DoD 3);
  [`BEO-ALL/archiv-grenze-ueber-merge-historie-ungemessen`](../observations/BEO-ALL/archiv-grenze-ueber-merge-historie-ungemessen/observation.md)
  neu (1×, Risiko §6);
  [`BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht`](../observations/BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht/observation.md)
  Beleg ergänzt (Review F-1, F-2; Stand `verkörpert` bleibt).
- **Folge-Slices:** keiner neu; `slice-archivierung-erkennt-benannte-slices` (§1) liegt in `open/`.
- **Trigger-Audit:** Carveouts: keiner berührt. Bootstrap-aware Gates: keines berührt. ADR:
  [ADR-0081](../../adr/0081-altbestand-grenze-aus-der-commit-abstammung.md) `Accepted`, kein
  Re-Evaluierungs-Trigger ausgelöst. Hard Rules: keine mit Auflösungs-Trigger aus diesem Vorgang.
- **Risiken aus §6:** Jede Zeile in §6 trägt ihren Ausgang.
- **Paarungen geprüft am 2026-10-07** (nach dem Move): (a) *Anker*: §7 trägt kein Feld `liegt in`,
  nichts zu prüfen. (b) *Folge-Slice*: `slice-archivierung-erkennt-benannte-slices` liegt in `open/`.
  (c) *Register*: die drei genannten Pfade existieren, `evidence/` trägt 1, 1 und 8 Dateien. Zweite
  Hälfte über das ganze Register: 3 Verzeichnisse ohne Beleg, namentlich `BEO-ALL/cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht`, `BEO-ALL/einstiegs-datei-weicht-von-der-pflichtgliederung-ab`, `BEO-ALL/planungs-bestand-waechst-schneller-als-er-abgebaut-wird`; sie gelten nicht als
  getragen ([`ADR-0069`](../../adr/0069-beleglose-register-verzeichnisse-sind-ein-befund-der-paarung-keine-ausnahme.md)
  Festlegung 2).

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist `*` (`internal/archive`, `cmd/`,
`internal/emit/templates/`, `docs/user/`, `harness/tools/full-smoke.sh`); `TOOLS` nur über
`full-smoke.sh`, dessen Aussage dem Produkt gilt; `CODEX` nicht.

**Vorgelagert — offene Beobachtungen sichten:** Register am gemergten Stand gesichtet
(`grep -l 'archive-welle\|Archivierung\|shallow\|Abstammung\|Add-Commit' docs/plan/planning/observations/BEO-ALL/*/observation.md`):
ein Treffer, `BEO-ALL/benannte-luecke-ohne-ausgang` — er misst den Umfang des
`archive-welle`-Blocks in `harness/README.md`, nicht die Grenze; kein Eintrag zu Archiv-Grenze,
Abstammung oder flachem Klon.

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).

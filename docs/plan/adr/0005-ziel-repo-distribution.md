# ADR-0005: Ziel-Repo-Distributionsmodell — Fetch (Kurs-SSoT) + deterministische Generierung

**Status:** Accepted

**Datum:** 2026-07-19

**Autor:** Demo

**Bezug:** [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`LH-FA-09`](../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren), [`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen), [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)

**Supersedes:** `ADR-0001` (Skelett-Distribution — Skelett-Fetch → deterministischer Generator; zugleich Templates+Regelwerk-Fetch statt Embed). <!-- d-check:ignore (Supersedes-Lineage auf superseded ADR) -->

**Schärft:** [architecture.md §Komponenten](../../../spec/architecture.md) — Emitter/Generator/Fetcher: welche Herkunftsklasse welches Ziel-Artefakt schreibt.

---

## Kontext

`ai-harness-init` bootstrappt ein Ziel-Repo aus mehreren Artefakt-Klassen. Zwei
Beobachtungen trieben diese Entscheidung:

1. **Embed-Duplikat.** Der Emitter trägt die Doc-Templates als `//go:embed`
   (`internal/emit/skel/`, [`LH-FA-02`](../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)) — byte-identische Kopien des
   Kurs-Template-Satzes. Zwei Quellen für denselben Inhalt driften; ein
   Drift-Wächter-Test hält sie heute nur mühsam gleich.
2. **Picker-Grenze fürs Skelett.** Die frühere Fetch-Entscheidung holte das
   Skelett vom gepinnten Kurs-Tag. Das Skelett ist aber mechanisch (gepinnte
   Base-Digests, Gate-Verdrahtung, Sprach-Layout) und kurs-versions-unabhängig
   — eine Fetch-Abhängigkeit dafür bringt Drift und Netz ohne Gegenwert.

Zudem erhält das Ziel-Repo heute **kein Regelwerk** — seine `AGENTS.md` §1 zeigt
auf Prozess-Module, die nicht mitgeliefert werden ([`LH-FA-09`](../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren) schließt die
Lücke).

Leitfrage: **Was ist echte Kurs-SSoT (holen) und was ist mechanisch
(generieren)?**

## Entscheidung

Wir wählen **Variante C: hole nur die Kurs-SSoT, generiere das Mechanische** —
vier Herkunftsklassen fürs Ziel-Repo, gepinnt über **eine Kurs-Version**:

| Klasse | Herkunft |
|---|---|
| Regelwerk + Doc-Templates (inkl. `AGENTS.template.md`) | **Fetch** Kurs @ version → vendored Baseline des Ziel-Repos ([`LH-FA-02`](../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)/[`LH-FA-09`](../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren)) |
| Verzeichnis-Gerüst + Skelett-Dateien (`Dockerfile`, `Makefile`, `go.mod` …) | **Deterministisch generiert**, Tool-als-Quelle ([`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4)) |
| Doc-Gate (`.d-check.yml` + `d-check.mk`) | **Generiert** (`--print-mk`, [`MR-010`](../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)) — unverändert |
| `AGENTS.md`-Inhalt (aus der gefetchten Vorlage) | **Agent/Mensch** autort — tool-fremd ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)) |

Der Bootstrap braucht damit **einmalig Netz** (Fetch); danach ist das Ziel-Repo
über seine vendored Baseline **netzlos** — es spiegelt [`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) fürs Ziel.
Nur das **Ziel-Repo** ist betroffen; das Dogfood behält seine eigene vendored
Baseline unverändert.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — Status quo: Embed-Templates + Skelett-Fetch | vorhanden | Embed-Duplikat driftet; Skelett-Fetch bringt Netz ohne Gegenwert; kein Regelwerk im Ziel |
| B — Alles fetchen, Skelett aus einem Referenz-Repo | eine Mechanik | reintroduziert Drift/Duplikat übers Skelett; zweite Quelle/Pin-Achse |
| **C — Fetch Kurs-SSoT + generiere das Mechanische (gewählt)** | kein Duplikat; eine Versions-Achse; netzlos nach Bootstrap; klare Tool/Agent-Grenze | Tool trägt Sprach-Generator-Wissen; Bootstrap braucht einmal Netz |

## Konsequenzen

- Positiv: Der Kurs ist die einzige Quelle für Regelwerk + Templates (kein
  Embed-Duplikat, ein Drift-Wächter weniger); eine Kurs-Version pinnt beide;
  das Ziel-Repo läuft nach dem Bootstrap netzlos.
- Negativ: Der Bootstrap braucht **einmalig Netz** (Fetch); das Tool trägt je
  Sprache ein Skelett-Generator-Profil (Wartung).
- Grenze: Nur das **Ziel-Repo** wechselt aufs Fetch+Generate-Modell — das
  Dogfood behält [`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache). Die **Picker**-Stanz der Durchsetzungsschicht
  ([`ADR-0004`](0004-durchsetzungs-emission.md)) bleibt **unberührt** — nur die Skelett-Klasse wird
  Generator; Durchsetzung + Workflow-Commands bleiben Picker (Kurs-Template-Satz).
- Folgepflicht: Embed (`internal/emit/skel`) entfernen; Fetch (Regelwerk +
  Templates) + Skelett-Generatoren + Gerüst implementieren; die Umsetzungs-Welle
  planen.

## Fitness Function (falls maschinell prüfbar)

| Tooling | Regel | Make-Target |
|---|---|---|
| Emit-Smoke | Bootstrap in tmp-Repo → `make gates` grün out-of-the-box ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)) | `make smoke` |
| Drift-Test | Ziel-Baseline-Content == Kurs-Version (Reproduzierbarkeit, [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)) | `make test` |

## Re-Evaluierungs-Trigger

Wenn **air-gapped Bootstrap** (kein Netz beim init) zur Pflicht wird → einen
Offline-Cache-/Bundle-Modus als eigenen Slice bewerten (der Fetch ist dann die
neu zu bewertende Annahme).

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-07-19 | Proposed | [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`LH-FA-09`](../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren) |
| 2026-07-19 | Accepted; supersedes [ADR-0001](0001-skelett-distribution.md) | Lastenheft v0.7.0 |

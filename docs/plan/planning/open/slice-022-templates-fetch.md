# Slice slice-022: Templates + Regelwerk fetchen statt einbetten

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-02-fetch-und-readme](../welle-02-fetch-und-readme.md).

**Bezug:** [`LH-FA-09`](../../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren), [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3), [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`ADR-0005`](../../../../docs/plan/adr/0005-ziel-repo-distribution.md).

**Autor:** Claude (Pair-Session). **Datum:** 2026-07-20.

---

## 1. Ziel

Der Emitter bezieht **Doc-Templates und Regelwerk aus dem gefetchten Kurs-Asset**
statt aus dem `//go:embed`-Baum: `internal/fetch` wechselt sein Ziel vom Sprachskelett
auf das Baseline-Bundle, und das Embed-Duplikat `internal/emit/skel` **entfällt** — die
Folgepflicht aus [`ADR-0005`](../../../../docs/plan/adr/0005-ziel-repo-distribution.md).
Das Zielrepo erhält damit erstmals ein Regelwerk ([`LH-FA-09`](../../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren)).

## 2. Definition of Done

- [ ] [`LH-FA-09`](../../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren) erfüllt: der Bootstrap legt Regelwerk **und** Templates als vendored Baseline im Zielrepo ab (spiegelt [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) fürs Ziel), Test referenziert.
- [ ] [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) weiterhin erfüllt: die zweiklassige Template-Ablage entsteht aus der **gefetchten** Quelle; kein Verhaltensverlust gegenüber slice-003.
- [ ] `internal/emit/skel` (Embed) ist **entfernt**; der Drift-Wächter-Test zwischen Embed und Kurs-Template-Satz entfällt ersatzlos — kein zweiter Pfad bleibt zurück.
- [ ] [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit): das gefetchte Asset ist **sha256-gepinnt**, vor dem Entpacken verifiziert; zwei Läufe mit gleicher Kurs-Version → identische Ablage.
- [ ] [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6): `make gates` bleibt **offline-grün** — der Netz-Fetch ist Bootstrap-Pfad, kein Gate.
- [ ] `make gates` grün.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/fetch` | update | Ziel wechselt Sprachskelett → Baseline-Bundle (Regelwerk + Templates), sha256-Pin |
| `internal/emit/skel` | entfernt | Embed-Duplikat; Folgepflicht [`ADR-0005`](../../../../docs/plan/adr/0005-ziel-repo-distribution.md) |
| `internal/emit` | update | Template-Quelle: Embed → gefetchte Baseline; Ziel-Ablage nach [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) |
| Emit-/Fetch-Tests | update | Drift-Wächter entfällt; Pin- und Reproduzierbarkeits-Test treten an seine Stelle |

## 4. Trigger

[`ADR-0005`](../../../../docs/plan/adr/0005-ziel-repo-distribution.md) accepted (**erfüllt 2026-07-19**) und welle-02 aktiv. Dieser Slice ist der
**erste** der umgeplanten welle-02 — slice-023 und slice-004b setzen auf seiner
Fetch-Quelle auf.

Rückführungen: `in-progress → next`, wenn Fetch-Umbau und Embed-Entfernung zusammen den
Ein-Sitzungs-Review sprengen (dann trennen: Fetch zuerst additiv, Embed-Entfernung als
Folge-Slice — mit dem bewusst in Kauf genommenen Zwischenzustand zweier Quellen).
`in-progress → open`, wenn das Kurs-Asset die Templates nicht in der von
[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) verlangten Zweiklassigkeit trägt (Carveout, Modul 7).

## 5. Closure-Trigger

DoD vollständig + Review konform + Closure-Notiz → nach `done/`.

## 6. Risiken und offene Punkte

- **Offline-grün ist die Kernbedingung:** der Fetch braucht Netz, `make gates` darf es
  nicht brauchen ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). Der Netz-Pfad gehört an den Bootstrap, nicht in ein Gate —
  dieselbe Trennung, die `regelwerk-check`/`baseline-freshness` schon tragen.
- **Ein Slice, nicht zwei:** Fetch und Embed-Entfernung müssen zusammen landen, sonst
  steht das Repo zwischendrin mit **zwei** Template-Quellen — genau die Drift, die
  [`ADR-0005`](../../../../docs/plan/adr/0005-ziel-repo-distribution.md) beseitigt. Das ist zugleich das Größen-Risiko aus §4.
- Das Ziel-Baseline-Layout muss [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) spiegeln (Tag-Verzeichnis + `SHA256SUMS`),
  sonst erbt das Zielrepo eine Baseline, die sein eigenes `baseline-verify` nicht prüfen kann.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example).

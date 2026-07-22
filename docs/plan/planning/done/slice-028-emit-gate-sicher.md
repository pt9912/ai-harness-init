# Slice slice-028: Emit out-of-the-box gate-sicher (Spec 0.8.0)

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-03-readme-und-smoke](../welle-03-readme-und-smoke.md).

**Bezug:** [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3), [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen), [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`ADR-0005`](../../../../docs/plan/adr/0005-ziel-repo-distribution.md).

**Autor:** Claude (Pair-Session). **Datum:** 2026-07-21.

---

## 1. Ziel

Der Emit produziert ein **out-of-the-box gate-sicheres** Zielrepo nach dem
nachgezogenen [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) (0.8.0): wiederkehrende Vorlagen **referenziert** aus der
vendored Baseline statt co-located dupliziert, derivative Indexe Fülle-wenn-Inhalt,
Leerordner via `.gitkeep` — der emittierte `docs-check` läuft **0-Befunde ohne
Nacharbeit**. Das entsperrt slice-024 (Voll-E2E-Smoke), der es beweist.

## 2. Definition of Done

- [ ] [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) (0.8.0): der Emit dupliziert die **wiederkehrenden** Vorlagen (ADR · slice · welle · carveout · review-report) **nicht mehr co-located** in `docs/` — sie liegen aus dem Fetch bereits vendored (`.harness/baseline/<tag>/templates/`) und werden von dort kopiert ([`ADR-0005`](../../../../docs/plan/adr/0005-ziel-repo-distribution.md)-Modell, wie der Dogfood). Test belegt: nicht emittiert.
- [ ] **Derivative Indexe** (ADR-Index, Carveout-Index) werden **nicht** als gestempelte Singletons emittiert (Fülle-wenn-Inhalt-da). Test belegt: nicht emittiert; kein emittiertes Singleton verlinkt sie.
- [ ] Leere Struktur-Verzeichnisse (Lifecycle `open/`/`next/`/`done/`, ADR-/Carveout-/Reviews-Ordner) werden mit `.gitkeep` gehalten. Test belegt: vorhanden.
- [ ] **Roadmap gate-sicher:** die emittierte Roadmap bricht `docs-check` im frischen Repo nicht (die „Abgeschlossene Wellen"-Beispielzeile — Design-Entscheidung in §6).
- [ ] [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6): der emittierte `docs-check` meldet **0 Befunde out-of-the-box** — belegt via `make smoke` (die heute 3 Befunde weg). Der **Voll-E2E-`make gates`-Beweis** ist [slice-024](../open/slice-024-voll-smoke.md), hier **nicht** behauptet.
- [ ] `make gates` grün; `make mutate` deckt die neuen Wächter (rot gesehen); Emit-Tests + `courseset-fixture.bats` an die neue Zielmenge angeglichen.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/emit/templates.go` | refactor | `inScope`/`isRecurring`: wiederkehrende Vorlagen **nicht** emittieren; derivative Indexe (ADR-/Carveout-Index) nicht als Singleton — referenziert-statt-co-located |
| `internal/emit` | update | `.gitkeep` in die Leer-Struktur-Verzeichnisse emittieren (neuer/erweiterter Schritt); Ziel-Menge + Pre-Flight (cmd) angleichen |
| Roadmap-Emit | update | „Abgeschlossene Wellen"-Beispielzeile gate-sicher (Design §6) |
| `internal/emit/*_test.go`, `test/courseset-fixture.bats` | update | `TestTemplates_EmittierterBestandVollstaendig` + Fixture an die neue Menge; kein-Co-Location- / `.gitkeep`- / Index-nicht-emittiert-Tests |
| `test/mutations/` | neu | rot färbende Wächter je neuer Zusage (§3.6) |

## 4. Trigger

[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) auf 0.8.0 nachgezogen (Doc-Reconciliation `done`, Commit `beec837`) — der Emit
zieht die Spec nach (Doc-führt). Aufgedeckt durch slice-024s Voll-Smoke (3 gate-unsichere
Befunde + Co-Location-Redundanz + Selbstwiderspruch der emittierten `AGENTS.md`).

Rückführungen: `in-progress → next`, wenn Co-Location-Entfernung, `.gitkeep` und Roadmap-Zeile
getrennt gehören (zu groß). `in-progress → open`, wenn die Roadmap-Zeile einen **Kurs-Fix**
erzwingt (Blocker, ggf. Carveout nach Modul 7).

## 5. Closure-Trigger

DoD vollständig + Review konform + Closure-Notiz → nach `done/`. **Entsperrt [slice-024](../open/slice-024-voll-smoke.md)**
(Voll-E2E-Smoke), mit dem welle-03 schließt und **M2** erreicht.

## 6. Risiken und offene Punkte

- **Roadmap-Beispielzeile — offene Design-Entscheidung.** Die Roadmap **muss** emittiert bleiben
  (stark inbound-verlinkt: `AGENTS.md`, `harness/README.md`, planning-README zeigen auf
  `in-progress/roadmap.md`). Ihre eine gate-unsichere „Abgeschlossene Wellen"-Beispielzeile — ein
  Markdown-Link auf ein `welle-NN`-Platzhalter-Ziel — braucht eine gate-sichere Frisch-Repo-Fassung. Optionen: **(a)**
  Kurs-Fix (Beispielzeile → Inline-Code/leer) + Re-Baseline — sauberste SSoT-Lösung, aber blockiert;
  **(b)** emit-seitige Neutralisierung nur dieser Zeile; **(c)** die „Abgeschlossene Wellen"-Tabelle
  im Skelett leer emittieren. Bei (a) → Blocker/Carveout.
- **Inbound-Link-Prüfung:** sicherstellen, dass **kein** emittiertes Singleton auf die nun
  nicht-emittierten co-located Vorlagen / derivativen Indexe verweist — sonst neue Befunde (die
  Prüfung ergab: die Set-Index-README zeigt auf `.template.md`, wird aber selbst nie emittiert).
- **Fixture-Treue:** `courseset-fixture.bats` koppelt den Dateibestand, die Emit-Tests die
  Transformation — beide an die neue Zielmenge angleichen, sonst falsch-grün.
- **Größe:** vier Konzerne (Co-Location · Indexe · `.gitkeep` · Roadmap) — falls über der
  Ein-Sitzungs-Linie, `in-progress → next` und die Roadmap-Zeile (mit ihrer offenen Entscheidung)
  abspalten.

## 7. Closure-Notiz (nach `done/`)

**Abgeschlossen:** 2026-07-22. Review konform ([`2026-07-22-slice-028-emit-gate-sicher.md`](../../../reviews/2026-07-22-slice-028-emit-gate-sicher.md):
0 HIGH/MEDIUM, 1 LOW aufgelöst), Verifikation bestätigt die DoD (getrennter Kontext).

**Ergebnis:** Der Emit produziert ein out-of-the-box gate-sicheres Zielrepo
([`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) 0.8.0):
`make smoke` meldet **9 Dateien, 0 Befunde** (vorher 3). Recurring nicht mehr co-located, derivative
Indexe nicht emittiert, Struktur via `.gitkeep`, Roadmap emit-seitig neutralisiert (§6 Option b).
Vendored Baseline unberührt (alles emit-seitig). **Entsperrt [slice-024](../open/slice-024-voll-smoke.md)**
(Voll-E2E, schließt welle-03 → M2).

**Steering-Loop-Eintrag:**

- **Sensor-Anhebung:** `make smoke` Schritt 4 *assertet* jetzt den docs-check-Exit (0 Befunde), statt
  ihn nur zu drucken. Ein print-only-„Beleg" ist kein Sensor ([`AGENTS.md`](../../../../AGENTS.md) §3.6) —
  genau diese Lücke ließ das nicht-gate-sichere Ziel bis slice-024 unbemerkt: der Bootstrap lief, der
  Befund-Zähler stand da, niemand las ihn. Vier neue Mutationen (26–29) geben den neuen Zusagen ihr
  rot gesehenes Gegenbeispiel.
- **Benannte Deckungs-Grenze:** reale Upstream-Drift der Roadmap-Link-Form fängt allein `make smoke`
  (Tier-2), nicht `make gates` — der go-Test läuft gegen die `courseSet()`-Fixture. Im Code ehrlich
  benannt (Review-LOW-F-1). Kandidat für Backlog-Cluster C (Doc-Gate-Härtung), falls die Klasse wiederkehrt.
- **Bestätigt (Muster „Messen zuerst"):** die emittierte `.d-check.yml` ignoriert `**/*.template.md`,
  also war Co-Location **nicht** der docs-check-Breaker; die 3 Befunde waren 2 Indexe + 1 Roadmap-Zeile.
  Und das im Ziel emittierte `.gitkeep` in `docs/plan/adr/` ist **load-bearing** (hält den
  Verzeichnis-Link aus AGENTS.md/harness-README nach Wegfall von Index + NNNN-Template), nicht bloß
  Dekoration — aufgedeckt durch Inbound-Link-Tracing, bestätigt durch den Smoke.

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example).

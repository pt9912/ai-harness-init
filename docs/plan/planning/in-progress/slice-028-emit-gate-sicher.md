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

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example).

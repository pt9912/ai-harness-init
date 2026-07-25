# Slice slice-044: Generator-Kompositions-Seam (`lang-renderer × arch-layout`)

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.1/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-07-arch-achse](welle-07-arch-achse.md).

**Bezug:** [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) (Generator/Arch-Achse), [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (`flat` byte-identisch), [`ADR-0008`](../../adr/0008-arch-achse-emittiertes-skelett.md) (Kompositions-Modell).

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-07-24.

---

## 1. Ziel

Der Generator wird von der flachen `profiles()`-Map (`lang → {relpfad: inhalt}`) auf eine
**Kompositions-Schicht** gehoben: **arch-invariante Bau-/Toolchain-Gerüstung** + ein **Rollen-Renderer**
je Sprache, komponiert mit einem **Arch-Layout** (Rollen → Verzeichnisse). Dieser Slice etabliert nur
die **Seam** — der einzige Arch-Wert ist `flat`, das erzeugte Skelett bleibt **byte-identisch** zum
heutigen Stand (kein neues Verhalten, kein CLI-Flag). Er isoliert den in
[`ADR-0008`](../../adr/0008-arch-achse-emittiertes-skelett.md) benannten Migrations-Bruch, bevor
slice-045 das `hexagonal`-Layout und `--arch` darauf aufsetzt.

## 2. Definition of Done

<!--
Was muss erfüllt sein, damit der Slice in done/ wandert?
Liste mit jeweils prüfbarem Kriterium.
-->

- [x] **Kompositions-Seam** ([`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4)): der Generator trägt eine Kompositions-Schicht — ein **Arch-Layout** (Rollen → Verzeichnisse; `flat` = eine Entry-Point-Rolle) + ein **Sprach-Renderer** (Rolle → Inhalt je Sprache) + die **arch-invariante Bau-Gerüstung**. `profiles()`/`goProfile`/`cppProfile` sind darauf umgestellt.
- [x] **`flat` byte-identisch** ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)): das für `go`/`cpp` erzeugte Skelett ist **byte-gleich** zum Ist-Stand; ein Test belegt es (Golden-/Fixture-Vergleich), und `make mutate` färbt einen Byte-Drift rot.
- [x] **Kein neues Verhalten:** kein `--arch`-Flag, kein `hexagonal`-Layout in diesem Slice (kommen in slice-045) — reiner interner Seam.
- [x] `make gates` grün; `make mutate` grün (Byte-Identität-Wächter rot gesehen).
- [x] `make full-smoke` grün: das gebootstrappte Skelett unverändert, `make gates` im Ziel out-of-the-box grün.
- [x] Doku: prüfen, dass der Ist-Code die bereits nachgezogene `architecture.md`-§2/§5-Beschreibung (Kompositions-Schicht) trifft; kein weiterer öffentlicher Vertrag berührt (Lastenheft/ADR schon nachgezogen).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

<!--
Welche Änderungen sind geplant? Datei- oder Komponenten-Ebene reicht.
Der Implementation-Agent erweitert diese Liste in seinem ersten Lauf.
-->

Die Ist-Messung vor Code steht aus (der Implementer verfeinert). Grober Datei-Plan:

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/gen/gen.go` | refactor | `profiles()` → Kompositions-Dispatch (`lang-renderer × arch-layout`); `DefaultVersion`/`SupportedLangs` unberührt |
| `internal/gen/golang.go` | refactor | `goProfile` → Bau-Gerüstung (`go.mod`/`Dockerfile`/`.golangci.yml`) + Entry-Point-Rolle (`cmd/app/main.go`); `flat` byte-identisch |
| `internal/gen/cpp.go` | refactor | `cppProfile` analog (`CMakeLists`/`.clang-tidy` + `src/main.cpp` + `tests/`) |
| `internal/gen/*_test.go` | update | Byte-Identität-Test (`flat` == Ist-Skelett je Sprache); Kompositions-Kopplung |
| `test/mutations/` | neu | Byte-Drift-Wächter (eine Rolle/Gerüstung fällt weg oder ändert Bytes → Skelett ≠ Ist → rot) |

**Verhaltens-erhaltender Refactor:** die Seam ist rein intern; die einzige beobachtbare Zusage ist die
**Byte-Identität** von `flat`. Keine Über-Abstraktion — nur so viel Struktur, wie slice-045
(`hexagonal` + `--arch`) braucht (YAGNI).

## 4. Trigger

<!--
Wann beginnt dieser Slice? (`next` → `in-progress`: Implementer beginnt.)
Beispiele: "Wenn Welle X done." / "Wenn Carveout CO-NN aufgelöst."

Auch die zwei Rückführungen vorab benennen — unter welcher Bedingung
geht dieser Slice zurück?
- `in-progress` → `next`: zu groß, zurück zur Zerlegung.
- `in-progress` → `open`: blockiert (Carveout? siehe Modul 7).
(kanonische Definition: [`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.1/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine))
-->

**`open` → `in-progress` (Implementer beginnt):** Welle [welle-07-arch-achse](welle-07-arch-achse.md)
ist aktiv ([`ADR-0008`](../../adr/0008-arch-achse-emittiertes-skelett.md) Accepted, Doc-Kette komplett);
erster Slice, kein Vorgänger blockiert.

Rückführungen:
- `in-progress` → `next`: falls die Umstellung **beider** Profile (go + cpp) + Tests zusammen über die
  Ein-Sitzungs-Review-Linie geht (dann go und cpp auf zwei Slices trennen).
- `in-progress` → `open`: falls die Byte-Identität sich als unmöglich erweist (unwahrscheinlich — reiner
  Seam-Refactor; Carveout, Modul 7).

## 5. Closure-Trigger

DoD vollständig; Review konform (Modul 10); Verifikation bestätigt die DoD (Modul 11);
`make gates` + `make mutate` grün; Slice per `git mv` nach `done/` (eigener Move-Commit);
Closure-Notiz mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Byte-Identität ist die tragende Zusage.** Der Seam-Refactor muss `flat` byte-gleich lassen — der
  stärkste Wächter (Golden-Vergleich gegen den Ist-Stand). Ein Rollen-Renderer, der auch nur Whitespace
  anders zusammensetzt, bricht ihn; genau das ist erwünscht (der Test soll das fangen).
- **Refactor-Mutations-Reconciliation** (slice-034/035-Lehre): verschobener Code = verschobene Deckung —
  Code + Wächter + Mutation **zusammen** bewegen, sonst veraltet eine profile-bezogene Mutation still.
- **Über-Abstraktion vermeiden:** nur die Seam für slice-045, kein spekulatives Layout-Framework (YAGNI).

## 7. Closure-Notiz (nach `done/`)

<!--
Wird *nach* Abschluss ergänzt. Inhalt:
- Was hat funktioniert?
- Was ging anders als geplant?
- Steering-Loop-Eintrag: welcher Guide/Sensor sollte verbessert werden?
  (kanonische Definition: [`/kurs/de/grundlagen/klassifikation.md` §Steering Loop](https://github.com/pt9912/ai-harness-course/blob/v3.5.1/kurs/de/grundlagen/klassifikation.md#steering-loop))
- Folge-Slices: welche neuen open/-Einträge?
-->

**Was hat funktioniert.** Der Seam ist ein sauberer, verhaltens-erhaltender Refactor: `arch.go`
trägt `archLayout` (Rollen `entrypoint`/`test`) + `composeSkeleton` (Gerüstung ∪ Rollen), `goProfile`/
`cppProfile` komponieren `<lang>Scaffolding` + `<lang>Role` mit dem `flat`-Layout. **Byte-Identität
vierfach belegt:** `make test` (`TestGenerate_GoProfile`/`CppProfile` asserten den exakten Datei-Satz,
grün), `make full-smoke` Exit 0 (Ziel out-of-the-box grün), `make mutate` 56 ok/0 (Fall 60 rot gesehen),
und der `git diff e730439..HEAD` ändert **keine Inhalts-Konstante** (nur die Map→Funktions-Umstrukturierung).
[`ADR-0008`](../../adr/0008-arch-achse-emittiertes-skelett.md)-konform: Gerüstung arch-invariant, Tests als Rolle (cpp `tests/`). YAGNI-minimal: nur `flat`,
`archLayout(unknown)→nil` als slice-045-Naht, kein CLI/hexagonal. Review **KONFORM** (0 HIGH/MEDIUM/LOW),
Verifikation **DoD BESTÄTIGT**.

**Was anders lief als geplant.** Die **Verifier-Infrastruktur scheiterte zweimal** und musste saniert
werden — die tragende Lehre dieses Slice.

**Steering-Loop-Einträge** (kanonische Definition:
[`/kurs/de/grundlagen/klassifikation.md` §Steering Loop](https://github.com/pt9912/ai-harness-course/blob/v3.5.1/kurs/de/grundlagen/klassifikation.md#steering-loop)):

- **Ein `make mutate`-fahrender Verifier gehört NICHT in einen Subagenten mit den heutigen
  Mechanismen.** Drei Fehlermodi real getroffen: (1) `isolation: worktree` legt `.claude/worktrees/<agent>`
  **untracked** im Haupt-Tree ab → das [`MR-003`](../../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)-Working-Tree-Hash (tracked **+ untracked**) verschiebt sich,
  der Stop-Hook feuert dauerhaft, solange der Verifier läuft; (2) die Subagent-Bash **auto-backgroundet
  Befehle >120s** (mutate/full-smoke) → der Agent „pausiert" und verdiktet nie (zwei Versuche); (3) am
  schlimmsten fuhr ein Versuch `nohup make mutate &`, das den Agent-Stop **überlebte**, verwaiste und
  Mutationen (`DefaultGoVersion="9.9.9"` u. a.) auf dem **Haupt-Tree** hinterließ — Force-Kill +
  `git checkout -- .` + Lock-Cleanup nötig. **Regel bis zur Harness-Behebung:** die langsamen DoD-Sensoren
  laufen **in-context** (der Implementer fährt gates/mutate/full-smoke real grün), danach bestätigt ein
  **read-only Verifier** (nur `git diff`/Code/Logs, **keine** `make`-Läufe, <120s) den DoD-Kern unabhängig
  — genau das lieferte hier das saubere Urteil. **Harness-Folgepunkte:** `.claude/worktrees/` in
  `.gitignore` (schließt Fehlermodus 1); Subagenten dürfen langsame Befehle nicht nohup-detachen (2/3).
- **Byte-Identität prüft man am stärksten am DIFF, nicht nur am Sensor.** `git diff <vor>..<nach>` auf die
  Generator-Dateien zeigt, ob nur die Struktur oder auch eine Inhalts-Konstante wanderte — eine
  Sekunden-Probe, die die teuren Sensoren (test/smoke) unabhängig plausibilisiert und die
  read-only-Verifikation trägt.

**Folge-Slices.** Keine neuen `open/`-Einträge. **Nächster Welle-Slice: slice-045** (erstes
`hexagonal`-Arch-Layout + Go-Rollen-Renderer [domain/ports/adapters] + CLI `--arch`) — er baut auf dieser
Seam. **Review-INFO** dieses Slice: (a) `archLayout(unknown)→nil` ist ein bewusst dormanter Zweig (slice-045
aktiviert ihn) — kein toter Code, die Naht; (b) Mutations-Nummern-Kollision `51` → auf `60` umbenannt
(INFO-2 aufgelöst).

## 8. Sub-Area-Modus-Begründung

**Status:** Pflicht-Sektion bei mindestens einer berührten Sub-Area
in BF oder Hybrid. Bei reinem GF genügt der Hinweis
*"alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked
Mini-Example)"*. Optional bei reinem Refactor ohne neue
Sub-Area-Berührung. Die vier Pflichtkriterien (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand)
stehen in
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Worked Mini-Example](https://github.com/pt9912/ai-harness-course/blob/v3.5.1/kurs/de/02-planung/modul-05-planning-harness.md#worked-mini-example-bootstrap-modus-pro-sub-area-für-einen-slice-begründen).

**Vorgelagert — Sub-Area-Wahl prüfen:** Jede hier aufgeführte Sub-Area
muss das Inklusionskriterium erfüllen (drei Achsen, Schwelle ≥ 2; siehe
[`/kurs/de/grundlagen/konventionen.md` §Was ist eine Sub-Area?](https://github.com/pt9912/ai-harness-course/blob/v3.5.1/kurs/de/grundlagen/konventionen.md#was-ist-eine-sub-area)).
Zu grobe Sub-Areas (*"Backend"*) vorher ausdifferenzieren — sonst trägt
der Begründungsblock mehrere Modi vermischt.

### Sub-Area: Generator (`internal/gen/`)

- **Modus:** BF — die Sub-Area existiert (`gen.go` `profiles()`, `golang.go`/`cpp.go`, die
  Skelett-Tests, `TestGoProfile_PinsMatchRepo`); dieser Slice **strukturiert sie um** (Seam), baut nicht
  auf grüner Wiese.
- **Konventionen-Dichte:** hoch. Der Generator fixiert Muster: „ein Profil je Sprache" (`profiles()`-Map),
  deterministisch/byte-identisch ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)),
  Pin-Kopplung an den Repo-Build (`TestGoProfile_PinsMatchRepo`), `<pfad>`-aware Fragmente (slice-037).
  Der Seam muss diese erben, nicht neu erfinden.
- **Phase-Reife:** Phase 4 (reif/produktiv) — der Generator emittiert real (welle-01ff, cpp slice-039).
  Der Seam ist ein verhaltens-erhaltender Refactor, kein Neubau.
- **Evidenz-/Diskrepanz-Risiko:** mittel. Die Umstellung berührt **beide** Profile + ihre Tests; das
  Diskrepanz-Risiko ist die Byte-Identität (ein still geänderter Byte bricht `full-smoke`/den Golden-Test).
  Die Refactor-Mutations-Reconciliation (Deckung mitbewegen) ist der bekannte Fallstrick.
- **Reconciliation-Aufwand:** klein–mittel (ein Slice). Graduation-Trigger: falls go + cpp zusammen die
  Review-Linie sprengen, auf zwei Slices trennen (`in-progress → next`).

# Slice slice-029: Binary-Extraktion in `make artifact` konsolidieren

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (Harness-Wartung). Einordnung *(Kontext, nicht normativ)*:
[roadmap](../in-progress/roadmap.md).

**Bezug:** [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten), [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`ADR-0003`](../../../../docs/plan/adr/0003-go-native-binaries.md).

**Autor:** Claude (Pair-Session). **Datum:** 2026-07-22.

---

## 1. Ziel

Die Extraktion des nativen Release-Binaries auf den Host lebt an **einer** Stelle: ein
`make artifact DEST=<dir>`-Target, das **einmal** baut (Prereq `build`) und **getrennt**
kopiert (`docker cp` aus dem `build`-Image). `smoke.sh` und `full-smoke.sh` teilen es —
die byte-nahe Bootstrap-Duplikation (slice-024-Review-F-2) verschwindet.

## 2. Definition of Done

- [ ] `make artifact DEST=<dir>` extrahiert das native Release-Binary: Build **einmal** über
  den `build`-Prereq (Gate-Image `ai-harness-init:build`), Copy **getrennt** via `docker cp`
  aus einem Wegwerf-Container (kein `--output`-Fusion). Docker-only, **kein neuer gepinnter
  Image** ([`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)).
- [ ] `harness/tools/smoke.sh` **und** `harness/tools/full-smoke.sh` nutzen beide `make artifact`
  — die Extraktion steht an **einer** Stelle (F-2 aufgelöst).
- [ ] Die `artifact`-Scratch-Stage im `Dockerfile` ist **entfernt** (nach dem Switch tot; kein
  `--target artifact`-Referent mehr). `.PHONY` um `artifact` erweitert.
- [ ] Nativ bleibt nativ: **kein** OCI-Vertriebsmittel, konform zu [`ADR-0003`](../../../../docs/plan/adr/0003-go-native-binaries.md).
- [ ] `make gates` grün; **`make smoke` grün**; **`make full-smoke` grün** — die Smokes SIND der
  Wächter der Extraktion ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)): läuft sie falsch, werden sie rot (kein eigener Test nötig).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `Makefile` | update | `artifact`-Target (`build`-Prereq → `docker create`/`cp`/`rm` mit `trap`-Cleanup + `DEST`-Guard) + `.PHONY` |
| `Dockerfile` | update | `artifact`-Scratch-Stage entfernen (tot nach dem Switch) |
| `harness/tools/smoke.sh` | update | Extraktions-Zeile → `make artifact DEST="$tmpbin" GO_VERSION="$GO_VERSION"` |
| `harness/tools/full-smoke.sh` | update | dito |

## 4. Trigger

Sofort (Harness-Wartung, welle-03 in `done/`, keine aktive Welle). Herkunft: slice-024-Review-**F-2**
(Bootstrap-Duplikation smoke.sh ↔ full-smoke.sh) + Design-Klärung mit dem Nutzer („build vom copy
trennen" — `docker cp` statt `--output`, in ein `make`-Target).

Rückführungen: `in-progress → open`, falls sich `docker create`/`docker cp` als unzuverlässig
erweist (z. B. Basis-Image ohne nutzbares Dummy-Command) → Blocker/Carveout. `in-progress → next`,
falls die Änderung wider Erwarten größer ist (unwahrscheinlich — vier Dateien).

## 5. Closure-Trigger

DoD vollständig + Review konform + Verifikation bestätigt + Closure-Notiz → nach `done/`.

## 6. Risiken und offene Punkte

- **`docker create ai-harness-init:build true`** setzt ein nutzbares `true` im Image voraus — das
  golang-Basisimage bringt es mit (coreutils). Wechselt die Basis, ist das Dummy-Command anzupassen
  (benannt, nicht spekulativ abgesichert).
- **Gemeinsamer Image-Tag `ai-harness-init:build`:** `make artifact` mutiert ihn wie `make build` schon
  heute — **kein neues** Shared-State. Bei parallelen Läufen deterministisch (gleiche Quelle → byte-gleiches
  Binary), das Copy folgt unmittelbar dem Build.
- **Kein neuer Wächter** ([`AGENTS.md`](../../../../AGENTS.md) §3.6): die Smokes selbst sind der Wächter der
  Extraktion — eine falsche Extraktion (leeres/fehlendes Binary) lässt Bootstrap bzw. `make gates` im Ziel
  rot werden. Ein separater Mutations-Fall wäre teuer (voller E2E je Mutation) und redundant.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (`harness/tools/`, `Makefile`, `Dockerfile` — siehe Kurs Modul 5
§Worked Mini-Example): adoptierte Tooling-Mechanik, niedriges Evidenz-/Diskrepanz-Risiko, reiner
Refactor ohne neue Sub-Area-Berührung.

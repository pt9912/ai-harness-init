# Slice slice-023: Go-Skelett-Generator (deterministisch)

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-02-fetch-und-readme](../welle-02-fetch-und-readme.md).

**Bezug:** [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`ADR-0005`](../../../../docs/plan/adr/0005-ziel-repo-distribution.md), [`ADR-0003`](../../../../docs/plan/adr/0003-go-native-binaries.md).

**Autor:** Claude (Pair-Session). **Datum:** 2026-07-20.

---

## 1. Ziel

Das Tool **generiert** das Go-Sprachskelett — `Dockerfile`, `Makefile`, `go.mod`,
`.golangci.yml` — **deterministisch aus tool-eigenem Sprach-Wissen** statt es zu fetchen
([`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) nach dem CR, [`ADR-0005`](../../../../docs/plan/adr/0005-ziel-repo-distribution.md) Herkunftsklasse „Tool-als-Quelle").
Ein Layout-Profil, nachvollziehbar wie `d-check --print-mk` — **nicht aus dem Nichts**.

## 2. Definition of Done

- [x] [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) (Generator-Teil) erfüllt: `--lang go` erzeugt das Skelett aus dem Layout-Profil, Test referenziert. *(Der Anker trägt historisch „Picker" — die Anforderung ist auf den Generator umgestellt, siehe Lastenheft §7 v0.7.0.)* → `gen.Generate`/`goProfile`; `TestGenerate_GoProfile` (voller Datei-Satz).
- [x] [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit): zwei Läufe mit gleicher Eingabe → **byte-identische** Ausgabe (kein Zeitstempel, keine Map-Iterations-Reihenfolge im Output). → statischer Inhalt + `sort.Strings` vor dem Write; `TestGenerate_Deterministic` (voller Satz byte-weise). `SKEL_GO_VERSION` ist deterministisch (gepinnter Default / genannter Wert, kein Netz/Datum).
- [x] [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6): das generierte `Makefile` behauptet **nur lauffähige** Targets — jedes emittierte Target läuft im frischen Zielrepo. → `TestGenerate_MakefileTargetsMatchStages` (Target↔Stage strukturell) **+ `make smoke` Schritt 5 (E2E): das generierte Skelett lintet/baut/testet sich real grün** (Host-Docker).
- [x] [`ADR-0003`](../../../../docs/plan/adr/0003-go-native-binaries.md) gewahrt: das generierte Skelett ist **Docker-only** (Stages im `Dockerfile`), keine Host-Toolchain-Annahme. → Dockerfile-Stages deps/test/lint/build, Makefile ruft nur `docker build --target`.
- [x] Der Generator bleibt **sprach-agnostisch** strukturiert (ein Profil je Sprache); `go` ist das erste, die übrigen fünf aus [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) folgen ohne Umbau der Mechanik. → `profiles()`-Map (Sprache → Profil-Builder), ein Eintrag `go`.
- [x] **Der Skelett-Fetch ist abgelöst:** `fetch.Skeleton` (der `lab/example/<lang>`-Pfad aus slice-004a) ist entfernt, **und die `--lang`-Validierung ist übernommen** — sie hing bis hierher am Fetch (fail-fast in `cmd/ai-harness-init`) und darf nicht ersatzlos verschwinden. Unbekannte Sprache → weiterhin Exit 2 mit der Liste der unterstützten Profile. → `fetch.go` gelöscht; `gen.UnknownLangError` + `langExitCode` → Exit 2 (real: `--lang rust` → Exit 2, kein Teil-Write).
- [x] `make gates` grün. → Exit 0 (Verifier selbst gefahren).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag. → s. §7.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/gen` | neu | Generator-Mechanik + Go-Layout-Profil (Tool-als-Quelle) |
| `internal/fetch` | update | `Skeleton` + `lab/example`-Extrakt entfernen; der Baseline-Fetch aus slice-022a bleibt |
| `cmd/ai-harness-init` | update | `--lang go` verdrahtet den Generator statt des früheren Fetch-Pfads; **`--lang`-Validierung wandert vom Fetch zum Generator-Profil** |
| Generator-Tests | neu | Determinismus (zwei Läufe byte-identisch), Target-Lauffähigkeit, Docker-only |

## 4. Trigger

slice-022b in `done/` (die gefetchte Baseline ist dann einzige Template-Quelle).
Vorher **blockiert** — sonst konkurrieren Generator und Embed um dieselbe Ausgabe.

Rückführungen: `in-progress → next`, wenn sich Generator-Mechanik und Go-Profil nicht in
einer Review-Sitzung prüfen lassen (dann trennen: Mechanik zuerst, Profil als Folge-Slice).
`in-progress → open`, wenn das Layout-Profil eine Architektur-Entscheidung erzwingt, die
[`ADR-0005`](../../../../docs/plan/adr/0005-ziel-repo-distribution.md) nicht deckt (z. B. hexagonale Schichten als Pflicht-Layout — dann ADR
vor Code, Modul 4).

## 5. Closure-Trigger

DoD vollständig + Review konform + Closure-Notiz → nach `done/`.

## 6. Risiken und offene Punkte

- **Determinismus ist das Kernrisiko** ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)): Go-Map-Iteration ist absichtlich
  ungeordnet, und ein Zeitstempel im generierten Header bräche die Byte-Gleichheit still.
  Der Test muss zwei volle Läufe vergleichen, nicht nur „Datei existiert".
- **Sprach-Generator-Wissen ist Wartungslast** — [`ADR-0005`](../../../../docs/plan/adr/0005-ziel-repo-distribution.md) §Konsequenzen nennt das
  ausdrücklich als Preis der Entscheidung. Das Profil muss klein und ablesbar bleiben,
  sonst wird jede Sprache ein eigener Wartungszweig.
- **Verdrahtung ist explizit nicht hier:** der `d-check.mk`-Include und der Init-Flow
  gehören zu slice-004b. Dieser Slice erzeugt das Skelett, er verdrahtet es nicht.

## 7. Closure-Notiz (nach `done/`)

**Abgeschlossen 2026-07-21.** Das Sprachskelett wechselt von **Fetch** (der
`lab/example/<lang>`-Pfad aus slice-004a) auf einen **deterministischen Generator**
([`ADR-0005`](../../../../docs/plan/adr/0005-ziel-repo-distribution.md) Herkunftsklasse
„Tool-als-Quelle"). Die fetch.go-Datei ist gelöscht (`internal/fetch` trägt nur noch den
Baseline-Fetch), `internal/gen` ist neu, `cmd/ai-harness-init` verdrahtet `gen.Generate`;
die `--lang`-Validierung wanderte vom Fetch zum Generator (unbekannt → Exit 2).

**Rollen-Durchlauf (frische Kontexte):** Review konform (0 HIGH/MEDIUM, 2 LOW behoben,
3 INFO — `docs/reviews/2026-07-21-slice-023-review.md`); Verifikation bestanden (8/8 DoD
CONFIRMED, 0 VIOLATED — `docs/reviews/2026-07-21-slice-023-verify.md`; `make gates` +
`make mutate` + `make smoke` selbst gefahren).

**Steering-Loop-Lerneintrag.**
- **Determinismus per Konstruktion, nicht per Test allein:** statischer Profil-Inhalt
  (Konstanten) + sortierte Schreibreihenfolge (`sort.Strings` vor dem Write) *garantieren*
  die Byte-Gleichheit; der Test *belegt* sie. Kehrseite (Review-F-3): ein per Konstruktion
  deterministischer Wächter ist nicht durch eine Mutation rot-färbbar — er trägt bewusst
  keinen `test/mutations`-Fall, ehrlich in `internal/gen` benannt, keine §3.6-Lücke.
- **Pin-Wartung als Kopplung statt Duplikat:** die Skelett-Pins sind benannte Consts, an das
  Repo-`Dockerfile`/`go.mod` gekoppelt (`TestGoProfile_PinsMatchRepo`) — eine Quelle, Drift
  fällt rot auf (Nutzer-getrieben: die Pins waren zuerst in den Templates verstreut).
- **E2E statt „auf später vertagen":** kein Gate lintet das generierte Skelett; statt DoD-3
  („lauffähige Targets") strukturell zu lassen, fährt `make smoke` Schritt 5 die generierten
  Go-Gates real — der Beweis, dass die kuratiert-reiche `.golangci.yml` + `main.go`
  zusammenpassen, liegt jetzt in slice-023, nicht erst in slice-024.

**Benannte Folge-Punkte (getrennt, kein Blocker dieser Closure):**
- **architecture.md-Reconciliation** (Verifier-F-4): §1/§2/§4 sagen noch „Skelett-Fetcher"/
  „Picker"; [`ADR-0005`](../../../../docs/plan/adr/0005-ziel-repo-distribution.md) (rank-1)
  schärft die Klasse zum Generator — die rank-2-Spec ist in einem Doku-/Folge-Slice
  nachzuziehen (Muster wie slice-017).
- **go-freshness-Sensor** (Nutzer „sauber trennen"): nächtlicher read-only Alarm auf neueres
  Go/golangci — die stehende „Versionen aktuell halten"-Mechanik, wie `make baseline-freshness`.
  Eigener Slice; der Bump bleibt deliberat.
- **`SKEL_GO_VERSION=latest`** Web-Lookup (go.dev): bewusst non-deterministisch/Netz → eigener
  Slice, damit der Determinismus-Kern rein bleibt.

**Entsperrt slice-004b** (Verdrahten: Gerüst + Init-Flow) — der Generator besitzt jetzt
Makefile/Dockerfile/go.mod, der Doc-Gate-Include folgt dort.

Wellen-Verweis folgt bei welle-02s Closure (done/welle-02-results.md).

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example).

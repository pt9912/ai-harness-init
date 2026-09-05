# MR-048 — Der Reproduzierbarkeits-Anker ist die Rezept-Form, die emittierten Skelette pinnen per Tag

- **Datum:** 2026-09-03
- **Wirksamkeits-Anlass:** slice-160 — die Docker-Form dieses Repos gegen die Ziel-Fassung.
- **Geltungsbereich:** die **Anker-Frage** auf beiden Ebenen, getrennt beantwortet —
  `Dockerfile`, `Makefile` und `d-check.mk` (Dogfood) sowie die Skelett-Vorlagen in
  [`internal/gen/golang.go`](../../internal/gen/golang.go) und
  [`internal/gen/cpp.go`](../../internal/gen/cpp.go) (emittierte Ebene). **Nicht** die zwei
  Regeln desselben Baseline-Abschnitts, die
  [slice-146](../../docs/plan/planning/open/slice-146-modul-14-multi-stage-build-abweichungen-deklarieren.md)
  hält (Runtime-Stage, Image-Hash-Beleg) — die bleiben dort offen.
- **Ersetzt-Baseline-Regel:**
  [`modul-14-docker-harness.md`](../../.harness/baseline/v6.0.0/regelwerk/modul-14-docker-harness.md#multi-stage-build-die-operativen-disziplinen-modul-14)
  §Multi-Stage-Build: die operativen Disziplinen, Regel *„Base-Image per Digest pinnen
  (`FROM …@sha256:…`), nicht per Tag"* — und zwar **nur für die emittierten Skelette**. Für den
  Dogfood tritt dieser Eintrag an keine Regel: dort ist sie erfüllt.
- **Adaption — zwei Verdikte, keine Pauschale über beide Ebenen.**
  1. **Dogfood: Rezept-Form, und sie heißt ab hier so.**
     [`modul-14-docker-harness.md`](../../.harness/baseline/v6.0.0/regelwerk/modul-14-docker-harness.md#zwei-formen-des-reproduzierbarkeits-ankers)
     §Zwei Formen des Reproduzierbarkeits-Ankers verlangt, dass ein Repo seine Form benennt
     (*„wer das nicht tut, hat die Rezept-Form und benennt sie besser auch so"*). Dies ist die
     Benennung. Beide Bedingungen der Rezept-Zeile sind gemessen:
     - *jede Eingabe ist digest-gepinnt* — `grep -c '@sha256:' Dockerfile` → **2**,
       `grep -cE '^[A-Z_]+ \?= .*@sha256:' Makefile` → **3**,
       `grep -cE '^DCHECK_DIGEST \?= sha256:' d-check.mk` → **1**;
     - *beim Build wird nichts installiert* — `go.mod` führt keine `require`-Zeile
       (`grep -c '^require' go.mod` → **0**), `go.sum` existiert nicht
       (`ls go.sum` → nicht vorhanden), und kein Produktionsimport zeigt aus dem eigenen Modul
       heraus (`git grep -hoE '^\s+"[a-z0-9.-]+\.[a-z]{2,}/[^"]+"' -- '*.go' | sort -u`
       → nur `github.com/pt9912/ai-harness-init/…`). `go mod download` in der `deps`-Stufe
       lädt damit nichts.

     **Keine Erwartungswerte** ([`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
     Setzung 2) — die Zahlen wandern mit dem Baum; tragend ist, dass keine der Eingaben
     ungepinnt bleibt. Die **Archiv-Form** liegt nicht vor und kann es nicht: kein Lauf hebt ein
     gebautes Image auf (`grep -rc 'docker push' Makefile d-check.mk .github/workflows/`
     gibt keine Nicht-Null-Zeile). Was daraus folgt, folgt aus der Rezept-Zeile selbst — der
     Digest eines *gebauten* Images ist hier kein Wiederholungs-Schlüssel.
  2. **Emittierte Ebene: weder Archiv- noch Rezept-Form, und das ist die Abweichung.** Die
     Skelette pinnen per **Tag** (`grep -nE '^FROM ' internal/gen/golang.go internal/gen/cpp.go`
     → `golang:${GO_VERSION}`, `golangci/golangci-lint:${GOLANGCI_LINT_VERSION}`,
     `ubuntu:${CXX_VERSION}`; `grep -c '@sha256:' internal/gen/cpp.go` → **0**), und das
     C++-Skelett **installiert beim Build** (`apt-get install … build-essential cmake
     clang-tidy` in der `toolchain`-Stufe). Damit ist die zweite Bedingung der Rezept-Zeile dort
     verletzt, und die erste ebenfalls.
- **Begründung.** Für die Tag-Form spricht eine **höherrangige** Quelle, nicht Bequemlichkeit:
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (Rang 1 der Source
  Precedence) verlangt *„Templates, Sprachskelett, d-check-Image und das Tool-Build-Image
  (Go-Toolchain) auf **Tag/Digest** gepinnt — kein floating main"* und lässt beide Formen
  ausdrücklich zu. Ein Digest im Skelett nähme dem Adopter den Knopf, den die Vorlage ihm gibt
  (`GO_VERSION`, `CXX_VERSION`), ohne dass eine Quelle dieses Repos ihm die Rezept-Form
  vorschreibt: **welche Anker-Form ein emittiertes Repo führt, entscheidet sein Betreiber.**
  Dieses Repo liefert eine Vorlage, keine Reproduzierbarkeits-Zusage über fremde Bäume.
- **Gemessen gegen den Text, nicht gegen das Thema.**
  [`ADR-0003`](../../docs/plan/adr/0003-go-native-binaries.md) §Entscheidung streicht das eigene
  OCI-Image als *Vertriebsmittel* und ist damit der Grund, warum keine Archiv-Form besteht — die
  **Anker-Frage** entscheidet sie nicht: *aufbewahren, um einen Lauf zu wiederholen* und
  *ausliefern* sind zwei Vorgänge, und die ADR spricht nur über den zweiten. Der Kurzschluss,
  den [`BEO-008`](../../docs/plan/planning/observations/BEO-008/adaptions-achse-1-kurzschluss/observation.md) führt, ist hier ausdrücklich
  vermieden.
- **Kein Wächter, und das gehört dazu.** Kein Modul aus `modules:` der
  [`.d-check.yml`](../../.d-check.yml) prüft eine Pin-Form (`grep -m1 '^modules:' .d-check.yml`
  führt `links, anchors, ids, matrix, codepaths, spans`), und `make comment-claims` hat weder
  `internal/gen/*.go`-Rohtext noch eine Markdown-Datei als Gegenstand seiner Prüfung. Die
  Tag-Achse melden `make freshness-go`, `make freshness-golangci` und `make freshness-cpp` —
  sie messen die **Aktualität** eines Pins, nicht seine **Form**.
- **Auflösungs-Trigger:** ein Change Request an
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
  ([`MR-015`](../conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)),
  der *„Tag/Digest"* für das Sprachskelett auf *Digest* verengt. Dann fällt die Deckung dieses
  Eintrags weg und die Skelette ziehen nach. Die Dogfood-Hälfte — die Benennung der Rezept-Form
  — ist **permanent** als Sachstands-Feststellung und neu zu entscheiden erst, wenn dieses Repo
  ein gebautes Image aufbewahrt.

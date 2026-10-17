# Review: slice-release-schnitt-v090-liefert-toolchain-pins-und-sperr-budget

Rolle Reviewer · Diff `47ec1cfe` (ein Commit, vier Dateien) · Plan:
`slice-release-schnitt-v090-liefert-toolchain-pins-und-sperr-budget` (in-progress) · Bezug
LH-QA-02, LH-QA-04, ADR-0058, ADR-0059 · geprüft gegen Plan, `docs/user/releasing.md`,
AGENTS.md §3.3/§3.6/§3.7/§3.10 — nicht gegen die DoD (Verifier).

## Summary

0 HIGH · 1 MEDIUM · 1 LOW · 2 INFO. Der Diff selbst (Pins, Tag-Kopplung, Handbuch) trägt. Das
MEDIUM betrifft einen Satz des Release-Text-Entwurfs (Bestand), kein Repo-Artefakt.

## Findings

### F-1 MEDIUM — Release-Text-Entwurf: „ältester Tag mit abweichender Fassung des `Dockerfile` ist v0.8.0" ist widerlegt

- `quelle`: `docs/user/releasing.md` Schritt 5 (Bestand: „dem ältesten Tag, dessen Fassung abweicht"), AGENTS.md §3.6
- `pfad`: Release-Text-Entwurf (Bericht des Implementers), Abschnitt Bestand
- `befund`: gemessen ist nur v0.8.0 gegen v0.9.0. `git show <tag>:internal/gen/golang.go` liefert
  `DefaultGoVersion`/`golangciVersion`: v0.1.0 und v0.1.1 `1.26.5`/`v2.12.2`, v0.2.0 `1.27.0`/`v2.13.1`,
  v0.3.0 bis v0.8.0 `1.27.1`/`v2.14.0`. Jeder ältere Tag trägt also ebenfalls eine abweichende
  Fassung; „v0.8.0" ist der jüngste abweichende, nicht der älteste. Der Satz sagt mehr, als die
  Messung hält, und schickt einen Adopter eines älteren Ziels in die Irre.
- `verifizierbar`: ja (Kommando oben, `git tag --sort=v:refname`)
- `klasse`: Bestand-Aussage über eine Tag-Grenze ohne Messung über die Tag-Reihe

### F-2 LOW — Abhilfe-Zeile: Wirkung der Dockerfile-Abweichung hängt am erneuerten `go.mk`

- `quelle`: Maintainability / `docs/user/benutzerhandbuch.md` Z. ~389 (zweite Klasse)
- `pfad`: `internal/gen/golang.go:971-984` (`go.mk`-Vorlage), `:938-954` (Dockerfile-Vorlage)
- `befund`: Die Klassenzuordnung stimmt mit dem Handbuch (Dockerfile, `go.mod` zweite Klasse;
  `harness/mk/*.mk` erste Klasse; `go.mod` trägt nur `go 1.27` und weicht nicht ab). Offene Frage
  beantwortet: `make test` und `make build` im Ziel übergeben `--build-arg GO_VERSION=$(GO_VERSION)`,
  `make lint` übergibt `GOLANGCI_LINT_VERSION`; ein `--build-arg` überstimmt den globalen
  `ARG`-Default (Probe unten). Nach einem Re-Lauf (`go.mk` neu geschrieben) ist ein bestehendes Go-Ziel
  über `make` faktisch auf Go 1.27.2 und golangci-lint v2.15.0; das alte `Dockerfile` (Defaults
  1.27.1/v2.14.0) wirkt nur bei direktem `docker build` ohne Argumente. Ohne Re-Lauf bleibt `go.mk` alt
  und das Ziel auf 1.27.1. Eine Rest-Abweichung: `make lint` übergibt `GO_VERSION` nicht, die
  `deps`-Stage (Modul-Cache für den Lint) baut mit dem Dockerfile-Default 1.27.1. Eine Abhilfe-Zeile
  „Dockerfile angleichen, sonst bleibt Ihr Ziel auf 1.27.1" wäre für den `make`-Weg zu stark; „Re-Lauf
  aktualisiert `go.mk` (wirksam über `make`), das `Dockerfile` bleibt Ihre Datei" ist es, was die
  Messung trägt.
- `verifizierbar`: ja für die Vorlagen (gelesen) und die Überstimmung (Probe); das vollständige
  Go-Ziel unter `make test` im Ziel nicht gefahren — der Verifier fährt es
- `klasse`: Abhilfe-Aussage ohne Wirkungsweg der Override-Kette

### I-1 INFO — Mutations-Probe (f)

`make mutate-auswahl` → CI-Branch (Exit 10, Fälle 80, 81, 98), nicht gepusht. Der Slice verlangt in
DoD/§3 keine Mutations-Probe, nur die Rot-Belege L1. Nicht belegt damit: die drei Fälle sind
Release-Skript-Wächter, kein Fall bindet die Makefile-Digests an `SHA256SUMS`; diese Lücke (realer
Digest ungebunden) steht im Plan §6 und bleibt bis `make traeger-fetch` nach der Publikation. Zuständig:
Verifier/Planner.

### I-2 INFO — Pin-Digest-Bruch (c) bleibt benannte Lücke

Ein verfälschter realer `Makefile`-Digest färbt `test/traeger-fetch.bats` nicht (Implementer: 10/10
grün; nicht von mir wiederholt). Plan §1 L1 und §6 nennen die Lücke; nicht verdeckt.

## Ergebnis zu den Schwerpunkten

**(a) Pins.** `TRAEGER_TAG` ist `v0.9.0` in `Makefile:45`, `internal/emit/templates/enforce/traeger.mk:25`
und `test/traeger-fetch.bats:121-122`. Die sechs `TRAEGER_SHA256_*` (`Makefile:46-51`) sind
zeichengleich mit dem lokal vorhandenen `dist/SHA256SUMS` (linux-amd64 `c7b1ac07…a23c`, linux-arm64
`4148c045…fe48`, darwin-amd64 `66c7fffd…cbcb`, darwin-arm64 `0422691f…a10d`, windows-amd64
`50aa9f25…13f6`, windows-arm64 `47eaef93…04e5b5`); `dist/` nicht neu gebaut. Reproduzierbarkeit des
Baus nicht von mir wiederholt (Verifier).

**(b) Release-Text-Entwurf.**
1. Widerlegt, siehe F-1.
2. Stimmt: Dockerfile-Vorlage `ARG GO_VERSION={{GO_VERSION}}` / `FROM golang:${GO_VERSION}`, Kommentar
   „Digest bewusst weggelassen" (`internal/gen/golang.go:936-941`) — Versions-Pin ohne `@sha256`.
3. Stimmt: `lockTries = 750`, `lockWait = 2 * time.Millisecond`, „1,5 s nominal" (`internal/span/emit.go:32,47-48`).
4. Zitat stimmt wörtlich: `https://go.dev/doc/devel/release` trägt „go1.27.2 (released 2026-10-08)
   includes security fixes to the `go` command, and the `crypto/tls`, `html/template`, `net/http`,
   `net/textproto`, and `os` packages" (per curl gelesen); keine CVE-Nummer auf der Seite im Eintrag.
5. Stimmt: Job `start-smoke` im `release.yml` fährt Matrix über alle sechs Binaries
   (`start-smoke.sh`: `--help`, Marker `ai-harness-init` und `add-lang`); `publish` hängt daran. Der
   Smoke belegt Start und Usage, keine Funktion.
6. „Assets: acht" stimmt mit `releasing.md` (sechs Binaries, `SHA256SUMS`, Formel).
7. Grenze „Ursache nicht reproduziert; erster grüner mutate-Lauf (Shard 7 grün) Hinweis, kein
   Wirkungsbeleg" deckt sich mit Plan §1/§6 und dem Kommentar `internal/span/emit.go:41-45`.
8. Bestand: Klassen stimmen (F-2); Pfade und Werte (Dockerfile ARG-Werte, `go.mk`, `traeger.mk`) gegen
   `internal/gen/golang.go` und die Tag-Reihe konsistent (`git diff v0.8.0 HEAD -- internal/gen internal/emit`:
   `golang.go` 2 Zeilen, `traeger.mk` 1 Zeile); die sechs Optionssätze selbst nicht neu gefahren
   (Verifier).

**(c) Rot-Belege.** (b) selbst nachgefahren in Kopie (`git archive` nach `~/.colima-tmp`, nur dort
`TRAEGER_TAG ?= v0.9.1`, Pause nach `sed -i`): `make test-bats BATS_TARGET=test/traeger-fetch.bats` →
`not ok 1 pin-kopplung …` mit `[ "$(pin_wert "$MK" 'TRAEGER_TAG')" = "v0.9.0" ]' failed` (Zeile 121),
Fälle 2-10 `ok`; kein `not ok 10`. Kopie entfernt. (a) und (c) nicht wiederholt.
Override-Probe: Dockerfile mit `ARG V=nonexistent-tag-xyz` und `FROM ai-harness-init:${V}`; `docker build
--build-arg V=build` → Image-ID, Build ohne Argument bricht ab — `--build-arg` überstimmt den Default.

**(d) Handbuch.** Z. 3 und Z. 81 `v0.9.0`, Stand `2026-10-17`; `grep -n 'v0\.8\.0' docs/user/benutzerhandbuch.md README.md` leer;
Aussagen Ist-Zustand, keine Chronik (§3.7), geprüft ohne Befund.

**(e) Commit-Zuschnitt.** Nur Release-Schnitt-Artefakte (Makefile, Vorlage, bats, Handbuch), kein
Architect-/Closure-Artefakt, keine Closure-Felder im Slice berührt (§3.3/§3.8/§3.10); Message nennt
Rolle und Kennungen. `git tag --sort=-v:refname | head -1` → `v0.8.0`; `git log origin/main..HEAD`
nennt fünf lokale Commits des Schnitts (Anlage, zwei `slice-mv`, Roadmap-Marke, `47ec1cfe`);
Freigabe-Vermerk §3 weiter „ausstehend"; `gates-passed.head` == `HEAD` == `47ec1cfe`. `make gates`
am Ende gefahren, Ausgabeende `span-check: Traeger vorhanden …` ohne Fehler.

**(f)** siehe I-1.

## Geprüft, ohne Befund

- Pins Makefile/Vorlage/bats gleich `v0.9.0`; sechs Digests gegen `dist/SHA256SUMS`.
- go.dev-Zitat, Datum, Lock-Budget, Dockerfile-Pin-Form, Assets-Zahl, Start-Smoke-Matrix.
- Handbuch Z. 3/81 und Stand-Datum; README ohne `v0.8.0`.
- Commit-Zuschnitt, Tag/Push-Stand, Stempel == HEAD.
- Kommentar-Klassen (§3.7): der Diff ändert keinen Kommentar außer dem Tag-Wert.

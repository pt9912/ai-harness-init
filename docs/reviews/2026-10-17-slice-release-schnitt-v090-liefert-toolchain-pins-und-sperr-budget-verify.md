# Verifikation slice-release-schnitt-v090-liefert-toolchain-pins-und-sperr-budget (HEAD cc1d32a0)

Rolle Verifier. Frage: bauen wir es richtig, gegen Plan und DoD. Geprueft ist die DoD vor Schritt P (L1, L2);
L3 (Publikation) ist nicht dran und wurde nicht angestossen. Implementer-Commit `47ec1cfe` (Diff `b874dc41..47ec1cfe`:
`Makefile`, `traeger.mk`, `test/traeger-fetch.bats`, `benutzerhandbuch.md`, 13 Zeilen), Reviewer-Report `cc1d32a0`
(0 HIGH / 1 MEDIUM / 1 LOW / 2 INFO). Messungen mit `PATH=/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH`; Bau und Brechen
in Kopien unter `~/.colima-tmp` (`git archive HEAD` bzw. `git archive v0.8.0`), nie im committeten Baum; Kopien am Ende entfernt.

## Verdikte je DoD-Punkt

- **L1 Tag-Baum vorbereitet und verifiziert — erfuellt, mit benannter Luecke (F-1).**
  - Eigener Neubau in leerer Kopie: `make release-artifacts DEST=dist TRAEGER_VERSION=v0.9.0` ->
    `release-artifacts: OK — 6 Binaries + SHA256SUMS in dist`, Exit 0. Die sechs Digests sind byte-gleich mit den sechs
    `TRAEGER_SHA256_*` (`Makefile:46-51`; `awk '{print $1}' dist/SHA256SUMS | sort | diff - <Makefile-Werte>` leer):
    linux-amd64 `c7b1ac07…`, linux-arm64 `4148c045…`, darwin-amd64 `66c7fffd…`, darwin-arm64 `0422691f…`,
    windows-amd64 `50aa9f25…`, windows-arm64 `47eaef93…`. Zusaetzlich liefert der Host-Bau (`make host-bin`, zweiter Bau)
    fuer darwin-arm64 `0422691f…` — gleich dem Asset des ersten Baus. Reproduzierbar.
  - `bash harness/tools/release-sums.sh verify dist` -> sechs `OK`, Exit 0.
  - `TRAEGER_TAG` == `v0.9.0` an drei Stellen: `Makefile:45`, `internal/emit/templates/enforce/traeger.mk:25`,
    `test/traeger-fetch.bats:121-122`.
  - **Rot 1 (selbst):** ein Byte an die Kopie `dist2/ai-harness-init-linux-arm64` angehaengt -> `ai-harness-init-linux-arm64: FAILED`,
    `sha256sum: WARNING: 1 computed checksum did NOT match`, Exit 1, Datei genannt.
  - **Rot 2 (selbst):** `TRAEGER_TAG` der Vorlage in der Kopie auf `v0.9.9` (Pause nach `sed -i`, Wert gelesen) ->
    `make test-bats BATS_TARGET=test/traeger-fetch.bats`: `not ok 1 pin-kopplung …`, `test/traeger-fetch.bats, line 122`,
    `[ "$(pin_wert "$FRAG" 'TRAEGER_TAG')" = "v0.9.0" ]' failed`. Basis ohne Eingriff: 10 von 10 `ok`.
  - **Rot 3, reale Quelle (selbst):** `TRAEGER_SHA256_LINUX_AMD64` im `Makefile` der Kopie auf `0000…` -> `bats test/traeger-fetch.bats`:
    weiterhin 10 von 10 `ok`. Kein Fall faerbt — die bekannte Luecke ist belegt (F-1). Der Slice fuehrt sie ehrlich: §2 L1 (Z. 88-89)
    verlangt genau diese Belegung, §6 (Z. 171) nennt „der reale `Makefile`-Digest ist ungebunden; den Pin gegen das Asset haelt erst
    `make traeger-fetch` nach der Publikation", der Rot-Punkt in L3 (Z. 102-103) ist nach der Publikation faellig.
  - `make gates` Exit 0 auf HEAD `cc1d32a0` (nach dem Reviewer-Commit neu gefahren, allein); `.harness/state/gates-passed.head`
    == `git rev-parse HEAD` == `cc1d32a001931ac77c9c07f337845a61e060e8e6`; letzte Zeile `span-check: … Ablageort git-ignoriert`.
- **L2 Handbuch im Ist-Zustand — erfuellt.**
  - `grep -n 'v0\.8\.0' docs/user/benutzerhandbuch.md README.md` -> leer. Zeile 3 `**Software-Stand:** v0.9.0`, Zeile 81
    „aktuell ausgeliefert wird `v0.9.0`"; Kopf `Stand:` 2026-10-17.
  - `grep -nE '1\.27|golangci|v2\.1[0-9]' docs/user/benutzerhandbuch.md README.md` -> nur `.golangci.yml` (Z. 626, Dateiname), kein
    Pin-Wert: es gibt nichts zu ziehen.
  - Zweite-Klasse-Beschreibung (Handbuch Z. 385-393): `Dockerfile` zweite Klasse (nur bei fehlender Datei), `.mk`-Bausteine unter
    `harness/mk/` erste Klasse. Das deckt sich mit der Messung unten (go.mk neu geschrieben, Dockerfile unangetastet). Das Handbuch
    nennt die Folge fuer die Go-Pins nicht (siehe F-2); der Plan verlangt es nicht.
  - Nicht gelesen: der ganze Handbuch-Text, nur Diff und Messkommandos.
- **Nebenpunkte aus §2:** `make gates` siehe L1; `releasing.md` nicht im Diff (unveraendert).
- **L3 — nicht dran, nicht angestossen.**

## Messaufgabe Bestand (selbst gefahren)

Traeger alt: `git archive v0.8.0` + `make host-bin TRAEGER_VERSION=v0.8.0` (`--version` -> `v0.8.0`). Traeger neu: Bau aus
`git archive HEAD` + `make host-bin TRAEGER_VERSION=v0.9.0` (`--version` -> `v0.9.0`, darwin-arm64). Je Optionssatz zwei frische
`git init`-Verzeichnisse, beide Laeufe Exit 0; `diff -rq -x .git -x baseline -x bin <alt> <neu>`:

| # | Optionssatz | Pfade, die differieren |
|---|---|---|
| 1 | ohne Option (dokument-only) | `harness/mk/traeger.mk` |
| 2 | `--lang go` | `Dockerfile`, `harness/mk/go.mk`, `harness/mk/traeger.mk` |
| 3 | `--lang go --arch hexagonal` | `Dockerfile`, `harness/mk/go.mk`, `harness/mk/traeger.mk` |
| 4 | `--lang go --arch hexslice` | `Dockerfile`, `harness/mk/go.mk`, `harness/mk/traeger.mk` |
| 5 | `--lang cpp --arch hexslice` | `harness/mk/traeger.mk` |
| 6 | `--lang kotlin --arch hexslice` | `harness/mk/traeger.mk` |

Inhalt (Satz 2, in 3 und 4 gleich): `traeger.mk` `TRAEGER_TAG ?= v0.8.0 -> v0.9.0`; `go.mk` und `Dockerfile` je
`GO_VERSION 1.27.1 -> 1.27.2`, `GOLANGCI_LINT_VERSION v2.14.0 -> v2.15.0`. `go.mod` differiert nicht (`go 1.27`, kein Patch-Pin) —
die Annahme im Plan (§6, „`go.mod`") trifft nicht zu. Abweichung von der Erwartung des Implementers: keine. Der Abschnitt „Bestand"
entfaellt damit nicht; die zweite Klasse (`Dockerfile`) aendert sich fuer jedes Go-Ziel.
Nicht gefahren: `--lang cpp` ohne `--arch` (der Auftrag nannte `cpp --arch hexslice`; der Slice-Text `--lang cpp`).

## Re-Lauf eines v0.8.0-Go-Ziels mit dem v0.9.0-Traeger (Reviewer F-2, jetzt gefahren)

Ziel aus Satz 2 (v0.8.0) kopiert, `ai-harness-init --lang go <ziel>` mit v0.9.0, Exit 0. Danach `diff -rq` gegen ein frisches
v0.9.0-Ziel: nur `Dockerfile` (bleibt `ARG GO_VERSION=1.27.1`, `ARG GOLANGCI_LINT_VERSION=v2.14.0`); `harness/mk/go.mk` ist neu
(`GO_VERSION ?= 1.27.2`, `GOLANGCI_LINT_VERSION ?= v2.15.0`). Nebenbefund: ein Re-Lauf **ohne** `--lang go` laesst `go.mk` auf
1.27.1/v2.14.0 stehen (Lauf meldet „sprach-agnostisch (doc-only Gate)").

Gelesene Ausgaben (BuildKit `plain`):
- `make test` -> Exit 0, Kommando `docker build --no-cache-filter test --build-arg GO_VERSION=1.27.2 --target test`;
  `load metadata for docker.io/library/golang:1.27.2`, `[deps 1/5] FROM …golang:1.27.2@sha256:82015309…`. Im Image
  `docker run --rm --entrypoint go app:test version` -> `go version go1.27.2 linux/arm64`. **Gebaut und getestet wird mit 1.27.2**:
  das Make-Argument schlaegt den Dockerfile-Default.
- `make build` -> Exit 0, Kommando mit `--build-arg GO_VERSION=1.27.2`: ebenfalls 1.27.2.
- `make lint` -> Exit 0, Kommando `docker build --build-arg GOLANGCI_LINT_VERSION=v2.15.0 --target lint` (**kein** `GO_VERSION`):
  `FROM docker.io/golangci/golangci-lint:v2.15.0@sha256:fbfcfd12…` und `[deps 1/5] FROM docker.io/library/golang:1.27.1@sha256:162be529…`.
  `golangci-lint --version` im Image: `2.15.0 built with go1.27.0`. **Rest-Abweichung belegt:** die deps-Stage des Lint-Laufs
  (Modul-Download) baut mit dem Dockerfile-Default 1.27.1; golangci-lint selbst ist v2.15.0. Die Abweichung ist auf `make lint`
  beschraenkt und aendert nicht die Go-Version von `make test`/`make build`. Sie entsteht nicht in einem neu aufgesetzten Ziel
  (Dockerfile und go.mk dann beide 1.27.2) und nicht, wenn der Nutzer das `Dockerfile` vor dem Re-Lauf loescht (Handbuch Z. 393).
  Wirkung auf das Lint-Ergebnis nicht gemessen.

## Tag-Reihe (selbst: `git show <tag>:internal/gen/golang.go`, Zeilen `DefaultGoVersion` und `golangciVersion`, alle 17 Tags)

| Tags | Go | golangci-lint |
|---|---|---|
| v0.1.0, v0.1.1 | 1.26.5 | v2.12.2 |
| v0.2.0 bis v0.2.7 | 1.27.0 | v2.13.1 |
| v0.2.8, v0.3.0 bis v0.8.0 | 1.27.1 | v2.14.0 |
| v0.9.0 (HEAD) | 1.27.2 | v2.15.0 |

Abweichung vom Review: `v0.2.8` traegt schon 1.27.1/v2.14.0 (Reviewer nannte v0.3.0 als Beginn; fuer die Aussage unerheblich).
Gemessen ist nur die Konstante in `golang.go`, nicht die Emission je Tag.

## Formulierungsvorschlag Abschnitt „Bestand" (nur Messbares)

> **Bestand.** Gemessen: Traeger `v0.8.0` gegen `v0.9.0`, je in ein frisches Git-Repository, ueber sechs Optionssaetze (ohne Option,
> `--lang go`, `--lang go --arch hexagonal`, `--lang go --arch hexslice`, `--lang cpp --arch hexslice`, `--lang kotlin --arch hexslice`).
> In allen sechs aendert sich `harness/mk/traeger.mk` (Tag), in den drei Go-Laeufen zusaetzlich `harness/mk/go.mk` und das `Dockerfile`
> (Go `1.27.1` -> `1.27.2`, golangci-lint `v2.14.0` -> `v2.15.0`); `go.mod` bleibt gleich. Ein Go-Ziel, das schon steht, bekommt beim
> erneuten Aufsetzen mit `--lang go` die neue `harness/mk/go.mk` (erste Klasse), sein `Dockerfile` bleibt (zweite Klasse): `make test`
> und `make build` laufen dann mit Go `1.27.2`, `make lint` mit golangci-lint `v2.15.0`, dessen Abhaengigkeits-Stage aber mit dem alten
> Dockerfile-Default Go `1.27.1`. Wer das Dockerfile angleichen will, loescht es vor dem Re-Lauf. Fuer aeltere Tags als `v0.8.0` ist
> nur der Pin-Wert in `golang.go` gelesen, die Emission nicht gefahren; der Satz „aeltester Tag mit abweichender Fassung ist v0.8.0"
> entfaellt (v0.8.0 ist der juengste Tag mit abweichender Pin-Fassung).

## Zustand vor Schritt P

- Kein Tag lokal: `git tag --sort=-v:refname | head -1` -> `v0.8.0`.
- Kein Push: `git log origin/main..HEAD --oneline` nennt nur lokale Commits (sechs vor diesem Report, `cc1d32a0` an der Spitze:
  Anlage, zwei `slice-mv`, Roadmap-Marke, Implementer, Reviewer); nichts veraendert.
- Freigabe-Vermerk im Slice §3 (Z. 138): `ausstehend`.

## Findings

- **F-1 (Zusage vs. Sensor, bekannt, ehrlich gefuehrt):** realer `Makefile`-Digest ungebunden (Rot 3: 10 von 10 gruen bei
  verfaelschtem Digest). Deckung vor der Publikation ist allein der eigene Neubau mit Digest-Gleichheit (Asset-Bau und Host-Bau).
  Planner: Ausgang bei Closure; nach der Publikation `make traeger-fetch` mit dem Rot-Beleg aus L3.
- **F-2 (Rest-Abweichung im Re-Lauf, belegt):** `make lint` im Re-Lauf-Ziel baut die deps-Stage mit Go 1.27.1, weil das Lint-Rezept
  in `go.mk` `GO_VERSION` nicht uebergibt. Gehoert in den Release-Text (Bestand), nicht in diesen Schnitt (§1 „weiterer
  Funktionsinhalt"). Ob die Vorlage `go.mk` kuenftig `GO_VERSION` auch beim Lint uebergeben soll, ist ein Folge-Slice-Kandidat
  fuer den Planner.
- **F-3 (Plan-Annahme widerlegt, klein):** §6 nennt `go.mod` als Pfad der zweiten Klasse mit Pin; `go.mod` traegt `go 1.27` ohne
  Patch und differiert nicht.
- Plan-vs-Code: Diff stimmt mit der §3-Tabelle ueberein; Gebautes ohne Plan nicht gefunden.

## Nicht belegt

- Dass der CI-/Workflow-Bau am Tag dieselben Digests liefert: erst nach Schritt P (`make traeger-fetch`, Pin gegen Asset).
- Mutations-Probe `make mutate-auswahl` -> CI-Branch: nicht gefahren (kein Push, Implementer nannte keinen Branch).
- Wirkung des Sperr-Budgets 750 (ausdruecklich nicht Gegenstand, §1).
- Emission aelterer Tags als `v0.8.0`; `--lang cpp` ohne `--arch`; Lint-Ergebnis des Re-Lauf-Ziels bei gemischtem Go-Stand.
- `make full-smoke-host` nicht gefahren (nicht verlangt).

Keine DoD-Haekchen gesetzt, nichts geschlossen (Planner, AGENTS.md §3.10).

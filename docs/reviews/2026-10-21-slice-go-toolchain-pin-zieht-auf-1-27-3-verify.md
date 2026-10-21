# Verifier-Report slice-go-toolchain-pin-zieht-auf-1-27-3

Stand HEAD fd801a53 (Pin-Sprung 5c91a7a1, Basis a40fc0a6). Bezug: LH-QA-02, LH-QA-01, MR-048, ADR-0003.
Läufe auf macOS (colima): nach AGENTS.md §3.9 kein Beleg im Sinne der Norm; Beleg ist die CI auf frischem Klon.

## Verdikte je DoD-Punkt

- **1 — Pin an jeder Stelle, belegter Digest: NICHT BESTÄTIGT (Stand heute).**
  - Diff `git diff a40fc0a6..5c91a7a1 --stat`: 5 Dateien, 6 Zeilen (Makefile, Dockerfile ARG+FROM, golang.go, smoke.sh, full-smoke.sh); Makefile-Diff bis HEAD nur GO_VERSION; go.mod unverändert. Bestätigt.
  - `make freshness-go` → `aktuell — gepinnt und latest sind beide 1.27.3`. Bestätigt.
  - `docker buildx imagetools inspect golang:1.27.3 --format '{{.Manifest.Digest}}'` → `sha256:6928d94d…9261`, Dockerfile:14 trägt `sha256:95786118…fe2b`. **Abweichung.**
  - `make freshness-digest` → `go-toolchain: DIGEST WEICHT AB` (gepinnt 957861185…, aufgelöst 6928d94d…), Exit 1; die übrigen Achsen aktuell.
  - Der Pin-Digest löst weiterhin als Index auf (`imagetools inspect golang@sha256:95786118…` ok): der Tag `golang:1.27.3` wurde nach dem Pin auf einen neuen Index umgesetzt (Manifest-Annotation created 2026-10-21T02:16:06Z). Der Pin war zum Commit-Zeitpunkt vermutlich korrekt (Commit-Message nennt dasselbe Kommando), ist aber jetzt nicht der des Tags; der Wert in der Commit-Message ist heute nicht reproduzierbar. Kein Rate-Limit aufgetreten.
  - Folge: DoD-Rot-Kommando `make freshness-digest` ist mit dem Ist-Stand rot; Closure-Trigger „Digest = Manifest-Digest des Tags" nicht erfüllt. Entscheidung für Planner: Digest auf 6928d94d… nachziehen (ein Wert, eigener Implementer-Lauf, danach Re-Review/Verify der Zeile) oder bewusst den älteren Index belassen und dokumentieren. Hinweis: Das Rezept-Muster (Tag-Umsetzung binnen Stunden) kann sich wiederholen.
- **2 — Skelett trägt 1.27.3, gekoppelt: bestätigt.**
  - Rot-Beleg nachgetragen (reale Quelle, danach `git checkout --`): `DefaultGoVersion="1.27.2"` → `make test-go`: `--- FAIL: TestGoProfile_PinsMatchRepo … ARG GO_VERSION: generiert "1.27.2" != Repo-Dockerfile "1.27.3" (Drift, LH-QA-02)`.
  - smoke.sh-Fallback auf 1.27.2 → `make test-bats BATS_TARGET=test/pin-fallbacks.bats`: `not ok 4 … smoke.sh: Fallback '1.27.2' != Makefile GO_VERSION '1.27.3'`. Beide Ursachen wie behauptet. Baum danach sauber.
  - Grenze: kein Wächter hält den Digest des Dockerfile gegen den Tag außer `freshness-digest` (Netz, nicht in `make gates`) — genau der Fall, der hier rot ist; `make gates` bleibt grün, obwohl der Digest abweicht.
- **3 — build/test/lint unter neuem Image: bestätigt (macOS/colima).** `make build` ok, `make test` alle Pakete ok, bats ok, `make lint` ohne Befund; kein `//nolint`, `.golangci.yml` nicht im Diff. `make gates` siehe unten.

## Vollständigkeit des Pin-Sprungs
`git grep -nE '1\.27\.2'` ohne reviews/done/observations: Fundstellen nur (a) Slice-Plan selbst (Prosa), (b) MR-092/MR-093 (datierte Messaussagen, bleiben), (c) `test/digest-freshness.bats` Z. 21–37 (Fixture-Strings der `--compare`-Fälle, kein Repo-Pin). Keine vergessene Pin-Stelle. Plan-vs-Code: kein Gebautes ohne Plan, keine Plan-Zusage ohne Code.

## Mutation
Hauptkontext liefert das CI-Ergebnis (Branch mutate/…-5c91a7a1); nicht gelesen. Reviewer-Befund bestätigt gelesen: Fälle 668/669/18 verankern 1.27/Digest nicht; der Sprung ist durch `TestGoProfile_PinsMatchRepo` und `pin-fallbacks.bats` bewacht (oben rot gesehen), der Digest nur durch `freshness-digest`.

## Offene Punkte für Planner
1. Digest-Abweichung (DoD 1) klären/nachziehen; danach `make freshness-digest` erneut.
2. DoD-Häkchen und Closure setzt der Planner; Risiko §6 „Image fehlt auf Hub" ist entfallen (Image existiert), „vergessener Digest" ist de facto durch Tag-Umsetzung eingetreten — `freshness-digest` hat ihn gefangen (Wächter greift), Ausgang beurteilt der Planner; Register-Evidenz für `pin-digest-ohne-waechter` bzw. neue Beobachtung „Tag wird nach dem Pin umgesetzt" erwägen.

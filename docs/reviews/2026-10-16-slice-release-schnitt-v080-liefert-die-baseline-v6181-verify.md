# Verifikation slice-release-schnitt-v080-liefert-die-baseline-v6181 (HEAD 90001439)

Rolle Verifier. Frage: bauen wir es richtig, gegen Plan und DoD. Geprueft ist die DoD vor Schritt P
(L1, L2); L3 (Publikation) ist nicht dran und wurde nicht angestossen. Diff `9abe4903..HEAD`: 4 Dateien
(`Makefile`, `traeger.mk`, `test/traeger-fetch.bats`, `benutzerhandbuch.md`), vollstaendig gelesen.
Messungen mit `PATH=/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH`; Bau und Brechen in Kopien
(`git archive HEAD`), nie im committeten Baum; Kopien am Ende entfernt.

## Verdikte je DoD-Punkt

- **L1 Tag-Baum vorbereitet und verifiziert — bestaetigt, mit benannter Luecke (F-1).**
  - Eigener Neubau in leerer Kopie: `make release-artifacts DEST=dist TRAEGER_VERSION=v0.8.0` ->
    `release-artifacts: OK — 6 Binaries + SHA256SUMS`. Die sechs Digests sind byte-gleich mit den sechs
    `TRAEGER_SHA256_*` in `Makefile:46-51` (linux-amd64 `6d89528d…`, linux-arm64 `22469502…`, darwin-amd64
    `ac2aa3f4…`, darwin-arm64 `822a7fa6…`, windows-amd64 `cc9fd36a…`, windows-arm64 `b8a4d128…`). Der Bau ist damit
    reproduzierbar (zweiter, unabhaengiger Bau, gleiche Digests); die Kopie war ein `git archive` ohne `.git`.
  - `bash harness/tools/release-sums.sh verify dist` -> sechs `OK`, EXIT 0.
  - `TRAEGER_TAG` == `v0.8.0` an drei Stellen: `Makefile:45`, `internal/emit/templates/enforce/traeger.mk:25`,
    `test/traeger-fetch.bats:121-122`.
  - **Rot 1 (selbst gefahren):** ein Byte an die `dist`-Kopie `ai-harness-init-linux-arm64` angehaengt ->
    `ai-harness-init-linux-arm64: FAILED`, `sha256sum: WARNING: 1 computed checksum did NOT match`, EXIT 1; Datei genannt.
  - **Rot 2 (selbst gefahren):** `TRAEGER_TAG` der Vorlage auf `v0.9.9` -> `not ok 1 pin-kopplung …` an
    `test/traeger-fetch.bats:122` (`pin_wert "$FRAG" 'TRAEGER_TAG' = v0.8.0` failed); Basis ohne Eingriff: 10 von 10 `ok`.
  - **Rot 3, reale Quelle (selbst gefahren):** `TRAEGER_SHA256_LINUX_AMD64` im realen `Makefile` auf `0000…` ->
    `bats test/traeger-fetch.bats`: weiterhin 10 von 10 `ok`. **Kein Fall faerbt** — die bekannte Luecke ist belegt (F-1).
  - `make gates` EXIT 0 am HEAD `90001439`; `.harness/state/gates-passed.head` == `git rev-parse HEAD`;
    `git status --short` leer. HEAD hat sich waehrend des Laufs nicht bewegt.
- **L2 Handbuch im Ist-Zustand — bestaetigt.**
  - `grep -n 'v0\.7\.0' docs/user/benutzerhandbuch.md README.md` -> leer. Zeile 3 `**Software-Stand:** v0.8.0`,
    Zeile 81 `aktuell ausgeliefert wird v0.8.0`; Kopf `Stand:` auf 2026-10-16 (vom Plan nicht verlangt, harmlos).
  - `grep -n 'v6\.18\.0' …` -> leer; einziger Baseline-Treffer Zeile 202 nennt `v6.18.1`.
  - Stichprobe gegen den Code: `--lang`-Zeile 459 nennt `go`, `cpp`, `kotlin` == Profile in `internal/gen/gen.go`
    (`cpp`, `kotlin` in `profiles()`); `SKEL_KOTLIN_VERSION`-Standard `9.8.1-jdk21` == `internal/gen/kotlin.go:10`
    `DefaultKotlinVersion`; Zeile 328 (`hexagonal` nur Go, `kotlin` mit `hexagonal` -> Exit 2) == Arch-Tabelle
    `gen.go:149-150` (`kotlin`: flat, hexslice). Die Pins `v0.84.0`/`v0.86.1` (Zeile 729) sind Aussagen ueber aeltere
    Ziele; nicht einzeln gegen `emit.go` gemessen.
  - Nicht gelesen: der ganze Handbuch-Text, nur die vom Diff und den Messkommandos beruehrten Zeilen.
- **Nebenpunkte aus §2 — bestaetigt:** `make gates` siehe L1; `releasing.md` unveraendert (nicht im Diff).
- **L3 — nicht dran, nicht angestossen.**

## Zustand vor Schritt P

- Kein Tag lokal: `git tag --sort=-v:refname | head -1` -> `v0.7.0`.
- Kein Push: `git log origin/main..HEAD --oneline | wc -l` -> 36 Commits lokal voraus (nur beschrieben, nichts veraendert).
- Freigabe-Vermerk im Slice (Zeile 116): `ausstehend`.

## Findings

- **F-1 (Zusage vs. Sensor, bekannt, ehrlich gefuehrt):** Der reale `Makefile`-Digest ist ungebunden — `test/traeger-fetch.bats`
  laeuft ueber Fixtures und Skript-Pfade, `pin-kopplung` haelt nur den Tag. Ein verfaelschter Digest bleibt bis
  `make traeger-fetch` nach der Publikation unentdeckt. Slice §6 (Zeile 142) fuehrt die Luecke samt Ausgang bei der Closure;
  Zeile 110 nennt das Brechen des realen Pins als Verifier-Pflicht. Die eigene Nachrechnung der Digests (Neubau, Gleichheit)
  ist vor der Publikation die einzige Deckung. Planner: Ausgang bei der Closure; nach Publikation `make traeger-fetch` fahren.
- **F-2 (Grenze der Reproduzierbarkeit):** Gleiche Digests belegen: derselbe Baum plus gepinnte Images ergibt gleiche Bytes.
  Sie belegen nicht, dass das vom Release-Workflow (CI) publizierte Asset gleich ist; das haelt erst der Vergleich nach
  Schritt P. Kein Mangel, Hinweis fuer L3.
- **F-3 (Hinweis):** `git worktree list` nennt neben dem Hauptbaum `…/scratchpad/w070` (detached `a6ed0813`) — nicht von
  diesem Lauf, nicht entfernt.
- Plan-vs-Code: Diff stimmt mit der §3-Tabelle (Vorlage, Pin, Handbuch, Bats) ueberein; Gebautes ohne Plan nicht gefunden.

## Nicht gefahren

- `make full-smoke` (nicht in der DoD vor Schritt P); `make traeger-fetch` (Netz, nach Publikation); Mutations-CI-Branch
  (Implementer nannte keinen).

Keine DoD-Haekchen gesetzt, nichts geschlossen (Planner, AGENTS.md §3.10).

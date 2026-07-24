# Welle welle-06-freshness: Multi-Komponenten-Versions-Freshness

**Lifecycle:** Die aktive Welle liegt flach unter `docs/plan/planning/`; bei
Closure wandert diese Datei per `git mv` nach `done/` (neben ihre
`welle-06-results.md`). Der Zustand ist die Verzeichnis-Position — kein
Status-Feld. Ob eine flache Welle *aktuell* oder *geplant* ist, sagt die Roadmap.

**Zielmeilenstein:** kein Meilenstein-Bezug (Reliability/Wartung — härtet die
Quellen-Freshness, die [`MR-003`](../../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)/[`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)-Achse).

**Verantwortlich:** ai-harness-init-Team (pt9912). **Datum:** 2026-07-23.

---

## 1. Welle-Ziel

Der nächtliche `upstream-drift`-Job prüft **jede gepinnte Komponente** gegen ihr
Upstream-Latest, nicht mehr nur den Regelwerk-Tag. Heute deckt `baseline-freshness`
allein die Regelwerk-Tag-Achse ab; alle anderen Pins (Go, golangci-lint, das C++-
ubuntu-Base-Tag, das d-check-Image, die Gate-Images) driften **unbemerkt**. Die Welle
verallgemeinert die vorhandene `releases/latest`-Mechanik zu einem parametrierten
Komponenten-Freshness-Sensor und hängt jede Achse in den Nachtlauf. Ergebnis: eine neuere
Version **irgendeiner** Komponente färbt den Nachtlauf rot (read-only Meldung, kein Bump).

Die Sensoren bleiben **read-only** und **außerhalb** `make gates` (Netz-Operation; `make gates`
bleibt offline-grün, [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)), bash+curl+coreutils ohne jq/node ([`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)),
jeweils mit hermetischem `--compare`-Pfad für netzlose Fixture-Tests in `make gates`.
Die *Auflösung* einer gemeldeten Drift (Re-Baseline/Bump) bleibt eine separate, bewusste
Operation ([`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)) — der Sensor *meldet*, er *mutiert* nichts.

## 2. Trigger (Welle startet)

- **Beobachtet (gefeuert):** upstream erschien Regelwerk **v3.5.1** > gepinnt `v3.5.0` —
  die erste beobachtete Tag-/Quellen-Drift (der Roadmap-Trigger der Freshness-Welle). Ein
  Dritter kann ohne Rückfrage bestätigen: `baseline-freshness` meldet den neueren Tag.

## 3. Closure-Trigger (Welle schließt)

- Alle Welle-Slices in `done/`.
- `make gates` grün (die neuen `--compare`-Fixture-Tests je Achse laufen offline in gates).
- `make mutate` grün — je neuem Freshness-Sensor eine rot-färbende Mutation gesehen.
- Jede Achse (Go, golangci-lint, ubuntu-Tag, d-check/Gate-Images) ist im nächtlichen
  `upstream-drift`-Job verdrahtet (belegt im Workflow-Diff), read-only, nicht in `make gates`.
- Closure-Notiz in `welle-06-results.md`.

## 4. Slices in dieser Welle

Nur der erste Slice ist geschnitten (cp-Disziplin — eine Slice-Datei entsteht erst, wenn
der Slice ansteht; slice-041/042 werden bei ihrem Schnitt per `cp` angelegt). Reihenfolge
nach Abdeckungssprung: die GitHub-`releases/latest`-Achsen zuerst (sie teilen die
vorhandene Mechanik), dann die zwei Sonderquellen.

| Slice | Titel | Bezug |
|---|---|---|
| slice-040 | Freshness-Generalisierung + GitHub-Release-Achsen (golangci-lint · d-check) in den Nachtlauf | [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) |
| slice-041 | Go-Version-Freshness (Quelle go.dev/dl) | [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) |
| slice-042 | C++/ubuntu-Base-Tag-Freshness (Quelle Docker-Hub-LTS) | [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) |

## 5. Abhängigkeiten

- Wird blockiert von: nichts (die Mechanik `baseline-freshness.sh` + der Nachtlauf
  `upstream-drift` existieren aus slice-018/027).
- Blockiert: nichts hart. Der v3.5.1-Bump ([`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)) ist unabhängig — die Welle
  *erkennt* Drift breiter, *löst* sie aber nicht auf.

## 6. Out-of-Scope für diese Welle

- **Kein Auto-Bump / kein Auto-PR.** Die Sensoren sind read-only; ein Re-Baseline/Version-
  Bump bleibt eine bewusste Operation ([`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)).
- **Kein GitHub-Issue-Öffnen** aus dem Nachtlauf (rotes CI-Kästchen reicht als Signal;
  eine Issue-Aufwertung wäre eine spätere, separate Erweiterung).
- **GH-Action-SHA-Pins** (`actions/checkout` etc.) — Dependabot-Territorium, nicht
  Toolchain-Freshness.
- **Gate-Images** (actionlint/shellcheck/bats) sind **digest-only** gepinnt — ohne
  Versions-String kein Tag-Vergleich. Sie brauchen zuerst eine Tag-Annotation neben dem
  Digest; das ist eine separate spätere Achse, nicht in dieser Welle.
- Der emittierte Ziel-Repo-Bootstrap bleibt unberührt (die Freshness-Sensoren sind
  ai-harness-init-Wartung, kein emittiertes Artefakt).

## 7. Closure-Notiz

**Geschlossen** (Beleg statt Datum: alle drei Slices in `done/`, `make gates` Exit 0, `make mutate`
55 ok/0, jede Achse im `upstream-drift`-Job verdrahtet). Results-Notiz mit Lieferung, Steering-Loop
und Verifikation: [welle-06-results.md](welle-06-results.md).

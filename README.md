# ai-harness-init

## Was ist ai-harness-init?

Eine CLI, die ein bestehendes Git-Repo mit dem AI-Harness-Kurs-Prozess
bootstrappt: Templates vom gepinnten Kurs-Tag, die Doc-Gate-Baseline und
sprachspezifische Code-Gates aus den lab/example-Skeletten. Für Teams,
die den Harness nicht von Hand zusammenkopieren wollen.

## Was kann ich heute tun?

**Ehrlicher Stand (2026-07-18):** Der **Offline-Kern ist gebaut** — Meilenstein M1
erreicht, welle-01 geschlossen ([welle-01-results](docs/plan/planning/done/welle-01-results.md)).
Das Go-Binary `cmd/ai-harness-init --lang <X> --name <Y>` leistet heute:

- **Doc-Gate-Baseline emittieren** — `.d-check.yml` + `d-check.mk` (Runtime-Codegen aus
  `d-check --print-mk`; slice-002);
- **Template-Baseline zweiklassig ablegen** — Singletons → gestempelte `.md`,
  Wiederkehrende → co-located `.template.md` (slice-003);
- **Sprachskelett vom gepinnten Kurs-Tag fetchen** in einen Staging-Bereich (slice-004a);
  unbekannte Sprache → Exit 2 + Liste.

Der Gate-Stack läuft grün, Docker-only: `make baseline-verify` · `docs-check` (d-check
v0.50.0) · `lint` · `build` · `test` (bats + Go-Unit) · `shell-lint`; `make gates` bündelt
sie. `make smoke` (Nicht-Gate) fährt den echten Bootstrap host-orchestriert. Betriebsregelwerk
+ Templates liegen committet vendored unter `.harness/baseline/v3.5.0/` (netzlos, [`MR-007`](harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache));
Durchsetzungsschicht (Command-Guard bash+awk, Gate-Nachweis, Regelwerk-Injektion) adoptiert.

**Noch offen (welle-02, M2):** das gefetchte Skelett in den Repo-Root **verdrahten/mergen**
(slice-004b — braucht eine Layering-ADR) und die **Root-README** emittieren (slice-005). Erst
dann läuft `make gates` im *emittierten* Repo out-of-the-box grün ([`LH-FA-01`](spec/lastenheft.md#lh-fa-01--repo-bootstrappen) Happy-Path).

**Nächster Schritt (Wiedereinstieg):** die **Layering-ADR** schreiben (Datei-Ownership
Skelett-Schicht ↔ Harness-Emit-Schicht) — sie entsperrt slice-004b; alternativ slice-005. Siehe
[roadmap](docs/plan/planning/in-progress/roadmap.md) (Aktuelle Welle) und
[welle-02](docs/plan/planning/welle-02-fetch-und-readme.md) (§4 Slices).

Keine Erfolgsmeldung ohne lauffähigen Beleg.

## Warum ai-harness-init?

Der Hand-Bootstrap ist mechanisch, aber fehleranfällig — besonders die
Code-Gates: ein fehlender oder falsch verdrahteter Gate ist ein
halluzinierter Gate (Modul 13). ai-harness-init verdrahtet stattdessen
echte, laufende Gates aus bereits gepflegten Skeletten.

## Kerngedanke

**Picker, kein Generator.** Das Tool generiert nichts aus dem Nichts,
sondern wählt das passende Sprachskelett und stempelt es — Single Source
of Truth bleibt der Kurs. Emittiert wird nur, was wirklich läuft.

## Was macht es vertrauenswürdig?

- **Prozess:** [`AGENTS.md`](AGENTS.md) (Hard Rules), [`harness/README.md`](harness/README.md) (Source Precedence, Sensors).
- **Verträge:** [`spec/lastenheft.md`](spec/lastenheft.md) (`LH-*`-IDs mit Akzeptanzkriterien).
- **Entscheidungen:** [`docs/plan/adr/`](docs/plan/adr/) — z. B. [`ADR-0001`](docs/plan/adr/0001-skelett-distribution.md) (Skelett-Distribution).
- **Gates:** `make docs-check` (links/anchors/ids/codepaths), `make test` (Command-Guard bats + Go-Unit-Tests), `make lint`/`make build` (Go via Dockerfile-Stages), `make shell-lint` (shellcheck) — grün; `make gates` bündelt sie. (Das arch-Gate a-check folgt mit dem Go-Code.)

## Lizenz

[MIT](LICENSE) © 2026 pt9912.

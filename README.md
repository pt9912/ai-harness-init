# ai-harness-init

## Was ist ai-harness-init?

Eine CLI, die ein bestehendes Git-Repo mit dem AI-Harness-Kurs-Prozess
bootstrappt: Templates vom gepinnten Kurs-Tag, die Doc-Gate-Baseline und
sprachspezifische Code-Gates aus den lab/example-Skeletten. Für Teams,
die den Harness nicht von Hand zusammenkopieren wollen.

## Was kann ich heute tun?

**Ehrlicher Stand:** Doku-Harness kohärent (Phase 3–4); der Code ist noch
ungebaut (Phase 0). Verfügbar:

- `make baseline-verify` (vendored Baseline netzlos, Integrität + Vollständigkeit),
  `make docs-check` (Doku-Referenz-Gate, d-check v0.46.0), `make test`
  (Command-Guard + Harness-Tests via bats **plus** Go-Unit-Tests) und `make shell-lint` (shellcheck) laufen
  grün — Docker-only;
- **Betriebsregelwerk + Templates committet vendored** unter
  `.harness/baseline/v3.1.0/` (netzlos auf jedem Checkout, [`MR-007`](harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)) — Baseline v3.1.0
  adoptiert;
- Durchsetzungsschicht adoptiert: Command-Guard (bash+awk), Gate-Nachweis,
  Regelwerk-Injektion (Codex-Hook / Claude-Pointer aus der vendored Baseline);
- Spec, Architektur, ADR und Harness-Einstieg sind adoptiert und lesbar;
- ausführbare Bootstrap-Funktion (`cmd/ai-harness-init`, Go-Binary): **folgt** —
  slice-001..005 auf Go geschnitten (`cmd/`, Go-Gates), **startbereit**; Impl gegen `LH-FA-*`.

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

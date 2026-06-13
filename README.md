# ai-harness-init

## Was ist ai-harness-init?

Eine CLI, die ein bestehendes Git-Repo mit dem AI-Harness-Kurs-Prozess
bootstrappt: Templates vom gepinnten Kurs-Tag, die Doc-Gate-Baseline und
sprachspezifische Code-Gates aus den lab/example-Skeletten. Für Teams,
die den Harness nicht von Hand zusammenkopieren wollen.

## Was kann ich heute tun?

**Ehrlicher Stand:** Doku-Harness kohärent (Phase 3–4); der Code ist noch
ungebaut (Phase 0). Verfügbar:

- `make docs-check` läuft grün (Doku-Referenz-Gate, d-check v0.8.0);
- Spec, Architektur, ADR und Harness-Einstieg sind adoptiert und lesbar;
- ausführbare Bootstrap-Funktion (`bin/ai-harness-init`): **folgt** —
  Implementierung gegen `LH-FA-*`.

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
- **Gates:** `make docs-check` grün (links/anchors/ids/codepaths); `make gates`. (`lint`/`test` folgen mit dem Code.)

## Lizenz

[MIT](LICENSE) © 2026 pt9912.

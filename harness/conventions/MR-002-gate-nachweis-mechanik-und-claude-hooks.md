# MR-002 — Gate-Nachweis-Mechanik und Claude-Hooks

- **Datum:** 2026-06-13
- **Geltungsbereich:** [`harness/tools/`](../../harness/tools/), [`.claude/`](../../.claude/), `make record-gates`
- **Ersetzt-Baseline-Regel:** keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**,
  und er setzt keine Abweichung: er protokolliert eine **Übernahme**. Das Artefakt-Set, das er
  einführt — Hook-Verdrahtung, Tool-Call-Gate, Handoff-Gate und die gemeinsame, inhaltsbasierte
  Nachweis-Quelle für Gate-Lauf *und* Handoff-Gate —, ist Punkt für Punkt das der Baseline:
  [`grundlagen-durchsetzungsschicht.md`](../../.harness/baseline/v6.0.0/regelwerk/grundlagen-durchsetzungsschicht.md#das-vollständige-artefakt-set)
  §Das vollständige Artefakt-Set, am Stand `v5.12.0` unter dem Titel §Referenz-Implementierung
  gelesen; ob die Deckung am adoptierten Stand `v5.18.0` trägt, misst der Adaptions-Durchgang
  (slice-157). Auch der Host-Toolchain-Block
  ersetzt dort nichts: Denylist-Inhalt und Grenze eines Befehls-Guards regelt
  [`modul-13-quality-gates.md`](../../.harness/baseline/v6.0.0/regelwerk/modul-13-quality-gates.md#guard-haertung)
  §Guard-Härtung, ohne den Umfang festzuschreiben. **Wo** die Skripte liegen, weicht ab — das trägt
  [`MR-005`](../conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption), nicht dieser Eintrag.
- **Adaption:** Übernahme der Working-Tree-Hash-Mechanik (`record-gates`
  als letzter `gates`-Prerequisite, der Stop-Hook vergleicht den Hash) und
  der `.claude`-Hooks (PreToolUse-Guard, Stop-Gate) aus d-check/b-cad. Der
  PreToolUse-Guard blockt Host-Paketmanager **und die Host-Go-Toolchain**
  (`go`/`gofmt`/`golangci-lint`) — der Build ist Docker-only.
- **Begründung:** Bewährte Mechanik gegen „Erfolgsmeldung ohne Gate-Lauf";
  der Host-Go-Block setzt das Docker-only-Build-Model durch (kein
  Host-Toolchain-Leak). Keine Logik-Dopplung zwischen Makefile und Hook.
- **Auflösungs-Trigger:** permanent.

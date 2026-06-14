# Claude Code Einstieg — ai-harness-init

Dieses Repo folgt dem AI-Harness-Prozess (Greenfield: Doc führt, Code folgt).

**Betriebsregelwerk (wortgleich, lokaler Cache).** Das **vollständige** Regelwerk
liegt unter `.harness/cache/agents-regelwerk.md` (~4000 Zeilen; via `make
regelwerk-fetch`, gitignored, sha256-gepinnt — [`MR-004`](harness/conventions.md#mr-004--sessionstart-regelwerk-injektor)). **Lies diese Datei
vollständig zu Beginn jeder Harness-Arbeit** (Source Precedence aus `AGENTS.md`
§1; bei >2000 Zeilen paginieren). Pointer-Modus: kein `@`-Auto-Import, weil der
Volltext Claudes 150k-Zeichen-Memory-Limit sprengt (~108k Token + Warnung).

Vor jeder Änderung an Code oder Dokumentation lesen:

1. `harness/README.md`
2. `AGENTS.md`
3. `harness/conventions.md`
4. der aktive Slice unter `docs/plan/planning/`
5. referenzierte ADRs unter `docs/plan/adr/`
6. referenzierte Anforderungen unter `spec/`

Regeln:

- Source Precedence aus `AGENTS.md` und `harness/README.md` befolgen.
- Nur `make`-Targets für Checks und Gates; keine Host-Paketmanager oder
  -Toolchains (`pip`, `npm`, `cargo`, `apt`, `brew`, `go`, …) — der Build
  ist Docker-only ([ADR-0003](docs/plan/adr/0003-go-native-binaries.md)). Der PreToolUse-Guard erzwingt das.
- Vor der Implementierung benennen: Slice-ID, betroffene `LH-*`-IDs,
  ADR-IDs, betroffene Komponenten, zu laufende Gates.
- Vor dem Abschluss: `make gates`. Der Stop-Hook lässt keinen Abschluss
  ohne abgedeckten Gate-Lauf zu.
- Kein Erfolg ohne echte Gate-Ausgabe.
- Bei Quellen-Konflikt: Konflikt melden und der höherrangigen Quelle folgen.

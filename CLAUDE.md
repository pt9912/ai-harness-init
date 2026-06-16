# Claude Code Einstieg — ai-harness-init

Dieses Repo folgt dem AI-Harness-Prozess (Greenfield: Doc führt, Code folgt).

**Betriebsregelwerk (wortgleich, Split-Modul-Cache).** Das Regelwerk liegt als
**Modul-Verzeichnis** unter `.harness/cache/agents-regelwerk/` (21 Dateien:
`grundlagen-*` + `modul-00`…`modul-16` + `README.md` als Index; via `make
regelwerk-fetch`, gitignored, ZIP-sha256-gepinnt — [`MR-006`](harness/conventions.md#mr-006--regelwerk-cache-als-split-modul-verzeichnis), ergänzt
[`MR-004`](harness/conventions.md#mr-004--sessionstart-regelwerk-injektor)). **Lies zu Beginn jeder Harness-Arbeit den Index** (`README.md`)
**und das für die Aufgabe relevante Modul on-demand** (Source Precedence aus
`AGENTS.md` §1) — der Volltext (~4000 Zeilen / ~108k Token) wird bewusst **nicht**
als Ganzes geladen (sprengt Claudes 150k-Zeichen-Memory-Limit; kein
`@`-Auto-Import). Fehlt das Verzeichnis, zuerst `make regelwerk-fetch` ausführen —
sonst ist das Regelwerk nicht verfügbar (dann **nicht** als geladen voraussetzen).

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

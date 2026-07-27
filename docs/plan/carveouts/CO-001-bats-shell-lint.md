# CO-001: shell-lint deckt die bats-Dateien nicht ab

**Status:** Aktiv.

**Datum angelegt:** 2026-07-21. **Letzte Prüfung:** 2026-07-27 (welle-08-Closure-Audit: **unverändert gültig, Trigger nicht erfüllt**. welle-08 selbst fügte **keine** `.bats`-Datei hinzu; die Zahl stieg dennoch von zwölf auf **dreizehn** — `test/comment-claims.bats` kam aus einem wellenlosen Slice derselben Sitzung. Gemessen: die neue Datei trägt **null** Verzweigungen/Schleifen (`grep -cE '^\s*(if|for|while|case) '` → 0), also weiter lineare `run`+`assert`-Logik — der Auflösungs-Trigger verlangt eigene Hilfsfunktionen mit Verzweigung. Die im Geltungsbereich genannte Zahl war auf „elf" stehengeblieben und ist hiermit korrigiert). **Vorherige Prüfung:** 2026-07-25 (welle-07-Closure-Audit: unverändert gültig; welle-07 fügte **keine** `.bats`-Datei hinzu — ihre neuen Wächter sind Go-Tests und `test/mutations/*.sh`, und Letztere werden von `shell-lint` **voll** gelintet. Geltungsbereich und Begründung unberührt). **Vorherige Prüfung:** 2026-07-24 (welle-06-Closure-Audit: drei `.bats`-Dateien hinzugekommen — `component-freshness`, `go-freshness`, `cpp-freshness` —, die unter denselben Glob-Ausschluss fallen).

**Betroffenes Gate:** `shell-lint` (shellcheck im gepinnten Image).

**Geltungsbereich:** alle bats-Dateien unter test/ (Endung .bats; aktuell dreizehn). Die
Shell-Hooks und -Helfer unter harness/tools/, .claude/hooks/,
internal/emit/templates/ und test/mutations/ bleiben **voll** gelintet — der
Ausschluss betrifft ausschließlich die bats-Testdateien.

**Folge-Slice:** noch keiner angelegt — Trigger-gebunden (Herkunft:
[slice-008](../planning/done/slice-008-shell-lint-gate.md), §6-Folge-Punkt).

---

## Begründung

shellcheck parst die bats-@test-Syntax nicht: eine .bats-Datei ist kein
POSIX-/Bash-Skript mit Shebang, sondern ein bats-DSL mit @test-Blöcken. Ein
direkter shellcheck-Lauf über die .bats-Dateien bricht mit **Parse**-Fehlern
(nicht mit echten Lint-Befunden) und wäre damit ein Gate, das nichts Reales
prüft. Der shell-lint-Recipe schließt .bats deshalb bewusst aus (dokumentiert im
Recipe-Kommentar des Makefiles).

Das ist eine technische Werkzeuggrenze, kein „noch nicht geschafft": die
bats-Logik ist heute dünn (Setup plus wenige lineare `run`+`assert`-Zeilen je
Datei), sodass der Nutzen einer Teilabdeckung den Aufwand — die @test-Rümpfe für
ein `--shell=bash`-Preprocessing zu extrahieren — aktuell nicht trägt.

## Auflösungs-Trigger

Sobald die bats-Logik nennenswert wächst — konkret: sobald **eine einzelne
.bats-Datei eigene Hilfsfunktionen mit Verzweigung oder Schleifen** trägt (nicht
nur lineare `run`+`assert`-Zeilen). Dann die @test-Rümpfe extrahieren und mit
`shellcheck --shell=bash` linten (slice-008-Folge), oder ein bats-natives
Lint-Werkzeug einführen.

## Geltungs-Konfiguration

| Datei | Zeile/Section | Wert |
|---|---|---|
| Makefile | `shell-lint`-Recipe (Kommentar + Datei-Liste des shellcheck-Aufrufs) | .bats nicht in der Liste — Grund im Kommentar; Verweis „CO-001" |

## Verifikation (nach Auflösung)

- [ ] Gate ist für den Geltungsbereich aktiviert (`shell-lint` deckt die bats-Dateien ab).
- [ ] `make gates` grün ohne Ausnahme.
- [ ] Datei wird nach `docs/plan/carveouts/done/` bewegt (reiner `git mv`). <!-- d-check:ignore (done/ entsteht erst bei erster Carveout-Auflösung) -->
- [ ] Folge-Slice geschlossen oder explizit dokumentiert.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-07-21 | Angelegt (Backlog-Formalisierung, Roadmap §Backlog Cluster E) | [slice-008](../planning/done/slice-008-shell-lint-gate.md) |
| 2026-07-21 | Geprüft, weiterhin gültig | — |
| 2026-07-22 | Audit bei welle-03-Closure: weiterhin gültig — Auflösungs-Trigger nicht erfüllt (welle-03 fügte keine bats-Hilfsfunktion mit Verzweigung/Schleifen hinzu; die vorhandenen `for`-Schleifen liegen in @test-Rümpfen, nicht in Helfern) | — |

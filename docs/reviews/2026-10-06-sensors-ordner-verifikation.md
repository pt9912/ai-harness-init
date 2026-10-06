# Verifikation slice-sensors-ordner-entsteht-im-ziel

Rolle Verifier, Range `cab136a5..974f1430`, Bezug ADR-0054 Festlegung 1, LH-FA-01. Host-Binary aus
`make host-bin`, Ziele in einem Scratch-Verzeichnis außerhalb des Repos.

- **DoD 1 (Emitter + Test, rot gesehen): bestätigt.** `--lang cpp --arch hexslice` und ohne `--lang`: je
  Exit 0, `harness/sensors/.gitkeep` 0 Byte, Modus 644, nach `git add -A` in `git ls-files`; keine
  `.gitignore` emittiert. Zweiter Lauf gegen Adopter-`.gitkeep` (`mine`) und `foo.md`: beide
  unverändert, Meldung `harness/sensors/.gitkeep liegt bereits — die Datei bleibt unberuehrt
  (skip-if-present).` Rot an der realen Quelle (`internal/emit/enforce.go`): Eintrag gestrichen →
  `make test-go` EXIT 2, allein `TestEnforce_SensorsOrdnerEntstehtMitSeinemTraeger` mit
  `harness/sensors/.gitkeep entsteht nicht: stat …: no such file or directory`; Klasse auf
  `Konvergent` → derselbe Test rot mit `Klasse konvergent, verlangt skip-if-present` und `der zweite
  Lauf ueberschrieb den belegten Pfad: ""`. Zurückgesetzt, `git status --short` leer.
- **DoD 2 (full-smoke-Stufe, Abdeckungs-Sicht): bestätigt.** Eintrag gestrichen → `make
  full-smoke-host` EXIT 2 nach 130 s, erste und einzige `FEHLER`-Zeile `Sensors-Ordner:
  harness/sensors/.gitkeep entsteht im Ziel NICHT …`. `make e2e-abdeckung` EXIT 0, `cmp` gegen den
  committeten Stand byte-gleich; Zeile `LH-FA-01 … Stufe 20` nennt Gemessenes und `NICHT gemessen:`
  am selben Ort.
- **DoD 3 (Grenze am Ort): bestätigt** — Kopfkommentar `internal/emit/templates.go` (`GRENZE
  harness/sensors/`) und Kommentar am Eintrag in `enforce.go`. **Abgrenzung §1: eingehalten** — der
  Diff berührt weder ein `targets`-Modul noch eine `structure`-Regel; die emittierte `.d-check.yml`
  trägt unter `structure:` allein `files: "harness/README.md"`.
- **Offener Punkt (Lücke, vom Plan nicht genannt) — die INFO des Reviews, gemessen.** Adopter-`.gitignore`
  mit `*.gitkeep`, `.gitkeep` oder `harness/sensors/` (je eigenes Ziel, `--lang go`): Bootstrap EXIT
  0 und schweigt dazu, die Datei entsteht, `git check-ignore -v` nennt die Regel, nach `git add -A`
  ist `git ls-files harness/sensors` leer, `git add -- harness/sensors/.gitkeep` EXIT 1. Ein Klon
  dieses Ziels trägt den Ordner nicht; die Zusage „der Verweis zeigt auf einen vorhandenen Ort" gilt
  dort nur für die Arbeitskopie. Weder §6 des Plans noch die Deklaration der Stufe nennen diese Klasse.
  An den Planner: als Beleg zu `BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht`
  oder als Grenze in die Deklaration (dann Architect/Implementer-Folge, nicht Closure).
- **DoD 4 (`make gates`):** einmal am Ende über diesem Bericht gefahren; Ergebnis steht in der
  Commit-Message. DoD 5 (Review) liegt vor; DoD 6–9 sind Closure-Arbeit des Planners, nicht Gegenstand.

# `make comment-claims` — Kommentar-Behauptungen nennen ihren Sensor

## Vertrag

Kommentar-Behauptungen (`AGENTS.md` §3.6) nennen ihren Sensor, und der genannte Test
existiert — hermetisch (bash+awk), kein Docker, kein Netz.

## Grenze — was das Grün nicht abdeckt

**Was `comment-claims` nicht deckt — benannt, weil eine Vollständigkeits-Zeile („N Datei(en) geprueft, 0 Befund(e)") sonst mehr behauptet als sie trägt** (Review-Befund HIGH-1 vom 2026-07-30; die hier zuerst stehende Zählung „an **zwei** Stellen" war selbst zu eng und ist in Runde 2 korrigiert worden): der Prüfbereich entsteht im Rezept aus `git ls-files` und ist an **drei** Stellen enger als der Gate-Stempel, den `record-gates` über den Arbeitsbaum legt (`harness/tools/working-tree-hash.sh`: `--cached --others --exclude-standard`).

1. **Nur der Index.** `git ls-files` ohne `--others`: eine neu angelegte, noch **untrackte** Datei liegt innerhalb des bestätigten Baum-Zustands und außerhalb des Prüfbereichs — sie wird erst nach ihrem ersten `git add` geprüft.
2. **Nur vier Pfad-Muster** — `internal/**/*.go`, `cmd/**/*.go`, `harness/tools/*.sh`, `.claude/hooks/*.sh`. Dauerhaft draußen liegen damit u. a. `Makefile`, `harness/tools/*.awk`, `internal/emit/templates/`, `test/`, `.codex/`, `.github/` und **jede** Markdown-Datei.
3. **Test-Dateien ausgenommen** (`_test.go`) — ein Kommentar dort behauptet keine Abdeckung, sondern *ist* eine.

**Nur (1) heilt ein `git add`; (2) und (3) sind permanent.** Wie groß der Ausschnitt ist, sagt der Gate in seiner letzten Zeile selbst (am 2026-07-30: 38 Dateien, 19 Go + 19 Shell); wie groß der Stempel ist, sagt `git ls-files --cached --others --exclude-standard`. **Eine eingefrorene Gegenüberstellung steht hier bewusst nicht** — sie wäre beim nächsten Commit falsch, dieselbe Falle wie bei der Span-Zählung in [`spec/spezifikation.md`](../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5. Wer eine Datei **in einem der vier Muster** neu anlegt und ihre Zusagen gedeckt sehen will, lässt den Gate **nach** dem `git add` laufen; wer eine `harness/tools/*.awk`, ein `Makefile`-Rezept oder eine Vorlage unter `internal/emit/templates/` schreibt, bekommt **gar keine** Prüfung — dort trägt allein das Review.

**Ein zweites, gemessenes Loch derselben Klasse — hier benannt, nicht nebenbei geschlossen:** die Negations-Ausnahme in `harness/tools/comment-claims.sh` lässt einen Satz durch, der eine Abdeckung *verneint*; ihr Fenster ist zwölf Zeichen breit. Ein Lauf über das (außerhalb liegende) `Makefile` meldet genau einen Treffer, und dort stehen zwischen „belegte" und „nicht" **dreizehn** Zeichen — die Ausnahme verfehlt ihn um ein Zeichen. Ob das Fenster weiter gehört oder der Satz umgeschrieben, entscheidet der Slice, der den Mechanismus anfasst.

Der Mechanismus selbst ist hier **nicht** geändert (Gate-*Anheben* ist ein Steering-Loop nach [`MR-001`](../conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids), und er betrifft jede künftige neue Datei, nicht die Telemetrie) — er wartet auf einen eigenen Schnitt.

## Bindung

[`AGENTS.md`](../../AGENTS.md) §3.6; Bestandteil von `make gates`.

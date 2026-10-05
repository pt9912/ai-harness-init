# Review — slice-emittierte-archivierung-kennt-den-altbestand

Gegenstand: Commits `7960691e`, `68514cc7`, `11487d06` (seit `a77606ea`). Bezug: ADR-0041, ADR-0033, ADR-0058, AGENTS.md §3.6/§3.7.

## Findings

1. **LOW** · quelle: ADR-0041 / AGENTS.md §3.6 (Zusage) · pfad: `internal/emit/templates/commands/close-welle.md:91-94` · befund: Der Satz endet mit "dann bleibt der Altbestand, wo er ist". Am gepinnten Träger v0.2.6 gilt für einen Welle-Schlüssel ohne `done/*/archiv.zip` weiter `[untergrenze]` (`git show v0.2.6:internal/archive/vorschau.go`, `welleGebunden` → `untergrenzeSperre`), während der Schlüssel `altbestand` mit `[kein-schreib-pfad]` abgewiesen wird. Die erste Wellen-Archivierung bleibt damit ebenfalls gesperrt; der Text nennt nur die Hälfte. · verifizierbar: ja (Lesen gegen `git show v0.2.6:internal/archive/{vorschau,collect}.go`) · klasse: emittierte Zusage nennt den Ausgang nur zur Hälfte.

## Geprüft, ohne Befund

- (a) Emittierter Text gegen v0.2.6: `[kein-schreib-pfad]` steht in Fragment-Kopfkommentar und close-welle Schritt 4; v0.2.6 führt die Sperre (`git show v0.2.6:internal/archive/vorschau.go`, Kennung `kein-schreib-pfad`), "ohne --vorschau" passt dazu; kein Schreibpfad-Versprechen. (Finding 1 betrifft nur die Vollständigkeit des Ausgangs.)
- (b) Fälle 509–513: `MUTATE_CASES='509-… 513-…' make mutate` → `5 ok, 0 Befund(e)`; jeder Fall trifft genau sein Muster (sed-Anker gegen Quelle gemessen: `[untergrenze]`, `[kein-schreib-pfad]`, `WELLE=altbestand` je Treffer in der Zieldatei vorhanden; 509 trifft nur die `archive-welle:`-Zeile, der Kommentar bleibt, Test liest die Hilfezeile). Kein Kopf behauptet Exklusivität. Die volle `t.Skip`-Gegenprobe ist nicht gefahren; die drei Fälle 511–513 färben denselben Test an verschiedenen Begriffen, ein Mitfärben durch einen zweiten Test ist nicht untersucht.
- (c) Stufe `archivierung_im_ziel`: Schritt (e) liest Ausgabe `archive-welle ok: altbestand` (Quelle: `internal/archive/anwenden.go:196`) und `altbestand/archiv.zip`; Deklaration `LH-FA-01 LH-QA-01` und Teilmessung (synthetischer Bestand, Träger aus Arbeitsbaum) stehen im selben Text und in `docs/user/e2e-abdeckung.md` (Stufe 4). Nicht gefahren: die Stufe selbst (Docker) und der DoD-Rot-Beleg (`WELLE=altbestandd`) — beides bleibt Verifier-Aufgabe.
- (d) Abweichung `slice-997-altbestand`: trägt; `slice-998-ohne-welle` wird in Schritt (b) per `git rm` entfernt (`full-smoke.sh:1639`), der Plan-Name wäre zum Zeitpunkt von (e) nicht mehr vorhanden.
- (e) `harness/sensors/archive-welle.md` unberührt (`git diff --stat a77606ea..HEAD -- harness/sensors` leer).
- Regeln: §3.7 Kommentare (Zusage/Kopplung, keine Chronik), §3.9 (keine Host-Toolchain), `TestCommands_NoInternalLeak` (Binärname nicht genannt) ohne Befund; Gate-Lauf siehe unten.

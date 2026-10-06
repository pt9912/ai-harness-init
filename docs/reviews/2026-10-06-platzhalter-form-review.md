# Review — slice-emittierte-commands-tragen-die-platzhalter-form-kennung

Rolle Reviewer · Diff `7d5d1755..18b7ced6` · Bezug MR-057, MR-059, MR-071, AGENTS.md §3.6/§3.7

## Findings

- **INFO** · MR-057 · `internal/emit/templates.go:505,522` · Der Ersatztext von `NeutralizeRoadmap` (`` `welle-NN-results.md` ``) geht ins Ziel und trägt eine Nummernform; er liegt ausserhalb von `emit.CommandPaths()`, der Wächter sieht ihn nicht. Abgrenzung des Plans (`roadmapDoneLink` unberührt) deckt das; benannt, nicht geändert. verifizierbar: ja (grep). klasse: emittierte Nummernform ausserhalb der Commands.
- **INFO** · §3.7 · `implement-slice.md:47-48` · Der Text bleibt wahr: `patterns=` steht in `internal/emit/templates/enforce/commit-msg-traceability.sh:60` (Zielpfad `tools/harness/commit-msg-traceability.sh` = `CommitMsgCheckPath`), dort `slice-[0-9]+`. Er sagt nur „vollständige Menge steht dort", nicht, dass ein benannter Slice kein Muster trifft; das ist nicht falsch, aber ein Adopter liest den Fall nicht ab. verifizierbar: nein. klasse: Zusage nennt Menge, nicht deren Grenze.

## Geprüft, ohne Befund

- (a) Vollständigkeit: `grep -rnE '(slice|welle)-(<N+>|N+\b|<NN)|<(slice|welle)-N' internal/emit` ausserhalb `_test.go` trifft nur Go-Kommentare (`templates.go:519,768`, nicht emittiert), `roadmapDoneLink` (s. o.) und `slice-mv.sh:162` (beschreibt ein Fundmuster, lehrt keine Form).
- (b) siehe zweites INFO; Pfad und Muster gegen `commitmsg.go:25` und das Skript gemessen, nicht angenommen.
- (c) Regex `\b(slice|welle)-(<N+>|N+\b)` fängt `slice-<NN>`, `welle-<NNN>`, `slice-N`; erlaubt `MR-<NNN>`, `slice-<Kennung>`, `slice-[0-9]+`. Kein Fehlalarm: Test grün auf HEAD. `make mutate` Fälle 518 und 519: 2 ok, 0 Befund. Gegenprobe 519 mit Mutation angewandt und `t.Skip` ausschliesslich im Wächter: `make test-go` EXIT 0, also bindet der Wächter allein, kein zweiter Test färbt mit. sed-Anker beider Fälle trifft den Quellbestand (beide rot gesehen), MR-071 erfüllt.
- (d) Kommentar von `TestCommands_NoInternalLeak` im Indikativ, Zeiger auf den Wächter, keine Chronik.
- (e) Hook-Muster, `slice-mv.sh`, `roadmapDoneLink`, `<welle-id>`/`<welle-NN-titel>` unberührt (Diff-Stat: 7 Dateien, keine davon).

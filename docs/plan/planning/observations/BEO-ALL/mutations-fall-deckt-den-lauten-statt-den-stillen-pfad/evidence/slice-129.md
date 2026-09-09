**Vorgang:** slice-129
**Fund:** Die Begründung von `test/mutations/288-closure-dir-anderer-pfad.sh:8` behauptete, ein auf
`docs/plan/planning/open` umgebogenes `closure.dir` prüfe den falschen Bestand *„ohne das je zu
melden"*; gemessen meldet derselbe Lauf **45** `closure-note-thin` und endet mit EXIT 1 — der Fall
mutiert also den **lauten** Pfad und trägt eine Zusage über einen stillen, den er nie berührt. Der
Wächter besteht, weil die im `# expect:` genannte Zusicherung ohnehin rot wird; dass die Begründung
daneben eine andere Fehlerrichtung behauptet, sieht `make mutate` nicht, und `test/` liegt
dauerhaft außerhalb von `make comment-claims` (HIGH-1 der zweiten Review-Runde). Der Review führt
die Klasse als *dritte Sitzung in Folge* nach `slice-125` F-1; als **Vorgang** ist es das zweite
Auftreten, denn drei Runden über demselben Slice sind eine Gelegenheit.

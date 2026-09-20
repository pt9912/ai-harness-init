# Wortgleiche Commit-Message für Arbeit und Nachzug-Fix

**Sub-Area:** `*` (gesamtes Repo)

Ein Implementer-Lauf committet Arbeit, findet kurz danach im selben Lauf einen Fehler darin und
committet den Fix mit derselben Commit-Message-Betreffzeile wie den ursprünglichen Commit —
`git log --oneline` unterscheidet Arbeit und Nachzug-Korrektur dann nicht, obwohl der zweite
Commit inhaltlich ein Fix des ersten ist. Kein Gate prüft Commit-Message-Eindeutigkeit über
aufeinanderfolgende Commits.

## Benannt, nicht gezählt

Zwei weitere Fälle mit wortgleicher Betreffzeile aufeinanderfolgender Commits stehen bereits in
der Repo-Historie (`3d818d90e0`/`1d8c0081d4`, `2f82b4666f`/`d7fd8227b6`,
`787f7e8a7c`/`94f25525`), keiner davon wurde beim jeweiligen Slice-Closure als Beobachtung
eingetragen — sie bekommen darum keine nachträgliche Evidence-Datei (`slice-mv.sh`
§Bedienhinweis: keine Belege erfinden), sind aber der Beleg dafür, dass die Klasse wiederkehrt.

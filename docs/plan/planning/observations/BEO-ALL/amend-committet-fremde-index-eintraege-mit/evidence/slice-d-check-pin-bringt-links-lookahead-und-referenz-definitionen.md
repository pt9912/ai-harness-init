**Vorgang:** slice-d-check-pin-bringt-links-lookahead-und-referenz-definitionen
**Fund:** Der Architect wollte den eigenen letzten Commit (Zeile-136-Fix) um die anchors.go-Ergänzung
erweitern (`git commit --amend`) — dazwischen hatte der Reviewer bereits die Nachrunde committet, HEAD
stand also auf dessen Commit, nicht mehr auf dem eigenen. Der Amend traf den fremden Reviewer-Commit:
dessen Inhalt verschwand als eigener Punkt, ersetzt durch die Architekt-Message. Selbst über das
Reflog aufgedeckt und vor dem Push repariert — `git reset` auf den Stand vor dem Reviewer-Commit,
danach den eigenen Fix als frischen Commit und den Reviewer-Commit erneut gesetzt. Am Reflog
nachfahrbar (vor einem späteren, unabhängigen `filter-branch`, der die Hashes der ganzen Kette
bewegt hat):

```sh
git reflog | grep -B1 -A2 'commit (amend).*anchors.go ergaenzt'
# … commit: Rolle Reviewer: Nachrunde MR-073 …          <- fremder Commit, lag zwischen
# … commit (amend): Rolle Architect: … anchors.go …     <- traf den fremden Commit statt des eigenen
# … reset: moving to HEAD^                              <- Reparatur vor dem Push
# … commit: Rolle Architect: … anchors.go …              <- sauberer Neu-Commit
# … commit: Rolle Reviewer: Nachrunde MR-073 …           <- Reviewer-Commit erneut gesetzt
```

Dritter Beleg dieser Beobachtung (nach der Konsistenz-Review vom 2026-09-15 und
`slice-174-archivierung-emittieren`) — 3× erreicht.

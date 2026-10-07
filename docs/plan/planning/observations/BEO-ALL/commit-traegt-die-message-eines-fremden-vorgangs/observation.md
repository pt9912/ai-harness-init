# Commit trägt die Message eines fremden Vorgangs

**Sub-Area:** `*` (gesamtes Repo)

Ein Commit trägt Inhalt des eigenen Vorgangs unter einer Message, die wortgleich die eines früheren
Commits eines anderen Vorgangs ist — Betreff, Rumpf und Kennung beschreiben fremde Arbeit.
`git log` ordnet den Inhalt damit dem falschen Vorgang zu; die Commit-Kennungs-Träger
(`.githooks/commit-msg`, PreToolUse-Zusatz) prüfen nur die Anwesenheit einer Kennung, nicht ihre
Zugehörigkeit, und lassen ihn durch.

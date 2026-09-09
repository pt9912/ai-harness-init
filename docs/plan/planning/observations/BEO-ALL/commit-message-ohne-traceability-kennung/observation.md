# Commit-Message ohne Traceability-Kennung

**Sub-Area:** `*` (gesamtes Repo)

Eine Commit-Message nennt weder eine `LH-*`- noch eine `ADR-*`-Kennung, obwohl
[`AGENTS.md`](../../../../../../AGENTS.md) §5 und
[`harness/README.md`](../../../../../../harness/README.md) §Traceability beides verlangen. Die Regel
ist in ihrer **Bezugseinheit** nicht eindeutig — *„PRs/Commits"* liest sich als *jeder Commit* wie
als *die Änderung als ganze* —, und der Verstoß ist nach einem Push nicht mehr behebbar, ohne
Historie zu schreiben.

Die Fehlerrichtung ist *die Spur trägt*: Die Message nennt meist Slice und Report, die Kette reißt
nicht ab, nur die Kennung fehlt, an der ein Sensor sie fassen könnte.

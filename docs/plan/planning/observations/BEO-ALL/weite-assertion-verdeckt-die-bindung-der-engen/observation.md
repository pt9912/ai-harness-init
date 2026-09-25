# Weite Assertion verdeckt die Bindung der engen

**Sub-Area:** `*` (gesamtes Repo)

Ein `bats`-Fall hält **eine** Ursache mit zwei Assertions verschiedener Weite, und die weite fängt
jede Mutation ab, die die enge fangen soll. Die enge Zusage ist damit durch die weite verdeckt: rot
wird der Fall so oder so, und die Gegenprobe, die nur die enge Assertion löscht, bleibt rot, weil die
weite anschlägt. Ob die enge etwas bindet, ist am Fall einzeln nicht ablesbar.

## Benannt, nicht gezählt

[`mutations-fall-nennt-einen-test-die-mutation-faerbt-mehrere`](../mutations-fall-nennt-einen-test-die-mutation-faerbt-mehrere/observation.md)
ist dieselbe Ursache eine Ebene höher: dort färbt die Mutation **zwei Tests** rot, hier zwei
Assertions **eines** Tests.

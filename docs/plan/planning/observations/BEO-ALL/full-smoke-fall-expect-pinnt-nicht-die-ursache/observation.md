# `# expect:` eines `full-smoke`-Falls pinnt die Ursache nicht

**Sub-Area:** `*` (gesamtes Repo)

Der Fall nennt in seinem Kopf eine Ursache (hier `wrong-direction`), sein `# expect:` ist aber der grobe
Satz der Stufe („make gates … NICHT Exit 0"); die Meldung der Stufe trägt die Fundstelle nicht. Das Rot ist
gesehen, die Ursache steht nur in einer Handprobe
([`AGENTS.md`](../../../../../../AGENTS.md) §3.6: das Rot muss die behauptete Ursache tragen). Nachbar:
`fall-kopf-nennt-andere-ursache-als-die-rote-stelle` — dort ist die Prosa falsch, hier stimmt sie und ist
nur nicht gepinnt.

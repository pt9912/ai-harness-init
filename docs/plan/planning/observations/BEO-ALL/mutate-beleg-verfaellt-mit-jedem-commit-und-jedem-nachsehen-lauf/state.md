**Stand:** gestrichen

Die Beobachtung kann in der beobachteten Form nicht mehr auftreten: kein Rollen-Lauf erzeugt oder
braucht den Beleg-Slot von `make mutate`. Ein Teillauf (`MUTATE_CASES`) liest, schreibt und löscht ihn
nie, der Vollsweep läuft als Teilläufe je Shard (`grep -n 'MUTATE_CASES' .github/workflows/mutate.yml`),
ein lokaler Vollauf verlangt `MUTATE_FORCE=1`, und kein Anweisungssatz führt den vollen Lauf als
Rundenpflicht (`grep -ln 'make mutate' .claude/commands/*.md .claude/agents/*.md`). Der Slice, der den
Ausgang `geplant` trug, ist mit diesem Grund entfallen
(`slice-mutate-beleg-gilt-ueber-rollen-dokumente-und-ist-ohne-lauf-lesbar` §7).

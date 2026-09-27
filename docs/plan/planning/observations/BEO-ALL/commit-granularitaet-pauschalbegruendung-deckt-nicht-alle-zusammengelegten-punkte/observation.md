# Eine Commit-Begründung für zusammengelegte DoD-Punkte trägt nicht für jeden von ihnen

**Sub-Area:** `*` (gesamtes Repo)

Ein Commit legt mehrere DoD-Punkte zusammen und begründet das pauschal (z. B. „geteilter
switch-Block"). Trifft die Begründung nur für einen Teil der zusammengelegten Punkte zu — ein
anderer sitzt in einem eigenen, unabhängig testbaren Codeblock mit eigenem Test und eigenem
Mutations-Fall —, deckt die Begründung mehr, als sie darf. Modul 5 stellt die
Commit-Granularität pro DoD-Punkt ausdrücklich ins Ermessen; das macht eine pauschale Begründung,
die für alle behauptet, was nur für einen Teil gilt, nicht falsch im Sinne einer Hard Rule, aber
ungenau.

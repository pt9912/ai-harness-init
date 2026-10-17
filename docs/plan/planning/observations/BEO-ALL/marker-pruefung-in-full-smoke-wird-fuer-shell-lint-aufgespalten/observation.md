# Marker-Prüfung in `full-smoke` wird für `shell-lint` aufgespalten und lockert die Ko-Okkurrenz

**Sub-Area:** `*` (gesamtes Repo)

Eine Marker-Prüfung in `harness/tools/full-smoke.sh`, deren Einzelquote-Muster einen Backtick enthält,
färbt `make shell-lint` mit SC2016 rot. Die Behebung ohne Suppression ([`AGENTS.md`](../../../../../../AGENTS.md)
§3.2) teilt die Prüfung in mehrere `grep -qF` auf; die Teile müssen dann nicht mehr aus derselben Zeile der
Ausgabe stammen, die Ko-Okkurrenz ist gelockert (Python-Stufe, F401-Marker).

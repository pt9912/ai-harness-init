**Vorgang:** slice-agent-watch-sh-wird-verankert
**Fund:** Der Melder `harness/tools/agent-watch.sh` bekommt eine Verankerung (Makefile-Ziel,
`kein Gate`-Marke, README-Zeile), bewusst ohne funktionalen Test — Plan §3 begründet den
Verzicht mit dem Werkzeug-Charakter (Dauerschleife ohne Exit-Code-Urteil). Ob der Melder
Speicherverbrauch richtig misst und rechtzeitig meldet, bleibt ungeprüft; nur die
Doku-Konsistenz seiner Verankerung ist ab jetzt bewacht.

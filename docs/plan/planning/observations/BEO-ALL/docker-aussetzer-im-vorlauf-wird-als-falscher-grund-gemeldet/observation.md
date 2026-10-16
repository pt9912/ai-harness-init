# Ein Docker-Aussetzer im Vorlauf eines Mutations-Falls wird als „falscher Grund“ gemeldet

**Sub-Area:** `*` (gesamtes Repo)

Fällt der Vorlauf eines `# verify: full-smoke`-Falls an einem Docker-/colima-Aussetzer (`ERROR: failed to build: … rpc error: code = Unavailable … EOF` in `make artifact-host`), ordnet `make mutate` das Rot als BEFUND „falscher Grund“ ein, obwohl weder der Fall noch der geprüfte Code etwas damit zu tun haben; ein Wiederholungslauf desselben Falls ist grün. Der Treiber trennt einen Umgebungsfehler des Vorlaufs nicht von einem falschen Grund des Falls; die Meldung verfälscht den Befund, den ein Lauf sichtbar machen soll.

## Benannt, nicht gezählt

Der Anlass im Plan von `slice-roter-gruen-vorlauf-des-mutate-treibers-zeigt-sein-log` (§1, §6) ist derselbe lokale Lauf wie der Beleg und zählt nicht zweimal. Fall 171 „scheiterte an den Vortagen mit falscher Grund“, vermutlich dasselbe Muster, ungemessen — ohne abgeschlossenen Vorgang kein Beleg. Nachbar: `paralleler-mutate-lauf-verliert-das-image-eines-workers` (anderes Symptom `No such image`, andere Ursache am Image-Tag).

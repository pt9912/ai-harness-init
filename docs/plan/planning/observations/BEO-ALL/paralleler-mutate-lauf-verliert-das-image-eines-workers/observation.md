# Paralleler make mutate verliert das Docker-Image eines Workers

**Sub-Area:** `*` (gesamtes Repo)

Die Worker von `make mutate` bauen im Grün-Vorlauf (`make test-go` in der Kopie) dasselbe Image-Tag `ai-harness-init:test`. Verschiebt ein Worker das Tag, verschwindet das Image, auf das die `.iid`-Datei eines anderen Workers zeigt; dessen Grün-Vorlauf endet mit `docker: Error response from daemon: No such image: sha256:…` (`test-go` Error 125), noch bevor die Mutation angewandt ist. Folge: ein Mehrfach-Lauf liefert nicht alle Ergebnisse (Worker-Status 3/3/3/1, 3 von 5 Fällen), ohne dass ein Fall rot oder falsch rot wird. Ob nur der lokale Image-Speicher (Colima) betroffen ist oder auch CI, ist ungemessen.

**Benannt, nicht gezählt:** ein einmaliger „falscher Grund“ für Fall 111 im Fünfer-Lauf des Implementers — weder reproduziert noch widerlegt, ohne Vorgang-Beleg.

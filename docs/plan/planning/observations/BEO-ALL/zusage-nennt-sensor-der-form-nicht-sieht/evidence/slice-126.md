**Vorgang:** slice-126
**Fund:** Der Kopf von `.claude/hooks/pretooluse-commit-msg-guard.sh` sagte zu, **jeden**
`git commit … -F <datei>`-Aufruf nach `make commit-msg-check` zu spiegeln. Gemessen hielt der
Matcher darunter fünf dieser Formen nicht: den Pfad in einfachen und in doppelten
Anführungszeichen, die Lang-Formen `--file` und `--file=` sowie das kombinierte Kurz-Flag (`-qF`).
Der genannte Geltungsbereich war damit weiter als der Code, und zwar in der Richtung, die still
bleibt — ein nicht erkannter Aufruf erzeugt keinen Befund, sondern keinen Lauf. Erst die zweite
Review-Runde verbreiterte den Matcher auf die zugesagte Menge.

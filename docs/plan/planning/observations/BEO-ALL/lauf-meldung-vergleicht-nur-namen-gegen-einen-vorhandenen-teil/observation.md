# Lauf-Meldung vergleicht nur Namen gegen einen vorhandenen Teil

**Sub-Area:** `*` (gesamtes Repo)

Die Meldung neuer Targets im Bootstrap und in `add-lang` vergleicht die Target-Namen des neu
geschriebenen Werkzeug-Teils mit denen des vorigen. Ein umbenanntes Target erscheint darum als neu,
das alte verschwindet ohne Zeile; und fehlt ein voriger Teil (Ziel aus einer älteren
Werkzeug-Fassung), nennt der Lauf nur die Zahlen-Zeile, auch wenn er ein neues Gate mitbringt.
Beide Ränder nennt das Benutzerhandbuch; kein Lauf hebt sie hervor.

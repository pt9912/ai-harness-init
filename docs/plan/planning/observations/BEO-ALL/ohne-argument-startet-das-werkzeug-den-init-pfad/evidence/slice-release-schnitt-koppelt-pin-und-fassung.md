**Vorgang:** slice-release-schnitt-koppelt-pin-und-fassung

**Fund:** Der Bootstrap-Unfall: Ein Aufruf des Trägers ohne Argument fiel in
den Init-Pfad und fuhr einen Bootstrap-Lauf gegen das Repo, in dem er steht.

**Klasse:** Der Dispatch führt seine Unterkommando-Fälle und keinen
Default-Zweig — ein Aufruf ohne Argument startet den Init-Pfad still, statt
laut abzuweisen. Der laut-Bruch von
[`ADR-0058`](../../../../../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md)
Festlegung 2 deckt ein **unbekanntes** Unterkommando, nicht das **fehlende**
Argument: Die Schadensvektor-Lücke bleibt auch nach `v0.2.0` offen.

**Schaden:** Konvergente Makefile-Ersetzung — die konvergenten Dateien wurden
umgeschrieben, Strays blieben liegen. Die beschädigte Makefile-Fassung ist im
Pin-Commit committet und trägt den Release-Tag `v0.2.0`.

**Reparatur:** Commit `e34ef1de`, append-only über dem Tag-Grund, kein
Force-Push.

**CI-Lage:** Beide Pushes nach dem ersten rot — der Zwischenstand wurde nicht
zur Spitze eines geprüften Push.

**Lage:** Der Vorgang läuft; seine Position im Planning-Lifecycle liest der
Lauf, der diesen Beleg bei der Closure gegen `done/` prüft — die Lage-Prüfung
läuft nach dem Move, der Beleg beansprucht sie hier nicht.
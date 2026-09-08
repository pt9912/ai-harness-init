# Vorhandene Fähigkeit ohne Träger wird von Hand nachgebaut

**Sub-Area:** `*` (gesamtes Repo)

Ein Lauf führt einen Vorgang von Hand aus, obwohl das Repo den Weg dafür bereits als Fähigkeit
führt — der Code kann es, nur ruft ihn für diesen Fall kein `make`-Ziel und kein Unterkommando.
Die Fehlerrichtung ist *es gibt keinen Weg*, während der Befund *der Weg hat keinen Einstieg*
lautet: Die Handarbeit liefert ein Ergebnis, das der Träger anders erzeugt hätte, und niemand
vergleicht die zwei.

## Benannt, nicht gezählt

Zwei Nachbarklassen tragen den Fall nicht.
[`aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand`](../aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand/observation.md)
spricht über das **gepinnte Fremd-Werkzeug**; hier liegt die Fähigkeit im eigenen Code.
[`vendored-baum-entsteht-aus-anderer-quelle-als-sein-pin`](../vendored-baum-entsteht-aus-anderer-quelle-als-sein-pin/observation.md)
spricht über die **Bytes eines bestimmten Baums**; diese Klasse sagt etwas Weiteres voraus — ein
Lauf kann jede Fähigkeit dieses Repos von Hand nachbauen, ohne den vendored Baum zu berühren.

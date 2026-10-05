# `make tap-check` — hält die Formel im Tap gegen das Asset des Tags

## Vertrag

hält die Formel am Kopf des Default-Branch des Tap byte-genau gegen das Asset des Tags (`TAG=<tag>`): Exit des Skripts 0 gleich oder Vorab-Tag, 1 Formel-Unterschied auch nach dem zweiten Lesen, 2 nicht ausführbar — `make` selbst endet bei jedem Fehlschlag mit 2, und die Klasse des Skripts steht in der letzten stderr-Zeile **des Skripts** `tap-check: Exit <N>` (bei Exit 0 fehlt sie; sie ist der Vertrag, die Ziffer in der Meldung von `make` nennt die Klasse ebenfalls, ihr Wortlaut hängt an der Locale; bei `make tap-check` aus dem Wurzelverzeichnis ist die Zeile die vorletzte der Ausgabe, unter `-C` oder einem umschließenden `make` folgen weitere Zeilen; nicht zugesagt bei Signal — dort fehlt auch die Klasse, der Prozess-Exit ist 128 plus die Signalnummer, wenn das Signal das Skript im Direktaufruf oder `make` selbst trifft, und 2, wenn es das Skript unter `make` trifft —, nicht beschreibbarer stderr — dort ist auch die Klasse nicht zugesagt, ein Formel-Unterschied kann als Klasse 2 enden — und fehlendem oder unbekanntem Modus); lesend, Transport im gepinnten Bild, braucht Netz an genau diesem Aufruf


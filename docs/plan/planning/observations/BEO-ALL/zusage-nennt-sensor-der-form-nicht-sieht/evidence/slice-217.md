**Vorgang:** slice-217
**Fund:** Ein Vorgang zählt einmal; dieser Beleg trägt **drei** Funde derselben Klasse an demselben
neuen Wächter [`test/doc-block-marke-wiring.bats`](../../../../../../../test/doc-block-marke-wiring.bats).

*Zweimal an der Ausgabe-Hälfte, in zwei Runden hintereinander.* Die Zusage in
[`harness/sensors/doc-structure.md`](../../../../../../../harness/sensors/doc-structure.md) sagt,
die Marke stehe **als letzte Zeile** der eigenen Ausgabe, und nennt diesen Wächter als den Träger,
der das hält. Er maß jeweils eine schwächere Eigenschaft: erst **Anwesenheit** statt Position —
eine Nachpflege, die das `@echo` **vor** den `docker run` setzt, blieb grün (Runde 1) —, danach
**Position ohne Form**: jede Rezept-Zeile, die das Literal als Teilstring trug, zählte, also auch
ein `@:`-No-op oder ein an die `docker run`-Zeile angehängter `#`-Kommentar, die beide nie etwas
ausgeben (Runde 2). Beide Male stand die Zusage unverändert daneben. Alle drei Lagen färben heute
rot, gemessen über Kopien außerhalb des Repos gegen dieselbe Verdrahtung (die bats-Datei im
gepinnten `BATS_IMAGE`, netzlos, Mount `:ro`); die unveränderte Kopie bleibt grün.

*Einmal an der Bezugsmenge, und dieser Fund steht offen.* Die Zusage nennt die Menge, über die der
Wächter urteilt, *„die C-Klasse"*, und definiert sie als *Modul zugeschaltet, kein Top-Level-Block
dafür*. Gemessen wird davon ein engerer Ausschnitt: das Modul muss **per `--enable`** zugeschaltet
sein (ein anderer Zuschalt-Weg fällt aus der Menge, ohne dass ein Lauf davon spricht), und
*Top-Level-Block* wird als `grep -qE "^<modul>:"` gelesen — also Anwesenheit eines Schlüssels, nicht
Wirksamkeit eines Prüfbereichs. Beide Verengungen sind heute folgenlos, weil jedes der Ziele in
[`d-check.mk`](../../../../../../../d-check.mk) sein Modul per `--enable` zuschaltet und jeder
Block einen Aktivierungs-Schlüssel trägt; benannt ist keine von beiden — weder im Kopf des
Wächters noch neben der Zusage.

Die verbleibende, **benannte** Grenze steht dagegen ausdrücklich unter der Zusage: Bricht
`docker run` mit einem Befund ab, erreicht `make` das `@echo` nie, und kein hermetischer Test sieht
das.

**Vorgang:** slice-224
**Fund:** Der Delta-Nachweis zählt Posten auf der **Datei**-Ebene — 42 Zeilen für die 42 Dateien,
die `git diff --name-only v6.0.0..v6.7.2 -- lab/regelwerk/ lab/templates/` ausgibt — und gibt je
Zeile **eine** Antwort. Eine Datei trägt aber mehrere unabhängige Positionen:

```sh
cd /Development/KI/ai-harness-course
diff <(git show v6.0.0:lab/regelwerk/modul-02-harness-bootstrap.md | sed 's/[[:space:]]\+/ /g; s/ *| */|/g') \
     <(git show v6.7.2:lab/regelwerk/modul-02-harness-bootstrap.md | sed 's/[[:space:]]\+/ /g; s/ *| */|/g') \
  | grep -c '^[0-9]'
# 3 — drei unabhängige Hunks (Zeile 148, 156, 397)
```

**Kein Erwartungswert** ([`MR-025`](../../../../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Die Zelle beschrieb einen davon — die Anker-Umbenennung in Zeile 397 — und nannte die
zwei anderen nicht; die beiden tragen die Gate-Index-Konsequenz, die andere Zeilen der Tabelle
ausdrücklich an einen Folge-Slice adressieren. Die **Antwort** der Zelle hält, der **Beleg** hielt
nicht, und die Vollständigkeits-Zusage von DoD-1 konnte das nicht merken: Sie zählt Dateien, und
die Datei war gezählt.

Die Klasse ist damit an derselben Zusage doppelt belegt — einmal als Ebenen-Fehler und einmal als
Beleg-Fehler; gezählt wird sie hier als der Ebenen-Fehler, den DoD-1 trägt. Den Beleg-Fehler führt
[`beleg-filter-entfernt-die-zeilenklasse-die-den-beleg-traegt`](../../beleg-filter-entfernt-die-zeilenklasse-die-den-beleg-traegt/observation.md)
als eigene Klasse: Ein Nachweis auf Hunk-Ebene wäre auch mit dem blinden Filter blind geblieben,
und ein tragfähiger Filter hätte die Datei-Ebene nicht geheilt.

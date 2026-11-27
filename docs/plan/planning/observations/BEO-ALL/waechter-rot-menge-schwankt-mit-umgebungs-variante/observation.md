# Wächter-Rot-Menge schwankt mit Umgebungs-Variante des Laufs

**Sub-Area:** ALL (gesamtes Repo)

**Kurzbeschreibung:** dieselbe Wächter-Datei liefert einzeln gefahren und im
vollen Sweep verschiedene Rot-Mengen, und dasselbe Wächter-Prüfmuster liefert
am selben Host je Werkzeug-Semantik verschiedene Urteile (PATH-/Env-Verschleppung
aus früheren Setups des Bats-Sweeps; `sort`/`comm`-Collation-Divergenz im
Ambient-`en_US.UTF-8`; `awk`-Byte-/Zeichen-Semantik je Locale; Werkzeug-Rest
am opt-in Image-Weg, das `make`/`git` nicht trägt). Der Wächter misst in diesen
Fällen den Ausführungsort, nicht mehr den Prüfgegenstand.

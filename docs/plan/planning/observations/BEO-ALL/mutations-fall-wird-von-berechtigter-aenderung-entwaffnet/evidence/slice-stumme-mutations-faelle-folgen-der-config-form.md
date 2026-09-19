**Vorgang:** slice-stumme-mutations-faelle-folgen-der-config-form

**Fund:** Der Zensus über alle 365 Fälle fand die drei Bestand-Fundstellen
(29, 275, 114 — ihre sed-Muster treffen den Quell-Bestand nicht mehr: die
Quelle trägt die neuen Fassungen, `internal/emit/templates.go:414`/`:428` und
kein `Rmdir` in `internal/span/emit.go`); dynamisch im Wegwerf-Klon meldet
`make mutate` sie als BEFUND (`MUTATE-EXIT=2`, Bedingung 2). Dieselben Fälle
lieferte der Config-Re-Schnitt: **68, 71, 96** (die vom Umschnitt dieses
Vorgangs gezogenen). Zwei Fundmengen, dieselbe Klasse, derselbe Vorgang —
ein Beleg.

**Klasse:** die Fall-Anlage misst ihr sed-Muster gegen die Fassung der letzten
Fassung, nicht gegen den Quell-Bestand — eine berechtigte Änderung
(Re-Schnitte der Config und der Quelle) entwaffnet die Fälle, und der Lauf
meldet den verlorenen Zahn. Die Fehlerrichtung ist *Zahn verloren, Wächter
unbewacht gelistet*.

**Lage:** der Vorgang läuft; seine Position im Planning-Lifecycle liest der
Lauf, der diesen Beleg bei der Closure gegen `done/` prüft — die Lage-Prüfung
läuft nach dem Move, der Beleg beansprucht sie hier nicht.
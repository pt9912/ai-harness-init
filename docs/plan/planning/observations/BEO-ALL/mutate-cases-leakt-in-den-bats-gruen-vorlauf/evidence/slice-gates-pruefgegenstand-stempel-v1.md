# BEO-ALL/mutate-cases-leakt-in-den-bats-gruen-vorlauf — Beleg

Beobachtet an HEAD `72d1d364` (Teillauf
`MUTATE_CASES='801-traeger-host-digest-entzaubert' make mutate`, Log
`4 isolierte Kopie(n) … 1 Faelle auf 4 Worker`).

Der Teillauf exportiert `MUTATE_CASES` in die Worker-Umgebung, und der
Gruen-Vorlauf eines `verify: test-bats`-Falls fährt die volle bats-Suite in
dieser Umgebung. Die Wrapper-Fälle des mutate-driver (die `teillauf_fake`/
`greift_main`-Fixtures unter `test/mutate-driver.bats`, Stufen 388–398) lesen
`MUTATE_CASES` selbst aus der Umgebung — der vom Teillauf gewählte Fall-Name
`801-traeger-host-digest-entzaubert` wird dort zum unbekannten Fall (keine
Datei `…/greift-praefix/cases/801-traeger-host-digest-entzaubert.sh`) — und
die Suite fällt im Vorlauf UND im Fall-Lauf an demselben Satz. Der Treiber
liest den Fall als „ohne Ergebnis — ein Worker ist gestorben"; der Fall selbst
ist unschuldig: dieselbe Hand-Mutation an der realen Datei mit direktem
`make test-bats BATS_TARGET=<datei>` faärbt die erwartete Rot-Menge
(`801`: Tests 1/2/7 von `test/traeger-fetch-host.bats`, gemessen 2026-11-27).

Grenze der Messung: die Lage wurde 3x gesehen, je Sicht ein Teillauf desselben
Falls `801-traeger-host-digest-entzaubert` — (1) bei Stallschranke 900 s,
(2) bei Stallschranke 900 s mit dem Zusatzbefund `host-baum` (der Zusatzbefund
gehoert dem parallelen Lauf, der waehrend des Zugs eine Fall-Zieldatei
anfasste, und schliesst nicht aus, dass die Lage dieselbe ist), (3) bei
vergroesserter Stallschranke 2700 s. Sichten 1 und 2 enden mit den Befunden
`vollstaendigkeit`/`zeit-bilanz` (kein Fall-Ergebnis); Sicht 3 dito bei der
vergroesserten Schranke. Nicht gemessen: ob CI-Shards (`mutate.yml`) dieselbe
Lesung tragen — derselbe Mechanismus spricht dafuer, die CI-Logs sind nicht
gelesen.

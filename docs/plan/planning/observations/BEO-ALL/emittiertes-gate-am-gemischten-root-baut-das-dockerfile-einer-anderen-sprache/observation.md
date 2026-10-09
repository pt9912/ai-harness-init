# Emittiertes Gate am gemischten Root baut das Dockerfile einer anderen Sprache

**Sub-Area:** `*` (gesamtes Repo)

`add-lang <sprache> .` an einem Root, der schon eine Sprache trägt, lässt deren `Dockerfile`
liegen (skip-if-present). Das Code-Gate-Ziel der neuen Sprache baut dann mit `docker build --target
<stage>` die Stages der vorhandenen Sprache: Die neue Sprache wird im Ziel weder kompiliert noch
gelintet, und `make gates` meldet grün. Weder das emittierte Fragment noch die Ausgabe von `add-lang`
nennt das.

## Benannt, nicht gezählt

- Dasselbe Muster trägt das cpp-Fragment am gemischten Root; kein abgeschlossener Vorgang hat es
  festgehalten.

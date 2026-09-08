**Vorgang:** slice-201
**Fund:** Der Ruhe-Marker der Roadmap wird von beiden vorgeschriebenen Ortswechseln dieses Slice
falsch gemacht, in beide Richtungen: Beim Eintritt nach `in-progress/` steht er zwei Commits lang
neben einem beanspruchten Slice, beim Übergang nach `done/` fehlt er zwei Commits lang neben
leerem `in-progress/` — dazwischen meldet das Modul `planning` je `planning-drift`. Der Slice hat
damit auf einem roten Baum begonnen, obwohl sein eigener Start-Trigger einen grünen verlangt. Kein
Schritt zieht das Feld nach: `make slice-mv` zieht nach eigener Zusage Pfade nach, keine
Zustandssätze, und die zwei Commits, die es setzt, sind beide reine Werkzeug-Commits.

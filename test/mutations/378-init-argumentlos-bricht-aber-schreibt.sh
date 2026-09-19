#!/usr/bin/env bash
# files: cmd/ai-harness-init/main.go
# expect: TestUnfallVektor_OhneArgumentImRepoWurzel
# verify: test-go
#
# SCHWAECHT DIE ZUSICHERUNG (bricht, aber schreibt): der Leer-Argument-Zweig
# druckt seine Meldung und bootstrappt TROTZDEM ein Ziel der Form "" — das
# Arbeitsverzeichnis —, bevor er mit Exit 2 zurueckkehrt. Exit-Code und Meldung
# des Aufrufs bleiben richtig; der gemessene Fall faerbt allein an der
# Verzeichnis-Pruefung rot: das stehende Git-Repo bekommt .harness, obwohl der
# Lauf laut brach. Ein Abbruch, der schreibt, ist kein Schaden-frei-Abbruch —
# der Prozess-Fall haelt die Unveraendertheit des stehenden Repos und sieht
# genau diese Verletzung.
#
# Die Geschwister-Sperren desselben Aufrufs decken 377 (stiller Init-Pfad ganz
# zurueck) und 253 (Mehrfach-Argument); alle drei messen denselben Prozess-Aufruf
# (TestUnfallVektor_OhneArgumentImRepoWurzel) an verschiedenen Verletzungen.
set -euo pipefail
sed -i 's|^\tif fs.NArg() == 0 {$|\tif fs.NArg() == 0 {\n\t\t_ = bootstrap("", *lang, *name, *arch, src, stdout, stderr)|' cmd/ai-harness-init/main.go
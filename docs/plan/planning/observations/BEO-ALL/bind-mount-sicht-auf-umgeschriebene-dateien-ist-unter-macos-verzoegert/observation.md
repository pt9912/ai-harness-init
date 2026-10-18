# Bind-Mount-Sicht auf umgeschriebene Dateien ist unter macOS verzögert

**Sub-Area:** `*` (gesamtes Repo)

Eine Stufe von `make full-smoke-host` schreibt eine Datei im Ziel um und lässt sofort einen Container (a-check) über den Bind-Mount lesen.
Unter macOS mit Colima sah der Container einmal die Größe der vorigen Fassung (abgeschnittener `resolution`-Block, „0 von 5 Import-Symbolen"),
bei einem ersetzten Inode gar keine Datei. Die C#-hexSlice-Stufe pausiert darum `sleep 2` nach jeder Änderung; die Python-, Kotlin- und
Java-hexSlice-Stufen schreiben ebenso um und laufen ohne Pause. Die Verzögerung ist beobachtet und von Reviewer (9 Versuche) und Verifier
nicht reproduziert; die Pausen haben keine Gegenprobe, und die 2 s sind eine Schwelle ohne Messung. Nachbarn:
[`lokaler-full-smoke-scheitert-auf-macos-host`](../lokaler-full-smoke-scheitert-auf-macos-host/observation.md) (anderer Mechanismus: Exec-Format-Fehler des
Linux-Binary auf dem Host) und
[`gruen-vorlauf-eines-mutate-workers-faellt-unter-runner-last`](../gruen-vorlauf-eines-mutate-workers-faellt-unter-runner-last/observation.md) (CI-Runner-Last,
nicht Mount).

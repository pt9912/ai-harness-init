**Vorgang:** slice-mutate-branch-worker-wartet-die-publikation-ab
**Fund:** Die Pflichtzeile in `docs/user/releasing.md` zählte mit `grep -c '^FEHLT'` die Fälle ohne Ergebnis, während ein gezogener Fall ohne Ergebniszeile (Fall 445 an der Zeitschranke) als `BEFUND (kein Ergebnis im Log)` in der Datei steht und mit 0 gezählt wurde (Review MEDIUM-1).

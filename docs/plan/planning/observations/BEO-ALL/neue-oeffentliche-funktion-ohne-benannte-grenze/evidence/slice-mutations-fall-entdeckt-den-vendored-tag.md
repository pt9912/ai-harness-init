**Vorgang:** slice-mutations-fall-entdeckt-den-vendored-tag
**Fund:** Die neu eingeführte Funktion `resolve_file_spec` in `harness/tools/mutate.sh` sagte in
ihrem Kopf zu, sie löse auf, *„nur, wenn die Datei da ist"*. Gemessen (Sonde im Review über einem
Wegwerf-Baum) liefert sie für ein **Verzeichnis** desselben Namens rc=0 — `compgen -G` trifft die
Unterscheidung nicht. Die Grenz-Aussage blieb damit hinter dem ungedeckten Rest zurück: Eine
`# files:`-Angabe auf ein Verzeichnis passiert die Schranke und fällt erst an
`sha256sum "${file_list[@]}"`, dort ohne Fall-Namen und als harter Abbruch des Workers statt als
Befund. Der Kommentar ist eingelöst und nennt das Verhalten jetzt zutreffend; das Verhalten selbst
blieb unverändert und war nie eine Forderung des Slice.

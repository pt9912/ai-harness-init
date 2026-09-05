**Vorgang:** slice-173
**Fund:** `slice-173` zeigte dieselbe Klasse im Go-Port: `gitLsFiles` liest mit `-z`, während der Suchraum `strings.TrimSpace` anwendet, wodurch ein getrackter Pfad mit Randleerraum aus dem durchsuchten Bestand fiele.

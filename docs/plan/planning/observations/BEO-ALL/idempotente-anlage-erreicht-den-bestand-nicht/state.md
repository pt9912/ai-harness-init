**Stand:** verkörpert — Regel *Bestand im Release-Text* in `docs/user/releasing.md` Schritt 5,
Anker `· seit slice-ziel-traegt-keine-kennung-dieses-repos`. Grenze: kein Sensor; Träger ist der
Release-Schnitt, der zwei frische Emissionen vergleicht (Verdikt
`2026-10-09-slice-ziel-traegt-keine-kennung-dieses-repos-architect-verdikt`).

`make full-smoke` bootstrappt in ein leeres Verzeichnis und misst damit nur das frische Ziel; ein
gealtertes Ziel liegt in keinem Prüfbereich dieses Repos. Baubar, nicht gebaut, ist ein Werkzeug-Ziel
im Release-Vorgang, das die zwei Emissionen über den skip-if-present-Pfaden vergleicht und gegen den
Release-Text hält (Verdikt §3).

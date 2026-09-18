**Vorgang:** slice-spec-straten-zeigen-nicht-nach-aussen

**Fund:** Der `git mv` dieses Slice von `in-progress/` nach `done/` macht **zwei** bewachte Größen in
anderen lebenden Artefakten falsch. Keine von beiden zieht ein Anweisungssatz dieses Repos nach;
`make slice-mv` zieht nach eigener Zusage Pfade nach, keine Zustandssätze und keine Zahlen.

1. **Der Ruhe-Marker der Roadmap.** Nach dem Move trägt `in-progress/` keinen Slice mehr, der
   Marker `Nichts in Arbeit.` fehlte aber — er war beim Übergang `next → in-progress` entfernt
   worden. Der Marker steht im `planning:`-Block der Gate-Konfiguration und wird gegen das
   Verzeichnis gehalten; sein Fehlen wäre `make docs-check` rot. Nachgezogen, und zwar erst
   **nach** dem Move — vor ihm hätte er das Falsche behauptet.
2. **Eine deklarierte Deckungs-Zahl einer Gate-Ausnahme.** Der Eintrag `docs/plan/planning/done/**`
   → `.harness/baseline/**` in der `ignore-refs`-Liste führt `# Deckung: 4`. Die bewegte Datei
   bringt **einen** Link in die vendorte Baseline mit und hebt die gedeckte Menge auf **5**;
   `make test-bats` fällt mit der Meldung *„5 aufloesende(r) Link(s), deklariert sind 4"* und nennt
   beide erlaubten Ausgänge. Der Bestand ist korrigiert — der Link ist der Form des eingefrorenen
   Artefakts gewichen (Tag und Regelwerk-Name statt eines Pfades, `AGENTS.md` §3.11) —, die
   Deklaration bleibt bei 4.

**Wirkung und Grenze.** Beide Größen sind bewacht, also fällt der Move **laut** aus statt still: der
Marker über das `planning`-Modul, die Zahl über den Breiten-Sensor der `ignore-refs`-Liste. Genau
das ist die benannte Lücke dieser Beobachtung — der Ausgleichs-Schritt ist nirgends vorgeschrieben,
und der bewegende Lauf trägt ihn von Hand nach. Zwei Ausgleichs-Schritte in einem Vorgang, keiner
davon im Werkzeug.

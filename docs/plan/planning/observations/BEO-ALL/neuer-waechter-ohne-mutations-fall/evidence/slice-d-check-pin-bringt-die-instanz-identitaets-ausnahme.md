**Vorgang:** slice-d-check-pin-bringt-die-instanz-identitaets-ausnahme

**Fund:** Der Review des Vorgangs führt F-1 (MEDIUM): Die Pin-Kopplung
(`TestDefaultImage_MatchesCanonical`, `TestDefaultDigest_MatchesCanonical` in
`internal/emit/emit_test.go`) hat keinen Fall unter `test/mutations/`
(`grep -rln 'DCHECK_DIGEST\|DCHECK_IMAGE\|DefaultDigest\|DefaultImage' test/mutations/` → kein
Treffer); der bestehende Fall `01-baseline-pin-kopplung.sh` deckt die Baseline-Pins, nicht den
d-check-Pin. Der Wächter trägt seine Zähne — die Rotation wurde am Wegwerf-Klon real rot gefahren
(`make test` Exit 1 mit beiden Testnamen in der Fehlerklasse); der fehlende Fall ist ein
Bestands-Defekt der Kuratierung, kein Bruch des Sprungs, den der Vorgang trägt.

**Wirkung und Grenze.** Die Klasse ist verkörpert
([`AGENTS.md`](../../../../../../../../AGENTS.md) §3.6 — wer keinen Fall in `test/mutations/` hat,
ist unbewacht; `make mutate` meldet jeden gelisteten Wächter, der seine Zähne verloren hat); dieser
Beleg ist die vierte Fundstelle und kein zweiter Anker — der Eintrag trägt keinen neuen Ausgang.
Der Ausgleich ist verdrahtet: `slice-pin-kopplung-bekommt-ihren-mutations-fall` (ist eine Datei in
`open/`) schreibt den Fall, der die Kopplungs-Zusage bindet.

Zählerstand nach diesem Beleg: 11
(`ls docs/plan/planning/observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/evidence/ | wc -l` → 11).
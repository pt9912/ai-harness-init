**Stand:** verkörpert — `make release-warten`, im `ci`-Job `full-smoke` der Schritt vor
`make full-smoke` (`seit slice-ci-wartet-die-publikation-des-gepinnten-releases-ab`).

Die Target-Zeile im `Makefile` trägt den Herkunfts-Anker nicht; die Herkunft steht hier. Der
Warte-Schritt trägt bis zu seiner Grenze: folgt der Tag dem Push von `main` später, fällt `ci` an
`make traeger-fetch` im frischen Klon, bis ein Re-Run nach der Publikation es hebt (Beleg
`slice-release-schnitt-v070-liefert-kotlin-und-v6180`). Der operative Ausgang nach überschrittener Grenze steht in
[`docs/user/releasing.md`](../../../../../../docs/user/releasing.md) §Prozedur, Schritt 6.

**Grenze, am Ort benannt:** `make release-warten` steht im `ci`-Job; der Worker des Workflows `mutate-branch` hat keinen
Warte-Schritt, sein Grün-Vorlauf `make full-smoke` fällt vor der Publikation an demselben Fetch (Beleg
`slice-release-schnitt-v0-10-0-liefert-java-python-csharp`: 9 von 31 Fällen ohne Ergebnis). Fälle, deren Wächter den Träger im Ziel holt, sind
vor der Publikation nicht belegbar; sie holt der nächtliche `mutate`-Vollsweep nach, dessen Ergebnis für diesen Schnitt ungemessen ist.
Geschärfte Regel als Vorschlag an den Architect, nicht verkörpert: der Schnitt nennt die Fälle ohne Ergebnis im Bericht und schließt mit der
benannten Lücke, oder die Probe läuft nach der Publikation; ein Wächter existiert nicht.

**Neue Möglichkeit:** `make release-warten` im Worker-Vorlauf des Workflows `mutate-branch` (Verdikt `2026-10-20-welle-sprachprofile-java-python-csharp-architect-verdikt`, V-2). Die Grenze oben ist *geplant*: `slice-mutate-branch-worker-wartet-die-publikation-ab` (Auftrag des Auftraggebers nach V-2).

**Worker-Hälfte der Grenze, nachgezogen:** `make release-warten` steht jetzt einmal im Job `plan` des Workflows `mutate-branch`, als eigener Schritt vor den Shards (Beleg `slice-mutate-branch-worker-wartet-die-publikation-ab`). Gedeckt ist die Verdrahtung (Text-Wächter, Fall 775 und 776); gemessen ist, dass der Schritt im Worker läuft und bei `TRAEGER_WARTEN_GRENZE=0` meldet (`release-warten: GRENZE ERREICHT`). **Nicht belegt:** dass der Worker ein später veröffentlichtes Release abwartet. Offen bleibt der Tag-Push nach Ablauf der Grenze; Träger ist `docs/user/releasing.md` §Prozedur, Schritt 6.

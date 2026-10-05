# Review: Tag-Baum v0.2.7 (Commit b1f45369)

Gegenstand: `slice-release-schnitt-v027-liefert-den-altbestand-pfad`, Diff Makefile, `traeger.mk`, `test/traeger-fetch.bats`, Benutzerhandbuch.
Bezug: ADR-0058, ADR-0059, LH-QA-02.

## Findings

- **LOW** · quelle: Maintainability / Handbuch-Ist-Zustand · pfad: `docs/user/benutzerhandbuch.md:4` ·
  befund: Die Zeile `**Stand:** 2026-09-25` blieb stehen, obwohl derselbe Commit Software-Stand, Auslieferungs-Aussage
  und `archive-welle`-Zeile ändert (Plan L2: Stand-Zeilen aktuell). · verifizierbar: ja (`grep -n '^\*\*Stand' docs/user/benutzerhandbuch.md`) ·
  klasse: Stand-Datum des Handbuchs zieht bei Inhaltsänderung nicht mit

- **INFO** · quelle: Maintainability · pfad: `docs/user/benutzerhandbuch.md` (Zeile `make archive-welle`) ·
  befund: „Untergrenze vor der ersten Wellen-Archivierung" ist gegen `harness/sensors/archive-welle.md` §4 und
  `archivierung.mk` Z. 14-17 korrekt; die zweite Sperre (`haenger`) bleibt auch nach `altbestand` stehen und steht im Handbuch nicht.
  Keine falsche Aussage, nur nicht vollständig. · verifizierbar: nein · klasse: Teilaussage zur Vorbedingung

## Geprüft, ohne Befund

- (a) Pins: `grep -rn 'v0\.2\.6' Makefile internal test docs/user harness` → leer. Die übrigen `v0.2.x` in `test/tap-nachzug.bats` und `docs/user/releasing.md` sind Fixture-Werte bzw. Aussagen über den damaligen Stand und bleiben zulässig. `TRAEGER_TAG` steht in Makefile, Vorlage und bats einheitlich auf `v0.2.7`.
- (b) Digests: alle sechs `TRAEGER_SHA256_*` im Makefile gleichen den Zeilen von `dist/SHA256SUMS` (per Auge je Plattform verglichen, alle sechs identisch).
- (c) Handbuch: `WELLE=altbestand` (wellenlose Slices samt Review-Reports unter `done/altbestand/`) deckt sich mit `archivierung.mk` und `archive-welle.md` §Vertrag/§7; keine Prognose, nichts Unimplementiertes; weitere `v0.2.4`-Vorkommen existieren nicht mehr.
- (d) Abgrenzung: kein Funktionsinhalt, kein `archive-slice`, keine Änderung an `releasing.md`.
- Bekannte Lücke (bats bindet den realen Makefile-Digest nicht): im Plan L1/§6 Risiko 5 korrekt als Fixture-Klasse getragen; nicht erneut gemeldet.

# Review: slice-sprung-auf-v6180-wird-vollzogen

**Range:** `458e0836` (Claim-Commit) bis `e5a3000b` · **Plan:** `slice-sprung-auf-v6180-wird-vollzogen` ·
**Regierende ADR:** ADR-0091 (Accepted) · Reviewer-Skill 2.3.0

**Summary:** 0 HIGH · 0 MEDIUM · 1 LOW · 0 INFO — annahmereif.

## Findings

### LOW-1 — Die vier neuen Schlüssel des emittierten reviews-Blocks haben keinen Fall in `test/mutations/`

- `kategorie`: LOW
- `quelle`: ADR-0091 Festlegung 2 (Wächter je neuem Schlüssel), AGENTS.md §3.6 (`make mutate` bewacht nur gelistete Wächter)
- `pfad`: `internal/emit/emit_test.go:618-632` (Test); `test/mutations/` (Fälle 568, 666, 667 binden nur Block-Kopf, Pin-Kommentar, `match: name`)
- `befund`: `TestDCheckConfig_ReviewsBleibtKommentarBlock` hält `require-promises`, `recursive`, `skip-pattern` und `skip-allows-empty` je einzeln. Er ist rot, wenn ein Schlüssel fehlt (siehe Bruchprobe). `make mutate` führt dafür aber keinen Fall, die Haltbarkeit der Zähne ist dort unbewacht.
- `verifizierbar`: ja (`ls test/mutations | grep -i 'skip\|promises\|recursive'` leer)
- `klasse`: Wächter ohne Mutations-Fall im kuratierten Set

## Bruchprobe (Kopie mit Rücksetzen, Baum danach sauber)

`sed -i '/^#   skip-allows-empty: true$/d' internal/emit/templates/d-check.yml` gefolgt von `make test-go` ergibt
`FAIL TestDCheckConfig_ReviewsBleibtKommentarBlock … Kommentar-Block reviews traegt "#   skip-allows-empty: true" nicht`.
Die Ursache ist die behauptete, die Meldung nennt genau den Schlüssel. Danach `git checkout`, `git status` leer.

## Geprüft, ohne Befund

- **Pins/Tag-Klammer:** `BASELINE_TAG` und `BASELINE_ZIP_SHA256` in `Makefile`, das `sources`-Paar in `.d-check.yml`, `DefaultTag` und `DefaultBaselineSHA256` in `internal/fetch/baseline.go` sowie `InventurMessTag` stehen auf `v6.18.0` mit gleichem sha256 (Diff gelesen). `make baseline-verify` meldet `v6.18.0 OK — 54 Dateien`, `.harness/baseline/` führt nur `v6.18.0`.
- **Symlinks/Adressen:** Alle sieben `.claude/rules`-Zeiger in den Baum zeigen auf `v6.18.0`. Die drei übrigen Zeiger sind repo-eigen (`AGENTS.md`, `conventions.md`, `README.md`). `git grep v6.17.0` außerhalb der Zeitdokumente und eingefrorenen Bäume findet nur Sprung-Beschreibungen (Slice-Plan, `migration.md`), keine lebende Adresse.
- **Emission:** Der Kommentar-Block in `internal/emit/templates/d-check.yml` ist wortgleich mit den fünf Schlüsseln der vendored Vorlage (`skip-pattern` byte-gleich). `reviews` bleibt aus `modules:` und als Kommentar, Festlegung 2 ist umgesetzt. Die Stufe `review_vorlagen_im_ziel` und die `e2e_abdeckung`-Zeile (Stufe 5 in `docs/user/e2e-abdeckung.md`) nennen die Teilmessung („gemessen ist der Text im Ziel, nicht dass ein aktivierter Block greift") am selben Ort.
- **Dogfood/Festlegung 3:** `harness/README.md` nennt `reviews` ausdrücklich nicht aktiv, mit Grund und Folge-Slice-Kennung `slice-review-deckung-laeuft-im-dogfood` (existiert im Planning-Lifecycle).
- **Rollen-Anweisungen:** Reviewer-Skill und Karten `reviewer.md` und `verifier.md` nennen die volle Slice-Kennung, die Skill-Fassung grenzt die Ablage-Regel gegen die Bestands-Reports ab.
- **Rollen-/Commit-Zuschnitt (§3.8):** Die Norm-Artefakte (AGENTS.md, `conventions*`, `migration.md`, ADR-0061) liegen in Architect-Commits mit Rolle in der Message. ADR-0061 ist `Proposed`, ihr Adress-Nachzug berührt keine immutable ADR (§3.4). Der Slice-Abschluss (§3.10) wurde nicht vorweggenommen: keine Closure-Notiz, kein `git mv`.
- **Gates:** `make gates` am sauberen Baum von HEAD `84c1499e` endet mit EXIT 0.

Hinweis: Die DoD-Abhakung ist nicht Gegenstand dieses Reviews, das ist Verifier-Sache (Bericht `2026-10-10-slice-sprung-auf-v6180-wird-vollzogen-verify.md`).

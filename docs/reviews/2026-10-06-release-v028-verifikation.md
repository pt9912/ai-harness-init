# Verifikation: slice-release-schnitt-v028-loest-den-slice-mv-block — 2026-10-06

**Rolle:** Verifier (Modul 11) · **Gegenstand:** Tag-Baum `2e3260d4` (`77f2d3dd`, `2270efaa`,
`2e3260d4`) · **Review:** `2026-10-06-release-v028-review.md` (kein HIGH/MEDIUM, F-1/F-3 behoben).
**Verdikt:** L1 **bestätigt**, L2 **bestätigt**, L3 **nicht verifizierbar vor dem Push** (Liste unten).
`make gates` lief am Baum mit diesem Bericht; Exit und Laufzeit trägt die Commit-Message.

- **L1 Digests — bestätigt.** Neubau aus `git archive 2e3260d4` in ein Scratch außerhalb des
  Repos, zweimal: `make release-artifacts DEST=<scratch>/d1|d2 TRAEGER_VERSION=v0.2.8` → beide
  Exit 0; `diff d1/SHA256SUMS d2/SHA256SUMS` → leer (reproduzierbar); `release-sums.sh verify d1`
  → sechs `OK`, Exit 0; die sechs `TRAEGER_SHA256_*` im `Makefile` je per `sed`/`awk` gegen
  `d1/SHA256SUMS` → sechsmal `gleich`; `diff dist/SHA256SUMS d1/SHA256SUMS` → leer.
  `--version` des frischen Linux-amd64 → `v0.2.8`. Rot: ein Byte an `linux-arm64` einer Kopie →
  `verify` Exit 1, nennt `ai-harness-init-linux-arm64: GESCHEITERT`.
- **L1 Pin-Brüche.** (a) Realer Digest verfälscht (`TRAEGER_SHA256_LINUX_AMD64` `5407…`→`0407…`),
  `make test-bats BATS_TARGET=test/traeger-fetch.bats` → 10/10 `ok`, Exit 0: **Lücke bestätigt**,
  kein Gate-Sensor bindet den realen Makefile-Digest (`grep -rl TRAEGER_SHA256` nennt außer der
  bats-Datei nur die Fetch-Skripte und `full-smoke.sh`, dessen Stufe im Ziel-Modus ohne
  Makefile-Digest fährt). Erst `make traeger-fetch` nach der Publikation hält ihn — Risiko 5 tritt
  ein, Beleg zu `BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle`. (b) Vorlage
  `traeger.mk` auf `v0.2.7` → `not ok 1 pin-kopplung`, Zeile 121, `pin_wert "$FRAG"` ≠ `v0.2.8` —
  rot aus dem behaupteten Grund. Grenze: der Fall vergleicht beide Stellen gegen das Literal, nicht
  gegeneinander. Beides zurückgesetzt, `git status` leer.
- **L1 Anlass — bestätigt.** Frisches Binary bootstrappt ein Scratch-Ziel (doc-only), `open/` trägt
  `slice-anlass`, `slice-anlass-lang`, `slice-y-z`, `slice-yz`. `make slice-mv SLICE=slice-anlass
  TO=next` → Exit 0, genau `slice-anlass.md` bewegt; `SLICE=slice-y` → Exit 0, bewegt
  `slice-y-z.md`, `slice-yz.md` bleibt (Handbuch-Aussage F-3 hält). Gegenprobe mit dem emittierten
  `slice-mv.sh` aus `v0.2.7` (Vorlage am Tag, nicht das Release-Binary) im selben Ziel → Exit 2,
  `'slice-anlass' ist mehrdeutig` — der Fehler des Adopters.
- **L2 — bestätigt.** `grep -n 'v0\.2\.7'` → leer; `grep -c slice-mv` → 3; Zahlwort Kopf
  „Fünf Betriebs-Operationen", „zwei der fünf", „Alle fünf"; Versions-grep aus dem Plan → leer.
  Stichproben am Ziel: Vertrag-Zelle mit 200 Zeichen → `docs-check` Exit 0, mit 201 → Exit 2,
  `section-cell-oversized … hat 201 Zeichen, erlaubt sind 200`; `harness/sensors/.gitkeep` liegt
  im Ziel. Nach `make hooks-install`: Message `Arbeit an slice-anlass-lang` → Exit 0, ohne Kennung →
  1, `xslice-anlass` → 1 (eigenes Wort); `slice-mv`-Commits tragen den Dateinamen. Keine Chronik,
  keine Prognose in den neuen Zeilen gefunden.
- **Plan-vs-Code.** `git diff --stat ce5cf985..HEAD` → genau die Plan-Dateien aus §3, dazu der
  Review-Report und `harness/sensors/traeger-fetch.md` (F-1, außerhalb §3, Übergabe an den Planner
  im Review vermerkt). Dessen Verweis stimmt: `grep -n '^TRAEGER_TAG' Makefile` → `45:TRAEGER_TAG
  ?= v0.2.8`. Zwölf Gegenstands-Commits aus §1 plus `77f2d3dd` = 13 unter
  `git log v0.2.7..HEAD -- internal/ cmd/`; kein Gebautes ohne Plan.
- **Erst nach dem Tag-Push belegbar (L3, offen):** `main`- und Tag-Push; `gh release view v0.2.8
  --json assets --jq '.assets|length'` → 8; die veröffentlichten Asset-Digests gleich den hier
  gemessenen; `make traeger-fetch` gegen den Pin und sein Rot mit verfälschtem `TRAEGER_SHA256_*`;
  `ci` an `main` und am Tag grün (ggf. `gh run rerun --failed` nach 404); Job `tap` grün und
  `make tap-check TAG=v0.2.8` Exit 0; Release-Text; erneuter `make gates` auf dem dann finalen
  Commit; Meldung an den Auftraggeber.

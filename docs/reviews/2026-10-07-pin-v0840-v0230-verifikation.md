# Verifikation — slice-pin-d-check-v0840-und-a-check-v0230

- **Rolle:** Verifier (Modul 11) · **Datum:** 2026-10-07 · **an:** Planner
- **Gegenstand:** `cb808e89`, `d45816fc`, `d883890c`, `b09a564e` + `8181fdd6` (`MR-084`), `76c5a48e`
  (Pin-Zahn, Review M-1); Review-Report `2026-10-07-pin-v0840-v0230-review.md` (M-1, L-1 behoben)
- **Geprüft gegen:** Slice-Plan §1–§3, `MR-063`, `MR-082`, `ADR-0060`, `AGENTS.md` §3.6

## Verdikte je Liefer-DoD-Punkt

- **1 — d-check `v0.84.0`: bestätigt.**
  - `grep -n '^DCHECK_IMAGE\|^DCHECK_DIGEST' d-check.mk` → `v0.84.0`, `sha256:e82ef2d2…1bba`;
    `internal/emit/emit.go:32-33` gleich.
  - `docker buildx imagetools inspect ghcr.io/pt9912/d-check:v0.84.0` → `image.index.v1+json`,
    Digest `sha256:e82ef2d2…1bba`, Manifests `linux/amd64` + `linux/arm64` — Tag und Pin lösen auf
    denselben Index.
  - Gegenmessung nach `MR-063` mit Kommandos und Befund-Zahlen steht im Umsetzungs-Commit `cb808e89`
    (fünf Stufen, `diff` leer); Code-Breite der Sonden-Stufe ist in `MR-084` benannt (`8181fdd6`).
    Nicht nachgefahren — der Review las sie vollständig.
  - Rot-Beleg vorhanden (`cb808e89`: `emit.go` auf `v0.83.0` → `TestDefaultDigest_MatchesCanonical`,
    `TestDefaultImage_MatchesCanonical` rot). Der Zahn liest die reale Quelle
    (`emit_test.go:255,267`: `mkVar(…"d-check.mk"…)`), keine Fixture. Nicht wiederholt.
    Grenze benannt: Digest gegen Tag hält kein Sensor (`BEO-ALL/pin-digest-ohne-waechter`).
- **2 — a-check `v0.23.0`: bestätigt.**
  - `internal/emit/archgate.go:24-25` → `v0.23.0`, `sha256:97cb6d4e…3f44`;
    `imagetools inspect` → Index, `linux/amd64` + `linux/arm64`, derselbe Digest.
  - `make full-smoke` einmal voll gefahren → **EXIT 0**. In der Ausgabe gelesen: jeder a-check-Lauf
    mit `a-check@sha256:97cb6d4e…` (5 Aufrufzeilen, kein anderer a-check-Digest); `hexslice` go
    (Mono `apps/hex`, Root): grün, Root `gesamt: 0 Befund(e)`; verbotener Import →
    `core-impurity: 1` (`greeting.go:8 … importiert app/internal/adapters/driven/notify`);
    `hexslice` cpp (`apps/cpphex`, Root): grün, verbotener Include → `core-impurity: 1`
    (`greeting.hpp:1`); `hexagonal` go: `make gates` Exit 0 (Stufe ab `full-smoke.sh:3005`,
    sonst `FEHLER`), Zähne `app-impurity: 1` und `lateral-adapter: 1`. Alle d-check-Läufe im Ziel
    mit `d-check@sha256:e82ef2d2…` (8×).
  - Pin-Zahn nach M-1 (`76c5a48e`): prüft `Tag >= v0.20.0`, Meldung nennt diese Ursache;
    Rot-Beleg `v0.19.9` → FAIL im Commit. Nicht wiederholt.
- **3 — Handbuch: bestätigt.** Die Aussage hält, was belegt ist:
  `docker manifest inspect <image>@<digest>` (das Kommando des Handbuchs) auf beide Pins →
  je `image.index.v1+json` mit `amd64` und `arm64`. Der Satz sagt „liegt vor" und „gefahren
  … nur mit der `linux/amd64`-Variante" — kein Lauf auf arm64 wird behauptet. „Docker zieht die
  Variante … ohne Emulation" ist Docker-Verhalten über einem Index; das emittierte Rezept setzt kein
  `--platform` (`grep -rn platform internal/emit internal/gen --include=*.go` ohne Treffer außerhalb
  von Tests). Dass die arm64-Variante **funktioniert**, ist nicht gemessen und nicht zugesagt
  (Risiko §6 „arm64 ungemessen" bleibt Planner-Ausgang).
- **`make gates`:** Ergebnis am Ende dieses Laufs, in der Rückmeldung an den Aufrufer.
- **Doku-Update/Review:** Architect-Commit `b09a564e` berührt nur `harness/conventions.md` und
  `MR-084` — eigener Commit wie verlangt; Review-Report liegt vor.

## Plan vs. Code

- **Plan → Code:** alle vier Zeilen der §3-Tabelle umgesetzt.
- **Code → Plan:** der geänderte Pin-Test liegt unter `internal/gen/archgate_test.go`, nicht unter
  den in §3 genannten `internal/emit/`/`test/`; `test/` unberührt. Ohne Verhaltens-Folge.
- Restbestand alter Pins (`git grep` auf `d-check:v0.83`/`a-check:v0.20`…) nur in `Accepted`-ADRs
  und eingefrorenen MR-Einträgen — keine lebende Stelle.

## Offen für Planner

- Risiken §6 (arm64 ungemessen, Digest ohne Wächter) brauchen ihren Ausgang bei der Closure; der
  Digest-Wächter-Beleg berührt `BEO-ALL/pin-digest-ohne-waechter` erneut.

Keine Findings.

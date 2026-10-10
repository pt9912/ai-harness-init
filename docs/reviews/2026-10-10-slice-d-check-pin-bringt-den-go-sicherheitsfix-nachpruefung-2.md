# Review: slice-d-check-pin-bringt-den-go-sicherheitsfix — Nachprüfung 2 (Pin v0.86.1)

**Rolle:** Reviewer · **Datum:** 2026-10-10 · **Gegenstand:** `a79d72a9..4abafc4f` (Commit `4abafc4f`)
gegen den Plan in der Fassung `43091527` und gegen die Nachprüfung `a79d72a9`.

**Urteil: freigegeben.** **Summary:** 0 HIGH · 0 MEDIUM · 0 LOW · 3 INFO (INFO-1 und INFO-2 aus
`a79d72a9` offen, INFO-3 neu). Keines ist eine Folge des Sprungs auf v0.86.1. Alle drei
Erkennungs-Ergebnisse unten sind an v0.86.0 und v0.86.1 gleich.

## Eingang

Diff `a79d72a9..4abafc4f` (drei Dateien: `d-check.mk`, `internal/emit/emit.go`,
`internal/emit/templates/d-check.yml`), Slice-Plan Fassung `43091527`, Report der Nachprüfung
`a79d72a9`, `AGENTS.md` §3.5/§3.6, `MR-063`, `MR-086`, `LH-QA-02`.

## Findings

### INFO-1 (aus `a79d72a9`) — offen

- `kategorie`: INFO · `quelle`: AGENTS.md §3.6 · `pfad`: `internal/emit/templates/d-check.yml:41-45`
- `befund`: Der Satz ist unverändert. An v0.86.1 neu gefahren: Plan `slice-ca`, Report
  `2026-01-01-slice-cache.md`, `match: name` → `review-missing` für `slice-ca`. Die Zuordnung verlangt
  also weiter eine Grenze hinter dem Namen, und der Kommentar nennt sie nicht.
- `verifizierbar`: ja · `klasse`: Grenzen-Aufzählung einer erkennenden Regel ohne Formen-Probe

### INFO-2 (aus `a79d72a9`) — offen

- `kategorie`: INFO · `quelle`: AGENTS.md §3.6 · `pfad`: `internal/emit/templates/d-check.yml:27-28`
- `befund`: „Still bleiben am Pin v0.86.1“ im `codepaths`-Block ist wieder von Hand nachgezogen. Kein
  Test koppelt die Fassung an `DefaultImage`, und die Commit-Message von `4abafc4f` nennt das
  selbst als Grenze.
- `verifizierbar`: nein · `klasse`: Aussage über das gepinnte Werkzeug ohne Blick in seinen Stand

### INFO-3 — Laut Kommentar zählt die Wortfolge „unabhängiger Review“ als Zusage, das gilt aber nur in einer Listen-Zeile

- `kategorie`: INFO · `quelle`: AGENTS.md §3.6 · `pfad`: `internal/emit/templates/d-check.yml:37-38`
- `befund`: Der Kommentar sagt, am Pin v0.86.1 werde neben der Vorlagen-Zeile „ebenso die Wortfolge
  ‚unabhängiger Review‘“ als Zusage erkannt. Gefahren an beiden Digests: `- [ ] unabhängiger Review`,
  `- [x] Ein unabhängiger Review liegt vor` und `- [ ] Unabhängiger Review …` → `review-missing`.
  Dieselbe Wortfolge als Prosa-Zeile (`Ein unabhängiger Review folgt.` bzw. `unabhängiger Review`) →
  0 Befunde. Wer die Wortfolge als Fließtext schreibt, bekommt ohne Report ein stilles Grün. Die
  Zeile der Vorlage ist eine Listen-Zeile, deshalb trifft der Normalfall zu. Das Ergebnis ist an
  v0.86.0 gleich, also kein Befund des Sprungs. Das Modul bleibt auskommentiert (`MR-086`).
- `verifizierbar`: ja (Sonde unten) · `klasse`: Grenzen-Aufzählung einer erkennenden Regel ohne Formen-Probe

## Sonden und Belege

- **Index-Digest:** `docker buildx imagetools inspect ghcr.io/pt9912/d-check:v0.86.1` → OCI-Index
  `sha256:3e0b9779a71e2fa942960e8b961428fba036455c535513d34a75bfb799ffce0e` (amd64 `1d3b0a2b…`,
  arm64 `01e31f8f…`). Derselbe Wert steht in `d-check.mk` (`DCHECK_DIGEST` und im Hunk-Kommando)
  und in `internal/emit/emit.go` (`DefaultDigest`), der Tag v0.86.1 in `DCHECK_IMAGE`/`DefaultImage`.
  `git grep -n 'v0\.86\.[01]' -- ':!docs/reviews' ':!docs/plan/planning'` findet ausserhalb dieser
  drei Dateien nur den MR-Eintrag des Architect, kein übrig gebliebenes v0.86.0.
- **Go-Fassung und x/net, linux/amd64:** `docker create --platform linux/amd64
  ghcr.io/pt9912/d-check@sha256:1d3b0a2b…` + `docker cp :/d-check` in den Scratchpad (sha256 der
  Kopie `7e3268f2…`), dann `docker run --rm --network none -v <dir>:/x:ro
  golang:1.27.1@sha256:e0174e51… go version -m /x/d-check` → `go1.27.2`,
  `dep golang.org/x/net v0.60.0`, `build GOARCH=amd64`. arm64 nicht selbst gefahren.
- **Was sich v0.86.0 → v0.86.1 im Werkzeug ändert:** `git -C /Development/d-check diff --stat v0.86.0
  v0.86.1 -- internal cmd Dockerfile go.mod` → nur `go.mod`, 1 Datei.
- **Ist die Prosa „am Pin v0.86.1“ gemessen (§3.6)?** Der `reviews`-Satz ist es, durch die Sonden
  A/A3/A6/A7/B1/B2/B3 in `4abafc4f` und durch die eigenen Sonden hier, je mit
  `docker run --rm --network none -v "$P:/repo:ro" ghcr.io/pt9912/d-check@sha256:3e0b9779…` über einem
  Probe-Repo, das nur `modules: [reviews]` führt:

  | Sonde | Aufbau | Ergebnis |
  |---|---|---|
  | N1 | ohne `match`, Plan `slice-cache`, Report liegt | EXIT 1, `review-missing` (Namens-Form ohne `match`) |
  | N2 | ohne `match`, Plan `slice-007`, Report liegt | EXIT 0 (Ziffern-Form) |
  | N4 | `match: name`, Vorlagen-Zeile, kein Report | EXIT 1, `review-missing` |
  | N5 | Plan ohne Zusage | EXIT 0 (Kontrolle) |
  | N3/U1–U4 | „unabhängiger Review“ als Listen- bzw. Prosa-Zeile | s. INFO-3 |

  Der `codepaths`-Satz ist durch die Sonden in `4abafc4f` gedeckt (`src/fehlt.go`, `/docs/fehlt.md`,
  Glob, umzäunter Block still, Kontrolle `codepath-missing`). Hier nicht neu gefahren.
- **Strenge-Bilanz:** gelesen, nicht nachgefahren. Die Werte in `4abafc4f` (v0.84.0 gegen v0.86.1,
  fünf Stufen, `diff` leer, neun Module mit Basis) sind mit der leeren Code-Differenz oben vereinbar.

## Negativbefund

- Pin-Paar (Tag und Digest, beide Stellen): selbst gegen den Index gemessen, ohne Befund.
- Sicherheitsgrund (Go 1.27.2, x/net v0.60.0): an amd64 selbst gemessen, ohne Befund.
- Gate-Strenge (AGENTS.md §3.5): ohne Befund. Kein Modul und kein Schalter wird geändert, die
  Werkzeug-Differenz ist allein `go.mod`.
- Kommentar-Klassen (AGENTS.md §3.7) in den drei geänderten Kommentar-Zeilen: ohne Befund.
- Plan-Treue (Fassung `43091527`, Liefer-Punkte 1 und 3, Datei-Tabelle §3): ohne Befund.
- Formen-Probe zur `reviews`-Aufzählung: gefahren sind Vorlagen-Zeile, Listen-Zeile mit Wortfolge
  (`- [ ]`, `- [x]`, Groß- und Kleinschreibung), Prosa-Zeile mit Wortfolge, Ziffern- und Namens-Form
  ohne `match` und eine Token-Grenze hinter dem Namen. Die Lücke ist INFO-3.

# Review: slice-d-check-pin-bringt-den-go-sicherheitsfix — d-check-Pin v0.85.0

**Rolle:** Reviewer (Baseline-Regelwerk `modul-10-review-harness.md`, Skill `.harness/skills/reviewer.md`),
frischer Kontext; Diff gegen Plan, MR-Einträge und Hard Rules. Die DoD prüft der Verifier.
**Datum:** 2026-10-09.

**Summary:** 0 HIGH · 1 MEDIUM · 0 LOW · 3 INFO — Pin und Digest korrekt, Bilanz vollständig; der
emittierte `reviews`-Kommentar beschreibt nach dem Sprung ein Verhalten, das der emittierte Pin
nicht mehr hat.

## Eingang

- **Diff:** `144a2ad5` (`d-check.mk`, `internal/emit/emit.go`), `f652d6fb` (`harness/README.md`).
- **Plan:** `slice-d-check-pin-bringt-den-go-sicherheitsfix` (in Arbeit).
- **Maßstab:** [`MR-063`](../../harness/conventions.md#mr-063), [`MR-065`](../../harness/conventions.md#mr-065),
  [`MR-067`](../../harness/conventions.md#mr-067), [`MR-084`](../../harness/conventions.md#mr-084),
  [`MR-086`](../../harness/conventions.md#mr-086), [`AGENTS.md`](../../AGENTS.md) §3.6/§3.7.

## Findings

### MEDIUM-1 — Emittierter `reviews`-Kommentar beschreibt den alten Pin neben dem neuen

- `kategorie`: MEDIUM · `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.7, [`LH-FA-03`](../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7)
- `pfad`: `internal/emit/templates/d-check.yml:37-47`
- `befund`: Der Block sagt „Am Pin v0.84.0 … erkennt [es] die Review-Zeile der Slice-Vorlage an keinem
  Slice, eine Kennung in Namens-Form auch mit der Wortfolge nicht", und das Werkzeug emittiert ihn
  jetzt neben `DefaultImage` v0.85.0. Am neuen Pin trifft das nicht mehr zu, und die erste Hälfte des
  Adopter-Triggers ist eingetreten. Wer dem Trigger folgt und den auskommentierten Block wörtlich
  übernimmt (ohne `match: name`), bekommt `review-missing` auch für einen Slice **mit** Report.
  Sonde (Scratch, `done/slice-foo-bar.md` mit Zeile „Review durchgeführt, …", Report
  `docs/reviews/2026-10-09-slice-foo-bar.md`, `.d-check.yml` mit `modules: [reviews]`, `done-dir`, `reviews-dir`):
  v0.84.0 → 0 Befunde (Zusage nicht erkannt); v0.85.0 → `review-missing … keine slice-<NNN>-Kennung
  im Dateinamen slice-foo-bar.md — match: name ordnet über den Basisnamen zu`; v0.85.0 mit
  `match: name` → 0 Befunde, ohne Report → `review-missing … ohne Report`. Leeres `done-dir`: an
  beiden Pins `review-missing … leere Pruefmenge … fail-closed`. Damit gilt die erste Grenze des
  Kommentars weiter, der Auflösungs-Trigger von MR-086 (frisches Ziel mit aktivem `reviews` grün)
  ist **nicht** eingetreten. Der Plan nimmt die Datei nicht in §3 auf; die Kopplung Pin↔Kommentar
  hält kein Test (die Suite war mit `v0.84.0` im Kommentar grün).
- `verifizierbar`: ja — Sonde oben, je Pin `docker run --rm --network none -v <dir>:/repo:ro ghcr.io/pt9912/d-check@<digest>`.
- `klasse`: aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand

### INFO-1 — Mutations-Urteil fehlt, Ursache ist der CI-Weg

- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 · `pfad`: CI-Lauf auf dem Branch `mutate/…-f652d6fb`
- `befund`: Der CI-Lauf brachte kein Urteil (Docker-Hub-Rate-Limit 429). Ursache ist der CI-Weg,
  nicht der Implementer. Das Rot der Pin-Kopplung ist vom Implementer von Hand belegt
  (`TestDefaultDigest_MatchesCanonical`, `TestDefaultImage_MatchesCanonical`), in diesem Review nicht
  nachgefahren.
- `verifizierbar`: ja, bei einem Wiederholungslauf · `klasse`: ci-lauf-ohne-urteil-bei-registry-limit

### INFO-2 — `spans` hat seine Basis allein über `fence-unclosed`

- `quelle`: [`MR-063`](../../harness/conventions.md#mr-063) · `pfad`: Commit-Message `144a2ad5`, Strenge-Bilanz
- `befund`: Die Bilanz nennt es selbst: `span-unclosed` und `span-nested-link` erscheinen in keiner
  Stufe, die Wegfall-Richtung dieser zwei Codes ist ungemessen. MR-063 ist auf Modul-Ebene erfüllt;
  der CHANGELOG v0.85.0 nennt keine Änderung an `spans`.
- `verifizierbar`: ja · `klasse`: gegenmessung-basis-trifft-nur-einen-grund-code

### INFO-3 — Hilfetext `make doc-complete` sagt weiter „Exit 1"

- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6, [`MR-010`](../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
- `pfad`: `d-check.mk:99`
- `befund`: `make help` zeigt „Requirements-Waise ⇒ Exit 1", über `make` ist es Exit 2. Die Zeile ist
  tool-generierter Bestand, nicht im Diff; der Implementer lässt sie mit Begründung MR-010 stehen.
- `verifizierbar`: ja · `klasse`: exit-zusage-aus-anderem-aufruf-abgeleitet

## Geprüft, ohne Befund

- **Digest:** `docker buildx imagetools inspect ghcr.io/pt9912/d-check:v0.85.0` → Index
  (`application/vnd.oci.image.index.v1+json`), `sha256:c07f1fe6…f09abe`, amd64 + arm64; identisch in
  `d-check.mk` (Pin und Hunk-Kommando) und `internal/emit/emit.go`. Kein weiterer lebender Ort nennt
  `v0.84.0`/`e82ef2d2` außer den Kommentaren in MEDIUM-1 (`git grep`, ohne Zeitdokumente und MR-Dateien).
- **Strenge-Bilanz:** fünf Stufen, alle Diffs leer; Dogfood und Ziel je neun Module
  (`grep -m1 '^modules:' .d-check.yml`, `internal/emit/templates/d-check.yml:17`), jedes mit benannten
  Grund-Codes; Prüf-Bedingung nach MR-067 genannt, `git ls-tree 327cb33c .claude/rules/ | grep -c '^120000'` → 10;
  MR-065-Angabe vorhanden, kein history-lesendes Modul aktiv. Kein Modul ohne Basis.
- **Go-Fassung:** Methode trägt (`go version` liest die eingebettete Build-Info). Nachgefahren:
  Binär aus dem Index-Digest (amd64) und aus dem arm64-Manifest `sha256:69493255…` per
  `docker create`/`docker cp`, `go version` im Go-Image des Dockerfile → beide `go1.27.2`.
- **README `doc-complete` (`f652d6fb`):** nach §3.6 korrekt. Kopie per `git archive HEAD` mit
  angehängter `LH-QA-99` ohne Verweis: `make -s doc-complete` → Exit 2 (`Fehler 1`), direkt
  `--trace --require-complete` → Exit 1; unverändert Exit 0. Zulässig ohne Plan-Zeile: die Closure
  von `slice-mutate-laeuft-ueber-einen-ci-branch` übergibt die Zeile namentlich an diesen Slice.
- **Hard Rules:** keine Gate-Lockerung (§3.5), kein Inline-Suppress (§3.2), Kopfkommentar
  `d-check.mk` trägt Zustand, keine Chronik (§3.7), Commits nennen Kennungen; kein Norm-Artefakt im Diff (§3.8).

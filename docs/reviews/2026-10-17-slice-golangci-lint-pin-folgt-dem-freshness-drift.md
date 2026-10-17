# Review-Report: slice-golangci-lint-pin-folgt-dem-freshness-drift

**Datum:** 2026-10-17 · **Rolle:** Reviewer (frischer Kontext) · **Diff:** `d198c4c8` (golangci-lint v2.14.0 -> v2.15.0)
**Plan:** `slice-golangci-lint-pin-folgt-dem-freshness-drift` §1-§3 · **Bezug:** LH-QA-02, MR-048, ADR-0003, AGENTS.md §3.2/§3.3/§3.5/§3.6/§3.7/§3.10
**Nicht geprueft:** DoD-Abhakung (Verifier).

## Summary

HIGH 0 · MEDIUM 0 · LOW 0 · INFO 1. Keine wiederkehrende Finding-Klasse.

## Findings

### INFO-1
- kategorie: INFO · quelle: Maintainability / BEO-ALL/pin-digest-ohne-waechter · pfad: Dockerfile:59, Makefile:15
- befund: Ein real existierender, aber falscher `@sha256` (anderer Tag) färbt kein Gate, und der Makefile-Pin wird nur von `make freshness-golangci` (Netz, nicht in `make gates`) gehalten. Beides ist im Slice (§3, §6) als Lücke benannt, nicht als gedeckt zugesagt; kein Code-Mangel.
- verifizierbar: nein · klasse: Doppelt geführter Pin-Wert ohne Kopplungs-Sensor (Folge-Slice `slice-doppelt-gefuehrte-werte-bekommen-ihren-kopplungs-sensor`)

## Ergebnis zu den Schwerpunkten

- (a) Vollständigkeit: `git grep -nE '2\.14\.0'` (ohne Baseline, Reviews, done/) nennt nur noch den Slice-Plan selbst (Z. 33 Anlass-Zitat, Z. 55 Plan-Prosa); README, docs/user/benutzerhandbuch.md, internal/emit/templates, internal/gen, .github, harness/, MR-Prosa und ADRs tragen keinen Treffer. Eine Suche `golangci…v?2.x.y` über ADR, MR, docs/user, README findet keine weitere Versionsnennung.
- (b) Digest: `docker buildx imagetools inspect golangci/golangci-lint:v2.15.0` -> MediaType `application/vnd.oci.image.index.v1+json`, `Digest: sha256:fbfcfd12a6f8d7f1b97b3362ca80fc2a244d46863148c73cb88e7793af96c481` == Dockerfile:59. Der Vorgänger (`git show d198c4c8^:Dockerfile`) trug ebenfalls `golangci/golangci-lint:${GOLANGCI_LINT_VERSION}@sha256:…` (Tag + Digest); MR-048-Form gewahrt.
- (c) `git diff d198c4c8^ d198c4c8 --stat`: genau 3 Dateien (Dockerfile, Makefile, internal/gen/golang.go), je 1-2 Zeilen; `.golangci.yml` unverändert, `nolint` kommt im Diff nicht vor. `make lint` und `make gates` am Ende: Exit 0 (keine Lockerung, kein stilles Abschalten).
- (d) Rot-Belege: b) selbst gefahren in einer Kopie unter ~/.colima-tmp (git archive HEAD, nur `ARG GOLANGCI_LINT_VERSION=v2.14.0` zurückgedreht, `make test-go`): `--- FAIL: TestGoProfile_PinsMatchRepo … gen_test.go:291: ARG GOLANGCI_LINT_VERSION: generiert "v2.15.0" != Repo-Dockerfile "v2.14.0" (Drift, LH-QA-02)`; die Ursache ist die behauptete. a) nicht nachgefahren (Spiegelbild, symmetrische Vergleichszeile). c) Makefile-Pin: nur `freshness-golangci`, im Slice §3 benannt, nicht als in gates gedeckt zugesagt. d) falscher Digest: Lücke `pin-digest-ohne-waechter`, benannt (§3, §6, §8).
- (e) Emission: `golangciVersion = "v2.15.0"` in internal/gen/golang.go; in internal/emit/templates, gen-Tests und test/mutations/16 keine Fixture mit v2.14.0 (Grep oben); das Skelett pinnt Tag-only und wird mit v2.15.0 erzeugt, Wächter ist `TestGoProfile_PinsMatchRepo`.
- (f) Trigger-Audit: ADR-0003/0007/0008/0009/0088 und MR-002/007/014/048/050 nennen `golangci` (Kontext/Tool-Name), keine nennt v2.14.0 als Pin (nur benannt, nichts geändert). §3.5: Anheben auf den Nachfolger derselben Linie senkt keine Schwelle; Slice-Aussage stimmt.
- (g) Commit-Zuschnitt: 3 Dateien, nur Pin-Werte, keine Closure/Norm-Artefakte (§3.8/§3.10), kein Move (§3.3); Message nennt Kommando, Digest, Rolle, LH-QA-02/MR-048/ADR-0003 und die Nicht-Release-Grenze; keine Kommentare neu geschrieben (§3.7). Stempel `.harness/state/gates-passed.head` = `d198c4c8beddd70fa4533eb611c6be6fe62841a2` = HEAD.
- (h) `make mutate-auswahl` -> CI-Branch (Exit 10, kein Push): Der Slice verlangt in §2/§6 keine Mutations-Probe, sondern je Punkt ein rotes Kommando (`make freshness-golangci`, `TestGoProfile_PinsMatchRepo`, `make lint`). Die Auswahl über einen Pin-Diff ohne Fall in `test/mutations/` belegt nichts; nicht belegt ist damit nur, was kein Fall bindet (Makefile-Pin, Digest) — dieselbe benannte Lücke wie INFO-1, kein neuer Befund.

## Sensoren

`make lint`: Exit 0 · `make gates` am Ende: Exit 0.

## Geprüft, ohne Befund

Pin-Menge (a) · Digest-Form und -Wert (b) · Diff-Umfang, Suppression, `.golangci.yml` (c) · Rot-Beleg Dockerfile-ARG (d) · Emission/Fixtures (e) · §3.5-Einordnung und ADR/MR-Trigger (f) · Commit-Zuschnitt und Stempel (g) · Mutations-Probe (h) · Kommentare im Diff (§3.7: keine geschrieben).

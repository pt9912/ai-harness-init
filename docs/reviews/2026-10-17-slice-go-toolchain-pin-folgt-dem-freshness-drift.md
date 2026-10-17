# Review-Report: slice-go-toolchain-pin-folgt-dem-freshness-drift

**Datum:** 2026-10-17 · **Rolle:** Reviewer (frischer Kontext) · **Diff:** `ca2dd354` (Go 1.27.1 -> 1.27.2)
**Plan:** `slice-go-toolchain-pin-folgt-dem-freshness-drift` §1-§3 · **Bezug:** LH-QA-02, MR-048, ADR-0003, AGENTS.md §3.3/§3.5/§3.6/§3.7/§3.10
**Nicht geprueft:** DoD-Abhakung (Verifier).

## Summary

HIGH 0 · MEDIUM 0 · LOW 0 · INFO 1. Keine wiederkehrende Finding-Klasse.

## Findings

### INFO-1
- kategorie: INFO · quelle: Maintainability / BEO-ALL/pin-digest-ohne-waechter · pfad: harness/tools/smoke.sh:27, harness/tools/full-smoke.sh:156
- befund: Die Fallbacks `${GO_VERSION:-1.27.2}` haben keinen Wächter und tragen keinen Kommentar dazu; sie wirken nur bei direktem Skript-Aufruf, denn alle vier `make`-Rezepte (Makefile:218/225/231/236) übergeben `GO_VERSION='$(GO_VERSION)'`. Die Lücke ist im Slice (§1, §3, §6) ehrlich geführt; kein Code-Mangel.
- verifizierbar: nein · klasse: Doppelt geführter Pin-Wert ohne Kopplungs-Sensor (Folge-Slice `slice-doppelt-gefuehrte-werte-bekommen-ihren-kopplungs-sensor`)

## Ergebnis zu den Schwerpunkten

- (a) Vollständigkeit: die Suche nach `1.27.1` (ohne Baseline, Reviews, done/) nennt nur noch den Slice-Plan selbst (Z. 33, 51, 101) und die datierte Prosa in MR-092:33; README, docs/user, internal/emit/templates, .github, d-check.mk und go.mod tragen keinen Treffer. Die Bleibe-Entscheidungen stimmen.
- (b) Digest: `docker buildx imagetools inspect golang:1.27.2` -> MediaType `application/vnd.oci.image.index.v1+json`, `Digest: sha256:820153096fda4de6ac1b7194d12e416b7dd8f4e9a33d17e0345b111b945162d8` = Dockerfile:14. Der Vorgänger (`git show ca2dd354^:Dockerfile`, Z. 14) war ebenfalls `golang:${GO_VERSION}@sha256:…` (Index-Form); MR-048-Form gewahrt.
- (c) b2 selbst gefahren: Kopie von HEAD unter ~/.colima-tmp, nur `ARG GO_VERSION=1.27.1` zurückgedreht, `docker build --target test`, dann die Go-Tests von `./internal/gen/` gezielt auf `TestGoProfile_PinsMatchRepo` -> `--- FAIL … gen_test.go:291: ARG GO_VERSION: generiert "1.27.2" != Repo-Dockerfile "1.27.1" (Drift, LH-QA-02)`; die Ursache ist die behauptete. Makefile-Pin: nur `freshness-go` (Netz, nicht in `make gates`) hält ihn, im Slice §3 als Lücke benannt. Ein real existierender falscher Digest färbt nichts: Lücke `pin-digest-ohne-waechter`, benannt. Der Nullen-Digest-Bruch des Implementers wurde nicht nachgefahren (für den Befund unerheblich).
- (d) Fallbacks: siehe INFO-1; im Ziel nur bei ungesetztem GO_VERSION und direktem Skript-Aufruf wirksam, dann mit dem aktuellen Wert 1.27.2.
- (e) Emission: in internal/gen und internal/emit steht `DefaultGoVersion = "1.27.2"` und gen_test.go (synthetisch 1.27.3, Override-Test, vom Default unabhängig); keine Golden Files/Fixtures mit 1.27.1. Das Skelett wird mit 1.27.2 erzeugt.
- (f) §3.5: Patch-Anheben auf den Nachfolger derselben Linie senkt keine Schwelle; die Aussage im Slice stimmt. Trigger-Audit: in `docs/plan/adr` nennt keine Datei `GO_VERSION` oder `1.27`; kein ADR-Re-Evaluierungs-Trigger feuert durch Nennung (nur benannt).
- (g) Commit-Zuschnitt: 5 Dateien, nur Pin-Werte, keine Closure, keine Norm-Artefakte (§3.8/§3.10); Message nennt Kommando, Digest, Rolle, LH-QA-02/MR-048; keine Kommentare neu geschrieben (§3.7).
- (h) Stempel: `.harness/state/gates-passed.head` = `ca2dd3544bdff57e7797ea6fe0ff51da34acedd6` = HEAD.

## Sensoren

`make gates` am Ende: Exit 0.

## Geprüft, ohne Befund

Pin-Menge (a) · Digest-Form und -Wert (b) · Rot-Beleg Dockerfile-ARG (c) · Fallbacks/Emission (d, e) · §3.5-Einordnung und ADR-Trigger (f) · Commit-Zuschnitt (g) · Gate-Stempel (h) · Kommentare im Diff (§3.7: keine geschrieben).

#!/usr/bin/env bash
# smoke.sh — Tier-2 Bootstrap-Smoke (Host-Docker + Netz, NICHT in gates). Verifiziert,
# dass der Bootstrap end-to-end laeuft, host-orchestriert (die Binary ruft selbst
# `docker run <d-check> --print-mk`, generiert das Skelett lokal und fetcht die
# Baseline per Netz — kein DinD, kein Netz im Container). `make gates` bleibt
# offline-schlank (LH-QA-01); dieser Smoke
# gehoert an DoD-Verify/CI/Wellen-Closure.
#
# Belege:
#   1. Binary aus der artifact-Stage extrahieren (Host).
#   2. `--lang go` bootstrappen: Doc-Gate (Runtime-Codegen, slice-002) + Template-
#      Baseline (slice-003) + Sprachskelett-Generierung (slice-023, lokal/
#      deterministisch, kein Netz) + vendored Baseline mit Verifier (slice-022a,
#      Netz-Fetch: Release-Asset).
#   3. Skelett generiert? (slice-023-Generator-Beweis, .harness/skeleton/).
#   4. Emittiertes d-check laeuft und akzeptiert die Config (kein Config-Crash).
#
# NICHT geprueft: 0-Befunde-out-of-the-box (voller emittierter Green-Run). Die
# emittierten Templates tragen noch Vorwaerts-Verweise/Platzhalter (u. a. auf die
# Root-README) — sie gate-sicher zu machen ist LH-FA-01 Happy-Path = slice-005.
set -euo pipefail

GO_VERSION="${GO_VERSION:-1.26.4}"
tmpbin="$(mktemp -d)"
tmprepo="$(mktemp -d)"
cleanup() { rm -rf "$tmpbin" "$tmprepo"; }
trap cleanup EXIT
# mktemp -d liefert 0700; der d-check-Container laeuft als Nicht-Root und kann den
# 0700-Mount nicht traversieren. Ein echtes Adopter-Git-Repo hat 0755.
chmod 755 "$tmprepo"

echo "smoke: 1/5 Binary aus der artifact-Stage auf den Host extrahieren ..."
docker build --build-arg GO_VERSION="$GO_VERSION" \
	--target artifact --output "type=local,dest=$tmpbin" .

echo "smoke: 2/5 Bootstrap (--lang go): Doc-Gate + Templates + Skelett-Generierung (lokal) ..."
( cd "$tmprepo" && "$tmpbin/ai-harness-init" --lang go --name smoke )

echo "smoke: 3/5 Skelett an den Ziel-Root verdrahtet? (slice-004b) + Templates emittiert? (slice-022b) ..."
if [ ! -f "$tmprepo/Makefile" ] || [ ! -f "$tmprepo/go.mod" ]; then
	echo "smoke: FEHLER — Sprachskelett nicht an den Ziel-Root verdrahtet (Makefile/go.mod fehlt)" >&2
	exit 1
fi
if [ -d "$tmprepo/.harness/skeleton" ]; then
	echo "smoke: FEHLER — transientes .harness/skeleton/ nach der Verdrahtung nicht aufgeraeumt (slice-004b)" >&2
	exit 1
fi
# Dass run() die Template-Schicht ueberhaupt ablegt, beobachtete bis slice-026
# KEIN Sensor (Review-Befund slice-022b N-3): die run()-Unit-Tests enden bewusst
# am DocGate, also VOR dem Templates-Schritt. Hier ist die einzige Stelle, an der
# die volle Kette real laeuft — also gehoert die Beobachtung hierher, auf
# Tier 2 (DoD-Verify/CI), nicht in `make gates`.
# Je ein Vertreter der beiden Klassen aus LH-FA-02: Singleton -> .md,
# Wiederkehrendes -> verbatim .template.md.
for rel in AGENTS.md docs/plan/planning/slice.template.md; do
	if [ ! -f "$tmprepo/$rel" ]; then
		echo "smoke: FEHLER — Template-Schicht unvollstaendig: $rel fehlt" >&2
		exit 1
	fi
done
# Gegenprobe zur In-Scope-Regel. Geprueft werden die Namen, die der Emitter
# WIRKLICH schriebe — nicht die Quell-Namen: singletonTarget haengt ".md" an,
# wenn ".template.md" nicht greift, aus `README.md` wuerde also `README.md.md`.
# Die erste Fassung prueste `README.md` und war damit unter der Mutation, gegen
# die sie gerichtet ist, wirkungslos (Review-Befund slice-026 F-2 — Falsch-
# Beispiel 1 aus AGENTS Paragraph 3.6, woertlich).
for rel in README.md.md Makefile.md .d-check.yml.md project-readme.md .harness/skills/reviewer.md; do
	if [ -e "$tmprepo/$rel" ]; then
		echo "smoke: FEHLER — out-of-scope-Artefakt emittiert: $rel" >&2
		exit 1
	fi
done

echo "smoke: 4/5 emittiertes docs-check laeuft + akzeptiert die Config ..."
out="$(make -C "$tmprepo" -f d-check.mk docs-check 2>&1 || true)"
if ! printf '%s\n' "$out" | grep -q "geprüft"; then
	echo "smoke: FEHLER — d-check lief nicht (Config-Crash / halluzinierte Config?):" >&2
	printf '%s\n' "$out" >&2
	exit 1
fi
printf '%s\n' "$out" | grep -E "geprüft|Befund"

echo "smoke: 5/5 verdrahtetes Skelett am Ziel-Root: d-check.mk eingebunden + Go-Gates gruen? ..."
# slice-004b: das Skelett liegt jetzt am Ziel-Root, das Makefile bindet d-check.mk
# ein (MR-010) — ein make gates statt zweier Gate-Quellen. Verdrahtung strukturell:
if ! grep -q '^include d-check.mk$' "$tmprepo/Makefile"; then
	echo "smoke: FEHLER — generiertes Makefile bindet d-check.mk NICHT ein (MR-010-Verdrahtung fehlt)" >&2
	exit 1
fi
# E2E: die Go-Gates (lint/build/test) am Ziel-Root real gruen — NICHT `make gates`
# (das schliesst jetzt docs-check ein, das auf den noch unvollstaendigen Templates
# anschlaegt: 0 Befunde out-of-the-box ist slice-005/024, nicht hier). Belegt, dass
# die kuratiert-reiche .golangci.yml + main.go am Root zusammenpassen (Host-Docker).
skel_out="$( make -C "$tmprepo" lint build test 2>&1 )" || {
	echo "smoke: FEHLER — die Go-Gates des verdrahteten Skeletts sind rot (lint/build/test):" >&2
	printf '%s\n' "$skel_out" | tail -25 >&2
	exit 1
}

echo "smoke: OK — Bootstrap laeuft, Skelett an den Root verdrahtet (d-check.mk eingebunden) + Go-Gates gruen, Doc-Gate-Config valide."
echo "smoke: HINWEIS — voller make-gates-Green-Run im Ziel (inkl. docs-check) ist slice-005/024 (LH-FA-01)."
